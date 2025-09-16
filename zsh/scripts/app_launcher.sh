#!/usr/bin/env bash

# FZF App Launcher
# Usage: kitty -e /path/to/this/script

# Get all desktop applications
get_apps() {
    find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | \
    while read -r desktop_file; do
        # Extract Name and Exec fields
        name=$(grep "^Name=" "$desktop_file" | head -n1 | cut -d'=' -f2-)
        exec_cmd=$(grep "^Exec=" "$desktop_file" | head -n1 | cut -d'=' -f2-)
        
        # Skip if no name or exec
        [[ -z "$name" || -z "$exec_cmd" ]] && continue
        
        # Clean up exec command (remove %u, %f, etc.)
        exec_cmd=$(echo "$exec_cmd" | sed 's/%[uUfF]//g' | sed 's/[[:space:]]*$//')
        
        echo "$name|$exec_cmd"
    done | sort -u
}

# Launch the selected application
launch_app() {
    local selected="$1"
    [[ -z "$selected" ]] && exit 0
    
    # Extract the command part (after the |)
    local cmd="${selected#*|}"
    
    # Launch in background and detach from terminal
    nohup bash -c "$cmd" >/dev/null 2>&1 &
    disown
}

# Main launcher
main() {
    # Set FZF options for better appearance
    export FZF_DEFAULT_OPTS="
        --height=60%
        --layout=reverse
        --border=rounded
        --margin=1
        --padding=1
        --prompt='Launch: '
        --pointer='→'
        --marker='●'
        --color='fg:#ebdbb2,bg:#282828,hl:#d3869b'
        --color='fg+:#ebdbb2,bg+:#3c3836,hl+:#d3869b'
        --color='info:#83a598,prompt:#d3869b,pointer:#d3869b'
        --color='marker:#d3869b,spinner:#d3869b,header:#83a598'
        --preview-window=hidden
    "
    
    # Get apps and format for display (show only name, keep full info for selection)
    local selected
    selected=$(get_apps | \
        fzf --delimiter='|' \
            --with-nth=1 \
            --exit-0 \
            --select-1)
    
    # Launch the selected app
    launch_app "$selected"
}

# Run the launcher
main "$@"
