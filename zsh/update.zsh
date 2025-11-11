# # zsh async left-prompt: Arch updates (official repo vs AUR)
# # - Non-blocking: does the slow checks in a background job; prompt reads cached counts.
# # - Requires: Nerd Font for icons. Optional (faster repo checks): `checkupdates` from pacman-contrib.
# # - Install: put in a file and `source` it from ~/.zshrc. Then, add `$(arch_upd_prompt_segment)`
# #   to the beginning of your PROMPT variable (see installation notes).
#
# # --- Config -------------------------------------------------------------------
# : ${ARCH_UPD_PROMPT_INTERVAL:=300}  # seconds between refreshes
# : ${ARCH_UPD_CACHE_FILE:="${XDG_CACHE_HOME:-$HOME/.cache}/arch_upd_prompt.cache"}
#
# typeset -gA ARCH_UPD_PROMPT_THEME=(
#   icon_main   ""   # nf-fa-wrench
#   icon_repo   ""   # nf-linux-archlinux
#   icon_aur    ""   # nf-oct-package
#   sep         "  "
#   color_main  "green"
#   color_repo  "blue"
#   color_aur   "magenta"
#   color_count "yellow"
#   color_dim   "240" # gray for 'refreshing' dot
# )
#
# # --- State --------------------------------------------------------------------
# typeset -gi _ARCH_UPD_REPO_COUNT=0
# typeset -gi _ARCH_UPD_AUR_COUNT=0
# typeset -gi _ARCH_UPD_LAST_REFRESH=0
# typeset -gi _ARCH_UPD_WORKER_PID=0
# typeset -g  _ARCH_UPD_STATUS=""
#
# # --- Utils --------------------------------------------------------------------
# _arch_upd_mkdirp() {
#   # portable dirname without external `dirname`
#   local d="${ARCH_UPD_CACHE_FILE%/*}"
#   [[ "$d" == "$ARCH_UPD_CACHE_FILE" || -z "$d" ]] && d="${XDG_CACHE_HOME:-$HOME/.cache}"
#   [[ -d "$d" ]] || mkdir -p -- "$d" 2>/dev/null
# }
#
# # Count official repo updates
# _arch_upd_count_repo() {
#   local n=0
#   if command -v checkupdates >/dev/null 2>&1; then
#     n=$(checkupdates 2>/dev/null | wc -l | tr -d '[:space:]')
#   elif command -v yay >/dev/null 2>&1; then
#     n=$(yay -Qu --repo 2>/dev/null | wc -l | tr -d '[:space:]')
#   else
#     n=0
#   fi
#   print -r -- "${n:-0}"
# }
#
# # Count AUR updates
# _arch_upd_count_aur() {
#   local n=0
#   if command -v yay >/dev/null 2>&1; then
#     if yay -h 2>&1 | grep -q -- "--aur"; then
#       n=$(yay -Qu --aur 2>/dev/null | wc -l | tr -d '[:space:]')
#     else
#       n=$(yay -Qua 2>/dev/null | wc -l | tr -d '[:space:]')
#     fi
#   else
#     n=0
#   fi
#   print -r -- "${n:-0}"
# }
#
# # --- Cache I/O ----------------------------------------------------------------
# _arch_upd_cache_load() {
#   # format: "epoch repo_count aur_count"
#   if [[ -f "$ARCH_UPD_CACHE_FILE" ]]; then
#     local e r a
#     # redirect order matters in some shells; keep < first
#     { read -r e r a < "$ARCH_UPD_CACHE_FILE"; } 2>/dev/null
#     if [[ -n "$e" && -n "$r" && -n "$a" ]]; then
#       _ARCH_UPD_LAST_REFRESH=$e
#       _ARCH_UPD_REPO_COUNT=$r
#       _ARCH_UPD_AUR_COUNT=$a
#       return 0
#     fi
#   fi
#   return 1
# }
#
# _arch_upd_cache_save() {
#   local e="$1" r="$2" a="$3"
#   _arch_upd_mkdirp
#   local tmp="${ARCH_UPD_CACHE_FILE}.tmp.$$"
#   print -r -- "$e $r $a" >| "$tmp" 2>/dev/null && mv -f -- "$tmp" "$ARCH_UPD_CACHE_FILE" 2>/dev/null
# }
#
# # --- Background worker --------------------------------------------------------
#
# _arch_upd_spawn_worker() {
#   # no job table entries, no notifications (local only)
#   setopt localoptions nomonitor nonotify
#
#   # Avoid multiple workers
#   if (( _ARCH_UPD_WORKER_PID > 0 )) && kill -0 "$_ARCH_UPD_WORKER_PID" >/dev/null 2>&1; then
#     return
#   fi
#
#   _ARCH_UPD_STATUS="."
#
#   (
#     emulate -L zsh
#     # do the slow work quietly
#     local r a now
#     r=$(_arch_upd_count_repo)
#     a=$(_arch_upd_count_aur)
#     now=$EPOCHSECONDS
#     _arch_upd_cache_save "$now" "$r" "$a"
#   ) >/dev/null 2>&1 &!   # run in background and disown immediately (no “[n] … done”)
#
#   _ARCH_UPD_WORKER_PID=$!
# }
#
# # --- Prompt builder -----------------------------------------------------------
# # MODIFIED: Renamed function for clarity and made it public (no leading underscore)
# arch_upd_prompt_segment() {
#   local -a segs=()
#   local pr=""
#
#   if (( _ARCH_UPD_REPO_COUNT > 0 )); then
#     segs+=("%F{${ARCH_UPD_PROMPT_THEME[color_repo]}}${ARCH_UPD_PROMPT_THEME[icon_repo]}%f %F{${ARCH_UPD_PROMPT_THEME[color_count]}}${_ARCH_UPD_REPO_COUNT}%f")
#   fi
#   if (( _ARCH_UPD_AUR_COUNT > 0 )); then
#     segs+=("%F{${ARCH_UPD_PROMPT_THEME[color_aur]}}${ARCH_UPD_PROMPT_THEME[icon_aur]}%f %F{${ARCH_UPD_PROMPT_THEME[color_count]}}${_ARCH_UPD_AUR_COUNT}%f")
#   fi
#
#   if (( ${#segs[@]} )); then
#     pr="%F{${ARCH_UPD_PROMPT_THEME[color_main]}}${ARCH_UPD_PROMPT_THEME[icon_main]}%f ${(j:${ARCH_UPD_PROMPT_THEME[sep]}:)segs}"
#     if (( _ARCH_UPD_WORKER_PID > 0 )) && kill -0 "$_ARCH_UPD_WORKER_PID" >/dev/null 2>&1; then
#       pr+=" %F{${ARCH_UPD_PROMPT_THEME[color_dim]}}${_ARCH_UPD_STATUS}%f"
#     fi
#   else
#     if (( _ARCH_UPD_WORKER_PID > 0 )) && kill -0 "$_ARCH_UPD_WORKER_PID" >/dev/null 2>&1; then
#       pr="%F{${ARCH_UPD_PROMPT_THEME[color_dim]}}${_ARCH_UPD_STATUS}%f"
#     fi
#   fi
#
#   # MODIFIED: Add a trailing space if the segment is not empty
#   if [[ -n "$pr" ]]; then
#     pr+=' '
#   fi
#
#   print -r -- "$pr"
# }
#
# # --- Hook (fast) --------------------------------------------------------------
# _arch_upd_precmd() {
#   _arch_upd_cache_load >/dev/null 2>&1
#
#   if (( EPOCHSECONDS - _ARCH_UPD_LAST_REFRESH >= ARCH_UPD_PROMPT_INTERVAL )); then
#     _arch_upd_spawn_worker
#   fi
#
#   # If worker finished since last time, clear status and pull fresh cache
#   if ! { (( _ARCH_UPD_WORKER_PID > 0 )) && kill -0 "$_ARCH_UPD_WORKER_PID" >/dev/null 2>&1; }; then
#     _ARCH_UPD_STATUS=""
#     _ARCH_UPD_WORKER_PID=0
#     _arch_upd_cache_load >/dev/null 2>&1
#   fi
# }
#
# # Install hook robustly via add-zsh-hook (safer than fiddling with precmd_functions)
# autoload -Uz add-zsh-hook
# add-zsh-hook precmd _arch_upd_precmd
#
# # Kick an initial async refresh on load; prompt stays instant
# _arch_upd_spawn_worker
