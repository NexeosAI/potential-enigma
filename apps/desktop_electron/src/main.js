import { app, BrowserWindow, shell } from 'electron';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const brandKey = (process.env.APP_BRAND ?? 'studentlyai').toLowerCase();

function resolveBrand() {
  switch (brandKey) {
    case 'studentsai_uk':
    case 'studentsaiuk':
      return 'studentsai_uk';
    case 'studentsai_us':
    case 'studentsaius':
      return 'studentsai_us';
    default:
      return 'studentlyai';
  }
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 960,
    minHeight: 640,
    title: 'McCaigs Education AI Suite',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  win.setMenuBarVisibility(false);

  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  const brand = resolveBrand();
  process.env.MC_CAIGS_BRAND = brand;
  win.loadFile(path.join(__dirname, 'renderer', 'index.html'));
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
