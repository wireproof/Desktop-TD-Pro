'use strict';
const {contextBridge, ipcRenderer} = require('electron');
contextBridge.exposeInMainWorld('desktopBridge', Object.freeze({
  checkpointStatus: status => ipcRenderer.send('checkpoint-status', String(status)),
  gameLoaded: () => ipcRenderer.send('game-loaded')
}));
