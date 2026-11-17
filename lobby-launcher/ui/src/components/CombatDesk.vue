<template>
  <div class="flex-1 flex overflow-hidden">
    <!-- Left: Combat Deployment Config & Launch Button -->
    <div class="w-96 bg-game-card/60 border-r border-game-border flex flex-col p-5 space-y-4 shrink-0 overflow-y-auto">
      <div class="flex items-center justify-between">
        <h2 class="text-sm font-bold text-amber-400 flex items-center space-x-1.5">
          <Crosshair class="w-4 h-4" />
          <span>战术作战部署</span>
        </h2>
        <span class="text-[11px] text-game-muted font-mono">UNITY 3D CLIENT</span>
      </div>

      <!-- Current Selected Map Card Preview -->
      <div class="relative h-44 rounded-xl overflow-hidden border border-amber-500/50 shadow-glow-gold group">
        <img
          :src="getMapImage(selectedMap)"
          :alt="selectedMap"
          class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          @error="onImgError"
        />
        <div class="absolute inset-0 bg-gradient-to-t from-black/90 via-black/30 to-transparent flex flex-col justify-end p-3">
          <div class="text-xs text-amber-400 font-mono">{{ selectedMap }}</div>
          <div class="text-base font-black text-white tracking-wide">{{ getMapDisplayName(selectedMap) }}</div>
        </div>
      </div>

      <!-- Battle Mode Selector -->
      <div class="space-y-1.5">
        <label class="text-xs font-semibold text-slate-300 flex items-center justify-between">
          <span>作战模式</span>
          <span class="text-[10px] text-game-muted">已选：{{ currentModeName }}</span>
        </label>
        <a-select v-model="selectedMode" placeholder="请选择游戏模式" class="w-full">
          <a-option v-for="m in modes" :key="m.id" :value="m.id">{{ m.name }}</a-option>
        </a-select>
      </div>

      <!-- Bot Controls -->
      <div class="p-3.5 rounded-lg bg-black/40 border border-slate-800 space-y-3">
        <div class="text-xs font-bold text-amber-400/90 flex items-center space-x-1.5">
          <Bot class="w-3.5 h-3.5" />
          <span>离线单机 AI 配置</span>
        </div>

        <!-- Ally Bots -->
        <div class="space-y-1">
          <div class="flex items-center justify-between text-xs text-slate-300">
            <span>友军 Bot 数量</span>
            <span class="font-mono text-amber-400">{{ allyBotCount }} 人</span>
          </div>
          <a-slider v-model="allyBotCount" :min="0" :max="8" :step="1" />
        </div>

        <!-- Enemy Bots -->
        <div class="space-y-1">
          <div class="flex items-center justify-between text-xs text-slate-300">
            <span>敌军 Bot 数量</span>
            <span class="font-mono text-red-400">{{ enemyBotCount }} 人</span>
          </div>
          <a-slider v-model="enemyBotCount" :min="0" :max="8" :step="1" />
        </div>

        <!-- Difficulty -->
        <div class="space-y-1">
          <label class="text-xs text-slate-300">Bot 战术智商 / 难度</label>
          <a-select v-model="botDifficulty" size="small" class="w-full">
            <a-option value="easy">简单 (新人适应)</a-option>
            <a-option value="normal">普通 (标准射击水平)</a-option>
            <a-option value="hard">专家 (快速反应与身法)</a-option>
            <a-option value="nightmare">噩梦 (瞬狙与极限锁头)</a-option>
          </a-select>
        </div>

        <!-- God Mode Switch -->
        <div class="flex items-center justify-between pt-1 border-t border-white/5">
          <div class="flex flex-col">
            <span class="text-xs font-medium text-slate-200">无敌上帝模式 (God Mode)</span>
            <span class="text-[10px] text-game-muted">锁定血量为99999</span>
          </div>
          <a-switch v-model="godMode" />
        </div>
      </div>

      <!-- Big Glowing Launch Combat Button -->
      <button
        @click="onLaunchCombat"
        :disabled="isLaunching"
        class="w-full py-3.5 rounded-xl bg-gradient-to-r from-red-600 via-amber-600 to-amber-500 hover:from-red-500 hover:to-amber-400 text-black font-black text-sm tracking-wider uppercase transition shadow-glow-gold hover:shadow-lg disabled:opacity-50 flex items-center justify-center space-x-2 shrink-0"
      >
        <Flame class="w-5 h-5 fill-current animate-pulse" />
        <span>{{ isLaunching ? '正在部署启动中...' : '🔥 立即出击 (启动 3D 战斗)' }}</span>
      </button>

      <!-- Launch Output Logs Accordion -->
      <div v-if="launchLogs.length > 0" class="p-2.5 rounded bg-black/60 border border-slate-800 text-[10px] font-mono text-emerald-400 space-y-0.5 max-h-32 overflow-y-auto">
        <div v-for="(log, lIdx) in launchLogs" :key="lIdx">> {{ log }}</div>
      </div>
    </div>

    <!-- Right: Map Library & Search -->
    <div class="flex-1 flex flex-col overflow-hidden bg-black/20">
      <div class="p-3 bg-game-card/40 border-b border-game-border flex items-center justify-between">
        <div class="text-xs font-bold text-slate-200 flex items-center space-x-2">
          <MapPin class="w-4 h-4 text-amber-400" />
          <span>战区地图库 ({{ maps.length }} 张地图)</span>
        </div>
        <div class="relative w-64">
          <Search class="w-4 h-4 text-game-muted absolute left-2.5 top-2" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜索地图名称..."
            class="w-full bg-black/50 border border-game-border focus:border-amber-400 rounded-md pl-8 pr-3 py-1 text-xs text-white placeholder-slate-500 focus:outline-none transition"
          />
        </div>
      </div>

      <div class="flex-1 overflow-y-auto p-4">
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          <div
            v-for="map in filteredMaps"
            :key="map.key"
            @click="onSelectMap(map)"
            class="rounded-xl overflow-hidden border bg-game-card/80 transition-all duration-200 cursor-pointer group flex flex-col justify-between"
            :class="map.key === selectedMap ? 'border-amber-400 shadow-glow-gold' : 'border-slate-800 hover:border-slate-600'"
          >
            <!-- Map Thumbnail -->
            <div class="h-32 relative overflow-hidden bg-black/80">
              <img
                :src="getMapImage(map.key)"
                :alt="map.name"
                class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                loading="lazy"
                @error="onImgError"
              />
              <div class="absolute top-2 right-2 px-1.5 py-0.5 rounded bg-black/70 border border-white/10 text-[10px] text-amber-400 font-mono">
                {{ map.key }}
              </div>
            </div>

            <!-- Map Metadata -->
            <div class="p-3 flex items-center justify-between">
              <div>
                <div class="text-xs font-bold text-slate-100 group-hover:text-amber-400 transition">{{ map.name || map.key }}</div>
                <div class="text-[10px] text-game-muted">{{ map.category || '团队/竞技/爆破' }}</div>
              </div>
              <button
                class="px-2.5 py-1 text-xs rounded font-bold transition"
                :class="map.key === selectedMap ? 'bg-amber-500 text-black' : 'bg-slate-800 text-slate-300 group-hover:bg-amber-500/20 group-hover:text-amber-300'"
              >
                {{ map.key === selectedMap ? '当前已选' : '选择作战' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { Crosshair, Bot, Flame, MapPin, Search } from 'lucide-vue-next';
import { Message } from '@arco-design/web-vue';
import { api } from '../api';
import { sound } from '../utils/audio';

const props = defineProps({
  maps: { type: Array, default: () => [] },
  activeBag: { type: Number, default: 1 },
  activeCareer: { type: String, default: 'cleaner' }
});

const selectedMap = ref('maps/map1');
const selectedMode = ref('team_deathmatch');
const allyBotCount = ref(3);
const enemyBotCount = ref(4);
const botDifficulty = ref('normal');
const godMode = ref(false);
const searchQuery = ref('');
const isLaunching = ref(false);
const launchLogs = ref([]);

const modes = [
  { id: 'team_deathmatch', name: '团队竞技 (Team Deathmatch)' },
  { id: 'double_tower', name: '双塔惊魂 (Double Tower Horror)' },
  { id: 'mutation', name: '终极变异 (Ultimate Mutation)' },
  { id: 'big_head', name: '大头英雄 (Big Head Hero)' },
  { id: 'gun_king', name: '枪王之王 (Gun King)' },
  { id: 'knife_only', name: '刀战锋芒 (Knife Only)' },
  { id: 'sniper_only', name: '生死狙击 (Sniper Battle)' }
];

const currentModeName = computed(() => {
  const m = modes.find(x => x.id === selectedMode.value);
  return m ? m.name : selectedMode.value;
});

const filteredMaps = computed(() => {
  if (!searchQuery.value.trim()) return props.maps;
  const q = searchQuery.value.trim().toLowerCase();
  return props.maps.filter(m => (m.name && m.name.toLowerCase().includes(q)) || (m.key && m.key.toLowerCase().includes(q)));
});

function onSelectMap(map) {
  sound.playClick();
  selectedMap.value = map.key;
  Message.info(`已选定战区地图：${map.name || map.key}`);
}

function getMapDisplayName(key) {
  const m = props.maps.find(x => x.key === key);
  return m ? (m.name || m.key) : key;
}

function getMapImage(key) {
  if (!key) return '/assets/icon.png';
  const clean = key.replace('maps/', '').replace('unitymaps/', '');
  return `/previews/maps/${clean}.png`;
}

function onImgError(e) {
  e.target.src = '/assets/icon.png';
}

async function onLaunchCombat() {
  sound.playEquip();
  isLaunching.value = true;
  launchLogs.value = ['正在下发战斗契约并校验地图包...'];
  try {
    const launchArgs = {
      map: selectedMap.value,
      mode: selectedMode.value,
      career: props.activeCareer,
      active_bag: props.activeBag,
      ally_bot_count: allyBotCount.value,
      enemy_bot_count: enemyBotCount.value,
      bot_difficulty: botDifficulty.value,
      god_mode: godMode.value
    };
    launchLogs.value.push(`启动配置：map=${launchArgs.map}, mode=${launchArgs.mode}, bag=${launchArgs.active_bag}`);
    const res = await api.launchCombat(launchArgs);
    launchLogs.value.push('Unity 3D 战斗客户端已拉起，正在进入对局！');
    Message.success('Unity 战斗客户端启动成功！');
  } catch (err) {
    launchLogs.value.push(`启动异常：${err}`);
    Message.error('启动失败：' + err);
  } finally {
    isLaunching.value = false;
  }
}
</script>
