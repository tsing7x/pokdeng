--
-- Author: XT
-- Date: 2015-09-25 11:54:54
--Description: Modified By TsingZhang.

local comfirmPanelSize = {
    WIDTH = 675,
    HEIGHT = 522
}

-- local AwardAddController = import(".AwardAddController")
local AddrComboItem = import(".ScoreComboItem")

local ScoreAddressPopup = class("ScoreAddressPopup", nk.ui.Panel)

function ScoreAddressPopup:ctor(ctrl, callback)
    -- body
    self:setNodeEventEnabled(true)
    self.super.ctor(self, {comfirmPanelSize.WIDTH, comfirmPanelSize.HEIGHT})

    display.addSpriteFrames("awardAddr_comfirm.plist", "awardAddr_comfirm.png")
    self.controller_ = ctrl
    self:renderMainView()
    self.controller_:getUserAddress(handler(self, self.bindAddressInfo_))
end

function ScoreAddressPopup:renderMainView()
    -- body
    local bgTitleBlockSize = {
        width = 674,
        height = 60
    }

    local bgTitleBlock = display.newScale9Sprite("#awAddr_bgTitleBlock.png", 0, comfirmPanelSize.HEIGHT / 2 - bgTitleBlockSize.height / 2,
        cc.size(bgTitleBlockSize.width, bgTitleBlockSize.height))
        :addTo(self)

    local titleLblParam = {
        frontSize = 28,
        color = display.COLOR_WHITE
    }

    local titleLbl = display.newTTFLabel({text = bm.LangUtil.getText("RECVADDR", "RECV_INFO"), size = titleLblParam.frontSize, color = titleLblParam.color, align = ui.TEXT_ALIGN_CENTER})
        :pos(bgTitleBlockSize.width / 2, bgTitleBlockSize.height / 2)
        :addTo(bgTitleBlock)

    self:addCloseBtn()

    local mainInfoDentBlockSize = {
        width = 658,
        height = 322
    }

    local mainInfoDentBgMagrinTop = 8
    self.mainInfoEditBlockBgDent_ = display.newScale9Sprite("#awAddr_bgDent.png", 0, comfirmPanelSize.HEIGHT / 2 - bgTitleBlockSize.height
        - mainInfoDentBlockSize.height / 2 - mainInfoDentBgMagrinTop, cc.size(mainInfoDentBlockSize.width, mainInfoDentBlockSize.height))
        :addTo(self, 9)

    local infoMainInsLblParam = {
        frontSizes = {
            sizeNor = 25,
            nameEdit = 24,
            sexRbtnIns = 25,
            addrCombIns = 24,
            detAddrIns = 25,
            contactsEdit = 22
            -- tipsAnim = 22
        },

        colors = {
            colorNor = cc.c3b(181, 181, 181),
            nameEdit = cc.c3b(172, 200, 239),
            -- sexRbtnInsSel = display.COLOR_GREEN,
            addrCombIns = cc.c3b(77, 95, 119),
            detAddrIns = cc.c3b(172, 200, 239),
            contactsEdit = cc.c3b(172, 200, 239),
            -- tipsAnim = display.COLOR_BLACK
        }
    }

    local infoMainComponsMagrins = {
        infoInsLblMagrinLeft = 30,
        infoInsLblsMagrinTopBottom = 20,
        infoInsLblMagrinEach = 42,
        componMagrinInsLbl = 8
    }

    local infoMainInsLblStr = bm.LangUtil.getText("RECVADDR", "INFO_INS")
    -- {
    --     "我的姓名：",
    --     "我的性别：",
    --     "详细地址：",
    --     "手机号码：",
    --     "电子邮箱："
    -- }

    local infoStandardInsLabel = display.newTTFLabel({text = infoMainInsLblStr[1], size = infoMainInsLblParam.frontSizes.sizeNor, color = infoMainInsLblParam.colors.colorNor,
            align = ui.TEXT_ALIGN_CENTER})
    local infoMainInsLabelGapEach = (mainInfoDentBlockSize.height - infoMainComponsMagrins.infoInsLblsMagrinTopBottom * 2 - infoStandardInsLabel:getContentSize().height) / 4
   
    -- MainInfoIns --
    local infoMainInsLabels = {}

    for i = 1, #infoMainInsLblStr do
        infoMainInsLabels[i] = display.newTTFLabel({text = infoMainInsLblStr[i], size = infoMainInsLblParam.frontSizes.sizeNor, color = infoMainInsLblParam.colors.colorNor,
            align = ui.TEXT_ALIGN_CENTER})
        infoMainInsLabels[i]:pos(infoMainComponsMagrins.infoInsLblMagrinLeft + infoMainInsLabels[i]:getContentSize().width / 2, mainInfoDentBlockSize.height
            - infoMainComponsMagrins.infoInsLblsMagrinTopBottom - infoStandardInsLabel:getContentSize().height / 2 - infoMainInsLabelGapEach * (i - 1))
            :addTo(self.mainInfoEditBlockBgDent_)
    end

    -- EditName -- 
    local nameEditBoxSize = {
        width = 488,
        height = 46
    }

    local nameMaxLength = 128
    local nameEditBoxPosAdj = {
        x = 15,
        y = 0
    }

    self.nameEdit_ = cc.ui.UIInput.new({image = "#awAddr_bgEditBox.png", size = cc.size(nameEditBoxSize.width, nameEditBoxSize.height), listener = handler(self, self.onNameEdit_),
        x = infoMainInsLabels[1]:getPositionX() + infoMainInsLabels[1]:getContentSize().width / 2 + infoMainComponsMagrins.componMagrinInsLbl + nameEditBoxSize.width / 2 - nameEditBoxPosAdj.x,
            y = infoMainInsLabels[1]:getPositionY() + nameEditBoxPosAdj.y})
        :addTo(self.mainInfoEditBlockBgDent_)

    self.nameEdit_:setFont(ui.DEFAULT_TTF_FONT, infoMainInsLblParam.frontSizes.nameEdit)
    self.nameEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, infoMainInsLblParam.frontSizes.nameEdit)
    self.nameEdit_:setMaxLength(nameMaxLength)
    self.nameEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "USER_NAME"))
    self.nameEdit_:setPlaceholderFontColor(infoMainInsLblParam.colors.nameEdit)
    self.nameEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.nameEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    -- self.alertN_ = display.newTTFLabel({text = "*", color = cc.c3b(0xFF, 0x0, 0x0), size = 32, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(cfgi.px + sz.width - offx + bdw + 10, cfgi.py + offy)
    --     :addTo(self.mainInfoEditBlockBgDent_)
    --     :hide()

    -- SexCheckBtn --
    self.sexCheckBtnGroup_ = nk.ui.CheckBoxButtonGroup.new()

    local rdbtnLabelOffset = {
        x = 30,
        y = 0
    }

    local sexRdbtnGap = 150

    self.sexChkBtns = {}
    self.sexChkBtns[1] = cc.ui.UICheckBoxButton.new({on = "#awAddr_rdbtn_sel.png", off = "#awAddr_rdbtn_unSel.png"}, {scale9 = false})
        -- :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "MAN"), size = infoMainInsLblParam.frontSizes.sexRbtnIns, color = infoMainInsLblParam.colors.colorNor,
        --     align = ui.TEXT_ALIGN_CENTER}))
        -- :setButtonLabelOffset(rdbtnLabelOffset.x, rdbtnLabelOffset.y)
        :pos(infoMainInsLabels[2]:getPositionX() + infoMainInsLabels[2]:getContentSize().width / 2 + infoMainComponsMagrins.componMagrinInsLbl, infoMainInsLabels[2]:getPositionY())
        :addTo(self.mainInfoEditBlockBgDent_)

    self.sexChkBtns[1].label_ = display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "MAN"), size = infoMainInsLblParam.frontSizes.sexRbtnIns, color = display.COLOR_WHITE,
        align = ui.TEXT_ALIGN_CENTER})
    self.sexChkBtns[1].label_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    self.sexChkBtns[1].label_:pos(rdbtnLabelOffset.x, rdbtnLabelOffset.y)
        :addTo(self.sexChkBtns[1])

    self.sexCheckBtnGroup_:addButton(self.sexChkBtns[1])

    self.sexChkBtns[2] = cc.ui.UICheckBoxButton.new({on = "#awAddr_rdbtn_sel.png", off = "#awAddr_rdbtn_unSel.png"}, {scale9 = false})
        -- :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "FEMALE"), size = infoMainInsLblParam.frontSizes.sexRbtnIns, color = infoMainInsLblParam.colors.colorNor,
        --     align = ui.TEXT_ALIGN_CENTER}))
        -- :setButtonLabelOffset(rdbtnLabelOffset.x, rdbtnLabelOffset.y)
        :pos(self.sexChkBtns[1]:getPositionX() + sexRdbtnGap, infoMainInsLabels[2]:getPositionY())
        :addTo(self.mainInfoEditBlockBgDent_)

    self.sexChkBtns[2].label_ = display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "FEMALE"), size = infoMainInsLblParam.frontSizes.sexRbtnIns, color = display.COLOR_WHITE,
        align = ui.TEXT_ALIGN_CENTER})
    self.sexChkBtns[2].label_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    self.sexChkBtns[2].label_:pos(rdbtnLabelOffset.x, rdbtnLabelOffset.y)
        :addTo(self.sexChkBtns[2])

    self.sexCheckBtnGroup_:addButton(self.sexChkBtns[2])

    self.sexCheckBtnGroup_:onButtonSelectChanged(handler(self, self.onSexRdBtnSelChangeCallBack_))

    local sexIdx = nil

    if nk.userData["aUser.msex"] == 2 or nk.userData["aUser.msex"] == 0 then
        --todo
        sexIdx = 2
    else
        sexIdx = 1
    end
    self.sexCheckBtnGroup_:getButtonAtIndex(sexIdx):setButtonSelected(true)

    -- AddrDetail --
    local comboxItemParam = {
        width = 146,
        height = 42
        -- lblFrontSize = 18
    }

    local comboxViewPosAdj = {
        x = 15,
        y = 0
    }

    local params = {}
    params.itemCls = AddrComboItem
    params.listWidth = comboxItemParam.width
    params.listHeight = comboxItemParam.height * 7
    params.listOffY = - comboxItemParam.height / 2
    params.borderSize = cc.size(comboxItemParam.width, comboxItemParam.height)
    params.lblSize = infoMainInsLblParam.frontSizes.addrCombIns
    params.lblcolor = infoMainInsLblParam.colors.addrCombIns
    params.barNoScale = true
    self.combo_ = nk.ui.ComboboxView.new(params)
        :pos(infoMainInsLabels[3]:getPositionX() + infoMainInsLabels[3]:getContentSize().width / 2 + infoMainComponsMagrins.componMagrinInsLbl + comboxItemParam.width / 2 - comboxViewPosAdj.x,
            infoMainInsLabels[3]:getPositionY() + comboxViewPosAdj.y)
        :addTo(self.mainInfoEditBlockBgDent_, 99)

    local cityDataList = bm.LangUtil.getText("SCOREMARKET", "CITY")
    self.combo_:setData(cityDataList, cityDataList[1])

    local addrEditBoxSize = {
        width = 330,
        height = 46
    }

    local addrDetMaxLength = 128
    local addrDetEditBoxMagrinLeft = 8
    self.addressEdit_ = cc.ui.UIInput.new({image = "#awAddr_bgEditBox.png", size = cc.size(addrEditBoxSize.width, addrEditBoxSize.height), listener = handler(self, self.onAddressEdit_),
        x = self.combo_:getPositionX() + comboxItemParam.width / 2 + addrDetEditBoxMagrinLeft + addrEditBoxSize.width / 2, y = infoMainInsLabels[3]:getPositionY()})
        :addTo(self.mainInfoEditBlockBgDent_)

    self.addressEdit_:setFont(ui.DEFAULT_TTF_FONT, infoMainInsLblParam.frontSizes.detAddrIns)
    self.addressEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, infoMainInsLblParam.frontSizes.detAddrIns)
    self.addressEdit_:setMaxLength(addrDetMaxLength)
    self.addressEdit_:setPlaceholderFontColor(infoMainInsLblParam.colors.detAddrIns)
    self.addressEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.addressEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.addressEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "DETAIL_ADDRESS"))
    -- self.alertA_ = display.newTTFLabel({text = "*", color = cc.c3b(0xFF, 0x0, 0x0), size = 32, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(cfgi.px + sz.width - offx + bdw + 10, cfgi.py + offy)
    --     :addTo(self.mainInfoEditBlockBgDent_)
    --     :hide()

    -- TelNum && EmailAddr-- 
    local contactsEditBoxSize = {
        width = 332,
        height = 46
    }

    local contactsEditBoxPosAdj = {
        x = 0,
        y = 0
    }

    local telMaxLength = 10
    self.telEdit_ = cc.ui.UIInput.new({image = "#awAddr_bgEditBox.png", size = cc.size(contactsEditBoxSize.width, contactsEditBoxSize.height), listener = handler(self, self.onTelEdit_),
        x = infoMainInsLabels[4]:getPositionX() + infoMainInsLabels[4]:getContentSize().width / 2 + infoMainComponsMagrins.componMagrinInsLbl + contactsEditBoxSize.width / 2 
            - contactsEditBoxPosAdj.x, y = infoMainInsLabels[4]:getPositionY() + contactsEditBoxPosAdj.y})
        :addTo(self.mainInfoEditBlockBgDent_)

    self.telEdit_:setFont(ui.DEFAULT_TTF_FONT, infoMainInsLblParam.frontSizes.contactsEdit)
    self.telEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, infoMainInsLblParam.frontSizes.contactsEdit)
    self.telEdit_:setMaxLength(telMaxLength)
    self.telEdit_:setPlaceholderFontColor(infoMainInsLblParam.colors.contactsEdit)
    self.telEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.telEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.telEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "MOBEL_TEL"))
    -- self.alertT_ = display.newTTFLabel({text = "**", color = cc.c3b(0xf7, 0xa5, 0x08), size = 35, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(cfgi.px + sz.width - offx + bdw + 13, cfgi.py + offy)
    --     :addTo(self.mainInfoEditBlockBgDent_)
    --     :hide()

    local emailMaxLength = 32
    self.emailEdit_ = cc.ui.UIInput.new({image = "#awAddr_bgEditBox.png", size = cc.size(contactsEditBoxSize.width, contactsEditBoxSize.height), listener = handler(self, self.onEmailEdit_),
        x = infoMainInsLabels[5]:getPositionX() + infoMainInsLabels[5]:getContentSize().width / 2 + infoMainComponsMagrins.componMagrinInsLbl + contactsEditBoxSize.width / 2 
            - contactsEditBoxPosAdj.x, y = infoMainInsLabels[5]:getPositionY() + contactsEditBoxPosAdj.y})
        :addTo(self.mainInfoEditBlockBgDent_)

    self.emailEdit_:setFont(ui.DEFAULT_TTF_FONT, infoMainInsLblParam.frontSizes.contactsEdit)
    self.emailEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, infoMainInsLblParam.frontSizes.contactsEdit)
    self.emailEdit_:setMaxLength(emailMaxLength)
    self.emailEdit_:setPlaceholderFontColor(infoMainInsLblParam.colors.contactsEdit)
    self.emailEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.emailEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.emailEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "EMAIL"))

    -- self.alertE_ = display.newTTFLabel({text = "*", color = cc.c3b(0xFF, 0x0, 0x0), size = 32, align = ui.TEXT_ALIGN_CENTER})
    --  :pos(cfgi.px + sz.width - offx + 320 + 10, cfgi.py + offy)
    --  :addTo(self.mainInfoEditBlockBgDent_)
    --  :hide()

    -- AreaBelow -- 
    -- AgreeTermsBtn -- 
    local infoBelowLblParam = {
        frontSizes = {
            argTerms = 20,
            updInfoBtn = 26,
            tipBot = 15
        },
        colors = {
            argTerms = cc.c3b(117, 136, 192),
            updInfoBtn = display.COLOR_WHITE,
            tipBot = cc.c3b(104, 172, 193)
        }
    }

    local argTermChkBtnSize = {
        width = 30,
        height = 30
    }

    local argTermsChkLblOffset = {
        x = 20,
        y = 0
    }

    local argTermChkBtnMagrinTop = 2
    self.argTermsChkBtn_ = cc.ui.UICheckBoxButton.new({on = "#awAddr_chkAgrTerms_sel.png", off = "#awAddr_chkAgrTerms_unSel.png"}, {scale9 = false})
        :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("RECVADDR", "ENSURE_INFO"), size = infoBelowLblParam.frontSizes.argTerms, color = infoBelowLblParam.colors.argTerms, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(argTermsChkLblOffset.x, argTermsChkLblOffset.y)
        :onButtonStateChanged(buttontHandler(self, self.onArgTermsChkBtnCallBack_))
        :align(display.LEFT_CENTER)

    local argTermsLabel = self.argTermsChkBtn_:getButtonLabel()

    self.argTermsChkBtn_:pos(- (argTermChkBtnSize.width + argTermsLabel:getContentSize().width + argTermsChkLblOffset.x) / 2,
        self.mainInfoEditBlockBgDent_:getPositionY() - mainInfoDentBlockSize.height / 2 - argTermChkBtnSize.height / 2 - argTermChkBtnMagrinTop)
        :addTo(self)

    self.argTermsSelImg_ = display.newSprite("#awAddr_qciAgr.png")
        :pos(argTermChkBtnSize.width / 2, 0)
        :addTo(self.argTermsChkBtn_)

    -- updInfoBtn --
    local updAddrBtnSize = {
        width = 214,
        height = 66
    }

    local updAddrBtnMagrinBot = 30

    self.updAddrInfoBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(updAddrBtnSize.width, updAddrBtnSize.height)
        :setButtonLabel(display.newTTFLabel({text =  bm.LangUtil.getText("RECVADDR", "UPDATE_INFO"), size = infoBelowLblParam.frontSizes.updInfoBtn, color = infoBelowLblParam.colors.updInfoBtn, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.onUpdateAddrInfoCallBack_))
        :pos(0, - comfirmPanelSize.HEIGHT / 2 + updAddrBtnMagrinBot + updAddrBtnSize.height / 2)
        :addTo(self)

    local tipBotMagrinBot = 8

    local finalBotTips = display.newTTFLabel({text = bm.LangUtil.getText("RECVADDR", "DISCLAIM"), size = infoBelowLblParam.frontSizes.tipBot, color = infoBelowLblParam.colors.tipBot,
        align = ui.TEXT_ALIGN_CENTER})
    finalBotTips:pos(0, - comfirmPanelSize.HEIGHT / 2 + tipBotMagrinBot + finalBotTips:getContentSize().height / 2)
        :addTo(self)

    self.argTermsChkBtn_:setButtonSelected(true)

    self.editEmail_ = ""
    self.editTel_ = ""
    self.editAddress_ = ""
    self.editNick_ = ""

    -- Anims --
    local AnimTipsPanelMagrinLeft = 5

    -- 填写格式暂时先写死,后面可能会改为翻译控制中泰文切换
    local fillTipsTel = "เช่น 084555555"
    local fillTipsEmail = "เช่น tsingZhang@boyaa.com"

    self:addAlertPopup(self.telEdit_:getPositionX() + contactsEditBoxSize.width / 2 + AnimTipsPanelMagrinLeft, self.telEdit_:getPositionY(), fillTipsTel)  -- AnimTelTips --
    self:addAlertPopup(self.emailEdit_:getPositionX() + contactsEditBoxSize.width / 2 + AnimTipsPanelMagrinLeft, self.emailEdit_:getPositionY(), fillTipsEmail)  -- AnimEmailTips --

    self.infoEditBoxList_ = {
        self.nameEdit_,
        self.addressEdit_,
        self.telEdit_,
        self.emailEdit_
    }

    for i, editbox in ipairs(self.infoEditBoxList_) do
        nk.EditBoxManager:addEditBox(editbox)
    end
end

function ScoreAddressPopup:addAlertPopup(px, py, text)
    -- body
    local tipsLblFrontSize = 22
    local tipsLabel = display.newTTFLabel({text = text, color = display.COLOR_BLACK, size = tipsLblFrontSize, align = ui.TEXT_ALIGN_CENTER})

    local tipsLblSize = tipsLabel:getContentSize()
    local tipsLblMagrins = {
        horizEach = 15,
        vertiEach = 5
    }

    local panelBorderSize = {
        width = tipsLblSize.width + tipsLblMagrins.horizEach * 2,
        height = tipsLblSize.height + tipsLblMagrins.vertiEach * 2
    }

    local borderPanelRectParam = {
        x = 20,
        y = 10,
        width = 15,
        height = 28
    }

    local aborderPanel = display.newScale9Sprite("#awAddr_bgRollTip.png", 0, 0, cc.size(panelBorderSize.width, panelBorderSize.height), cc.rect(borderPanelRectParam.x, borderPanelRectParam.y, 
        borderPanelRectParam.width, borderPanelRectParam.height))

    local alertPopup_ = display.newNode()
        :pos(px, py)
        :addTo(self.mainInfoEditBlockBgDent_)
        

    tipsLabel:pos(panelBorderSize.width / 2, panelBorderSize.height / 2)
        :addTo(aborderPanel)

    aborderPanel:pos(panelBorderSize.width / 2, 0)
        :addTo(alertPopup_)

    alertPopup_:runAction(cc.RepeatForever:create(transition.sequence({
            cc.MoveBy:create(0.6, cc.p(10, 0)),            -- cc.DelayTime:create(0.3),
            cc.MoveBy:create(0.6, cc.p(-10, 0)),            -- cc.DelayTime:create(0.1),
        })))

    return alertPopup_
end

function ScoreAddressPopup:onNameEdit_(event)
    -- body
    if event == "began" then
    elseif event == "changed" then
        local text = self.nameEdit_:getText()
        local filteredText = nk.keyWordFilter(text)

        if filteredText ~= text then
            self.nameEdit_:setText(filteredText)
        end
        self.editNick_ = self.nameEdit_:getText()

        -- print(self.editNick_)
        -- if self.editNick_ ~= "" then
        --     self.alertN_:hide()
        -- else
        --    self.alertN_:show();
        -- end
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
        -- print(self.editNick_)
    end
end

function ScoreAddressPopup:onSexRdBtnSelChangeCallBack_(evt)
    -- body
    if evt.selected == 1 then
        --todo
        self.sexChkBtns[1].label_:setTextColor(cc.c3b(152, 229, 228))
        self.sexChkBtns[2].label_:setTextColor(display.COLOR_WHITE)
    else
        self.sexChkBtns[1].label_:setTextColor(display.COLOR_WHITE)
        self.sexChkBtns[2].label_:setTextColor(cc.c3b(152, 229, 228))
    end
    self.sexIndex_ = evt.selected
end

function ScoreAddressPopup:onTelEdit_(event)
    -- body
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then

        if device.platform == "android" then
        -- 输入框内容发生变化
            local text = self.telEdit_:getText()
            if string.find(text, "^[+-]?%d+$") then

                local textTrim = string.trim(text)
                local len = string.len(textTrim)

                if len < 9 then
                   text = ""
                end

                textTrim = string.trim(text)
                self.telEdit_:setText(textTrim)

                self.editTel_ = textTrim
                
            else
                -- 输入字符非法
                self.editTel_ = self.editTel_ or ""
                self.telEdit_:setText(self.editTel_)
            end
            -- 
            -- if self.editTel_ ~= "" then
            --     self.alertT_:hide()
            -- else
            --     self.alertT_:show()
            -- end
        else
            local text = self.telEdit_:getText()
            local textTrim = string.trim(text)
            self.telEdit_:setText(textTrim)
            self.editTel_ = textTrim
        end
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
        -- print(self.editTel_)
    end
end

function ScoreAddressPopup:onAddressEdit_(event)
    -- body
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化self.addressEdit_
        local text = self.addressEdit_:getText()
        local filteredText = nk.keyWordFilter(text)
        if filteredText ~= text then
            self.addressEdit_:setText(filteredText)
        end

        text = self.addressEdit_:getText()

        local addrTextLenthReal = string.len(string.trim(text))
        if addrTextLenthReal <= 0 then
            --todo
            text = ""
            self.addressEdit_:setText(text)
        end

        self.editAddress_ = text
        -- if self.editAddress_ ~= "" then
        --     self.alertA_:hide()
        -- else
        --     self.alertA_:show()
        -- end
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
        -- print(self.editAddress_)
    end
end

function ScoreAddressPopup:onEmailEdit_(event)
    -- body
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化
        local text = string.trim(self.emailEdit_:getText())
        local filteredText = nk.keyWordFilter(text)

        if filteredText ~= text then
            --todo
            self.emailEdit_:setText(filteredText)
        end

        -- if self:isRightEmail(text) then
        --     --todo
        -- end
        self.editEmail_ = self.emailEdit_:getText()

    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
        -- print(self.editTel_)
    end
end

function ScoreAddressPopup:onArgTermsChkBtnCallBack_(evt)
    -- body
    if evt.state == "on" then
        --todo
        self.argTermsSelImg_:show()
        self.updAddrInfoBtn_:setButtonEnabled(true)
    else
        self.argTermsSelImg_:hide()
        self.updAddrInfoBtn_:setButtonEnabled(false)
    end
end

function ScoreAddressPopup:onUpdateAddrInfoCallBack_()
    -- body
    self.updAddrInfoBtn_:setButtonEnabled(false)

    local result = nil

    local params = {}
    params.name = self.editNick_ or ""

    if params.name == nil or params.name == "" then
        -- self.alertN_:show()
        result = bm.LangUtil.getText("SCOREMARKET", "USER_NAME")
    end
    
    params.tel = self.editTel_

    if params.tel == nil or params.tel == "" then
        -- self.alertT_:show()
        result = bm.LangUtil.getText("SCOREMARKET", "MOBEL_TEL")
    end

    params.address = self.editAddress_ or ""

    if params.address == nil or params.address == "" then
        -- self.alertA_:show()
        result = bm.LangUtil.getText("SCOREMARKET", "DETAIL_ADDRESS")
    end

    params.mail = self.editEmail_ or ""

    if params.mail == nil or params.mail == "" then
        -- self.alertE_:show()
        result = bm.LangUtil.getText("SCOREMARKET", "EMAIL")
    end

    if result then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "ALERT_WRITEADDRESS", result))
        self.updAddrInfoBtn_:setButtonEnabled(true)
        return
    end

     params.sex = self.sexIndex_ or ""
     params.city = self.combo_:getText() or ""

     self.controller_:saveUserAddress(params, self.saveAddrCallBack_)
     self:hidePanel_()
end

function ScoreAddressPopup:bindAddressInfo_(data)
    -- body
    if data then
        self.editEmail_ = data.mail or ""
        self.editTel_ = data.tel or ""
        self.editAddress_ = data.address or ""
        self.editNick_ = data.name or ""

        local cityDataList = bm.LangUtil.getText("SCOREMARKET", "CITY")

        if self and self.combo_ then
            self.combo_:setText(data.city or cityDataList[1])
        end
        -- self.savedCity_ = data.city
        if self then
            --todo
            if self.emailEdit_ then
                --todo
                self.emailEdit_:setText(data.mail) -- self.emailEdit_:setPlaceHolder(bm.LangUtil.getText("SCOREMARKET", "EMAIL"));
            end

            if self.nameEdit_ then
                --todo
                self.nameEdit_:setText(data.name)
            end

            if self.telEdit_ then
                --todo
                self.telEdit_:setText(data.tel)
            end

            if self.addressEdit_ then
                --todo
                self.addressEdit_:setText(data.address)
            end

            if self.sexCheckBtnGroup_ then
                --todo
                data.sex = checkint(data.sex or 0)

                if data.sex ~= 1 and data.sex ~= 2 then
                    data.sex = 1
                end
                self.sexIndex_ = data.sex

                self.sexCheckBtnGroup_:getButtonAtIndex(self.sexIndex_):setButtonSelected(true)
            end
        end
    else
        -- self.alertT_:show()
    end
end

function ScoreAddressPopup:isRightEmail(str)
     if string.len(str or "") < 6 then return false end
     local b,e = string.find(str or "", '@')
     local bstr = ""
     local estr = ""
     if b then
         bstr = string.sub(str, 1, b - 1)
         estr = string.sub(str, e + 1, -1)
     else
         return false
     end

     -- check the string before '@'
     local p1, p2 = string.find(bstr, "[%w_]+")
     if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end

     -- check the string after '@'
     if string.find(estr, "^[%.]+") then return false end
     if string.find(estr, "%.[%.]+") then return false end
     if string.find(estr, "@") then return false end
     if string.find(estr, "[%.]+$") then return false end

     _, count = string.gsub(estr, "%.", "")
     if (count < 1 ) or (count > 3) then
         return false
     end

     return true
 end

function ScoreAddressPopup:showPanel(callBack)
    -- body
    self.saveAddrCallBack_ = callBack

    self:showPanel_()
    return self
end

function ScoreAddressPopup:onShowed()
    -- body
    if self and self.combo_ then
        --todo
        self.combo_:onShowed()
    end
end

function ScoreAddressPopup:onEnter()
    -- body
end

function ScoreAddressPopup:onExit()
    -- body
    display.removeSpriteFramesWithFile("awardAddr_comfirm.plist", "awardAddr_comfirm.png")

    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
    -- self.controller_:dispose()
end

function ScoreAddressPopup:onCleanup()
    -- body
    for _, editbox in ipairs(self.infoEditBoxList_) do
        nk.EditBoxManager:removeEditBox(editbox)
    end

end

return ScoreAddressPopup