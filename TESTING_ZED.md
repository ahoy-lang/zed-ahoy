# Testing Ahoy LSP in Zed

This guide provides step-by-step instructions for testing the Ahoy Language Server in Zed.

## Prerequisites

1. **Install ahoy-lsp:**
   ```bash
   cd ahoy/lsp
   go build -o ahoy-lsp .
   mkdir -p ~/.local/bin
   cp ahoy-lsp ~/.local/bin/
   ```

2. **Verify installation:**
   ```bash
   which ahoy-lsp
   # Should output: /home/username/.local/bin/ahoy-lsp
   
   # Test it runs
   ahoy-lsp
   # Should wait for input (press Ctrl+C to exit)
   ```

3. **Install Zed extension:**
   ```bash
   cd zed-ahoy
   cargo build --target wasm32-wasip1 --release
   cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
   ./install_to_zed.sh
   ```

4. **Restart Zed completely** (close all windows and reopen)

## Test File

Create `test_zed.ahoy`:

```ahoy
? Ahoy Language - Zed LSP Test File

? ==================== FUNCTION DEFINITIONS ====================
add :: |a:int, b:int| int:
    return a plus b

multiply :: |x:int, y:int| int:
    return x times y

greet :: |name:string| string:
    return "Hello, " plus name

? ==================== VARIABLES ====================
num1: 10
num2: 20
sum: add|num1, num2|
product: multiply|num1, num2|
message: greet|"World"|

? ==================== CONDITIONALS ====================
if sum greater_than product then
    print|"Sum is greater"|
anif product greater_than sum then
    print|"Product is greater"|
else
    print|"They are equal"|

? ==================== LOOPS ====================
loop:1 to 10 do
    print|"Iteration"|

? ==================== ARRAYS ====================
numbers: [1, 2, 3, 4, 5]
loop num in numbers do
    print|"Number: %v", num|

? ==================== OBJECTS ====================
point: <x: 100, y: 200>
color: <r: 255, g: 128, b: 64>

? ==================== TEST INSTRUCTIONS ====================
? 1. Hover over "add" on line 6 - should show function signature
? 2. Ctrl+Click on "add" on line 15 - should jump to line 6
? 3. Press Ctrl+Shift+O (Cmd+Shift+O on Mac) - should show document outline
? 4. Type "lo" at the end of file + trigger completion - should suggest "loop"
? 5. Delete ":" after "int:" on line 6 - should show red squiggle error
```

## Testing Checklist

Open `test_zed.ahoy` in Zed and verify each feature:

### 1. Extension Loading ✓

- [ ] File opens with syntax highlighting
- [ ] Bottom-right shows "Ahoy" as the language
- [ ] No error notifications on startup

**If not working:**
- Check extension installed: `ls ~/.local/share/zed/extensions/installed/ahoy`
- Reload window: Cmd/Ctrl+Shift+P → "zed: reload window"

### 2. LSP Server Starting ✓

- [ ] Status bar shows LSP indicator
- [ ] No "Language server failed" error

**Check logs:**
```bash
tail -f ~/.local/share/zed/logs/Zed.log | grep -i ahoy
```

Should see:
- "[ahoy-lsp] Starting Ahoy Language Server"
- "[ahoy-lsp] Server created successfully"

**If not starting:**
- Verify binary: `which ahoy-lsp`
- Check PATH: `echo $PATH | grep ".local/bin"`
- Set explicit path in settings (see ZED_CONFIGURATION.md)

### 3. Diagnostics (Error Detection) ✓

**Test 1: Syntax Error**
- [ ] Delete `:` after `int:` on line 6
- [ ] Red squiggle or error indicator should appear
- [ ] Hover over error shows message
- [ ] Undo (Cmd/Ctrl+Z)
- [ ] Error disappears

**Test 2: Invalid Keyword**
- [ ] Add line: `function wrong()`
- [ ] Should show error (Ahoy doesn't use `function`)
- [ ] Delete the line
- [ ] Error clears

**If not working:**
- LSP may not be connected
- Check logs for connection errors
- Try reload window

### 4. Hover Information ✓

- [ ] Hover over `add` on line 6
  - Should show: Function signature or type info
  
- [ ] Hover over `if` keyword on line 23
  - Should show: Documentation about conditionals
  
- [ ] Hover over `loop` keyword on line 30
  - Should show: Documentation about loops

- [ ] Hover over variable `sum` on line 15
  - Should show: Variable type or value info

**If not working:**
- Make sure there are no syntax errors (they prevent AST creation)
- Check cursor is on the correct token
- Try reloading window

### 5. Go to Definition ✓

**Test 1: Function Definition**
- [ ] Place cursor on `add` at line 15 (in `sum: add|num1, num2|`)
- [ ] Press F12 or Cmd/Ctrl+Click
- [ ] Should jump to line 6 (function definition)
- [ ] Press Cmd/Ctrl+- to go back

**Test 2: Another Function**
- [ ] Place cursor on `multiply` at line 16
- [ ] Press F12
- [ ] Should jump to line 9
- [ ] Go back

**Test 3: Variable**
- [ ] Place cursor on `num1` at line 15
- [ ] Press F12
- [ ] Should jump to line 13 (variable definition)

**If not working:**
- Ensure no syntax errors in file
- Symbol must be in scope
- Try reloading window

### 6. Autocompletion ✓

- [ ] Go to end of file (after line 40)
- [ ] Type: `lo`
- [ ] Trigger completion (Cmd/Ctrl+Space or automatic)
- [ ] Should see `loop` in suggestions
- [ ] Escape to cancel

- [ ] Type: `if`
- [ ] Trigger completion
- [ ] Should see `if`, `then` suggestions
- [ ] Escape to cancel

- [ ] Type: `re`
- [ ] Trigger completion
- [ ] Should see `return` suggestion
- [ ] Escape to cancel

**If not working:**
- Completions may require typing more characters
- Check if completion is enabled in settings
- Try Cmd/Ctrl+Space manually

### 7. Document Symbols ✓

- [ ] Press Cmd+Shift+O (Mac) or Ctrl+Shift+O (Linux)
- [ ] Should see outline with:
  - `add` (function)
  - `multiply` (function)
  - `greet` (function)
  - `num1`, `num2`, `sum`, `product`, etc. (variables)

- [ ] Type "add" to filter
- [ ] Press Enter to jump to symbol
- [ ] Should navigate to function definition

**If not working:**
- Ensure file has no syntax errors
- Try reloading window
- Check if symbols are being parsed (hover should work)

### 8. Code Actions ✓

- [ ] Place cursor on a line with an error
- [ ] Press Cmd/Ctrl+. (period)
- [ ] Should see quick fix suggestions
- [ ] Try applying one

**Note:** Code actions require errors to suggest fixes.

**If not working:**
- Not all errors have code actions
- Feature may be limited in current version

### 9. Error Recovery ✓

**Test server doesn't crash:**
- [ ] Add lots of invalid syntax:
  ```
  function bad() { wrong syntax !!! ### garbage
  ```
- [ ] Server should NOT crash
- [ ] Errors should appear
- [ ] Fix the syntax
- [ ] Errors should clear
- [ ] All features should still work

**If server crashes:**
- Check logs for panic messages
- Report as a bug with reproduction steps

### 10. Performance ✓

- [ ] File opens quickly (< 1 second)
- [ ] Typing is responsive (no lag)
- [ ] Hover appears quickly (< 100ms)
- [ ] Go-to-def is instant
- [ ] Completions appear quickly

**If slow:**
- File may be very large (>1000 lines)
- Try smaller file for testing
- Check CPU usage

## Viewing Logs

### Real-time Logs
```bash
tail -f ~/.local/share/zed/logs/Zed.log | grep -i ahoy
```

### All Zed Logs
```bash
cat ~/.local/share/zed/logs/Zed.log | grep -i ahoy | tail -50
```

### What to Look For

**Good signs:**
```
[ahoy-lsp] Starting Ahoy Language Server
[ahoy-lsp] Server created successfully
[ahoy-lsp] Handler started, waiting for requests
```

**Bad signs:**
```
ahoy-lsp not found
Failed to start language server
LSP connection error
```

## Common Issues

### "LSP not starting"

1. **Check binary exists:**
   ```bash
   which ahoy-lsp
   ls -l ~/.local/bin/ahoy-lsp
   ```

2. **Check PATH:**
   ```bash
   echo $PATH | grep ".local/bin"
   ```

3. **Set explicit path in Zed settings:**
   
   Edit `~/.config/zed/settings.json`:
   ```json
   {
     "lsp": {
       "ahoy-lsp": {
         "binary": {
           "path": "/home/username/.local/bin/ahoy-lsp"
         }
       }
     }
   }
   ```

4. **Reload Zed:**
   - Cmd/Ctrl+Shift+P → "zed: reload window"

### "Features not working"

1. **Wrong syntax:**
   - Ahoy uses `::` for functions, not `function`
   - See test file above for correct syntax

2. **Syntax errors:**
   - Fix all errors first
   - LSP needs valid syntax to build AST

3. **Not recognized as Ahoy:**
   - Check bottom-right shows "Ahoy"
   - File must have `.ahoy` extension

### "Extension not loading"

1. **Reinstall:**
   ```bash
   cd zed-ahoy
   ./install_to_zed.sh
   ```

2. **Check installation:**
   ```bash
   ls ~/.local/share/zed/extensions/installed/ahoy/
   # Should show: extension.toml, extension.wasm, etc.
   ```

3. **Rebuild:**
   ```bash
   cargo clean
   cargo build --target wasm32-wasip1 --release
   cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
   ```

## Success Criteria

✅ All 10 tests pass
✅ No errors in logs
✅ Features work smoothly
✅ Server doesn't crash on invalid input
✅ Performance is good

If all tests pass: **Zed LSP integration is working!** 🎉

## Next Steps

After successful testing:

1. Write real Ahoy code with LSP support
2. Test with larger projects
3. Configure settings for your workflow (see ZED_CONFIGURATION.md)
4. Report any issues found
5. Contribute improvements

## Getting Help

If tests fail:

1. Read this guide completely
2. Check ZED_CONFIGURATION.md
3. Read ../EDITOR_LSP_TESTING.md
4. View logs for error messages
5. Try minimal reproduction
6. Open issue with:
   - Test that failed
   - Log output
   - Zed version
   - OS version
   - Steps to reproduce

## Resources

- Configuration: ZED_CONFIGURATION.md
- Zed Docs: https://zed.dev/docs
- LSP Testing: ../EDITOR_LSP_TESTING.md
- Troubleshooting: ../LSP_COMPLETE_GUIDE.md

---

Happy testing! 🚢