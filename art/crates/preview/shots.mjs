// Real-time screenshots of the preview through Chrome's DevTools protocol, for checking motion frame by frame.
// Serve this folder first (python -m http.server 8765 --bind 127.0.0.1), then:
// node shots.mjs <name> "<query>" <ms,ms,...> ["selector@ms" ...]   -> shots/<name>_<ms>.jpg
// The query drives the page's test hook: auto=1|3|10, force=<rarity or item id>, crate=<id>, pay=Coins|Diamonds, quick=1
import { spawn } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const CHROME = process.env.WB_BROWSER || "C:/Program Files/Google/Chrome/Application/chrome.exe";
const URL_BASE = process.env.PREVIEW_URL || "http://localhost:8765/local.html";
const [name, query, times, ...actions] = process.argv.slice(2);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
mkdirSync(`${HERE}/shots`, { recursive: true });

const port = 9300 + Math.floor(Math.random() * 500);
const chrome = spawn(CHROME, ["--headless=new", "--hide-scrollbars", "--mute-audio", "--autoplay-policy=no-user-gesture-required",
  `--user-data-dir=${tmpdir()}/wb_crate_shots_${port}`, `--remote-debugging-port=${port}`, "--window-size=1500,1000", "about:blank"], { stdio: "ignore" });
let target;
for (let i = 0; i < 40 && !target; i++) {
  await sleep(250);
  try { target = (await (await fetch(`http://127.0.0.1:${port}/json`)).json()).find((t) => t.type === "page"); } catch { /* not up yet */ }
}
const ws = new WebSocket(target.webSocketDebuggerUrl);
let id = 0;
const pending = new Map();
const logs = [];
ws.onmessage = (m) => {
  const d = JSON.parse(m.data);
  if (d.id && pending.has(d.id)) { pending.get(d.id)(d); pending.delete(d.id); }
  if (d.method === "Runtime.exceptionThrown") logs.push("EXC " + JSON.stringify(d.params.exceptionDetails).slice(0, 600));
  if (d.method === "Runtime.consoleAPICalled" && /error|warn/.test(d.params.type)) logs.push(d.params.type + " " + d.params.args.map((a) => a.value ?? a.description).join(" ").slice(0, 400));
};
await new Promise((r) => (ws.onopen = r));
const send = (method, params = {}) => new Promise((r) => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
await send("Runtime.enable");
await send("Page.enable");
await send("Emulation.setDeviceMetricsOverride", { width: 1500, height: 1000, deviceScaleFactor: 1, mobile: false });
await send("Page.navigate", { url: `${URL_BASE}?${query}` });
await sleep(900);
const rect = JSON.parse((await send("Runtime.evaluate", { expression: "JSON.stringify(document.querySelector('#stageWrap').getBoundingClientRect())", returnByValue: true })).result.result.value);
const t0 = Date.now();
const plan = times.split(",").map((t) => ({ t: +t, kind: "shot" }));
for (const a of actions) { const [sel, at] = a.split("@"); plan.push({ t: +at, kind: "click", sel }); }
plan.sort((a, b) => a.t - b.t);
for (const step of plan) {
  const left = step.t - (Date.now() - t0);
  if (left > 0) await sleep(left);
  if (step.kind === "click") {
    await send("Runtime.evaluate", { expression: `(() => { const e = document.querySelector(${JSON.stringify(step.sel)}); if (e) e.click(); return !!e; })()` });
    continue;
  }
  const shot = await send("Page.captureScreenshot", { format: "jpeg", quality: 82, clip: { x: rect.x, y: rect.y, width: rect.width, height: rect.height, scale: 0.7 } });
  writeFileSync(`${HERE}/shots/${name}_${String(step.t).padStart(5, "0")}.jpg`, Buffer.from(shot.result.data, "base64"));
}
console.log(logs.length ? logs.join("\n") : "no errors");
ws.close();
chrome.kill();
