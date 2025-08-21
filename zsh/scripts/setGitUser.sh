#!/usr/bin/env bash

# Usage: git-user [personal|work]

if [[ $# -ne 1 ]]; then
  echo "Usage: git-user [personal|work]"
  exit 1
fi

PROFILE=$1

case "$PROFILE" in
  personal)
    git config user.name "travmonkey"
    git config user.email "t.coding@batk.me"
    echo "Set Git user to PERSONAL"
    ;;
  work)
    git config user.name "Travis Hepworth"
    git config user.email "t.hepworth@cablelabs.com"
    echo "Set Git user to WORK"
    ;;
  *)
    echo "Invalid profile. Use 'personal' or 'work'."
    exit 1
    ;;
esac
