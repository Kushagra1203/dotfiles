#!/usr/bin/env bash
set -e

# @describe Create diff for key=value change (no write)
# @option --path! File path
# @option --key! Config key
# @option --value! New value
# @env LLM_OUTPUT=/dev/stdout

main() {
    if [[ ! -f "$argc_path" ]]; then
        echo '{ "error": "NotFound" }' >> "$LLM_OUTPUT"
        exit 0
    fi

    old="$(cat "$argc_path")"

    if grep -qE "^[[:space:]]*$argc_key[[:space:]]*=" "$argc_path"; then
        new="$(sed -E "s|^([[:space:]]*$argc_key[[:space:]]*=).*|\1 $argc_value|" "$argc_path")"
    else
        new="$old"$'\n'"$argc_key = $argc_value"
    fi

    diff=$(diff -u --label "${argc_path}.before" --label "${argc_path}.after" <(printf "%s" "$old") <(printf "%s" "$new") || true)

    {
        printf '{ "error": null, "new_content": %s, "diff": %s }\n' \
            "$(printf "%s" "$new" | jq -Rs .)" \
            "$(printf "%s" "$diff" | jq -Rs .)"
    } >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"

