import json
import os
import re

# Paths
LIB_PATH = os.path.expanduser("~/userstyles/lib/lib.less")
JSON_PATH = os.path.expanduser("~/.config/matugen/scripts/import.json")
MASTER_FILE = os.path.expanduser("~/userstyles/matugen_final.user.css")

with open(LIB_PATH, "r") as f:
    lib_content = f.read()

with open(JSON_PATH, "r") as f:
    data = json.load(f)

# 1. Collect ALL unique variables from ALL styles
collected_vars = set()
for s in data[1:]:
    if "sourceCode" in s:
        # Find every @var line in the metadata
        vars_found = re.findall(r"@var\s+.+?\s+.+?\s+.+", s["sourceCode"])
        for v in vars_found:
            # We skip the common flavor/accent vars since we define them ourselves
            if not any(x in v for x in ["lightFlavor", "darkFlavor", "accentColor"]):
                collected_vars.add(v)

# 2. Build the Giant Metadata Header
var_block = "\n".join(sorted(list(collected_vars)))
header = f"""/* ==UserStyle==
@name Matugen Final
@namespace matugen
@version {os.path.getmtime(LIB_PATH)}
@preprocessor less
@var select lightFlavor "Light Flavor" ["latte:Latte", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha*"]
@var select darkFlavor "Dark Flavor" ["latte:Latte", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha*"]
@var select accentColor "Accent" ["rosewater:Rosewater", "flamingo:Flamingo", "pink:Pink", "mauve:Mauve*", "red:Red", "maroon:Maroon", "peach:Peach", "yellow:Yellow", "green:Green", "teal:Teal", "blue:Blue", "sapphire:Sapphire", "sky:Sky", "lavender:Lavender", "subtext0:Gray"]
{var_block}
==/UserStyle== */

"""

# 3. Assemble the file
with open(MASTER_FILE, "w") as f:
    f.write(header)
    f.write(lib_content)  # Your Matugen Hexes

    for s in data[1:]:
        if "sourceCode" in s:
            # Clean the code: remove metadata and imports
            clean = re.sub(
                r"/\* ==UserStyle==.*?==/UserStyle== \*/",
                "",
                s["sourceCode"],
                flags=re.DOTALL,
            )
            clean = re.sub(r"@import\s+.*?;", "", clean)
            f.write(f"\n/* --- {s.get('name')} --- */\n{clean}")

print(f"✅ Success! Master file generated: {MASTER_FILE}")
