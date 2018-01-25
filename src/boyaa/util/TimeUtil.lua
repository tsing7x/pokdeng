
--
-- Author: shanks
-- Date: 2014.09.09
--

local TimeUtil = class("TimeUtil")

-- -- 将一个时间数转换成"00:00:00"格式
-- function TimeUtil:getTimeString(timeInt)
--     if (tonumber(timeInt) <= 0) then
--         return "00:00:00"
--     else
--         return string.format("%02d:%02d:%02d", math.floor(timeInt/(60*60)), math.floor((timeInt/60)%60), timeInt%60)
--     end
-- end

-- 将一个时间数转换成"00:00"格式
function TimeUtil:getTimeString(timeInt)
    if (tonumber(timeInt) <= 0) then
        return "00:00"
    else
        return string.format("%02d:%02d", math.floor((timeInt/60)%60), timeInt%60)
    end
end

-- 将一个时间数转换成"00"分格式
function TimeUtil:getTimeMinuteString(timeInt)
    if (tonumber(timeInt) <= 0) then
        return "00"
    else
        return string.format("%02d", math.floor((timeInt/60)%60))
    end
end

-- 将一个时间数转换成"00“秒格式
function TimeUtil:getTimeSecondString(timeInt)
    if (tonumber(timeInt) <= 0) then
        return "00"
    else
        return string.format("%02d", timeInt%60)
    end
end

function TimeUtil:getTimeDayTb(timeInt)
    local day = math.floor(timeInt / ( 60 * 60 * 24)) --以天数为单位取整
    local hour= math.floor(timeInt % (60 * 60 * 24) / ( 60 * 60)) --以小时为单位取整
    local min = math.floor(timeInt % (60 * 60) / 60) --以分钟为单位取整
    local sec = math.floor(timeInt % 60) --以秒为单位取整 

    return {day = day,hour = hour,min = min,sec = sec}
end


function TimeUtil:getTimeDayString(timeInt)
   
    -- local day = math.floor(timeInt / 60) --以天数为单位取整
    -- local hour= math.floor(timeInt % 86400000 / 3600000) --以小时为单位取整
    -- local min = math.floor(timeInt % 86400000 % 3600000 / 60000) --以分钟为单位取整
    -- local seconds = math.floor(timeInt % 86400000 % 3600000 % 60000 / 1000) --以秒为单位取整 


    seconds = timeInt % 60
    timeInt = (timeInt - seconds) / 60
    min = timeInt % 60
    timeInt = (timeInt - min) / 60
    hour = timeInt % 24
    day = (timeInt - hour) / 24


    -- dump("timeInt:"  .. timeInt .. " day:" .. day .. " hour:" .. hour .. " min:" .. min .. " seconds:" .. seconds,"getTimeDayString")
    if hour > 0 then
         return string.format("%02d:%02d:%02d", hour, min,seconds)
    else
        return string.format("%02d:%02d", min,seconds)
    end

    
end


function TimeUtil:get_timezone()
  local now = os.time()
  local dtime = os.difftime(now, os.time(os.date("!*t", now)))
  return (dtime/3600)
end


-- 00:00:00 或者 00:00 格式换算成秒
function TimeUtil:timeStrToSec(timeStr,sep,fmt)
    sep = sep or ":"
    local tb = string.split(timeStr,sep)
    local len = #tb
    local time = 0
    if len == 2 then
        fmt = fmt or "mm-ss"
        if fmt == "mm-ss" then  --分秒形式
            time = tonumber(tb[2]) *60 + tonumber(tb[3])
        elseif fmt == "hh-mm" then  -- 时分形式
            time = tonumber(tb[1]) * 3600 + tonumber(tb[2]) *60
        end
    elseif len == 3 then  -- 时分秒形式
        time = tonumber(tb[1]) * 3600 + tonumber(tb[2]) *60 + tonumber(tb[3])
    end
    
    return time
end

return TimeUtil