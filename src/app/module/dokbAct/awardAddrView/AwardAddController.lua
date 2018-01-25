--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-06-03 14:59:21
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: AwardAddController.lua By TsingZhang.
--

local AwardAddController = class("AwardAddController")

function AwardAddController:ctor(view)
	-- body
	self.view_ = view
end

function AwardAddController:getUserAddress(callback)
	-- body
	self.getDefaultUserAddrReq_ = nk.http.getUserAddress(function(retData)
		callback(retData)
	end,function(errData)
		self.getDefaultUserAddrReq_ = nil
		-- dump("getUserAddress.errData :===================")
	end)
end

function AwardAddController:saveUserAddress(info, alertAddrCallBack)
	-- body
	-- self.view_:setLoading(true)
	self.saveUserAddrReq_ = nk.http.saveUserAddress(info, function(retData)
			-- dump(retData, "saveUserAddress.retData :===================")

			nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "SAVEADDRESS_SUCCESS"))

			if alertAddrCallBack then
				--todo
				alertAddrCallBack()
			end
		end, function(errData)
			self.saveUserAddrReq_ = nil
			-- dump(errData, "saveUserAddress.errData :===================")

			nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "SAVEADDRESS_FAIL"))
			-- self.view_:setLoading(false)
		end
	)
end

function AwardAddController:dispose()
	-- body
	if self.getDefaultUserAddrReq_ then
		--todo
		nk.http.cancel(self.getDefaultUserAddrReq_)
	end

	if self.saveUserAddrReq_ then
		--todo
		nk.http.cancel(self.saveUserAddrReq_)
	end
end

return AwardAddController