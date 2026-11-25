#!/usr/bin/env python3
"""
scripts/pipeline/decoder.py
===========================
LLM Decoder for voice-driven code dictation.
Accepts an Intermediate Representation (JSON AST) from encoder.py and
translates it into valid, idiomatic code for the specified target language
by querying the local Ollama API (http://localhost:11434/api/generate)
using a strict syntax compiler system prompt.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Union

# Resolve repository paths
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent


def find_env_file() -> Optional[Path]:
    """Locate project .env file in standard search locations."""
    candidates = [
        Path(os.environ.get("AI_DOTFILES_ENV", "")),
        REPO_ROOT / ".env",
        Path.cwd() / ".env",
        Path.home() / ".config" / "ai_dotfiles" / ".env",
    ]
    for candidate in candidates:
        if candidate and candidate.is_file():
            return candidate
    return None


def load_env_variables() -> Dict[str, str]:
    """Parse .env file into key-value dictionary."""
    env_vars: Dict[str, str] = {}
    env_path = find_env_file()
    if not env_path:
        return env_vars

    try:
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, val = line.split("=", 1)
                    key = key.strip()
                    val = val.strip()
                    if val and val[0] in ("'", '"') and val.endswith(val[0]):
                        val = val[1:-1]
                    elif "#" in val:
                        val = val.split("#", 1)[0].strip()
                    env_vars[key] = val
                    if key not in os.environ:
                        os.environ[key] = val
    except Exception as e:
        print(f"[decoder] WARN: Failed to read .env at {env_path}: {e}", file=sys.stderr)

    return env_vars


LOADED_ENV = load_env_variables()

# Configuration defaults from .env
LLM_PROVIDER = os.environ.get("LLM_PROVIDER", "ollama").strip().lower()
OLLAMA_ENDPOINT = os.environ.get("LOCAL_LLM_ENDPOINT", "http://localhost:11434").rstrip("/")
OLLAMA_MODEL = os.environ.get("LLM_MODEL_NAME", "llama3:8b-instruct-q8_0")
DEFAULT_GEMINI_MODEL = "gemini-4-hydrogen"
GEMINI_ENDPOINT = os.environ.get(
    "GEMINI_API_ENDPOINT", "https://generativelanguage.googleapis.com/v1beta"
).rstrip("/")
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "") or os.environ.get("LLM_API_KEY", "")
LLM_TIMEOUT = float(os.environ.get("LLM_TIMEOUT_SECONDS", "15"))
AGENT_CLI_TIMEOUT = float(os.environ.get("AGENT_CLI_TIMEOUT_SECONDS", "60"))

PROVIDER_DEFAULT_MODELS: Dict[str, str] = {
    "ollama": OLLAMA_MODEL,
    "gemini": DEFAULT_GEMINI_MODEL,
    "openai": "gpt-4o",
    "anthropic": "claude-sonnet-4-20250514",
    "openrouter": "anthropic/claude-sonnet-4",
    "lmstudio": "local-model",
    "openai-compatible": "local-model",
}

OPENAI_COMPATIBLE_PROVIDERS: Dict[str, Dict[str, Any]] = {
    "openai": {
        "endpoint_env": "OPENAI_API_ENDPOINT",
        "default_endpoint": "https://api.openai.com/v1",
        "key_envs": ("OPENAI_API_KEY", "LLM_API_KEY"),
        "require_key": True,
    },
    "openrouter": {
        "endpoint_env": "OPENROUTER_API_ENDPOINT",
        "default_endpoint": "https://openrouter.ai/api/v1",
        "key_envs": ("OPENROUTER_API_KEY", "LLM_API_KEY"),
        "require_key": True,
    },
    "lmstudio": {
        "endpoint_env": "LOCAL_LLM_ENDPOINT",
        "default_endpoint": "http://localhost:1234/v1",
        "key_envs": ("OPENAI_API_KEY", "LLM_API_KEY"),
        "require_key": False,
    },
    "openai-compatible": {
        "endpoint_env": "OPENAI_API_ENDPOINT",
        "default_endpoint": "http://localhost:8000/v1",
        "key_envs": ("OPENAI_API_KEY", "LLM_API_KEY"),
        "require_key": False,
    },
}

CLI_AGENT_PROVIDERS = {
    "agy",
    "antigravity",
    "claude-cli",
    "claude",
    "codex-cli",
    "codex",
    "gemini-cli",
    "aider",
    "opencode",
    "custom-cli",
}

SYSTEM_PROMPT = (
    "You are a syntax compiler. Translate the provided JSON AST into valid code "
    "for the target language. Output raw code only. No markdown formatting, "
    "no explanations, no conversational text."
)

LANGUAGE_MAP: Dict[str, str] = {
    "py": "Python 3",
    "python": "Python 3",
    "rs": "Rust",
    "rust": "Rust",
    "ts": "TypeScript",
    "typescript": "TypeScript",
    "js": "JavaScript",
    "javascript": "JavaScript",
    "go": "Go",
    "golang": "Go",
    "cpp": "C++",
    "cxx": "C++",
    "c": "C",
    "sh": "Bash",
    "bash": "Bash",
    "sql": "SQL",
    "json": "JSON",
    "html": "HTML",
    "css": "CSS",
    "rb": "Ruby",
    "java": "Java",
    "kt": "Kotlin",
}


def resolve_language_name(ext: str) -> str:
    """Normalize file extension to canonical language display name."""
    clean = ext.lower().lstrip(".")
    return LANGUAGE_MAP.get(clean, f"{clean.upper()} code")


def strip_markdown_fences(code: str) -> str:
    """Remove markdown code blocks, backticks, or conversational preamble."""
    cleaned = code.strip()
    # Match ```lang ... ``` blocks
    fence_pattern = r"^```[a-zA-Z0-9_-]*\s*\n(.*?)\n```$"
    match = re.match(fence_pattern, cleaned, flags=re.DOTALL)
    if match:
        cleaned = match.group(1).strip()
    else:
        # Strip standalone leading or trailing ``` lines
        lines = cleaned.splitlines()
        if lines and lines[0].strip().startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].strip().startswith("```"):
            lines = lines[:-1]
        cleaned = "\n".join(lines).strip()
    return cleaned


def deterministic_fallback_codegen(ir: Dict[str, Any], ext: str) -> str:
    """
    Deterministic code synthesizer for common AST intents used when
    Ollama service is temporarily offline or unreachable.
    """
    clean_ext = ext.lower().lstrip(".")
    intent = ir.get("intent", "")

    if intent == "function_declaration":
        name = ir.get("name", "function_name")
        params = ir.get("params", [])
        returns = ir.get("returns", "void")
        body = ir.get("body", [])

        if clean_ext in ("py", "python"):
            py_type_map = {"int": "int", "float": "float", "string": "str", "str": "str", "bool": "bool", "void": "None"}
            p_strs = [f"{p.get('name')}: {py_type_map.get(p.get('type', 'any'), 'Any')}" for p in params]
            ret_ann = f" -> {py_type_map.get(returns, 'None')}" if returns != "void" else ""
            lines = [f"def {name}({', '.join(p_strs)}){ret_ann}:"]
            if body:
                for b in body:
                    if b.get("intent") == "guard_clause":
                        lines.append(f"    if not {b.get('condition', 'True')}:")
                        lines.append(f"        raise ValueError(\"{b.get('message', 'validation error')}\")")
                    elif b.get("intent") == "return_statement":
                        lines.append(f"    return {b.get('value', 'None')}")
                    else:
                        lines.append(f"    {b.get('value', b.get('raw', 'pass'))}")
            else:
                lines.append("    pass")
            return "\n".join(lines)

        elif clean_ext in ("rs", "rust"):
            rs_type_map = {"int": "i32", "float": "f32", "double": "f64", "string": "String", "str": "&str", "bool": "bool", "void": "()"}
            p_strs = [f"{p.get('name')}: {rs_type_map.get(p.get('type', 'any'), 'i32')}" for p in params]
            ret_ann = f" -> {rs_type_map.get(returns, '()')}" if returns != "void" else ""
            lines = [f"pub fn {name}({', '.join(p_strs)}){ret_ann} {{"]
            if body:
                for b in body:
                    if b.get("intent") == "guard_clause":
                        lines.append(f"    if !{b.get('condition', 'true')} {{")
                        lines.append(f"        return Err(anyhow::anyhow!(\"{b.get('message', 'validation error')}\"));")
                        lines.append("    }")
                    elif b.get("intent") == "return_statement":
                        lines.append(f"    {b.get('value', '()')}")
                    else:
                        lines.append(f"    {b.get('value', b.get('raw', ''))};")
            else:
                lines.append("    todo!()")
            lines.append("}")
            return "\n".join(lines)

        elif clean_ext in ("ts", "typescript", "js", "javascript"):
            ts_type_map = {"int": "number", "float": "number", "string": "string", "str": "string", "bool": "boolean", "void": "void"}
            p_strs = [f"{p.get('name')}: {ts_type_map.get(p.get('type', 'any'), 'any')}" for p in params]
            ret_ann = f": {ts_type_map.get(returns, 'void')}" if clean_ext.startswith("t") else ""
            lines = [f"export function {name}({', '.join(p_strs)}){ret_ann} {{"]
            if body:
                for b in body:
                    if b.get("intent") == "guard_clause":
                        lines.append(f"    if (!{b.get('condition', 'true')}) {{")
                        lines.append(f"        throw new Error(\"{b.get('message', 'validation error')}\");")
                        lines.append("    }")
                    elif b.get("intent") == "return_statement":
                        lines.append(f"    return {b.get('value', 'null')};")
                    else:
                        lines.append(f"    {b.get('value', b.get('raw', ''))};")
            else:
                lines.append("    // Implementation")
            lines.append("}")
            return "\n".join(lines)

    elif intent in ("mutable_var", "variable_declaration", "constant_declaration"):
        name = ir.get("name", "var_name")
        val = ir.get("value", "None")
        if clean_ext in ("py", "python"):
            return f"{name} = {val}"
        elif clean_ext in ("rs", "rust"):
            prefix = "let mut" if intent == "mutable_var" else ("const" if intent == "constant_declaration" else "let")
            return f"{prefix} {name} = {val};"
        else:
            prefix = "let" if intent == "mutable_var" else ("const" if intent == "constant_declaration" else "let")
            return f"{prefix} {name} = {val};"

    elif intent == "guard_clause":
        cond = ir.get("condition", "condition")
        msg = ir.get("message", "invalid")
        if clean_ext in ("py", "python"):
            return f"if not {cond}:\n    raise ValueError(\"{msg}\")"
        else:
            return f"if (!{cond}) {{\n    throw new Error(\"{msg}\");\n}}"

    elif intent == "literal":
        return str(ir.get("raw", ""))

    elif intent == "empty":
        return ""

    elif intent == "code_correction":
        return str(ir.get("code", ""))

    return str(ir)


def _post_json(
    url: str,
    payload: Dict[str, Any],
    headers: Dict[str, str],
    timeout: float,
) -> Dict[str, Any]:
    """Send a JSON POST request and return the parsed JSON response."""
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers=headers, method="POST")
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def call_ollama(
    user_prompt: str,
    target_endpoint: str,
    target_model: str,
    timeout: float,
    system_prompt: str = SYSTEM_PROMPT,
) -> Optional[str]:
    """Query the local/remote Ollama /api/generate endpoint."""
    payload = {
        "model": target_model,
        "prompt": user_prompt,
        "system": system_prompt,
        "stream": False,
        "options": {
            "temperature": 0.0,  # Strict deterministic output
            "num_predict": 512,
        },
    }
    api_url = f"{target_endpoint}/api/generate"

    try:
        resp_json = _post_json(
            api_url,
            payload,
            headers={"Content-Type": "application/json"},
            timeout=timeout,
        )
        raw_output = resp_json.get("response", "")
        if raw_output:
            return strip_markdown_fences(raw_output)
    except urllib.error.URLError as e:
        print(f"[decoder] WARN: Ollama connection to {api_url} failed: {e}. Utilizing deterministic fallback.", file=sys.stderr)
    except Exception as e:
        print(f"[decoder] WARN: Decoder error querying Ollama: {e}. Utilizing deterministic fallback.", file=sys.stderr)

    return None


def call_gemini(
    user_prompt: str,
    target_model: str,
    api_key: str,
    timeout: float,
    base_endpoint: str = GEMINI_ENDPOINT,
    system_prompt: str = SYSTEM_PROMPT,
) -> Optional[str]:
    """Query the Google Gemini generateContent REST API."""
    if not api_key:
        print("[decoder] WARN: GEMINI_API_KEY is not set. Utilizing deterministic fallback.", file=sys.stderr)
        return None

    encoded_model = urllib.parse.quote(target_model, safe="")
    api_url = f"{base_endpoint}/models/{encoded_model}:generateContent"
    payload = {
        "system_instruction": {"parts": [{"text": system_prompt}]},
        "contents": [{"role": "user", "parts": [{"text": user_prompt}]}],
        "generationConfig": {
            "temperature": 0.0,
            "maxOutputTokens": 512,
        },
    }

    try:
        resp_json = _post_json(
            api_url,
            payload,
            headers={
                "Content-Type": "application/json",
                "x-goog-api-key": api_key,
            },
            timeout=timeout,
        )
        candidates = resp_json.get("candidates") or []
        if candidates:
            parts = (candidates[0].get("content") or {}).get("parts") or []
            raw_output = "".join(part.get("text", "") for part in parts)
            if raw_output:
                return strip_markdown_fences(raw_output)
        print("[decoder] WARN: Gemini response contained no text candidates. Utilizing deterministic fallback.", file=sys.stderr)
    except urllib.error.HTTPError as e:
        err_body = ""
        try:
            err_body = e.read().decode("utf-8", errors="replace").strip()
        except Exception:
            pass
        detail = f" ({err_body})" if err_body else ""
        print(f"[decoder] WARN: Gemini API HTTP {e.code} error: {e.reason}{detail}. Utilizing deterministic fallback.", file=sys.stderr)
    except urllib.error.URLError as e:
        print(f"[decoder] WARN: Gemini connection failed: {e}. Utilizing deterministic fallback.", file=sys.stderr)
    except Exception as e:
        print(f"[decoder] WARN: Decoder error querying Gemini: {e}. Utilizing deterministic fallback.", file=sys.stderr)

    return None


def _resolve_first_env(keys: Tuple[str, ...]) -> str:
    for key in keys:
        val = os.environ.get(key, "").strip()
        if val:
            return val
    return ""


def call_openai_compatible(
    provider_name: str,
    user_prompt: str,
    target_model: str,
    timeout: float,
    endpoint_override: Optional[str] = None,
    system_prompt: str = SYSTEM_PROMPT,
) -> Optional[str]:
    """Query an OpenAI or OpenAI-compatible /chat/completions endpoint."""
    spec = OPENAI_COMPATIBLE_PROVIDERS[provider_name]
    base_url = (
        endpoint_override
        or os.environ.get(spec["endpoint_env"], "")
        or spec["default_endpoint"]
    ).rstrip("/")
    if not base_url.endswith("/v1") and provider_name == "lmstudio":
        base_url = f"{base_url}/v1"
    api_url = f"{base_url}/chat/completions"

    api_key = _resolve_first_env(spec["key_envs"])
    if spec["require_key"] and not api_key:
        print(f"[decoder] WARN: {spec['key_envs'][0]} is not set for {provider_name}. Utilizing deterministic fallback.", file=sys.stderr)
        return None

    headers = {"Content-Type": "application/json"}
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"

    payload = {
        "model": target_model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        "temperature": 0.0,
        "max_tokens": 512,
    }

    try:
        resp_json = _post_json(api_url, payload, headers=headers, timeout=timeout)
        choices = resp_json.get("choices") or []
        if choices:
            raw_output = ((choices[0].get("message") or {}).get("content")) or ""
            if raw_output:
                return strip_markdown_fences(raw_output)
        print(f"[decoder] WARN: {provider_name} response contained no choices. Utilizing deterministic fallback.", file=sys.stderr)
    except urllib.error.HTTPError as e:
        err_body = ""
        try:
            err_body = e.read().decode("utf-8", errors="replace").strip()
        except Exception:
            pass
        detail = f" ({err_body})" if err_body else ""
        print(f"[decoder] WARN: {provider_name} API HTTP {e.code} error: {e.reason}{detail}. Utilizing deterministic fallback.", file=sys.stderr)
    except urllib.error.URLError as e:
        print(f"[decoder] WARN: {provider_name} connection failed: {e}. Utilizing deterministic fallback.", file=sys.stderr)
    except Exception as e:
        print(f"[decoder] WARN: Decoder error querying {provider_name}: {e}. Utilizing deterministic fallback.", file=sys.stderr)

    return None


def call_anthropic(
    user_prompt: str,
    target_model: str,
    api_key: str,
    timeout: float,
    base_endpoint: Optional[str] = None,
    system_prompt: str = SYSTEM_PROMPT,
) -> Optional[str]:
    """Query the Anthropic Messages REST API."""
    if not api_key:
        print("[decoder] WARN: ANTHROPIC_API_KEY is not set. Utilizing deterministic fallback.", file=sys.stderr)
        return None

    endpoint = (
        base_endpoint
        or os.environ.get("ANTHROPIC_API_ENDPOINT", "https://api.anthropic.com")
    ).rstrip("/")
    api_url = f"{endpoint}/v1/messages"
    payload = {
        "model": target_model,
        "system": system_prompt,
        "messages": [{"role": "user", "content": user_prompt}],
        "temperature": 0.0,
        "max_tokens": 512,
    }
    headers = {
        "Content-Type": "application/json",
        "x-api-key": api_key,
        "anthropic-version": os.environ.get("ANTHROPIC_API_VERSION", "2023-06-01"),
    }

    try:
        resp_json = _post_json(api_url, payload, headers=headers, timeout=timeout)
        content_blocks = resp_json.get("content") or []
        raw_output = "".join(
            block.get("text", "") for block in content_blocks if block.get("type") == "text"
        )
        if raw_output:
            return strip_markdown_fences(raw_output)
        print("[decoder] WARN: Anthropic response contained no text blocks. Utilizing deterministic fallback.", file=sys.stderr)
    except urllib.error.HTTPError as e:
        err_body = ""
        try:
            err_body = e.read().decode("utf-8", errors="replace").strip()
        except Exception:
            pass
        detail = f" ({err_body})" if err_body else ""
        print(f"[decoder] WARN: Anthropic API HTTP {e.code} error: {e.reason}{detail}. Utilizing deterministic fallback.", file=sys.stderr)
    except urllib.error.URLError as e:
        print(f"[decoder] WARN: Anthropic connection failed: {e}. Utilizing deterministic fallback.", file=sys.stderr)
    except Exception as e:
        print(f"[decoder] WARN: Decoder error querying Anthropic: {e}. Utilizing deterministic fallback.", file=sys.stderr)

    return None


def _build_cli_agent_command(
    provider_name: str,
    combined_prompt: str,
    target_model: Optional[str],
) -> Tuple[Optional[List[str]], Optional[str]]:
    """Build (argv, stdin_text) for a supported CLI coding agent."""
    cont = os.environ.get("AGENT_CLI_CONTINUE", "false").strip().lower() == "true"
    conv_id = os.environ.get("AGENT_CLI_CONVERSATION_ID", "").strip()

    if provider_name == "custom-cli":
        template = os.environ.get("AGENT_CLI_CMD", "").strip()
        if not template:
            print("[decoder] WARN: AGENT_CLI_CMD is not set for custom-cli. Utilizing deterministic fallback.", file=sys.stderr)
            return None, None
        parts = shlex.split(template)
        uses_placeholder = any("{prompt}" in p or "{model}" in p for p in parts)
        cmd = [
            p.replace("{prompt}", combined_prompt).replace("{model}", target_model or "")
            for p in parts
        ]
        stdin_text = None if any("{prompt}" in p for p in parts) else combined_prompt
        if not uses_placeholder:
            stdin_text = combined_prompt
        return cmd, stdin_text

    if provider_name in ("agy", "antigravity"):
        cmd = ["agy", "--output-format", "text"]
        if conv_id:
            cmd.extend(["--conversation", conv_id])
        elif cont:
            cmd.append("--continue")
        if target_model:
            cmd.extend(["--model", target_model])
        cmd.extend(["-p", combined_prompt])
        return cmd, None

    if provider_name in ("claude-cli", "claude"):
        cmd = ["claude", "--output-format", "text"]
        if conv_id:
            cmd.extend(["--resume", conv_id])
        elif cont:
            cmd.append("--continue")
        if target_model:
            cmd.extend(["--model", target_model])
        cmd.extend(["-p", combined_prompt])
        return cmd, None

    if provider_name in ("codex-cli", "codex"):
        cmd = ["codex", "exec"]
        if target_model:
            cmd.extend(["--model", target_model])
        cmd.append(combined_prompt)
        return cmd, None

    if provider_name == "gemini-cli":
        cmd = ["gemini"]
        if target_model:
            cmd.extend(["--model", target_model])
        cmd.extend(["-p", combined_prompt])
        return cmd, None

    if provider_name == "aider":
        cmd = ["aider", "--yes", "--no-git"]
        if target_model:
            cmd.extend(["--model", target_model])
        cmd.extend(["--message", combined_prompt])
        return cmd, None

    if provider_name == "opencode":
        cmd = ["opencode", "run"]
        if target_model:
            cmd.extend(["--model", target_model])
        cmd.append(combined_prompt)
        return cmd, None

    return None, None


def call_cli_agent(
    provider_name: str,
    user_prompt: str,
    target_model: Optional[str],
    timeout: float,
    system_prompt: str = SYSTEM_PROMPT,
) -> Optional[str]:
    """Invoke a local CLI agent (agy, claude-cli, codex-cli, gemini-cli, aider, opencode, custom-cli)."""
    combined_prompt = f"{system_prompt}\n\n{user_prompt}" if system_prompt else user_prompt
    cmd, stdin_text = _build_cli_agent_command(provider_name, combined_prompt, target_model)
    if not cmd:
        return None

    binary = cmd[0]
    if not shutil.which(binary):
        print(f"[decoder] WARN: CLI agent binary '{binary}' not found in PATH. Utilizing deterministic fallback.", file=sys.stderr)
        return None

    try:
        res = subprocess.run(
            cmd,
            input=stdin_text,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        if res.returncode == 0:
            raw_output = res.stdout.strip()
            if raw_output:
                return strip_markdown_fences(raw_output)
            print(f"[decoder] WARN: CLI agent '{binary}' returned empty output. Utilizing deterministic fallback.", file=sys.stderr)
        else:
            err = (res.stderr or res.stdout or "").strip()
            print(f"[decoder] WARN: CLI agent '{binary}' exited with {res.returncode}: {err}. Utilizing deterministic fallback.", file=sys.stderr)
    except subprocess.TimeoutExpired:
        print(f"[decoder] WARN: CLI agent '{binary}' timed out after {timeout}s. Utilizing deterministic fallback.", file=sys.stderr)
    except Exception as e:
        print(f"[decoder] WARN: Failed running CLI agent '{binary}': {e}. Utilizing deterministic fallback.", file=sys.stderr)

    return None


def dispatch_llm(
    user_prompt: str,
    system_prompt: str = SYSTEM_PROMPT,
    endpoint: Optional[str] = None,
    model: Optional[str] = None,
    provider: Optional[str] = None,
) -> Optional[str]:
    """Route a prompt to the configured LLM API provider or CLI agent."""
    target_provider = (provider or os.environ.get("LLM_PROVIDER", LLM_PROVIDER)).strip().lower()
    target_endpoint = (endpoint or OLLAMA_ENDPOINT).rstrip("/")
    default_model = PROVIDER_DEFAULT_MODELS.get(target_provider, OLLAMA_MODEL)
    target_model = model or os.environ.get("LLM_MODEL_NAME") or default_model

    if target_provider in CLI_AGENT_PROVIDERS:
        cli_model = model or os.environ.get("AGENT_CLI_MODEL", "").strip() or None
        return call_cli_agent(
            target_provider, user_prompt, cli_model, AGENT_CLI_TIMEOUT, system_prompt=system_prompt
        )
    if target_provider == "gemini":
        api_key = os.environ.get("GEMINI_API_KEY", "") or os.environ.get("LLM_API_KEY", "") or GEMINI_API_KEY
        return call_gemini(user_prompt, target_model, api_key, LLM_TIMEOUT, system_prompt=system_prompt)
    if target_provider == "anthropic":
        api_key = os.environ.get("ANTHROPIC_API_KEY", "") or os.environ.get("LLM_API_KEY", "")
        return call_anthropic(
            user_prompt, target_model, api_key, LLM_TIMEOUT, base_endpoint=endpoint, system_prompt=system_prompt
        )
    if target_provider in OPENAI_COMPATIBLE_PROVIDERS:
        return call_openai_compatible(
            target_provider,
            user_prompt,
            target_model,
            LLM_TIMEOUT,
            endpoint_override=endpoint,
            system_prompt=system_prompt,
        )
    return call_ollama(user_prompt, target_endpoint, target_model, LLM_TIMEOUT, system_prompt=system_prompt)


def decode(
    ir: Union[Dict[str, Any], str],
    ext: str,
    correction: Optional[str] = None,
    endpoint: Optional[str] = None,
    model: Optional[str] = None,
    provider: Optional[str] = None,
) -> str:
    """
    Translates JSON AST into clean source code for the given extension via the configured LLM provider or CLI agent.
    """
    clean_ext = ext.lower().lstrip(".")
    lang_name = resolve_language_name(clean_ext)

    # Ensure ir is dictionary for processing
    if isinstance(ir, str):
        try:
            ir_dict = json.loads(ir)
        except Exception:
            ir_dict = {"intent": "literal", "raw": ir}
    else:
        ir_dict = ir

    # Construct user prompt
    prompt_parts = [
        f"Target Language: {lang_name} (file extension: .{clean_ext})",
        "",
        "JSON AST Intermediate Representation:",
        json.dumps(ir_dict, indent=2),
    ]

    if correction:
        prompt_parts.extend([
            "",
            "Correction Request / Compiler Errors to Resolve:",
            correction,
            "Ensure the output strictly resolves this compiler/linter error while preserving the AST semantics.",
        ])

    user_prompt = "\n".join(prompt_parts)
    decoded = dispatch_llm(
        user_prompt=user_prompt,
        system_prompt=SYSTEM_PROMPT,
        endpoint=endpoint,
        model=model,
        provider=provider,
    )

    if decoded is not None:
        return decoded

    # Fallback when LLM service is unreachable or unconfigured
    return deterministic_fallback_codegen(ir_dict, clean_ext)


def main() -> None:
    parser = argparse.ArgumentParser(description="LLM Syntax Decoder (JSON AST -> Source Code)")
    parser.add_argument("input_data", nargs="?", default="", help="JSON AST string or file path")
    parser.add_argument("-e", "--ext", default="py", help="Target file extension (e.g. py, rs, ts)")
    parser.add_argument("--correction", default=None, help="Linter correction prompt for retries")
    parser.add_argument("--model", default=None, help="Override LLM model name")
    parser.add_argument("--endpoint", default=None, help="Override API endpoint")
    parser.add_argument("--provider", default=None, help="Override LLM provider or CLI agent")
    parser.add_argument("--raw-prompt", action="store_true", help="Send input directly as a text prompt instead of JSON AST")
    parser.add_argument("--system-prompt-file", default=None, help="Path to custom system prompt file (for --raw-prompt)")
    args = parser.parse_args()

    input_data = args.input_data
    if not input_data:
        if not sys.stdin.isatty():
            input_data = sys.stdin.read().strip()

    if not input_data:
        print("[decoder] Error: No input provided.", file=sys.stderr)
        sys.exit(1)

    if args.raw_prompt:
        sys_prompt = SYSTEM_PROMPT
        if args.system_prompt_file:
            with open(args.system_prompt_file, "r", encoding="utf-8") as f:
                sys_prompt = f.read()
        result = dispatch_llm(
            user_prompt=input_data,
            system_prompt=sys_prompt,
            endpoint=args.endpoint,
            model=args.model,
            provider=args.provider,
        )
        if result is None:
            sys.exit(1)
        print(result)
        return

    # Check if input is a path to a JSON file
    if os.path.isfile(input_data):
        with open(input_data, "r", encoding="utf-8") as f:
            input_data = f.read().strip()

    code = decode(
        ir=input_data,
        ext=args.ext,
        correction=args.correction,
        endpoint=args.endpoint,
        model=args.model,
        provider=args.provider,
    )
    print(code)


if __name__ == "__main__":
    main()
