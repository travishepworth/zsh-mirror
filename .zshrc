# ~/.zshrc - Main configuration file (keep this minimal)
#!/usr/bin/env zsh

# Set the config directory
export ZSH_CONFIG_DIR="${HOME}/.config/zsh"
export CONFIG_DIR="${ZSH_CONFIG_DIR}"

# Create config directory if it doesn't exist
[[ ! -d "$ZSH_CONFIG_DIR" ]] && mkdir -p "$ZSH_CONFIG_DIR"

# Source all configuration modules
# Handle case where no .zsh files exist
setopt NULL_GLOB  # Don't error if glob matches nothing
for config_file in "$ZSH_CONFIG_DIR"/*.zsh "$ZSH_CONFIG_DIR"/zsh/*.zsh; do
  [[ -r "$config_file" ]] && source "$config_file"
done
unsetopt NULL_GLOB  # Reset to default behavior

# Source local/private configurations (not version controlled)
[[ -r "$ZSH_CONFIG_DIR/local.zsh" ]] && source "$ZSH_CONFIG_DIR/local.zsh"
