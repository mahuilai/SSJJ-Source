<template>
  <div class="h-screen w-screen flex flex-col bg-game-bg select-none overflow-hidden">
    <!-- Top Global Header -->
    <HeaderBar
      :profile="profile"
      :active-bag="activeBag"
      @update:active-bag="onBagChange"
      @open-settings="settingsVisible = true"
      @launch-flash="onLaunchFlashLobby"
    />

    <!-- Main Navigation Bar -->
    <nav class="h-11 bg-game-card/70 border-b border-game-border flex items-center justify-between px-6 shrink-0">
      <div class="flex items-center space-x-1">
        <button
          v-for="tab in navTabs"
          :key="tab.id"
          @click="onSelectTab(tab.id)"
          :class="[
            'px-4 py-1.5 text-xs font-bold rounded-md transition-all duration-150 flex items-center space-x-2',
            currentTab === tab.id
              ? 'bg-amber-500/15 text-amber-400 border border-amber-500/50 shadow-sm'
              : 'text-game-muted hover:text-slate-200 hover:bg-white/5'
          ]"
        >
          <component :is="tab.icon" class="w-3.5 h-3.5" />
          <span>{{ tab.label }}</span>
          <span v-if="tab.badge" class="ml-1 text-[10px] px-1.5 py-0.2 rounded-full bg-slate-800 text-slate-300 font-mono">
            {{ tab.badge }}
          </span>
        </button>
      </div>

      <!-- Quick Status Ticker -->
      <div class="flex items-center space-x-4 text-xs font-mono text-game-muted">
        <span class="flex items-center space-x-1.5">
          <span class="w-2 h-2 rounded-full bg-emerald-500 animate-ping"></span>
          <span class="text-emerald-400">本地离线沙盒已就绪</span>
        </span>
        <span>|</span>
        <span>军械总库: <strong class="text-amber-400">{{ weapons.length }}</strong> 件</span>
        <span>|</span>
        <span>特种部队: <strong class="text-cyan-400">{{ characters.length }}</strong> 名</span>
      </div>
    </nav>

    <!-- Main Active Workspace View -->
    <main class="flex-1 flex overflow-hidden">
      <WarehouseView
        v-if="currentTab === 'warehouse'"
        :weapons="weapons"
        :active-bag="activeBag"
        :profile="profile"
        @refresh-profile="loadProfile"
      />

      <RosterView
        v-else-if="currentTab === 'roster'"
        :characters="characters"
        :active-career="activeCareer"
        @update:active-career="val => activeCareer = val"
        @refresh-profile="loadProfile"
      />

      <CombatDesk
        v-else-if="currentTab === 'combat'"
        :maps="maps"
        :active-bag="activeBag"
        :active-career="activeCareer"
      />
    </main>

    <!-- Settings Dialog -->
    <SettingsModal
      v-model:visible="settingsVisible"
      :settings="settings"
      @refresh-settings="loadSettings"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { Package, Users, Swords } from 'lucide-vue-next';
import { Message, Modal } from '@arco-design/web-vue';
import HeaderBar from './components/HeaderBar.vue';
import WarehouseView from './components/WarehouseView.vue';
import RosterView from './components/RosterView.vue';
import CombatDesk from './components/CombatDesk.vue';
import SettingsModal from './components/SettingsModal.vue';
import { api } from './api';
import { sound } from './utils/audio';

const currentTab = ref('warehouse');
const activeBag = ref(1);
const activeCareer = ref('cleaner');
const settingsVisible = ref(false);

const weapons = ref([]);
const characters = ref([]);
const maps = ref([]);
const profile = ref({
  playerName: '离线指挥官',
  level: 100,
  vipLv: 18,
  rank: '全服元帅',
  bags: []
});
const settings = ref({});

const navTabs = computed(() => [
  { id: 'warehouse', label: '个人军械仓库', icon: Package, badge: weapons.value.length || '21,669' },
  { id: 'roster', label: '特战特种干员', icon: Users, badge: characters.value.length || '335' },
  { id: 'combat', label: '战术作战指挥台', icon: Swords, badge: '快速出击' },
]);

function onSelectTab(tabId) {
  sound.playSwitch();
  currentTab.value = tabId;
}

function onBagChange(bagIdx) {
  activeBag.value = bagIdx;
}

async function loadInventory() {
  try {
    const data = await api.getInventory();
    if (data) {
      weapons.value = data.weapons || [];
      characters.value = data.characters || [];
      maps.value = data.maps || [];
    }
  } catch (err) {
    console.warn('获取装备清单异常（降级为本地预载）：', err);
  }
}

async function loadProfile() {
  try {
    const data = await api.getProfile();
    if (data) {
      profile.value = data;
      if (data.active_bag) activeBag.value = data.active_bag;
      if (data.career) activeCareer.value = data.career;
    }
  } catch (err) {
    console.warn('获取玩家存档异常：', err);
  }
}

async function loadSettings() {
  try {
    const data = await api.getSettings();
    if (data) {
      settings.value = data;
    }
  } catch (err) {
    console.warn('获取启动器配置异常：', err);
  }
}

async function onLaunchFlashLobby() {
  sound.playEquip();
  try {
    await api.launchFlashLobby();
    Modal.success({
      title: '原版经典大厅唤起中',
      content: '已拉起官方原版 Adobe AIR 大厅！你可以体验原作 100% 原始 Flash 动效与交互。大厅内的换装与战术配置将与本启动器实时同步互通。',
      okText: '好的'
    });
  } catch (err) {
    Message.error('拉起原版大厅失败：' + err);
  }
}

onMounted(() => {
  loadInventory();
  loadProfile();
  loadSettings();
});
</script>
