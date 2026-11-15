'use strict';
const {app, BrowserWindow, Menu, dialog, ipcMain, session} = require('electron');
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const port = 58919;
const smokeTest = process.argv.includes('--smoke-test');
let smokeTimer;
let mainWindow, server;
const webRoot = app.isPackaged ? path.join(process.resourcesPath, 'Web') : path.join(__dirname, '..', 'app', 'Resources', 'Web');
const contentTypes = {'.html':'text/html; charset=utf-8', '.js':'text/javascript; charset=utf-8', '.wasm':'application/wasm', '.swf':'application/x-shockwave-flash'};
function startServer() {
  return new Promise((resolve, reject) => {
    server = http.createServer((req, res) => {
      let url;
      try { url = new URL(req.url, `http://127.0.0.1:${port}`); } catch { res.writeHead(400).end(); return; }
      const name = url.pathname.slice(1);
      if (req.method !== 'GET' || !name || name.includes('/') || name.includes('\\') || name.includes('..')) { res.writeHead(404).end(); return; }
      fs.readFile(path.join(webRoot, name), (error, data) => {
        if (error) { res.writeHead(404).end(); return; }
        res.writeHead(200, {'Content-Type':contentTypes[path.extname(name)] || 'application/octet-stream','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}); res.end(data);
      });
    });
    server.once('error', reject); server.listen(port, '127.0.0.1', resolve);
  });
}
function message(text) { if (mainWindow && !mainWindow.isDestroyed()) dialog.showMessageBox(mainWindow,{type:'info',title:'Desktop TD',message:String(text),buttons:['OK']}); }
async function checkpoint(command) {
  try {
    const result = await mainWindow.webContents.executeJavaScript(`window.wireCheckpointCommand ? window.wireCheckpointCommand('${command}') : 'The game is still loading.'`);
    message(result);
  } catch { message('The game could not perform that action.'); }
}
function createWindow() {
  mainWindow = new BrowserWindow({show:!smokeTest,width:1120,height:800,minWidth:700,minHeight:500,backgroundColor:'#151b18',title:'Desktop TD',autoHideMenuBar:false,webPreferences:{preload:path.join(__dirname,'preload.cjs'),contextIsolation:true,nodeIntegration:false,sandbox:true}});
  mainWindow.webContents.setWindowOpenHandler(() => ({action:'deny'}));
  mainWindow.webContents.on('will-navigate',(event,url) => { if (!url.startsWith(`http://127.0.0.1:${port}/`)) event.preventDefault(); });
  mainWindow.loadURL(`http://127.0.0.1:${port}/index.html`);
  mainWindow.on('closed',()=>{mainWindow=null});
  const menu = [
    ...(process.platform === 'darwin' ? [{label:app.name,submenu:[{role:'about'},{type:'separator'},{role:'quit'}]}] : []),
    {label:'Game',submenu:[{label:'Save Sandbox checkpoint',click:()=>checkpoint('save')},{label:'Load Sandbox checkpoint',click:()=>checkpoint('load')},{type:'separator'},{role:'quit'}]},
    {label:'View',submenu:[{role:'togglefullscreen',accelerator:process.platform === 'darwin' ? 'Ctrl+Command+F' : 'F11'},{role:'resetZoom'}]},
    {label:'Help',submenu:[{label:'How to save',click:()=>message('During a single-player Sandbox game, choose Save Sandbox checkpoint and wait for confirmation. To restore, start a fresh Sandbox with the same settings, do not preload towers, and choose Load Sandbox checkpoint before starting.')}]} 
  ];
  Menu.setApplicationMenu(Menu.buildFromTemplate(menu));
}
if (!app.requestSingleInstanceLock()) app.quit();
else {
  app.on('second-instance',()=>{if(mainWindow){if(mainWindow.isMinimized())mainWindow.restore();mainWindow.focus()}});
  app.whenReady().then(async()=>{
    session.defaultSession.webRequest.onBeforeRequest((details, callback) => {
      let allowed=false; try { const u=new URL(details.url); allowed=u.hostname==='127.0.0.1' && u.port===String(port) && u.protocol==='http:'; } catch {}
      callback({cancel:!allowed});
    });
    ipcMain.on('checkpoint-status',(_event,status)=>message(status));
    ipcMain.on('game-loaded', async (event) => {
      if (!smokeTest || !mainWindow || event.sender !== mainWindow.webContents) return;
      try {
        const ready = await mainWindow.webContents.executeJavaScript("!!document.querySelector('ruffle-player') && typeof window.wireCheckpointCommand === 'function'");
        if (!ready) throw new Error('Ruffle player or checkpoint bridge missing');
        console.log('DESKTOP_TD_SMOKE_OK'); clearTimeout(smokeTimer); app.exit(0);
      } catch (error) { console.error('DESKTOP_TD_SMOKE_FAILED', error); app.exit(1); }
    });
    if (smokeTest) smokeTimer = setTimeout(()=>{console.error('DESKTOP_TD_SMOKE_TIMEOUT');app.exit(1)},60000);
    try { await startServer(); createWindow(); } catch (error) { dialog.showErrorBox('Unable to start Desktop TD',`The local game server could not start. Close another copy and try again.\n\n${error.message}`); app.quit(); }
    app.on('activate',()=>{if(!mainWindow) createWindow()});
  });
  app.on('window-all-closed',()=>{if(process.platform!=='darwin')app.quit()});
  app.on('before-quit',()=>server?.close());
}
