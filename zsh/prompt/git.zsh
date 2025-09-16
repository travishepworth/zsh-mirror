#!/usr/bin/env zsh
# git.zsh - Git prompt module for zsh

# Main function to update GIT_PROMPT environment variable
git_prompt_update() {
    GIT_PROMPT=""
    
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
    fi
    
    local branch=""
    local dirty=""
    local ahead_behind=""
    
    # Get current branch name
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    
    if [[ -z "$branch" ]]; then
        return 0
    fi
    
    # Check if working directory is clean
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        dirty="*"
    fi
    
    # Check ahead/behind status
    local upstream=$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2>/dev/null)
    if [[ -n "$upstream" ]]; then
        local ahead=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)
        local behind=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
        
        if [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
            ahead_behind="↑↓"
        elif [[ "$ahead" -gt 0 ]]; then
            ahead_behind="↓"
        elif [[ "$behind" -gt 0 ]]; then
            ahead_behind="↑"
        fi
    fi
    
    # Build the prompt
    GIT_PROMPT="$branch$dirty"
    if [[ -n "$ahead_behind" ]]; then
        GIT_PROMPT="$GIT_PROMPT $ahead_behind"
    fi
}

# Initial call to set the prompt
git_prompt_update
