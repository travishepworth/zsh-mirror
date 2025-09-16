#!/usr/bin/env zsh

PROMPT_DIR="$CONFIG_DIR/zsh/prompt"
source $PROMPT_DIR/kube-context.zsh
source $PROMPT_DIR/git.zsh

prompt_directory_path() {
    # echo "%F{yellow}%~%f"
    echo "%F{blue}%~%f %F{cyan}➜%f "
}

prompt_symbol() {
    echo "-->"
}

build_prompt() {
    local kubernetes_info="$(echo "$KUBE_PROMPT")"
    local directory_path="$(prompt_directory_path)"
    local git_info="$(echo "$GIT_PROMPT")"
    local symbol="$(prompt_symbol)"
    
    local line1=" $kubernetes_info"
    local line2=" $directory_path $git_info"
    local line3=" $symbol "
    
    PROMPT="$line1
$line2
$line3"
}

setup_prompt() {
    setopt PROMPT_SUBST
    
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd kube_prompt_info
    add-zsh-hook precmd git_prompt_update
    add-zsh-hook precmd build_prompt
    
    build_prompt
}

setup_prompt
