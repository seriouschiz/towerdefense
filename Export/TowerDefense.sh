#!/bin/sh
echo -ne '\033c\033]0;TowerDefense\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/TowerDefense.x86_64" "$@"
