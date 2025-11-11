#!/usr/bin/env zsh
# prompt.zsh - Pure prompt with Arch updates prepended and Kube context injected
# Source required modules
source "${0:A:h}/arch-updates.zsh"
source "${0:A:h}/kube-context.zsh"
# --- PURE PROMPT SETUP ---
fpath+=($CONFIG_DIR/zsh/pure)
autoload -U promptinit; promptinit
prompt pure
zstyle :prompt:pure:git:stash show yes
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
add-zsh-hook precmd kube_prompt_info
add-zsh-hook preexec detect_kubectl_usage
# --- CUSTOMIZE PROMPT ---
setopt prompt_subst
PROMPT='$(local seg=$(arch_upd_prompt_segment); [[ -n "$seg" ]] && print "$seg\n")${KUBE_PROMPT}'$PROMPT
