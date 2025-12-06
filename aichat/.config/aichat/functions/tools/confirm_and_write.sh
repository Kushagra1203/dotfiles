#!/usr/bin/env bash
set -e

# @describe Safely write new content to a file with backup
# @option --path! File to write
# @option --new-content! Updated file content
# @env LLM_OUTPUT=/dev/stdout

main() {
    local path="$argc_path"
    local backup="${path}.bak"
    local new="$argc_new_content"

    # Backup if exists
    if [[ -f "$path" ]]; then
        cp "$path" "$backup"
    else
        backup=null
    fi

    # DIRECT WRITE (no fs_write dependency)
    printf "%s" "$new" > "$path"

    printf '{ "backup": "%s", "error": null }\n' "$backup" >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"

