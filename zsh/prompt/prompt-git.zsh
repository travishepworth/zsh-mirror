#!/usr/bin/env zsh
# prompt-git.zsh - Git status integration for prompt

autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{green}●%f'
zstyle ':vcs_info:*' unstagedstr '%F{red}●%f'
zstyle ':vcs_info:git:*' formats ' %F{242}%b%f%c%u%m'
zstyle ':vcs_info:git:*' actionformats ' %F{242}%b%f %F{yellow}%a%f%c%u%m'

# Hook for stash indicator
+vi-git-stash() {
    local stash_count
    if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
        stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
        if (( stash_count > 0 )); then
            hook_com[misc]=" %F{cyan}≡${stash_count}%f"
        fi
    fi
}

zstyle ':vcs_info:git*+set-message:*' hooks git-stash

git_prompt_info() {
    vcs_info
}
