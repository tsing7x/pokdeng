-- -- Author: thinkeras3@163.com
-- -- Date: 2015-10-19 10:0:39
-- -- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- -- 用户报名弹窗


-- --[[
-- local MatchApplyPopup = class("MatchApplyPopup", nk.ui.Panel)
-- local WIDTH = 890
-- local HEIGHT = 473
-- local TOP_HEIGHT = 52
-- local AWARD_BG_HEIGHT = 178
-- local PADDING = 10
-- local BUTTON_W = 160
-- local BUTTON_H = 56

-- local MatchApplyAwardItem = import(".MatchApplyAwardItem")
-- local MatchApplyAwardItemEx = import(".MatchApplyAwardItemEx")
-- local MatchRankPopup = import(".MatchRankPopup")
-- local MatchForceExitTipPopup  = import(".MatchForceExitTipPopup")
-- local MatchExitTipPopup = import(".MatchExitTipPopup")
-- local PayGuide = import("app.module.room.purchGuide.PayGuide")
-- local FirChargePayGuidePopup = import("app.module.newstore.firChrgGuide.FirChrgPayGuidePopup")
-- local AgnChargePayGuidePopup = import("app.module.newstore.agnChrgGuide.AgnChrgPayGuidePopup")

-- function MatchApplyPopup:ctor(matchBaseInfo)
--     cc.Director:getInstance():getTextureCache():removeUnusedTextures()
--     display.addSpriteFrames("match.plist", "match.png")
    
-- 	self:setTouchEnabled(true)
--     self:setTouchSwallowEnabled(true)
--     self:setNodeEventEnabled(true)
--     self.myTicketsArr_ = {}
--     self.matchBaseInfo_ = matchBaseInfo
--     self.id_ = self.matchBaseInfo_["id"]
-- 	self:createNode_()
--     self:requestMyTickets()
--     dump(matchBaseInfo.tickets,"matchBaseInfo")
-- end

-- function MatchApplyPopup:createNode_()
-- 	display.newScale9Sprite("#match_dialog.png", 0, 0, cc.size(WIDTH,HEIGHT ))
--     :pos(0,0)
--     :addTo(self)
    

-- 	display.newScale9Sprite("#match_dialogTop.png", 0, 0, cc.size(WIDTH-8,TOP_HEIGHT ))
--     :pos(0,HEIGHT/2 - TOP_HEIGHT/2)
--     :addTo(self)

--     display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "APPLY_1"), color = cc.c3b(0x60, 0xab, 0x36), size = 30,align = ui.TEXT_ALIGN_CENTER})
--     :addTo(self)
--     :pos(0,HEIGHT/2 - TOP_HEIGHT/2)


--     self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
--             :pos(WIDTH * 0.5 - 22, HEIGHT * 0.5 - 25)
--             :onButtonClicked(function() 
--                     self:onClose()
--                     nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
--                 end)
--             :addTo(self, 99)

--     display.newScale9Sprite("#match_award_desc_bg.png",0,0,cc.size(WIDTH-40,AWARD_BG_HEIGHT))
--     :addTo(self)
--     :pos(0,AWARD_BG_HEIGHT/2 - PADDING)

--     display.newScale9Sprite("#match_award_desc_bg.png",0,0,cc.size(WIDTH-40,AWARD_BG_HEIGHT-100))
--     :addTo(self)
--     :pos(0,-(AWARD_BG_HEIGHT-100)-PADDING-5)


--     self.applyText_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "APPLY_2"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
--     self.applyBtn_ = cc.ui.UIPushButton.new({normal = "#common_btnGreenCor_nor.png", pressed = "#common_btnGreenCor_pre.png"}, {scale9 = true})
--     :setButtonSize(BUTTON_W, BUTTON_H)
--     :addTo(self)
--     :setButtonLabel("normal", self.applyText_)
--     :onButtonClicked(buttontHandler(self, self.onApplyMatch_))
--     :pos(WIDTH/5+50,-HEIGHT/2 + 2*PADDING +BUTTON_H/2)


--     self.cancelText_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "CANCEL"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
--     cc.ui.UIPushButton.new({normal = "#match_gray_btn.png", pressed = "#match_gray_btn.png"}, {scale9 = true})
--     :setButtonSize(BUTTON_W, BUTTON_H)
--     :addTo(self)
--     :setButtonLabel("normal", self.cancelText_)
--     :onButtonClicked(buttontHandler(self, self.onClose))
--     :pos(-WIDTH/5+175,-HEIGHT/2 + 2*PADDING +BUTTON_H/2)

--     display.newScale9Sprite("#match_yellow_buy_tk_bt.png",0,0,cc.size(BUTTON_W,BUTTON_H))
--     :addTo(self)
--     :pos(-WIDTH/5-50,-HEIGHT/2 + 2*PADDING +BUTTON_H/2)
--     display.newSprite("#tong_big_ticket.png")
--     :addTo(self)
--     :pos(-WIDTH/5-100,-HEIGHT/2 + 2*PADDING +BUTTON_H/2)
--     :setScale(.5)

--     display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "BUY"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
--     :addTo(self)
--     :pos(-WIDTH/5-30,-HEIGHT/2 + 2*PADDING +BUTTON_H/2)

--     cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
--     :setButtonSize(BUTTON_W-5, BUTTON_H)
--     :pos(-WIDTH/5-50,-HEIGHT/2 + 2*PADDING +BUTTON_H/2)
--     :onButtonClicked(buttontHandler(self, self.buyTicket))
--     :addTo(self)

--     local matchPrizeData = nk.MatchConfig:getPrizeDataById(self.id_)
--     dump(matchPrizeData,"matchPrizeData")
--     self.itemArr_ = {}
--     local size = 0
--     for i=1,3 do
--         local item = MatchApplyAwardItem.new(i,matchPrizeData.prize[i])
--         size = item:getContentSize()
--         table.insert(self.itemArr_,item)
--         self.itemArr_[i]:addTo(self)
--     end
--     self.itemArr_[1]:pos(-size.width - 15,50)
--     self.itemArr_[2]:pos(0,50)
--     self.itemArr_[3]:pos(size.width + 15,50)

--     self.moreAward_ = display.newNode()
--     :addTo(self)
--     :pos(WIDTH/2 - 190/2 - 20,-23)

    
--     if #matchPrizeData.prize > 3 then
--         display.newScale9Sprite("#match_moreAward_bg.png", 0, 0, cc.size(190,44),cc.rect(13,18,3,3))
--         :addTo(self.moreAward_)

--         display.newSprite("#match_moreAward.png")
--         :addTo(self.moreAward_)
--         :pos(-55,-5)

--         display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "MORE_AWARD"), color = cc.c3b(0x6a,0x78,0xff), size = 20, align = ui.TEXT_ALIGN_CENTER})
--         :addTo(self.moreAward_)
--         :pos(15,-5)

--         cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
--         :setButtonSize(190, 44)
--         :onButtonClicked(buttontHandler(self, self.moreAwardHandler))
--         :addTo(self.moreAward_)
--     end

--     self.chipsApplyNode_ = display.newNode()
--     :addTo(self)
--     :pos(0,-(AWARD_BG_HEIGHT-100)-PADDING-5)
--     self.buttonNode_ = display.newNode()
--     :addTo(self.chipsApplyNode_)
--     :pos(WIDTH/2-150,0)
--     display.newScale9Sprite("#match_change_apply.png",0,0,cc.size(240,62))
--     :addTo(self.buttonNode_)
--     display.newSprite("#tong_big_ticket.png")
--     :addTo(self.buttonNode_)
--     :pos(-80,0)
--     :setScale(.5)
--     display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "JOIN_BY_TICKETN"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
--     :addTo(self.buttonNode_)
--     :pos(20,2)
--     cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
--     :setButtonSize(230, 50)
--     :onButtonClicked(buttontHandler(self, self.useTicketApply))
--     :addTo(self.buttonNode_)

--     self.enterpriceTxt1_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "JOIN_FEE"), color = cc.c3b(0x89,0xa2,0xc6),dimensions = cc.size(140, 30), size = 20, align = ui.TEXT_ALIGN_RIGHT})
--     :addTo(self.chipsApplyNode_)
--     :pos(-WIDTH/2+90,20)

--     local enterpriceTxt1Size = self.enterpriceTxt1_:getContentSize()
--     local icon1_X = -WIDTH/2+90 + enterpriceTxt1Size.width/2 + 20;
--      display.newSprite("#chip_icon.png")
--      :addTo(self.chipsApplyNode_)
--      :pos(icon1_X,20)

--     local applyMoney = self.matchBaseInfo_.fee["entry"] or 0;
--     local servMoney = self.matchBaseInfo_.fee["serv"] or 0;
--     if tonumber(applyMoney) == 0 then 
--         applyMoney = bm.LangUtil.getText("MATCH", "FREE")
--         servMoney = bm.LangUtil.getText("MATCH", "FREE")
--     else
--         applyMoney = bm.formatBigNumber(tonumber(applyMoney))
--         servMoney = bm.formatBigNumber(tonumber(servMoney))
--     end
--     self.applyMoneyTxt_ = display.newTTFLabel({text = ""..applyMoney, color = cc.c3b(0xe1,0xc8,0x02), size = 20, align = ui.TEXT_ALIGN_LEFT})
--     :addTo(self.chipsApplyNode_)
--     :align(display.LEFT_CENTER)
--     :pos(icon1_X + 20,20)

--     local applyMoneyTxtSize = self.applyMoneyTxt_:getContentSize()
--     local servMoenyTxtX  = icon1_X + 50 + applyMoneyTxtSize.width/2 + 100

--     self.servMoneyTxt_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "SERVICE_FEE"), color = cc.c3b(0x89,0xa2,0xc6), size = 20, align = ui.TEXT_ALIGN_LEFT})
--     :addTo(self.chipsApplyNode_)
--     :pos(servMoenyTxtX,20)

--     local size1 = self.servMoneyTxt_:getContentSize()
--     local icon2_X = servMoenyTxtX + size1.width/2+20
--     display.newSprite("#chip_icon.png")
--      :addTo(self.chipsApplyNode_)
--      :pos(icon2_X,20)

--     display.newTTFLabel({text = ""..servMoney, color = cc.c3b(0xe1,0xc8,0x02), size = 20, align = ui.TEXT_ALIGN_LEFT})
--     :addTo(self.chipsApplyNode_)
--     :align(display.LEFT_CENTER)
--     :pos(icon2_X + 20,20)

--     self.myChipsTxt_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "YOU_CHIPS"), color = cc.c3b(0x89,0xa2,0xc6), size = 20,dimensions = cc.size(140, 30), align = ui.TEXT_ALIGN_RIGHT})
--     :addTo(self.chipsApplyNode_)
--     :pos(-WIDTH/2+90,-20)

--     local myChipsTxtSize = self.myChipsTxt_:getContentSize()
--     local icon3_X = -WIDTH/2+90 + myChipsTxtSize.width/2 + 20 
--      display.newSprite("#chip_icon.png")
--      :addTo(self.chipsApplyNode_)
--      :pos(icon3_X,-20)

--     local myChips = bm.formatNumberWithSplit(nk.userData["aUser.money"])
--     display.newTTFLabel({text = ""..myChips, color = cc.c3b(0xe1,0xc8,0x02), size = 20, align = ui.TEXT_ALIGN_LEFT})
--     :addTo(self.chipsApplyNode_)
--     :align(display.LEFT_CENTER)
--     :pos(icon3_X + 20,-20)

--     self.chipApplyTips_ = display.newTTFLabel({text = "", color = cc.c3b(0xff,0x00,0x00), size = 20,dimensions = cc.size(783, 28), align = ui.TEXT_ALIGN_LEFT})
--     :addTo(self.chipsApplyNode_)
--     :align(display.LEFT_CENTER)
--     :pos(-WIDTH/2+20,-50)


--     self.ticketApplyNode_ = display.newNode()
--     :addTo(self)
--     :hide()
--     :pos(0,-(AWARD_BG_HEIGHT-100)-PADDING-5)
--     self.buttonNode2_ = display.newNode()
--     :addTo(self.ticketApplyNode_)
--     :pos(WIDTH/2-150,0)
--     display.newScale9Sprite("#match_change_apply.png",0,0,cc.size(240,62))
--     :addTo(self.buttonNode2_)
--     display.newSprite("#chip_icon.png")
--     :addTo(self.buttonNode2_)
--     :pos(-80,0)
--     display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "JOIN_BY_CHIPS"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
--     :addTo(self.buttonNode2_)
--     :pos(20,2)
--     cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
--     :setButtonSize(230, 50)
--     :onButtonClicked(buttontHandler(self, self.useChipsApply))
--     :addTo(self.buttonNode2_)

--     display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "JOIN_FEE"), color = display.COLOR_WHITE, size = 20, align = ui.TEXT_ALIGN_CENTER})
--     :addTo(self.ticketApplyNode_)
--     :pos(-WIDTH/2+40,15)
--     :align(display.LEFT_CENTER)

--     self.ticketName_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "YOU_TICKETS"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
--     :addTo(self.ticketApplyNode_)
--     :pos(-WIDTH/2+40,-20)
--     :align(display.LEFT_CENTER)

--     self.ticketNum_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "PICS","1"), color = cc.c3b(0xe1,0xc8,0x02), size = 20, align = ui.TEXT_ALIGN_CENTER})
--     :addTo(self.ticketApplyNode_)
--     :pos(-WIDTH/2+210,-20)
--     :align(display.LEFT_CENTER)

--     local ticketsTable = self.matchBaseInfo_.tickets
--     self.ticketsIdArr = {}
--     for k,v in pairs(ticketsTable) do
--          table.insert(self.ticketsIdArr,k)
--     end
--     table.sort( self.ticketsIdArr, function( a1,a2 )
--         return a1 < a2
--     end )

--     self.icon1_ = display.newSprite("#tong_small_ticket.png")
--     :addTo(self.ticketApplyNode_)
--     --:pos(-WIDTH/2+100,-20)

--     self.icon2_ = display.newSprite("#tong_small_ticket.png")
--     :addTo(self.ticketApplyNode_)
--     --:pos(-WIDTH/2+100,-20)

--     local ticketsStr1 = "";
--     local ticketsStr2 = "";
--     if self.ticketsIdArr and #self.ticketsIdArr>0 then
--         self.buttonNode_:show()
--         local ticketdata1 = nk.MatchConfig:getTicketDataById(checkint(self.ticketsIdArr[1]))
--         local ticketdata2 = nk.MatchConfig:getTicketDataById(checkint(self.ticketsIdArr[2]))
--         ticketsStr1 = ticketdata1.name.."x"..ticketsTable[self.ticketsIdArr[1]]
--         if ticketdata2 == nil then 
--             ticketsStr2 = ""
--         else
--              ticketsStr2 = ticketdata2.name.."x"..ticketsTable[self.ticketsIdArr[2]]
--         end
--         self:addTicketImage(ticketdata1,ticketdata2)
--     else
--         self.buttonNode_:hide()
--     end

--     local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)
--         :addButton(cc.ui.UICheckBoxButton.new({off="#match_checkbox_off.png", on="#match_checkbox_on.png"})
--             :setButtonLabel(display.newTTFLabel({text = ticketsStr1, color = display.COLOR_WHITE,size = 20}))
--             :setButtonLabelOffset(60, 0)
--             :align(display.LEFT_CENTER))
--         :addButton(cc.ui.UICheckBoxButton.new({off="#match_checkbox_off.png", on="#match_checkbox_on.png"})
--             :setButtonLabel(display.newTTFLabel({text = ticketsStr2, color = display.COLOR_WHITE,size = 20}))
--             :setButtonLabelOffset(60, 0)
--             :align(display.LEFT_CENTER))       
--         :setButtonsLayoutMargin(10, 10, 10, 10)
--         :onButtonSelectChanged(function(event)
--             --print("Option %d selected, Option %d unselected", event.selected, event.last)
--             --self:switchLang_(self:langIndexToStr_(event.selected))
--             --dump(event.selected,"selected")
--             self.ticketType_ = event.selected
--             self:setTicketInfo() 
--         end)
--         --:align(display.LEFT_TOP,LEFT + 50, TOP - 250)
--         :addTo(self.ticketApplyNode_)
--         :pos(-WIDTH/2+40 + 70,-10)
--     group:getButtonAtIndex(1)
--     :setButtonSelected(true)
--     self.ticketType_ = 1
--     self.awardListNode_ = display.newNode()
--     :addTo(self)
--     :pos(0,-(AWARD_BG_HEIGHT-100)-PADDING-5)
--     :hide()

--     self.icon1_:pos(-250,15)
--     self.icon2_:pos(45,15)

--     if self.ticketsIdArr[2] == nil then
--         group:getButtonAtIndex(2)
--         :hide()
--         self.icon2_:hide()
--     end

--     local btn = group:getButtonAtIndex(1)
--     local ss = group:convertToWorldSpace(cc.p(btn:getPosition()))
--     local dd = self.ticketApplyNode_:convertToNodeSpace(ss)
--     self.icon1_:pos(dd.x + 50,15)
   
--     local btn2 = group:getButtonAtIndex(2)
--     local sss = group:convertToWorldSpace(cc.p(btn2:getPosition()))
--     local ddd = self.ticketApplyNode_:convertToNodeSpace(sss)

--     -- local fuck = display.newTTFLabel({text = "fuckdandan", color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})

--     -- btn:setButtonLabel("normal",fuck)
--     -- dump(ddd.x,"fuckdandan")
--     self.icon2_:pos(ddd.x + 50,15)

--      -- 添加列表
--     self.list_ = bm.ui.ListView.new(
--         {
--             viewRect = cc.rect(-828* 0.5 , -72 * 0.5, 828, 72),
--             direction = bm.ui.ListView.DIRECTION_VERTICAL
--         }, 
--             MatchApplyAwardItemEx
--     )
--     :pos(0, 0)
--     :addTo(self.awardListNode_)

--     self.applyType_ = 1;
--     local fee_data = self.matchBaseInfo_.fee
--     if fee_data["serv"] == 0 and fee_data["entry"]==0 and fee_data["tickets"] then
--         self.canApplyType_ = 2 -- 只允许门票报名 1:免费赛 3:两种报名方式都可以
--         self.chipsApplyNode_:hide()
--         self.ticketApplyNode_:show()
--         self.buttonNode2_:hide()
--         self.applyType_ = 2
--     elseif  fee_data["serv"] == 0 and fee_data["entry"]==0 and not fee_data["tickets"] then
--         self.canApplyType_ = 1 -- 只允许门票报名 1:免费赛 3:两种报名方式都可以
--     else
--         self.canApplyType_ = 3 -- 只允许门票报名 1:免费赛 3:两种报名方式都可以
--     end

-- end
-- function MatchApplyPopup:setTicketInfo()
--     if self.ticketsIdArr==nil or #self.ticketsIdArr==0 then return end
--     local ticketId = self.ticketsIdArr[self.ticketType_]
--     local ticketName =  nk.MatchConfig:getTicketDataById(checkint(ticketId)).name
--     self.ticketName_:setString(""..ticketName.. bm.LangUtil.getText("MATCH", "NUM"))
--     local num = 0
--     for i=1,#self.myTicketsArr_ do
--         if checkint(ticketId) == checkint(self.myTicketsArr_[i].pnid) then
--             num = self.myTicketsArr_[i].pcnter
--         end
--     end
--     self.ticketNum_:setString(""..num)
--     local ticketNameSize = self.ticketName_:getContentSize()
--     self.ticketNum_:pos(-WIDTH/2+40 +ticketNameSize.width+20, -20)
-- end
-- --检测是否可以用门票报名该比赛
-- --优先显示门票报名
-- function MatchApplyPopup:checkMyticket()
--     --self.myTicketsArr_
--     if self.ticketsIdArr == nil or #self.ticketsIdArr == 0 then--免费赛

--     else
--         local haveTicket = 0 
--         for i=1,#self.ticketsIdArr do
--             for j=1,#self.myTicketsArr_ do
--                 if tonumber(self.ticketsIdArr[i]) == tonumber(self.myTicketsArr_[j].pnid ) then
--                     if tonumber(self.myTicketsArr_[j].pcnter)> 0 then
--                         haveTicket = 1
--                     end
--                 end
--             end
--         end
--         if self.canApplyType_ == 3 then
--             if haveTicket == 1 then
--                 self.ticketApplyNode_:show()
--                 self.chipsApplyNode_:hide()
--                 self.applyType_ = 2
--             else
--                 self.ticketApplyNode_:hide()
--                 self.chipsApplyNode_:show()
--                 self.applyType_ = 1
--             end
--         end
--     end
-- end
-- function MatchApplyPopup:requestMyTickets()
--     self.getTicketRequestId = nk.http.getUserTickets(
--         function(data)
--             nk.http.cancel( self.getTicketRequestId )
--             self.myTicketsArr_ = data
--             self:setTicketInfo()
--             self:checkMyticket()
--         end,
--         function(errorData)
--             nk.http.cancel( self.getTicketRequestId )
--             --nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
--         end
--     )
-- end
-- function MatchApplyPopup:show()
-- 	self:showPanel_()
-- end
-- function MatchApplyPopup:onShowed()
--     if self.list_ then 
--        -- self.list_:setData({1,2,2,5,6,6,7,7,7,7,7,7,7,7,7})
--         self.list_:update()
--         self.list_:update()
--     end
--     self:setLoading(true)
--     self.getFreeApplyMatchNumRequest_ = nk.http.getFreeApplyMatchNum(self.id_,function(data)
--         self:setLoading(false)
--         nk.http.cancel(self.getFreeApplyMatchNumRequest_)
--         if tonumber(data.limit) == 0  then
--             self.chipApplyTips_:setString("")
--             return
--         else
--             self.chipApplyTips_:setString(bm.LangUtil.getText("MATCH", "CAN_JOIN_NUM_BY_CHIPS")..data.todayJoinNum.."/"..data.limit)
--             if self.matchBaseInfo_.fee["entry"] == 0 then
--                 self.chipApplyTips_:setString(bm.LangUtil.getText("MATCH", "CAN_JOIN_NUM_BY_FREE")..data.todayJoinNum.."/"..data.limit)
--             end
--         end
--     end,function(errorData)
--         nk.http.cancel(self.getFreeApplyMatchNumRequest_)
--         self:setLoading(false)
--         self.chipApplyTips_:setString("")
--     end);
-- end
-- function MatchApplyPopup:moreAwardHandler()

--     if not self.showedMoreAward then
--         self.ticketApplyNode_:hide()
--         self.chipsApplyNode_:hide()
--         self.awardListNode_:show()
--         self.showedMoreAward = 1

--         self.list_:update()
--         self.list_:update()

--         local data = {}
--         local matchPrizeData = nk.MatchConfig:getPrizeDataById(self.id_)
--         for i=4,#matchPrizeData.prize do
--             table.insert(data,matchPrizeData.prize[i])
--         end
--         self.list_:setData(data)
--     else
--         self.showedMoreAward = nil
--         self.ticketApplyNode_:show()
--         self.chipsApplyNode_:hide()
--         self.awardListNode_:hide()
--         self.applyType_ = 2
--     end
--     --
    
-- end
-- function MatchApplyPopup:useChipsApply()
--     self.ticketApplyNode_:hide()
--     self.chipsApplyNode_:show()
--     self.applyType_ = 1
-- end
-- function MatchApplyPopup:useTicketApply()
--     self.ticketApplyNode_:show()
--     self.chipsApplyNode_:hide()
--     self.applyType_ = 2
-- end
-- function MatchApplyPopup:buyTicket()
--     self:onClose()

--     local isThirdPayOpen = nk.OnOff:check("payGuide")
--     local isFirstCharge = nk.userData.best.paylog == 0 or false
--     local isAlmChargeFavPay = nk.userData.bagPayList and nk.userData.bagPayList.almRechgFav == 1 or false

--     if nk.OnOff:check("firstchargeFavGray") and isThirdPayOpen and isFirstCharge then
--         --todo
--         FirChargePayGuidePopup.new():showPanel()
--     else
--         if nk.OnOff:check("rechargeFavGray") and isThirdPayOpen and not isFirstCharge and not isAlmChargeFavPay then
--             --todo
--             AgnChargePayGuidePopup.new():showPanel()
--         else
--             local params = {}

--             params.isOpenThrPartyPay = isThirdPayOpen
--             params.isFirstCharge = isFirstCharge
--             params.sceneType = 1
--             params.payListType = nil
--             params.isSellCashCoin = true

--             if isThirdPayOpen then
--                 --todo
--                 PayGuide.new(params):show()
--             else
--                 local cashPaymentPageIdx = 2
--                 StorePopup.new(cashPaymentPageIdx):showPanel()
--             end
--         end
--     end
-- end

-- function MatchApplyPopup:onApplyMatch_()
--     --MatchExitTipPopup.new():show()
--    -- MatchGameResultPopup.new(1,2):show()
--     --  nk.TopTipManager:showTopTip(""..self.applyType_)
--     --  MatchForceExitTipPopup.new(0):show()
--     -- -- bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_MATCH_WITH_DATA, data = nil})
--     --  do return end
--     self:setLoading(true)
--     self.applyBtn_:setButtonEnabled(false)  --免得重复报名
--     local ticketID = 0
--     if self.applyType_ == 1 then  --金币报名

--     else                        --门票报名
--        ticketID = self.ticketsIdArr[self.ticketType_]
--        dump(ticketID,"ticketType_")
--        local ticketName =  nk.MatchConfig:getTicketDataById(checkint(ticketID)).name
--        dump(ticketName,"ticketName")
--        dump(self.id_,"id")

--     end
--     self.applyMatchRequestId_ = nk.http.applyMatch(self.id_,self.applyType_,ticketID,
--         function(data)
--             self:setLoading(false)
--             nk.http.cancel(self.applyMatchRequestId_)
--             self.applyBtn_:setButtonEnabled(true)
--             local matchid = data.matchid 
--             local tid = data.tid
--             local money = checkint(data.money)
--             nk.userData["aUser.money"]=money
--             bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_MATCH_WITH_DATA, data = {tid = tid,matchid = matchid}})
--             self:onClose()
--         end,
--         function(errorData)
--            self:setLoading(false)
--             nk.http.cancel(self.applyMatchRequestId_)
--             self.applyBtn_:setButtonEnabled(true)
--             if errorData.errorCode == -1 then  -- 缺少参数
--                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "APPLY_FAIL",errorData.errorCode))
--             elseif errorData.errorCode == -2 then-- 比赛场关闭
--                 local errTips = bm.LangUtil.getText("HALL", "NOTOPEN")
--                 if errorData.retData and errorData.retData.data then
--                     local msg = errorData.retData.data["msg"]
--                     if msg and msg ~= "" then
--                         errTips = msg
--                     end
--                 end
--                 nk.TopTipManager:showTopTip(errTips)
--             elseif errorData.errorCode == -3 then-- 金币不足
--                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "CHIP_NO_ENOUGH"))
--             elseif errorData.errorCode == -4 then-- 门票不足
--                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "TICKET_NO_ENOUGH"))
--             elseif errorData.errorCode == -5 then-- 报名失败
--                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "APPLY_FAIL",errorData.errorCode))
--             elseif errorData.errorCode == -6 then-- PHP向SERVER报名失败
--                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "APPLY_FAIL",errorData.errorCode))
--             elseif errorData.errorCode == -8 then
--                 if self.matchBaseInfo_.fee["entry"] == 0 then
--                     nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "APPLY_FREE_OVER"))
--                 else
--                     nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "APPLY_CHIPS_OVER"))
--                 end    
--             else
--                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("MATCH", "APPLY_FAIL",errorData.errorCode))
--             end
--         end
--     )



--     --bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_MATCH_WITH_DATA, data = nil})
--     --do return end
--    -- MatchRankPopup.new():show()
--    -- MatchGameResultPopup.new(1):show()
-- end
-- function MatchApplyPopup:addTicketImage(ticketdata1,ticketdata2)
--     self.imgLoaderId_1 =  nk.ImageLoader:nextLoaderId() -- 头像加载id
--     self.imgLoaderId_2 =  nk.ImageLoader:nextLoaderId() -- 头像加载id


--     if ticketdata1 and ticketdata1.smallUrl and string.len(ticketdata1.smallUrl) > 0 then
--         nk.ImageLoader:loadAndCacheImage(
--             self.imgLoaderId_1, 
--             ticketdata1.smallUrl, 
--              handler(self, self.onAvatarLoadComplete_1), 
--               nk.ImageLoader.CACHE_TYPE_MATCH
--             )
--     end

--     if ticketdata2 and ticketdata2.smallUrl and string.len(ticketdata2.smallUrl) > 0 then
--         nk.ImageLoader:loadAndCacheImage(
--             self.imgLoaderId_2, 
--             ticketdata2.smallUrl, 
--              handler(self, self.onAvatarLoadComplete_2), 
--               nk.ImageLoader.CACHE_TYPE_MATCH
--             )
--     end

-- end

-- function MatchApplyPopup:onAvatarLoadComplete_1(success, sprite)
--     if success then
--         self.icon1_:show()
--          local tex = sprite:getTexture()
--          local texSize = tex:getContentSize()
--          self.icon1_:setTexture(tex)
--          self.icon1_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
--          -- self.icon2_:setScaleX(60 / texSize.width)
--          -- self.icon2_:setScaleY(60 / texSize.height)
--     end
-- end

-- function MatchApplyPopup:onAvatarLoadComplete_2(success, sprite)
--     if success then
--         self.icon2_:show()
--          local tex = sprite:getTexture()
--          local texSize = tex:getContentSize()
--          self.icon2_:setTexture(tex)
--          self.icon2_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
--          -- self.icon2_:setScaleX(60 / texSize.width)
--          -- self.icon2_:setScaleY(60 / texSize.height)
--     end
-- end
-- function MatchApplyPopup:onCleanup()
-- 	nk.http.cancel(self.applyMatchRequestId_)
--     nk.http.cancel( self.getTicketRequestId )
--     nk.http.cancel(self.getFreeApplyMatchNumRequest_)
--     nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_1)
--     nk.ImageLoader:cancelJobByLoaderId(self.imgLoaderId_2)
--     display.removeSpriteFramesWithFile("match.plist", "match.png")
-- end

-- function MatchApplyPopup:setLoading(isLoading)
--     if isLoading then
--         if not self.juhua_ then
--             self.juhua_ = nk.ui.Juhua.new()
--                --:pos(display.cx, display.cy)
--                 :addTo(self)
--         end
--     else
--         if self.juhua_ then
--             self.juhua_:removeFromParent()
--             self.juhua_ = nil
--         end
--     end
-- end

-- return MatchApplyPopup

