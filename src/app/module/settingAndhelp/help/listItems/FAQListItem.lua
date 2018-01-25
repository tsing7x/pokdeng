--
-- Author: viking@boomegg.com
-- Date: 2014-09-01 10:22:00
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FAQListItem = class("FAQListItem", bm.ui.ListItem)

FAQListItem.WIDTH = 0
FAQListItem.HEIGHT = 75

FAQListItem.ANSWER_SIZE = 20
FAQListItem.ANSWER_COLOR = cc.c3b(0x64, 0x9a, 0xc9)

function FAQListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    FAQListItem.super.ctor(self, FAQListItem.WIDTH, FAQListItem.HEIGHT)

    self.contentWidth = FAQListItem.WIDTH - 4
    local contentH = FAQListItem.HEIGHT
    self.isFolded_ = true

    --触摸层
    self.touchBtn_ = cc.ui.UIPushButton.new("#common_transparent_skin.png", {scale9 = true})
    self.touchBtn_:setTouchSwallowEnabled(false)
    self.touchBtn_:onButtonPressed(function(evt)
        self.btnPressedY_ = evt.y
        self.btnClickCanceled_ = false
    end)
    self.touchBtn_:onButtonRelease(function(evt)
        if math.abs(evt.y - self.btnPressedY_) > 10 then
            self.btnClickCanceled_ = true
        end
    end)
    self.touchBtn_:onButtonClicked(function(evt)
        if not self.btnClickCanceled_ and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
            self:foldContent()
        end
    end)
    self.touchBtn_:setButtonSize(FAQListItem.WIDTH, FAQListItem.HEIGHT)
    self.touchBtn_:pos(FAQListItem.WIDTH * 0.5, FAQListItem.HEIGHT * 0.5)
    self.touchBtn_:addTo(self)

    --内容容器
    self.contentContainer_ = display.newNode():addTo(self):pos(FAQListItem.WIDTH * 0.5, FAQListItem.HEIGHT * 0.5)

    self.heightExtra_ = 0
    --底部详情面板
    self.bottomPanel_ = cc.ClippingNode:create():addTo(self.contentContainer_)
    self.bottomPanel_:setContentSize(cc.size(self.contentWidth, 1))

    self.stencil_ = display.newRect(FAQListItem.WIDTH - 8, FAQListItem.HEIGHT * 0.5, {fill=true, fillColor=cc.c4f(1, 1, 1, 1)})
    self.stencil_:setAnchorPoint(cc.p(0.5, 0))
    self.stencil_:pos(-1, -FAQListItem.HEIGHT * 0.5)
    self.bottomPanel_:setStencil(self.stencil_)

    --顶部面板
    self.topPanel_ = display.newNode():addTo(self.contentContainer_)

    --底部背景
    self.bottomHeight = 60
    self.bottomBackground_ = display.newScale9Sprite("#help_item_extended.png"):addTo(self.bottomPanel_):size(self.contentWidth - 4, self.bottomHeight):pos(-1, 0)

    --顶部背景
    self.background_ = display.newScale9Sprite("#help_item_background.png")
    self.background_:setContentSize(cc.size(FAQListItem.WIDTH - 4, FAQListItem.HEIGHT))
    self.background_:addTo(self.topPanel_)
    self.background_:pos(- 1, 0)

    --折叠按钮
    local foldIconMarginLeft = 28
    self.foldIcon_ = display.newSprite("#store_list_triangle.png", FAQListItem.WIDTH * -0.5 + foldIconMarginLeft, 0):addTo(self.topPanel_)
    self.foldIcon_:setAnchorPoint(cc.p(0.3, 0.5))

    --标题
    self.titleMarginLeft = foldIconMarginLeft + self.foldIcon_:getContentSize().width + 12
    self.title_ = display.newTTFLabel({size=28, color=cc.c3b(0xca, 0xca, 0xca), align=ui.TEXT_ALIGN_LEFT}):pos(FAQListItem.WIDTH * -0.5 + self.titleMarginLeft, 0)
        :addTo(self.topPanel_)
    self.title_:setAnchorPoint(cc.p(0, 0.5))

    --解答
    local answerLabelPadding = 30 * 2
    self.answerLabel = display.newTTFLabel({
            size = FAQListItem.ANSWER_SIZE, 
            color = FAQListItem.ANSWER_COLOR, 
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(self.contentWidth - answerLabelPadding, 0)
        }):addTo(self.bottomPanel_):hide()
    self.answerLabel:setAnchorPoint(cc.p(0, 0.5))

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame_))
    -- self:setContentSize(cc.size(FAQListItem.WIDTH, FAQListItem.HEIGHT))
end

function FAQListItem:onTouch_(evt)
    local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    local isTouchInSprite = self:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    if name == "began" then
        if isTouchInSprite then
            --self.beginX_ = evt.x
            self.beginY_ = evt.y
            --self.beginTime_ = bm.getTime()
            self.cancelClick_ = false
            self.isTouching_ = true
            return true
        else
            return false
        end
    elseif not self.isTouching_ then
        return false
    elseif name == "moved" then
        if math.abs(evt.y - self.beginY_) > 10 then
            self.cancelClick_ = true
        end
    elseif name == "ended"  or name == "cancelled" then
        self.isTouching_ = false
        if not self.cancelClick_ and isTouchInSprite and self:getParent():getParent():getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y)) then
            self:foldContent()
        end
    end
    return true
end

function FAQListItem:onEnterFrame_()
    local bottomHeight = self.bottomBackground_:getContentSize().height
    local dest, direction
    if self.isFolded_ then
        dest = 0
        direction = -1
    else
        dest = bottomHeight
        direction = 1
    end
    if self.heightExtra_ == dest then
        self:unscheduleUpdate()
    else
        self.heightExtra_ = self.heightExtra_ + direction * math.max(1, math.abs(self.heightExtra_ - dest) * 0.08)
        if direction > 0 and self.heightExtra_ > dest or direction < 0 and self.heightExtra_ < dest then
            self.heightExtra_ = dest
        end
    end
    self.foldIcon_:rotation(90 * (self.heightExtra_ / (bottomHeight)))

    local contentHeight = FAQListItem.HEIGHT + self.heightExtra_
    self.bottomPanel_:setPositionY(-self.heightExtra_)
    self:setContentSize(cc.size(FAQListItem.WIDTH, FAQListItem.HEIGHT + self.heightExtra_))
    self.contentContainer_:setPositionY(FAQListItem.HEIGHT * 0.5 + self.heightExtra_)
    -- self.touchBtn_:setButtonSize(FAQListItem.WIDTH, FAQListItem.HEIGHT + self.heightExtra_)
    -- self.touchBtn_:setPositionY(contentHeight * 0.5)
    self.touchBtn_:setPositionY(FAQListItem.HEIGHT / 2 + self.heightExtra_)
    self.stencil_:setScaleY((FAQListItem.HEIGHT * 0.2 + self.heightExtra_ ) / (FAQListItem.HEIGHT * 0.5))
    self:dispatchEvent({name="RESIZE"})
end

function FAQListItem:foldContent()
    if self.isFolded_ then
        self.isFolded_ = false
    else
        self.isFolded_ = true
    end
    self:unscheduleUpdate()
    self:scheduleUpdate()

    -- 这里针对index_ == 1 第一个Item特殊绘制。(后续可能的需求！)
    -- if self.index_ == 1 then
    --     --todo

    -- end

    if self.index_ == 2 and not self.initItem2 then
        self.initItem2 = true
        -- self:createItem2(self.data_)
        self:createItem(self.data_)
    elseif self.index_ ~= 2 and not self.initItem then
        self.initItem = true
        self:createItem(self.data_)
    end    
end

function FAQListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.data_ = data
        self.title_:setString(data[1])
    end
end

local answerLabelMarginBottom = 5
local linePadding = 26

function FAQListItem:createItem(data)
    self.answerLabel:show()
    local answerLabelMarginLeft = self.titleMarginLeft
    self.answerLabel:setString(data[2])
    local answerLabelSize = self.answerLabel:getContentSize()    
    local h = linePadding + answerLabelSize.height
    self.bottomBackground_:size(self.contentWidth - 4, h)
    self.bottomBackground_:setPositionY(h * 0.5 - FAQListItem.HEIGHT * 0.5 + 4)
    self.answerLabel:pos(-FAQListItem.WIDTH/2 + answerLabelMarginLeft, h * 0.5 - FAQListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
end

function FAQListItem:createItem2(data)
    self.answerLabel:removeFromParent()
    local answerLabelMarginLeft = self.titleMarginLeft

    local answerLabel = display.newTTFLabel({
            text = data[2][1],
            size = FAQListItem.ANSWER_SIZE, 
            color = FAQListItem.ANSWER_COLOR, 
            align = ui.TEXT_ALIGN_LEFT
        }):addTo(self.bottomPanel_)
    answerLabel:setAnchorPoint(cc.p(0, 0.5))

    --商城图标
    local storeIcon = display.newSprite("#store_btn_icon.png"):addTo(self.bottomPanel_)
    local answerLabel2 = display.newTTFLabel({
            text = data[2][2],
            size = FAQListItem.ANSWER_SIZE, 
            color = FAQListItem.ANSWER_COLOR, 
            align = ui.TEXT_ALIGN_LEFT
        }):addTo(self.bottomPanel_)
    answerLabel2:setAnchorPoint(cc.p(0, 0.5))

    local padding = 10
    local answerLabelSize = answerLabel:getContentSize()    
    local h = linePadding + math.max(answerLabelSize.height, storeIcon:getContentSize().height)
    self.bottomBackground_:size(self.contentWidth - 4, h)
    self.bottomBackground_:setPositionY(h * 0.5 - FAQListItem.HEIGHT * 0.5 + 4)
    answerLabel:pos(-FAQListItem.WIDTH/2 + answerLabelMarginLeft, h * 0.5 - FAQListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
    storeIcon:pos(-FAQListItem.WIDTH/2 + answerLabelMarginLeft + padding + answerLabelSize.width + storeIcon:getContentSize().width/2, 
            h * 0.5 - FAQListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
    answerLabel2:pos(-FAQListItem.WIDTH/2 + answerLabelMarginLeft + padding + answerLabelSize.width + storeIcon:getContentSize().width + padding, 
            h * 0.5 - FAQListItem.HEIGHT * 0.5 + answerLabelMarginBottom)
end

return FAQListItem