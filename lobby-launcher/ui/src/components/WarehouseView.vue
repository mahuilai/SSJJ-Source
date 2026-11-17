<template>
  <div class="flex-1 flex overflow-hidden">
    <!-- Left: Current Active Bag Slots (4 Slots: Primary, Secondary, Melee, Throwable) -->
    <div class="w-80 bg-game-card/60 border-r border-game-border flex flex-col p-4 space-y-3 shrink-0">
      <div class="flex items-center justify-between">
        <h2 class="text-sm font-bold text-amber-400 flex items-center space-x-1.5">
          <Briefcase class="w-4 h-4" />
          <span>背包 {{ activeBag }} 当前配置</span>
        </h2>
        <span class="text-[11px] text-game-muted font-mono">4 个作战装备槽</span>
      </div>

      <!-- 4 Standard Weapon Slots -->
      <div class="space-y-2.5 flex-1 overflow-y-auto pr-1">
        <div
          v-for="(slotName, sIdx) in slotLabels"
          :key="sIdx"
          class="relative p-3 rounded-lg border transition-all duration-200 group bg-black/40"
          :class="currentSlots[sIdx]?.weapon ? 'border-amber-500/50 hover:border-amber-400' : 'border-slate-800 border-dashed'"
        >
          <!-- Slot Badge -->
          <div class="flex items-center justify-between text-[11px] mb-2">
            <span class="font-mono text-amber-400/90 font-semibold">{{ slotName }}</span>
            <span v-if="currentSlots[sIdx]?.skin" class="text-[10px] bg-purple-900/60 text-purple-300 border border-purple-700/50 px-1.5 rounded">
              {{ currentSlots[sIdx].skin }}
            </span>
          </div>

          <!-- Equipped Weapon Info -->
          <div v-if="currentSlots[sIdx]?.weapon" class="flex items-center space-x-3">
            <div class="w-16 h-12 rounded bg-black/60 border border-slate-700/60 flex items-center justify-center p-1 shrink-0">
              <img
                :src="getWeaponImage(currentSlots[sIdx].weapon)"
                :alt="currentSlots[sIdx].weapon"
                class="max-w-full max-h-full object-contain filter drop-shadow"
                @error="onImgError"
              />
            </div>
            <div class="flex-1 min-w-0">
              <div class="text-xs font-bold text-slate-100 truncate">
                {{ getWeaponDisplayName(currentSlots[sIdx].weapon) }}
              </div>
              <div class="text-[10px] text-game-muted font-mono truncate">
                {{ currentSlots[sIdx].weapon }}
              </div>
            </div>
          </div>
          <div v-else class="h-12 flex items-center justify-center text-xs text-slate-600">
            <span>空槽位 (从右侧仓库点击装备)</span>
          </div>
        </div>
      </div>

      <!-- Quick Tips -->
      <div class="p-2.5 rounded bg-black/30 border border-slate-800 text-[11px] text-game-muted flex items-start space-x-2">
        <Info class="w-4 h-4 text-cyan-400 shrink-0 mt-0.5" />
        <div>
          点击右侧仓库中的任意武器，即可一键装备至当前选中的作战背包。重启或启动战斗时永久自动生效。
        </div>
      </div>
    </div>

    <!-- Right: Personal Warehouse Catalog & Search -->
    <div class="flex-1 flex flex-col overflow-hidden bg-black/20">
      <!-- Toolbar: Categories, Quality Filters & Search -->
      <div class="p-3 bg-game-card/40 border-b border-game-border flex flex-wrap items-center justify-between gap-3">
        <!-- Category Tabs -->
        <div class="flex items-center space-x-1 bg-black/40 p-1 rounded-lg border border-game-border">
          <button
            v-for="cat in categories"
            :key="cat.id"
            @click="selectCategory(cat.id)"
            :class="[
              'px-3 py-1 text-xs rounded transition font-medium',
              selectedCategory === cat.id
                ? 'bg-amber-500 text-black font-bold shadow-sm'
                : 'text-game-muted hover:text-white'
            ]"
          >
            {{ cat.name }} ({{ cat.count }})
          </button>
        </div>

        <!-- Search Bar -->
        <div class="relative w-64">
          <Search class="w-4 h-4 text-game-muted absolute left-2.5 top-2" />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="搜索武器名称或代号..."
            class="w-full bg-black/50 border border-game-border focus:border-amber-400 rounded-md pl-8 pr-3 py-1 text-xs text-white placeholder-slate-500 focus:outline-none transition"
          />
        </div>
      </div>

      <!-- Item Grid Area -->
      <div class="flex-1 overflow-y-auto p-4">
        <!-- Grid of Weapon Cards -->
        <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-3">
          <div
            v-for="weapon in filteredWeapons"
            :key="weapon.id || weapon.key"
            @click="onSelectWeapon(weapon)"
            class="relative rounded-lg p-2.5 flex flex-col justify-between transition-all duration-150 cursor-pointer group"
            :class="getFrameClass(weapon)"
          >
            <!-- Top: Name & Category -->
            <div class="flex items-start justify-between">
              <span class="text-xs font-bold text-slate-100 group-hover:text-amber-400 transition truncate pr-1">
                {{ weapon.name || weapon.key }}
              </span>
              <span
                v-if="weapon.qualityTag"
                class="text-[9px] px-1 py-0.5 rounded font-bold shrink-0"
                :class="getQualityTagClass(weapon.qualityTag)"
              >
                {{ weapon.qualityTag }}
              </span>
            </div>

            <!-- Weapon Image -->
            <div class="h-24 my-2 flex items-center justify-center p-1 relative overflow-hidden">
              <img
                :src="getWeaponImage(weapon.key)"
                :alt="weapon.name"
                class="max-w-full max-h-full object-contain filter drop-shadow group-hover:scale-105 transition-transform duration-200"
                loading="lazy"
                @error="onImgError"
              />
            </div>

            <!-- Footer: Key & Quick Equip Action -->
            <div class="flex items-center justify-between text-[10px] text-game-muted border-t border-white/5 pt-1.5">
              <span class="font-mono truncate max-w-[80px]">{{ weapon.categoryName || '武器' }}</span>
              <button
                @click.stop="quickEquip(weapon)"
                class="px-2 py-0.5 rounded bg-amber-500/20 hover:bg-amber-500 text-amber-300 hover:text-black font-semibold border border-amber-500/40 transition"
              >
                装备
              </button>
            </div>
          </div>
        </div>

        <!-- Empty State -->
        <div v-if="filteredWeapons.length === 0" class="h-64 flex flex-col items-center justify-center text-game-muted">
          <PackageOpen class="w-12 h-12 text-slate-700 mb-2" />
          <span class="text-sm">未找到匹配的军火库装备</span>
        </div>
      </div>
    </div>

    <!-- Weapon Equip Modal / Drawer -->
    <a-modal
      v-model:visible="modalVisible"
      :title="selectedWeapon ? `装配武器 · ${selectedWeapon.name}` : '装配武器'"
      :footer="false"
      modal-class="game-modal"
    >
      <div v-if="selectedWeapon" class="space-y-4">
        <div class="flex items-center space-x-4 p-3 rounded-lg bg-black/60 border border-slate-800">
          <div class="w-24 h-16 rounded bg-black/80 flex items-center justify-center p-1 border border-slate-700">
            <img :src="getWeaponImage(selectedWeapon.key)" class="max-w-full max-h-full object-contain" />
          </div>
          <div>
            <div class="text-sm font-bold text-white">{{ selectedWeapon.name }}</div>
            <div class="text-xs text-game-muted font-mono">内部代码：{{ selectedWeapon.key }}</div>
            <div class="text-xs text-amber-400 mt-1">推荐装备槽位：{{ recommendSlot(selectedWeapon) }}</div>
          </div>
        </div>

        <div class="text-xs font-semibold text-slate-300">请选择要装配的作战背包槽位：</div>
        <div class="grid grid-cols-2 gap-2">
          <button
            v-for="(slotName, sIdx) in slotLabels"
            :key="sIdx"
            @click="doEquip(sIdx)"
            class="p-2.5 rounded-lg border border-slate-800 hover:border-amber-400 bg-slate-900/80 hover:bg-amber-500/10 text-left transition flex items-center justify-between"
          >
            <div class="flex flex-col">
              <span class="text-xs font-bold text-white">{{ slotName }}</span>
              <span class="text-[10px] text-game-muted">当前：{{ currentSlots[sIdx]?.weapon || '无' }}</span>
            </div>
            <ArrowRight class="w-4 h-4 text-amber-400" />
          </button>
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { Briefcase, Search, Info, PackageOpen, ArrowRight } from 'lucide-vue-next';
import { Message } from '@arco-design/web-vue';
import { api } from '../api';
import { sound } from '../utils/audio';

const props = defineProps({
  weapons: { type: Array, default: () => [] },
  activeBag: { type: Number, default: 1 },
  profile: { type: Object, default: () => ({}) }
});

const emit = defineEmits(['refresh-profile']);

const slotLabels = ['1. 主武器', '2. 副武器', '3. 近战武器', '4. 投掷武器'];
const selectedCategory = ref('all');
const searchQuery = ref('');
const modalVisible = ref(false);
const selectedWeapon = ref(null);

const categories = computed(() => [
  { id: 'all', name: '全部', count: props.weapons.length },
  { id: 'primary', name: '主武器', count: props.weapons.filter(w => isPrimary(w)).length },
  { id: 'secondary', name: '副武器', count: props.weapons.filter(w => isSecondary(w)).length },
  { id: 'melee', name: '近战', count: props.weapons.filter(w => isMelee(w)).length },
  { id: 'throwable', name: '投掷', count: props.weapons.filter(w => isThrowable(w)).length },
]);

const currentSlots = computed(() => {
  const bagIdx = props.activeBag - 1;
  const bag = props.profile?.bags?.[bagIdx];
  if (!bag) return [{}, {}, {}, {}];
  return [
    { weapon: bag.primary, skin: bag.primary_skin },
    { weapon: bag.secondary, skin: bag.secondary_skin },
    { weapon: bag.melee, skin: bag.melee_skin },
    { weapon: bag.throwable, skin: bag.throwable_skin },
  ];
});

function isPrimary(w) {
  const cat = (w.category || '').toLowerCase();
  return cat.includes('primary') || cat.includes('rifle') || cat.includes('sniper') || cat.includes('mg') || cat.includes('smg') || cat.includes('shotgun');
}
function isSecondary(w) {
  const cat = (w.category || '').toLowerCase();
  return cat.includes('secondary') || cat.includes('pistol') || cat.includes('bow');
}
function isMelee(w) {
  const cat = (w.category || '').toLowerCase();
  return cat.includes('melee') || cat.includes('knife') || cat.includes('sword') || cat.includes('dagger');
}
function isThrowable(w) {
  const cat = (w.category || '').toLowerCase();
  return cat.includes('throwable') || cat.includes('grenade') || cat.includes('bomb');
}

const filteredWeapons = computed(() => {
  let list = props.weapons;
  if (selectedCategory.value === 'primary') list = list.filter(w => isPrimary(w));
  else if (selectedCategory.value === 'secondary') list = list.filter(w => isSecondary(w));
  else if (selectedCategory.value === 'melee') list = list.filter(w => isMelee(w));
  else if (selectedCategory.value === 'throwable') list = list.filter(w => isThrowable(w));

  if (searchQuery.value.trim()) {
    const q = searchQuery.value.trim().toLowerCase();
    list = list.filter(w => (w.name && w.name.toLowerCase().includes(q)) || (w.key && w.key.toLowerCase().includes(q)));
  }
  return list;
});

function selectCategory(catId) {
  sound.playSwitch();
  selectedCategory.value = catId;
}

function onSelectWeapon(weapon) {
  sound.playClick();
  selectedWeapon.value = weapon;
  modalVisible.value = true;
}

function quickEquip(weapon) {
  let slot = 0;
  if (isPrimary(weapon)) slot = 0;
  else if (isSecondary(weapon)) slot = 1;
  else if (isMelee(weapon)) slot = 2;
  else if (isThrowable(weapon)) slot = 3;

  doDirectEquip(weapon, slot);
}

function recommendSlot(weapon) {
  if (isPrimary(weapon)) return '1. 主武器';
  if (isSecondary(weapon)) return '2. 副武器';
  if (isMelee(weapon)) return '3. 近战武器';
  if (isThrowable(weapon)) return '4. 投掷武器';
  return '主武器';
}

function doEquip(slotIdx) {
  if (!selectedWeapon.value) return;
  doDirectEquip(selectedWeapon.value, slotIdx);
  modalVisible.value = false;
}

async function doDirectEquip(weapon, slotIdx) {
  sound.playEquip();
  try {
    await api.equipWeapon(props.activeBag - 1, slotIdx, weapon.key, '');
    Message.success(`已装备 [${weapon.name || weapon.key}] 到背包 ${props.activeBag} 的 ${slotLabels[slotIdx]}`);
    emit('refresh-profile');
  } catch (err) {
    Message.error('装备失败：' + err);
  }
}

function getWeaponImage(key) {
  if (!key) return '/assets/icon.png';
  return `/previews/weapons/${key}.png`;
}

function getWeaponDisplayName(key) {
  const found = props.weapons.find(w => w.key === key);
  return found ? (found.name || found.key) : key;
}

function getFrameClass(weapon) {
  const bg = weapon.background || '';
  if (bg.includes('hero')) return 'quality-frame-hero';
  if (bg.includes('gold')) return 'quality-frame-gold';
  if (bg.includes('brilliant')) return 'quality-frame-brilliant';
  if (bg.includes('god')) return 'quality-frame-god';
  return 'quality-frame-normal';
}

function getQualityTagClass(tag) {
  if (tag === '英雄') return 'bg-red-950 text-red-300 border border-red-700';
  if (tag === '黄金') return 'bg-amber-950 text-amber-300 border border-amber-700';
  if (tag === '传说') return 'bg-purple-950 text-purple-300 border border-purple-700';
  return 'bg-slate-800 text-slate-300';
}

function onImgError(e) {
  e.target.src = '/assets/icon.png';
}
</script>
