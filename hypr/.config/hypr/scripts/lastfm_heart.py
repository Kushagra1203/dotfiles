import pylast
import subprocess
import os

# CONFIGURATION
API_KEY = "def80942b2c7de34d9145810034222f2"
API_SECRET = "8dfba13c97a8d5c43c3452d01a05942c"
USERNAME = "StupidMe_12"
SESSION_KEY_FILE = os.path.expanduser("~/.config/rescrobbled/session")

def get_network():
    if os.path.exists(SESSION_KEY_FILE):
        with open(SESSION_KEY_FILE, "r") as f:
            sk = f.read().strip()
        return pylast.LastFMNetwork(api_key=API_KEY, api_secret=API_SECRET, session_key=sk)
    raise Exception("Session key not found. Run rescrobbled once to login.")

def get_metadata():
    try:
        raw_list = subprocess.check_output(["playerctl", "-l"]).decode().strip()
        if not raw_list:
            raise Exception("No players found.")
        all_players = raw_list.split('\n')
    except subprocess.CalledProcessError:
        raise Exception("Playerctl failed.")

    ignored = ["firefox", "zen", "chromium", "browser"]
    for player in all_players:
        if any(x in player.lower() for x in ignored):
            continue
        try:
            status = subprocess.check_output(["playerctl", "-p", player, "status"]).decode().strip()
            if status == "Playing":
                title = subprocess.check_output(["playerctl", "-p", player, "metadata", "title"]).decode().strip()
                artist = subprocess.check_output(["playerctl", "-p", player, "metadata", "artist"]).decode().strip()
                return title, artist
        except:
            continue
    raise Exception("No active music found.")

try:
    title, artist = get_metadata()
    network = get_network()
    track = network.get_track(artist, title)
    track.love()

    # Success Notification: 
    # 1. Removed manual <b> tags
    # 2. Added hint to replace/update the same notification bubble
    subprocess.run([
        "notify-send", 
        "-a", "Last.fm", 
        "-i", "emblem-favorite",
        "-h", "string:x-canonical-private-synchronous:lastfm-love", 
        "Loved on Last.fm", 
        f"{title}\nby {artist}"
    ])

except Exception as e:
    subprocess.run([
        "notify-send", 
        "-a", "Last.fm Error", 
        "-h", "string:x-canonical-private-synchronous:lastfm-love", 
        "Heart Error", 
        str(e)
    ])
