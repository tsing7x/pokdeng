--
-- Author: tony
-- Date: 2014-07-28 11:34:41
--

local LuaJavaBridge = class("LuaJavaBridge")
local logger = bm.Logger.new("LuaJavaBridge")

function LuaJavaBridge:ctor()
end

function LuaJavaBridge:call_(javaClassName, javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
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

function LuaJavaBridge:getMac()
    local ok, ret = self:call_("com/boyaa/cocoslib/core/functions/GetMacFunction", "apply", {}, "()Ljava/lang/String;")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:getMacAddr()
    local ok, ret = self:call_("com/boyaa/cocoslib/core/functions/GetMacFunction", "getMacAddr", {}, "()Ljava/lang/String;")
    if ok then
        return ret
    end
    return nil
end

function LuaJavaBridge:vibrate(time)
    self:call_("com/boyaa/cocoslib/core/functions/VibrateFunction", "apply", {time}, "(I)V")
end

function LuaJavaBridge:getFixedWidthText(font, size, text, width)
    local ok, ret = self:call_("com/boyaa/cocoslib/core/functions/GetFixedWidthTextFunction", "apply", {font or "", size or 20, text or "", width or device.display.widthInPixels}, "(Ljava/lang/String;ILjava/lang/String;I)Ljava/lang/String;")
    if ok then
        return ret or ""
    end
    return ""
end

function LuaJavaBridge:pickImage(callback)
    self:call_("com/boyaa/cocoslib/core/functions/PickImageFunction", "apply", {function(result)
            logger:debug("pickImage result:", result)
            if callback then
                if result == "nosdcard" then
                    callback(false, "nosdcard")
                elseif result == "error" then
                    callback(false, "error")
                else
                    callback(true, result)
                end
            end
        end}, "(I)V")
end

function LuaJavaBridge:pickupPic(callback)
    self:call_("com/boyaa/cocoslib/core/functions/PickupPicFunction", "apply", {function(result)
            logger:debug("pickupPic result:", result)
            if callback then
                if result == "nosdcard" then
                    callback(false, "nosdcard")
                elseif result == "error" then
                    callback(false, "error")
                else
                    callback(true, result)
                end
            end
        end}, "(I)V")
end


function LuaJavaBridge:getIDFA()
    local deviceInfo = self:getDeviceInfo()
    return deviceInfo.deviceId or self:getMacAddr() or 'android_idfa_nil'
end


function LuaJavaBridge:getAppVersion()
    local ok, ret = self:call_("com/boyaa/cocoslib/core/functions/GetAppVersionFunction", "apply", {}, "()Ljava/lang/String;")
    if ok then
        return ret or ""
    end
    return ""
end

function LuaJavaBridge:getAppBundleId()
    local ok, ret = self:call_("com/boyaa/cocoslib/core/functions/GetAppVersionFunction", "apply", {}, "()Ljava/lang/String;")
    if ok then
        return ret or ""
    end
    return ""
end

function LuaJavaBridge:getDeviceInfo()
    local deviceInfo = {deviceId = "", deviceName = "", deviceModel = "", installInfo = "", cpuInfo = "", ramSize = "", simNum = "", networkType = "",location = ""}
    local ok, ret = self:call_("com/boyaa/cocoslib/core/functions/GetDeviceInfoFunction", "apply", {}, "()Ljava/lang/String;")
    if ok and ret ~= "" then
        deviceInfo = json.decode(ret)
    end
    return deviceInfo
end

-- 拨打电话
function LuaJavaBridge:makePhoneCall(phoneNum)
    -- body
    self:call_("com/boyaa/cocoslib/core/functions/MakePhoneCallFunction", "apply", {phoneNum}, "(Ljava/lang/String;)V")
end

--content:发送的内容
--to:发送的号码
--isSys:是否调用系统短信界面,默认调用系统短信界面
function LuaJavaBridge:sendSms(content,to,isSys)
    to = to or ""
    content = content or ""
    if isSys == nil then
        isSys = true
    end

    if isSys then
        self:call_("com/boyaa/cocoslib/core/functions/SMSFunction", "doSendSMSTo", {content,to}, "(Ljava/lang/String;Ljava/lang/String;)V")
    else
        self:call_("com/boyaa/cocoslib/core/functions/SMSFunction", "sendSMS", {content,to}, "(Ljava/lang/String;Ljava/lang/String;)V")

    end
    
end

function LuaJavaBridge:showEmailView(subject, content)
    self:call_("com/boyaa/cocoslib/core/functions/ShowEmailViewFunction", "apply", {subject,content}, "(Ljava/lang/String;Ljava/lang/String;)V")
end

function LuaJavaBridge:getLoginToken()
    return crypto.encodeBase64(self:getMac() .. "_pokdengboyaa")
end
-- 粘贴到剪贴板
function LuaJavaBridge:setClipboardText(content)
    self:call_("com/boyaa/cocoslib/core/functions/ClipboardManagerFunction", "apply", {content}, "(Ljava/lang/String;)V")
end
function LuaJavaBridge:getChannelId()
    local ok, ret = self:call_("com/boyaa/cocoslib/core/functions/GetChannelIdFunction", "apply", {}, "()Ljava/lang/String;")
    if ok then
        return ret or "GooglePlay"
    end
    return "GooglePlay"
end


function LuaJavaBridge:isAppInstalled(packageName)
    packageName = packageName or ""
    local ok, ret = self:call_("com/boyaa/cocoslib/core/functions/GetPackageInfoFunction", "isAppInstalled", {packageName}, "(Ljava/lang/String;)Ljava/lang/String;")
    if ok then
        if not ret or ret == "" then
            return false,nil
        end
        -- flag: 是否安装查询的应用
        --firstInstallTime: 初次安装时间
        --lastUpdateTime: 最近更新应用时间
        local packInfo = json.decode(ret);
        if not packInfo then
            return false,nil
        end
        return (packInfo.flag == "true" and true or false),packInfo
    

    end
    return false,nil
    
end

-- 返回值
-- nil:未安装 
-- true:成功调用方法
-- false:未成功调用方法
function LuaJavaBridge:launchApp(packageName)
    packageName = packageName or ""
    local isAppInstalled = self:isAppInstalled(packageName)

    if not isAppInstalled then
        return nil
    end

    local ok, ret = self:call_("com/boyaa/cocoslib/core/functions/GetPackageInfoFunction", "launchApp", {packageName}, "(Ljava/lang/String;)V")
    return ok
end

return LuaJavaBridge