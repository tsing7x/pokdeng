--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-30 20:45:42
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: DokbAttendActPopup.lua By TsingZhang.
--

local ResultAttendPopup = import(".DokbAttendActResultPopup")

local attendActPanelParam = {
	WIDTH = 622,
	HEIGHT = 366
}

local DokbAttendActPopup = class("DokbAttendActPopup", function()
	-- body
	return display.newNode()
end)

function DokbAttendActPopup:ctor(param)
	-- body
	self:setNodeEventEnabled(true)

	self.background_ = display.newScale9Sprite("#dokb_bgActPanel.png", 0, 0, cc.size(attendActPanelParam.WIDTH, attendActPanelParam.HEIGHT))
		:addTo(self)

	self.background_:setTouchEnabled(true)
	self.background_:setTouchSwallowEnabled(true)

	self:renderMainView(param)
	self:drawCloseBtn()
end

function DokbAttendActPopup:renderMainView(gemData)
	-- body
	self.gemId_ = gemData.id

	local bgDentBlockSize = {
		width = 555,
		height = 235
	}
	local bgDentMagrinTop = 15

	local bgDent = display.newScale9Sprite("#dokb_bgDent.png", attendActPanelParam.WIDTH / 2, attendActPanelParam.HEIGHT - bgDentBlockSize.height / 2
		- bgDentMagrinTop, cc.size(bgDentBlockSize.width, bgDentBlockSize.height))
		:addTo(self.background_)

	local gemFramePaddingTop = 62
	self.gemFrame_ = cc.ui.UIImage.new(--[["#chip_icon_icon.png"]])
	self.gemFrame_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
	self.gemFrame_:pos(bgDentBlockSize.width / 2, bgDentBlockSize.height - gemFramePaddingTop)
		:addTo(bgDent)

	self.gemFrameImgLoaderId_ = nk.ImageLoader:nextLoaderId()
	nk.ImageLoader:loadAndCacheImage(self.gemFrameImgLoaderId_, gemData.propsurl or "", handler(self, self.onGemFrameImgLoadComplete_))

	local attendInfoLblParam = {
		frontSizes = {
			gemName = 24,
			attdTips = 20,
			attdBtn = 22,
			argTermTips = 18
		},
		colors = {
			gemName = cc.c3b(241, 230, 112),
			attdTips = display.COLOR_WHITE,
			attdBtn = display.COLOR_WHITE,
			argTermTips = cc.c3b(101, 112, 182)
		}
	}

	local gemNamePosYAdj = 15
	local gemInfoShownBorderMagrin = 5

	self.gemName_ = display.newTTFLabel({text = gemData.props or "Gem Name.", size = attendInfoLblParam.frontSizes.gemName, color = attendInfoLblParam.colors.gemName, align = ui.TEXT_ALIGN_CENTER})
		:pos(bgDentBlockSize.width / 2, bgDentBlockSize.height / 2 - gemNamePosYAdj)
		:addTo(bgDent)

	-- local divdLineHeight = 2
	local divLineWidthFixHoriz = 40
	local dividLineContSize = {
		width = bgDentBlockSize.width - divLineWidthFixHoriz * 2,
		height = 2
	}
	local infoDividLineMagrinTop = 4

	local infoDvidLine = display.newScale9Sprite("#dokb_divLine_info.png", bgDentBlockSize.width / 2, self.gemName_:getPositionY() - self.gemName_:getContentSize().height / 2
		- infoDividLineMagrinTop, cc.size(dividLineContSize.width, dividLineContSize.height))
		:addTo(bgDent)

	local costTipStr = nil
	if gemData.price then
		--todo
		-- local attendPrice = json.decode(gemData.price)

		costTipStr = bm.LangUtil.getText("DOKB", "ATTENED_COST", bm.formatBigNumber(gemData.price.point or 0), bm.formatBigNumber(gemData.price.money or 0))
		-- "确定花费" .. bm.formatBigNumber(gemData.price.point or 0--[[attendPrice.point or 0]]) .. "现金币 + " .. bm.formatBigNumber(gemData.price.money or 0--[[attendPrice.money or 0]]) .. "筹码参与此次夺宝吗？"
	else
		costTipStr = bm.LangUtil.getText("DOKB", "ATTENED_COST", 0, 0)
		-- "确定花费0现金币 + 0筹码参与此次夺宝吗？"
	end

	-- 目前仅调整costTips显示宽度，仅有cosTips显示越界 -- 
	local costTipLblMagrinTop = 4
	self.attendCostTip_ = display.newTTFLabel({text = costTipStr, size = attendInfoLblParam.frontSizes.attdTips, color = attendInfoLblParam.colors.attdTips, 
		dimensions = cc.size(bgDentBlockSize.width - gemInfoShownBorderMagrin * 2, 0), align = ui.TEXT_ALIGN_LEFT})
	self.attendCostTip_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.attendCostTip_:pos(gemInfoShownBorderMagrin, infoDvidLine:getPositionY() - costTipLblMagrinTop - self.attendCostTip_:getContentSize().height / 2)
		:addTo(bgDent)

	local peopTipLblMagrinBot = 4
	self.peopChgceResTip_ = display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "ATTENDED_PEOPREST", (gemData.total or 0) - (gemData.nowcount or 0)), size = attendInfoLblParam.frontSizes.attdTips,
		color = attendInfoLblParam.colors.attdTips, align = ui.TEXT_ALIGN_CENTER})
	self.peopChgceResTip_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.peopChgceResTip_:pos(gemInfoShownBorderMagrin, peopTipLblMagrinBot + self.peopChgceResTip_:getContentSize().height / 2)
		:addTo(bgDent)

	local attdBtnPaddingBot = 50
	local attdBtnSize = {
		width = 130,
		height = 54
	}

	self.attendActBtn_ = cc.ui.UIPushButton.new({normal = "#common_btnGreenCor_nor.png", pressed = "#common_btnGreenCor_pre.png", disabled = "#common_btn_disabled.png"},
		{scale9 = true})
		:setButtonSize(attdBtnSize.width, attdBtnSize.height)
		:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "ATTENED_ENSURE"), size = attendInfoLblParam.frontSizes.attdBtn, color = attendInfoLblParam.colors.attdBtn, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self.onAttendBtnCallBack_))
		:pos(attendActPanelParam.WIDTH / 2, attdBtnSize.height / 2 + attdBtnPaddingBot)
		:addTo(self.background_)

	self.attendActBtn_:setButtonEnabled(false)
	self.attendActBtnEnable = true
	
	local argTipsChkBtnMagrinBot = 15
	local argTermsChkLblOffset = {
		x = 20,
		y = 0
	}

	local argTermsChkBtnSize = {
		width = 30,
		height = 30
	}

	self.argTermsChkBtn_ = cc.ui.UICheckBoxButton.new({off = "#dokb_chkAgrTerms_unSel.png", on = "#dokb_chkAgrTerms_sel.png"},
		{scale9 = false})
		:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DOKB", "ATTENDED_ARGTERM"), size = attendInfoLblParam.frontSizes.argTermTips, color = attendInfoLblParam.colors.argTermTips,
			align = ui.TEXT_ALIGN_CENTER}))
		:setButtonLabelOffset(argTermsChkLblOffset.x, argTermsChkLblOffset.y)
		:onButtonStateChanged(buttontHandler(self, self.onArgTermsChkBtnCallBack_))
		:align(display.LEFT_CENTER)

	local argTermsLabel = self.argTermsChkBtn_:getButtonLabel()
	self.argTermsChkBtn_:pos(attendActPanelParam.WIDTH / 2 - (argTermsChkBtnSize.width + argTermsLabel:getContentSize().width + argTermsChkLblOffset.x) / 2,
		argTipsChkBtnMagrinBot + argTermsChkBtnSize.height / 2)
		:addTo(self.background_)

	self.argTermsSelImg_ = display.newSprite("#dokb_qciAgr.png")
		:pos(argTermsChkBtnSize.width / 2, 0)
		:addTo(self.argTermsChkBtn_)
		:hide()

	self.argTermsChkBtn_:setButtonSelected(true)
end

function DokbAttendActPopup:drawCloseBtn()
	-- body
	local closBtnPosAdj = {
		x = 8,
		y = 8
	}

	local closeBtn = cc.ui.UIPushButton.new({normal = "#dokb_btnClose_nor.png", pressed = "#dokb_btnClose_pre.png", disabled = "#dokb_btnClose_nor.png"},
		{scale9 = false})
		:onButtonClicked(buttontHandler(self, self.onCloseBtnCallBack_))
		:pos(attendActPanelParam.WIDTH - closBtnPosAdj.x, attendActPanelParam.HEIGHT - closBtnPosAdj.y)
		:addTo(self.background_)
end

function DokbAttendActPopup:onAttendBtnCallBack_(evt)
	-- body
	if self.attendActBtnEnable then
		--todo
		self.attendActBtnEnable = false

		self.attendActReq_ = nk.http.attendActDokb(self.gemId_, function(retData)
			-- body
			-- dump(retData, "attendActDokb.data :=================")

			if self.attendActCallBack_ then
				--todo
				self.attendActCallBack_()
			end

			nk.userData["aUser.money"] = retData.money
			nk.userData["match.point"] = retData.point

			ResultAttendPopup.new({code = retData.treatureCode or "000000", type = 1}):showPanel()

			self.attendActBtnEnable = true

			if self and self.hidePanel then
				--todo
				self:hidePanel()
			end

		end, function(errData)
			-- body
			-- dump(errData, "attendActDokb.errData :==================")
			self.attendActReq_ = nil
			-- bm.LangUtil.getText("COMMON", "BAD_NETWORK")
			if errData.errorCode == - 1 then
				--todo
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("DOKB", "ATTENDED_FAILD_NOTENOUGH_PEOP"))
				-- nk.TopTipManager:showTopTip("夺宝失败,宝物不存在！")

				bm.EventCenter:dispatchEvent(nk.eventNames.DOKB_LOTRY_LOAD_NEXTROUND_RERESHDATA)
			elseif errData.errorCode == - 2 then
				--todo
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("DOKB", "ATTENED_FAILD_FINISHED"))

				bm.EventCenter:dispatchEvent(nk.eventNames.DOKB_LOTRY_LOAD_NEXTROUND_RERESHDATA)
			elseif errData.errorCode == - 3 then
				--todo
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("DOKB", "ATTENED_FAILD_EXPIRED"))

				bm.EventCenter:dispatchEvent(nk.eventNames.DOKB_LOTRY_LOAD_NEXTROUND_RERESHDATA)
			elseif errData.errorCode == - 4 then
				--todo
				ResultAttendPopup.new({type = 3}):showPanel()
			elseif errData.errorCode == - 5 then
				--todo
				ResultAttendPopup.new({type = 2}):showPanel()
			else
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
			end

			self.attendActBtnEnable = true
			
			if self and self.hidePanel then
				--todo
				self:hidePanel()
			end
		end)
	end
	
	-- ResultAttendPopup.new({code = 12234, type = 3}):showPanel()
end

function DokbAttendActPopup:onArgTermsChkBtnCallBack_(evt)
	-- body

	if evt.state == "on" then
		--todo
		self.argTermsSelImg_:show()
		self.attendActBtn_:setButtonEnabled(true)
	else
		self.argTermsSelImg_:hide()
		self.attendActBtn_:setButtonEnabled(false)
	end
end

function DokbAttendActPopup:onCloseBtnCallBack_(evt)
	-- body
	-- nk.PopupManager:removePopup(self)
	self:hidePanel()
end

function DokbAttendActPopup:onGemFrameImgLoadComplete_(success, sprite)
	-- body
	if success then
		--todo
		local tex = sprite:getTexture()
		local texSize = tex:getContentSize()

		-- local bgDentBlockSize = {
		-- 	width = 555,
		-- 	height = 235
		-- }
		-- local gemFramePaddingTop = 85

		local gemFrameShownSize = {
			width = 160,
			height = 100
		}
		if self and self.gemFrame_ then
			--todo
			self.gemFrame_:setTexture(tex)
			self.gemFrame_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
			-- self.gemFrame_:pos(bgDentBlockSize.width / 2 - texSize.width / 2, bgDentBlockSize.height - 
			-- 	gemFramePaddingTop)

			self.gemFrame_:setScaleX(gemFrameShownSize.width / texSize.width)
			self.gemFrame_:setScaleY(gemFrameShownSize.height / texSize.height)
		end
	end
end

function DokbAttendActPopup:showPanel(popEvtCallback, attendActCallBack)
	-- body
	self.popEvtCallBack_ = popEvtCallback
	self.attendActCallBack_ = attendActCallBack

	nk.PopupManager:addPopup(self)
end

function DokbAttendActPopup:hidePanel()
	-- body
	nk.PopupManager:removePopup(self)
end

function DokbAttendActPopup:onShowed()
	-- body
	if self and self.popEvtCallBack_ then
		--todo
		self.popEvtCallBack_()
	end
end

-- function DokbAttendActPopup:onRemovePopup(removeFunc)
-- 	-- body
-- 	removeFunc()
-- 	if self.popEvtCallBack_ then
-- 		--todo
-- 		self.popEvtCallBack_()
-- 	end
-- end

function DokbAttendActPopup:onEnter()
	-- body
end

function DokbAttendActPopup:onExit()
	-- body
	nk.ImageLoader:cancelJobByLoaderId(self.gemFrameImgLoaderId_)

	if self.attendActReq_ then
		--todo
		nk.http.cancel(self.attendActReq_)
	end
end

function DokbAttendActPopup:onCleanup()
	-- body
	if self.popEvtCallBack_ then
		--todo
		self.popEvtCallBack_()
	end
end

return DokbAttendActPopup