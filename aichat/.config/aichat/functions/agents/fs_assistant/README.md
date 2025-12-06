# fs_assistant

fs_assistant locates and safely edits config files. It reuses existing fs_* tools and web_search.
Use `aichat --agent fs_assistant` or `.agent fs_assistant` in REPL.

Key steps:
- guess_filename -> fuzzy_find -> read_file -> web_search -> prepare_kv_edit -> confirm_and_write

