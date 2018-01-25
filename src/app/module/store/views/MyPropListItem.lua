--
-- Author: tony
-- Date: 2014-08-19 21:24:02
--

local MyPropListItem = class("MyPropListItem", bm.ui.ListItem)

function MyPropListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    MyPropListItem.super.ctor(self, MyPropListItem.WIDTH, MyPropListItem.HEIGHT)

    self.background_ = display.newScale9Sprite("#store_item_background.png")
    self.background_:setContentSize(cc.size(MyPropListItem.WIDTH - 4, 72))
    self.background_:addTo(self)
    self.background_:pos(MyPropListItem.WIDTH * 0.5 - 1, MyPropListItem.HEIGHT * 0.5)

    --商品背景
    self.prdBg_ = display.newSprite("#store_prop_item_background.png", 72, MyPropListItem.HEIGHT * 0.5):addTo(self)

    --标题
    self.title_ = display.newTTFLabel({size=28, color=cc.c3b(0xBA, 0xE9, 0xFF), align=ui.TEXT_ALIGN_LEFT}):pos(144, MyPropListItem.HEIGHT * 0.5):addTo(self)
    self.title_:setAnchorPoint(cc.p(0, 0.5))

    self.remain_ = display.newTTFLabel({size=20, color=cc.c3b(0X21, 0X60, 0XAE), align=ui.TEXT_ALIGN_RIGHT}):pos(MyPropListItem.WIDTH - 168, MyPropListItem.HEIGHT * 0.5):addTo(self)
    self.remain_:setAnchorPoint(cc.p(1, 0.5))

    self.buyBtnBg_ = display.newSprite("#store_buy_button.png")
    local bgsize = self.buyBtnBg_:getContentSize()
    self.buyBtnBg_:pos(MyPropListItem.WIDTH - 16 - bgsize.width * 0.5, MyPropListItem.HEIGHT * 0.5)
    self.buyBtnBg_:addTo(self)

    self.useBtnBg_ = display.newScale9Sprite("#common_green_btn_up.png", MyPropListItem.WIDTH - 16 - bgsize.width * 0.5, MyPropListItem.HEIGHT * 0.5, cc.Size(144, 54)):addTo(self)

    self.buyBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#common_button_pressed_cover.png"}, {scale9=true})
    self.buyBtn_:setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("STORE", "BUY"), size=28, color=cc.c3b(0x83, 0x36, 0x01), align=ui.TEXT_ALIGN_CENTER}))
    self.buyBtn_:onButtonClicked(buttontHandler(self, self.onBuyButtonClicked_))
    self.buyBtn_:setButtonSize(bgsize.width - 4, bgsize.height - 4)
    self.buyBtn_:pos(MyPropListItem.WIDTH - 16 - bgsize.width * 0.5, MyPropListItem.HEIGHT * 0.5)
    self.buyBtn_:addTo(self)

    self.useBtn_ = cc.ui.UIPushButton.new({normal="#transparent.png", pressed="#common_button_pressed_cover.png"}, {scale9=true})
    self.useBtn_:setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("STORE", "USE"), size=28, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
    self.useBtn_:onButtonClicked(buttontHandler(self, self.onUseButtonClicked_))
    self.useBtn_:setButtonSize(bgsize.width - 4, bgsize.height - 4)
    self.useBtn_:pos(MyPropListItem.WIDTH - 16 - bgsize.width * 0.5, MyPropListItem.HEIGHT * 0.5 + 1)
    self.useBtn_:addTo(self)

end

function MyPropListItem:onDataSet(dataChanged, data)
    if dataChanged then
        if data.propType == 2 then
            --道具
            if self.prd_ then
                self.prd_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("store_prd_prop.png"))
            else
                self.prd_ = display.newSprite("#store_prd_prop.png"):addTo(self)
                self.prd_:pos(self.prdBg_:getPositionX(), self.prdBg_:getPositionY())
            end
        else
            if self.prd_ then
                self.prd_:removeFromParent()
                self.prd_  = nil
            end
        end
        if data.buttonType == "use" then
            self.useBtnBg_:show()
            self.useBtn_:show()
            self.buyBtnBg_:hide()
            self.buyBtn_:hide()
        elseif data.buttonType == "buy" then
            self.useBtnBg_:hide()
            self.useBtn_:hide()
            self.buyBtnBg_:show()
            self.buyBtn_:show()
        else
            self.useBtnBg_:hide()
            self.useBtn_:hide()
            self.buyBtnBg_:hide()
            self.buyBtn_:hide()
        end
        self.title_:setString(data.title)
        self.remain_:setString(data.ramainText)
    end
end

function MyPropListItem:onBuyButtonClicked_()
    self:dispatchEvent({name="ITEM_EVENT", type="GOTO_TAB", tab=2})
end

function MyPropListItem:onUseButtonClicked_()
    bm.HttpService.POST({mod="user", act="useprops", id=self.data.propId}, function(data)
            local jdata = json.decode(data)
            if jdata and jdata.ret == 0 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "USE_SUCC_MSG"))
                self:dispatchEvent({name="ITEM_EVENT", type="REFRESH_MY_PROP"})
            else
                print(data)
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "USE_FAIL_MSG"))
            end
        end,
        function()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("STORE", "USE_FAIL_MSG"))
        end)
end

return MyPropListItem