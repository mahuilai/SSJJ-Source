// 生死狙击 · 纯离线单机大厅
// Electron 主进程：只做窗口与本地文件访问，零网络、零后台服务。
const { app, BrowserWindow, ipcMain, shell } = require('electron');
const path = require('path');
const fs = require('fs');
const os = require('os');

const ROOT = path.join(__dirname, '..');
const ASSETS = path.join(ROOT, 'assets');
const SCENES = path.join(ASSETS, 'scenes');
const DATA = path.join(ROOT, 'data');

// 大厅原生尺寸（与官方 AIR 视口一致）
const VIEW_W = 1024;
const VIEW_H = 650;

let win = null;

function createWindow() {
  win = new BrowserWindow({
    width: VIEW_W + 16,
    height: VIEW_H + 39,
    useContentSize: true,
    resizable: true,
    backgroundColor: '#000000',
    title: '4399生死狙击 · 官方大厅（1:1 离线复刻）',
    icon: path.join(ASSETS, 'icon.ico'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      backgroundThrottling: false,
    },
  });

  win.setMenuBarVisibility(false);
  win.loadFile(path.join(__dirname, 'index.html'));
  win.once('ready-to-show', () => win.show());

  // 调试/验收：等到页面渲染稳定后自动截图并退出
  if (process.env.SSJJ_SHOT) {
    win.webContents.once('did-finish-load', () => {
      setTimeout(async () => {
        try {
          // 可选：截图前点击某元素（SSJJ_CLICK=<data-name>）
          if (process.env.SSJJ_CLICK) {
            const target = JSON.stringify('[data-name="' + process.env.SSJJ_CLICK + '"]');
            await win.webContents.executeJavaScript(
              `(function(){var e=document.querySelector(${target}); if(e) e.click();})()`
            );
            await new Promise((r) => setTimeout(r, 6000));
          }
          const dbg = await win.webContents.executeJavaScript(
            `(function(){ return { hasFn: typeof fillStoreCells, prof: !!window.__prof, n: document.querySelectorAll('[data-name^=\icon\]').length }; })()`
          );
          console.log('DBG ' + JSON.stringify(dbg));
          const dom = await win.webContents.executeJavaScript(`
            (() => {
              const q = (n) => document.querySelector('[data-name="'+n+'"]');
              const info = {};
              for (const n of ['HallModePanel','sbag','bg','icon0','icon1','icon5','storageName']) {
                const e = q(n);
                if (!e) { info[n] = null; continue; }
                const r = e.getBoundingClientRect();
                info[n] = { w: Math.round(r.width), h: Math.round(r.height), kids: e.children.length, bg: !!e.style.backgroundImage };
              }
              return info;
            })()
          `);
          console.log('DOMINFO ' + JSON.stringify(dom));
          const img = await win.webContents.capturePage();
          require('fs').writeFileSync(process.env.SSJJ_SHOT, img.toPNG());
          console.log('SHOT_SAVED ' + process.env.SSJJ_SHOT);
        } catch (e) { console.log('SHOT_ERR ' + e); }
        app.quit();
      }, Number(process.env.SSJJ_SHOT_DELAY || 6000));
    });
  }
}

app.whenReady().then(() => {
  // 开发期禁用磁盘缓存，确保每次都读到最新的场景 JSON。
  try {
    const { session } = require('electron');
    session.defaultSession.clearCache();
  } catch (e) {}
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

// ── 本地数据访问 ─────────────────────────────────────────────
// 场景：assets/scenes/<view>.json  →  { view, nodes:[...], problems:[] }
ipcMain.handle('scene:load', (_e, view) => {
  const safe = String(view).replace(/[^A-Za-z0-9_]/g, '');
  const file = path.join(SCENES, safe + '.json');
  if (!fs.existsSync(file)) return null;
  return JSON.parse(fs.readFileSync(file, 'utf8'));
});

// 场景索引（供导航使用）
ipcMain.handle('scene:list', () => {
  if (!fs.existsSync(SCENES)) return [];
  return fs.readdirSync(SCENES)
    .filter((f) => f.endsWith('.json'))
    .map((f) => f.replace(/\.json$/, ''))
    .sort();
});

// 玩家档案：纯本地 JSON，读写全在磁盘，永不重置
const PROFILE = path.join(DATA, 'user_profile.json');

function defaultProfile() {
  return {
    version: 1,
    nickname: '你来时冬至',
    level: 91,
    vip: 18,
    gp: 91,
    gold: 91,
    server: '联通一区',
    bagIndex: 1,
    bags: [
      { id: 1, master: 'M4A1', secondary: '沙漠之鹰', melee: '广陵·贰', grenade: '', role: '监察者' },
      { id: 2, master: '', secondary: '', melee: '', grenade: '', role: '' },
      { id: 3, master: '', secondary: '', melee: '', grenade: '', role: '' },
      { id: 4, master: '', secondary: '', melee: '', grenade: '', role: '' },
      { id: 5, master: '', secondary: '', melee: '', grenade: '', role: '' },
    ],
  };
}

ipcMain.handle('profile:load', () => {
  try {
    if (!fs.existsSync(PROFILE)) {
      const p = defaultProfile();
      fs.mkdirSync(DATA, { recursive: true });
      fs.writeFileSync(PROFILE, JSON.stringify(p, null, 2), 'utf8');
      return p;
    }
    return JSON.parse(fs.readFileSync(PROFILE, 'utf8'));
  } catch (e) {
    return defaultProfile();
  }
});

ipcMain.handle('profile:save', (_e, profile) => {
  try {
    fs.mkdirSync(DATA, { recursive: true });
    const tmp = PROFILE + '.tmp';
    fs.writeFileSync(tmp, JSON.stringify(profile, null, 2), 'utf8');
    fs.renameSync(tmp, PROFILE);
    return true;
  } catch (e) {
    return false;
  }
});

// ── 武器 / 角色 / 皮肤 索引 ──────────────────────────────────
ipcMain.handle('assets:list', (_e, kind) => {
  const dir = path.join(ASSETS, 'previews', String(kind));
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir).filter((f) => /\.png$/i.test(f)).sort();
});

// 一键拉起 3D 战斗端，带上当前背包参数
ipcMain.handle('battle:launch', (_e, config) => {
  const exe = path.join('D:', 'SSJJ', 'SSJJ-4399', 'battle', '3_64', 'SSJJ_BattleClient_Unity.exe');
  try {
    require('child_process').spawn(exe, [], {
      detached: true,
      stdio: 'ignore',
      cwd: path.dirname(exe),
    }).unref();
    return { ok: true, exe };
  } catch (e) {
    return { ok: false, error: String(e) };
  }
});

ipcMain.handle('shell:openPath', (_e, p) => shell.openPath(p));

// 语言表：官方 i18n 文本，渲染层用 WORD_xxx 取实际文案
ipcMain.handle('i18n:load', () => {
  const f = path.join(ASSETS, 'i18n.txt');
  const map = {};
  try {
    for (const line of fs.readFileSync(f, 'utf8').split(/\r?\n/)) {
      const i = line.indexOf('=');
      if (i > 0) map[line.slice(0, i).trim()] = line.slice(i + 1);
    }
  } catch (e) {}
  return map;
});
