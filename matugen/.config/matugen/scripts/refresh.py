import os
import re
import time

# Path to your local catppuccin styles
STYLES_DIR = os.path.expanduser("~/userstyles/styles")
# A unique number that always goes up (current time)
NEW_VERSION = str(int(time.time()))

print(f"🔄 Bumping all styles to version: {NEW_VERSION}")

for root, dirs, files in os.walk(STYLES_DIR):
    for file in files:
        if file == "catppuccin.user.less":
            path = os.path.join(root, file)

            with open(path, "r") as f:
                content = f.read()

            # 1. Update the Version
            content = re.sub(r"@version\s+\d+", f"@version {NEW_VERSION}", content)

            # 2. Ensure Update URL is local (just in case)
            style_name = os.path.basename(root)
            local_url = (
                f"http://localhost:1919/styles/{style_name}/catppuccin.user.less"
            )
            content = re.sub(r"@updateURL\s+\S+", f"@updateURL {local_url}", content)

            with open(path, "w") as f:
                f.write(content)

print("✅ Files updated. Now click 'Check for updates' in Stylus.")
