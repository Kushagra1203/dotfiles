import http.server
import json
import os
import re
import socketserver
import subprocess

PORT = 1919
BASE_DIR = os.path.expanduser("~/userstyles")
IMPORT_JSON = os.path.expanduser("~/.config/matugen/scripts/import.json")
LIB_PATH = os.path.expanduser("~/userstyles/lib/lib.less")
STYLES_DIR = os.path.expanduser("~/userstyles/styles")

cache = {}

try:
    with open(IMPORT_JSON, "r") as f:
        data = json.load(f)
    styles_info = {
        s.get("usercssData", {})
        .get("namespace", "")
        .split("/")[-1]: s.get("usercssData", {})
        .get("vars", {})
        for s in data[1:]
    }
except:
    styles_info = {}


class SmartHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/list-sites":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            sites = [
                d
                for d in os.listdir(STYLES_DIR)
                if os.path.isdir(os.path.join(STYLES_DIR, d))
            ]
            self.wfile.write(json.dumps(sites).encode())
            return

        if "/get-style" in self.path:
            site = re.search(r"site=([^&]+)", self.path).group(1)
            input_file = os.path.join(STYLES_DIR, site, "catppuccin.user.less")

            if not os.path.exists(input_file):
                self.send_error(404)
                return

            curr_time = os.path.getmtime(LIB_PATH)
            if site in cache and cache[site]["time"] == curr_time:
                css_output = cache[site]["css"]
            else:
                try:
                    with open(LIB_PATH, "r") as f:
                        lib_text = f.read()
                    colors = [
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

                    cmd = ["lessc"]
                    for c in colors:
                        # m = re.search(f"@{c}:\\s*(#[a-fA-F0-9]{{6}})", lib_text)
                        m = re.search(f"@{c}\\s*:\\s*(#[a-fA-F0-9]{{6}})", lib_text)
                        hex_val = m.group(1) if m else "#ffffff"
                        cmd.append(f"--modify-var={c}={hex_val}")

                    if site in styles_info:
                        for v_name, v_info in styles_info[site].items():
                            val = v_info.get("default", "0")
                            if "Flavor" in v_name:
                                val = "mocha"
                            if isinstance(val, bool):
                                val = "1" if val else "0"
                            cmd.append(f"--modify-var={v_name}={val}")

                    cmd.append(input_file)
                    result = subprocess.run(cmd, capture_output=True, text=True)

                    if result.returncode == 0:
                        css_output = (
                            re.sub(r"^[^{]*\{", "", result.stdout, count=1)
                            .strip()
                            .rstrip("}")
                        )
                        cache[site] = {"css": css_output, "time": curr_time}
                    else:
                        self.send_error(500)
                        return
                except:
                    self.send_error(500)
                    return

            self.send_response(200)
            self.send_header("Content-type", "text/css")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("X-Wallpaper-Time", str(int(curr_time)))
            self.end_headers()
            self.wfile.write(css_output.encode())

    # This keeps the server completely quiet
    def log_message(self, format, *args):
        return


class ReuseServer(socketserver.TCPServer):
    allow_reuse_address = True


# Removed the start message for a truly silent background process
with ReuseServer(("127.0.0.1", PORT), SmartHandler) as httpd:
    httpd.serve_forever()
