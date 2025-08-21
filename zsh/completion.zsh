# ─────────────────────────────────────────────────────────────
# Completion Settings
# ─────────────────────────────────────────────────────────────
autoload -Uz compinit
_zcompcache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
mkdir -p "${_zcompcache%/}"
compinit -d "${_zcompcache}" -C

REPORTTIME=1

# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
