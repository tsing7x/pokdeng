--
-- Author: johnny@boomegg.com
-- Date: 2014-08-31 20:40:41
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local DeleteFriendPopUp = import(".DeleteFriendPopUp")
local FriendListItem = class("FriendListItem", bm.ui.ListItem)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function FriendListItem:ctor()
    self:setNodeEventEnabled(true)
    FriendListItem.super.ctor(self, 708, 84)

    local posY = self.height_ * 0.5
    -- 分割线
    local lineWidth = 684
    local lineHeight = 2
    local lineMarginLeft = 12
    display.newScale9Sprite("#pop_up_split_line.png")
        :pos(lineWidth/2 + lineMarginLeft, 0)
        :addTo(self)
        :size(lineWidth, lineHeight)
end

function FriendListItem:createContent_()
    local posY = self.height_ * 0.5
    -- 分割线
    local lineWidth = 684
    local lineHeight = 2
    local lineMarginLeft = 12

    -- 头像
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(57 / 100)
        :pos(64, posY)
        :addTo(self)
    self.avatarBg_ = display.newSprite("#ranking_avatar_bg.png")
        :pos(64, posY)
        :addTo(self)
    self.genderIcon_ = display.newSprite("#male_icon.png")
        :pos(88, posY - 20)
        :addTo(self)
        :scale(0.8)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    -- 触摸头像删除好友
    self.deleteFriendButton = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(100, 82)
        :onButtonClicked(handler(self, self.deleteFriendHandler))
        :pos(64, posY)
        :addTo(self)

    -- 昵称标签
    self.nick_ =  display.newTTFLabel({text = "", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 128, posY + 20)
        :addTo(self)

    -- 资产
    self.money_ =  display.newTTFLabel({text = "", color = cc.c3b(0x3E, 0xA2, 0xEE), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 128, posY - 20)
        :addTo(self)

    --送花按钮
    self.sendflowerLabel = display.newTTFLabel({text = "ส่งดอกมะลิ -10", color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.sendflowerBtn = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(140, 52)
        :setButtonLabel("normal", self.sendflowerLabel)
        :setButtonLabel("disable", display.newTTFLabel({text = "วันนี้ส่งแล้ว", color = styles.FONT_COLOR.DARK_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :pos(480, posY)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onSendFlowerClick_))
    self.sendflowerBtn:setTouchSwallowEnabled(false)

    -- 赠送按钮
    self.sendBtnNormalLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SEND_CHIP"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.sendBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(140, 52)
        :setButtonLabel("normal", self.sendBtnNormalLabel_)
        :setButtonLabel("disable", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SEND_CHIP"), color = styles.FONT_COLOR.DARK_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :pos(480, posY)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onSendClick_))
    self.sendBtn_:setTouchSwallowEnabled(false)

    -- 追踪按钮
    self.trackBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(140, 52)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("RANKING", "TRACE_PLAYER"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("disable", display.newTTFLabel({text = bm.LangUtil.getText("RANKING", "TRACE_PLAYER"), color = styles.FONT_COLOR.DARK_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :pos(632, posY)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onTraceClick_))
    self.trackBtn_:setTouchSwallowEnabled(false)

    -- 恢复按钮
    self.restoreBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(140, 52)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "RESTORE_BTN_TIP"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))        
        :pos(632, posY)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onRestoreClick_))
    self.restoreBtn_:setTouchSwallowEnabled(false)
    self.restoreBtn_:hide()
end

function FriendListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end
    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end
    if self.avatarDeactived_ and self.data_ then
        self.avatarDeactived_ = false
        nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            self.data_.img, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
    end
end

function FriendListItem:onItemDeactived()
    if self.created_ then
        nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
        if self.avatarLoaded_ then
            self.avatarLoaded_ = false
            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
            self.avatar_:scale(57 / 100)
            self.avatarDeactived_ = true
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end
end

function FriendListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = self.dataChanged_ or dataChanged
    self.data_ = data
end

--[{"uid":"10105","s_picture":"https:\/\/graph.facebook.com\/787488638025887\/picture","sex":"m","nick":"Zhang Mike","money":650500}]
function FriendListItem:setData_(data)
    -- 设置头像
    if checkint(data.msex) ~= 1 then
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("female_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    else
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("male_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
    end
    self.avatar_:scale(57 / 100)

    -- 设置昵称
    self.nick_:setString(nk.Native:getFixedWidthText("", 24, (data.name or " "), 200))

    -- 资产设置
    self.money_:setString(bm.LangUtil.getText("COMMON", "ASSETS", bm.formatNumberWithSplit(data.money)))

    local isDelListItem = false -- 是否是已删除好友列表
    if isset(data, "s_picture") then--这段代码很飘逸
        data.micon = data.s_picture
        isDelListItem = true
    end
    if data.hasDelete then
        isDelListItem = true
    end

    if string.len(data.micon) > 5 then
        if self.loadImageHandle_ then
            scheduler.unscheduleGlobal(self.loadImageHandle_)
            self.loadImageHandle_ = nil
        end
        --self.loadImageHandle_ = scheduler.performWithDelayGlobal(function()
                self.loadImageHandle_ = nil
                nk.ImageLoader:loadAndCacheImage(
                    self.userAvatarLoaderId_, 
                    data.micon, 
                    handler(self, self.onAvatarLoadComplete_), 
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
        --    end, 0.1 * self.index_)
    end


    if not isDelListItem then
        -- 设置赠送按钮
        if nk.userData.isSendChips and nk.userData.isSendChips == 0 then
            self.sendBtn_:hide()
        else
            self.sendBtn_:show()
            if checkint(data.canSendMoney) > 0 then
                self.sendBtn_:setButtonEnabled(true)
                --赠送金币目前写死，以后要做成可配置的。data.sdchip
                self.sendBtnNormalLabel_:setString(bm.LangUtil.getText("FRIEND", "SEND_CHIP_WITH_NUM", bm.formatBigNumber(10000)))
            else
                self.sendBtn_:setButtonEnabled(false)
            end
        end

        if nk.OnOff:check("mother") then
            self.sendflowerBtn:show()
            self.sendBtn_:hide()
            if data.sendf then
                if checkint(data.sendf) == 1 then
                    self.sendflowerBtn:setButtonEnabled(true)
                    self.sendflowerLabel:setString("ส่งดอกมะลิ -10")
                else
                    self.sendflowerBtn:setButtonEnabled(false)
                    self.sendflowerLabel:setString("วันนี้ส่งแล้ว")
                end
            else
                self.sendflowerBtn:hide()
                
                self.sendBtn_:show()
            end
        else
            self.sendflowerBtn:hide()
            self.sendBtn_:show()
        end
        

        -- 设置追踪按钮
         if data.roomid and checkint(data.roomid) > 0 then
            self.trackBtn_:setButtonEnabled(true)
            self.trackBtn_:setButtonLabelString(bm.LangUtil.getText("RANKING", "TRACE_PLAYER"))
        elseif data.roomid and checkint(data.roomid) == 0 then
            self.trackBtn_:setButtonEnabled(true)
            self.trackBtn_:setButtonLabelString(bm.LangUtil.getText("RANKING", "HALL"))
        else
            self.trackBtn_:setButtonEnabled(false)
            self.trackBtn_:setButtonLabelString(bm.LangUtil.getText("RANKING", "OFF_LINE"))
        end

    else
        self.sendBtn_:hide()
        self.trackBtn_:hide()
        self.restoreBtn_:show()
        self.deleteFriendButton:hide()
    end
end

function FriendListItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()

        if self and self.avatar_ then
            --todo
            self.avatar_:setTexture(tex)
            self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
            self.avatar_:setScaleX(57 / texSize.width)
            self.avatar_:setScaleY(57 / texSize.height)
        end
        self.avatarLoaded_ = true
    end
end

function FriendListItem:onSendClick_()
    self.owner_.controller_:sendChip(self)
end

function FriendListItem:onSendFlowerClick_()
    self.owner_.controller_:sendFriendFlower(self)
end

function FriendListItem:onSendChipSucc()
    --此处写死，后续做成动态self.data_.sdchip
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "SEND_CHIP_SUCCESS", bm.formatNumberWithSplit(10000)))
    local canSend = checkint(self.data_.canSendMoney) - 1
    self.data_.canSendMoney = canSend
    if canSend <= 0 then
        self.sendBtn_:setButtonEnabled(false)
    end
end

function FriendListItem:onSendFlowerSucc( )
    self.sendf=0;
    self.sendflowerBtn:setButtonEnabled(false)
    self.sendflowerLabel:setString("วันนี้ส่งแล้ว")
    bm.DataProxy:setData(nk.dataKeys.CHANGE_FLOWER, 1)
end

function FriendListItem:onTraceClick_()
-- print("FriendListItem:onTraceClick_============")
    local roomid = checkint(self.data_.roomid)
    if roomid <= 0 then
        nk.PopupManager:removeAllPopup()
        return
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    -- dump("FriendListItem:onTraceClick_============")
    if self.data_.gameType == 3 then--抢庄房间
        local sendData = {tableId = roomid, gameLevel = self.data_.gameLevel}
        bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = sendData})
    elseif self.data_.gameType == 2 then--私人房
         nk.server:searchPersonalRoom(nil, self.data_.roomid)
    elseif self.data_.gameType == 4 then
        --todo
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("FRIEND", "CANT_TRACE_FRIEND"))
    else
        --todo
        bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = self.data_})
    end

    nk.PopupManager:removeAllPopup()
end

function FriendListItem:onRestoreClick_()   
    self.owner_.controller_:restoreFriend(self)
end

function FriendListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    if self.loadImageHandle_ then
        scheduler.unscheduleGlobal(self.loadImageHandle_)
        self.loadImageHandle_ = nil
    end
end

function FriendListItem:deleteFriendHandler()
    local deletefriend = DeleteFriendPopUp.new()
    deletefriend:show(self.data_,self)
end

return FriendListItem