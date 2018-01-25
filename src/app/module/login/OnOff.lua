-- 开关控制
-- Author: LeoLuo
-- Date: 2015-06-12 16:30:43
--


-- 先使用check()函数判断开关状态 ，
-- 如果是关闭状态再调用checkTip()获取对应开关的提示信息显示，如果为nil，则显示默认文本
local OnOff = class("OnOff")
local logger = bm.Logger.new("OnOff")

function OnOff:ctor()
	self.onoff_ = {}
    self.version_ = {}
    self.onOffTip_ = {}
end

function OnOff:init(retData)
    self.onoff_ = retData.open
    self.version_ = retData.version
    self.onOffTip_ = retData.opentips

end

-- isRawValue 是否返回原始值
function OnOff:check(name,isRawValue)
    local value = isset(self.onoff_, name) and tonumber(self.onoff_[name]) == 1
    if isRawValue then
        value = isset(self.onoff_, name) and tonumber(self.onoff_[name]) or nil
    end
    return value
end

function OnOff:checkTip(name)
    local tip = isset(self.onOffTip_, name) and (self.onOffTip_[name]) or nil
    return tip
end

-- Change key:name OnOff state --
-- @param name: OnOffKey, state :change to state, true On, false off
function OnOff:setOnOffState(name, state)
    -- body
    if isset(self.onoff_, name) then
        --todo
        if state then
            --todo
            self.onoff_[name] = 1
        else
            self.onoff_[name] = 0
        end
    else
        dump("key :" .. tostring(name) .. "Not Exist！")
    end
end

function OnOff:checkVersion(name, version)
    return isset(self.version_, name) and self.version_[name] == version
end

function OnOff:checkLocalVersion(name)
    local version = checkint(nk.userDefault:getStringForKey(nk.cookieKeys.CONFIG_VER.."_"..name, 0))
    return self:checkVersion(name, version)
end

function OnOff:saveNewVersionInLocal(name)
    nk.userDefault:setStringForKey(nk.cookieKeys.CONFIG_VER.."_"..name, 0)
end


function OnOff:checkReportError(name)
	return isset(self.onoff_, name) and checkint(self.onoff_[name]) == 1
end

return OnOff