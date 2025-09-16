#!/usr/bin/env bash

kcnx() {
  if [[ -z "$1" ]]; then
    echo "Error: You must provide a name for the context." >&2
    echo "Usage: kcnx <name>" >&2
    return 1
  fi

  local CONTEXT_NAME="$1"
  local NAMESPACE="$1"
  local OIDC_USER="oidc"

  local CURRENT_CLUSTER=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
  if [[ -z "$CURRENT_CLUSTER" ]]; then
    echo "Error: Could not determine the current Kubernetes cluster." >&2
    echo "Please ensure you have a valid kubeconfig and a current context set." >&2
    return 1
  fi

  echo "==> Creating context '$CONTEXT_NAME'..."
  echo "    Cluster:   $CURRENT_CLUSTER"
  echo "    User:      $OIDC_USER"
  echo "    Namespace: $NAMESPACE"

  kubectl config set-context "$CONTEXT_NAME" \
    --cluster="$CURRENT_CLUSTER" \
    --user="$OIDC_USER" \
    --namespace="$NAMESPACE"

  if [[ $? -eq 0 ]]; then
    echo "\n==> Switching to context '$CONTEXT_NAME'."
    kubectl config use-context "$CONTEXT_NAME"
  else
    echo "\nError: Failed to create context." >&2
    return 1
  fi
}

kcnx "$@"
