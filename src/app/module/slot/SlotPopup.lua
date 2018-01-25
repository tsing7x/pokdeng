--
-- Author: viking@boomegg.com
-- Date: 2014-11-21 10:43:25
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local SlotPopup = class("SlotPopup", function()
    return display.newNode()
end)

local SlotController = import(".SlotController")
local SideBar = import(".SideBar")
local FlashBar = import(".FlashBar")
local TurningContent = import(".TurningContent")
local BetChipBar = import(".BetChipBar")
local AutoCheckBox = import(".AutoCheckBox")
local Handler = import(".Handler")
local HelpPopup = import(".HelpPopup")
local MinusMoneyView = import(".MinusMoneyView")
local AddMoneyView = import(".AddMoneyView")

SlotPopup.WIDTH = 479
SlotPopup.HEIGHT = 347

function SlotPopup:ctor(isInRoom)
    self:setNodeEventEnabled(true)
    self.isInRoom_ = isInRoom
    self.controller_ = SlotController.new(self)
    self:setupView()
end

function SlotPopup:setupView()
    self.container_ = display.newNode():addTo(self)
    local container_ = self.container_
    --背景
    display.newSprite("#slot_background.png"):addTo(container_):setTouchEnabled(true)

    --背景光
    local lightMarginTop = 68/2
    display.newSprite("#slot_bg_light.png"):addTo(container_):pos(0, SlotPopup.HEIGHT/2 - lightMarginTop)

    --标题
    local titleMarginTop = 16
    display.newSprite("#slot_title.png"):addTo(container_):pos(0, SlotPopup.HEIGHT/2 - titleMarginTop)

    --帮助按钮
    local helpMarginTop = 69
    local helpMarginLeft = 50
    local helpWidth = 34
    local helpHeight = 34
    
    local helpBtnNode_ = display.newNode():addTo(container_):pos(-SlotPopup.WIDTH/2 + helpMarginLeft, SlotPopup.HEIGHT/2 - helpMarginTop)
    display.newSprite("#slot_help_btn_bg.png"):addTo(helpBtnNode_)

    local helpStateBtn_ = display.newSprite("#slot_help_btn_up.png"):addTo(helpBtnNode_)

    local helpBtn_ = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#transparent.png"}, {scale9 = true})
        :size(helpWidth + 34, helpHeight + 34)
        :onButtonClicked(buttontHandler(self, self.onHelpClickListener_))
        :onButtonPressed(function()
            helpStateBtn_:setSpriteFrame(display.newSpriteFrame("slot_help_btn_down.png"))
        end)
        :onButtonRelease(function()
            helpStateBtn_:setSpriteFrame(display.newSpriteFrame("slot_help_btn_up.png"))
        end)
        :addTo(helpBtnNode_)

    --中奖闪光条
    self.flashBar_ = FlashBar.new():addTo(container_):pos(0, SlotPopup.HEIGHT/2 - helpMarginTop)

    --滚动框
    local turningContentMarginTop = 10
    self.turningContent_ = TurningContent.new(function(i, rewardMoney, isTopReward)
        self.controller_:turningContentCallback(i, rewardMoney, isTopReward)
    end):addTo(container_):pos(0, -turningContentMarginTop)

    --下注栏
    local betChipBarWidth = 264
    local betChipBarHeight = 63
    local betChipBarMarginBottom = 8
    local betChipBarMarginLeft = 16
    local insetRect = cc.rect(6, 0, 2, betChipBarHeight)
    local frame = display.newSpriteFrame("slot_bet_chip_bg.png")
    local betChipBarNode_ = ccui.Scale9Sprite:createWithSpriteFrame(frame, insetRect)
    betChipBarNode_:size(betChipBarWidth, betChipBarHeight)
    betChipBarNode_:pos(-SlotPopup.WIDTH/2 + betChipBarWidth/2 + betChipBarMarginLeft, -SlotPopup.HEIGHT/2 + betChipBarHeight/2 + betChipBarMarginBottom)
    betChipBarNode_:addTo(container_)

    self.betChipBar_ = BetChipBar.new(0, function(bet)
        self.flashBar_:setTip(bet)
    end):addTo(betChipBarNode_)

    --自动下注
    local checkBoxWidth = 157
    local checkBoxHeight = 45
    local checkBoxMarginRight = 24
    local checkBoxMarginBottom = 12
    self.autoCheckBox_ = AutoCheckBox.new(function(isChecked)
        self.controller_:autoCheckCallback(isChecked)
    end):pos(SlotPopup.WIDTH/2 - checkBoxWidth/2 - checkBoxMarginRight, -SlotPopup.HEIGHT/2 + checkBoxHeight/2 + checkBoxMarginBottom)
        :addTo(container_)

    --拉杆
    local handlerBaseWidth = 38
    local handlerBaseHeight = 81
    local handlerMarginBottom = -45
    local handlerMarginRight = -3
    self.handler_ = Handler.new(function()
        self.controller_:handlerCallback()
    end):addTo(container_):pos(SlotPopup.WIDTH/2 + handlerBaseWidth/2 + handlerMarginRight, handlerMarginBottom)

    --房间内外
    if self.isInRoom_ then
        --可以打开的按钮哟
        self.sideBtn_ = SideBar.new(function(evtName, xArgs)
            self.controller_:sideBarCallback_(evtName, xArgs)
        end):addTo(self)
        local sideBtnPosX = -SlotPopup.WIDTH/2 - self.sideBtn_:getContentSize().width/2
        local sideBtnPosY = -15
        self.sideBtn_:pos(sideBtnPosX, sideBtnPosY)
        self:initPosition()
        self:scale(0.8)

        --减筹码动画
        self.minusMoneyView_ = MinusMoneyView.new(sideBtnPosX + SideBar.WIDTH/2):addTo(self):hide()
        self.minusMoneyView_:pos(sideBtnPosX + SideBar.WIDTH/2, sideBtnPosY)

        --加筹码动画
        self.addMoneyView_ = AddMoneyView.new(sideBtnPosX - SideBar.WIDTH/2):addTo(self):hide()
        self.addMoneyView_:pos(sideBtnPosX - SideBar.WIDTH/2, sideBtnPosY)
    end
        --关闭按钮
        local closeBtnWidth = 58
        local closeBtnHeight = 59
        local closeBtnPadding = 0
        cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed = "#panel_black_close_btn_down.png"})
            :onButtonClicked(buttontHandler(self, self.onCloseBtnListener_))
            :addTo(self)
            :pos(SlotPopup.WIDTH/2 - closeBtnWidth/2 - closeBtnPadding, SlotPopup.HEIGHT/2 - closeBtnHeight/2 - closeBtnPadding)
        -- self:scale(1.2)
    -- end
end

function SlotPopup:onCloseBtnListener_()
    self:hide()
end

function SlotPopup:onHelpClickListener_()
    HelpPopup.new(self.betChipBar_:getBet()):show()
end

function SlotPopup:initPosition()
    assert(self.isInRoom_, "SlotPopup should in Room")
    local width = display.width
    local height = display.height
    local marginLeft = 10
    local marginTop = 70
    local x = width + SlotPopup.WIDTH/2 - SideBar.WIDTH - marginLeft
    local y = height/2 + marginTop
    self:pos(x, y)
    self.srcX = x
end

function SlotPopup:getSrcX()
    return self.srcX or 0
end

function SlotPopup:getEndX()
    local width = display.width
    local marginLeft = 15
    local endX = width - SlotPopup.WIDTH/2 - marginLeft
    return endX
end

function SlotPopup:closeUnVisible(unVisible)
    self.container_:setVisible(not unVisible)
end

function SlotPopup:isInRoom()
    return self.isInRoom_
end

function SlotPopup:getFlashBar()
    return self.flashBar_
end

function SlotPopup:getSideBar()
    assert(self.isInRoom_, "SlotPopup should in Room")
    return self.sideBtn_
end

function SlotPopup:getHandler()
    return self.handler_
end

function SlotPopup:getTurningContent()
    return self.turningContent_
end

function SlotPopup:getBetBar()
    return self.betChipBar_
end

function SlotPopup:getAutoCheckBox()
    return self.autoCheckBox_
end

function SlotPopup:getMinusMoneyView()
    return self.minusMoneyView_
end

function SlotPopup:getAddMoneyView()
    return self.addMoneyView_
end

function SlotPopup:setPreBlind(roomInfo,timeArr)
    -- set betChipNum -- 
    -- self.betChipBar_:setPreBlind(roomInfo.blind)
    self.betChipBar_:setPreBlind(roomInfo.blind,timeArr) 

    self.tid_ = roomInfo.tid
end

function SlotPopup:getTid()
    return self.tid_
end

function SlotPopup:show()
    if self.isInRoom_ then
        return self
    else
        nk.PopupManager:addPopup(self)
        return self
    end
end

function SlotPopup:onShowed()
    assert(self.isInRoom_, "SlotPopup should in Room")
end

function SlotPopup:hide()
    if self.isInRoom_ then
        self.controller_:sideBarCallback_("clicked", {startX = self:getSrcX(), currentX = self:getEndX()})
        return self
    else
        nk.PopupManager:removePopup(self)
        return self
    end
end
function SlotPopup:closeSlot()
    nk.PopupManager:removePopup(self)
    return self
end
function SlotPopup:onCleanup()
    self.controller_:dispose()
    if not self.isInRoom_ then
        display.removeSpriteFramesWithFile("slot_texture.plist", "slot_texture.png")
    end
end

return SlotPopup