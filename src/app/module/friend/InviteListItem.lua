--
-- Author: johnny@boomegg.com
-- Date: 2014-09-10 15:33:47
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local InviteListItem = class("InviteListItem", function ()
    return display.newNode()
end)

InviteListItem.ITEM_WIDTH = 260
InviteListItem.ITEM_HEIGHT = 100

function InviteListItem:ctor(data, owner, popup, index)
    self:setNodeEventEnabled(true)
    self:setContentSize(260, 100)

    self.data_ = data
    self.owner_ = owner
    self.popup_ = popup
end

function InviteListItem:createContent_()
    local data = self.data_
    -- avatar
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(66 / 100)
        :pos(-79, 0)
        :addTo(self)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
    --nk.schedulerPool_:delayCall(function()
        nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            data.url, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    --end, 0.1 * index)

    -- background
    self.itemBg_ = display.newSprite("#invite_user_bg_unselected.png")
        :addTo(self)
    bm.TouchHelper.new(self.itemBg_, handler(self, self.onBgTouch_))
    self.itemBg_:setTouchSwallowEnabled(false)

    -- nick
    display.newTTFLabel({text = data.name, color = styles.FONT_COLOR.DARK_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT, dimensions=cc.size(112, 0)})
        :align(display.LEFT_CENTER, -40, 16)
        :addTo(self)

    -- reward
    display.newTTFLabel({text = "+" .. data.chips, color = cc.c3b(0x00, 0x8a, 0xff), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, -40, -16)
        :addTo(self)

    if self.isSelected_ then
        self.itemBg_:setSpriteFrame(display.newSpriteFrame("invite_user_bg_selected.png"))
    else
        self.itemBg_:setSpriteFrame(display.newSpriteFrame("invite_user_bg_unselected.png"))
    end
end

function InviteListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end
    if self.avatarDeactived_ and self.data_ then
        self.avatarDeactived_ = false
        nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            self.data_.url, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end
end

function InviteListItem:onItemDeactived()
    if self.created_ then
        nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
        if self.avatarLoaded_ then
            self.avatarLoaded_ = false
            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
            self.avatar_:scale(66 / 100)
            self.avatarDeactived_ = true
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end
end
function InviteListItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(66 / texSize.width)
        self.avatar_:setScaleY(66 / texSize.height)
        self.avatarLoaded_ = true
    end
end

function InviteListItem:onBgTouch_(target, evtName)
    if evtName == bm.TouchHelper.TOUCH_BEGIN then
        self.ownerBeginPlace_ = self.owner_:getCurrentPlace()
    elseif evtName == bm.TouchHelper.CLICK then
        if math.abs(self.ownerBeginPlace_ - self.owner_:getCurrentPlace()) < 20 then
            if self.isSelected_ then
                self.isSelected_ = false
                self.itemBg_:setSpriteFrame(display.newSpriteFrame("invite_user_bg_unselected.png"))
            else
                if self.popup_:getSelectedItemNum() >= 50 then
                    -- 不能选取超过50个好友，否则facebook会出错，这里给出提示
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "INVITE_FRIENDS_NUM_LIMIT_TIP"))
                else
                    self.isSelected_ = true
                    self.itemBg_:setSpriteFrame(display.newSpriteFrame("invite_user_bg_selected.png"))
                end
            end
        end
        self.popup_:setSelecteTip()
    end
end

function InviteListItem:getData()
    return self.data_
end

function InviteListItem:isSelected()
    return self.isSelected_
end

function InviteListItem:setSelected(isSelected)
    self.isSelected_ = isSelected
    if self.created_ then
        if self.isSelected_ then
            self.itemBg_:setSpriteFrame(display.newSpriteFrame("invite_user_bg_selected.png"))
        else
            self.itemBg_:setSpriteFrame(display.newSpriteFrame("invite_user_bg_unselected.png"))
        end
    end
end

function InviteListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

return InviteListItem