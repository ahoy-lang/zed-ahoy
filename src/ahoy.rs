use std::fs;
use zed::{LanguageServerId, Worktree};
use zed_extension_api::{self as zed, serde_json, settings::LspSettings, Result};

struct AhoyExtension {
    cached_binary_path: Option<String>,
}

impl AhoyExtension {
    fn language_server_binary_path(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> Result<String> {
        let language_server = language_server_id.as_ref();

        // Check if user has configured a custom binary path in settings
        if let Some(path) = LspSettings::for_worktree(language_server, worktree)
            .ok()
            .and_then(|settings| settings.binary)
            .and_then(|binary| binary.path)
        {
            return Ok(path);
        }

        // Try to find ahoy-lsp in PATH using Zed's which() helper
        if let Some(path) = worktree.which("ahoy-lsp") {
            return Ok(path);
        }

        // Check if we have a cached path that still exists
        if let Some(path) = &self.cached_binary_path {
            if fs::metadata(path).map_or(false, |stat| stat.is_file()) {
                return Ok(path.to_string());
            }
        }

        // Try common installation locations manually
        let home = std::env::var("HOME").unwrap_or_default();
        let possible_paths = vec![
            format!("{home}/.local/bin/ahoy-lsp"),
            "/usr/local/bin/ahoy-lsp".to_string(),
            "/usr/bin/ahoy-lsp".to_string(),
        ];

        for path in possible_paths {
            if fs::metadata(&path).map_or(false, |stat| stat.is_file()) {
                self.cached_binary_path = Some(path.clone());
                return Ok(path);
            }
        }

        Err("ahoy-lsp not found. Please install it and ensure it's in your PATH, or configure the binary path in settings.".into())
    }
}

impl zed::Extension for AhoyExtension {
    fn new() -> Self {
        Self {
            cached_binary_path: None,
        }
    }

    fn language_server_command(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> Result<zed::Command> {
        let ahoy_lsp_binary_path =
            self.language_server_binary_path(language_server_id, worktree)?;

        Ok(zed::Command {
            command: ahoy_lsp_binary_path,
            args: vec![],
            env: vec![("AHOY_LSP_DEBUG".to_string(), "1".to_string())]
                .into_iter()
                .collect(),
        })
    }

    fn language_server_initialization_options(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> Result<Option<serde_json::Value>> {
        let settings = LspSettings::for_worktree(language_server_id.as_ref(), worktree)
            .ok()
            .and_then(|lsp_settings| lsp_settings.initialization_options.clone());
        Ok(settings)
    }

    fn language_server_workspace_configuration(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> Result<Option<serde_json::Value>> {
        let settings = LspSettings::for_worktree(language_server_id.as_ref(), worktree)
            .ok()
            .and_then(|lsp_settings| lsp_settings.settings.clone())
            .unwrap_or_default();
        Ok(Some(settings))
    }
}

zed::register_extension!(AhoyExtension);
