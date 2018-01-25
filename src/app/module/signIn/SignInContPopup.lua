--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-11-04 17:44:05
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: SignInHelpPopup Signature Complement.
--

local panel = nk.ui.Panel
local TextureHandler = import(".TextureHandle")

local SignInHelpPopup = import(".SignInHelpPopup")
-- local SignInSuccPopup = import(".SignInSuccPopup")
local SignInModule = import(".SignInModule")
local LineCompon = import(".LineCompon")
local SignInPanelParam = {
	WIDTH = 865,
	HEIGHT = 552,

	frontSizes = {
		title = 30,
		tipsBottom = 18
	},

	colors = {
		title = cc.c3b(189, 189, 189),
		tipsBottom = cc.c3b(249, 211, 22)
	}
}

local SignInContPopup = class("SignInContPopup", panel)

function SignInContPopup:ctor()
	-- body
	self.super.ctor(self, {SignInPanelParam.WIDTH, SignInPanelParam.HEIGHT})
	self:setNodeEventEnabled(true)

	TextureHandler.loadTexture()

	self:initViews()
end

function SignInContPopup:initViews()
	-- body
	local titleBlockWidthFixEachSide = 0
	local titleBlockMagrinTop = 0

	local titleBlockParam = {
		WIDTH = SignInPanelParam.WIDTH - titleBlockWidthFixEachSide * 2,
		HEIGHT = 54
	}

	local titleBlock = display.newScale9Sprite("#signIn_blockTitle.png", 0, SignInPanelParam.HEIGHT / 2 - titleBlockParam.HEIGHT / 2 - titleBlockMagrinTop,
		cc.size(titleBlockParam.WIDTH, titleBlockParam.HEIGHT))
		:addTo(self)

	local titleLabel = display.newTTFLabel({text = bm.LangUtil.getText("CSIGNIN", "SIGNIN_MAIN_TITLE"), size = SignInPanelParam.frontSizes.title, color = SignInPanelParam.colors.title, algin = ui.TEXT_ALIGN_CENTER})
		:pos(titleBlockParam.WIDTH / 2, titleBlockParam.HEIGHT / 2)
		:addTo(titleBlock)

	local helpBtnMagrin = {
		top = 5,
		left = 15
	}

	local helpBtnSize = {
		width = 42,
		height = 42
	}

	local helpBtn = cc.ui.UIPushButton.new("#signIn_qMark.png", {scale9 = false})
		:onButtonClicked(buttontHandler(self, self._onHelpBtnCallBack))
		:pos(helpBtnSize.width / 2 + helpBtnMagrin.left, titleBlockParam.HEIGHT - helpBtnSize.height / 2 - helpBtnMagrin.top)
		:addTo(titleBlock)

	local closeBtnSize = {
		width = 42,
		height = 42
	}

	local closeBtnMagrin = {
		top = 8,
		right = 10
	}

	local closeBtnPosFix = {
		x = 10,
		y = 4
	}

	self:addCloseBtn()
	self.closeBtn_:pos(SignInPanelParam.WIDTH / 2 - closeBtnSize.width / 2 - closeBtnMagrin.right + closeBtnPosFix.x, SignInPanelParam.HEIGHT / 2 - closeBtnSize.height / 2 - closeBtnMagrin.top + closeBtnPosFix.y)

	local tipsBottomMagrinBottom = 8
	local tipsBottom = display.newTTFLabel({text = bm.LangUtil.getText("CSIGNIN", "SIGNIN_MAIN_TIPS_BOTOOM"), size = SignInPanelParam.frontSizes.tipsBottom, color = SignInPanelParam.colors.tipsBottom, align = ui.TEXT_ALIGN_CENTER})
	tipsBottom:pos(0, - SignInPanelParam.HEIGHT / 2 + tipsBottom:getContentSize().height / 2 + tipsBottomMagrinBottom)
		:addTo(self)

	self:drawMainSignInBlock()
end

function SignInContPopup:drawMainSignInBlock()
	-- body
	local signInMainBlockParam = {
		WIDTH = 852,
		HEIGHT = 455
	}

	local signInMainBlockMagrinBottom = 40

	local signInMainBlockPosYShift = 3
	self._signInMainBlockBg = display.newScale9Sprite("#signIn_blockMain.png", 0, - SignInPanelParam.HEIGHT / 2 + signInMainBlockParam.HEIGHT / 2 + signInMainBlockMagrinBottom - signInMainBlockPosYShift,
		cc.size(signInMainBlockParam.WIDTH, signInMainBlockParam.HEIGHT))
		:addTo(self)

	-- 这里可以独自抽出一个方法来，实现数据变更时的UI变更！--
end

function SignInContPopup:onGetSignInData(evt)
	-- body

	local signInDataList = SignInModule.getSignInDataList()

	if signInDataList then
		--todo
		self:setLoading(false)

		local signInMainBlockHeight = 455
		local lineComponParam = {
			WIDTH = 840,
			HEIGHT = 108
		}

		local lineComponMagrin = {
			top = 10,
			left = 8,
			eachLine = 2
		}

		local daysInOneLine = 8

		for i = 1, 4 do

			local componItemDataList = {}

			for j = 1, daysInOneLine do
				table.insert(componItemDataList, signInDataList[(i - 1) * daysInOneLine + j])
			end

			local lineItemCompon = LineCompon.new(componItemDataList, signInDataList.todayIdx)
				:pos(lineComponMagrin.left, signInMainBlockHeight - lineComponMagrin.top - lineComponParam.HEIGHT * i - lineComponMagrin.eachLine * (i - 1))
				:addTo(self._signInMainBlockBg)
		end
	else
		self:showBadNetDialog()
	end
	
end

function SignInContPopup:_onHelpBtnCallBack()
	-- body
	SignInHelpPopup.new():show()
	-- SignInSuccPopup.new({rewardType = 6, rewardNum = 20}):show()
end

function SignInContPopup:setLoading(isLoading)
	-- body
	if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, 0)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function SignInContPopup:showBadNetDialog()
	-- body
	if self.juhua_ then
		--todo
		self.juhua_:removeFromParent()
        self.juhua_ = nil
	end

	nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        SignInModule.getSignInDataFromSvr()
                        self:setLoading(true)
                    end
                end
    }):show()
end

function SignInContPopup:show()
	-- body
	self:showPanel_()
end

function SignInContPopup:onShowed()
	-- body
	SignInModule.getSignInDataFromSvr()
	self:setLoading(true)
end

function SignInContPopup:onEnter()
	-- body
	bm.EventCenter:addEventListener(nk.eventNames.SIGNIN_GET_DATA_SUCC, handler(self, self.onGetSignInData))
	bm.EventCenter:addEventListener(nk.eventNames.SIGNIN_GET_DATA_FAIL, handler(self, self.onGetSignInData))
end

function SignInContPopup:onExit()
	-- body
	TextureHandler.removeTexture()

	bm.EventCenter:removeEventListenersByEvent(nk.eventNames.SIGNIN_GET_DATA_SUCC)
	bm.EventCenter:removeEventListenersByEvent(nk.eventNames.SIGNIN_GET_DATA_FAIL)
end

function SignInContPopup:onCleanup()
	-- body
end

return SignInContPopup