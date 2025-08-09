<template>
  <!-- 设备管理弹窗 -->
  <el-dialog :visible="visible" width="90vw" top="5vh" center append-to-body destroy-on-close @close="handleClose">
    <template #title>
      <div style="margin: 0 10px 10px;display: flex;align-items: center;gap: 10px;font-weight: 700;font-size: 20px;text-align: left;color: #3d4566;">
        <div
          style="width: 40px;height: 40px;border-radius: 50%;background: #5778ff;display: flex;align-items: center;justify-content: center;">
          <img loading="lazy" src="@/assets/home/equipment.png" alt="" style="width: 18px;height: 15px;" />
        </div>
        设备管理
      </div>
      <div style="height: 1px;background: #e8f0ff;" />
    </template>
    <DeviceManage :agent-id="currentAgentId" />
  </el-dialog>
</template>

<script>
import DeviceManage from '@/components/DeviceManagement.vue'; // 引入角色配置弹窗组件
export default {
  components: { DeviceManage },
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    currentAgentId: {
      type: String,
      default: ''
    }
  },
  data() {
    return {}
  },
  methods: {
    saveConfig() {
      this.$refs.roleConfig.saveConfig();
    },
    resetConfig() {
      this.$refs.roleConfig.resetConfig();
    },
    handleClose() {
      this.$emit('update:visible', false);
    }
  },
}
</script>

<style lang="scss" scoped>

</style>