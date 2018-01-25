--
-- Author: Tom
-- Date: 2014-12-04 14:29:12
--
local LoadMatchControlEx =  class("LoadMatchControlEx")
local instance


local TYPE_TIME_MATCH = 2
local TYPE_NORMAL_MATCH = 1
local DEFAULT_MATCH_COUNT = 2


LoadMatchControlEx.TYPE_NORMAL_MATCH = 1
LoadMatchControlEx.TYPE_TIME_MATCH = 2

function LoadMatchControlEx:getInstance()
    instance = instance or LoadMatchControlEx.new()
    return instance
end

function LoadMatchControlEx:ctor()
    self.logger = bm.Logger.new("LoadMatchControlEx")
    self.schedulerPool_ = bm.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false 
    local typeTb = {LoadMatchControlEx.TYPE_NORMAL_MATCH,LoadMatchControlEx.TYPE_TIME_MATCH}
    local typeStr = table.concat(typeTb,",")
    self.mtype_ = typeStr
    self:addEventListeners()
end



function LoadMatchControlEx:addEventListeners()
    if not self.SVR_SUONA_BROADCAST_RECV_ID_ then
        self.SVR_SUONA_BROADCAST_RECV_ID_ = bm.EventCenter:addEventListener(nk.eventNames.SVR_SUONA_BROADCAST_RECV, handler(self, self.onSuonaBroadRecv_))
    end
end



function LoadMatchControlEx:removeEventListeners()
    if self.SVR_SUONA_BROADCAST_RECV_ID_ then
        bm.EventCenter:removeEventListener(self.SVR_SUONA_BROADCAST_RECV_ID_)
        self.SVR_SUONA_BROADCAST_RECV_ID_ = nil
    end
end

--收到更新配置广播，拉取新配置
function LoadMatchControlEx:onSuonaBroadRecv_(evt)
    if evt.data and evt.data.msg_info then
        local msgInfo = json.decode(evt.data.msg_info)
        local msgType = msgInfo.type
        -- 类型四是更新比赛场配置
        if msgType == 4 then
            local loadConfigCallback = self.loadMatchConfigCallback_
            self:loadConfig(nil,loadConfigCallback,true)
        end

    end
end

function LoadMatchControlEx:getServerTime()
    return self.serverTime_
end

function LoadMatchControlEx:loadConfig(mtype, callback,force)
    -- dump(mtype,"LoadMatchControlEx:loadConfig")

    if force then
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
        if self.getListRequestId_ then
            nk.http.cancel(self.getListRequestId_)
            self.getListRequestId_ = nil
        end
    end

    if self.isConfigLoading_ then
        return
    end
    

    local typeTb = {TYPE_NORMAL_MATCH,TYPE_TIME_MATCH}
    local typeStr = table.concat(typeTb,",")
    self.mtype_ = (mtype or typeStr)

    self.loadMatchConfigCallback_ = callback
    self:loadConfig_()
end


function LoadMatchControlEx:preDealAction()

    ---[[定时赛
    self:dealNotificationTimer()
    self:dealRegisterNotificationTimer()
    --]]


    ---[[定人赛


    --]]
end


function LoadMatchControlEx:preDealMatchDatas()

    if self.matchData_ then
        --系统时间
        self.serverTime_ = self.matchData_["now"] or os.time()
        self.clientTime_ = os.time()
        self.servDayTime_ = self.matchData_["zeroPoint"]
        self.serverTimeZone_ = self.matchData_["timeZone"] or 7
        if self.matchData_["match"] then
            -- 过滤未开放场次过滤
            table.filter(self.matchData_["match"],function(v,k)
                return (v.open == 1)
            end)

            local newMdatas = table.values(self.matchData_["match"])
            self.matchData_["match"] = newMdatas

            ---[[定时赛
            for _,v in pairs(self.matchData_["match"]) do
                if checkint(v.type) == TYPE_TIME_MATCH then
                    v.serverTime = self.serverTime_
                    v.clientTime = self.clientTime_
                    v.servDayTime = self.servDayTime_
                end
            end
            --]]


            ---[[ 定人赛

            --]]
        end
    end
end

function LoadMatchControlEx:loadConfig_()
    local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true

            self.getListRequestId_ = nk.http.getTimeMatchList(self.mtype_, function(data)

                -- dump(data, "nk.http.getTimeMatchList.retData :=================", 8)
                self.isConfigLoading_ = false
                self.isConfigLoaded_ = true
                self.getListRequestId_ = nil

                self.matchData_ = data

                self:preDealMatchDatas()
                self:preDealAction()

                 if self.loadMatchConfigCallback_ then
                    self.loadMatchConfigCallback_(true, self.matchData_)
                end

            end,function(errData)
                -- dump(errData, "nk.http.getTimeMatchList.errData :=================")
                self.getListRequestId_ = nil
                self.isConfigLoaded_ = false
                self.isConfigLoading_ = false
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
                        loadConfigFunc()
                    end, 2)
                else
                   if self.loadMatchConfigCallback_ then
                        self.loadMatchConfigCallback_(false)
                    end
                end

            end)

        elseif self.isConfigLoaded_ then
             if self.loadMatchConfigCallback_ then
                self.loadMatchConfigCallback_(true, self.matchData_)
            end
        end
    end

    loadConfigFunc()

end

function LoadMatchControlEx:cancel()
    if self.loadMatchConfigCallback_ then
        self.loadMatchConfigCallback_ = nil
    end
end

function LoadMatchControlEx:isConfigLoaded()
    return self.isConfigLoaded_
end

function LoadMatchControlEx:isConfigLoading()
    return self.isConfigLoading_
end

function LoadMatchControlEx:getMatchDatas()
    return (self.matchData_ ~= nil and self.matchData_["match"] or {})
end

function LoadMatchControlEx:getMatchVersion()
    return (self.matchData_ ~= nil and self.matchData_["version"] or 0)
end


function LoadMatchControlEx:getMatchDatasByType(mtype)
    local temp = {}
    if self.matchData_ and self.matchData_["match"] then
        for _,v in pairs(self.matchData_["match"]) do
            if checkint(v.type) == mtype then
                table.insert(temp,v)
            end
        end
    end
    return temp
end

-- function LoadMatchControlEx:getTicketsDatas()
--     return (self.matchData_ ~= nil and self.matchData_["tickets"] or {})
-- end


-- function LoadMatchControlEx:getPrizesDatas()
--      return (self.matchData_ ~= nil and self.matchData_["prizes"] or {})
-- end

-- 根据场次ID获取比赛场次信息
--[[

 {

    "id": 2,

    "icon1": "http://pirates133.by.com/pokdeng/staticres/match/icon/icon2_1.png",

    "name": "热身赛(9人开赛)",

    "icon2": "http://pirates133.by.com/pokdeng/staticres/match/icon/icon2_2.png",

    "limit": "3万筹码+3K服务费 或 热身赛门票X1",

    "prize": "热身赛门票X1\\n8000筹码\\n冠军积分X2",

    "fee":{"serv":3000,"entry":30000},

    "tickets":{"101":1,"104":1},

    "open":1

    

},
--]]
function LoadMatchControlEx:getMatchDataById(id)

    if self.matchData_ ~= nil and self.matchData_["match"] then
        for _,v in pairs(self.matchData_["match"]) do
            if id == v.id then
                return v         
            end
        end
    end

    return nil
end



--根据门票ID获取门票信息
--[[
{
    "id": 101,
    "name": "热身赛门票"
    
}
--]]
-- function LoadMatchControlEx:getTicketDataById(id)

--     if self.matchData_ ~= nil and self.matchData_["tickets"] then
--         for _,v in pairs(self.matchData_["tickets"]) do
--             if id == v.id then
--                 return v         
--             end
--         end
--     end

--     return nil
-- end


--根据场次ID获取奖励信息
--[[
{
    "id": 1,
    "prize":[
        {
            "rank": 1,
            "desc":["初级赛门票X1","80000筹码","冠军积分X2"]
        },
        {
            "rank": 2,
            "desc":["初级赛门票X1","50000筹码","冠军积分X1"]
        },
        {
            "rank": 3,
            "desc":["初级赛门票X1","30000筹码","冠军积分X1"]
        }
    ]
}
--]]
function LoadMatchControlEx:getPrizeDataById(id)

    local match = self:getMatchDataById(id)
    if match then

        return match.prizeDesc
        -- if match.type == TYPE_TIME_MATCH then
        --     return match.prizeDesc
        -- elseif match.type == TYPE_NORMAL_MATCH then

        --     if self.matchData_["prizes"] then
        --         for _,v in pairs(self.matchData_["prizes"]) do
        --             if id == v.id then
        --                 return v         
        --             end
        --         end
        --     end
        -- end

    end
        
    return nil
end



function LoadMatchControlEx:filterTimeArrByDay(dayArr,timeArr,curDay)

    local temp = {}
   
        if dayArr and #dayArr > 0 then
            for idx,day in ipairs(dayArr) do
                if day >= curDay then
                    if idx == #dayArr then
                       --后面再没比赛了 
                        for _,time in pairs(timeArr) do
                            if time.round == 0 then
                                time.day = day
                                time.timestamp = bm.TimeUtil:timeStrToSec(time.time) + time.day
                                table.insert(temp,time) 

                           end

                        end
                          

                    else
                        for _,time in pairs(timeArr) do
                            --后面日期还有比赛
                            if dayArr[(idx + time.round)] then
                                time.day = dayArr[(idx + time.round)]
                                time.timestamp = bm.TimeUtil:timeStrToSec(time.time) + time.day
                                table.insert(temp,time)
                            end
                            
                        end
                        break
                    end

                end
            end
        else

            for _,time in pairs(timeArr) do
                time.day = (self.servDayTime_ + (time.round * 3600 * 24)) 
                time.timestamp = bm.TimeUtil:timeStrToSec(time.time) + time.day
                table.insert(temp,time)
            end
            
        end
   
    
    return temp
end


function LoadMatchControlEx:findNextSomeTimeMatchs(curTime,count)

    if not self.matchData_ then
        return
    end


    local passTime = os.time() - (self.clientTime_ or self.serverTime_)
    local curTime = self.serverTime_ + passTime
    -- local curTime = os.time()
    local timeZone = bm.TimeUtil:get_timezone()
    local serverTimeZone = self.serverTimeZone_ or 7
    local desTimeZone = serverTimeZone - timeZone
    local desTime = curTime + (desTimeZone * 3600)
    curTime = os.date("%X",desTime)
    
    


    -- dump(curTime,"findNextSomeTimeMatchs===")
    local temp = {}
    local timeMatchTb = self:getMatchDatasByType(TYPE_TIME_MATCH)
    -- dump(timeMatchTb,"timeMatchTb=====",10)
    for _,v in pairs(timeMatchTb) do
        count = v.showNum or count or DEFAULT_MATCH_COUNT
        local timeArr = self:findNextSomeTime(v.times,curTime,count)
        local finalTimeArr = self:filterTimeArrByDay(v.date,timeArr,self.servDayTime_)

        -- dump(timeArr,"timeArr===")
        -- dump(finalTimeArr,"finalTimeArr===")
        for __,vv in pairs(finalTimeArr) do
            local mdata = clone(v)
            mdata.mtime = vv
            table.insert(temp,mdata)
        end
    end

    return temp
end


-- 根据当前时间获取接下来count个数据 {{time = "00:20:10,round = 1"},{time = "01:30:10,round = 0"}}
function LoadMatchControlEx:findNextSomeTime(timeArr,curTime,count)
    count = count or 1
    local temp = {}
    local tb = clone(timeArr)
    local tIdx = table.indexof(tb,curTime)
    if tIdx then
        --存在相同时间的比赛
        tIdx = tIdx + 1
    else
        local t = clone(tb)



        table.insert(t,curTime)
        table.sort(t)
        tIdx = table.indexof(t,curTime)
    end

    local length = #tb
    local round = 0
    -- local idx = table.indexof(tb,curTime)
    local index 
    for i = tIdx,tIdx+(count - 1) do
       
        index = i%length
        if index == 0 then
            index = length
        end
        round = math.floor((i-1)/length)  -- 当前是第几圈，每圈差24小时
        if tb[index] then
            local t = {}
            t.round = round
            t.time = tb[index]
            table.insert(temp,t)
        end
    end
    return temp   
end

function LoadMatchControlEx:clearNotiTimer()

    if self.notiTimerId_ then
        self.schedulerPool_:clear(self.notiTimerId_)
        self.notiTimerId_ = nil
    end
end

-- 计时，用于通知实时刷新列表和玩家已经报名场次
function LoadMatchControlEx:dealNotificationTimer()
    local curShowMatchs = self:findNextSomeTimeMatchs()
    table.sort(curShowMatchs,function(t1,t2)
        return t1.mtime.timestamp < t2.mtime.timestamp
    end)

    -- dump(curShowMatchs,"dealNotificationTimer",10)

    local firstData = table.remove(curShowMatchs,1)
    -- dump(firstData,"dealNotificationTimer - firstData:")
     -- dump(os.time(),"dealNotificationTimer-fdata-time")
    if firstData then
        self:clearNotiTimer()
        local passTime = os.time() - firstData.clientTime
        local nowServerTime = firstData.serverTime + passTime
        local delay = firstData.mtime.timestamp - nowServerTime
        -- dump(firstData.mtime.timestamp ,"dealNotificationTimer - timestamp:")
        -- dump(os.time() ,"dealNotificationTimer - os.time:")
        -- dump(delay,"dealNotificationTimer server- delay:")
        -- dump((firstData.mtime.timestamp - os.time()),"dealNotificationTimer client- delay:")
        self.notiTimerId_ = self.schedulerPool_:delayCall(function(schePool,fdata)

            -- dump(fdata,"计时完毕，刷新列表TIME_MATCH_OPEN-time:" .. os.time())
            bm.EventCenter:dispatchEvent({name=nk.eventNames.TIME_MATCH_OPEN, data=fdata})
            self:dealNotificationTimer()
        end, delay+1,firstData)

        -- dump(self.notiTimerId_,"self.notiTimerId_")
    end
    
end

-- pushOnlineCondition:在线推送时间
-- pushOfflineCondition：离线推送时间
function LoadMatchControlEx:dealRegisterNotificationTimer()
    if not self.registerMatchsTb_ then
        self.registerMatchsTb_ = {}
    end

    --过滤已经超时通知的场次
    if not self.clientTime_ or not self.serverTime_ then
        return
    end
    local passTime = os.time() - self.clientTime_
    local nowServerTime = self.serverTime_ + passTime
    -- local now = os.time()
    local now = nowServerTime
    table.filter(self.registerMatchsTb_,function(v,k)
        return v.time > now 
    end)

    local newRegTb = table.values(self.registerMatchsTb_)
    self.registerMatchsTb_ = newRegTb


    table.sort(self.registerMatchsTb_,function(t1,t2)
        if t1.time < t2.time then
            return true
        elseif t1.time == t2.time then
            return t1.ptime > t2.ptime
        else
            return false
        end
    end)

    local firstData = self.registerMatchsTb_[1]

    -- local firstData = table.remove(self.registerMatchsTb_,1)

    if firstData then
        if self.curPushingMatch_ then
            if (firstData.id == self.curPushingMatch_.id) and (firstData.matchid == self.curPushingMatch_.matchid) and (firstData.time == self.curPushingMatch_.time) then
                local delayingPtime = self.curPushingMatch_.ptime
                local firstDataPtime = firstData.ptime
                if delayingPtime > firstDataPtime then
                    -- dump(self.curPushingMatch_,"curdelaying")
                    -- dump(firstData,"firstData")
                    return
                end
            else

            end

        end

        -- local nextData = table.remove(self.registerMatchsTb_,1)
        local nextData = firstData
        self.curPushingMatch_ = nextData
        self:clearRegisterNotiTimer()
        local id = nextData.id
        local match = self:getMatchDataById(id)
        local pushTime = nextData.ptime or 60
        local notiDelay = nextData.time - now - pushTime
        -- dump(pushTime,"addRegisterMatch - pushTime:")
        -- dump(notiDelay,"addRegisterMatch - delay:")

        -- dump(self.registerMatchsTb_,"after dealRegisterNotificationTimer")

        self.regNotiTimerId_ = self.schedulerPool_:delayCall(function(schePool,fdata)

            -- dump("计时完毕，已报名比赛推送通知")
            -- dump(self.curPushingMatch_,"计时完毕，curpushMatch")
            local idx = table.indexof(self.registerMatchsTb_,self.curPushingMatch_)
            -- dump(idx,"curPushingMatch_-idx:")
            if idx then
                table.remove(self.registerMatchsTb_,idx)
            end
            self.curPushingMatch_ = nil
            bm.EventCenter:dispatchEvent({name=nk.eventNames.TIME_MATCH_PUSH, data=fdata})
            self:dealRegisterNotificationTimer()
        end, notiDelay+1,nextData)
    end

    
end


function LoadMatchControlEx:clearRegisterNotiTimer()
    if self.regNotiTimerId_ then
        self.schedulerPool_:clear(self.regNotiTimerId_)
        self.regNotiTimerId_ = nil
    end
end


function LoadMatchControlEx:delRegisterMatch(id,matchid,time)

    -- dump(self.registerMatchsTb_,"before delRegisterMatch")
    for i = #self.registerMatchsTb_,1 ,-1 do
        -- dump("id:" .. id .. " matchid:" .. matchid .. " time:" .. time)
        if (self.registerMatchsTb_[i]) and (self.registerMatchsTb_[i].id == id) and (self.registerMatchsTb_[i].matchid == matchid) and (self.registerMatchsTb_[i].time == time) then
            -- dump("id:" .. self.registerMatchsTb_[i].id .. " matchid:" .. self.registerMatchsTb_[i].matchid .. " time:" .. self.registerMatchsTb_[i].time," isequle===")
            table.remove(self.registerMatchsTb_,i)
        end
    end

    -- dump(self.registerMatchsTb_,"after delRegisterMatch")
    -- local newRegTb = table.values(self.registerMatchsTb_)
    -- self.registerMatchsTb_ = newRegTb
    self:dealRegisterNotificationTimer()
end

-- match {id:xxx,time:xxxxxxx,matchid:xxx}
-- id:场次ID  time:开赛时间戳   matchid:比赛场id(进入比赛用于请求server)
function LoadMatchControlEx:addRegisterMatch(match)
    if not self.registerMatchsTb_ then
        self.registerMatchsTb_ = {}
    end

    --inMatchRoom 0:不在比赛场 1：在比赛场
    --已经在比赛房间，不倒计时提醒
    if match and (checkint(match.inMatchRoom) == 0) then
        assert((match.id ~= nil) and (match.matchid ~= nil) and (match.time ~= nil))

        local matchInfo = self:getMatchDataById(match.id)
        if not matchInfo then
            return
        end

        -- dump(matchInfo,"addRegisterMatch-matchInfo")
        -- dump(matchInfo,"addRegisterMatch-matchInfo")
        local pushTime = matchInfo.pushOnlineCondition
        if (pushTime == nil or pushTime == "" or pushTime == 0) then
            -- pushTime = {60,30,10}
            -- 如果没有设置，则不推送倒计时提醒
            return
        end
        local pushTimeTb = string.split(pushTime,",")

        local passTime = os.time() - self.clientTime_
        local nowServerTime = self.serverTime_ + passTime
        local leftTime = match.time - nowServerTime

        -- dump(pushTimeTb,"pushTimeTb")
         -- dump(leftTime,"leftTime=")
        if pushTimeTb then
            for i,v in ipairs(pushTimeTb) do
                local tt = tonumber(v)
                if tt <= leftTime then
                    --小于剩余开赛时间的提醒时间才有效
                    local mdata = clone(match)
                    mdata.ptime = tt
                    mdata.isSameEnd = (tonumber(i) == #pushTimeTb) -- 是否同一个比赛的最后一次倒计时提醒
                    table.insert(self.registerMatchsTb_,mdata)
                end
                
            end
        else
                local mdata = clone(match)
                mdata.ptime = 60
                mdata.isSameEnd = true
                table.insert(self.registerMatchsTb_,mdata)
        end
        
        -- table.insert(self.registerMatchsTb_,match)
        -- table.sort(self.registerMatchsTb_,function(t1,t2)
        --     return t1.time < t2.time
        -- end)
    end

    -- dump(self.registerMatchsTb_,"addRegisterMatch")

    self:dealRegisterNotificationTimer()
 
end



--缓存已报名比赛
function LoadMatchControlEx:cacheRegisterMatch(match)
    if not self.cacheRegMatchTb_ then
        self.cacheRegMatchTb_ = {}
    end

    if match then
        assert((match.id ~= nil) and (match.time ~= nil))
        if not self.cacheRegMatchTb_[match.id] then
            self.cacheRegMatchTb_[match.id] = {}
        end

        local isInTb = false
        for _,v in pairs(self.cacheRegMatchTb_[match.id]) do
            if v.id == match.id and v.time == match.time then
                isInTb = true
                break
            end
        end

        if not isInTb then
            local mdata = clone(match)
            table.insert(self.cacheRegMatchTb_[match.id],mdata)
        end

    end
end


function LoadMatchControlEx:findRegisterMatchByIdAndTime(id,time)
    if self.cacheRegMatchTb_ and self.cacheRegMatchTb_[id] then
        for _,v in pairs(self.cacheRegMatchTb_[id]) do
            if v.id == id and v.time == time then
                return v
            end
        end
        
    end
    return nil
    
end



function LoadMatchControlEx:dispose()
    -- self:clearRegisterNotiTimer()
    -- self:clearNotiTimer()
    self.schedulerPool_:clearAll()
    self.registerMatchsTb_ = {}
    self.curPushingMatch_ = nil
    self.cacheRegMatchTb_ = {}

    self.matchData_ = nil
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
    if self.getListRequestId_ then
        nk.http.cancel(self.getListRequestId_)
        self.getListRequestId_ = nil
    end

end

return LoadMatchControlEx