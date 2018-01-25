--
-- Author: Tom
-- Date: 2014-12-04 14:29:12
--
local LoadMatchControl =  class("LoadMatchControl")
local instance

function LoadMatchControl:getInstance()
    instance = instance or LoadMatchControl.new()
    return instance
end

function LoadMatchControl:ctor()
    self.logger = bm.Logger.new("LoadMatchControl")
    self.schedulerPool_ = bm.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end

function LoadMatchControl:loadConfig(url, callback)
    dump(url,"LoadMatchControl:loadConfig")
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadMatchConfigCallback_ = callback
    self:loadConfig_()
end

function LoadMatchControl:loadConfig_()

    local retryLimit = 6
    local loadConfigFunc
    loadConfigFunc = function()
        if not self.isConfigLoaded_ and not self.isConfigLoading_ then
            self.isConfigLoading_ = true
            bm.cacheFile(self.url_ or "", function(result, content)
                self.isConfigLoading_ = false
                if result == "success" then
                    self.isConfigLoaded_ = true
                    self.isConfigLoading_ = false
                    self.matchData_ = json.decode(content)

                    self:preDealMatchDatas()

                    if self.loadMatchConfigCallback_ then
                        self.loadMatchConfigCallback_(true, self.matchData_)
                    end
                else
                    self.logger:debug("loadConfigFunc failed => " .. json.encode(jsn))
                    self.isConfigLoaded_ = false
                    self.isConfigLoading_ = false

                    retryLimit = retryLimit - 1
                    if retryLimit > 0 then
                        self.schedulerPool_:delayCall(function()
                            loadConfigFunc()
                        end, 10)
                    else
                       if self.loadMatchConfigCallback_ then
                            self.loadMatchConfigCallback_(false)
                        end
                    end
                end
            end, "match")
        elseif self.isConfigLoaded_ then
             if self.loadMatchConfigCallback_ then
                self.loadMatchConfigCallback_(true, self.matchData_)
            end
        end
    end

    loadConfigFunc()

end


function LoadMatchControl:preDealMatchDatas()
    if not self.matchData_ then 
        return
    end

    if self.matchData_["match"] then
        -- 过滤未开放场次过滤
        table.filter(self.matchData_["match"],function(v,k)
            return (checkint(v.open) == 1)
        end)

        local newMdatas = table.values(self.matchData_["match"])
        self.matchData_["match"] = newMdatas

    end
end

function LoadMatchControl:cancel()
    if self.loadMatchConfigCallback_ then
        self.loadMatchConfigCallback_ = nil
    end
end

function LoadMatchControl:isConfigLoaded()
    return self.isConfigLoaded_
end

function LoadMatchControl:isConfigLoading()
    return self.isConfigLoading_
end

function LoadMatchControl:getMatchDatas()
    return (self.matchData_ ~= nil and self.matchData_["match"] or {})
end

function LoadMatchControl:getMatchVersion()
    return (self.matchData_ ~= nil and self.matchData_["version"] or 0)
end

function LoadMatchControl:getTicketsDatas()
    return (self.matchData_ ~= nil and self.matchData_["tickets"] or {})
end


function LoadMatchControl:getPrizesDatas()
     return (self.matchData_ ~= nil and self.matchData_["prizes"] or {})
end

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
function LoadMatchControl:getMatchDataById(id)

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
function LoadMatchControl:getTicketDataById(id)

    if self.matchData_ ~= nil and self.matchData_["tickets"] then
        for _,v in pairs(self.matchData_["tickets"]) do
            if id == v.id then
                return v         
            end
        end
    end

    return nil
end


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
function LoadMatchControl:getPrizeDataById(id)
    if self.matchData_ ~= nil and self.matchData_["prizes"] then
        for _,v in pairs(self.matchData_["prizes"]) do
            if id == v.id then
                return v         
            end
        end
    end

    return nil
end

return LoadMatchControl