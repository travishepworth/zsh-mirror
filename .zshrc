# ~/.zshrc - Main configuration file (keep this minimal)
#!/usr/bin/env zsh

export ZSH_CONFIG_DIR="${HOME}/.config/zsh"
export CONFIG_DIR="${ZSH_CONFIG_DIR}"

[[ ! -d "$ZSH_CONFIG_DIR" ]] && mkdir -p "$ZSH_CONFIG_DIR"

setopt NULL_GLOB
for config_file in "$ZSH_CONFIG_DIR"/*.zsh "$ZSH_CONFIG_DIR"/zsh/*.zsh; do
  [[ -r "$config_file" ]] && source "$config_file"
done
unsetopt NULL_GLOB

[[ -r "$ZSH_CONFIG_DIR/local.zsh" ]] && source "$ZSH_CONFIG_DIR/local.zsh"
