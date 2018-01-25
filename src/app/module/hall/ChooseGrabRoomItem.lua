
--
-- Author: VanfoHuang
-- Date: 2015-09-10 
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--[[
local LIST_ITEM_WIDTH = display.width-85
local LIST_ITEM_HEIGHT = 80

local LIST_BG_WIDTH = display.width-85
local LIST_BG_HEIGHT = 70
local LIST_ITEM_SPACE_Y = LIST_ITEM_HEIGHT - LIST_BG_HEIGHT
local POSY =  LIST_BG_HEIGHT * 0.5 + LIST_ITEM_SPACE_Y * 0.5
local LEFT_GAP = 20
local ChooseGrabRoomItem = class("ChooseGrabRoomItem", bm.ui.ListItem)


function ChooseGrabRoomItem:ctor()
	self:setNodeEventEnabled(true)
    ChooseGrabRoomItem.super.ctor(self, LIST_ITEM_WIDTH, LIST_ITEM_HEIGHT)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.itemBg_ = display.newScale9Sprite("#perItemBg.png",0,0,cc.size(LIST_BG_WIDTH,LIST_BG_HEIGHT))
	:pos(LIST_ITEM_WIDTH*0.5,LIST_ITEM_HEIGHT*0.5 + LIST_ITEM_SPACE_Y*0.5)
	:addTo(self)

    self.cashItemBg_ = display.newScale9Sprite("#yellow_item_bg.png",0,0,cc.size(LIST_BG_WIDTH,LIST_BG_HEIGHT))
    :pos(LIST_ITEM_WIDTH*0.5,LIST_ITEM_HEIGHT*0.5 + LIST_ITEM_SPACE_Y*0.5)
    :addTo(self)
    :hide()


end


function ChooseGrabRoomItem:createContent_()
	
    local totalLen = LIST_ITEM_WIDTH-20
    local itemLen = totalLen/7

    self.noDealerText_ = display.newTTFLabel({text = T("空庄"), color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 15, POSY)
        :addTo(self)
        :hide()

     -- 头像
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(57 / 100)
        :pos(44, POSY+5)
        :addTo(self)
        :hide()
    self.avatarBg_ = display.newSprite("#ranking_avatar_bg.png")
        :pos(44, POSY+5)
        :addTo(self)
        :hide()
    self.genderIcon_ = display.newSprite("#male_icon.png")
        :pos(68, POSY+5 - 20)
        :addTo(self)
        :hide()
        :scale(0.8)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id



	self.roomIdText = display.newTTFLabel({text = "", color = cc.c3b(0x29, 0x93, 0x2E), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 5+itemLen, POSY)-- +20
        :addTo(self)
        --:pos(-totalLen/2,POSY)

   self.roomNameText = display.newTTFLabel({text = "", color = cc.c3b(0xcc, 0xac, 0x45), size = 24, align = ui.TEXT_ALIGN_CENTER})
    :align(display.LEFT_CENTER, 115, POSY)
    :addTo(self)
    :pos(5+2*itemLen - LEFT_GAP + 30,POSY)

    local nameSize = self.roomNameText:getContentSize()
    self.cashIcon_ = display.newSprite("#cash_coin_icon.png")
    :addTo(self)
    --:pos(5+2*itemLen - LEFT_GAP + 110,POSY)
    :pos(5+2*itemLen+nameSize.width-20,POSY)
    :scale(.8)
    self.cashIcon_:hide()

    self.roomBetText = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
    :align(display.LEFT_CENTER, 220, POSY)
    :addTo(self)
    :pos(5+3*itemLen- LEFT_GAP+40,POSY)
    --:pos(-totalLen/2+2*itemLen,POSY)

    self.entryLimitText = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
    :align(display.LEFT_CENTER, 330, POSY)
    :addTo(self)
    :pos(5+4*itemLen- LEFT_GAP+40,POSY)
    --:pos(-totalLen/2+3*itemLen,POSY)

    -- self.serviceFeeText = 
    -- display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xd2, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
    -- :align(display.CENTER, 445, POSY)
    -- :addTo(self)
    -- :pos(5+5*itemLen- LEFT_GAP-20,POSY)
    --:pos(-totalLen/2+4*itemLen,POSY)

    -- self.locker = display.newSprite("#perLocker.png")
    -- :align(display.LEFT_CENTER, 527, POSY)
    -- :addTo(self)
    -- :pos(5+5*itemLen - 60- LEFT_GAP,POSY)
    -- --:pos(-totalLen/2+5*itemLen,POSY)

    self.playerNumProgBar_ = nk.ui.ProgressBar.new(
        "#perSliderBg.png", 
        "#perSliderFg.png", 
        {
            bgWidth = 125, 
            bgHeight = 35, 
            fillWidth = 35, 
            fillHeight = 35
        }
    )
    :align(display.LEFT_CENTER, 585, POSY)
    :addTo(self)
    :pos(5+5*itemLen-10,POSY)
    --:pos(-totalLen/2+6*itemLen,POSY)
    :setValue(0.8)

    self.playerNumText = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 24, align = ui.TEXT_ALIGN_CENTER,dimensions = cc.size(125,35)})
    :align(display.LEFT_CENTER, 580, POSY)
    :addTo(self)
    :pos(5+5*itemLen-15,POSY)

    local joinBtnBg = display.newScale9Sprite("#perGreenBtn.png",0,0,cc.size(115,48))
    :align(display.LEFT_CENTER, 725, POSY)
    :addTo(self)
    :pos(5+6*itemLen+4,POSY)

    self.joinBtn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(123, 50)
        :align(display.LEFT_CENTER, 723, POSY)
        :pos(5+6*itemLen,POSY)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("HALL", "PERSONAL_ROOM_ENTER"), size=24, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onJoinBtnClicked))


end


function ChooseGrabRoomItem:onJoinBtnClicked()
     self:dispatchEvent({name="ITEM_EVENT", data = self.data_})

end



function ChooseGrabRoomItem:onDataSet(dataChanged, data)
    self.dataChanged_ = self.dataChanged_ or dataChanged
    self.data_ = data
end



function ChooseGrabRoomItem:setData_(data)
    -- data = {}
    -- data.isAnim = true
    if type(data) == "table" and data.isAnim and not self.hasAnim then
        self.hasAnim = true
        -- transition.fadeIn(self, {time = 2})

        -- dump("ChooseGrabRoomItem=================================")
    end

    self.data_ = data
    if data.level == consts.ROOM_GAME_LEVEL.GRAB_CASH_ROOM_LEVEL then
        self.cashIcon_:show()
        self.cashItemBg_:show()
        self.itemBg_:hide()

        self.roomIdText:setTextColor(cc.c3b(0x00, 0x4e, 0x22))
        self.roomNameText:setTextColor(cc.c3b(0x00, 0x4e, 0x22))
        self.roomBetText:setTextColor(cc.c3b(0x00, 0x4e, 0x22))
        self.entryLimitText:setTextColor(cc.c3b(0x00, 0x4e, 0x22))
    else
        self.cashIcon_:hide()
        self.cashItemBg_:hide()
        self.itemBg_:show()
        self.roomIdText:setTextColor(cc.c3b(0x29, 0x93, 0x2E))
        self.roomNameText:setTextColor(cc.c3b(0xcc, 0xac, 0x45))
        self.roomBetText:setTextColor(cc.c3b(0xff, 0xd2, 0x00))
        self.entryLimitText:setTextColor(cc.c3b(0xff, 0xd2, 0x00))
    end
    local ante = bm.formatBigNumber(data.ante)
     self.roomIdText:setString(ante or "") --庄家携带
     local door_ = bm.formatBigNumber(data.door)--上庄门槛
     self.roomBetText:setString(door_ or "")
    

     local baseChip_ = bm.formatBigNumber(data.basechip)
     --local name = nk.Native:getFixedWidthText("", 24, "thinker" or "", (LIST_ITEM_WIDTH-20)/8 - 10)
     self.roomNameText:setString(baseChip_ or "") --底注场次

     local minAnte_ = bm.formatBigNumber(data.minante)
     self.entryLimitText:setString(minAnte_ or "") -- 最小携带
    
     self.playerNumProgBar_:setValue(data.userCount/10 or 0)
     self.playerNumText:setString(data.userCount .. "/10" or "0/10")
   
    

    if not data.userinfo or #data.userinfo<5 then
        self.avatar_:hide()
        self.avatarBg_:hide()
        self.genderIcon_:hide()
        self.noDealerText_:show()
    else

        local userinfoData = json.decode(data.userinfo)
        self.avatar_:show()
        self.avatarBg_:show()
        self.genderIcon_:show()
        self.noDealerText_:hide()

        dump(userinfoData,"playeruserinfoData")

        local imgurl = userinfoData.mavatar
            if string.find(imgurl, "facebook") then
                if string.find(imgurl, "?") then
                    imgurl = imgurl .. "&width=100&height=100"
                else
                    imgurl = imgurl .. "?width=100&height=100"
                end
            end

        
        -- 设置头像
        if checkint(userinfoData.msex) ~= 1 then
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("female_icon.png"))
            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
        else
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("male_icon.png"))
            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
        end

        if userinfoData.mavatar then
            nk.ImageLoader:loadAndCacheImage(
                self.userAvatarLoaderId_, 
                imgurl, 
                handler(self, self.onAvatarLoadComplete_), 
                nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
            )
        end
    end

end



function ChooseGrabRoomItem:onAvatarLoadComplete_(success, sprite)
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

function ChooseGrabRoomItem:lazyCreateContent()
	if not self.created_ then
        self.created_ = true
        self:createContent_()
    end


    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    end

end
function ChooseGrabRoomItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    -- if self.loadImageHandle_ then
    --     scheduler.unscheduleGlobal(self.loadImageHandle_)
    --     self.loadImageHandle_ = nil
    -- end
end
return ChooseGrabRoomItem

--]]
