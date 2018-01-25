require("config")
require("framework.init")
require("boyaa.init")
require("app.init")

local NineKeApp = class("NineKeApp", cc.mvc.AppBase)
local TRANSITION_TIME = 0.6

function NineKeApp:ctor()
    NineKeApp.super.ctor(self)
    nk.app = self
end

function NineKeApp:run()
   
    nk.SoundManager:preload("commonSounds")

    -- init analytics
    self:init_analytics()

    -- 上报广告平台游戏开始
    if nk.AdSdk then
        nk.AdSdk:reportStart()
    end

    self:enterScene("HallScene")
end

-- init analytics
function NineKeApp:init_analytics()
    if device.platform == "android" or device.platform == "ios" then

        cc.analytics:start("analytics.UmengAnalytics")
        -- 改为真实的应用ID，第二参数为渠道号(可选)
        cc.analytics:doCommand{command = "startWithAppkey",
                args = {appKey = appconfig.UMENG_APPKEY, channelId = nk.Native:getChannelId()}}
        --更新在线参数
        -- cc.analytics:doCommand{command = "setLogEnabled", args = {value = true}}
        cc.analytics:doCommand{command = "updateOnlineConfig"}
    end
end

function NineKeApp:enterHallScene(args)
    -- dump(args, "NineKeApp:enterHallScene,args :===================")
    self:enterScene("HallScene", args, "FADE", TRANSITION_TIME)
    nk.SoundManager:playSound(nk.SoundManager.REPLACE_SCENE)
end

function NineKeApp:enterRoomScene(args)
    self:enterScene("RoomScene", args, "FADE", TRANSITION_TIME)
    nk.SoundManager:playSound(nk.SoundManager.REPLACE_SCENE)
end
function NineKeApp:enterRoomSceneEx(args)
    self:enterScene("RoomSceneEx", args, "FADE", TRANSITION_TIME)
    nk.SoundManager:playSound(nk.SoundManager.REPLACE_SCENE)
end
function NineKeApp:enterMatchRoomScene(args)
    self:enterScene("MatchRoomScene", args, "FADE", TRANSITION_TIME)
    nk.SoundManager:playSound(nk.SoundManager.REPLACE_SCENE)
end
function NineKeApp:enterGrabDealerRoomScene(args)
     self:enterScene("GrabDealerRoomScene", args, "FADE", TRANSITION_TIME)
    nk.SoundManager:playSound(nk.SoundManager.REPLACE_SCENE)
end
-- 统计停留在游戏不到30秒
local function umeng_check_enter_background_too_short()
    local g = global_statistics_for_umeng
    local t1 = g.enter_foreground_time or g.run_main_timestamp
    local delta = math.abs(os.difftime(os.time(), t1))
    if delta <= 30 then
        cc.analytics:doCommand {command = 'eventCustom', args = {eventId = 'leave_in_short_time',
            attributes = 'leave_time,' .. delta, counter    = 1}}
    end
end

-- 统计 loading界面关闭应用的情况
-- 日期: Jun 2 2016
-- 备注: 产品曦敏说,此项的含义是为了统计没有进入过大厅,还停留在登录界面就流失的
-- 用户的数量.
-- 已经进入过大厅并游戏了很长时间,只是后来返回登录界面,然后切到后台的用户,不应该
-- 统计的.
local function umeng_check_close_view()
    local g = global_statistics_for_umeng
    if g.umeng_view == g.Views.login then
        if g.first_enter_login_not_checked then
            g.first_enter_login_not_checked = false

            -- cocos2d-x/external/extra/network/CCNetwork.h
            local nt = network.getInternetConnectionStatus()
            local ns = ({ [0] = 'NA', [1] = 'Wifi', [2] = 'WWAN' })[nt] or 'Unknown'
            local s1 = 'network_type,' .. ns

            -- 友盟限制: 每个事件最多10个参数,每个参数最多1000个取值
            local dt = math.abs(os.difftime(os.time(), g.run_main_timestamp))
            if dt > 999 then dt = 999 end
            local s2 = '|quit_time,' .. dt

            cc.analytics:doCommand {command = 'eventCustom', args = {eventId = 'quit_at_login_scene',
                attributes = s1 .. s2, counter    = 2}}
        end
    end
end

function NineKeApp:onEnterBackground()
    NineKeApp.super.onEnterBackground(self)
    bm.EventCenter:dispatchEvent(nk.eventNames.APP_ENTER_BACKGROUND)
    if device.platform == "android" or device.platform == "ios" then
        umeng_check_enter_background_too_short()
        umeng_check_close_view()
        cc.analytics:doCommand {command = "applicationDidEnterBackground"}
    end

    audio.stopMusic(true)
end

function NineKeApp:onEnterForeground()
    NineKeApp.super.onEnterForeground(self)
    bm.EventCenter:dispatchEvent(nk.eventNames.APP_ENTER_FOREGROUND)
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand {command = "applicationWillEnterForeground"}

        -- 记录下返回的时间
        global_statistics_for_umeng.enter_foreground_time = os.time()
    end
end

return NineKeApp
