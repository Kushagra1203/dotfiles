#!/usr/bin/env bash
set -e

# @describe Fuzzy-search for a filename across paths
# @option --name! Filename or pattern (exact name or glob fragment)
# @option --search-roots Comma-separated list of roots to search (optional)
# @env LLM_OUTPUT=/dev/stdout

main() {
    local pattern="$argc_name"
    local roots="${argc_search_roots:-/home,~/.config,/etc,/usr/local/etc}"

    IFS=',' read -ra dirs <<< "$roots"
    declare -a found=()

    for d in "${dirs[@]}"; do
        d=$(eval echo "$d")
        [[ -d "$d" ]] || continue

        # direct match
        while IFS= read -r -d '' f; do
            found+=("$f")
        done < <(find "$d" -type f -name "$pattern" -print0 2>/dev/null)

        # fuzzy substring match
        while IFS= read -r -d '' f; do
            found+=("$f")
        done < <(find "$d" -type f -iname "*$pattern*" -print0 2>/dev/null)
    done

    # dedupe, preserve order
    readarray -t uniq < <(printf "%s\n" "${found[@]}" | awk '!seen[$0]++')

    {
        printf '{ "count": %d, "candidates": [' "${#uniq[@]}"
        local first=true
        for p in "${uniq[@]}"; do
            $first || printf ', '
            printf '"%s"' "$p"
            first=false
        done
        printf '] }\n'
    } >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"

