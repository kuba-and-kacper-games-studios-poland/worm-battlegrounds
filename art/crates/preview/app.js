/* Crate opening preview: the GACHA screen, the reel and the reveals, drawn in the game's 1920 x 1080 units. */
(() => {
  const A = window.ASSETS;
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const wait = (ms) => new Promise((r) => setTimeout(r, ms));
  const rnd = FX.rnd, pick = FX.pick;
  const TAU = Math.PI * 2;
  const stage = $("#stage");

  // ------------------------------------------------------------------------------------------------- easing and tweens
  function bezier(x1, y1, x2, y2) {
    const cx = 3 * x1, bx = 3 * (x2 - x1) - cx, ax = 1 - cx - bx;
    const cy = 3 * y1, by = 3 * (y2 - y1) - cy, ay = 1 - cy - by;
    const sx = (t) => ((ax * t + bx) * t + cx) * t, sy = (t) => ((ay * t + by) * t + cy) * t;
    return (x) => {
      if (x <= 0) return 0;
      if (x >= 1) return 1;
      let lo = 0, hi = 1, t = x;
      for (let i = 0; i < 40; i++) { const v = sx(t); if (Math.abs(v - x) < 1e-6) break; if (v < x) lo = t; else hi = t; t = (lo + hi) / 2; }
      return sy(t);
    };
  }
  const easeRoll = bezier(0.075, 0.82, 0.165, 1); // CS2's reel curve (easeOutCirc)
  const easeOut3 = (t) => 1 - Math.pow(1 - t, 3);
  const easeInOut3 = (t) => (t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2);
  const tween = (ms, fn, ease = (t) => t) => new Promise((res) => {
    const t0 = performance.now();
    const f = (now) => { const t = Math.min(1, (now - t0) / ms); fn(ease(t), t); if (t < 1) requestAnimationFrame(f); else res(); };
    requestAnimationFrame(f);
  });
  const anim = (el, kf, o) => el.animate(kf, { fill: "forwards", ...o });

  // ------------------------------------------------------------------------------------------------------------ sound
  const Sound = (() => {
    let ctx = null, master = null, loading = null, vol = 0.8, muted = false;
    const buffers = {};
    const toBuf = (uri) => { const b = atob(uri.split(",")[1]); const a = new Uint8Array(b.length); for (let i = 0; i < b.length; i++) a[i] = b.charCodeAt(i); return a.buffer; };
    function init() {
      if (loading) return loading;
      const AC = window.AudioContext || window.webkitAudioContext;
      if (!AC) return (loading = Promise.resolve());
      ctx = new AC();
      master = ctx.createGain();
      master.gain.value = muted ? 0 : vol;
      master.connect(ctx.destination);
      loading = Promise.all(Object.entries(A.snd).map(([k, uri]) => new Promise((res) => {
        try { ctx.decodeAudioData(toBuf(uri), (b) => { buffers[k] = b; res(); }, () => res()); } catch (e) { res(); }
      })));
      return loading;
    }
    function play(name, o = {}) {
      if (!ctx || !buffers[name]) return null;
      if (ctx.state === "suspended") ctx.resume();
      const s = ctx.createBufferSource();
      s.buffer = buffers[name];
      s.playbackRate.value = o.rate || 1;
      const g = ctx.createGain();
      g.gain.value = o.vol ?? 1;
      s.connect(g); g.connect(master);
      s.start(ctx.currentTime + (o.delay || 0));
      return { stop(ms = 150) { try { g.gain.setTargetAtTime(0, ctx.currentTime, ms / 3000); s.stop(ctx.currentTime + ms / 1000 + 0.05); } catch (e) { /* already stopped */ } } };
    }
    const apply = () => { if (master) master.gain.value = muted ? 0 : vol; };
    return { init, play, setVol(v) { vol = v; apply(); }, setMuted(m) { muted = m; apply(); }, get time() { return ctx ? ctx.currentTime : 0; } };
  })();
  const unlockAudio = () => Sound.init();
  window.addEventListener("pointerdown", unlockAudio, { once: true, capture: true });
  window.addEventListener("keydown", unlockAudio, { once: true, capture: true });

  // ------------------------------------------------------------------------------------------------------------- data
  const R = {
    Common: { c: "#c8c8d2", g: ["#e3e3e8", "#b0b0b9"], mask: "rt_mask_common", rank: 0 },
    Uncommon: { c: "#5adc6e", g: ["#acedb6", "#4fc261"], mask: "rt_mask_uncommon", rank: 1 },
    Rare: { c: "#4da0ff", g: ["#a6cfff", "#448de0"], mask: "rt_mask_common", rank: 2 },
    Epic: { c: "#be5aff", g: ["#deacff", "#a74fe0"], mask: "rt_mask_epic", rank: 3 },
    Legendary: { c: "#ffc828", g: ["#ffe393", "#e0b023"], mask: "rt_mask_legendary", rank: 4 },
  };
  const RANKED = ["Legendary", "Epic", "Rare", "Uncommon", "Common"];
  const it = (name, r, pic, extra = {}) => ({ name, r, pic, ...extra });
  const ITEMS = {
    Grenade: it("Grenade", "Common", "item_Grenade"), Shotgun: it("Shotgun", "Common", "item_Shotgun"),
    Uzi: it("Uzi", "Uncommon", "item_Uzi"), BaseballBat: it("Baseball bat", "Uncommon", "svg:Item_BaseballBat", { stand: true }),
    Dynamite: it("Dynamite", "Uncommon", "item_Dynamite"), SpartanSpear: it("Spartan spear", "Uncommon", "item_SpartanSpear"),
    ClusterBomb: it("Cluster bomb", "Rare", "item_ClusterBomb"), SpiderBomb: it("Spider bomb", "Rare", "item_SpiderBomb"),
    Minigun: it("Minigun", "Rare", "item_Minigun"), HomingMissile: it("Homing missile", "Epic", "item_HomingMissile"),
    OnePunch: it("One Punch", "Epic", "svg:Item_OnePunch", { stand: true }),
    VarietyGrenade: it("Variety grenade", "Legendary", "item_VarietyGrenade", { special: "variety" }),
    BlackHoleGrenade: it("Black hole grenade", "Legendary", "item_BlackHoleGrenade", { special: "blackhole" }),
    Parachute: it("Parachute", "Uncommon", "svg:Item_Parachute", { stand: true }), Bandage: it("Bandage", "Uncommon", "item_Bandage"),
    Jetpack: it("Jetpack", "Rare", "item_Jetpack"), SpeedPotion: it("Speed potion", "Rare", "item_SpeedPotion"),
    Medkit: it("Medkit", "Epic", "item_Medkit"),
    LowGravityPotion: it("Low gravity potion", "Legendary", "item_SpeedPotion", { hue: true, special: "lowgravity", stand: true }),
    Skin_Soldier: it("Soldier", "Uncommon", "svg:Skin_Soldier", { stand: true }), Skin_Pirate: it("Pirate", "Uncommon", "svg:Skin_Pirate", { stand: true }),
    Skin_Cowboy: it("Cowboy", "Uncommon", "svg:Skin_Cowboy", { stand: true }), Skin_Ninja: it("Ninja", "Rare", "svg:Skin_Ninja", { stand: true }),
    Skin_Knight: it("Knight", "Rare", "svg:Skin_Knight", { stand: true }), Skin_Clown: it("Clown", "Rare", "svg:Skin_Clown", { stand: true }),
    Skin_Robot: it("Robot", "Epic", "svg:Skin_Robot", { stand: true }), Skin_Devil: it("Devil", "Epic", "svg:Skin_Devil", { stand: true }),
    Skin_Skeleton: it("Skeleton", "Legendary", "svg:Skin_Skeleton", { special: "skeleton", stand: true }),
  };
  const picOf = (item) => (item.pic.startsWith("svg:") ? A.svg[item.pic.slice(4)] : A.img[item.pic]);

  // The crates' rows (Data/Crates/*.lua) with each one's theme
  const CRATES = {
    Weapon: {
      name: "Weapon crate", tab: "Weapons", icon: "Crate_Weapon", g1: "#ffb347", g2: "#ff7a1a", amb: "embers", tier: "Standard",
      prices: { Coins: [100, 300, 900] },
      odds: { Coins: { Uzi: 14.75, BaseballBat: 14.75, Dynamite: 14.75, SpartanSpear: 14.75, ClusterBomb: 10, SpiderBomb: 10, Minigun: 10, HomingMissile: 5, OnePunch: 5, VarietyGrenade: 0.5, BlackHoleGrenade: 0.5 } },
    },
    Premium: {
      name: "Premium crate", tab: "Premium", icon: "Crate_Premium", g1: "#5ce1ff", g2: "#ffd24a", amb: "glints", tier: "Premium", premium: true,
      prices: { Diamonds: [250, 750, 2250] },
      odds: { Diamonds: { ClusterBomb: 26, SpiderBomb: 26, Minigun: 26, HomingMissile: 10, OnePunch: 10, VarietyGrenade: 1, BlackHoleGrenade: 1 } },
    },
    Utility: {
      name: "Utility crate", tab: "Utility", icon: "Crate_Utility", g1: "#3ff0c0", g2: "#18b49a", amb: "bubbles", tier: "Standard",
      prices: { Coins: [100, 300, 900], Diamonds: [200, 600, 1800] },
      odds: {
        Coins: { Parachute: 27.5, Bandage: 27.5, Jetpack: 15, SpeedPotion: 15, Medkit: 10, LowGravityPotion: 5 },
        Diamonds: { Parachute: 15, Bandage: 15, Jetpack: 20, SpeedPotion: 20, Medkit: 20, LowGravityPotion: 10 },
      },
    },
    Skin: {
      name: "Skin crate", tab: "Skins", icon: "Crate_Skin", g1: "#ff6ad5", g2: "#b04dff", amb: "sparkles", tier: "Standard",
      prices: { Coins: [100, 300, 900], Diamonds: [50, 150, 450] },
      odds: {
        Coins: { Skin_Soldier: 20, Skin_Pirate: 20, Skin_Cowboy: 20, Skin_Ninja: 10, Skin_Knight: 10, Skin_Clown: 10, Skin_Robot: 2, Skin_Devil: 7, Skin_Skeleton: 1 },
        Diamonds: { Skin_Soldier: 20, Skin_Pirate: 20, Skin_Cowboy: 20, Skin_Ninja: 10, Skin_Knight: 10, Skin_Clown: 10, Skin_Robot: 2, Skin_Devil: 7, Skin_Skeleton: 1 },
      },
    },
  };
  const ORDER = ["Weapon", "Premium", "Utility", "Skin"];
  const COUNTS = [1, 3, 10];
  const SHINY_COPIES = 10;

  const state = {
    crate: "Weapon", pay: "Coins", quick: false, force: "random",
    bal: { Coins: 5000, Diamonds: 5000 }, copies: { Uzi: 3, Minigun: 9, Skin_Pirate: 2 }, busy: false,
  };

  // --------------------------------------------------------------------------------------------- picture-layer styles
  (() => {
    const css = [];
    for (const [k, uri] of Object.entries(A.img)) css.push(`.i-${k}{background-image:url(${uri})}.m-${k}{-webkit-mask-image:url(${uri});mask-image:url(${uri})}`);
    css.push(".mk{-webkit-mask-size:100% 100%;mask-size:100% 100%;-webkit-mask-repeat:no-repeat;mask-repeat:no-repeat}");
    css.push(`#stage{--tabmask:url(${A.img.tab_main});--btnmask:url(${A.img.btn_main})}`);
    const s = document.createElement("style");
    s.textContent = css.join("\n");
    document.head.appendChild(s);
  })();
  const L = (img, x, y, w, h, tint) =>
    `<i class="ly i-${img}${tint ? ` m-${img} tn` : ""}" style="left:${x * 100}%;top:${y * 100}%;width:${w * 100}%;height:${h * 100}%;${tint ? `--t:${tint}` : ""}"></i>`;
  const DARK = "#191923";
  const STAR_SVG = '<svg viewBox="0 0 100 100" style="width:62%;height:100%"><path d="M50 6 L62 37 L95 38 L69 58 L78 91 L50 72 L22 91 L31 58 L5 38 L38 37 Z" fill="#ffd84a" stroke="#14141c" stroke-width="7" stroke-linejoin="round"/><path d="M50 18 L58 40 L44 42 Z" fill="#fff7c2"/></svg>';

  function cardHTML(id, o = {}) {
    const item = ITEMS[id];
    const col = o.gold ? R.Legendary.c : R[item.r].c;
    const w = o.w || 162, h = o.h || 145;
    return `<div class="card ${o.kind || ""} ${o.gold ? "gold" : ""}" data-id="${id}" style="--rc:${col};--s:${(w / 162).toFixed(3)};width:${w}px;height:${h}px;${o.style || ""}">
      ${L("card_stroke2", -0.0058, -0.0385, 1.0116, 1.0769, DARK)}${L("card_main", 0, 0, 1, 1, DARK)}
      <i class="ly m-card_main mk glow" style="left:0;top:0;width:100%;height:100%"></i>
      ${L("card_stroke", 0.0058, -0.0231, 0.9883, 1.0461, col)}
      ${o.gold ? `<div class="star">${STAR_SVG}</div>` : `<img class="icon${item.hue ? " hue-purple" : ""}" src="${picOf(item)}" alt="">`}
      ${o.noName ? "" : `<b class="name gt">${o.gold ? "???" : item.name}</b>`}
      ${o.chance != null ? `<b class="chance gt">${o.chance}%</b>` : ""}
    </div>`;
  }

  function rarityTitleHTML(r, w, txt) {
    const h = w / 10.3771;
    return `<div class="rtitle" style="width:${w}px;height:${h}px">
      ${L("rt_stroke2", -0.002, -0.1042, 1.0041, 1.2083, DARK)}${L("rt_main", 0, 0, 1, 1, DARK)}
      ${L("rt_stroke", 0.002, -0.0625, 0.996, 1.125, R[r].c)}${L(R[r].mask, 0, 0, 1, 1)}
      <div class="txt gg" style="font-size:${h * 0.72}px;background-image:linear-gradient(${R[r].g[0]},${R[r].g[1]})">${(txt || r).toUpperCase()}</div>
    </div>`;
  }

  function buyBoxHTML(count, cur) {
    const dia = cur === "Diamonds";
    const main = dia ? "#56b8ff" : "#5adc6e";
    const stroke = dia ? "#ffd24a" : "#4dc761";
    const mask = count === 1 ? "btn_mask1" : count === 3 ? "btn_mask3" : "btn_mask10";
    return `<div class="box">${L("btn_stroke2", 0, 0, 1.0033, 1, DARK)}${L("btn_main", 0.0015, 0.0556, 0.997, 0.8889, main)}
      ${L("btn_stroke", 0.0066, 0.0222, 0.9867, 0.9556, stroke)}${L(mask, 0.0067, 0.0222, 0.9867, 0.9556)}</div>`;
  }

  function darkBtnHTML(txt, w = 300, h = 96, strokeCol = "#828282") {
    return `<div class="darkbtn" style="width:${w}px;height:${h}px">${L("chip_stroke2", 0, 0, 1, 1, DARK)}${L("chip_main", 0.0034, 0.061, 0.9931, 0.878, DARK)}
      ${L("chip_stroke", 0.0068, 0.0244, 0.9865, 0.9512, strokeCol)}<div class="txt gt">${txt}</div></div>`;
  }

  // ----------------------------------------------------------------------------------------------- the screen's scale
  const wrap = $("#stageWrap");
  let scale = 1;
  const fit = () => { scale = wrap.clientWidth / 1920; stage.style.transform = `scale(${scale})`; };
  new ResizeObserver(fit).observe(wrap);
  fit();
  const stageRect = (el) => {
    const s = stage.getBoundingClientRect(), r = el.getBoundingClientRect();
    return { x: (r.left - s.left) / scale, y: (r.top - s.top) / scale, w: r.width / scale, h: r.height / scale };
  };

  // ------------------------------------------------------------------------------- the lobby behind it, blurred out
  (() => {
    const c = $("#bg"), x = c.getContext("2d"), W = c.width, H = c.height;
    let g = x.createLinearGradient(0, 0, 0, H * 0.5);
    g.addColorStop(0, "#3b8fe8"); g.addColorStop(1, "#b6e2ff");
    x.fillStyle = g; x.fillRect(0, 0, W, H);
    x.fillStyle = "#ffffff";
    for (const [cx, cy, s] of [[150, 70, 1.2], [420, 40, 0.9], [700, 90, 1.4], [880, 30, 0.8], [60, 160, 0.7]]) {
      for (let i = 0; i < 5; i++) x.fillRect(cx + i * 22 * s - 40 * s, cy - (i % 2) * 12 * s, 60 * s, 34 * s);
    }
    x.fillStyle = "#3aa647"; x.fillRect(0, H * 0.4, W, H * 0.16);
    x.fillStyle = "#4fc25c"; x.fillRect(0, H * 0.4, W, 8);
    const tree = (tx, ty, s) => {
      x.fillStyle = "#7a4b25"; x.fillRect(tx - 7 * s, ty - 60 * s, 14 * s, 70 * s);
      x.fillStyle = "#2e9a35";
      for (let i = 0; i < 4; i++) x.fillRect(tx - (46 - i * 9) * s, ty - (70 + i * 30) * s, (92 - i * 18) * s, 32 * s);
      x.fillStyle = "#49c450"; x.fillRect(tx - 30 * s, ty - 186 * s, 26 * s, 20 * s);
    };
    tree(120, 300, 1.4); tree(250, 260, 1.0); tree(700, 270, 1.2); tree(860, 300, 1.5); tree(560, 250, 0.8);
    g = x.createLinearGradient(0, H * 0.55, 0, H);
    g.addColorStop(0, "#32a83f"); g.addColorStop(1, "#1f8a2c");
    x.fillStyle = g; x.fillRect(0, H * 0.55, W, H * 0.45);
    x.strokeStyle = "rgba(255,255,255,.08)"; x.lineWidth = 2;
    for (let i = -10; i < 20; i++) { x.beginPath(); x.moveTo(W / 2 + i * 30, H * 0.55); x.lineTo(W / 2 + i * 110, H); x.stroke(); }
    const pod = (cx, cy, rx, ry) => {
      x.fillStyle = "#454f74"; x.beginPath(); x.ellipse(cx, cy + 14, rx, ry, 0, 0, TAU); x.fill(); x.fillRect(cx - rx, cy, rx * 2, 14);
      x.fillStyle = "#5e6994"; x.beginPath(); x.ellipse(cx, cy, rx, ry, 0, 0, TAU); x.fill();
    };
    x.fillStyle = "#56608a"; x.fillRect(430, 230, 100, 120);
    pod(330, 380, 90, 22); pod(630, 380, 90, 22); pod(480, 410, 130, 30);
    x.fillStyle = "#ff8fcf"; x.beginPath(); x.ellipse(480, 360, 26, 46, 0, 0, TAU); x.fill();
    x.fillRect(470, 290, 4, 30); x.fillRect(486, 290, 4, 30);
  })();

  // ------------------------------------------------------------------------------------------------------- the shop
  const shop = $("#shop");
  shop.innerHTML = `
    <div class="title out-up">${L("title_stroke2", 0, 0, 1, 1, DARK)}${L("title_main", 0.0031, 0.0472, 0.9937, 0.9057, DARK)}
      ${L("title_stroke", 0.0062, 0.0189, 0.9877, 0.9623, "#828282")}${L("title_mask", 0.0031, 0.0472, 0.9937, 0.9057)}<div class="txt gt">GACHA</div></div>
    <div id="tabs" class="out-up"></div>
    <div id="balance" class="out-up"></div>
    <div id="back" class="btn out-up" role="button" tabindex="0" aria-label="Back">${L("back_stroke2", 0.0551, 0, 0.9132, 0.9464, DARK)}
      ${L("back_main", 0.0625, 0.0447, 0.8697, 0.8572, "#ff4d4d")}${L("back_stroke", 0.0696, 0.0179, 0.8843, 0.9107, "#e64040")}
      ${L("back_mask", 0.0696, 0.0179, 0.8843, 0.9107)}<div class="arrow gt">&lt;</div><div class="name gt">BACK</div></div>
    <div id="odds" class="out-left"></div>
    <div id="showcase">
      <div class="sc-beam"></div><div class="sc-glow"></div><div class="sc-rays"></div><div class="sc-halo"></div>
      <canvas class="sc-parts" width="600" height="660"></canvas>
      <svg class="sc-pedestal" viewBox="0 0 400 150" aria-hidden="true">
        <defs><radialGradient id="pedGlow"><stop offset="0" stop-color="var(--g1)" stop-opacity=".85"/><stop offset="1" stop-color="var(--g1)" stop-opacity="0"/></radialGradient></defs>
        <ellipse cx="200" cy="118" rx="196" ry="30" fill="rgba(0,0,0,.38)"/>
        <path d="M22 52 V98 A178 40 0 0 0 378 98 V52 Z" fill="#30374f" stroke="#14141c" stroke-width="6"/>
        ${Array.from({ length: 11 }, (_, i) => { const a = Math.PI * (0.08 + 0.84 * i / 10); const xx = 200 - Math.cos(a) * 170; return `<rect x="${xx - 7}" y="${66 + Math.sin(a) * 30}" width="14" height="18" rx="3" fill="#3c4562" stroke="#14141c" stroke-width="2.5"/>`; }).join("")}
        <ellipse cx="200" cy="52" rx="178" ry="40" fill="#4a5474" stroke="#14141c" stroke-width="6"/>
        <ellipse cx="200" cy="52" rx="120" ry="25" fill="url(#pedGlow)"/>
        <ellipse cx="200" cy="52" rx="152" ry="32" fill="none" style="stroke:var(--g1)" stroke-width="5" opacity=".95"/>
        <ellipse cx="200" cy="52" rx="152" ry="32" fill="none" style="stroke:var(--g1)" stroke-width="14" opacity=".25"/>
        <path d="M60 40 A150 30 0 0 1 200 20" fill="none" stroke="#fff" stroke-opacity=".25" stroke-width="5" stroke-linecap="round"/>
      </svg>
      <div class="sc-crate"><img alt="" src=""><div class="sc-shine"></div></div>
      <div class="sc-tier gt"></div>
      <div class="sc-plate">${L("chip_stroke2", 0, 0, 1, 1, DARK)}${L("chip_main", 0.0034, 0.061, 0.9931, 0.878, DARK)}
        ${L("chip_stroke", 0.0068, 0.0244, 0.9865, 0.9512, "#828282")}<div class="txt gt"></div></div>
    </div>
    <div id="buy" class="out-down"></div>
    <div id="quick" class="btn out-down" role="button" tabindex="0" aria-label="Quick open">${L("chip_stroke2", 0, 0, 1, 1, DARK)}${L("chip_main", 0.0034, 0.061, 0.9931, 0.878, DARK)}
      ${L("chip_stroke", 0.0068, 0.0244, 0.9865, 0.9512, "#828282")}
      <div class="txt gt"><svg viewBox="0 0 26 32"><path d="M16 1 L3 18 H12 L9 31 L23 12 H14 Z" fill="currentColor" stroke="#14141c" stroke-width="2.5" stroke-linejoin="round"/></svg>QUICK</div></div>
    <div id="skip" class="btn" role="button" tabindex="0" aria-label="Skip">${L("chip_stroke2", 0, 0, 1, 1, DARK)}${L("chip_main", 0.0034, 0.061, 0.9931, 0.878, DARK)}
      ${L("chip_stroke", 0.0068, 0.0244, 0.9865, 0.9512, "#ffffff")}<div class="txt gt">SKIP</div></div>`;
  $("#showcase .sc-plate").classList.add("out-fade");
  $("#showcase .sc-tier").classList.add("out-fade");
  $("#showcase .sc-pedestal").classList.add("out-fade");
  // the skip button lives above the reels
  $("#open").appendChild($("#skip"));

  const hoverSnd = () => Sound.play("Button_Hover", { vol: 0.5 });
  function bindBtn(el, fn) {
    el.addEventListener("pointerenter", hoverSnd);
    el.addEventListener("click", fn);
    el.addEventListener("keydown", (e) => { if (e.key === "Enter") fn(e); });
  }

  function renderTabs() {
    $("#tabs").innerHTML = ORDER.map((id) => {
      const c = CRATES[id], sel = id === state.crate, prem = !!c.premium;
      const stroke = prem ? (sel ? "#ffe27a" : "#c99a2a") : sel ? "#ffffff" : "#828282";
      const gem = prem ? `<img class="gem" src="${A.img.item_Diamonds}" alt="">` : "";
      return `<div class="tab btn ${sel ? "sel" : ""} ${prem ? "premium" : ""}" data-crate="${id}" role="button" tabindex="0">
        ${L("tab_stroke2", 0, 0, 1, 1, DARK)}${L("tab_main", 0.0093, 0.0714, 0.9813, 0.8571, prem ? "#2a1f3a" : DARK)}
        ${L(sel ? "tab_stroke_sel" : "tab_stroke", 0.0093, 0.0238, 0.9815, 0.9524, stroke)}
        <div class="txt gt">${gem}${c.tab.toUpperCase()}</div></div>`;
    }).join("");
    $$("#tabs .tab").forEach((t) => bindBtn(t, () => { Sound.play("Button_Click"); selectCrate(t.dataset.crate); }));
  }

  function renderBalance() {
    const c = CRATES[state.crate];
    const curs = ["Coins", "Diamonds"].filter((k) => c.prices[k]);
    $("#balance").innerHTML = curs.map((k) => {
      const sel = k === state.pay;
      return `<div class="chip btn ${sel ? "" : "dim"}" data-cur="${k}" role="button" tabindex="0">${L("chip_stroke2", 0, 0, 1, 1, DARK)}
        ${L("chip_main", 0.0034, 0.061, 0.9931, 0.878, DARK)}${L("chip_stroke", 0.0068, 0.0244, 0.9865, 0.9512, sel ? (k === "Diamonds" ? "#ffd24a" : "#ffffff") : "#828282")}
        <img src="${A.img["item_" + k]}" alt=""><div class="amt gt">${state.bal[k].toLocaleString("en-US")}</div></div>`;
    }).join("");
    $$("#balance .chip").forEach((ch) => bindBtn(ch, () => { if (state.pay !== ch.dataset.cur) { Sound.play("Button_Click"); state.pay = ch.dataset.cur; refreshShop(); } }));
  }

  // TextScaled, roughly: shrink a label until it fits its box
  function fitText(root) {
    for (const el of $$(".card .name, .rv-name, .sc-plate .txt", root)) {
      el.style.fontSize = "";
      let fs = parseFloat(getComputedStyle(el).fontSize);
      const min = fs * 0.55;
      while (el.scrollWidth > el.clientWidth + 1 && fs > min) { fs -= 1; el.style.fontSize = fs + "px"; }
    }
  }

  function renderOdds() {
    const c = CRATES[state.crate], odds = c.odds[state.pay];
    const by = {};
    for (const [id, ch] of Object.entries(odds)) (by[ITEMS[id].r] ||= []).push([id, ch]);
    $("#odds").innerHTML = RANKED.filter((r) => by[r]).map((r) => `<div class="rsec">${rarityTitleHTML(r, 493)}
      <div class="rgrid">${by[r].map(([id, ch]) => cardHTML(id, { chance: ch })).join("")}</div></div>`).join("");
    fitText($("#odds"));
  }

  function renderBuy() {
    const c = CRATES[state.crate];
    $("#buy").innerHTML = COUNTS.map((n, i) => `<div class="buybtn btn ${state.pay === "Diamonds" ? "diamonds" : ""}" data-n="${n}" role="button" tabindex="0" aria-label="Open ${n}">
      <div class="amount gt">x${n}</div>${buyBoxHTML(n, state.pay)}
      <div class="price"><img src="${A.img["item_" + state.pay]}" alt=""><span class="p gt">${c.prices[state.pay][i].toLocaleString("en-US")}</span></div></div>`).join("");
    $$("#buy .buybtn").forEach((b) => bindBtn(b, () => buy(+b.dataset.n, b)));
  }

  let ambient = null;
  function renderShowcase() {
    const c = CRATES[state.crate];
    const sc = $("#showcase");
    sc.style.setProperty("--g1", c.g1);
    sc.style.setProperty("--g2", c.g2);
    stage.style.setProperty("--g1", c.g1);
    stage.style.setProperty("--mk", c.premium ? "#fff0a8" : "#ffd23a");
    $(".sc-crate img", sc).src = A.svg[c.icon];
    $(".sc-crate", sc).style.setProperty("--cratemask", `url(${A.svg[c.icon]})`);
    $(".sc-plate .txt", sc).textContent = c.name.toUpperCase();
    fitText(sc);
    $(".sc-tier", sc).innerHTML = c.premium ? `<img src="${A.img.item_Diamonds}" alt="">PREMIUM` : "STANDARD";
    stage.classList.toggle("premium", !!c.premium);
    startAmbient(c.amb);
  }

  function startAmbient(kind) {
    if (ambient) ambient.forEach((e) => e.stop());
    ambient = [];
    const E = (o) => ambient.push(FX.emitter("amb", o));
    if (kind === "embers") E({ rate: 16, spawn: () => ({ shape: "dot", x: rnd(150, 450), y: rnd(430, 520), vx: rnd(-15, 15), vy: rnd(-110, -50), g: -12, drag: 0.2, size: rnd(1.6, 3.6), life: rnd(2, 3.6), color: pick(["#ffb347", "#ffd27a", "#ff7a1a"]), wobble: 2.2 }) });
    if (kind === "glints") {
      E({ rate: 9, spawn: () => ({ shape: "star", x: rnd(130, 470), y: rnd(80, 470), vx: 0, vy: rnd(-12, -4), size: rnd(7, 15), life: rnd(0.8, 1.5), fade: "twinkle", color: pick(["#fff6c4", "#9ff2ff", "#ffd24a"]) }) });
      E({ rate: 10, spawn: () => ({ shape: "dot", x: rnd(140, 460), y: rnd(420, 520), vx: rnd(-10, 10), vy: rnd(-70, -35), drag: 0.1, size: rnd(1.4, 3), life: rnd(2.5, 4), color: pick(["#9ff2ff", "#ffe27a"]), wobble: 1.5 }) });
    }
    if (kind === "bubbles") E({ rate: 9, spawn: () => ({ shape: "bubble", add: false, x: rnd(150, 450), y: rnd(440, 520), vx: 0, vy: rnd(-80, -40), drag: 0.1, size: rnd(5, 12), life: rnd(2.6, 4), color: "#a8fde6", wobble: 3, fade: "inout" }) });
    if (kind === "sparkles") {
      E({ rate: 10, spawn: () => ({ shape: "star", x: rnd(120, 480), y: rnd(80, 480), vx: 0, vy: rnd(-16, -6), size: rnd(6, 13), life: rnd(0.8, 1.4), fade: "twinkle", color: pick(["#ffd0f0", "#ff6ad5", "#ffffff", "#d7a6ff"]) }) });
    }
  }

  function refreshShop() {
    renderTabs(); renderBalance(); renderOdds(); renderBuy(); renderShowcase();
  }

  function selectCrate(id) {
    if (!CRATES[id]) return;
    const changed = state.crate !== id;
    state.crate = id;
    if (!CRATES[id].prices[state.pay]) state.pay = Object.keys(CRATES[id].prices)[0];
    refreshShop();
    if (changed) {
      if (CRATES[id].premium) Sound.play("Crate_Premium", { vol: 0.9 });
      anim($("#showcase .sc-crate img"), [{ transform: "scale(.6) translateY(40px)", opacity: 0 }, { transform: "scale(1.06)", opacity: 1, offset: 0.7 }, { transform: "scale(1)", opacity: 1 }], { duration: 420, easing: "cubic-bezier(.3,1.4,.6,1)" });
    }
  }

  bindBtn($("#quick"), () => { Sound.play("Button_Click"); setQuick(!state.quick); });
  bindBtn($("#back"), () => Sound.play("Button_Close"));
  function setQuick(q) {
    state.quick = q;
    $("#quick").classList.toggle("on", q);
    $("#quick").querySelector(".ly.tn:nth-of-type(3)")?.style.setProperty("--t", q ? "#ffe066" : "#828282");
    $("#dQuick").setAttribute("aria-pressed", String(q));
  }

  // --------------------------------------------------------------------------------------------------- rolling items
  function weighted(odds, filter = () => true) {
    const rows = Object.entries(odds).filter(([id]) => filter(id));
    const total = rows.reduce((s, [, w]) => s + w, 0);
    let x = Math.random() * total;
    for (const [id, w] of rows) { x -= w; if (x <= 0) return id; }
    return rows[rows.length - 1][0];
  }
  function forcedPick(odds) {
    const f = state.force;
    if (ITEMS[f]) return odds[f] != null ? f : weighted(odds);
    const want = R[f].rank;
    const ranks = [...new Set(Object.keys(odds).map((id) => R[ITEMS[id].r].rank))];
    const best = ranks.sort((a, b) => Math.abs(a - want) - Math.abs(b - want) || b - a)[0];
    return weighted(odds, (id) => R[ITEMS[id].r].rank === best);
  }
  function rollPack(count) {
    const odds = CRATES[state.crate].odds[state.pay];
    const ids = [];
    for (let i = 0; i < count; i++) ids.push(i === 0 && state.force !== "random" ? forcedPick(odds) : weighted(odds));
    for (let i = ids.length - 1; i > 0; i--) { const j = (Math.random() * (i + 1)) | 0; [ids[i], ids[j]] = [ids[j], ids[i]]; }
    return ids.map((id) => {
      const copies = (state.copies[id] = (state.copies[id] || 0) + 1);
      return { id, item: ITEMS[id], rank: R[ITEMS[id].r].rank, copies, isNew: copies === 1, justShiny: copies === SHINY_COPIES };
    });
  }
  const filler = (odds) => weighted(odds, (id) => ITEMS[id].r !== "Legendary");

  // ------------------------------------------------------------------------------------------------- screen helpers
  const flashEl = $("#flash"), darkEl = $("#darken");
  function flash(color = "#fff", peak = 0.8, ms = 420) {
    flashEl.style.background = color;
    anim(flashEl, [{ opacity: peak }, { opacity: 0 }], { duration: ms, easing: "ease-out" });
  }
  function darken(to, ms = 400) {
    const from = +getComputedStyle(darkEl).opacity;
    anim(darkEl, [{ opacity: from }, { opacity: to }], { duration: ms, easing: "ease-in-out" });
  }
  // --------------------------------------------------------------------------------------------- the 3D crate stage
  // The bought crates drop onto the screen in 3D and wait for a tap (Quick open opens them at once); the tap
  // rattles them, springs their hatches and drops their walls, and a flash hands over to the reels. A legendary's
  // golden crate goes through the same.
  const c3back = $("#c3back"), tapEl = $("#tapPrompt");
  async function crateStage({ crate, count, gold = false, quick = false }) {
    const C3 = await window.Crate3DReady;
    const c = CRATES[crate];
    const col = gold ? "#ffc828" : c.g1;
    c3back.style.setProperty("--c3", col);
    c3back.classList.toggle("gold", gold);
    c3back.classList.add("on");
    let sparkle = null;
    await C3.show({ crate, count, gold, quick, color: col, onLand: (p, k) => {
      if (k === 0 || count < 10 || k % 3 === 0) Sound.play("Crate_Settle", { vol: count === 10 ? 0.5 : 0.9, rate: rnd(0.9, 1.05) });
      FX.ring("back", p.x, p.y + 120 * p.scale, { color: "#ffffff", r0: 30, r1: 220 * p.scale, life: 0.4, width: 6 });
      FX.burst("back", p.x, p.y + 130 * p.scale, { count: 10, speed: [80, 260], life: [0.3, 0.6], size: [5, 9], colors: ["#ffffff", col], drag: 3 });
      if (count === 1) shake(160, 6);
    } });
    if (gold) {
      Sound.play("Crate_GoldHit", { vol: 0.8 });
      const pts = C3.points();
      sparkle = FX.emitter("front", { rate: 22, duration: 60, spawn: () => {
        const p = pick(pts);
        return { shape: "star", x: p.x + rnd(-260, 260) * p.scale, y: p.y + rnd(-200, 170) * p.scale, vx: 0, vy: rnd(-50, -15), size: rnd(7, 13), life: rnd(0.5, 0.9), fade: "twinkle", color: pick(["#fff6c4", "#ffd24a"]) };
      } });
    }
    if (!quick) {
      tapEl.innerHTML = gold ? `TAP TO OPEN<small>LEGENDARY CRATE</small>` : count > 1 ? "TAP TO OPEN ALL" : "TAP TO OPEN";
      tapEl.classList.add("on");
      await C3.waitTap();
      tapEl.classList.remove("on");
      Sound.play("Button_Click", { vol: 0.7 });
    } else {
      await wait(160);
    }
    await C3.open({
      quick,
      onRattle: () => { if (!quick) Sound.play("Crate_Shake"); },
      onHatch: (p, n) => {
        if (n === 0) Sound.play("Crate_Unlock");
        // a shaft of light out of the open hatches
        const beam = document.createElement("div");
        beam.className = "c3beam";
        beam.style.cssText = `left:${p.x}px;top:${p.y - 900}px;width:${300 * p.scale}px;--c3:${col}`;
        $("#world").insertBefore(beam, $("#open"));
        anim(beam, [{ transform: "translateX(-50%) scaleY(0)", opacity: 1 }, { transform: "translateX(-50%) scaleY(1)", opacity: 1, offset: 0.35 }, { transform: "translateX(-50%) scaleY(1.05)", opacity: 0 }], { duration: quick ? 520 : 900, easing: "ease-out" }).finished.then(() => beam.remove());
        FX.burst("front", p.x, p.y, { count: count === 10 ? 14 : 34, shape: "spark", speed: [400, 1200], life: [0.4, 0.8], size: [3, 6], colors: [col, "#ffffff"], drag: 2.4, angle: -Math.PI / 2, spread: Math.PI * 0.75 });
        if (count === 1) shake(220, 8);
      },
      onBurst: (p, n) => {
        FX.ring("front", p.x, p.y, { color: col, r0: 40 * p.scale, r1: (count === 10 ? 260 : 620) * p.scale, life: 0.5, width: count === 10 ? 8 : 16 });
        if (n === 0) flash(gold ? "#fff1b0" : c.premium ? "#dffbff" : "#fff6dc", 0.28, 300);
      },
    });
    flash("#ffffff", 0.9, 520);
    Sound.play("Crate_Land", { vol: 0.7 });
    if (sparkle) sparkle.stop();
    C3.hide();
    c3back.classList.remove("on");
  }

  let shakeUntil = 0;
  function shake(ms, amp) {
    const world = $("#world"), t0 = performance.now();
    shakeUntil = t0 + ms;
    const f = (now) => {
      const t = (now - t0) / ms;
      if (t >= 1 || now > shakeUntil + 5) { world.style.transform = ""; return; }
      const a = (typeof amp === "function" ? amp(t) : amp * (1 - t));
      world.style.transform = `translate(${rnd(-a, a)}px, ${rnd(-a, a)}px)`;
      requestAnimationFrame(f);
    };
    requestAnimationFrame(f);
  }
  let lastTick = 0;
  function tick(vol = 0.85, rate = 1) {
    const now = performance.now();
    if (now - lastTick < 42) return;
    lastTick = now;
    Sound.play("Crate_Tick", { vol, rate: rate * rnd(0.975, 1.035) });
  }
  let lastLand = 0;
  function landSound(vol) {
    const now = performance.now();
    if (now - lastLand < 70) return;
    lastLand = now;
    Sound.play("Crate_Land", { vol });
  }

  // ----------------------------------------------------------------------------------------------------------- reels
  const reelsEl = $("#reels");
  let reels = [];
  let skipRequested = false;

  function markerHTML(axis, x, y, len) {
    if (axis === "x") {
      return `<div class="marker" style="left:${x}px;top:${y}px;width:0;height:${len}px">
        <div class="line" style="left:-3px;top:-6px;width:6px;height:${len + 12}px"></div>
        <div class="tri" style="left:-16px;top:-26px;border-left:16px solid transparent;border-right:16px solid transparent;border-top:22px solid var(--mk)"></div>
        <div class="tri" style="left:-16px;top:${len + 4}px;border-left:16px solid transparent;border-right:16px solid transparent;border-bottom:22px solid var(--mk)"></div></div>`;
    }
    return `<div class="marker" style="left:${x}px;top:${y}px;width:${len}px;height:0">
      <div class="line" style="top:-3px;left:-6px;height:6px;width:${len + 12}px"></div>
      <div class="tri" style="top:-16px;left:-26px;border-top:16px solid transparent;border-bottom:16px solid transparent;border-left:22px solid var(--mk)"></div>
      <div class="tri" style="top:-16px;left:${len + 4}px;border-top:16px solid transparent;border-bottom:16px solid transparent;border-right:22px solid var(--mk)"></div></div>`;
  }

  /* One reel: a strip of cards that scrolls past the marker. p is the strip coordinate under the marker. Horizontal
     reels run right to left, as CS's; the ten-pack's columns run top to bottom. */
  function buildReel(o) {
    const r = { ...o, done: false, lastIdx: null };
    const pitch = (o.axis === "x" ? o.cw : o.ch) + o.gap;
    r.pitch = pitch;
    const ids = [];
    for (let i = 0; i < o.count; i++) ids.push(i === o.win ? o.result.id : o.fill());
    const cards = ids.map((id, i) => {
      const pos = o.axis === "x" ? `left:${i * pitch}px;top:${(o.h - o.ch) / 2}px` : `top:${i * pitch}px;left:${(o.w - o.cw) / 2}px`;
      return cardHTML(id, { kind: "reel", w: o.cw, h: o.ch, gold: i === o.win && o.result.gold, style: pos, noName: o.noName });
    }).join("");
    const el = document.createElement("div");
    el.className = o.axis === "x" ? "band" : "col";
    el.style.cssText = `left:${o.x}px;top:${o.y}px;width:${o.w}px;height:${o.h}px`;
    el.innerHTML = `<div class="strip">${cards}</div>`;
    if (o.lens) {
      const lw = Math.round(o.cw * 1.5);
      el.innerHTML += `<div class="lens" style="left:${o.w / 2 - lw / 2}px;width:${lw}px"><div class="zoom" style="left:${-(o.w / 2 - lw / 2)}px;transform:scale(1.06);transform-origin:${o.w / 2}px 50%"><div class="strip">${cards}</div></div><i class="lens-glass"></i></div>`;
      el.classList.add("dim");
    }
    reelsEl.appendChild(el);
    if (!o.noName) fitText(el);
    r.el = el;
    r.strips = $$(".strip", el);
    r.winEl = (r.strips[1] || r.strips[0]).children[o.win];
    const span = o.axis === "x" ? o.cw : o.ch;
    r.centre = o.win * pitch + span / 2;
    r.p1 = o.win * pitch + span * rnd(0.1, 0.9);
    r.p0 = o.axis === "x" ? 2 * pitch + span / 2 : (o.count - 3) * pitch + span / 2;
    r.mid = (o.axis === "x" ? o.w : o.h) / 2;
    r.set = (p) => {
      r.p = p;
      const tf = o.axis === "x" ? `translate3d(${r.mid - p}px,0,0)` : `translate3d(0,${r.mid - p}px,0)`;
      for (const s of r.strips) s.style.transform = tf;
    };
    r.set(r.p0);
    return r;
  }

  function runReels(list, onTickVol) {
    return new Promise((res) => {
      const t0 = performance.now();
      for (const r of list) { r.t0 = t0 + (r.delay || 0); r.ease = easeRoll; r.from = r.p0; }
      const f = (now) => {
        let alive = false;
        if (skipRequested) {
          skipRequested = false;
          for (const r of list) if (!r.done) { r.from = r.p; r.t0 = now; r.dur = 380 + (r.skipStagger || 0); r.ease = easeOut3; }
          stopTease();
        }
        for (const r of list) {
          if (r.done) continue;
          if (now < r.t0) { alive = true; continue; }
          const t = Math.min(1, (now - r.t0) / r.dur);
          const p = r.from + (r.p1 - r.from) * r.ease(t);
          r.set(p);
          const idx = Math.floor((p + r.gap / 2) / r.pitch);
          if (r.lastIdx !== null && idx !== r.lastIdx) tick(onTickVol, r.tickRate || 1);
          r.lastIdx = idx;
          if (t >= 1) { r.done = true; r.onLand && r.onLand(r); } else alive = true;
        }
        if (alive) requestAnimationFrame(f); else res();
      };
      requestAnimationFrame(f);
    });
  }

  async function settle(r, sound = true) {
    await wait(240);
    if (sound) Sound.play("Crate_Settle", { vol: 0.8 });
    const from = r.p;
    await tween(380, (e) => r.set(from + (r.centre - from) * e), easeInOut3);
  }

  // the tease: a heartbeat under a rare drop slowing in
  let teaseSnd = null, teaseTimers = [];
  function startTease() {
    stopTease();
    teaseSnd = Sound.play("Crate_Tease", { vol: 1 });
    stage.classList.add("cinema");
    $$(".marker").forEach((m) => m.classList.add("hot"));
    for (const t of [0, 0.55, 1.02, 1.42, 1.74, 2.0, 2.2]) {
      teaseTimers.push(setTimeout(() => {
        anim(darkEl, [{ opacity: 0.32 }, { opacity: 0.08 }], { duration: 300, easing: "ease-out" });
        $$(".marker .line").forEach((l) => anim(l, [{ filter: "brightness(1.8)" }, { filter: "none" }], { duration: 260 }));
      }, t * 1000));
    }
  }
  function stopTease(keepBars) {
    teaseTimers.forEach(clearTimeout);
    teaseTimers = [];
    if (teaseSnd) { teaseSnd.stop(200); teaseSnd = null; }
    if (!keepBars) stage.classList.remove("cinema");
  }

  // ------------------------------------------------------------------------------------------------------ the opening
  let token = 0;
  async function buy(count, btnEl) {
    if (state.busy) return;
    const c = CRATES[state.crate];
    const price = c.prices[state.pay][COUNTS.indexOf(count)];
    if (state.bal[state.pay] < price) {
      Sound.play("Button_Close");
      if (btnEl) anim(btnEl, [{ transform: "translateX(0)" }, { transform: "translateX(-10px)" }, { transform: "translateX(10px)" }, { transform: "translateX(0)" }], { duration: 260 });
      return;
    }
    Sound.play("Button_Click");
    await Sound.init();
    state.bal[state.pay] -= price;
    renderBalance();
    const results = rollPack(count);
    results.forEach((r) => (r.gold = r.item.r === "Legendary"));
    await openSequence(count, results);
  }

  async function openSequence(count, results) {
    const my = ++token;
    state.busy = true;
    const quick = state.quick;
    const c = CRATES[state.crate];
    clearResult();
    stage.classList.add("opening");
    $("#openTitle").innerHTML = `${c.name.toUpperCase()}<span class="count">x${count}</span>`;

    // the showcase makes way for the 3D crates, which drop in, wait for a tap and burst open
    anim($("#showcase"), [{ opacity: 1 }, { opacity: 0 }], { duration: 300 });
    await crateStage({ crate: state.crate, count, quick });
    if (my !== token) return;

    // the reels unfold
    reelsEl.innerHTML = "";
    const odds = c.odds[state.pay];
    const fill = () => filler(odds);
    reels = [];
    let markers = "";
    if (count === 1) {
      reels.push(buildReel({ axis: "x", x: 0, y: 330, w: 1920, h: 300, cw: 236, ch: 211, gap: 18, count: 38, win: 33, result: results[0], fill, lens: true, dur: quick ? 1700 : 6000 }));
      markers = markerHTML("x", 960, 330, 300);
    } else if (count === 3) {
      const order = results.map((r, i) => [r.rank + Math.random() * 0.5, i]).sort((a, b) => a[0] - b[0]).map((x) => x[1]);
      results.forEach((res, i) => {
        const rank = order.indexOf(i);
        reels.push(buildReel({ axis: "x", x: 0, y: 200 + i * 252, w: 1920, h: 228, cw: 176, ch: 157, gap: 14, count: 46, win: 41, result: res, fill,
          dur: quick ? 1300 + rank * 230 : 5000 + rank * 620, delay: i * 90, skipStagger: rank * 90 }));
      });
      markers = markerHTML("x", 960, 200, 228 * 3 + 24 * 2);
    } else {
      const order = results.map((r, i) => [r.rank + Math.random() * 0.5, i]).sort((a, b) => a[0] - b[0]).map((x) => x[1]);
      results.forEach((res, i) => {
        const rank = order.indexOf(i);
        reels.push(buildReel({ axis: "y", x: 157 + i * 162, y: 210, w: 150, h: 660, cw: 138, ch: 123, gap: 10, count: 34, win: 4, result: res, fill, noName: true,
          dur: quick ? 1100 + rank * 95 : 3900 + rank * 280, delay: i * 45, skipStagger: rank * 40 }));
      });
      markers = markerHTML("y", 150, 540, 1620);
    }
    reelsEl.insertAdjacentHTML("beforeend", markers);
    stage.classList.add("rolling", "canskip");
    for (const r of reels) {
      if (r.axis === "x") anim(r.el, [{ transform: "scaleY(0)", opacity: 0 }, { transform: "scaleY(1.06)", opacity: 1, offset: 0.7 }, { transform: "scaleY(1)", opacity: 1 }], { duration: 380, easing: "ease-out", delay: r.delay || 0 });
      else anim(r.el, [{ transform: "translateY(60px)", opacity: 0 }, { transform: "none", opacity: 1 }], { duration: 360, easing: "cubic-bezier(.2,.8,.2,1)", delay: r.delay || 0 });
    }
    if (count > 1) Sound.play("Crate_Spin", { vol: 0.8 });
    await wait(quick ? 160 : 300);
    if (my !== token) return;

    // a rare drop slowing in gets the heartbeat
    const slowest = reels.reduce((a, b) => (a.dur + (a.delay || 0) >= b.dur + (b.delay || 0) ? a : b));
    let teaseTimer = null;
    if (!quick && slowest.result.rank >= 3) teaseTimer = setTimeout(startTease, slowest.dur + (slowest.delay || 0) - 2600);
    const landVol = count === 10 ? 0.55 : 0.9;
    for (const r of reels) r.onLand = () => { landSound(landVol); anim(r.winEl, [{ filter: "brightness(1.9)" }, { filter: "none" }], { duration: 380 }); };
    await runReels(reels, count === 10 ? 0.62 : 0.85);
    clearTimeout(teaseTimer);
    stopTease(true);
    stage.classList.remove("canskip");
    if (my !== token) return;
    await Promise.all(reels.map((r, i) => settle(r, count === 1 || i === reels.length - 1)));
    $$(".marker").forEach((m) => m.classList.remove("hot"));
    await wait(120);

    if (count === 1) await revealOne(results[0], reels[0]);
    else await revealMany(count, results);
    stage.classList.remove("cinema");
    state.busy = false;
  }

  // ------------------------------------------------------------------------------------------------------- reveals
  const result = $("#result");
  function clearResult() {
    result.innerHTML = "";
    result.classList.remove("show");
    FX.clear("back");
    FX.clear("front");
    darkEl.getAnimations().forEach((a) => a.cancel());
    darkEl.style.opacity = 0;
  }

  const RAYS = { Common: 0, Uncommon: 0.16, Rare: 0.28, Epic: 0.42, Legendary: 0.6 };
  function rarityFX(r, x, y, big = true) {
    const col = R[r].c, k = big === true ? 1 : big === false ? 0.55 : big;
    if (r === "Common") FX.burst("front", x, y, { count: 16 * k, speed: [180, 480], life: [0.4, 0.8], size: [3, 5], colors: ["#ffffff", col], drag: 2 });
    if (r === "Uncommon") {
      FX.ring("front", x, y, { color: col, r0: 40, r1: 360 * k, life: 0.5, width: 10 });
      FX.burst("front", x, y, { count: 30 * k, shape: "star", speed: [200, 700], life: [0.5, 1], size: [6, 11], colors: [col, "#e9ffe9"], drag: 2.2 });
    }
    if (r === "Rare") {
      FX.ring("front", x, y, { color: col, r0: 40, r1: 520 * k, life: 0.55, width: 14 });
      setTimeout(() => FX.ring("front", x, y, { color: "#cfe6ff", r0: 30, r1: 380 * k, life: 0.5, width: 8 }), 110);
      FX.burst("front", x, y, { count: 44 * k, shape: "spark", speed: [400, 1100], life: [0.4, 0.9], size: [3, 5], colors: [col, "#ffffff"], drag: 2.4 });
    }
    if (r === "Epic") {
      if (k >= 0.6) { flash(col, 0.38 * k, 380); shake(260, 9 * k); }
      FX.ring("front", x, y, { color: col, r0: 60, r1: 760 * k, life: 0.65, width: 18 });
      FX.burst("front", x, y, { count: 90 * k, shape: "spark", speed: [500, 1500], life: [0.5, 1.1], size: [3, 6], colors: [col, "#ff9cf0", "#ffffff"], drag: 2.2 });
      FX.burst("front", x, y, { count: 24 * k, shape: "star", speed: [200, 600], life: [0.8, 1.4], size: [8, 14], colors: ["#f2d4ff", col], drag: 1.6 });
    }
    if (r === "Legendary") {
      FX.ring("front", x, y, { color: col, r0: 60, r1: 900 * k, life: 0.7, width: 22 });
      FX.burst("front", x, y, { count: 30 * k, shape: "coin", speed: [400, 1100], life: [1.6, 2.4], size: [12, 18], colors: ["#ffcf33"], gravity: 1400, drag: 0.6, additive: false });
      FX.burst("front", x, y, { count: 70 * k, shape: "spark", speed: [500, 1600], life: [0.5, 1.1], size: [3, 6], colors: [col, "#fff3b0", "#ffffff"], drag: 2.2 });
    }
  }

  // Builds the big reveal: rays, glow, card, rarity bar, name, copies and the buttons
  function showBig(res, o = {}) {
    const r = res.item.r;
    result.classList.add("show");
    result.style.setProperty("--rc", R[r].c);
    const cx = o.cx ?? 960, cy = o.cy ?? 420, w = o.w ?? 470, h = w / 1.1169;
    const wrapEl = document.createElement("div");
    wrapEl.className = "rv";
    wrapEl.innerHTML = `
      <div class="rv-glow" style="left:${cx}px;top:${cy}px"></div>
      <div class="rv-rays" style="left:${cx}px;top:${cy}px"></div>
      <div class="rv-cardwrap" style="position:absolute;left:${cx - w / 2}px;top:${cy - h / 2}px;width:${w}px;height:${h}px">${cardHTML(res.id, { kind: "big", w, h, noName: true })}
        ${res.isNew ? `<div class="newtag gt">NEW!</div>` : ""}</div>
      <div class="rv-rt" style="left:${960 - w / 2}px;top:${cy + h / 2 + 22}px">${rarityTitleHTML(r, w)}</div>
      <div class="rv-name gt" style="top:${cy + h / 2 + 22 + w / 10.3771 + 18}px">${res.item.name.split("").map((ch, i) => `<span style="--i:${i}">${ch === " " ? "&nbsp;" : ch}</span>`).join("")}</div>
      <div class="rv-copies" style="top:${cy + h / 2 + 22 + w / 10.3771 + 118}px">${res.justShiny ? `<div class="lbl gt" style="color:#ffe066;font-size:36px">SHINY!</div>` : `<div class="lbl gt">${Math.min(res.copies, SHINY_COPIES)} / ${SHINY_COPIES} copies to shiny</div>`}
        <div class="bar"><i></i></div></div>`;
    result.appendChild(wrapEl);
    const rays = $(".rv-rays", wrapEl), glow = $(".rv-glow", wrapEl), card = $(".rv-cardwrap", wrapEl);
    anim(glow, [{ opacity: 0, transform: "scale(.6)" }, { opacity: 0.9, transform: "scale(1)" }], { duration: 500, easing: "ease-out" });
    if (RAYS[r]) {
      anim(rays, [{ opacity: 0 }, { opacity: RAYS[r] }], { duration: 600, easing: "ease-out" });
      rays.animate([{ transform: "rotate(0deg)" }, { transform: "rotate(360deg)" }], { duration: r === "Legendary" ? 16000 : 26000, iterations: Infinity });
    }
    const entrance = {
      pop: [{ transform: "scale(.35)", opacity: 0 }, { transform: "scale(1.1)", opacity: 1, offset: 0.65 }, { transform: "scale(1)", opacity: 1 }],
      squash: [{ transform: "scale(.2,.2)", opacity: 0 }, { transform: "scale(1.28,.78)", opacity: 1, offset: 0.35 }, { transform: "scale(.9,1.12)", offset: 0.6 }, { transform: "scale(1.04,.97)", offset: 0.8 }, { transform: "scale(1)", opacity: 1 }],
      ghost: [{ transform: "translateY(30px) scale(.96)", opacity: 0, filter: "blur(14px) brightness(2)" }, { transform: "none", opacity: 1, filter: "none" }],
      float: [{ transform: "translateY(320px) rotate(-6deg)", opacity: 0 }, { transform: "translateY(-14px) rotate(2deg)", opacity: 1, offset: 0.75 }, { transform: "none", opacity: 1 }],
    }[o.entrance || "pop"];
    const dur = { pop: 520, squash: 720, ghost: 1000, float: 1700 }[o.entrance || "pop"];
    anim(card, entrance, { duration: dur, easing: o.entrance === "float" ? "cubic-bezier(.2,.8,.2,1)" : o.entrance === "ghost" ? "ease-out" : "cubic-bezier(.3,1.3,.6,1)" });
    if (o.entrance === "float") setTimeout(() => card.animate([{ transform: "translateY(0) rotate(-1.5deg)" }, { transform: "translateY(-16px) rotate(1.5deg)" }, { transform: "translateY(0) rotate(-1.5deg)" }], { duration: 3200, iterations: Infinity, easing: "ease-in-out" }), dur);
    // the words come in after the card
    const after = o.textDelay ?? Math.min(dur, 600);
    anim($(".rv-rt", wrapEl), [{ transform: "scaleX(0)", opacity: 0 }, { transform: "scaleX(1)", opacity: 1 }], { duration: 300, delay: after, easing: "cubic-bezier(.3,1.3,.6,1)" });
    const spans = $$(".rv-name span", wrapEl);
    spans.forEach((s, i) => {
      const big = r === "Legendary";
      anim(s, [{ transform: big ? "translateY(-40px) scale(1.8)" : "translateY(18px)", opacity: 0 }, { transform: "none", opacity: 1 }], { duration: big ? 380 : 260, delay: after + 120 + i * (big ? 45 : 18), easing: "cubic-bezier(.3,1.4,.6,1)" });
      if (o.entrance === "float") setTimeout(() => s.animate([{ transform: "translateY(0)" }, { transform: "translateY(-12px)" }, { transform: "translateY(0)" }], { duration: 2400, iterations: Infinity, delay: i * 110, easing: "ease-in-out" }), after + 600);
    });
    const copies = $(".rv-copies", wrapEl);
    anim(copies, [{ opacity: 0, transform: "translateY(12px)" }, { opacity: 1, transform: "none" }], { duration: 300, delay: after + 360 });
    setTimeout(() => { const bar = $(".bar i", copies); if (bar) bar.style.width = `${(Math.min(res.copies, SHINY_COPIES) / SHINY_COPIES) * 100}%`; }, after + 450);
    if (res.justShiny) setTimeout(() => { Sound.play("Reveal_Shiny"); FX.burst("front", cx, cy, { count: 40, shape: "star", speed: [200, 700], life: [0.6, 1.2], size: [8, 14], colors: ["#fff6c4", "#ffe066", "#ffffff"], drag: 1.6 }); }, after + 500);
    return { wrapEl, card };
  }

  function addButtons(count, top = 905) {
    const c = CRATES[state.crate];
    const price = c.prices[state.pay][COUNTS.indexOf(count)];
    const row = document.createElement("div");
    row.className = "rv-btns";
    row.style.top = `${top}px`;
    row.innerHTML = `<div class="buybtn btn ${state.pay === "Diamonds" ? "diamonds" : ""}" id="again" role="button" tabindex="0"><div class="amount gt">OPEN ${count === 1 ? "AGAIN" : `x${count} AGAIN`}</div>${buyBoxHTML(count, state.pay)}
      <div class="price"><img src="${A.img["item_" + state.pay]}" alt=""><span class="p gt">${price.toLocaleString("en-US")}</span></div></div>
      <div class="btn" id="cont" role="button" tabindex="0" style="position:relative;top:13px">${darkBtnHTML("CONTINUE")}</div>`;
    result.appendChild(row);
    anim(row, [{ opacity: 0, transform: "translateY(40px)" }, { opacity: 1, transform: "none" }], { duration: 360, easing: "cubic-bezier(.2,.8,.2,1)" });
    bindBtn($("#again", row), () => { backToShop(true); buy(count, $("#again", row)); });
    bindBtn($("#cont", row), () => { Sound.play("Button_Click"); backToShop(); });
  }

  function backToShop(instant) {
    token++;
    stopTease();
    clearResult();
    reelsEl.innerHTML = "";
    stage.classList.remove("rolling", "canskip", "cinema");
    $("#open").getAnimations().forEach((a) => a.cancel());
    $("#open").style.cssText = "";
    const sc = $("#showcase");
    sc.getAnimations().forEach((a) => a.cancel());
    $$("#showcase *").forEach((e) => e.getAnimations().forEach((a) => a.cancel()));
    $("#showcase .sc-crate").style.animation = "";
    stage.classList.remove("opening");
    state.busy = false;
    if (!instant) anim($("#showcase .sc-crate img"), [{ transform: "scale(.5)", opacity: 0 }, { transform: "scale(1.06)", opacity: 1, offset: 0.7 }, { transform: "scale(1)", opacity: 1 }], { duration: 480, delay: 200, easing: "cubic-bezier(.3,1.4,.6,1)" });
    else { stage.classList.add("opening"); }
  }

  async function revealOne(res, reel) {
    const my = token;
    if (res.gold) { await goldMoment(res, reel.winEl, false); if (my !== token) return; addButtons(1); return; }
    // the winning card lifts out of the reel and becomes the reveal
    const from = stageRect(reel.winEl);
    reel.el.classList.add("dim");
    anim($("#open"), [{ opacity: 1 }, { opacity: 0 }], { duration: 380, delay: 120 });
    Sound.play(`Reveal_${res.item.r}`);
    const { card } = showBig(res, { entrance: "pop", textDelay: 420 });
    card.getAnimations().forEach((a) => a.cancel());
    const to = stageRect(card);
    anim(card, [{ transform: `translate(${from.x - to.x}px, ${from.y - to.y}px) scale(${from.w / to.w})` }, { transform: "translate(0,0) scale(1.08)", offset: 0.75 }, { transform: "none" }], { duration: 520, easing: "cubic-bezier(.3,.9,.4,1)" });
    setTimeout(() => rarityFX(res.item.r, 960, 420), 330);
    await wait(700);
    if (my !== token) return;
    addButtons(1);
  }

  // A legendary: the reel lands on the gold star card; a golden reel picks which one; then its own drop plays
  async function goldMoment(res, goldEl, inGrid) {
    const my = token;
    const c = CRATES[state.crate];
    const pool = Object.keys(c.odds[state.pay]).filter((id) => ITEMS[id].r === "Legendary");
    Sound.play("Crate_GoldHit");
    flash("#ffe9a0", 0.7, 500);
    darken(0.55, 500);
    stage.classList.add("cinema");
    const g = stageRect(goldEl);
    FX.ring("front", g.x + g.w / 2, g.y + g.h / 2, { color: "#ffc828", r0: 40, r1: 520, life: 0.6, width: 16 });
    FX.burst("front", g.x + g.w / 2, g.y + g.h / 2, { count: 60, shape: "spark", speed: [300, 1100], life: [0.5, 1], size: [3, 6], colors: ["#ffc828", "#fff3b0", "#ffffff"], drag: 2.2 });
    const sparkle = FX.emitter("front", { rate: 26, duration: 1.6, spawn: () => ({ shape: "star", x: g.x + rnd(0, g.w), y: g.y + rnd(0, g.h), vx: 0, vy: rnd(-40, -10), size: rnd(6, 12), life: rnd(0.5, 0.9), fade: "twinkle", color: pick(["#fff6c4", "#ffd24a"]) }) });
    anim(goldEl, [{ transform: "scale(1)", filter: "brightness(1)" }, { transform: "scale(1.14)", filter: "brightness(1.5)" }, { transform: "scale(1.1)", filter: "brightness(1.15)" }], { duration: 700, easing: "cubic-bezier(.3,1.4,.6,1)" });
    await wait(state.quick ? 700 : 1100);
    if (my !== token) return;

    // the gold card gives way to a golden crate, tapped open like the first
    sparkle.stop();
    for (const old of [...reelsEl.children]) anim(old, [{ opacity: 1, transform: "none" }, { opacity: 0, transform: "scale(1.04)" }], { duration: 220 });
    await wait(220);
    reelsEl.innerHTML = "";
    darken(0.35, 300);
    $("#openTitle").innerHTML = `<span style="color:#ffe066">LEGENDARY CRATE</span>`;
    await crateStage({ crate: state.crate, count: 1, gold: true, quick: state.quick });
    if (my !== token) return;
    darken(0.55, 300);
    $("#open").getAnimations().forEach((a) => a.cancel());
    $("#open").style.opacity = 1;

    if (pool.length > 1) {
      // the golden reel, in the middle of the screen
      $("#openTitle").innerHTML = `<span style="color:#ffe066">LEGENDARY</span>`;
      const gr = buildReel({ axis: "x", x: 0, y: 330, w: 1920, h: 300, cw: 236, ch: 211, gap: 18, count: 30, win: 25, result: { id: res.id }, fill: () => pick(pool), dur: state.quick ? 1500 : 3200, tickRate: 1.12 });
      gr.el.classList.add("golden");
      gr.el.style.background = "linear-gradient(rgba(60,40,0,.85), rgba(30,20,0,.9))";
      reelsEl.insertAdjacentHTML("beforeend", markerHTML("x", 960, 330, 300));
      anim(reelsEl.lastElementChild, [{ opacity: 0 }, { opacity: 1 }], { duration: 320 });
      anim(gr.el, [{ transform: "scaleY(0)", opacity: 0 }, { transform: "scaleY(1)", opacity: 1 }], { duration: 320, easing: "ease-out" });
      Sound.play("Crate_Spin", { vol: 0.9 });
      gr.onLand = () => { landSound(0.9); };
      stage.classList.add("canskip");
      await runReels([gr], 0.9);
      stage.classList.remove("canskip");
      if (my !== token) return;
      await settle(gr);
      goldEl = gr.winEl;
      await wait(150);
    } else {
      // the crate's only legendary: its card rises out of the crate
      const solo = document.createElement("div");
      solo.style.cssText = `position:absolute;left:${960 - 236 / 2}px;top:${480 - 211 / 2}px;width:236px;height:211px`;
      solo.innerHTML = cardHTML(res.id, { kind: "reel", w: 236, h: 211, noName: true });
      reelsEl.appendChild(solo);
      anim(solo, [{ transform: "translateY(120px) scale(.4)", opacity: 0 }, { transform: "translateY(-10px) scale(1.08)", opacity: 1, offset: 0.7 }, { transform: "none", opacity: 1 }], { duration: 480, easing: "cubic-bezier(.3,1.3,.6,1)" });
      landSound(0.9);
      await wait(520);
      goldEl = solo.firstElementChild;
    }
    await special(res, goldEl);
  }

  async function special(res, fromEl) {
    const kind = res.item.special;
    const f = stageRect(fromEl);
    const fx = f.x + f.w / 2, fy = f.y + f.h / 2;
    const open = $("#open");
    open.style.transformOrigin = `${fx}px ${fy}px`;
    if (kind === "blackhole") {
      Sound.play("Legend_BlackHole");
      darken(0.88, 1200);
      const bh = document.createElement("div");
      bh.className = "bh";
      bh.style.left = `960px`; bh.style.top = `440px`;
      bh.innerHTML = `<div class="disk"><i></i></div><div class="core"></div>`;
      result.appendChild(bh);
      anim(bh, [{ transform: "scale(0)" }, { transform: "scale(1)" }], { duration: 1150, easing: "cubic-bezier(.5,0,.75,0)" });
      open.style.transformOrigin = "960px 440px";
      anim(open, [{ transform: "none", filter: "none", opacity: 1 }, { transform: "scale(.12) rotate(55deg)", filter: "blur(5px)", opacity: 0 }], { duration: 1200, easing: "cubic-bezier(.6,0,.9,.4)" });
      const orbit = (p, dt) => {
        const sp = 220 + 120000 / (p.r + 60);
        p.r -= sp * dt;
        p.a += (1.6 + 420 / (p.r + 40)) * dt;
        const nx = p.cx + Math.cos(p.a) * p.r, ny = p.cy + Math.sin(p.a) * p.r * 0.5;
        p.vx = (nx - p.x) / Math.max(dt, 1e-3); p.vy = (ny - p.y) / Math.max(dt, 1e-3);
        p.x = nx; p.y = ny;
        if (p.r < 24) p.age = p.life;
      };
      const em = FX.emitter("front", { rate: (t) => 70 + t * 220, duration: 1.2, spawn: () => { const a = rnd(0, TAU), r = rnd(650, 1100); return { shape: "spark", x: 960 + Math.cos(a) * r, y: 440 + Math.sin(a) * r * 0.5, vx: 0, vy: 0, life: 3, size: rnd(2, 4.5), color: pick(["#b45cff", "#5ce1ff", "#ffffff", "#ff5fd2"]), update: orbit, r, a, cx: 960, cy: 440 }; } });
      shake(1250, (t) => 1 + t * t * 9);
      await wait(1250);
      em.stop();
      anim(bh, [{ transform: "scale(1)" }, { transform: "scale(0)" }], { duration: 120, easing: "ease-in" });
      setTimeout(() => bh.remove(), 140);
      flash("#ffffff", 0.95, 520);
      FX.ring("front", 960, 440, { color: "#b45cff", r0: 30, r1: 1100, life: 0.8, width: 28 });
      FX.ring("front", 960, 440, { color: "#5ce1ff", r0: 20, r1: 700, life: 0.6, width: 12 });
      FX.burst("front", 960, 440, { count: 170, shape: "spark", speed: [600, 1800], life: [0.5, 1.2], size: [3, 6], colors: ["#b45cff", "#5ce1ff", "#ffffff", "#ff5fd2"], drag: 2.2 });
      shake(420, 16);
      // the disk stays behind the card, turning
      const disk = document.createElement("div");
      disk.className = "bh";
      disk.style.cssText = "left:960px;top:420px;opacity:.55";
      disk.innerHTML = `<div class="disk" style="transform:scaleY(.36) scale(1.25)"><i></i></div>`;
      result.prepend(disk);
      FX.emitter("back", { rate: 28, spawn: () => { const a = rnd(0, TAU), r = rnd(500, 900); return { shape: "dot", x: 960 + Math.cos(a) * r, y: 420 + Math.sin(a) * r * 0.5, vx: 0, vy: 0, life: 4, size: rnd(1.5, 3), color: pick(["#b45cff", "#5ce1ff", "#ffffff"]), update: (p, dt) => { p.r -= (60 + 9000 / (p.r + 40)) * dt; p.a += (0.6 + 120 / (p.r + 40)) * dt; p.x = p.cx + Math.cos(p.a) * p.r; p.y = p.cy + Math.sin(p.a) * p.r * 0.5; if (p.r < 120) p.age = p.life; }, r, a, cx: 960, cy: 420 }; } });
      showBig(res, { entrance: "pop" });
      await wait(900);
    } else if (kind === "variety") {
      Sound.play("Legend_Variety");
      anim(fromEl, [{ transform: "scale(1.1) rotate(0)" }, { transform: "scale(1.2) rotate(-9deg)" }, { transform: "scale(1.24) rotate(9deg)" }, { transform: "scale(1.3) rotate(-7deg)" }, { transform: "scale(1.36) rotate(0)" }], { duration: 380 });
      await wait(390);
      anim(open, [{ opacity: 1 }, { opacity: 0 }], { duration: 160 });
      flash("conic-gradient(from 0deg, #ff4d4d, #ffb347, #ffe066, #5adc6e, #5ce1ff, #7b6bff, #ff5fd2, #ff4d4d)", 0.7, 600);
      const rainbow = ["#ff4d4d", "#ffb347", "#ffe066", "#5adc6e", "#5ce1ff", "#7b6bff", "#ff5fd2", "#ffffff"];
      FX.burst("front", fx, fy, { count: 240, shape: "confetti", angle: -Math.PI / 2, spread: 3.4, speed: [500, 1600], life: [2.4, 3.8], size: [12, 22], colors: rainbow, gravity: 1100, drag: 1.1, additive: false, vrot: 9 });
      FX.burst("front", fx, fy, { count: 16, shape: "smiley", angle: -Math.PI / 2, spread: 2.6, speed: [600, 1300], life: [3, 3.8], size: [24, 42], colors: ["#ffd93b"], gravity: 1500, drag: 0.4, floor: 1050, bounce: 0.55, additive: false, vrot: 5 });
      FX.ring("front", fx, fy, { color: "#ffe066", r0: 30, r1: 820, life: 0.6, width: 20 });
      shake(320, 11);
      const bgRain = document.createElement("div");
      bgRain.style.cssText = "position:absolute;left:960px;top:420px;width:1600px;height:1600px;margin:-800px 0 0 -800px;pointer-events:none;opacity:0;mix-blend-mode:screen;background:repeating-conic-gradient(#ff4d4d 0 10deg,#ffb347 10deg 20deg,#ffe066 20deg 30deg,#5adc6e 30deg 40deg,#5ce1ff 40deg 50deg,#7b6bff 50deg 60deg,#ff5fd2 60deg 70deg);-webkit-mask:radial-gradient(closest-side,#000 10%,transparent 70%);mask:radial-gradient(closest-side,#000 10%,transparent 70%)";
      result.prepend(bgRain);
      anim(bgRain, [{ opacity: 0 }, { opacity: 0.32 }], { duration: 600 });
      bgRain.animate([{ transform: "rotate(0)" }, { transform: "rotate(360deg)" }], { duration: 20000, iterations: Infinity });
      FX.emitter("back", { rate: 22, duration: 6, spawn: () => ({ shape: "confetti", add: false, x: rnd(0, 1920), y: -20, vx: rnd(-60, 60), vy: rnd(80, 220), g: 60, drag: 0.3, size: rnd(10, 18), life: 6, color: pick(rainbow), vrot: rnd(-6, 6), wobble: 2 }) });
      showBig(res, { entrance: "squash" });
      await wait(900);
    } else if (kind === "skeleton") {
      Sound.play("Legend_Skeleton");
      const tint = document.createElement("div");
      tint.style.cssText = "position:absolute;inset:0;pointer-events:none;background:radial-gradient(70% 70% at 50% 45%, rgba(20,70,30,.35), rgba(2,14,6,.88))";
      result.prepend(tint);
      anim(tint, [{ opacity: 0 }, { opacity: 1 }], { duration: 200 });
      flash("#ffffff", 1, 140);
      FX.bolt("front", rnd(700, 820), -20, fx, fy, { color: "#b8ffc4" });
      setTimeout(() => { flash("#e6ffe9", 0.8, 260); FX.bolt("front", rnd(1100, 1250), -20, fx + 40, fy, { color: "#b8ffc4", width: 6 }); }, 170);
      shake(380, 13);
      await wait(200);
      anim(open, [{ opacity: 1 }, { opacity: 0 }], { duration: 250, delay: 150 });
      FX.burst("front", fx, fy, { count: 22, shape: "bone", angle: -Math.PI / 2, spread: 3.2, speed: [500, 1200], life: [1.5, 2.1], size: [40, 62], colors: ["#fff"], gravity: 1700, drag: 0.5, floor: 1060, bounce: 0.3, additive: false, vrot: 10 });
      FX.burst("front", fx, fy, { count: 60, shape: "flame", speed: [100, 500], life: [0.6, 1.1], size: [20, 46], colors: ["rgba(90,255,140,.85)", "rgba(160,255,190,.8)"], drag: 2, gravity: -300 });
      FX.emitter("back", { rate: 90, spawn: () => { const side = Math.random() < 0.5 ? rnd(620, 760) : rnd(1160, 1300); const x = Math.random() < 0.35 ? rnd(700, 1220) : side; return { shape: "flame", x, y: rnd(540, 700), vx: rnd(-20, 20), vy: rnd(-260, -110), drag: 0.4, size: rnd(30, 70), life: rnd(0.9, 1.6), color: pick(["rgba(80,255,130,.8)", "rgba(150,255,180,.75)"]), wobble: 3 }; } });
      FX.emitter("back", { rate: 3, spawn: () => ({ shape: "fog", add: false, x: rnd(-100, 2020), y: rnd(800, 1100), vx: rnd(-30, 30), vy: rnd(-10, 0), drag: 0, size: rnd(240, 420), life: rnd(5, 8), fade: "inout", color: "rgba(140,255,170,.10)" }) });
      await wait(350);
      showBig(res, { entrance: "ghost", textDelay: 1100 });
      await wait(1200);
    } else if (kind === "lowgravity") {
      Sound.play("Legend_LowGravity");
      const tint = document.createElement("div");
      tint.style.cssText = "position:absolute;inset:0;pointer-events:none;background:radial-gradient(80% 80% at 50% 40%, rgba(120,90,255,.30), rgba(20,8,60,.8))";
      result.prepend(tint);
      anim(tint, [{ opacity: 0 }, { opacity: 1 }], { duration: 900 });
      anim(fromEl, [{ transform: "scale(1.1) translateY(0) rotate(0)" }, { transform: "scale(1.15) translateY(-160px) rotate(-8deg)", opacity: 0 }], { duration: 1000, easing: "cubic-bezier(.4,0,.2,1)" });
      anim(open, [{ opacity: 1 }, { opacity: 0 }], { duration: 900, delay: 300 });
      const bub = (layer, rate) => FX.emitter(layer, { rate, spawn: () => ({ shape: "bubble", add: false, x: rnd(0, 1920), y: 1110, vx: 0, vy: rnd(-170, -60), drag: 0, size: rnd(8, 30), life: rnd(5, 8), color: pick(["#d8ecff", "#c9b8ff", "#a8fde6"]), wobble: 2, fade: "inout" }) });
      bub("back", 26); bub("front", 6);
      FX.emitter("back", { rate: 8, spawn: () => ({ shape: "star", x: rnd(0, 1920), y: rnd(300, 1080), vx: 0, vy: rnd(-40, -15), drag: 0, size: rnd(5, 10), life: rnd(1.5, 3), fade: "twinkle", color: pick(["#ffffff", "#d7c8ff"]) }) });
      await wait(700);
      FX.burst("front", fx, fy - 160, { count: 34, shape: "bubble", speed: [80, 260], life: [1.4, 2.4], size: [8, 22], colors: ["#e5f2ff", "#c9b8ff"], drag: 1.2, gravity: -60, additive: false });
      showBig(res, { entrance: "float", textDelay: 1300 });
      await wait(1700);
    } else {
      Sound.play("Reveal_Legendary");
      showBig(res, { entrance: "pop" });
      rarityFX("Legendary", 960, 420);
      await wait(900);
    }
  }

  // Three and ten packs: the winners leave their reels for a row or a grid, rarest last; a legendary then gets its moment
  async function revealMany(count, results) {
    const my = token;
    Sound.play("Results_Open");
    result.classList.add("show");
    const slots = count === 3
      ? results.map((_, i) => ({ cx: 960 + (i - 1) * 450, cy: 420, w: 380 }))
      : results.map((_, i) => ({ cx: 960 + ((i % 5) - 2) * 300, cy: i < 5 ? 268 : 588, w: 228 }));
    const order = results.map((r, i) => [r.rank, i]).sort((a, b) => a[0] - b[0]).map((x) => x[1]);
    const best = order[order.length - 1];
    const holder = document.createElement("div");
    holder.className = "rv-many";
    result.appendChild(holder);
    const cards = results.map((res, i) => {
      const s = slots[i], h = s.w / 1.1169;
      const d = document.createElement("div");
      d.style.cssText = `position:absolute;left:${s.cx - s.w / 2}px;top:${s.cy - h / 2}px;width:${s.w}px;height:${h}px`;
      d.innerHTML = cardHTML(res.id, { kind: "big", w: s.w, h, noName: true, gold: res.gold });
      holder.appendChild(d);
      const from = stageRect(reels[i].winEl);
      const to = { x: s.cx - s.w / 2, y: s.cy - h / 2, w: s.w };
      anim(d, [{ transform: `translate(${from.x - to.x}px, ${from.y - to.y}px) scale(${from.w / to.w})` }, { transform: "none" }], { duration: 520, delay: i * 30, easing: "cubic-bezier(.3,.9,.4,1)" });
      return { el: d, slot: s, h, res };
    });
    anim($("#open"), [{ opacity: 1 }, { opacity: 0 }], { duration: 300, delay: 150 });
    await wait(560 + count * 30);
    if (my !== token) return;

    // name each card in turn, the best last
    const step = count === 3 ? 420 : 110;
    for (const i of order) {
      const { el, slot, h, res } = cards[i];
      if (res.gold) continue;
      const lbl = document.createElement("div");
      const fs = count === 3 ? 46 : 28;
      lbl.innerHTML = `<div style="position:absolute;left:${slot.cx - slot.w / 2}px;top:${slot.cy + h / 2 + 10}px">${rarityTitleHTML(res.item.r, slot.w)}</div>
        <div class="gt" style="position:absolute;left:${slot.cx - 200}px;width:400px;text-align:center;top:${slot.cy + h / 2 + 18 + slot.w / 10.3771}px;font-size:${fs}px;--o:${count === 3 ? 4 : 3}px">${res.item.name}</div>`;
      holder.appendChild(lbl);
      if (res.isNew) el.insertAdjacentHTML("beforeend", `<div class="newtag gt" style="font-size:${count === 3 ? 24 : 18}px">NEW!</div>`);
      anim(el, [{ transform: "scale(1)" }, { transform: "scale(1.12)" }, { transform: "scale(1)" }], { duration: 300, easing: "cubic-bezier(.3,1.4,.6,1)" });
      anim(lbl, [{ opacity: 0, transform: "translateY(10px)" }, { opacity: 1, transform: "none" }], { duration: 220 });
      if (i === best) {
        Sound.play(`Reveal_${res.item.r}`);
        rarityFX(res.item.r, slot.cx, slot.cy, count === 3 ? true : 0.6);
        el.insertAdjacentHTML("beforeend", `<div class="ribbon gt">BEST</div>`);
      } else {
        Sound.play(count === 3 ? `Reveal_${res.item.r}` : "Card_Flip", { vol: count === 3 ? 0.7 : 0.75, rate: count === 3 ? 1 : rnd(0.95, 1.08) });
        rarityFX(res.item.r, slot.cx, slot.cy, count === 3 ? false : 0.32);
      }
      await wait(step);
      if (my !== token) return;
    }

    // any legendary: it comes to the middle and gets its drop
    for (const i of order) {
      const { el, slot, h, res } = cards[i];
      if (!res.gold) continue;
      await wait(400);
      holder.style.transition = "opacity 300ms";
      holder.style.opacity = 0;
      const solo = document.createElement("div");
      solo.className = "solo";
      solo.style.cssText = `position:absolute;left:${960 - 236 / 2}px;top:${480 - 211 / 2}px;width:236px;height:211px`;
      solo.innerHTML = cardHTML(res.id, { kind: "reel", w: 236, h: 211, gold: true, noName: true });
      $("#reels").innerHTML = "";
      $("#open").getAnimations().forEach((a) => a.cancel());
      $("#open").style.opacity = 1;
      $("#reels").appendChild(solo);
      const from = stageRect(el);
      anim(solo, [{ transform: `translate(${from.x - (960 - 118)}px, ${from.y - (480 - 105.5)}px) scale(${from.w / 236})` }, { transform: "none" }], { duration: 450, easing: "cubic-bezier(.3,.9,.4,1)" });
      el.style.visibility = "hidden";
      await wait(480);
      if (my !== token) return;
      await goldMoment(res, solo.firstElementChild, true);
      if (my !== token) return;
      await wait(2200);
      if (my !== token) return;
      // back into its place in the grid
      const extras = [...result.children].filter((x) => x !== holder);
      extras.forEach((x) => anim(x, [{ opacity: 1 }, { opacity: 0 }], { duration: 350 }));
      anim($("#open"), [{ opacity: 1 }, { opacity: 0 }], { duration: 300 });
      FX.clear("back");
      FX.clear("front");
      darken(0, 400);
      await wait(360);
      extras.forEach((x) => x.remove());
      el.innerHTML = cardHTML(res.id, { kind: "big", w: slot.w, h, noName: true });
      el.style.visibility = "";
      holder.style.opacity = 1;
      const lbl = document.createElement("div");
      const fs = count === 3 ? 46 : 28;
      lbl.innerHTML = `<div style="position:absolute;left:${slot.cx - slot.w / 2}px;top:${slot.cy + h / 2 + 10}px">${rarityTitleHTML("Legendary", slot.w)}</div>
        <div class="gt" style="position:absolute;left:${slot.cx - 200}px;width:400px;text-align:center;top:${slot.cy + h / 2 + 18 + slot.w / 10.3771}px;font-size:${fs}px;--o:${count === 3 ? 4 : 3}px">${res.item.name}</div>`;
      holder.appendChild(lbl);
      if (i === best) el.insertAdjacentHTML("beforeend", `<div class="ribbon gt">BEST</div>`);
      anim(el, [{ transform: "scale(1.3)", filter: "brightness(2)" }, { transform: "none", filter: "none" }], { duration: 420, easing: "cubic-bezier(.3,1.4,.6,1)" });
      rarityFX("Legendary", slot.cx, slot.cy, false);
      stage.classList.remove("cinema");
    }

    // the pack's summary
    const byR = {};
    results.forEach((r) => (byR[r.item.r] = (byR[r.item.r] || 0) + 1));
    const news = results.filter((r) => r.isNew).length;
    const sum = document.createElement("div");
    sum.className = "summary";
    sum.style.top = count === 3 ? "760px" : "800px";
    sum.innerHTML = RANKED.filter((r) => byR[r]).map((r) => `<div class="s gt" style="--rc:${R[r].c}"><b></b>${byR[r]} ${r}</div>`).join("") + (news ? `<div class="s gt" style="background:#ff4d4d">${news} new</div>` : "");
    result.appendChild(sum);
    anim(sum, [{ opacity: 0 }, { opacity: 1 }], { duration: 300 });
    addButtons(count, count === 3 ? 870 : 880);
  }

  // ------------------------------------------------------------------------------------------------- skip and keys
  const doSkip = () => { if (stage.classList.contains("canskip")) { skipRequested = true; stage.classList.remove("canskip"); Sound.play("Button_Click", { vol: 0.6 }); } };
  bindBtn($("#skip"), doSkip);
  window.addEventListener("keydown", (e) => {
    if (e.code !== "Space" || /input|textarea|select/i.test(e.target.tagName)) return;
    e.preventDefault();
    if (window.Crate3D && window.Crate3D.isWaiting()) window.Crate3D.tap();
    else if (stage.classList.contains("canskip")) doSkip();
    else if ($("#cont")) $("#cont").click();
  });

  // ---------------------------------------------------------------------------------------------------- FX canvases
  FX.setup("back", $("#fxBack"));
  FX.setup("front", $("#fxFront"));
  FX.setup("amb", $("#showcase .sc-parts"));

  // ------------------------------------------------------------------------------------------------ review controls
  const FORCE = [["random", "Random (real odds)"], ["Uncommon", "Uncommon"], ["Rare", "Rare"], ["Epic", "Epic"], ["Legendary", "Legendary"],
    ["BlackHoleGrenade", "Black hole grenade"], ["VarietyGrenade", "Variety grenade"], ["Skin_Skeleton", "Skeleton skin"], ["LowGravityPotion", "Low gravity potion"]];
  const HOME = { BlackHoleGrenade: "Weapon", VarietyGrenade: "Weapon", Skin_Skeleton: "Skin", LowGravityPotion: "Utility" };
  $("#forceGrp").insertAdjacentHTML("beforeend", FORCE.map(([k, t]) => `<button class="pill" data-force="${k}" aria-pressed="${k === "random"}">${t}</button>`).join(""));
  $$("#forceGrp .pill").forEach((b) => b.addEventListener("click", () => {
    state.force = b.dataset.force;
    $$("#forceGrp .pill").forEach((x) => x.setAttribute("aria-pressed", String(x === b)));
    const home = HOME[state.force];
    if (home && !(CRATES[state.crate].odds[state.pay] || {})[state.force] && !state.busy) selectCrate(home);
  }));
  $("#dQuick").addEventListener("click", () => setQuick(!state.quick));
  $("#dMute").addEventListener("click", (e) => { const m = e.currentTarget.getAttribute("aria-pressed") !== "true"; e.currentTarget.setAttribute("aria-pressed", String(m)); Sound.setMuted(m); });
  $("#dVol").addEventListener("input", (e) => Sound.setVol(e.target.value / 100));
  $("#dRefill").addEventListener("click", () => { state.bal.Coins = 5000; state.bal.Diamonds = 5000; renderBalance(); });

  // ----------------------------------------------------------------------------------------------------- sound board
  const GROUPS = [
    ["The reel", ["Crate_Tick", "Crate_Land", "Crate_Settle", "Crate_Spin"]],
    ["The crate", ["Crate_Shake", "Crate_Unlock", "Crate_Tease", "Crate_GoldHit", "Crate_Premium"]],
    ["Reveals", ["Reveal_Common", "Reveal_Uncommon", "Reveal_Rare", "Reveal_Epic", "Reveal_Legendary", "Reveal_Shiny"]],
    ["Legendary drops", ["Legend_BlackHole", "Legend_Variety", "Legend_Skeleton", "Legend_LowGravity"]],
    ["Results", ["Card_Flip", "Results_Open"]],
  ];
  const WHERE = {
    Crate_Tick: "Each card crossing the line. Thins out as the reel slows.", Crate_Land: "The reel stops.", Crate_Settle: "The line eases onto the card's centre.",
    Crate_Spin: "Three and ten packs, as their reels start; the golden reel.", Crate_Shake: "The crate rattling before it opens.",
    Crate_Unlock: "The crate bursting open into the reel.", Crate_Tease: "Under an epic or legendary in the roll's last 2.6 s.",
    Crate_GoldHit: "The reel lands on the gold star card.", Crate_Premium: "Picking the Premium tab.",
    Reveal_Common: "A common drop.", Reveal_Uncommon: "An uncommon drop.", Reveal_Rare: "A rare drop.", Reveal_Epic: "An epic drop.",
    Reveal_Legendary: "A legendary without its own call (for later ones).", Reveal_Shiny: "The copy that makes an item shiny.",
    Legend_BlackHole: "Black hole grenade's drop.", Legend_Variety: "Variety grenade's drop.", Legend_Skeleton: "Skeleton skin's drop.",
    Legend_LowGravity: "Low gravity potion's drop.", Card_Flip: "Each card of a ten pack being named.", Results_Open: "A pack's winners leaving their reels.",
  };
  const KIND = (n) => (/Tick|Land|Settle/.test(n) ? "Refined synthesis" : "Classic soundscape");
  const PLAY = '<svg viewBox="0 0 12 12"><path d="M2 1 L11 6 L2 11 Z" fill="currentColor"/></svg>';
  $("#soundCols").innerHTML = GROUPS.map(([g, names]) => `<div class="snd-group"><h3>${g}</h3>${names.map((n) => `
    <div class="snd"><button class="play" data-snd="${n}" aria-label="Play ${n}">${PLAY}</button>
      <div style="min-width:0"><div class="nm">${n.replace(/_/g, " ")}</div><div class="wh">${WHERE[n] || ""} <span style="opacity:.75">${KIND(n)}.</span></div></div>
      <div class="len">${A.sndInfo[n] ? A.sndInfo[n].seconds.toFixed(2) + " s" : ""}</div></div>`).join("")}
    ${g === "The reel" ? `<div class="snd"><button class="play" data-run="1" aria-label="Play a tick run">${PLAY}</button><div style="min-width:0"><div class="nm">Tick run</div><div class="wh">The ticks at CS:GO's own timing: 16 a second, then thinning out over 5 s.</div></div><div class="len">5.00 s</div></div>` : ""}</div>`).join("");
  $$("#soundCols .play").forEach((b) => b.addEventListener("click", async () => {
    await Sound.init();
    if (b.dataset.run) {
      const times = [];
      for (let t = 0; t <= 1.375; t += 0.0625) times.push(t);
      times.push(1.62, 1.70, 1.79, 1.87, 2.0, 2.15, 2.31, 2.47, 2.62, 2.77, 2.94, 3.10, 3.34, 3.63, 3.95, 4.39, 5.0);
      times.forEach((t) => Sound.play("Crate_Tick", { delay: t, vol: 0.85, rate: rnd(0.975, 1.035) }));
      Sound.play("Crate_Land", { delay: 5.25 });
      return;
    }
    Sound.play(b.dataset.snd);
  }));

  // ------------------------------------------------------------------------------------------------------ icon sheet
  const menu = [["STYLE", "Menu_Style"], ["WEAPONS", "Crate_Weapon"], ["SKINS", "Crate_Skin"]];
  $("#menuDemo").innerHTML = menu.map(([t, ic]) => `<div class="menu-btn">${L("menu_stroke2", 0, 0, 1, 1, DARK)}${L("menu_main", 0.0083, 0.0472, 0.9833, 0.9057, DARK)}
    ${L("menu_stroke", 0.0164, 0.0189, 0.9672, 0.9623, "#828282")}<img class="ico" src="${A.svg[ic]}" alt=""><div class="txt gt">${t}</div></div>`).join("");
  const ICONS = [
    ["Crate_Weapon", "Weapon crate", "Olive army crate, steel corners, a stencilled crosshair. Amber embers on its pedestal.", "#ffb347"],
    ["Crate_Premium", "Premium crate", "Obsidian chest, gold trim, a glowing seam and a cut diamond. Cyan and gold glow, glints and a halo.", "#5ce1ff"],
    ["Crate_Utility", "Utility crate", "Teal steel supply case with a hazard band, latches and a gear-and-plus stencil. Bubbles.", "#3ff0c0"],
    ["Crate_Skin", "Skin crate", "Pink crate wrapped in a gold ribbon and bow, a snail-shell seal. Pink sparkles.", "#ff6ad5"],
    ["Crate_Starter", "Starter crate", "Plain pine crate with a green star, for the tutorial's free crate.", "#9be15d"],
    ["Menu_Style", "STYLE button", "A shell with a paintbrush, for the lobby's customise button.", "#ff7ac4"],
  ];
  const STANDS = ["Item_OnePunch", "Item_BaseballBat", "Item_Parachute", "Skin_Soldier", "Skin_Pirate", "Skin_Cowboy", "Skin_Ninja", "Skin_Knight", "Skin_Clown", "Skin_Robot", "Skin_Devil", "Skin_Skeleton"];
  $("#iconGrid").innerHTML = ICONS.map(([k, t, d, c]) => `<div class="ic"><div class="pv" style="background:radial-gradient(closest-side, ${c}55, transparent 75%), #10141c"><img src="${A.svg[k]}" alt="${t}"></div><b>${t}</b><span>${d}</span></div>`).join("")
    + STANDS.map((k) => `<div class="ic"><div class="pv" style="background:#10141c"><img src="${A.svg[k]}" alt="${k}"></div><b>${k.replace("Item_", "").replace("Skin_", "Skin: ").replace(/([a-z])([A-Z])/g, "$1 $2")}</b><span>Stand-in for this preview</span></div>`).join("");

  // ----------------------------------------------------------------------------------------------------------- notes
  $("#notes").innerHTML = `
    <div class="note"><h3>New: the 3D crates</h3><ul>
      <li><b>Real 3D crates</b> (made in Blender, in the game's model look: chunky bevelled parts, flat bright colours, the Roblox stud) drop onto the screen when you buy. In the game they sit in a ViewportFrame, so they're lit the way a ViewportFrame lights things; the glows, beams and sparks stay the 2D effects.</li>
      <li><b>TAP TO OPEN:</b> the crate rattles with its hatches straining, the hatches spring open with a shaft of light, then the walls fall outward, a ball of light rises out of it and swells into the flash that starts the reel.</li>
      <li><b>x3:</b> one crate in front, two behind. <b>x10:</b> a pyramid of 1, 2, 3 and 4. One tap opens them all, front first.</li>
      <li><b>A legendary</b> lands as the gold card, then a golden crate (the same crate, glowing gold, on gold rays) pops out: tap it, it opens the same way, and the golden reel and the item's own drop follow.</li>
      <li><b>Quick open</b> skips the tap and plays the opening faster.</li>
    </ul></div>
    <div class="note"><h3>Taken from CS:GO</h3><ul>
      <li><b>The reel:</b> a strip of 38 cards running right to left under a fixed line, on CS2's own curve (fast, then a long creep, 6 s).</li>
      <li><b>Honest near misses:</b> the line stops anywhere from 10% to 90% across the winning card, as CS does, so close calls happen by themselves. Nothing is placed next to the winner.</li>
      <li><b>The lens:</b> the card under the line is shown sharp and slightly larger; the rest of the strip is dimmed.</li>
      <li><b>Rhythm:</b> ticks follow the cards, fast at first and thinning out, then a moment of quiet before the reveal.</li>
      <li><b>The gold card:</b> legendaries never appear as filler. The gold star card only shows when it's yours, then a golden reel picks which one, as CS does with knives.</li>
    </ul></div>
    <div class="note"><h3>Ours</h3><ul>
      <li><b>The GACHA screen's own frames, font and buttons.</b> Opening keeps the screen and turns it: the odds slide away, the crate comes forward, rattles and bursts into the reel.</li>
      <li><b>x3:</b> three stacked reels on one line. <b>x10:</b> ten columns falling top to bottom on a horizontal line.</li>
      <li><b>Rarest stops last</b> in a pack, then the winners leave their reels for a row or grid, named one by one, the best last with a BEST ribbon.</li>
      <li><b>A reveal for every rarity,</b> growing from a puff (uncommon) to flash, shake and rays (epic). Each legendary has its own drop.</li>
      <li><b>Skip</b> (button or Space) and <b>Quick open</b> for players who open a lot.</li>
    </ul></div>
    <div class="note"><h3>Premium feels premium</h3><ul>
      <li>Gold-edged PREMIUM tab with a diamond and a slow sheen, and a soft shimmer sound when picked.</li>
      <li>Deep violet backdrop, cyan and gold glow, a turning gold halo and diamond glints round the crate; a gold PREMIUM tag.</li>
      <li>Diamond prices turn the buy buttons blue with a gold rim and a sheen, on any crate paid in diamonds.</li>
      <li>While opening: gold-and-cyan reel edges and a pale gold line.</li>
      <li>Coin crates stay plain: green buttons, one warm glow, STANDARD tag.</li>
    </ul></div>
    <div class="note"><h3>Please confirm</h3><ul>
      <li>The layout, the crate icons and the themes.</li>
      <li>x10 as ten falling columns (x3 as stacked reels).</li>
      <li>The heartbeat only plays for epic and legendary, so it does hint that something big is coming. Keep it, or also play it sometimes on smaller drops?</li>
      <li>Rarest-stops-last in packs.</li>
      <li>The sound set. Once approved: the sounds are uploaded to The Snail Studio, the icons are uploaded, and CrateOpen is rebuilt from the GACHA design's pictures.</li>
    </ul></div>`;
  $("#rarityTable").innerHTML = `<h3>Rarity steps</h3><table><thead><tr><th>Rarity</th><th>On the reel</th><th>Reveal</th><th>Sound</th></tr></thead><tbody>
    <tr><td><span class="sw" style="--c:${R.Uncommon.c}"></span>Uncommon</td><td>Green outline and glow</td><td>Green ring, sparkles</td><td>Three harp notes up</td></tr>
    <tr><td><span class="sw" style="--c:${R.Rare.c}"></span>Rare</td><td>Blue outline and glow</td><td>Two blue rings, sparks, slow rays</td><td>Harp arpeggio into piano, chimes</td></tr>
    <tr><td><span class="sw" style="--c:${R.Epic.c}"></span>Epic</td><td>Purple; the heartbeat as it slows in</td><td>Purple flash, shake, fast rays, sparks</td><td>Snare into a brass chord, choir and crash</td></tr>
    <tr><td><span class="sw" style="--c:${R.Legendary.c}"></span>Legendary</td><td>Gold star card, then a golden reel</td><td>Its own drop: black hole, confetti party, graveyard, floating</td><td>Gold hit, then its own call</td></tr>
    </tbody></table>`;

  // ------------------------------------------------------------------------------------------------------------ start
  refreshShop();
  setQuick(false);
  if (document.fonts) document.fonts.ready.then(() => fitText(document));

  // Test hook for headless checks (?auto=3&force=Epic&crate=Weapon&pay=Coins&quick=1); a published page gets no query
  const q = new URLSearchParams(location.search);
  if (q.get("auto") || q.get("crate")) {
    setTimeout(() => {
      if (q.get("crate")) selectCrate(q.get("crate"));
      if (q.get("pay") && CRATES[state.crate].prices[q.get("pay")]) { state.pay = q.get("pay"); refreshShop(); }
      if (q.get("force")) state.force = q.get("force");
      if (q.get("quick")) setQuick(true);
      if (COUNTS.includes(+q.get("auto"))) buy(+q.get("auto"));
    }, 400);
  }
})();
