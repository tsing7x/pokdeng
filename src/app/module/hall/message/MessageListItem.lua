
local MessageListItem = class("MessageListItem", bm.ui.ListItem)

local posY

local logger = bm.Logger.new("MessageListItem")
local CornuPopup     = import("app.module.cornucopiaEx.CornuPopup")
function MessageListItem:ctor()
    self:setNodeEventEnabled(true)
    MessageListItem.super.ctor(self, 708, 80)
    
    posY = self.height_ * 0.5

    -- pic
    -- self.avatar_ = display.newSprite("#message_email_close.png")
    self.avatar_ = display.newSprite()
        :pos(40, posY)
        :addTo(self)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    -- delete btn
    cc.ui.UIPushButton.new({normal="#message_item_delete_btn_up.png", pressed="#message_item_delete_btn_down.png"})
        :onButtonClicked(handler(self, self.onDelete))
        :pos(660, posY)    
        :addTo(self)

    -- 分割线
    display.newSprite("#pop_up_split_line.png")
        :pos(self.width_ * 0.5, 1)
        :addTo(self)
        :setScaleX(self.width_)

    --回赠button
    self.sendBtnNormalLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("MESSAGE", "FREE_SEND"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.sendBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
    :setButtonSize(120, 45)
    :setButtonLabel("normal", self.sendBtnNormalLabel_)
    :setButtonLabel("disable", display.newTTFLabel({text = bm.LangUtil.getText("MESSAGE", "FREE_SEND"), color = styles.FONT_COLOR.DARK_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER}))
    :pos(570, posY)
    :addTo(self)
    :onButtonClicked(buttontHandler(self, self.onSendClick_))

    self.goBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(120, 30)
    --:align(display.CENTER_LEFT)
    :pos(570, posY-20)
    :onButtonClicked(buttontHandler(self, self.goFarm_))
    :setButtonLabel("normal", display.newTTFLabel({text = T("去农场>>"), color = cc.c3b(0xf0,0xff,0x00), size = 20, align = ui.TEXT_ALIGN_CENTER}))
    :addTo(self)

    -- click
    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onClick))
    self:setTouchSwallowEnabled(false)
end
function MessageListItem:goFarm_()
    CornuPopup.new():show()
end
function MessageListItem:onClick(event)
    local list3 = self:getOwner()
    local data3 = list3:getData()
    local itemData3 = data3[self:getIndex()]
    self.content = display.newTTFLabel({text = itemData3.msg, color = cc.c3b(0xaa, 0xaa, 0xaa), size = 24, align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(560, 0)})
            :align(display.LEFT_CENTER, 80, posY)
            :addTo(self)

    nk.http.readedUserMessage(itemData3.a,
        function (data)
            -- logger:debug("click:" .. data)
            itemData3.c = 1
        end,
        function (errData)
            -- logger:debug("click:" .. data)
        end)
end

--回赠
function MessageListItem:onSendClick_()
    if self.data_.g and checkint(self.data_.g==1) then
        nk.http.returnSendGift(
            self.data_.a,
            function(data)
                 self:onDelete()
            end,
            function(errorData)
            end
        )
    end
end

function MessageListItem:onDelete()
    local list2 = self:getOwner()
    local data2 = list2:getData()
    local itemData2 = data2[self:getIndex()]
    table.remove(data2, self:getIndex())
    list2:setData(nil)
    list2:setData(data2)

    nk.http.deleteUserMessage(itemData2.a,function(data)
        logger:debug("delete msg succeed:" .. tostring(data))
    end,function (data)
        logger:debug("delete msg fail:" .. tostring(data))
    end)

    --[[
    bm.HttpService.POST(
        {
             mod = "user" , 
            act = "deletemsg",
            id = itemData2.a
         },
        function (data)
            -- data == 1, succeed
            logger:debug("delete:" .. data)
            if data == 1 then
                
            end
        end,
        function (data)
            logger:debug("delete:" .. data)
        end)

    --]]
end

function MessageListItem:onDataSet(dataChanged, data)
     self.data_ = data
    nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            data.img, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )

    -- self.content:setString(data.msg)
    if checkint(data.c) == 1 then
        -- msg has read
        -- todo:better, 文字左对齐了，但是没居中，暂时把80改为了60基本ok
        self.content = display.newTTFLabel({text = data.msg, color = cc.c3b(0xaa, 0xaa, 0xaa), size = 24, align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(560, 0)})
            :align(display.LEFT_CENTER, 80, posY)
            :addTo(self)
    else 
        self.content = display.newTTFLabel({text = data.msg, color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_LEFT, dimensions = cc.size(560, 0)})
                :align(display.LEFT_CENTER, 80, posY)
                :addTo(self)
    end   

    if data.g and checkint(data.g)== 1 then
        self.sendBtn_:show()
    else
        self.sendBtn_:hide()
    end
    self.goBtn_:hide()
    if data.b and checkint(data.b) == 101 then
        if data.f and checkint(data.f) == 4 then
            self.goBtn_:show()
        end
    end
end

function MessageListItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()

        if self and self.avatar_ then
            --todo
            self.avatar_:setTexture(tex)
            self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        end
        -- self.avatar_:setScaleX(66 / texSize.width)
        -- self.avatar_:setScaleY(66 / texSize.height)
    end
end

function MessageListItem:onCleanup()
    -- body
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

return MessageListItem