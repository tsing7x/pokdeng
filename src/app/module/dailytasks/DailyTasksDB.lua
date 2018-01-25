--
-- Author: viking@boomegg.com
-- Date: 2014-09-12 15:37:17
--

local DailyTasksDB = class("DailyTasksDB")

function DailyTasksDB:ctor(uid)
    -- body
end

function DailyTasksDB:readFromDB(taskProgressMap)
    local uidDateKey = "RECORD_DATE"
    local todayString = os.date("%Y%m%d")
    local recordDate = self:readString(uidDateKey)
    if todayString == recordDate then
        print("readFromDB:", todayString, recordDate)
        for k,v in pairs(taskProgressMap) do
            print("readFromDB",k, v)
            taskProgressMap[k] = self:readInt(k)
        end
    else
        self:saveToDB(taskProgressMap, uidDateKey, todayString)
    end
end

function DailyTasksDB:saveToDB(taskProgressMap, uidDateKey, todayString)
    self:writeString(uidDateKey, todayString)
    print("saveToDB")
    for k,v in pairs(taskProgressMap) do
        print("saveToDB",k, v)
        self:writeInt(k, 0)
    end
end

function DailyTasksDB:update(key, value)
    print("update", key, value)
    self:writeInt(key, value)
end

function DailyTasksDB:readInt(key)
    key = tostring(nk.userData.uid) .. key
    return cc.UserDefault:getInstance():getIntegerForKey(key, 0)
end

function DailyTasksDB:writeInt(key, value)
    key = tostring(nk.userData.uid) .. key
    if key ~= nil and value ~= nil then
        cc.UserDefault:getInstance():setIntegerForKey(key, value)
        cc.UserDefault:getInstance():flush()
    end
end

function DailyTasksDB:readString(key)
    key = tostring(nk.userData.uid) .. key
    return cc.UserDefault:getInstance():getStringForKey(key, "")
end

function DailyTasksDB:writeString(key, value)
    key = tostring(nk.userData.uid) .. key
    cc.UserDefault:getInstance():setStringForKey(key, value)
    cc.UserDefault:getInstance():flush()
end

return DailyTasksDB