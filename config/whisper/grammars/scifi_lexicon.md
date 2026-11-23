# Sci-Fi Single-Syllable Voice Grammar Codex

> **Protocol Specification**: Spoken voice triggers mapped to strictly single-syllable sci-fi, cybernetic, and space-opera codewords. Designed for rapid, zero-fatigue code dictation with Whisper and local LLM prompt optimization.

## Overview & Voice Rules

When dictating code in Cursor / VS Code:
1. **Monosyllabic Velocity**: Every voice trigger is strictly **one syllable** in English to eliminate recognition slur and acoustic fatigue.
2. **Domain Mapping**: Raw audio transcribed by Whisper (CPU-mode) is matched against this lexicon. The local LLM prompt optimizer transforms the spoken triggers into valid programming syntax for the active language context.
3. **Universal Coverage**: Fully maps all **1,392 distinct words** across all 595 languages defined in `config/prompts/lang_prompts.env`.

---

## 1. Core High-Frequency Primitives (Quick Reference)

| Category | Spoken Trigger | Target Expansion | Thematic Meaning / Context |
| :--- | :--- | :--- | :--- |
| Control Flow | `test` | `if <condition>` | Diagnostic condition gate check |
| Control Flow | `shift` | `else` | Alternate execution branch shift |
| Control Flow | `spin` | `for <item> in <items>` | Iterative loop cycle |
| Control Flow | `hold` | `while <condition>` | Continuous hold loop |
| Control Flow | `yield` | `return <value>` | Emit value or beam output |
| Control Flow | `snap` | `break` | Fracture execution loop |
| Control Flow | `skip` | `continue` | Skip to next cycle |
| Control Flow | `scan` | `match / switch` | Pattern matching scan |
| Types & Data | `strand` | `string / String` | Linear byte/nanowire strand |
| Types & Data | `count` | `int / integer` | Discrete numerical tally |
| Types & Data | `drift` | `float / double` | Floating point drift |
| Types & Data | `bit` | `bool / boolean` | Binary 1-bit logic state |
| Types & Data | `void` | `void / null / None` | Empty vacuum state |
| Types & Data | `pulse` | `true` | Active high signal pulse |
| Types & Data | `dead` | `false` | Zero ground state |
| Types & Data | `ray` | `array / vector` | Linear sensor array beam |
| Types & Data | `grid` | `dict / map / hash` | Coordinate sector grid |
| Types & Data | `hull` | `struct` | Composite hull structure |
| Types & Data | `clan` | `class` | Archetype classification group |
| Types & Data | `port` | `interface` | Standardized docking interface |
| Functions | `core` | `function / def` | Main computing reactor core |
| Functions | `spark` | `fn / lambda` | Lightweight function spark |
| Functions | `ping` | `call / invoke()` | Subspace communication ping |
| Declarations | `flux` | `var / mutable` | Variable dynamic flux |
| Declarations | `lock` | `const / final` | Permanent immutable lock |
| Declarations | `bind` | `let` | Lexical scope binding |
| Concurrency | `sync` | `async` | Temporal warp sync |
| Concurrency | `hold` | `await` | Hold until signal lock |
| Concurrency | `strand` | `thread` | Parallel quantum strand |
| Concurrency | `duct` | `chan / channel` | Plasma transmission duct |
| Concurrency | `beam` | `send / emit` | Transmit packet beam |
| Concurrency | `catch` | `recv / receive` | Capture incoming signal |
| Modules & I/O | `dock` | `import / use` | Dock external module/freighter |
| Modules & I/O | `ship` | `export` | Transmit outbound payload |
| Modules & I/O | `pod` | `module / package` | Detachable equipment pod |
| Modules & I/O | `hive` | `server / host` | Central nexus hive |
| Modules & I/O | `drone` | `client / worker` | Remote recon drone |
| Modules & I/O | `cast` | `print / echo` | Broadcast text to HUD |
| Memory | `point` | `pointer / *ptr` | Targeting vector pointer |
| Memory | `vault` | `memory / cache` | Cryo memory vault |
| Memory | `purge` | `free / delete` | Vent exhausted memory |
| Errors | `scram` | `panic! / fatal` | Emergency reactor scram |
| Errors | `breach` | `throw / exception` | Hull breach exception handler |

---

## 2. Complete Wordspace Master Lexicon (A-Z)

The following table maps all **1392 distinct words** extracted from `config/prompts/lang_prompts.env` to their corresponding single-syllable sci-fi voice triggers.

| Word | Sci-Fi Trigger | Category | Rationale & Expansion |
| :--- | :--- | :--- | :--- |
| `01` | `amp` | General Lexicon | Acoustic nearest neighbor for '01' |
| `05` | `amp` | General Lexicon | Acoustic nearest neighbor for '05' |
| `1C` | `arc` | General Lexicon | Acoustic nearest neighbor for '1C' |
| `3` | `amp` | General Lexicon | Acoustic nearest neighbor for '3' |
| `4D` | `and` | General Lexicon | Acoustic nearest neighbor for '4D' |
| `4gl` | `flight` | General Lexicon | Acoustic nearest neighbor for '4gl' |
| `7` | `amp` | General Lexicon | Acoustic nearest neighbor for '7' |
| `a` | `amp` | General Lexicon | Acoustic nearest neighbor for 'a' |
| `ABAP` | `amp` | General Lexicon | Acoustic nearest neighbor for 'ABAP' |
| `abstract` | `arc` | General Lexicon | Acoustic nearest neighbor for 'abstract' |
| `Abuild` | `and` | General Lexicon | Acoustic nearest neighbor for 'Abuild' |
| `access` | `arc` | General Lexicon | Acoustic nearest neighbor for 'access' |
| `accessor` | `arc` | General Lexicon | Acoustic nearest neighbor for 'accessor' |
| `acquires` | `arc` | General Lexicon | Acoustic nearest neighbor for 'acquires' |
| `ActionScript` | `arc` | General Lexicon | Acoustic nearest neighbor for 'ActionScript' |
| `actor` | `arc` | General Lexicon | Acoustic nearest neighbor for 'actor' |
| `Ada` | `ada` | Primitives | Direct single-syllable match 'ada' |
| `ADD` | `plus` | Arithmetic | Positive particle infusion |
| `add` | `plus` | Arithmetic | Positive particle infusion |
| `address` | `slot` | Low Level | Galactic coordinate slot |
| `after` | `arc` | General Lexicon | Acoustic nearest neighbor for 'after' |
| `Agda` | `and` | General Lexicon | Acoustic nearest neighbor for 'Agda' |
| `Agent` | `and` | General Lexicon | Acoustic nearest neighbor for 'Agent' |
| `AGS` | `ags` | Primitives | Direct single-syllable match 'ags' |
| `AIDL` | `and` | General Lexicon | Acoustic nearest neighbor for 'AIDL' |
| `Aiken` | `and` | General Lexicon | Acoustic nearest neighbor for 'Aiken' |
| `AL` | `al` | Primitives | Direct single-syllable match 'al' |
| `Aleo` | `amp` | General Lexicon | Acoustic nearest neighbor for 'Aleo' |
| `ALGOL` | `amp` | General Lexicon | Acoustic nearest neighbor for 'ALGOL' |
| `alias` | `ash` | General Lexicon | Acoustic nearest neighbor for 'alias' |
| `align` | `and` | General Lexicon | Acoustic nearest neighbor for 'align' |
| `all` | `all` | Primitives | Direct single-syllable match 'all' |
| `allocator` | `arc` | General Lexicon | Acoustic nearest neighbor for 'allocator' |
| `Alloy` | `amp` | General Lexicon | Acoustic nearest neighbor for 'Alloy' |
| `Alpine` | `amp` | General Lexicon | Acoustic nearest neighbor for 'Alpine' |
| `always` | `ash` | General Lexicon | Acoustic nearest neighbor for 'always' |
| `AMPL` | `amp` | Phonetic | Phonetic prefix match 'amp' -> amp |
| `and` | `and` | Logic | Simultaneous dual-lock |
| `Answer` | `and` | Phonetic | Phonetic prefix match 'an' -> and |
| `ANTLR` | `and` | Phonetic | Phonetic prefix match 'an' -> and |
| `any` | `any` | Primitives | Direct single-syllable match 'any' |
| `anyerror` | `and` | Phonetic | Phonetic prefix match 'an' -> and |
| `Apex` | `amp` | General Lexicon | Acoustic nearest neighbor for 'Apex' |
| `APL` | `apl` | Primitives | Direct single-syllable match 'apl' |
| `Apollo` | `amp` | General Lexicon | Acoustic nearest neighbor for 'Apollo' |
| `AppleScript` | `arc` | General Lexicon | Acoustic nearest neighbor for 'AppleScript' |
| `Applicative` | `amp` | General Lexicon | Acoustic nearest neighbor for 'Applicative' |
| `Arc` | `arc` | Primitives | Direct single-syllable match 'arc' |
| `architecture` | `arch` | Phonetic | Phonetic prefix match 'arch' -> arch |
| `ARG` | `arg` | Primitives | Direct single-syllable match 'arg' |
| `args` | `arc` | Phonetic | Phonetic prefix match 'ar' -> arc |
| `argument` | `arc` | Phonetic | Phonetic prefix match 'ar' -> arc |
| `arithmetic` | `arc` | Phonetic | Phonetic prefix match 'ar' -> arc |
| `ArkTS` | `arc` | Phonetic | Phonetic prefix match 'ar' -> arc |
| `Array` | `ray` | Collections | Linear sensor array beam |
| `array` | `ray` | Collections | Linear sensor array beam |
| `ArrayList` | `arc` | Phonetic | Phonetic prefix match 'ar' -> arc |
| `arrow` | `arc` | Phonetic | Phonetic prefix match 'ar' -> arc |
| `article` | `arc` | Phonetic | Phonetic prefix match 'ar' -> arc |
| `as` | `mask` | Modularity | Holographic alias mask |
| `ASL` | `ash` | Phonetic | Phonetic prefix match 'as' -> ash |
| `asm` | `chip` | Hardware | Direct silicon assembly |
| `ASP` | `asp` | Primitives | Direct single-syllable match 'asp' |
| `AspectJ` | `ash` | Phonetic | Phonetic prefix match 'as' -> ash |
| `Assembly` | `ash` | Phonetic | Phonetic prefix match 'as' -> ash |
| `assert` | `clinch` | Error Handling | Invariant lock verification |
| `assignment` | `ash` | Phonetic | Phonetic prefix match 'as' -> ash |
| `Asymptote` | `ash` | Phonetic | Phonetic prefix match 'as' -> ash |
| `async` | `sync` | Concurrency | Temporal warp sync |
| `atom` | `amp` | General Lexicon | Acoustic nearest neighbor for 'atom' |
| `ATS` | `ats` | Primitives | Direct single-syllable match 'ats' |
| `attr` | `arc` | General Lexicon | Acoustic nearest neighbor for 'attr' |
| `attribute` | `arc` | General Lexicon | Acoustic nearest neighbor for 'attribute' |
| `Augeas` | `ash` | General Lexicon | Acoustic nearest neighbor for 'Augeas' |
| `auto` | `bot` | Modifiers | Automated type inference |
| `AutoHotkey` | `arch` | General Lexicon | Acoustic nearest neighbor for 'AutoHotkey' |
| `AutoIt` | `amp` | General Lexicon | Acoustic nearest neighbor for 'AutoIt' |
| `AviSynth` | `ash` | General Lexicon | Acoustic nearest neighbor for 'AviSynth' |
| `await` | `hold` | Concurrency | Hold until signal lock |
| `Awk` | `awk` | Primitives | Direct single-syllable match 'awk' |
| `awk` | `awk` | Primitives | Direct single-syllable match 'awk' |
| `axiom` | `amp` | General Lexicon | Acoustic nearest neighbor for 'axiom' |
| `B` | `bail` | General Lexicon | Acoustic nearest neighbor for 'B' |
| `B4X` | `bail` | General Lexicon | Acoustic nearest neighbor for 'B4X' |
| `background` | `bail` | Phonetic | Phonetic prefix match 'ba' -> bail |
| `Ballerina` | `bail` | Phonetic | Phonetic prefix match 'ba' -> bail |
| `BAML` | `bail` | Phonetic | Phonetic prefix match 'ba' -> bail |
| `bash` | `deck` | Language | Command deck terminal shell |
| `Basic` | `base` | Phonetic | Phonetic prefix match 'bas' -> base |
| `bat` | `bat` | Primitives | Direct single-syllable match 'bat' |
| `Beef` | `beef` | Primitives | Direct single-syllable match 'beef' |
| `Befunge` | `beam` | Phonetic | Phonetic prefix match 'be' -> beam |
| `BEGIN` | `beam` | Phonetic | Phonetic prefix match 'be' -> beam |
| `begin` | `beam` | Phonetic | Phonetic prefix match 'be' -> beam |
| `Bend` | `bend` | Primitives | Direct single-syllable match 'bend' |
| `Berry` | `berth` | Phonetic | Phonetic prefix match 'ber' -> berth |
| `BH` | `bh` | Primitives | Direct single-syllable match 'bh' |
| `BibTeX` | `bind` | Phonetic | Phonetic prefix match 'bi' -> bind |
| `Bicep` | `bind` | Phonetic | Phonetic prefix match 'bi' -> bind |
| `binary` | `bind` | Phonetic | Phonetic prefix match 'bin' -> bind |
| `binding` | `bind` | Phonetic | Phonetic prefix match 'bind' -> bind |
| `Bison` | `bind` | Phonetic | Phonetic prefix match 'bi' -> bind |
| `bit` | `bit` | Logic | Single logical unit |
| `BitBake` | `bit` | Phonetic | Phonetic prefix match 'bit' -> bit |
| `BlitzMax` | `blitz` | Phonetic | Phonetic prefix match 'blit' -> blitz |
| `block` | `block` | Primitives | Direct single-syllable match 'block' |
| `Bluespec` | `blade` | Phonetic | Phonetic prefix match 'bl' -> blade |
| `body` | `board` | Phonetic | Phonetic prefix match 'bo' -> board |
| `Boo` | `boo` | Primitives | Direct single-syllable match 'boo' |
| `Boogie` | `boom` | Phonetic | Phonetic prefix match 'boo' -> boom |
| `bool` | `bit` | Data Types | Binary 1-bit logic state |
| `Boolean` | `bit` | Data Types | Binary quantum spin state |
| `boolean` | `bit` | Data Types | Binary quantum spin state |
| `border` | `bore` | Phonetic | Phonetic prefix match 'bor' -> bore |
| `borrow` | `bore` | Phonetic | Phonetic prefix match 'bor' -> bore |
| `borrowed` | `bore` | Phonetic | Phonetic prefix match 'bor' -> bore |
| `box` | `box` | Primitives | Direct single-syllable match 'box' |
| `BQN` | `bang` | General Lexicon | Acoustic nearest neighbor for 'BQN' |
| `braces` | `braces` | Primitives | Direct single-syllable match 'braces' |
| `brackets` | `brace` | Phonetic | Phonetic prefix match 'brac' -> brace |
| `break` | `snap` | Control Flow | Fracture execution loop |
| `Brightscript` | `brace` | Phonetic | Phonetic prefix match 'br' -> brace |
| `bss` | `bss` | Primitives | Direct single-syllable match 'bss' |
| `Buffer` | `tank` | Memory | Fluid memory buffer tank |
| `buffer` | `tank` | Memory | Fluid memory buffer tank |
| `BuildContext` | `build` | Phonetic | Phonetic prefix match 'buil' -> build |
| `builtin` | `build` | Phonetic | Phonetic prefix match 'buil' -> build |
| `button` | `build` | Phonetic | Phonetic prefix match 'bu' -> build |
| `by` | `by` | Primitives | Direct single-syllable match 'by' |
| `byte` | `byte` | Data Types | 8-bit octet storage block |
| `Bytes` | `bytes` | Primitives | Direct single-syllable match 'bytes' |
| `bytes` | `bytes` | Primitives | Direct single-syllable match 'bytes' |
| `C` | `core` | Language | Pure silicon bare-metal dialect |
| `c` | `core` | Language | Pure silicon bare-metal dialect |
| `C2hs` | `clash` | General Lexicon | Acoustic nearest neighbor for 'C2hs' |
| `C3` | `cache` | General Lexicon | Acoustic nearest neighbor for 'C3' |
| `Cadence` | `cache` | Phonetic | Phonetic prefix match 'ca' -> cache |
| `Cairo` | `cache` | Phonetic | Phonetic prefix match 'ca' -> cache |
| `calc` | `calc` | Primitives | Direct single-syllable match 'calc' |
| `call` | `ping` | Functions | Subspace communication ping |
| `callback` | `cache` | Phonetic | Phonetic prefix match 'ca' -> cache |
| `camelCase` | `cam` | Phonetic | Phonetic prefix match 'cam' -> cam |
| `CameLIGO` | `cam` | Phonetic | Phonetic prefix match 'cam' -> cam |
| `Cangjie` | `cache` | Phonetic | Phonetic prefix match 'ca' -> cache |
| `CAP` | `cap` | Primitives | Direct single-syllable match 'cap' |
| `Cap` | `cap` | Primitives | Direct single-syllable match 'cap' |
| `cap` | `cap` | Primitives | Direct single-syllable match 'cap' |
| `car` | `car` | Primitives | Direct single-syllable match 'car' |
| `Carbon` | `card` | Phonetic | Phonetic prefix match 'car' -> card |
| `CartoCSS` | `card` | Phonetic | Phonetic prefix match 'car' -> card |
| `case` | `slot` | Control Flow | Target branch hardpoint |
| `cast` | `cast` | Primitives | Direct single-syllable match 'cast' |
| `cat` | `cat` | Primitives | Direct single-syllable match 'cat' |
| `catch` | `trap` | Error Handling | Exception containment trap |
| `cbuffer` | `cruise` | General Lexicon | Acoustic nearest neighbor for 'cbuffer' |
| `cdata` | `card` | General Lexicon | Acoustic nearest neighbor for 'cdata' |
| `cdr` | `cdr` | Primitives | Direct single-syllable match 'cdr' |
| `CDS` | `cds` | Primitives | Direct single-syllable match 'cds' |
| `Cedar` | `cell` | Phonetic | Phonetic prefix match 'ce' -> cell |
| `Ceylon` | `cell` | Phonetic | Phonetic prefix match 'ce' -> cell |
| `CFC` | `cfc` | Primitives | Direct single-syllable match 'cfc' |
| `chan` | `duct` | Concurrency | Plasma transmission duct |
| `Channel` | `duct` | Concurrency | Inter-pod plasma duct |
| `Chapel` | `chain` | Phonetic | Phonetic prefix match 'cha' -> chain |
| `char` | `rune` | Data Types | Single glyph character unit |
| `Charity` | `char` | Phonetic | Phonetic prefix match 'char' -> char |
| `child` | `child` | Primitives | Direct single-syllable match 'child' |
| `children` | `chill` | Phonetic | Phonetic prefix match 'chil' -> chill |
| `chmod` | `chain` | Phonetic | Phonetic prefix match 'ch' -> chain |
| `ChucK` | `chuck` | Primitives | Direct single-syllable match 'chuck' |
| `circle` | `circle` | Primitives | Direct single-syllable match 'circle' |
| `Circom` | `chime` | General Lexicon | Acoustic nearest neighbor for 'Circom' |
| `Cirru` | `cruise` | General Lexicon | Acoustic nearest neighbor for 'Cirru' |
| `Clarion` | `claim` | Phonetic | Phonetic prefix match 'cla' -> claim |
| `Clarity` | `claim` | Phonetic | Phonetic prefix match 'cla' -> claim |
| `class` | `clan` | OOP & Types | Archetype classification group |
| `Classic` | `clash` | Phonetic | Phonetic prefix match 'clas' -> clash |
| `className` | `clash` | Phonetic | Phonetic prefix match 'clas' -> clash |
| `clause` | `clause` | Primitives | Direct single-syllable match 'clause' |
| `Clean` | `clean` | Primitives | Direct single-syllable match 'clean' |
| `clean` | `clean` | Primitives | Direct single-syllable match 'clean' |
| `Click` | `click` | Primitives | Direct single-syllable match 'click' |
| `CLIPS` | `clips` | Primitives | Direct single-syllable match 'clips' |
| `clock` | `clock` | Primitives | Direct single-syllable match 'clock' |
| `Clojure` | `ring` | Language | Lisp dialect on JVM ring |
| `CLOSE` | `seal` | I/O & Files | Airtight hatch seal |
| `Closure` | `cloak` | Phonetic | Phonetic prefix match 'clo' -> cloak |
| `cls` | `cls` | Primitives | Direct single-syllable match 'cls' |
| `Clue` | `clue` | Primitives | Direct single-syllable match 'clue' |
| `CMake` | `cache` | General Lexicon | Acoustic nearest neighbor for 'CMake' |
| `cmake` | `cache` | General Lexicon | Acoustic nearest neighbor for 'cmake' |
| `CMD` | `cmd` | Primitives | Direct single-syllable match 'cmd' |
| `cmd` | `cmd` | Primitives | Direct single-syllable match 'cmd' |
| `cmdlet` | `caste` | General Lexicon | Acoustic nearest neighbor for 'cmdlet' |
| `cmp` | `clamp` | General Lexicon | Acoustic nearest neighbor for 'cmp' |
| `COBOL` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `code` | `code` | Primitives | Direct single-syllable match 'code' |
| `CodeQL` | `code` | Phonetic | Phonetic prefix match 'code' -> code |
| `CoffeeScript` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `ColdFusion` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `colon` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `color` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `comb` | `comb` | Primitives | Direct single-syllable match 'comb' |
| `combinator` | `comb` | Phonetic | Phonetic prefix match 'comb' -> comb |
| `comma` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `Command` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `command` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `Common` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `companion` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `component` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `compress` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `comptime` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `compute` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `Computer` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `ComputeShader` | `comb` | Phonetic | Phonetic prefix match 'com' -> comb |
| `concat` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `cond` | `cond` | Primitives | Direct single-syllable match 'cond' |
| `cons` | `cons` | Primitives | Direct single-syllable match 'cons' |
| `console` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `const` | `lock` | Declarations | Permanent immutable lock |
| `CONSTANT` | `lock` | Declarations | Fixed parameter lock |
| `constant` | `lock` | Declarations | Fixed parameter lock |
| `constexpr` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `construct` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `constructor` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `content` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `Context` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `context` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `contract` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `ContractAddress` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `COPY` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `copy` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `Core` | `core` | Hardware | Processor fusion core |
| `coroutine` | `core` | Phonetic | Phonetic prefix match 'cor' -> core |
| `covergroup` | `coast` | Phonetic | Phonetic prefix match 'co' -> coast |
| `cpp` | `plus` | Language | Extended object bare-metal |
| `CQL` | `cell` | General Lexicon | Acoustic nearest neighbor for 'CQL' |
| `cross` | `cross` | Primitives | Direct single-syllable match 'cross' |
| `Crystal` | `crypt` | Phonetic | Phonetic prefix match 'cry' -> crypt |
| `csharp` | `sharp` | Language | Enterprise managed runtime |
| `Csound` | `cloud` | General Lexicon | Acoustic nearest neighbor for 'Csound' |
| `CSS` | `skin` | Markup | Exterior aesthetic hull skin |
| `Cuda` | `cuff` | Phonetic | Phonetic prefix match 'cu' -> cuff |
| `CUE` | `cue` | Primitives | Direct single-syllable match 'cue' |
| `curl` | `curl` | Primitives | Direct single-syllable match 'curl' |
| `curly` | `cuff` | Phonetic | Phonetic prefix match 'cu' -> cuff |
| `current` | `cuff` | Phonetic | Phonetic prefix match 'cu' -> cuff |
| `Curry` | `cuff` | Phonetic | Phonetic prefix match 'cu' -> cuff |
| `CURSOR` | `cuff` | Phonetic | Phonetic prefix match 'cu' -> cuff |
| `cut` | `cut` | Primitives | Direct single-syllable match 'cut' |
| `CWeb` | `crew` | General Lexicon | Acoustic nearest neighbor for 'CWeb' |
| `cx` | `cache` | General Lexicon | Acoustic nearest neighbor for 'cx' |
| `cy` | `cy` | Primitives | Direct single-syllable match 'cy' |
| `Cycript` | `crypt` | General Lexicon | Acoustic nearest neighbor for 'Cycript' |
| `Cypher` | `charge` | General Lexicon | Acoustic nearest neighbor for 'Cypher' |
| `Cython` | `count` | General Lexicon | Acoustic nearest neighbor for 'Cython' |
| `D` | `dam` | General Lexicon | Acoustic nearest neighbor for 'D' |
| `d` | `dam` | General Lexicon | Acoustic nearest neighbor for 'd' |
| `Dafny` | `dam` | Phonetic | Phonetic prefix match 'da' -> dam |
| `Dart` | `dart` | Language | High-speed frontend dart |
| `dash` | `dash` | Primitives | Direct single-syllable match 'dash' |
| `Daslang` | `dash` | Phonetic | Phonetic prefix match 'das' -> dash |
| `DATA` | `dam` | Phonetic | Phonetic prefix match 'da' -> dam |
| `data` | `dam` | Phonetic | Phonetic prefix match 'da' -> dam |
| `dataclass` | `dam` | Phonetic | Phonetic prefix match 'da' -> dam |
| `DataWeave` | `dam` | Phonetic | Phonetic prefix match 'da' -> dam |
| `DECLARE` | `deck` | Phonetic | Phonetic prefix match 'dec' -> deck |
| `declare` | `deck` | Phonetic | Phonetic prefix match 'dec' -> deck |
| `def` | `forge` | Functions | Define/manufacture routine |
| `default` | `base` | Control Flow | Default base state |
| `defclass` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defcustom` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defer` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defimpl` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `define` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `definition` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defmacro` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defmethod` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defmodule` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defn` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defp` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defparameter` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defprotocol` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defstruct` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defun` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `defvar` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `deinit` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `delegate` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `DenizenScript` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `deref` | `peel` | Low Level | Unmask target payload |
| `deriving` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `Description` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `device` | `dead` | Phonetic | Phonetic prefix match 'de' -> dead |
| `Dhall` | `dash` | General Lexicon | Acoustic nearest neighbor for 'Dhall' |
| `dict` | `vault` | Collections | Associative data vault |
| `dictionary` | `vault` | Collections | Cryo key-value vault |
| `die` | `die` | Primitives | Direct single-syllable match 'die' |
| `DIGITAL` | `dial` | Phonetic | Phonetic prefix match 'di' -> dial |
| `directive` | `dial` | Phonetic | Phonetic prefix match 'di' -> dial |
| `directories` | `dial` | Phonetic | Phonetic prefix match 'di' -> dial |
| `discard` | `disk` | Phonetic | Phonetic prefix match 'dis' -> disk |
| `DISPLAY` | `disk` | Phonetic | Phonetic prefix match 'dis' -> disk |
| `display` | `disk` | Phonetic | Phonetic prefix match 'dis' -> disk |
| `div` | `split` | Arithmetic | Particle fission split |
| `DIVISION` | `dive` | Phonetic | Phonetic prefix match 'div' -> dive |
| `dlang` | `dawn` | General Lexicon | Acoustic nearest neighbor for 'dlang' |
| `DM` | `dm` | Primitives | Direct single-syllable match 'dm' |
| `DO` | `do` | Primitives | Direct single-syllable match 'do' |
| `do` | `do` | Primitives | Direct single-syllable match 'do' |
| `Dockerfile` | `dock` | Phonetic | Phonetic prefix match 'dock' -> dock |
| `doctype` | `dock` | Phonetic | Phonetic prefix match 'doc' -> dock |
| `Document` | `dock` | Phonetic | Phonetic prefix match 'doc' -> dock |
| `Dogescript` | `dock` | Phonetic | Phonetic prefix match 'do' -> dock |
| `dolist` | `dock` | Phonetic | Phonetic prefix match 'do' -> dock |
| `done` | `done` | Primitives | Direct single-syllable match 'done' |
| `DOT` | `dot` | Primitives | Direct single-syllable match 'dot' |
| `dot` | `dot` | Primitives | Direct single-syllable match 'dot' |
| `dotimes` | `dock` | Phonetic | Phonetic prefix match 'do' -> dock |
| `double` | `twin` | Data Types | Double-precision binary pair |
| `downto` | `dock` | Phonetic | Phonetic prefix match 'do' -> dock |
| `dplyr` | `drop` | General Lexicon | Acoustic nearest neighbor for 'dplyr' |
| `DROP` | `dump` | Memory & Systems | Eject ballast / drop memory |
| `drop` | `dump` | Memory & Systems | Eject ballast / drop memory |
| `DType` | `deep` | General Lexicon | Acoustic nearest neighbor for 'DType' |
| `Dune` | `dune` | Primitives | Direct single-syllable match 'dune' |
| `DUP` | `dup` | Primitives | Direct single-syllable match 'dup' |
| `Dylan` | `dawn` | General Lexicon | Acoustic nearest neighbor for 'Dylan' |
| `dynamic` | `drain` | General Lexicon | Acoustic nearest neighbor for 'dynamic' |
| `DynArray` | `drain` | General Lexicon | Acoustic nearest neighbor for 'DynArray' |
| `E` | `etch` | General Lexicon | Acoustic nearest neighbor for 'E' |
| `each` | `each` | Primitives | Direct single-syllable match 'each' |
| `Earthly` | `etch` | General Lexicon | Acoustic nearest neighbor for 'Earthly' |
| `EasyCrypt` | `etch` | General Lexicon | Acoustic nearest neighbor for 'EasyCrypt' |
| `eax` | `etch` | General Lexicon | Acoustic nearest neighbor for 'eax' |
| `Ebuild` | `build` | General Lexicon | Acoustic nearest neighbor for 'Ebuild' |
| `ebx` | `etch` | General Lexicon | Acoustic nearest neighbor for 'ebx' |
| `echo` | `chime` | I/O & Files | Audio terminal feedback |
| `ECL` | `ecl` | Primitives | Direct single-syllable match 'ecl' |
| `Eclass` | `etch` | General Lexicon | Acoustic nearest neighbor for 'Eclass' |
| `ecx` | `etch` | General Lexicon | Acoustic nearest neighbor for 'ecx' |
| `EdgeQL` | `etch` | General Lexicon | Acoustic nearest neighbor for 'EdgeQL' |
| `edx` | `etch` | General Lexicon | Acoustic nearest neighbor for 'edx' |
| `Either` | `etch` | General Lexicon | Acoustic nearest neighbor for 'Either' |
| `element` | `etch` | General Lexicon | Acoustic nearest neighbor for 'element' |
| `elif` | `step` | Control Flow | Sub-branch conditional step |
| `elisp` | `etch` | General Lexicon | Acoustic nearest neighbor for 'elisp' |
| `Elixir` | `flask` | Language | Erlang beam alchemical elixir |
| `Elm` | `elm` | Primitives | Direct single-syllable match 'elm' |
| `ELSE` | `shift` | Control Flow | Alternate path shift |
| `else` | `shift` | Control Flow | Alternate path shift |
| `elseif` | `etch` | General Lexicon | Acoustic nearest neighbor for 'elseif' |
| `ELSIF` | `etch` | General Lexicon | Acoustic nearest neighbor for 'ELSIF' |
| `elsif` | `etch` | General Lexicon | Acoustic nearest neighbor for 'elsif' |
| `Elvish` | `etch` | General Lexicon | Acoustic nearest neighbor for 'Elvish' |
| `Emacs` | `etch` | General Lexicon | Acoustic nearest neighbor for 'Emacs' |
| `EmberScript` | `etch` | General Lexicon | Acoustic nearest neighbor for 'EmberScript' |
| `emit` | `etch` | General Lexicon | Acoustic nearest neighbor for 'emit' |
| `END` | `end` | Primitives | Direct single-syllable match 'end' |
| `end` | `end` | Primitives | Direct single-syllable match 'end' |
| `endclass` | `etch` | General Lexicon | Acoustic nearest neighbor for 'endclass' |
| `endif` | `etch` | General Lexicon | Acoustic nearest neighbor for 'endif' |
| `Engine` | `etch` | General Lexicon | Acoustic nearest neighbor for 'Engine' |
| `Enterprise` | `etch` | General Lexicon | Acoustic nearest neighbor for 'Enterprise' |
| `entity` | `etch` | General Lexicon | Acoustic nearest neighbor for 'entity' |
| `entry` | `etch` | General Lexicon | Acoustic nearest neighbor for 'entry' |
| `ENTRYPOINT` | `etch` | General Lexicon | Acoustic nearest neighbor for 'ENTRYPOINT' |
| `Enum` | `rank` | Data Types | Enumerated fleet rank tier |
| `enum` | `rank` | Data Types | Enumerated fleet rank tier |
| `ENV` | `env` | Primitives | Direct single-syllable match 'env' |
| `env` | `env` | Primitives | Direct single-syllable match 'env' |
| `ENVIRONMENT` | `etch` | General Lexicon | Acoustic nearest neighbor for 'ENVIRONMENT' |
| `EQ` | `eq` | Primitives | Direct single-syllable match 'eq' |
| `ERB` | `erb` | Primitives | Direct single-syllable match 'erb' |
| `Erlang` | `beam` | Language | Fault-tolerant telecomm cluster |
| `errdefer` | `etch` | General Lexicon | Acoustic nearest neighbor for 'errdefer' |
| `Error` | `etch` | General Lexicon | Acoustic nearest neighbor for 'Error' |
| `error` | `etch` | General Lexicon | Acoustic nearest neighbor for 'error' |
| `errorlevel` | `etch` | General Lexicon | Acoustic nearest neighbor for 'errorlevel' |
| `ES6` | `etch` | General Lexicon | Acoustic nearest neighbor for 'ES6' |
| `esac` | `etch` | General Lexicon | Acoustic nearest neighbor for 'esac' |
| `euo` | `etch` | General Lexicon | Acoustic nearest neighbor for 'euo' |
| `eval` | `solve` | Functions | Quantum calculation solve |
| `event` | `flare` | Concurrency | Sensor detection flare |
| `except` | `breach` | Error Handling | Hull breach exception handler |
| `EXCEPTION` | `etch` | General Lexicon | Acoustic nearest neighbor for 'EXCEPTION' |
| `Exception` | `etch` | General Lexicon | Acoustic nearest neighbor for 'Exception' |
| `exception` | `etch` | General Lexicon | Acoustic nearest neighbor for 'exception' |
| `executable` | `etch` | General Lexicon | Acoustic nearest neighbor for 'executable' |
| `EXECUTE` | `etch` | General Lexicon | Acoustic nearest neighbor for 'EXECUTE' |
| `exit` | `etch` | General Lexicon | Acoustic nearest neighbor for 'exit' |
| `expand` | `etch` | General Lexicon | Acoustic nearest neighbor for 'expand' |
| `export` | `ship` | Modularity | Transmit outbound payload |
| `EXPOSE` | `etch` | General Lexicon | Acoustic nearest neighbor for 'EXPOSE' |
| `expression` | `etch` | General Lexicon | Acoustic nearest neighbor for 'expression' |
| `extend` | `etch` | General Lexicon | Acoustic nearest neighbor for 'extend' |
| `extends` | `etch` | General Lexicon | Acoustic nearest neighbor for 'extends' |
| `extension` | `etch` | General Lexicon | Acoustic nearest neighbor for 'extension' |
| `extern` | `out` | Modifiers | External off-ship link |
| `external` | `etch` | General Lexicon | Acoustic nearest neighbor for 'external' |
| `F` | `fall` | General Lexicon | Acoustic nearest neighbor for 'F' |
| `f64` | `fall` | General Lexicon | Acoustic nearest neighbor for 'f64' |
| `fact` | `fact` | Primitives | Direct single-syllable match 'fact' |
| `Factor` | `fall` | Phonetic | Phonetic prefix match 'fa' -> fall |
| `fail` | `fail` | Primitives | Direct single-syllable match 'fail' |
| `False` | `dead` | Data Types | Zero low ground state |
| `false` | `dead` | Data Types | Zero low ground state |
| `Fancy` | `fall` | Phonetic | Phonetic prefix match 'fa' -> fall |
| `Fantom` | `fall` | Phonetic | Phonetic prefix match 'fa' -> fall |
| `Faust` | `faust` | Primitives | Direct single-syllable match 'faust' |
| `FC` | `fc` | Primitives | Direct single-syllable match 'fc' |
| `felt252` | `feed` | Phonetic | Phonetic prefix match 'fe' -> feed |
| `Fennel` | `fence` | Phonetic | Phonetic prefix match 'fen' -> fence |
| `FETCH` | `fetch` | Primitives | Direct single-syllable match 'fetch' |
| `fetch` | `fetch` | Primitives | Direct single-syllable match 'fetch' |
| `ff` | `ff` | Primitives | Direct single-syllable match 'ff' |
| `fi` | `fi` | Primitives | Direct single-syllable match 'fi' |
| `Fiber` | `field` | Phonetic | Phonetic prefix match 'fi' -> field |
| `fileprivate` | `field` | Phonetic | Phonetic prefix match 'fi' -> field |
| `fill` | `fill` | Primitives | Direct single-syllable match 'fill' |
| `filter` | `field` | Phonetic | Phonetic prefix match 'fi' -> field |
| `final` | `lock` | Declarations | Sealed bulkhead lock |
| `finally` | `last` | Error Handling | Final terminal teardown |
| `find` | `find` | Primitives | Direct single-syllable match 'find' |
| `FIRRTL` | `fire` | Phonetic | Phonetic prefix match 'fir' -> fire |
| `fish` | `fish` | Primitives | Direct single-syllable match 'fish' |
| `flag` | `flag` | Primitives | Direct single-syllable match 'flag' |
| `flex` | `flex` | Primitives | Direct single-syllable match 'flex' |
| `Flix` | `flix` | Primitives | Direct single-syllable match 'flix' |
| `Float` | `drift` | Data Types | Floating point vector drift |
| `float` | `drift` | Data Types | Floating point vector drift |
| `float2` | `flood` | Phonetic | Phonetic prefix match 'flo' -> flood |
| `float3` | `flood` | Phonetic | Phonetic prefix match 'flo' -> flood |
| `float4` | `flood` | Phonetic | Phonetic prefix match 'flo' -> flood |
| `float4x4` | `flood` | Phonetic | Phonetic prefix match 'flo' -> flood |
| `Float64` | `flood` | Phonetic | Phonetic prefix match 'flo' -> flood |
| `Fluent` | `fluent` | Primitives | Direct single-syllable match 'fluent' |
| `FLUX` | `flux` | Primitives | Direct single-syllable match 'flux' |
| `fn` | `spark` | Functions | Lightweight function spark |
| `fold` | `fold` | Primitives | Direct single-syllable match 'fold' |
| `font` | `font` | Primitives | Direct single-syllable match 'font' |
| `footer` | `foam` | Phonetic | Phonetic prefix match 'fo' -> foam |
| `FOR` | `spin` | Control Flow | Iterative cycle loop |
| `for` | `spin` | Control Flow | Iterative cycle loop |
| `foreach` | `forge` | Phonetic | Phonetic prefix match 'for' -> forge |
| `Form` | `form` | Primitives | Direct single-syllable match 'form' |
| `form` | `form` | Primitives | Direct single-syllable match 'form' |
| `Formal` | `form` | Phonetic | Phonetic prefix match 'form' -> form |
| `format` | `form` | Phonetic | Phonetic prefix match 'form' -> form |
| `Forth` | `forth` | Primitives | Direct single-syllable match 'forth' |
| `Fortran` | `forge` | Phonetic | Phonetic prefix match 'for' -> forge |
| `FPP` | `fpp` | Primitives | Direct single-syllable match 'fpp' |
| `FragColor` | `frost` | Phonetic | Phonetic prefix match 'fr' -> frost |
| `fragment` | `frost` | Phonetic | Phonetic prefix match 'fr' -> frost |
| `frame` | `frame` | Primitives | Direct single-syllable match 'frame' |
| `Framework` | `frost` | Phonetic | Phonetic prefix match 'fr' -> frost |
| `Free` | `purge` | Memory | Vent exhausted memory |
| `free` | `purge` | Memory | Vent exhausted memory |
| `FreeBASIC` | `frost` | Phonetic | Phonetic prefix match 'fr' -> frost |
| `FROM` | `base` | Modularity | Origin jump base |
| `from` | `base` | Modularity | Origin jump base |
| `fun` | `fun` | Primitives | Direct single-syllable match 'fun' |
| `func` | `core` | Functions | Primary executable sub-core |
| `FUNCTION` | `core` | Functions | Main computing reactor core |
| `function` | `core` | Functions | Main computing reactor core |
| `functions` | `fume` | Phonetic | Phonetic prefix match 'fu' -> fume |
| `Functor` | `fume` | Phonetic | Phonetic prefix match 'fu' -> fume |
| `Futhark` | `fume` | Phonetic | Phonetic prefix match 'fu' -> fume |
| `Future` | `fume` | Phonetic | Phonetic prefix match 'fu' -> fume |
| `G` | `gale` | General Lexicon | Acoustic nearest neighbor for 'G' |
| `g` | `gale` | General Lexicon | Acoustic nearest neighbor for 'g' |
| `Game` | `game` | Primitives | Direct single-syllable match 'game' |
| `GAML` | `gale` | Phonetic | Phonetic prefix match 'ga' -> gale |
| `GAMS` | `gams` | Primitives | Direct single-syllable match 'gams' |
| `GCC` | `gcc` | Primitives | Direct single-syllable match 'gcc' |
| `GDB` | `gdb` | Primitives | Direct single-syllable match 'gdb' |
| `GDShader` | `grade` | General Lexicon | Acoustic nearest neighbor for 'GDShader' |
| `Gee` | `gee` | Primitives | Direct single-syllable match 'gee' |
| `gen` | `gen` | Primitives | Direct single-syllable match 'gen' |
| `Genero` | `gene` | Phonetic | Phonetic prefix match 'gene' -> gene |
| `GenServer` | `gene` | Phonetic | Phonetic prefix match 'gen' -> gene |
| `Genshi` | `gene` | Phonetic | Phonetic prefix match 'gen' -> gene |
| `Gentoo` | `gene` | Phonetic | Phonetic prefix match 'gen' -> gene |
| `Get` | `get` | Primitives | Direct single-syllable match 'get' |
| `get` | `get` | Primitives | Direct single-syllable match 'get' |
| `getter` | `gear` | Phonetic | Phonetic prefix match 'ge' -> gear |
| `ggplot` | `ghost` | General Lexicon | Acoustic nearest neighbor for 'ggplot' |
| `Gherkin` | `ghost` | Phonetic | Phonetic prefix match 'gh' -> ghost |
| `given` | `gene` | General Lexicon | Acoustic nearest neighbor for 'given' |
| `gl` | `gl` | Primitives | Direct single-syllable match 'gl' |
| `Gleam` | `gleam` | Primitives | Direct single-syllable match 'gleam' |
| `GLib` | `glib` | Primitives | Direct single-syllable match 'glib' |
| `Glimmer` | `glide` | Phonetic | Phonetic prefix match 'gli' -> glide |
| `global` | `realm` | Modifiers | System-wide galactic scope |
| `GLSL` | `glaze` | Phonetic | Phonetic prefix match 'gl' -> glaze |
| `Glyph` | `glyph` | Primitives | Direct single-syllable match 'glyph' |
| `Gno` | `gene` | General Lexicon | Acoustic nearest neighbor for 'Gno' |
| `Gnuplot` | `glint` | General Lexicon | Acoustic nearest neighbor for 'Gnuplot' |
| `Go` | `flight` | Language | Concurrent goroutine fleet |
| `go` | `flight` | Language | Concurrent goroutine fleet |
| `goal` | `goal` | Primitives | Direct single-syllable match 'goal' |
| `golang` | `gale` | General Lexicon | Acoustic nearest neighbor for 'golang' |
| `Golo` | `glow` | General Lexicon | Acoustic nearest neighbor for 'Golo' |
| `Goose` | `goose` | Primitives | Direct single-syllable match 'goose' |
| `Goroutine` | `glint` | General Lexicon | Acoustic nearest neighbor for 'Goroutine' |
| `goto` | `jump` | Control Flow | Hyperspace instruction jump |
| `Grace` | `grace` | Primitives | Direct single-syllable match 'grace' |
| `grammar` | `grade` | Phonetic | Phonetic prefix match 'gra' -> grade |
| `Grammatical` | `grade` | Phonetic | Phonetic prefix match 'gra' -> grade |
| `GraphQL` | `grid` | API | Targeted query lattice |
| `Graphviz` | `grade` | Phonetic | Phonetic prefix match 'gra' -> grade |
| `grep` | `grep` | Primitives | Direct single-syllable match 'grep' |
| `grid` | `grid` | Primitives | Direct single-syllable match 'grid' |
| `Groovy` | `grade` | Phonetic | Phonetic prefix match 'gr' -> grade |
| `group` | `group` | Primitives | Direct single-syllable match 'group' |
| `GSC` | `gsc` | Primitives | Direct single-syllable match 'gsc' |
| `guard` | `guard` | Primitives | Direct single-syllable match 'guard' |
| `Guidance` | `guide` | Phonetic | Phonetic prefix match 'guid' -> guide |
| `h` | `hack` | General Lexicon | Acoustic nearest neighbor for 'h' |
| `Hack` | `hack` | Primitives | Direct single-syllable match 'hack' |
| `handle` | `handle` | Primitives | Direct single-syllable match 'handle' |
| `Harbour` | `hack` | Phonetic | Phonetic prefix match 'ha' -> hack |
| `Hare` | `hare` | Primitives | Direct single-syllable match 'hare' |
| `has` | `has` | Primitives | Direct single-syllable match 'has' |
| `hash` | `hash` | Primitives | Direct single-syllable match 'hash' |
| `HashMap` | `hack` | Phonetic | Phonetic prefix match 'ha' -> hack |
| `Haskell` | `pure` | Language | Pure mathematical functional form |
| `Haxe` | `hack` | Phonetic | Phonetic prefix match 'ha' -> hack |
| `HCL` | `hcl` | Primitives | Direct single-syllable match 'hcl' |
| `head` | `head` | Primitives | Direct single-syllable match 'head' |
| `header` | `heap` | Phonetic | Phonetic prefix match 'hea' -> heap |
| `HEALTHCHECK` | `heap` | Phonetic | Phonetic prefix match 'hea' -> heap |
| `height` | `height` | Primitives | Direct single-syllable match 'height' |
| `highp` | `hinge` | Phonetic | Phonetic prefix match 'hi' -> hinge |
| `HIP` | `hip` | Primitives | Direct single-syllable match 'hip' |
| `HiveQL` | `hive` | Phonetic | Phonetic prefix match 'hive' -> hive |
| `HLSL` | `haul` | General Lexicon | Acoustic nearest neighbor for 'HLSL' |
| `HolyC` | `hold` | Phonetic | Phonetic prefix match 'hol' -> hold |
| `hoon` | `hoon` | Primitives | Direct single-syllable match 'hoon' |
| `Host` | `hive` | Networking | Mothership host server |
| `href` | `haze` | General Lexicon | Acoustic nearest neighbor for 'href' |
| `HTML` | `mesh` | Markup | Structural hyper-lattice |
| `html` | `mesh` | Markup | Structural hyper-lattice |
| `HTMLDivElement` | `helm` | General Lexicon | Acoustic nearest neighbor for 'HTMLDivElement' |
| `Hurl` | `hurl` | Primitives | Direct single-syllable match 'hurl' |
| `Hy` | `hy` | Primitives | Direct single-syllable match 'hy' |
| `i32` | `ice` | General Lexicon | Acoustic nearest neighbor for 'i32' |
| `ID` | `id` | Primitives | Direct single-syllable match 'id' |
| `id` | `id` | Primitives | Direct single-syllable match 'id' |
| `IDENTIFICATION` | `ice` | General Lexicon | Acoustic nearest neighbor for 'IDENTIFICATION' |
| `IDL` | `idl` | Primitives | Direct single-syllable match 'idl' |
| `Idris` | `isle` | General Lexicon | Acoustic nearest neighbor for 'Idris' |
| `IF` | `test` | Control Flow | Diagnostic gate check |
| `if` | `test` | Control Flow | Diagnostic gate check |
| `ifeq` | `ice` | General Lexicon | Acoustic nearest neighbor for 'ifeq' |
| `ifneq` | `ice` | General Lexicon | Acoustic nearest neighbor for 'ifneq' |
| `IGOR` | `ice` | General Lexicon | Acoustic nearest neighbor for 'IGOR' |
| `IL` | `il` | Primitives | Direct single-syllable match 'il' |
| `ImageJ` | `ice` | General Lexicon | Acoustic nearest neighbor for 'ImageJ' |
| `Imba` | `ice` | General Lexicon | Acoustic nearest neighbor for 'Imba' |
| `img` | `ice` | General Lexicon | Acoustic nearest neighbor for 'img' |
| `ImHex` | `ice` | General Lexicon | Acoustic nearest neighbor for 'ImHex' |
| `immutability` | `isle` | General Lexicon | Acoustic nearest neighbor for 'immutability' |
| `immutable` | `isle` | General Lexicon | Acoustic nearest neighbor for 'immutable' |
| `impl` | `build` | Metaprogramming | Implement chassis specs |
| `implements` | `isle` | General Lexicon | Acoustic nearest neighbor for 'implements' |
| `implicit` | `ice` | General Lexicon | Acoustic nearest neighbor for 'implicit' |
| `import` | `dock` | Modularity | Dock external freighter/module |
| `in` | `in` | Primitives | Direct single-syllable match 'in' |
| `include` | `graft` | Modularity | Graft external headers |
| `indent` | `ice` | General Lexicon | Acoustic nearest neighbor for 'indent' |
| `index` | `ice` | General Lexicon | Acoustic nearest neighbor for 'index' |
| `inductive` | `ice` | General Lexicon | Acoustic nearest neighbor for 'inductive' |
| `Inform` | `ice` | General Lexicon | Acoustic nearest neighbor for 'Inform' |
| `inherit` | `ice` | General Lexicon | Acoustic nearest neighbor for 'inherit' |
| `init` | `ice` | General Lexicon | Acoustic nearest neighbor for 'init' |
| `initialize` | `isle` | General Lexicon | Acoustic nearest neighbor for 'initialize' |
| `Ink` | `ink` | Primitives | Direct single-syllable match 'ink' |
| `inline` | `isle` | General Lexicon | Acoustic nearest neighbor for 'inline' |
| `inner` | `ice` | General Lexicon | Acoustic nearest neighbor for 'inner' |
| `Inno` | `ice` | General Lexicon | Acoustic nearest neighbor for 'Inno' |
| `inout` | `ice` | General Lexicon | Acoustic nearest neighbor for 'inout' |
| `input` | `ice` | General Lexicon | Acoustic nearest neighbor for 'input' |
| `insert` | `isle` | General Lexicon | Acoustic nearest neighbor for 'insert' |
| `install` | `isle` | General Lexicon | Acoustic nearest neighbor for 'install' |
| `instance` | `ice` | General Lexicon | Acoustic nearest neighbor for 'instance' |
| `Int` | `count` | Data Types | Discrete integer counter |
| `int` | `count` | Data Types | Discrete integer counter |
| `int32` | `ice` | General Lexicon | Acoustic nearest neighbor for 'int32' |
| `Int64` | `ice` | General Lexicon | Acoustic nearest neighbor for 'Int64' |
| `int64` | `ice` | General Lexicon | Acoustic nearest neighbor for 'int64' |
| `integer` | `count` | Data Types | Discrete numerical tally |
| `interactive` | `ice` | General Lexicon | Acoustic nearest neighbor for 'interactive' |
| `interface` | `port` | OOP & Types | Standardized docking interface |
| `Internal` | `isle` | General Lexicon | Acoustic nearest neighbor for 'Internal' |
| `internal` | `isle` | General Lexicon | Acoustic nearest neighbor for 'internal' |
| `IO` | `io` | Primitives | Direct single-syllable match 'io' |
| `Io` | `io` | Primitives | Direct single-syllable match 'io' |
| `Ioke` | `ice` | General Lexicon | Acoustic nearest neighbor for 'Ioke' |
| `iota` | `ice` | General Lexicon | Acoustic nearest neighbor for 'iota' |
| `is` | `is` | Primitives | Direct single-syllable match 'is' |
| `Isabelle` | `isle` | Phonetic | Phonetic prefix match 'is' -> isle |
| `ISPC` | `isle` | Phonetic | Phonetic prefix match 'is' -> isle |
| `it` | `it` | Primitives | Direct single-syllable match 'it' |
| `items` | `isle` | General Lexicon | Acoustic nearest neighbor for 'items' |
| `iterator` | `ice` | General Lexicon | Acoustic nearest neighbor for 'iterator' |
| `J` | `jet` | General Lexicon | Acoustic nearest neighbor for 'J' |
| `Jac` | `jac` | Primitives | Direct single-syllable match 'jac' |
| `Jai` | `jai` | Primitives | Direct single-syllable match 'jai' |
| `Janet` | `jet` | General Lexicon | Acoustic nearest neighbor for 'Janet' |
| `Java` | `brew` | Language | Class-based orbital runtime |
| `JavaScript` | `script` | Language | Dynamic hyperscript engine |
| `JCL` | `jcl` | Primitives | Direct single-syllable match 'jcl' |
| `JetBrains` | `jet` | Phonetic | Phonetic prefix match 'jet' -> jet |
| `JFlex` | `jet` | General Lexicon | Acoustic nearest neighbor for 'JFlex' |
| `Jison` | `jolt` | General Lexicon | Acoustic nearest neighbor for 'Jison' |
| `jmp` | `jmp` | Primitives | Direct single-syllable match 'jmp' |
| `join` | `join` | Primitives | Direct single-syllable match 'join' |
| `Jolie` | `jolt` | Phonetic | Phonetic prefix match 'jol' -> jolt |
| `jq` | `jet` | General Lexicon | Acoustic nearest neighbor for 'jq' |
| `JS` | `js` | Primitives | Direct single-syllable match 'js' |
| `js` | `js` | Primitives | Direct single-syllable match 'js' |
| `JSON` | `wire` | Data Format | Compact serialized telemetry |
| `JSONiq` | `jolt` | General Lexicon | Acoustic nearest neighbor for 'JSONiq' |
| `Jsonnet` | `jet` | General Lexicon | Acoustic nearest neighbor for 'Jsonnet' |
| `JSX` | `jet` | General Lexicon | Acoustic nearest neighbor for 'JSX' |
| `Julia` | `gem` | Language | Scientific compute gemstone |
| `Just` | `just` | Primitives | Direct single-syllable match 'just' |
| `justify` | `jump` | Phonetic | Phonetic prefix match 'ju' -> jump |
| `Kaitai` | `kin` | General Lexicon | Acoustic nearest neighbor for 'Kaitai' |
| `KakouneScript` | `knot` | General Lexicon | Acoustic nearest neighbor for 'KakouneScript' |
| `KCL` | `kcl` | Primitives | Direct single-syllable match 'kcl' |
| `KerboScript` | `keel` | Phonetic | Phonetic prefix match 'ke' -> keel |
| `KerML` | `keel` | Phonetic | Phonetic prefix match 'ke' -> keel |
| `kernel` | `keel` | Phonetic | Phonetic prefix match 'ke' -> keel |
| `key` | `key` | Primitives | Direct single-syllable match 'key' |
| `keyof` | `key` | Phonetic | Phonetic prefix match 'key' -> key |
| `Koka` | `knob` | General Lexicon | Acoustic nearest neighbor for 'Koka' |
| `Kotlin` | `isle` | Language | Jet-propelled JVM platform |
| `KRL` | `keel` | General Lexicon | Acoustic nearest neighbor for 'KRL' |
| `kwargs` | `king` | General Lexicon | Acoustic nearest neighbor for 'kwargs' |
| `LABEL` | `lance` | Phonetic | Phonetic prefix match 'la' -> lance |
| `LabVIEW` | `lance` | Phonetic | Phonetic prefix match 'la' -> lance |
| `lambda` | `flux` | Functions | Anonymous micro-flux |
| `Langium` | `lance` | Phonetic | Phonetic prefix match 'lan' -> lance |
| `Language` | `lance` | Phonetic | Phonetic prefix match 'lan' -> lance |
| `Lasso` | `last` | Phonetic | Phonetic prefix match 'las' -> last |
| `latch` | `latch` | Primitives | Direct single-syllable match 'latch' |
| `layout` | `layout` | Primitives | Direct single-syllable match 'layout' |
| `lea` | `lea` | Primitives | Direct single-syllable match 'lea' |
| `Lean` | `lean` | Primitives | Direct single-syllable match 'lean' |
| `Left` | `left` | Primitives | Direct single-syllable match 'left' |
| `lemma` | `leaf` | Phonetic | Phonetic prefix match 'le' -> leaf |
| `len` | `len` | Primitives | Direct single-syllable match 'len' |
| `Leo` | `leo` | Primitives | Direct single-syllable match 'leo' |
| `lerp` | `lerp` | Primitives | Direct single-syllable match 'lerp' |
| `Less` | `less` | Primitives | Direct single-syllable match 'less' |
| `let` | `bind` | Declarations | Lexical scope binding |
| `letrec` | `leaf` | Phonetic | Phonetic prefix match 'le' -> leaf |
| `Lex` | `lex` | Primitives | Direct single-syllable match 'lex' |
| `LFE` | `leaf` | General Lexicon | Acoustic nearest neighbor for 'LFE' |
| `li` | `li` | Primitives | Direct single-syllable match 'li' |
| `lib` | `lib` | Primitives | Direct single-syllable match 'lib' |
| `libraries` | `light` | Phonetic | Phonetic prefix match 'li' -> light |
| `library` | `light` | Phonetic | Phonetic prefix match 'li' -> light |
| `LigoLANG` | `light` | Phonetic | Phonetic prefix match 'lig' -> light |
| `LilyPond` | `light` | Phonetic | Phonetic prefix match 'li' -> light |
| `line` | `line` | Primitives | Direct single-syllable match 'line' |
| `link` | `link` | Primitives | Direct single-syllable match 'link' |
| `Linker` | `link` | Phonetic | Phonetic prefix match 'link' -> link |
| `LINQ` | `line` | Phonetic | Phonetic prefix match 'lin' -> line |
| `Liquidsoap` | `light` | Phonetic | Phonetic prefix match 'li' -> light |
| `Lisp` | `lisp` | Primitives | Direct single-syllable match 'lisp' |
| `List` | `chain` | Collections | Linked sequence chain |
| `list` | `chain` | Collections | Linked sequence chain |
| `Literate` | `light` | Phonetic | Phonetic prefix match 'li' -> light |
| `LiveCode` | `light` | Phonetic | Phonetic prefix match 'li' -> light |
| `LiveScript` | `light` | Phonetic | Phonetic prefix match 'li' -> light |
| `LLVM` | `lance` | General Lexicon | Acoustic nearest neighbor for 'LLVM' |
| `Lobster` | `lock` | Phonetic | Phonetic prefix match 'lo' -> lock |
| `local` | `deck` | Modifiers | Local compartment scope |
| `location` | `lock` | Phonetic | Phonetic prefix match 'loc' -> lock |
| `log` | `log` | I/O & Files | Captain's flight log |
| `logic` | `log` | Phonetic | Phonetic prefix match 'log' -> log |
| `Logos` | `log` | Phonetic | Phonetic prefix match 'log' -> log |
| `Logtalk` | `log` | Phonetic | Phonetic prefix match 'log' -> log |
| `LOLCODE` | `lock` | Phonetic | Phonetic prefix match 'lo' -> lock |
| `LookML` | `loop` | Phonetic | Phonetic prefix match 'loo' -> loop |
| `LOOP` | `loop` | Control Flow | Orbital execution loop |
| `loop` | `loop` | Control Flow | Orbital execution loop |
| `LSL` | `last` | General Lexicon | Acoustic nearest neighbor for 'LSL' |
| `Lua` | `moon` | Language | Embedded lunar scripting core |
| `Luau` | `luau` | Primitives | Direct single-syllable match 'luau' |
| `M` | `mark` | General Lexicon | Acoustic nearest neighbor for 'M' |
| `M4` | `mark` | General Lexicon | Acoustic nearest neighbor for 'M4' |
| `Macaulay2` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `Machine` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `Macro` | `blast` | Metaprogramming | Expansion macro blast |
| `macro` | `blast` | Metaprogramming | Expansion macro blast |
| `make` | `make` | Primitives | Direct single-syllable match 'make' |
| `Makefile` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `Maker` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `Mako` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `malloc` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `Management` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `Map` | `grid` | Collections | Key-value sector grid |
| `map` | `grid` | Collections | Key-value sector grid |
| `mapping` | `chart` | Collections | Coordinate sector chart |
| `margin` | `mark` | Phonetic | Phonetic prefix match 'mar' -> mark |
| `mat3` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `mat4` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `mat4x4f` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `match` | `scan` | Control Flow | Pattern matching scan |
| `MATLAB` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `Matrix` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `matrix` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `Max` | `max` | Primitives | Direct single-syllable match 'max' |
| `MAXScript` | `mark` | Phonetic | Phonetic prefix match 'ma' -> mark |
| `Maybe` | `maybe` | Primitives | Direct single-syllable match 'maybe' |
| `mcfunction` | `mount` | General Lexicon | Acoustic nearest neighbor for 'mcfunction' |
| `media` | `mech` | Phonetic | Phonetic prefix match 'me' -> mech |
| `member` | `mech` | Phonetic | Phonetic prefix match 'me' -> mech |
| `Mermaid` | `mech` | Phonetic | Phonetic prefix match 'me' -> mech |
| `Meson` | `mesh` | Phonetic | Phonetic prefix match 'mes' -> mesh |
| `message` | `mesh` | Phonetic | Phonetic prefix match 'mes' -> mesh |
| `METAFONT` | `mech` | Phonetic | Phonetic prefix match 'me' -> mech |
| `Metal` | `mech` | Phonetic | Phonetic prefix match 'me' -> mech |
| `MetaPost` | `mech` | Phonetic | Phonetic prefix match 'me' -> mech |
| `Method` | `drive` | Functions | Object drive operation |
| `method` | `drive` | Functions | Object drive operation |
| `MeTTa` | `mech` | Phonetic | Phonetic prefix match 'me' -> mech |
| `MiniD` | `mill` | Phonetic | Phonetic prefix match 'mi' -> mill |
| `minimum` | `mill` | Phonetic | Phonetic prefix match 'mi' -> mill |
| `MiniZinc` | `mill` | Phonetic | Phonetic prefix match 'mi' -> mill |
| `Mint` | `mint` | Primitives | Direct single-syllable match 'mint' |
| `Mirah` | `mill` | Phonetic | Phonetic prefix match 'mi' -> mill |
| `mIRC` | `mill` | Phonetic | Phonetic prefix match 'mi' -> mill |
| `mixin` | `mill` | Phonetic | Phonetic prefix match 'mi' -> mill |
| `mixins` | `mill` | Phonetic | Phonetic prefix match 'mi' -> mill |
| `mkdir` | `mark` | General Lexicon | Acoustic nearest neighbor for 'mkdir' |
| `MLIR` | `mill` | General Lexicon | Acoustic nearest neighbor for 'MLIR' |
| `Modelica` | `mode` | Phonetic | Phonetic prefix match 'mode' -> mode |
| `modifier` | `mode` | Phonetic | Phonetic prefix match 'mod' -> mode |
| `Modula` | `mode` | Phonetic | Phonetic prefix match 'mod' -> mode |
| `Module` | `pod` | Modularity | Detachable equipment pod |
| `module` | `pod` | Modularity | Detachable equipment pod |
| `Mojo` | `mode` | Phonetic | Phonetic prefix match 'mo' -> mode |
| `Monad` | `mode` | Phonetic | Phonetic prefix match 'mo' -> mode |
| `Monkey` | `mode` | Phonetic | Phonetic prefix match 'mo' -> mode |
| `MoonBit` | `moon` | Phonetic | Phonetic prefix match 'moon' -> moon |
| `MoonScript` | `moon` | Phonetic | Phonetic prefix match 'moon' -> moon |
| `mov` | `mov` | Primitives | Direct single-syllable match 'mov' |
| `MOVE` | `move` | Primitives | Direct single-syllable match 'move' |
| `Move` | `move` | Primitives | Direct single-syllable match 'move' |
| `move` | `move` | Primitives | Direct single-syllable match 'move' |
| `MPS` | `mps` | Primitives | Direct single-syllable match 'mps' |
| `MQL4` | `meld` | General Lexicon | Acoustic nearest neighbor for 'MQL4' |
| `MQL5` | `meld` | General Lexicon | Acoustic nearest neighbor for 'MQL5' |
| `MSG` | `msg` | Primitives | Direct single-syllable match 'msg' |
| `msg` | `msg` | Primitives | Direct single-syllable match 'msg' |
| `MUF` | `muf` | Primitives | Direct single-syllable match 'muf' |
| `mul` | `surge` | Arithmetic | Power multiplication surge |
| `mupad` | `mark` | General Lexicon | Acoustic nearest neighbor for 'mupad' |
| `mut` | `shift` | Declarations | Mutable genetic modifier |
| `mutable` | `mast` | General Lexicon | Acoustic nearest neighbor for 'mutable' |
| `mutate` | `mast` | General Lexicon | Acoustic nearest neighbor for 'mutate' |
| `mutating` | `mount` | General Lexicon | Acoustic nearest neighbor for 'mutating' |
| `mutation` | `mount` | General Lexicon | Acoustic nearest neighbor for 'mutation' |
| `my` | `my` | Primitives | Direct single-syllable match 'my' |
| `Myghty` | `mast` | General Lexicon | Acoustic nearest neighbor for 'Myghty' |
| `n` | `net` | General Lexicon | Acoustic nearest neighbor for 'n' |
| `namespace` | `net` | General Lexicon | Acoustic nearest neighbor for 'namespace' |
| `namespaces` | `net` | General Lexicon | Acoustic nearest neighbor for 'namespaces' |
| `NASL` | `net` | General Lexicon | Acoustic nearest neighbor for 'NASL' |
| `nav` | `nav` | Primitives | Direct single-syllable match 'nav' |
| `NCL` | `net` | General Lexicon | Acoustic nearest neighbor for 'NCL' |
| `Nearley` | `net` | Phonetic | Phonetic prefix match 'ne' -> net |
| `NED` | `ned` | Primitives | Direct single-syllable match 'ned' |
| `negedge` | `net` | Phonetic | Phonetic prefix match 'ne' -> net |
| `Nemerle` | `net` | Phonetic | Phonetic prefix match 'ne' -> net |
| `nesC` | `nesc` | Primitives | Direct single-syllable match 'nesc' |
| `nesting` | `net` | Phonetic | Phonetic prefix match 'ne' -> net |
| `NET` | `net` | Primitives | Direct single-syllable match 'net' |
| `NetLinx` | `net` | Phonetic | Phonetic prefix match 'net' -> net |
| `NetLogo` | `net` | Phonetic | Phonetic prefix match 'net' -> net |
| `never` | `net` | Phonetic | Phonetic prefix match 'ne' -> net |
| `New` | `birth` | OOP & Context | Instantiate new unit |
| `new` | `birth` | OOP & Context | Instantiate new unit |
| `NewLisp` | `net` | Phonetic | Phonetic prefix match 'ne' -> net |
| `newtype` | `net` | Phonetic | Phonetic prefix match 'ne' -> net |
| `NEXT` | `next` | Primitives | Direct single-syllable match 'next' |
| `next` | `next` | Primitives | Direct single-syllable match 'next' |
| `Nextflow` | `net` | Phonetic | Phonetic prefix match 'ne' -> net |
| `Nil` | `void` | Data Types | Zero telemetry signal |
| `nil` | `void` | Data Types | Zero telemetry signal |
| `Nim` | `skiff` | Language | Metaprogrammed systems skiff |
| `Nit` | `nit` | Primitives | Direct single-syllable match 'nit' |
| `Nix` | `nix` | Primitives | Direct single-syllable match 'nix' |
| `node` | `node` | Collections | Network relay nexus node |
| `nogc` | `node` | Phonetic | Phonetic prefix match 'no' -> node |
| `Noir` | `noir` | Primitives | Direct single-syllable match 'noir' |
| `None` | `shade` | Data Types | Absence of matter/signal |
| `nonmutating` | `node` | Phonetic | Phonetic prefix match 'no' -> node |
| `normalize` | `node` | Phonetic | Phonetic prefix match 'no' -> node |
| `not` | `bang` | Logic | Inversion null-wave |
| `Nothing` | `node` | Phonetic | Phonetic prefix match 'no' -> node |
| `nothrow` | `node` | Phonetic | Phonetic prefix match 'no' -> node |
| `NOTICE` | `node` | Phonetic | Phonetic prefix match 'no' -> node |
| `ns` | `ns` | Primitives | Direct single-syllable match 'ns' |
| `NSIS` | `night` | General Lexicon | Acoustic nearest neighbor for 'NSIS' |
| `Nu` | `nu` | Primitives | Direct single-syllable match 'nu' |
| `NULL` | `void` | Data Types | Null energy state |
| `null` | `void` | Data Types | Null energy state |
| `nullable` | `nuke` | Phonetic | Phonetic prefix match 'nu' -> nuke |
| `nullptr` | `nuke` | Phonetic | Phonetic prefix match 'nu' -> nuke |
| `number` | `nuke` | Phonetic | Phonetic prefix match 'nu' -> nuke |
| `NumPy` | `nuke` | Phonetic | Phonetic prefix match 'nu' -> nuke |
| `NWScript` | `night` | General Lexicon | Acoustic nearest neighbor for 'NWScript' |
| `Oberon` | `orb` | General Lexicon | Acoustic nearest neighbor for 'Oberon' |
| `Object` | `thing` | OOP & Types | Instantiated matter unit |
| `object` | `thing` | OOP & Types | Instantiated matter unit |
| `Objective` | `orb` | General Lexicon | Acoustic nearest neighbor for 'Objective' |
| `OCaml` | `mount` | Language | Typed ML battle-cruiser |
| `Odin` | `or` | General Lexicon | Acoustic nearest neighbor for 'Odin' |
| `of` | `of` | Primitives | Direct single-syllable match 'of' |
| `off` | `off` | Primitives | Direct single-syllable match 'off' |
| `Ok` | `ok` | Primitives | Direct single-syllable match 'ok' |
| `ok` | `ok` | Primitives | Direct single-syllable match 'ok' |
| `ol` | `ol` | Primitives | Direct single-syllable match 'ol' |
| `Omgrofl` | `or` | General Lexicon | Acoustic nearest neighbor for 'Omgrofl' |
| `OMNeT` | `ore` | General Lexicon | Acoustic nearest neighbor for 'OMNeT' |
| `on` | `on` | Primitives | Direct single-syllable match 'on' |
| `ONBUILD` | `orb` | General Lexicon | Acoustic nearest neighbor for 'ONBUILD' |
| `onClick` | `or` | General Lexicon | Acoustic nearest neighbor for 'onClick' |
| `ooc` | `or` | General Lexicon | Acoustic nearest neighbor for 'ooc' |
| `Opa` | `opa` | Primitives | Direct single-syllable match 'opa' |
| `Opal` | `or` | General Lexicon | Acoustic nearest neighbor for 'Opal' |
| `opaque` | `ore` | General Lexicon | Acoustic nearest neighbor for 'opaque' |
| `OPEN` | `vent` | I/O & Files | Unseal hatch / open stream |
| `Open` | `vent` | I/O & Files | Unseal hatch / open stream |
| `open` | `vent` | I/O & Files | Unseal hatch / open stream |
| `OpenQASM` | `ore` | General Lexicon | Acoustic nearest neighbor for 'OpenQASM' |
| `OpenRC` | `ore` | General Lexicon | Acoustic nearest neighbor for 'OpenRC' |
| `OpenSCAD` | `ore` | General Lexicon | Acoustic nearest neighbor for 'OpenSCAD' |
| `operations` | `ore` | General Lexicon | Acoustic nearest neighbor for 'operations' |
| `Option` | `out` | General Lexicon | Acoustic nearest neighbor for 'Option' |
| `Optional` | `out` | General Lexicon | Acoustic nearest neighbor for 'Optional' |
| `optional` | `out` | General Lexicon | Acoustic nearest neighbor for 'optional' |
| `or` | `or` | Logic | Alternative vector branch |
| `Oracle` | `or` | Phonetic | Phonetic prefix match 'or' -> or |
| `OTHERS` | `ore` | General Lexicon | Acoustic nearest neighbor for 'OTHERS' |
| `our` | `our` | Primitives | Direct single-syllable match 'our' |
| `out` | `out` | Primitives | Direct single-syllable match 'out' |
| `outer` | `out` | Phonetic | Phonetic prefix match 'out' -> out |
| `Output` | `out` | Phonetic | Phonetic prefix match 'out' -> out |
| `output` | `out` | Phonetic | Phonetic prefix match 'out' -> out |
| `OVER` | `ore` | General Lexicon | Acoustic nearest neighbor for 'OVER' |
| `OverpassQL` | `ore` | General Lexicon | Acoustic nearest neighbor for 'OverpassQL' |
| `OverPy` | `ore` | General Lexicon | Acoustic nearest neighbor for 'OverPy' |
| `override` | `ore` | General Lexicon | Acoustic nearest neighbor for 'override' |
| `owned` | `owned` | Primitives | Direct single-syllable match 'owned' |
| `Ox` | `ox` | Primitives | Direct single-syllable match 'ox' |
| `Oxygene` | `ore` | General Lexicon | Acoustic nearest neighbor for 'Oxygene' |
| `Oz` | `oz` | Primitives | Direct single-syllable match 'oz' |
| `P4` | `pace` | General Lexicon | Acoustic nearest neighbor for 'P4' |
| `package` | `pack` | Modularity | Pre-assembled supply pack |
| `Pact` | `pact` | Primitives | Direct single-syllable match 'pact' |
| `padding` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `Pages` | `pages` | Primitives | Direct single-syllable match 'pages' |
| `pair` | `pair` | Primitives | Direct single-syllable match 'pair' |
| `Pan` | `pan` | Primitives | Direct single-syllable match 'pan' |
| `panic` | `scram` | Error Handling | Emergency reactor scram |
| `Papyrus` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `Parallel` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `param` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `parameter` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `parens` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `parent` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `Parrot` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `parse` | `parse` | Primitives | Direct single-syllable match 'parse' |
| `parser` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `Pascal` | `pass` | Phonetic | Phonetic prefix match 'pas' -> pass |
| `PascalCase` | `pass` | Phonetic | Phonetic prefix match 'pas' -> pass |
| `path` | `path` | Primitives | Direct single-syllable match 'path' |
| `Pattern` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `pattern` | `pace` | Phonetic | Phonetic prefix match 'pa' -> pace |
| `pause` | `pause` | Primitives | Direct single-syllable match 'pause' |
| `Pawn` | `pawn` | Primitives | Direct single-syllable match 'pawn' |
| `payable` | `payable` | Primitives | Direct single-syllable match 'payable' |
| `pcall` | `pace` | General Lexicon | Acoustic nearest neighbor for 'pcall' |
| `PDDL` | `pearl` | General Lexicon | Acoustic nearest neighbor for 'PDDL' |
| `PEG` | `peg` | Primitives | Direct single-syllable match 'peg' |
| `Pep8` | `peak` | Phonetic | Phonetic prefix match 'pe' -> peak |
| `PERFORM` | `peak` | Phonetic | Phonetic prefix match 'pe' -> peak |
| `Perl` | `pearl` | Language | Regex string manipulation orb |
| `perl6` | `peak` | Phonetic | Phonetic prefix match 'pe' -> peak |
| `phony` | `phase` | Phonetic | Phonetic prefix match 'ph' -> phase |
| `PIC` | `pic` | Primitives | Direct single-syllable match 'pic' |
| `pid` | `pid` | Primitives | Direct single-syllable match 'pid' |
| `PigLatin` | `pick` | Phonetic | Phonetic prefix match 'pi' -> pick |
| `Pike` | `pike` | Primitives | Direct single-syllable match 'pike' |
| `pipe` | `pipe` | Concurrency | Conduit data pipe |
| `pipefail` | `pipe` | Phonetic | Phonetic prefix match 'pipe' -> pipe |
| `PixelShader` | `pick` | Phonetic | Phonetic prefix match 'pi' -> pick |
| `Pkl` | `pack` | General Lexicon | Acoustic nearest neighbor for 'Pkl' |
| `placeholder` | `plate` | Phonetic | Phonetic prefix match 'pla' -> plate |
| `PlantUML` | `plate` | Phonetic | Phonetic prefix match 'pla' -> plate |
| `PLpgSQL` | `plate` | Phonetic | Phonetic prefix match 'pl' -> plate |
| `PLSQL` | `plate` | Phonetic | Phonetic prefix match 'pl' -> plate |
| `Plutus` | `plug` | Phonetic | Phonetic prefix match 'plu' -> plug |
| `PogoScript` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `Pointer` | `point` | Low Level | Targeting vector pointer |
| `pointer` | `point` | Low Level | Targeting vector pointer |
| `Polar` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `Policy` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `polygon` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `Pony` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `pop` | `pop` | Primitives | Direct single-syllable match 'pop' |
| `port` | `port` | Networking | Orbital communications port |
| `Portugol` | `port` | Phonetic | Phonetic prefix match 'port' -> port |
| `posedge` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `POSITION` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `Position` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `position` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `PostgreSQL` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `POV` | `pov` | Primitives | Direct single-syllable match 'pov' |
| `Power` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `PowerBuilder` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `PowerShell` | `pod` | Phonetic | Phonetic prefix match 'po' -> pod |
| `Praat` | `press` | Phonetic | Phonetic prefix match 'pr' -> press |
| `pragma` | `press` | Phonetic | Phonetic prefix match 'pr' -> press |
| `precision` | `press` | Phonetic | Phonetic prefix match 'pre' -> press |
| `predicate` | `press` | Phonetic | Phonetic prefix match 'pre' -> press |
| `prerequisites` | `press` | Phonetic | Phonetic prefix match 'pre' -> press |
| `print` | `cast` | I/O & Files | Broadcast text to HUD |
| `printf` | `cast` | I/O & Files | Formatted HUD projection |
| `println` | `prime` | Phonetic | Phonetic prefix match 'pri' -> prime |
| `private` | `cloak` | Modifiers | Cloaked stealth frequency |
| `Pro` | `pro` | Primitives | Direct single-syllable match 'pro' |
| `proc` | `proc` | Primitives | Direct single-syllable match 'proc' |
| `PROCEDURE` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `procedure` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `process` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `Processing` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `Procfile` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `product` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `PROGRAM` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `Program` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `program` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `Programming` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `programming` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `project` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `Promela` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `Promise` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `proof` | `proof` | Primitives | Direct single-syllable match 'proof' |
| `prop` | `prop` | Primitives | Direct single-syllable match 'prop' |
| `Propeller` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `property` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `props` | `props` | Primitives | Direct single-syllable match 'props' |
| `protected` | `shield` | Modifiers | Shielded fleet access |
| `Proto` | `wire` | Serialization | Protobuf binary wire format |
| `proto3` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `protobuf` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `Protocol` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `protocol` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `Prover` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `provide` | `probe` | Phonetic | Phonetic prefix match 'pro' -> probe |
| `ptr` | `point` | Low Level | Direct address point |
| `pub` | `broad` | Modifiers | Broadcast public frequency |
| `public` | `broad` | Modifiers | Open broadcast channel |
| `pure` | `pure` | Primitives | Direct single-syllable match 'pure' |
| `PureBasic` | `pure` | Phonetic | Phonetic prefix match 'pure' -> pure |
| `PureScript` | `pure` | Phonetic | Phonetic prefix match 'pure' -> pure |
| `push` | `push` | Primitives | Direct single-syllable match 'push' |
| `puts` | `puts` | Primitives | Direct single-syllable match 'puts' |
| `px` | `px` | Primitives | Direct single-syllable match 'px' |
| `pydantic` | `pyre` | Phonetic | Phonetic prefix match 'py' -> pyre |
| `Pyret` | `pyre` | Phonetic | Phonetic prefix match 'pyre' -> pyre |
| `Python` | `coil` | Language | Cyber-serpent runtime |
| `PythonInterface` | `pyre` | Phonetic | Phonetic prefix match 'py' -> pyre |
| `Q` | `queen` | General Lexicon | Acoustic nearest neighbor for 'Q' |
| `qed` | `qed` | Primitives | Direct single-syllable match 'qed' |
| `QML` | `quell` | General Lexicon | Acoustic nearest neighbor for 'QML' |
| `quad` | `quad` | Primitives | Direct single-syllable match 'quad' |
| `Quake` | `quake` | Primitives | Direct single-syllable match 'quake' |
| `QuakeC` | `queen` | Phonetic | Phonetic prefix match 'qu' -> queen |
| `qualified` | `queen` | Phonetic | Phonetic prefix match 'qu' -> queen |
| `quasiquote` | `queen` | Phonetic | Phonetic prefix match 'qu' -> queen |
| `QUERY` | `queen` | Phonetic | Phonetic prefix match 'que' -> queen |
| `Query` | `queen` | Phonetic | Phonetic prefix match 'que' -> queen |
| `query` | `queen` | Phonetic | Phonetic prefix match 'que' -> queen |
| `Quint` | `quint` | Primitives | Direct single-syllable match 'quint' |
| `quote` | `quote` | Primitives | Direct single-syllable match 'quote' |
| `R` | `ray` | Language | Statistical sensor beam analysis |
| `r` | `ray` | Language | Statistical sensor beam analysis |
| `Racket` | `rack` | Phonetic | Phonetic prefix match 'rack' -> rack |
| `Ragel` | `rack` | Phonetic | Phonetic prefix match 'ra' -> rack |
| `RAISE` | `flare` | Error Handling | Signal alert flare |
| `raise` | `flare` | Error Handling | Signal alert flare |
| `raised` | `raised` | Primitives | Direct single-syllable match 'raised' |
| `Raku` | `rack` | Phonetic | Phonetic prefix match 'ra' -> rack |
| `range` | `range` | Primitives | Direct single-syllable match 'range' |
| `rank` | `rank` | Primitives | Direct single-syllable match 'rank' |
| `Rascal` | `rack` | Phonetic | Phonetic prefix match 'ra' -> rack |
| `RAScript` | `rack` | Phonetic | Phonetic prefix match 'ra' -> rack |
| `rax` | `rax` | Primitives | Direct single-syllable match 'rax' |
| `Ray` | `ray` | Primitives | Direct single-syllable match 'ray' |
| `rbp` | `rip` | General Lexicon | Acoustic nearest neighbor for 'rbp' |
| `rbx` | `rack` | General Lexicon | Acoustic nearest neighbor for 'rbx' |
| `React` | `react` | Primitives | Direct single-syllable match 'react' |
| `reader` | `read` | Phonetic | Phonetic prefix match 'read' -> read |
| `readonly` | `read` | Phonetic | Phonetic prefix match 'read' -> read |
| `real` | `real` | Primitives | Direct single-syllable match 'real' |
| `REALbasic` | `realm` | Phonetic | Phonetic prefix match 'real' -> realm |
| `ReasonLIGO` | `read` | Phonetic | Phonetic prefix match 'rea' -> read |
| `Rebol` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `rec` | `rec` | Primitives | Direct single-syllable match 'rec' |
| `receive` | `catch` | Concurrency | Capture incoming signal |
| `recipe` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `record` | `log` | Data Types | Black-box telemetry record |
| `recover` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `rect` | `rect` | Primitives | Direct single-syllable match 'rect' |
| `recur` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `Red` | `red` | Primitives | Direct single-syllable match 'red' |
| `Redcode` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `redirect` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `reduce` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `ref` | `link` | Low Level | Tethered memory link |
| `reg` | `slot` | Hardware | Micro-register slot |
| `regex` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `rem` | `rem` | Primitives | Direct single-syllable match 'rem' |
| `Remove` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `remove` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `RenderScript` | `rend` | Phonetic | Phonetic prefix match 'rend' -> rend |
| `repeat` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `repeated` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `REPL` | `repl` | Primitives | Direct single-syllable match 'repl' |
| `Repo` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `Representation` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `require` | `claim` | Modularity | Demand required component |
| `required` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `ReScript` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `reset` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `Result` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `ret` | `ret` | Primitives | Direct single-syllable match 'ret' |
| `RETURN` | `yield` | Control Flow | Emit value or beam output |
| `return` | `yield` | Control Flow | Emit value or beam output |
| `returns` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `revert` | `read` | Phonetic | Phonetic prefix match 're' -> read |
| `REXX` | `rexx` | Primitives | Direct single-syllable match 'rexx' |
| `Rhai` | `raid` | General Lexicon | Acoustic nearest neighbor for 'Rhai' |
| `rho` | `rho` | Primitives | Direct single-syllable match 'rho' |
| `Right` | `right` | Primitives | Direct single-syllable match 'right' |
| `Ring` | `ring` | Primitives | Direct single-syllable match 'ring' |
| `rm` | `rm` | Primitives | Direct single-syllable match 'rm' |
| `RobotFramework` | `rock` | Phonetic | Phonetic prefix match 'ro' -> rock |
| `Roc` | `roc` | Primitives | Direct single-syllable match 'roc' |
| `Rocq` | `rock` | Phonetic | Phonetic prefix match 'roc' -> rock |
| `role` | `role` | Primitives | Direct single-syllable match 'role' |
| `ROOT` | `root` | Primitives | Direct single-syllable match 'root' |
| `ROT` | `rot` | Primitives | Direct single-syllable match 'rot' |
| `Rouge` | `rouge` | Primitives | Direct single-syllable match 'rouge' |
| `rpc` | `rpc` | Primitives | Direct single-syllable match 'rpc' |
| `RPGLE` | `realm` | General Lexicon | Acoustic nearest neighbor for 'RPGLE' |
| `rsp` | `rip` | General Lexicon | Acoustic nearest neighbor for 'rsp' |
| `Ruby` | `gem` | Language | Precious syntax crystal |
| `rule` | `rule` | Primitives | Direct single-syllable match 'rule' |
| `rulesets` | `rule` | Phonetic | Phonetic prefix match 'rule' -> rule |
| `RUN` | `run` | Primitives | Direct single-syllable match 'run' |
| `runscript` | `rune` | Phonetic | Phonetic prefix match 'run' -> rune |
| `s` | `scald` | General Lexicon | Acoustic nearest neighbor for 's' |
| `safe` | `safe` | Primitives | Direct single-syllable match 'safe' |
| `Sage` | `sage` | Primitives | Direct single-syllable match 'sage' |
| `Sail` | `sail` | Primitives | Direct single-syllable match 'sail' |
| `Salt` | `salt` | Primitives | Direct single-syllable match 'salt' |
| `sampler` | `spear` | General Lexicon | Acoustic nearest neighbor for 'sampler' |
| `sampler2D` | `spear` | General Lexicon | Acoustic nearest neighbor for 'sampler2D' |
| `SamplerState` | `stream` | General Lexicon | Acoustic nearest neighbor for 'SamplerState' |
| `SAS` | `sas` | Primitives | Direct single-syllable match 'sas' |
| `Sass` | `sass` | Primitives | Direct single-syllable match 'sass' |
| `saturate` | `stream` | General Lexicon | Acoustic nearest neighbor for 'saturate' |
| `say` | `say` | Primitives | Direct single-syllable match 'say' |
| `Scala` | `climb` | Language | Scalable type pinnacle |
| `scalar` | `scald` | Phonetic | Phonetic prefix match 'scal' -> scald |
| `scan` | `scan` | Primitives | Direct single-syllable match 'scan' |
| `Scenic` | `scald` | Phonetic | Phonetic prefix match 'sc' -> scald |
| `schema` | `scald` | Phonetic | Phonetic prefix match 'sc' -> scald |
| `Scheme` | `scheme` | Primitives | Direct single-syllable match 'scheme' |
| `Scilab` | `scald` | Phonetic | Phonetic prefix match 'sc' -> scald |
| `Score` | `score` | Primitives | Direct single-syllable match 'score' |
| `Script` | `script` | Primitives | Direct single-syllable match 'script' |
| `script` | `script` | Primitives | Direct single-syllable match 'script' |
| `SCSS` | `scald` | Phonetic | Phonetic prefix match 'sc' -> scald |
| `SDL` | `sdl` | Primitives | Direct single-syllable match 'sdl' |
| `sealed` | `sealed` | Primitives | Direct single-syllable match 'sealed' |
| `SECTION` | `seal` | Phonetic | Phonetic prefix match 'se' -> seal |
| `section` | `seal` | Phonetic | Phonetic prefix match 'se' -> seal |
| `sed` | `sed` | Primitives | Direct single-syllable match 'sed' |
| `select` | `pick` | Concurrency | Multiplexed signal pick |
| `selector` | `seal` | Phonetic | Phonetic prefix match 'se' -> seal |
| `Self` | `helm` | OOP & Context | Current ship command helm |
| `self` | `helm` | OOP & Context | Current ship command helm |
| `semicolon` | `seal` | Phonetic | Phonetic prefix match 'se' -> seal |
| `send` | `beam` | Concurrency | Transmit packet beam |
| `sender` | `seal` | Phonetic | Phonetic prefix match 'se' -> seal |
| `seq` | `seq` | Primitives | Direct single-syllable match 'seq' |
| `Server` | `hive` | Networking | Central nexus hive |
| `server` | `hive` | Networking | Central nexus hive |
| `service` | `seal` | Phonetic | Phonetic prefix match 'se' -> seal |
| `Set` | `ring` | Collections | Unique orbital ring elements |
| `set` | `ring` | Collections | Unique orbital ring elements |
| `setq` | `seal` | Phonetic | Phonetic prefix match 'se' -> seal |
| `setter` | `seal` | Phonetic | Phonetic prefix match 'se' -> seal |
| `Setup` | `seal` | Phonetic | Phonetic prefix match 'se' -> seal |
| `sh` | `sh` | Primitives | Direct single-syllable match 'sh' |
| `shadow` | `shade` | Phonetic | Phonetic prefix match 'shad' -> shade |
| `shape` | `shape` | Primitives | Direct single-syllable match 'shape' |
| `shared` | `shared` | Primitives | Direct single-syllable match 'shared' |
| `SHELL` | `shell` | Primitives | Direct single-syllable match 'shell' |
| `Shell` | `shell` | Primitives | Direct single-syllable match 'shell' |
| `ShellSession` | `sheet` | Phonetic | Phonetic prefix match 'she' -> sheet |
| `Shen` | `shen` | Primitives | Direct single-syllable match 'shen' |
| `shift` | `shift` | Primitives | Direct single-syllable match 'shift' |
| `Sieve` | `sieve` | Primitives | Direct single-syllable match 'sieve' |
| `sig` | `sig` | Primitives | Direct single-syllable match 'sig' |
| `signal` | `ping` | Concurrency | Subspace beacon ping |
| `signature` | `sign` | Phonetic | Phonetic prefix match 'sign' -> sign |
| `signer` | `sign` | Phonetic | Phonetic prefix match 'sign' -> sign |
| `SIMD` | `simd` | Primitives | Direct single-syllable match 'simd' |
| `Singularity` | `sink` | Phonetic | Phonetic prefix match 'sin' -> sink |
| `SIP` | `sip` | Primitives | Direct single-syllable match 'sip' |
| `size` | `size` | Primitives | Direct single-syllable match 'size' |
| `sizeof` | `siege` | Phonetic | Phonetic prefix match 'si' -> siege |
| `Slang` | `slang` | Primitives | Direct single-syllable match 'slang' |
| `Slash` | `slash` | Primitives | Direct single-syllable match 'slash' |
| `Smali` | `smash` | Phonetic | Phonetic prefix match 'sma' -> smash |
| `Smalltalk` | `smash` | Phonetic | Phonetic prefix match 'sma' -> smash |
| `Smithy` | `smite` | Phonetic | Phonetic prefix match 'smit' -> smite |
| `SmPL` | `smash` | Phonetic | Phonetic prefix match 'sm' -> smash |
| `SMT` | `smt` | Primitives | Direct single-syllable match 'smt' |
| `snake` | `snake` | Primitives | Direct single-syllable match 'snake' |
| `Snakemake` | `snag` | Phonetic | Phonetic prefix match 'sna' -> snag |
| `Solidity` | `chain` | Language | Blockchain consensus contracts |
| `Some` | `some` | Primitives | Direct single-syllable match 'some' |
| `some` | `some` | Primitives | Direct single-syllable match 'some' |
| `SourcePawn` | `source` | Phonetic | Phonetic prefix match 'sour' -> source |
| `span` | `span` | Primitives | Direct single-syllable match 'span' |
| `spawn` | `spawn` | Concurrency | Spawn autonomous worker |
| `spec` | `spec` | Primitives | Direct single-syllable match 'spec' |
| `Spin` | `spin` | Primitives | Direct single-syllable match 'spin' |
| `split` | `split` | Primitives | Direct single-syllable match 'split' |
| `SQF` | `squad` | Phonetic | Phonetic prefix match 'sq' -> squad |
| `square` | `square` | Primitives | Direct single-syllable match 'square' |
| `Squirrel` | `squad` | Phonetic | Phonetic prefix match 'squ' -> squad |
| `src` | `src` | Primitives | Direct single-syllable match 'src' |
| `SRecode` | `source` | General Lexicon | Acoustic nearest neighbor for 'SRecode' |
| `stage` | `stage` | Primitives | Direct single-syllable match 'stage' |
| `Stan` | `stan` | Primitives | Direct single-syllable match 'stan' |
| `starknet` | `star` | Phonetic | Phonetic prefix match 'star' -> star |
| `Starlark` | `star` | Phonetic | Phonetic prefix match 'star' -> star |
| `Stata` | `stack` | Phonetic | Phonetic prefix match 'sta' -> stack |
| `state` | `state` | Primitives | Direct single-syllable match 'state' |
| `StatefulWidget` | `stack` | Phonetic | Phonetic prefix match 'sta' -> stack |
| `StatelessWidget` | `stack` | Phonetic | Phonetic prefix match 'sta' -> stack |
| `static` | `fixed` | Declarations | Stationary base station |
| `std` | `std` | Primitives | Direct single-syllable match 'std' |
| `stdbool` | `stack` | Phonetic | Phonetic prefix match 'st' -> stack |
| `stdio` | `stack` | Phonetic | Phonetic prefix match 'st' -> stack |
| `stdlib` | `stack` | Phonetic | Phonetic prefix match 'st' -> stack |
| `STOP` | `stop` | Primitives | Direct single-syllable match 'stop' |
| `STOPSIGNAL` | `stone` | Phonetic | Phonetic prefix match 'sto' -> stone |
| `STORAGE` | `storm` | Phonetic | Phonetic prefix match 'stor' -> storm |
| `storage` | `storm` | Phonetic | Phonetic prefix match 'stor' -> storm |
| `store` | `store` | Primitives | Direct single-syllable match 'store' |
| `str` | `wire` | Data Types | Phonetic / fiber-optic wire |
| `Stream` | `flow` | Concurrency | Continuous plasma flow |
| `String` | `strand` | Data Types | Linear peptide/nanowire strand |
| `string` | `strand` | Data Types | Linear peptide/nanowire strand |
| `stroke` | `stroke` | Primitives | Direct single-syllable match 'stroke' |
| `Struct` | `hull` | Data Types | Composite hull structure |
| `struct` | `hull` | Data Types | Composite hull structure |
| `Style` | `style` | Primitives | Direct single-syllable match 'style' |
| `sub` | `drop` | Arithmetic | Particle depletion |
| `subscription` | `sun` | Phonetic | Phonetic prefix match 'su' -> sun |
| `subtype` | `sun` | Phonetic | Phonetic prefix match 'su' -> sun |
| `super` | `prime` | OOP & Context | Parent flagship prime |
| `SurrealQL` | `surge` | Phonetic | Phonetic prefix match 'sur' -> surge |
| `suspend` | `sun` | Phonetic | Phonetic prefix match 'su' -> sun |
| `SV` | `sv` | Primitives | Direct single-syllable match 'sv' |
| `SVG` | `siege` | General Lexicon | Acoustic nearest neighbor for 'SVG' |
| `svg` | `siege` | General Lexicon | Acoustic nearest neighbor for 'svg' |
| `SWAP` | `swap` | Primitives | Direct single-syllable match 'swap' |
| `swap` | `swap` | Primitives | Direct single-syllable match 'swap' |
| `Sway` | `sway` | Primitives | Direct single-syllable match 'sway' |
| `Swift` | `swift` | Language | High-velocity client stardrive |
| `switch` | `shift` | Control Flow | Multi-position relay shift |
| `symbol` | `sync` | Phonetic | Phonetic prefix match 'sy' -> sync |
| `syntax` | `synth` | Phonetic | Phonetic prefix match 'synt' -> synth |
| `SysML` | `sync` | Phonetic | Phonetic prefix match 'sy' -> sync |
| `System` | `sync` | Phonetic | Phonetic prefix match 'sy' -> sync |
| `SystemVerilog` | `sync` | Phonetic | Phonetic prefix match 'sy' -> sync |
| `t` | `tag` | General Lexicon | Acoustic nearest neighbor for 't' |
| `tab` | `tab` | Primitives | Direct single-syllable match 'tab' |
| `table` | `table` | Primitives | Direct single-syllable match 'table' |
| `TableGen` | `tag` | Phonetic | Phonetic prefix match 'ta' -> tag |
| `tag` | `tag` | Primitives | Direct single-syllable match 'tag' |
| `Talon` | `tag` | Phonetic | Phonetic prefix match 'ta' -> tag |
| `Tape` | `tape` | Primitives | Direct single-syllable match 'tape' |
| `Target` | `tag` | Phonetic | Phonetic prefix match 'ta' -> tag |
| `target` | `tag` | Phonetic | Phonetic prefix match 'ta' -> tag |
| `Task` | `task` | Concurrency | Drone sub-mission task |
| `task` | `task` | Concurrency | Drone sub-mission task |
| `Tcl` | `tick` | General Lexicon | Acoustic nearest neighbor for 'Tcl' |
| `Tcsh` | `thrust` | General Lexicon | Acoustic nearest neighbor for 'Tcsh' |
| `td` | `td` | Primitives | Direct single-syllable match 'td' |
| `Teal` | `teal` | Primitives | Direct single-syllable match 'teal' |
| `Template` | `mold` | Metaprogramming | Fabricator assembly mold |
| `template` | `mold` | Metaprogramming | Fabricator assembly mold |
| `Templates` | `tear` | Phonetic | Phonetic prefix match 'te' -> tear |
| `Tensor` | `tear` | Phonetic | Phonetic prefix match 'te' -> tear |
| `term` | `term` | Primitives | Direct single-syllable match 'term' |
| `Terraform` | `tear` | Phonetic | Phonetic prefix match 'te' -> tear |
| `text` | `text` | Primitives | Direct single-syllable match 'text' |
| `texture` | `tear` | Phonetic | Phonetic prefix match 'te' -> tear |
| `Texture2D` | `tear` | Phonetic | Phonetic prefix match 'te' -> tear |
| `texture2d` | `tear` | Phonetic | Phonetic prefix match 'te' -> tear |
| `th` | `th` | Primitives | Direct single-syllable match 'th' |
| `THEN` | `then` | Primitives | Direct single-syllable match 'then' |
| `then` | `then` | Primitives | Direct single-syllable match 'then' |
| `theorem` | `thing` | Phonetic | Phonetic prefix match 'th' -> thing |
| `this` | `helm` | OOP & Context | Local vessel helm |
| `thread` | `strand` | Concurrency | Parallel quantum strand |
| `threadgroup` | `thrust` | Phonetic | Phonetic prefix match 'thr' -> thrust |
| `Thrift` | `thrift` | Primitives | Direct single-syllable match 'thrift' |
| `throw` | `pitch` | Error Handling | Eject fault into stream |
| `throws` | `throws` | Primitives | Direct single-syllable match 'throws' |
| `TI` | `ti` | Primitives | Direct single-syllable match 'ti' |
| `tibble` | `tick` | Phonetic | Phonetic prefix match 'ti' -> tick |
| `tidyverse` | `tide` | Phonetic | Phonetic prefix match 'tid' -> tide |
| `title` | `title` | Primitives | Direct single-syllable match 'title' |
| `TL` | `tl` | Primitives | Direct single-syllable match 'tl' |
| `TLA` | `tla` | Primitives | Direct single-syllable match 'tla' |
| `to` | `to` | Primitives | Direct single-syllable match 'to' |
| `todo` | `tone` | Phonetic | Phonetic prefix match 'to' -> tone |
| `Toit` | `toit` | Primitives | Direct single-syllable match 'toit' |
| `token` | `tone` | Phonetic | Phonetic prefix match 'to' -> tone |
| `Tolk` | `tone` | Phonetic | Phonetic prefix match 'to' -> tone |
| `TOML` | `chart` | Data Format | Configuration parameter table |
| `tr` | `tr` | Primitives | Direct single-syllable match 'tr' |
| `trait` | `gene` | OOP & Types | Genetic behavior trait |
| `Transcript` | `trace` | Phonetic | Phonetic prefix match 'tra' -> trace |
| `transform` | `trace` | Phonetic | Phonetic prefix match 'tra' -> trace |
| `True` | `pulse` | Data Types | Active high signal pulse |
| `true` | `pulse` | Data Types | Active high signal pulse |
| `try` | `probe` | Error Handling | Speculative execution probe |
| `TS` | `ts` | Primitives | Direct single-syllable match 'ts' |
| `TSRX` | `thrust` | General Lexicon | Acoustic nearest neighbor for 'TSRX' |
| `TSX` | `task` | General Lexicon | Acoustic nearest neighbor for 'TSX' |
| `tuple` | `pack` | Data Types | Compact multi-payload pod |
| `TXL` | `tag` | General Lexicon | Acoustic nearest neighbor for 'TXL' |
| `type` | `form` | Data Types | Physical matter type form |
| `typedef` | `type` | Phonetic | Phonetic prefix match 'type' -> type |
| `typename` | `type` | Phonetic | Phonetic prefix match 'type' -> type |
| `typeof` | `type` | Phonetic | Phonetic prefix match 'type' -> type |
| `TypeScript` | `type` | Language | Type-fortified hyperscript |
| `TypeSpec` | `type` | Phonetic | Phonetic prefix match 'type' -> type |
| `Typst` | `type` | Phonetic | Phonetic prefix match 'typ' -> type |
| `u128` | `bound` | General Lexicon | Acoustic nearest neighbor for 'u128' |
| `u256` | `bound` | General Lexicon | Acoustic nearest neighbor for 'u256' |
| `u32` | `bound` | General Lexicon | Acoustic nearest neighbor for 'u32' |
| `u64` | `bound` | General Lexicon | Acoustic nearest neighbor for 'u64' |
| `u8` | `bound` | General Lexicon | Acoustic nearest neighbor for 'u8' |
| `uint256` | `count` | General Lexicon | Acoustic nearest neighbor for 'uint256' |
| `uint32` | `count` | General Lexicon | Acoustic nearest neighbor for 'uint32' |
| `Uiua` | `bail` | General Lexicon | Acoustic nearest neighbor for 'Uiua' |
| `ul` | `ul` | Primitives | Direct single-syllable match 'ul' |
| `undefined` | `field` | General Lexicon | Acoustic nearest neighbor for 'undefined' |
| `Unified` | `field` | General Lexicon | Acoustic nearest neighbor for 'Unified' |
| `uniform` | `form` | General Lexicon | Acoustic nearest neighbor for 'uniform' |
| `unify` | `fin` | General Lexicon | Acoustic nearest neighbor for 'unify' |
| `union` | `meld` | Data Types | Overlapping quantum state |
| `unique` | `queen` | General Lexicon | Acoustic nearest neighbor for 'unique' |
| `unit` | `count` | General Lexicon | Acoustic nearest neighbor for 'unit' |
| `unknown` | `bound` | General Lexicon | Acoustic nearest neighbor for 'unknown' |
| `unless` | `plunge` | General Lexicon | Acoustic nearest neighbor for 'unless' |
| `Uno` | `uno` | Primitives | Direct single-syllable match 'uno' |
| `unquote` | `count` | General Lexicon | Acoustic nearest neighbor for 'unquote' |
| `unreachable` | `branch` | General Lexicon | Acoustic nearest neighbor for 'unreachable' |
| `UnrealScript` | `cruise` | General Lexicon | Acoustic nearest neighbor for 'UnrealScript' |
| `UNTIL` | `flint` | General Lexicon | Acoustic nearest neighbor for 'UNTIL' |
| `until` | `flint` | General Lexicon | Acoustic nearest neighbor for 'until' |
| `Untyped` | `plunge` | General Lexicon | Acoustic nearest neighbor for 'Untyped' |
| `UrWeb` | `brew` | General Lexicon | Acoustic nearest neighbor for 'UrWeb' |
| `use` | `draw` | Modularity | Draw power from module |
| `useCallback` | `base` | General Lexicon | Acoustic nearest neighbor for 'useCallback' |
| `useContext` | `count` | General Lexicon | Acoustic nearest neighbor for 'useContext' |
| `useEffect` | `caste` | General Lexicon | Acoustic nearest neighbor for 'useEffect' |
| `useMemo` | `source` | General Lexicon | Acoustic nearest neighbor for 'useMemo' |
| `USER` | `cruise` | General Lexicon | Acoustic nearest neighbor for 'USER' |
| `useRef` | `cruise` | General Lexicon | Acoustic nearest neighbor for 'useRef' |
| `uses` | `uses` | Primitives | Direct single-syllable match 'uses' |
| `useState` | `caste` | General Lexicon | Acoustic nearest neighbor for 'useState' |
| `using` | `sign` | General Lexicon | Acoustic nearest neighbor for 'using' |
| `usize` | `cruise` | General Lexicon | Acoustic nearest neighbor for 'usize' |
| `val` | `lock` | Declarations | Immutable static value |
| `Vala` | `valve` | Phonetic | Phonetic prefix match 'val' -> valve |
| `value` | `valve` | Phonetic | Phonetic prefix match 'val' -> valve |
| `var` | `flux` | Declarations | Variable dynamic flux |
| `VARIABLE` | `flux` | Declarations | Mutable flux register |
| `variable` | `flux` | Declarations | Mutable flux register |
| `variables` | `valve` | Phonetic | Phonetic prefix match 'va' -> valve |
| `VBScript` | `vise` | General Lexicon | Acoustic nearest neighbor for 'VBScript' |
| `VCL` | `valve` | General Lexicon | Acoustic nearest neighbor for 'VCL' |
| `vec2` | `veer` | Phonetic | Phonetic prefix match 've' -> veer |
| `vec2f` | `veer` | Phonetic | Phonetic prefix match 've' -> veer |
| `vec3` | `veer` | Phonetic | Phonetic prefix match 've' -> veer |
| `vec3f` | `veer` | Phonetic | Phonetic prefix match 've' -> veer |
| `vec4` | `veer` | Phonetic | Phonetic prefix match 've' -> veer |
| `vec4f` | `veer` | Phonetic | Phonetic prefix match 've' -> veer |
| `Vector` | `ray` | Collections | Directional array vector beam |
| `vector` | `ray` | Collections | Directional array vector beam |
| `Velocity` | `veer` | Phonetic | Phonetic prefix match 've' -> veer |
| `Verilog` | `veer` | Phonetic | Phonetic prefix match 've' -> veer |
| `Verse` | `verse` | Primitives | Direct single-syllable match 'verse' |
| `vertex` | `veer` | Phonetic | Phonetic prefix match 've' -> veer |
| `VertexShader` | `veer` | Phonetic | Phonetic prefix match 've' -> veer |
| `VHDL` | `vhdl` | Primitives | Direct single-syllable match 'vhdl' |
| `view` | `view` | Primitives | Direct single-syllable match 'view' |
| `viewBox` | `vise` | Phonetic | Phonetic prefix match 'vi' -> vise |
| `Vim` | `vim` | Primitives | Direct single-syllable match 'vim' |
| `virtual` | `vise` | Phonetic | Phonetic prefix match 'vi' -> vise |
| `Visual` | `vise` | Phonetic | Phonetic prefix match 'vis' -> vise |
| `void` | `void` | Data Types | Empty space vacuum state |
| `Volt` | `volt` | Primitives | Direct single-syllable match 'volt' |
| `VOLUME` | `volt` | Phonetic | Phonetic prefix match 'vol' -> volt |
| `Vyper` | `veer` | General Lexicon | Acoustic nearest neighbor for 'Vyper' |
| `warn` | `warn` | Primitives | Direct single-syllable match 'warn' |
| `WDL` | `weld` | General Lexicon | Acoustic nearest neighbor for 'WDL' |
| `WebAssembly` | `weld` | Phonetic | Phonetic prefix match 'we' -> weld |
| `WebIDL` | `weld` | Phonetic | Phonetic prefix match 'we' -> weld |
| `WESL` | `weld` | Phonetic | Phonetic prefix match 'we' -> weld |
| `WGSL` | `wall` | General Lexicon | Acoustic nearest neighbor for 'WGSL' |
| `WHEN` | `when` | Primitives | Direct single-syllable match 'when' |
| `when` | `when` | Primitives | Direct single-syllable match 'when' |
| `where` | `where` | Primitives | Direct single-syllable match 'where' |
| `while` | `hold` | Control Flow | Conditional stasis loop |
| `Whiley` | `whir` | Phonetic | Phonetic prefix match 'whi' -> whir |
| `Widget` | `wing` | Phonetic | Phonetic prefix match 'wi' -> wing |
| `width` | `width` | Primitives | Direct single-syllable match 'width' |
| `wildcard` | `wing` | Phonetic | Phonetic prefix match 'wi' -> wing |
| `wire` | `wire` | Primitives | Direct single-syllable match 'wire' |
| `wisp` | `wisp` | Primitives | Direct single-syllable match 'wisp' |
| `Witcher` | `wing` | Phonetic | Phonetic prefix match 'wi' -> wing |
| `with` | `with` | Primitives | Direct single-syllable match 'with' |
| `without` | `wing` | Phonetic | Phonetic prefix match 'wi' -> wing |
| `Wolfram` | `wall` | General Lexicon | Acoustic nearest neighbor for 'Wolfram' |
| `Wollok` | `wake` | General Lexicon | Acoustic nearest neighbor for 'Wollok' |
| `WORKDIR` | `ward` | General Lexicon | Acoustic nearest neighbor for 'WORKDIR' |
| `Workflow` | `wake` | General Lexicon | Acoustic nearest neighbor for 'Workflow' |
| `workgroup` | `warp` | General Lexicon | Acoustic nearest neighbor for 'workgroup' |
| `WORKING` | `wing` | General Lexicon | Acoustic nearest neighbor for 'WORKING' |
| `Wren` | `wren` | Primitives | Direct single-syllable match 'wren' |
| `Write` | `etch` | I/O & Files | Laser etch payload to disk |
| `writeln` | `wire` | General Lexicon | Acoustic nearest neighbor for 'writeln' |
| `x` | `fixed` | General Lexicon | Acoustic nearest neighbor for 'x' |
| `X10` | `fixed` | General Lexicon | Acoustic nearest neighbor for 'X10' |
| `xBase` | `base` | General Lexicon | Acoustic nearest neighbor for 'xBase' |
| `XC` | `xc` | Primitives | Direct single-syllable match 'xc' |
| `Xmake` | `beam` | General Lexicon | Acoustic nearest neighbor for 'Xmake' |
| `XML` | `tag` | Data Format | Tagged hierarchical payload |
| `xmlns` | `slam` | General Lexicon | Acoustic nearest neighbor for 'xmlns' |
| `Xojo` | `jolt` | General Lexicon | Acoustic nearest neighbor for 'Xojo' |
| `Xonsh` | `ghost` | General Lexicon | Acoustic nearest neighbor for 'Xonsh' |
| `XProc` | `crop` | General Lexicon | Acoustic nearest neighbor for 'XProc' |
| `XQuery` | `cruise` | General Lexicon | Acoustic nearest neighbor for 'XQuery' |
| `XS` | `xs` | Primitives | Direct single-syllable match 'xs' |
| `XSLT` | `blast` | General Lexicon | Acoustic nearest neighbor for 'XSLT' |
| `Xtend` | `drone` | General Lexicon | Acoustic nearest neighbor for 'Xtend' |
| `y` | `yaw` | General Lexicon | Acoustic nearest neighbor for 'y' |
| `Yacc` | `yacc` | Primitives | Direct single-syllable match 'yacc' |
| `YAML` | `tree` | Data Format | Indented human-readable spec |
| `YARA` | `yaw` | Phonetic | Phonetic prefix match 'ya' -> yaw |
| `yield` | `yield` | Control Flow | Surrender execution slice |
| `Yul` | `yul` | Primitives | Direct single-syllable match 'yul' |
| `z` | `zap` | General Lexicon | Acoustic nearest neighbor for 'z' |
| `ZAP` | `zap` | Primitives | Direct single-syllable match 'zap' |
| `Zeek` | `zone` | General Lexicon | Acoustic nearest neighbor for 'Zeek' |
| `ZenScript` | `zone` | General Lexicon | Acoustic nearest neighbor for 'ZenScript' |
| `Zephir` | `zap` | General Lexicon | Acoustic nearest neighbor for 'Zephir' |
| `Zig` | `bolt` | Language | Zero-overhead systems scalpel |
| `ZIL` | `zap` | General Lexicon | Acoustic nearest neighbor for 'ZIL' |
| `Zimpl` | `zap` | General Lexicon | Acoustic nearest neighbor for 'Zimpl' |
| `zsh` | `warp` | Language | Enhanced warp command deck |

---

## 3. Dictation Workflow Example

### Spoken Input:
```text
core fetch user by id slot id form count yield strand
test id bang pulse
    flare breach user not found
yield strand user id
```

### Rendered Output (Python Context):
```python
def fetch_user_by_id(id: int) -> str:
    if not id:
        raise Exception('user not found')
    return f'user {id}'
```

### Rendered Output (Rust Context):
```rust
fn fetch_user_by_id(id: i64) -> Result<String, Error> {
    if id == 0 {
        return Err(Error::msg("user not found"));
    }
    Ok(format!("user {}", id))
}
```
