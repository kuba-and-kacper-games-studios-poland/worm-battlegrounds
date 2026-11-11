"""Builds preview.html: every effect (make_classic.py's classic.json) and piece of music with a player, what it replaces
and where it plays, for review before anything is uploaded.
python -I make_preview.py <folder with make_classic.py's WB_*.wav> <folder with WB_Music_*.wav>"""

import base64
import html
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import json  # noqa: E402

# Where each plays, and what it replaces (the SoundsList name it takes over, or NEW)
WHERE = {
    "Turn_Yours": ("Your turn starts (with the callout banner)", "Turn_Yours"),
    "Turn_Start": ("Anyone else's turn starts", "Turn_Start (the 'ta-ra-ra-ram' fanfare)"),
    "Turn_Next": ("The turn before yours starts ('You're next!')", "Turn_Next"),
    "Turn_Tick": ("Your last 5 seconds, faster and higher at the end", "Turn_Tick"),
    "Turn_TimeUp": ("Your turn runs out without a shot", "NEW"),
    "Turn_Whoosh": ("Under the 'Your turn' banner sliding in", "Turn_Whoosh"),
    "Match_SuddenDeath": ("Sudden death begins", "Match_SuddenDeath"),
    "Match_Knockout": ("A blow knocks a snail out (with the camera punch-in)", "NEW"),
    "Match_WaterRise": ("The sea rises each sudden-death turn", "NEW"),
    "Fire_Bazooka": ("Bazooka fired", "Fire_Bazooka"),
    "Fire_HomingMissile": ("Homing missile fired", "Fire_HomingMissile"),
    "Fire_Throw": ("Grenade, cluster bomb, variety grenade, black hole grenade, spider bomb, spear thrown",
                   "Fire_Grenade, Fire_ClusterBomb, Fire_VarietyGrenade, Fire_BlackHoleGrenade, Fire_SpiderBomb, "
                   "Fire_SpartanSpear"),
    "Fire_Dynamite": ("Dynamite placed", "Fire_Dynamite"),
    "Fire_Shotgun": ("Shotgun fired", "Fire_Shotgun"),
    "Fire_Uzi": ("Uzi burst", "Fire_Uzi"),
    "Fire_Minigun": ("Minigun burst", "Fire_Minigun"),
    "Fire_BaseballBat": ("Baseball bat swing", "Fire_BaseballBat"),
    "Fire_OnePunch": ("One Punch", "Fire_OnePunch"),
    "Use_Heal": ("Bandage or medkit used", "Use_Bandage, Use_Medkit"),
    "Use_Potion": ("Speed or low-gravity potion drunk", "Use_SpeedPotion, Use_LowGravityPotion"),
    "Use_Parachute": ("Parachute opened", "Use_Parachute"),
    "Use_Jetpack": ("Jetpack put on", "Use_Jetpack"),
    "Explosion_Big": ("Big blasts (radius 6+)", "Explosion_Big"),
    "Explosion_Small": ("Smaller blasts", "Explosion_Small"),
    "Shot_Bounce": ("A thrown bomb bouncing", "Shot_Bounce"),
    "Shot_Whistle": ("A lobbed shot coming down", "Shot_Whistle (the community upload)"),
    "Button_Hover": ("Hovering any button", "Button_Hover"),
    "Button_Click": ("Pressing any button", "Button_Click"),
    "Button_Close": ("Closing a window", "Button_Click-CloseWidget"),
    "Window_Open": ("Opening the shop, crates, loadout and other windows", "NEW"),
    "Notification": ("A notification popping up", "Notification"),
    "Error": ("Something refused (not enough coins...)", "Error"),
    "Teleport_Out": ("The teleport card sliding over as a match starts", "NEW"),
    "Teleport_In": ("The card sliding off as the match appears", "NEW"),
    "Snail_Step": ("The active snail walking", "Snail_Step"),
    "Snail_Jump": ("A snail jumping", "Snail_Jump"),
    "Snail_Land": ("A snail landing", "Snail_Land"),
    "Snail_Jetpack": ("Jetpack flying (seamless loop)", "Snail_Jetpack"),
    "Snail_Hurt": ("A snail hurt", "Snail_Hurt"),
    "Snail_ShellBreak": ("A shell breaking under 50 health", "Snail_ShellBreak"),
    "Snail_KnockedOut": ("A snail knocked out by damage", "Snail_KnockedOut"),
    "Snail_Splash": ("A snail falling into the sea", "Snail_Splash"),
    "Snail_Burn": ("A snail falling into lava", "Snail_Burn"),
    "Snail_Ghost": ("The ghost rising after a knockout", "Snail_Ghost"),
    "Liquid_Obsidian": ("Lava turning water into obsidian", "NEW"),
}

MUSIC = [
    ("Lobby", "Lobby, 91 s loop at 84 BPM in G major, barely there: a meadow (a light breeze, birds, crickets, the "
              "grass moving) and the game's own four-bar tune, a call rising up G major and an answer coming home, "
              "on the harp, later the piano, then the harp again, its first notes on the chimes between, over a "
              "string chord breathing in. No drums", "BGM (the placeholder)"),
    ("Battle_PicnicPlains", "Picnic Plains, 74 s loop at 104 BPM in F Lydian: a sunny meadow, birds, crickets, "
                            "leaves and gusts of breeze. A soft shaker, a hand drum in the middle, a string chord now "
                            "and then; one instrument at a time (harp, piano, chimes, a far-off horn) plays a bit of "
                            "the tune, with bars of meadow between", "In-match music (none per map today)"),
    ("Battle_PicnicPlains_SuddenDeath", "Picnic Plains in sudden death, 132 BPM: the tune on the bright horn every 8 "
                                        "bars, the horn answering, over a full kit, snare rolls, crashes, running "
                                        "strings and bass, a choir pad; fewer birds, more wind", "NEW"),
    ("Battle_Desert", "Desert, 80 s loop at 96 BPM in D Phrygian dominant: hot wind and sand, the lava sea bubbling "
                      "and rumbling on the left, drips from the oasis on the right, cicadas. A slow camel walk on a "
                      "hand drum, a choir drone breathing in; one instrument at a time (guitar, harp, a low horn, "
                      "chimes) plays a bit of the snaky tune, with room between", "In-match music"),
    ("Battle_Desert_SuddenDeath", "Desert in sudden death, 124 BPM: the kit and a maqsum on the hand drums, an "
                                  "orchestra hit every 8 bars, running sweep bass, a low choir; the tune on the guitar, "
                                  "answered by the horn, the lava boiling louder", "NEW"),
    ("Battle_RockslideRidge", "Rockslide Ridge, 84 s loop at 92 BPM in A Dorian, half-time, kept as it was (your "
                              "pick): wind whistling round the rocks, stones tumbling off somewhere, a hawk. Low "
                              "drums, a choir and string pad, and a horn call in fourths that echoes off the "
                              "mountains", "In-match music"),
    ("Battle_RockslideRidge_SuddenDeath", "Rockslide Ridge in sudden death, 120 BPM: driving kick and toms, snare rolls, "
                                          "crashes and orchestra hits, strings and bass in sixteenths, the call on the "
                                          "bright horn every 4 bars, rockfalls three times as often", "NEW"),
    ("Win", "Victory sting, 6 s: a snare roll into a big brass chord with the orchestra hit (Great Strategy font)",
     "Match_Win"),
    ("Lose", "Defeat sting, 4.5 s: a sad trumpet sliding down, wobbling on its last note", "Match_Lose"),
]

GROUPS = [
    ("Turns and match", ["Turn_Yours", "Turn_Start", "Turn_Next", "Turn_Tick", "Turn_TimeUp", "Turn_Whoosh",
                         "Match_SuddenDeath", "Match_Knockout", "Match_WaterRise"]),
    ("Weapons", ["Fire_Bazooka", "Fire_HomingMissile", "Fire_Throw", "Fire_Dynamite", "Fire_Shotgun", "Fire_Uzi",
                 "Fire_Minigun", "Fire_BaseballBat", "Fire_OnePunch"]),
    ("Utilities", ["Use_Heal", "Use_Potion", "Use_Parachute", "Use_Jetpack"]),
    ("Blasts and shots", ["Explosion_Big", "Explosion_Small", "Shot_Bounce", "Shot_Whistle"]),
    ("Snails", ["Snail_Step", "Snail_Jump", "Snail_Land", "Snail_Jetpack", "Snail_Hurt", "Snail_ShellBreak",
                "Snail_KnockedOut", "Snail_Splash", "Snail_Burn", "Snail_Ghost"]),
    ("World", ["Liquid_Obsidian"]),
    ("Interface and teleports", ["Button_Hover", "Button_Click", "Button_Close", "Window_Open", "Notification", "Error",
                                 "Teleport_Out", "Teleport_In"]),
]

KINDS = {
    "CLASSIC": ("classic", "CLASSIC ROBLOX"),
    "BUILT": ("built", "MADE FROM CLASSIC"),
    "SCORED": ("scored", "GREAT STRATEGY"),
}

TODO = [
    ("After you approve", [
        "Classic sounds go straight into SoundsList by their Roblox ids (nothing to upload)",
        "Made-from-classic and Great Strategy sounds, and the music, are uploaded to the group and wired in",
        "Lobby music in the lobby; each map's loop in its match, crossfading into its sudden-death version",
        "New hooks: time up, knockout ding, water rise, obsidian hiss, window open, teleport out/in",
    ]),
    ("Credits", [
        "Great Strategy and StealthPilot soundfonts: NotRoblox (CC BY 3.0), from BadliZ's 'The Great Strategy' (2005)",
        "Classic sounds: Roblox's own 2009 uploads (public domain); OOF: Roblox's official 2025 upload",
    ]),
]


def player(wav, loop=False):
    """An audio player with the sound embedded as MP3 (every browser and webview plays it; OGG isn't everywhere)."""
    mp3 = os.path.splitext(wav)[0] + ".mp3"
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-codec:a", "libmp3lame", "-q:a", "4", mp3],
                   check=True)
    with open(mp3, "rb") as f:
        data = base64.b64encode(f.read()).decode()
    return f"<audio controls {'loop ' if loop else ''}preload='none' src='data:audio/mpeg;base64,{data}'></audio>"


# Sounds remade since the last preview (the owner's notes, 2026-11-10)
REMADE = {"Turn_Yours", "Turn_Start", "Lobby", "Battle_PicnicPlains", "Battle_PicnicPlains_SuddenDeath",
          "Battle_Desert", "Battle_Desert_SuddenDeath"}


def card(name, what, where, replaces, audio, kind=None, ref=None):
    tag = "new" if replaces == "NEW" else "swap"
    badge = f"<span class='{KINDS[kind][0]}'>{KINDS[kind][1]}</span>" if kind else ""
    if name in REMADE:
        badge = "<span class='remade'>REMADE</span>" + badge
    note = (f"<br><b>In game:</b> Roblox's own sound, <code>{html.escape(ref)}</code>, nothing to upload" if ref else "")
    return (f"<div class='card'><div class='top'><b>{name}</b><span class='tags'>{badge}<span class='{tag}'>"
            f"{'NEW' if tag == 'new' else 'REPLACES'}</span></span></div><p class='what'>{html.escape(what)}</p>"
            f"<p class='meta'>" + (f"<b>Plays:</b> {html.escape(where)}" if where else "")
            + ("" if tag == "new" else f"{'<br>' if where else ''}<b>Takes over:</b> {html.escape(replaces)}")
            + note + f"</p>{audio}</div>")


def main():
    folder = sys.argv[1]
    music = sys.argv[2] if len(sys.argv) > 2 else None
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "preview.html")
    rows = []
    with open(os.path.join(folder, "classic.json"), encoding="utf-8") as f:
        meta = json.load(f)
    if music:
        rows.append("<h2>Music</h2><p class='lead'>In the Worms Armageddon way: each level's track is its ambience "
                    "and a quiet song that sounds like the level, mixed as one. The songs are light now: a soft pulse, "
                    "a chord breathing in now and then, and one instrument at a time playing a bit of the level's "
                    "tune, with the level's sounds between; all on the classic Roblox samples (The Great Strategy and "
                    "Wind of Fjords). Sudden death keeps each level's key and tune, faster and driving. Rockslide "
                    "Ridge is kept as it was. Loops play on repeat here, so you can hear the seam (there shouldn't be "
                    "one).</p><div class='grid'>")
        for name, what, replaces in MUSIC:
            loop = not name in ("Win", "Lose")
            rows.append(card(name, what, "", replaces, player(os.path.join(music, f"WB_Music_{name}.wav"), loop)))
        rows.append("</div>")
    for title, names in GROUPS:
        rows.append(f"<h2>{html.escape(title)}</h2><div class='grid'>")
        for name in names:
            row = meta[name]
            where, replaces = WHERE[name]
            audio = player(os.path.join(folder, f"WB_{name}.wav"), row["loop"])
            rows.append(card(name, row["what"], where, replaces, audio, row["kind"], row["ref"]))
        rows.append("</div>")
    todo = "".join(f"<h3>{html.escape(t)}</h3><ul>" + "".join(f"<li>{i}</li>" for i in items) + "</ul>"
                   for t, items in TODO)
    page = f"""<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Snail Sound Preview</title><style>
:root{{--bg:#12131a;--card:#1c1e29;--ink:#eceef6;--dim:#9aa0b4;--acc:#ff8c14;--new:#3fb46a;--line:#2b2e3d}}
body{{margin:0;background:var(--bg);color:var(--ink);font:15px/1.45 system-ui,sans-serif}}
main{{max-width:1100px;margin:0 auto;padding:24px 16px 64px}}
h1{{margin:0 0 4px}} .lead{{color:var(--dim);margin:0 0 20px}}
h2{{margin:28px 0 10px;border-bottom:2px solid var(--acc);padding-bottom:4px}}
.grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:12px}}
.card{{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:12px}}
.top{{display:flex;justify-content:space-between;align-items:center;gap:8px}}
.top span{{font-size:11px;font-weight:700;padding:2px 7px;border-radius:99px}}
.swap{{background:#3a2a12;color:var(--acc)}} .new{{background:#173322;color:var(--new)}}
.tags{{display:flex;gap:4px}} .classic{{background:#1d2b45;color:#7fb2ff}} .built{{background:#2c2240;color:#c49bff}}
.scored{{background:#40301a;color:#ffcf6b}} .remade{{background:#3d1a2a;color:#ff7fb0}} code{{font-size:12px;color:var(--ink)}}
.what{{margin:8px 0 6px}} .meta{{color:var(--dim);font-size:13px;margin:0 0 8px}}
audio{{width:100%;height:36px}} ul{{color:var(--dim)}} h3{{margin:18px 0 6px}}
.box{{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:4px 16px 12px;margin-top:12px}}
</style></head><body><main>
<h1>Snail sound preview</h1>
<p class="lead">The classic 2005-2009 Roblox soundscape. <b>Remade</b> marks what changed since your last listen:
the two turn calls (military now) and every level track but Rockslide Ridge. Music plays on the classic Roblox tracker samples. Effects are <b>Classic Roblox</b> (Roblox's own 2009
sounds, played straight from their ids), <b>Made from classic</b> (layered or re-pitched from them) or <b>Great
Strategy</b> (scored on the music's instruments). Nothing is uploaded yet: tell me which to keep, change or redo.</p>
{''.join(rows)}
<h2>Still to make</h2><div class="box">{todo}</div>
</main></body></html>"""
    with open(out, "w", encoding="utf-8") as f:
        f.write(page)
    print(out, os.path.getsize(out) // 1024, "KB")


if __name__ == "__main__":
    main()
