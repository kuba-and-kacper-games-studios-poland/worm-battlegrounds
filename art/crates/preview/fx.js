/* Particle effects for the crate preview: one small engine drawing on several canvases (behind the result, in
   front of everything, and the showcase's ambience). Shapes are drawn in the game's cartoon manner: inked bones,
   smileys and coins, glowing additive sparks and flames. */
const FX = (() => {
  const layers = {};
  const TAU = Math.PI * 2;
  const rnd = (a, b) => a + Math.random() * (b - a);
  const pick = (a) => a[(Math.random() * a.length) | 0];
  let last = performance.now();

  function setup(name, canvas) {
    layers[name] = { cv: canvas, ctx: canvas.getContext("2d"), parts: [], emitters: [], hooks: [] };
  }

  function add(layer, p) {
    const L = layers[layer];
    if (!L) return p;
    p.age = 0;
    p.rot = p.rot ?? rnd(0, TAU);
    p.vrot = p.vrot ?? rnd(-6, 6);
    p.drag = p.drag ?? 1.2;
    p.g = p.g ?? 0;
    p.add = p.add ?? true;
    p.alpha = p.alpha ?? 1;
    L.parts.push(p);
    return p;
  }

  function burst(layer, x, y, o) {
    const n = o.count || 30;
    for (let i = 0; i < n; i++) {
      const a = o.angle != null ? o.angle + rnd(-o.spread / 2, o.spread / 2) : rnd(0, TAU);
      const sp = rnd(o.speed[0], o.speed[1]);
      const j = o.jitter || 0;
      add(layer, {
        x: x + rnd(-j, j), y: y + rnd(-j, j), vx: Math.cos(a) * sp, vy: Math.sin(a) * sp,
        life: rnd(o.life[0], o.life[1]), size: rnd(o.size[0], o.size[1]), color: pick(o.colors),
        shape: o.shape || "dot", g: o.gravity || 0, drag: o.drag ?? 1.4, add: o.additive ?? true,
        fade: o.fade || "out", floor: o.floor, bounce: o.bounce, vrot: o.vrot != null ? rnd(-o.vrot, o.vrot) : undefined,
      });
    }
  }

  function ring(layer, x, y, o) {
    add(layer, { shape: "ring", x, y, vx: 0, vy: 0, r0: o.r0 ?? 30, r1: o.r1 ?? 420, life: o.life ?? 0.6,
      color: o.color, width: o.width ?? 12, size: 1, add: true });
  }

  function emitter(layer, o) {
    const e = { ...o, acc: 0, alive: true, t: 0 };
    layers[layer].emitters.push(e);
    return { stop() { e.alive = false; }, e };
  }

  function hook(layer, fn) {
    const h = { fn, alive: true };
    layers[layer].hooks.push(h);
    return { stop() { h.alive = false; } };
  }

  function clear(layer) {
    const L = layers[layer];
    if (!L) return;
    L.parts.length = 0;
    L.emitters.forEach((e) => (e.alive = false));
    L.emitters.length = 0;
    L.hooks.forEach((h) => (h.alive = false));
    L.hooks.length = 0;
    L.ctx.clearRect(0, 0, L.cv.width, L.cv.height);
  }

  function bolt(layer, x0, y0, x1, y1, o = {}) {
    const pts = [];
    const segs = 14;
    for (let i = 0; i <= segs; i++) {
      const t = i / segs;
      const off = i === 0 || i === segs ? 0 : rnd(-1, 1) * (o.jag ?? 60) * Math.sin(Math.PI * t);
      pts.push([x0 + (x1 - x0) * t + off, y0 + (y1 - y0) * t + rnd(-10, 10)]);
    }
    add(layer, { shape: "bolt", x: 0, y: 0, vx: 0, vy: 0, pts, life: o.life ?? 0.35, color: o.color ?? "#d8ffd0",
      size: o.width ?? 8, add: true });
  }

  // --- drawing ------------------------------------------------------------------------------------------------------

  function star(ctx, s) {
    ctx.beginPath();
    for (let i = 0; i < 8; i++) {
      const r = i % 2 === 0 ? s : s * 0.22;
      const a = (i / 8) * TAU;
      ctx.lineTo(Math.cos(a) * r, Math.sin(a) * r);
    }
    ctx.closePath();
  }

  function draw(ctx, p, t) {
    let a = p.fade === "inout" ? Math.sin(Math.PI * Math.min(1, t)) : p.fade === "twinkle"
      ? Math.max(0, Math.sin(Math.PI * t) * (0.6 + 0.4 * Math.sin(p.age * 18 + p.rot * 5))) : 1 - t * t;
    a *= p.alpha;
    if (a <= 0.003) return;
    ctx.globalAlpha = Math.min(1, a);
    ctx.globalCompositeOperation = p.add ? "lighter" : "source-over";
    const s = p.size;
    switch (p.shape) {
      case "dot": {
        ctx.fillStyle = p.color;
        ctx.globalAlpha = Math.min(1, a) * 0.28;
        ctx.beginPath(); ctx.arc(p.x, p.y, s * 2.4, 0, TAU); ctx.fill();
        ctx.globalAlpha = Math.min(1, a);
        ctx.beginPath(); ctx.arc(p.x, p.y, s, 0, TAU); ctx.fill();
        break;
      }
      case "spark": {
        const sp = Math.hypot(p.vx, p.vy);
        const len = Math.min(90, 6 + sp * 0.04);
        const nx = p.vx / (sp || 1), ny = p.vy / (sp || 1);
        ctx.strokeStyle = p.color; ctx.lineCap = "round"; ctx.lineWidth = s;
        ctx.beginPath(); ctx.moveTo(p.x, p.y); ctx.lineTo(p.x - nx * len, p.y - ny * len); ctx.stroke();
        break;
      }
      case "star": {
        ctx.save(); ctx.translate(p.x, p.y); ctx.rotate(p.rot * 0.2);
        ctx.fillStyle = p.color; star(ctx, s); ctx.fill();
        ctx.globalAlpha *= 0.35; ctx.beginPath(); ctx.arc(0, 0, s * 0.9, 0, TAU); ctx.fill();
        ctx.restore();
        break;
      }
      case "confetti": {
        ctx.save(); ctx.translate(p.x, p.y); ctx.rotate(p.rot);
        ctx.scale(1, Math.cos(p.rot * 2.3));
        ctx.fillStyle = p.color; ctx.fillRect(-s / 2, -s * 0.3, s, s * 0.6);
        ctx.restore();
        break;
      }
      case "bubble": {
        ctx.strokeStyle = p.color; ctx.lineWidth = Math.max(2, s * 0.14);
        ctx.beginPath(); ctx.arc(p.x, p.y, s, 0, TAU); ctx.stroke();
        ctx.fillStyle = p.color; ctx.globalAlpha *= 0.12; ctx.fill();
        ctx.globalAlpha = Math.min(1, a) * 0.9; ctx.fillStyle = "#fff";
        ctx.beginPath(); ctx.arc(p.x - s * 0.35, p.y - s * 0.4, s * 0.22, 0, TAU); ctx.fill();
        break;
      }
      case "bone": {
        ctx.save(); ctx.translate(p.x, p.y); ctx.rotate(p.rot);
        ctx.fillStyle = "#f4f0e2"; ctx.strokeStyle = "#14141c"; ctx.lineWidth = 4;
        const L = s, r = s * 0.22;
        ctx.beginPath();
        ctx.arc(-L / 2, -r * 0.8, r, 0, TAU); ctx.arc(-L / 2, r * 0.8, r, 0, TAU);
        ctx.arc(L / 2, -r * 0.8, r, 0, TAU); ctx.arc(L / 2, r * 0.8, r, 0, TAU);
        ctx.rect(-L / 2, -r * 0.7, L, r * 1.4);
        ctx.stroke(); ctx.fill();
        ctx.restore();
        break;
      }
      case "smiley": {
        ctx.save(); ctx.translate(p.x, p.y); ctx.rotate(p.rot * 0.5);
        ctx.fillStyle = "#ffd93b"; ctx.strokeStyle = "#14141c"; ctx.lineWidth = Math.max(3, s * 0.12);
        ctx.beginPath(); ctx.arc(0, 0, s, 0, TAU); ctx.fill(); ctx.stroke();
        ctx.fillStyle = "#14141c";
        ctx.beginPath(); ctx.ellipse(-s * 0.33, -s * 0.2, s * 0.12, s * 0.22, 0, 0, TAU); ctx.fill();
        ctx.beginPath(); ctx.ellipse(s * 0.33, -s * 0.2, s * 0.12, s * 0.22, 0, 0, TAU); ctx.fill();
        ctx.beginPath(); ctx.arc(0, s * 0.05, s * 0.55, 0.15 * Math.PI, 0.85 * Math.PI); ctx.lineWidth = Math.max(3, s * 0.12); ctx.stroke();
        ctx.restore();
        break;
      }
      case "flame": {
        const k = 1 - t * 0.7;
        const g = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, s * k);
        g.addColorStop(0, "rgba(235,255,230,0.95)"); g.addColorStop(0.35, p.color); g.addColorStop(1, "rgba(0,0,0,0)");
        ctx.fillStyle = g; ctx.beginPath(); ctx.arc(p.x, p.y, s * k, 0, TAU); ctx.fill();
        break;
      }
      case "coin": {
        ctx.save(); ctx.translate(p.x, p.y); ctx.scale(Math.max(0.12, Math.abs(Math.cos(p.rot * 1.6))), 1);
        ctx.fillStyle = "#ffcf33"; ctx.strokeStyle = "#14141c"; ctx.lineWidth = 3.5;
        ctx.beginPath(); ctx.arc(0, 0, s, 0, TAU); ctx.fill(); ctx.stroke();
        ctx.fillStyle = "#fff2a8"; ctx.beginPath(); ctx.arc(-s * 0.25, -s * 0.25, s * 0.3, 0, TAU); ctx.fill();
        ctx.restore();
        break;
      }
      case "ring": {
        const e = 1 - Math.pow(1 - t, 3);
        const r = p.r0 + (p.r1 - p.r0) * e;
        ctx.strokeStyle = p.color; ctx.lineWidth = p.width * (1 - t * 0.7);
        ctx.beginPath(); ctx.arc(p.x, p.y, r, 0, TAU); ctx.stroke();
        break;
      }
      case "bolt": {
        ctx.globalAlpha = Math.min(1, a) * (0.6 + 0.4 * Math.random());
        for (const [w, col] of [[s * 3.2, p.color], [s, "#ffffff"]]) {
          ctx.strokeStyle = col; ctx.lineWidth = w; ctx.lineJoin = "round"; ctx.lineCap = "round";
          ctx.beginPath(); p.pts.forEach(([x, y], i) => (i ? ctx.lineTo(x, y) : ctx.moveTo(x, y))); ctx.stroke();
        }
        break;
      }
      case "fog": {
        const g = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, s);
        g.addColorStop(0, p.color); g.addColorStop(1, "rgba(0,0,0,0)");
        ctx.fillStyle = g; ctx.beginPath(); ctx.arc(p.x, p.y, s, 0, TAU); ctx.fill();
        break;
      }
    }
  }

  function step(now) {
    const dt = Math.min(0.05, (now - last) / 1000);
    last = now;
    for (const name in layers) {
      const L = layers[name];
      const { ctx } = L;
      for (const e of L.emitters) {
        if (!e.alive) continue;
        e.t += dt;
        e.acc += dt * (typeof e.rate === "function" ? e.rate(e.t) : e.rate);
        while (e.acc >= 1) { e.acc -= 1; add(name, e.spawn(e.t)); }
        if (e.duration && e.t > e.duration) e.alive = false;
      }
      L.emitters = L.emitters.filter((e) => e.alive);
      for (const h of L.hooks) if (h.alive) h.fn(dt, now);
      L.hooks = L.hooks.filter((h) => h.alive);
      if (!L.parts.length && !L.dirty) continue;
      ctx.clearRect(0, 0, L.cv.width, L.cv.height);
      L.dirty = L.parts.length > 0;
      const keep = [];
      for (const p of L.parts) {
        p.age += dt;
        const t = p.age / p.life;
        if (t >= 1) continue;
        if (p.update) p.update(p, dt);
        else {
          const k = Math.exp(-p.drag * dt);
          p.vx *= k; p.vy *= k; p.vy += p.g * dt;
          p.x += p.vx * dt; p.y += p.vy * dt;
          if (p.wobble) p.x += Math.sin(p.age * p.wobble + p.rot * 3) * 30 * dt;
          if (p.floor && p.y > p.floor) { p.y = p.floor; p.vy *= -(p.bounce ?? 0.5); p.vx *= 0.8; }
        }
        p.rot += p.vrot * dt;
        draw(ctx, p, t);
        keep.push(p);
      }
      ctx.globalAlpha = 1; ctx.globalCompositeOperation = "source-over";
      L.parts = keep;
    }
    requestAnimationFrame(step);
  }
  requestAnimationFrame(step);

  return { setup, add, burst, ring, emitter, hook, clear, bolt, rnd, pick, layers };
})();
