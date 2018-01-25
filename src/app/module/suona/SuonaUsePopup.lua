--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-12-03 18:20:48
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: SuonaUsePopup By tsing.
--

local TextureProcesser = import(".TexturePrcs")
local MsgRecListItem = import(".MsgLogRecItem")

local SuonaController = import(".SuonaController")
local SuonaUsePopup = class("SuonaUsePopup", nk.ui.Panel)

local SuonaUsePopupPanelParam = {
	WIDTH = 745,
	HEIGHT = 325
}

local TabButtonSize = {
	width = {
		nor = 180,
		sel = 180
	},

	height = {
		nor = 48,
		sel = 53
	}
}

local TabButtonIdxIconImg = {
	{nor = "suona_icTabSn_nor.png", sel = "suona_icTabSn_sel.png"},
	{nor = "suona_icTabRe_nor.png", sel = "suona_icTabRe_sel.png"}
}

function SuonaUsePopup:ctor(defaultTabIndex)
	-- body
	self.super.ctor(self, {SuonaUsePopupPanelParam.WIDTH, SuonaUsePopupPanelParam.HEIGHT})
	
	self.controller_ = SuonaController.new(self)
	self:setNodeEventEnabled(true)
	-- self:setTouchEnabled(true)  -- 这里在Panel类内部已经设置了点击事件，无需再进行设置。

	TextureProcesser.loadTexture()

	self:addCloseBtn()

	-- local str = nil
	-- str = "ห้องระดับต้นยังมี 2 ที่นั่งค่ะ เข้ามาร่วมรับชิปเงินสดกันสิ 5555 ขายชิปป็อกเด้งค่ะ"

	-- str = "หากเพื่อนคนไหนยังไม่มีชิปเงินสดมากพอที่จะไปแลกรางวัลจริง แคปรูปที่บัญทึก【ชิปเงินสดของฉัน】มาใต้โพสต์ก็ได้เหมือนกันนะคะ" ..
	-- 	"ระยะเวลากิจกรรมถึง 10 ก.ค. 59 นี้เท่านั้น  แอดมินจะแจกรางวัลหลังจบกิจกรรมภายใน 3 วันทำการนะจ๊ะ"
	-- str = "aa"

	self.controller_:updateUserMoneyWare()
	self.defaultTabIdx_ = defaultTabIndex or 1
	self:initViews()
end

function SuonaUsePopup:initViews()
	-- body
	local tabPageContSize = {
		width = 730,
		height = 250
	}
	local tabPageContPosYShift = 24

	local tabPageContBg = display.newScale9Sprite("#suona_bgMainDent.png", 0, - tabPageContPosYShift,
		cc.size(tabPageContSize.width, tabPageContSize.height))
		:addTo(self)

	local tabButtonImgSel = {
		"#suona_btnTabBarLeft_sel.png",
		"#suona_btnTabBarMid_sel.png"
	}

	local tabButtonIdxLabel = bm.LangUtil.getText("SUONA", "TAB_TEXT")
	-- {
	-- 	"小喇叭",
	-- 	"喇叭记录"
	-- }

	local tabButtonMagrins = {
		top = 12,
		left = 7,
		each = 5
	}

	self.tabBtnGroup = nk.ui.CheckBoxButtonGroup.new()

	self.tabButtons_ = {}

	local buttonIconMagrinLeft = 24
	local bgSelImgSizeHAdjust = 5

	local buttonLabelParam = {
		frontSize = 20,
		color = cc.c3b(31, 157, 234)
	}

	for i = 1, 2 do
		self.tabButtons_[i] = cc.ui.UICheckBoxButton.new({
			on = tabButtonImgSel[i],
            off = "#suona_btnTabBar.png"}, {scale9 = true})
			:setButtonSize(TabButtonSize.width.nor, TabButtonSize.height.nor)

		self.tabButtons_[i]:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_TOP])
		self.tabButtons_[i]:pos(- SuonaUsePopupPanelParam.WIDTH / 2 + tabButtonMagrins.left + TabButtonSize.width.nor / 2 * (2 * i - 1) + tabButtonMagrins.each * (i - 1),
				SuonaUsePopupPanelParam.HEIGHT / 2 - tabButtonMagrins.top)
			:addTo(self)

		self.tabButtons_[i].icon_ = display.newSprite("#" .. TabButtonIdxIconImg[i].nor)
		self.tabButtons_[i].icon_:pos(- TabButtonSize.width.nor / 2 + buttonIconMagrinLeft + self.tabButtons_[i].icon_:getContentSize().width / 2, 
			- TabButtonSize.height.nor / 2)
			:addTo(self.tabButtons_[i])

		self.tabButtons_[i].label_ = display.newTTFLabel({text = tabButtonIdxLabel[i], size = buttonLabelParam.frontSize, color = buttonLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
			:pos((buttonIconMagrinLeft + self.tabButtons_[i].icon_:getContentSize().width) / 2, - TabButtonSize.height.nor / 2)
			:addTo(self.tabButtons_[i])

		self.tabButtons_[i].bgSelLight_ = display.newScale9Sprite("#suona_bgTabBarImgSel.png", 0, - (TabButtonSize.height.nor + bgSelImgSizeHAdjust) / 2, cc.size(TabButtonSize.width.nor, TabButtonSize.height.nor + bgSelImgSizeHAdjust))
			:addTo(self.tabButtons_[i])
			:hide()

		self.tabBtnGroup:addButton(self.tabButtons_[i])
	end

	self.pageContContainer_ = display.newNode()
		:addTo(tabPageContBg)

	self.tabBtnGroup:onButtonSelectChanged(handler(self, self.onTabBtnSelChanged_))

	self.tabBtnGroup:getButtonAtIndex(self.defaultTabIdx_):setButtonSelected(true)

end

function SuonaUsePopup:drawPageCont(pageIdx)
	-- body
	local tabPageContSize = {
		width = 730,
		height = 250
	}

	local drawPageContByPageIndex = {
		[1] = function()
			-- body
			local pageCont = display.newNode()

			-- Main Block --
			local suonaSpeakerIconMagrins = {
				left = 15,
				top = 10
			}

			local suonaSpeakerIcon = display.newSprite("#suona_icSnSpeaker.png")
			suonaSpeakerIcon:pos(suonaSpeakerIconMagrins.left + suonaSpeakerIcon:getContentSize().width / 2,
				tabPageContSize.height - suonaSpeakerIconMagrins.top - suonaSpeakerIcon:getContentSize().height / 2)
				:addTo(pageCont)

			local inputTexBgSize = {
				width = 527,
				height = 56
			}

			-- local inputTextBg = display.newScale9Sprite("#suona_bgInputTex.png", suonaSpeakerIconMagrins.left + suonaSpeakerIcon:getContentSize().width + inputTexBgSize.width / 2,
			-- 	tabPageContSize.height - suonaSpeakerIconMagrins.top - inputTexBgSize.height / 2, cc.size(inputTexBgSize.width, inputTexBgSize.height))
			-- 	:addTo(pageCont)

			local inputContParam = {
				size = 20,
				color = display.COLOR_BLACK 
			}

			local inputTexEditPosYShift = 1
			self.inputTexEdit_ = cc.ui.UIInput.new({image = "#suona_bgInputTex.png", listener = handler(self, self.onSpeakInfoEdit_), size = cc.size(inputTexBgSize.width, inputTexBgSize.height)})
				:align(display.LEFT_CENTER, suonaSpeakerIconMagrins.left + suonaSpeakerIcon:getContentSize().width, tabPageContSize.height - suonaSpeakerIconMagrins.top - inputTexBgSize.height / 2 - inputTexEditPosYShift)
		        :addTo(pageCont)

			self.inputTexEdit_:setTouchSwallowEnabled(true)
			self.inputTexEdit_:setPlaceHolder(bm.LangUtil.getText("SUONA", "MAXMSGLENTH_TIP"))

			self.inputTexEdit_:setFontColor(inputContParam.color)
		    self.inputTexEdit_:setPlaceholderFontColor(inputContParam.color)
		    self.inputTexEdit_:setFont(ui.DEFAULT_TTF_FONT, inputContParam.size)
		    self.inputTexEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, inputContParam.size)
		    self.inputTexEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		    self.inputTexEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

			local sendBtnSize = {
				width = 130,
				height = 66
			}

			local sendBtnPosShift = {
				x = 6,
				y = 4
			}

			local sendBtnLabelParam = {
				frontSize = 22,
				color = display.COLOR_WHITE
			}
		    local sendBtn = cc.ui.UIPushButton.new("#suona_btnGreen.png", {scale9 = true})
		    	:setButtonSize(sendBtnSize.width, sendBtnSize.height)
		    	:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "SEND"), size = sendBtnLabelParam.frontSize, color = sendBtnLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
		    	:onButtonClicked(buttontHandler(self, self.onSendBtnCallBack_))
		    	:pos(suonaSpeakerIconMagrins.left + suonaSpeakerIcon:getContentSize().width + inputTexBgSize.width + sendBtnSize.width / 2 - sendBtnPosShift.x,
		    		tabPageContSize.height - suonaSpeakerIconMagrins.top - sendBtnSize.height / 2 + sendBtnPosShift.y)
		    	:addTo(pageCont)

		    -- sendBtn:setButtonEnabled(false)
		    -- Tips Below Block --
		    local suonaTipsBelowStr = bm.LangUtil.getText("SUONA", "USE_MAIN_TIPS")
		 --    {
		 --    	"1.每发送一条全服小喇叭需花费100000筹码",
		 --    	"2.每人每3分钟内只可发放一条全服小喇叭",
		 --    	"3.在线的人均可看到喇叭发言，大胆告白吧"
			-- }

			local tipsBelowMagrins = {
				left = 18,
				top = 25,
				eachLine = 10
			}

			local tipsBlowLabelParam = {
				frontSize = 18,
				color = cc.c3b(121, 121, 121)
			}

		    for i = 1, 3 do
		    	local tipsBelowLabel = display.newTTFLabel({text = suonaTipsBelowStr[i], size = tipsBlowLabelParam.frontSize, color = tipsBlowLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
		    	tipsBelowLabel:setAnchorPoint(display.ANCHOR_POINTS[display.LEFT_TOP])
	    		tipsBelowLabel:pos(tipsBelowMagrins.left, tabPageContSize.height - suonaSpeakerIconMagrins.top - inputTexBgSize.height - inputTexEditPosYShift 
	    			- tipsBelowMagrins.top - (tipsBelowLabel:getContentSize().height + tipsBelowMagrins.eachLine) * (i - 1))
		    		:addTo(pageCont)
		    end

		    -- Tips Bottom --
		    local tipsbottomLabelParam = {
		    	frontSize = 18,
		    	color = cc.c3b(181, 99, 18)
			}

		    local tipsBottomMagrinBottom = 12
		    local tipsBottom = display.newTTFLabel({text = bm.LangUtil.getText("SUONA", "USE_TIP_BOTTOM"), size = tipsbottomLabelParam.frontSize, color = tipsbottomLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
	    	tipsBottom:pos(tabPageContSize.width / 2, tipsBottom:getContentSize().height / 2 + tipsBottomMagrinBottom)
	    		:addTo(pageCont)

			return pageCont
		end,

		[2] = function()
			-- body
			local pageCont = display.newNode()

			-- MainInfo Block --
			local msgRecBgSize = {
				width = 710,
				height = 210
			}

			local msgRecBgMagrinTop = 10
			local msgRecordBlockBg = display.newScale9Sprite("#suona_bgMsgRecDent.png", tabPageContSize.width / 2, tabPageContSize.height - msgRecBgMagrinTop - msgRecBgSize.height / 2,
				cc.size(msgRecBgSize.width, msgRecBgSize.height))
				:addTo(pageCont)

			local msgLogRecListParam = {
				width = 688,
				height = 182
			}

			local msgRecListMagrinTop = 15
			self.msgRecList_ = bm.ui.ListView.new({viewRect = cc.rect(- msgLogRecListParam.width / 2, - msgLogRecListParam.height / 2, msgLogRecListParam.width, msgLogRecListParam.height),
				direction = bm.ui.ListView.DIRECTION_VERTICAL}, MsgRecListItem)
				:pos(msgRecBgSize.width / 2, msgRecBgSize.height / 2) -- tabPageContSize.width / 2 - msgLogRecListParam.width / 2, tabPageContSize.height - msgRecBgMagrinTop - msgRecListMagrinTop - msgLogRecListParam.height
				:addTo(msgRecordBlockBg)

			-- self.msgRecList_:setTouchEnabled(true)
			-- self.msgRecList_:setTouchSwallowEnabled(false)
			-- Tips Bottom --

			local tipsBottomLabelParam = {
				frontSize = 16,
				color = cc.c3b(118, 118, 118)
			}
			local tipsBottomLabelMagrinBottom = 8
			local tipsBottom = display.newTTFLabel({text = bm.LangUtil.getText("SUONA", "MSGREC_TIP_BOTTOM"), size = tipsBottomLabelParam.frontSize, color = tipsBottomLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
			tipsBottom:pos(tabPageContSize.width / 2, tipsBottomLabelMagrinBottom + tipsBottom:getContentSize().height / 2)
				:addTo(pageCont)

			-- 拉取消息记录 --
			self.controller_:getSuonaMsgRec()

			self.loadingBar_ = nk.ui.Juhua.new()
				:pos(tabPageContSize.width / 2, tabPageContSize.height / 2)
				:addTo(pageCont)
			-- 加载 loading --
			-- self.msgRecList_:setData({1, 2, 3, 4})
			
			return pageCont
		end
	}

	self.pages_ = self.pages_ or {}

	for _, page in pairs(self.pages_) do
        if page then
            --todo
            page:hide()
        end
    end

    local page = self.pages_[pageIdx]

    if not page then
    	--todo
    	page = drawPageContByPageIndex[pageIdx]()
    	self.pages_[pageIdx] = page
    	page:addTo(self.pageContContainer_)
    end

    page:show()

	-- drawPageContByPageIndex[pageIdx]()
end

function SuonaUsePopup:onTabBtnSelChanged_(evt)
	-- body

	local buttonLabelColor = {
		nor = cc.c3b(31, 157, 234),
		sel = display.COLOR_WHITE
	}

	if not self.selectedIdx_ then
		--todo
		self.selectedIdx_ = evt.selected

		self.tabButtons_[self.selectedIdx_]:setButtonSize(TabButtonSize.width.sel, TabButtonSize.height.sel)
		self.tabButtons_[self.selectedIdx_].icon_:setSpriteFrame(display.newSpriteFrame(TabButtonIdxIconImg[self.selectedIdx_].sel))
		self.tabButtons_[self.selectedIdx_].label_:setTextColor(buttonLabelColor.sel)
		self.tabButtons_[self.selectedIdx_].bgSelLight_:show()
	end

	local isChanged = self.selectedIdx_ ~= evt.selected

	if isChanged then
		--todo
		self.tabButtons_[self.selectedIdx_]:setButtonSize(TabButtonSize.width.nor, TabButtonSize.height.nor)
		self.tabButtons_[evt.selected]:setButtonSize(TabButtonSize.width.sel, TabButtonSize.height.sel)

		-- 修改前一个Button为常态
		self.tabButtons_[self.selectedIdx_].icon_:setSpriteFrame(display.newSpriteFrame(TabButtonIdxIconImg[self.selectedIdx_].nor))
		self.tabButtons_[self.selectedIdx_].label_:setTextColor(buttonLabelColor.nor)
		self.tabButtons_[self.selectedIdx_].bgSelLight_:hide()

		-- 修改点击Button为选中状态
		self.tabButtons_[evt.selected].icon_:setSpriteFrame(display.newSpriteFrame(TabButtonIdxIconImg[evt.selected].sel))
		self.tabButtons_[evt.selected].label_:setTextColor(buttonLabelColor.sel)
		self.tabButtons_[evt.selected].bgSelLight_:show()

		self.selectedIdx_ = evt.selected
	end

	self:drawPageCont(self.selectedIdx_)
end

function SuonaUsePopup:show()
	-- body
	self:showPanel_()
end

function SuonaUsePopup:onShowed()
	-- body
	-- if self.msgRecList_ then
	-- 	--todo
	-- 	self.msgRecList_:update()
	-- end
end

function SuonaUsePopup:onSpeakInfoEdit_(event)
	-- body
	if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化
        local text = self.inputTexEdit_:getText()
        local filteredText = nk.keyWordFilter(text)
        if filteredText ~= text then
            self.inputTexEdit_:setText(filteredText)
        end

        self.msgInfo_ = self.inputTexEdit_:getText()
        -- self.editNick_ = string.trim(self.inputTexEdit_:getText())
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
    end
end

function SuonaUsePopup:onSendBtnCallBack_()
	-- body
	if nk.userData.silenced == 1 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "USER_SILENCED_MSG"))
        return
    end
    
	if self.controller_.isUserMoneyUpdated_ then
		--todo
		-- 更新到了筹码数据才有操作
		
		if not self.msgInfo_ or string.utf8len(self.msgInfo_) <= 0 then
			--todo
			nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("SUONA", "EMPTY_MSG_TIP"), messageType = 1000})
		else

			local maxLenthCanSend = 223
			if string.utf8len(self.msgInfo_) > maxLenthCanSend then
				--todo
				nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("SUONA", "TOLONG_MSG_TIP"), messageType = 1000})
			else
				-- 加上金钱限制，userMoney < 2M 提示筹码不足
				-- local moneyNeedForBroadCastOnce = 2000000
				local moneyNeedForBroadCastOnce = 1
				if nk.userData["aUser.money"] < moneyNeedForBroadCastOnce then
					-- todo
					nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("SUONA", "NOTENOUGH_MONEY_TOSEND_TIP"), messageType = 1000})
				else
					self.controller_:sendSuonaMsg(self.msgInfo_)
				end
				self:hidePanel_()
			end
			
		end
	else
		nk.CenterTipManager:showCenterTip({text = bm.LangUtil.getText("SUONA", "WAITFOR_MONEY_UPDATE_TIP"), messageType = 1000})
	end
end

function SuonaUsePopup:onMsgRecDataGet(msgRecDataList)
	-- body
	if self.loadingBar_ then
        --todo
        self.loadingBar_:removeFromParent()
        self.loadingBar_ = nil
    end
    
	if self.msgRecList_ then
		--todo
		self.msgRecList_:update()
		-- self.msgRecList_:update()
	end

	self.msgRecList_:setData(msgRecDataList)
end

function SuonaUsePopup:onGetMsgRecError()
	-- body
	nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
                secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
                callback = function (type)
                    if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                        self.controller_:getSuonaMsgRec()
                    else
                        if self.loadingBar_ then
                            --todo
                            self.loadingBar_:removeFromParent()
                            self.loadingBar_ = nil
                        end
                    end
                end
        }):show()
end

function SuonaUsePopup:onEnter()
	-- body
end

function SuonaUsePopup:onExit()
	-- body
	TextureProcesser.removeTexture()
end

function SuonaUsePopup:onCleanup()
	-- body
	self.controller_:dispose()
end

return SuonaUsePopup