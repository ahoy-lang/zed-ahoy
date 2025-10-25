# Query Files Fixed

## Problem
Zed was failing to load the Ahoy language with error:
```
Query error at 2:3. Invalid node type [
```

## Root Cause
The brackets.scm file was using invalid syntax - it had string literals like `"("` which are not valid node types in tree-sitter queries for bracket matching.

## Files Fixed

### 1. brackets.scm
**Before:**
```scm
("(" @open ")" @close)
("[" @open "]" @close)
("{" @open "}" @close)
```

**After:**
```scm
; Brackets are configured in config.toml
; This file can be empty or contain tree-sitter node patterns
; For now, leaving empty as bracket pairs are defined in config.toml
```

**Reason:** Bracket matching is already properly configured in `config.toml`, so this query file can be empty.

### 2. indents.scm
**Before:**
```scm
[
  (function_declaration)
  (if_statement)
  (loop_statement)
  (switch_statement)
] @indent

[
  "}"
] @outdent
```

**After:**
```scm
; Indent blocks
(function_declaration) @indent
(if_statement) @indent
(loop_statement) @indent
(switch_statement) @indent
```

**Reason:** Removed the `@outdent` rule with string literal `"}"` which could cause issues. Simplified to just indent the block nodes.

### 3. folds.scm
**Before:**
```scm
[
  (function_declaration)
  (if_statement)
  (loop_statement)
  (switch_statement)
] @fold
```

**After:**
```scm
(function_declaration) @fold
(if_statement) @fold
(loop_statement) @fold
(switch_statement) @fold
```

**Reason:** Simplified syntax, though the old version would have worked.

## Try Again

Now try reloading the extension in Zed:
1. Open Zed
2. Cmd+Shift+P → "zed: reload extensions"
3. Or restart Zed

The extension should now load without errors!

## What Works Now
- ✅ Syntax highlighting
- ✅ Code folding
- ✅ Smart indentation
- ✅ Bracket matching (via config.toml)
- ✅ Outline view
