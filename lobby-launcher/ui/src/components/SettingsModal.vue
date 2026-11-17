<template>
  <a-modal
    :visible="visible"
    @cancel="$emit('update:visible', false)"
    title="启动器与环境设置"
    :footer="false"
    modal-class="game-modal"
    width="640px"
  >
    <div class="space-y-4 text-xs">
      <!-- Game Directory -->
      <div class="space-y-1">
        <label class="font-bold text-slate-300">Unity 3D 战斗客户端目录 (3_64)</label>
        <div class="flex space-x-2">
          <input
            v-model="form.game_dir"
            type="text"
            class="flex-1 bg-black/60 border border-slate-700 rounded px-2.5 py-1.5 text-slate-200 focus:outline-none focus:border-amber-400 font-mono"
            placeholder="D:\SSJJ-4399\battle\3_64"
          />
        </div>
        <p class="text-[10px] text-game-muted">存放 SSJJ_BattleClient_Unity.exe 与 AssetBundle 的实际目录。</p>
      </div>

      <!-- Start Script -->
      <div class="space-y-1">
        <label class="font-bold text-slate-300">启动脚本路径 (launch_offline_battle.py)</label>
        <input
          v-model="form.start_script"
          type="text"
          class="w-full bg-black/60 border border-slate-700 rounded px-2.5 py-1.5 text-slate-200 focus:outline-none focus:border-amber-400 font-mono"
          placeholder="portable\scripts\launch_offline_battle.py"
        />
      </div>

      <!-- Audio Options -->
      <div class="p-3 rounded bg-black/40 border border-slate-800 flex items-center justify-between">
        <div class="flex flex-col">
          <span class="font-bold text-slate-200">大厅交互音效</span>
          <span class="text-[10px] text-game-muted">点击、切换标签与换装装备时播放战术反馈提示音</span>
        </div>
        <a-switch v-model="soundEnabled" @change="onToggleSound" />
      </div>

      <!-- Save Button -->
      <div class="pt-3 border-t border-slate-800 flex justify-end space-x-2">
        <button
          @click="$emit('update:visible', false)"
          class="px-4 py-1.5 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 transition"
        >
          取消
        </button>
        <button
          @click="onSave"
          class="px-5 py-1.5 rounded bg-amber-500 hover:bg-amber-400 text-black font-bold transition shadow-sm"
        >
          保存配置
        </button>
      </div>
    </div>
  </a-modal>
</template>

<script setup>
import { ref, watch } from 'vue';
import { Message } from '@arco-design/web-vue';
import { api } from '../api';
import { sound } from '../utils/audio';

const props = defineProps({
  visible: { type: Boolean, default: false },
  settings: { type: Object, default: () => ({}) }
});

const emit = defineEmits(['update:visible', 'refresh-settings']);

const form = ref({
  game_dir: '',
  start_script: ''
});

const soundEnabled = ref(true);

watch(() => props.settings, (val) => {
  if (val) {
    form.value.game_dir = val.game_dir || '';
    form.value.start_script = val.start_script || '';
  }
}, { immediate: true });

function onToggleSound(val) {
  sound.enabled = val;
  if (val) sound.playClick();
}

async function onSave() {
  sound.playEquip();
  try {
    await api.saveSettings(form.value);
    Message.success('设置已保存');
    emit('refresh-settings');
    emit('update:visible', false);
  } catch (err) {
    Message.error('保存设置失败：' + err);
  }
}
</script>
