--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-04-11 17:15:03
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: FirChrgPgController by Tsing.
--
local QuickPurchaseServiceManager = import("..QuickPurchaseServiceManager")
local PURCHASE_TYPE = import("..PURCHASE_TYPE")

local FirChrgPgController = class("FirChrgPgController")

function FirChrgPgController:ctor(view)
	-- body
	self:init()
	self.view_ = view
end

function FirChrgPgController:init()
	-- body
	self.quickPay_ = QuickPurchaseServiceManager.new()
	self.quickPay_:setPurchaseCallback(handler(self, self.onPurchaseResultCallBack))
	self.quickPay_:loadPayConfig(handler(self, self.onConfigLoaded))
	-- local isServiceAvailable = self.quickPay_:isServiceAvailable(PURCHASE_TYPE.BLUE_PAY)
 --    local service = self.quickPay_:getPurchaseService(PURCHASE_TYPE.BLUE_PAY)
end

function FirChrgPgController:getFirstChargePayment()
	-- body

	self.loadPaymentReqId_ = nk.http.getPaymentList(function(retData)
		-- body
		-- dump(retData, "getPaymentList.data: ==================")
		self.rewardData_ = {}
        -- local prd = {}
        self.rewardData_.pid = retData.pid or retData.id or ""
        self.rewardData_.id = retData.id
        self.rewardData_.sid = retData.sid
        self.rewardData_.appid = retData.appid
        self.rewardData_.pmode = retData.pmode
        self.rewardData_.pamount = retData.pamount
        self.rewardData_.discount = retData.discount
        self.rewardData_.pcoins = retData.pcoins
        self.rewardData_.pchips = retData.pchips
        self.rewardData_.pcard = retData.pcard
        self.rewardData_.ptype = retData.ptype
        self.rewardData_.pnum = retData.pnum
        self.rewardData_.getname = retData.getname
        self.rewardData_.desc = retData.desc
        self.rewardData_.stag = retData.stag
        self.rewardData_.currency= retData.currency
        self.rewardData_.prid= retData.prid
        self.rewardData_.expire= retData.expire
        self.rewardData_.state= retData.state
        self.rewardData_.device= retData.device
        self.rewardData_.sortid= retData.sortid
        self.rewardData_.etime= retData.etime
        self.rewardData_.status= retData.status
        self.rewardData_.use_status= retData.use_status
        self.rewardData_.item_id = retData.item_id

        --三公原有字段兼容处理
        self.rewardData_.price = retData.pamount or 0
        self.rewardData_.chipNum = retData.pchips or 0
        self.rewardData_.ticketNum = retData.pnum or 0
        self.rewardData_.cashCions = retData.pcoins or 0
        self.rewardData_.title = retData.getname or ""
        self.rewardData_.tag = retData["tag"] == 1 and "hot" or (retData["tag"] == 2 and "new" or "")
        -- prd.img = chip.u and chip.u ~= "" and chip.u or prd.id
        self.rewardData_.img = ""
        -- self:getChipIcon(imgIdx,chip.pchips)
        -- self.rewardData_ = prd
        -- table.insert(self.rewardData_, prd)

		if self.view_ and self.view_.onPaymentDataGet then
			--todo
			self.view_:onPaymentDataGet(self.rewardData_)
		end

	end, function(errData)
		-- body
		dump(errData, "getPaymentList.errData: =================")

		self.loadPaymentReqId_ = nil
		if self.view_ and self.view_.onPaymentDataWrong then
			--todo
			self.view_:onPaymentDataWrong(errData)
		end
	end)
end

function FirChrgPgController:purchaseRewardBag()
	-- body
	-- dump(self.rewardData_, "self.rewardData_.data: ======================")

	self.quickPay_:makePurchase(PURCHASE_TYPE.BLUE_PAY, self.rewardData_.pid, self.rewardData_)
end

function FirChrgPgController:onConfigLoaded(ret, paytypeConfig)
	-- body

	-- dump(paytypeConfig,"PayGuide:onLoadPayConfig")
	-- if ret == 0 then
	-- 	local isServiceAvailable = self.quickPay_:isServiceAvailable(PURCHASE_TYPE.BLUE_PAY)
 --        local service = self.quickPay_:getPurchaseService(PURCHASE_TYPE.BLUE_PAY)
	-- 	--todo
	-- else

	-- end

	if ret ~= 0 then
		--todo
		dump("config Loaded Wrong!")
		if self.view_ and self.view_.loadingBar_ then
			--todo
			self.view_.loadingBar_:removeSelf()
			self.view_.loadingBar_ = nil
		end
	end
end

function FirChrgPgController:onPurchaseResultCallBack(isSucc, result)
	-- body
	self.view_.loadingBar_:removeSelf()
	self.view_.loadingBar_ = nil

	if isSucc then
		--todo
		nk.userData.best.paylog = 1  -- 充值记录
		nk.userData.best.ispay = 1  -- 付费筹码记录
		bm.DataProxy:setData(nk.dataKeys.CHARGEFAV_ONOFF, false)

		-- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false
		local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
		if nk.OnOff:check("rechargeFavGray") and rechargeFavAccess then
			--todo
			bm.DataProxy:setData(nk.dataKeys.ALMRECHARGEFAV_ONOFF, true)
		end
	end

	self.view_:hidePanel()
end

function FirChrgPgController:dispose()
	-- body
	if self.quickPay_ then
		--todo
		self.quickPay_:autoDispose()
		self.quickPay_ = nil
	end
	
	if self.loadPaymentReqId_ then
		--todo
		nk.http.cancel(self.loadPaymentReqId_)
	end
end

return FirChrgPgController