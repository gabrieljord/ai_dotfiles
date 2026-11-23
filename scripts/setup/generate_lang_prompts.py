#!/usr/bin/env python3
"""
Generate comprehensive Whisper vocabulary prompts for all programming languages
recognized by GitHub Linguist (lib/linguist/languages.yml).

Usage:
    python3 scripts/setup/generate_lang_prompts.py [path_to_languages.yml] [output_env_file]
"""

import os
import re
import sys
import yaml

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(SCRIPT_DIR))
DEFAULT_YML = os.path.join(SCRIPT_DIR, "languages.yml")
DEFAULT_OUT = os.path.join(REPO_ROOT, "config", "prompts", "lang_prompts.env")

# ------------------------------------------------------------------------------
# 1. Curated High-Precision Domain Vocabularies for Top & Major Languages
# ------------------------------------------------------------------------------
CURATED_VOCABULARY = {
    # Tier 1 Popular Languages
    "Python": "Python, async, await, def, dict, list, tuple, snake_case, kwargs, args, self, cls, lambda, elif, None, True, False, import, from, return, yield, Exception, try, except, finally, with, __init__, str, int, float, bool, dataclass, pydantic",
    "Rust": "Rust, fn, mut, impl, struct, enum, Result, Option, match, Vec, pub, crate, use, let, const, static, trait, where, unsafe, loop, while, for, if, else, return, Ok, Err, Some, None, panic, cargo, println, borrow, reference, deref, lifetime, &'a",
    "TypeScript": "TypeScript, interface, type, const, let, function, return, export, import, from, async, await, Promise, undefined, null, boolean, string, number, any, unknown, never, readonly, class, implements, extends, arrow function, typeof, keyof",
    "TSX": "TypeScript, TSX, React, useState, useEffect, useContext, useMemo, useCallback, useRef, FC, JSX, props, className, onClick, children, fragment, component, return, interface, type, HTMLDivElement",
    "JavaScript": "JavaScript, ES6, const, let, var, function, return, async, await, Promise, import, export, default, class, extends, constructor, this, null, undefined, Object, Array, console.log, arrow function, callback, map, filter, reduce",
    "JSX": "JavaScript, JSX, React, useState, useEffect, component, props, className, onClick, return, div, span, button, input, form, render",
    "Go": "Go, golang, func, package, import, return, var, const, type, struct, interface, chan, select, defer, go, if, else, for, range, switch, case, default, nil, true, false, iota, make, len, cap, panic, recover, error, Goroutine, context.Context",
    "C": "C, printf, malloc, free, sizeof, NULL, typedef, struct, enum, union, include, stdio.h, stdlib.h, stdbool.h, int, char, void, float, double, pointer, return, size_t",
    "C++": "C++, cpp, std, vector, string, auto, template, typename, class, struct, public, private, protected, virtual, override, nullptr, constexpr, static_cast, dynamic_cast, namespace, using, include, int, void, double, float, bool, return, std::move, unique_ptr, shared_ptr",
    "C#": "C#, csharp, class, struct, interface, enum, record, namespace, using, public, private, protected, internal, async, await, Task, string, int, bool, var, new, return, get, set, LINQ, from, select, where, null, true, false, override, virtual",
    "Java": "Java, public, private, protected, class, interface, enum, record, extends, implements, package, import, void, int, boolean, String, new, return, static, final, try, catch, finally, throw, throws, null, true, false, this, super, List, Map, Set, Optional",
    "Kotlin": "Kotlin, fun, val, var, class, object, interface, enum, data class, sealed, companion object, package, import, override, suspend, coroutine, null, nullable, String, Int, Boolean, List, Map, return, when, is, in, lambda, it",
    "Swift": "Swift, func, let, var, class, struct, enum, protocol, extension, public, private, fileprivate, mutating, nonmutating, init, deinit, return, guard, if, else, switch, case, default, true, false, nil, Optional, some, any, async, await, actor, Task",
    "PHP": "PHP, function, class, public, private, protected, readonly, interface, trait, namespace, use, return, new, static, self, parent, null, true, false, array, string, int, bool, float, try, catch, throw, Exception, echo, foreach, as",
    "Ruby": "Ruby, def, end, class, module, attr_accessor, attr_reader, initialize, self, nil, true, false, if, else, elsif, unless, while, until, return, yield, block, proc, lambda, require, include, extend, puts, symbol, hash, array",
    "Scala": "Scala, def, val, var, class, trait, object, case class, sealed, package, import, override, implicit, using, given, match, case, yield, for, if, else, return, Option, Some, None, Either, Future, List, Vector, Map, type",

    # Functional Programming
    "Haskell": "Haskell, data, type, newtype, class, instance, where, let, in, do, case, of, if, then, else, import, qualified, as, module, deriving, Monad, Functor, Applicative, IO, Maybe, Just, Nothing, Either, Left, Right, pure, return",
    "Elixir": "Elixir, def, defp, defmodule, defmacro, defstruct, defprotocol, defimpl, fn, end, if, else, unless, cond, case, with, do, use, import, require, alias, atom, tuple, list, map, GenServer, Task, Agent, Repo, Enum, Stream",
    "Erlang": "Erlang, -module, -export, -record, -spec, fun, end, case, of, if, receive, after, catch, try, atom, tuple, list, binary, pid, spawn, send, gen_server, handle_call, handle_cast, ok, error",
    "Clojure": "Clojure, defn, defn-, def, let, fn, if, when, cond, loop, recur, do, quote, var, ns, require, use, atom, deref, swap!, reset!, map, filter, reduce, vector, hash-map, set, nil, true, false",
    "F#": "F#, let, rec, mut, type, module, open, match, with, function, fun, if, then, else, elif, val, member, inherit, interface, async, task, seq, list, array, Some, None, Ok, Error, Result, Option",
    "OCaml": "OCaml, let, rec, in, type, of, match, with, fun, function, if, then, else, module, struct, sig, end, open, include, val, external, exception, mutable, ref, List, Array, Option, Result",
    "Racket": "Racket, define, lambda, let, let*, cond, if, match, struct, module, provide, require, syntax-case, syntax-parse, for, for/list, cons, car, cdr, null, true, false",
    "Scheme": "Scheme, define, lambda, let, letrec, if, cond, case, and, or, begin, quote, quasiquote, unquote, set!, cons, car, cdr, list, null?, pair?, symbol?",
    "Common Lisp": "Common Lisp, defun, defmacro, defvar, defparameter, defstruct, defclass, defmethod, let, let*, lambda, if, when, unless, cond, case, loop, format, nil, t, cons, car, cdr, list",
    "Emacs Lisp": "Emacs Lisp, elisp, defun, defvar, defcustom, let, let*, lambda, if, when, unless, cond, while, dolist, dotimes, setq, interactive, provide, require, message, with-current-buffer",

    # Systems & Emerging Languages
    "Zig": "Zig, fn, pub, const, var, struct, enum, union, error, try, catch, defer, errdefer, comptime, inline, switch, while, for, if, else, return, unreachable, std, ArrayList, allocator, u8, u32, u64, usize, i32, bool, void, anyerror",
    "Nim": "Nim, proc, func, method, iterator, macro, template, type, var, let, const, import, from, export, if, elif, else, when, case, of, for, while, return, discard, echo, string, int, bool, seq, table",
    "D": "D, dlang, auto, void, int, string, bool, import, module, class, struct, interface, template, enum, immutable, const, pure, nothrow, @nogc, @safe, return, if, else, foreach, while, writeln",
    "V": "V, vlang, fn, pub, mut, struct, interface, enum, type, const, import, for, in, if, else, match, return, defer, unsafe, println, string, int, bool, array, map",
    "Crystal": "Crystal, def, end, class, struct, module, lib, fun, macro, nil, true, false, if, else, elsif, unless, while, until, return, yield, spawn, Channel, Fiber, getter, setter, property, puts",
    "Vala": "Vala, class, struct, interface, enum, delegate, signal, public, private, protected, construct, return, get, set, async, yield, var, string, int, bool, Gee, GLib, Object",
    "Gleam": "Gleam, pub, fn, let, assert, type, opaque, case, of, import, as, try, use, panic, todo, Nil, True, False, Ok, Error, Result, Int, Float, String, List",
    "Mojo": "Mojo, fn, def, struct, trait, alias, var, let, inout, owned, borrowed, raised, try, except, SIMD, DType, Tensor, Pointer, PythonInterface",
    "Carbon": "Carbon, fn, var, let, package, import, library, class, interface, impl, auto, match, case, default, if, else, while, for, return, bool, i32, f64, String",

    # Mobile & Scripting
    "Dart": "Dart, void, int, double, String, bool, var, final, const, class, abstract, interface, mixin, extends, implements, with, async, await, Future, Stream, Widget, BuildContext, StatelessWidget, StatefulWidget, return, if, else",
    "Lua": "Lua, function, end, local, nil, true, false, if, then, else, elseif, while, do, repeat, until, for, in, return, break, and, or, not, table, insert, remove, concat, print, require, pcall",
    "Perl": "Perl, my, our, state, sub, package, use, require, if, unless, elsif, else, while, until, for, foreach, return, print, die, warn, scalar, array, hash, regex, split, join",
    "R": "R, function, return, if, else, for, while, in, repeat, break, next, data.frame, matrix, vector, list, tibble, ggplot, tidyverse, dplyr, mutate, select, filter, c, library, require",
    "Julia": "Julia, function, end, struct, mutable struct, macro, abstract type, module, using, import, export, if, elseif, else, for, while, try, catch, finally, return, Array, Vector, Matrix, Float64, Int64, String, println",
    "Raku": "Raku, perl6, sub, method, class, role, grammar, token, rule, regex, my, our, has, if, with, without, loop, for, given, when, say, print",

    # Shell, Scripting & Automation
    "Shell": "bash, sh, zsh, echo, printf, if, then, elif, else, fi, for, in, do, done, while, until, case, esac, function, return, exit, export, local, readonly, set -euo pipefail, grep, sed, awk, cat, curl, jq, chmod, mkdir, rm",
    "Bash": "bash, sh, echo, printf, if, then, elif, else, fi, for, in, do, done, while, until, case, esac, function, return, exit, export, local, readonly, set -euo pipefail, grep, sed, awk, cat, curl, jq",
    "Zsh": "zsh, autoload, zparseopts, echo, printf, if, then, elif, else, fi, for, in, do, done, while, case, esac, function, return, exit, export, typeset, local",
    "Fish": "fish, function, end, if, else, switch, case, for, in, while, set, echo, test, return, exit, command, string, status",
    "PowerShell": "PowerShell, function, param, cmd, cmdlet, Get-, Set-, New-, Remove-, if, elseif, else, foreach, while, do, return, Write-Host, Write-Output, Write-Error, $true, $false, $null, [string], [int], [bool]",
    "Batchfile": "bat, cmd, echo, @echo off, rem, set, if, else, goto, call, pause, exit, for, in, do, shift, errorlevel",
    "Nushell": "nushell, nu, def, let, mut, if, else, loop, each, where, select, get, reject, insert, update, open, save, to, from, http, path, str, table",

    # Web & UI Markup
    "HTML": "HTML, doctype, html, head, title, body, div, span, header, footer, section, article, nav, a, href, img, src, button, input, form, table, tr, td, th, ul, ol, li, class, id, placeholder",
    "CSS": "CSS, selector, display, flex, grid, margin, padding, border, color, background, font-size, width, height, justify-content, align-items, media query, rem, px, calc, var, box-shadow, z-index",
    "SCSS": "SCSS, Sass, nesting, mixin, include, extend, variable, function, display, flex, grid, margin, padding, border, color, background",
    "Sass": "Sass, nesting, mixin, include, extend, variable, display, flex, grid, margin, padding, border, color",
    "Less": "Less, variables, mixins, nesting, operations, functions, namespaces, rulesets",
    "Svelte": "Svelte, script, style, main, onMount, createEventDispatcher, writable, readable, derived, bind:value, on:click, {#if}, {:else}, {#each}, {/each}, {#await}, export let",
    "Vue": "Vue, template, script, setup, style, scoped, ref, reactive, computed, watch, onMounted, v-if, v-else, v-for, v-model, v-on, v-bind, emit, defineProps, defineEmits",
    "Astro": "Astro, frontmatter, props, slot, client:load, client:visible, client:only, getStaticPaths, Markdown, component",

    # Shaders, Graphics & Hardware Description
    "GLSL": "GLSL, vertex, fragment, compute, precision, highp, uniform, in, out, inout, layout, location, vec2, vec3, vec4, mat3, mat4, sampler2D, texture, dot, cross, normalize, gl_Position, gl_FragColor",
    "HLSL": "HLSL, cbuffer, Texture2D, SamplerState, float2, float3, float4, float4x4, matrix, SV_POSITION, SV_Target, VertexShader, PixelShader, ComputeShader, mul, saturate, lerp",
    "WGSL": "WGSL, fn, var, let, const, override, struct, fn, return, vec2f, vec3f, vec4f, mat4x4f, binding, group, location, builtin, vertex, fragment, compute, workgroup_size",
    "Metal": "Metal, kernel, vertex, fragment, device, threadgroup, constant, thread, float2, float3, float4, float4x4, texture2d, sampler, stage_in, attribute, position",
    "CUDA": "CUDA, __global__, __device__, __host__, __shared__, __constant__, blockIdx, threadIdx, blockDim, gridDim, cudaMalloc, cudaFree, cudaMemcpy, __syncthreads, atomicAdd",
    "OpenCL": "OpenCL, __kernel, __global, __local, __constant, __private, get_global_id, get_local_id, get_global_size, get_local_size, barrier, cl_mem, clCreateBuffer",
    "Verilog": "Verilog, module, endmodule, input, output, inout, wire, reg, assign, always, posedge, negedge, begin, end, initial, parameter, localparam, if, else, case, endcase",
    "SystemVerilog": "SystemVerilog, module, interface, package, class, endclass, logic, bit, byte, int, typedef, struct, always_ff, always_comb, always_latch, assert, property, covergroup",
    "VHDL": "VHDL, entity, is, port, in, out, inout, end, architecture, of, is, begin, signal, process, variable, if, then, else, elsif, case, when, component, std_logic, std_logic_vector",

    # Smart Contracts & Blockchain
    "Solidity": "Solidity, pragma, contract, interface, library, struct, enum, function, public, private, external, internal, view, pure, payable, returns, mapping, address, uint256, bool, string, bytes, require, revert, assert, event, emit, modifier",
    "Vyper": "Vyper, @external, @internal, @view, @pure, def, struct, event, HashMap, DynArray, String, Bytes, address, uint256, bool, msg.sender, msg.value, assert, raise",
    "Cairo": "Cairo, starknet, contract, fn, trait, impl, struct, enum, felt252, u128, u256, ContractAddress, storage, event, external, view, assert, panic",
    "Move": "Move, module, script, struct, fun, public, entry, acquires, has, copy, drop, store, key, signer, address, u8, u64, u128, vector, borrow_global, move_to, assert!",

    # Data, Query & Configuration Formats
    "SQL": "SQL, SELECT, FROM, WHERE, JOIN, LEFT JOIN, INNER JOIN, RIGHT JOIN, GROUP BY, ORDER BY, HAVING, INSERT INTO, UPDATE, SET, DELETE, CREATE TABLE, ALTER TABLE, DROP, INDEX, PRIMARY KEY, FOREIGN KEY, NULL, AND, OR, NOT, IN, AS, COUNT, SUM, AVG, LIMIT, OFFSET",
    "PLpgSQL": "PLpgSQL, PostgreSQL, DECLARE, BEGIN, END, RAISE, NOTICE, EXCEPTION, PERFORM, EXECUTE, RETURN, NEXT, QUERY, FOR, LOOP, IF, THEN, ELSE, ELSIF",
    "TSQL": "TSQL, Transact-SQL, DECLARE, SET, SELECT, BEGIN, END, IF, ELSE, WHILE, TRY, CATCH, TRANSACTION, COMMIT, ROLLBACK, SP_, EXEC, OUTPUT",
    "PLSQL": "PLSQL, Oracle, DECLARE, BEGIN, END, EXCEPTION, WHEN, OTHERS, THEN, PROCEDURE, FUNCTION, CURSOR, OPEN, FETCH, CLOSE, FOR, LOOP",
    "GraphQL": "GraphQL, type, query, mutation, subscription, schema, input, interface, union, enum, scalar, fragment, on, directive, ID, String, Int, Float, Boolean",
    "JSON": "JSON, key, value, string, number, boolean, array, object, null, curly braces, square brackets, colon, comma",
    "YAML": "YAML, key, value, list, mapping, indent, colon, dash, boolean, string, number, dictionary",
    "TOML": "TOML, table, section, key, value, string, integer, boolean, array, inline table, brackets",
    "Markdown": "Markdown, heading, bullet list, ordered list, link, image, bold, italic, code block, backticks, blockquote, table, task list, frontmatter",
    "XML": "XML, tag, element, attribute, schema, namespace, xmlns, cdata, doctype, parser, node, child, parent",
    "SVG": "SVG, svg, path, d, stroke, fill, circle, cx, cy, r, rect, x, y, width, height, line, polygon, g, transform, viewBox",

    # DevOps, Tooling & Build Specs
    "Dockerfile": "Dockerfile, FROM, RUN, CMD, LABEL, EXPOSE, ENV, ADD, COPY, ENTRYPOINT, VOLUME, USER, WORKDIR, ARG, ONBUILD, STOPSIGNAL, HEALTHCHECK, SHELL",
    "Makefile": "Makefile, target, prerequisites, recipe, tab, variable, wildcard, phony, ifeq, ifneq, else, endif, make, clean, all, install",
    "CMake": "CMake, cmake_minimum_required, project, add_executable, add_library, target_link_libraries, target_include_directories, set, if, else, endif, find_package",
    "Terraform": "Terraform, HCL, resource, data, variable, output, provider, module, locals, terraform, backend, type, string, number, bool, list, map",
    "Protocol Buffer": "Protocol Buffer, protobuf, syntax, proto3, message, string, int32, int64, uint32, bool, bytes, repeated, optional, enum, service, rpc, returns",

    # Classical, Scientific & Historical
    "Assembly": "Assembly, asm, section, .text, .data, .bss, global, extern, mov, push, pop, call, ret, jmp, cmp, add, sub, mul, div, lea, eax, ebx, ecx, edx, rax, rbx, rsp, rbp",
    "Fortran": "Fortran, PROGRAM, SUBROUTINE, FUNCTION, MODULE, USE, IMPLICIT NONE, INTEGER, REAL, DOUBLE PRECISION, COMPLEX, LOGICAL, CHARACTER, DIMENSION, DO, WHILE, IF, THEN, ELSE, END",
    "COBOL": "COBOL, IDENTIFICATION DIVISION, ENVIRONMENT DIVISION, DATA DIVISION, PROCEDURE DIVISION, PROGRAM-ID, WORKING-STORAGE SECTION, PIC, 01, 05, DISPLAY, MOVE, PERFORM, UNTIL, IF, ELSE, STOP RUN",
    "Pascal": "Pascal, program, unit, uses, const, type, var, begin, end, procedure, function, if, then, else, case, of, while, do, repeat, until, for, to, downto, integer, boolean, string, real, writeln",
    "Delphi": "Delphi, unit, interface, implementation, uses, type, class, constructor, destructor, property, published, public, private, protected, override, virtual, begin, end",
    "Ada": "Ada, procedure, function, package, body, is, begin, end, type, subtype, record, access, constant, declare, loop, if, then, else, elsif, case, when, return, null, exception, pragma",
    "APL": "APL, vector, matrix, array, rho, iota, reduce, scan, compress, expand, outer product, inner product, quad, assignment",
    "BQN": "BQN, array, list, table, rank, shape, fold, scan, each, table, arithmetic, combinator",
    "Forth": "Forth, : (colon), ; (semicolon), DUP, DROP, SWAP, OVER, ROT, @ (fetch), ! (store), +, -, *, /, IF, ELSE, THEN, DO, LOOP, BEGIN, UNTIL, VARIABLE, CONSTANT",
    "Prolog": "Prolog, predicate, clause, rule, fact, query, cut, fail, true, false, assert, retract, atom, term, functor, unification, variable, member, append",
}

# ------------------------------------------------------------------------------
# 2. Paradigm Classifier for General Languages
# ------------------------------------------------------------------------------
def infer_domain_keywords(lang_name, meta):
    """
    Intelligently generates targeted keywords for any language based on its
    GitHub Linguist metadata (tm_scope, ace_mode, codemirror_mode, group, etc.).
    """
    scope = meta.get("tm_scope", "").lower()
    ace = meta.get("ace_mode", "").lower()
    group = meta.get("group", "")
    interpreters = meta.get("interpreters", [])

    # Group bias
    group_prefix = f"Group: {group}, " if group and group != lang_name else ""

    # Logic programming
    if "prolog" in scope or "prolog" in ace or "mercury" in lang_name.lower():
        return f"{lang_name}, {group_prefix}predicate, clause, fact, rule, goal, query, cut, fail, unify, atom, term, variable"

    # Hardware description / EDA
    if "verilog" in scope or "vhdl" in scope or "systemverilog" in scope or "hdl" in scope:
        return f"{lang_name}, {group_prefix}module, entity, architecture, process, signal, wire, reg, clock, reset, always, posedge, negedge, input, output, inout"

    # Shaders / GPU
    if "shader" in scope or "glsl" in ace or "hlsl" in ace:
        return f"{lang_name}, {group_prefix}vertex, fragment, compute, uniform, buffer, texture, sampler, vec2, vec3, vec4, mat4, layout, location, in, out"

    # Lisp family
    if "lisp" in scope or "lisp" in ace or "clojure" in ace or "scheme" in scope:
        return f"{lang_name}, {group_prefix}defun, defmacro, let, lambda, cons, car, cdr, list, quote, eval, nil, t, s-expression, parens"

    # ML / Typed Functional
    if "ocaml" in scope or "sml" in scope or "fsharp" in scope or "haskell" in scope:
        return f"{lang_name}, {group_prefix}type, val, let, rec, match, with, of, module, signature, pattern, fun, case, immutability"

    # Theorem Provers
    if any(tp in lang_name.lower() for tp in ["coq", "lean", "agda", "idris", "isabelle"]):
        return f"{lang_name}, {group_prefix}theorem, lemma, definition, proof, axiom, qed, inductive, type, prop, by"

    # Assembly / Low-level
    if "assembly" in scope or "asm" in ace or "disassembly" in lang_name.lower():
        return f"{lang_name}, {group_prefix}section, text, data, bss, global, extern, mov, push, pop, call, ret, jmp, cmp, add, sub, registers"

    # Shell / CLI scripting
    if "shell" in scope or "sh" in ace or any("sh" in interp for interp in interpreters):
        return f"{lang_name}, {group_prefix}echo, printf, export, env, exit, pipe, redirect, command, script, argument, flag, process"

    # Smart contracts / Blockchain
    if any(sc in lang_name.lower() for sc in ["solidity", "vyper", "cairo", "move", "clarity", "cadence", "scilla", "yul"]):
        return f"{lang_name}, {group_prefix}contract, function, public, private, view, pure, address, uint256, mapping, event, emit, require, state"

    # Data / Config
    if meta.get("type") == "data" or "json" in ace or "yaml" in ace or "xml" in ace:
        return f"{lang_name}, {group_prefix}key, value, object, array, list, mapping, boolean, string, number, null, indent"

    # Markup
    if meta.get("type") == "markup" or "html" in ace or "markdown" in ace:
        return f"{lang_name}, {group_prefix}tag, element, attribute, class, id, text, link, header, content"

    # Default General Programming Language
    return f"{lang_name}, {group_prefix}function, class, struct, method, variable, parameter, return, import, module, if, else, loop, string, integer, boolean"


# ------------------------------------------------------------------------------
# 3. Identifier Sanitizer (POSIX/Bash compliant variable names)
# ------------------------------------------------------------------------------
def sanitize_ident(s):
    """Converts a file extension or language name into a valid UPPERCASE bash identifier."""
    # Special naming overrides
    s = s.replace("c++", "cpp").replace("C++", "CPP")
    s = s.replace("c#", "cs").replace("C#", "CS")
    s = s.replace("f#", "fs").replace("F#", "FS")
    s = s.replace("q#", "qs").replace("Q#", "QS")
    s = s.replace("1c", "one_c").replace("1C", "ONE_C")
    s = s.replace("4d", "four_d").replace("4D", "FOUR_D")
    s = s.replace("+", "p").replace("#", "s")
    s = re.sub(r'[^a-zA-Z0-9_]', '_', s.lstrip('.'))
    s = re.sub(r'_+', '_', s).strip('_')
    if not s:
        s = "UNKNOWN"
    if s[0].isdigit():
        s = 'LANG_' + s
    return s.upper()


# ------------------------------------------------------------------------------
# 4. Main Generator
# ------------------------------------------------------------------------------
def main():
    yml_path = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_YML
    out_path = sys.argv[2] if len(sys.argv) > 2 else DEFAULT_OUT

    if not os.path.isfile(yml_path):
        print(f"Error: languages.yml not found at {yml_path}", file=sys.stderr)
        sys.exit(1)

    print(f"Reading GitHub Linguist specifications from: {yml_path}")
    with open(yml_path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)

    # Filter for all programming languages + coding-relevant markup/data
    prog_langs = {k: v for k, v in data.items() if v.get("type") == "programming"}
    extra_langs = {k: v for k, v in data.items() if v.get("type") in ("markup", "data") and (
        k in ("HTML", "CSS", "SCSS", "Sass", "Less", "Markdown", "XML", "SVG", "SQL", 
              "PLpgSQL", "TSQL", "PLSQL", "GraphQL", "JSON", "YAML", "TOML", "Dockerfile", 
              "Protocol Buffer", "Terraform", "Mermaid", "PlantUML", "Graphviz (DOT)")
        or "SQL" in k or "Template" in k or "Shader" in k
    )}
    target_langs = {**prog_langs, **extra_langs}

    print(f"Processing {len(target_langs)} target languages ({len(prog_langs)} programming + {len(extra_langs)} markup/data)...")

    # Map variables
    # Format: PROMPT_<ID>="value"
    # Secondary aliases: PROMPT_<ALIAS>="$PROMPT_<PRIMARY>"
    lines = []
    lines.append("# ==============================================================================")
    lines.append("# GitHub Linguist Dynamic Language Vocabulary Prompts for Whisper Speech-to-Text")
    lines.append("# ==============================================================================")
    lines.append("# This configuration contains initial_prompt strings for ALL programming languages")
    lines.append("# recognized by GitHub Linguist (570+ programming languages + markup & data formats).")
    lines.append("# Sourced by scripts/dictate.sh to bias Whisper token probabilities and eliminate")
    lines.append("# domain homophones during IDE voice dictation.")
    lines.append("#")
    lines.append("# Variable convention: PROMPT_<SANITIZED_EXTENSION_OR_LANGUAGE_NAME>")
    lines.append("# Fallback: PROMPT_DEFAULT")
    lines.append("# ==============================================================================\n")

    defined_vars = set()

    for name in sorted(target_langs.keys()):
        meta = target_langs[name]
        exts = meta.get("extensions", [])
        filenames = meta.get("filenames", [])
        aliases = meta.get("aliases", [])

        # Determine vocabulary string
        if name in CURATED_VOCABULARY:
            vocab = CURATED_VOCABULARY[name]
        else:
            vocab = infer_domain_keywords(name, meta)

        lines.append(f"# --- {name} ---")

        # Select primary variable
        primary_var = None
        if exts:
            primary_var = f"PROMPT_{sanitize_ident(exts[0])}"
        elif filenames:
            primary_var = f"PROMPT_{sanitize_ident(filenames[0])}"
        else:
            primary_var = f"PROMPT_{sanitize_ident(name)}"

        # Escape special characters that would be expanded in double-quoted bash strings
        vocab_escaped = vocab.replace('"', '\\"').replace('$', '\\$').replace('`', '\\`')

        # Emit primary definition
        if primary_var not in defined_vars:
            lines.append(f'{primary_var}="{vocab_escaped}"')
            defined_vars.add(primary_var)

        # Emit aliases for extensions
        for ext in exts:
            v = f"PROMPT_{sanitize_ident(ext)}"
            if v != primary_var and v not in defined_vars:
                lines.append(f'{v}="${primary_var}"')
                defined_vars.add(v)

        # Emit aliases for filenames (e.g. Dockerfile, Makefile, Procfile)
        for fn in filenames:
            v = f"PROMPT_{sanitize_ident(fn)}"
            if v != primary_var and v not in defined_vars:
                lines.append(f'{v}="${primary_var}"')
                defined_vars.add(v)

        # Emit alias for formal language name (e.g. PROMPT_PYTHON, PROMPT_RUST)
        lname_var = f"PROMPT_{sanitize_ident(name)}"
        if lname_var != primary_var and lname_var not in defined_vars:
            lines.append(f'{lname_var}="${primary_var}"')
            defined_vars.add(lname_var)

        # Emit aliases (e.g. golang, csharp, etc.)
        for alias in aliases:
            v = f"PROMPT_{sanitize_ident(alias)}"
            if v != primary_var and v not in defined_vars:
                lines.append(f'{v}="${primary_var}"')
                defined_vars.add(v)

        lines.append("")

    # Global Fallback
    lines.append("# ==============================================================================")
    lines.append("# Generic Default Fallback")
    lines.append("# ==============================================================================")
    lines.append('PROMPT_DEFAULT="code, programming, function, variable, parameter, argument, return, class, method, import, package, string, integer, float, boolean, null, undefined, true, false, if, else, loop, async, await, try, catch, snake_case, camelCase, PascalCase"\n')

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"Successfully generated {out_path} with {len(defined_vars)} mapped prompts covering {len(target_langs)} languages.")


if __name__ == "__main__":
    main()
