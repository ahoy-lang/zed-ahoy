# Ahoy LSP Debugging Guide for Zed

## Quick Checklist

Before debugging, verify these basics:

- [ ] `ahoy-lsp` is installed: `which ahoy-lsp` (should show `/usr/local/bin/ahoy-lsp`)
- [ ] Zed extension is installed: `ls -la ~/.local/share/zed/extensions/installed/ahoy`
- [ ] File has `.ahoy` extension
- [ ] Zed has been restarted after installation

## Step 1: Verify ahoy-lsp Binary Works

Test the LSP server manually:

```bash
# This should hang waiting for input (that's correct!)
ahoy-lsp

# Press Ctrl+C to exit
# If you get "command not found", install it:
cd /path/to/ahoy-lang/ahoy
./install_lsp.sh
```

## Step 2: Check Zed Extension Installation

```bash
# Check if extension is installed
ls -la ~/.local/share/zed/extensions/installed/ahoy

# Should show a symlink to your zed-ahoy directory
# If not, reinstall:
cd /path/to/zed-ahoy
./install_to_zed.sh
```

## Step 3: Check Language Recognition

1. Open a `.ahoy` file in Zed
2. Look at bottom-right corner of Zed window
3. Should show: **"Ahoy"** (the language)
4. If it shows "Plain Text", the extension isn't loaded

**Fix:**
- Make sure file extension is `.ahoy` (not `.txt`)
- Reload Zed: `Ctrl+Shift+P` → "zed: reload window"
- Check extension.toml has correct path_suffixes

## Step 4: Check LSP Server Status

### Option A: Command Palette
1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "lsp"
3. Look for "lsp: show running language servers"
4. Should show `ahoy-lsp` in the list

### Option B: Status Bar
1. Open a `.ahoy` file
2. Bottom-right corner should show:
   - Language: "Ahoy"
   - Server: "ahoy-lsp" (may appear after a few seconds)

### If LSP not showing:
- Check Zed logs (see Step 5)
- Verify `languages/ahoy/config.toml` has `language_servers = ["ahoy-lsp"]`
- Rebuild extension: `cd zed-ahoy && ./install_to_zed.sh`

## Step 5: Check Zed Logs

### View Logs in Terminal
```bash
# Watch logs in real-time
tail -f ~/.local/share/zed/logs/Zed.log

# Or check latest log
cat ~/.local/share/zed/logs/Zed.log | tail -50

# Search for ahoy-lsp errors
grep -i "ahoy" ~/.local/share/zed/logs/Zed.log
grep -i "lsp" ~/.local/share/zed/logs/Zed.log | tail -20
```

### Common Error Messages

**Error: "command not found: ahoy-lsp"**
```
Fix: Install ahoy-lsp to PATH
cd /path/to/ahoy/lsp
sudo cp ahoy-lsp /usr/local/bin/
```

**Error: "failed to start language server"**
```
Fix: Check ahoy-lsp runs manually
ahoy-lsp  # Should hang - press Ctrl+C
```

**Error: "no language server found for language ahoy"**
```
Fix: Check languages/ahoy/config.toml has:
language_servers = ["ahoy-lsp"]
```

**Error: "extension not loaded"**
```
Fix: Reinstall extension
cd zed-ahoy
./install_to_zed.sh
# Restart Zed
```

## Step 6: Test LSP Features Manually

Create a test file `test_lsp.ahoy`:

```ahoy
? Test diagnostics (should show error - missing 'do')
func broken_function
    ahoy "error!"
end

? Test valid function (no error)
func working do
    x: 42
end

? Test autocomplete
? Type "fu" then press Ctrl+Space

? Test go-to-definition
? Ctrl+Click on 'x' below
value: x
```

### Expected Results:

1. **Diagnostics**: Red underline on line 2 (missing 'do')
2. **Autocomplete**: Type "fu" + Ctrl+Space → shows "func"
3. **Go-to-definition**: Ctrl+Click on `x` on line 14 → jumps to line 9
4. **Hover**: Hover over `x` → shows "x: int, Variable x, Type: int"

### If Nothing Works:

1. **Check extension.toml language_servers config:**
   ```bash
   cat ~/.local/share/zed/extensions/installed/ahoy/extension.toml
   # Should have [language_servers.ahoy-lsp] section
   ```

2. **Check language config:**
   ```bash
   cat ~/.local/share/zed/extensions/installed/ahoy/languages/ahoy/config.toml
   # Should have: language_servers = ["ahoy-lsp"]
   ```

3. **Rebuild everything:**
   ```bash
   cd zed-ahoy
   cargo clean
   cargo build --release --target wasm32-wasip1
   cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
   ./install_to_zed.sh
   # Kill and restart Zed completely
   ```

## Step 7: Enable Verbose Logging

Add to Zed settings (`~/.config/zed/settings.json`):

```json
{
  "lsp": {
    "ahoy-lsp": {
      "initialization_options": {},
      "settings": {}
    }
  }
}
```

Then check logs again after restarting Zed.

## Step 8: Test LSP Server Directly

Create a test script to verify LSP responds:

```bash
cat > /tmp/test_lsp.sh << 'EOF'
#!/bin/bash
{
  echo -n 'Content-Length: 123\r\n\r\n'
  echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":"file:///tmp","capabilities":{}}}'
} | ahoy-lsp
EOF

chmod +x /tmp/test_lsp.sh
timeout 2 /tmp/test_lsp.sh
```

Should output JSON response with server capabilities.

## Common Issues and Solutions

### Issue: "Language shows as Ahoy but no LSP"

**Cause:** Language recognized but LSP not connected

**Solution:**
1. Check `languages/ahoy/config.toml` has `language_servers = ["ahoy-lsp"]`
2. Rebuild extension
3. Restart Zed

### Issue: "Syntax highlighting works but no autocomplete"

**Cause:** Tree-sitter works but LSP doesn't

**Solution:**
1. Verify ahoy-lsp in PATH: `which ahoy-lsp`
2. Check Zed logs for LSP startup errors
3. Test ahoy-lsp manually: `ahoy-lsp`

### Issue: "Extension not loading at all"

**Cause:** Build or installation problem

**Solution:**
```bash
cd zed-ahoy
rm -rf target
cargo clean
rustup target add wasm32-wasip1
cargo build --release --target wasm32-wasip1
cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
rm -rf ~/.local/share/zed/extensions/installed/ahoy
./install_to_zed.sh
# Completely quit and restart Zed (not just reload window)
```

### Issue: "LSP crashes on file open"

**Cause:** Parser error or malformed Ahoy code

**Solution:**
1. Check Zed logs for panic/crash messages
2. Test with simple valid file:
   ```ahoy
   func test do
       ahoy "hello"
   end
   ```
3. If parser crashes, report with the problematic code

## Verification Script

Run this to verify everything:

```bash
#!/bin/bash
echo "=== Ahoy LSP Verification ==="
echo ""
echo "1. Checking ahoy-lsp binary..."
which ahoy-lsp && echo "   ✓ Found" || echo "   ✗ Not found"
echo ""
echo "2. Checking Zed extension..."
[ -e ~/.local/share/zed/extensions/installed/ahoy ] && echo "   ✓ Installed" || echo "   ✗ Not installed"
echo ""
echo "3. Checking extension files..."
[ -f ~/.local/share/zed/extensions/installed/ahoy/extension.wasm ] && echo "   ✓ WASM file exists" || echo "   ✗ WASM missing"
[ -f ~/.local/share/zed/extensions/installed/ahoy/extension.toml ] && echo "   ✓ Config exists" || echo "   ✗ Config missing"
echo ""
echo "4. Checking language config..."
if [ -f ~/.local/share/zed/extensions/installed/ahoy/languages/ahoy/config.toml ]; then
    grep -q "language_servers" ~/.local/share/zed/extensions/installed/ahoy/languages/ahoy/config.toml && echo "   ✓ LSP configured" || echo "   ✗ LSP not configured"
else
    echo "   ✗ Language config missing"
fi
echo ""
echo "If all checks pass, restart Zed and open a .ahoy file"
```

## Still Not Working?

1. **Check Zed version:**
   ```bash
   zed --version
   ```
   Make sure you're on a recent version (0.140.0+)

2. **Try with a different extension:**
   Test if other LSP extensions work in Zed to rule out general Zed issues

3. **Check permissions:**
   ```bash
   ls -la ~/.local/share/zed/extensions/installed/ahoy
   # Make sure you have read/execute permissions
   ```

4. **Nuclear option - Clean reinstall:**
   ```bash
   # Remove everything
   rm -rf ~/.local/share/zed/extensions/installed/ahoy
   rm -rf zed-ahoy/target
   
   # Reinstall LSP
   cd ahoy/lsp
   go build -o ahoy-lsp .
   sudo cp ahoy-lsp /usr/local/bin/
   
   # Reinstall extension
   cd ../../zed-ahoy
   cargo build --release --target wasm32-wasip1
   cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
   ./install_to_zed.sh
   
   # Completely quit Zed (killall zed)
   # Start Zed fresh
   ```

## Success Indicators

When everything is working, you should see:

- ✓ Bottom-right shows "Ahoy" and "ahoy-lsp"
- ✓ Red underlines on syntax errors
- ✓ Ctrl+Space shows autocomplete
- ✓ Ctrl+Click jumps to definitions
- ✓ Hover shows type information
- ✓ Ctrl+Shift+O shows document outline

Good luck! 🚢