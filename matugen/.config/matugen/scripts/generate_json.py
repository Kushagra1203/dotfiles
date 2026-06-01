import json
import os
import re

# Paths
STYLES_DIR = os.path.expanduser("~/userstyles/styles")
OUTPUT_JSON = os.path.expanduser("~/userstyles/theme_map.json")

theme_map = {}

print("🔨 Compiling Matugen CSS into a Theme Map...")

for root, dirs, files in os.walk(STYLES_DIR):
    if "matugen.css" in files:
        domain = os.path.basename(root)
        file_path = os.path.join(root, "matugen.css")

        with open(file_path, "r") as f:
            content = f.read()

            # 1. Remove the UserStyle metadata block
            content = re.sub(
                r"/\* ==UserStyle==.*?==/UserStyle== \*/", "", content, flags=re.DOTALL
            )

            # 2. THE FIX: Remove the @-moz-document wrapper
            # Find everything inside the FIRST { and before the LAST }
            match = re.search(r"^[^{]*\{(.*)\}[^}]*$", content, re.DOTALL)
            if match:
                clean_css = match.group(1).strip()
            else:
                # If no wrapper found, just use the content as is
                clean_css = content.strip()

            theme_map[domain] = clean_css

with open(OUTPUT_JSON, "w") as f:
    json.dump(theme_map, f, indent=4)

print(f"✅ Created {OUTPUT_JSON} with {len(theme_map)} themes.")
