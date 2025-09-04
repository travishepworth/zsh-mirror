# It only re-runs kubectl when ~/.kube/config changes.

# Declare global variables for caching
_KUBE_PROMPT_LAST_KUBECONFIG_MOD_TIME=0
_KUBE_PROMPT_CACHED_VAL=""
_KUBE_ACTIVATED=false

kube_prompt_info() {
  # Path to your kubeconfig file
  local kubeconfig_file="${KUBECONFIG:-$HOME/.kube/config}"

  # Check if the file exists
  if [[ ! -f "$kubeconfig_file" ]]; then
    KUBE_PROMPT=""
    return
  fi

  if ! $_KUBE_ACTIVATED; then
    KUBE_PROMPT=""
    return
  fi
  
  # Get the last modification time of the kubeconfig file
  # zstat is a Zsh built-in, which is faster than calling /usr/bin/stat
  zmodload zsh/stat
  local current_mod_time=$(zstat +mtime "$kubeconfig_file")

  # If the file hasn't changed, use the cached value and exit
  if [[ "$current_mod_time" -eq "$_KUBE_PROMPT_LAST_KUBECONFIG_MOD_TIME" ]]; then
    KUBE_PROMPT=$_KUBE_PROMPT_CACHED_VAL
    return
  fi

  # If the file *has* changed, update the modification time
  _KUBE_PROMPT_LAST_KUBECONFIG_MOD_TIME=$current_mod_time

  # --- This part is the same as before ---
  if ! command -v kubectl &> /dev/null; then
    _KUBE_PROMPT_CACHED_VAL=""
    KUBE_PROMPT=$_KUBE_PROMPT_CACHED_VAL
    return
  fi
  
  local kube_info=$(kubectl config view --minify --output 'jsonpath={.contexts[0].context.cluster} {.contexts[0].context.user} {.contexts[0].context.namespace}')
  
  if [[ -z "$kube_info" ]]; then
    _KUBE_PROMPT_CACHED_VAL=""
    KUBE_PROMPT=$_KUBE_PROMPT_CACHED_VAL
    return
  fi

  local -a info_parts
  info_parts=(${(s: :)kube_info})
  local cluster="${info_parts[1]#*-}"
  local cluster="${cluster%%-*}"
  local user="${info_parts[2]%%/*}"
  local namespace="${info_parts[3]:-default}"
  
  # Update the cache and the final variable
  _KUBE_PROMPT_CACHED_VAL="%F{cyan}( ${cluster}:${user}:${namespace})%f"
  KUBE_PROMPT=$_KUBE_PROMPT_CACHED_VAL
}
