# zsh async prompt segment: Arch updates (official repo vs AUR)
# - Non-blocking: does the slow checks in a background job; prompt reads cached counts.

# --- Config -------------------------------------------------------------------
: ${ARCH_UPD_PROMPT_INTERVAL:=300}
: ${ARCH_UPD_CACHE_FILE:="${XDG_CACHE_HOME:-$HOME/.cache}/arch_upd_prompt.cache"}

typeset -gA ARCH_UPD_PROMPT_THEME=(
  icon_main   ""   # nf-fa-wrench
  icon_repo   ""   # nf-linux-archlinux
  icon_aur    ""   # nf-oct-package
  sep         "  "
  color_main  "green"
  color_repo  "blue"
  color_aur   "magenta"
  color_count "yellow"
  color_dim   "240" # gray for 'refreshing' dot
)

# --- State --------------------------------------------------------------------
typeset -gi _ARCH_UPD_REPO_COUNT=0
typeset -gi _ARCH_UPD_AUR_COUNT=0
typeset -gi _ARCH_UPD_LAST_REFRESH=0
typeset -gi _ARCH_UPD_WORKER_PID=0
typeset -g  _ARCH_UPD_STATUS=""

# --- Utils --------------------------------------------------------------------
_arch_upd_mkdirp() {
  local d="${ARCH_UPD_CACHE_FILE%/*}"; [[ -d "$d" ]] || mkdir -p -- "$d" 2>/dev/null
}
_arch_upd_count_repo() {
  if command -v checkupdates >/dev/null; then checkupdates 2>/dev/null | wc -l | tr -d '[:space:]';
  elif command -v yay >/dev/null; then yay -Qu --repo 2>/dev/null | wc -l | tr -d '[:space:]';
  else print 0; fi
}
_arch_upd_count_aur() {
  if command -v yay >/dev/null; then
    if yay -h 2>&1 | grep -q -- "--aur"; then yay -Qu --aur 2>/dev/null | wc -l | tr -d '[:space:]';
    else yay -Qua 2>/dev/null | wc -l | tr -d '[:space:]'; fi
  else print 0; fi
}

# --- Cache I/O ----------------------------------------------------------------
_arch_upd_cache_load() {
  if [[ -f "$ARCH_UPD_CACHE_FILE" ]]; then
    local e r a; { read -r e r a < "$ARCH_UPD_CACHE_FILE"; } 2>/dev/null
    if [[ -n "$e" && -n "$r" && -n "$a" ]]; then
      _ARCH_UPD_LAST_REFRESH=$e; _ARCH_UPD_REPO_COUNT=$r; _ARCH_UPD_AUR_COUNT=$a; return 0;
    fi
  fi; return 1;
}
_arch_upd_cache_save() {
  local e="$1" r="$2" a="$3"; _arch_upd_mkdirp
  print -r -- "$e $r $a" >| "${ARCH_UPD_CACHE_FILE}.tmp.$$" && mv -f -- "${ARCH_UPD_CACHE_FILE}.tmp.$$" "$ARCH_UPD_CACHE_FILE"
}

# --- Background worker --------------------------------------------------------
_arch_upd_spawn_worker() {
  setopt localoptions nomonitor nonotify
  if (( _ARCH_UPD_WORKER_PID > 0 )) && kill -0 "$_ARCH_UPD_WORKER_PID" >/dev/null 2>&1; then return; fi
  _ARCH_UPD_STATUS="."
  ( emulate -L zsh; local r a; r=$(_arch_upd_count_repo); a=$(_arch_upd_count_aur); _arch_upd_cache_save "$EPOCHSECONDS" "$r" "$a" ) >/dev/null 2>&1 &!
  _ARCH_UPD_WORKER_PID=$!
}

# --- Prompt builder -----------------------------------------------------------
arch_upd_prompt_segment() {
  local -a segs=(); local pr=""
  if (( _ARCH_UPD_REPO_COUNT > 0 )); then
    segs+=("%F{${ARCH_UPD_PROMPT_THEME[color_repo]}}${ARCH_UPD_PROMPT_THEME[icon_repo]}%f %F{${ARCH_UPD_PROMPT_THEME[color_count]}}${_ARCH_UPD_REPO_COUNT}%f")
  fi
  if (( _ARCH_UPD_AUR_COUNT > 0 )); then
    segs+=("%F{${ARCH_UPD_PROMPT_THEME[color_aur]}}${ARCH_UPD_PROMPT_THEME[icon_aur]}%f %F{${ARCH_UPD_PROMPT_THEME[color_count]}}${_ARCH_UPD_AUR_COUNT}%f")
  fi
  if (( ${#segs[@]} )); then
    pr="%F{${ARCH_UPD_PROMPT_THEME[color_main]}}${ARCH_UPD_PROMPT_THEME[icon_main]}%f ${(j:${ARCH_UPD_PROMPT_THEME[sep]}:)segs}"
    if (( _ARCH_UPD_WORKER_PID > 0 )) && kill -0 "$_ARCH_UPD_WORKER_PID" >/dev/null 2>&1; then pr+=" %F{${ARCH_UPD_PROMPT_THEME[color_dim]}}${_ARCH_UPD_STATUS}%f"; fi
  elif (( _ARCH_UPD_WORKER_PID > 0 )) && kill -0 "$_ARCH_UPD_WORKER_PID" >/dev/null 2>&1; then pr="%F{${ARCH_UPD_PROMPT_THEME[color_dim]}}${_ARCH_UPD_STATUS}%f";
  fi
  print -r -- "$pr"
}

# --- Hook (fast) --------------------------------------------------------------
_arch_upd_precmd() {
  _arch_upd_cache_load >/dev/null 2>&1
  if (( EPOCHSECONDS - _ARCH_UPD_LAST_REFRESH >= ARCH_UPD_PROMPT_INTERVAL )); then _arch_upd_spawn_worker; fi
  if ! { (( _ARCH_UPD_WORKER_PID > 0 )) && kill -0 "$_ARCH_UPD_WORKER_PID" >/dev/null 2>&1; }; then
    _ARCH_UPD_STATUS=""; _ARCH_UPD_WORKER_PID=0; _arch_upd_cache_load >/dev/null 2>&1;
  fi
}
autoload -Uz add-zsh-hook; add-zsh-hook precmd _arch_upd_precmd
_arch_upd_spawn_worker
