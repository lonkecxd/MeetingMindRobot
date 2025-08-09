<template>
  <div class="welcome">
    <HeaderBar />

    <div class="main-wrapper">
      <div class="operation-bar">
        <h2 class="page-title">设备管理</h2>
        <div class="right-operations">
          <el-input placeholder="请输入设备型号或Mac地址查询" v-model="searchKeyword"
                  class="search-input" @keyup.enter.native="handleSearch" clearable />
          <el-button class="btn-search" @click="handleSearch">搜索</el-button>
        </div>
      </div>
      <DeviceManage :agent-id="agentId" />
    </div>
  </div>
</template>

<script>
import Api from '@/apis/api';
import AddDeviceDialog from "@/components/AddDeviceDialog.vue";
import HeaderBar from "@/components/HeaderBar.vue";
import DeviceManage from "@/components/DeviceManagement.vue";

export default {
  components: { HeaderBar, AddDeviceDialog, DeviceManage },
  props: {
    agentId: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      addDeviceDialogVisible: false,
      selectedDevices: [],
      isAllSelected: false,
      searchKeyword: "",
      activeSearchKeyword: "",
      currentAgentId: this.$route.query.agentId || '',
      currentPage: 1,
      pageSize: 5,
      pageSizeOptions: [5, 10, 20, 50, 100],
      deviceList: [],
      loading: false,
      userApi: null,
    };
  },
  computed: {
    filteredDeviceList() {
      const keyword = this.activeSearchKeyword.toLowerCase();
      if (!keyword) return this.deviceList;
      return this.deviceList.filter(device =>
        (device.model && device.model.toLowerCase().includes(keyword)) ||
        (device.macAddress && device.macAddress.toLowerCase().includes(keyword))
      );
    },

    paginatedDeviceList() {
      const start = (this.currentPage - 1) * this.pageSize;
      const end = start + this.pageSize;
      return this.filteredDeviceList.slice(start, end);
    },
    pageCount() {
      return Math.ceil(this.filteredDeviceList.length / this.pageSize);
    },
    visiblePages() {
      const pages = [];
      const maxVisible = 3;
      let start = Math.max(1, this.currentPage - 1);
      let end = Math.min(this.pageCount, start + maxVisible - 1);

      if (end - start + 1 < maxVisible) {
        start = Math.max(1, end - maxVisible + 1);
      }

      for (let i = start; i <= end; i++) {
        pages.push(i);
      }
      return pages;
    },
  },
  mounted() {
    const agentId = this.$route.query.agentId;
    if (agentId) {
      this.fetchBindDevices(agentId);
    }
  },
  created() {
    this.getFirmwareTypes()
  },
  methods: {
    async getFirmwareTypes() {
      try {
        const res = await Api.dict.getDictDataByType('FIRMWARE_TYPE')
        this.firmwareTypes = res.data
      } catch (error) {
        console.error('获取固件类型失败:', error)
        this.$message.error(error.message || '获取固件类型失败')
      }
    },
    handlePageSizeChange(val) {
      this.pageSize = val;
      this.currentPage = 1;
    },
    handleSearch() {
      this.activeSearchKeyword = this.searchKeyword;
      this.currentPage = 1;
    },

    handleSelectionChange(val) {
      this.selectedDevices = val;
      this.isAllSelected = val.length === this.filteredDeviceList.length;
    },
    toggleAllSelection() {
      if (this.isAllSelected) {
        this.selectedDevices = [];
      } else {
        this.selectedDevices = this.filteredDeviceList.map(device => device.device_id);
      }
      this.isAllSelected = !this.isAllSelected;
    },

    deleteSelected() {
      console.log(this.selectedDevices)
      if (this.selectedDevices.length === 0) {
        this.$message.warning({
          message: '请至少选择一条记录',
          showClose: true
        });
        return;
      }

      this.$confirm(`确认要解绑选中的 ${this.selectedDevices.length} 台设备吗？`, '警告', {
        width: '300px',
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        const deviceIds = this.selectedDevices.map(device => device.device_id);
        this.batchUnbindDevices(deviceIds);
      });
    },

    batchUnbindDevices(deviceIds) {
      const promises = deviceIds.map(id => {
        return new Promise((resolve, reject) => {
          Api.device.unbindDevice(id, ({ data }) => {
            if (data.code === 0) {
              resolve();
            } else {
              reject(data.msg || '解绑失败');
            }
          });
        });
      });

      Promise.all(promises)
        .then(() => {
          this.$message.success({
            message: `成功解绑 ${deviceIds.length} 台设备`,
            showClose: true
          });
          this.fetchBindDevices(this.currentAgentId);
          this.selectedDevices = [];
          this.isAllSelected = false;
        })
        .catch(error => {
          this.$message.error({
            message: error || '批量解绑过程中出现错误',
            showClose: true
          });
        });
    },

    handleAddDevice() {
      this.addDeviceDialogVisible = true;
    },
    startEditRemark(index, row) {
      this.deviceList[index].isEdit = true;
      this.$nextTick(() => {
        this.$refs[`remarkInput-${index}`][0].focus();
      });
    },
    stopEditRemark(index) {
      this.deviceList[index].isEdit = false;
    },
    handleUnbind(device_id) {
      this.$confirm('确认要解绑该设备吗？', '警告', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        Api.device.unbindDevice(device_id, ({ data }) => {
          if (data.code === 0) {
            this.$message.success({
              message: '设备解绑成功',
              showClose: true
            });
            this.fetchBindDevices(this.$route.query.agentId);
          } else {
            this.$message.error({
              message: data.msg || '设备解绑失败',
              showClose: true
            });
          }
        });
      });
    },
    goFirst() {
      this.currentPage = 1;
    },
    goPrev() {
      if (this.currentPage > 1) this.currentPage--;
    },
    goNext() {
      if (this.currentPage < this.pageCount) this.currentPage++;
    },
    goToPage(page) {
      this.currentPage = page;
    },

    fetchBindDevices(agentId) {
      this.loading = true;
      Api.device.getAgentBindDevices(agentId, ({ data }) => {
        this.loading = false;
        if (data.code === 0) {
          this.deviceList = data.data.map(device => {
            const bindDate = new Date(device.createDate);
            const formattedBindTime = `${bindDate.getFullYear()}-${(bindDate.getMonth() + 1).toString().padStart(2, '0')}-${bindDate.getDate().toString().padStart(2, '0')} ${bindDate.getHours().toString().padStart(2, '0')}:${bindDate.getMinutes().toString().padStart(2, '0')}:${bindDate.getSeconds().toString().padStart(2, '0')}`;
            return {
              device_id: device.id,
              model: device.board,
              firmwareVersion: device.appVersion,
              macAddress: device.macAddress,
              bindTime: formattedBindTime,
              lastConversation: device.lastConnectedAt,
              remark: device.alias,
              isEdit: false,
              otaSwitch: device.autoUpdate === 1,
              rawBindTime: new Date(device.createDate).getTime()
            };
          })
          // this.deviceList = [{
          //   device_id: 1,
          //   model: 'xiaozhi-cube-1.54tft-ml307',
          //   firmwareVersion: '1.5.5',
          //   macAddress: '00:00:00:00:00:00',
          //   bindTime: '2025-05-10 10:00:00',
          //   lastConversation: '2025-05-10 10:00:00',
          //   remark: null,
          //   isEdit: false,
          //   otaSwitch: true,
          //   rawBindTime: '2025-05-10 10:00:00'
          // },
          // {
          //   device_id: 2,
          //   model: 'xiaozhi-cube-1.54tft-ml307',
          //   firmwareVersion: '1.5.5',
          //   macAddress: '00:00:00:00:00:00',
          //   bindTime: '2025-05-10 10:00:00',
          //   lastConversation: '2025-05-10 10:00:00',
          //   remark: '测试',
          //   isEdit: false,
          //   otaSwitch: true,
          //   rawBindTime: '2025-05-10 10:00:00'
          // },
          // {
          //   device_id: 3,
          //   model: 'xiaozhi-cube-1.54tft-ml307',
          //   firmwareVersion: '1.5.5',
          //   macAddress: '00:00:00:00:00:00',
          //   bindTime: '2025-05-10 10:00:00',
          //   lastConversation: '2025-05-10 10:00:00',
          //   remark: '测试',
          //   isEdit: false,
          //   otaSwitch: true,
          //   rawBindTime: '2025-05-10 10:00:00'
          // },
          // {
          //   device_id: 4,
          //   model: 'xiaozhi-cube-1.54tft-ml307',
          //   firmwareVersion: '1.5.5',
          //   macAddress: '00:00:00:00:00:00',
          //   bindTime: '2025-05-10 10:00:00',
          //   lastConversation: '2025-05-10 10:00:00',
          //   remark: '测试',
          //   isEdit: false,
          //   otaSwitch: true,
          //   rawBindTime: '2025-05-10 10:00:00'
          // },
          // {
          //   device_id: 5,
          //   model: 'xiaozhi-cube-1.54tft-ml307',
          //   firmwareVersion: '1.5.5',
          //   macAddress: '00:00:00:00:00:00',
          //   bindTime: '2025-05-10 10:00:00',
          //   lastConversation: '2025-05-10 10:00:00',
          //   remark: '测试',
          //   isEdit: false,
          //   otaSwitch: true,
          //   rawBindTime: '2025-05-10 10:00:00'
          // }]
              .sort((a, b) => a.rawBindTime - b.rawBindTime);
          this.activeSearchKeyword = "";
          this.searchKeyword = "";
        } else {
          this.$message.error(data.msg || '获取设备列表失败');
        }
      });
    },
    headerCellClassName({columnIndex}) {
      if (columnIndex === 0) {
        return "custom-selection-header";
      }
      return "";
    },
    getFirmwareTypeName(type) {
      const firmwareType = this.firmwareTypes.find(item => item.key === type)
      return firmwareType ? firmwareType.name : type
    },
    handleOtaSwitchChange(row) {
      Api.device.enableOtaUpgrade(row.device_id, row.otaSwitch ? 1 : 0, ({ data }) => {
        if (data.code === 0) {
          this.$message.success(row.otaSwitch ? '已设置成自动升级' : '已关闭自动升级')
        } else {
          row.otaSwitch = !row.otaSwitch
          this.$message.error(data.msg || '操作失败')
        }
      })
    },
  }
};
</script>

<style scoped>
.welcome {
  min-width: 320px;
  min-height: 506px;
  height: 100vh;
  display: flex;
  position: relative;
  flex-direction: column;
  background: linear-gradient(to bottom right, #dce8ff, #e4eeff, #e6cbfd);
  background-size: cover;
  -webkit-background-size: cover;
  -o-background-size: cover;
}

.main-wrapper {
  padding: 0 12px;
  /* border-radius: 15px; */
  /* min-height: calc(100vh - 200px); */
  height: auto;
  max-height: 81vh;
  overflow-y: auto;
  /* box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1); */
  position: relative;
  /* background: rgba(237, 242, 255, 0.5); */
  display: flex;
  flex-direction: column;
}

.operation-bar {
  /* 保持原有父容器设置 */
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 16px;
  flex-wrap: wrap;
  gap: 10px;
}

.page-title {
  font-size: 24px;
  margin: 0;
  color: #2c3e50;
}

.right-operations {
  display: flex;
  flex: 1; /* 占据剩余空间 */
  min-width: 300px; /* 最小宽度保障 */
  max-width: 480px;
  margin-left: auto;
  flex-wrap: nowrap; /* 禁止内部换行 */
  justify-content: space-between;
}

.search-input {
  flex: 1; /* 关键：自动填充剩余空间 */
  min-width: 150px; /* 最小有效操作宽度 */
  max-width: 400px; /* 最大宽度限制 */
  border-radius: 4px;
  transition: width 0.3s; /* 添加平滑过渡 */
}

.btn-search {
  background: linear-gradient(135deg, #6b8cff, #a966ff);
  border: none;
  color: white;
  flex-shrink: 0; /* 禁止按钮压缩 */
  padding: 0 20px; /* 固定左右间距 */
}

/* 移动端适配 */
@media (max-width: 768px) {
  .right-operations {
    min-width: 100%; /* 小屏幕占满整行 */
  }
  
  .search-input {
    max-width: calc(100% - 80px); /* 动态计算可用空间 */
  }
}

::v-deep .search-input .el-input__inner {
  /* 保持原有输入框样式 */
  border-radius: 4px;
  border: 1px solid #DCDFE6;
  background-color: white;
  transition: border-color 0.2s;
}

::v-deep .page-size-select{
  width: 100px;
  margin-right: 8px;
}

::v-deep .page-size-select .el-input__inner{
  height: 32px;
  line-height: 32px;
  border-radius: 4px;
  border: 1px solid #e4e7ed;
  background: #dee7ff;
  color: #606266;
  font-size: 14px;
}
::v-deep .page-size-select .el-input__suffix{
  right: 6px;
  width: 15px;
  height: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  top: 6px;
  border-radius: 4px;
}

::v-deep .page-size-select .el-input__suffix-inner{
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
}
::v-deep .page-size-select .el-icon-arrow-up:before{
  content: "";
  display: inline-block;
  border-left: 6px solid transparent;
  border-right: 6px solid transparent;
  border-top: 9px solid #606266;
  position: relative;
  transform: rotate(0deg);
  transition: transform 0.3s;
}

::v-deep .search-input .el-input__inner:focus {
  border-color: #6b8cff;
  outline: none;
}

.content-panel {
  flex: 1;
  display: flex;
  /* overflow: hidden; */
  /* height: 100%; */
  /* border-radius: 15px; */
  background: transparent;
  /* border: 1px solid #fff; */
  margin: 15px 0;
}

.no-data-container {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: white;
  border-radius: 15px;
}

.device-manager-card {
  border-radius: 12px;
  background: #f8fafc;
}

.device-card-list {
  width: 100%;
}

.device-grid {
  display: grid;
  gap: 20px;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
}

.device-item-card {
  border-radius: 8px;
  transition: all 0.3s ease;
  border: 1px solid #ebeef5;
  background: #fff;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }

  .card-header {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 1px solid #f0f2f5;

    .device-title {
      flex: 1;
      display: flex;
      align-items: center;
      gap: 8px;

      .label {
        color: #909399;
        font-size: 14px;
      }

      .value {
        color: #303133;
        font-size: 16px;
        font-weight: 600;
        flex: 1;
        text-align: left;
      }
    }
  }

  .device-info {
    .info-row {
      display: flex;
      margin: 12px 0;
      font-size: 14px;
      line-height: 1.5;

      .label {
        color: #909399;
        min-width: 80px;
        flex-shrink: 0;
        text-align: left;
        padding-right: 12px;
      }

      .value {
        color: #303133;
        flex: 1;
        word-break: break-all;
        text-align: left;
        
        &.mac-address {
          font-family: monospace;
          color: #606266;
        }
      }
    }
  }

  .card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 16px;
    padding-top: 16px;
    border-top: 1px solid #f0f2f5;

    .footer-left {
      display: flex;
      align-items: center;

      .edit-btn {
        color: #409EFF;
        padding: 0;
        
        &:hover {
          color: #66b1ff;
        }

        i {
          margin-right: 4px;
        }
      }

      .unbind-btn {
        color: #f56c6c;
        padding: 0;
        
        &:hover {
          color: #f78989;
        }

        i {
          margin-right: 4px;
        }
      }
    }

    .footer-right {
      margin-left: 16px;
    }
  }
}

@media (max-width: 768px) {
  .device-grid {
    gap: 16px;
  }

  .device-item-card {
    .device-info {
      .info-row {
        flex-direction: column;
        margin: 8px 0;
        
        .label {
          margin-bottom: 4px;
        }
      }
    }

    .card-header {
      .device-title {
        flex-direction: column;
        align-items: flex-start;
        gap: 4px;

        .label {
          text-align: left;
        }
      }
    }

    .card-footer {
      flex-direction: row;
      align-items: center;
      gap: 12px;

      .footer-left {
        flex: 1;
        justify-content: flex-start;
      }

      .footer-right {
        margin-left: 0;
      }
    }
  }
}

@media (max-width: 480px) {
  .device-grid {
    gap: 12px;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  }
}

.content-area {
  flex: 1;
  height: 100%;
  min-width: 600px;
  overflow: auto;
  background-color: white;
  display: flex;
  flex-direction: column;
}

.device-card {
  background: white;
  border: none;
  box-shadow: none;
  display: flex;
  flex-direction: column;
  flex: 1;
  overflow: hidden;
}

.table_bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.ctrl_btn {
  display: flex;
  gap: 8px;
}

.ctrl_btn .el-button {
  min-width: 72px;
  height: 32px;
  padding: 7px 12px 7px 10px;
  font-size: 12px;
  border-radius: 4px;
  line-height: 1;
  font-weight: 500;
  border: none;
  transition: all 0.3s ease;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

.ctrl_btn .el-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.ctrl_btn .el-button--primary {
  background: #5f70f3;
  color: white;
}

.ctrl_btn .el-button--success {
  background: #5bc98c;
  color: white;
}

.ctrl_btn .el-button--danger {
  background: #fd5b63;
  color: white;
}

.custom-pagination {
  display: flex;
  align-items: center;
  gap: 10px;
}

.custom-pagination .el-select {
  margin-right: 8px;
}

.custom-pagination .pagination-btn:first-child,
.custom-pagination .pagination-btn:nth-child(2),
.custom-pagination .pagination-btn:nth-last-child(2),
.custom-pagination .pagination-btn:nth-child(3) {
  min-width: 60px;
  height: 32px;
  padding: 0 12px;
  border-radius: 4px;
  border: 1px solid #e4e7ed;
  background: #dee7ff;
  color: #606266;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.custom-pagination .pagination-btn:first-child:hover,
.custom-pagination .pagination-btn:nth-child(2):hover,
.custom-pagination .pagination-btn:nth-last-child(2):hover,
.custom-pagination .pagination-btn:nth-child(3):hover {
  background: #d7dce6;
}

.custom-pagination .pagination-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.custom-pagination .pagination-btn:not(:first-child):not(:nth-child(3)):not(:nth-child(2)):not(:nth-last-child(2)) {
  min-width: 28px;
  height: 32px;
  padding: 0;
  border-radius: 4px;
  border: 1px solid transparent;
  background: transparent;
  color: #606266;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.custom-pagination .pagination-btn:not(:first-child):not(:nth-child(3)):not(:nth-child(2)):not(:nth-last-child(2)):hover {
  background: rgba(245, 247, 250, 0.3);
}

.custom-pagination .pagination-btn.active {
  background: #5f70f3 !important;
  color: #ffffff !important;
  border-color: #5f70f3 !important;
}

.custom-pagination .pagination-btn.active:hover {
  background: #6d7cf5 !important;
}

.custom-pagination .total-text {
  color: #909399;
  font-size: 14px;
  margin-left: 10px;
}

:deep(.transparent-table) {
  background: white;
  border: none;
}

:deep(.transparent-table .el-table__header th) {
  background: white !important;
  color: black;
  border-right: none !important;
}

:deep(.transparent-table .el-table__body tr td) {
  border-top: 1px solid rgba(0, 0, 0, 0.04);
  border-bottom: 1px solid rgba(0, 0, 0, 0.04);
  border-right: none !important;
}

:deep(.transparent-table .el-table__header tr th:first-child .cell),
:deep(.transparent-table .el-table__body tr td:first-child .cell) {
  padding-left: 10px;
}

:deep(.el-icon-edit) {
  color: #7079aa;
  cursor: pointer;
}

:deep(.el-icon-edit:hover) {
  color: #5a64b5;
}

:deep(.custom-selection-header .el-checkbox) {
  display: none !important;
}

:deep(.custom-selection-header::after) {
  content: "选择";
  display: inline-block;
  color: black;
  font-weight: bold;
  padding-bottom: 18px;
}

:deep(.el-table .el-button--text) {
  color: #7079aa;
}

:deep(.el-table .el-button--text:hover) {
  color: #5a64b5;
}

:deep(.transparent-table) {
  flex: 1;
  display: flex;
  flex-direction: column;
  max-height: calc(100vh - 330px);
}

:deep(.el-table__body-wrapper) {
  flex: 1;
  overflow: auto;
  max-height: none !important;
}

:deep(.el-table__header-wrapper) {
  flex-shrink: 0;
}

/* 隐藏复选框标签文字 */
::v-deep .el-checkbox__label {
  display: none !important;
}

@media (min-width: 1144px) {
  .main-wrapper {
    padding: 0 40px;
  }
  /* .table_bottom {
    margin-top: 40px;
  }

  :deep(.transparent-table) .el-table__body tr td {
    padding-top: 16px;
    padding-bottom: 16px;
  } */
}
</style>
