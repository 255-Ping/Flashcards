#!/bin/sh
printf '\033c\033]0;%s\a' FlashCards
base_path="$(dirname "$(realpath "$0")")"
"$base_path/FlashCards.x86_64" "$@"
