-- Author: thinkeras3@163.com
-- Date: 2015-10-19 10:0:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 报名弹窗1--3名奖励Item

local AWARD_CONTENT_BG_W = 264
local AWARD_CONTENT_BG_H = 154

local MatchApplyAwardItem = class("MatchApplyAwardItem", function()
	return display.newNode()
end)

function MatchApplyAwardItem:ctor(rank,data)
    if data == nil or data.desc == nil then
        data = {}
        data.desc = {}
        data.desc[1] =  bm.LangUtil.getText("MATCH", "NONE")
        data.desc[2] = ""
        data.desc[3] = ""
    end
    --dump(data.desc,"data.desc")
    self.desc_ = data.desc
	self.rank = rank
    self.data_ = data
    self:setNodeEventEnabled(true)
	self:setContentSize(cc.size(AWARD_CONTENT_BG_W,AWARD_CONTENT_BG_H))
	self:createNode_()
end

function MatchApplyAwardItem:createNode_()

	 display.newScale9Sprite("#match_award_content_bg.png", 0, 0, cc.size(AWARD_CONTENT_BG_W,AWARD_CONTENT_BG_H ))
    :pos(0,30)
    :addTo(self)

    display.newScale9Sprite("#match_award_content_title.png", 0, 0, cc.size(AWARD_CONTENT_BG_W,30 ))
    :pos(0,30+AWARD_CONTENT_BG_H/2 - 15)
    :addTo(self)


    -- local pictruePath = "#match_"..self.rank.."_medal.png"
    -- self.display.newSprite(pictruePath):addTo(self)
    -- :pos(AWARD_CONTENT_BG_W/2- 40,-5)

    -- display.newSprite("#match_light.png")
    -- :addTo(self)
    -- :pos(AWARD_CONTENT_BG_W/2- 25,20)

    self.avatar_= display.newSprite("#common_transparent_skin.png")--
    --:size(70,70)
    :pos(AWARD_CONTENT_BG_W/2- 30,-5)
    :addTo(self)

    self.avatar_:hide()

    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
     if  self.data_.imgurl and string.len( self.data_.imgurl) > 5 then
                self.loadImageHandle_ = nil
                nk.ImageLoader:loadAndCacheImage(
                    self.userAvatarLoaderId_, 
                    self.data_.imgurl, 
                    handler(self, self.onAvatarLoadComplete_), 
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
    end
    
    display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "HOW_RANK",self.rank), color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_CENTER})
    :addTo(self)
    :pos(0,30+AWARD_CONTENT_BG_H/2 - 15)

    display.newTTFLabel({text = self.desc_[1], color = cc.c3b(0x89, 0xa2, 0xc6), size = 20, dimensions = cc.size(255, 24),align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(0,AWARD_CONTENT_BG_H/2 - 20)

    local desc2 = self.desc_[2]
    if desc2 == nil then desc2 = "" end
    display.newTTFLabel({text = desc2, color = cc.c3b(0x89, 0xa2, 0xc6), size = 20, dimensions = cc.size(255, 24),align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(0,AWARD_CONTENT_BG_H/2 - 54)

     local desc3 = self.desc_[3]
    if desc3 == nil then desc3 = "" end
    display.newTTFLabel({text = desc3, color = cc.c3b(0x89, 0xa2, 0xc6), size = 20, dimensions = cc.size(255, 24),align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(0,AWARD_CONTENT_BG_H/2 - 88)

    --nk.Native:getFixedWidthText("", 20, desc or "", 193)
end
function MatchApplyAwardItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        --self.avatar_:setScaleX(59 / texSize.width)
       -- self.avatar_:setScaleY(82 / texSize.height)
        self.avatarLoaded_ = true
        self.avatar_:show()
    end
end

function MatchApplyAwardItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

 return MatchApplyAwardItem