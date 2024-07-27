#!/bin/sh
echo -ne '\033c\033]0;Strongerholder\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Strongerholer II.x86_64" "$@"
