# Ahoy Extension for Zed

This extension adds support for the Ahoy programming language to the [Zed editor](https://zed.dev).

## Features

- **Syntax Highlighting**: Full syntax highlighting for Ahoy code using Tree-sitter
- **Language Server (LSP)**: Full IDE features powered by ahoy-lsp
  - Real-time diagnostics (syntax error checking)
  - Autocomplete (keywords, operators, types)
  - Go-to-definition (Ctrl+Click or F12)
  - Hover information (type info and documentation)
  - Document outline (Ctrl+Shift+O)
  - Code actions / Quick fixes (Ctrl+.)
- **Code Folding**: Fold functions, loops, conditionals, and other blocks
- **Bracket Matching**: Automatic bracket, brace, and parenthesis matching
- **Indentation**: Smart indentation support

## Quick Installation

```bash
cd /path/to/zed-ahoy
./install_to_zed.sh
```

This will:
1. Build the extension for wasm32-wasip1
2. Install it to `~/.local/share/zed/extensions/installed/ahoy`
3. Check if ahoy-lsp is installed

Then restart Zed and open any `.ahoy` file!

## Prerequisites

### 1. Install ahoy-lsp (Language Server)

The LSP provides all the smart IDE features. Install it first:

```bash
cd ../ahoy
./install_lsp.sh
```

This installs `ahoy-lsp` to `/usr/local/bin/` or `~/.local/bin/`.

Verify installation:
```bash
which ahoy-lsp
# Should output: /usr/local/bin/ahoy-lsp
```

### 2. Install Rust toolchain

```bash
# Install Rust if not already installed
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add wasm target
rustup target add wasm32-wasip1
```

## Manual Installation

If the script doesn't work, follow these steps:

### Build the Extension

```bash
cd zed-ahoy
cargo build --release --target wasm32-wasip1
cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
```

### Install to Zed

```bash
mkdir -p ~/.local/share/zed/extensions/installed
ln -sf $(pwd) ~/.local/share/zed/extensions/installed/ahoy
```

### Restart Zed

Completely quit and restart Zed (not just reload window).

## Verifying Installation

Open any `.ahoy` file in Zed and check:

1. **Bottom-right status bar** should show:
   - Language: **"Ahoy"**
   - Server: **"ahoy-lsp"** (after a few seconds)

2. **Test LSP features:**
   - Create a syntax error → should see red underline
   - Type `fu` + Ctrl+Space → should show autocomplete
   - Ctrl+Click on a variable → should jump to definition
   - Hover over a symbol → should show type info

## Testing

Use the included test files:

```bash
zed simple_test.ahoy
```

This file contains examples of:
- Valid and invalid syntax (for diagnostics)
- Variables and functions (for go-to-definition)
- Comments explaining how to test each feature

## Troubleshooting

### No LSP / No autocomplete

1. **Check ahoy-lsp is installed:**
   ```bash
   which ahoy-lsp
   ```
   If not found, install it from `../ahoy/lsp/`

2. **Check Zed logs:**
   ```bash
   tail -f ~/.local/share/zed/logs/Zed.log
   ```
   Look for errors related to "ahoy" or "lsp"

3. **Verify extension is installed:**
   ```bash
   ls -la ~/.local/share/zed/extensions/installed/ahoy
   ```

4. **Rebuild and reinstall:**
   ```bash
   cd zed-ahoy
   ./install_to_zed.sh
   # Restart Zed
   ```

See `LSP_DEBUG.md` for comprehensive troubleshooting guide.

### Syntax highlighting works but no LSP

This means tree-sitter is working but the language server isn't connected.

1. Check that `languages/ahoy/config.toml` contains:
   ```toml
   language_servers = ["ahoy-lsp"]
   ```

2. Rebuild the extension:
   ```bash
   ./install_to_zed.sh
   ```

3. Restart Zed completely

### Extension not loading

1. Make sure you have the wasm32-wasip1 target:
   ```bash
   rustup target add wasm32-wasip1
   ```

2. Rebuild:
   ```bash
   cargo clean
   cargo build --release --target wasm32-wasip1
   cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
   ```

3. Check the symlink exists:
   ```bash
   ls -la ~/.local/share/zed/extensions/installed/ahoy
   ```

## File Extension

The extension recognizes files with the `.ahoy` extension.

## Development

See `LSP_DEBUG.md` for detailed debugging information.

### Building

```bash
cargo build --release --target wasm32-wasip1
cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
```

### Testing Changes

After making changes:
```bash
./install_to_zed.sh
# Ctrl+Shift+P → "zed: reload window"
```

## Documentation

- `LSP_DEBUG.md` - Comprehensive LSP troubleshooting guide
- `simple_test.ahoy` - Test file for LSP features
- `../ahoy/LSP_QUICKSTART.md` - Quick start guide for LSP
- `../ahoy/LSP_SETUP.md` - Full LSP setup guide

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT
