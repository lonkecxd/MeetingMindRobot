<template>
  <div class="welcome">
    <HeaderBar />
    <el-main style="padding: 16px 20px; display: flex;flex-direction: column;">
      <div style="border-radius: 16px;background: #fafcfe; border: 1px solid #e8f0ff; width: 98%; max-width: 750px; margin: 0 auto;">
        <div
          style="padding: 15px 24px;font-weight: 700;font-size: 19px;text-align: left;color: #3d4566;display: flex;gap: 13px;align-items: center;">
          <div
            style="width: 37px;height: 37px;background: #5778ff;border-radius: 50%;display: flex;align-items: center;justify-content: center;">
            <img loading="lazy" src="@/assets/home/setting-user.png" alt="" style="width: 19px;height: 19px;" />
          </div>
          <!-- {{ form.agentName }} -->配置角色
        </div>
        <div style="height: 1px; background: #e8f0ff;" />
        
        <RoleConfigContent />
      </div>

    </el-main>
  </div>
</template>

<script>
import HeaderBar from "@/components/HeaderBar.vue";
import RoleConfigContent from "@/components/RoleConfigContent.vue";

export default {
  name: 'RoleConfigPage',
  components: { HeaderBar, RoleConfigContent },
  provide() {
    return {
      currentAgentId: () => this.$route.query.agentId
    }
  },
  data() {
    return {}
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
.welcome {
  min-width: 320px;
  min-height: 506px;
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(145deg, #e6eeff, #eff0ff);
  background-size: cover;
  /* 确保背景图像覆盖整个元素 */
  background-position: center;
  /* 从顶部中心对齐 */
  -webkit-background-size: cover;
  /* 兼容老版本WebKit浏览器 */
  -o-background-size: cover;
  /* 兼容老版本Opera浏览器 */
}

.el-form-item ::v-deep .el-form-item__label {
  /* font-size: 10px !important; */
  color: #3d4566 !important;
  font-weight: 400;
  line-height: 22px;
  padding-bottom: 2px;
}

.select-field {
  width: 100%;
  /* max-width: 720px; */
  border: 1px solid #e4e6ef;
  background: #f6f8fb;
  border-radius: 8px;
  height: 36px !important;
}

.audio-box {
  flex: 1;
  height: 37px;
  border-radius: 20px;
  border: 1px solid #e4e6ef;
}

.clear-btn {
  width: 48px;
  height: 19px;
  background: #fd8383;
  border-radius: 10px;
  line-height: 19px;
  font-size: 11px;
  color: #fff;
  cursor: pointer;
}

.clear-text {
  color: #979db1;
  font-size: 11px;
  display: flex;
  align-items: center;
  gap: 8px;
  margin-left: 16px;
}

.template-item {
  height: 37px;
  width: 76px;
  border-radius: 8px;
  background: #e6ebff;
  line-height: 37px;
  font-weight: 400;
  font-size: 11px;
  text-align: center;
  color: #5778ff;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.template-item:hover {
  background-color: #d0d8ff;
}

.prompt-bottom {
  margin-bottom: 4px;
  display: flex;
  justify-content: space-between;
  padding: 0 16px;
  align-items: center;
}

.input-46 {
  border: 1px solid #e4e6ef;
  background: #f6f8fb;
  border-radius: 8px;
  height: 36px !important;
}

.save-btn,
.reset-btn {
  width: 112px;
  height: 37px;
  border-radius: 18px;
  line-height: 37px;
  box-sizing: border-box;
  cursor: pointer;
  font-size: 11px
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

.textarea-box {
  border: 1px solid #e4e6ef;
  border-radius: 8px;
  background: #f6f8fb;
}
</style>
