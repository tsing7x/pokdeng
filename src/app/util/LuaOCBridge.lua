--
-- Author: johnny@boomegg.com
-- Date: 2014-07-30 16:17:52
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local LuaOCBridge = class("LuaOCBridge")
local logger = bm.Logger.new("LuaOCBridge")

function LuaOCBridge:ctor()
end

function LuaOCBridge:vibrate(time)
    cc.Native:vibrate()
end

function LuaOCBridge:sendSms(content,to,isSys)
    content = content or ""
    to = to or ""
    luaoc.callStaticMethod("LuaOCBridge", "showSMSView", {
        content = content,
        to = to,
        cannotCallback = handler(self, self.cannotShowSMSView_)
    })
end


function LuaOCBridge:getIDFA()
    local ok, r = luaoc.callStaticMethod("LuaOCBridge", "getiOSIDFA", nil)
    return ok and r or 'getiOSIDFA_nil'
end

function LuaOCBridge:cannotShowSMSView_()
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("FRIEND", "CANNOT_SEND_SMS"),
        secondBtnText = bm.LangUtil.getText("COMMON", "CONFIRM")
    })
        :show()
end

function LuaOCBridge:showEmailView(subject, content)
    luaoc.callStaticMethod("LuaOCBridge", "showMAILView", {
        subject = subject,
        content = content,
        cannotCallback = handler(self, self.cannotShowMAILView_)
    })
end

function LuaOCBridge:cannotShowMAILView_()
    nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("FRIEND", "CANNOT_SEND_MAIL"),
        firstBtnText = bm.LangUtil.getText("COMMON", "CANCEL"),
        secondBtnText = bm.LangUtil.getText("COMMON", "CONFIRM"),
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                cc.Native:openURL("mailto:")
            end
        end
    })
        :show()
end

function LuaOCBridge:pickImage(callback)
    self.pickImageCallback_ = callback
    luaoc.callStaticMethod("LuaOCBridge", "showImagePicker", {pickedImageCallback = handler(self, self.onPickedImage_)})
end

function LuaOCBridge:onPickedImage_(imagePath)
    logger:debugf("imagePath: %s", imagePath)
    if self.pickImageCallback_ then
        if imagePath and imagePath ~= "" then
            self.pickImageCallback_(true, imagePath)
        else
            self.pickImageCallback_(false, imagePath)
        end
    end
end

function LuaOCBridge:pickupPic(callback)
    self.pickupPicCallback_ = callback
    luaoc.callStaticMethod("LuaOCBridge", "pickupPic", {pickedImageCallback = handler(self, self.onPickupPic_)})
end

function LuaOCBridge:onPickupPic_(imagePath)
    logger:debugf("imagePath: %s", imagePath)
    if self.pickupPicCallback_ then
        if imagePath and imagePath ~= "" then
            self.pickupPicCallback_(true, imagePath)
        else
            self.pickupPicCallback_(false, "")
        end
    end
end

function LuaOCBridge:getFixedWidthText(fontName, fontSize, text, fixedWidth)
    local ok, fixedString = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getFixedWidthText",
        {
            text = text,
            fixedWidth = fixedWidth,
            fontName = fontName,
            fontSize = fontSize,
        }
    )
    if ok then
        return fixedString
    else
        return text
    end
end

function LuaOCBridge:getLoginToken()
    local openUdid = nk.userDefault:getStringForKey("OPEN_UDID")
    if not openUdid or openUdid == "" then
        openUdid = device.getOpenUDID()
        nk.userDefault:setStringForKey("OPEN_UDID", openUdid)
        nk.userDefault:flush()
    end
    local is_dev = false
    if is_dev then
        return crypto.encodeBase64("C6:6A:B7:61:7E:C7".."_pokdengboyaa")
    else
        return crypto.encodeBase64(openUdid .. "_pokdengboyaa")
    end
end

function LuaOCBridge:getAppVersion()
    local ok, version = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getAppVersion", nil)
    if ok then
        return version
    else
        return "1.0.0"
    end
end

function LuaOCBridge:getAppBundleId()
    local ok, bundleId = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getAppBundleId", nil)
    if ok then
        return bundleId
    else
        return ""
    end
end

function LuaOCBridge:getChannelId()
    return "AppStore"
end

function LuaOCBridge:getDeviceInfo()
    local ok, deviceInfo = luaoc.callStaticMethod(
        "LuaOCBridge",
        "getDeviceInfo", nil)
    if ok then
        return json.decode(deviceInfo)
    else
        return {}
    end
end

function LuaOCBridge:getMacAddr()
    return nil
end


function LuaOCBridge:isAppInstalled(packageName)
    packageName = packageName or ""
    --暂无需求，return false
    return false,nil
end



function LuaOCBridge:setClipboardText(content)
    content = content or ""
    luaoc.callStaticMethod("LuaOCBridge", "setClipboardText", {
        content = content
    })
end

return LuaOCBridge
