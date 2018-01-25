--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-18 16:57:47
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: AgnChrgPgController By TsingZhang.
--

local QuickPurchaseServiceManager = import("..QuickPurchaseServiceManager")
local PURCHASE_TYPE = import("..PURCHASE_TYPE")

local AgnChrgPgController = class("AgnChrgPgController")

function AgnChrgPgController:ctor(view)
	-- body
	self:init()
	self.view_ = view
end

function AgnChrgPgController:init()
	-- body
	self.quickPay_ = QuickPurchaseServiceManager.new()
	self.quickPay_:setPurchaseCallback(handler(self, self.onPurchaseResultCallBack))
	self.quickPay_:loadPayConfig(handler(self, self.onConfigLoaded))
end

function AgnChrgPgController:getRechargeAlmFavPayment(packType)
	-- body
	-- self.loadPaymentReqId_ = nk.http.getAlmRechargePaymentList(packType, function(retData)
	
	self.loadPaymentReqId_ = nk.http.getAlmRechargePaymentList(packType, function(retData)
		-- body
		-- dump(retData, "getAlmRechargePaymentList.data: =====================")
		self.rewardData_ = {}
        -- local prd = {}
        self.rewardData_.pid = retData[1].pid or retData[1].id or ""
        self.rewardData_.id = retData[1].id
        self.rewardData_.sid = retData[1].sid
        self.rewardData_.appid = retData[1].appid
        self.rewardData_.pmode = retData[1].pmode
        self.rewardData_.pamount = retData[1].pamount
        self.rewardData_.discount = retData[1].discount
        self.rewardData_.pcoins = retData[1].pcoins
        self.rewardData_.pchips = retData[1].pchips
        self.rewardData_.pcard = retData[1].pcard
        self.rewardData_.ptype = retData[1].ptype
        self.rewardData_.pnum = retData[1].pnum
        self.rewardData_.getname = retData[1].getname
        self.rewardData_.desc = retData[1].desc
        self.rewardData_.stag = retData[1].stag
        self.rewardData_.currency= retData[1].currency
        self.rewardData_.prid= retData[1].prid
        self.rewardData_.expire= retData[1].expire
        self.rewardData_.state= retData[1].state
        self.rewardData_.device= retData[1].device
        self.rewardData_.sortid= retData[1].sortid
        self.rewardData_.etime= retData[1].etime
        self.rewardData_.status= retData[1].status
        self.rewardData_.use_status= retData[1].use_status
        self.rewardData_.item_id = retData[1].item_id

        --三公原有字段兼容处理
        self.rewardData_.price = retData[1].pamount or 0
        self.rewardData_.chipNum = retData[1].pchips or 0
        self.rewardData_.ticketNum = retData[1].pnum or 0
        self.rewardData_.cashCions = retData[1].pcoins or 0
        self.rewardData_.title = retData[1].getname or ""
        self.rewardData_.tag = retData[1]["tag"] == 1 and "hot" or (retData[1]["tag"] == 2 and "new" or "")
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
		dump(errData, "getAlmRechargePaymentList.errData: =================")

		self.loadPaymentReqId_ = nil
		if self.view_ and self.view_.onPaymentDataWrong then
			--todo
			self.view_:onPaymentDataWrong(errData)
		end
	end)

	self.packType_ = packType
end

function AgnChrgPgController:purchaseRewardBag()
	-- body
	self.quickPay_:makePurchase(PURCHASE_TYPE.BLUE_PAY, self.rewardData_.pid, self.rewardData_)
end

function AgnChrgPgController:onConfigLoaded(ret, paytypeConfig)
	-- body
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

function AgnChrgPgController:onPurchaseResultCallBack(isSucc, result)
	-- body
	self.view_.loadingBar_:removeSelf()
	self.view_.loadingBar_ = nil

	if isSucc then
		--todo
		-- nk.userData.best.paylog = 1  -- 充值记录
		-- nk.userData.best.ispay = 1  -- 付费筹码记录
		-- nk.userData.bagPayList.almRechgFav = 1  -- 慈善礼包已购买

		-- bm.DataProxy:setData(nk.dataKeys.ALMRECHARGEFAV_ONOFF, false)

		if self.packType_ == 0 then
			--todo
			nk.userData.bagPayList.type = 1
		else
			nk.userData.bagPayList.type = 0
		end

		nk.userData.bagPayList.access = 0

		bm.DataProxy:setData(nk.dataKeys.ALMRECHARGEFAV_ONOFF, false)
	end

	self.view_:hidePanel()
end

function AgnChrgPgController:dispose()
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

return AgnChrgPgController