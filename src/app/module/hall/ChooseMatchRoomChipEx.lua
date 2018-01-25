-- --
-- -- Author: johnny@boomegg.com
-- -- Date: 2014-08-09 17:27:11
-- -- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
-- --
-- local ChooseMatchRoomChipEx = class("ChooseMatchRoomChipEx", bm.ui.ListItem)

-- ChooseMatchRoomChipEx.WIDTH = 436
-- ChooseMatchRoomChipEx.HEIGHT = 196


-- function ChooseMatchRoomChipEx:ctor(index,pageView)
--     -- common_transparent_skin.png
--     local chipSkin = "#match_room_chip_bg.png"
--     local nameSkin = "#match_name1.png"


--     ChooseMatchRoomChipEx.super.ctor(self, ChooseMatchRoomChipEx.WIDTH, ChooseMatchRoomChipEx.HEIGHT)
--     cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
--     self.nameSkin_ = nameSkin
--     self.chip_ = display.newSprite(chipSkin)
--         :addTo(self)
--     self.chip_:setTouchEnabled(true)
--     self.chip_:setTouchSwallowEnabled(false)
--     self.chip_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
--     self:setNodeEventEnabled(true)
--     -- 前注
--     -- self.preCallLabel_= display.newTTFLabel({text = "", color = textColor, size = 36, align = ui.TEXT_ALIGN_CENTER})
--     --     :pos(0, 20)
--     --     :addTo(self)
--     --     :hide()
--     -- display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PRE_CALL_TEXT"), color = textColor, size = 18, align = ui.TEXT_ALIGN_CENTER})
--     --     :pos(0, -6)
--     --     :addTo(self)
--     --     :hide()

--     -- 在玩人数
--     -- self.playerCountIcon_ = display.newSprite("#player_count_icon.png")
--     --     :align(display.LEFT_CENTER, 0, -34)
--     --     :addTo(self)
--     --     :hide()

--     local chipSize = self.chip_:getContentSize()
--     local playerCountLabelPosX,playerCountLabelPosY = (chipSize.width * 0.5 - 75),(chipSize.height * 0.5 - 27)

--     self.playerCountLabel_ = display.newTTFLabel({text = "", color = cc.c3b(0xFF, 0xED, 0xA4), size = 18, align = ui.TEXT_ALIGN_CENTER})
--         :align(display.LEFT_CENTER, playerCountLabelPosX, playerCountLabelPosY)
--         :addTo(self)
--         :hide()
--     self:setPlayerCount(0)

--     -- 最大买入
--     local bgPosY = -(self.chip_:getContentSize().height * 0.5 + 16)
--     display.newScale9Sprite("#player_count_bg.png", 0, 0, cc.size(148, 32))
--         :pos(0, bgPosY)
--         :addTo(self)
--         :hide()
--     self.maxBuyInLabel_ = display.newTTFLabel({text = "", color = cc.c3b(0x6C, 0xAA, 0x34), size = 18, align = ui.TEXT_ALIGN_CENTER})
--         :pos(0, bgPosY)
--         :addTo(self)
--         :hide()

--     -- local chipW,chipH = self.chip_:getContentSize().width,self.chip_:getContentSize().height
--     -- local chipSize = self.chip_:getContentSize()
--     local nameIconPosX,nameIconPosY = (-chipSize.width * 0.5 + 140),(chipSize.height * 0.5 - 27)
--     self.nameIcon_ = display.newSprite(nameSkin)
--     :align(display.LEFT_CENTER, (-chipSize.width * 0.5 + 40), nameIconPosY)
--     :addTo(self)

--     local nameIconSize = self.nameIcon_:getContentSize()
--     local nameIconW,nameIconH = nameIconSize.width,nameIconSize.height

--     self.nameLabel_ = display.newTTFLabel({text = "", color = cc.c3b(0xFF, 0xED, 0xA4), size = 18, align = ui.TEXT_ALIGN_CENTER})
--         :align(display.LEFT_CENTER, (-chipSize.width * 0.5 + 40) + nameIconW, nameIconPosY)
--         :addTo(self)

--     local prizeLabelPosX,prizeLabelPosY = nameIconPosX,nameIconPosY-nameIconH
--     self.prizeLabel_ =  display.newTTFLabel({text = "", color = cc.c3b(0xFF, 0xED, 0xA4), size = 18, align = ui.TEXT_ALIGN_CENTER})
--         :align(display.LEFT_CENTER, prizeLabelPosX,prizeLabelPosY)
--         :addTo(self)


--     local prizeLabelSize = self.prizeLabel_:getContentSize()
--     self.prizeDesLabel_ =  display.newTTFLabel({text = "", color = cc.c3b(0x1F, 0x3f, 0x10), size = 20, align = ui.TEXT_ALIGN_LEFT_CENTER,dimensions=cc.size(202, 0)})
--         :align(display.LEFT_TOP, prizeLabelPosX, prizeLabelPosY-prizeLabelSize.height * 0.5)
--         :addTo(self)

--     local bgSize = self.chip_:getContentSize()
--     self.prizeNode_ = display.newNode()
--     :addTo(self)
--     :pos(0,-bgSize.height/2+40)
--     self.prizeNode_:setContentSize(cc.size(bgSize.width-70,26))
    

--     local prizeNodeSize = self.prizeNode_:getContentSize()
--     -- display.newScale9Sprite("match/match_rank_content.png",0, 0, cc.size(bgSize.width-70,26 ))
--     -- :addTo(self.prizeNode_)

--     display.newSprite("#chip_icon.png")
--     :addTo(self.prizeNode_)
--     :pos(-prizeNodeSize.width/2+30,0)
    

--     self.enterPrice_ = display.newTTFLabel({text = "300000+3000", color = cc.c3b(0xeb, 0xe6, 0x07), size = 20, align = ui.TEXT_ALIGN_LEFT_CENTER})
--     :addTo(self.prizeNode_)
--     :pos(-prizeNodeSize.width/2+50+60,0)

--     local enterPriceSize = self.enterPrice_:getContentSize()
--     self.orLabel_ = display.newTTFLabel({text = "OR", color = cc.c3b(0xdb, 0xec, 0x87), size = 20, align = ui.TEXT_ALIGN_LEFT_CENTER})
--     :addTo(self.prizeNode_)
--     :pos(-prizeNodeSize.width/2+80 + enterPriceSize.width,0)

--     self.ticketIcon_ = display.newSprite("#hall_tong_small_ticket.png")
--         :addTo(self.prizeNode_)
--         :pos(prizeNodeSize.width/2 - 110,0)

--     self.ticketNum_ = display.newTTFLabel({text = "1", color = cc.c3b(0xeb, 0xe6, 0x07), size = 20, align = ui.TEXT_ALIGN_LEFT_CENTER})
--     :addTo(self.prizeNode_)
--     :pos(prizeNodeSize.width/2 - 70,0)


--     self.ticketApplyNode_ = display.newNode()
--     :addTo(self)
--     :pos(0,-bgSize.height/2+40)
--     self.ticketApplyNode_:setContentSize(cc.size(bgSize.width-70,26))

--      self.ticketIcon2_ = display.newSprite("#hall_tong_small_ticket.png")
--         :addTo(self.ticketApplyNode_)
--         :pos(-20,0)
--     self.ticketNum2_ = display.newTTFLabel({text = "1", color = cc.c3b(0xeb, 0xe6, 0x07), size = 20, align = ui.TEXT_ALIGN_LEFT_CENTER})
--     :addTo(self.ticketApplyNode_)
--     :pos(20,0)


--     local limitLabelPosX,limitLabelPosY = (0),(-chipSize.height * 0.5+40)
--     self.limitLabel_ = display.newTTFLabel({text = "", color = cc.c3b(0xFF, 0xED, 0xA4), size = 18, align = ui.TEXT_ALIGN_CENTER})
--         :align(display.CENTER, limitLabelPosX, limitLabelPosY)
--         :addTo(self)

--     local chipSize = self.chip_:getContentSize()
--     local icon1PosX,icon1PosY = (-chipSize.width * 0.5 + 76),(10)
--     local iconNode1 = display.newNode()
--     :pos(icon1PosX,icon1PosY)
--     :addTo(self)
--     self.icon1_ = display.newSprite("#popup_tab_bar_bg.png")
--         :addTo(iconNode1)
--         -- :hide()

--     local icon2PosX,icon2PosY = (chipSize.width * 0.5-15),(-chipSize.height * 0.5+25)
--     local iconNode2 = display.newNode()
--     :pos(icon2PosX,icon2PosY)
--     :addTo(self)

--     self.icon2_ = display.newSprite("#popup_tab_bar_bg.png")
--         :align(display.BOTTOM_RIGHT,0,0)
--         :pos(-10,25)
--         :addTo(iconNode2)
--         -- :hide()
    
--     self.imgLoaderId_1 =  nk.ImageLoader:nextLoaderId() -- 头像加载id
--     self.imgLoaderId_2 =  nk.ImageLoader:nextLoaderId() -- 头像加载id
--     self.imgLoaderId_3 =  nk.ImageLoader:nextLoaderId() -- 头像加载id
--     self.imgLoaderId_4 =  nk.ImageLoader:nextLoaderId()
--     self.imgLoaderId_5 =  nk.ImageLoader:nextLoaderId() --  场次名称加载id
-- end


-- function ChooseMatchRoomChipEx:isTouchInViewRect_(event)
--     local viewRect = self:convertToWorldSpace(cc.p(0, 0))
--     viewRect.width = ChooseMatchRoomChipEx.WIDTH
--     viewRect.height = ChooseMatchRoomChipEx.HEIGHT

--     return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
-- end


-- function ChooseMatchRoomChipEx:onTouch_(evt)
--     -- local name, curX, curY, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
--     -- if name == "began" and not self:isTouchInViewRect_(evt) then
--     --     return false
--     -- end

--     self.touchInSprite_ = self.chip_:getCascadeBoundingBox():containsPoint(cc.p(evt.x, evt.y))
--     if evt.name == "began" then
--         self:scaleTo(0.05, 0.9)
--         self.clickCanced_ = false
--         return true
--     elseif evt.name == "moved" then
--         if not self.touchInSprite_ and not self.clickCanced_ then
--             self:scaleTo(0.05, 1)
--             self.clickCanced_ = true
--         end
--     elseif evt.name == "ended" or name == "cancelled" then
--         if not self.clickCanced_ then
--             nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
--             self:scaleTo(0.05, 1)
--             -- if self.callback_ then
--             --     self.callback_(self.baseData_)
--             -- end
--             self:dispatchEvent({name="ITEM_EVENT",data=self.data_})
--         end
--     end
-- end

-- function ChooseMatchRoomChipEx:setPlayerCount(count)
--     if count >= 0 then
--         -- if self.preCall_ then
--         --     count = self.preCall_[6] * count
--         -- end
--         self.playerCountLabel_:setString(bm.formatNumberWithSplit(count))
--         -- local iconWidth = self.playerCountIcon_:getContentSize().width
--         -- local labelWidth = self.playerCountLabel_:getContentSize().width
--         -- self.playerCountIcon_:show()
--         --     :setPositionX(-(iconWidth + labelWidth + 6) * 0.5)
--         self.playerCountLabel_:show()

--         if self.baseData_ and tonumber(self.baseData_.open) == 0 then
--             self.playerCountLabel_:setString("0")
--         end
--         --     :setPositionX(self.playerCountIcon_:getPositionX() + iconWidth + 6)
--     end
-- end



-- function ChooseMatchRoomChipEx:onDataSet(dataChanged, data)
--     dump(data,"onDataSet")
--     self:updateBaseInfo(data)
--     if data and data.playerCount then
--         self:setPlayerCount(data.playerCount or 0)
--     end
-- end

-- function ChooseMatchRoomChipEx:setPreCall(val)
--     do return end 
--     self.preCall_ = val
--     if self.preCall_ and #self.preCall_ > 4 then        
--         self.preCallLabel_:setString(bm.formatBigNumber(self.preCall_[2]))
--         self.maxBuyInLabel_:setString(bm.LangUtil.getText("HALL", "MIN_BUY_IN_TEXT", bm.formatBigNumber(self.preCall_[3])))
--     end
-- end

-- function ChooseMatchRoomChipEx:getValue()
--     return (self.preCall_ and self.preCall_[2] or 0)
-- end


-- function ChooseMatchRoomChipEx:updateBaseInfo(data)
--     self.baseData_ = data
--     dump(data,"ChooseMatchRoomChipEx:updateBaseInfo")
--     self.nameLabel_:setString(data.name)
--     self.nameLabel_:setVisible(false)
--     self.prizeDesLabel_:setString(data.prize)
--     self.limitLabel_:setString(data.limit)
--     self:loadImageTexture(data)
--     if tonumber(data.fee.entry)==0 and tonumber(data.fee.serv)==0 and not data.fee.tickets then --免费场
--         self.limitLabel_:setVisible(true)
--         self.prizeNode_:setVisible(false)
--         self.ticketApplyNode_:setVisible(false)
--     elseif tonumber(data.fee.entry)==0 and tonumber(data.fee.serv)==0 and  data.fee.tickets then --门票专场(不含金币报名)
--         self.limitLabel_:setVisible(false)
--         self.prizeNode_:setVisible(false)
--         self.ticketApplyNode_:setVisible(true)
--         local needTicketId = data.fee.tickets
--         if needTicketId then
--             local ticketsArr = data.tickets
--             self.ticketNum_:setString(""..ticketsArr[""..needTicketId])
--             self.ticketNum2_:setString(""..ticketsArr[""..needTicketId])
--         end

--     else
--         self.limitLabel_:setVisible(false)
--         self.prizeNode_:setVisible(true)
--         self.ticketApplyNode_:setVisible(false)
--         local priceStr = bm.formatBigNumber(tonumber(data.fee.entry)).."+"..bm.formatBigNumber(tonumber(data.fee.serv))
--         self.enterPrice_:setString(priceStr)
--         local needTicketId = data.fee.tickets
--         if needTicketId then
--             local ticketsArr = data.tickets
--             self.ticketNum_:setString(""..ticketsArr[""..needTicketId])
--             self.ticketNum2_:setString(""..ticketsArr[""..needTicketId])
--         end

--     end
--     if tonumber(data.open) == 0 then  --木有开放
--         self.nameLabel_:hide()
--         self.prizeDesLabel_:hide()
--         self.limitLabel_:show()
--         self.icon1_:hide()
--         self.icon2_:hide()
--         self.prizeNode_:hide()
--         self.limitLabel_:setString(bm.LangUtil.getText("HALL","NOTOPEN"))
--         self.ticketApplyNode_:setVisible(false)
--         self.playerCountLabel_:setString("0")
--         self.nameIcon_:hide()
--         self.match_no_open_picture_ = display.newSprite("#match_no_open_picture.png")
--         :addTo(self)
--         :pos(-120,10)
--         self.match_no_open_title_ = display.newSprite("#match_no_open_title.png")
--         :addTo(self)
--         :pos(80,0)
--     end
    
-- end


-- function ChooseMatchRoomChipEx:getBaseInfo()
--     return self.baseData_
-- end

-- function ChooseMatchRoomChipEx:loadImageTexture(data)
    
--     if data.icon1 and string.len(data.icon1) > 0 then
--         nk.ImageLoader:loadAndCacheImage(
--             self.imgLoaderId_1, 
--             data.icon1, 
--              handler(self, self.onAvatarLoadComplete_1), 
--               nk.ImageLoader.CACHE_TYPE_MATCH
--             )
--     end

--     if data.icon2 and string.len(data.icon2) > 0 then
--         nk.ImageLoader:loadAndCacheImage(
--             self.imgLoaderId_2, 
--             data.icon2, 
--              handler(self, self.onAvatarLoadComplete_2), 
--               nk.ImageLoader.CACHE_TYPE_MATCH
--             )
--     end

--     local ticketId = data.fee.tickets;
--     if ticketId then
--         local ticketData = nk.MatchConfig:getTicketDataById(ticketId)
--         if ticketData.smallUrl and string.len(ticketData.smallUrl) > 0 then
--             nk.ImageLoader:loadAndCacheImage(
--             self.imgLoaderId_3, 
--             ticketData.smallUrl, 
--              handler(self, self.onAvatarLoadComplete_3), 
--               nk.ImageLoader.CACHE_TYPE_MATCH
--             )



--             nk.ImageLoader:loadAndCacheImage(
--             self.imgLoaderId_4, 
--             ticketData.smallUrl, 
--              handler(self, self.onAvatarLoadComplete_4), 
--               nk.ImageLoader.CACHE_TYPE_MATCH
--             )
--         end
--     end


--      if data.titleIcon and string.len(data.titleIcon) > 0 then
--         nk.ImageLoader:loadAndCacheImage(
--             self.imgLoaderId_5, 
--             data.titleIcon, 
--              handler(self, self.onAvatarLoadComplete_5), 
--               nk.ImageLoader.CACHE_TYPE_MATCH
--             )
--     end


-- end


-- function ChooseMatchRoomChipEx:onAvatarLoadComplete_1(success, sprite)
--     -- do return end
--     if success then
--         self.icon1_:show()
--          local tex = sprite:getTexture()
--          local texSize = tex:getContentSize()
--          self.icon1_:setTexture(tex)
--          self.icon1_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
--          -- self.icon1_:setScaleX(60 / texSize.width)
--          -- self.icon1_:setScaleY(60 / texSize.height)
--          if self.baseData_ and self.baseData_.open == 0 then
--             self.icon1_:hide()
--         end
--     end
-- end

-- function ChooseMatchRoomChipEx:onAvatarLoadComplete_2(success, sprite)
--     if success then
--         self.icon2_:show()
--          local tex = sprite:getTexture()
--          local texSize = tex:getContentSize()
--          self.icon2_:setTexture(tex)
--          self.icon2_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
--          -- self.icon2_:setScaleX(60 / texSize.width)
--          -- self.icon2_:setScaleY(60 / texSize.height)

--          if self.baseData_ and self.baseData_.open == 0 then
--             self.icon2_:hide()
--         end
--     end
-- end

-- function ChooseMatchRoomChipEx:onAvatarLoadComplete_3(success,sprite)
--     if success then
        
--          local tex = sprite:getTexture()
--          local texSize = tex:getContentSize()
--          self.ticketIcon_:setTexture(tex)
--          self.ticketIcon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
--          -- self.icon2_:setScaleX(60 / texSize.width)
--          -- self.icon2_:setScaleY(60 / texSize.height)
--     end
-- end
-- function ChooseMatchRoomChipEx:onAvatarLoadComplete_4(success,sprite)
--     if success then
        
--          local tex = sprite:getTexture()
--          local texSize = tex:getContentSize()
--          self.ticketIcon2_:setTexture(tex)
--          self.ticketIcon2_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
--          -- self.icon2_:setScaleX(60 / texSize.width)
--          -- self.icon2_:setScaleY(60 / texSize.height)
--     end
-- end

-- function ChooseMatchRoomChipEx:onAvatarLoadComplete_5(success,sprite)
--     if success then
        
--          local tex = sprite:getTexture()
--          local texSize = tex:getContentSize()
--          self.nameIcon_:setTexture(tex)
--          self.nameIcon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
         
--     end
-- end

-- function ChooseMatchRoomChipEx:onCleanup()
--     nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_1)
--     nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_2)
--     nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_3)
--     nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_4)
--     nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_5)
-- end


    

-- function ChooseMatchRoomChipEx:onChipClick(callback)
--      assert(type(callback) == "function", "callback should be a function")
--      self.callback_ = callback
--      return self
-- end

-- return ChooseMatchRoomChipEx