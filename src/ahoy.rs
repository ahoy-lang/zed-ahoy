use std::fs;
use zed_extension_api::{self as zed, LanguageServerId, Result, Worktree};

struct AhoyExtension {
    cached_binary_path: Option<String>,
}

impl zed::Extension for AhoyExtension {
    fn new() -> Self {
        Self {
            cached_binary_path: None,
        }
    }

    fn language_server_command(
        &mut self,
        _language_server_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> Result<zed::Command> {
        // Try to find ahoy-lsp binary if not cached
        if self.cached_binary_path.is_none() {
            self.cached_binary_path = self.find_ahoy_lsp_binary(worktree);
        }

        let command = self
            .cached_binary_path
            .as_ref()
            .map(|s| s.as_str())
            .unwrap_or("ahoy-lsp");

        Ok(zed::Command {
            command: command.to_string(),
            args: vec![],
            env: vec![("AHOY_LSP_DEBUG".to_string(), "1".to_string())]
                .into_iter()
                .collect(),
        })
    }

    fn language_server_initialization_options(
        &mut self,
        _language_server_id: &LanguageServerId,
        _worktree: &Worktree,
    ) -> Result<Option<zed::serde_json::Value>> {
        Ok(Some(zed::serde_json::json!({
            "debug": true,
        })))
    }
}

impl AhoyExtension {
    fn find_ahoy_lsp_binary(&self, worktree: &Worktree) -> Option<String> {
        // List of possible locations for ahoy-lsp
        let possible_paths = vec![
            // User's local bin
            format!(
                "{}/.local/bin/ahoy-lsp",
                std::env::var("HOME").unwrap_or_default()
            ),
            // System-wide installation
            "/usr/local/bin/ahoy-lsp".to_string(),
            "/usr/bin/ahoy-lsp".to_string(),
            // Relative to worktree (for development)
            format!("{}/ahoy/lsp/ahoy-lsp", worktree.root_path()),
            format!("{}/lsp/ahoy-lsp", worktree.root_path()),
        ];

        // Check each path
        for path in &possible_paths {
            if fs::metadata(path).is_ok() {
                return Some(path.clone());
            }
        }

        // Fall back to PATH lookup (just use the command name)
        None
    }
}

zed::register_extension!(AhoyExtension);
