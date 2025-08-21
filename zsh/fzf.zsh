# ─────────────────────────────────────────────────────────────
# fzf Reverse Search Integration
# ─────────────────────────────────────────────────────────────

if [[ $- == *i* ]]; then  # Only run in interactive shells
  # Source fzf keybindings and completion
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

  fzf-history-widget() {
    local selected
    selected=$(fc -rl 1 | awk '{$1=""; print substr($0,2)}' | fzf --exact --no-sort --reverse --height 40% --border --prompt='History> ')
    if [[ -n $selected ]]; then
      LBUFFER=$selected
      zle redisplay
    fi
    zle reset-prompt
  }

  autoload -Uz fzf-history-widget
  zle -N fzf-history-widget
  bindkey '^R' fzf-history-widget
  zle -I  # Invalidate zle cache
fi

