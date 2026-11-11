"""Stand-in pictures for items that still use the placeholder, and snail portraits for the skins (draft only)."""

from make_icons import INK, svg


def glove():
    return svg(
        f'<g transform="rotate(-18 256 256)">'
        f'<rect x="150" y="330" width="170" height="110" rx="26" fill="#f3f5f8" stroke="{INK}" stroke-width="14"/>'
        f'<rect x="150" y="372" width="170" height="26" fill="#ff4d4d" stroke="{INK}" stroke-width="10"/>'
        f'<path d="M130 230 C120 120 210 70 300 84 C380 96 420 160 410 240 C404 300 370 340 310 344 H170 '
        f'C140 340 132 290 130 230 Z" fill="#ff3b3b" stroke="{INK}" stroke-width="16" stroke-linejoin="round"/>'
        f'<path d="M150 210 C130 170 160 120 200 140 C230 156 226 220 200 240" fill="#ff6a6a" stroke="{INK}" '
        f'stroke-width="12" stroke-linejoin="round"/>'
        f'<path d="M240 120 C300 104 360 128 380 170" fill="none" stroke="#ffb3b3" stroke-width="18" '
        f'stroke-linecap="round"/>'
        f'<path d="M230 300 C280 310 340 300 370 280" fill="none" stroke="#b81f1f" stroke-width="10" '
        f'stroke-linecap="round"/></g>')


def bat():
    return svg(
        f'<g transform="rotate(-42 256 256)">'
        f'<path d="M232 470 L222 300 C214 200 206 120 214 60 C220 30 292 30 298 60 C306 120 298 200 290 300 '
        f'L280 470 Z" fill="#e0a35a" stroke="{INK}" stroke-width="16" stroke-linejoin="round"/>'
        f'<path d="M236 70 C232 140 238 220 244 300" fill="none" stroke="#ffd79a" stroke-width="12" '
        f'stroke-linecap="round"/>'
        f'<rect x="222" y="380" width="68" height="76" fill="#3a3f4b" stroke="{INK}" stroke-width="12"/>'
        f'<path d="M226 396 H286 M226 414 H286 M226 432 H286" stroke="#5c6475" stroke-width="6"/>'
        f'<ellipse cx="256" cy="470" rx="40" ry="16" fill="#c98a45" stroke="{INK}" stroke-width="14"/></g>')


def parachute():
    return svg(
        f'<path d="M70 230 C70 110 170 50 256 50 C342 50 442 110 442 230 C410 210 380 210 350 230 C320 208 290 208 '
        f'256 230 C222 208 192 208 162 230 C132 210 102 210 70 230 Z" fill="#ff8a2a" stroke="{INK}" stroke-width="16" '
        f'stroke-linejoin="round"/>'
        f'<path d="M162 230 C170 140 210 70 256 50 C302 70 342 140 350 230 C320 208 290 208 256 230 C222 208 192 208 '
        f'162 230 Z" fill="#fff3e0" stroke="{INK}" stroke-width="10" stroke-linejoin="round"/>'
        f'<path d="M110 110 C150 76 200 62 240 60" fill="none" stroke="#ffc58f" stroke-width="12" '
        f'stroke-linecap="round"/>'
        f'<path d="M74 232 L222 380 M162 230 L232 380 M350 230 L280 380 M438 232 L290 380" stroke="{INK}" '
        f'stroke-width="7"/>'
        f'<rect x="206" y="372" width="100" height="84" rx="10" fill="#c98a45" stroke="{INK}" stroke-width="14"/>'
        f'<path d="M206 404 H306 M256 372 V456" stroke="{INK}" stroke-width="8"/>')


def snail(body, shell, spiral, acc="", face_extra="", eyes="normal"):
    """A front-facing snail portrait in the lobby snail's manner (two long feelers, big eyes), with an accessory."""
    eye = (f'<ellipse cx="216" cy="250" rx="30" ry="40" fill="#fff" stroke="{INK}" stroke-width="10"/>'
           f'<ellipse cx="296" cy="250" rx="30" ry="40" fill="#fff" stroke="{INK}" stroke-width="10"/>'
           f'<rect x="210" y="236" width="14" height="34" rx="7" fill="{INK}"/>'
           f'<rect x="290" y="236" width="14" height="34" rx="7" fill="{INK}"/>')
    if eyes == "led":
        eye = (f'<rect x="184" y="228" width="64" height="40" rx="8" fill="#16212e" stroke="{INK}" stroke-width="10"/>'
               f'<rect x="264" y="228" width="64" height="40" rx="8" fill="#16212e" stroke="{INK}" stroke-width="10"/>'
               f'<rect x="200" y="240" width="32" height="16" rx="6" fill="#5fffe0"/>'
               f'<rect x="280" y="240" width="32" height="16" rx="6" fill="#5fffe0"/>')
    if eyes == "skull":
        eye = (f'<ellipse cx="216" cy="250" rx="30" ry="36" fill="{INK}"/><ellipse cx="296" cy="250" rx="30" ry="36" '
               f'fill="{INK}"/><circle cx="222" cy="252" r="8" fill="#9dff8a"/><circle cx="290" cy="252" r="8" '
               f'fill="#9dff8a"/><path d="M246 300 L256 284 L266 300 Z" fill="{INK}"/>')
    return svg(
        f'<circle cx="360" cy="330" r="118" fill="{shell}" stroke="{INK}" stroke-width="16"/>'
        f'<path d="M360 330 m0 -18 a18 18 0 1 1 -18 18 a36 36 0 0 1 36 -36 a54 54 0 0 1 54 54 a72 72 0 0 1 -72 72" '
        f'fill="none" stroke="{spiral}" stroke-width="16" stroke-linecap="round"/>'
        f'<path d="M206 170 C196 120 180 80 150 52 M306 170 C318 120 334 80 364 52" fill="none" stroke="{INK}" '
        f'stroke-width="30" stroke-linecap="round"/>'
        f'<path d="M206 170 C196 120 180 80 150 52 M306 170 C318 120 334 80 364 52" fill="none" stroke="{body}" '
        f'stroke-width="14" stroke-linecap="round"/>'
        f'<circle cx="150" cy="52" r="20" fill="{body}" stroke="{INK}" stroke-width="10"/>'
        f'<circle cx="364" cy="52" r="20" fill="{body}" stroke="{INK}" stroke-width="10"/>'
        f'<path d="M150 470 C130 360 150 170 256 160 C362 170 382 360 362 470 Z" fill="{body}" stroke="{INK}" '
        f'stroke-width="16" stroke-linejoin="round"/>'
        f'<path d="M180 260 C182 214 204 186 236 178" fill="none" stroke="#fff" stroke-opacity="0.45" '
        f'stroke-width="14" stroke-linecap="round"/>'
        f'{eye}{face_extra}{acc}')


def _soldier():
    return snail("#9ccf6a", "#5d7a2b", "#3e521c", acc=(
        f'<path d="M150 214 C150 120 362 120 362 214 Z" fill="#5f7a2b" stroke="{INK}" stroke-width="14"/>'
        f'<rect x="136" y="204" width="240" height="26" rx="12" fill="#4b6222" stroke="{INK}" stroke-width="12"/>'
        f'<circle cx="220" cy="160" r="9" fill="#86a443"/><circle cx="290" cy="150" r="12" fill="#86a443"/>'))


def _pirate():
    return snail("#ffb88a", "#8b5a2b", "#5a3412", acc=(
        f'<path d="M156 210 C160 140 352 140 356 210 Z" fill="#e33b3b" stroke="{INK}" stroke-width="14"/>'
        f'<circle cx="200" cy="176" r="8" fill="#fff"/><circle cx="250" cy="166" r="8" fill="#fff"/>'
        f'<circle cx="300" cy="176" r="8" fill="#fff"/>'
        f'<path d="M350 200 L392 226 L360 240 Z" fill="#e33b3b" stroke="{INK}" stroke-width="10"/>'
        f'<ellipse cx="296" cy="252" rx="34" ry="40" fill="{INK}"/>'
        f'<path d="M180 204 L330 250" stroke="{INK}" stroke-width="8"/>'))


def _cowboy():
    return snail("#ffd27a", "#c98a45", "#7a4a1a", acc=(
        f'<ellipse cx="256" cy="186" rx="170" ry="30" fill="#a8672a" stroke="{INK}" stroke-width="14"/>'
        f'<path d="M180 184 C176 110 200 90 230 104 C246 112 266 112 282 104 C312 90 336 110 332 184 Z" '
        f'fill="#c07a34" stroke="{INK}" stroke-width="14" stroke-linejoin="round"/>'
        f'<rect x="182" y="160" width="148" height="18" fill="#5a3412"/>'))


def _ninja():
    tails = "M356 190 C392 196 416 222 430 250 M356 196 C384 214 396 246 398 276"
    return snail("#3a3f4b", "#2a2e38", "#ff4d4d", face_extra=(
        f'<rect x="166" y="222" width="180" height="58" rx="18" fill="#f0c9a0" stroke="{INK}" stroke-width="10"/>'
        f'<ellipse cx="216" cy="250" rx="22" ry="20" fill="#fff" stroke="{INK}" stroke-width="8"/>'
        f'<ellipse cx="296" cy="250" rx="22" ry="20" fill="#fff" stroke="{INK}" stroke-width="8"/>'
        f'<rect x="210" y="240" width="12" height="20" rx="6" fill="{INK}"/>'
        f'<rect x="290" y="240" width="12" height="20" rx="6" fill="{INK}"/>'), acc=(
        f'<rect x="150" y="176" width="212" height="30" rx="10" fill="#ff4d4d" stroke="{INK}" stroke-width="12"/>'
        f'<path d="{tails}" fill="none" stroke="{INK}" stroke-width="24" stroke-linecap="round"/>'
        f'<path d="{tails}" fill="none" stroke="#ff4d4d" stroke-width="12" stroke-linecap="round"/>'))


def _knight():
    return snail("#c9d2de", "#7a8597", "#4a5466", acc=(
        f'<path d="M160 290 C150 160 362 160 352 290 Z" fill="#aab4c3" stroke="{INK}" stroke-width="14"/>'
        f'<rect x="176" y="236" width="160" height="16" rx="6" fill="{INK}"/>'
        f'<path d="M206 270 H306 M206 284 H306" stroke="#7a8597" stroke-width="6"/>'
        f'<path d="M256 150 C250 100 290 70 330 84 C300 96 290 120 290 152 Z" fill="#e33b3b" stroke="{INK}" '
        f'stroke-width="10"/>'))


def _clown():
    wig = "".join(f'<circle cx="{x}" cy="{y}" r="34" fill="{c}" stroke="{INK}" stroke-width="10"/>' for x, y, c in (
        (176, 184, "#ff5fd2"), (226, 160, "#ffd84d"), (286, 160, "#7ac8ff"), (336, 184, "#8be36a")))
    return snail("#fff3f3", "#7ac8ff", "#ff5fd2", face_extra=(
        f'<circle cx="256" cy="304" r="22" fill="#ff3b3b" stroke="{INK}" stroke-width="10"/>'
        f'<path d="M210 340 Q256 370 302 340" fill="none" stroke="#ff3b3b" stroke-width="12" stroke-linecap="round"/>'),
        acc=wig)


def _robot():
    return snail("#b8c3d1", "#6c7686", "#3ee0ff", eyes="led", acc=(
        f'<rect x="196" y="320" width="120" height="40" rx="10" fill="#8e98a8" stroke="{INK}" stroke-width="10"/>'
        f'<path d="M216 340 H296" stroke="#3ee0ff" stroke-width="8" stroke-dasharray="12 8"/>'))


def _devil():
    return snail("#ff4747", "#7a1020", "#ffb02e", acc=(
        f'<path d="M180 190 C160 160 150 120 166 88 C186 120 206 140 220 168 Z" fill="#ffd24a" stroke="{INK}" '
        f'stroke-width="12" stroke-linejoin="round"/>'
        f'<path d="M332 190 C352 160 362 120 346 88 C326 120 306 140 292 168 Z" fill="#ffd24a" stroke="{INK}" '
        f'stroke-width="12" stroke-linejoin="round"/>'
        f'<path d="M190 214 L240 232 M322 214 L272 232" stroke="{INK}" stroke-width="12" stroke-linecap="round"/>'))


def _skeleton():
    return snail("#f2efe6", "#2a2a30", "#e8e4d8", eyes="skull", acc=(
        f'<path d="M200 330 H312 M216 318 V344 M240 318 V344 M264 318 V344 M288 318 V344" stroke="{INK}" '
        f'stroke-width="8" stroke-linecap="round"/>'))


STANDINS = {"Item_OnePunch": glove, "Item_BaseballBat": bat, "Item_Parachute": parachute,
            "Skin_Soldier": _soldier, "Skin_Pirate": _pirate, "Skin_Cowboy": _cowboy, "Skin_Ninja": _ninja,
            "Skin_Knight": _knight, "Skin_Clown": _clown, "Skin_Robot": _robot, "Skin_Devil": _devil,
            "Skin_Skeleton": _skeleton}
