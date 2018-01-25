local logger = bm.Logger.new("AdScenePluginAndroid")

local TEST_URL = "http://api.adsunion.oa.com/"
local AdScenePluginAndroid = class("AdScenePluginAndroid")
local IS_TEST = false


function AdScenePluginAndroid:ctor()

	self.isSetupComplete_ = false
    self.isSetuping_ = false
    self.isSupported_ = false

	self.setupListener_ = handler(self,self.onSetupListener)
	self.loadAdDataListener_ = handler(self,self.onLoadAdDataListener)
	self.adShowListener_ = handler(self,self.onAdShowListener)
	self.adCloseListener_ = handler(self,self.onAdCloseListener)

	self:call_("setSetupCompleteListener",{self.setupListener_},"(I)V")
    self:call_("setLoadAdDataListener",{self.loadAdDataListener_},"(I)V")
    self:call_("setAdShowListener",{self.adShowListener_},"(I)V")
    self:call_("setAdCloseListener",{self.adCloseListener_},"(I)V")

    self:setup()
	
end

function AdScenePluginAndroid:setup(callback)
	self.setupCallback_ = callback
	dump("AdScenePluginAndroid_setup")
	local appid ="397072001439459143" --"981742001430280263"
    local appsec = "$2Y$10$DYVW/ERITNATVSAG9LKGYU3TD";--"$2Y$10$B2XJP.34BEKYX/IXUTJ7T./YE"
    local channelname = nk.Native:getChannelId()

    local testUrl = nil
    if IS_TEST then
    	--todo
    	testUrl = TEST_URL
    else
    	testUrl = ""
    end

    if (not self.isSetupComplete_) and (not self.isSetuping_) then
		self.isSetuping_ = true
		self:call_("setup",{appid,appsec,channelname, testUrl},"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
    end

    self:setCancelable(false)
end

--在登陆成功后并确认该用户是否展示广告后调用该方法加载广告数据,非游戏应用userid 可传空字符
function AdScenePluginAndroid:loadAdData(isShowAd,callback)
	self.loadAdDataCallback_ = callback
	isShowAd = isShowAd or false
	local userid = nk.userData["aUser.mid"]
	self:call_("loadAdData",{userid,isShowAd},"(Ljava/lang/String;Z)V")
end


function AdScenePluginAndroid:onAdShowListener(state)
	--广告框状态回调函数state :0 代表无广告不展示1.有广告广告正常显示
	dump(state,"AdScenePluginAndroid:onAdShowListener")
	if self.adShowCallback_ then
		self.adShowCallback_(tonumber(state))
	end
end


function AdScenePluginAndroid:onAdCloseListener(cType)
	--ctype -- 0:点击back键  1:点击弹框上的关闭按钮    2:点击空白区域
	dump(cType,"AdScenePluginAndroid:onAdCloseListener")
	if self.adCloseCallback_ then
		self.adCloseCallback_(tonumber(cType))
	end
end

-- adType -- 1:九宫格广告 2:插屏广告 7:海报广告 12:半圆广告
function AdScenePluginAndroid:onLoadAdDataListener(retJson)
	dump(retJson,"onLoadAdDataListener")
	local jsObj = json.decode(retJson)
	if jsObj then
		local isSuccess = (jsObj.isSuccess == "true")
		local adType = jsObj.adType
		local mes = jsObj.mes

		if self.loadAdDataCallback_ then
			self.loadAdDataCallback_(isSuccess,adType,mes)
		end
	end

end


function AdScenePluginAndroid:onSetupListener(retJson)
	self.isSetuping_ = false
	self.isSetupComplete_ = true
	local jsObj = json.decode(retJson)
	if jsObj then
		self.isSupported_ = (jsObj.isSupported == "true")
		if self.setupCallback_ then
			self.setupCallback_(self.isSupported_)
		end
	end
end



-- 插屏广告
--注：isFloat ：true 代表设置广告弹窗为系统弹出，显示在屏幕最上层
--				false 代表普通的广告弹窗
function AdScenePluginAndroid:showInterstitialAdDialog(isFloat,adShowCallback,adCloseCallback)
	self.adShowCallback_ = adShowCallback
	self.adCloseCallback_ = adCloseCallback
	self:call_("showInterstitialAdDialog",{isFloat},"(Z)V")
end

--悬浮窗
function AdScenePluginAndroid:setShowRecommendBar(isShow,adShowCallback,adCloseCallback)
	self.adShowCallback_ = adShowCallback
	self.adCloseCallback_ = adCloseCallback
	self:call_("setShowRecommendBar",{isShow},"(Z)V")
end

-- 九宫格广告 
-- isFloat ：true 代表设置广告弹窗为系统弹出，显示在屏幕最上层
	 	-- false 代表普通的广告弹窗
function AdScenePluginAndroid:setShowSudokuDialog(isFloat,adShowCallback,adCloseCallback)
	self.adShowCallback_ = adShowCallback
	self.adCloseCallback_ = adCloseCallback
	isFloat = (isFloat == nil) and true or isFloat
	self:call_("setShowSudokuDialog",{isFloat},"(Z)V")
	

end

--激励广告
function AdScenePluginAndroid:showRewardDialog(isFloat,adShowCallback,adCloseCallback)
	self.adShowCallback_ = adShowCallback
	self.adCloseCallback_ = adCloseCallback
	isFloat = (isFloat == nil) and true or isFloat
	self:call_("showRewardDialog",{isFloat},"(Z)V")
end

--设置弹框是否可被回退键取消
function AdScenePluginAndroid:setCancelable(cancelable)
	cancelable = cancelable or false
	self:call_("setCancelable",{cancelable},"(Z)V")
end


function AdScenePluginAndroid:cancelDialog()
	self:call_("cancelDialog",{cancelable},"()V")
end

-- 退出游戏相关缓存
function AdScenePluginAndroid:destroy()
	self:call_("destroy",{},"()V")
end



function AdScenePluginAndroid:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/boyaa/cocoslib/adscene/AdSceneBridge", javaMethodName, javaParams, javaMethodSig)
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


return AdScenePluginAndroid
