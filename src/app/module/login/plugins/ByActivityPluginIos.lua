local channelInfo = import("channelConfig")
local ByActivityJumpManager = import("..ByActivityJump")

local ByActivityPluginIOS = class("ByActivityPluginIOS")

local ApiUrl_test = "http://192.168.204.68/operating/web/index.php?m=%s&p=%s&appid=%s&api=%s"
local ApiUrl_online = "http://mvlptlac01.boyaagame.com/?m=%s&p=%s&appid=%s&api=%s"
-- local isDebug = appconfig.VERSION_CHECK_URL == channelInfo.localServerUrl
local isDebug = false
local appid = 9605

function ByActivityPluginIOS:ctor()
    self.apiUrl_ = isDebug and ApiUrl_test or ApiUrl_online
    self.isSetupSucc_ = false
end

function ByActivityPluginIOS:setup(callback)
	-- dump("ByActivityPluginIOS:setup")
    local deviceInfo = nk.Native:getDeviceInfo()

    self.mid_ = nk.userData["aUser.mid"]
    self.sitemid_ = nk.userData["aUser.sitemid"]
    self.userType_ = nk.userData["aUser.lid"]
    self.version_ = nk.Native:getAppVersion()
    self.api_ = nk.userData["aUser.sid"]
    self.appid_ = appid
    self.deviceno_ = nk.Native:getIDFA() or ""
    self.osversion_ = deviceInfo.osVersion or ""
    self.networkstate_ = deviceInfo.networkType or ""

    self.isSetupSucc_ = true

    -- self.disTime_ = timeLimit or 2  -- 默认强推一天展示两次 Unused!
    self._jumpManager = ByActivityJumpManager.new()
    if callback then
        --todo
        callback()
    end
end

function ByActivityPluginIOS:getFullUrl(m,p,api)
    local appid = self.appid_
    return string.format(self.apiUrl_, m, p, appid, api)
end

-- Abandoned! --
function ByActivityPluginIOS:setJumpIndeedParam(view, controller)
    -- body
    self._view = view
    self._controller = controller
end
-- end --

function ByActivityPluginIOS:onByActivityActionListener(jsonStr)
	
    local jsonObj = json.decode(jsonStr)
    if jsonObj then

        if self.displayCallback_ then
            self.displayCallback_(jsonObj)
            self.displayCallback_ = nil
        end
        self._jumpManager:doJump(jsonObj)

        self:disposeWebView()
    end   
end

--退出活动界面时候调用
function ByActivityPluginIOS:onByActivityCloseListener(str)

    if self.closeCallBack_ then
        self.closeCallBack_(str)
        self.closeCallBack_ = nil
    end

    self.getUserinfoRequestId_ = nk.http.getMemberInfo(nk.userData["aUser.mid"], function(retData)
        self.getUserinfoRequestId_ = nil
        nk.userData["aUser.money"] = retData.aUser.money or nk.userData["aUser.money"] or 0
        nk.userData["aUser.gift"] = retData.aUser.gift or nk.userData["aUser.gift"] or 0
        nk.userData["aUser.mlevel"] = retData.aUser.mlevel or nk.userData["aUser.mlevel"] or 1
        nk.userData["aUser.exp"] = retData.aUser.exp or nk.userData["aUser.exp"] or 0

        nk.userData["aBest.maxmoney"] = retData.aBest.maxmoney or nk.userData["aBest.maxmoney"] or 0
        nk.userData["aBest.maxwmoney"] = retData.aBest.maxwmoney or nk.userData["aBest.maxwmoney"] or 0
        nk.userData["aBest.maxwcard"] = retData.aBest.maxwcard or nk.userData["aBest.maxwcard"] or 0
        nk.userData["aBest.rankMoney"] = retData.aBest.rankMoney or nk.userData["aBest.rankMoney"] or 0

        nk.userData["match"] = retData.match
        nk.userData['match.point'] = retData.match.point
        nk.userData['match.highPoint'] = retData.match.highPoint
    end, function(errData)
        -- nk.http.cancel(self.getUserinfoRequestId_)
        self.getUserinfoRequestId_ = nil
        dump(errData, "getMemberInfo.errData :=========================")        
    end)
end

function ByActivityPluginIOS:disposeWebView()
    if self.webView_ then
        self.webView_:removeFromParent()
        self.webView_ = nil
    end
    self:onByActivityCloseListener(nil)
end

function ByActivityPluginIOS:getBaseParams()
    local tb = {}
    tb.mid = self.mid_
    tb.version = self.version_
    tb.sid = self.userType_
    tb.api = self.api_
    tb.osversion = self.osversion_
    tb.appid = ""
    tb.sitemid = self.sitemid_
    tb.networkstate = self.networkstate_
    tb.deviceno = self.deviceno_

    return tb
end

--展示活动
function ByActivityPluginIOS:display(displayCallback, closeCallBack)
    self.displayCallback_ = displayCallback
    self.closeCallBack_ = closeCallBack

    if self.isSetupSucc_ then
        local params = self:getBaseParams()
        -- dump(params, "ByActivityPluginIOS:display.param :================")

        self.webView_ = ccexp.WebView:create()
        self.webView_:size(display.width, display.height)
        self.webView_:addTo(nk.runningScene, 999)
        self.webView_:setScalesPageToFit(true)
        self.webView_:pos(display.cx, display.cy)
        self.webView_:setBackgroundColor(0, 0, 0, 0)

        local bgScale = nil
        if display.width > 1140 and display.height == 640 then
            bgScale = display.width / 1140
        elseif display.width == 960 and display.height > 640 then
            bgScale = display.height / 640
        else
            bgScale = 1
        end

        local webViewBg = display.newSprite("activity_bg.jpg")
            :scale(bgScale)
            :addTo(self.webView_)
            :pos(display.cx, display.cy)

        self.openWebviewLoading_ = nk.ui.Juhua.new()
            :addTo(self.webView_)
            :pos(display.cx, display.cy)
            :show()

        self.webView_:setOnShouldStartLoading(function(sender, url)
            -- dump(url,"onWebViewShouldStartLoading, url is ")

            local orgUrl = string.urldecode(url)
            -- dump(orgUrl,"orgUrl :=================")

            if orgUrl and orgUrl ~= "" then
                local gmatchFun = string.gmatch(orgUrl,"%b{}")
                local jumpStr = nil
                if gmatchFun then
                    for str in gmatchFun do 
                        local target = string.match(str,"target")
                        local desc = string.match(str,"desc")
                        if target then
                            jumpStr = str
                            if jumpStr and jumpStr ~= "" then
                                -- local jumpObj = json.decode(jumpStr)
                                self:onByActivityActionListener(jumpStr)
                                -- dump(jumpStr,"jumpStr :=================")

                                return false
                            end

                            break
                        end
                    end
                end                
            end

            return true
        end)

        self.webView_:setOnDidFinishLoading(function(sender, url)
            -- dump(url,"onWebViewDidFinishLoading, url is ")
            if self.openWebviewLoading_ then
                self.openWebviewLoading_:hide()
            end
            nk.DReport:report({id = "actCenterDisplaySucc"})
        end)

        self.webView_:setOnDidFailLoading(function(sender, url)
            -- dump(url,"onWebViewDidFinishLoading, url is ")
            -- dump("webView loading Fail!")
            if self.openWebviewLoading_ then
                self.openWebviewLoading_:hide()
            end
        end)

        local webUrl = self:getFullUrl("activities","index", string.urlencode(json.encode(params)))

        -- dump(webUrl,"ByActivityPluginIOS:display-webUrl :===================")
        self.webView_:loadURL(webUrl)
    else
        dump("SDK incorrect return in setup!")
    end
	
end

--强推 @param size: 0:小(0.6) 1:中(0.8)  2:大(0.9)
function ByActivityPluginIOS:displayForce(size, displayCallback, closeCallBack)

    -- do return end
    self.displayCallback_ = displayCallback
    self.closeCallBack_ = closeCallBack

   if self.isSetupSucc_ then
        --todo
        self:showForceDisplayView(size)
    else
        dump("SDK incorrect return in setup!")
    end 
end

function ByActivityPluginIOS:showForceDisplayView(size)
    -- body
    local size = size or 1

    local getWebViewSizeScale = {
        [0] = function()
            -- body
            return 0.6
        end,

        [1] = function()
            -- body
            return 0.8
        end,

        [2] = function()
            -- body
            return 0.9
        end
    }

    local sizeScale = nil

    if getWebViewSizeScale[size] then
        --todo
        sizeScale = getWebViewSizeScale[size]()
    else
        sizeScale = getWebViewSizeScale[1]()
    end

    local param = self:getBaseParams()

    local urlTest = "http://192.168.204.68/operating/web/index.php?m=%s&p=%s&appid=%s&newapi=%s"
    local urlReal = "http://mvlptlac01.boyaagame.com/?m=%s&p=%s&appid=%s&newapi=%s"
    local urlChose = isDebug and urlTest or urlReal

    local urlApply = string.format(urlChose, "activities", "actrelated", appid, string.urlencode(json.encode(param)))

    -- dump(urlApply, "getForceDisplayData.url :=====================")
    self.reqGetForceDisplayDataId_ = nk.http.post_url(urlApply, {}, function(retData)
        -- body
        self.reqGetForceDisplayDataId_ = nil
        -- dump(retData, "getForceDisplayData.retData :===================")

        local jsonInfo = json.decode(retData)

        local addrSuffix = jsonInfo.act_push.act
        local actPushUrl = jsonInfo.act_push.url

        local displayTimeLimit = checkint(jsonInfo.act_push.rate or 3) -- 每日展示次数限制

        if actPushUrl then
            --todo

            local actPushLastDisplayDay = nk.userDefault:getStringForKey(nk.cookieKeys.ACT_PUSH_DISRECORDDAY)
            local dayNow = os.date("%Y%m%d")

            local actPushDisplayTimes = nk.userDefault:getIntegerForKey(nk.cookieKeys.ACT_PUSH_DISTIME, 0)

            local pushUrlSplice = actPushUrl .. "&appid=%s&newapi=%s"
            local pushUrlApply = string.format(pushUrlSplice, appid, string.urlencode(json.encode(param))) .. addrSuffix

            -- dump(pushUrlApply, "act_pushContentUrl :====================")

            if string.len(actPushLastDisplayDay) <= 0 or actPushLastDisplayDay ~= dayNow then
                --todo
                self:loadActWebPage(pushUrlApply, sizeScale)

                nk.userDefault:setStringForKey(nk.cookieKeys.ACT_PUSH_DISRECORDDAY, dayNow)
                nk.userDefault:setIntegerForKey(nk.cookieKeys.ACT_PUSH_DISTIME, 1)
            else
                if actPushDisplayTimes < displayTimeLimit then
                    --todo
                    self:loadActWebPage(pushUrlApply, sizeScale)

                    nk.userDefault:setIntegerForKey(nk.cookieKeys.ACT_PUSH_DISTIME, actPushDisplayTimes + 1)
                else
                    dump("ActPush Time Limit,Not Display!")
                end
            end
        else
            dump("No Act_push Msg!")
        end
    end, function(errData)
        -- body
        self.reqGetForceDisplayDataId_ = nil
        dump(errData, "getForceDisplayData.errData: ===================")
    end)
end

function ByActivityPluginIOS:loadActWebPage(url, scale)
    -- body
    self.webView_ = ccexp.WebView:create()
    self.webView_:size(display.width * scale, display.height * scale)
    self.webView_:addTo(nk.runningScene, 999)
    self.webView_:setScalesPageToFit(true)
    self.webView_:pos(display.cx, display.cy)
    self.webView_:setBackgroundColor(0, 0, 0, 0)

    local background = display.newScale9Sprite("#modal_texture.png", 0, 0,
        cc.size(display.width, display.height))
        :addTo(self.webView_)

    background:setTouchEnabled(true)
    background:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onBackgroundTouch_))

    local webViewBg = display.newSprite("activity_bg.jpg")
    local bgSize = webViewBg:getContentSize()

    webViewBg:setScaleX((display.width * scale)/ bgSize.width)
    webViewBg:setScaleY((display.height * scale)/ bgSize.height)
    webViewBg:addTo(self.webView_)
        :pos(display.cx, display.cy)

    self.openWebviewLoading_ = nk.ui.Juhua.new()
        :addTo(self.webView_)
        :pos(display.cx, display.cy)
        :show()

    self.webView_:setOnShouldStartLoading(function(sender, url)
        -- body
        -- dump(url, "startLoading.url :=================")
        local orgUrl = string.urldecode(url)
        -- dump(orgUrl,"orgUrl :=================")

        if orgUrl and orgUrl ~= "" then
            local gmatchFun = string.gmatch(orgUrl,"%b{}")
            local jumpStr = nil
            if gmatchFun then
                for str in gmatchFun do 
                    local target = string.match(str,"target")
                    local desc = string.match(str,"desc")
                    if target then
                        jumpStr = str
                        if jumpStr and jumpStr ~= "" then
                            -- dump(jumpStr,"jumpStr :==============")
                            self:onByActivityActionListener(jumpStr)
                            return false
                        end
                        break
                    end
                end
            end                
        end

        return true
    end)

    self.webView_:setOnDidFinishLoading(function(sender, url)
        -- body
        -- dump(url, "finishLoading.url :====================")
        if self.openWebviewLoading_ then
            self.openWebviewLoading_:hide()
        end
        nk.DReport:report({id = "actCenterDisplaySucc"})
    end)

    self.webView_:setOnDidFailLoading(function(sender, url)
        -- body
        -- dump(url, "FailLoading.url :================")

        if self.openWebviewLoading_ then
            self.openWebviewLoading_:hide()
        end
    end)

    self.webView_:loadURL(url)
end

function ByActivityPluginIOS:onBackgroundTouch_(evt)
    -- body
    self:disposeWebView()
end

-- @param serverId: 1代表测试服务器，0代表正式服务器，传其他的值没有用的哦
function ByActivityPluginIOS:switchServer(serverId)
    -- body
    dump("switchServer to server :" .. serverId)
    isDebug = serverId == 1
end

-- Unused! --
function ByActivityPluginIOS:setWebViewTimeOut(timeOut)
    -- body
    dump("setWebViewTimeOut.timeOut :" .. timeOut)
end

-- Unused! --
function ByActivityPluginIOS:setWebViewCloseTip(closeTip)
    -- body
    dump("setWebViewCloseTip.closeTip :" .. closeTip)
end

-- Unused! --
function ByActivityPluginIOS:setNetWorkBadTip(badNetTip)
    -- body
    dump("setNetWorkBadTip.badNetTip :" .. badNetTip)
end

-- Unused! --
function ByActivityPluginIOS:setAnimIn(animId)
    -- body
    dump("setNetWorkBadTip.setAnimIn :" .. animId)
end

-- Unused! --
function ByActivityPluginIOS:setAnimOut(animId)
    -- body
    dump("setAnimOut.animId :" .. animId)
end

-- Unused! --
function ByActivityPluginIOS:setCloseType(isClickOnceToClose)
    -- body
    dump("setCloseType.isClickOnceToClose :" .. tostring(isClickOnceToClose))
end

-- Unused! --
function ByActivityPluginIOS:dismiss(animId)
    -- body
    dump("dismiss.animId :" .. animId)
end

function ByActivityPluginIOS:clearRelatedCache()
    -- body
    nk.userDefault:setIntegerForKey(nk.cookieKeys.ACT_PUSH_DISTIME, 0)
    -- dump("ACT_PUSH_DISTIME :" .. nk.userDefault:getIntegerForKey(nk.cookieKeys.ACT_PUSH_DISTIME, - 1))
end

function ByActivityPluginIOS:getSetupState()
    -- body
    return self.isSetupSucc_
end

return ByActivityPluginIOS

