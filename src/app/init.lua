--[[
    全局上下文
]]

-- 临时hack, 在mac player上面运行时,把平台 伪装成windows以适配现有代码
if device.platform == 'mac' then
    device.platform = 'windows'
end

require("app.consts")
require("app.styles")

nk = nk or {}

-- 设置元表
local mt = {}
mt.__index = function (t, k)
    if k == "userData" then
        return bm.DataProxy:getData(nk.dataKeys.USER_DATA)
    elseif k == "runningScene" then
        return cc.Director:getInstance():getRunningScene()
    elseif k == "userDefault" then
        return cc.UserDefault:getInstance()
    end
end
setmetatable(nk, mt)

import(".util.functions").exportMethods(nk)

-- 常量设置
nk.widthScale = display.width / 960
nk.heightScale = display.height / 640

nk.config = import(".config")

-- data keys
nk.dataKeys = import(".keys.DATA_KEYS")
nk.cookieKeys = import(".keys.COOKIE_KEYS")

-- event names
nk.eventNames = import(".keys.EVENT_NAMES")

-- http
nk.http = import(".net.HttpRequest")
nk.http.init()

-- Server
nk.server = import(".net.HallServer").new()

-- 声音管理类
nk.SoundManager = import(".manager.SoundManager").new()

-- 弹框管理类
nk.PopupManager = import(".manager.PopupManager").new()

nk.EditBoxManager = import(".manager.EditBoxManager").new()
-- test util
nk.TestUtil = import(".util.TestUtil").new()

-- 顶部消息管理类
nk.TopTipManager = import(".manager.TopTipManager").new()

-- 屏幕中央消息管理
nk.CenterTipManager = import(".manager.CenterTipManager").new()

nk.CommonTipManager = import(".manager.CommonTipManager").new()

-- 顶部复合消息管理器
nk.TopTipExManager = import(".manager.TopTipExManager").new()

--公共调度器
nk.schedulerPool = bm.SchedulerPool.new()

--每日任务事件上报类
if nk.DailyTasksEventHandler then
    nk.DailyTasksEventHandler:removeEvent()
end
nk.DailyTasksEventHandler = import(".module.dailytasks.DailyTasksEventHandler").new()

-- 公共UI
nk.ui = import(".pokerUI.init")

-- 原生桥接
if device.platform == "android" then
    nk.Native = import(".util.LuaJavaBridge").new()
    nk.Facebook = import("app.module.login.plugins.FacebookPluginAndroid").new()
    nk.GCMPush = import("app.module.login.plugins.GoogleCloudMessaging").new()
    nk.Push = import("app.module.login.plugins.XinGePushAndroid").new()
    nk.AdSdk = import("app.module.login.plugins.AdSdkPluginAndroid").new()

    if nk.config.POKDENG_ADSCENE_ENABLED then
        dump("nk.AdSceneSdk.new")
        -- nk.AdSceneSdk = import("app.module.login.plugins.AdScenePluginAndroid").new()
    end

    nk.ByActivity = import("app.module.login.plugins.ByActivityPluginAndroid").new()
    -- nk.ByActivity = import("app.module.login.plugins.ByActivityPluginIos").new()
elseif device.platform == "ios" then
    nk.Native = import(".util.LuaOCBridge").new()
    nk.Facebook = import("app.module.login.plugins.FacebookPluginIos").new()
    nk.Push = import("app.module.login.plugins.ApplePushService").new()
    nk.AdSdk = import("app.module.login.plugins.AdSdkPluginIos").new()
    nk.ByActivity = import("app.module.login.plugins.ByActivityPluginIos").new()
else
    nk.Native = import(".util.LuaBridgeAdapter")
    nk.Facebook = import("app.module.login.plugins.FacebookPluginAdapter").new()
    nk.AdSdk = import("app.module.login.plugins.AdSdkPluginAdapter").new()
end

-- 支持graph api
import("app.module.login.plugins.FacebookGraphApi").exportMethods(nk.Facebook)

-- 开关控制
nk.OnOff = import('app.module.login.OnOff').new()
-- feed控制器
nk.sendFeed = import('app.module.login.SendFeed').new()
--D后台上报
nk.DReport = import("app.module.report.PodengReport").new()

-- 加载远程图像
nk.ImageLoader = bm.ImageLoader.new()
nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG = "CACHE_TYPE_USER_HEAD_IMG"
nk.ImageLoader:registerCacheType(nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG, {
    path = device.writablePath .. "cache" .. device.directorySeparator .. "headpics" .. device.directorySeparator,
    onCacheChanged = function(path) 
        require("lfs")
        local fileDic = {}
        local fileIdx = {}
        local MAX_FILE_NUM = 500
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local f = path.. device.directorySeparator ..file
                --print ("\t "..f)
                local attr = lfs.attributes(f)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    --for name, value in pairs(attr) do
                    --    print(name, value)
                    --end
                    fileDic[attr.access] = f
                    fileIdx[#fileIdx + 1] = attr.access
                end
            end
        end
        if #fileIdx > MAX_FILE_NUM then
            table.sort(fileIdx)
            repeat
                local file = fileDic[fileIdx[1]]
                print("remove file -> " .. file)
                os.remove(file)
                table.remove(fileIdx, 1)
            until #fileIdx <= MAX_FILE_NUM
        end
    end,
})

nk.ImageLoader.CACHE_TYPE_ACT = "CACHE_TYPE_ACT"
nk.ImageLoader:registerCacheType(nk.ImageLoader.CACHE_TYPE_ACT, {
    path = device.writablePath .. "cache" .. device.directorySeparator .. "act" .. device.directorySeparator,
    onCacheChanged = function(path) 
        require("lfs")
        local fileDic = {}
        local fileIdx = {}
        local MAX_FILE_NUM = 100
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local f = path.. device.directorySeparator ..file
                --print ("\t "..f)
                local attr = lfs.attributes(f)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    --for name, value in pairs(attr) do
                    --    print(name, value)
                    --end
                    fileDic[attr.access] = f
                    fileIdx[#fileIdx + 1] = attr.access
                end
            end
        end
        if #fileIdx > MAX_FILE_NUM then
            table.sort(fileIdx)
            repeat
                local file = fileDic[fileIdx[1]]
                print("remove file -> " .. file)
                os.remove(file)
                table.remove(fileIdx, 1)
            until #fileIdx <= MAX_FILE_NUM
        end
    end,
})

nk.ImageLoader.CACHE_TYPE_GIFT = "CACHE_TYPE_GIFT"
nk.ImageLoader:registerCacheType(nk.ImageLoader.CACHE_TYPE_GIFT, {
    path = device.writablePath .. "cache" .. device.directorySeparator .. "gift" .. device.directorySeparator,
    onCacheChanged = function(path) 
        require("lfs")
        local fileDic = {}
        local fileIdx = {}
        local MAX_FILE_NUM = 400
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local f = path.. device.directorySeparator ..file
                --print ("\t "..f)
                local attr = lfs.attributes(f)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    --for name, value in pairs(attr) do
                    --    print(name, value)
                    --end
                    fileDic[attr.access] = f
                    fileIdx[#fileIdx + 1] = attr.access
                end
            end
        end
        if #fileIdx > MAX_FILE_NUM then
            table.sort(fileIdx)
            repeat
                local file = fileDic[fileIdx[1]]
                print("remove file -> " .. file)
                os.remove(file)
                table.remove(fileIdx, 1)
            until #fileIdx <= MAX_FILE_NUM
        end
    end,
})

nk.ImageLoader.CACHE_TYPE_MATCH = "CACHE_TYPE_MATCH"
nk.ImageLoader:registerCacheType(nk.ImageLoader.CACHE_TYPE_MATCH, {
    path = device.writablePath .. "cache" .. device.directorySeparator .. "match" .. device.directorySeparator,
    onCacheChanged = function(path) 
        require("lfs")
        local fileDic = {}
        local fileIdx = {}
        local MAX_FILE_NUM = 100
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local f = path.. device.directorySeparator ..file
                --print ("\t "..f)
                local attr = lfs.attributes(f)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    --for name, value in pairs(attr) do
                    --    print(name, value)
                    --end
                    fileDic[attr.access] = f
                    fileIdx[#fileIdx + 1] = attr.access
                end
            end
        end
        if #fileIdx > MAX_FILE_NUM then
            table.sort(fileIdx)
            repeat
                local file = fileDic[fileIdx[1]]
                print("remove file -> " .. file)
                os.remove(file)
                table.remove(fileIdx, 1)
            until #fileIdx <= MAX_FILE_NUM
        end
    end,
})

bm.ui.ScrollView.defaultScrollBarFactory =  function (direction)
    if direction == bm.ui.ScrollView.DIRECTION_VERTICAL then
        return display.newScale9Sprite("#vertical_scroll_bar.png", 0, 0, cc.size(8, 24))
    elseif direction == bm.ui.ScrollView.DIRECTION_HORIZONTAL then
        return display.newScale9Sprite("#horizontal_scroll_bar.png", 0, 0, cc.size(24, 8))
    end
end

return nk
