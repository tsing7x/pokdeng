--
-- Author: Johnny Lee
-- Date: 2014-07-08 12:47:00
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
-- local DisplayUtil = import("app.util.DisplayUtil")
local HallScene = class("HallScene", function()
    return display.newScene("HallScene")
end)
local HallController = import("app.module.hall.HallController")
local LoginGameView = import("app.module.hall.LoginGameView")
local MainHallView  = import("app.module.hall.MainHallView")
-- local ChooseRoomView  = import("app.module.hall.ChooseRoomView")
local ChooseRoomView = import("app.module.hall.ChooseRoomViewEx")
local AttendDokbActPageView = import("app.module.dokbAct.AttendDokbActPageView")
local ChoosePersonalRoomView = import("app.module.hall.ChoosePersonalRoomView")
local ChooseMatchRoomView = import("app.module.hall.ChooseMatchRoomViewEEx")
local PswEntryPopup = import("app.module.hall.personalRoomDialog.PswEntryPopup")

-- local MatchRoomChooseHelpPopup = import("app.module.match.views.MatchRoomChooseHelpPopup")

local logger = bm.Logger.new("HallScene")

-- 加载纹理参数
HallScene.numTexture = 0

local BACKGROUND_ZORDER  = 0
local LOGIN_GAME_ZORDER  = 1
local POKER_GIRL_ZORDER  = 2
local CHOOSE_ROOM_ZORDER = 3
local CHOOSE_PERSONAL_ROOM_ZORDER = 4
local MAIN_HALL_ZORDER   = 5

function HallScene:ctor(viewType, action)

    -- dump(display.getRunningScene().name, "ctor: display.getRunningScene().name :===================")
    self.viewType_ = viewType or 0
    self.controller_ = HallController.new(self)
    self.animTime_ = self.controller_:getAnimTime()

    -- 背景缩放系数
    if display.width > 1140 and display.height == 640 then
        self.bgScale_ = display.width / 1140
    elseif display.width == 960 and display.height > 640 then
        self.bgScale_ = display.height / 640
    else
        self.bgScale_ = 1
    end

    -- 背景
    self.mainHallBg_ = display.newSprite("main_hall_bg.jpg")
        :scale(self.bgScale_)
        :pos(display.cx, display.cy)
        :addTo(self, BACKGROUND_ZORDER)

    display.addSpriteFrames("personalRoop_th.plist", "personalRoop_th.png")
    
    -- poker girl
    display.addSpriteFrames("girl_texture.plist", "girl_texture.png")
    self.pokerGirlBatchNode_ = display.newBatchNode("girl_texture.png")
        :addTo(self, POKER_GIRL_ZORDER)
    display.newSprite("#poker_girl.png")
        :addTo(self.pokerGirlBatchNode_)
        :schedule(handler(self, self.pokerGirlBlink_), 5) -- 5
   
    -- self:addGrayFilter()
    if self.viewType_ == HallController.FIRST_OPEN then
        self.pokerGirlBatchNode_:pos(display.cx * 0.5 + 48, display.cy):scale(self.bgScale_)
        self.loginView_ = LoginGameView.new(self.controller_)
            :pos(display.cx, display.cy)
            :addTo(self, LOGIN_GAME_ZORDER)
        self.loginView_:setShowState()
    elseif self.viewType_ == HallController.LOGIN_GAME_VIEW then
        self.pokerGirlBatchNode_:pos(display.cx, display.cy):scale(self.bgScale_)
    elseif self.viewType_ == HallController.MAIN_HALL_VIEW then
        self.pokerGirlBatchNode_:pos(display.cx, display.cy):scale(self.bgScale_ * 0.8)
    elseif self.viewType_ == HallController.CHOOSE_NOR_VIEW then
        self.pokerGirlBatchNode_:pos(display.cx, display.cy):scale(self.bgScale_)
    elseif self.viewType_ == HallController.CHOOSE_PRO_VIEW then
        self.pokerGirlBatchNode_:pos(display.cx, display.cy):scale(self.bgScale_)
    elseif self.viewType_ == HallController.CHOOSE_PERSONAL_NOR_VIEW then
        self.pokerGirlBatchNode_:pos(display.cx, display.cy):scale(self.bgScale_)
    elseif self.viewType_ == HallController.CHOOSE_PERSONAL_POINT_VIEW then
        self.pokerGirlBatchNode_:pos(display.cx, display.cy):scale(self.bgScale_)
    elseif self.viewType_ == HallController.CHOOSE_MATCH_NOR_VIEW then
        self.pokerGirlBatchNode_:pos(display.cx, display.cy):scale(self.bgScale_)
    elseif self.viewType_ == HallController.CHOOSE_MATCH_PRO_VIEW then
        self.pokerGirlBatchNode_:pos(display.cx, display.cy):scale(self.bgScale_)
    end

    self.action_ = action
    -- 根据视图类型加载纹理
    if self.viewType_ == HallController.FIRST_OPEN then
        -- 首次进入场景，加载大厅纹理与共用纹理
        display.addSpriteFrames("common_texture.plist", "common_texture.png", handler(self, self.onLoadTextureComplete))

        self.viewType_ = HallController.LOGIN_GAME_VIEW
    else
        self:showHallView_()
    end

    -- android返回键处理
    if device.platform == "android" then
        self.touchLayer_ = display.newLayer()
        self.touchLayer_:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
            if event.key == "back" then 
                if not nk.PopupManager:removeTopPopupIf() then
                    local currentHallView = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
                    if currentHallView == HallController.MAIN_HALL_VIEW then
                        device.showAlert(bm.LangUtil.getText("COMMON", "LOGOUT_DIALOG_TITLE"),
                            bm.LangUtil.getText("COMMON", "LOGOUT_DIALOG_MSG"),
                            {
                                bm.LangUtil.getText("COMMON", "CANCEL"),
                                bm.LangUtil.getText("COMMON", "LOGOUT"),
                            },
                            function(event)
                                if event.buttonIndex == 2 then
                                    -- 派发登出成功事件
                                    bm.EventCenter:dispatchEvent(nk.eventNames.HALL_LOGOUT_SUCC)
                                else
                                    local isAdSceneOpen = nk.OnOff:check("unionAd")
                                    dump(isAdSceneOpen,"onLoadedHallTexture_")

                                    if isAdSceneOpen and nk.AdSceneSdk then
                                        local state = nk.AdSceneSdk:showInterstitialAdDialog(true,
                                            function(state)
                                                -- dump(state,"showBannerAdDialog-callback333")
                                                if (1 ~= checkint(state)) then
                                                    nk.AdSceneSdk:destroy()
                                                    nk.app.exit()
                                                end
                                            end, function(ctype)
                                                -- body
                                                nk.AdSceneSdk:destroy()
                                                nk.app.exit()
                                            end)
                                        -- dump(state,"state--showBannerAdDialog444")
                                    else
                                        nk.app:exit()
                                    end
                                end
                            end)

                    elseif currentHallView == HallController.CHOOSE_NOR_VIEW then
                        self.controller_:showMainHallView()
                    elseif currentHallView == HallController.CHOOSE_PRO_VIEW then
                        self.controller_:showMainHallView()
                    elseif currentHallView == HallController.CHOOSE_PERSONAL_NOR_VIEW then
                        self.controller_:showMainHallView()
                    elseif currentHallView == HallController.CHOOSE_PERSONAL_POINT_VIEW then
                        self.controller_:showMainHallView()
                    elseif currentHallView == HallController.CHOOSE_MATCH_NOR_VIEW then
                        self.controller_:showMainHallView()
                    elseif currentHallView == HallController.CHOOSE_MATCH_PRO_VIEW then
                        self.controller_:showMainHallView()
                    else
                        device.showAlert(bm.LangUtil.getText("COMMON", "QUIT_DIALOG_TITLE"),
                            bm.LangUtil.getText("COMMON", "QUIT_DIALOG_MSG"),
                            {
                                bm.LangUtil.getText("COMMON", "QUIT_DIALOG_CONFIRM"), 
                                bm.LangUtil.getText("COMMON", "QUIT_DIALOG_CANCEL")
                            }, function(event)
                                if event.buttonIndex == 1 then
                                    
                                    local isAdSceneOpen = nk.OnOff:check("unionAd")
                                    
                                    if isAdSceneOpen and nk.AdSceneSdk then
                                        local state = nk.AdSceneSdk:showInterstitialAdDialog(true,
                                            function(state)
                                              
                                                if (1 ~= checkint(state)) then
                                                    nk.AdSceneSdk:destroy()
                                                    nk.app.exit()
                                                end
                                            end,function(ctype)
                                                -- if (2 ~= checkint(ctype)) then
                                                    nk.AdSceneSdk:destroy()
                                                    nk.app.exit()
                                                -- end
 
                                            end)
                                       
                                    else
                                        nk.app:exit()
                                    end

                                    -- nk.app:exit()
                                end
                            end)
                    end
                end
            end
        end)
        self.touchLayer_:setKeypadEnabled(true)
        self:addChild(self.touchLayer_)
    end

    if action == "logout" then
        self.controller_:doLogout()
    elseif action == "doublelogin" then
        self.controller_:doLogout(bm.LangUtil.getText("LOGIN", "DOUBLE_LOGIN_MSG"))
    end
end

function HallScene:onLoadTextureComplete(str, texture)
    HallScene.numTexture = HallScene.numTexture + 1
    dump("HallScene.numTexture " .. HallScene.numTexture)
    if HallScene.numTexture == 1 then
        display.addSpriteFrames("hall_texture.plist", "hall_texture.png", handler(self, self.onLoadTextureComplete))
    elseif HallScene.numTexture == 2 then
        self:showHallView_()

        -- 把这里算作 大厅进入完成, 是最准确的
        self.controller_:umengEnterHallTimeUsage()

        self.controller_:checkAutoLogin()
    end
end

function HallScene:showHallView_()
    if self.viewType_ == HallController.LOGIN_GAME_VIEW then
        -- 展示登录游戏界面
        self:showLoginView_()
    elseif self.viewType_ == HallController.MAIN_HALL_VIEW then
        -- 展示主大厅界面
        self:showMainHallView_(MainHallView.TABLE_POS_BOTTOM)
    elseif self.viewType_ == HallController.CHOOSE_NOR_VIEW then
        -- 展示选择普通房间界面
        self:showChooseRoomView_(HallController.CHOOSE_NOR_VIEW)
    elseif self.viewType_ == HallController.CHOOSE_PRO_VIEW then
        -- 展展示选择专业房间界面
        self:showChooseRoomView_(HallController.CHOOSE_PRO_VIEW)

    elseif self.viewType_ == HallController.CHOOSE_PERSONAL_NOR_VIEW then
        -- 展示选择普通私人房间界面
        self:showChoosePersonalRoomView_(HallController.CHOOSE_PERSONAL_NOR_VIEW)
    elseif self.viewType_ == HallController.CHOOSE_PERSONAL_POINT_VIEW then
        -- 展展示选择积分私人房间界面
        self:showChoosePersonalRoomView_(HallController.CHOOSE_PERSONAL_POINT_VIEW)
    elseif self.viewType_ == HallController.CHOOSE_MATCH_NOR_VIEW then
        -- 展示选择普通比赛房间界面
        self:showChooseMatchRoomView_(HallController.CHOOSE_MATCH_NOR_VIEW)
    elseif self.viewType_ == HallController.CHOOSE_MATCH_PRO_VIEW then
        -- 展展示选择专业比赛房间界面
        self:showChooseMatchRoomView_(HallController.CHOOSE_MATCH_PRO_VIEW)
    end
end

-- 显示登录视图
function HallScene:showLoginView_()
    -- 登录视图
    if not self.loginView_ then
        self.loginView_ = LoginGameView.new(self.controller_)
            :pos(display.cx, display.cy)
            :addTo(self, LOGIN_GAME_ZORDER)
    end

    -- self:addGrayFilter()

    -- 动画
    self.pokerGirlBatchNode_:moveTo(self.animTime_, display.cx * 0.5 + 48, display.cy)
    self.loginView_:playShowAnim()

    -- 设置当前场景类型全局数据
    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.LOGIN_GAME_VIEW)
end

-- 显示主界面视图
function HallScene:showMainHallView_(tablePos)
    -- 主界面视图
    self.mainHallView_ = MainHallView.new(self.controller_, tablePos)
        :pos(display.cx, display.cy)
        :addTo(self, MAIN_HALL_ZORDER)

    -- 动画
    self.pokerGirlBatchNode_:scaleTo(self.animTime_, self.bgScale_):moveTo(self.animTime_, display.cx, display.cy)
    self.mainHallView_:playShowAnim()

    -- 设置当前场景类型全局数据
    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.MAIN_HALL_VIEW)
    
    self.controller_:updateOnline()

    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    self.controller_:checkToRoom()

    -- self:removeGrayFilter()
end

-- 显示选择房间视图
function HallScene:showChooseRoomView_(viewType)
    -- 选房间视图
    self.chooseRoomView_ = ChooseRoomView.new(self.controller_, viewType)
        :pos(display.cx, display.cy)
        :addTo(self, CHOOSE_ROOM_ZORDER)

    -- 动画
    self.pokerGirlBatchNode_:scaleTo(self.animTime_, self.bgScale_ * 0.8)
    self.chooseRoomView_:playShowAnim()

    -- 设置当前场景类型全局数据
    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, viewType)

    if self.action_ == "gochsnorroom" then
        --todo
        dump("Go ChooseNorRoomView!")
    end
end
--设置抢庄房间列表
function HallScene:onSetGrabRoomList(data)
    if self.chooseRoomView_ and self.chooseRoomView_["onSetGrabRoomList"] then
        self.chooseRoomView_:onSetGrabRoomList(data)
    end
end


-- 显示比赛场选场视图
function HallScene:showChooseMatchRoomView_(viewType)
    -- 选房间视图
    self.chooseMatchRoomView_ = ChooseMatchRoomView.new(self.controller_, viewType)
        :pos(display.cx, display.cy)
        :addTo(self, CHOOSE_PERSONAL_ROOM_ZORDER)

    -- 动画
    self.pokerGirlBatchNode_:scaleTo(self.animTime_, self.bgScale_ * 0.8)
    self.chooseMatchRoomView_:playShowAnim()

    -- 设置当前场景类型全局数据
    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, viewType)
end

function HallScene:showDokbActPageView_()
    -- body
    self.pokerGirlBatchNode_:scaleTo(self.animTime_, self.bgScale_ * 0.8)
    self.attendDokbActPageView_ = AttendDokbActPageView.new(self.controller_):showPanel()
    self.attendDokbActPageView_:playShowAnim()
end

--显示私人房选场视图
-- 显示选择房间视图
function HallScene:showChoosePersonalRoomView_(viewType)
    -- 选房间视图
    self.choosePersonalRoomView_ = ChoosePersonalRoomView.new(self.controller_, viewType)
        :pos(display.cx, display.cy)
        :addTo(self, CHOOSE_PERSONAL_ROOM_ZORDER)

    -- 动画
    self.pokerGirlBatchNode_:scaleTo(self.animTime_, self.bgScale_ * 0.8)
    self.choosePersonalRoomView_:playShowAnim()

    -- 设置当前场景类型全局数据
    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, viewType)
end

function HallScene:onLoginSucc()
    if self.loginView_ then
        self.loginView_:playHideAnim()
        self.loginView_ = nil
    end
    self:showMainHallView_(MainHallView.TABLE_POS_BOTTOM)
    -- self:performWithDelay(handler(self.controller_, self.controller_.checkNeedEnterRoomInLoginData), 1)
end

function HallScene:onLogoutSucc()
    if self.mainHallView_ and self.mainHallView_.playHideAnim  then
        self.mainHallView_:playHideAnim()
    end
    if self.chooseRoomView_ and self.chooseRoomView_.playHideAnim then
        self.chooseRoomView_:playHideAnim()
    end

    if self.attendDokbActPageView_ and self.attendDokbActPageView_.hidePanel then
        --todo
        self.attendDokbActPageView_:hidePanel()
        self.attendDokbActPageView_ = nil
    end

    if self.choosePersonalRoomView_ and self.choosePersonalRoomView_.playHideAnim then
        self.choosePersonalRoomView_:playHideAnim()
    end

    if self.chooseMatchRoomView_ and self.chooseMatchRoomView_.playHideAnim then
        self.chooseMatchRoomView_:playHideAnim()
    end
    
    self.pokerGirlBatchNode_:scaleTo(self.animTime_, self.bgScale_)
    self:showLoginView_()

    local isAdSceneOpen = nk.OnOff:check("unionAd")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(false)
    end
end

function HallScene:onShowChooseRoom(viewType)
    if self.mainHallView_ then
        self.mainHallView_:playHideAnim()
    end
    self:showChooseRoomView_(viewType)
end

function HallScene:onShowDobkActPage()
    -- body
    if self.mainHallView_ then
        self.mainHallView_:playHideAnim()
    end

    self:showDokbActPageView_()
end

function HallScene:onShowChoosePersonalRoom(viewType)
    -- MatchRoomChooseHelpPopup.new():show()

    if self.mainHallView_ then
        self.mainHallView_:playHideAnim()
    end
    self:showChoosePersonalRoomView_(viewType)
end

function HallScene:showChooseMatchRoomView(viewType)
    if self.mainHallView_ then
        self.mainHallView_:playHideAnim()
    end
    self:showChooseMatchRoomView_(viewType)
end
function HallScene:onUpdateMatchInfo()
    dump("0x0220,HallScene")
    if self.chooseMatchRoomView_ and self.chooseMatchRoomView_["getMatchHallInfo"] then
         dump("0x0220,HallScene 2")
        self.chooseMatchRoomView_:getMatchHallInfo()
    end
end
function HallScene:onShowMainHall()

    local currentHallView = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
    if currentHallView == HallController.CHOOSE_NOR_VIEW or currentHallView == HallController.CHOOSE_PRO_VIEW then
        if self.chooseRoomView_ then
            self.chooseRoomView_:playHideAnim()
        end
    end

    if currentHallView == HallController.CHOOSE_PERSONAL_NOR_VIEW or currentHallView == HallController.CHOOSE_PERSONAL_POINT_VIEW then
        if self.choosePersonalRoomView_ then
            self.choosePersonalRoomView_:playHideAnim()
        end
    end

    if currentHallView == HallController.CHOOSE_MATCH_NOR_VIEW or currentHallView == HallController.CHOOSE_MATCH_PRO_VIEW then
        if self.chooseMatchRoomView_ then
            self.chooseMatchRoomView_:playHideAnim()
        end
    end
   
    self:showMainHallView_(MainHallView.TABLE_POS_TOP)
end

function HallScene:getBgScale()
    return self.bgScale_ or 1
end

function HallScene:onSearchPersonalRoom(data)
    local ret = data.ret
    dump(data,"onSearchPersonalRoom")
    if ret == 0 then
         if data.hasPwd == 1 then
            --有密码，弹密码框
            PswEntryPopup.new(data, handler(self, self.onPswPopCallback)):show() 
            --传入这个回调 handler(self,self.onPswPopCallback)
        else
            --无密码，直接进
            nk.server:loginPersonalRoom(nil,data.tableID)

        end

    else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL","PERSONAL_NOROOM"))
    end
end

function HallScene:onPswPopCallback(psw,roomData)
    if not psw or not roomData then
        return
    end

    nk.server:loginPersonalRoom(nil,roomData.tableID,psw)
    dump(psw,"psw==onPswPopCallback")
end

function HallScene:pokerGirlBlink_()
    local blinkSpr = display.newSprite("#poker_girl_blink_half.png")
        :pos(- 31.4, 235.8)
        :addTo(self.pokerGirlBatchNode_)
    blinkSpr:performWithDelay(function ()
        blinkSpr:setSpriteFrame(display.newSpriteFrame("poker_girl_blink_all.png"))
    end, 0.05) -- 0.05
    blinkSpr:performWithDelay(function ()
        blinkSpr:setSpriteFrame(display.newSpriteFrame("poker_girl_blink_half.png"))
    end, 0.15) -- 0.15
    blinkSpr:performWithDelay(function ()
        blinkSpr:removeFromParent()
    end, 0.20) -- 0.20
end

function HallScene:onEnter()
    -- dump(display.getRunningScene().name, "onEnter: display.getRunningScene().name :===================")

    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "beginScene",
                    args = {sceneName = "HallScene"}}
    end
    if self.action_ == "doublelogin" and self.viewType_ == HallController.LOGIN_GAME_VIEW then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "DOUBLE_LOGIN_MSG"))
        self.action_ = " "
    end

end

function HallScene:onEnterTransitionFinish()
    -- body
    -- dump(display.getRunningScene().name, "onEnterFinish: display.getRunningScene().name :===================")

    if self.viewType_ == HallController.MAIN_HALL_VIEW then
        --todo
        local doActionByTag = {
            ["activitycenter"] = function()
                -- body
                self:performWithDelay(function()
                    -- body
                    self.controller_.view_:onMoreChipClick()
                end, 0.2)
                -- self.controller_.view_:onMoreChipClick()
            end,

            ["freechips"] = function()
                -- body
                self.controller_.view_:_onSignInBtnCallBack()

                self:performWithDelay(function()
                    -- body
                    self.controller_.view_:onNewestActivityClick(nil, bm.TouchHelper.CLICK)
                end, 0.2)
                
                -- local NewestActPopup = import("app.module.newestact.NewestActPopup")
                -- NewestActPopup.new(1, function(action, param)
                --     if action == "playnow" then
                --         self.controller_:getEnterRoomData(nil, true)
                --     elseif action == "gotoChoseRoomView" then
                --         self.controller_:showChooseRoomView(param)
                --     elseif action == "invite" then

                --         if self.controller_.view_ and self.controller_.view_.onInviteBtnClick then
                --             self.controller_.view_:onInviteBtnClick()
                --         end
                --     elseif action == "openShop" then

                --         if self.controller_.view_ and self.controller_.view_.onStoreBtnClicked then
                --             -- self:onStoreBtnClicked()
                --             StorePopup.new(nil,param and param.purchaseType or nil):showPanel()
                --         end
                --     elseif action == "goMatchRoom" then
                --         self.controller_:showChooseMatchRoomView(self.controller_.CHOOSE_MATCH_NOR_VIEW)
                --         local matchDataInfo = nk.MatchConfig:getMatchDataById(3)

                --         if matchDataInfo then
                --             --todo
                --             -- nk.runningScene.controller_.view_:onChipClick_(matchDataInfo)
                --             -- dump(matchDataInfo, "matchDataInfo :===============")
                --             self.controller_.view_:onChipClick_(matchDataInfo)
                --             -- MatchApplyPopup.new(matchDataInfo):show()
                --         else
                --             dump("matchRoomData config Wrong!")
                --         end
                --     elseif action == "clkActCenter" then
                --         --todo

                --         self.controller_.view_:onMoreChipClick()
                --     elseif action == "openScoreMarket" then
                --         self.controller_.view_:onScoreMarketBtnClicked()
                --     end
                -- end):show()
            end,

            ["fillawrdaddr"] = function()
                -- body
                local isPopFillAdress = true
                self.controller_.view_:onScoreMarketBtnClicked(isPopFillAdress)
            end
        }

        if self.action_ and doActionByTag[self.action_] then
            --todo

            doActionByTag[self.action_]()
        end
    end
end

function HallScene:onExit()
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "endScene",
                    args = {sceneName = "HallScene"}}
    end

    if device.platform == "android" then
        device.cancelAlert()
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    bm.DataProxy:setData(nk.dataKeys.LAST_ENTER_SCENE,"HallScene")
end

function HallScene:onCleanup()
    -- 清除大厅纹理（保留共用纹理）
    display.removeSpriteFramesWithFile("hall_texture.plist", "hall_texture.png")
    
    
    if nk.config.CHRISTMAS_THEME_ENABLED then
        display.removeSpriteFramesWithFile("christmas_texture.plist", "christmas_texture.png")
    end
    if nk.config.SONGKRAN_THEME_ENABLED then
        display.removeSpriteFramesWithFile("songkran_texture.plist", "songkran_texture.png")
    end

    if nk.config.POKDENG_AD_ENABLED then
        display.removeSpriteFramesWithFile("pokdeng_ad_texture.plist", "pokdeng_ad_texture.png")
    end

    display.removeSpriteFramesWithFile("personalRoop_th.plist", "personalRoop_th.png")
    
    -- 清理控制器
    self.controller_:dispose()

    local isAdSceneOpen = nk.OnOff:check("unionAd")
    if isAdSceneOpen and nk.AdSceneSdk then
        nk.AdSceneSdk:setShowRecommendBar(false)
    end
end

-- function HallScene:addGrayFilter()
--     DisplayUtil.setGray(self.pokerGirlBatchNode_)
--     DisplayUtil.setGray(self.mainHallBg_)
-- end


-- function HallScene:removeGrayFilter()
--     DisplayUtil.removeShader(self.pokerGirlBatchNode_)
--     DisplayUtil.removeShader(self.mainHallBg_)
-- end
return HallScene