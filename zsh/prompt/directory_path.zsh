#!/usr/bin/env zsh
# Directory Path Module for Zsh Prompt
# Features: Gruvbox theme, powerline separators, customizable colors

# ============================================================================
# COLOR CONFIGURATION (Gruvbox Theme)
# ============================================================================

# Gruvbox color palette
typeset -A DIRPATH_COLORS
DIRPATH_COLORS=(
    # Gruvbox colors (256-color codes)
    'bg_dark'     '235'   # #282828
    'bg_medium'   '237'   # #3c3836
    'bg_light'    '239'   # #504945
    'fg_light'    '223'   # #ebdbb2
    'fg_medium'   '250'   # #d5c4a1
    'orange'      '208'   # #fe8019
    'blue'        '109'   # #83a598
    'green'       '142'   # #b8bb26
    'yellow'      '214'   # #fabd2f
    'red'         '167'   # #fb4934
    'purple'      '175'   # #d3869b
    'aqua'        '108'   # #8ec07c
)

# Theme configuration - easily customizable
DIRPATH_BG_COLOR="${DIRPATH_COLORS[bg_medium]}"
DIRPATH_FG_COLOR="${DIRPATH_COLORS[fg_light]}"
DIRPATH_SEPARATOR_COLOR="${DIRPATH_COLORS[bg_dark]}"
DIRPATH_HOME_COLOR="${DIRPATH_COLORS[blue]}"
DIRPATH_CURRENT_COLOR="${DIRPATH_COLORS[orange]}"

# ============================================================================
# SEPARATOR CHARACTERS
# ============================================================================

# Powerline separators
DIRPATH_SEPARATOR=""          # Forward separator
DIRPATH_SEPARATOR_THIN=""     # Thin separator
DIRPATH_LEFT_CAP=""           # Left cap
DIRPATH_RIGHT_CAP=""          # Right cap

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Function to set background and foreground colors
_dirpath_color() {
    local bg_color="$1"
    local fg_color="$2"
    echo "%K{$bg_color}%F{$fg_color}"
}

# Function to reset colors
_dirpath_reset() {
    echo "%k%f"
}

# Function to create separator
_dirpath_separator() {
    local prev_bg="$1"
    local next_bg="$2"
    echo "%K{$next_bg}%F{$prev_bg}${DIRPATH_SEPARATOR}%f"
}

# Function to shorten path intelligently
_dirpath_shorten() {
    local path="$1"
    local max_length="${DIRPATH_MAX_LENGTH:-50}"
    
    # Replace home directory with ~
    path="${path/#$HOME/~}"
    
    # If path is short enough, return as is
    if [[ ${#path} -le $max_length ]]; then
        echo "$path"
        return
    fi
    
    # Split path into components
    local -a path_parts
    path_parts=("${(@s:/:)path}")
    
    # Always keep the first part (~ or /) and last part
    local first="${path_parts[1]}"
    local last="${path_parts[-1]}"
    local middle_count=$((${#path_parts} - 2))
    
    if [[ $middle_count -le 0 ]]; then
        echo "$path"
        return
    fi
    
    # Shorten middle parts
    local shortened_middle=""
    local i=2
    while [[ $i -le $((${#path_parts} - 1)) ]]; do
        local part="${path_parts[$i]}"
        if [[ ${#part} -gt 1 ]]; then
            shortened_middle+="/${part[1]}"
        else
            shortened_middle+="/$part"
        fi
        ((i++))
    done
    
    echo "${first}${shortened_middle}/$last"
}

# ============================================================================
# MAIN DIRECTORY PATH FUNCTION
# ============================================================================

dirpath_module() {
    local current_path="$PWD"
    local display_path
    local output=""
    
    # Get shortened path
    display_path="$(_dirpath_shorten "$current_path")"
    
    # Handle special cases
    if [[ "$current_path" == "$HOME" ]]; then
        # Home directory - special styling
        output+="%K{$DIRPATH_HOME_COLOR}%F{$DIRPATH_FG_COLOR}"
        output+=" ~ "
        output+="%K{$DIRPATH_SEPARATOR_COLOR}%F{$DIRPATH_HOME_COLOR}"
        output+="$DIRPATH_SEPARATOR"
    elif [[ "$current_path" == "/" ]]; then
        # Root directory
        output+="%K{$DIRPATH_CURRENT_COLOR}%F{$DIRPATH_FG_COLOR}"
        output+=" / "
        output+="%K{$DIRPATH_SEPARATOR_COLOR}%F{$DIRPATH_CURRENT_COLOR}"
        output+="$DIRPATH_SEPARATOR"
    else
        # Regular directory
        local -a path_components
        local processed_path="${display_path/#~\//$HOME/}"
        
        # Split path and style each component
        if [[ "$display_path" =~ ^~ ]]; then
            # Starts with home
            output+="%K{$DIRPATH_HOME_COLOR}%F{$DIRPATH_FG_COLOR}"
            output+=" ~ "
            
            # Add separator if there are more components
            if [[ "$display_path" != "~" ]]; then
                output+="%K{$DIRPATH_BG_COLOR}%F{$DIRPATH_HOME_COLOR}"
                output+="$DIRPATH_SEPARATOR"
                
                # Add the rest of the path
                local rest_path="${display_path#~/}"
                output+="%F{$DIRPATH_FG_COLOR} $rest_path "
                
                output+="%K{$DIRPATH_SEPARATOR_COLOR}%F{$DIRPATH_BG_COLOR}"
                output+="$DIRPATH_SEPARATOR"
            else
                output+="%K{$DIRPATH_SEPARATOR_COLOR}%F{$DIRPATH_HOME_COLOR}"
                output+="$DIRPATH_SEPARATOR"
            fi
        else
            # Absolute path
            output+="%K{$DIRPATH_BG_COLOR}%F{$DIRPATH_FG_COLOR}"
            output+=" $display_path "
            output+="%K{$DIRPATH_SEPARATOR_COLOR}%F{$DIRPATH_BG_COLOR}"
            output+="$DIRPATH_SEPARATOR"
        fi
    fi
    
    # Reset colors
    output+="$(_dirpath_reset)"
    
    echo "$output"
}

# ============================================================================
# CUSTOMIZATION FUNCTIONS
# ============================================================================

# Function to change color theme
dirpath_set_theme() {
    local theme="$1"
    
    case "$theme" in
        "gruvbox-dark")
            DIRPATH_BG_COLOR="${DIRPATH_COLORS[bg_medium]}"
            DIRPATH_FG_COLOR="${DIRPATH_COLORS[fg_light]}"
            DIRPATH_HOME_COLOR="${DIRPATH_COLORS[blue]}"
            DIRPATH_CURRENT_COLOR="${DIRPATH_COLORS[orange]}"
            ;;
        "gruvbox-light")
            DIRPATH_BG_COLOR="${DIRPATH_COLORS[fg_light]}"
            DIRPATH_FG_COLOR="${DIRPATH_COLORS[bg_dark]}"
            DIRPATH_HOME_COLOR="${DIRPATH_COLORS[blue]}"
            DIRPATH_CURRENT_COLOR="${DIRPATH_COLORS[orange]}"
            ;;
        "minimal")
            DIRPATH_BG_COLOR="240"
            DIRPATH_FG_COLOR="255"
            DIRPATH_HOME_COLOR="244"
            DIRPATH_CURRENT_COLOR="248"
            ;;
        *)
            echo "Unknown theme: $theme"
            echo "Available themes: gruvbox-dark, gruvbox-light, minimal"
            return 1
            ;;
    esac
}

# Function to set custom colors
dirpath_set_colors() {
    local bg="$1"
    local fg="$2"
    local home="$3"
    local current="$4"
    
    [[ -n "$bg" ]] && DIRPATH_BG_COLOR="$bg"
    [[ -n "$fg" ]] && DIRPATH_FG_COLOR="$fg"
    [[ -n "$home" ]] && DIRPATH_HOME_COLOR="$home"
    [[ -n "$current" ]] && DIRPATH_CURRENT_COLOR="$current"
}

# ============================================================================
# CONFIGURATION VARIABLES
# ============================================================================

# Maximum path length before shortening
DIRPATH_MAX_LENGTH=50

# Whether to show git repository name
DIRPATH_SHOW_GIT_REPO=true

# ============================================================================
# USAGE EXAMPLE
# ============================================================================

# Add to your .zshrc:
# source /path/to/this/dirpath_module.zsh
# PROMPT='$(dirpath_module) $ '

# Or for right prompt:
# RPROMPT='$(dirpath_module)'

# Change theme:
# dirpath_set_theme "gruvbox-light"

# Custom colors (bg, fg, home, current):
# dirpath_set_colors "235" "223" "109" "208"
