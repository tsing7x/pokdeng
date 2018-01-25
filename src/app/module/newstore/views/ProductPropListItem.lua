--
-- Author: tony
-- Date: 2014-11-20 19:02:16
--

local ProductPropListItem = class("ProductPropListItem", bm.ui.ListItem)

ProductPropListItem.WIDTH = 100
ProductPropListItem.HEIGHT = 77
ProductPropListItem.PADDING_LEFT = 2
ProductPropListItem.PADDING_RIGHT = 2
local ROW_GAP = 2
function ProductPropListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    ProductPropListItem.super.ctor(self, ProductPropListItem.WIDTH, ProductPropListItem.HEIGHT + ROW_GAP)
    local contentW = ProductPropListItem.WIDTH - ProductPropListItem.PADDING_LEFT - ProductPropListItem.PADDING_RIGHT
    local contentH = ProductPropListItem.HEIGHT
    self.isFolded_ = true

    self.touchBtn_ = cc.ui.UIPushButton.new("#transparent.png", {scale9=true})
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
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self:foldContent()
        end
    end)
    self.touchBtn_:setButtonSize(ProductPropListItem.WIDTH, ProductPropListItem.HEIGHT + ROW_GAP)
    self.touchBtn_:pos(ProductPropListItem.WIDTH * 0.5, (ProductPropListItem.HEIGHT + ROW_GAP) * 0.5)
    self.touchBtn_:addTo(self)

    --内容容器
    self.contentContainer_ = display.newNode():addTo(self):pos(ProductPropListItem.WIDTH * 0.5 + (ProductPropListItem.PADDING_LEFT - ProductPropListItem.PADDING_RIGHT) * 0.5, (ProductPropListItem.HEIGHT + ROW_GAP) * 0.5)

    self.heightExtra_ = 0
    --底部详情面板
    self.bottomPanel_ = cc.ClippingNode:create():addTo(self.contentContainer_)
    self.bottomPanel_:setContentSize(cc.size(contentW, 1))

    self.stencil_ = display.newRect(contentW, contentH * 0.5, {fill=true, fillColor=cc.c4f(1, 1, 1, 1)})
    self.stencil_:setAnchorPoint(cc.p(0.5, 0))
    self.stencil_:setPositionY(-contentH * 0.5)
    self.bottomPanel_:setStencil(self.stencil_)

    --顶部面板
    self.topPanel_ = display.newNode():addTo(self.contentContainer_)

    --底部背景
    self.bottomBackground_ = display.newScale9Sprite("#store_item_extended.png"):addTo(self.bottomPanel_)

    --顶部背景
    self.background_ = display.newScale9Sprite("#store_item_background.png")
    self.background_:setContentSize(cc.size(contentW, contentH))
    self.background_:addTo(self.topPanel_)

    --折叠按钮
    self.foldIcon_ = display.newSprite("#store_list_triangle.png", contentW * -0.5 + 28, 0):addTo(self.topPanel_)
    self.foldIcon_:setAnchorPoint(cc.p(0.3, 0.5))

    --标题
    self.title_ = display.newTTFLabel({size=28, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_LEFT})
    :pos(contentW * -0.5 + 172, 0):addTo(self.topPanel_)
    self.title_:setAnchorPoint(cc.p(0, 0.5))
    self.title_:setTouchEnabled(false)

    --购买按钮背景
    self.buyBtn_ = cc.ui.UIPushButton.new({normal="#store_buy_btn_up.png", pressed="#store_buy_btn_down.png", disabled="#store_btn_disabled.png"}, {scale9=true})
    self.buyBtn_:setButtonLabel(display.newTTFLabel({size=28, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
    self.buyBtn_:onButtonClicked(function(evt)
        local thisTime = bm.getTime()
        if not ProductPropListItem.buyBtnLastClickTime or math.abs(thisTime - ProductPropListItem.buyBtnLastClickTime) > 2 then
            ProductPropListItem.buyBtnLastClickTime = thisTime
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self:dispatchEvent({name="ITEM_EVENT", type="MAKE_PURCHASE", pid=self.data_.pid})
        end
    end)
    self.buyBtn_:setButtonSize(150, ProductPropListItem.HEIGHT)
    self.buyBtn_:pos(contentW * 0.5 - 75, 0)
    self.buyBtn_:addTo(self.topPanel_)

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame_))
end

function ProductPropListItem:getContentSize()
    return cc.size(ProductPropListItem.WIDTH, ProductPropListItem.HEIGHT + self.heightExtra_)
end

function ProductPropListItem:onTouch_(evt)
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

function ProductPropListItem:onEnterFrame_()
    local bottomHeight = self.bottomBackground_:getContentSize().height
    local dest, direction
    if self.isFolded_ then
        dest = 0
        direction = -1
    else
        dest = bottomHeight - 8
        direction = 1
    end
    if self.heightExtra_ == dest then
        self:unscheduleUpdate()
    else
        self.heightExtra_ = self.heightExtra_ + direction * math.max(1, math.abs(self.heightExtra_ - dest) * 0.14)
        if direction > 0 and self.heightExtra_ > dest or direction < 0 and self.heightExtra_ < dest then
            self.heightExtra_ = dest
        end
    end
    self.foldIcon_:rotation(90 * (self.heightExtra_ / (bottomHeight - 8)))

    local contentHeight = ProductPropListItem.HEIGHT + self.heightExtra_ + ROW_GAP
    self.bottomPanel_:setPositionY(-self.heightExtra_)
    self.contentContainer_:setPositionY((ProductPropListItem.HEIGHT + ROW_GAP) * 0.5 + self.heightExtra_)
    self.touchBtn_:setButtonSize(ProductPropListItem.WIDTH, ProductPropListItem.HEIGHT + self.heightExtra_)
    self.touchBtn_:setPositionY(contentHeight * 0.5)
    self.stencil_:setScaleY((ProductPropListItem.HEIGHT * 0.2 + self.heightExtra_ ) / (ProductPropListItem.HEIGHT * 0.5))
    self:dispatchEvent({name="RESIZE"})
end

function ProductPropListItem:foldContent()
    if self.isFolded_ then
        self.isFolded_ = false
    else
        self.isFolded_ = true
    end
    self:unscheduleUpdate()
    self:scheduleUpdate()
end

function ProductPropListItem:onDataSet(dataChanged, data)
    if dataChanged then
        local contentW = ProductPropListItem.WIDTH - ProductPropListItem.PADDING_LEFT - ProductPropListItem.PADDING_RIGHT
        local contentH = ProductPropListItem.HEIGHT
        local details = string.split(data.detail, "\n")
        local row = 0
        local h = 24
        if self.detailTexts_ then
            for i, v in ipairs(self.detailTexts_) do
                v:removeFromParent()
            end
        end
        self.detailTexts_ = {}
        for i = 1, #details do
            local detail = details[i]
            if detail and string.trim(detail) and string.trim(detail) ~= "" then
                row = row + 1
                local lb = display.newTTFLabel({text=detail, size=20, color=cc.c3b(0x42, 0x77, 0xBA), align=ui.TEXT_ALIGN_LEFT})
                lb:setAnchorPoint(cc.p(0, 0.5))
                self.detailTexts_[row] = lb
                h = h + 30
            end
        end
        self.bottomBackground_:setContentSize(cc.size(contentW - 4, h))
        self.bottomBackground_:setPositionY(h * 0.5 - contentH * 0.5 + 6)
        local y = h - ProductPropListItem.HEIGHT * 0.5 - 10
        for i, lb in ipairs(self.detailTexts_) do
            lb:pos(-0.5 * contentW + 48, y - 15)
            display.newSprite("#store_list_circle.png", -0.5 * contentW + 30, y - 15):addTo(self.bottomPanel_)
            lb:addTo(self.bottomPanel_)
            y = y - 30
        end
        self.title_:setString(data.title)
        if data.buyButtonEnabled == false then
            self.buyBtn_:setButtonEnabled(false)
        else
            self.buyBtn_:setButtonEnabled(true)
        end
        if data.buyButtonLabel then
            self.buyBtn_:setButtonLabelString(data.buyButtonLabel)
        else
            self.buyBtn_:setButtonLabelString(data.priceLabel or "")
        end
        if self.prd_ then
            self.prd_:removeFromParent()
            self.prd_ = nil
        end
        local filename
        if data.propType == 2 then
            --互动道具
            filename = "store_prd_prop.png"
        elseif data.propType == 32 then
            --喇叭
            filename = "store_prd_broadcast.png"
        end
        if filename then
            local path = cc.FileUtils:getInstance():fullPathForFilename(filename)
            if io.exists(path) then
                self.prd_ = display.newSprite(filename)
            else
                local prdFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(filename)
                if prdFrame then
                    self.prd_ = display.newSprite(prdFrame)
                end
            end
        end
        if self.prd_ then
            self.prd_:addTo(self.topPanel_):pos(contentW * -0.5 + 100, 0)
        end
        if not self.isFolded_ and data then
            self:foldContent()
        end
    end

end

return ProductPropListItem