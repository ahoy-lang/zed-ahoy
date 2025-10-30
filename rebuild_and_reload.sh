#!/bin/bash

# Rebuild and reload the Zed Ahoy extension

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Rebuilding Zed Ahoy Extension ==="
echo ""

echo "1. Cleaning previous build artifacts..."
cargo clean
rm -f extension.wasm
echo "   ✓ Clean complete"
echo ""

echo "2. Building extension WASM..."
cargo build --release --target wasm32-wasip1
echo "   ✓ WASM built"
echo ""

echo "3. Copying WASM to extension root..."
cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
echo "   ✓ WASM copied"
echo ""

echo "4. Verifying extension structure..."
if [ ! -f "extension.toml" ]; then
    echo "   ✗ ERROR: extension.toml not found!"
    exit 1
fi

if [ ! -f "extension.wasm" ]; then
    echo "   ✗ ERROR: extension.wasm not found!"
    exit 1
fi

if [ ! -d "languages/ahoy" ]; then
    echo "   ✗ ERROR: languages/ahoy directory not found!"
    exit 1
fi

if [ ! -f "grammars/ahoy.wasm" ]; then
    echo "   ✗ ERROR: grammars/ahoy.wasm not found!"
    exit 1
fi

echo "   ✓ Extension structure valid"
echo ""

echo "5. Checking if extension is installed in Zed..."
ZED_EXT_DIR="${HOME}/.local/share/zed/extensions/installed/ahoy"

if [ -L "$ZED_EXT_DIR" ]; then
    echo "   ✓ Extension is symlinked (development mode)"
    LINK_TARGET=$(readlink -f "$ZED_EXT_DIR")
    if [ "$LINK_TARGET" != "$SCRIPT_DIR" ]; then
        echo "   ⚠ Warning: Symlink points to $LINK_TARGET instead of $SCRIPT_DIR"
        echo "   Updating symlink..."
        rm "$ZED_EXT_DIR"
        ln -s "$SCRIPT_DIR" "$ZED_EXT_DIR"
        echo "   ✓ Symlink updated"
    fi
elif [ -d "$ZED_EXT_DIR" ]; then
    echo "   ✓ Extension directory exists (installed mode)"
    echo "   Copying new WASM..."
    cp extension.wasm "$ZED_EXT_DIR/"
    echo "   ✓ WASM copied"
else
    echo "   Installing extension to Zed..."
    mkdir -p "$(dirname "$ZED_EXT_DIR")"
    ln -s "$SCRIPT_DIR" "$ZED_EXT_DIR"
    echo "   ✓ Extension installed"
fi
echo ""

echo "6. Checking LSP binary..."
LSP_PATH="${HOME}/.local/bin/ahoy-lsp"
if [ ! -f "$LSP_PATH" ]; then
    echo "   ✗ WARNING: ahoy-lsp not found at $LSP_PATH"
    echo "   Run: cd ../ahoy-lsp && ./build.sh"
else
    echo "   ✓ LSP binary found at $LSP_PATH"
fi
echo ""

echo "=== Build Complete ==="
echo ""
echo "Next steps:"
echo "1. Restart Zed completely (Ctrl+Q or Cmd+Q, then reopen)"
echo "2. Open a .ahoy file"
echo "3. Check Zed logs for LSP startup:"
echo "   tail -f ~/.local/share/zed/logs/Zed.log | grep -i ahoy"
echo "4. In Zed, open Command Palette and search for 'Ahoy'"
echo ""
echo "To verify the extension is loaded:"
echo "   ls -la ~/.local/share/zed/extensions/installed/ | grep ahoy"
echo ""
