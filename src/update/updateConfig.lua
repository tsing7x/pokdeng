--
-- Date: 2014-11-03 15:52:13
--

local updateConfig = {}

local func = require("update.functions")

updateConfig.DEBUG                 = false
updateConfig.PRE_PUBLIC            = false  -- 热更新线上测试 testflist
updateConfig.ENABLED               = true
updateConfig.DEBUG_SVR_VERSION     = nil --覆盖mobilespecial返回的服务端版本号
updateConfig.DEBUG_VERSION         = "10.0.0" --客户端版本(Player运行取这个)
updateConfig.CLIENT_VERSION        = func.getAppVersion() or updateConfig.DEBUG_VERSION
updateConfig.SKIT_UPDATE_TIMES_KEY = "SKIT_UPDATE_TIMES_KEY" .. updateConfig.CLIENT_VERSION
updateConfig.UPDATE_DIR            = device.writablePath .. "upd/"
updateConfig.UPDATE_RES_DIR        = updateConfig.UPDATE_DIR .. "res/"
updateConfig.UPDATE_RES_TMP_DIR    = updateConfig.UPDATE_DIR .. "restmp/"
updateConfig.UPDATE_LIST_FILE_NAME = (updateConfig.PRE_PUBLIC == true and "testflist" or "flist") .. updateConfig.CLIENT_VERSION
updateConfig.UPDATE_LIST_FILE      = updateConfig.UPDATE_DIR .. updateConfig.UPDATE_LIST_FILE_NAME

return updateConfig