<template>
  <div class="welcome">
    
  </div>

</template>

<script>
import { mapGetters } from 'vuex';
import AddWisdomBodyDialog from '@/components/AddWisdomBodyDialog.vue';
import DeviceItem from '@/components/DeviceItem.vue';
import HeaderBar from '@/components/HeaderBar.vue';
import VersionFooter from '@/components/VersionFooter.vue';

export default {
  name: 'HomePage',
  components: { DeviceItem, AddWisdomBodyDialog, HeaderBar, VersionFooter },
  data() {
    return {
      addDeviceDialogVisible: false,
      devices: [],
      originalDevices: [],
      isSearching: false,
      searchRegex: null
    }
  },
  computed: {
    ...mapGetters(['getIsSuperAdmin']),
    isSuperAdmin() {
      return this.getIsSuperAdmin;
    }
  },
  mounted() {
    // 判断是否为管理员，如果是管理员则跳转到管理员页面，否则跳转到用户页面
    if (this.isSuperAdmin) {
      this.$router.push('/adminHome');
    } else {
      this.$router.push('/userHome');
    }
  },

  methods: {}
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
  background-size: 100% 100%;
  /* 确保背景图像覆盖整个元素 */
  background-position: center;
  /* 从顶部中心对齐 */
  -webkit-background-size: cover;
  /* 兼容老版本WebKit浏览器 */
  -o-background-size: cover;
  /* 兼容老版本Opera浏览器 */
}

</style>