// 渲染层：把官方布局还原成像素。
// 节点按嵌套结构渲染，子节点的坐标相对父容器，与原版 UIComponent 一致。
//
// 关键点：
//  * component 节点只是占位，其真实布局在同名场景 JSON 里；能查到就内联渲染。
//  * 背包格子是 CommonCell 实例，需要按 profile 的装配数据填武器图。

const VIEW_W = 1024;
const VIEW_H = 650;
const ATLAS = '../assets/atlas/';

const stage = document.getElementById('stage');
const overlay = document.getElementById('overlay');
const statusEl = document.getElementById('status');

let profile = null;
let i18n = {};
let templates = {};
let scene = null;
const sceneCache = new Map();

function fitViewport() {
  const vp = document.getElementById('viewport');
  const s = Math.min(window.innerWidth / VIEW_W, window.innerHeight / VIEW_H);
  vp.style.position = 'absolute';
  vp.style.transformOrigin = 'top left';
  vp.style.transform = `scale(${s})`;
  vp.style.left = `${(window.innerWidth - VIEW_W * s) / 2}px`;
  vp.style.top = `${(window.innerHeight - VIEW_H * s) / 2}px`;
}
window.addEventListener('resize', fitViewport);

function tr(key) {
  if (!key) return '';
  return i18n[key] || '';
}

function num(v, d = 0) {
  const n = typeof v === 'number' ? v : parseFloat(v);
  return Number.isFinite(n) ? n : d;
}

async function getScene(name) {
  if (sceneCache.has(name)) return sceneCache.get(name);
  let s = null;
  try { s = await window.lobby.loadScene(name); } catch (e) { s = null; }
  sceneCache.set(name, s);
  return s;
}

// 组件 -> 场景名候选（同名优先，其次带 View 后缀）
// 弹窗类容器：初始隐藏（原版运行时由代码按需 show）
// 会被其它节点通过 className 引用的“类定义”容器
const TEMPLATE_CLASSES = new Set([
  'HallBigModeItem','HallBig2ModeItem','HallModeItem','HallEntraceUI','HallEntraceItem1',
  'HallEntraceItem2','SmallBombCell','SmallCommonCell','SmallBagView','RewardItem','Pager',
  'NewRoleItem','NewCurrencyItem','AutomaticEquipItemBase','PlayerTypeItemBase',
  'HallModeTips','HallModeLockTips','NewSwitchRoleList','NewPlayerProtrait',
  'FunctionTrailerItem','AvatarBagSelecter','MatchInfoView','RigthButton','TopButtonPanel',
  'NewBottomBar','CurrencyBar','NewCurrencyBar','YuShiCollection','ChatPop',
  'WeaponUnlockIcon','PlayerInfoItem','KingItemBase','NewRecommendStuffView',
]);

const HIDDEN_NAMES = /^(maskSp|newPlayerSp|fashCacheTips|microClientTips|bgAntiTips|labelAntiTips)$/;

const HIDDEN_CONTAINERS = new Set([
  'SettingView','LocalFlashView','SecondLevelPasswordView','PasswordAlert','PasswordTooltips',
  'NewSettingPanel','ReopenPackPanel','ReTipAlertPanel','BindPhoneView','BindPhoneAlert',
  'FirstBindPhoneView','AutomaticEquipPanel','AutomaticEquipMaskPanel','PlayerTypePanel',
  'OrderlinessPanel','TemporaryBagTipsPanel','DeleteTipsPanel','MatchPanel',
  'ArithmeticRewardsUI','SecondLevelAmendPassWordPanel','SecondLevelPsswordAingPanel',
  'GameModeListPanel','ActivityListPanel','HallModeLockTips','HallModeTips',
]);
// 主界面常驻容器
const SHOWN_CONTAINERS = new Set([
  'SmallBagView','CurrencyBar','NewBottomBar','RigthButton','TopButtonPanel',
  'NewPlayerProtrait','NewRecommendStuffView','MatchInfoView','FunctionTrailerItem',
  'AvatarBagSelecter','NewSwitchRoleList','HallEntraceUI','KingItemBase','Pager',
  'HallBigModeItem','HallBig2ModeItem','HallModeItem','HallModeTips','HallModeLockTips',
  'GameModeListPanel','ActivityListPanel','PlayerInfoItem','YuShiCollection','RewardItem',
  'ChatPop','NewCurrencyBar','NewCurrencyItem','WeaponUnlockIcon','HallEntraceItem1',
  'HallEntraceItem2','AutomaticEquipItemBase','PlayerTypeItemBase','SmallBombCell',
  'SmallCommonCell','NewRoleItem','LocalFlashView_never',
]);

const COMP_SIZE = {
  SmallBagView: [250, 520],
  bagView: [200, 520],
};
function compW(c) { return (COMP_SIZE[c] || [0, 0])[0]; }
function compH(c) { return (COMP_SIZE[c] || [0, 0])[1]; }

const compCache = new Map();
async function resolveComponent(comp) {
  if (!comp) return null;
  if (compCache.has(comp)) return compCache.get(comp);
  // 严格同名匹配；仅对已知别名做映射
  const ALIAS = { SmallBagView: 'bagView' };
  let found = await getScene(ALIAS[comp] || comp);
  if (!(found && found.root && (found.root.children || []).length)) found = null;
  compCache.set(comp, found);
  return found;
}

// 武器图：codeName -> 立绘 PNG
function weaponIcon(codeName) {
  if (!codeName) return null;
  const c = String(codeName).trim().toLowerCase();
  return `../assets/previews/weapons/${c}.png`;
}

function buildNode(node, opts) {
  const el = document.createElement('div');
  el.className = 'n';

  const x = num(node.x), y = num(node.y);
  const w = num(node.w), h = num(node.h);

  el.style.left = x + 'px';
  el.style.top = y + 'px';
  if (w) el.style.width = w + 'px';
  if (h) el.style.height = h + 'px';
  if (node.alpha !== undefined) el.style.opacity = num(node.alpha, 1);
  if (node.name) el.dataset.name = node.name;

  // 背包格子：用 profile 装配数据填立绘
  if (opts && opts.slot) {
    const icon = weaponIcon(opts.slot);
    if (icon) {
      el.classList.add('img');
      el.style.backgroundImage = `url("${icon}")`;
      el.style.backgroundSize = 'contain';
      el.style.backgroundRepeat = 'no-repeat';
      el.style.backgroundPosition = 'center';
    }
    return el;
  }

  if (node.file) {
    el.classList.add('img');
    el.style.backgroundImage = `url("${ATLAS}${node.file}")`;
  }

  if (node.text) {
    el.classList.add('label');
    el.textContent = node.text;
    if (node.textColor !== undefined) {
      const c = Number(node.textColor);
      if (Number.isFinite(c)) {
        el.style.color = '#' + (c & 0xffffff).toString(16).padStart(6, '0');
      }
    }
    if (node.fontSize) el.style.fontSize = num(node.fontSize) + 'px';
  }

  const kids = node.children || [];
  for (const child of kids) {
    const ce = buildNode(child, null);
    if (ce) el.appendChild(ce);
  }

  if (!node.file && !node.text && kids.length === 0) return null;
  return el;
}

// 递归把组件场景内联进占位节点
async function buildNodeDeep(node, depth) {
  depth = depth || 0;
  if (depth > 12) return null;
  // 顶层组件：z<0 或明显在视口外的弹窗容器不渲染
  // 弹窗容器默认隐藏
  if (HIDDEN_CONTAINERS.has(node.name)) return null;
  // 模式/活动下拉列表：点顶部按钮才展开，首页不渲染（无论模板引用还是内嵌实例）
  if (node.component === 'GameModeListPanel' || node.component === 'ActivityListPanel') return null;
  // 首页只展示两个大模式块（mode_1/mode_2）。
  // mode_3/4/5 是切页后的小模式格，其模板里只有红色按钮底，首页不显示。
  if (node.name === 'mode_3' || node.name === 'mode_4' || node.name === 'mode_5') return null;
  // 顶层类模板只是类定义（HallBigModeItem/SmallCommonCell 等），不直接显示。
  // 面板类容器（HallModePanel/SettingView...）要正常渲染。
  if (depth === 0 && node.name && node.component === node.name
      && !num(node.x) && !num(node.y) && TEMPLATE_CLASSES.has(node.name)) return null;
  if (node.name && HIDDEN_NAMES.test(node.name)) return null;
  const el = document.createElement('div');
  el.className = 'n';
  const x = num(node.x), y = num(node.y);
  const w = num(node.w), h = num(node.h);
  el.style.left = x + 'px';
  el.style.top = y + 'px';
  if (w) el.style.width = w + 'px';
  if (h) el.style.height = h + 'px';
  // 容器没有显式尺寸时不要裁剪，否则子树会被压成 0x0
  if (!w && !h) el.style.overflow = 'visible';
  if (node.alpha !== undefined) el.style.opacity = num(node.alpha, 1);
  if (node.name) el.dataset.name = node.name;

  if (node.file) {
    el.classList.add('img');
    el.style.backgroundImage = `url("${ATLAS}${node.file}")`;
  }
  const label = tr(node.text);
  if (label) {
    el.classList.add('label');
    el.textContent = label;
    if (node.textColor !== undefined) {
      const c = Number(node.textColor);
      if (Number.isFinite(c)) el.style.color = '#' + (c & 0xffffff).toString(16).padStart(6, '0');
    }
    if (node.fontSize) el.style.fontSize = num(node.fontSize) + 'px';
  }

  let painted = !!(node.file || label);

  // 1) 内置子树（dec.xml 里的容器已经带了完整布局）优先
  const ownKids = node.children || [];
  if (ownKids.length) {
    for (const c of ownKids) {
      const ce = await buildNodeDeep(c, depth + 1);
      if (ce) { el.appendChild(ce); painted = true; }
    }
  } else if (node.component && templates[node.component]) {
    // 2) 用 mainView 内的类模板实例化（官方 UIComponent 语义）
    const tpl = templates[node.component];
    if (!num(node.w) && num(tpl.w)) el.style.width = num(tpl.w) + 'px';
    if (!num(node.h) && num(tpl.h)) el.style.height = num(tpl.h) + 'px';
    for (const c of (tpl.children || [])) {
      const ce = await buildNodeDeep(c, depth + 1);
      if (ce) { el.appendChild(ce); painted = true; }
    }
  } else if (node.component) {
    // 3) 兜底：内联同名场景文件
    const sub = await resolveComponent(node.component);
    if (sub) {
      // 组件只有坐标没尺寸时，给一个合理视口，避免内容溢出
      if (!num(node.w)) el.style.width = compW(node.component) + 'px';
      if (!num(node.h)) el.style.height = compH(node.component) + 'px';
      el.style.overflow = 'hidden';
      for (const c of (sub.root.children || [])) {
        const ce = await buildNodeDeep(c, depth + 1);
        if (ce) { el.appendChild(ce); painted = true; }
      }
    }
  }



  if (!painted) return null;
  return el;
}

// 收集 mainView 里的类模板容器（name==className、自身有子节点）
function collectTemplates(root) {
  const t = {};
  for (const c of (root.children || [])) {
    const n = c.name || '';
    if (n && c.component === n && (c.children || []).length) t[n] = c;
  }
  return t;
}

async function renderScene(s) {
  stage.innerHTML = '';
  scene = s;
  templates = collectTemplates(s.root);
  const frag = document.createDocumentFragment();
  let drawn = 0;
  // 顶部道具类界面需要压在最上层；模式大图区需要在背景之上、导航之下。
  const TOP_LAYER = new Set(['CurrencyBar','NewBottomBar','RigthButton','TopButtonPanel',
    'NewCurrencyBar','ChatPop','YuShiCollection','NewPlayerProtrait']);
  const BACK_LAYER = new Set(['HallModePanel']);
  const kids = s.root.children || [];
  const rank = (n) => (n.name === 'bg' ? 0 : (BACK_LAYER.has(n.name) ? 1 : (TOP_LAYER.has(n.name) ? 3 : 2)));
  const ordered = kids.map((n, i) => [rank(n), i, n]).sort((a, b) => a[0] - b[0] || a[1] - b[1]).map((x) => x[2]);
  for (const child of ordered) {
    const el = await buildNodeDeep(child, 0);
    if (el) { frag.appendChild(el); drawn++; }
  }
  stage.appendChild(frag);

  // 背包 5 格：挂到 mainView 的 sbag 容器上
  await mountBag();

  statusEl.textContent =
    `${s.view} · 节点 ${countNodes(s.root)} · 顶层 ${drawn} · 缺图 ${s.problems.length}`;
}

// 在左下角背包位渲染 5 个格子（主/副/近战/投掷）
async function mountBag() {
  const sbag = stage.querySelector('[data-name="sbag"]');
  if (!sbag || !profile) return;

  const bags = profile.bags || [];
  const idx = Math.max(0, Math.min((profile.bagIndex || 1) - 1, bags.length - 1));
  const bag = bags[idx] || {};

  // sbag 容器尺寸（官方 SmallBagView 视口约 250x190）
  sbag.style.width = sbag.style.width || '250px';
  sbag.style.height = sbag.style.height || '190px';

  const wrap = document.createElement('div');
  wrap.style.position = 'absolute';
  wrap.style.left = '0px';
  wrap.style.top = '0px';
  wrap.style.width = '100%';
  wrap.style.height = '100%';

  const slots = [
    { key: 'master', label: '主武器', x: 4, y: 4, w: 118, h: 62 },
    { key: 'secondary', label: '副武器', x: 4, y: 70, w: 118, h: 56 },
    { key: 'melee', label: '近战武器', x: 4, y: 130, w: 118, h: 56 },
    { key: 'grenade', label: '投掷武器', x: 128, y: 4, w: 56, h: 56 },
  ];

  for (const s of slots) {
    const cell = document.createElement('div');
    cell.style.position = 'absolute';
    cell.style.left = s.x + 'px';
    cell.style.top = s.y + 'px';
    cell.style.width = s.w + 'px';
    cell.style.height = s.h + 'px';
    cell.style.background = 'rgba(0,0,0,0.45)';
    cell.style.border = '1px solid rgba(120,180,255,0.35)';
    cell.style.boxSizing = 'border-box';
    cell.style.borderRadius = '3px';
    cell.style.overflow = 'hidden';

    const code = bag[s.key];
    if (code) {
      const img = document.createElement('img');
      img.src = weaponIcon(code);
      img.style.width = '100%';
      img.style.height = '100%';
      img.style.objectFit = 'contain';
      img.onerror = () => { img.style.display = 'none'; };
      cell.appendChild(img);

      const cap = document.createElement('div');
      cap.textContent = code;
      cap.style.position = 'absolute';
      cap.style.left = '0';
      cap.style.bottom = '0';
      cap.style.width = '100%';
      cap.style.fontSize = '10px';
      cap.style.color = '#cfe3ff';
      cap.style.background = 'rgba(0,0,0,0.55)';
      cap.style.textAlign = 'center';
      cell.appendChild(cap);
    }
    wrap.appendChild(cell);
  }

  sbag.appendChild(wrap);
}

function countNodes(n) {
  return 1 + (n.children || []).reduce((a, c) => a + countNodes(c), 0);
}

// 顶部导航 -> 场景映射
const NAV_MAP = {
  storageBtn: 'weaponStorage2View',
  temporaryBagBtn: 'weaponStorage2View',
  mallBtn: 'mallView',
  activityBtn: 'ActivityListPanel',
  gameHallBtn: 'mainView',
};

function bindNav() {
  for (const [name, view] of Object.entries(NAV_MAP)) {
    const el = stage.querySelector('[data-name="' + name + '"]');
    if (!el) continue;
    el.style.pointerEvents = 'auto';
    el.style.cursor = 'pointer';
    el.addEventListener('click', async (ev) => {
      ev.stopPropagation();
      await showView(view);
    });
  }
}

// bagView 的 6 个格位 -> profile 字段
const BAG_CELLS = [
  ['cellMaster', 'master'],
  ['cellSeondary', 'secondary'],
  ['cellClosed', 'melee'],
  ['cellBoom1', 'grenade'],
];

function fillBagCells() {
  if (!profile) return;
  const bags = profile.bags || [];
  const idx = Math.max(0, Math.min((profile.bagIndex || 1) - 1, bags.length - 1));
  const bag = bags[idx] || {};
  for (const [cell, key] of BAG_CELLS) {
    const el = stage.querySelector('[data-name="' + cell + '"]');
    if (!el) continue;
    const code = bag[key];
    if (!code) continue;
    // 格子尺寸取自身
    const w = parseFloat(el.style.width) || 50;
    const h = parseFloat(el.style.height) || 62;
    const img = document.createElement('img');
    img.src = weaponIcon(code);
    img.style.position = 'absolute';
    img.style.left = '0';
    img.style.top = '0';
    img.style.width = w + 'px';
    img.style.height = h + 'px';
    img.style.objectFit = 'contain';
    img.style.pointerEvents = 'none';
    img.onerror = () => { img.style.display = 'none'; };
    el.appendChild(img);
  }
}

// 仓库格位（icon0..icon15）按顺序铺武器立绘
const STORE_CELLS = ['icon0','icon1','icon2','icon3','icon4','icon5','icon6','icon7',
                     'icon8','icon9','icon10','icon11','icon12','icon13','icon14','icon15'];

function fillStoreCells() {
  const list = (profile && profile.storageWeapons) || [];
  // 默认展示背包里的三把 + 常见武器，避免全空
  const fallback = ['m4a1','deagle','guqin_trans_sword','ak47','awp','barrett_m107',
                    'm4a1_hero','ak47_hero','deagle_glory','92fs','mp5','usp'];
  const codes = list.length ? list : (profile && profile.bags && profile.bags[0]
    ? [profile.bags[0].master, profile.bags[0].secondary, profile.bags[0].melee].filter(Boolean).concat(fallback)
    : fallback);
  STORE_CELLS.forEach((name, i) => {
    const el = stage.querySelector('[data-name="' + name + '"]');
    if (!el) return;
    const code = codes[i];
    if (!code) return;
    const w = parseFloat(el.style.width) || 220;
    const h = parseFloat(el.style.height) || 86;
    const img = document.createElement('img');
    img.src = weaponIcon(code);
    img.style.position = 'absolute';
    img.style.left = '0';
    img.style.top = '0';
    img.style.width = w + 'px';
    img.style.height = h + 'px';
    img.style.objectFit = 'contain';
    img.style.pointerEvents = 'none';
    img.onerror = () => { img.style.display = 'none'; };
    el.appendChild(img);
  });
}

async function showView(view) {
  if (view === 'mainView') { await boot(); return; }
  const s = await getScene(view);
  if (!s) { statusEl.textContent = '未找到 ' + view; return; }
  await renderScene(s);
  fillBagCells();
  fillStoreCells();
  // 兜底：DOM 就绪后再补一次
  setTimeout(() => { fillStoreCells(); }, 300);
  bindBack();
}

function bindBack() {
  const back = stage.querySelector('[data-name="backBtn"], [data-name="returnBtn"], [data-name="closeBtn"]');
  if (!back) return;
  back.style.pointerEvents = 'auto';
  back.style.cursor = 'pointer';
  back.addEventListener('click', () => boot());
}

async function boot() {
  statusEl.textContent = 'boot start';
  fitViewport();
  if (!window.lobby) { statusEl.textContent = 'NO BRIDGE'; return; }
  try { profile = await window.lobby.loadProfile(); } catch (e) { profile = null; }
  try { i18n = await window.lobby.loadI18n(); } catch (e) { i18n = {}; }
  statusEl.textContent = 'profile ok';
  let s = null;
  try { s = await getScene('mainView'); } catch (e) { statusEl.textContent = 'ERR loadScene: ' + e; return; }
  if (!s) { statusEl.textContent = '未找到 mainView'; return; }
  try { await renderScene(s); bindNav(); } catch (e) {
    statusEl.textContent = 'ERR render: ' + (e && e.message ? e.message : e);
    return;
  }
}

boot();
