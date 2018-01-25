--
-- Author: thinkeras3@163.com
-- Date: 2015-08-02 11:11:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
--

local MouthersDayActPopup = class("MouthersDayActPopup", function() return display.newNode() end)
local FriendPopup         = import("app.module.friend.FriendPopup")
local InvitePopup         = import("app.module.friend.InvitePopup")


function MouthersDayActPopup:ctor(parentPanel)
    self.flowerNum_=0;
    self.parentPanel_ = parentPanel


	self.button_Arr = {"เชิญทันที","แชร์ทันที","เล่นไพ่ทันที","ค้นหาเพื่อน"};--立即邀请，立即分享，立即玩牌，查看好友

	 self.background = cc.ui.UIImage.new("#atc_bg.png")
     :align(display.CENTER)
     :pos(0,-40)
     :addTo(self)

     self.titlebg = cc.ui.UIImage.new("#act_title.png")
     :align(display.CENTER)
     :pos(0,170)
     :addTo(self)

     self.flower = cc.ui.UIImage.new("#act_flower.png")
     :align(display.CENTER)
     :pos(-300,20)
     :addTo(self)

     self.sendflowerBtn = cc.ui.UIPushButton.new({normal="#act_left_btn.png", pressed="#act_left_btn_down.png"}, {scale9=true})
     :setButtonLabel(display.newTTFLabel({size=30, color=cc.c3b(0xff, 0xd2, 0x88), text=""}))
     :setButtonSize(200, 62)
     :onButtonClicked(buttontHandler(self, self.sendFlowerClick))
     :align(display.CENTER)
     :pos(-300,-70)
     :addTo(self)

     display.newTTFLabel({text = "แลกชิป", color = cc.c3b(0x2a, 0x6d, 0x98), size = 36, align = ui.TEXT_ALIGN_CENTER})
     :pos(-300, -60)
     :addTo(self)

     display.newTTFLabel({text = "(10 ดอกขึ้นไป)", color = cc.c3b(0x2a, 0x6d, 0x98), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :pos(-300, -83)
     :addTo(self)

     self.top_title_bg = cc.ui.UIImage.new("#act_top_title_bg.png")
     :align(display.CENTER)
     :pos(0,125)
     :addTo(self)

     --收集茉莉花，为母亲祈福！
      self.top_title_txt = cc.ui.UILabel.new({text = "ระยะเวลากิจกรรม : 7-13 ส.ค. 58", size = 20, color = display.COLOR_WHITE})
      :align(display.CENTER, 0, 125)
      :addTo(self)


     for i=1,4 do
     	display.newSprite("#act_item_bg.png")
        :pos(115, -(i*55)+90)
        :align(display.CENTER)
        :addTo(self)
     end

     self.invate_btn = cc.ui.UIPushButton.new({normal="#act_right_btn_up.png", pressed="#act_right_btn_down.png"}, {scale9=true})
     :setButtonLabel(display.newTTFLabel({size=20, color=cc.c3b(0x43, 0x85, 0xAF), text=self.button_Arr[1]}))
     :setButtonSize(120, 40)
     :onButtonClicked(buttontHandler(self, self.inviteClick))
     :align(display.CENTER)
     :pos(330,35)
     :addTo(self)

     self.share_btn = cc.ui.UIPushButton.new({normal="#act_right_btn_up.png", pressed="#act_right_btn_down.png"}, {scale9=true})
     :setButtonLabel(display.newTTFLabel({size=20, color=cc.c3b(0x43, 0x85, 0xAF), text=self.button_Arr[2]}))
     :setButtonSize(120, 40)
     :onButtonClicked(buttontHandler(self, self.shareClick))
     :align(display.CENTER)
     :pos(330,-20)
     :addTo(self)

     self.play_btn = cc.ui.UIPushButton.new({normal="#act_right_btn_up.png", pressed="#act_right_btn_down.png"}, {scale9=true})
     :setButtonLabel(display.newTTFLabel({size=20, color=cc.c3b(0x43, 0x85, 0xAF), text=self.button_Arr[3]}))
     :setButtonSize(120, 40)
     :onButtonClicked(buttontHandler(self, self.playClick))
     :align(display.CENTER)
     :pos(330,-75)
     :addTo(self)

     self.checkFriend_btn = cc.ui.UIPushButton.new({normal="#act_right_btn_up.png", pressed="#act_right_btn_down.png"}, {scale9=true})
     :setButtonLabel(display.newTTFLabel({size=20, color=cc.c3b(0x43, 0x85, 0xAF), text=self.button_Arr[4]}))
     :setButtonSize(120, 40)
     :onButtonClicked(buttontHandler(self, self.checkFriendClick))
     :align(display.CENTER)
     :pos(330,-130)
     :addTo(self)

     -- display.newTTFLabel({text = "เชิญเพื่อน", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})--1,邀请好友
     -- :align(display.CENTER, -115, 45)
     -- :addTo(self)--每成功邀请一位好友，直接获得20朵茉莉花
     -- display.newTTFLabel({text = "เชิญเพื่อนสำเร็จ 1 ท่าน รับดอกมะลิ 20 ดอกทันที", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})
     -- :align(display.CENTER, 18, 25)
     -- :addTo(self)

     -- display.newTTFLabel({text = "แชร์กิจกรรม", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})--2,分享活动
     -- :align(display.CENTER, -115, -12)
     -- :addTo(self)--参与游戏中任意分享，可获得10朵茉莉花，每日限1次
     -- display.newTTFLabel({text = "แชร์อะไรก็ได้ในเกมส์ รับดอกมะลิ 10 ดอก จำกัด 1 ครั้ง/วัน", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})
     -- :align(display.CENTER, 40, -32)
     -- :addTo(self)

     -- display.newTTFLabel({text = "เล่นไพ่", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})--2,玩牌获得
     -- :align(display.CENTER, -115, -62)
     -- :addTo(self)--每玩5局即可获得3朵，每天最多600朵
     -- display.newTTFLabel({text = "เล่นไพ่ 5 รอบ รับดอกมะลิ 3 ดอก มากสุด 600 ดอก/วัน", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})
     -- :align(display.CENTER, 20, -82)
     -- :addTo(self)

     -- display.newTTFLabel({text = "ส่งให้เพื่อน", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})--2,好友互赠
     -- :align(display.CENTER, -115, -122)
     -- :addTo(self)--将茉莉赠送给好友，10朵/次，好友可收到15朵
     -- display.newTTFLabel({text = "ส่งดอกมะลิให้เพื่อน 10ดอก/ครั้ง เพื่อนจะได้รับ 15 ดอก ", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})
     -- :align(display.CENTER, 20, -142)
     -- :addTo(self)

     display.newTTFLabel({text = "เชิญเพื่อน", color = cc.c3b(0xff, 0xff, 0x84), size = 18, align = ui.TEXT_ALIGN_CENTER})
     :pos(-125, 45)
     :addTo(self)
     --每成功邀请一位好友，直接获得20朵茉莉花

     display.newTTFLabel({text = "เชิญเพื่อนสำเร็จ 1 ท่าน รับดอกมะลิ 20 ดอกทันที", color = cc.c3b(0xff, 0xff, 0x84), size = 18, align = ui.TEXT_ALIGN_CENTER})
     :pos(18, 25)
     :addTo(self)

     cc.ui.UILabel.new({text = "แชร์", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})--2,分享活动
     :align(display.CENTER, -145, -12)
     :addTo(self)--参与游戏中任意分享，可获得10朵茉莉花，每日限1次
     cc.ui.UILabel.new({text = "แชร์กิจกรรม รับดอกมะลิ 10 ดอก จำกัด 1 ครั้ง/วัน", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})
     :align(display.CENTER, 40, -32)
     :addTo(self)

     display.newTTFLabel({text = "เล่นไพ่", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})--2,玩牌获得
     :align(display.CENTER, -135, -62)
     :addTo(self)--每玩5局即可获得3朵，每天最多600朵
     display.newTTFLabel({text = "เล่นไพ่ 5 รอบ รับดอกมะลิ 3 ดอก มากสุด 600 ดอก/วัน", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})
     :align(display.CENTER, 40, -82)
     :addTo(self)

     display.newTTFLabel({text = "ส่งให้เพื่อน", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})--2,好友互赠
     :align(display.CENTER, -120, -122)
     :addTo(self)--将茉莉赠送给好友，10朵/次，好友可收到15朵
     display.newTTFLabel({text = "ส่งดอกมะลิให้เพื่อน 10ดอก/ครั้ง เพื่อนจะได้รับ 15 ดอก ", size = 18, color =cc.c3b(0xff, 0xff, 0x84)})
     :align(display.CENTER, 45, -142)
     :addTo(self)


     --如何获取茉莉花
     display.newTTFLabel({text = "จะหาดอกมะลิได้จากที่ใด? ", size = 20, color =cc.c3b(0x00, 0xbe, 0xe6)})
     :align(display.CENTER, -50, 75)
     :addTo(self)

     self.myFlowerTxt = display.newTTFLabel({text = "ดอกมะลิของฉัน: 0  ดอก", size = 20, color =cc.c3b(0x1d, 0x91, 0xa3)})
     :align(display.CENTER, -300, 75)
     :addTo(self)

     display.newTTFLabel({text = "1 ดอก = $200", size = 20, color =display.COLOR_WHITE})
     :align(display.CENTER, -300, -20)
     :addTo(self)

     display.newTTFLabel({text = "แลกชิปครั้งแรกของวัน \n รับเพิ่ม +$10K", color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
     :pos(-300, -120)
     :addTo(self)

    -- self:loadData()
end

function MouthersDayActPopup:loadData()
     nk.http.getMyFlowerNum(
          function(data)
               self:setData_(data);
          end,
          function(errorData)
            if errorData then
               -- nk.TopTipManager:showTopTip("errorCode=="..errorData.errorCode or 0)
            end
          end
     )
end

function MouthersDayActPopup:sendFlowerClick()

    -- nk.ui.MothersDayTips.new():show({flower=10,getMoney=5000})

    -- do return end
      if self.flowerNum_<10 then
          nk.TopTipManager:showTopTip("ดอกมะลิของคุณไม่ถึง 10 ดอก ไม่สามารถแลกชิปได้ค่ะ")
          return;
      end
     
      nk.http.getMoneyByFlower(
          function(data)
               nk.ui.MothersDayTips.new():show(data,self.loadData)
               self:setData_({flower=0});
               nk.userData["aUser.money"] = checkint(data.money)

          end,
          function (errorData)
               if errorData and errorData.errorCode==-3 then
                     nk.TopTipManager:showTopTip("ดอกมะลิของคุณไม่ถึง 10 ดอก ไม่สามารถส่งได้ค่ะ")  
               else
                     nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
               end
          end
     )
end
function MouthersDayActPopup:inviteClick( )
     InvitePopup.new():show(1)
    
end
function MouthersDayActPopup:shareClick( )
  local feedData = clone(bm.LangUtil.getText("FEED", "FLOWER_INTRODUCE"))
  nk.Facebook:shareFeed(feedData, function(success, result)
       if not success then
          nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))     
       else
          nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS")) 
          self:feedShareReward()            
       end
  end)
end
function MouthersDayActPopup:playClick( )
     self.parentPanel_.callback_("playnow")
    self.parentPanel_:hide()
end

function MouthersDayActPopup:checkFriendClick( )
  FriendPopup.new():show()
end
function MouthersDayActPopup:setData_(data)
     self.flowerNum_ = checkint(data.flower);
     self.myFlowerTxt:setString("ดอกมะลิของฉัน: "..checkint(data.flower).." ดอก");
end

function MouthersDayActPopup:feedShareReward()
    nk.http.feedShareGetReward(

        function(data)
            if data and data.flower then
                self:loadData();
            end
        end,

        function(errorData)

        end


    )
end
return MouthersDayActPopup