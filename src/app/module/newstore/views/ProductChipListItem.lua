--
-- Author: tony
-- Date: 2014-11-20 17:35:13
--
local ProductChipListItem = class("ProductChipListItem", bm.ui.ListItem)

ProductChipListItem.WIDTH = 100
ProductChipListItem.HEIGHT = 20
ProductChipListItem.PADDING_LEFT = 10
ProductChipListItem.PADDING_RIGHT = 2
local ROW_GAP = 2

function ProductChipListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    ProductChipListItem.super.ctor(self, ProductChipListItem.WIDTH, ProductChipListItem.HEIGHT + ROW_GAP)

    display.newScale9Sprite("#store_item_background.png", ProductChipListItem.WIDTH * 0.5 + (ProductChipListItem.PADDING_LEFT -ProductChipListItem.PADDING_RIGHT) * 0.5, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5, cc.size(ProductChipListItem.WIDTH - ProductChipListItem.PADDING_LEFT - ProductChipListItem.PADDING_RIGHT, ProductChipListItem.HEIGHT))
        :addTo(self)

    self.hot_ = display.newSprite("#store_label_hot.png"):pos(ProductChipListItem.PADDING_LEFT + 28, ProductChipListItem.HEIGHT + ROW_GAP * 0.5 - 28):addTo(self, 1)
    self.new_ = display.newSprite("#store_label_new.png"):pos(ProductChipListItem.PADDING_LEFT + 28, ProductChipListItem.HEIGHT + ROW_GAP * 0.5 - 28):addTo(self, 1):hide()
    self.off_ = display.newSprite("#store_label_off.png"):pos(ProductChipListItem.PADDING_LEFT + 28, ProductChipListItem.HEIGHT + ROW_GAP * 0.5 - 28):addTo(self, 1):hide()
    self.offLabel_ = display.newTTFLabel({text="", size=16, color=cc.c3b(0x01, 0x45, 0x17), align=ui.TEXT_ALIGN_CENTER})
    self.offLabel_:pos(self.off_:getPositionX() - 8, self.off_:getPositionY() + 8)
    self.offLabel_:rotation(-45)
    self.offLabel_:addTo(self, 1):hide()

    self.title_ = display.newTTFLabel({text="", size=28, color=cc.c3b(0x27, 0x90, 0xD5), align=ui.TEXT_ALIGN_LEFT})
    self.title_:setAnchorPoint(cc.p(0, 0.5))
    self.title_:pos(ProductChipListItem.PADDING_LEFT + 136, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5)
    self.title_:addTo(self)

    self.titleOffOrigin_ = display.newTTFLabel({text="", size=26, color=cc.c3b(0xCA, 0xCA, 0xCA), align=ui.TEXT_ALIGN_LEFT})
    self.titleOffOrigin_:setAnchorPoint(cc.p(0, 0.5))
    self.titleOffOrigin_:pos(ProductChipListItem.PADDING_LEFT + 136, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5 + 16)
    self.titleOffOrigin_:addTo(self)

    self.titleOffOriginDeleteLine_ = display.newRect(1, 2, {fill=true, fillColor=cc.c4f(0xF9 / 0xff, 0xBA / 0xff, 0x22 / 0xff, 1)})
    self.titleOffOriginDeleteLine_:setAnchorPoint(cc.p(0, 0.5))
    self.titleOffOriginDeleteLine_:pos(ProductChipListItem.PADDING_LEFT + 136, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5 + 16)
    self.titleOffOriginDeleteLine_:addTo(self)

    self.titleOff_ = display.newTTFLabel({text="", size=26, color=cc.c3b(0x27, 0x90, 0xD5), align=ui.TEXT_ALIGN_LEFT})
    self.titleOff_:setAnchorPoint(cc.p(0, 0.5))
    self.titleOff_:pos(ProductChipListItem.PADDING_LEFT + 136, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5 - 16)
    self.titleOff_:addTo(self)
    
    self.offRate_ = display.newTTFLabel({text = "", size = 22, color = cc.c3b(0xca, 0xca, 0xca), align = ui.TEXT_ALIGN_RIGHT})
    self.offRate_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
    self.offRate_:pos(ProductChipListItem.WIDTH * 0.75, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5 + 16)
        :addTo(self)
        :hide()

    self.offRateDeleteLine_ = display.newRect(1, 2, {fill = true, fillColor = cc.c4f(0xf9 / 0xff, 0xba / 0xff, 0x22 / 0xff, 1)})
    self.offRateDeleteLine_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_RIGHT])
    self.offRateDeleteLine_:pos(ProductChipListItem.WIDTH * 0.75, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5 + 16)
        :addTo(self)
        :hide()

    self.rate_ = display.newTTFLabel({text="", size=22, color=cc.c3b(0x64, 0x9A, 0xC9), align=ui.TEXT_ALIGN_RIGHT})
    self.rate_:setAnchorPoint(cc.p(1, 0.5))
    self.rate_:pos(ProductChipListItem.WIDTH * 0.75, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5)
    self.rate_:addTo(self)

    self.buyBtn_ = cc.ui.UIPushButton.new({normal="#store_buy_btn_up.png", pressed="#store_buy_btn_down.png", disabled="#store_btn_disabled.png"}, {scale9=true})
    self.buyBtn_:setButtonLabel(display.newTTFLabel({size=28, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
    self.buyBtn_:onButtonClicked(function(evt)
        local thisTime = bm.getTime()
        if not ProductChipListItem.buyBtnLastClickTime or math.abs(thisTime - ProductChipListItem.buyBtnLastClickTime) > 2 then
            ProductChipListItem.buyBtnLastClickTime = thisTime
            nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
            self:dispatchEvent({name="ITEM_EVENT", type="MAKE_PURCHASE", pid=self.data_.pid,goodData = self.data_})
        end
    end)
    self.buyBtn_:setButtonSize(150, ProductChipListItem.HEIGHT)
    self.buyBtn_:pos(ProductChipListItem.WIDTH - ProductChipListItem.PADDING_RIGHT - 75, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5)
    self.buyBtn_:addTo(self)
end

function ProductChipListItem:onDataSet(dataChanged, data)
    if dataChanged then
        -- local rate = nil
        if data.rate and data.rate > 100000 then
            local rate = tonumber(string.format("%d", data.rate))
            self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", bm.formatBigNumber(rate), data.priceDollar))
        elseif data.rate > 1000 then
            --todo
            local rate = tonumber(string.format("%d", data.rate))
            self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", bm.formatNumberWithSplit(rate), data.priceDollar))
        else
            self.rate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", string.format("%.2f", data.rate or 0), data.priceDollar))
        end

        if data.discount ~= 1 then
            self.hot_:hide()
            self.new_:hide()
            self.off_:show()

            self.offLabel_:show():setString(string.format("%+d%%",  math.round((data.discount - 1) * 100)))
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

        if data.discount == 1 then
            self.title_:show()
            self.title_:setString(data.title or "")
            self.titleOffOrigin_:hide()
            self.titleOffOriginDeleteLine_:hide()
            self.titleOff_:hide()

            self.offRate_:hide()
            self.offRateDeleteLine_:hide()
            self.rate_:pos(ProductChipListItem.WIDTH * 0.75, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5)
        else
            self.title_:hide()
            self.titleOffOrigin_:show()
            self.titleOffOrigin_:setString(data.title or "")
            self.titleOffOriginDeleteLine_:setScaleX(self.titleOffOrigin_:getContentSize().width)
            self.titleOffOriginDeleteLine_:show()
            self.titleOff_:show()
            self.titleOff_:setString(bm.LangUtil.getText("STORE", "FORMAT_CHIP", bm.formatBigNumber(data.chipNumOff)))

            self.offRate_:show()
            local offRate = (data.rate or 0) / (data.discount or 1)
            if data.rate and offRate > 100000 then
                --todo
                local rate = tonumber(string.format("%d", offRate))
                self.offRate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", bm.formatBigNumber(rate), data.priceDollar))
            elseif offRate > 1000 then
                --todo
                local rate = tonumber(string.format("%d", offRate))
                self.offRate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", bm.formatNumberWithSplit(rate), data.priceDollar))
            else
                self.offRate_:setString(bm.LangUtil.getText("STORE", "RATE_CHIP", string.format("%.2f", offRate), data.priceDollar))
            end

            self.offRateDeleteLine_:setScaleX(self.offRate_:getContentSize().width)
            self.offRateDeleteLine_:show()

            self.rate_:pos(ProductChipListItem.WIDTH * 0.75, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5 - 16)
        end
        if self.prdImg_ then
            self.prdImg_:removeFromParent()
            self.prdImg_ = nil
        end
        local path = cc.FileUtils:getInstance():fullPathForFilename("store_prd_" .. data.img .. ".png")
        if io.exists(path) then
            self.prdImg_ = display.newSprite("store_prd_" .. data.img .. ".png")
        else
            local prdFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("store_prd_" .. data.img .. ".png")
            if prdFrame then
                self.prdImg_ = display.newSprite(prdFrame)
            end
        end
        if self.prdImg_ then
            self.prdImg_:pos(88, (ProductChipListItem.HEIGHT + ROW_GAP) * 0.5)
            self.prdImg_:addTo(self)
        end
        if data.buyButtonEnabled == false then
            self.buyBtn_:setButtonEnabled(false)
        else
            self.buyBtn_:setButtonEnabled(true)
        end
        if data.buyButtonLabel then
            self.buyBtn_:setButtonLabelString(data.buyButtonLabel)
        else
            self.buyBtn_:setButtonLabelString(data.priceLabel)
        end
    end
end

return ProductChipListItem