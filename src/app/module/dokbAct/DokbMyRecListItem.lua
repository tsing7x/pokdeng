--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-30 17:25:13
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: DokbMyRecListItem.lua By TsingZhang.
--

local ScoreMarketView = import("app.module.scoreMarket.ScoreMarketView")

local AwardAddrComfirmPopup = import(".awardAddrView.AwardAddComfirmPopup")

local myRecListItemParam = {
	WIDTH = 866,
	HEIGHT = 56
}

local DokbMyRecListItem = class("DokbMyRecListItem", bm.ui.ListItem)

function DokbMyRecListItem:ctor()
	-- body
	self:setNodeEventEnabled(true)
	self.super.ctor(self, myRecListItemParam.WIDTH, myRecListItemParam.HEIGHT)

	local itemInfoLblParam = {
		frontSizes = {
			termId = 18,
			gemName = 18,
			lotryCode = 20,
			exprTime = 20,
			btnGetPriz = 18
		},
		colors = {
			termId = display.COLOR_WHITE,
			gemName = display.COLOR_WHITE,
			lotryCode = cc.c3b(143, 217, 92),
			exprTime = cc.c3b(196, 93, 95),
			btnGetPriz = display.COLOR_WHITE
		}
	}

	self.termId_ = display.newTTFLabel({text = "term Id", size = itemInfoLblParam.frontSizes.termId, color = itemInfoLblParam.colors.termId, align = ui.TEXT_ALIGN_CENTER})
		:pos(myRecListItemParam.WIDTH / 10, myRecListItemParam.HEIGHT / 2)
		:addTo(self)

	self.gemName_ = display.newTTFLabel({text = "gem Name", size = itemInfoLblParam.frontSizes.gemName, color = itemInfoLblParam.colors.gemName, align = ui.TEXT_ALIGN_CENTER})
		:pos(myRecListItemParam.WIDTH / 10 * 3, myRecListItemParam.HEIGHT / 2)
		:addTo(self)

	self.lotryCode_ = display.newTTFLabel({text = "lotry Code", size = itemInfoLblParam.frontSizes.lotryCode, color = itemInfoLblParam.colors.lotryCode, align = ui.TEXT_ALIGN_CENTER})
		:pos(myRecListItemParam.WIDTH / 10 * 5, myRecListItemParam.HEIGHT / 2)
		:addTo(self)

	self.exprTime_ = display.newTTFLabel({text = "19700101", size = itemInfoLblParam.frontSizes.exprTime, color = itemInfoLblParam.colors.exprTime, align = ui.TEXT_ALIGN_CENTER})
		:pos(myRecListItemParam.WIDTH / 10 * 7, myRecListItemParam.HEIGHT / 2)
		:addTo(self)

	local getPrizBtnSize = {
		width = 124,
		height = 42
	}

	self.getPrizBtn_ = cc.ui.UIPushButton.new({normal = "#common_btnGreenCor_nor.png", pressed = "#common_btnGreenCor_pre.png", disabled = "#dokb_btnGetRw_dis.png"}, {scale9 = true})
		:setButtonSize(getPrizBtnSize.width, getPrizBtnSize.height)
		:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "MYREC_GET_REWARD"), size = itemInfoLblParam.frontSizes.btnGetPriz, color = itemInfoLblParam.colors.btnGetPriz, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self.onGetPrizBtnCallBack_))
		:pos(myRecListItemParam.WIDTH / 10 * 9, myRecListItemParam.HEIGHT / 2)
		:addTo(self)

	self.getPrizBtn_:setButtonEnabled(false)
	self.isgetPrizBtnEnable = true

	local divdLineHeight = 2
	self.divdItemLine_ = display.newScale9Sprite("#dokb_divLine_recItem.png", myRecListItemParam.WIDTH / 2, 0, cc.size(myRecListItemParam.WIDTH, divdLineHeight))
		:addTo(self)
end

function DokbMyRecListItem:onDataSet(isChanged, data)
	-- body
	if isChanged then
		--todo
		self.lotryAttendData_ = data
		self.gemId_ = data.id
		-- self.termNum_ = data.time
		-- self.myLotryCode_ = data.treasurecode
		self.gemType_ = data.type or 1 -- 1:兑换卡; 2:实物

		self.awardId_ = data.rewardId
		-- self.exchangeName_ = nil
		-- self.exchangeCode_ = nil
		-- if self.gemType_ == 0 then
		-- 	--todo
		-- 	self.exchangeName_ = data.exchgName or "0000001"
		-- 	self.exchangeCode_ = data.exchgCode or "adc123456"
		-- end

		self.prizStatus_ = data.status or 3  -- 1:未领奖; 2:已领奖; 3:已过期

		self.termId_:setString(bm.LangUtil.getText("DOKB", "MYREC_TERM_NUM", data.time or "000000"))
		self.gemName_:setString(data.props or "Gem Name.")
		self.lotryCode_:setString(data.treasurecode or "Lotry Code.")
		self.exprTime_:setString(data.effectivetime or "19700101")

		self:refrshGetPrizBtnUi(self.prizStatus_)
	end
end

function DokbMyRecListItem:refrshGetPrizBtnUi(status)
	-- body
	local getPrizBtnLblParam = {
		frontSize = 18,
		color = display.COLOR_WHITE
	}

	local refreshBtnByStatus = {
		[1] = function()
			-- body
			self.getPrizBtn_:setButtonImage("normal", "#common_btnGreenCor_nor.png")
			self.getPrizBtn_:setButtonImage("pressed", "#common_btnGreenCor_pre.png")
			self.getPrizBtn_:setButtonImage("disabled", "#dokb_btnGetRw_dis.png")

			self.getPrizBtn_:setButtonEnabled(true)

			self.getPrizBtn_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "MYREC_GET_REWARD"), size = getPrizBtnLblParam.frontSize, color = getPrizBtnLblParam.color,
				align = ui.TEXT_ALIGN_CENTER}))
		end,

		[2] = function()
			-- body
			self.getPrizBtn_:setButtonImage("normal", "#chipChos_btn_quickPlay_nor.png")
			self.getPrizBtn_:setButtonImage("pressed", "#chipChos_btn_quickPlay_pre.png")
			self.getPrizBtn_:setButtonImage("disabled", "#dokb_btnGetRw_dis.png")

			self.getPrizBtn_:setButtonEnabled(true)

			self.getPrizBtn_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "MYREC_GETTED"), size = getPrizBtnLblParam.frontSize, color = getPrizBtnLblParam.color,
				align = ui.TEXT_ALIGN_CENTER}))
		end,

		[3] = function()
			-- body
			self.getPrizBtn_:setButtonImage("normal", "#common_btnGreenCor_nor.png")
			self.getPrizBtn_:setButtonImage("pressed", "#common_btnGreenCor_pre.png")
			self.getPrizBtn_:setButtonImage("disabled", "#dokb_btnGetRw_dis.png")

			self.getPrizBtn_:setButtonEnabled(false)

			self.getPrizBtn_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "MYREC_EXPIRED"), size = getPrizBtnLblParam.frontSize, color = getPrizBtnLblParam.color,
				align = ui.TEXT_ALIGN_CENTER}))
		end
	}

	refreshBtnByStatus[status]()
end

function DokbMyRecListItem:onGetPrizBtnCallBack_(evt)
	-- body
	if self.isgetPrizBtnEnable then
		--todo
		self.isgetPrizBtnEnable = false
		-- self:reqGetMyRewardPriz()
		if self.prizStatus_ == 1 then
			--todo

			if self.gemType_ == 1 then
				--todo
				self:reqGetMyRewardPriz()
			elseif self.gemType_ == 2 then
				--todo
				AwardAddrComfirmPopup.new():showPanel(handler(self, self.reqGetMyRewardPriz))
			end

			-- self.getMyRewardReq_ = nk.http.getDokbMyReward(self.awardId_, function(retData)
			-- 	-- body
			-- 	-- dump(retData, "getDokbMyReward.data :==================", 6)

			-- 	if self.gemType_ == 1 then
			-- 		--todo
			-- 		-- 兑换码提示
			-- 		nk.ui.Dialog.new({titleText = "领奖成功", messageText = "密码: " .. (retData.password or "ABC1234567"), secondBtnText = "复制", 
			-- 	        callback = function (type)
			-- 	            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
			-- 	            	nk.Native:setClipboardText(retData.password)
			-- 			        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "COPY_SUCCESS"))
			-- 	            end
			-- 	        end}):show()

			-- 	elseif self.gemType_ == 2 then
			-- 		--todo
			-- 		-- 地址确认框
			-- 		AwardAddrComfirmPopup.new():showPanel()
			-- 	end

			-- 	self.prizStatus_ = 2

			-- 	self.isgetPrizBtnEnable = true

			-- 	if self and self.refrshGetPrizBtnUi then
			-- 		--todo
			-- 		self:refrshGetPrizBtnUi(self.prizStatus_)
			-- 	end
			-- end, function(errData)
			-- 	-- body
			-- 	self.getMyRewardReq_ = nil
			-- 	-- dump(errData, "getDokbMyReward.errData :====================", 6)

			-- 	if errData.errorCode == - 2 then
			-- 		--todo
			-- 		nk.TopTipManager:showTopTip("领奖失败,奖励已过期！")

			-- 		self.prizStatus_ = 3

			-- 		if self and self.refrshGetPrizBtnUi then
			-- 			--todo
			-- 			self:refrshGetPrizBtnUi(self.prizStatus_)
			-- 		end

			-- 	else
			-- 		nk.TopTipManager:showTopTip("网络错误,领奖失败！")
			-- 	end

			-- 	self.isgetPrizBtnEnable = true
			-- end)
		else
			-- 已领奖,弹出兑换码消息框或者是地址确认框.
			if self.gemType_ == 1 then
				--todo
				-- 兑换码提示
				-- nk.ui.Dialog.new({titleText = "领奖成功", messageText = "卡号: " .. self.exchangeName_ .. "\n\n密码: "
				-- 	.. self.exchangeCode_, secondBtnText = "复制", 
				--         callback = function (type)
				--             if type == nk.ui.Dialog.SECOND_BTN_CLICK then
				--             	nk.Native:setClipboardText(self.gemPin_)
				-- 		        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET","COPY_SUCCESS"))
				--             end
				--         end}):show()
				
				-- 兑换商城 记录页兑换卡记录项
				display.addSpriteFrames("scoreMarket_th.plist", "scoreMarket_th.png", function()
					local recPageIdx = 2
					local cashCardGroup = 2

			        ScoreMarketView.new(recPageIdx, cashCardGroup):show()
			    end)

			elseif self.gemType_ == 2 then
				--todo
				-- 地址确认框
				-- AwardAddrComfirmPopup.new():showPanel()
				-- 兑换商城 记录实物兑换页项

				display.addSpriteFrames("scoreMarket_th.plist", "scoreMarket_th.png", function()
					local recPageIdx = 2
					local physGroup = 1
					
			        ScoreMarketView.new(recPageIdx, physGroup):show()
			    end)
			end

			self.isgetPrizBtnEnable = true
		end
	end
end

function DokbMyRecListItem:reqGetMyRewardPriz()
	-- body

	self.getMyRewardReq_ = nk.http.getDokbMyReward(self.awardId_, function(retData)
		-- body
		-- dump(retData, "getDokbMyReward.data :==================")

		if self.gemType_ == 1 then
			--todo
			-- 兑换码提示
			nk.ui.Dialog.new({titleText = bm.LangUtil.getText("DOKB", "MYREC_SUCC_GET_REWARD"), messageText = "PIN: " .. (retData.password or "ABC1234567"), secondBtnText = bm.LangUtil.getText("SCOREMARKET", "COPY"), 
		        callback = function (type)
		            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
		            	nk.Native:setClipboardText(retData.password)
				        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "COPY_SUCCESS"))
		            end
		        end}):show()

		elseif self.gemType_ == 2 then
			--todo
			-- 地址确认框
			-- AwardAddrComfirmPopup.new():showPanel()
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("DOKB", "MYREC_GETTED_REWARD"))
		end

		self.prizStatus_ = 2

		self.isgetPrizBtnEnable = true

		if self and self.refrshGetPrizBtnUi then
			--todo
			self:refrshGetPrizBtnUi(self.prizStatus_)
		end

	end, function(errData)
		-- body
		self.getMyRewardReq_ = nil
		-- dump(errData, "getDokbMyReward.errData :====================")

		if errData.errorCode == - 2 then
			--todo
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("DOKB", "MYREC_FAILD_EXPIRED"))

			self.prizStatus_ = 3

			if self and self.refrshGetPrizBtnUi then
				--todo
				self:refrshGetPrizBtnUi(self.prizStatus_)
			end

		else
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("DOKB", "MYREC_FAILD_BAD_NETWORK"))
		end

		self.isgetPrizBtnEnable = true

		-- nk.ui.Dialog.new({messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
	 --        callback = function (type)
	 --            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
	 --                self:reqGetMyRewardPriz()
	 --            end
	 --        end}):show()
	end)
end

function DokbMyRecListItem:onEnter()
	-- body
end

function DokbMyRecListItem:onExit()
	-- body
	if self.getMyRewardReq_ then
		--todo
		nk.http.cancel(self.getMyRewardReq_)
	end
end

function DokbMyRecListItem:onCleanup()
	-- body
end

return DokbMyRecListItem