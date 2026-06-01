import json
import os
import re
import subprocess

# Paths
BASE_DIR = os.path.expanduser("~/userstyles")
IMPORT_JSON = os.path.expanduser("~/.config/matugen/scripts/import.json")
LIB_PATH = os.path.expanduser("~/userstyles/lib/lib.less")

# 1. Load Stylus data to get unique variables for each site
try:
    with open(IMPORT_JSON, "r") as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"❌ Error: Could not find {IMPORT_JSON}")
    exit(1)

# Map folder names (slugs) to their Stylus variables
styles_info = {
    s.get("usercssData", {})
    .get("namespace", "")
    .split("/")[-1]: s.get("usercssData", {})
    .get("vars", {})
    for s in data[1:]
}

# 2. Extract Matugen Hex Codes from lib.less
with open(LIB_PATH, "r") as f:
    lib_content = f.read()


def get_hex(name):
    m = re.search(f"@{name}:\\s*(#[a-fA-F0-9]{{6}})", lib_content)
    return m.group(1) if m else "#ffffff"


COLORS = [
    "base",
    "text",
    "mauve",
    "blue",
    "surface0",
    "mantle",
    "crust",
    "surface1",
    "surface2",
    "overlay0",
    "overlay1",
    "overlay2",
    "subtext0",
    "subtext1",
    "peach",
    "red",
    "sky",
    "sapphire",
    "teal",
    "green",
    "lavender",
    "pink",
    "flamingo",
    "rosewater",
    "yellow",
    "maroon",
]
COLOR_MAP = {k: get_hex(k) for k in COLORS}

print("🏗️  Mass Compiling 130+ styles...")

# 3. LOOP THROUGH EVERY FOLDER IN STYLES/
success_count = 0
styles_dir = os.path.join(BASE_DIR, "styles")

for style_slug in os.listdir(styles_dir):
    folder_path = os.path.join(styles_dir, style_slug)
    input_file = os.path.join(folder_path, "catppuccin.user.less")
    output_file = os.path.join(folder_path, "matugen.css")

    if not os.path.exists(input_file):
        continue

    # Prepare lessc command
    cmd = ["lessc"]

    # Inject Matugen Colors
    for name, hex_code in COLOR_MAP.items():
        cmd.append(f"--modify-var={name}={hex_code}")

    # Inject Site-Specific Vars (from import.json)
    if style_slug in styles_info:
        for var_name, var_info in styles_info[style_slug].items():
            if var_name in COLOR_MAP:
                continue

            # FORCE MOCHA DEFAULTS (The Secret Sauce)
            val = var_info.get("default", "0")
            if "Flavor" in var_name:
                val = "mocha"

            if isinstance(val, bool):
                val = "1" if val else "0"
            cmd.append(f"--modify-var={var_name}={val}")

    cmd.append(input_file)
    cmd.append(output_file)  # Compile directly to matugen.css

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode == 0:
        success_count += 1
        print(f" ✔ {style_slug}")
    else:
        # If a style fails (usually missing a plugin), we just skip it
        print(f" ✘ {style_slug} (Skipped)")

print(f"\n✨ DONE! Successfully baked {success_count} matugen.css files.")
