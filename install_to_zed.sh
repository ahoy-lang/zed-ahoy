#!/bin/bash

# Ahoy Zed Extension Installation Script

set -e

echo "========================================"
echo "  Ahoy Zed Extension Installer"
echo "========================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZED_EXTENSIONS_DIR="$HOME/.local/share/zed/extensions/installed"

# Check if Zed is installed
if ! command -v zed &> /dev/null; then
    echo "⚠️  Warning: 'zed' command not found in PATH"
    echo "   Make sure Zed is installed and in your PATH"
    echo ""
fi

echo "Building extension..."

# Add wasm32-wasip2 target if not installed
if ! rustup target list | grep -q "wasm32-wasip2 (installed)"; then
    echo "Installing wasm32-wasip2 target..."
    rustup target add wasm32-wasip2
fi

# Build the extension
cd "$SCRIPT_DIR"
cargo build --release --target wasm32-wasip2

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✓ Build successful"
echo ""

# Copy wasm to extension root
cp target/wasm32-wasip2/release/ahoy.wasm extension.wasm

echo "Installing extension to Zed..."

# Create extensions directory if it doesn't exist
mkdir -p "$ZED_EXTENSIONS_DIR"

# Remove old installation if exists
if [ -L "$ZED_EXTENSIONS_DIR/ahoy" ] || [ -d "$ZED_EXTENSIONS_DIR/ahoy" ]; then
    echo "Removing old installation..."
    rm -rf "$ZED_EXTENSIONS_DIR/ahoy"
fi

# Create symlink to extension directory
ln -sf "$SCRIPT_DIR" "$ZED_EXTENSIONS_DIR/ahoy"

echo "✓ Extension installed to: $ZED_EXTENSIONS_DIR/ahoy"
echo ""

# Check if ahoy-lsp is in PATH
if command -v ahoy-lsp &> /dev/null; then
    echo "✓ ahoy-lsp found at: $(which ahoy-lsp)"
else
    echo "⚠️  Warning: ahoy-lsp not found in PATH"
    echo ""
    echo "The extension needs ahoy-lsp to provide LSP features."
    echo "To install it:"
    echo ""
    echo "  cd $(dirname "$SCRIPT_DIR")/ahoy-lsp"
    echo "  make install"
    echo ""
fi

echo "========================================"
echo "  Installation Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Restart Zed (if running)"
echo "2. Open any .ahoy file"
echo "3. Check bottom-right status bar"
echo "   - Should show 'Ahoy' as the language"
echo "   - Should show 'ahoy-lsp' if LSP is working"
echo ""
echo "To test:"
echo "  zed test.ahoy"
echo ""
echo "Troubleshooting:"
echo "  - Zed logs: ~/.local/share/zed/logs/"
echo "  - Extension logs: Check Zed menu → View → Debug → Language Server Logs"
echo "  - Reload window: Cmd+Shift+P (Mac) or Ctrl+Shift+P → 'zed: reload window'"
echo ""
echo "Happy coding! 🚢"
