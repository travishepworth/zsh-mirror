# ─────────────────────────────────────────────────────────────
# Keybinds
# ─────────────────────────────────────────────────────────────

bindkey -e
bindkey '^[[H' beginning-of-line     # xterm-style Home
bindkey '^[[F' end-of-line           # xterm-style End
bindkey '^[OH' beginning-of-line     # Kitty/VTE alternative Home
bindkey '^[OF' end-of-line           # Kitty/VTE alternative End
bindkey '^[[3~' delete-char

bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
