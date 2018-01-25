-- Author: thinkeras3@163.com
-- Date: 2015-10-27 10:0:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 获奖记录ITEM

local ITEM_HEIGHT = 76
local WIDTH = 700

local MatchRecordItem = class("MatchRecordItem", bm.ui.ListItem)

function MatchRecordItem:ctor()
	MatchRecordItem.super.ctor(self, WIDTH, ITEM_HEIGHT+5)
    self:setNodeEventEnabled(true)
	self.background_ = display.newScale9Sprite("#match_record_content_bg.png", 0, 0, cc.size(WIDTH,ITEM_HEIGHT ))
    :pos(WIDTH/2,ITEM_HEIGHT/2)
    :addTo(self)

	-- self.rank = 1
	-- local pictruePath = "#match_1_medal.png"
 --    self.icon_ = display.newSprite(pictruePath):addTo(self)
 --    :pos(45,ITEM_HEIGHT/2)

    self.avatar_= display.newSprite("#common_transparent_skin.png")--
    :size(70,70)
    :pos(45,ITEM_HEIGHT/2)
    :addTo(self)

    self.avatar_:setScale(0.8)

    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

     local posY = self.height_ * 0.5
     -- 昵称标签
    self.time_ =  display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "AWARD_TIME"), color = cc.c3b(0xB8, 0xBA, 0xBD), size = 24, align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, 100, posY + 15)
        :addTo(self)


    self.desc_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "RANKING"), color = cc.c3b(0x77, 0x98, 0xC9), size = 20, align = ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER, 100, posY - 20)
        :addTo(self)

    -- 资产
    -- self.rank_ =  display.newTTFLabel({text = "1", color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_LEFT})
    --     :align(display.LEFT_CENTER, 384, posY - 20)
    --     :addTo(self)


    --领奖按钮
    self.getRewardBtnLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "AWARD_GET"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.getRewardBtn_ = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(120, 42)
        :setButtonLabel("normal", self.getRewardBtnLabel_)
        :pos(630, ITEM_HEIGHT/2+7)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.getRewardClick))
    self.getRewardBtn_:setTouchSwallowEnabled(false)
end
function MatchRecordItem:setData(data)
	--self.rank_:setString(data.."")
    self.itemData_ = data
    self.time_:setString(data.time.."")
    --self.rank_:setString(data.rank.."")

    local str = bm.LangUtil.getText("MATCH", "RANK_TIPS",nk.userData["aUser.name"],data.idName,data.rank)
    self.desc_:setString(str)

    if tonumber(data.reward) == 0 then 
        self.getRewardBtn_:setVisible(true)
    else
        self.getRewardBtn_:setVisible(false)
    end

    --data.imgurl = "http://pic14.nipic.com/20110522/7411759_164157418126_2.jpg"
    if data.imgurl and string.len(data.imgurl) > 5 then
                self.loadImageHandle_ = nil
                nk.ImageLoader:loadAndCacheImage(
                    self.userAvatarLoaderId_,
                    data.imgurl, 
                    handler(self, self.onAvatarLoadComplete_), 
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
    end

end
function MatchRecordItem:onAvatarLoadComplete_(success, sprite)
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
function MatchRecordItem:getRewardClick()
    local params = {}
    params.matchid = self.itemData_.matchid
    params.uid =nk.userData["aUser.mid"]
    params.rank = self.itemData_.rank
    params.logid  = self.itemData_.logid
   
   
       self.matchGetRewardRequest_ =  nk.http.matchGetReward(params,function(data)
            nk.http.cancel(self.matchGetRewardRequest_)
            nk.userData["aUser.money"] = tonumber(data.money)
            self.getRewardBtn_:setVisible(false)
            self.owner_.updateView(data)
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "AWARD_SUCC"))--bm.LangUtil.getText("GIFT", "SET_GIFT_SUCCESS_TOP_TIP")
        end,
        function(errordata)
            nk.http.cancel(self.matchGetRewardRequest_)
        end)

end
function MatchRecordItem:onCleanup()
    nk.http.cancel(self.matchGetRewardRequest_)
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

return MatchRecordItem