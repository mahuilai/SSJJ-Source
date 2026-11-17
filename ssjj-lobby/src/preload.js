// 渲染进程与主进程之间的受控桥接。
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('lobby', {
  loadScene: (view) => ipcRenderer.invoke('scene:load', view),
  listScenes: () => ipcRenderer.invoke('scene:list'),
  loadProfile: () => ipcRenderer.invoke('profile:load'),
  loadI18n: () => ipcRenderer.invoke('i18n:load'),
  saveProfile: (p) => ipcRenderer.invoke('profile:save', p),
  listAssets: (kind) => ipcRenderer.invoke('assets:list', kind),
  launchBattle: (cfg) => ipcRenderer.invoke('battle:launch', cfg),
  openPath: (p) => ipcRenderer.invoke('shell:openPath', p),
});
