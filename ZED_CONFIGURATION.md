# Zed Configuration Guide for Ahoy

This guide explains how to configure the Ahoy language extension in Zed.

## Basic Setup

After installing the extension, Zed should automatically detect `.ahoy` files and start the language server.

## Configuring the LSP Binary Path

If `ahoy-lsp` is not in your PATH, you can configure the binary path in your Zed settings.

### Option 1: Global Settings

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

### Option 2: Project-Specific Settings

Create `.zed/settings.json` in your project root:

```json
{
  "lsp": {
    "ahoy-lsp": {
      "binary": {
        "path": "./ahoy/lsp/ahoy-lsp"
      }
    }
  }
}
```

## LSP Settings

You can pass initialization options and settings to the language server:

```json
{
  "lsp": {
    "ahoy-lsp": {
      "binary": {
        "path": "/home/username/.local/bin/ahoy-lsp"
      },
      "initialization_options": {
        "debug": true
      },
      "settings": {
        "ahoy": {
          "linting": true,
          "diagnostics": true
        }
      }
    }
  }
}
```

## Language-Specific Settings

Configure editor behavior for Ahoy files:

```json
{
  "languages": {
    "Ahoy": {
      "tab_size": 4,
      "hard_tabs": false,
      "soft_wrap": "none",
      "format_on_save": "off",
      "show_inline_completions": true,
      "show_whitespaces": "selection"
    }
  }
}
```

## File Associations

If Zed doesn't automatically recognize `.ahoy` files, add this:

```json
{
  "file_types": {
    "Ahoy": ["ahoy"]
  }
}
```

## Troubleshooting

### LSP Not Starting

1. **Check if binary is found:**
   - Open Zed logs: `tail -f ~/.local/share/zed/logs/Zed.log`
   - Look for "ahoy-lsp" or errors

2. **Verify binary path:**
   ```bash
   which ahoy-lsp
   # Should output: /home/username/.local/bin/ahoy-lsp
   ```

3. **Set explicit path in settings** (see Option 1 above)

4. **Reload Zed:**
   - Command Palette (Ctrl+Shift+P or Cmd+Shift+P)
   - Type: "zed: reload window"

### Extension Not Loading

1. **Check extension is installed:**
   ```bash
   ls ~/.local/share/zed/extensions/installed/ahoy
   ```

2. **Reinstall extension:**
   ```bash
   cd zed-ahoy
   ./install_to_zed.sh
   ```

3. **Check for build errors:**
   ```bash
   cargo build --target wasm32-wasip1 --release
   ```

### Features Not Working

1. **Check file is recognized as Ahoy:**
   - Bottom-right corner should show "Ahoy"
   - If not, manually select language

2. **Check LSP status:**
   - Look for LSP indicator in status bar
   - View → Debug → Language Server Logs

3. **Verify correct syntax:**
   - Ahoy uses `::` for functions, not `function` keyword
   - See SYNTAX.md for reference

## Complete Example Configuration

Here's a complete Zed configuration for Ahoy development:

`~/.config/zed/settings.json`:

```json
{
  "lsp": {
    "ahoy-lsp": {
      "binary": {
        "path": "/home/username/.local/bin/ahoy-lsp"
      },
      "initialization_options": {
        "debug": false
      }
    }
  },
  "languages": {
    "Ahoy": {
      "tab_size": 4,
      "hard_tabs": false,
      "soft_wrap": "preferred_line_length",
      "preferred_line_length": 100,
      "format_on_save": "off",
      "show_inline_completions": true,
      "show_whitespaces": "selection",
      "enable_language_server": true
    }
  },
  "file_types": {
    "Ahoy": ["ahoy"]
  }
}
```

## Environment Variables

The Ahoy LSP extension sets these environment variables:

- `AHOY_LSP_DEBUG=1` - Enables debug logging

To add more environment variables, you'll need to modify the extension source.

## Binary Resolution Order

The extension looks for `ahoy-lsp` in this order:

1. Path configured in Zed settings (`lsp.ahoy-lsp.binary.path`)
2. System PATH (using Zed's `worktree.which()`)
3. Cached path from previous lookup
4. Common locations:
   - `~/.local/bin/ahoy-lsp`
   - `/usr/local/bin/ahoy-lsp`
   - `/usr/bin/ahoy-lsp`

## Performance Settings

For better performance with large files:

```json
{
  "languages": {
    "Ahoy": {
      "show_inline_completions": false,
      "enable_language_server": true
    }
  }
}
```

## Debug Mode

To see detailed LSP communication:

1. Enable debug logging:
   ```json
   {
     "lsp": {
       "ahoy-lsp": {
         "initialization_options": {
           "debug": true
         }
       }
     }
   }
   ```

2. View logs:
   ```bash
   tail -f ~/.local/share/zed/logs/Zed.log | grep -i ahoy
   ```

3. Or in Zed: View → Debug → Language Server Logs

## Keybindings

Add custom keybindings for Ahoy in `~/.config/zed/keymap.json`:

```json
[
  {
    "context": "Editor && language == Ahoy",
    "bindings": {
      "ctrl-shift-r": "editor::Rename",
      "ctrl-shift-f": "editor::Format",
      "f12": "editor::GoToDefinition",
      "shift-f12": "editor::GoToReferences"
    }
  }
]
```

## Known Limitations

- Cross-file symbol resolution not yet supported
- Semantic tokens currently disabled
- Column positions may be approximate for some AST nodes
- Large files (>1000 lines) may be slower

## Updating

After updating the LSP server or extension:

1. **Update server binary:**
   ```bash
   cd ahoy/lsp
   go build -o ahoy-lsp .
   cp ahoy-lsp ~/.local/bin/
   ```

2. **Update extension:**
   ```bash
   cd zed-ahoy
   cargo build --target wasm32-wasip1 --release
   cp target/wasm32-wasip1/release/ahoy.wasm extension.wasm
   ./install_to_zed.sh
   ```

3. **Reload Zed:**
   - Command Palette → "zed: reload window"

## Getting Help

If you encounter issues:

1. Check this configuration guide
2. Read TROUBLESHOOTING.md
3. View Zed logs: `~/.local/share/zed/logs/Zed.log`
4. Check extension logs in Zed: View → Debug
5. Test binary directly: `ahoy-lsp` (Ctrl+C to exit)
6. Open an issue with logs and configuration

## Example Project Setup

For a multi-developer project, commit `.zed/settings.json`:

```json
{
  "lsp": {
    "ahoy-lsp": {
      "binary": {
        "path": "ahoy-lsp"
      }
    }
  },
  "languages": {
    "Ahoy": {
      "tab_size": 4,
      "hard_tabs": false,
      "format_on_save": "off"
    }
  }
}
```

And document in your README:
```markdown
# Setup

1. Install ahoy-lsp:
   ```bash
   cd ahoy/lsp
   go build -o ahoy-lsp .
   cp ahoy-lsp ~/.local/bin/
   ```

2. Install Zed extension:
   ```bash
   cd zed-ahoy
   ./install_to_zed.sh
   ```

3. Open project in Zed
```

## Resources

- Zed Documentation: https://zed.dev/docs
- Ahoy LSP Documentation: ../EDITOR_LSP_TESTING.md
- Extension Source: src/ahoy.rs
- Report Issues: GitHub Issues

---

Last Updated: October 2024
Extension Version: 0.2.0