# Boilerplate & Command Grammar Rules

This grammar defines spoken macros for dates, template boilerplate, shell commands, and IDE menu operations. When recognized during dictation, the pipeline expands the rule into the target text or command.

---

## 1. Date & Time Macros

The pipeline expands temporal macros based on current system time:

| Spoken Trigger | Output Format | Example Expansion |
| :--- | :--- | :--- |
| `american date today` | `MM/DD/YYYY` | `11/23/2026` |
| `iso date today` / `date today` | `YYYY-MM-DD` | `2026-11-23` |
| `european date today` | `DD/MM/YYYY` | `23/11/2026` |
| `timestamp now` | `YYYY-MM-DD HH:MM:SS` | `2026-11-23 15:20:00` |
| `unix timestamp` | Epoch seconds | `1795530000` |

---

## 2. Language Boilerplate Macros

| Spoken Trigger | Target Language | Expanded Output |
| :--- | :--- | :--- |
| `shebang bash` | Bash / Shell | `#!/usr/bin/env bash`<br>`set -euo pipefail` |
| `shebang python` | Python | `#!/usr/bin/env python3` |
| `python main` / `dunder main` | Python | `if __name__ == "__main__":`<br>&nbsp;&nbsp;&nbsp;&nbsp;`main()` |
| `rust main` | Rust | `fn main() -> Result<(), Box<dyn std::error::Error>> {`<br>&nbsp;&nbsp;&nbsp;&nbsp;`Ok(())`<br>`}` |
| `react functional component <name>` | TSX / JSX | `interface <name>Props {}`<br><br>`export const <name>: React.FC<<name>Props> = (props) => {`<br>&nbsp;&nbsp;&nbsp;&nbsp;`return <div></div>;`<br>`};` |
| `header guard <name>` | C / C++ | `#ifndef <NAME>_H`<br>`#define <NAME>_H`<br><br>`#endif // <NAME>_H` |

---

## 3. Comments & Annotations

| Spoken Trigger | Output (Language Aware) |
| :--- | :--- |
| `todo comment <text>` | `// TODO: <text>` or `# TODO: <text>` |
| `fixme comment <text>` | `// FIXME: <text>` or `# FIXME: <text>` |
| `note comment <text>` | `// NOTE: <text>` or `# NOTE: <text>` |
| `section header <title>` | `// -----------------------------------------------------------------------------`<br>`// <title>`<br>`// -----------------------------------------------------------------------------` |
| `docstring <summary>` | Triple-quoted block (Python) or JSDoc/Rustdoc comment |

---

## 4. Git & Workflow Commands

| Spoken Trigger | Action / Text |
| :--- | :--- |
| `git commit feat <msg>` | `git commit -m "feat: <msg>"` |
| `git commit fix <msg>` | `git commit -m "fix: <msg>"` |
| `git status check` | `git status` |
| `git checkout branch <name>` | `git checkout -b <name>` |
