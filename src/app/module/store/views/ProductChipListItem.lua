--
-- Author: tony
-- Date: 2014-08-19 21:21:23
--
local ProductChipListItem = class("ProductChipListItem", bm.ui.ListItem)

ProductChipListItem.WIDTH = 100
ProductChipListItem.HEIGHT = 20

function ProductChipListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    ProductChipListItem.super.ctor(self, ProductChipListItem.WIDTH, ProductChipListItem.HEIGHT)
    self.background_ = display.newScale9Sprite("#store_item_background.png")
    self.background_:setContentSize(cc.size(ProductChipListItem.WIDTH - 4, 72))
    self.background_:addTo(self)
    self.background_:pos(ProductChipListItem.WIDTH * 0.5 - 1, ProductChipListItem.HEIGHT * 0.5)

    self.prdImg_ = display.newSprite("#store_prd_100.png")
    self.prdImg_:pos(48, ProductChipListItem.HEIGHT * 0.5)
    self.prdImg_:addTo(self)

    self.hot_ = display.newSprite("#store_label_hot.png"):pos(28 - 2, ProductChipListItem.HEIGHT - 28 - 2):addTo(self)
    self.new_ = display.newSprite("#store_label_new.png"):pos(28 - 2, ProductChipListItem.HEIGHT - 28 - 2):addTo(self):hide()
    self.off_ = display.newSprite("#store_label_off.png"):pos(28 - 2, ProductChipListItem.HEIGHT - 28 - 2):addTo(self):hide()
    self.offLabel_ = display.newTTFLabel({text="", size=16, color=cc.c3b(0x01, 0x45, 0x17), align=ui.TEXT_ALIGN_CENTER})
    self.offLabel_:pos(self.off_:getPositionX() - 8, self.off_:getPositionY() + 8)
    self.offLabel_:rotation(-45)
    self.offLabel_:addTo(self):hide()

    self.title_ = display.newTTFLabel({text="", size=28, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_LEFT})
    self.title_:setAnchorPoint(cc.p(0, 0.5))
    self.title_:pos(100, ProductChipListItem.HEIGHT * 0.5)
    self.title_:addTo(self)

    self.titleOffOrigin_ = display.newTTFLabel({text="", size=28, color=cc.c3b(0x23, 0x63, 0xB3), align=ui.TEXT_ALIGN_LEFT})
    self.titleOffOrigin_:setAnchorPoint(cc.p(0, 0.5))
    self.titleOffOrigin_:pos(100, ProductChipListItem.HEIGHT * 0.5 + 16)
    self.titleOffOrigin_:addTo(self)

    self.titleOffOriginDeleteLine_ = display.newRect(1, 2, {fill=true, fillColor=cc.c4f(0xF9 / 0xff, 0xBA / 0xff, 0x22 / 0xff, 1)})
    self.titleOffOriginDeleteLine_:setAnchorPoint(cc.p(0, 0.5))
    self.titleOffOriginDeleteLine_:pos(100, ProductChipListItem.HEIGHT * 0.5 + 16)
    self.titleOffOriginDeleteLine_:addTo(self)

    self.titleOff_ = display.newTTFLabel({text="", size=28, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_LEFT})
    self.titleOff_:setAnchorPoint(cc.p(0, 0.5))
    self.titleOff_:pos(100, ProductChipListItem.HEIGHT * 0.5 - 16)
    self.titleOff_:addTo(self)
    
    self.rate_ = display.newTTFLabel({text="", size=20, color=cc.c3b(0x23, 0x63, 0xB3), align=ui.TEXT_ALIGN_RIGHT})
    self.rate_:setAnchorPoint(cc.p(1, 0.5))
    self.rate_:pos(432, ProductChipListItem.HEIGHT * 0.5)
    self.rate_:addTo(self)

    self.buyBtnBg_ = display.newSprite("#store_buy_button.png")
    local bgsize = self.buyBtnBg_:getContentSize()
    self.buyBtnBg_:pos(ProductChipListItem.WIDTH - 16 - bgsize.width * 0.5, ProductChipListItem.HEIGHT * 0.5)
    self.buyBtnBg_:addTo(self)
    self.buyBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#common_button_pressed_cover.png"}, {scale9=true})
    self.buyBtn_:setButtonLabel(display.newTTFLabel({size=28, color=cc.c3b(0x83, 0x36, 0x01), align=ui.TEXT_ALIGN_CENTER}))
    self.buyBtn_:onButtonClicked(function(evt)
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        self:dispatchEvent({name="ITEM_EVENT", type="MAKE_PURCHASE", pid=self.data_.pid})
    end)
    self.buyBtn_:setButtonSize(bgsize.width - 4, bgsize.height - 4)
    self.buyBtn_:pos(ProductChipListItem.WIDTH - 16 - bgsize.width * 0.5, ProductChipListItem.HEIGHT * 0.5)
    self.buyBtn_:addTo(self)
end

function ProductChipListItem:onDataSet(dataChanged, data)
    print(json.encode(data))
    if dataChanged then
        if data.rate and data.rate > 1000 then
            local rate = tonumber(string.format("%d", data.rate))
            self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", bm.formatNumberWithSplit(rate), data.priceDollar))
        else
            self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", string.format("%.2f", data.rate or 0), data.priceDollar))
        end

        if data.discount ~= 0 then
            self.hot_:hide()
            self.new_:hide()
            self.off_:show()
            self.offLabel_:show():setString(string.format("%+d%%", data.discount))
        elseif data.tag == "hot" then
            self.hot_:show()
            self.new_:hide()
            self.off_:hide()
            self.offLabel_:hide()
        elseif data.tag == "new" then
            self.hot_:hide()
            self.new_:show()
            self.off_:hide()
            self.offLabel_:hide()
        else
            self.hot_:hide()
            self.new_:hide()
            self.off_:hide()
            self.offLabel_:hide()
        end

        if data.discount == 0 then
            self.title_:show()
            self.title_:setString(data.title or "")
            self.titleOffOrigin_:hide()
            self.titleOffOriginDeleteLine_:hide()
            self.titleOff_:hide()
        else
            self.title_:hide()
            self.titleOffOrigin_:show()
            self.titleOffOrigin_:setString(data.title or "")
            self.titleOffOriginDeleteLine_:setScaleX(self.titleOffOrigin_:getContentSize().width)
            self.titleOffOriginDeleteLine_:show()
            self.titleOff_:show()
            self.titleOff_:setString(bm.LangUtil.getText("STORE", "FORMAT_CHIP", bm.formatBigNumber(data.chipNumOff)))
        end

        local prdFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("store_prd_" .. data.img .. ".png")
        if prdFrame then
            self.prdImg_:setSpriteFrame(prdFrame)
        end

        self.buyBtn_:setButtonLabelString(data.priceLabel)
    end
end

return ProductChipListItem