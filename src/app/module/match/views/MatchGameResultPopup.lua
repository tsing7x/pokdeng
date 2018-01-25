-- Author: thinkeras3@163.com
-- Date: 2015-10-20 14:0:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 比赛结果

local MatchGameResultPopup = class("MatchGameResultPopup", nk.ui.Panel)
local WIDTH = 558
local HEIGHT = 328
local BTN_WIDTH = 143
local BTN_HEIGHT = 53
function MatchGameResultPopup:ctor(rank,matchType,resultData,callback)
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    display.addSpriteFrames("match.plist", "match.png")
	self.myRank_ = tonumber(rank)
    self.resultData_ = resultData
    self.callback_ = callback
    local matchPrizeData = nk.MatchConfigEx:getPrizeDataById(tonumber(matchType))
    -- local prize =  matchPrizeData.prize
    self.data_ = nil
    for i=1,#matchPrizeData do
        if rank == i then
            self.data_ = matchPrizeData[i]
        end
    end
    -- if tonumber(self.resultData_.type) ~= 0 then
    --     self.data_ = nil
    -- end
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:setNodeEventEnabled(true)
	self:createNode_()
    --L.FEED.WIN_MATCH
end

function MatchGameResultPopup:createNode_()
	-- body

	display.newScale9Sprite("#match_result_bg.png", 0, 0, cc.size(WIDTH,HEIGHT ))
    :pos(0,0)
    :addTo(self)

    display.newScale9Sprite("#match_result_content_bg.png", 0, 0, cc.size(541,255 ))
    :pos(0,-10)
    :addTo(self)

    display.newSprite("#match_result_light.png")
   	:addTo(self)
   	:pos(0,170)

   	display.newSprite("#match_result_title.png")
   	:addTo(self)
   	:pos(-30,140)

   	self.rank_ =  display.newTTFLabel({text = ""..self.myRank_, color = styles.FONT_COLOR.LIGHT_TEXT, size = 40, align = ui.TEXT_ALIGN_CENTER})
    :pos(30,138)
    :addTo(self)

    if self.data_ ~= nil then
	    display.newSprite("#match_result_big_club.png")
	    :addTo(self)
	    :pos(-WIDTH/2+110,0)
	else
		display.newSprite("#match_beautiful_girl.png")
	    :addTo(self)
	    :pos(-WIDTH/2+110,10)
	end

    local str = bm.LangUtil.getText("MATCH", "CONGRATULATION",self.myRank_)
    if self.data_ == nil then
        str = bm.LangUtil.getText("MATCH", "PLAY_AGAIN")
    end
    
    self.content_txt_ = display.newTTFLabel({text = str, color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, dimensions=cc.size(318, 70),align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(115,75)--328 110

    display.newScale9Sprite("#match_result_award_content.png", 0, 0, cc.size(328,108 ))
    :pos(90,-10)
    :addTo(self)

    display.newScale9Sprite("#match_result_award_title.png", 0, 0, cc.size(328,26 ))
    :pos(90,31)
    :addTo(self)

    display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "AWARD_CONTENT"), color = cc.c3b(0xff,0xc0,0x00), size = 20,dimensions=cc.size(328, 26), align = ui.TEXT_ALIGN_CENTER})
    :pos(90,31)
    :addTo(self)

    -- self.awardtxt1_ = display.newTTFLabel({text = "门票X1", color = cc.c3b(0x89, 0xa2, 0xc6), size = 20,dimensions=cc.size(300, 26), align = ui.TEXT_ALIGN_LEFT})
    -- :pos(90,5)
    -- :addTo(self)

    -- self.awardtxt2_ = display.newTTFLabel({text = "冠军积分X1", color = cc.c3b(0x89, 0xa2, 0xc6), size = 20,dimensions=cc.size(300, 26), align = ui.TEXT_ALIGN_LEFT})
    -- :pos(90,-20)
    -- :addTo(self)


    -- self.awardtxt3_ = display.newTTFLabel({text = "筹码+900", color = cc.c3b(0x89, 0xa2, 0xc6), size = 20,dimensions=cc.size(300, 26), align = ui.TEXT_ALIGN_LEFT})
    -- :pos(90,-45)
    -- :addTo(self)

    self.awardtxt_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "NONE"), color = cc.c3b(0x89, 0xa2, 0xc6), size = 20,dimensions=cc.size(300, 85), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(90,-23)

    local str = ""
    if self.data_ then
        -- for i=1,#self.data_.desc do
        --     str = str..self.data_.desc[i].." \n"
        -- end
        str = string.gsub(self.data_,",","\n")
        self.awardtxt_:setString(str)
    end

    if tonumber(self.resultData_.type) ~= 0 then
        self.awardtxt_:setString(bm.LangUtil.getText("MATCH", "AWARD_UPPER_LIMIT"))
    end

    display.newScale9Sprite("#match_result_share_bt.png", 0, 0, cc.size(BTN_WIDTH,BTN_HEIGHT ))
    :addTo(self)
    :pos(0,-100)
    :hide()

    local btnLabel = ""
    if self.data_ == nil then
        self.btnType_ = 1
        btnLabel= bm.LangUtil.getText("MATCH", "LOOKER")
    else
        self.btnType_ = 2
        btnLabel = bm.LangUtil.getText("MATCH", "SHARE")
    end
    self.shareText_ = display.newTTFLabel({text = btnLabel, color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(BTN_WIDTH, BTN_HEIGHT)
    :setButtonLabel("normal", self.shareText_)
    :onButtonClicked(buttontHandler(self, self.shareBtnClk))
    :addTo(self)
    :pos(0,-100)
    :hide()

    display.newScale9Sprite("#match_result_apply_bt.png", 0, 0, cc.size(BTN_WIDTH,BTN_HEIGHT ))
    :addTo(self)
    :pos(0,-100)
    
    self.applyNextStr_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "RETURN"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(BTN_WIDTH, BTN_HEIGHT)
    :setButtonLabel("normal", self.applyNextStr_)
    :onButtonClicked(buttontHandler(self, self.applyBtnClk))
    :addTo(self)
    -- :pos(185,-100)
    :pos(0,-100)

    display.newSprite("#match_result_debris.png")
    :addTo(self)

    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
            :pos(WIDTH * 0.5 - 22, HEIGHT * 0.5 - 25)
            :onButtonClicked(function() 
                    self:onClose()
                    if self.callback_ then
                        self.callback_(3)
                    end
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 99)
end

function MatchGameResultPopup:show()
	self:showPanel_()
end

function MatchGameResultPopup:onCleanup()
	self.callback_ = nil
    display.removeSpriteFramesWithFile("match.plist", "match.png")
end
function MatchGameResultPopup:shareBtnClk()
    -- if self.btnType_ == 1 then--分享
    --     nk.sendFeed:win_match(self.myRank_)
    -- elseif self.btnType_ == 2 then--旁观，不操作

    -- end

    -- if self.callback_ then
    --     self.callback_(self.btnType_)
    -- end
    -- self:onClose()
end

function MatchGameResultPopup:applyBtnClk()
   if self.callback_ then
        self.callback_(3)
    end
    self:onClose()
end
return MatchGameResultPopup