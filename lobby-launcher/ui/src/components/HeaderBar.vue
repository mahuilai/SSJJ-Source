<template>
  <header class="h-14 bg-game-card/90 border-b border-game-border flex items-center justify-between px-4 select-none backdrop-blur-md z-30" data-tauri-drag-region>
    <!-- Left: Game Logo & Title -->
    <div class="flex items-center space-x-3">
      <div class="w-8 h-8 rounded bg-gradient-to-br from-amber-500 to-red-600 flex items-center justify-center shadow-glow-gold">
        <Crosshair class="w-5 h-5 text-black font-black" />
      </div>
      <div>
        <div class="text-sm font-bold tracking-wider text-amber-400 flex items-center space-x-1.5">
          <span>生死狙击</span>
          <span class="text-[10px] bg-red-950/80 text-red-400 border border-red-800/60 px-1 py-0.5 rounded font-mono">OFFLINE HQ</span>
        </div>
        <div class="text-[10px] text-game-muted font-mono tracking-tight">DUAL-ENGINE TACTICAL LAUNCHER</div>
      </div>
    </div>

    <!-- Center: Player Card & 5 Bags Quick Switch -->
    <div class="flex items-center space-x-5">
      <!-- Player Badge -->
      <div class="flex items-center space-x-2.5 bg-black/40 border border-game-border px-3 py-1 rounded-full">
        <div class="w-6 h-6 rounded-full bg-gradient-to-tr from-blue-600 to-indigo-400 flex items-center justify-center text-xs font-bold text-white shadow-sm">
          {{ (profile.playerName || 'P')[0] }}
        </div>
        <div class="flex flex-col">
          <div class="flex items-center space-x-1.5">
            <span class="text-xs font-medium text-slate-200">{{ profile.playerName || '离线指挥官' }}</span>
            <span class="text-[10px] bg-amber-500/20 text-amber-400 border border-amber-500/40 px-1 rounded font-bold">
              VIP {{ profile.vipLv || 18 }}
            </span>
          </div>
          <span class="text-[10px] text-game-muted font-mono">LV.{{ profile.level || 100 }} · {{ profile.rank || '元帅' }}</span>
        </div>
      </div>

      <!-- 5-Bag Switch Tabs -->
      <div class="flex items-center bg-black/50 p-0.5 rounded-lg border border-game-border">
        <button
          v-for="idx in 5"
          :key="idx"
          @click="onSelectBag(idx)"
          :class="[
            'px-2.5 py-1 text-xs font-semibold rounded transition-all duration-150 flex items-center space-x-1',
            activeBag === idx
              ? 'bg-gradient-to-r from-amber-500 to-amber-600 text-black shadow-glow-gold'
              : 'text-game-muted hover:text-slate-200 hover:bg-white/5'
          ]"
        >
          <Shield class="w-3 h-3" />
          <span>背包 {{ idx }}</span>
        </button>
      </div>
    </div>

    <!-- Right: Classic Flash Lobby Entry, Settings & Window Controls -->
    <div class="flex items-center space-x-2">
      <!-- One-click Classic Flash AIR Lobby -->
      <button
        @click="$emit('launch-flash')"
        class="flex items-center space-x-1.5 px-3 py-1.5 rounded-md bg-gradient-to-r from-cyan-950 to-blue-900 border border-cyan-500/50 hover:border-cyan-400 text-cyan-300 hover:text-white transition shadow-sm hover:shadow-glow-cyan text-xs font-medium"
        title="唤起官方原版 Adobe AIR 大厅 (1:1 原作 Flash 动效与完整音效)"
      >
        <Sparkles class="w-3.5 h-3.5 text-cyan-400 animate-pulse" />
        <span>原版经典大厅</span>
      </button>

      <!-- Settings Button -->
      <button
        @click="$emit('open-settings')"
        class="p-1.5 rounded hover:bg-slate-800 text-game-muted hover:text-white transition"
        title="设置与路径"
      >
        <Settings class="w-4 h-4" />
      </button>

      <!-- Window Minimze / Maximize / Close -->
      <div class="flex items-center space-x-1 pl-2 border-l border-game-border">
        <button
          @click="api.minimizeWindow()"
          class="p-1.5 rounded hover:bg-slate-800 text-game-muted hover:text-white transition"
        >
          <Minus class="w-3.5 h-3.5" />
        </button>
        <button
          @click="api.maximizeWindow()"
          class="p-1.5 rounded hover:bg-slate-800 text-game-muted hover:text-white transition"
        >
          <Square class="w-3 h-3" />
        </button>
        <button
          @click="api.closeWindow()"
          class="p-1.5 rounded hover:bg-red-600 text-game-muted hover:text-white transition"
        >
          <X class="w-3.5 h-3.5" />
        </button>
      </div>
    </div>
  </header>
</template>

<script setup>
import { Crosshair, Shield, Sparkles, Settings, Minus, Square, X } from 'lucide-vue-next';
import { api } from '../api';
import { sound } from '../utils/audio';

const props = defineProps({
  profile: { type: Object, default: () => ({}) },
  activeBag: { type: Number, default: 1 }
});

const emit = defineEmits(['update:activeBag', 'open-settings', 'launch-flash']);

function onSelectBag(idx) {
  sound.playSwitch();
  emit('update:activeBag', idx);
  api.setActiveBag(idx);
}
</script>
