// API Bridge supporting both Tauri IPC and Web REST API
const isTauri = typeof window !== 'undefined' && window.__TAURI_INTERNALS__ !== undefined;

export const api = {
  async getInventory() {
    if (isTauri) {
      const { invoke } = await import('@tauri-apps/api/core');
      return await invoke('get_inventory');
    }
    const res = await fetch('/api/inventory');
    return await res.json();
  },

  async getProfile() {
    if (isTauri) {
      const { invoke } = await import('@tauri-apps/api/core');
      return await invoke('get_profile');
    }
    const res = await fetch('/api/profile');
    return await res.json();
  },

  async equipWeapon(bagIndex, slotIndex, weaponKey, skinKey = '') {
    if (isTauri) {
      const { invoke } = await import('@tauri-apps/api/core');
      return await invoke('equip_weapon', { bagIndex, slotIndex, weaponKey, skinKey });
    }
    const res = await fetch('/api/profile/equip_weapon', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ bagIndex, slotIndex, weaponKey, skinKey })
    });
    return await res.json();
  },

  async equipCharacter(careerKey, skinKey = '') {
    if (isTauri) {
      const { invoke } = await import('@tauri-apps/api/core');
      return await invoke('equip_character', { careerKey, skinKey });
    }
    const res = await fetch('/api/profile/equip_character', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ careerKey, skinKey })
    });
    return await res.json();
  },

  async setActiveBag(bagIndex) {
    if (isTauri) {
      const { invoke } = await import('@tauri-apps/api/core');
      return await invoke('set_active_bag', { bagIndex });
    }
    const res = await fetch('/api/profile/set_active_bag', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ bagIndex })
    });
    return await res.json();
  },

  async getSettings() {
    if (isTauri) {
      const { invoke } = await import('@tauri-apps/api/core');
      return await invoke('get_settings');
    }
    const res = await fetch('/api/settings');
    return await res.json();
  },

  async saveSettings(settings) {
    if (isTauri) {
      const { invoke } = await import('@tauri-apps/api/core');
      return await invoke('save_settings', { settings });
    }
    const res = await fetch('/api/settings/save', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(settings)
    });
    return await res.json();
  },

  async launchCombat(launchArgs) {
    if (isTauri) {
      const { invoke } = await import('@tauri-apps/api/core');
      return await invoke('launch_combat', { launchArgs });
    }
    const res = await fetch('/api/launch/combat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(launchArgs)
    });
    return await res.json();
  },

  async launchFlashLobby() {
    if (isTauri) {
      const { invoke } = await import('@tauri-apps/api/core');
      return await invoke('launch_flash_lobby');
    }
    const res = await fetch('/api/launch/flash_lobby', { method: 'POST' });
    return await res.json();
  },

  async getLaunchStatus() {
    if (isTauri) {
      const { invoke } = await import('@tauri-apps/api/core');
      return await invoke('get_launch_status');
    }
    const res = await fetch('/api/launch/status');
    return await res.json();
  },

  async minimizeWindow() {
    if (isTauri) {
      const { getCurrentWindow } = await import('@tauri-apps/api/window');
      return await getCurrentWindow().minimize();
    }
    await fetch('/api/window/minimize', { method: 'POST' });
  },

  async maximizeWindow() {
    if (isTauri) {
      const { getCurrentWindow } = await import('@tauri-apps/api/window');
      return await getCurrentWindow().toggleMaximize();
    }
    await fetch('/api/window/maximize', { method: 'POST' });
  },

  async closeWindow() {
    if (isTauri) {
      const { getCurrentWindow } = await import('@tauri-apps/api/window');
      return await getCurrentWindow().close();
    }
    await fetch('/api/window/close', { method: 'POST' });
  }
};
