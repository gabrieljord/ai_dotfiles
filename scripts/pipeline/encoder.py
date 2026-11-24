#!/usr/bin/env python3
"""
scripts/pipeline/encoder.py
===========================
Deterministic AST Encoder for voice-driven code dictation.
Parses raw Whisper transcript using a deterministic state-machine parser
guided by the sci-fi grammar lexicon (whisper/grammars/scifi_lexicon.json),
converting spoken text into an Intermediate Representation (JSON AST)
without relying on probabilistic LLM inference.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
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
                    val = val.strip().strip("'\"")
                    env_vars[key] = val
                    if key not in os.environ:
                        os.environ[key] = val
    except Exception as e:
        print(f"[encoder] WARN: Failed to read .env at {env_path}: {e}", file=sys.stderr)

    return env_vars


# Load environment variables on startup
LOADED_ENV = load_env_variables()


def find_lexicon_path() -> Optional[Path]:
    """Locate whisper/grammars/scifi_lexicon.json in the repository."""
    candidates = [
        REPO_ROOT / "whisper" / "grammars" / "scifi_lexicon.json",
        REPO_ROOT / "config" / "whisper" / "grammars" / "scifi_lexicon.json",
        Path.home() / ".config" / "ai_dotfiles" / "whisper" / "grammars" / "scifi_lexicon.json",
    ]
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    return None


def load_scifi_mappings() -> Tuple[Dict[str, str], Dict[str, str], Dict[str, str]]:
    """
    Load trigger mappings from scifi_lexicon.json.
    Returns:
        (trigger_to_intent, trigger_to_type, trigger_to_word)
    """
    # Core curated intent mappings ensuring strict specification compliance
    trigger_to_intent: Dict[str, str] = {
        # Function declarations
        "spark": "function_declaration",
        "core": "function_declaration",
        "forge": "function_declaration",
        "fn": "function_declaration",
        "def": "function_declaration",
        "func": "function_declaration",
        "function": "function_declaration",
        # Variables & constants
        "flux": "mutable_var",
        "var": "mutable_var",
        "variable": "mutable_var",
        "lock": "constant_declaration",
        "const": "constant_declaration",
        "constant": "constant_declaration",
        "bind": "variable_declaration",
        "let": "variable_declaration",
        # Structs, classes & interfaces
        "hull": "struct_declaration",
        "struct": "struct_declaration",
        "clan": "class_declaration",
        "class": "class_declaration",
        "port": "interface_declaration",
        "interface": "interface_declaration",
        # Modularity
        "dock": "import_statement",
        "import": "import_statement",
        "ship": "export_statement",
        "export": "export_statement",
        # Control flow & guard clauses
        "yield": "return_statement",
        "return": "return_statement",
        "guard": "guard_clause",
        "test": "if_statement",
        "if": "if_statement",
        "shift": "else_statement",
        "else": "else_statement",
        "step": "elif_statement",
        "elif": "elif_statement",
        "spin": "for_loop",
        "for": "for_loop",
        "hold": "while_loop",
        "while": "while_loop",
        "snap": "break_statement",
        "break": "break_statement",
        "skip": "continue_statement",
        "continue": "continue_statement",
        "scan": "match_statement",
        "match": "match_statement",
    }

    # Type primitive mappings
    trigger_to_type: Dict[str, str] = {
        "drift": "float",
        "float": "float",
        "twin": "double",
        "double": "double",
        "count": "int",
        "int": "int",
        "integer": "int",
        "strand": "string",
        "string": "string",
        "wire": "str",
        "str": "str",
        "bit": "bool",
        "bool": "bool",
        "boolean": "bool",
        "rune": "char",
        "char": "char",
        "byte": "byte",
        "void": "void",
        "pulse": "bool",
        "dead": "bool",
        "ray": "array",
        "vector": "vector",
        "chain": "list",
        "list": "list",
        "grid": "map",
        "vault": "dict",
        "dict": "dict",
        "dictionary": "dict",
        "ring": "set",
        "set": "set",
        "any": "any",
    }

    trigger_to_word: Dict[str, str] = {}

    lexicon_path = find_lexicon_path()
    if lexicon_path:
        try:
            with open(lexicon_path, "r", encoding="utf-8") as f:
                data = json.load(f)
                for word, entry in data.items():
                    trig = entry.get("trigger", "").lower()
                    w = entry.get("word", word).lower()
                    cat = entry.get("category", "")
                    if trig:
                        trigger_to_word[trig] = w
                        # Infer data types
                        if cat in ("Data Types", "Primitives") and trig not in trigger_to_type:
                            trigger_to_type[trig] = w
        except Exception as e:
            print(f"[encoder] WARN: Could not load scifi_lexicon.json: {e}", file=sys.stderr)

    return trigger_to_intent, trigger_to_type, trigger_to_word


TRIGGER_TO_INTENT, TRIGGER_TO_TYPE, TRIGGER_TO_WORD = load_scifi_mappings()

# Number words to digit string
NUMBER_WORDS: Dict[str, str] = {
    "zero": "0",
    "one": "1",
    "two": "2",
    "three": "3",
    "four": "4",
    "five": "5",
    "six": "6",
    "seven": "7",
    "eight": "8",
    "nine": "9",
    "ten": "10",
    "true": "true",
    "pulse": "true",
    "false": "false",
    "dead": "false",
    "null": "null",
    "none": "none",
    "void": "null",
}


def to_snake_case(words: List[str]) -> str:
    """Format list of words into snake_case."""
    cleaned = [re.sub(r"[^a-zA-Z0-9_]", "", w.lower()) for w in words]
    return "_".join(w for w in cleaned if w)


def to_camel_case(words: List[str]) -> str:
    """Format list of words into camelCase."""
    cleaned = [re.sub(r"[^a-zA-Z0-9]", "", w) for w in words]
    cleaned = [w for w in cleaned if w]
    if not cleaned:
        return ""
    return cleaned[0].lower() + "".join(w.capitalize() for w in cleaned[1:])


def to_pascal_case(words: List[str]) -> str:
    """Format list of words into PascalCase."""
    cleaned = [re.sub(r"[^a-zA-Z0-9]", "", w) for w in words]
    return "".join(w.capitalize() for w in cleaned if w)


def to_constant_case(words: List[str]) -> str:
    """Format list of words into CONSTANT_CASE."""
    cleaned = [re.sub(r"[^a-zA-Z0-9]", "", w.upper()) for w in words]
    return "_".join(w for w in cleaned if w)


def to_kebab_case(words: List[str]) -> str:
    """Format list of words into kebab-case."""
    cleaned = [re.sub(r"[^a-zA-Z0-9]", "", w.lower()) for w in words]
    return "-".join(w for w in cleaned if w)


def format_identifier(words: List[str], casing: Optional[str] = None) -> str:
    """Format identifier using specified casing or default snake_case."""
    if not words:
        return ""
    if casing == "__CAMEL_CASE__":
        return to_camel_case(words)
    elif casing == "__PASCAL_CASE__":
        return to_pascal_case(words)
    elif casing == "__CONSTANT_CASE__":
        return to_constant_case(words)
    elif casing == "__KEBAB_CASE__":
        return to_kebab_case(words)
    return to_snake_case(words)


def tokenize(text: str) -> List[str]:
    """
    Tokenize raw speech text into normalized tokens,
    collapsing multi-word compound phrases and casing triggers.
    """
    text = text.strip()
    # Normalize punctuation added by speech recognition
    text = re.sub(r"[,\.:;!?]", " ", text)
    text = text.lower()

    # Pre-collapse compound tokens and keywords
    replacements: List[Tuple[str, str]] = [
        (r"\bthin\s+arrow\b", "__THIN_ARROW__"),
        (r"\bfat\s+arrow\b", "__FAT_ARROW__"),
        (r"\barrow\s+func\b", "__FAT_ARROW__"),
        (r"\b->\b", "__THIN_ARROW__"),
        (r"\b=>\b", "__FAT_ARROW__"),
        (r"\bsnake\s+case\b", "__SNAKE_CASE__"),
        (r"\bcamel\s+case\b", "__CAMEL_CASE__"),
        (r"\bpascal\s+case\b", "__PASCAL_CASE__"),
        (r"\bconstant\s+case\b", "__CONSTANT_CASE__"),
        (r"\bscreaming\s+snake\b", "__CONSTANT_CASE__"),
        (r"\bkebab\s+case\b", "__KEBAB_CASE__"),
        (r"\bequals\s+equals\b", "__EQUALS_EQUALS__"),
        (r"\bis\s+equal\s+to\b", "__EQUALS_EQUALS__"),
        (r"\bnot\s+equals\b", "__NOT_EQUALS__"),
        (r"\bbang\s+equals\b", "__NOT_EQUALS__"),
        (r"\band\s+and\b", "__AND_AND__"),
        (r"\bor\s+or\b", "__OR_OR__"),
        (r"\bopen\s+paren\b", "__OPEN_PAREN__"),
        (r"\bclose\s+paren\b", "__CLOSE_PAREN__"),
        (r"\bopen\s+brace\b", "__OPEN_BRACE__"),
        (r"\bclose\s+brace\b", "__CLOSE_BRACE__"),
        (r"\bopen\s+bracket\b", "__OPEN_BRACKET__"),
        (r"\bclose\s+bracket\b", "__CLOSE_BRACKET__"),
        (r"\belse\s+if\b", "step"),
        (r"\bpoint\b", "."),
    ]

    for pattern, replacement in replacements:
        text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)

    tokens = [t for t in text.split() if t]
    return tokens


class StateMachineParser:
    """
    Deterministic state-machine parser that converts tokenized spoken input
    into an Intermediate Representation (JSON AST).
    """

    def __init__(self, tokens: List[str], raw_text: str):
        self.tokens = tokens
        self.raw_text = raw_text
        self.pos = 0
        self.length = len(tokens)

    def peek(self, offset: int = 0) -> Optional[str]:
        idx = self.pos + offset
        if 0 <= idx < self.length:
            return self.tokens[idx]
        return None

    def consume(self) -> str:
        tok = self.tokens[self.pos]
        self.pos += 1
        return tok

    def match(self, target: Union[str, Tuple[str, ...]]) -> bool:
        curr = self.peek()
        if not curr:
            return False
        if isinstance(target, tuple):
            return curr in target
        return curr == target

    def parse(self) -> Dict[str, Any]:
        """Main parse entry point."""
        if not self.tokens:
            return {"intent": "empty", "raw": ""}

        first_token = self.peek()
        intent = TRIGGER_TO_INTENT.get(first_token or "")

        if intent == "function_declaration":
            return self.parse_function()
        elif intent in ("mutable_var", "variable_declaration", "constant_declaration"):
            return self.parse_variable(intent)
        elif intent in ("struct_declaration", "class_declaration", "interface_declaration"):
            return self.parse_type_declaration(intent)
        elif intent == "guard_clause":
            return self.parse_guard()
        elif intent == "return_statement":
            return self.parse_return()
        elif intent == "import_statement":
            return self.parse_import()
        elif intent == "export_statement":
            return self.parse_export()
        elif intent in ("if_statement", "for_loop", "while_loop", "match_statement"):
            return self.parse_control_flow(intent)

        # Missing or unrecognized sci-fi lexicon triggers: treat as literal expression
        return {"intent": "literal", "raw": self.raw_text}

    def parse_function(self) -> Dict[str, Any]:
        """
        Parses function declaration:
        [spark|core|fn|def] <name> [with <params>] [thin arrow|to|returns <type>] [body...]
        """
        # Consume triggering token (e.g. spark, core, fn)
        self.consume()

        # Check for casing directive on function name
        casing: Optional[str] = None
        if self.peek() in ("__SNAKE_CASE__", "__CAMEL_CASE__", "__PASCAL_CASE__", "__CONSTANT_CASE__"):
            casing = self.consume()

        # Parse function name
        name_words: List[str] = []
        param_boundary_tokens = ("with", "parameters", "params", "takes", "__THIN_ARROW__", "to", "returns", "yields")
        body_boundary_triggers = ("guard", "yield", "return", "test", "if", "flux", "bind", "lock", "hull")

        while self.peek():
            curr = self.peek()
            if curr in param_boundary_tokens or curr in body_boundary_triggers:
                break
            name_words.append(self.consume())

        fn_name = format_identifier(name_words, casing) if name_words else "unnamed_function"

        params: List[Dict[str, str]] = []
        # Parse parameters if 'with' / 'params'
        if self.match(("with", "parameters", "params", "takes")):
            self.consume()  # consume 'with'
            params = self.parse_param_list()

        # Parse return type if return indicator present
        returns: Optional[str] = None
        if self.match(("__THIN_ARROW__", "to", "returns", "yields")):
            self.consume()  # consume arrow / to / returns
            ret_words: List[str] = []
            while self.peek():
                curr = self.peek()
                if curr in body_boundary_triggers:
                    break
                ret_words.append(self.consume())
            if ret_words:
                returns = self.resolve_type(ret_words[0])
            else:
                returns = "void"

        # Parse body statements if remaining tokens exist
        body: List[Dict[str, Any]] = []
        while self.peek():
            stmt = self.parse_body_statement()
            if stmt:
                body.append(stmt)
            else:
                break

        node: Dict[str, Any] = {
            "intent": "function_declaration",
            "name": fn_name,
        }
        if params:
            node["params"] = params
        if returns is not None:
            node["returns"] = returns
        node["body"] = body

        return node

    def parse_param_list(self) -> List[Dict[str, str]]:
        """Parses parameter sequences: <name> <type> [and / comma] ..."""
        params: List[Dict[str, str]] = []
        end_tokens = ("__THIN_ARROW__", "to", "returns", "yields", "guard", "yield", "return", "test")

        while self.peek() and self.peek() not in end_tokens:
            if self.match(("and", "comma", ",")):
                self.consume()
                continue

            param_casing: Optional[str] = None
            if self.peek() in ("__SNAKE_CASE__", "__CAMEL_CASE__"):
                param_casing = self.consume()

            name_tok = self.consume()
            p_name = format_identifier([name_tok], param_casing)

            # Check if next token is a recognized type or type trigger
            p_type = "any"
            if self.peek() and self.peek() not in end_tokens and self.peek() not in ("and", "comma", ","):
                type_tok = self.consume()
                p_type = self.resolve_type(type_tok)

            params.append({"name": p_name, "type": p_type})

        return params

    def parse_variable(self, intent: str) -> Dict[str, Any]:
        """
        Parses variable declarations:
        [flux|lock|bind] <name> [type] [assign <value>]
        """
        self.consume()  # consume trigger
        casing: Optional[str] = None
        if self.peek() in ("__SNAKE_CASE__", "__CAMEL_CASE__", "__PASCAL_CASE__", "__CONSTANT_CASE__"):
            casing = self.consume()

        name_words: List[str] = []
        while self.peek() and self.peek() not in ("assign", "equals", "=", "is", "drift", "count", "strand", "bit", "void"):
            name_words.append(self.consume())

        var_name = format_identifier(name_words, casing) if name_words else "unnamed_var"

        var_type: Optional[str] = None
        if self.peek() in TRIGGER_TO_TYPE:
            var_type = self.resolve_type(self.consume())

        value: Optional[str] = None
        if self.match(("assign", "equals", "=", "is")):
            self.consume()
            val_words: List[str] = []
            while self.peek():
                val_words.append(self.consume())
            value = self.normalize_value(val_words)

        res: Dict[str, Any] = {"intent": intent, "name": var_name}
        if var_type:
            res["type"] = var_type
        if value is not None:
            res["value"] = value
        return res

    def parse_guard(self) -> Dict[str, Any]:
        """
        Parses guard clauses:
        guard <condition> [fail|breach|raise|throw] <message>
        """
        self.consume()  # consume 'guard'
        cond_words: List[str] = []
        action = "fail"
        msg_words: List[str] = []

        while self.peek() and self.peek() not in ("fail", "breach", "raise", "throw"):
            cond_words.append(self.consume())

        condition = format_identifier(cond_words) if cond_words else "condition"

        if self.match(("fail", "breach", "raise", "throw")):
            action_tok = self.consume()
            action = "fail" if action_tok in ("fail", "breach") else action_tok
            while self.peek() and self.peek() not in ("yield", "return", "guard"):
                msg_words.append(self.consume())

        message = " ".join(msg_words) if msg_words else f"{condition} check failed"
        return {
            "intent": "guard_clause",
            "condition": condition,
            "action": action,
            "message": message,
        }

    def parse_return(self) -> Dict[str, Any]:
        """Parses return statement: [yield|return] <value>"""
        self.consume()
        val_words: List[str] = []
        while self.peek():
            val_words.append(self.consume())
        return {"intent": "return_statement", "value": self.normalize_value(val_words)}

    def parse_type_declaration(self, intent: str) -> Dict[str, Any]:
        """Parses struct/class/interface declaration."""
        self.consume()
        name_words: List[str] = []
        while self.peek() and self.peek() not in ("with", "parameters", "has"):
            name_words.append(self.consume())

        type_name = to_pascal_case(name_words) if name_words else "Item"
        fields: List[Dict[str, str]] = []
        if self.match(("with", "parameters", "has")):
            self.consume()
            fields = self.parse_param_list()

        return {"intent": intent, "name": type_name, "fields": fields}

    def parse_import(self) -> Dict[str, Any]:
        """Parses import statement: dock <module> [from <source>]"""
        self.consume()
        mod_words: List[str] = []
        while self.peek():
            mod_words.append(self.consume())
        return {"intent": "import_statement", "module": " ".join(mod_words)}

    def parse_export(self) -> Dict[str, Any]:
        """Parses export statement: ship <target>"""
        self.consume()
        target_words: List[str] = []
        while self.peek():
            target_words.append(self.consume())
        return {"intent": "export_statement", "target": " ".join(target_words)}

    def parse_control_flow(self, intent: str) -> Dict[str, Any]:
        """Parses control flow constructs (test/if, spin/for, hold/while)."""
        self.consume()
        cond_words: List[str] = []
        while self.peek() and self.peek() not in ("yield", "return", "snap", "skip", "body"):
            cond_words.append(self.consume())

        body: List[Dict[str, Any]] = []
        while self.peek():
            stmt = self.parse_body_statement()
            if stmt:
                body.append(stmt)
            else:
                break

        return {"intent": intent, "condition": " ".join(cond_words), "body": body}

    def parse_body_statement(self) -> Optional[Dict[str, Any]]:
        """Parses an individual statement within a function or block body."""
        if not self.peek():
            return None

        curr = self.peek()
        stmt_intent = TRIGGER_TO_INTENT.get(curr or "")

        if stmt_intent == "guard_clause":
            return self.parse_guard()
        elif stmt_intent == "return_statement":
            return self.parse_return()
        elif stmt_intent in ("mutable_var", "variable_declaration", "constant_declaration"):
            return self.parse_variable(stmt_intent)
        elif stmt_intent in ("if_statement", "for_loop", "while_loop"):
            return self.parse_control_flow(stmt_intent)
        elif curr in ("snap", "break"):
            self.consume()
            return {"intent": "break_statement"}
        elif curr in ("skip", "continue"):
            self.consume()
            return {"intent": "continue_statement"}

        # General statement fallback
        remaining: List[str] = []
        while self.peek() and self.peek() not in ("guard", "yield", "return", "test", "if"):
            remaining.append(self.consume())
        return {"intent": "expression", "value": " ".join(remaining)}

    def resolve_type(self, token: str) -> str:
        """Resolve sci-fi or programming type trigger to canonical type string."""
        tok = token.lower()
        if tok in TRIGGER_TO_TYPE:
            return TRIGGER_TO_TYPE[tok]
        if tok in TRIGGER_TO_WORD:
            word = TRIGGER_TO_WORD[tok]
            if word in TRIGGER_TO_TYPE:
                return TRIGGER_TO_TYPE[word]
            return word
        return tok

    def normalize_value(self, words: List[str]) -> str:
        """Normalize literal value expressions (numbers, strings, booleans)."""
        if not words:
            return ""

        # Check single numbers or boolean triggers
        if len(words) == 1:
            w = words[0].lower()
            if w in NUMBER_WORDS:
                return NUMBER_WORDS[w]
            if w in TRIGGER_TO_WORD:
                mapped = TRIGGER_TO_WORD[w]
                if mapped in NUMBER_WORDS:
                    return NUMBER_WORDS[mapped]
            if re.match(r"^\d+(\.\d+)?$", w):
                return w

        val_str = " ".join(words)
        # Check string literals (e.g. strand hello world -> "hello world")
        if words[0] in ("strand", "wire", "string", "str"):
            return f'"{val_str[len(words[0]):].strip()}"'

        return val_str


def encode_transcript_to_ir(raw_text: str) -> Dict[str, Any]:
    """
    Public API: Encodes raw Whisper text into deterministic JSON AST.
    """
    tokens = tokenize(raw_text)
    parser = StateMachineParser(tokens, raw_text)
    return parser.parse()


def main() -> None:
    parser = argparse.ArgumentParser(description="Deterministic Voice AST Encoder")
    parser.add_argument("input_text", nargs="?", default="", help="Raw transcribed speech text")
    parser.add_argument("--compact", action="store_true", help="Emit compact single-line JSON")
    args = parser.parse_args()

    input_text = args.input_text
    if not input_text:
        if not sys.stdin.isatty():
            input_text = sys.stdin.read().strip()

    if not input_text:
        print("{}", file=sys.stdout)
        sys.exit(0)

    ast = encode_transcript_to_ir(input_text)
    indent = None if args.compact else 2
    output = json.dumps(ast, indent=indent)
    print(output)


if __name__ == "__main__":
    main()
