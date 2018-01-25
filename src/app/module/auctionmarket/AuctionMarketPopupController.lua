
-- Author: Vanfo
-- Date: 2016-01-8 14:20:00

local AuctionMarketPopupController = class("AuctionMarketPopupController")
local logger = bm.Logger.new("AuctionMarketPopupController")

function AuctionMarketPopupController:ctor(view)
	self.schedulerPool_ = bm.SchedulerPool.new()
	self.view_ = view

	self:startTimeCount()
end




function AuctionMarketPopupController:startTimeCount()
	self.schedulerPool_:loopCall(function()
		if self.nowTime_ then
			self.nowTime_ = self.nowTime_ + 1
		end

		return true
	end,1)
end



function AuctionMarketPopupController:getNowTime()
	return self.nowTime_
end


function AuctionMarketPopupController:getAuctionInitInfo()
	-- dump("=========getAuctionInitInfo========")
	self.view_:setLoading(true)
	local retryLimit = 3
    local deliveryFunc
    getInitFunc = function()
    	self.requestAuctionInitId_ = nk.http.getAuctionInitInfo(function(data)
    		self.requestAuctionInitId_ = nil
    		self:onGetAuctionInitInfoSucc_(data)
    	end,
		function()
			retryLimit = retryLimit - 1
			 if retryLimit > 0 then
                self.schedulerPool_:delayCall(function()
                    getInitFunc()
                end, 2)
            else
            	self.requestAuctionInitId_ = nil
                self:onGetAuctionInitInfoFail_()
            end
		end)

   end

   getInitFunc()

end


function AuctionMarketPopupController:onGetAuctionInitInfoSucc_(data)
	self.initInfo_ = data

	if self and self.view_ then
		--todo
		self.view_:setLoading(false)
	end

	if data and data.now and (data.now > 0) then
		self.nowTime_ = data.now
	end

	-- dump(data,"onGetAuctionInitInfoSucc_===")
	if self.view_ and self.view_["onGetAuctionInitInfoSucc_"] then
		self.view_:onGetAuctionInitInfoSucc_(data)
	end
end


function AuctionMarketPopupController:onGetAuctionInitInfoFail_(data)
	-- self.requestAuctionInitId_ = nil
	if self.view_ then
		self.view_:setLoading(false)
	end
	
end

function AuctionMarketPopupController:getInitInfo()
	return self.initInfo_
end

function AuctionMarketPopupController:getAuctionCenterData(category,curPage,pageNum,sortkey,order,pageIdx)
	local params = {}
	params.category = category
	params.curPage = curPage 
	params.pageNum = sortkey 
	params.order = order
	params.pageIdx = pageIdx 
	-- params.self = self
	self.view_:setLoading(true)
	self.requestAuctionDataId_ = nk.http.getAuctionCenterData(category,curPage,pageNum,sortkey,order,function(data)
		self:onGetAuctionCenterDataSucc_(data,params)
	end,handler(self, self.onGetAuctionCenterDataFail_))
end

function AuctionMarketPopupController:onGetAuctionCenterDataSucc_(data,params)
	self.requestAuctionDataId_ = nil
	self.view_:setLoading(false)
	if data and data.now and (data.now > 0) then
		self.nowTime_ = data.now
	end
	if self.view_ and self.view_["onGetAuctionCenterDataSucc_"] then
		self.view_:onGetAuctionCenterDataSucc_(data,params)
	end
end

function AuctionMarketPopupController:onGetAuctionCenterDataFail_(errData)
	self.requestAuctionDataId_ = nil
	self.view_:setLoading(false)
	-- dump(errData,"onGetAuctionCenterDataFail_")
end

-- 获取一口价列表数据
function AuctionMarketPopupController:getAuctionFixedPriceData(category,curPage,pageNum,sortkey,order)
	local params = {}
	params.category = category
	params.curPage = curPage 
	params.pageNum = sortkey 
	params.order = order 
	-- params.self = self
	self.view_:setLoading(true)
	self.requestAuctionFixedPriceDataId_ = nk.http.getAuctionFixedPriceData(category,curPage,pageNum,sortkey,order,function(data)
		self:onGetAuctionFixedPriceDataSucc_(data,params)
	end,handler(self, self.onGetAuctionFixedPriceDataFail_))
end

function AuctionMarketPopupController:onGetAuctionFixedPriceDataSucc_(data,params)
	self.requestAuctionFixedPriceDataId_ = nil
	self.view_:setLoading(false)
	if data and data.now and (data.now > 0) then
		self.nowTime_ = data.now
	end
	
	if self.view_ and self.view_["onGetAuctionFixedPriceDataSucc_"] then
		self.view_:onGetAuctionFixedPriceDataSucc_(data,params)
	end
end

function AuctionMarketPopupController:onGetAuctionFixedPriceDataFail_(errData)
	self.requestAuctionFixedPriceDataId_ = nil
	self.view_:setLoading(false)
	-- dump(errData,"onGetAuctionFixedPriceDataFail_")
end

--获取可拍卖物品数据 succCallBack, failCallBack 必传参数！！！
function AuctionMarketPopupController:getCanAuctionData(succCallBack, failCallBack)
	self.requestCanAuctionId_ = nk.http.getCanAuctionData(function(data)
		-- body
		-- dump(data, "getCanAuctionData.data:==================")

		self.requestCanAuctionId_ = nil
		succCallBack(data)
	end, function(errData)
		-- body
		-- dump(errData, "getCanAuctionData.errData:=================")
		failCallBack(errData)

		self.requestCanAuctionId_ = nil
	end)
end

-- 立即竞拍 参数表参数属必传参数 @attrParam
--[[
	attrParam.itemId :物品Id
	attrParam.auctType :拍卖类型
	attrParam.auctPrice :竞拍出价
]]
function AuctionMarketPopupController:auctProdByAttr(attrParam, auctSuccCallBack, auctFailCallBack)
	-- 这里忘了传参数? nk.http.auctionSomething(itemid,flag,price,resultCallback,errorCallback)
	
	self.requestAuctProdId_ = nk.http.auctProd(attrParam, function(data)
		-- body
		self.requestAuctProdId_ = nil
		-- dump(data, "auctProd.data:================")

		auctSuccCallBack(data)
		self:onAuctProdByAttrSucc_(data)
	end, function(errData)
		-- body
		-- dump(errData, "auctProd.errData:================")

		auctFailCallBack(errData)
		self:onAuctProdByAttrFail_(errData)
		self.requestAuctProdId_ = nil
	end)
end


function AuctionMarketPopupController:onAuctProdByAttrSucc_(data)
	-- dump(data,"AuctionMarketPopupController:onAuctProdByAttrSucc_")
	self.view_:setLoading(false)
	if self.view_ and self.view_["onAuctProdByAttrSucc_"] then
		self.view_:onAuctProdByAttrSucc_(data)
	end
end


function AuctionMarketPopupController:onAuctProdByAttrFail_(errData)
	dump(data,"AuctionMarketPopupController:onAuctProdByAttrFail_")
	self.view_:setLoading(false)
	if self.view_ and self.view_["onAuctProdByAttrFail_"] then
		self.view_:onAuctProdByAttrFail_(errData)
	end

end


-- 获取我的拍卖物品数据
function AuctionMarketPopupController:getMyAuctionData(category)
	category = category or 0
	self.view_:setLoading(true)
	self.requestGetMyAuctionDataId_ = nk.http.getMyAuctionData(category,handler(self,self.onGetMyAuctionDataSucc_),
		handler(self, self.onGetMyAuctionDataFail_))
end

function AuctionMarketPopupController:onGetMyAuctionDataFail_(errData)
	self.view_:setLoading(false)
	self.requestGetMyAuctionDataId_ = nil
end

function AuctionMarketPopupController:onGetMyAuctionDataSucc_(data)
	self.requestGetMyAuctionDataId_ = nil
	self.view_:setLoading(false)
	if data and data.now and (data.now > 0) then
		self.nowTime_ = data.now
	end
	if self.view_ and self.view_["onGetMyAuctionDataSucc_"] then
		self.view_:onGetMyAuctionDataSucc_(data)
	end
end

function AuctionMarketPopupController:onGetMyAuctionDataFail_(errData)
	-- body
	-- dump(errData, "onGetMyAuctionDataFail_.errData:===================")
	self.view_:setLoading(false)
end

 --添加拍卖 @prodParam:
--[[
	prodParam.prodType :物品类型Id
	prodParam.num :物品数量
	prodParam.expireType :过期时间Type
	prodParam.auctType :参拍类型，1:普通拍卖, 2:一口价拍卖
	prodParam.auctStartPrice :参拍起始价
]]
function AuctionMarketPopupController:addAuctSellProd(prodParam, dataGetCallBack, dataErrCallBack)
	self.requestAddMyAuctionDataId_ = nk.http.addAuctSellProdData(prodParam, function(data)
		-- body
		self.requestAddMyAuctionDataId_ = nil
		-- dump(data, "addAuctSellProdData.data:==================")

		dataGetCallBack(data)
		self:onAddAuctSellProdSucc_(data)
	end, function(errData)
		-- body
		-- dump(errData, "addAuctSellProdData.errData:===================")
		dataErrCallBack(errData)
		self:onAddAuctSellProdFail_(errData)

		self.requestAddMyAuctionDataId_ = nil
	end)
	self.view_:setLoading(false)
end


function AuctionMarketPopupController:onAddAuctSellProdSucc_(data)
	if self.view_ and self.view_["onAddAuctSellProdSucc_"] then
		self.view_:onAddAuctSellProdSucc_(data)
	end
end


function AuctionMarketPopupController:onAddAuctSellProdFail_(errData)
	if self.view_ and self.view_["onAddAuctSellProdFail_"] then
		self.view_:onAddAuctSellProdFail_(errData)
	end
end

--获取拍卖纪录
function AuctionMarketPopupController:getAuctionRecordData(category)
	category = category or 0
	self.view_:setLoading(true)
	self.requestAuctionRecordDataId_ = nk.http.getAuctionRecordData(category,handler(self,self.onGetAuctionRecordDataSucc_),
		handler(self, self.onGetAuctionRecordDataFail_))
end


function AuctionMarketPopupController:onGetAuctionRecordDataSucc_(data)
	self.requestAuctionRecordDataId_ = nil
	self.view_:setLoading(false)
	if self.view_ and self.view_["onGetAuctionRecordDataSucc_"] then
		self.view_:onGetAuctionRecordDataSucc_(data)
	end
end

function AuctionMarketPopupController:onGetAuctionRecordDataFail_(data)
	self.requestAuctionRecordDataId_ = nil
	self.view_:setLoading(false)
	
end


function AuctionMarketPopupController:dispose()

	self.schedulerPool_:clearAll()
	
	if self.requestAuctionInitId_ then
		nk.http.cancel(self.requestAuctionInitId_)
		self.requestAuctionInitId_ = nil
	end


	if self.requestAuctionDataId_ then
		nk.http.cancel(self.requestAuctionDataId_)
		self.requestAuctionDataId_ = nil
	end

	if self.requestAuctProdId_ then
		nk.http.cancel(self.requestAuctProdId_)
		self.requestAuctProdId_ = nil
	end

	if self.requestAuctionFixedPriceDataId_ then
		nk.http.cancel(self.requestAuctionFixedPriceDataId_)
		self.requestAuctionFixedPriceDataId_ = nil
	end

	if self.requestCanAuctionId_ then
		nk.http.cancel(self.requestCanAuctionId_)
		self.requestCanAuctionId_ = nil
	end

	if self.requestGetMyAuctionDataId_ then
		nk.http.cancel(self.requestGetMyAuctionDataId_)
		self.requestGetMyAuctionDataId_ = nil
	end

	if self.requestAddMyAuctionDataId_ then
		nk.http.cancel(self.requestAddMyAuctionDataId_)
		self.requestAddMyAuctionDataId_ = nil
	end

	if self.requsetGetTimeSwicthId_ then
		--todo
		nk.http.cancel(self.requsetGetTimeSwicthId_)
		self.requsetGetTimeSwicthId_ = nil
	end

	if self.requestAuctionRecordDataId_ then
		nk.http.cancel(self.requestAuctionRecordDataId_)
		self.requestAuctionRecordDataId_ = nil
	end
end

return AuctionMarketPopupController