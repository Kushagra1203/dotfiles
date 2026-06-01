import json
import os
import re
import time

# PATHS
INPUT_JSON = os.path.expanduser("~/.config/matugen/scripts/import.json")
OUTPUT_JSON = os.path.expanduser("~/matugen_bridge.json")
# Use current time as a version to force Stylus to see an "update"
NEW_VERSION = str(int(time.time()))

with open(INPUT_JSON, "r") as f:
    data = json.load(f)

print(f"🔗 Wiring {len(data)-1} styles to your local update server...")

for entry in data[1:]:
    style_slug = entry.get("usercssData", {}).get("namespace", "").split("/")[-1]
    if not style_slug:
        continue

    # 1. Point the internal source code to your local library
    if "sourceCode" in entry:
        old_lib = "https://userstyles.catppuccin.com/lib/lib.less"
        new_lib = "http://localhost:1919/lib/lib.less"
        entry["sourceCode"] = entry["sourceCode"].replace(old_lib, new_lib)

        # 2. Update the @updateURL inside the source code text
        # This tells Stylus WHERE to look when you click 'Check for updates'
        local_update_url = (
            f"http://localhost:1919/styles/{style_slug}/catppuccin.user.less"
        )
        entry["sourceCode"] = re.sub(
            r"@updateURL\s+\S+", f"@updateURL {local_update_url}", entry["sourceCode"]
        )

        # 3. Update the version inside the source code to force Stylus to notice
        entry["sourceCode"] = re.sub(
            r"@version\s+\S+", f"@version {NEW_VERSION}", entry["sourceCode"]
        )

    # 4. Update the Stylus metadata fields
    entry["updateUrl"] = local_update_url
    if "usercssData" in entry:
        entry["usercssData"]["updateURL"] = local_update_url
        entry["usercssData"]["version"] = NEW_VERSION

        # Force Mocha/Matugen settings
        if "vars" in entry["usercssData"]:
            v = entry["usercssData"]["vars"]
            if "lightFlavor" in v:
                v["lightFlavor"]["default"] = "mocha"
            if "darkFlavor" in v:
                v["darkFlavor"]["default"] = "mocha"

with open(OUTPUT_JSON, "w") as f:
    json.dump(data, f, indent=2)

print(f"✅ DONE! Import {OUTPUT_JSON} into Stylus ONCE.")
