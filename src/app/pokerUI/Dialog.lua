--
-- Author: johnny@boomegg.com
-- Date: 2014-08-14 14:42:32
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local Panel = import(".Panel")
local Dialog = class("Dialog", Panel)

local DEFAULT_WIDTH = 540
local DEFAULT_HEIGHT = 360
local TOP_HEIGHT = 68
local PADDING = 32
local BTN_HEIGHT = 72

Dialog.FIRST_BTN_CLICK  = 1
Dialog.SECOND_BTN_CLICK = 2
Dialog.CLOSE_BTN_CLICK  = 3

function Dialog:ctor(args)
    if type(args) == "string" then
        self.messageText_ = args
        self.firstBtnText_ = bm.LangUtil.getText("COMMON", "CANCEL")
        self.secondBtnText_ = bm.LangUtil.getText("COMMON", "CONFIRM")
        self.titleText_ = bm.LangUtil.getText("COMMON", "NOTICE")
    elseif type(args) == "table" then
        self.messageText_ = args.messageText
        self.specialWidth_ = args.specialWidth
        self.callback_ = args.callback
        self.firstBtnText_ = args.firstBtnText or bm.LangUtil.getText("COMMON", "CANCEL")
        self.secondBtnText_ = args.secondBtnText or bm.LangUtil.getText("COMMON", "CONFIRM")
        self.titleText_ = args.titleText or bm.LangUtil.getText("COMMON", "NOTICE")
        self.noCloseBtn_ = (args.hasCloseButton == false)
        self.noFristBtn_ = (args.hasFirstButton == false)
        self.notCloseWhenTouchModel_ = (args.closeWhenTouchModel == false)
        self.showStandUpTips = (args.showStandUpTips == 1)--此项打开显示一个checkbox,目前为房间站起专用
        self.standUpCallback = args.standUpCallback
    end

    -- 设置dialog的尺寸
    local dialogWidth = self.specialWidth_ or DEFAULT_WIDTH
    -- 初始化文本
    local messageLabel = display.newTTFLabel({
            text = self.messageText_,
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 26,
            align = ui.TEXT_ALIGN_CENTER,
            dimensions = cc.size(dialogWidth - 32, 0)
        })
        :pos(0, (PADDING + BTN_HEIGHT - TOP_HEIGHT) * 0.5)

    local dialogHeight =  messageLabel:getContentSize().height + PADDING * 3 + BTN_HEIGHT + TOP_HEIGHT
    if dialogHeight < DEFAULT_HEIGHT then dialogHeight = DEFAULT_HEIGHT end
    Dialog.super.ctor(self, {dialogWidth, dialogHeight})

    if not self.noCloseBtn_ then
        self:addCloseBtn()
    end
    
    -- overlay
    display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(self.width_ - PADDING * 0.5, self.height_ - PADDING * 0.25 - TOP_HEIGHT))
        :pos(0, -30)
        :addTo(self)
    
    -- 添加标签
    display.newTTFLabel({text = self.titleText_, color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, self.height_ * 0.5 - TOP_HEIGHT * 0.5)
        :addTo(self)
    messageLabel:addTo(self)

    -- 初始化按钮
    local showFirstBtn = false
    local buttonWidth = 0
    if not self.noFristBtn_ then
        if self.firstBtnText_ then
            showFirstBtn = true
        end
    end
    self.secondBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onButtonClick_))
        :setButtonLabel("normal", display.newTTFLabel({text = self.secondBtnText_, color = styles.FONT_COLOR.LIGHT_TEXT, size = 28, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", display.newTTFLabel({text = self.secondBtnText_, color = styles.FONT_COLOR.GREY_TEXT, size = 28, align = ui.TEXT_ALIGN_CENTER}))
    if showFirstBtn then
        self.firstBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png"}, {scale9 = true})
            :addTo(self)
            :onButtonClicked(buttontHandler(self, self.onButtonClick_))
            :setButtonLabel("normal", display.newTTFLabel({text = self.firstBtnText_, color = styles.FONT_COLOR.LIGHT_TEXT, size = 28, align = ui.TEXT_ALIGN_CENTER}))
            :setButtonLabel("pressed", display.newTTFLabel({text = self.firstBtnText_, color = styles.FONT_COLOR.GREY_TEXT, size = 28, align = ui.TEXT_ALIGN_CENTER}))
        buttonWidth = (dialogWidth - 3 * PADDING) * 0.5
        self.firstBtn_:setButtonSize(buttonWidth, BTN_HEIGHT):pos(-(PADDING + buttonWidth) * 0.5, -dialogHeight * 0.5 + PADDING + BTN_HEIGHT * 0.5)
        self.secondBtn_:setButtonSize(buttonWidth, BTN_HEIGHT):pos((PADDING + buttonWidth) * 0.5, -dialogHeight * 0.5 + PADDING + BTN_HEIGHT * 0.5)
    else
        buttonWidth = 280
        self.secondBtn_:setButtonSize(buttonWidth, BTN_HEIGHT):pos(0, -dialogHeight * 0.5 + PADDING + BTN_HEIGHT * 0.5)
    end

    if self.showStandUpTips==true then
        local selectBtn = cc.ui.UICheckBoxButton.new({off = "#checkbox_button_off_2.png", on = "#checkbox_button_on_2.png"});
        selectBtn:setButtonLabel(cc.ui.UILabel.new({text = bm.LangUtil.getText("ROOM", "STAND_UP_TIPS"), size = 28,  color = display.COLOR_WHITE}))
        selectBtn:setButtonLabelOffset(40, 0)
        selectBtn:setButtonLabelAlignment(display.LEFT_CENTER)
        selectBtn:align(display.CENTER, -150, -30)
        selectBtn:addTo(self)
        selectBtn:onButtonClicked(
            function(event) 
                self.isSelect = selectBtn:isButtonSelected();
            end
        )
        messageLabel:pos(0, (PADDING + BTN_HEIGHT - TOP_HEIGHT) * 0.5 + 30)
    else

    end
end

-- 按钮点击事件处理
function Dialog:onButtonClick_(event)
    if self.showStandUpTips==true and self.isSelect and self.isSelect == true then
        self.standUpCallback()
        self.callback_ = nil
        self.standUpCallback=nil
        self:hidePanel_()
        return
    end 

    if self.callback_ then
        if event.target == self.firstBtn_ then
            self.callback_(Dialog.FIRST_BTN_CLICK)
        elseif event.target == self.secondBtn_ then
            self.callback_(Dialog.SECOND_BTN_CLICK)
        end
    end
    self.callback_ = nil

    if self.hidePanel_ then
        --todo
        self:hidePanel_()
    end
end

function Dialog:show()
    if self.notCloseWhenTouchModel_ then
        self:showPanel_(true, true, false, true)
    else
        self:showPanel_()
    end
    return self
end

function Dialog:onRemovePopup(removeFunc)
    if self.callback_ then
        self.callback_(Dialog.CLOSE_BTN_CLICK)
    end
    removeFunc()
end

-- override onClose()
function Dialog:onClose()
    if self.callback_ then
        self.callback_(Dialog.CLOSE_BTN_CLICK)
    end
    self.callback_ = nil
    self:hidePanel_()
end

return Dialog