
local logger = bm.Logger.new("ByActivityPluginAndroid")

local ByActivityJumpManager = import("..ByActivityJump")

local ByActivityPluginAndroid = class("ByActivityPluginAndroid")

function ByActivityPluginAndroid:ctor()

	dump("ByActivityPluginAndroid")
	self.byActivityListener_ = handler(self, self.onByActivityActionListener)
    self.byActivityCloseListener = handler(self,self.onByActivityCloseListener)
	self:call_("setByActivityCallback",{self.byActivityListener_},"(I)V")
    self:call_("setByActivityCloseCallback",{self.byActivityCloseListener},"(I)V")

    self._isSetupSucc = false
end

--该初始化接口在登录完成，nk.userData 赋值之后才调用
function ByActivityPluginAndroid:setup(callback)
	dump("ByActivityPluginAndroid:setup")
    local mid = nk.userData["aUser.mid"]
    local sitemid = nk.userData["aUser.sitemid"]
    local userType = nk.userData["aUser.lid"]
    local currentVersion = nk.Native:getAppVersion()
    local version = currentVersion
    local api = nk.userData["aUser.sid"] 
    local appid = "9605" --固定
    local deviceno = nk.Native:getIDFA() or ""

    -- 补充参数 --
    local apiUrl = "http://mvlptlac01.boyaagame.com"  -- 指定活动中心正式地址头部
    local key = "boyaa&&@9605"  -- 密钥<固定>
    local langIdx = 1 -- 设置展示语言, 0:中文; 1:泰语; 2:印尼
    local channelId = ""  --暂时留空

    local isDebugMode = false  -- 是否进入Debug模式打印更多信息以供调试

	self:call_("setup", {mid, sitemid, userType, version, api, appid, deviceno, apiUrl, key, channelId, langIdx, isDebugMode},
        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IZ)V")

    self._jumpManager = ByActivityJumpManager.new()
    self.setupSuccCallBack_ = callback
end

-- Abandoned! --
function ByActivityPluginAndroid:setJumpIndeedParam(view, controller)
    -- body
    self._view = view
    self._controller = controller
end
-- end --

function ByActivityPluginAndroid:onByActivityActionListener(jsonStr)
	-- jsonData.data1,jsonData.data2
    dump(jsonStr, "jsonStr :=============")
	local jsonData = json.decode(jsonStr)

    if jsonData.data1 then
        --todo
        local data1 = json.decode(jsonData.data1)
    end
    
    -- dump(data1, "data1 :=============")

    local data2 = nil

    if jsonData.data2 then
        --todo
        dump(jsonData.data2, "jsonData.data2 :==============")
        data2 = json.decode(jsonData.data2)
        
        -- "jsonData.data2: ============" = "{"target":"activityNumber","count":1}"
        if data2.target == "activityNumber" then
            --todo
            self._isSetupSucc = true

            if data2.count <= 0 then
                --todo
                dump("No Activities!")
            end

            if self.setupSuccCallBack_ then
                --todo
                self.setupSuccCallBack_(data2)
                self.setupSuccCallBack_ = nil
            end

            if self.displayCallback_ then
                self.displayCallback_(data2)
                self.displayCallback_ = nil
            end
        end
    end

    self._jumpManager:doJump(data2)
end

--退出活动界面时候调用
function ByActivityPluginAndroid:onByActivityCloseListener(str)

    if self.closeCallBack_ then
        self.closeCallBack_(str)
        self.closeCallBack_ = nil
    end

    self.getUserinfoRequestId_ = nk.http.getMemberInfo(nk.userData["aUser.mid"],
    function(retData)
        self.getUserinfoRequestId_ = nil
        -- nk.http.cancel(self.getUserinfoRequestId_)
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
    end,
    function(errData)
        dump(errData, "getMemberInfo.errData :====================")
        self.getUserinfoRequestId_ = nil
        -- nk.http.cancel(self.getUserinfoRequestId_)
    end)
end

--展示活动
function ByActivityPluginAndroid:display(displayCallback,closeCallBack)
    self.displayCallback_ = displayCallback
    self.closeCallBack_ = closeCallBack

    if self._isSetupSucc then
        --todo
        self:call_("display",{},"()V")

        nk.DReport:report({id = "actCenterDisplaySucc"})
    else
        dump("SDK incorrect return in setup!")
    end
	
end

--强推 @param size: 0:小 1:中  2:大
function ByActivityPluginAndroid:displayForce(size,displayCallback,closeCallBack)
    self.displayCallback_ = displayCallback
    self.closeCallBack_ = closeCallBack

   if self._isSetupSucc then
        --todo
        size = size or 0
        self:call_("displayForce",{size},"(I)V")

        nk.DReport:report({id = "actCenterDisplaySucc"})
    else
        dump("SDK incorrect return in setup!")
    end 

end

-- @param serverId: 1代表测试服务器，0代表正式服务器，传其他的值没有用的哦
function ByActivityPluginAndroid:switchServer(serverId)
    -- body
    local serverId = serverId or 0  -- 默认切换到正式服
    self:call_("switchServer", {serverId}, "(I)V")
end

function ByActivityPluginAndroid:setWebViewTimeOut(timeOut)
    -- body
    local time = timeOut or 2500
    self:call_("setWebViewTimeOut", {time}, "(I)V")
end

function ByActivityPluginAndroid:setWebViewCloseTip(closeTip)
    -- body
    self:call_("setWebViewCloseTip", {closeTip}, "(Ljava/lang/String;)V")
end

function ByActivityPluginAndroid:setNetWorkBadTip(badNetTip)
    -- body
    self:call_("setNetWorkBadTip", {badNetTip}, "(Ljava/lang/String;)V")
end

-- @param animId: 
    -- -1 不使用任何动画，直接显示
    -- 0 从左往右退出
    -- 1 从上往下退出
    -- 2 360°旋转
    -- 3 从右往左推进
    -- 4 从下往上推进
    -- 其次，还允许传入外部动画，比如外部的res/anim目录下，有动画 loading ，那么这里可以传入 R.anim.loading
    -- 更多动画正在扩展中，有好的建议可以 RTX： KillaXiao 你的提议就是我的动力~~
 
function ByActivityPluginAndroid:setAnimIn(animId)
    -- body
    self:call_("setAnimIn", {animId}, "(I)V")
end

-- @param animId: 
    -- -1 不使用任何动画，直接显示
    -- 0 从左往右退出
    -- 1 从上往下退出
    -- 2 360°旋转
    -- 3 从右往左推进
    -- 4 从下往上推进
    -- 其次，还允许传入外部动画，比如外部的res/anim目录下，有动画 loading ，那么这里可以传入 R.anim.loading
    -- 更多动画正在扩展中，有好的建议可以 RTX： KillaXiao 你的提议就是我的动力~~
    
function ByActivityPluginAndroid:setAnimOut(animId)
    -- body
    self:call_("setAnimOut", {animId}, "(I)V")
end

-- 设置是否点击一次关闭活动中心,默认为点击两次。
function ByActivityPluginAndroid:setCloseType(isClickOnceToClose)
    -- body
    self:call_("setCloseClickOnce", {isClickOnceToClose}, "(Z)V")
end

function ByActivityPluginAndroid:dismiss(animId)
    -- body
    -- 退出动画默认为1
    local animId = animId or 1
    self:call_("dismiss", {animId}, "(I)V")
end

-- 清除展示次数记录缓存
function ByActivityPluginAndroid:clearRelatedCache()
    -- body
    self:call_("clearCache", {}, "()V")
end

function ByActivityPluginAndroid:getSetupState()
    -- body
    return self._isSetupSucc
end

function ByActivityPluginAndroid:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/boyaa/cocoslib/byactivity/ByActivityBridge", javaMethodName, javaParams, javaMethodSig)
        if not ok then
            if ret == -1 then
                logger:errorf("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
            elseif ret == -2 then
                logger:errorf("call %s failed, -2 无效的签名", javaMethodName)
            elseif ret == -3 then
                logger:errorf("call %s failed, -3 没有找到指定的方法", javaMethodName)
            elseif ret == -4 then
                logger:errorf("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
            elseif ret == -5 then
                logger:errorf("call %s failed, -5 Java 虚拟机出错", javaMethodName)
            elseif ret == -6 then
                logger:errorf("call %s failed, -6 Java 虚拟机出错", javaMethodName)
            end
        end
        return ok, ret
    else
        logger:debugf("call %s failed, not in android platform", javaMethodName)
        return false, nil
    end
end

return ByActivityPluginAndroid

