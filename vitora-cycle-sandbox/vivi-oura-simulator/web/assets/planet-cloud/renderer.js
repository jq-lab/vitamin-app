const NS = 'http://www.w3.org/2000/svg';
const XN = 'http://www.w3.org/1999/xlink';

const PLANETS = [
  {
    id: 'pearl-flower',
    name: '01｜珍珠花朵星球',
    reference: './assets/reference/ref-1.png',
    description: '偏早期参考：珍珠渐变球体 + 百合花簇 + 空洞球面 + 细环绕轨道。',
    type: 'solidHollow',
    matte: false,
    palette: {
      a: '#f0e7ff', b: '#f7c6d6', c: '#b7c9ff', d: '#f9efc8', e: '#7d73d8', ring: '#8f79bd'
    },
    shell: { cx: 550, cy: 560, r: 265, holes: [[620,530,36],[520,645,44],[615,720,50],[435,690,52],[470,505,20]], shellBands: 8 },
    flowers: [
      { x: 505, y: 448, size: 96, petals: 6, color: '#f7d9b0', inner: '#f0b3d0', rotate: -0.3 },
      { x: 435, y: 525, size: 86, petals: 5, color: '#d7c0fa', inner: '#f4b5cf', rotate: 0.7 },
      { x: 585, y: 422, size: 52, petals: 28, color: '#7f7de0', inner: '#afcaef', pompom: true },
      { x: 370, y: 455, size: 68, petals: 5, color: '#cca9ef', inner: '#f1dbc5', rotate: -0.5 },
    ],
    petals: [
      { x: 650, y: 450, len: 170, width: 44, rotate: 0.1, color: '#d9b6e8' },
      { x: 660, y: 540, len: 185, width: 56, rotate: 0.48, color: '#b4b6ff' },
      { x: 540, y: 410, len: 150, width: 44, rotate: -0.45, color: '#f1c0d0' },
      { x: 485, y: 395, len: 130, width: 38, rotate: -0.7, color: '#b4b0ff' },
    ],
    rings: { cx: 550, cy: 585, rx: 455, ry: 90, count: 4, tilt: -0.08, colorA: '#7c64b1', colorB: '#d9c5ec' },
    satellites: [
      { x: 110, y: 650, r: 42, color: '#6e79df' }, { x: 920, y: 565, r: 34, color: '#9d7bd8' },
      { x: 885, y: 755, r: 28, color: '#d4bc83' }, { x: 255, y: 185, r: 22, color: '#b39488' }
    ]
  },
  {
    id: 'candy-ribbon',
    name: '02｜糖彩丝带星球',
    reference: './assets/reference/ref-2.png',
    description: '偏粉蓝橙的丝带包裹球体，大花只占上部 1/3，轨道环穿过球体中央。',
    type: 'ribbonSphere',
    matte: false,
    palette: { a: '#b9dfff', b: '#f7b9d8', c: '#ffd287', d: '#f7eef9', e: '#f5c56b', ring: '#eb8bb5' },
    shell: { cx: 520, cy: 572, r: 260 },
    ribbons: [
      { color: '#b9dfff', width: 70, rotate: -0.65, arc: 1.15 },
      { color: '#f7b9d8', width: 60, rotate: 0.55, arc: 1.22 },
      { color: '#ffd287', width: 52, rotate: 0.15, arc: 0.95 },
      { color: '#f7d1ec', width: 54, rotate: -1.08, arc: 1.08 },
      { color: '#ff9db1', width: 48, rotate: 0.95, arc: 0.9 }
    ],
    flowers: [
      { x: 520, y: 410, size: 100, petals: 6, color: '#b9dfff', inner: '#ffd98f', rotate: 0.2 },
      { x: 720, y: 470, size: 70, petals: 5, color: '#f9bfd7', inner: '#ffb39f', rotate: 0.6 },
      { x: 760, y: 690, size: 42, petals: 28, color: '#f6e0b3', inner: '#efc370', pompom: true }
    ],
    rings: { cx: 520, cy: 560, rx: 490, ry: 96, count: 4, tilt: 0.04, colorA: '#ff9db7', colorB: '#ffc785' },
    satellites: [
      { x: 515, y: 126, r: 21, color: '#8ea8d8' }, { x: 865, y: 205, r: 28, color: '#efddb1' },
      { x: 764, y: 684, r: 32, color: '#f2dda8' }
    ]
  },
  {
    id: 'hydrangea-hollow',
    name: '03｜绣球镂空星球',
    reference: './assets/reference/ref-3.png',
    description: '优化版本：花只占约 1/3，主体强调镂空线条和空洞窗口，更适合 Claude 继续精修。',
    type: 'lineHollow',
    matte: true,
    palette: { a: '#d9d2ff', b: '#c0d3ff', c: '#e7ccff', d: '#f6d7ef', ring: '#d8b7f7', e: '#a788ee' },
    shell: { cx: 520, cy: 605, r: 270, holes: [[673,438,75],[678,584,54],[332,575,43],[510,770,82],[415,690,52]], shellBands: 12 },
    flowers: [
      { x: 420, y: 465, size: 50, petals: 5, color: '#dcbdf5', inner: '#f2e3ef' },
      { x: 510, y: 420, size: 44, petals: 5, color: '#dce7ff', inner: '#d7c4ff' },
      { x: 590, y: 390, size: 38, petals: 5, color: '#e1eeff', inner: '#c6b8ff' },
      { x: 350, y: 390, size: 28, petals: 20, color: '#c8b0f5', pompom: true },
      { x: 285, y: 470, size: 24, petals: 18, color: '#c7aff3', pompom: true },
      { x: 628, y: 340, size: 24, petals: 18, color: '#cab6fa', pompom: true },
    ],
    sprays: [
      { x: 265, y: 418, len: 180, angle: 0.55, color: '#c1c4ff' },
      { x: 565, y: 370, len: 150, angle: 0.3, color: '#f1d7ea' },
      { x: 502, y: 494, len: 220, angle: 1.25, color: '#e8c3f0' },
    ],
    rings: { cx: 520, cy: 620, rx: 470, ry: 90, count: 4, tilt: 0.03, colorA: '#d0b4f2', colorB: '#f2c8e1' },
    satellites: [
      { x: 195, y: 218, r: 32, color: '#cdaef6' }, { x: 875, y: 235, r: 30, color: '#eac7d6' },
      { x: 870, y: 785, r: 34, color: '#b79df0' }, { x: 265, y: 844, r: 28, color: '#c1d0ff' },
      { x: 140, y: 724, r: 17, color: '#f2dbe7' }
    ]
  },
  {
    id: 'sunflower-hollow',
    name: '04｜向日葵镂空星球',
    reference: './assets/reference/ref-4.png',
    description: '优化版本：暖黄色、绿色线条球体，花卉只覆盖右上角 1/3 区域，中心主体保持镂空。',
    type: 'lineHollowWarm',
    matte: true,
    palette: { a: '#f7e3a6', b: '#f9efcc', c: '#d7ebb9', d: '#fde8bb', ring: '#efcf77', e: '#d4efc6' },
    shell: { cx: 530, cy: 594, r: 265, holes: [[396,436,44],[535,674,80],[420,590,38],[610,585,28]], shellBands: 11 },
    flowers: [
      { x: 675, y: 448, size: 110, petals: 18, color: '#f9e38a', inner: '#e7b545', sunflower: true },
      { x: 600, y: 575, size: 42, petals: 12, color: '#f3f0dd', inner: '#e2c46a' },
      { x: 738, y: 624, size: 30, petals: 24, color: '#f7d975', pompom: true },
      { x: 505, y: 466, size: 18, petals: 20, color: '#f6edcf', pompom: true }
    ],
    leaves: [
      { x: 445, y: 498, len: 220, width: 58, rotate: -1.05, color: '#c9e0ae' },
      { x: 675, y: 532, len: 160, width: 52, rotate: 0.62, color: '#d1e9af' }
    ],
    rings: { cx: 530, cy: 605, rx: 465, ry: 88, count: 4, tilt: 0.02, colorA: '#f3d172', colorB: '#f0d99e' },
    satellites: [
      { x: 194, y: 273, r: 34, color: '#f1d381' }, { x: 903, y: 723, r: 38, color: '#d8e7bf' },
      { x: 255, y: 829, r: 28, color: '#efe2bf' }, { x: 178, y: 458, r: 19, color: '#f4d56b' }
    ],
    beads: [
      { x: 160, y: 662, r: 11, color: '#efd6ab' }, { x: 260, y: 376, r: 6, color: '#f5ce87' },
      { x: 875, y: 376, r: 7, color: '#f0ba6b' }, { x: 902, y: 455, r: 8, color: '#d0d49f' },
      { x: 900, y: 850, r: 9, color: '#f0bc69' }
    ]
  },
  {
    id: 'iris-open',
    name: '05｜鸢尾开放丝带星球',
    reference: './assets/reference/ref-5.png',
    description: '开放式丝带结构：主体更轻、更空，花卉聚在左下 1/3，适合做动画化。',
    type: 'openRibbon',
    matte: true,
    palette: { a: '#c6ddff', b: '#dabef8', c: '#f5d1ea', d: '#b8e2ff', ring: '#deb8ef', e: '#b28bf1' },
    shell: { cx: 525, cy: 560, r: 255 },
    tendrils: [
      { color: '#c0d7ff', width: 34, rotate: 0.1, arc: 1.1 },
      { color: '#d3b4f5', width: 28, rotate: -0.8, arc: 1.18 },
      { color: '#f0caee', width: 24, rotate: 0.95, arc: 1.05 },
      { color: '#a9ddff', width: 32, rotate: -0.2, arc: 0.95 },
      { color: '#d8c7ff', width: 22, rotate: 0.65, arc: 1.25 },
    ],
    flowers: [
      { x: 385, y: 545, size: 78, petals: 3, color: '#bfbbff', inner: '#f2c2ef', iris: true },
      { x: 470, y: 642, size: 54, petals: 3, color: '#e8c5f6', inner: '#f3bfd7', iris: true },
      { x: 305, y: 470, size: 26, petals: 5, color: '#eeddf9', inner: '#cbb1f7' },
      { x: 280, y: 520, size: 22, petals: 18, color: '#c0c6ff', pompom: true },
      { x: 430, y: 450, size: 18, petals: 18, color: '#c0a6f7', pompom: true }
    ],
    rings: { cx: 515, cy: 610, rx: 438, ry: 78, count: 4, tilt: 0.03, colorA: '#d7b5ef', colorB: '#f0d5ef' },
    satellites: [
      { x: 210, y: 305, r: 16, color: '#c5b8f6' }, { x: 220, y: 742, r: 19, color: '#f1cce4' },
      { x: 890, y: 318, r: 27, color: '#cfb1fa' }, { x: 820, y: 860, r: 20, color: '#b7d7ff' }
    ],
    dust: [
      { x: 120, y: 480, r: 7, color: '#b992f0' }, { x: 844, y: 600, r: 6, color: '#e7c7eb' },
      { x: 670, y: 654, r: 6, color: '#c89ef2' }
    ]
  }
];

function svgEl(name, attrs = {}) {
  const el = document.createElementNS(NS, name);
  for (const [key, value] of Object.entries(attrs)) el.setAttribute(key, value);
  return el;
}

function clear(node) { while (node.firstChild) node.removeChild(node.firstChild); }

function polar(cx, cy, r, ang) {
  return [cx + r * Math.cos(ang), cy + r * Math.sin(ang)];
}

function lerp(a, b, t) { return a + (b - a) * t; }

function withAlpha(hex, alpha) {
  const h = hex.replace('#', '');
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  return `rgba(${r},${g},${b},${alpha})`;
}

function seedNoise(seed) {
  let s = seed || 1;
  return () => {
    s = (s * 9301 + 49297) % 233280;
    return s / 233280;
  };
}

function addDefs(svg, planet) {
  const defs = svgEl('defs');
  const bg = svgEl('radialGradient', { id: 'bgGrad', cx: '50%', cy: '45%', r: '70%' });
  bg.append(svgEl('stop', { offset: '0%', 'stop-color': '#f8f8fb' }));
  bg.append(svgEl('stop', { offset: '100%', 'stop-color': '#eeeeef' }));
  defs.append(bg);

  const shell = svgEl('linearGradient', { id: 'shellGrad', x1: '20%', y1: '15%', x2: '80%', y2: '85%' });
  shell.append(svgEl('stop', { offset: '0%', 'stop-color': planet.palette.a }));
  shell.append(svgEl('stop', { offset: '35%', 'stop-color': planet.palette.b || planet.palette.a }));
  shell.append(svgEl('stop', { offset: '65%', 'stop-color': planet.palette.c || planet.palette.a }));
  shell.append(svgEl('stop', { offset: '100%', 'stop-color': planet.palette.d || planet.palette.c || planet.palette.a }));
  defs.append(shell);

  const matte = svgEl('filter', { id: 'softMatte', x: '-20%', y: '-20%', width: '140%', height: '140%' });
  matte.append(svgEl('feGaussianBlur', { in: 'SourceGraphic', stdDeviation: '0.4', result: 'blur' }));
  const blend = svgEl('feColorMatrix', {
    in: 'blur', type: 'matrix',
    values: '1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 0.98 0'
  });
  matte.append(blend);
  defs.append(matte);

  const grain = svgEl('filter', { id: 'paperGrain', x: '-20%', y: '-20%', width: '140%', height: '140%' });
  grain.append(svgEl('feTurbulence', { type: 'fractalNoise', baseFrequency: '0.9', numOctaves: '2', seed: '4', result: 'noise' }));
  grain.append(svgEl('feColorMatrix', { type: 'saturate', values: '0', in: 'noise', result: 'gray' }));
  grain.append(svgEl('feComponentTransfer', { in: 'gray' }));
  defs.append(grain);

  svg.append(defs);
}

function drawBackground(svg) {
  svg.append(svgEl('rect', { x: 0, y: 0, width: 1024, height: 1024, fill: 'url(#bgGrad)' }));
}

function drawSphereBase(group, shell) {
  group.append(svgEl('circle', {
    cx: shell.cx, cy: shell.cy, r: shell.r,
    fill: 'url(#shellGrad)', opacity: '0.94'
  }));
}

function drawSoftShadow(group, cx, cy, rx, ry) {
  group.append(svgEl('ellipse', {
    cx, cy: cy + 12, rx, ry,
    fill: 'rgba(170,170,190,0.07)'
  }));
}

function drawOrbitRings(group, rings, matte) {
  const g = svgEl('g', { opacity: matte ? '0.92' : '0.95' });
  for (let i = 0; i < rings.count; i++) {
    const rx = rings.rx - i * 18;
    const ry = rings.ry - i * 3;
    const path = svgEl('ellipse', {
      cx: rings.cx,
      cy: rings.cy,
      rx,
      ry,
      fill: 'none',
      stroke: i % 2 === 0 ? rings.colorA : rings.colorB,
      'stroke-width': matte ? 3.2 : 4.2,
      opacity: matte ? 0.9 : 0.82,
      transform: `rotate(${(rings.tilt || 0) * 180 / Math.PI} ${rings.cx} ${rings.cy})`
    });
    g.append(path);
  }
  group.append(g);
}

function drawSatellites(group, satellites) {
  satellites?.forEach((s) => {
    group.append(drawPompom(s.x, s.y, s.r, s.color, Math.max(10, Math.floor(s.r * 0.8))));
  });
}

function drawBeads(group, beads) {
  beads?.forEach((b) => {
    group.append(svgEl('circle', { cx: b.x, cy: b.y, r: b.r, fill: b.color, opacity: 0.95 }));
  });
}

function drawPompom(x, y, r, color, count = 18) {
  const g = svgEl('g');
  const rand = seedNoise(Math.round(x + y + r));
  for (let i = 0; i < count; i++) {
    const a = (Math.PI * 2 * i) / count;
    const rr = r * (0.52 + rand() * 0.34);
    const [px, py] = polar(x, y, rr * 0.4, a);
    g.append(svgEl('circle', {
      cx: px, cy: py, r: rr * 0.22,
      fill: withAlpha(color, 0.94), opacity: 0.96
    }));
  }
  g.append(svgEl('circle', { cx: x, cy: y, r: r * 0.3, fill: withAlpha(color, 0.7) }));
  return g;
}

function drawPetalFlower(f) {
  const g = svgEl('g', { transform: `translate(${f.x} ${f.y}) rotate(${(f.rotate || 0) * 57.3})` });
  if (f.pompom) return drawPompom(f.x, f.y, f.size * 0.55, f.color, 26);
  if (f.sunflower) {
    const petals = f.petals || 16;
    for (let i = 0; i < petals; i++) {
      const ang = (Math.PI * 2 * i) / petals;
      const el = svgEl('ellipse', {
        cx: Math.cos(ang) * (f.size * 0.56),
        cy: Math.sin(ang) * (f.size * 0.56),
        rx: f.size * 0.16,
        ry: f.size * 0.42,
        fill: f.color,
        opacity: 0.98,
        transform: `rotate(${(ang * 180 / Math.PI) + 90} ${Math.cos(ang) * (f.size * 0.56)} ${Math.sin(ang) * (f.size * 0.56)})`
      });
      g.append(el);
    }
    g.append(drawPompom(0, 0, f.size * 0.24, f.inner || '#e0af36', 26));
    return g;
  }
  if (f.iris) {
    const petals = [
      { ang: -0.85, len: 0.6, w: 0.24 },
      { ang: 0.85, len: 0.6, w: 0.24 },
      { ang: Math.PI, len: 0.78, w: 0.28 }
    ];
    petals.forEach((p) => {
      const path = svgEl('path', {
        d: `M0 0 C ${f.size * 0.1} ${-f.size * p.len * 0.2}, ${f.size * p.w} ${-f.size * p.len * 0.8}, 0 ${-f.size * p.len}
            C ${-f.size * p.w} ${-f.size * p.len * 0.8}, ${-f.size * 0.1} ${-f.size * p.len * 0.2}, 0 0 Z`,
        fill: f.color,
        opacity: 0.98,
        transform: `rotate(${(p.ang * 180 / Math.PI) + 90})`
      });
      g.append(path);
    });
    g.append(svgEl('circle', { cx: 0, cy: 0, r: f.size * 0.14, fill: f.inner || '#f2ccdd' }));
    return g;
  }
  const petals = f.petals || 6;
  for (let i = 0; i < petals; i++) {
    const ang = (Math.PI * 2 * i) / petals;
    const el = svgEl('ellipse', {
      cx: Math.cos(ang) * (f.size * 0.42),
      cy: Math.sin(ang) * (f.size * 0.42),
      rx: f.size * 0.16,
      ry: f.size * 0.38,
      fill: f.color,
      opacity: 0.98,
      transform: `rotate(${(ang * 180 / Math.PI) + 90} ${Math.cos(ang) * (f.size * 0.42)} ${Math.sin(ang) * (f.size * 0.42)})`
    });
    g.append(el);
  }
  g.append(svgEl('circle', { cx: 0, cy: 0, r: f.size * 0.12, fill: f.inner || '#f7e2af' }));
  return g;
}

function drawLeaf(l) {
  return svgEl('path', {
    d: `M ${l.x} ${l.y} C ${l.x + Math.cos(l.rotate) * l.len * 0.24} ${l.y + Math.sin(l.rotate) * l.len * 0.24},
      ${l.x + Math.cos(l.rotate) * l.len * 0.76 + l.width * Math.sin(l.rotate)} ${l.y + Math.sin(l.rotate) * l.len * 0.76 - l.width * Math.cos(l.rotate)},
      ${l.x + Math.cos(l.rotate) * l.len} ${l.y + Math.sin(l.rotate) * l.len}
      C ${l.x + Math.cos(l.rotate) * l.len * 0.7 - l.width * Math.sin(l.rotate)} ${l.y + Math.sin(l.rotate) * l.len * 0.7 + l.width * Math.cos(l.rotate)},
      ${l.x + Math.cos(l.rotate) * l.len * 0.25 - l.width * 0.35 * Math.sin(l.rotate)} ${l.y + Math.sin(l.rotate) * l.len * 0.25 + l.width * 0.35 * Math.cos(l.rotate)},
      ${l.x} ${l.y} Z`,
    fill: l.color,
    opacity: 0.96
  });
}

function drawRibbonArc(cx, cy, r, width, rotate, arc, color, opacity = 0.92) {
  const g = svgEl('g', { transform: `translate(${cx} ${cy}) rotate(${rotate * 57.3})` });
  const a1 = -Math.PI * arc;
  const a2 = Math.PI * arc;
  const [x1, y1] = polar(0, 0, r, a1);
  const [x2, y2] = polar(0, 0, r, a2);
  const [ix1, iy1] = polar(0, 0, r - width, a1);
  const [ix2, iy2] = polar(0, 0, r - width, a2);
  const large = arc > 0.5 ? 1 : 0;
  const d = `M ${x1} ${y1} A ${r} ${r} 0 ${large} 1 ${x2} ${y2} L ${ix2} ${iy2} A ${r - width} ${r - width} 0 ${large} 0 ${ix1} ${iy1} Z`;
  g.append(svgEl('path', { d, fill: color, opacity }));
  return g;
}

function drawSolidHollow(group, planet) {
  drawSoftShadow(group, planet.shell.cx, planet.shell.cy, 160, 32);
  drawSphereBase(group, planet.shell);
  planet.shell.holes?.forEach(([x, y, r]) => {
    group.append(svgEl('circle', { cx: x, cy: y, r, fill: '#f7f7fb', opacity: 0.8 }));
  });
  planet.petals?.forEach((p, idx) => {
    group.append(drawRibbonArc(p.x, p.y, p.len * 0.52, p.width, p.rotate, 0.45, p.color, 0.88));
  });
  planet.flowers.forEach((f) => group.append(drawPetalFlower(f)));
}

function drawRibbonSphere(group, planet) {
  drawSoftShadow(group, planet.shell.cx, planet.shell.cy, 170, 32);
  group.append(svgEl('circle', {
    cx: planet.shell.cx, cy: planet.shell.cy, r: planet.shell.r,
    fill: withAlpha('#ffffff', 0.75), opacity: 0.8
  }));
  planet.ribbons.forEach((rb, idx) => {
    const g = drawRibbonArc(planet.shell.cx + idx * 4 - 8, planet.shell.cy + idx * 5 - 10, planet.shell.r * rb.arc, rb.width, rb.rotate, 0.55, rb.color, 0.92);
    group.append(g);
  });
  planet.flowers.forEach((f) => group.append(drawPetalFlower(f)));
}

function drawLineHollow(group, planet) {
  const g = svgEl('g');
  drawSoftShadow(g, planet.shell.cx, planet.shell.cy, 165, 28);
  const rand = seedNoise(42);
  for (let i = 0; i < planet.shell.shellBands; i++) {
    const r = planet.shell.r - i * 12;
    const tilt = -0.78 + i * 0.12;
    const color = i % 2 ? withAlpha(planet.palette.a, 0.86) : withAlpha(planet.palette.b, 0.9);
    g.append(drawRibbonArc(planet.shell.cx + (i - 5) * 4, planet.shell.cy + Math.sin(i) * 6, r, 8, tilt, 0.72, color, 1));
  }
  planet.shell.holes?.forEach(([x, y, r]) => {
    g.append(svgEl('circle', { cx: x, cy: y, r, fill: '#f5f5f8', opacity: 0.96 }));
    g.append(svgEl('circle', { cx: x, cy: y, r, fill: 'none', stroke: withAlpha(planet.palette.a, 0.72), 'stroke-width': 4 }));
  });
  for (let i = 0; i < 40; i++) {
    const ang = rand() * Math.PI * 2;
    const rr = planet.shell.r * (0.4 + rand() * 0.48);
    const [x, y] = polar(planet.shell.cx, planet.shell.cy, rr, ang);
    g.append(svgEl('circle', { cx: x, cy: y, r: rand() * 2.2 + 0.6, fill: withAlpha('#ffffff', 0.8) }));
  }
  planet.sprays?.forEach((s) => {
    for (let i = 0; i < 9; i++) {
      const t = i / 8;
      const x = s.x + Math.cos(s.angle) * s.len * t;
      const y = s.y + Math.sin(s.angle) * s.len * t - Math.sin(t * Math.PI) * 14;
      g.append(svgEl('circle', { cx: x, cy: y, r: lerp(5, 2, t), fill: withAlpha(s.color, 0.9) }));
    }
  });
  planet.flowers.forEach((f) => g.append(drawPetalFlower(f)));
  group.append(g);
}

function drawWarmHollow(group, planet) {
  drawSoftShadow(group, planet.shell.cx, planet.shell.cy, 155, 28);
  for (let i = 0; i < planet.shell.shellBands; i++) {
    const r = planet.shell.r - i * 14;
    const ang = -1 + i * 0.16;
    const color = i % 2 ? withAlpha('#f9efcf', 0.96) : withAlpha('#ead289', 0.8);
    group.append(drawRibbonArc(planet.shell.cx + Math.sin(i) * 8, planet.shell.cy + Math.cos(i) * 4, r, 10, ang, 0.63, color, 0.98));
  }
  planet.shell.holes.forEach(([x, y, r]) => {
    group.append(svgEl('circle', { cx: x, cy: y, r, fill: '#faf7ec', opacity: 0.98 }));
    group.append(svgEl('circle', { cx: x, cy: y, r, fill: 'none', stroke: withAlpha('#edd488', 0.75), 'stroke-width': 4 }));
  });
  planet.leaves?.forEach((l) => group.append(drawLeaf(l)));
  planet.flowers.forEach((f) => group.append(drawPetalFlower(f)));
}

function drawOpenRibbon(group, planet) {
  drawSoftShadow(group, planet.shell.cx, planet.shell.cy, 150, 24);
  planet.tendrils.forEach((t, idx) => {
    group.append(drawRibbonArc(planet.shell.cx + (idx - 2) * 12, planet.shell.cy - 8 + idx * 6, planet.shell.r * t.arc * 0.74, t.width, t.rotate, 0.48 + idx * 0.04, t.color, 0.96));
  });
  for (let i = 0; i < 5; i++) {
    const r = 110 + i * 46;
    group.append(svgEl('ellipse', {
      cx: planet.shell.cx + i * 3,
      cy: planet.shell.cy + 8,
      rx: r,
      ry: 18 + i * 6,
      fill: 'none',
      stroke: withAlpha(i % 2 ? '#d5b0eb' : '#bfd5f9', 0.34),
      'stroke-width': 3,
      transform: `rotate(${(-38 + i * 10)} ${planet.shell.cx} ${planet.shell.cy})`
    }));
  }
  planet.flowers.forEach((f) => group.append(drawPetalFlower(f)));
}

function renderPlanet(svg, planet) {
  clear(svg);
  addDefs(svg, planet);
  drawBackground(svg);
  const main = svgEl('g', { filter: planet.matte ? 'url(#softMatte)' : '' });
  if (planet.type === 'solidHollow') drawSolidHollow(main, planet);
  if (planet.type === 'ribbonSphere') drawRibbonSphere(main, planet);
  if (planet.type === 'lineHollow') drawLineHollow(main, planet);
  if (planet.type === 'lineHollowWarm') drawWarmHollow(main, planet);
  if (planet.type === 'openRibbon') drawOpenRibbon(main, planet);
  drawOrbitRings(main, planet.rings, planet.matte);
  drawSatellites(main, planet.satellites);
  drawBeads(main, planet.beads);
  drawBeads(main, planet.dust);
  svg.append(main);
}

function populateUI() {
  const select = document.getElementById('variantSelect');
  const stage = document.getElementById('planetStage');
  const refImg = document.getElementById('referenceImage');
  const refText = document.getElementById('referenceText');
  const refPanel = document.getElementById('referencePanel');
  const thumbGrid = document.getElementById('thumbGrid');

  PLANETS.forEach((planet, idx) => {
    const option = document.createElement('option');
    option.value = planet.id;
    option.textContent = planet.name;
    select.append(option);

    const card = document.createElement('article');
    card.className = 'thumb-card';
    card.innerHTML = `<h3>${planet.name}</h3><div class="thumb-stage"><svg viewBox="0 0 1024 1024"></svg></div><p>${planet.description}</p>`;
    thumbGrid.append(card);
    renderPlanet(card.querySelector('svg'), planet);
  });

  function update(id) {
    const planet = PLANETS.find((p) => p.id === id) || PLANETS[0];
    renderPlanet(stage, planet);
    refImg.src = planet.reference;
    refText.textContent = planet.description;
    select.value = planet.id;
  }

  select.addEventListener('change', () => update(select.value));
  document.getElementById('toggleReference').addEventListener('click', () => refPanel.classList.toggle('hide'));
  document.getElementById('openSingle').addEventListener('click', () => {
    const id = select.value;
    window.open(`./single.html?variant=${encodeURIComponent(id)}`, '_blank');
  });
  update(PLANETS[0].id);
}

window.VIVI_PLANET_CLOUD = {
  PLANETS,
  renderPlanet,
};
