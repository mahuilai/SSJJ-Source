<template>
  <div class="flex-1 flex overflow-hidden">
    <!-- Left: Selected Active Character Spotlight -->
    <div class="w-88 bg-game-card/60 border-r border-game-border flex flex-col p-4 space-y-4 shrink-0">
      <div class="flex items-center justify-between">
        <h2 class="text-sm font-bold text-amber-400 flex items-center space-x-1.5">
          <UserCheck class="w-4 h-4" />
          <span>出战特种部队</span>
        </h2>
        <span class="text-[11px] text-game-muted font-mono">当前指派</span>
      </div>

      <!-- Character Poster Area -->
      <div class="relative h-72 rounded-xl bg-gradient-to-b from-black/80 to-slate-900 border border-amber-500/40 p-3 flex flex-col items-center justify-between shadow-glow-gold overflow-hidden">
        <div class="absolute inset-0 bg-radial from-amber-500/10 via-transparent to-transparent pointer-events-none"></div>

        <div class="w-full flex items-center justify-between z-10">
          <span class="text-[11px] font-bold px-2 py-0.5 rounded bg-amber-500/20 text-amber-400 border border-amber-500/40">
            {{ activeCharacterObj?.faction || '特战人员' }}
          </span>
          <span class="text-[10px] text-game-muted font-mono">{{ activeCareerKey }}</span>
        </div>

        <div class="flex-1 flex items-center justify-center p-2 z-10">
          <img
            :src="getCharacterImage(activeCareerKey)"
            :alt="activeCareerKey"
            class="max-w-full max-h-56 object-contain filter drop-shadow-2xl"
            @error="onImgError"
          />
        </div>

        <div class="w-full text-center z-10 bg-black/60 backdrop-blur py-1.5 rounded-lg border border-white/5">
          <div class="text-sm font-bold text-white">{{ activeCharacterObj?.name || activeCareerKey }}</div>
          <div class="text-[10px] text-amber-400/90 font-mono">当前出战人员</div>
        </div>
      </div>

      <!-- Role Description / Instructions -->
      <div class="p-3 rounded-lg bg-black/40 border border-slate-800 text-xs text-game-muted space-y-1">
        <div class="font-bold text-slate-300 flex items-center space-x-1">
          <Info class="w-3.5 h-3.5 text-cyan-400" />
          <span>阵营换装说明</span>
        </div>
        <p class="text-[11px] leading-relaxed">
          生死狙击中角色分为【联军】与【风暴】两大阵营。你可以在右侧切换阵营并选择对应的特种干员，点击卡片直接指派为出战角色。
        </p>
      </div>
    </div>

    <!-- Right: Characters Roster Grid & Faction Switch -->
    <div class="flex-1 flex flex-col overflow-hidden bg-black/20">
      <!-- Faction & Search Bar -->
      <div class="p-3 bg-game-card/40 border-b border-game-border flex items-center justify-between gap-3">
        <!-- Factions -->
        <div class="flex items-center space-x-1 bg-black/40 p-1 rounded-lg border border-game-border">
          <button
            v-for="f in factions"
            :key="f.id"
            @click="selectFaction(f.id)"
            :class="[
              'px-3 py-1 text-xs rounded transition font-medium',
              selectedFaction === f.id
                ? 'bg-amber-500 text-black font-bold shadow-sm'
                : 'text-game-muted hover:text-white'
            ]"
          >
            {{ f.name }} ({{ f.count }})
          </button>
        </div>

        <!-- Search -->
        <div class="relative w-64">
          <Search class="w-4 h-4 text-game-muted absolute left-2.5 top-2" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜索特种人员姓名/代号..."
            class="w-full bg-black/50 border border-game-border focus:border-amber-400 rounded-md pl-8 pr-3 py-1 text-xs text-white placeholder-slate-500 focus:outline-none transition"
          />
        </div>
      </div>

      <!-- Character Card Grid -->
      <div class="flex-1 overflow-y-auto p-4">
        <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-3">
          <div
            v-for="char in filteredCharacters"
            :key="char.key"
            @click="onSelectCharacter(char)"
            class="relative rounded-lg p-3 flex flex-col justify-between transition-all duration-150 cursor-pointer group border bg-black/40"
            :class="char.key === activeCareerKey ? 'border-amber-400 bg-amber-500/10 shadow-glow-gold' : 'border-slate-800 hover:border-slate-600'"
          >
            <!-- Card Header -->
            <div class="flex items-center justify-between">
              <span class="text-xs font-bold text-slate-100 group-hover:text-amber-400 transition truncate pr-1">
                {{ char.name || char.key }}
              </span>
              <span
                v-if="char.faction"
                class="text-[9px] px-1 py-0.5 rounded font-mono"
                :class="char.faction.includes('风暴') ? 'bg-red-950/80 text-red-300' : 'bg-blue-950/80 text-blue-300'"
              >
                {{ char.faction }}
              </span>
            </div>

            <!-- Portrait Image -->
            <div class="h-28 my-2 flex items-center justify-center relative overflow-hidden">
              <img
                :src="getCharacterImage(char.key)"
                :alt="char.name"
                class="max-w-full max-h-full object-contain filter drop-shadow group-hover:scale-105 transition-transform duration-200"
                loading="lazy"
                @error="onImgError"
              />
            </div>

            <!-- Card Footer -->
            <div class="flex items-center justify-between text-[10px] text-game-muted border-t border-white/5 pt-1.5">
              <span class="font-mono truncate max-w-[80px]">{{ char.key }}</span>
              <button
                v-if="char.key === activeCareerKey"
                class="px-2 py-0.5 rounded bg-amber-500 text-black font-bold text-[10px]"
              >
                出战中
              </button>
              <button
                v-else
                @click.stop="onSelectCharacter(char)"
                class="px-2 py-0.5 rounded bg-slate-800 hover:bg-amber-500 hover:text-black font-semibold text-slate-300 transition text-[10px]"
              >
                指派出战
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
import { UserCheck, Info, Search } from 'lucide-vue-next';
import { Message } from '@arco-design/web-vue';
import { api } from '../api';
import { sound } from '../utils/audio';

const props = defineProps({
  characters: { type: Array, default: () => [] },
  activeCareer: { type: String, default: 'cleaner' }
});

const emit = defineEmits(['update:activeCareer', 'refresh-profile']);

const selectedFaction = ref('all');
const searchQuery = ref('');

const factions = computed(() => [
  { id: 'all', name: '全部人员', count: props.characters.length },
  { id: 'coalition', name: '联军阵营', count: props.characters.filter(c => isCoalition(c)).length },
  { id: 'storm', name: '风暴阵营', count: props.characters.filter(c => isStorm(c)).length }
]);

function isCoalition(c) {
  const f = (c.faction || '').toLowerCase();
  return f.includes('联军') || f.includes('coalition') || (!f.includes('风暴') && !f.includes('storm'));
}
function isStorm(c) {
  const f = (c.faction || '').toLowerCase();
  return f.includes('风暴') || f.includes('storm');
}

const activeCareerKey = computed(() => props.activeCareer);
const activeCharacterObj = computed(() => props.characters.find(c => c.key === activeCareerKey.value));

const filteredCharacters = computed(() => {
  let list = props.characters;
  if (selectedFaction.value === 'coalition') list = list.filter(c => isCoalition(c));
  else if (selectedFaction.value === 'storm') list = list.filter(c => isStorm(c));

  if (searchQuery.value.trim()) {
    const q = searchQuery.value.trim().toLowerCase();
    list = list.filter(c => (c.name && c.name.toLowerCase().includes(q)) || (c.key && c.key.toLowerCase().includes(q)));
  }
  return list;
});

function selectFaction(fId) {
  sound.playSwitch();
  selectedFaction.value = fId;
}

async function onSelectCharacter(char) {
  sound.playEquip();
  try {
    await api.equipCharacter(char.key, '');
    emit('update:activeCareer', char.key);
    Message.success(`已指派 [${char.name || char.key}] 为当前出战特种兵`);
    emit('refresh-profile');
  } catch (err) {
    Message.error('指派角色失败：' + err);
  }
}

function getCharacterImage(key) {
  if (!key) return '/assets/icon.png';
  return `/previews/characters/${key}.png`;
}

function onImgError(e) {
  e.target.src = '/assets/icon.png';
}
</script>
