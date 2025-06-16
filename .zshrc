# ─────────────────────────────────────────────────────────────
# History Settings
# ─────────────────────────────────────────────────────────────
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

CONFIG_DIR="$HOME/.config/zsh"

# ─────────────────────────────────────────────────────────────
# Completion Settings
# ─────────────────────────────────────────────────────────────
autoload -Uz compinit
compinit

REPORTTIME=1

# Enable menu-based selection on tab completion

# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# ─────────────────────────────────────────────────────────────
# Keybinds
# ─────────────────────────────────────────────────────────────

bindkey -e
bindkey '^[[H' beginning-of-line     # xterm-style Home
bindkey '^[[F' end-of-line           # xterm-style End
bindkey '^[OH' beginning-of-line     # Kitty/VTE alternative Home
bindkey '^[OF' end-of-line           # Kitty/VTE alternative End

# ─────────────────────────────────────────────────────────────
# Plugin Configuration
# ─────────────────────────────────────────────────────────────

# source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # must be last

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
  }

  autoload -Uz fzf-history-widget
  zle -N fzf-history-widget
  bindkey '^R' fzf-history-widget
  zle -I  # Invalidate zle cache
fi

rgi() {
  local query
  query=$(printf "" | fzf --prompt="Rg: " --print-query --phony --bind "change:reload:rg --color=always --line-number --no-heading --hidden --smart-case --glob '!.git/*' {q} || true" \
          --delimiter : \
          --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
          --preview-window 'up:60%:wrap' \
          --bind "enter:become(nvim +{2} {1})")

  # fallback if nothing selected
  [ -z "$query" ] && return 0
}

# ─────────────────────────────────────────────────────────────
# PATH & Scripts
# ─────────────────────────────────────────────────────────────

export PATH="$CONFIG_DIR/.zsh/scripts:$PATH"
function ls() {
  $CONFIG_DIR/.zsh/scripts/eza-wrapper.sh "$@"
}

# ─────────────────────────────────────────────────────────────
# Prompt (Pure)
# ─────────────────────────────────────────────────────────────

fpath+=($CONFIG_DIR/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

# bindkey -v
#
# # Show -- INSERT -- or -- NORMAL -- in the right prompt
# function zle-keymap-select {
#   if [[ $KEYMAP == vicmd ]]; then
#     # NORMAL mode: block cursor
#     echo -ne '\e[2 q'
#     RPROMPT="%F{yellow}[NORMAL]%f"
#   else
#     # INSERT mode: line cursor
#     echo -ne '\e[6 q'
#     RPROMPT=""
#   fi
#   zle reset-prompt
# }
# zle -N zle-keymap-select
#
# function zle-line-init {
#   zle-keymap-select
# }
# zle -N zle-line-init


# ─────────────────────────────────────────────────────────────
# Startup
# ─────────────────────────────────────────────────────────────

if [[ "$(tty)" == "/dev/tty1" ]]; then
  Hyprland
fi
fastfetch

# zoxide (jump directory utility)
eval "$(zoxide init --cmd cd zsh)"
