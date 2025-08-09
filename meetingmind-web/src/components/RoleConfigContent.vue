<template>
  <div>    
    <RoleConfig ref="roleConfig" />

    <div style="display: flex; padding: 0 16px 30px; gap: 8px; align-items: center; flex-wrap: wrap;">
      <div class="save-btn" @click="saveConfig">
        保存配置
      </div>
      <div class="reset-btn" @click="resetConfig">
        重制
      </div>
      <div class="clear-text">
        <img loading="lazy" src="@/assets/home/red-info.png" alt="" style="width: 19px;height: 19px;" />
        保存配置后，需要重启设备，新的配置才会生效。
      </div>
    </div>
  </div>
</template>

<script>
import RoleConfig from "@/views/roleConfig.vue";

export default {
  name: 'RoleConfigContentWrap',
  components: { RoleConfig },
  data() {
    return { }
  },
  computed: { },
  methods: {
    saveConfig() {
      this.$refs.roleConfig.saveConfig();
    },
    resetConfig() {
      this.$refs.roleConfig.resetConfig();
    }
  },
  watch: { },
  mounted() { }
}
</script>

<style scoped>
.save-btn,
.reset-btn {
  width: 112px;
  height: 37px;
  border-radius: 18px;
  line-height: 37px;
  box-sizing: border-box;
  cursor: pointer;
  font-size: 11px;
  text-align: center;
}

.save-btn {
  border-radius: 18px;
  background: #5778ff;
  color: #fff;
}

.reset-btn {
  border: 1px solid #adbdff;
  background: #e6ebff;
  color: #5778ff;
}
</style>
