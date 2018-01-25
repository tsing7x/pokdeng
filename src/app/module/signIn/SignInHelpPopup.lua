--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-11-04 17:44:42
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: SignInHelpPopup Signature Complement.
--

local panel = nk.ui.Panel

local SignInHelpPanelParam = {
	WIDTH = 682,
	HEIGHT = 260,
}

local SignInHelpPopup = class("SignInHelpPopup", panel)

function SignInHelpPopup:ctor()
	-- body
	self.super.ctor(self, {SignInHelpPanelParam.WIDTH, SignInHelpPanelParam.HEIGHT})

	local closeBtnSize = {
		width = 42,
		height = 42
	}

	local closeBtnPosAdjust = {
		right = 6,
		top = 8
	}

	self:addCloseBtn()
	self.closeBtn_:pos(SignInHelpPanelParam.WIDTH / 2 - closeBtnSize.width / 2 - closeBtnPosAdjust.right, SignInHelpPanelParam.HEIGHT / 2 - closeBtnSize.height / 2 - closeBtnPosAdjust.top)

	self:drawMainTips()
end

function SignInHelpPopup:drawMainTips()
	-- body
	local tipsFrontSize = 20
	local tipsColor = cc.c3b(121, 145, 177)

	local tipsShownWidth = 576

	local tipsMagrin = {
		left = 45,
		eachLine = 35
	}

	local tipsLabelCont = bm.LangUtil.getText("CSIGNIN", "REWARD_DESC_TIPS")

	local tips2 = display.newTTFLabel({text = tipsLabelCont[2], size = tipsFrontSize, color = tipsColor, align = ui.TEXT_ALIGN_CENTER})
	tips2:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	tips2:pos(- SignInHelpPanelParam.WIDTH / 2 + tipsMagrin.left, 0)
		:addTo(self)

	local tips1 = display.newTTFLabel({text = tipsLabelCont[1], size = tipsFrontSize, color = tipsColor, dimensions = cc.size(tipsShownWidth, 0), align = ui.TEXT_ALIGN_LEFT})
	tips1:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	tips1:pos(- SignInHelpPanelParam.WIDTH / 2 + tipsMagrin.left, tipsMagrin.eachLine + tips1:getContentSize().height / 2)
		:addTo(self)

	local tips3 = display.newTTFLabel({text = tipsLabelCont[3], size = tipsFrontSize, color = tipsColor, dimensions = cc.size(tipsShownWidth, 0), algin = ui.TEXT_ALIGN_LEFT})
	tips3:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_CENTER])
	tips3:pos(- SignInHelpPanelParam.WIDTH / 2 + tipsMagrin.left, - (tipsMagrin.eachLine + tips3:getContentSize().height / 2))
		:addTo(self)
end

function SignInHelpPopup:show()
	-- body
	self:showPanel_()
end

return SignInHelpPopup