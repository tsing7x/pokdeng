--
-- Author: johnny@boomegg.com
-- Date: 2014-08-26 21:26:45
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local HallController = class("HallController")
local logger = bm.Logger.new("HallController")
local RegisterPopup = import("app.login.RegisterPopup")
local LoginRewardView = import("app.module.loginreward.LoginRewardView")
local MessageData = import("app.module.hall.message.MessageData")
local LoadGiftControl = import("app.module.gift.LoadGiftControl")
local LoadLevelControl = import("app.util.LoadLevelControl")
local UserCrash = import("app.module.room.userCrash.UserCrash")
local PayGuide = import("app.module.room.purchGuide.PayGuide")
local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
local AgnChargePayGuidePopup = import("app.module.newstore.agnChrgGuide.AgnChrgPayGuidePopup")
local PayGuidePopMgr = import("app.module.room.purchGuide.PayGuidePopMgr")
local GrabDealerEnterLimitPopup = import("app.module.grabDealer.views.GrabDealerEnterLimitPopup")
-- local NewestActPopup = import("app.module.newestact.NewestActPopup")
-- local MatchApplyPopup = import("app.module.match.views.MatchApplyPopup")

local TicketTransferPopup = import("app.module.ticketTransfer.TicketTransferPopup")
local NewerGuidePopup = import("app.module.newer.NewerGuidePopup")

-- 视图类型
HallController.FIRST_OPEN      = 0
HallController.LOGIN_GAME_VIEW = 1
HallController.MAIN_HALL_VIEW  = 2
HallController.CHOOSE_NOR_VIEW = 3
HallController.CHOOSE_PRO_VIEW = 4
HallController.CHOOSE_PERSONAL_NOR_VIEW = 5
HallController.CHOOSE_PERSONAL_POINT_VIEW = 6
HallController.CHOOSE_MATCH_NOR_VIEW = 7
HallController.CHOOSE_MATCH_PRO_VIEW = 8

-- 事件TAG
HallController.SVR_LOGIN_OK_EVENT_TAG = 100
HallController.SVR_DOUBLE_LOGINUCC_EVENT_TAG = 101
HallController.SVR_ONLINE_EVENT_TAG = 102
HallController.SVR_LOGIN_ROOM_OK_EVENT_TAG = 103
HallController.SVR_LOGIN_ROOM_FAIL_EVENT_TAG = 104
HallController.SVR_ERROR_EVENT_TAG = 105
HallController.HALL_LOGOUT_SUCC_EVENT_TAG = 106
HallController.ENTER_ROOM_WITH_DATA_EVENT_TAG = 107

HallController.SVR_GET_PERSONAL_ROOM_LIST_EVENT_TAG = 108
HallController.SVR_LOGIN_PERSONAL_ROOM_TAG = 109
HallController.SVR_SEARCH_PERSONAL_ROOM_TAG = 110
HallController.SVR_CREATE_PERSONAL_ROOM_TAG = 111
HallController.SVR_COMMON_BROADCAST_TAG = 112 

HallController.ENTER_MATCH_WITH_DATA_EVENT_TAG = 113
HallController.SVR_LOGIN_OK_NEW_EVENT_TAG = 114
HallController.SVR_LOGIN_MATCH_ROOM_FAIL_EVENT_TAG = 115
HallController.SVR_LOGIN_MATCH_ROOM_OK_EVENT_TAG = 116
HallController.ENTER_GRAB_WITH_DATA_EVENT_TAG = 119
HallController.SVR_LOGIN_GRAB_ROOM_OK_EVENT_TAG = 120
HallController.SVR_LOGIN_GRAB_DELAER_ROOM_FAIL_EVENT_TAG = 121
HallController.SVR_LOGIN_OK_RE_CONECT_TAG = 122
HallController.SVR_GRAB_ROOM_LIST_RESULT_EVENT_TAG = 123
HallController.SVR_PUSH_MATCH_ROOM_EVENT_TAG = 124
HallController.SVR_TIME_MATCH_OFF_TAG = 125

HallController.SVR_SUONA_BROADCAST_RECV_TAG = 117
HallController.SVR_LOGIN_NEW_ROOM_OK_EVENT_TAG = 126
-- 动画时间
HallController.ANIM_TIME = 0.5

function HallController:ctor(scene)
    self.scene_ = scene    
    bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_OK, handler(self, self.onLoginServerSucc_), HallController.SVR_LOGIN_OK_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_DOUBLE_LOGIN, handler(self, self.onDoubleLoginError_), HallController.SVR_DOUBLE_LOGINUCC_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_ONLINE, handler(self, self.onOnline_), HallController.SVR_ONLINE_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_ROOM_OK, handler(self, self.onLoginRoomSucc_), HallController.SVR_LOGIN_ROOM_OK_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_ROOM_FAIL, handler(self, self.onLoginRoomFail_), HallController.SVR_LOGIN_ROOM_FAIL_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_ERROR, handler(self, self.onServerFail_), HallController.SVR_ERROR_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.HALL_LOGOUT_SUCC, handler(self, self.handleLogoutSucc_), HallController.HALL_LOGOUT_SUCC_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_GET_PERSONAL_ROOM_LIST, handler(self, self.onGetPersonalRoomList), HallController.SVR_GET_PERSONAL_ROOM_LIST_EVENT_TAG)
    -- bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_PERSONAL_ROOM, handler(self, self.onLoginPersonalRoom), HallController.SVR_LOGIN_PERSONAL_ROOM_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_SEARCH_PERSONAL_ROOM,handler(self,self.onSearchPersonalRoom),HallController.SVR_SEARCH_PERSONAL_ROOM_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_CREATE_PERSONAL_ROOM,handler(self,self.onCreatePersonalRoom),HallController.SVR_CREATE_PERSONAL_ROOM_TAG)
    -- 绑定事件
    bm.EventCenter:addEventListener(nk.eventNames.ENTER_ROOM_WITH_DATA, handler(self, self.onEnterRoom_), HallController.ENTER_ROOM_WITH_DATA_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_COMMON_BROADCAST,handler(self,self.onBroadCast_),HallController.SVR_COMMON_BROADCAST_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.ENTER_MATCH_WITH_DATA, handler(self, self.onEnterMatch_), HallController.ENTER_MATCH_WITH_DATA_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.ENTER_GRAB_DEALER_ROOM,handler(self,self.onEnterGrabDealer_),HallController.ENTER_GRAB_WITH_DATA_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_OK_NEW, handler(self, self.onLoginServerSuccNew_), HallController.SVR_LOGIN_OK_NEW_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_OK_RE_CONECT,handler(self,self.onReLoginServerSuccNew_),HallController.SVR_LOGIN_OK_RE_CONECT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_MATCH_ROOM_FAIL,handler(self,self.onLoginMatchRoomFail_),HallController.SVR_LOGIN_MATCH_ROOM_FAIL_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_MATCH_ROOM_OK,handler(self,self.onLoginMatchRoomOk_),HallController.SVR_LOGIN_MATCH_ROOM_OK_EVENT_TAG)
	bm.EventCenter:addEventListener(nk.eventNames.SVR_SUONA_BROADCAST_RECV, handler(self, self.onSuonaBroadRecv_), HallController.SVR_SUONA_BROADCAST_RECV_TAG)

    bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_GRAB_ROOM_OK,handler(self, self.onLoginGrabRoomSucc_),HallController.SVR_LOGIN_GRAB_ROOM_OK_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_GRAB_DELAER_ROOM_FAIL,handler(self,self.onLoginGrabRoomFail_),HallController.SVR_LOGIN_GRAB_DELAER_ROOM_FAIL_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_GRAB_ROOM_LIST_RESULT,handler(self,self.onGrabRoomlistResult),HallController.SVR_GRAB_ROOM_LIST_RESULT_EVENT_TAG)

    bm.EventCenter:addEventListener(nk.eventNames.SVR_PUSH_MATCH_ROOM,handler(self,self.onTimeMatchPush_ ),HallController.SVR_PUSH_MATCH_ROOM_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.eventNames.SVR_TIME_MATCH_OFF,handler(self,self.timeMatchOff_),HallController.SVR_TIME_MATCH_OFF_TAG)

    bm.EventCenter:addEventListener(nk.eventNames.SVR_LOGIN_NEW_ROOM_OK,handler(self,self.onLoginNewRoomSucc_),HallController.SVR_LOGIN_NEW_ROOM_OK_EVENT_TAG)
    --登录是否正在处理
    self.isLoginInProgress_ = false
    self:bindDataObservers_()
    -- self:umengUpdateTimeUsage()

    self.schedulerPool_ = bm.SchedulerPool.new()

    self.schedulerPool_:delayCall(handler(self,self.umengUpdateTimeUsage),6)

end

function HallController:bindDataObservers_()
    self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", handler(self,self.checkMoneyChange))
end

function HallController:unbindDataObservers_()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.moneyObserverHandle_)
end

function HallController:checkMoneyChange(money)
    --检测破产,记录历史钱数
    if not self.hallGlobalMoney_ then
        -- dump(money,"HallCheckMoneyChange首次赋值,money:")
        self.hallGlobalMoney_ = money
    else
        if nk.userData.bankruptcyGrant and (self.hallGlobalMoney_ > nk.userData.bankruptcyGrant.maxBmoney and money < nk.userData.bankruptcyGrant.maxBmoney) then
            -- dump("money:" .. money .. " oldMoney:" .. self.hallGlobalMoney_,"HallCheckMoneyChange破产上报,money:")
            self.hallGlobalMoney_ = money
            local otherFiled = bm.LangUtil.getText("COMMON", "OTHER")
            --符合破产条件上报,大厅传底注为0，标识为“其他”
            nk.http.reportBankrupt(0,otherFiled or "")
        elseif nk.userData.bankruptcyGrant and (money > nk.userData.bankruptcyGrant.maxBmoney) then
            self.hallGlobalMoney_ = money
            -- dump(money,"HallCheckMoneyChange非破产,money:")
        end
        
    end

end

function HallController:onOnline_(evt)

end

-- 重复登录
function HallController:onDoubleLoginError_()
    -- nk.PopupManager:removeAllPopup()
    
    nk.ui.Dialog.new({
        messageText = T("您的账户在别处登录"), 
        secondBtnText = T("确定"),
        closeWhenTouchModel = false,
        hasFirstButton = false,
        hasCloseButton = false,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self:handleLogoutSucc_()
            end
        end,
    }):show()
    self:handleLogoutSucc_()
end


--断线重连后重新进入房间
function HallController:reLoginRoom_()
    -- 添加加载loading
    msg = msg or bm.LangUtil.getText("ROOM", "ENTERING_MSG")
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    self.roomLoading_ = nk.ui.RoomLoading.new(msg)
        -- :pos(display.cx, display.cy)
        :addTo(self.view_, 100)
    self.roomLoading_:setNodeEventEnabled(true)
    self.roomLoading_.onCleanup = handler(self,function(obj)
        obj.roomLoading_ = nil
    end)


    nk.server:loginRoom(self.tid__)
    nk.server:pause()
    self.loginRoomSucc_ = false
    self:loadRoomTexture_()
end    

function HallController:loginWithGuest()
    if self.isLoginInProgress_ then
        return
    end
    self.isLoginInProgress_ = true

    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    local isLoginedDevice = (lastLoginType and lastLoginType ~= "")
    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE, "GUEST")
    nk.userDefault:flush()
    -- 登录动画
    if self.view_ and self.view_.playLoginAnim then
        --todo
        self.view_:playLoginAnim()
    end
    self:startGuestLogin_("")
end

function HallController:checkAutoLogin()
    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)

    if lastLoginType == "GUEST" then
        self:loginWithGuest()
    elseif lastLoginType == "FACEBOOK" then

        --为保证每次token可用，需每次调用FB API 登录
        self:loginWithFacebook()

        --[[
        local accessToken = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_ACCESS_TOKEN, "")
        if accessToken and accessToken ~= "" then
            tokenData = string.split(accessToken, "#")
            if tokenData and tokenData[2] and (tonumber(tokenData[2]) > os.time()) then
                self:loginFacebookWithAccessToken_(tokenData[1],tokenData[2])
            else
                --兼容旧版和IOS版本
                self:loginFacebookWithAccessToken_(accessToken,nil)
            end
            
        end
        --]]
    end
end

function HallController:startGuestLogin_(deviceName)  
    self.loginWithGuestId_ = nk.http.login(
        "GUEST", nk.Native:getLoginToken(),nil,nil,
        handler(self, self.onLoginSucc_), 
        handler(self, self.onLoginError_)
    )
end

function HallController:loginWithNewGuestByDebug()

    if self.view_ and self.view_.playLoginAnim then
        --todo
        self.view_:playLoginAnim()
    end
    nk.http.login(
        "GUEST", nk.Native:getLoginToken(true), nil,nil,
        handler(self, self.onLoginSucc_), 
        handler(self, self.onLoginError_)
    )
end

function HallController:loginWithFacebook()
    if self.isLoginInProgress_ then
        return
    end
    self.isLoginInProgress_ = true
    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE, "FACEBOOK")
    nk.userDefault:flush()
    
    if nk.Facebook then
        nk.Facebook:login(function(success, result)
            logger:debug(success, result)
            if success then
                -- local tokenData = json.decode(result)
                if result then
                    if type(result) == "table" then
                        local accessToken = result.accessToken
                        local exptime = result.exptime
                        self:loginFacebookWithAccessToken_(accessToken,exptime)
                    elseif type(result) == "string" then
                        --兼容旧版和IOS
                        self:loginFacebookWithAccessToken_(result,nil)
                    end

                end
                
            else
                self.isLoginInProgress_ = false
                if result == "canceled" then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "CANCELLED_MSG"))
                    self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "5", "authorization cancelled")
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                    self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "6", "authorization failed")
                end
            end
        end)
    end
end

function HallController:loginFacebookWithAccessToken_(accessToken,exptime)
    nk.Facebook.setAccessToken(accessToken) 
    nk.Facebook.getId(function(data)
        local idsTbl = json.decode(data)
        if type(idsTbl) == "table" and idsTbl.id then
            local id = idsTbl.id            
            local sesskey = nk.userDefault:getStringForKey(nk.cookieKeys.LOGIN_SESSKEY .. id, "")           
            self:loginFacebookWithAccessTokenAndSesskey_(accessToken,sesskey,exptime)
        else
            self:loginFacebookWithAccessTokenAndSesskey_(accessToken, "",exptime)
        end        
    end, function() 
        self:loginFacebookWithAccessTokenAndSesskey_(accessToken, "",exptime)
    end)

    
    --[[
    self.view_:playLoginAnim()
    -- 开始登录
    self.facebookAccessToken_ = accessToken
    tokenStr = accessToken
    if exptime then
        tokenStr = accessToken .. "#" .. exptime
    end
    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_ACCESS_TOKEN, tokenStr)
    nk.userDefault:flush()
    nk.http.login(
        "FACEBOOK", nk.Native:getLoginToken(), accessToken,
        handler(self, self.onLoginSucc_), 
        handler(self, self.onLoginError_)
    )
    --]]
end

function HallController:loginFacebookWithAccessTokenAndSesskey_(accessToken, sesskey,tokenExptime)
    if self.view_ and self.view_.playLoginAnim then
        --todo
        self.view_:playLoginAnim()
    end

    -- 开始登录
    self.facebookAccessToken_ = accessToken
    tokenStr = accessToken
    if tokenExptime then
        tokenStr = accessToken .. "#" .. tokenExptime
    end
    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_ACCESS_TOKEN, tokenStr)
    nk.userDefault:flush()

    self.loginWithFBId_ = nk.http.login(
        "FACEBOOK", nk.Native:getLoginToken(), accessToken,sesskey,
        handler(self, self.onLoginSucc_), 
        handler(self, self.onLoginError_))
end


function HallController:onLoginSucc_(data)

    -- dump(data, "onLoginSucc_.data :=============")
    self.isLoginInProgress_ = false
    self:processUserData(data)
    bm.DataProxy:setData(nk.dataKeys.USER_DATA, data, true)

    -- 连接HallServer
    local ip,port = string.match(nk.userData.hallip[1], "([%d%.]+):(%d+)")  
    -- if ip then
    --     ip = string.format("64:ff9b::%s",ip)
    -- end
  
    nk.server:connect(ip, port, false)
    nk.http.load(function(retData)

        -- dump(retData, "load.retData :===================", 8)
        nk.OnOff:init(retData)

        if (not nk.OnOff:checkLocalVersion("roomlist")) or bm.DataProxy:getData(nk.dataKeys.TABLE_CONF) == nil then
            nk.http.getRoomList(function(retData)
                -- dump(retData,"getRoomList.retData :====================", 10)

                nk.OnOff:saveNewVersionInLocal("roomlist")
                bm.DataProxy:setData(nk.dataKeys.TABLE_CONF, retData.roomlist)
                bm.DataProxy:cacheData(nk.dataKeys.TABLE_CONF)
            end)
        end

        if (not nk.OnOff:checkLocalVersion("bankerlist")) or bm.DataProxy:getData(nk.dataKeys.GRAB_ROOM_LIST) == nil then
            nk.http.getGrabRoomList(function(retData)
                nk.OnOff:saveNewVersionInLocal("bankerlist")
                bm.DataProxy:setData(nk.dataKeys.GRAB_ROOM_LIST, retData)
                bm.DataProxy:cacheData(nk.dataKeys.GRAB_ROOM_LIST)
                -- dump(retData.roomlist,"roomlist")
            end)
        end


        if retData.bankruptcyGrant then
            nk.userData["bankruptcyGrant"] = retData.bankruptcyGrant
        end

        if retData.loginAward then
            nk.userData["loginReward"] = retData.loginAward
        end

        if retData.registrationAward then
            nk.userData["loginRewardStep"] = checkint(retData.registrationAward)
        end

        -- gucuReward! --
        if nk.OnOff:check("replayAward") then
            --todo
            nk.userData["recallAward"] = retData.recallAward
        end

        if retData.best then
            nk.userData["best"] = retData.best
        end
        
        if retData.bagPayList then
            --todo
            nk.userData["bagPayList"] = retData.bagPayList
        end

        if retData.open then
            nk.userData["open"] = retData.open
            nk.userData["open"]["mother"] = nil
            --if nk.userData["open"]["mother"] then
               bm.DataProxy:setData(nk.dataKeys.OPEN_ACT, 1) 
           -- end
        end
        if retData.bowltips then
            local codeNum = checkint(retData.bowltips.code)
            bm.DataProxy:setData(nk.dataKeys.FARM_TIPS, codeNum)
        end
        if retData.pointNotice then
            local winNum = checkint(retData.pointNotice)
            bm.DataProxy:setData(nk.dataKeys.CASH_WIN_SEND_NUM,winNum)
        else
            bm.DataProxy:setData(nk.dataKeys.CASH_WIN_SEND_NUM,45)
        end
        if retData.inviteFriend then
            nk.userData.inviteFriendLimit = retData.inviteFriend["fbLimit"].."" or "200"
            nk.userData.inviteSendChips = retData.inviteFriend["sendChips"] or 1000   --邀请发送奖励
            nk.userData.inviteBackChips = retData.inviteFriend["backChips"] or 50000 --邀请回来奖励
            nk.userData.recallBackChips = 50000 --召回奖励
            nk.userData.recallSendChips = 500   --召回发送奖励
        end

        local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)

        if lastLoginType == "FACEBOOK" then
            --todo
            self:reportInvitableFriends_(nk.userData.inviteFriendLimit)  -- 缓存FB好友数据
        end
        
        -- 没有奖励的情况之下才判断破产
        if checkint(retData.loginAward.ret) == 0 and checkint(retData.registrationAward) == 0 then
            if nk.userData.bankruptcyGrant and nk.userData["aUser.money"] < nk.userData.bankruptcyGrant.maxBmoney then

                if nk.userData["aUser.bankMoney"] >= nk.userData.bankruptcyGrant.maxsafebox then
                    --保险箱的钱大于设定值，引导保险箱取钱
                    local userCrash = UserCrash.new(0,0,0,0,true)
                    userCrash:show()

                else
                    if nk.userData.bankruptcyGrant.bankruptcyTimes < nk.userData.bankruptcyGrant.num then
                        -- dump(nk.userData.bankruptcyGrant.money[nk.userData.bankruptcyGrant.bankruptcyTimes],"bankruptcyGrant");

                        if nk.userData.bankruptcyGrant.bankruptcyTimes == 0 then
                            --todo
                            local isShowPay = nk.OnOff:check("payGuide")
                            local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false
                            -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

                            local shownSence = 3
                            local isThirdPayOpen = isShowPay
                            local isFirstCharge = not isPay
                            local payBillType = nil

                            if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
                                --todo
                                FirChargePayGuidePopup.new(0):showPanel(0)
                            else
                                local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                                if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and isPay and rechargeFavAccess then
                                    --todo
                                    AgnChargePayGuidePopup.new():showPanel(0)
                                else
                                    local params = {}

                                    params.isOpenThrPartyPay = isThirdPayOpen
                                    params.isFirstCharge = isFirstCharge
                                    params.sceneType = shownSence
                                    params.payListType = payBillType

                                    PayGuide.new(params):show(0)
                                end
                            end
                        else
                            local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
                            local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
                            local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
                            local limitDay = nk.userData.bankruptcyGrant.day or 1
                            local limitTimes = nk.userData.bankruptcyGrant.num or 0
                            local userCrash = UserCrash.new(bankruptcyTimes,rewardMoney,limitDay,limitTimes)
                            userCrash:show()
                        end
                    end
                end
            end
        end

        if retData.popad and retData.popad.open == 1 then
            --todo
            nk.userData.popad = retData.popad
        end

        if nk.ByActivity then
            --todo
            -- nk.ByActivity:switchServer(1) -- 切换到测试服
            nk.ByActivity:setup(function(initData)
                -- body
                nk.ByActivity:setWebViewTimeOut(3000)
                nk.ByActivity:setWebViewCloseTip(bm.LangUtil.getText("NEWSTACT", "DOUBLE_CLICK_EXIT"))
                nk.ByActivity:setNetWorkBadTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))

                nk.ByActivity:displayForce(2, function(data)
                    -- body
                    -- dump(data, "displayForce:displayCallBack.data :==============")
                end, function(str)
                    -- body
                    -- dump(str, "displayForce:closeCallBack.str :================")
                end)
            end)
        end

        local isShowPay = nk.OnOff:check("payGuide")
        local isPay = nk.userData.best and nk.userData.best.paylog == 1 or false
        -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

        if nk.AdSceneSdk then
          nk.AdSceneSdk:setup()
        end
        local isAdSceneOpen = nk.OnOff:check("unionAd")
        
        -- aUser.msta == 2 禁言，其他不禁言
        local silenced = checkint(nk.userData["aUser.msta"])
        nk.userData.silenced = (silenced == 2) and 1 or 0

        if isAdSceneOpen and nk.AdSceneSdk then
          dump(isAdSceneOpen, "HallScene:onLoginSucc")
          nk.AdSceneSdk:setShowRecommendBar(1)
        end
        
        if isShowPay and not isPay then
            --todo
            bm.DataProxy:setData(nk.dataKeys.CHARGEFAV_ONOFF, true)

            bm.DataProxy:setData(nk.dataKeys.ALMRECHARGEFAV_ONOFF, false)
            -- 补充符合首冲条件上报 --
            if nk.OnOff:check("firstchargeFavGray") then
                --todo
                nk.http.reportFirstPayData(1, function(retData)
                    -- body
                    -- dump(retData, "reportFirstPayData.data :==================")
                    
                end, function(errData)
                    -- body
                    dump(retData, "reportFirstPayData.errData :==================")
                end)
            end
        else
            bm.DataProxy:setData(nk.dataKeys.CHARGEFAV_ONOFF, false)

            local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
            if isShowPay and isPay and nk.OnOff:check("rechargeFavGray") and rechargeFavAccess then
                --todo
                nk.DReport:report({id = "AlmReChargeFavAccord"})
                bm.DataProxy:setData(nk.dataKeys.ALMRECHARGEFAV_ONOFF, true)
            else
                bm.DataProxy:setData(nk.dataKeys.ALMRECHARGEFAV_ONOFF, false)
            end
        end

        --引导提示
        if not nk.NewerGuideTip then
            nk.NewerGuideTip = import("app.module.newer.NewerGuideTipControler").new()
        end

        -- retData.dayNum = 2
        if checkint(retData.dayNum) > 0 then
            --新手引导相关管理
            if not nk.NewerGuide then
                nk.NewerGuide = import("app.module.newer.NewerGuideControler").new()
            end
            nk.NewerGuide:init(retData.dayNum)
            local firstRewardFlag = (checkint(nk.userData["isCreate"]) == 1) and true or false
            nk.NewerGuide:setFirstRewardFlag(firstRewardFlag)
        end

        self:onRewardPopup()
        self:showLoginReward()
        -- -- 登陆成功之后弹出各种奖励弹框
        -- self.view_:performWithDelay(handler(self, self.onRewardPopup), 1.5)
        -- -- login reward
        -- self.view_:performWithDelay(handler(self, self.showLoginReward), 1.5)
    end, function(errData)
        -- body
        dump(errData, "load.errData: ================")
    end)

    nk.http.GetUpdateVerInitInfo(function(data)
       local version = data.version
       local prizedesc = data.prizedesc

       bm.DataProxy:setData(nk.dataKeys.UPDATE_INFO,data)
    end,function(errData)
        
    end)

    nk.http.getIsCanSignState(function(data)
        -- body
        -- dump(data, "getIsCanSignState :===================")
        if data == 1 then
            --todo
            bm.DataProxy:setData(nk.dataKeys.HALL_SIGNIN_NEW, true)
        else
            bm.DataProxy:setData(nk.dataKeys.HALL_SIGNIN_NEW, false)
        end
    end,

    function(errData)
        -- body
        -- 错误情况默认为当天未签！
        bm.DataProxy:setData(nk.dataKeys.HALL_SIGNIN_NEW, false)
    end)

    -- 设置视图
    if (not self.scene_) or (not self.scene_.onLoginSucc) then
        --todo
        return
    end
    
    self.scene_:onLoginSucc()
    -- 派发登录成功事件
    bm.EventCenter:dispatchEvent(nk.eventNames.HALL_LOGIN_SUCC)
    -- 拉取消息
    self.onGetMessage()

    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    self:reportLoginResult_(lastLoginType, "0", "login success")
    if lastLoginType ==  "FACEBOOK" then
        
        nk.userData["canEditAvatar"] = false
        -- 设置FB好友为牌友
        -- bm.HttpService.POST({mod="friend", act="setFriends", access_token=self.facebookAccessToken_},
        --     function(ret)
        --         print("set facebook friends ret -> ", ret)
        --     end,
        --     function()
        --         print("set facebook friends fail")
        --     end)
        -- update apprequest
        nk.Facebook:updateAppRequest()
        -- 上报能邀请的好友数量
        -- self:reportInvitableFriends_()


        -- facebook 保存sesskey用于快速登录
        nk.userDefault:setStringForKey(nk.cookieKeys.LOGIN_SESSKEY .. nk.userData["aUser.sitemid"], data.sesskey)

    elseif lastLoginType == "GUEST" then
        nk.userData["canEditAvatar"] = true
    end

    local headImgLastUpdateTime = nk.userDefault:getStringForKey(nk.cookieKeys.DALIY_USERHEADIMG_UPDATE)
    local dayNow = os.date("%Y%m%d%H") -- 小时刷新

    if string.len(headImgLastUpdateTime) <= 0 or headImgLastUpdateTime ~= dayNow  then
        --todo
        nk.userDefault:setIntegerForKey(nk.cookieKeys.ENTEREDEXPER_TIMES_TODAY, 0)

        nk.userDefault:setStringForKey(nk.cookieKeys.DALIY_USERHEADIMG_UPDATE, dayNow)

        local deviceInfo = nk.Native:getDeviceInfo()

        --wifi环境下清理
        local netState = network.getInternetConnectionStatus()
        if netState == cc.kCCNetworkStatusReachableViaWiFi then
            nk.clearMyHeadImgCache()
        end

    end

    --缓存脏话库
    nk.cacheKeyWordFile()

    --更新折扣率
    self:updateUserMaxDiscount()

    --缓存礼物
    if nk.config.GIFT_SHOP_ENABLED and nk.userData.GIFT_JSON then
        LoadGiftControl:getInstance():loadConfig(nk.userData.GIFT_JSON)
    end

    --获取互动道具数量
    nk.http.getUserProps(2,function(pdata)
        if pdata then

            -- dump(pdata, "getUserProps.retData :=================")
            for _,v in pairs(pdata) do
                if tonumber(v.pnid) == 2001 then
                    nk.userData.hddjNum = checkint(v.pcnter)
                    break
                end
            end
        end
        
    end,function(errData)
        dump(errData, "getUserProps.errData :=================")
    end)

    -- 推送注册
    if nk.Push then
        nk.Push:register(function(success, result)
            if success then
                -- bm.HttpService.POST({mod="mobile", act="pushToken", token=result})
                nk.http.reportPushToken(result or "","clientid")
            end
        end)
    end

    if nk.GCMPush then
        nk.GCMPush:register(function(success, result)
            if success then
                -- bm.HttpService.POST({mod="mobile", act="pushToken", token=result})
                nk.http.reportPushToken(result or "","pushToken")
            end
        end)
    end

    if nk.AdSdk then
        -- 第一次登录上报注册信息
       if checkint(nk.userData["isCreate"]) == 1 then
            nk.AdSdk:reportReg(tostring(nk.userData["aUser.mid"]))
       end

       -- 上报登录信息
       nk.AdSdk:reportLogin(tostring(nk.userData["aUser.mid"]))

    end

    local searchedGamePackageName = "com.boomegg.nineke"  -- com.boomegg.nineke
    local isAppInstalled, gameInstallInfo = nk.Native:isAppInstalled(searchedGamePackageName)

    if gameInstallInfo then
        --todo
        local packageFlag = gameInstallInfo.flag
        local packageFirstInstallTime = gameInstallInfo.firstInstallTime
        local packageLastUpdateTime = gameInstallInfo.lastUpdateTime
    end
    

    local installState = isAppInstalled and 2 or 1
    
    nk.http.getUnionActShowState(installState,
        function(data)
            -- body
            -- dump(data, "getUnionActShowState.data :=====================")

            -- Annote For test --
             bm.DataProxy:setData(nk.dataKeys.UNIONACT_ONOFF, true) 
            -- end --
        end,

        function (errData)
            -- body
            -- dump(errData, "getUnionActShowState.errData :=====================")

            -- 取到返回数据错误，不满足开房条件 && 必要的话给予提醒 --

            -- Annote for test --
            bm.DataProxy:setData(nk.dataKeys.UNIONACT_ONOFF, false)
            -- end --
    end)

    -- just for test --
    -- bm.DataProxy:setData(nk.dataKeys.UNIONACT_ONOFF, true)
    -- end --

    -- dump(nk.userData, "nk.userData : ================")

    bm.DataProxy:setData(nk.dataKeys.SUONA_USETIP_ONOFF, true)  -- 每日首次登陆显示小喇叭tips,注释此条！
    if nk.userData.isFirst == 1 then
        --todo
        bm.DataProxy:setData(nk.dataKeys.HALL_NEWSTACT_PAOPTIP, true)

        -- nk.userDefault:setIntegerForKey(nk.cookieKeys.LAST_USED_EXPRE, 3)

        -- bm.DataProxy:setData(nk.dataKeys.SUONA_USETIP_ONOFF, true)  -- 每日首次登陆显示tips,添加这条
    else
        bm.DataProxy:setData(nk.dataKeys.HALL_NEWSTACT_PAOPTIP, false)
    end
    
    self:umengLoginTimeUsage()

    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_MID, nk.userData["aUser.mid"])
    nk.userDefault:flush()

end

--断线重连后重新进入房间
function HallController:reLoginMatch_()
    -- 添加加载loading
    msg = msg or bm.LangUtil.getText("ROOM", "ENTERING_MSG")
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end
    self.roomLoading_ = nk.ui.RoomLoading.new(msg)
        -- :pos(display.cx, display.cy)
        :addTo(self.view_, 100)
    self.roomLoading_:setNodeEventEnabled(true)
    self.roomLoading_.onCleanup = handler(self,function(obj)
        obj.roomLoading_ = nil
    end)

    dump(self.matchid_,"reLoginMatch_")
    nk.server:checkJoinMatch(self.matchid_)

    -- nk.server:loginRoom(self.tid__)
    -- nk.server:pause()
    -- self.loginRoomSucc_ = false
    -- self:loadRoomTexture_()
end

function HallController:reLoginTimeMatch_()
    msg = msg or bm.LangUtil.getText("ROOM", "ENTERING_MSG")
    if self.roomLoading_ then 
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    self.roomLoading_ = nk.ui.RoomLoading.new(msg)
        -- :pos(display.cx, display.cy)
        :addTo(self.view_, 100)
    self.roomLoading_:setNodeEventEnabled(true)
    self.roomLoading_.onCleanup = handler(self,function(obj)
        obj.roomLoading_ = nil
    end)

    dump(self.tid__,"reLoginTimeMatch_tid")
    dump(self.matchid_,"reLoginTimeMatch_matchid")
    
    local uid = nk.userData.uid   
    local strinfo = json.encode(nk.getUserInfo())
    nk.server:loginMatchRoom(uid, self.matchid_, self.tid__, strinfo or "")
end

function HallController:onLoginMatchRoomOk_(event)
    self.loginMatchRoomSucc_ = true
    dump("HallController:onLoginMatchRoomOk_")

    if self.loadedRoomTexture_ then
        -- self.isEnterRoomIng = false
        app:enterMatchRoomScene()
    else
        if (not self.loadingMatchRoomTexture_) then
            -- 添加加载loading
            msg = msg or bm.LangUtil.getText("ROOM", "ENTERING_MSG")
            if self.roomLoading_ then 
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            self.roomLoading_ = nk.ui.RoomLoading.new(msg)
                -- :pos(display.cx, display.cy)
                :addTo(self.view_, 100)
            self.roomLoading_:setNodeEventEnabled(true)
            self.roomLoading_.onCleanup = handler(self,function(obj)
                obj.roomLoading_ = nil
            end)

            nk.server:pause()
            -- self.loginRoomSucc_ = false
            self:loadMatchRoomTexture_()
        end
    end
   
end

function HallController:onLoginMatchRoomFail_(event)

    dump("HallController:onLoginMatchRoomFail_")
    self.loginMatchRoomSucc_ = false

    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    if self.loadedMatchRoomTexture_ then
        self.loadedMatchRoomTexture_ = false
        display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")
    end
end

function HallController:onLoginServerSuccNew_(event)

    do return end
   
    local runningScene = display.getRunningScene()
    if (not runningScene) or (runningScene.name == nil) or (runningScene.name ~= "HallScene") then
        return
    end 

    local data = event.data
    -- dump(data,"onLoginServerSuccNew_")
   
    if data.tid > 0 then
        --matchid > 0 在比赛场
        if data.matchid and data.matchid > 0 then
            self.matchid_ = data.matchid
            self.view_:performWithDelay(handler(self, self.reLoginMatch_), 1.5)
        else
            -- 重连房间
            self.tid__ = data.tid
            self.view_:performWithDelay(handler(self, self.reLoginRoom_), 1.5)
        end  
    end

    -- if data.tid > 0 and (not self.notReConnect_) then
    --     -- 重连房间
    --     self.tid__ = data.tid
    --     self.view_:performWithDelay(handler(self, self.reLoginRoom_), 1.5)
    -- end

end
function HallController:onReLoginServerSuccNew_(event)
    local runningScene = display.getRunningScene()
    if (not runningScene) or (runningScene.name == nil) or (runningScene.name ~= "HallScene") then
        return
    end 
    local data = event.data
    if data.tid <= 0 then
        return
    end
    
    dump(data,"HallController:onReLoginServerSuccNew_(204).data :====================")
    if data.type == 1 then
        self.tid__ = data.tid
        self.view_:performWithDelay(handler(self, self.reLoginRoom_), 1.5)
    elseif data.type == 2 then
            local exData = json.decode(data.extStr)
            self.matchid_ = exData.matchid
            self.view_:performWithDelay(handler(self, self.reLoginMatch_), 1.5)
    elseif data.type == 3 then
        self.grabRoomId_ = data.tid
       -- nk.TopTipManager:showTopTip("重连抢庄房间 tid = "..self.grabRoomId_)
        self.view_:performWithDelay(function()
            nk.server:loginGrabDealerRoom(self.grabRoomId_)
        end,1.5)
    elseif data.type == 4 then
        self.tid__ = data.tid
        local exData = json.decode(data.extStr)
        self.matchid_ = exData.matchid
        self.view_:performWithDelay(handler(self, self.reLoginTimeMatch_), 1.5)
    end
end

function HallController:onLoginServerSucc_(event)
    -- do return end
    -- local data = event.data
    -- if data.tid > 0 and (not self.notReConnect_) then
    --     -- 重连房间
    --     self.tid__ = data.tid
    --     self.view_:performWithDelay(handler(self, self.reLoginRoom_), 1.5)
    -- end
end

function HallController:getProxyListFromUserData_(userData)
    local ret = {}
    if userData.proxyAddr_array then
        for _, proxyAddr in ipairs(userData.proxyAddr_array) do
            local proxyArr = string.split(proxyAddr, ":")
            local proxyIp = proxyArr[1]
            local proxyPort = checkint(proxyArr[2])
            if proxyIp and string.len(proxyIp) > 0 and proxyPort > 0 then
                table.insert(ret, {ip=proxyIp, port=proxyPort})
            end
        end
    end
    return ret
end

function HallController:onSuonaBroadRecv_(evt)
    -- body
    -- dump(evt.data, "suonaInfoData :===================")
    -- 解析Data
    if evt.data and evt.data.msg_info then
        --todo
        local chatData = json.decode(evt.data.msg_info)

        -- 针对不是小喇叭的type 进行过滤.
        local msgType = chatData.type

        if msgType == 2 then
            --todo
            -- 等待做其他处理！
            local contentMsg = chatData.content
            local jumpIndex = chatData.location
            local textColorHex = chatData.color

            -- local textColorRGB = nil
            -- if textColorHex and string.len(textColorHex) > 0 then
            --     --todo
            --     local colorR = "0x" .. string.sub(textColorHex, 1, 2)
            --     local colorG = "0x" .. string.sub(textColorHex, 3, 4)
            --     local colorB = "0x" .. string.sub(textColorHex, 5, 6)

            --     textColorRGB = cc.c3b(colorR, colorG, colorB)
            -- end

            if jumpIndex == "0" then
                --todo
                -- nk.TopTipExManager:showTopTip({text = contentMsg, messageType = 1001})
                -- nk.TopTipExManager:setLblColor_(textColorRGB)
                self.suonaMsgQueue_ = self.suonaMsgQueue_ or {}
                table.insert(self.suonaMsgQueue_, contentMsg)

                if self.view_ and self.view_.playSuonaMsgScrolling then
                    --todo
                    self.view_:playSuonaMsgScrolling(contentMsg)
                else
                    nk.TopTipManager:showTopTip({text = contentMsg, messageType = 1000})
                end

            else
                -- self.broadcastJumpAction_ = jumpIndex

                -- self.exButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_aqua.png", pressed = "#common_btn_aqua.png", disabled = "#common_btn_disabled.png"},
                --     {scale9 = true})
                --     :setButtonSize(120, 48)
                --     :setButtonLabel("normal", display.newTTFLabel({text = "Go>>>", size = 20, color = styles.FONT_COLOR.LIGHT_TEXT,
                --         align = ui.TEXT_ALIGN_CENTER}))
                --     :onButtonClicked(buttontHandler(self, self.onBoroadCastMsgJump_))

                -- nk.TopTipExManager:showTopTip({text = contentMsg, messageType = 1001, button = self.exButton_})

                -- nk.TopTipExManager:setLblColor_(textColorRGB)

                return
            end

            return
        elseif msgType == 1 or not msgType then
            --todo
            local chatFromName = chatData.name
            local chatMsg = chatData.content
            local chatInfoMsg = "[" .. chatFromName .. "]" .. bm.LangUtil.getText("SUONA", "SAY") .. chatMsg

            self.suonaMsgQueue_ = self.suonaMsgQueue_ or {}
            table.insert(self.suonaMsgQueue_, chatInfoMsg)

            if self.view_ and self.view_.playSuonaMsgScrolling then
                --todo
                self.view_:playSuonaMsgScrolling(chatInfoMsg)
            else
                nk.TopTipManager:showTopTip({text = chatInfoMsg, messageType = 1000})
            end
        end
    end
end

-- 上报可邀请的好友数量
function HallController:reportInvitableFriends_(inviteAbleFriendNum)
    if device.platform == "android" or device.platform == "ios" then        
        -- local date = nk.userDefault:getStringForKey(nk.cookieKeys.DALIY_REPORT_INVITABLE)       
        nk.Facebook:getInvitableFriends(function(success, friendData) 
            if success then
                dump("FaceBook.getInvitableFriends Data Succ!")
            else
                dump("FaceBook.getInvitableFriends Data Failed!")
            end      
        end, inviteAbleFriendNum)
    end
end

function HallController:processUserData(userData)
    userData.inviteSendChips = 1000   --邀请发送奖励
    userData.inviteBackChips = 50000 --邀请回来奖励
    userData.recallBackChips = 50000 --召回奖励
    userData.recallSendChips = 500   --召回发送奖励
    --userData.uid = userData['aUser.mid']
    userData.GIFT_JSON = userData["urls.gift"] --礼物配置Json
    userData.MSGTPL_ROOT = userData["urls.msg"] --消息模板配置Json
    userData.LEVEL_JSON = userData["urls.level"] --等级配置Json
    userData.UPLOAD_PIC = userData["urls.updateicon"] -- 头像上传地址
    userData.WHEEL_CONF = userData["urls.luckyWheel2"] --幸运转盘配置Json
    userData.DIRTY_LIB  = userData["urls.keyword"] --过滤词库
    userData.MATCH_JSON = userData["urls.match"] -- 比赛场场次配置json
    userData.SCOREMARKET_JSON = userData["urls.matchgift"] --积分商城商品配置json
    userData.PROPS_JSON = userData["urls.props"]

    -- test
    userData.GIFT_SHOP = 1

    --level 缓存等级
    if not nk.Level then
        nk.Level = import("app.util.LoadLevelControl").new()
    end
    nk.Level:loadConfig(userData.LEVEL_JSON,function(success,levelData)
        if success then
            --计算是否可升级
            local exp = checkint(userData["aUser.exp"])
            local level = userData["aUser.mlevel"]          
            local maxLevel = nk.Level:getLevelByExp(exp);
            local dsLevel = maxLevel- level
            if (maxLevel > level) and (dsLevel >= 1) then
                userData.nextRwdLevel = level + 1
            else
                userData.nextRwdLevel = 0
            end
        end
    end)


    -- if not nk.MatchConfig then
    --     nk.MatchConfig = import("app.module.match.LoadMatchControl").new()
    -- end
    if not nk.MatchConfigEx then
        nk.MatchConfigEx = import("app.module.match.LoadMatchControlEx").new()
    end
    if not nk.MatchRegisterControl then
        nk.MatchRegisterControl = import("app.module.match.MatchRegisterControl").new()
    end
    if not nk.Props then
        nk.Props = import("app.util.LoadPropsControl").new()  
    end

    -- nk.MatchConfig:loadConfig(userData.MATCH_JSON)
    nk.MatchConfigEx:loadConfig(nil,handler(self,self.onLoadMatchExConfig),true)
    nk.Props:loadConfig(userData.PROPS_JSON,nil)
    -- nk.ScoreMarketConfig = import("app.module.scoreMarket.LoadScoreMarketControl").new()
    -- nk.ScoreMarketConfig:loadConfig(userData.SCOREMARKET_JSON) 
end


function HallController:onLoadMatchExConfig(isSuccess,matchsdata)
    if isSuccess and matchsdata then
        nk.http.getRegisteredMatchInfo(function(data)
            -- dump(data,"getRegisteredMatchInfo")

            for _,v in pairs(data) do
                nk.MatchConfigEx:addRegisterMatch(v)
                nk.MatchConfigEx:cacheRegisterMatch(v)

            end
        end,function(errData)
            
        end)

    end
end

function HallController:onRewardPopup()
    if nk.userData.loginRewardStep ~= nil and nk.userData.loginRewardStep > 0 then
        --原来的注释，现有新版奖励
        --display.addSpriteFrames("register_reward.plist", "register_reward.png", handler(self, self.onLoadRegisterTextureComplete))
        self:checkShowNewerGuidePopup()
    end
end

function HallController:checkShowNewerGuidePopup()
    if (not nk.NewerGuide) or (nk.NewerGuide:getNewerDay() ~= 1) then
        return
    end

    if checkint(nk.userData["isCreate"]) == 1 then
        local data = {}
        data.isAnim = true
        data.addMoney = 100000
        data.content = bm.LangUtil.getText("NEWER", "GUIDE_REWARD_CONTENT_1",100000,200000)
        data.iconFlag = 1
        data.onClose = function()
            if nk.NewerGuide then
                nk.NewerGuide:setFirstRewardFlag(false)
                local newerDay = nk.NewerGuide:getNewerDay()
                bm.DataProxy:setData(nk.dataKeys.NEWER_GUIDE_DAY,newerDay)
            end
        end
        NewerGuidePopup.new():show(data)
   end
end

function HallController:onLoadRegisterTextureComplete()
    if nk.userData.loginRewardStep ~= nil and nk.userData.loginRewardStep > 0 then
        nk.PopupManager:addPopup(RegisterPopup.new(), true,true,false)
    end
end

function HallController:onLoginError_(errData)
    -- @TODO: 后续上报

    -- dump(errData, "login.errData :===================")
    -- 通知网络错误
    local errTipsStr = bm.LangUtil.getText("COMMON", "BAD_NETWORK")
    if errData ~= nil and errData.errorCode then
        if (1 == errData.errorCode) then
            self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "1", "json parse error")
        elseif (-5 == errData.errorCode) then
            -- 通知账号被封
            errTipsStr = bm.LangUtil.getText("COMMON", "BE_BANNED")
        else
            self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "2", "php error:" .. errData.errorCode)
        end
    else
        self:reportLoginResult_(nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE), "4", "connection problem")
    end


    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE, "")
    nk.userDefault:flush()

    -- 视图处理登录失败
    self.isLoginInProgress_ = false
    self.view_:playLoginFailAnim()
    -- 通知网络错误
    if errTipsStr and errTipsStr ~= "" then
        nk.TopTipManager:showTopTip(errTipsStr)
    end
    

    self:umengLoginTimeUsage()
end

function HallController:doLogout()

    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE, "")
    nk.userDefault:flush()
    if nk.Facebook then
        nk.Facebook:logout()
        nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_ACCESS_TOKEN, "")
        nk.userDefault:flush()
    end
    nk.server:disconnect()   

    -- 上报广告平台 登出
    if nk.AdSdk then
        nk.AdSdk:reportLogout()
    end

    if nk.MatchConfigEx then
        nk.MatchConfigEx:dispose()
    end

    if nk.NewerGuide then
        nk.NewerGuide:dispose()
    end
    
    nk.PopupManager:removeAllPopup()
end

function HallController:onEnterMatch_(evt)
    self:getEnterMatchRoomData(evt.data)

end
--抢庄场选场逻辑
function HallController:findGrabRoom()
    local selfMoney = nk.userData["aUser.money"]
    local high = 240000000
    local middle = 24000000
    local low = 50000
    if selfMoney >= high then
        return 301  --高级场
    elseif selfMoney>=middle and selfMoney<high then
        return 302  --中级场
    elseif selfMoney>=low and selfMoney<middle then
        return 303  --低级场
    end
    return -1 --金币不足
end

function HallController:onEnterGrabDealer_(evt)

    -- dump(evt, "EVT.NAME|:ENTER_GRAB_DEALER_ROOM :===================")
    local gameLevel = evt.data and evt.data.gameLevel or nil
    local tableId = evt.data and evt.data.tableId or 0
    nk.server:getGrabDealerRoomAndLogin(gameLevel, checkint(tableId))
end

function HallController:loadGrabRoomTexture_()
    -- if self.loadingGrabRoomTexture_ then
    --     return
    -- end
    
    if not self.loadedGrabRoomTexture_ then
        self.loadingGrabRoomTexture_ = true
        self.loadedGrabRoomTexture_ = false
        self.loadGrabRoomTextureNum_ = 0
        cc.Director:getInstance():getTextureCache():addImageAsync("room_background.jpg", handler(self, self.onLoadedGrabRoomTexture_))
    else
        if self.loginGrabRoomSucc_ then
            app:enterGrabDealerRoomScene()
            --app:enterRoomSceneEx()
        end
        self.loadedGrabRoomTexture_ = true
    end
end

function HallController:loadNewRoomTexture_()
    -- if self.loadingGrabRoomTexture_ then
    --     return
    -- end
    
    if not self.loadedGrabRoomTexture_ then
        self.loadingGrabRoomTexture_ = true
        self.loadedGrabRoomTexture_ = false
        self.loadGrabRoomTextureNum_ = 0
        cc.Director:getInstance():getTextureCache():addImageAsync("room_background.jpg", handler(self, self.onLoadedNewRoomTexture_))
    else
        if self.loginGrabRoomSucc_ then
            app:enterRoomSceneEx()
        end
        self.loadedGrabRoomTexture_ = true
    end
end

function HallController:onLoadedNewRoomTexture_()
    self.loadGrabRoomTextureNum_ = self.loadGrabRoomTextureNum_ + 1
    if self.loadGrabRoomTextureNum_ == 1 then
        display.addSpriteFrames("room_texture.plist", "room_texture.png", handler(self, self.onLoadedNewRoomTexture_))
    elseif self.loadGrabRoomTextureNum_ == 2 then
        display.addSpriteFrames("grabDealerRoom.plist", "grabDealerRoom.png", handler(self, self.onLoadedNewRoomTexture_))
    elseif self.loadGrabRoomTextureNum_ == 3 then
        
        if self.loginGrabRoomSucc_ then
            app:enterRoomSceneEx()
        end
        self.loadedGrabRoomTexture_ = true
        self.loadingGrabRoomTexture_ = false
    end
end

function HallController:onLoadedGrabRoomTexture_()
    self.loadGrabRoomTextureNum_ = self.loadGrabRoomTextureNum_ + 1
    if self.loadGrabRoomTextureNum_ == 1 then
        display.addSpriteFrames("room_texture.plist", "room_texture.png", handler(self, self.onLoadedGrabRoomTexture_))
    elseif self.loadGrabRoomTextureNum_ == 2 then
        display.addSpriteFrames("grabDealerRoom.plist", "grabDealerRoom.png", handler(self, self.onLoadedGrabRoomTexture_))
    elseif self.loadGrabRoomTextureNum_ == 3 then
        
        if self.loginGrabRoomSucc_ then
            app:enterGrabDealerRoomScene()
        end
        self.loadedGrabRoomTexture_ = true
        self.loadingGrabRoomTexture_ = false
    end
end

-- 登录抢庄房间成功
function HallController:onLoginGrabRoomSucc_(evt)
    if evt.data then
        local roomInfo = {}
        
        roomInfo.minBuyIn = evt.data.minAnte
        roomInfo.maxBuyIn = evt.data.maxAnte
        roomInfo.roomType = evt.data.tableLevel
        roomInfo.blind = evt.data.baseAnte
        roomInfo.playerNum = evt.data.maxSeatCnt
        roomInfo.defaultBuyIn = evt.data.defaultAnte
        roomInfo.tid     = evt.data.tableId

        bm.DataProxy:setData(nk.dataKeys.ROOM_INFO, roomInfo)
    end

    if self.loadedGrabRoomTexture_ then
        self.isEnterRoomIng = false
        app:enterGrabDealerRoomScene()
    else
        if (not self.loadingGrabRoomTexture_) then
            -- 添加加载loading
           -- msg = "进抢庄房间啦，balalala"--msg or bm.LangUtil.getText("ROOM", "ENTERING_MSG")
            if self.roomLoading_ then 
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            local grabMsg = T("正在进入抢庄房间，请稍候...")
            self.roomLoading_ = nk.ui.RoomLoading.new(grabMsg)
                -- :pos(display.cx, display.cy)
                :addTo(self.view_, 100)
            self.roomLoading_:setNodeEventEnabled(true)
            self.roomLoading_.onCleanup = handler(self, function(obj)
                obj.roomLoading_ = nil
            end)

            nk.server:pause()
            -- self.loginRoomSucc_ = false
            self:loadGrabRoomTexture_()
        end
    end
    self.loginGrabRoomSucc_ = true    
end

-- 登录新玩法房间成功
function HallController:onLoginNewRoomSucc_(evt)
    if evt.data then
        local roomInfo = {}
        
        roomInfo.minBuyIn = evt.data.minAnte
        roomInfo.maxBuyIn = evt.data.maxAnte
        roomInfo.roomType = evt.data.tableLevel
        roomInfo.blind = evt.data.baseAnte
        roomInfo.playerNum = evt.data.maxSeatCnt
        roomInfo.defaultBuyIn = evt.data.defaultAnte
        roomInfo.tid     = evt.data.tableId

        bm.DataProxy:setData(nk.dataKeys.ROOM_INFO, roomInfo)
    end

    if self.loadedGrabRoomTexture_ then
        self.isEnterRoomIng = false
        app:enterRoomSceneEx()
    else
        if (not self.loadingGrabRoomTexture_) then
            -- 添加加载loading
           -- msg = "进抢庄房间啦，balalala"--msg or bm.LangUtil.getText("ROOM", "ENTERING_MSG")
            if self.roomLoading_ then 
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            local grabMsg = T("正在进入新玩法房间，请稍候...")
            self.roomLoading_ = nk.ui.RoomLoading.new(grabMsg)
                -- :pos(display.cx, display.cy)
                :addTo(self.view_, 100)
            self.roomLoading_:setNodeEventEnabled(true)
            self.roomLoading_.onCleanup = handler(self,function(obj)
                obj.roomLoading_ = nil
            end)

            nk.server:pause()
            -- self.loginRoomSucc_ = false
            self:loadNewRoomTexture_()
        end
    end
    self.loginGrabRoomSucc_ = true    
end

function HallController:onEnterRoom_(evt)
    local data = evt.data
    if (data and data.roomid and checkint(data.roomid) > 0) and (nk and nk.server) then
        -- nk.server:loginRoom(data.roomid)
        -- 添加加载loading
        msg = msg or bm.LangUtil.getText("ROOM", "ENTERING_MSG")
        if self.roomLoading_ then 
            self.roomLoading_:removeFromParent()
            self.roomLoading_ = nil
        end
        self.roomLoading_ = nk.ui.RoomLoading.new(msg)
            -- :pos(display.cx, display.cy)
            :addTo(self.view_, 100)
        self.roomLoading_:setNodeEventEnabled(true)
        self.roomLoading_.onCleanup = handler(self,function(obj)
            obj.roomLoading_ = nil
        end)

        nk.server:loginRoom(checkint(data.roomid))
        nk.server:pause()
        self.loginRoomSucc_ = false
        self:loadRoomTexture_()

        --以下定时器，5秒自动干掉loading,搜索房间server么有返回的情况下，
        --以免客户端卡死
        -- if not self.schedulerPool then
        --     self.schedulerPool = bm.SchedulerPool.new()
        -- end
        self.schedulerPool_:delayCall(function()
            if self.roomLoading_ then 
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
             
        end,5)
    end
end

function HallController:handleLogoutSucc_()
    self:doLogout()
    -- 设置视图
    self.scene_:onLogoutSucc()
end

function HallController:showChooseRoomView(viewType)
    -- 设置视图
    self.scene_:onShowChooseRoom(viewType)
end

function HallController:showChooseMatchRoomView(viewType)
    self.scene_:showChooseMatchRoomView(viewType)
end

function HallController:showDobkActPageView()
    -- body
    self.scene_:onShowDobkActPage()
end

function HallController:showChoosePersonalRoomView(viewType)
    self.scene_:onShowChoosePersonalRoom(viewType)
end
function HallController:checkToRoom()
    -- do return end
    local toMatchData = bm.DataProxy:getData(nk.dataKeys.TO_MATCH_DATA)
    --dump(toMatchData,"toMatchData")
    if toMatchData then
        if toMatchData.matchid and toMatchData.tableid then
            local matchid = toMatchData.matchid
            local tableid = toMatchData.tableid
            local uid = nk.userData.uid   
            local strinfo = json.encode(nk.getUserInfo())
            self.view_:performWithDelay(function()
                nk.server:loginMatchRoom(uid,matchid,tableid,(strinfo or ""))
            end, 1.5)
            bm.DataProxy:setData(nk.dataKeys.TO_MATCH_DATA,nil)
        end
    end
end
function HallController:showMainHallView()
    -- 设置视图
    self.scene_:onShowMainHall()
end


--进入比赛场
function HallController:getEnterMatchRoomData(args)

    dump("getEnterMatchRoomData"..args.matchid)

    -- msg = msg or bm.LangUtil.getText("ROOM", "ENTERING_MSG")
    -- if self.roomLoading_ then 
    --     self.roomLoading_:removeFromParent()
    --     self.roomLoading_ = nil
    -- end
    -- self.roomLoading_ = nk.ui.RoomLoading.new(msg)
    --     -- :pos(display.cx, display.cy)
    --     :addTo(self.view_, 100)

    if not nk.server:isLogin() then
        return
    end

    local matchid = args.matchid
    nk.server:checkJoinMatch(matchid)          
end


function HallController:loadMatchRoomTexture_()
    if self.loadingMatchRoomTexture_ then
        return
    end
    
    if not self.loadedMatchRoomTexture_ then
        self.loadingMatchRoomTexture_ = true
        self.loadedMatchRoomTexture_ = false
        self.loadMatchRoomTextureNum_ = 0
        cc.Director:getInstance():getTextureCache():addImageAsync("room_background.jpg", handler(self, self.onLoadedMatchRoomTexture_))
    else
        if self.loginMatchRoomSucc_ then
            app:enterMatchRoomScene()
        end
        self.loadedMatchRoomTexture_ = true
    end
end


function HallController:onLoadedMatchRoomTexture_()
    self.loadMatchRoomTextureNum_ = self.loadMatchRoomTextureNum_ + 1
    if self.loadMatchRoomTextureNum_ == 1 then
        display.addSpriteFrames("room_texture.plist", "room_texture.png", handler(self, self.onLoadedMatchRoomTexture_))
    elseif self.loadMatchRoomTextureNum_ == 2 then
        
        if self.loginMatchRoomSucc_ then
            app:enterMatchRoomScene()
        end
        self.loadedMatchRoomTexture_ = true
        self.loadingMatchRoomTexture_ = false
    end
end

function HallController:getEnterCashRoomData()
    local level = nk.getRoomLevelByCash(nk.userData["match.point"])
    if level == nil then
        self:getEnterRoomData(nil, true)
        return
    end
    local sendData = {gameLevel = checkint(level),tableId = 0}
    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = sendData})
end

-- 进入房间
function HallController:getEnterRoomData(args, isPlaynow) 
    if self.isEnterRoomIng == 1 then
        return
    end   
    -- dump("click enter room")

    if not nk.server:isLogin() then
        return
    end

    local level = nil
    if args == nil then
        local tableConf = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
        if not tableConf then 
            return
        end
       
        level = tableConf[1][1][1][1]
    else
        level = args.sb[1]
    end
    -- dump("level :" .. tostring(level))
  
    local roomData = nk.getRoomDataByLevel(level)

    if not roomData then
        return
    end

    -- dump(roomData, "roomData :==============")
    local roomDataFliter = {}
    roomDataFliter.blind = roomData.blind
    roomDataFliter.minBuyIn = roomData.minBuyIn
    roomDataFliter.maxBuyIn = roomData.limit
    roomDataFliter.roomType = roomData.roomGroup
    roomDataFliter.enterLimit = roomData.enterLimit

    -- 这里追加房间类型字段 1：低级场， 2：普通场， 3：高级场
    -- roomDataFliter.roomType = nil
    if isPlaynow then

        local isShowPay = nk.OnOff:check("payGuide")
        local isPay = nil
        -- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

        if nk.userData and nk.userData.best then
            isPay = nk.userData.best.paylog == 1 or false
        else
            isPay = false
        end

        level = nk.getRoomLevelByMoney2(nk.userData["aUser.money"])
        local roomData = nk.getRoomDataByLevel(level)
        if not roomData then
            return
        end

        if nk.userData["aUser.money"] >= roomData.enterLimit then
            --todo

            self.isEnterRoomIng = 1
            nk.server:quickPlay()
        else
            if nk.userData["aUser.bankMoney"] >= nk.userData.bankruptcyGrant.maxsafebox then
                --保险箱的钱大于设定值，引导保险箱取钱
                local userCrash = UserCrash.new(0,0,0,0,true)
                userCrash:show()

            else
                if nk.userData.bankruptcyGrant.bankruptcyTimes == 0 then
                    --todo
                    local shownSence = 3
                    local isThirdPayOpen = isShowPay
                    local isFirstCharge = not isPay
                    local payBillType = roomData.roomGroup

                    if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
                        --todo
                        FirChargePayGuidePopup.new(0):showPanel(0)
                    else

                        local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
                        if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and isPay and rechargeFavAccess then
                            --todo
                            AgnChargePayGuidePopup.new():showPanel(0)
                        else
                            local params = {}

                            params.isOpenThrPartyPay = isThirdPayOpen
                            params.isFirstCharge = isFirstCharge
                            params.sceneType = shownSence
                            params.payListType = payBillType

                            PayGuide.new(params):show(0)
                        end
                    end
                else

                    if nk.userData.bankruptcyGrant then
                        local rewardTime = nk.userData.bankruptcyGrant.bankruptcyTimes + 1
                        local bankruptcyTimes = nk.userData.bankruptcyGrant.bankruptcyTimes
                        local rewardMoney = nk.userData.bankruptcyGrant.money[rewardTime] or 0
                        local limitDay = nk.userData.bankruptcyGrant.day or 1
                        local limitTimes = nk.userData.bankruptcyGrant.num or 0
                        local userCrash = UserCrash.new(bankruptcyTimes,rewardMoney,limitDay,limitTimes)
                        userCrash:show()
                    end
                end
            end
        end
    else

        if roomData.maxBuyIn > 0 and nk.userData["aUser.money"] >= roomData.maxBuyIn and roomData.isAllIn == 1 then

            nk.ui.Dialog.new({
                messageText = T("您的筹码已超过该底注场上限，请切换更高级的场次游戏吧"), 
                titleText = bm.LangUtil.getText("COMMON", "NOTICE"),
                hasFirstButton = true,
                hasCloseButton = true,
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        nk.server:quickPlay()
                    end
                end}
                ):show()
            return
        end

        local isSuccLoginRoom = true
        if nk.userData["aUser.money"] >= roomDataFliter.enterLimit then
            isSuccLoginRoom = true
        else
            isSuccLoginRoom = false
            PayGuidePopMgr.new(roomDataFliter):show()
        end

        if isSuccLoginRoom then
            --todo
            nk.server:getRoomAndLogin(level, 0)
            self.isEnterRoomIng = 1
            msg = msg or bm.LangUtil.getText("ROOM", "ENTERING_MSG")
            if self.roomLoading_ then 
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            self.roomLoading_ = nk.ui.RoomLoading.new(msg)
                -- :pos(display.cx, display.cy)
                :addTo(self.view_, 100)
            self.roomLoading_:setNodeEventEnabled(true)
            self.roomLoading_.onCleanup = handler(self,function(obj)
                obj.roomLoading_ = nil
            end)
            nk.server:pause()
            self.loginRoomSucc_ = false
        end
    end
end

-- 开始连接房间
function HallController:loadRoomTexture_()
    if self.loadingRoomTexture_ then
        return
    end
    
    if not self.loadedRoomTexture_ then
        self.loadingRoomTexture_ = true
        self.loadedRoomTexture_ = false
        self.loadRoomTextureNum_ = 0
        cc.Director:getInstance():getTextureCache():addImageAsync("room_background.jpg", handler(self, self.onLoadedRoomTexture_))
    else
        if self.loginRoomSucc_ then
            app:enterRoomScene()
           --app:enterGrabDealerRoomScene()
        end
        self.loadedRoomTexture_ = true
    end
  
end

-- 加载房间纹理完成
function HallController:onLoadedRoomTexture_()
    self.loadRoomTextureNum_ = self.loadRoomTextureNum_ + 1
    if self.loadRoomTextureNum_ == 1 then
        display.addSpriteFrames("room_texture.plist", "room_texture.png", handler(self, self.onLoadedRoomTexture_))
    elseif self.loadRoomTextureNum_ == 2 then
        
        if self.loginRoomSucc_ then
            app:enterRoomScene()
            --app:enterGrabDealerRoomScene()
        end
        self.loadedRoomTexture_ = true
        self.loadingRoomTexture_ = false
    end
end

-- 登录房间成功
function HallController:onLoginRoomSucc_(evt)
    -- dump(evt, "HallController:onLoginRoomSucc_.evt :==================")
    if evt.data then
        local roomInfo = {}
        
        roomInfo.minBuyIn = evt.data.minAnte
        roomInfo.maxBuyIn = evt.data.maxAnte
        roomInfo.roomType = evt.data.tableLevel
        roomInfo.blind = evt.data.baseAnte
        roomInfo.playerNum = evt.data.maxSeatCnt
        roomInfo.defaultBuyIn = evt.data.defaultAnte
        roomInfo.tid     = evt.data.tableId

        bm.DataProxy:setData(nk.dataKeys.ROOM_INFO, roomInfo)
    end

    if self.loadedRoomTexture_ then
        self.isEnterRoomIng = false
        app:enterRoomScene()
    else
        if (not self.loadingRoomTexture_) then
            -- 添加加载loading
            msg = msg or bm.LangUtil.getText("ROOM", "ENTERING_MSG")
            if self.roomLoading_ then 
                self.roomLoading_:removeFromParent()
                self.roomLoading_ = nil
            end
            self.roomLoading_ = nk.ui.RoomLoading.new(msg)
                -- :pos(display.cx, display.cy)
                :addTo(self.view_, 100)

            nk.server:pause()
            -- self.loginRoomSucc_ = false
            self:loadRoomTexture_()
        end
    end

    self.loginRoomSucc_ = true    
end

-- 登录房间失败
function HallController:onLoginRoomFail_(evt)
    dump("login room fail")
    self.isEnterRoomIng = false
    if self.tid__ ~= nil and self.tid__ > 0 then
        self.notReConnect_ = true 
    end

    -- 移除加载loading
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    -- 清除房间纹理
    if self.loadedRoomTexture_ then
        self.loadedRoomTexture_ = false
        display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")
    end
    
    
    local errNum = checkint(evt.data.errno)

    -- dump(evt.data, "data : =====================")
    if errNum==5 then--桌子不存在
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ERROR_TABLE_NOT_EXIST"))
    elseif errNum==6 then--您正在房间内
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ERROR_USER_IN_TABLE"))
    elseif errNum==9 then--筹码太少
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ERROR_NOT_ENOUGH_MONEY"))
    elseif errNum==13 then--筹码太多，不能进场
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ERROR_TOO_MUCH_MONEY"))
    else
        nk.TopTipManager:showTopTip(T("服务器繁忙,请稍后再试[%d]", evt.data.errno))
    end  
end
function HallController:onLoginGrabRoomFail_(evt)
    dump("login grab room fail")
    self.isEnterRoomIng = false
    if self.tid__ ~= nil and self.tid__ > 0 then
        self.notReConnect_ = true 
    end

    -- 移除加载loading
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    -- 清除房间纹理
    if self.loadedGrabRoomTexture_ then
        self.loadedGrabRoomTexture_ = false
        display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")
    end
    
    
    local errNum = checkint(evt.data.errno)

    -- dump(evt.data, "data : =====================")
    if errNum==5 then--桌子不存在
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ERROR_TABLE_NOT_EXIST"))
    elseif errNum==6 then--您正在房间内
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ERROR_USER_IN_TABLE"))
    elseif errNum==9 then--筹码太少
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ERROR_NOT_ENOUGH_MONEY"))
    elseif errNum==13 then--筹码太多，不能进场
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "ERROR_TOO_MUCH_MONEY"))
    else
        nk.TopTipManager:showTopTip(T("服务器繁忙,请稍后再试[%d]", evt.data.errno))
    end  
end
function HallController:onServerFail_(evt)    
    --连接失败
    if evt.data == consts.SVR_ERROR.ERROR_CONNECT_FAILURE then       
        self:showErrorByDialog_(bm.LangUtil.getText("COMMON", "ERROR_CONNECT_FAILURE"))
    --心跳包超时
    elseif evt.data == consts.SVR_ERROR.ERROR_HEART_TIME_OUT then       
        self:showErrorByDialog_(bm.LangUtil.getText("COMMON", "ERROR_HEART_TIME_OUT"))
    --登录超时
    elseif evt.data == consts.SVR_ERROR.ERROR_LOGIN_TIME_OUT then       
        self:showErrorByDialog_(bm.LangUtil.getText("COMMON", "ERROR_LOGIN_TIME_OUT"))   
    end
end

function HallController:onGrabRoomlistResult(evt)
    if self.scene_ and self.scene_["onSetGrabRoomList"] then
        self.scene_:onSetGrabRoomList(evt.data)
    end
end
function HallController:onTimeMatchPush_(evt)
    -- dump("发送比赛场登录")
    local pack = evt.data
    local matchid = pack.matchid
    local tableid = pack.tableid
    local uid = nk.userData.uid   
    local strinfo = json.encode(nk.getUserInfo())
    nk.server:loginMatchRoom(uid,matchid,tableid,(strinfo or ""))
end
function HallController:timeMatchOff_(evt)

    --还得退赛。
    local pack = evt.data
    local matchid = pack.matchid
    nk.http.outMatch(matchid,function(data) 
        --dump(data,"outMatch")
        if self.scene_ and self.scene_["onUpdateMatchInfo"] then
            self.scene_:onUpdateMatchInfo()
        end
    end,

    function(errordata) 
        --dump(errordata,"outMatch")
    end)

end
function HallController:onGetPersonalRoomList(evt)
    if self.view_ and self.view_["onGetPersonalRoomList"] then
        self.view_:onGetPersonalRoomList(false, evt.data)
    end
end


function HallController:onLoginPersonalRoom(evt)
    -- do return end
    -- if self.view_ and self.view_["onLoginPersonalRoom"] then
    --     self.view_:onLoginPersonalRoom(evt.data)
    -- end
end


function HallController:onSearchPersonalRoom(evt)
    if self.scene_ and self.scene_["onSearchPersonalRoom"] then
        self.scene_:onSearchPersonalRoom(evt.data)

    end
    -- if self.view_ and self.view_["onSearchPersonalRoom"] then
    --     self.view_:onSearchPersonalRoom(evt.data)
    -- end
end


function HallController:onCreatePersonalRoom(evt)
    if self.view_ and self.view_["onCreatePersonalRoom"] then
        self.view_:onCreatePersonalRoom(evt.data)
    end
end

function HallController:onBroadCast_(evt)
    local pack = evt.data
    local mtype = pack.mtype
    if mtype == 2 then
        if pack.info then
            local inviteData = json.decode(pack.info)
            local inviteName_ = inviteData.name
            local tid = inviteData.tid;
            local content_ = bm.LangUtil.getText("HALL","PERSONAL_ROOM_INVITE_CONTENT",inviteName_)
            local buttonLabel_ = bm.LangUtil.getText("HALL","PERSONAL_ROOM_TOP_TIPS")[1]

            local button = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
                :setButtonSize(140, 52)
                :setButtonLabel("normal", display.newTTFLabel({text = buttonLabel_ , color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
                :onButtonClicked(buttontHandler(self,
                function() 
                    nk.server:searchPersonalRoom(nil,tid)
                end))
            nk.TopTipExManager:showTopTip({text = content_,button = button})
            
        end
    end
end

function HallController:showErrorByDialog_(msg)

    if self.errorDlg_ then
        return
    end

    msg = bm.LangUtil.getText("COMMON","ERROR_NETWORK_FAILURE") or msg
    self.errorDlg_ = nk.ui.Dialog.new({
        messageText = msg, 
        secondBtnText = bm.LangUtil.getText("COMMON", "RETRY_PLEASE"), 
        titleText = bm.LangUtil.getText("COMMON", "ERROR_NOTICE"),
        closeWhenTouchModel = false,
        hasFirstButton = false,
        hasCloseButton = false,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                local ip,port = string.match(nk.userData.hallip[1], "([%d%.]+):(%d+)")  
               
               
                if nk and nk.CommonTipManager then
                    nk.CommonTipManager:playReconnectingAnim(true,bm.LangUtil.getText("COMMON","ERROR_NETWORK_RECONNECT","\n"))
                end

                if (ip and ip ~= "") and (port and port ~= "") then
                   nk.server:connect(ip, port, false) 
                end
            end

            self.errorDlg_ = nil
        end,
    }):show()
end

function HallController:onServerStop_()
    -- 移除加载loading
    if self.roomLoading_ then
        self.roomLoading_:removeFromParent()
        self.roomLoading_ = nil
    end

    -- 清除房间纹理
    display.removeSpriteFramesWithFile("room_texture.plist", "room_texture.png")

    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("ROOM", "SERVER_STOPPED_MSG"), 
        secondBtnText = bm.LangUtil.getText("COMMON", "LOGOUT"), 
        closeWhenTouchModel = false,
        hasFirstButton = false,
        hasCloseButton = false,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self:handleLogoutSucc_()
            end
        end,
    }):show()
end

-- 获取在玩人数
function HallController:getPlayerCountData(roomType, field)
    nk.http.cancel(self.playerCountRequestId_)
    self.playerCountRequestId_ = nk.http.getOnline(function(retData)
        if self.view_ and self.view_["onGetPlayerCountData"] then
            self.view_:onGetPlayerCountData(retData, field)
        end
                 
    end, function ()
        if self.view_ then
            self.view_:performWithDelay(handler(self, self.getPlayerCountData), 2)
        end
        
    end)    
end

--获取比赛场在玩人数
function HallController:getMatchPlayerCountData()
    nk.http.cancel(self.matchPlayerCountRequestId_)
    -- local configVer = nk.MatchConfig:getMatchVersion()
    self.matchPlayerCountRequestId_ = nk.http.getMatchOnlineNum(1,function(retData)      
        if self.view_ and self.view_["getMatchPlayerCountData"] then
            self.view_:getMatchPlayerCountData(retData, field)
        end
        
    end, function ()
        if self.view_ then
            self.view_:performWithDelay(handler(self, self.getMatchPlayerCountData), 2)
        end
        
    end) 
end

--获取比赛场在线人数新接口
function HallController:getTimeMatchPlayerCountData(tb)
    nk.http.cancel(self.timeMatchPlayerCountRequestId_)
    -- local configVer = nk.MatchConfigEx:getMatchVersion()
    self.timeMatchPlayerCountRequestId_ = nk.http.getTimeMatchPeople(tb,function(retData)      
        if self.view_ and self.view_["onGetTimeMatchPlayerCountData"] then
            self.view_:onGetTimeMatchPlayerCountData(retData)
        end
        
    end, function ()
        if self.view_ then
            self.view_:performWithDelay(handler(self, self.getMatchPlayerCountData), 2)
        end
        
    end) 
end

-- 设置当前视图
function HallController:setDisplayView(view)
    self.view_ = view
end

-- 获取背景缩放系数
function HallController:getBgScale()
    return self.scene_:getBgScale()
end

-- 获取动画时间
function HallController:getAnimTime()
    return HallController.ANIM_TIME
end

-- 清理实例
function HallController:dispose()
    -- 移除请求
    nk.http.cancel(self.playerCountRequestId_)
    nk.http.cancel(self.matchPlayerCountRequestId_)
    if self.requestMatchInfoId_ then
        nk.http.cancel(self.requestMatchInfoId_)
        self.requestMatchInfoId_ = nil
    end

    if self.timeMatchPlayerCountRequestId_ then
        nk.http.cancel(self.timeMatchPlayerCountRequestId_)
        self.timeMatchPlayerCountRequestId_ = nil
    end

    -- if self.schedulerPool then
    --     self.schedulerPool:clearAll()
    -- end

    -- 移除事件
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_OK_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_DOUBLE_LOGINUCC_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_ONLINE_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_ROOM_OK_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_ROOM_FAIL_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_ERROR_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.HALL_LOGOUT_SUCC_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.ENTER_ROOM_WITH_DATA_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_GET_PERSONAL_ROOM_LIST_EVENT_TAG)
    -- bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_PERSONAL_ROOM_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_SEARCH_PERSONAL_ROOM_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_COMMON_BROADCAST_TAG)

    bm.EventCenter:removeEventListenersByTag(HallController.ENTER_MATCH_WITH_DATA_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.ENTER_GRAB_WITH_DATA_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_OK_NEW_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_MATCH_ROOM_OK_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_MATCH_ROOM_FAIL_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_GRAB_ROOM_OK_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_GRAB_DELAER_ROOM_FAIL_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_OK_RE_CONECT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_GRAB_ROOM_LIST_RESULT_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_SUONA_BROADCAST_RECV_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_PUSH_MATCH_ROOM_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_TIME_MATCH_OFF_TAG)
    bm.EventCenter:removeEventListenersByTag(HallController.SVR_LOGIN_NEW_ROOM_OK_EVENT_TAG)
    self:unbindDataObservers_()

    self.suonaMsgQueue_ = nil
    self.schedulerPool_:clearAll()
end

function HallController:cancelLoginAndClearCache()
    -- body
    if self.loginWithFBId_ then
        --todo
        nk.http.cancel(self.loginWithFBId_)
    end

    if self.loginWithGuestId_ then
        --todo
        nk.http.cancel(self.loginWithGuestId_)
    end

    nk.clearLoginCache()
    self.isLoginInProgress_ = false
    self.view_:playLoginFailAnim()

    -- self:checkAutoLogin()
end

-- 显示登陆奖励
function HallController:showLoginReward()
    -- hacode
    if nk.TestUtil.simuLogrinRewardJust then
        nk.TestUtil.simuLoginReward()
    end
    -- GucuRecallRewardPopup Here--
    if nk.userData.recallAward then
        --todo
        if self.view_ and self.view_.popGucuRecallReward then
            --todo
            self.view_:popGucuRecallReward()
        end
    end

    if nk.userData.loginReward and nk.userData.loginReward.ret == 1 then

        -- dump(nk.userData.popad, "nk.userData.popad :==============")
        local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
        if userLevelFact >= 2 and nk.userData.popad then
            --todo
            if self.view_ and self.view_.popAdPromot then
                --todo
                self.view_:popAdPromot()

                nk.DReport:report({id = "openPopAd"})
            end      
        end
        display.addSpriteFrames("loginreward_texture.plist", "loginreward_texture.png", handler(self, self.onLoadLgTextureComplete))
    end
end


function HallController:onLoginRewardViewCallback(data)
    if data then
        if "action_close" == data.action then
            if nk.OnOff:check("ticketTrans") then
                self.requestMatchInfoId_ = nk.http.matchHallInfo(function(data)
                    self.requestMatchInfoId_ = nil
                    nk.userData["match.point"] = checkint(data.point)
                    
                    nk.userData["match.highPoint"] = checkint(data.highPoint)
                   
                    local tickets = data.tickets
                    for i=1,#tickets do
                        local item = tickets[i]
                        local tickKey = "match.ticket_" .. item.pnid
                        nk.userData[tickKey] = checkint(item.pcnter)
                    end

                    --通用门票大于0,弹转换框
                    if checkint(nk.userData["match.ticket_7104"]) > 0 then
                        TicketTransferPopup.new():show()
                    end

                end,function(errData)
                    self.requestMatchInfoId_ = nil
                end)
            end
            
        end
    end
end

function HallController:onLoadLgTextureComplete(str, texture)
    LoginRewardView.new():show_(handler(self,self.onLoginRewardViewCallback))
end

-- get message
function HallController:onGetMessage()
    MessageData.new()
end

function HallController:reportLoginResult_(loginType, code, detail)
     if device.platform == "android" or device.platform == "ios" then
         local eventName
         if loginType == "FACEBOOK" then
             eventName = "login_result_facebook"
         elseif loginType == "GUEST" then
             eventName = "login_result_guest"
         end
         -- if eventName then
         --    cc.analytics:doCommand{
         --        command = "event",
         --        args = {
         --            eventId = eventName,
         --            label = "[" .. code .. "]" .. detail,
         --        },
         --    }
        -- end
    end
end

function HallController:updateOnline()
    nk.http.getOnlineNumber(function(retData) 
        nk.userData.USER_ONLINE = retData.number
    end,function() end)
end

function HallController:updateUserMaxDiscount()
    local userData = nk.userData
    if not userData then return end

    local requestMaxDiscount
    local maxretry = 4
    requestMaxDiscount = function()
        bm.HttpService.POST({
                mod="payCenter",
                act="getMaxDiscount",
            },
            function(retData)
                local retJson = json.decode(retData)
                if retJson and retJson.ret == 0 then
                    userData.__user_discount = tonumber(retJson.discount) or 1
                else
                    maxretry = maxretry - 1
                    if maxretry > 0 then
                        requestMaxDiscount()
                    end
                end
            end,
            function()
                maxretry = maxretry - 1
                if maxretry > 0 then
                    requestMaxDiscount()
                end
            end)
    end
    requestMaxDiscount()
end

function HallController:umengEnterHallTimeUsage()
    if device.platform ~= "android" and device.platform ~= "ios" then
        return
    end

    local g = global_statistics_for_umeng

    -- 一次进程启动只算作一次
    if g.first_enter_hall_checked then return end

    g.first_enter_hall_checked = true

    local delta = math.abs(os.difftime(os.time(), g.run_main_timestamp))

    -- 60秒以上的,只统计为60秒
    if delta > 60 then delta = 60 end

    -- cc.analytics:doCommand {
    --     command = 'eventCustom',
    --     args = {
    --         eventId    = 'boot_to_hall_time_usage',
    --         attributes = 'boot_time,' .. delta,
    --         counter    = 1, -- 自定义属性的数量, 默认为0
    --     },
    -- }
end


function HallController:umengUpdateTimeUsage()
    if device.platform ~= "android" and device.platform ~= "ios" then
        return
    end

    local g = global_statistics_for_umeng
    ------------------------------------------FirstApi-------------------------
    local firstCheckedFirstapi = g.first_update_checked_firstapi
    if not firstCheckedFirstapi then
        g.first_update_checked_firstapi = true
        local checkFirstApiInfo = g.update_check_info.firstApi
        ---- 重连次数内请求firstApi成功
        local succInLimitTime = false
        for i,v in pairs(checkFirstApiInfo) do
            if v.result == "success" then
                succInLimitTime = true
                --     cc.analytics:doCommand {
                --     command = 'eventCustom',
                --     args = {
                --         eventId    = 'check_update_firstApi_success',
                --         attributes = 'fail_times,' .. (i-1) .. "|success_times," .. (v.check or i) .. "|succ_" .. (v.check or i) .. "," .. (v.time or 0),
                --         counter    = 1,
                --     },
                -- }

                break
            else
                -- cc.analytics:doCommand {
                --     command = 'eventCustom',
                --     args = {
                --         eventId    = 'check_update_firstApi_success_2',
                --         attributes = 'fail_' .. (i-1) .. "," .. (v.time or 0),
                --         counter    = 1,
                --     }
                -- }
            end
        end

        -- 重连次数内请求firstApi不成功
        -- if not succInLimitTime then
        --             cc.analytics:doCommand {
        --             command = 'eventCustom',
        --             args = {
        --                 eventId    = 'check_update_firstApi_fail',
        --                 attributes = 'fail_time,' .. #checkFirstApiInfo,
        --                 counter    = 1,
        --             },
        --         }
        -- end
    end 
    ------------------------------------------FirstApi-------------------------

    ------------------------------------------Flist-------------------------
    local firstCheckedFlist = g.first_update_checked_flist
    if not firstCheckedFlist then
        g.first_update_checked_flist = true
        local checkFlistInfo = g.update_check_info.flist
        ---- 重连次数内请求firstApi成功
        local succInLimitTime1 = false
        for i,v in pairs(checkFlistInfo) do
            if v.result == "success" then
                succInLimitTime1 = true
                --     cc.analytics:doCommand {
                --     command = 'eventCustom',
                --     args = {
                --         eventId    = 'check_update_flist_success',
                --         attributes = 'fail_times,' .. (i-1) .. "|success_times," .. (v.check or i) .. "|succ_" .. (v.check or i) .. "," .. (v.time or 0),
                --         counter    = 1,
                --     },
                -- }

                break
            else
                -- cc.analytics:doCommand {
                
                --     command = 'eventCustom',
                --     args = {
                --         eventId    = 'check_update_flist_success',
                --         attributes = 'fail_' .. (i-1) .. "," .. (v.time or 0),
                --         counter    = 1,
                --     }
                -- }
            end
        end

        -- 重连次数内请求firstApi不成功
        -- if not succInLimitTime1 then
        --             cc.analytics:doCommand {
        --             command = 'eventCustom',
        --             args = {
        --                 eventId    = 'check_update_flist_fail',
        --                 attributes = 'fail_time,' .. #checkFlistInfo,
        --                 counter    = 1,
        --             },
        --         }
        -- end
    end
    ------------------------------------------Flist-------------------------
end

function HallController:umengLoginTimeUsage()
    if device.platform ~= "android" and device.platform ~= "ios" then
        return
    end

    local g = global_statistics_for_umeng
    local login_check_info = g.login_check_info
    local attributes = ""
    local result = login_check_info.result
    local time = login_check_info.time or 0
    if result == "success" then
        attributes = "success," .. time
    elseif result == "fail" then
         attributes = "fail," .. time
    end

    -- if attributes and (attributes ~= "") then
    --     cc.analytics:doCommand {
    --         command = 'eventCustom',
    --         args = {
    --             eventId    = 'check_login_info',
    --             attributes = attributes,
    --             counter    = 1, -- 自定义属性的数量, 默认为0
    --         },
    --     }


    --     -- dump(attributes,"umengLoginTimeUsage")
    -- end
end
return HallController