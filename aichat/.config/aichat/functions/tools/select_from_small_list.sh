#!/usr/bin/env bash
set -e

# @describe Present 2–3 candidates to user
# @option --candidates+ File paths
# @env LLM_OUTPUT=/dev/stdout

main() {
    local -a arr=("${argc_candidates[@]}")

    {
        printf '{ "count": %d, "choices": [' "${#arr[@]}"
        local i=1 first=true
        for p in "${arr[@]}"; do
            $first || printf ', '
            printf '{ "i": %d, "path": "%s" }' "$i" "$p"
            i=$((i+1))
            first=false
        done
        printf '] }\n'
    } >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"

