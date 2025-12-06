#!/usr/bin/env bash
set -e

# @describe Guess possible filenames from natural language
# @option --description! Natural language like "my hyprlock config" or "admit card pdf"
# @env LLM_OUTPUT=/dev/stdout

main() {
    local desc="$argc_description"
    local lower=$(echo "$desc" | tr '[:upper:]' '[:lower:]')

    declare -a out=()

    # Known config mappings
    [[ "$lower" == *"hyprlock"* ]] && out+=("hyprlock.conf")
    [[ "$lower" == *"hyprland"* ]] && out+=("hyprland.conf")
    [[ "$lower" == *"kitty"* ]] && out+=("kitty.conf")
    [[ "$lower" == *"nvim"* || "$lower" == *"neovim"* ]] && out+=("init.lua" "init.vim")

    # Tokenize description into words
    read -ra TOKENS <<< "$lower"

    # Detect common extensions
    exts=("pdf" "png" "jpg" "jpeg" "txt" "json" "md" "conf")

    # Look for words that match known extensions
    for ext in "${exts[@]}"; do
        if grep -qw "$ext" <<< "$lower"; then
            # Combine all words before + extension
            base=$(echo "$lower" | sed "s/ *$ext//")
            base=$(echo "$base" | tr ' ' '_' | tr -cd '[:alnum:]_')
            out+=("${base}.${ext}")
        fi
    done

    # Direct word matches containing dots
    for tok in "${TOKENS[@]}"; do
        [[ "$tok" == *.* ]] && out+=("$tok")
    done

    # If no dot detected but extension-like token exists (e.g. "pdf")
    for ext in "${exts[@]}"; do
        if [[ "${TOKENS[-1]}" == "$ext" ]]; then
            prev="${TOKENS[-2]}"
            [[ -n "$prev" ]] && out+=("${prev}.${ext}")
        fi
    done

    # Absolute fallback — last token raw
    if [[ ${#out[@]} -eq 0 ]]; then
        out+=("${TOKENS[-1]}")
    fi

    # Remove empty entries + dedupe
    uniq=()
    for x in "${out[@]}"; do
        [[ -z "$x" ]] && continue
        [[ " ${uniq[*]} " == *" $x "* ]] && continue
        uniq+=("$x")
    done

    {
        printf '{ "candidates": ['
        local first=true
        for c in "${uniq[@]}"; do
            $first || printf ', '
            printf '"%s"' "$c"
            first=false
        done
        printf '] }\n'
    } >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"

