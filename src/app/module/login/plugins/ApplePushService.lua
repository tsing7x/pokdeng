--
-- Author: johnny@boomegg.com
-- Date: 2014-08-29 14:22:13
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local ApplePushService = class("ApplePushService")

function ApplePushService:ctor()
    -- to do
end

function ApplePushService:register(callback)
    local ok, pushToken = luaoc.callStaticMethod("LuaOCBridge", "getPushToken")
    if ok and callback and pushToken and pushToken ~= "" then
        pushToken = string.gsub(pushToken, " ", "")
        pushToken = string.gsub(pushToken, "<", "")
        pushToken = string.gsub(pushToken, ">", "")
        callback(true, pushToken)
    end
end

return ApplePushService