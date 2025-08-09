<template>
  <div class="welcome">
    <DeviceManagementAdmin v-if="isSuperAdmin" />
    <DeviceManagementUser v-else />
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import DeviceManagementAdmin from '@/views/DeviceManagement.vue';
import DeviceManagementUser from '@/views/DeviceManagementUser.vue';

export default {
  name: 'DeviceManagementLoad',
  components: { DeviceManagementAdmin, DeviceManagementUser },
  data() {
    return { }
  },
  computed: {
    ...mapGetters(['getIsSuperAdmin']),
    isSuperAdmin() {
      return this.getIsSuperAdmin;
    }
  },

  methods: {}
}
</script>

<style lang="scss" scoped>
</style>