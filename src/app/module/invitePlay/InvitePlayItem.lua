local InvitePlayItem = class("InvitePlayItem", bm.ui.ListItem)

function InvitePlayItem:ctor()
	self:setNodeEventEnabled(true)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    InvitePlayItem.super.ctor(self, 708, 84)

    local posY = self.height_ * 0.5
    -- 分割线
    local lineWidth = 684
    local lineHeight = 2
    local lineMarginLeft = 12
    display.newScale9Sprite("#pop_up_split_line.png")
    :pos(lineWidth/2 + lineMarginLeft, 0)
    :addTo(self)
    :size(lineWidth, lineHeight)

    self:createContent_()
end

function InvitePlayItem:createContent_()
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

    -- -- 触摸头像删除好友
    -- self.deleteFriendButton = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
    --     :setButtonSize(100, 82)
    --     :onButtonClicked(handler(self, self.deleteFriendHandler))
    --     :pos(64, posY)
    --     :addTo(self)

    -- 昵称标签
    self.nick_ =  display.newTTFLabel({text = "", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 128, posY + 20)
        :addTo(self)

    -- 资产
    self.money_ =  display.newTTFLabel({text = "", color = cc.c3b(0x3E, 0xA2, 0xEE), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 128, posY - 20)
        :addTo(self)

    -- on line
    self.line_ =  display.newTTFLabel({text = "", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.CENTER, 438, posY)
        :addTo(self)

    self.sendBtnNormalLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SEND_INVITE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.inviteBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(140, 52)
        :setButtonLabel("normal", self.sendBtnNormalLabel_)
        :setButtonLabel("disable", display.newTTFLabel({text = bm.LangUtil.getText("FRIEND", "SEND_INVITE"), color = styles.FONT_COLOR.DARK_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :pos(610, posY)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onInviteClick_))
        self.inviteBtn_:setTouchSwallowEnabled(false)


    -- line邀请
    self.lineCallBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(140, 52)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_LINECALL"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("disable", display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_LINECALL"), color = styles.FONT_COLOR.DARK_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :pos(610, posY)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onLineInviteClick_))
    self.lineCallBtn_:setTouchSwallowEnabled(false)
end
function InvitePlayItem:onInviteClick_(evt)
   -- self.inviteBtn_:setButtonEnabled(false)
    self:dispatchEvent({name="ITEM_EVENT", data = self.data_.fid})
end
function InvitePlayItem:onLineInviteClick_( ... )
	local content = bm.LangUtil.getText("FRIEND","INVITE_CONTENT2") .. " https://goo.gl/IvNuO6"
    local contentType = "text"
    device.openURL(string.format("line://msg/%s/%s",contentType,content))
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
        args = {eventId = "line_invite_friends", label = "user line_invite_friends"}}
    end
end
function InvitePlayItem:setData(data)
    -- 设置头像
    self.data_ = data
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

    --是否在线
        if checkint(data.roomid) > 0 then--在线,在房间内
            self.inviteBtn_:show()
            self.lineCallBtn_:hide()
            self.line_:setString(bm.LangUtil.getText("HALL","PERSONAL_ROOM_INVITE_ONLINE")[4]);
        elseif checkint(data.roomid)==-1 then  --不在线
            self.inviteBtn_:hide()
            self.lineCallBtn_:show()
            self.line_:setString(bm.LangUtil.getText("HALL","PERSONAL_ROOM_INVITE_ONLINE")[2]);
        else--在大厅
            self.inviteBtn_:show()
            self.lineCallBtn_:hide()
            self.line_:setString(bm.LangUtil.getText("HALL","PERSONAL_ROOM_INVITE_ONLINE")[3]);
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
end
function InvitePlayItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()

        if self and self.avatar_ then
            --todo
            self.avatar_:setTexture(tex)
            self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
            self.avatar_:setScaleX(57 / texSize.width)
            self.avatar_:setScaleY(57 / texSize.height)
            self.avatarLoaded_ = true
        end
    end
end

function InvitePlayItem:onCleanup()
    -- body
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

return InvitePlayItem