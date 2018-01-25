
local LoadScoreMarketControl =  class("LoadScoreMarketControl")
local instance

function LoadScoreMarketControl:getInstance()
    instance = instance or LoadScoreMarketControl.new()
    return instance
end
function LoadScoreMarketControl:ctor()
    self.logger = bm.Logger.new("LoadScoreMarketControl")
    self.schedulerPool_ = bm.SchedulerPool.new()
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end

function LoadScoreMarketControl:loadConfig(url, callback)
    dump(url,"LoadScoreMarketControl:loadConfig")
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadScoreMarketConfigCallback_ = callback
    self:loadConfig_()
end

function LoadScoreMarketControl:loadConfig_()
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
                    dump("loadscoremarketSuccess","loadscoremarketSuccess")
                    self.scoreMarketData_ = json.decode(content)
                    if self.loadScoreMarketConfigCallback_ then
                        self.loadScoreMarketConfigCallback_(true, self.scoreMarketData_)
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
                       if self.loadScoreMarketConfigCallback_ then
                            self.loadScoreMarketConfigCallback_(false)
                        end
                    end
                end
            end, "scoreMarket")
        elseif self.isConfigLoaded_ then
             if self.loadScoreMarketConfigCallback_ then
                self.loadScoreMarketConfigCallback_(true, self.scoreMarketData_)
            end
        end
    end

    loadConfigFunc()
end
function LoadScoreMarketControl:cancel()
    if self.loadScoreMarketConfigCallback_ then
        self.loadScoreMarketConfigCallback_ = nil
    end
end

function LoadScoreMarketControl:isConfigLoaded()
    return self.isConfigLoaded_
end

function LoadScoreMarketControl:isConfigLoading()
    return self.isConfigLoading_
end
--由于php的json数据结构没有分类 so...
function LoadScoreMarketControl:getGoodsBuyType(goodsType)
	local dataForType = {}
	if self.scoreMarketData_== nil then
		return dataForType
	end
	for k,v in pairs(self.scoreMarketData_) do
		if goodsType == self.scoreMarketData_[k].category then
			table.insert(dataForType,self.scoreMarketData_[k])
		end
	end
	local groupData = {}
	local temp = {}
	for i=1,#dataForType,3 do
		temp = {}
		temp[1] = dataForType[i]
		temp[2] = dataForType[i+1]
		temp[3] = dataForType[i+2]
		table.insert(groupData,temp)
	end

	return groupData
end

return LoadScoreMarketControl