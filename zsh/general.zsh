# ─────────────────────────────────────────────────────────────
# PATH & Scripts
# ─────────────────────────────────────────────────────────────

export PATH="$CONFIG_DIR/zsh/scripts:$PATH"
function ls() {
  $CONFIG_DIR/zsh/scripts/eza-wrapper.sh "$@"
}

# ─────────────────────────────────────────────────────────────
# Plugin Configuration
# ─────────────────────────────────────────────────────────────

# source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $CONFIG_DIR/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $CONFIG_DIR/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # must be last

# ─────────────────────────────────────────────────────────────
# Prompt (Pure)
# ─────────────────────────────────────────────────────────────

fpath+=($CONFIG_DIR/zsh/pure)
autoload -U promptinit; promptinit
prompt pure

# ─────────────────────────────────────────────────────────────
# Startup
# ─────────────────────────────────────────────────────────────

# if [[ "$(tty)" == "/dev/tty1" ]]; then
#   sway
# fi
fastfetch

# zoxide (jump directory utility)
eval "$(zoxide init --cmd cd zsh)"
