--
-- Author: ThinkerWang
-- Date: 2015-10-23 16:20:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- game score market record item


local ITEM_HEIGHT = 86
local WIDTH = 676
local LOAD_IMG_TAG = 111

local ScoreMarketRecordItem = class("ScoreMarketRecordItem", bm.ui.ListItem)

function ScoreMarketRecordItem:ctor()
	ScoreMarketRecordItem.super.ctor(self, WIDTH, ITEM_HEIGHT+7)
    self:setNodeEventEnabled(true)
	display.newScale9Sprite("#score_record_item.png",0, 0, cc.size(WIDTH,ITEM_HEIGHT ))
	:addTo(self)
	:pos(WIDTH/2,ITEM_HEIGHT/2+7)

	self.name_ = display.newTTFLabel({text = "" , color = cc.c3b(0xff, 0xff, 0xff), size = 20, dimensions = cc.size(WIDTH-120, 24),align = ui.TEXT_ALIGN_LEFT})
	:addTo(self)
	:pos(WIDTH/2+60,ITEM_HEIGHT/2+7 + 20)

	self.time_ = display.newTTFLabel({text = "" , color = cc.c3b(0x4f, 0x6f, 0xa2), size = 20, dimensions = cc.size(240, 24),align = ui.TEXT_ALIGN_LEFT})
	:addTo(self)
	:pos(WIDTH/2-100,ITEM_HEIGHT/2+7 - 20)

    self.exchangeNum_ = display.newTTFLabel({text = "" , color = cc.c3b(0xff, 0xff, 0xff), size = 20, dimensions = cc.size(280, 24),align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(WIDTH/2+100,ITEM_HEIGHT/2+7 - 20)

     -- cope按钮
    self.copeBtnNormalLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "COPY"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.copeBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(120, 42)
        :setButtonLabel("normal", self.copeBtnNormalLabel_)
        :pos(580, ITEM_HEIGHT/2+7)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onCopeBtn))
    self.copeBtn_:setTouchSwallowEnabled(false)

	-- 图标ICON
    -- self.icon_ = display.newNode()
    -- :size(70,70)
    -- :pos(60,ITEM_HEIGHT/2 + 7)
    -- :addTo(self)

    self.avatar_= display.newSprite("#common_transparent_skin.png")
    --:size(70,70)
    :pos(60,ITEM_HEIGHT/2 + 7)
    :addTo(self)

    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    -- display.newSprite("#score_coin_goods.png")
    -- :addTo(self.icon_)
end
function ScoreMarketRecordItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        -- self.avatar_:setTexture(tex)
        -- self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        -- self.avatar_:setScaleX(57 / texSize.width)
        -- self.avatar_:setScaleY(57 / texSize.height)
        -- self.avatarLoaded_ = true

                            local xxScale = 57/texSize.width
                            local yyScale = 57/texSize.height
                            sprite:scale(xxScale<yyScale and xxScale or yyScale)
                            :addTo(self.avatar_,0,LOAD_IMG_TAG)
                            --:
    end
end
function ScoreMarketRecordItem:setData(data)
    self.itemData_ = data
    self.name_:setString(''..data.name)
    self.time_:setString(""..data.time)
    self.exchangeNum_:setString("")
    self.copeBtn_:setVisible(false)
    if tonumber(data.category) == 1 then

        
    elseif tonumber(data.category) == 2 then
        self.exchangeNum_:setString(data.pin.."")
        self.copeBtn_:setVisible(true)
    elseif tonumber(data.category) == 3 then

    end

     local oldAvatar = self.avatar_:getChildByTag(LOAD_IMG_TAG)
    if oldAvatar then
        oldAvatar:removeFromParent()
    end
	--local data = {}
   -- data.micon = "http://pic14.nipic.com/20110522/7411759_164157418126_2.jpg"
    if string.len(data.imgurl) > 5 then
        if self.loadImageHandle_ then
            scheduler.unscheduleGlobal(self.loadImageHandle_)
            self.loadImageHandle_ = nil
        end
        --self.loadImageHandle_ = scheduler.performWithDelayGlobal(function()
                self.loadImageHandle_ = nil
                nk.ImageLoader:loadAndCacheImage(
                    self.userAvatarLoaderId_, 
                    data.imgurl, 
                    handler(self, self.onAvatarLoadComplete_))
        --    end, 0.1 * self.index_)
    end
end
function ScoreMarketRecordItem:onCopeBtn()
    if self.itemData_.pin then
        nk.Native:setClipboardText(self.itemData_.pin);
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET","COPY_SUCCESS"));
    end
end
function ScoreMarketRecordItem:onCleanup()
	nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

return ScoreMarketRecordItem