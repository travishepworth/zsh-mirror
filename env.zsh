export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export ELECTRON_OZONE_PLATFORM_HINT=wayland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export MOZ_ENABLE_WAYLAND=1
export _JAVA_AWT_WM_NONREPARENTING=1

export WLR_DRM_NO_ATOMIC=1

export SDL_VIDEODRIVER=wayland
export LESS='-R --ignore-case --quit-if-one-screen --raw-control-chars'
export LESSHISTFILE='-'
export LESS_TERMCAP_md=$'\e[01;34m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;36m'
export LESS_TERMCAP_ue=$'\e[0m'

export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

export GREP_OPTIONS='--color=auto'

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
