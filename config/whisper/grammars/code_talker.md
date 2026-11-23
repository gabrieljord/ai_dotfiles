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

---

## 5. Sci-Fi Single-Syllable Keyword Layer

To eliminate recognition slur and speech fatigue during high-speed coding, the pipeline supports single-syllable sci-fi keywords that map directly to high-frequency programming constructs. See [scifi_lexicon.md](file:///home/blujay/code/ai_dotfiles/config/whisper/grammars/scifi_lexicon.md) for the complete A-Z codex covering all 1,392 words in `config/prompts/lang_prompts.env`.

| Sci-Fi Trigger | Traditional Spoken Equivalent | Target Expansion | Thematic Meaning / Context |
| :--- | :--- | :--- | :--- |
| `test <cond>` | `if <cond>` | `if <cond>:` / `if (<cond>) {` | Diagnostic condition gate check |
| `shift` | `else` | `else:` / `else {` | Alternate execution branch shift |
| `step <cond>` | `else if <cond>` / `elif <cond>` | `elif <cond>:` / `else if (<cond>) {` | Sub-branch conditional step |
| `spin <item> in <items>` | `for <item> in <items>` | `for <item> in <items>:` | Iterative loop cycle |
| `hold <cond>` | `while <cond>` | `while <cond>:` / `while (<cond>) {` | Continuous hold stasis loop |
| `yield <val>` | `return <val>` | `return <val>` | Emit value or beam output |
| `snap` | `break` | `break;` / `break` | Fracture execution loop |
| `skip` | `continue` | `continue;` / `continue` | Skip to next loop cycle |
| `scan <val>` | `match <val>` / `switch <val>` | `match <val>:` / `switch (<val>) {` | Pattern matching scan |
| `core <name>` | `def <name>` / `function <name>` | `def <name>(...):` / `fn <name>(...)` | Main computing reactor core |
| `spark <name>` | `fn <name>` / `lambda <args>` | `fn <name>` / `lambda <args>:` | Lightweight function spark |
| `flux <name>` | `var <name>` / `mut <name>` | `let mut <name>` / `var <name>` | Variable dynamic flux |
| `lock <name>` | `const <name>` / `final <name>` | `const <name> =` | Permanent immutable lock |
| `bind <name>` | `let <name>` | `let <name> =` | Lexical scope binding |
| `sync <fn>` | `async <fn>` | `async def` / `async fn` | Temporal warp sync |
| `hold <expr>` | `await <expr>` | `await <expr>` | Hold until signal lock |
| `dock <mod>` | `import <mod>` / `use <mod>` | `import <mod>` / `use <mod>::*` | Dock external module/freighter |
| `ship <item>` | `export <item>` | `export const` / `pub use` | Transmit outbound payload |
| `strand` | `string` / `str` | `String` / `str` / `std::string` | Linear byte/nanowire strand |
| `count` | `int` / `integer` | `int` / `i32` / `i64` | Discrete numerical tally |
| `drift` | `float` / `double` | `float` / `f64` | Floating point vector drift |
| `bit` | `bool` / `boolean` | `bool` / `boolean` | Binary 1-bit logic state |
| `void` | `void` / `null` / `None` | `void` / `None` / `null` | Empty vacuum state |
| `pulse` | `true` | `True` / `true` | Active high signal pulse |
| `dead` | `false` | `False` / `false` | Zero ground state |
| `hull <name>` | `struct <name>` | `struct <name> {` | Composite hull structure |
| `clan <name>` | `class <name>` | `class <name>:` / `class <name> {` | Archetype classification group |
| `port <name>` | `interface <name>` | `interface <name> {` | Standardized docking interface |

