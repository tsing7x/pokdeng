--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-12-28 17:47:22
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: SuonaPopController By tsing.
--

local SuonaController = class("SuonaController")

function SuonaController:ctor(view)
	-- body
	self.view_ = view
end

function SuonaController:updateUserMoneyWare()
	-- body
	self.getUserMoneyUpdateReqId_ = nk.http.getMemberInfo(nk.userData["aUser.mid"],
		function(retData)
			nk.userData["aUser.money"] = retData.aUser.money or nk.userData["aUser.money"] or 0

			self.isUserMoneyUpdated_ = true

		end,

		function(errData)
			-- body
			self.isUserMoneyUpdated_ = true
			dump(errData, "SuonaController.updateUserMoney errData: ==============")
		end)
end

function SuonaController:sendSuonaMsg(suonaMsg)
	-- body
	self.broadcastSuonaMsgId_ = nk.http.broadcastSuonaMsg(suonaMsg, function(data)
		-- body
		-- dump(data, "sendSuonaMsg.data :===============")
		-- 更新筹码携带

			if data.money then
				--todo
				nk.userData["aUser.money"] = data.money

				local consumptionChip = checkint(data.addMoney)
				bm.EventCenter:dispatchEvent({name = nk.eventNames.UPDATE_SEAT_ANTE_CHIP, data = {chip = consumptionChip}})
			end

			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_INVITE_ONLINE")[5], messageType = 1000})
		end,

		function(errData)
			-- body
			-- 根据不同的状态码弹出提示
			dump(errData, "sendSuonaMsg.errData :==================")

			if errData.errorCode == -3 then
				--todo
				nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("SUONA", "SENDFREQ_TOOHIGH_TIP"), messageType = 1000})
			else
				nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("SUONA", "BADNETWORK_TIP"), messageType = 1000})
			end
		end)
end

function SuonaController:getSuonaMsgRec()
	-- body
	self.getSuonaMsgRecId_ = nk.http.getSuonaMsgRecord(function(data)
		-- body
		-- dump(data, "getSuonaMsgRecord.data :======================")

		self:formateMsgRecData(data)
	end,

	function(errData)
		-- body
		dump(errData, "getSuonaMsgRecord.errData :==============")

		-- 网络异常
		if self.view_ and self.view_.onGetMsgRecError then
			--todo
			self.view_:onGetMsgRecError()
		end
	end)
end

function SuonaController:formateMsgRecData(dataList)
	-- body
	local itemData = nil

	local msgSender = nil
	local msgContent = nil
	local msgSendTime = nil

	local msgRecDataList = {}
	for i = 1, #dataList do
		msgSender = dataList[i].name
		msgContent = dataList[i].content
		msgSendTime = os.date("%H:%M", dataList[i].time)

		itemData = msgSendTime .. " [" .. msgSender .. "]" .. bm.LangUtil.getText("SUONA", "SAY") .. msgContent

		table.insert(msgRecDataList, itemData)
	end

	if self.view_ and self.view_.onMsgRecDataGet then
		--todo
		self.view_:onMsgRecDataGet(msgRecDataList)
	end
end

function SuonaController:dispose()
	-- body
	-- if self.getUserMoneyUpdateReqId_ then
	-- 	--todo
	-- 	nk.http.cancel(self.getUserMoneyUpdateReqId_)
	-- end

	-- if self.broadcastSuonaMsgId_ then
	-- 	--todo
	-- 	nk.http.cancel(self.broadcastSuonaMsgId_)
	-- end

	if self.getSuonaMsgRecId_ then
		--todo
		nk.http.cancel(self.getSuonaMsgRecId_)
	end
end

return SuonaController