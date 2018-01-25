--
-- Author: viking@boomegg.com
-- Date: 2014-09-12 17:19:48
--

local DailyTask = class("DailyTask")

DailyTask.STATUS_UNDER_WAY = 0
DailyTask.STATUS_CAN_REWARD = 1
DailyTask.STATUS_FINISHED = 2

DailyTask.STATUS_BIG_VALUE = 100
DailyTask.ID_DAILY_SIGN_IN = 10000

function DailyTask:ctor()
    self.CDN_URL = nk.userData.CNDURL
end

function DailyTask:fromJSON(json)
    self.id = json.id
    self.name = json.name
    self.desc = json.desc 
    self.rewardDesc = json.rewardDesc
    if self.id ==  DailyTask.ID_DAILY_SIGN_IN then
        self.status = DailyTask.STATUS_BIG_VALUE
    else
        self.status = tonumber(json.status or DailyTask.STATUS_UNDER_WAY)
    end
    self.progress = json.progress

    self.target = tonumber(json.target)
    self.isSpecial = json.special
    self.iconUrl = json.iconUrl or ""
    self.tag = json.tag or 0
    self.sort = json.sort or 0
end

function DailyTask:endsWith(originString, endString)
    if originString then
        local len = string.len(endString)
        local str = string.sub(originString, -1, -len)
        if str == endString then
            return true
        end
    end
    return false
end

return DailyTask