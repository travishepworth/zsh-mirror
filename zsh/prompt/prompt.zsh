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

# --- SSH DETECTION (NEW SECTION) ---
# Create a variable that will hold user@host, but only for SSH sessions.
# It will be empty otherwise.
local ssh_info=""
if [[ -n "$SSH_CONNECTION" ]]; then
  # %F{...} sets the color (yellow is 226 or just 'yellow')
  # %n is the username
  # %m is the short hostname
  # %f resets the color
  # The trailing space is important for separation.
  ssh_info="%F{yellow}%n@%m%f "
fi

# --- ASSEMBLE PROMPT ---
local updates='$(local seg=$(arch_upd_prompt_segment); [[ -n "$seg" ]] && print "$seg\n")'
local dir='$(prompt_dir)'
local git='${vcs_info_msg_0_}'
local bracket='$(prompt_bracket)'
local bracket_top='$(prompt_bracket_top)'
local kube='${KUBE_PROMPT}'
local char='$(prompt_char)'

# MODIFIED LINE: Added ${ssh_info} to the top line of the prompt
PROMPT="${updates}"$'\n'"${bracket_top} ${ssh_info}${dir} ${git}"$'\n'"${bracket} ${kube}${char} "
