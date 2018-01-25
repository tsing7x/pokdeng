--
-- Author: Tom
-- Date: 2014-09-15 11:09:27
--
local WIDTH = 500
local HEIGHT = 210
local LEFT = -WIDTH * 0.5
local TOP = HEIGHT * 0.5
local RIGHT = WIDTH * 0.5
local BOTTOM = -HEIGHT * 0.5

local Panel = nk.ui.Panel
local DeleteFriendPopUp = class("DeleteFriendPopUp", Panel)

function DeleteFriendPopUp:ctor()
    self:setNodeEventEnabled(true)
    DeleteFriendPopUp.super.ctor(self, {WIDTH, HEIGHT})


    self.headImgMaleBg_ = display.newScale9Sprite("#user_info_avatar_bg.png", LEFT + 12 + 60, TOP - 12 - 60, cc.size(116, 116)):addTo(self)
    self.headImgFemaleBg_ = display.newScale9Sprite("#user_info_avatar_bg.png", LEFT + 12 + 60, TOP - 12 - 60, cc.size(116, 116)):addTo(self):hide()

    --头像剪裁容器
    self.headImageLoaderId_ = nk.ImageLoader:nextLoaderId()
    self.headImgContainer_ = cc.ClippingNode:create()

    local stencil = display.newDrawNode()
    local pn = {{-50, -50}, {-50, 50}, {50, 50}, {50, -50}}  
    local clr = cc.c4f(255, 0, 0, 255)  
    stencil:drawPolygon(pn, clr, 1, clr)
    self.headImgContainer_:setStencil(stencil)
    self.headImgContainer_:pos(self.headImgMaleBg_:getPositionX(), self.headImgMaleBg_:getPositionY())
    self.headImgContainer_:addTo(self)

     --性别图标背景
    self.sexFemaleBg_ = display.newSprite("#female_icon_with_bg.png"):pos(LEFT + 168, TOP - 42):addTo(self):hide()
    self.sexMaleBg_ = display.newSprite("#male_icon_with_bg.png"):pos(LEFT + 168, TOP - 42):addTo(self):hide()
    self.sexMale_ = display.newSprite("#icon_male.png", self.sexMaleBg_:getPositionX(), self.sexMaleBg_:getPositionY()):addTo(self):hide()
    self.sexFemale_ = display.newSprite("#icon_female.png", self.sexMaleBg_:getPositionX(), self.sexMaleBg_:getPositionY()):addTo(self):hide()

    --筹码图标
    self.chipIcon_ = display.newSprite("#chip_icon.png", LEFT + 164, TOP - 94):addTo(self)
    --等级图标
    self.levelIcon_ = display.newSprite("#level_icon.png", LEFT + 402, TOP - 96):addTo(self)


    --昵称
    self.nick_ = display.newTTFLabel({size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.nick_:setAnchorPoint(cc.p(0, 0.5))
    self.nick_:pos(LEFT + 205, TOP - 42)
    self.nick_:addTo(self)
    --UID
    self.uid_ = display.newTTFLabel({size=20, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.uid_:setAnchorPoint(cc.p(0, 0.5))
    self.uid_:pos(LEFT + 380, TOP - 42)
    self.uid_:addTo(self)
    --筹码
    self.chip_ = display.newTTFLabel({size=24, color=cc.c3b(0xff, 0xd5, 0x31)})
    self.chip_:setAnchorPoint(cc.p(0, 0.5))
    self.chip_:pos(LEFT + 186, TOP - 20 - 36 * 2)
    self.chip_:addTo(self)

    --等级
    self.level_ = display.newTTFLabel({size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.level_:setAnchorPoint(cc.p(0, 0.5))
    self.level_:pos(self.levelIcon_:getPositionX() + 20, TOP - 20 - 36 * 2)
    self.level_:addTo(self)

    --排名
    self.ranking_ = display.newTTFLabel({text = bm.LangUtil.getText("ROOM", "INFO_RANKING", ".."),size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.ranking_:setAnchorPoint(cc.p(0, 0.5))
    self.ranking_:pos(LEFT + 150, TOP - 20 - 36 * 3)
    self.ranking_:addTo(self)

    --胜率
    self.winRate_ = display.newTTFLabel({size=24, color=cc.c3b(0xce, 0xe8, 0xff)})
    self.winRate_:setAnchorPoint(cc.p(0, 0.5))
    self.winRate_:pos(LEFT + 150, TOP - 20 - 36 * 4)
    self.winRate_:addTo(self)

    -- 头像
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(99 / 100)
        :pos(LEFT + 12 + 60, TOP - 12 - 60)
        :addTo(self)
    self.genderIcon_ = display.newSprite("#male_icon.png")
        :pos(LEFT + 12 + 20, TOP - 12 - 90)
        :addTo(self)

    self.delFriendBtn_ = cc.ui.UIPushButton.new({
                normal="#common_red_btn_up.png",
                pressed="#common_red_btn_down.png",
            }, {scale9=true})
        :setButtonSize(122, 47)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("ROOM", "UN_FOLLOW"), size=24, color=cc.c3b(0xFF, 0xFF, 0xFF)}))
        :onButtonClicked(buttontHandler(self, self.delFriendClicked_))
        :pos(LEFT + 12 + 60, self.headImgMaleBg_:getPositionY() - 12 - 60 - 24)
        :addTo(self)

end

function DeleteFriendPopUp:delFriendClicked_()

    nk.http.deleteFriend(self.data.fid, function(data)
        local idx = nk.userData.friendUidList and table.indexof(nk.userData.friendUidList, self.data.fid)
        if idx then
            table.remove(nk.userData.friendUidList, idx)
        end
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DELE_FRIEND_SUCCESS_MSG"))
        self:deleFriendSuccess()
        self:hide()

    end, function(errorData)
        if errorData.errorCode then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "DELE_FRIEND_FAIL_MSG"));
        end
    end)
end

function DeleteFriendPopUp:deleFriendSuccess()
    if self.owner then
        local list2 = self.owner:getOwner()
        local data2 = list2:getData()
        local itemData2 = data2[self.owner:getIndex()]
        table.remove(data2, self.owner:getIndex())
        list2:setData(nil)
        list2:setData(data2)
    end
end

function DeleteFriendPopUp:hide()
    self:hidePanel_()

end

function DeleteFriendPopUp:show(data, owner_)

    self.owner = owner_
    self:showPanel_()
    self.data = data

    self.nick_:setString(data.name)
    self.uid_:setString(bm.LangUtil.getText("ROOM", "INFO_UID", data.fid))
    self.chip_:setString(bm.formatBigNumber(data.money))
    self.level_:setString(bm.LangUtil.getText("ROOM", "INFO_LEVEL", data.mlevel))
   -- self.winRate_:setString(bm.LangUtil.getText("ROOM", "INFO_WIN_RATE", data.win + data.lose > 0 and math.round(data.win * 100 / (data.win + data.lose)) or 0))
    self.winRate_:setString(bm.LangUtil.getText("ROOM", "INFO_WIN_RATE",data.win));
    -- 设置头像

    if checkint(data.msex) ~= 1 then
        self.sexMale_:hide()
        self.sexMaleBg_:hide()
        self.sexFemale_:show()
        self.sexFemaleBg_:show()
        self.headImgFemaleBg_:show()
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("female_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    else
        self.sexMale_:show()
        self.sexMaleBg_:show()
        self.sexFemale_:hide()
        self.sexFemaleBg_:hide()
        self.headImgFemaleBg_:hide()
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("male_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
    end

    if string.len(data.micon) > 5 then
        nk.ImageLoader:loadAndCacheImage(
            self.headImageLoaderId_, 
            data.micon, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG)
    end

    --设置排名
    local playerRank = checkint(data.rank);
    if playerRank>10000 then
        self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", ">10000"))
    else
        self.ranking_:setString(bm.LangUtil.getText("ROOM", "INFO_RANKING", playerRank))
    end 
    
    -- 设置昵称
    if data.name then
        self.nick_:setString(nk.Native:getFixedWidthText("", 24, data.name, 170))
    end

    if checkint(data.isFBfriend or 0) == 1 then
        --todo
        self.delFriendBtn_:setButtonEnabled(false)
        self.delFriendBtn_:hide()
    end
end


function DeleteFriendPopUp:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(99 / texSize.width)
        self.avatar_:setScaleY(99/ texSize.height)
    end
end

function DeleteFriendPopUp:onExit()
    nk.ImageLoader:cancelJobByLoaderId(self.headImageLoaderId_)
end


return DeleteFriendPopUp