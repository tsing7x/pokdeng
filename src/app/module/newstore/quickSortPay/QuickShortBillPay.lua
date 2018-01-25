local QuickPurchaseServiceManager = import("app.module.newstore.QuickPurchaseServiceManager")
local PURCHASE_TYPE = import("app.module.newstore.PURCHASE_TYPE")

local QuickShortBillPay = class("QuickShortBillPay")

function QuickShortBillPay:ctor(isCashProd, billIdx)
	-- body
	self.isCashProd_ = isCashProd
	self.billIdx_ = billIdx or 1

	self:init()
end

function QuickShortBillPay:init()
	-- body
	if not self.quickPay_ then
		--todo
		self.quickPay_ = QuickPurchaseServiceManager.new()
	end

	self.quickPay_:loadPayConfig(handler(self, self.onConfigLoaded))
	self.quickPay_:setPurchaseCallback(handler(self, self.onPurchaseResultCallBack))
end

function QuickShortBillPay:onConfigLoaded(ret, paytypeConfig)
	-- body
	if ret == 0 then
		--todo
		local isServiceAvailable = self.quickPay_:isServiceAvailable(PURCHASE_TYPE.BLUE_PAY)
        local service = self.quickPay_:getPurchaseService(PURCHASE_TYPE.BLUE_PAY)

        if isServiceAvailable and service then
        	--todo
        	if self.isCashProd_ then
        		--todo
        		self.quickPay_:loadCashProductList(PURCHASE_TYPE.BLUE_PAY, function(config, isComplete, data)
        			-- body
        			if isComplete then
        				--todo
        				-- dump(data, "QuickShortBillPay:loadCashProductList.data :===================")

        				if data[self.billIdx_] then
        					--todo
        					self.quickPay_:makePurchase(PURCHASE_TYPE.BLUE_PAY, data[self.billIdx_].pid, data[self.billIdx_])
        				end
        			end
        		end)
        	else
        		self.quickPay_:loadChipProductList(PURCHASE_TYPE.BLUE_PAY, function(config, isComplete, data)
        			-- body
        			if isComplete then
        				--todo
        				-- dump(data, "QuickShortBillPay:loadChipProductList.data :===================")

        				if data[self.billIdx_] then
        					--todo
        					self.quickPay_:makePurchase(PURCHASE_TYPE.BLUE_PAY, data[self.billIdx_].pid, data[self.billIdx_])
        				end
        			end
        		end)
        	end
        end
	end
end

function QuickShortBillPay:onPurchaseResultCallBack(succ, result)
	-- body
	if succ then
		--todo
		nk.userData.best.paylog = 1

		if self.isCashProd_ then
			--todo
			dump("QuickShortBillPay :CashProd Purchase Succ!")
		else
			nk.userData.best.ispay = 1
			bm.DataProxy:setData(nk.dataKeys.CHARGEFAV_ONOFF, false)

			-- local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false
			local rechargeFavAccess = nk.userData.bagPayList and nk.userData.bagPayList.access == 1 or false
			if nk.OnOff:check("rechargeFavGray") and rechargeFavAccess then
				--todo
				bm.DataProxy:setData(nk.dataKeys.ALMRECHARGEFAV_ONOFF, true)
			end
		end
	end
end

return QuickShortBillPay