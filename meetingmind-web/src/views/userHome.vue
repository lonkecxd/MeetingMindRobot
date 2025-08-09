<template>
  <div class="welcome">
    <div class="user-menu">
      <el-dropdown trigger="click" @command="handleCommand">
        <div class="user-menu-trigger">
          <i class="el-icon-user"></i>
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item disabled>
              <i class="el-icon-user"></i>
              {{ userInfo.username }}
            </el-dropdown-item>
            <el-dropdown-item divided command="changePassword">
              <i class="el-icon-key"></i>
              修改密码
            </el-dropdown-item>
            <el-dropdown-item command="logout">
              <i class="el-icon-switch-button"></i>
              退出登录
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
    <el-carousel :interval="5000" arrow="always" :autoplay="false" :loop="false" indicator-position="none" height="100vh">
      <el-carousel-item v-for="item in originalDevices" :key="item.id">
        <div class="agent">
          <div class="agent-name" @click="showAgentMenu(item)">
            {{ item.agentName }}
          </div>
          <img class="agent-image" src="@/assets/agent/ai-image3.png" alt="">
        </div>
        <div class="other-funtion">
          <div class="action-box">
            <div class="action-btn" @click="handleChatHistory(item)">
              <span>记忆</span>
            </div>
          </div>
        </div>
        <div class="bottom-buttons">
          <div class="action-btn soul-btn" @click="handleSoulInjection(item.id)">
            <span>灵魂注入</span>
          </div>
          <div class="action-btn sense-btn" @click="handleSenseAwakening(item.id)">
            <span>感官觉醒</span>
          </div>
        </div>
      </el-carousel-item>
      <el-carousel-item v-if="!isOriginalDevicesLoading">
        <div class="create-agent">
          <div style="margin-top: 100px;">
            <div class="summon-button" @click="showAddDialog">
              <span class="button-text">创造智能体</span>
              <div class="button-glow"></div>
              <div class="button-particles"></div>
            </div>
            <img src="@/assets/agent/00.png" width="80%" style="max-width: 400px;">
          </div>
        </div>
      </el-carousel-item>
    </el-carousel>

    <!-- 修改密码弹窗 -->
    <ChangePasswordDialog v-model="isChangePasswordDialogVisible" />
    <!-- 创造智能体弹窗 -->
    <AddWisdomBodyDialog :visible.sync="addDeviceDialogVisible" @confirm="handleWisdomBodyAdded" />
    <!-- 角色配置弹窗 -->
    <RoleConfigDialog :visible.sync="isRoleConfigDialogVisible" :current-agent-id="currentAgentId" />
    <!-- 设备管理弹窗 -->
    <DeviceManageDialog :visible.sync="isDeviceManageDialogVisible" :current-agent-id="currentAgentId" />
    <!-- 聊天记录弹窗 -->
    <chat-history-dialog :visible.sync="isChatHistoryDialogVisible" :agent-id="currentAgentId" :agent-name="currentAgentName" />

    <!-- 智能体操作弹框 -->
    <el-dialog
      :visible.sync="agentMenuVisible"
      :show-close="true"
      :close-on-press-escape="false"
      custom-class="agent-menu-dialog"
      center
    >
      <template #title>
        <div class="dialog-title">你想做些什么呢？</div>
      </template>
      <div class="menu-options">
        <!-- <div class="menu-item" @click="handleAbandon">
          <i class="el-icon-edit"></i>
          <span>更改称呼</span>
        </div> -->
        <div class="menu-item" @click="handleAbandon">
          <i class="el-icon-delete"></i>
          <span>抛弃</span>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import Api from '@/apis/api';
import userApi from '@/apis/module/user';
import { mapActions, mapGetters } from 'vuex';
import AddWisdomBodyDialog from '@/components/AddWisdomBodyDialog.vue';
import ChangePasswordDialog from '@/components/ChangePasswordDialog.vue'; // 引入修改密码弹窗组件
import RoleConfigDialog from '@/components/RoleConfigDialog.vue'; // 引入角色配置弹窗组件
import DeviceManageDialog from '@/components/DeviceManagementDialog.vue';
import ChatHistoryDialog from '@/components/ChatHistoryDialog.vue';
import DeviceItem from '@/components/DeviceItem.vue';
import VersionFooter from '@/components/VersionFooter.vue';

export default {
  name: 'HomePage',
  components: { DeviceItem, AddWisdomBodyDialog, ChangePasswordDialog, VersionFooter, RoleConfigDialog, DeviceManageDialog, ChatHistoryDialog },
  data() {
    return {
      addDeviceDialogVisible: false,
      devices: [],
      originalDevices: [],
      isSearching: false,
      searchRegex: null,
      userInfo: {
        username: '',
        mobile: ''
      },
      isChangePasswordDialogVisible: false, // 修改密码弹窗的显示状态
      isRoleConfigDialogVisible: false, // 角色配置弹窗的显示状态
      isDeviceManageDialogVisible: false, // 设备管理弹窗的显示状态
      currentAgentId: '', // 当前智能体ID
      currentAgentName: '', // 当前智能体名称
      isOriginalDevicesLoading: true, // 是否正在加载智能体列表
      agentMenuVisible: false,
      isChatHistoryDialogVisible: false,
    }
  },
  computed: {
    ...mapGetters(['getIsSuperAdmin']),
    isSuperAdmin() {
      return this.getIsSuperAdmin;
    },
  },
  mounted() {
    this.fetchUserInfo()
    this.fetchAgentList();
  },

  methods: {
    // 获取用户信息
    fetchUserInfo() {
      userApi.getUserInfo(({ data }) => {
        this.userInfo = data.data
        if (data.data.superAdmin !== undefined) {
          this.$store.commit('setUserInfo', data.data);
        }
      })
    },
    showAddDialog() {
      this.addDeviceDialogVisible = true
    },
    goToRoleConfig() {
      // 点击配置角色后跳转到角色配置页
      this.$router.push('/role-config')
    },
    handleWisdomBodyAdded(res) {
      this.fetchAgentList();
      this.addDeviceDialogVisible = false;
    },
    handleDeviceManage() {
      this.$router.push('/device-management');
    },
    // 获取智能体列表
    fetchAgentList() {
      this.isOriginalDevicesLoading = true;
      Api.agent.getAgentList(({ data }) => {
        this.originalDevices = data.data.map(item => ({
          ...item,
          agentId: item.id // 字段映射
        }));
        this.isOriginalDevicesLoading = false;
      });
    },
    // 删除智能体
    handleDeleteAgent(agentId) {
      this.$confirm('离开既是永别，确定要抛弃我吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        Api.agent.deleteAgent(agentId, (res) => {
          if (res.data.code === 0) {
            this.$message.success({
              message: '删除成功',
              showClose: true
            });
            this.fetchAgentList(); // 刷新列表
          } else {
            this.$message.error({
              message: res.data.msg || '删除失败',
              showClose: true
            });
          }
        });
      }).catch(() => { });
    },
    async handleCommand(command) {
      switch (command) {
        case 'changePassword':
        this.isChangePasswordDialogVisible = true;
          break;
        case 'logout':
          try {
              // 调用 Vuex 的 logout action
              await this.logout();
              this.$message.success({
                message: '退出登录成功',
                showClose: true
              });
            } catch (error) {
              console.error('退出登录失败:', error);
              this.$message.error({
                message: '退出登录失败，请重试',
                showClose: true
              });
            }
          break;
      }
    },
    handleSoulInjection(agentId) {
      this.isRoleConfigDialogVisible = true;
      this.currentAgentId = agentId;
    },
    handleSenseAwakening(agentId) {
      this.isDeviceManageDialogVisible = true;
      this.currentAgentId = agentId;
    },
    handleSummon() {
      this.isSummoning = true;
    },
    showAgentMenu() {
      this.agentMenuVisible = true;
    },
    handleAbandon() {
      this.agentMenuVisible = false;
      this.handleDeleteAgent(this.currentAgentId);
    },
    handleChatHistory(device) {
      if (device.memModelId === 'Memory_nomem') {
        return
      }
      this.isChatHistoryDialogVisible = true
      this.currentAgentId = device.id
      this.currentAgentName = device.agentName
    },
    // 使用 mapActions 引入 Vuex 的 logout action
    ...mapActions(['logout'])
  }
}
</script>

<style lang="scss" scoped>
.welcome {
  min-width: 320px;
  min-height: 506px;
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: url("@/assets/bg.jpg");
  background-size: cover;
  position: relative;
  overflow: hidden;
  /* 确保背景图像覆盖整个元素 */
  background-position: center;
  /* 从顶部中心对齐 */
  -webkit-background-size: cover;
  /* 兼容老版本WebKit浏览器 */
  -o-background-size: cover;
  /* 兼容老版本Opera浏览器 */
}

.agent {
  position: absolute;
  bottom: 0;
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: flex-end;
  .agent-image {
    width: auto;
    height: 86%;
    object-fit: contain;
    position: absolute;
    bottom: 0;
  }
  .agent-name {
    position: absolute;
    top: 25px;
    color: #fff;
    background-image: linear-gradient(90deg, #00c9ff 0%, #92fe9d 50%, #aa7ecd 100%);
    -webkit-background-clip: text;
    background-clip: text;
    font-size: 28px;
    font-weight: 600;
    letter-spacing: 3px;
    padding: 12px 30px;
    background: rgba(0, 0, 0, 0.6);
    border-radius: 8px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.1);
    text-shadow: 0 0 10px rgba(88, 120, 255, 1);
    transform: skew(-5deg);
    transition: all 0.3s ease;
    backdrop-filter: blur(5px);
    cursor: pointer;
    max-width: 75%;

    &:hover {
      transform: skew(-5deg) translateY(-2px);
      box-shadow: 0 0 30px rgba(88, 120, 255, 0.3);
      border-color: rgba(88, 120, 255, 0.3);
      background: rgba(0, 0, 0, 0.7);
    }
  }
}

@keyframes scanline {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(100%);
  }
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.user-menu {
  position: absolute;
  right: 10px;
  top: 10px;
  z-index: 99;
}

.user-menu-trigger {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.2);

  i {
    font-size: 20px;
    color: #fff;
    transition: all 0.3s ease;
  }

  &:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }
}

:deep(.el-dropdown-menu) {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  padding: 4px 0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);

  .el-dropdown-menu__item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    color: #606266;
    font-size: 14px;

    i {
      font-size: 16px;
    }

    &:hover {
      background: rgba(88, 120, 255, 0.1);
      color: #5778ff;
    }

    &.is-disabled {
      color: #909399;
      cursor: default;
      background: none;
    }
  }

  .el-dropdown-menu__item--divided {
    border-top: 1px solid rgba(0, 0, 0, 0.06);
    margin: 4px 0;
  }
}

.bottom-buttons {
  position: fixed;
  bottom: 40px;
  width: 100%;
  display: flex;
  justify-content: center;
  gap: 30px;
  z-index: 10;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 32px;
  border-radius: 40px;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #fff;
  font-size: 18px;
  font-weight: 500;
  letter-spacing: 1px;

  i {
    font-size: 20px;
  }

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }
}

.soul-btn {
  background: rgba(88, 120, 255, 0.4);
  
  &:hover {
    background: rgba(88, 120, 255, 0.5);
    border-color: rgba(88, 120, 255, 0.6);
  }
}

.sense-btn {
  background: rgba(166, 102, 255, 0.4);
  
  &:hover {
    background: rgba(166, 102, 255, 0.5);
    border-color: rgba(166, 102, 255, 0.6);
  }
}

.other-funtion{
  position: absolute;
  top: 120px;
  padding: 0 10%;
  width: 80%;
  .action-box{
    display: flex;
    justify-content: space-between;
    margin-bottom: 20px;
  }
  .action-btn{
    background: rgba(77,77,77, 0.4);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }
}

@media (max-width: 768px) {
  .bottom-buttons {
    bottom: 20px;
    gap: 20px;
  }

  .action-btn {
    padding: 12px 24px;
    font-size: 16px;

    i {
      font-size: 18px;
    }
  }
}

.create-agent {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  position: relative;
  overflow: hidden;
  // background-image: url("@/assets/agent/00.png");
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
}

.summon-button {
  position: relative;
  padding: 20px 40px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50px;
  cursor: pointer;
  overflow: hidden;
  transition: all 0.3s ease;
  // border: 1px solid rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  z-index: 2;
  width: 10em;
  margin: 0 auto;

  &::before {
    content: '';
    position: absolute;
    top: -2px;
    left: -2px;
    right: -2px;
    bottom: -2px;
    background: linear-gradient(45deg, 
      #FF89A2,
      #00c9ff,
      #aa7ecd,
      #00c9ff
    );
    border-radius: 50px;
    z-index: -1;
    animation: borderRotate 4s linear infinite;
    background-size: 400% 400%;
  }

  &::after {
    content: '';
    position: absolute;
    inset: 1px;
    background: rgba(0, 0, 0, 0.8);
    border-radius: 50px;
    z-index: -1;
  }

  &:hover {
    transform: translateY(-2px);
    box-shadow: 
      0 0 20px rgba(0, 201, 255, 0.4),
      0 0 40px rgba(146, 254, 157, 0.2);
    border-color: transparent;

    .button-glow {
      opacity: 1;
      transform: scale(1.2);
    }

    .button-text {
      text-shadow: 0 0 10px rgba(0, 201, 255, 0.8);
    }

    .scan-line {
      transform: translateX(100%);
    }
  }
}

.button-content {
  position: relative;
  z-index: 2;
}

.button-text {
  font-size: 24px;
  color: #fff;
  font-weight: bold;
  letter-spacing: 2px;
  transition: all 0.3s ease;
  background: linear-gradient(45deg, #00c9ff, #aa7ecd);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  display: inline-block;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, 
      transparent,
      rgba(255, 255, 255, 0.2),
      transparent
    );
    transform: translateX(-100%);
    animation: textShine 3s infinite;
  }
}

.scan-line {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 2px;
  background: linear-gradient(90deg,
    transparent,
    #00c9ff,
    #92fe9d,
    transparent
  );
  transform: translateX(-100%);
  transition: transform 0.3s ease;
}

.button-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 100%;
  height: 100%;
  background: radial-gradient(circle at center,
    rgba(0, 201, 255, 0.4) 0%,
    rgba(146, 254, 157, 0.2) 30%,
    transparent 70%
  );
  opacity: 0;
  transition: all 0.3s ease;
  pointer-events: none;
  animation: glowPulse 2s infinite;
}

.button-particles {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: 
    radial-gradient(circle at 20% 20%, rgba(0, 201, 255, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 80% 80%, rgba(146, 254, 157, 0.1) 0%, transparent 50%);
  animation: particleFloat 8s infinite;
}

@keyframes borderRotate {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

@keyframes textShine {
  0% {
    transform: translateX(-100%);
  }
  20%, 100% {
    transform: translateX(100%);
  }
}

@keyframes glowPulse {
  0%, 100% {
    opacity: 0.5;
    transform: translate(-50%, -50%) scale(1);
  }
  50% {
    opacity: 0.8;
    transform: translate(-50%, -50%) scale(1.1);
  }
}

@keyframes particleFloat {
  0% {
    transform: translate(0, 0);
    opacity: 0.5;
  }
  50% {
    transform: translate(10px, 10px);
    opacity: 0.8;
  }
  100% {
    transform: translate(0, 0);
    opacity: 0.5;
  }
}

@media (max-width: 768px) {
  .summon-button {
    padding: 15px 30px;
  }

  .button-text {
    font-size: 18px;
  }
}

:deep(.el-carousel__arrow) {
  background: rgba(0, 0, 0, 0.5);
}

::v-deep .el-dialog {
  border-radius: 15px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}
::v-deep .el-dialog__body {
  padding: 4px 6px;
  max-height: 76vh;
  overflow-y: auto;
}
::v-deep .el-dialog__header {
  padding: 10px;
}

:deep(.agent-menu-dialog) {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  box-shadow: 
    0 0 20px rgba(88, 120, 255, 0.2),
    0 0 40px rgba(0, 201, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(88, 120, 255, 0.2);
  overflow: hidden;
  position: relative;
  width: 90%;
  max-width: 400px;
  min-width: 300px;

  .el-dialog__headerbtn {
    top: 20px;
    right: 20px;
    font-size: 20px;
    color: #3d4566;
    transition: all 0.3s ease;

    &:hover {
      color: #5778ff;
      transform: rotate(90deg);
    }
  }

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 2px;
    background: linear-gradient(90deg, 
      transparent,
      #00c9ff,
      #92fe9d,
      #00c9ff,
      transparent
    );
    animation: borderFlow 3s linear infinite;
  }

  .el-dialog__header {
    padding: 25px 20px;
    border-bottom: 1px solid rgba(88, 120, 255, 0.1);
    position: relative;
    overflow: hidden;

    &::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 0;
      width: 100%;
      height: 1px;
      background: linear-gradient(90deg,
        transparent,
        rgba(88, 120, 255, 0.3),
        transparent
      );
    }
  }

  .el-dialog__body {
    padding: 0;
    position: relative;
  }

  .dialog-title {
    color: #3d4566;
    font-size: 22px;
    font-weight: 600;
    text-align: center;
    letter-spacing: 2px;
    position: relative;
    text-shadow: 0 0 10px rgba(88, 120, 255, 0.2);
    background: linear-gradient(90deg, #3d4566, #5778ff);
    -webkit-background-clip: text;
    background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .menu-options {
    padding: 20px 25px 25px;
    position: relative;
    overflow: hidden;

    &::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: 
        radial-gradient(circle at 20% 20%, rgba(88, 120, 255, 0.05) 0%, transparent 50%),
        radial-gradient(circle at 80% 80%, rgba(0, 201, 255, 0.05) 0%, transparent 50%);
      pointer-events: none;
    }
  }

  .menu-item {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    padding: 18px;
    color: #3d4566;
    font-size: 18px;
    cursor: pointer;
    border-radius: 12px;
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
    background: rgba(255, 255, 255, 0.8);
    border: 1px solid rgba(88, 120, 255, 0.1);
    backdrop-filter: blur(5px);

    i {
      font-size: 20px;
      color: #5778ff;
      transition: all 0.3s ease;
    }

    &::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(90deg,
        transparent,
        rgba(88, 120, 255, 0.1),
        transparent
      );
      transform: translateX(-100%);
      transition: transform 0.3s ease;
    }

    span {
      font-weight: 500;
      letter-spacing: 2px;
    }

    &:hover {
      background: rgba(88, 120, 255, 0.05);
      transform: translateY(-2px);
      border-color: rgba(88, 120, 255, 0.2);
      box-shadow: 0 4px 12px rgba(88, 120, 255, 0.1);

      &::before {
        transform: translateX(100%);
      }

      i {
        transform: scale(1.1);
        color: #00c9ff;
      }
    }

    &:active {
      transform: translateY(0);
      background: rgba(88, 120, 255, 0.1);
    }
  }
}



@keyframes borderFlow {
  0% {
    background-position: 0% 50%;
  }
  100% {
    background-position: 100% 50%;
  }
}

@media (max-width: 768px) {
  :deep(.agent-menu-dialog) .dialog-title  {
    font-size: 20px;
  }

  :deep(.agent-menu-dialog) .menu-item {
    padding: 16px;
    font-size: 15px;

    i {
      font-size: 20px;
    }
  }
}
</style>