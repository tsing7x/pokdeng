-- Author: thinkeras3@163.com
-- Date: 2015-10-20 10:0:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 排行榜Item

local ITEM_HEIGHT = 320/4
local WIDTH = 596

local MatchRankItem = class("MatchRankItem", bm.ui.ListItem)

function MatchRankItem:ctor()
	MatchRankItem.super.ctor(self, WIDTH, ITEM_HEIGHT)
    self:setNodeEventEnabled(true)

	-- display.newScale9Sprite("#match_award_desc_bg.png",0,0,cc.size(WIDTH,ITEM_HEIGHT))
 --    :addTo(self)
 --    :pos(WIDTH/2,ITEM_HEIGHT/2)

    display.newScale9Sprite("#match_black_line.png",0,0,cc.size(WIDTH-10,2))
    :addTo(self)
    :pos(WIDTH/2,0)

	self.rank = 1
	

    self.clubContainer_ =  display.newNode():addTo(self)
    :pos(45,ITEM_HEIGHT/2)

    local posY = self.height_ * 0.5
    self.rank_ =  display.newTTFLabel({text = "1", color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 27, posY )
        :addTo(self)



    
     -- 头像
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(57 / 100)
        :pos(120, posY)
        :addTo(self)
    self.avatarBg_ = display.newSprite("#ranking_avatar_bg.png")
        :pos(120, posY)
        :addTo(self)
    self.genderIcon_ = display.newSprite("#male_icon.png")
        :pos(144, posY - 20)
        :addTo(self)
        :scale(0.8)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id


     -- 昵称标签
    -- self.nick_ =  display.newTTFLabel({text = "", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 164, posY + 15)
    --     :addTo(self)


    self.socretxt_ = display.newTTFLabel({text = "คะแนนห้องแข่ง: ", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, 234, posY )
        :addTo(self)

    local socretxtSize = self.socretxt_:getContentSize()
    -- 资产
    self.money_ =  display.newTTFLabel({text = "+1000", color = cc.c3b(0x00, 0x6c, 0xff), size = 24, align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, 234+socretxtSize.width + 20, posY)
        :addTo(self)
end

function MatchRankItem:setData(data)
    
    self.rank_:setString(data.rank.."")
    self.money_:setString(data.leftPoints.."")
    local userInfo = json.decode(data.userinfo)

   -- self.nick_:setString(userInfo.name)

    if checkint(data.rank)<=3 then
        local pictruePath = "#match_"..data.rank.."_medal.png"
        display.newSprite(pictruePath):addTo(self.clubContainer_)
        
    end

    if checkint(userInfo.msex) ~= 1 then
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("female_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    else
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("male_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
    end

    if userInfo.mavatar and string.len(userInfo.mavatar) > 5 then
        -- if self.loadImageHandle_ then
        --     scheduler.unscheduleGlobal(self.loadImageHandle_)
        --     self.loadImageHandle_ = nil
        -- end
        --self.loadImageHandle_ = scheduler.performWithDelayGlobal(function()


            local imgurl = userInfo.mavatar
            if string.find(imgurl, "facebook") then
                if string.find(imgurl, "?") then
                    imgurl = imgurl .. "&width=100&height=100"
                else
                    imgurl = imgurl .. "?width=100&height=100"
                end
            end

                self.loadImageHandle_ = nil
                nk.ImageLoader:loadAndCacheImage(
                    self.userAvatarLoaderId_, 
                    imgurl, 
                    handler(self, self.onAvatarLoadComplete_), 
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
        --    end, 0.1 * self.index_)
    end
end
function MatchRankItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    -- if self.loadImageHandle_ then
    --     scheduler.unscheduleGlobal(self.loadImageHandle_)
    --     self.loadImageHandle_ = nil
    -- end
end

function MatchRankItem:onAvatarLoadComplete_(success, sprite)
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
return MatchRankItem