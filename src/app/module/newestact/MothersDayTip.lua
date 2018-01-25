--
-- Author: thinkeras3@163.com
-- Date: 2015-08-04 11:11:39
-- Copyright: Copyright (c) 2014, BOYAA INTERACTIVE CO., LTD All rights reserved.
--

local Panel = import("app.pokerUI.Panel")
local MotherDayTip = class("MotherDayTip", Panel)

function MotherDayTip:ctor()
     self:setNodeEventEnabled(true)--cc.rect(72,5,50,10)
     self.backgroundCenter_ = display.newScale9Sprite("#act_tips_bg1.png", 0, 0, cc.size(592, 350)):addTo(self)
     --self.backgroundCenter_ = display.newScale9Sprite("#act_tips_bg1.png", 0, 0, cc.size(592, 350),cc.rect(83,75,4,10)):addTo(self)
     self.backgroundtip = display.newSprite("#act_tips_title.png"):addTo(self)
     self.backgroundtip:pos(0,130)
     self.backgroundCenter_:setTouchEnabled(true)
     self.backgroundCenter_:setTouchSwallowEnabled(true)
     display.newTTFLabel({text = "ร่วมอวยพรคุณแม่ เขียน【สิ่งที่อยากบอก】\nหรือ【ความทรงจำเกี่ยวกับคุณแม่】รับชิปฟรีเพิ่ม 20%", color = cc.c3b(0xff, 0xff, 0xff), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :pos(-10, -20)
     :addTo(self)
     -- display.newTTFLabel({text = "【สิ่งที่อยากบอก】", color = cc.c3b(0xff, 0xff, 0x84), size = 20, align = ui.TEXT_ALIGN_CENTER})
     -- :pos(-35, -10)
     -- :addTo(self)

     --  display.newTTFLabel({text = "【ความทรงจำเกี่ยวกับคุณแม่】", color = cc.c3b(0xff, 0xff, 0x84), size = 20, align = ui.TEXT_ALIGN_CENTER})
     --  :pos(160, -10)
     --  :addTo(self)
      

      display.newTTFLabel({text = "ยินดีด้วยค่ะ คุณใช้ดอกมะลิ", color = cc.c3b(0xff, 0xff, 0xff), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :pos(-50, 50)
     :addTo(self)

     self.flowerLabel = display.newTTFLabel({text = "10 ดอก", color = cc.c3b(0xff, 0xff, 0x84), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :pos(80, 50)
     :addTo(self)

      display.newTTFLabel({text = "แลกช่อมะลิสำเร็จ ได้รับ", color = cc.c3b(0xff, 0xff, 0xff), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :pos(-50, 25)
     :addTo(self)

     self.rewardLabel = display.newTTFLabel({text = "10 ชิป!", color = cc.c3b(0xff, 0xff, 0x84), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :pos(80, 25)
     :addTo(self)

     self.join_btn = cc.ui.UIPushButton.new("#act_tips_btn.png")
     :setButtonLabel(display.newTTFLabel({size=20, color=cc.c3b(0x43, 0x85, 0xAF), text="     เข้าร่วมทันที"}))
     :onButtonClicked(buttontHandler(self, self.joinClick))
     :align(display.CENTER)
     :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
     :onButtonPressed(function(event)
            event.target:setScale(1.05)
        end)
     :pos(-20,-110)
     :addTo(self)
end
function MotherDayTip:show(data,callback)
    if self.notCloseWhenTouchModel_ then
        self:showPanel_(true, true, false, true)
    else
        self:showPanel_()
    end

    if data then
        self.flowerLabel:setString("            "..checkint(data.flower).." ดอก")
        self.rewardLabel:setString("            "..checkint(data.getMoney).." ชิป!")
    end
    self.callback = callback;
    return self
end

function MotherDayTip:joinClick()
  self:hidePanel_()
  local feedData = clone(bm.LangUtil.getText("FEED", "FLOWER_GETEDREWARD"))
  nk.Facebook:shareFeed(feedData, function(success, result)
       if not success then
          nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))     
       else   
          nk.http.shareGetMoney(
            function(data)
                if data and data.money then
                    nk.userData["aUser.money"] = checkint(data.money)
                end
                local rewardStr = "";
                if data and data.getMoney then
                    local addmoney = data.getMoney or 0;
                    rewardStr = bm.LangUtil.getText("CRASH", "GET_REWARD", addmoney)
                end 
                if data and data.flower then
                    if checkint(data.flower)>0 then
                        rewardStr = rewardStr.." ได้รับดอกมะลิ"..checkint(data.flower).."ดอก"
                    end
                end
                nk.TopTipManager:showTopTip(rewardStr)

                if self.callback then
                    self.callback()
                end
            end,
            function (errorData)
                if errorData and errorData.errorCode then
                    if errorData.errorCode ~= -3 then--  -3为已经领取过，所以不提示
                       nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL")) 
                   end
                end 
            end
            ) 

                     
       end
  end)
end

return MotherDayTip;