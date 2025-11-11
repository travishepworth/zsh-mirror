#!/usr/bin/env zsh
# prompt-char.zsh - Dynamic prompt character based on exit status

prompt_char() {
    echo "%(?:%F{magenta}:%F{red})❯%f"
}

prompt_bracket() {
    echo "%F{242}╰─%f"
}

prompt_bracket_top() {
    echo "%F{242}╭─%f"
}
