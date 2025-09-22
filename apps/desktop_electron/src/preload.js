import { contextBridge } from 'electron';

const brand = process.env.MC_CAIGS_BRAND ?? 'studentlyai';

contextBridge.exposeInMainWorld('mcCaigs', {
  brand,
});
