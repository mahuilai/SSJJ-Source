// 分离启动游戏进程：detached + stdio ignore，父进程退出不影响子进程
const { spawn } = require('child_process');
const fs = require('fs');

const dir = 'D:\\SSJJ-4399\\battle\\3_64';
const exe = dir + '\\SSJJ_BattleClient_Unity.exe';
const log = dir + '\\log\\offline.log';
try { fs.unlinkSync(log); } catch (e) {}

const args = [
  '-screen-fullscreen', '0',
  '-screen-width', '1600',
  '-screen-height', '900',
  '-logFile', log,
];

const child = spawn(exe, args, {
  cwd: dir,
  detached: true,
  stdio: 'ignore',
  windowsHide: false,
});
child.unref();
console.log('spawned pid=' + child.pid);
