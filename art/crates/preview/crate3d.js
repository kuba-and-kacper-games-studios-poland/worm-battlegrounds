/* The 3D crates for the crate opening preview: the GLB models from make_models.py, drawn the way a Roblox
   ViewportFrame can draw them (one ambient and one directional light, no shadows, no bloom; glows and sparks stay
   the 2D effects). app.js drives it: show() drops the crates in, waitTap() waits for the player, open() plays the
   opening, hide() clears it. Each step reports screen points (in the stage's 1920 x 1080 units) for the 2D effects. */
import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";

const W = 1920, H = 1080;
const canvas = document.getElementById("crate3d");
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(2, window.devicePixelRatio || 1));
renderer.setSize(W, H, false);
renderer.outputColorSpace = THREE.SRGBColorSpace;

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(26, W / H, 0.1, 300);
// a ViewportFrame's light: Ambient plus one LightColor from LightDirection
const ambient = new THREE.AmbientLight(0xffffff, 1.35);
const sun = new THREE.DirectionalLight(0xffffff, 2.1);
sun.position.set(-5, 9, 7);
scene.add(ambient, sun);

// --------------------------------------------------------------------------------------------- the stud pattern
// The game's models wear the Roblox stud: a faint L in each tile. Here it multiplies each part's colour; UVs are in
// studs, so two tiles a stud.
function studTexture() {
  const c = document.createElement("canvas");
  c.width = c.height = 128;
  const g = c.getContext("2d");
  g.fillStyle = "#ffffff";
  g.fillRect(0, 0, 128, 128);
  g.fillStyle = "rgba(0,0,0,0.07)";
  g.fillRect(0, 124, 128, 4);
  g.fillRect(124, 0, 4, 128);
  g.fillStyle = "rgba(255,255,255,1)";
  g.fillRect(0, 0, 128, 3);
  g.strokeStyle = "rgba(0,0,0,0.16)";
  g.lineWidth = 7;
  g.lineCap = "square";
  g.beginPath();
  g.moveTo(34, 30);
  g.lineTo(34, 78);
  g.lineTo(82, 78);
  g.stroke();
  const t = new THREE.CanvasTexture(c);
  t.wrapS = t.wrapT = THREE.RepeatWrapping;
  t.repeat.set(2, 2);
  t.colorSpace = THREE.SRGBColorSpace;
  t.anisotropy = 8;
  return t;
}
const STUD = studTexture();

function shadowTexture() {
  const c = document.createElement("canvas");
  c.width = c.height = 128;
  const g = c.getContext("2d");
  const gr = g.createRadialGradient(64, 64, 4, 64, 64, 62);
  gr.addColorStop(0, "rgba(0,0,0,0.55)");
  gr.addColorStop(1, "rgba(0,0,0,0)");
  g.fillStyle = gr;
  g.fillRect(0, 0, 128, 128);
  const t = new THREE.CanvasTexture(c);
  t.colorSpace = THREE.SRGBColorSpace;
  return t;
}
const SHADOW = shadowTexture();

function glowTexture() {
  const c = document.createElement("canvas");
  c.width = c.height = 128;
  const g = c.getContext("2d");
  const gr = g.createRadialGradient(64, 64, 0, 64, 64, 64);
  gr.addColorStop(0, "rgba(255,255,255,1)");
  gr.addColorStop(0.25, "rgba(255,255,255,0.55)");
  gr.addColorStop(1, "rgba(255,255,255,0)");
  g.fillStyle = gr;
  g.fillRect(0, 0, 128, 128);
  const t = new THREE.CanvasTexture(c);
  t.colorSpace = THREE.SRGBColorSpace;
  return t;
}
const GLOWTEX = glowTexture();

// The orb of light that rises out of an opened crate (in the game: a Neon ball, with a 2D glow over it)
function makeOrb(color) {
  const orb = new THREE.Group();
  const ball = new THREE.Mesh(new THREE.IcosahedronGeometry(0.62, 2), new THREE.MeshBasicMaterial({ color: new THREE.Color(color).lerp(new THREE.Color(0xffffff), 0.55) }));
  const halo = new THREE.Sprite(new THREE.SpriteMaterial({ map: GLOWTEX, color: new THREE.Color(color), blending: THREE.AdditiveBlending, depthWrite: false, transparent: true }));
  halo.scale.setScalar(4.2);
  orb.add(halo, ball);
  orb.visible = false;
  return orb;
}

// --------------------------------------------------------------------------------------------------- the models
const loader = new GLTFLoader();
const cache = {};
async function model(name) {
  if (!cache[name]) cache[name] = loader.loadAsync(`3d/Crate_${name}.glb`).then((g) => g.scene);
  return cache[name];
}

const PART = /^(HatchL|HatchR|Front|Back|Left|Right|Inner|Base)/;

function dressMaterial(m) {
  if (/_Glow/.test(m.name)) {
    return new THREE.MeshStandardMaterial({ name: m.name, color: 0xfff3c8, emissive: 0xffe08a, emissiveIntensity: 1.1, roughness: 1 });
  }
  const shiny = /_(Metal|Rivet|Gem|Emblem|Stripe|Ribbon|Cross)$/.test(m.name);
  return new THREE.MeshStandardMaterial({ name: m.name, color: m.color.clone(), map: STUD, roughness: shiny ? 0.38 : 0.62, metalness: 0, emissive: 0x000000 });
}

async function makeCrate(name) {
  const src = await model(name);
  const root = src.clone(true);
  const parts = {};
  const mats = [];
  root.traverse((o) => {
    const m = PART.exec(o.name);
    if (m && !parts[m[1]]) parts[m[1]] = o;
    if (o.isMesh) {
      o.material = Array.isArray(o.material) ? o.material.map(dressMaterial) : dressMaterial(o.material);
      (Array.isArray(o.material) ? o.material : [o.material]).forEach((x) => mats.push(x));
    }
  });
  // the model's root is the crate's empty; centre it on its footprint
  const holder = new THREE.Group();
  const shadow = new THREE.Mesh(new THREE.PlaneGeometry(7.2, 5.8), new THREE.MeshBasicMaterial({ map: SHADOW, transparent: true, depthWrite: false }));
  shadow.rotation.x = -Math.PI / 2;
  shadow.position.y = 0.01;
  const body = new THREE.Group();
  body.add(root);
  holder.add(shadow, body);
  return { holder, body, root, parts, mats, shadow };
}

// ------------------------------------------------------------------------------------------------------ layouts
// One crate in the middle; a 3-pack as one in front and two behind; a 10-pack as a pyramid of 1, 2, 3 and 4 rows.
function layout(count) {
  if (count === 1) return { at: [[0, 0, 0]], scale: 1, cam: [0, 7.2, 16.2], look: [0, 1.3, 0], yaw: -0.5 };
  if (count === 3) return { at: [[0, 0, 2.4], [-4.3, 0, -2.0], [4.3, 0, -2.0]], scale: 0.88, cam: [0, 9.5, 22.5], look: [0, 1.0, -0.2], yaw: -0.3 };
  const rows = [[0], [-2.6, 2.6], [-5.2, 0, 5.2], [-7.8, -2.6, 2.6, 7.8]];
  const at = [];
  rows.forEach((xs, r) => xs.forEach((x) => at.push([x, 0, 5.2 - r * 3.9])));
  return { at, scale: 0.78, cam: [0, 13.5, 30.5], look: [0, 0.6, -1.6], yaw: -0.22 };
}

// ---------------------------------------------------------------------------------------------------- the stage
const ease = {
  outBack: (t, s = 1.70158) => 1 + (s + 1) * Math.pow(t - 1, 3) + s * Math.pow(t - 1, 2),
  outCubic: (t) => 1 - Math.pow(1 - t, 3),
  inCubic: (t) => t * t * t,
  outBounce: (t) => {
    const n = 7.5625, d = 2.75;
    if (t < 1 / d) return n * t * t;
    if (t < 2 / d) return n * (t -= 1.5 / d) * t + 0.75;
    if (t < 2.5 / d) return n * (t -= 2.25 / d) * t + 0.9375;
    return n * (t -= 2.625 / d) * t + 0.984375;
  },
};
const clamp01 = (x) => Math.max(0, Math.min(1, x));

let crates = [];
let golden = false;
let idle = true;
let waiting = null;
let clock0 = performance.now();

function project(v) {
  const p = v.clone().project(camera);
  return { x: (p.x + 1) / 2 * W, y: (1 - p.y) / 2 * H };
}
function points(which = "centre") {
  return crates.map((c) => {
    const box = new THREE.Box3().setFromObject(c.root);
    const centre = box.getCenter(new THREE.Vector3());
    const top = new THREE.Vector3(centre.x, box.max.y, centre.z);
    const p = project(which === "top" ? top : centre);
    p.scale = c.scale;
    return p;
  });
}

function setGold(c, k) {
  for (const m of c.mats) {
    if (/_Glow/.test(m.name)) continue;
    m.emissive.setRGB(1.0 * k, 0.72 * k, 0.12 * k);
  }
}

function frame() {
  const ms = now();
  const t = (ms - clock0) / 1000;
  for (const c of crates) {
    if (c.anim) c.anim(ms);
    else if (idle) {
      c.body.position.y = 0.08 + Math.sin(t * 2.1 + c.phase) * 0.08;
      c.body.rotation.y = Math.sin(t * 0.8 + c.phase) * 0.1;
      c.body.rotation.z = Math.sin(t * 1.3 + c.phase) * 0.012;
      // the light inside leaks through the hatches' seam
      const glow = c.mats.find((m) => /_Glow/.test(m.name));
      if (glow) glow.emissiveIntensity = 1.0 + Math.sin(t * 3 + c.phase) * 0.35;
      if (waiting) {
        const beat = Math.pow(Math.max(0, Math.sin(t * Math.PI * 1.6)), 8);
        c.body.scale.setScalar(1 + beat * 0.035);
        const lift = beat * 0.05;
        c.parts.HatchL.rotation.z = lift;
        c.parts.HatchR.rotation.z = -lift;
      }
    }
    if (golden) setGold(c, 0.16 + Math.sin(t * 4 + c.phase) * 0.07);
  }
  renderer.render(scene, camera);
  if (crates.length) requestAnimationFrame(frame);
}

async function show({ crate, count, gold = false, quick = false, color = "#ffcc66", onLand }) {
  hide();
  golden = gold;
  const L = layout(count);
  camera.position.set(...L.cam);
  camera.lookAt(new THREE.Vector3(...L.look));
  const made = await Promise.all(L.at.map(() => makeCrate(crate)));
  crates = made.map((c, i) => {
    const [x, y, z] = L.at[i];
    c.holder.position.set(x, y, z);
    c.holder.scale.setScalar(L.scale);
    c.holder.rotation.y = L.yaw + (count > 1 ? (x / 10) * -0.35 : 0);
    c.scale = L.scale;
    c.phase = i * 1.37;
    c.index = i;
    c.orb = makeOrb(color);
    c.orb.position.set(0, 1.2, 0);
    c.holder.add(c.orb);
    // the light inside takes the crate's colour
    const glow = c.mats.find((m) => /_Glow/.test(m.name));
    if (glow) { glow.color.set(color).lerp(new THREE.Color(0xffffff), 0.55); glow.emissive.set(color).lerp(new THREE.Color(0xffffff), 0.3); }
    scene.add(c.holder);
    return c;
  });
  canvas.classList.add("on");
  clock0 = performance.now();
  idle = true;
  requestAnimationFrame(frame);

  // the crates drop in, front ones last, and land with a bounce
  const order = crates.map((c, i) => i).sort((a, b) => crates[a].holder.position.z - crates[b].holder.position.z);
  const dropMs = quick ? 360 : 620;
  const gap = count === 10 ? 55 : count === 3 ? 110 : 0;
  await Promise.all(order.map((i, k) => new Promise((done) => {
    const c = crates[i];
    const t0 = performance.now() + k * gap;
    const spin = (Math.random() - 0.5) * 0.9;
    let landed = false;
    c.body.position.y = 9;
    c.shadow.material.opacity = 0;
    c.anim = (now) => {
      const t = clamp01((now - t0) / dropMs);
      c.body.position.y = 9 * (1 - ease.outBounce(t));
      c.body.rotation.y = spin * (1 - ease.outCubic(t));
      c.shadow.material.opacity = ease.outCubic(t);
      const squash = t > 0.36 && t < 0.62 ? Math.sin((t - 0.36) / 0.26 * Math.PI) * 0.1 : 0;
      c.body.scale.set(1 + squash * 0.6, 1 - squash, 1 + squash * 0.6);
      if (!landed && t >= 0.364) {
        landed = true;
        if (onLand) onLand(points("centre")[i], k);
      }
      if (t >= 1) { c.anim = null; c.body.scale.setScalar(1); done(); }
    };
  })));
}

function waitTap() {
  return new Promise((resolve) => {
    waiting = resolve;
    canvas.classList.add("tap");
  });
}
function tap() {
  if (!waiting) return false;
  const r = waiting;
  waiting = null;
  canvas.classList.remove("tap");
  crates.forEach((c) => { c.body.scale.setScalar(1); c.parts.HatchL.rotation.z = 0; c.parts.HatchR.rotation.z = 0; });
  r();
  return true;
}
canvas.addEventListener("pointerdown", () => tap());
canvas.addEventListener("click", () => tap());

// The opening, on every crate at once (front first): it rattles with its hatches straining, the hatches spring open,
// then the walls fall outward and the light inside flares.
async function open({ quick = false, onRattle, onHatch, onBurst } = {}) {
  idle = false;
  const k = quick ? 0.55 : 1;
  const RATTLE = 520 * k, HATCH = 300 * k, WALLS = 380 * k, SWELL = 240 * k;
  const swellTo = crates.length === 10 ? 0.5 : crates.length === 3 ? 1.0 : 1.8;
  const order = crates.map((c, i) => i).sort((a, b) => crates[b].holder.position.z - crates[a].holder.position.z);
  const gap = crates.length === 10 ? 60 * k : crates.length === 3 ? 120 * k : 0;
  openStart = realNow();
  if (onRattle) onRattle(points("centre"));
  await Promise.all(order.map((i, n) => new Promise((done) => {
    const c = crates[i];
    const t0 = performance.now() + n * gap;
    const glow = c.mats.find((m) => /_Glow/.test(m.name));
    let hatched = false, burst = false;
    c.anim = (now) => {
      const ms = now - t0;
      if (ms < 0) return;
      // the rattle: harder and faster, the hatches lifting against their latches
      if (ms < RATTLE) {
        const t = ms / RATTLE;
        const amp = 0.025 + t * 0.07;
        c.body.rotation.z = Math.sin(ms * 0.055) * amp;
        c.body.rotation.x = Math.sin(ms * 0.041 + 1) * amp * 0.5;
        c.body.position.y = Math.abs(Math.sin(ms * 0.055)) * 0.12 * (0.4 + t);
        const strain = Math.max(0, Math.sin(ms * 0.11)) * (0.05 + t * 0.12);
        c.parts.HatchL.rotation.z = strain;
        c.parts.HatchR.rotation.z = -strain;
        c.body.scale.set(1 + t * 0.04, 1 - t * 0.06, 1 + t * 0.04);
        if (glow) glow.emissiveIntensity = 1.2 + t * 2;
        return;
      }
      c.body.rotation.z = 0;
      c.body.rotation.x = 0;
      // the hatches spring open
      const th = clamp01((ms - RATTLE) / HATCH);
      const hatchA = 2.25 * ease.outBack(th, 2.2);
      c.parts.HatchL.rotation.z = hatchA;
      c.parts.HatchR.rotation.z = -hatchA;
      c.body.scale.set(1 + 0.04 * (1 - th), 1 - 0.06 * (1 - th) + Math.sin(th * Math.PI) * 0.08, 1 + 0.04 * (1 - th));
      c.body.position.y = Math.sin(th * Math.PI) * 0.35;
      if (!hatched) { hatched = true; if (onHatch) onHatch(points("top")[i], n); }
      // then the walls fall outward, the light inside flaring
      const tw = clamp01((ms - RATTLE - HATCH * 0.55) / WALLS);
      const wallA = 1.62 * ease.outBounce(tw);
      c.parts.Front.rotation.x = wallA;
      c.parts.Back.rotation.x = -wallA;
      c.parts.Left.rotation.z = wallA;
      c.parts.Right.rotation.z = -wallA;
      if (glow) glow.emissiveIntensity = 3.2 + tw * 5;
      // the orb rises out of the crate, swelling, as the walls go down
      const to = clamp01((ms - RATTLE - HATCH * 0.2) / (HATCH * 0.8 + WALLS));
      // then it swells into the flash that hands over to the reels
      const ts = clamp01((ms - RATTLE - HATCH * 0.55 - WALLS) / SWELL);
      c.orb.visible = true;
      c.orb.position.y = 1.0 + ease.outCubic(to) * 2.6;
      c.orb.scale.setScalar(ease.outBack(Math.min(1, to * 1.6), 2.4) * (1 + Math.sin(ms * 0.03) * 0.06) * (1 + ease.inCubic(ts) * swellTo));
      c.orb.children[0].material.opacity = 0.6 + 0.4 * to;
      if (!burst && tw > 0.05) { burst = true; if (onBurst) onBurst(points("centre")[i], n); }
      if (ts >= 1) { c.anim = () => {}; done(); }
    };
  })));
}

function hide() {
  waiting = null;
  canvas.classList.remove("on", "tap");
  for (const c of crates) scene.remove(c.holder);
  crates = [];
  golden = false;
  renderer.clear();
}

// Review aid: Crate3D.freeze(ms) holds the scene's clock at ms after the next open() starts, for screenshots.
let freezeAt = null, openStart = 0;
const realNow = performance.now.bind(performance);
function now() { return freezeAt != null && openStart && realNow() - openStart > freezeAt ? openStart + freezeAt : realNow(); }
window.Crate3D = { show, waitTap, tap, open, hide, points, isWaiting: () => !!waiting, preload: (names) => Promise.all(names.map(model)),
  freeze: (ms) => { freezeAt = ms; openStart = 0; } };
window.__crate3dResolve(window.Crate3D);
