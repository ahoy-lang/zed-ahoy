# Fix Instructions for Zed Extension

## What Was Fixed

1. **Added Rust bindings** to tree-sitter-ahoy:
   - `Cargo.toml` - Rust package manifest
   - `bindings/rust/lib.rs` - Rust interface
   - `bindings/rust/build.rs` - Build script

2. **Added C bindings** to tree-sitter-ahoy:
   - `bindings/c/tree-sitter-ahoy.h` - C header
   - `bindings/c/tree-sitter-ahoy.pc.in` - pkg-config template

3. **Fixed extension.toml** - Removed duplicate fields

## Steps to Complete

### 1. Commit and Push Grammar Files

```bash
cd /home/lee/Documents/ahoy/tree-sitter-ahoy

# Add the new binding files
git add Cargo.toml
git add bindings/c/
git add bindings/rust/

# Commit
git commit -m "Add Rust and C bindings for Zed editor support"

# Push to GitHub
git push origin master
```

### 2. Wait for GitHub to Update
Wait 10-15 seconds for GitHub to process the push.

### 3. Try Installing in Zed Again

```
1. Open Zed
2. Press Cmd+Shift+P (or Ctrl+Shift+P)
3. Type "zed: install dev extension"
4. Select the zed-ahoy folder
```

## What Zed Needs

Zed compiles tree-sitter grammars from source. It requires:

- ✅ `src/parser.c` - Generated parser (exists)
- ✅ `grammar.js` - Grammar definition (exists)
- ✅ `Cargo.toml` - Rust build config (now added)
- ✅ `bindings/rust/lib.rs` - Rust bindings (now added)
- ✅ `bindings/rust/build.rs` - Build script (now added)
- ✅ `bindings/c/tree-sitter-ahoy.h` - C header (now added)

## Verification

Test that the grammar builds:

```bash
cd /home/lee/Documents/ahoy/tree-sitter-ahoy
cargo build --release
```

Should complete successfully (it already does locally).

## If Still Failing

Check Zed's log for errors:
1. Open Zed
2. Cmd+Shift+P → "zed: open log"
3. Look for compilation errors

Common issues:
- GitHub not updated yet (wait longer)
- Wrong branch (should be `master`)
- Network issues (check internet connection)
