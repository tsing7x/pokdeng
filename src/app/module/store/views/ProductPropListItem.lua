--
-- Author: tony
-- Date: 2014-08-19 21:23:04
--

local ProductPropListItem = class("ProductPropListItem", bm.ui.ListItem)

ProductPropListItem.WIDTH = 100
ProductPropListItem.HEIGHT = 20
ProductPropListItem.ON_ITEM_CLICKED_LISTENER = nil
function ProductPropListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    ProductPropListItem.super.ctor(self, ProductPropListItem.WIDTH, ProductPropListItem.HEIGHT)
    local contentW = ProductPropListItem.WIDTH - 4
    local contentH = 72
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
    self.touchBtn_:setButtonSize(ProductPropListItem.WIDTH, ProductPropListItem.HEIGHT)
    self.touchBtn_:pos(ProductPropListItem.WIDTH * 0.5, ProductPropListItem.HEIGHT * 0.5)
    self.touchBtn_:addTo(self)

    --内容容器
    self.contentContainer_ = display.newNode():addTo(self):pos(ProductPropListItem.WIDTH * 0.5, ProductPropListItem.HEIGHT * 0.5)

    self.heightExtra_ = 0
    --底部详情面板
    self.bottomPanel_ = cc.ClippingNode:create():addTo(self.contentContainer_)
    self.bottomPanel_:setContentSize(cc.size(contentW, 1))

    self.stencil_ = display.newRect(ProductPropListItem.WIDTH - 6, ProductPropListItem.HEIGHT * 0.5, {fill=true, fillColor=cc.c4f(1, 1, 1, 1)})
    self.stencil_:setAnchorPoint(cc.p(0.5, 0))
    self.stencil_:setPositionY(-ProductPropListItem.HEIGHT * 0.5)
    self.bottomPanel_:setStencil(self.stencil_)

    --顶部面板
    self.topPanel_ = display.newNode():addTo(self.contentContainer_)

    --底部背景
    self.bottomBackground_ = display.newScale9Sprite("#store_item_extended.png"):addTo(self.bottomPanel_):pos(-2, 0)

    --顶部背景
    self.background_ = display.newScale9Sprite("#store_item_background.png")
    self.background_:setContentSize(cc.size(ProductPropListItem.WIDTH - 4, 72))
    self.background_:addTo(self.topPanel_)
    self.background_:pos(- 1, 0)

    --折叠按钮
    self.foldIcon_ = display.newSprite("#store_list_triangle.png", ProductPropListItem.WIDTH * -0.5 + 28, 0):addTo(self.topPanel_)
    self.foldIcon_:setAnchorPoint(cc.p(0.3, 0.5))

    --商品背景
    self.prdBg_ = display.newSprite("#store_prop_item_background.png", ProductPropListItem.WIDTH * -0.5 + 110, 0):addTo(self.topPanel_)

    --标题
    self.title_ = display.newTTFLabel({size=28, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_LEFT}):pos(ProductPropListItem.WIDTH * -0.5 + 172, 0):addTo(self.topPanel_)
    self.title_:setAnchorPoint(cc.p(0, 0.5))

    --购买按钮背景
    self.buyBtnBg_ = display.newSprite("#store_buy_button.png")
    local bgsize = self.buyBtnBg_:getContentSize()
    self.buyBtnBg_:pos(ProductPropListItem.WIDTH * 0.5 - 16 - bgsize.width * 0.5, 0)
    self.buyBtnBg_:addTo(self.topPanel_)
    self.buyBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#common_button_pressed_cover.png"}, {scale9=true})
    self.buyBtn_:setButtonLabel(display.newTTFLabel({size=28, color=cc.c3b(0x83, 0x36, 0x01), align=ui.TEXT_ALIGN_CENTER}))
    self.buyBtn_:onButtonClicked(function(evt)
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self:dispatchEvent({name="ITEM_EVENT", type="MAKE_PURCHASE", pid=self.data_.pid})
    end)
    self.buyBtn_:setButtonSize(bgsize.width - 4, bgsize.height - 4)
    self.buyBtn_:pos(ProductPropListItem.WIDTH * 0.5 - 16 - bgsize.width * 0.5, 0)
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

    local contentHeight = ProductPropListItem.HEIGHT + self.heightExtra_
    self.bottomPanel_:setPositionY(-self.heightExtra_)
    self.contentContainer_:setPositionY(ProductPropListItem.HEIGHT * 0.5 + self.heightExtra_)
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
        local details = string.split(data.detail, "\n")
        local row = 0
        local h = 24
        local detailTexts = {}
        for i = 1, #details do
            local detail = details[i]
            if detail and string.trim(detail) and string.trim(detail) ~= "" then
                row = row + 1
                local lb = display.newTTFLabel({text=detail, size=20, color=cc.c3b(0x42, 0x77, 0xBA), align=ui.TEXT_ALIGN_LEFT})
                lb:setAnchorPoint(cc.p(0, 0.5))
                detailTexts[row] = lb
                h = h + 30
            end
        end
        self.bottomBackground_:setContentSize(cc.size(ProductPropListItem.WIDTH - 8, h))
        self.bottomBackground_:setPositionY(h * 0.5 - ProductPropListItem.HEIGHT * 0.5 + 6)
        local y = h - ProductPropListItem.HEIGHT * 0.5 - 10
        for i, lb in ipairs(detailTexts) do
            lb:pos(-0.5 * ProductPropListItem.WIDTH + 48, y - 15)
            display.newSprite("#store_list_circle.png", -0.5 * ProductPropListItem.WIDTH + 30, y - 15):addTo(self.bottomPanel_)
            lb:addTo(self.bottomPanel_)
            y = y - 30
        end
        self.title_:setString(data.title)
        self.buyBtn_:setButtonLabelString(data.priceLabel or "")
        if data.propType == 2 then
            --道具
            if self.prd_ then
                self.prd_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("#store_prd_prop.png"))
            else
                self.prd_ = display.newSprite("#store_prd_prop.png"):addTo(self.topPanel_)
                self.prd_:pos(self.prdBg_:getPositionX(), self.prdBg_:getPositionY())
            end
        else
            if self.prd_ then
                self.prd_:removeFromParent()
                self.prd_  = nil
            end
        end
    end

end

return ProductPropListItem