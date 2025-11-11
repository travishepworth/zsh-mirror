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

source $CONFIG_DIR/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $CONFIG_DIR/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # must be last

# ─────────────────────────────────────────────────────────────
# Prompt
# ─────────────────────────────────────────────────────────────

source $CONFIG_DIR/zsh/prompt/prompt.zsh

# ─────────────────────────────────────────────────────────────
# Startup
# ─────────────────────────────────────────────────────────────

fastfetch

# zoxide (jump directory utility)
eval "$(zoxide init --cmd cd zsh)"
