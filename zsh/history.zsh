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

# History settings
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# History options
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt INC_APPEND_HISTORY        # Write to history immediately
setopt SHARE_HISTORY             # Share history between sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicates
setopt HIST_FIND_NO_DUPS         # Don't display duplicates in search
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
setopt HIST_SAVE_NO_DUPS         # Don't save duplicates
setopt HIST_VERIFY               # Show command before executing from history
