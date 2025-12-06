#!/usr/bin/env bash
set -e

# @describe Use interactive fzf to select a file
# @arg candidates* File paths
# @env LLM_OUTPUT=/dev/stdout

main() {
    if ! command -v fzf >/dev/null; then
        echo '{ "selected": null, "error": "fzf-not-installed" }' >> "$LLM_OUTPUT"
        exit 0
    fi

    sel="$(printf "%s\n" "${argc_candidates[@]}" | fzf --ansi)"
    [[ $? -ne 0 ]] && { echo '{ "selected": null, "error": "fzf-aborted" }' >> "$LLM_OUTPUT"; exit 0; }

    printf '{ "selected": "%s", "error": null }\n' "$sel" >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"

