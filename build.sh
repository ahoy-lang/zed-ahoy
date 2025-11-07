#!/bin/bash
set -e

MODE="${1:-dev}"

echo "=== Building Zed Ahoy Extension (${MODE} mode) ==="
echo ""

cd "$(dirname "$0")"

# Always sync the latest grammar for dev builds
if [ "$MODE" = "dev" ]; then
    echo "1. Syncing tree-sitter-ahoy grammar to grammars/ahoy..."
    rsync -av --exclude='.git' --exclude='node_modules' --exclude='target' --exclude='build' \
      ../tree-sitter-ahoy/ grammars/ahoy/
    echo "   ✓ Grammar synced"
    echo ""
fi

# Build the extension
echo "2. Building extension WASM..."
cargo build --release --target wasm32-wasip1
cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
echo "   ✓ Extension built"
echo ""

# For dev mode, ensure symlink
if [ "$MODE" = "dev" ]; then
    echo "3. Setting up development symlink..."
    ZED_EXT_DIR="$HOME/.local/share/zed/extensions/installed/ahoy"
    if [ -L "$ZED_EXT_DIR" ]; then
        echo "   ✓ Already symlinked"
    else
        mkdir -p "$(dirname "$ZED_EXT_DIR")"
        ln -sf "$(pwd)" "$ZED_EXT_DIR"
        echo "   ✓ Symlink created"
    fi
    echo ""
    
    echo "=== Development Build Complete ==="
    echo ""
    echo "Using local grammar from grammars/ahoy/"
    echo "Restart Zed to reload: pkill -9 zed && zed"
else
    echo "=== Production Build Complete ==="
    echo ""
    echo "Will fetch grammar from GitHub when installed"
    echo "Ready to publish extension.wasm"
fi
