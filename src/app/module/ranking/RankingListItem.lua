--
-- Author: johnny@boomegg.com
-- Date: 2014-08-24 17:16:54
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local RankingListItem = class("RankingListItem", bm.ui.ListItem)
local RankingPopupController = import(".RankingPopupController")

function RankingListItem:ctor()
    self:setNodeEventEnabled(true)
    RankingListItem.super.ctor(self, 708, 95)
    self.schedulerPool_ = bm.SchedulerPool.new()

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

function RankingListItem:createContent_()
    local posY = self.height_ * 0.5
    local lineWidth = 684
    local lineHeight = 2
    local lineMarginLeft = 12

    -- 头像
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(57 / 100)
        :pos(60, posY)
        :addTo(self)
    self.avatarBg_ = display.newSprite("#ranking_avatar_bg.png")
        :pos(60, posY)
        :addTo(self)
    self.genderIcon_ = display.newSprite("#male_icon.png")
        :pos(84, posY - 20)
        :addTo(self)
        :scale(0.8)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id


    -- 名次图标
    self.rank_ = display.newSprite("#ranking_rank_label_bg.png")
        :pos(40, 76)
        :addTo(self)

    -- 排名状态
    self.rankStatusIcon_ = display.newSprite("#ranking_rank_up.png")
        :pos(self.width_ * 0.6, posY)
        :addTo(self)

    -- 追踪按钮
    self.trackBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(152, 52)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("RANKING", "TRACE_PLAYER"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("disable", display.newTTFLabel({text = bm.LangUtil.getText("RANKING", "TRACE_PLAYER"), color = styles.FONT_COLOR.DARK_TEXT, size = 22, align = ui.TEXT_ALIGN_CENTER}))
        :pos(self.width_ * 0.85, posY)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onTraceClick_))
    self.trackBtn_:setTouchSwallowEnabled(false)

    -- 名次标签
    self.ranking_ = display.newTTFLabel({text = "", color = cc.c3b(0x17, 0x7A, 0xD7), size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(40, 76)
        :addTo(self)

    -- 昵称标签
    self.nick_ =  display.newTTFLabel({text = "", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 124, posY + 20)
        :addTo(self)

    -- 资产or等级
    self.rankData_ =  display.newTTFLabel({text = "", color = cc.c3b(0x3E, 0xA2, 0xEE), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 124, posY - 20)
        :addTo(self)
end

function RankingListItem:lazyCreateContent()
    if not self.created_ then
        self.created_ = true
        self:createContent_()
    end
    if self.dataChanged_ then
        self.dataChanged_ = false
        self:setData_(self.data_)
    else
        self:updateRankItemText_()
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

function RankingListItem:onItemDeactived()
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

--[[
    需要的data数据：
        nick = "Aloha", 
        img = "img.png", 
        money = 1889, 
        level = 12, 
        ip = "192.168.0.1",
        port = "9001", 
        tid = "10012"
]]
function RankingListItem:onDataSet(dataChanged, data)
    self.dataChanged_ = self.dataChanged_ or dataChanged   
    self.data_ = data
end

function RankingListItem:updateRankItemText_()
    -- 排名数据
    if RankingPopupController.currentRankingType == 1 then
        self.rankData_:setString(bm.LangUtil.getText("COMMON", "ASSETS", bm.formatNumberWithSplit(self.data_.money or 0)))
    elseif RankingPopupController.currentRankingType == 2 then
        self.rankData_:setString(bm.LangUtil.getText("COMMON", "LEVEL", nk.Level:getLevelByExp(checkint(self.data_.exp)) or 1))
    elseif RankingPopupController.currentRankingType == 3 then
        self.rankData_:setString(bm.LangUtil.getText("COMMON", "ASSETS", bm.formatNumberWithSplit(self.data_.winMoney or 0)))
    elseif RankingPopupController.currentRankingType == 4 then
        self.rankData_:setString(bm.LangUtil.getText("COMMON", "ASSETS", bm.formatNumberWithSplit(self.data_.point or 0)))
    end
end

function RankingListItem:setData_(data)
    -- 设置名次
    self.ranking_:setString(self.index_)
    if self.index_ <= 3 then
        if self.index_ == 1 then
            self.topRankIcon_ = display.newSprite("#ranking_gold_icon.png")
            self.rank_:hide()
            self.ranking_:hide()
        elseif self.index_ == 2 then
            self.topRankIcon_ = display.newSprite("#ranking_sliver_icon.png")
            self.rank_:hide()
            self.ranking_:hide()
        elseif self.index_ == 3 then
            self.topRankIcon_ = display.newSprite("#ranking_copper_icon.png")
            self.rank_:hide()
            self.ranking_:hide()
        end
        self.topRankIcon_:pos(40, 76):addTo(self)
    else
        if self.topRankIcon_ then
            self.topRankIcon_:removeFromParent()
        end
        self.rank_:show()
        self.ranking_:show()
    end
    
    -- 设置头像
    if checkint(data.msex) ~= 1 then
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("female_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    else
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("male_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
    end
    self.avatar_:scale(57 / 100)
    if data.micon and string.len(data.micon) > 5 then
        --self.schedulerPool_:delayCall(function()
            nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            data.micon, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
        --end, 0.5 + 0.1 * self.index_)
    end 

    -- 设置昵称
    self.nick_:setString(nk.Native:getFixedWidthText("", 24, (data.name or " "), 200))
    self:updateRankItemText_()

    -- 设置名次状态 该字段作废，server表示太难搞了。
    if data.stat then
        self.rankStatusIcon_:setVisible(true)
        if data.stat == 1 then
            self.rankStatusIcon_:setSpriteFrame(display.newSpriteFrame("ranking_rank_up.png"))
        elseif data.stat == -1 then
            self.rankStatusIcon_:setSpriteFrame(display.newSpriteFrame("ranking_rank_down.png"))
        else
            self.rankStatusIcon_:setSpriteFrame(display.newSpriteFrame("ranking_rank_equal.png"))
        end
    else
        self.rankStatusIcon_:setVisible(false)
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
end

function RankingListItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(57 / texSize.width)
        self.avatar_:setScaleY(57 / texSize.height)
        self.avatarLoaded_ = true
    end
end

function RankingListItem:onTraceClick_()

    dump(self.data_,"onTraceClick_")
    local roomid = checkint(self.data_.roomid);
    if roomid <= 0 then
        return
    end
    if self.data_.gameType ==3 then--抢庄房间
        local sendData = {tableId = roomid,gameLevel = self.data_.gameLevel}
        bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = sendData})
    elseif self.data_.gameType == 2 then--私人房
        nk.server:searchPersonalRoom(nil,self.data_.roomid)
    else--普通房
        bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_ROOM_WITH_DATA, data = self.data_})
    end
    -- nk.server:loginRoom(roomid)
    nk.PopupManager:removeAllPopup()
end

function RankingListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    self.schedulerPool_:clearAll()
end

return RankingListItem