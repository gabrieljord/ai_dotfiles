# Code Talker Grammar Rules

This grammar defines voice dictation mappings for programming symbols, casing styles, and language constructs. The LLM prompt optimizer and code generator reference these rules to translate raw spoken input into syntactically valid source code.

---

## 1. Casing Conventions

Dictate the casing trigger followed by the words to format:

| Spoken Trigger | Example Dictation | Output Code |
| :--- | :--- | :--- |
| `snake case <phrase>` | `snake case get user by id` | `get_user_by_id` |
| `camel case <phrase>` | `camel case fetch customer data` | `fetchCustomerData` |
| `pascal case <phrase>` | `pascal case auth token provider` | `AuthTokenProvider` |
| `screaming snake <phrase>` / `constant case <phrase>` | `constant case max retry count` | `MAX_RETRY_COUNT` |
| `kebab case <phrase>` | `kebab case header nav item` | `header-nav-item` |
| `dot case <phrase>` | `dot case user profile service` | `user.profile.service` |

---

## 2. Punctuation & Brackets

| Spoken Phrase | Rendered Symbol | Context / Usage |
| :--- | :--- | :--- |
| `open paren` / `close paren` | `(` / `)` | Function parameters, expressions |
| `parens <phrase>` | `(<phrase>)` | Auto-encloses phrase in parentheses |
| `open brace` / `close brace` / `curly` | `{` / `}` | Code blocks, object literals, dictionaries |
| `curlies <phrase>` | `{ <phrase> }` | Auto-encloses phrase in braces |
| `open bracket` / `close bracket` / `square` | `[` / `]` | Array indexing, list literals |
| `brackets <phrase>` | `[<phrase>]` | Auto-encloses phrase in brackets |
| `open angle` / `close angle` | `<` / `>` | Generics, templates, comparisons |
| `angles <phrase>` | `<<phrase>>` | Generics, e.g. `<T>` |
| `semi` / `semicolon` | `;` | Statement terminator |
| `colon` / `two dots` | `:` | Type annotations, key-value, slices |
| `colon colon` / `double colon` | `::` | Rust/C++ namespace resolution |
| `comma` | `,` | Argument separator |
| `dot` / `period` | `.` | Member access, method calls |
| `single quote` / `quote` | `'` | String literal |
| `double quote` / `quotes` | `"` | String literal |
| `backtick` / `tick` | `` ` `` | Template literal |
| `triple backticks` | ` ``` ` | Multi-line string or markdown code block |

---

## 3. Operators & Logic

| Spoken Phrase | Rendered Symbol |
| :--- | :--- |
| `arrow func` / `fat arrow` | `=>` |
| `thin arrow` / `returns` | `->` |
| `equals` / `assign` | `=` |
| `equals equals` / `is equal to` | `==` (or `===` in JS/TS) |
| `triple equals` / `strictly equals` | `===` |
| `not equals` / `bang equals` | `!=` (or `!==` in JS/TS) |
| `bang` / `not` | `!` |
| `plus` / `minus` / `times` / `divide` | `+` / `-` / `*` / `/` |
| `plus equals` / `minus equals` | `+=` / `-=` |
| `and and` / `logical and` | `&&` |
| `or or` / `logical or` | `\|\|` |
| `pipe` / `bar` | `\|` |
| `null coalescing` / `question question` | `??` |
| `optional chain` / `question dot` | `?.` |
| `spread` / `ellipsis` | `...` |

---

## 4. Control Flow & Constructs

| Spoken Dictation | Python (`py`) | Rust (`rs`) | TypeScript/JavaScript (`ts`/`js`) |
| :--- | :--- | :--- | :--- |
| `if <cond>` | `if <cond>:` | `if <cond> {` | `if (<cond>) {` |
| `else if <cond>` | `elif <cond>:` | `else if <cond> {` | `else if (<cond>) {` |
| `else block` | `else:` | `else {` | `else {` |
| `for item in items` | `for item in items:` | `for item in items {` | `for (const item of items) {` |
| `return <val>` | `return <val>` | `return <val>;` / `<val>` | `return <val>;` |
| `arrow function <args> returns <expr>` | `lambda <args>: <expr>` | `\|<args>\| <expr>` | `(<args>) => <expr>` |
