-- Author: thinkeras3@163.com
-- Date: 2015-10-20 10:0:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 排行榜Item

local ITEM_HEIGHT = 320/4
local WIDTH = 596

local MatchRankAwardItem = class("MatchRankAwardItem", bm.ui.ListItem)

function MatchRankAwardItem:ctor()
	MatchRankAwardItem.super.ctor(self, WIDTH, ITEM_HEIGHT)
    self:setNodeEventEnabled(true)
	display.newScale9Sprite("#match_black_line.png",0,0,cc.size(WIDTH-10,2))
    :addTo(self)
    :pos(WIDTH/2,0)


    local posY = self.height_ * 0.5
    self.rank_ =  display.newTTFLabel({text = "1", color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 27, posY )
        :addTo(self)


    local pictruePath = "#match_1_medal.png"
    self.avatar_= display.newSprite(pictruePath):addTo(self)
    :pos(45,ITEM_HEIGHT/2)
    :hide()
    self.avatar_:setScale(0.8)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
    -- self.rank_ =  display.newTTFLabel({text = "1", color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 35, posY + 10)
    --     :addTo(self)--

    -- display.newTTFLabel({text = "排名:", color = cc.c3b(0x89, 0xa2, 0xc6), size = 20, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 100, posY + 15)
    --     :addTo(self)
    -- self.rankEx_ = display.newTTFLabel({text = "1", color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 160, posY + 15)
    --     :addTo(self)


    -- display.newTTFLabel({text = "筹码:", color = cc.c3b(0x89, 0xa2, 0xc6), size = 20, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 100, posY - 20)
    --     :addTo(self)

    -- display.newTTFLabel({text = "600", color = cc.c3b(0xff, 0xc0, 0x00), size = 20, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 160, posY - 20)
    --     :addTo(self)

    -- display.newTTFLabel({text = "冠军积分:", color = cc.c3b(0x89, 0xa2, 0xc6), size = 20, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 220, posY - 20)
    --     :addTo(self)
    -- display.newTTFLabel({text = "+1000", color = cc.c3b(0x00, 0x6c, 0xff), size = 20, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 314, posY - 20)
    --     :addTo(self)

    -- display.newTTFLabel({text = "XX门票:", color = cc.c3b(0x89, 0xa2, 0xc6), size = 20, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 400, posY - 20)
    --     :addTo(self)
    -- display.newTTFLabel({text = "+1000", color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 484, posY - 20)
    --     :addTo(self)

    self.money_ = display.newTTFLabel({text = "600", color = cc.c3b(0xff, 0xc0, 0x00), size = 20, dimensions = cc.size(491/3, 24),align = ui.TEXT_ALIGN_LEFT})
         :align(display.LEFT_CENTER, 100, posY )
         :addTo(self)

    self.score_ = display.newTTFLabel({text = "+1000", color = cc.c3b(0x00, 0x6c, 0xff), size = 20,  dimensions = cc.size(491/3, 24),align = ui.TEXT_ALIGN_LEFT})
         :align(display.LEFT_CENTER, 100 + 491/3, posY )
         :addTo(self)

    self.ticket_ = display.newTTFLabel({text = "+1000", color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, dimensions = cc.size(491/3, 24),align = ui.TEXT_ALIGN_LEFT})
         :align(display.LEFT_CENTER, 100+491/3*2, posY)
         :addTo(self)
end

function MatchRankAwardItem:setData(data)
    self.rank = tonumber(data.rank)
    

   self.rank_:setString(data.rank)


   dump(data,"MatchRankAwardItem:setData")
    local descTb = string.split(data.desc,",")
    -- local desc = data.desc
    self.money_:setString(descTb[1] or "")
    self.score_:setString(descTb[2] or "")
    self.ticket_:setString(descTb[3] or "")

     if  data.imgurl and string.len( data.imgurl) > 5 then
                self.loadImageHandle_ = nil
                nk.ImageLoader:loadAndCacheImage(
                    self.userAvatarLoaderId_, 
                    data.imgurl, 
                    handler(self, self.onAvatarLoadComplete_), 
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
    end
end
function MatchRankAwardItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
       -- self.avatar_:setScaleX(70 / texSize.width)
       -- self.avatar_:setScaleY(70 / texSize.height)
        self.avatarLoaded_ = true
    end
end

function MatchRankAwardItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end
return MatchRankAwardItem