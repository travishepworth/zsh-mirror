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
