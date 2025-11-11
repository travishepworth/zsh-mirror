#!/usr/bin/env zsh
# prompt.zsh - Custom prompt assembly

# Source components
source "${0:A:h}/arch-updates.zsh"
source "${0:A:h}/kube-context.zsh"
source "${0:A:h}/prompt-git.zsh"
source "${0:A:h}/prompt-dir.zsh"
source "${0:A:h}/prompt-char.zsh"

# Enable prompt substitution
setopt prompt_subst

# --- KUBERNETES ACTIVATION DETECTION ---
_KUBE_ACTIVATED=false
detect_kubectl_usage() {
    if [[ "$1" =~ ^(kubectl|kc|oc|kctx)([[:space:]]|$) ]]; then
        _KUBE_ACTIVATED=true
    elif [[ "$1" =~ ^(ff)([[:space:]]|$) ]]; then
        _KUBE_ACTIVATED=false
    fi
}

# --- HOOKS ---
autoload -Uz add-zsh-hook
add-zsh-hook precmd git_prompt_info
add-zsh-hook precmd kube_prompt_info
add-zsh-hook preexec detect_kubectl_usage

# --- ASSEMBLE PROMPT ---
local updates='$(local seg=$(arch_upd_prompt_segment); [[ -n "$seg" ]] && print "$seg\n")'
local dir='$(prompt_dir)'
local git='${vcs_info_msg_0_}'
local bracket='$(prompt_bracket)'
local bracket_top='$(prompt_bracket_top)'
local kube='${KUBE_PROMPT}'
local char='$(prompt_char)'

PROMPT="${updates}"$'\n'"${bracket_top} ${dir} ${git}"$'\n'"${bracket} ${kube}${char} "
