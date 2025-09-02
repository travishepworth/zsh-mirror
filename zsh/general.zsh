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

source $CONFIG_DIR/zsh/prompt/kube-context.zsh
_KUBE_ACTIVATED=false

detect_kubectl_usage() {
    # Check if the last command contained kubectl or kc
    if [[ "$1" =~ ^(kubectl|kc)([[:space:]]|$) ]]; then
        _KUBE_ACTIVATED=true
    elif [[ "$1" =~ ^(ff)([[:space:]]|$) ]]; then
        _KUBE_ACTIVATED=false
    fi
}

fpath+=($CONFIG_DIR/zsh/pure)
autoload -U promptinit; promptinit
prompt pure
zstyle :prompt:pure:git:stash show yes

autoload -Uz add-zsh-hook
add-zsh-hook precmd kube_prompt_info
add-zsh-hook preexec detect_kubectl_usage
setopt PROMPT_SUBST
if ! $_KUBE_ACTIVATED; then
  KUBE_PROMPT=""
fi
PROMPT='${KUBE_PROMPT}'$PROMPT

# ─────────────────────────────────────────────────────────────
# Startup
# ─────────────────────────────────────────────────────────────

# if [[ "$(tty)" == "/dev/tty1" ]]; then
#   sway
# fi
fastfetch

# zoxide (jump directory utility)
eval "$(zoxide init --cmd cd zsh)"
