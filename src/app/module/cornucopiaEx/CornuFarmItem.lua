--自己的农场
---
local CornuFarmItem = class("CornuFarmItem", 
function()
	return display.newNode() 
end)
local CornuSelectSeedPoup = import(".CornuSelectSeedPoup")
local CornuGetSeedPopup = import(".CornuGetSeedPopup")
local WIDTH = 124
local HEIGHT = 78

local STATE_1 = 1   --等级未解锁
local STATE_2 = 2   --金币未解锁
local STATE_3 = 3   --可种植
local STATE_4 = 4   --可加速
local STATE_5 = 5   --可收获
function CornuFarmItem:ctor(parent)
  self:setNodeEventEnabled(true)
  self.parent_ = parent
	display.newSprite("#cor_plant.png")
   	:addTo(self)

   	--金花
   	self.goldFlower_ = display.newSprite("#cor_gold_flower.png")
   	:addTo(self)
   	:pos(5,10)
   	:hide()
   	--银花
   	self.sliverFlower_ = display.newSprite("#cor_sliver_flower.png")
   	:addTo(self)
   	:pos(5,10)
   	:hide()
   	--小树苗
   	self.tree_ = display.newSprite("#cor_tree.png")
   	:addTo(self)
   	:pos(5,15)
   	:hide()

   	self.timeBg_ = display.newSprite("#cor_time_bg.png")
   	:addTo(self)
   	--:pos(3,-HEIGHT/2 - 5)
    :pos(-WIDTH/2+10,0)
    :hide()

    


   	self.time_ = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 18, align = ui.TEXT_ALIGN_CENTER})
    :align(display.TOP_LEFT)
    :addTo(self.timeBg_)
    :pos(0,19)

    self.paopao_ = display.newSprite("#cor_paopao.png")
    :addTo(self)
    :pos(0,54)
    :hide()

    self.hand_ = display.newSprite("#cor_hand.png")
    :addTo(self.paopao_)
   	:pos(47/2,30)
    :hide()

    self.chanzi_ = display.newSprite("#cor_chanzi.png")
    :addTo(self.paopao_)
    :pos(23,30)
    :hide()

    self.speedTip_ = display.newSprite("#cor_litter_quick.png")
    :addTo(self.paopao_)
    :pos(25,30)
    :hide()

    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
    :setButtonSize(47, 47)
    :pos(23,30)
    :onButtonClicked(buttontHandler(self, self.click_))
    :addTo(self.paopao_)

    self.black_lock_ = display.newSprite("#cor_lock_cannot_lock.png")
    :addTo(self)
    :hide()

    self.green_lock_ = display.newSprite("#cor_lock_can_lock.png")
    :addTo(self)
    :hide()


    self.click_btn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
    :setButtonSize(WIDTH, HEIGHT)
    :onButtonClicked(buttontHandler(self, self.click_))
    :addTo(self)
end

function CornuFarmItem:click_()
    if self.state_ == STATE_3 then --种植
        CornuSelectSeedPoup.new(self.seedData_,
          function(seedId)
              self:plantSeed(seedId)
          end
        ):show()
    elseif self.state_ == STATE_4 then--加速
        self:addSpeed()
    elseif self.state_ == STATE_2 then  --解锁
        nk.ui.Dialog.new({
        messageText = bm.LangUtil.getText("DORNUCOPIA", "OPEN_LOCK_TIPS",self.data_.needMoney), 
        hasFirstButton = true,
        hasCloseButton = true,
        callback = function (type)
            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self:openLock()
            end
        end,
    }):show()
        
    elseif self.state_ == STATE_5 then --收获
        self:reapMySeed()
    end
end
--种植
function CornuFarmItem:plantSeed(sid)

    self.plantRequestId_ = nk.http.plantSeed(nk.userData["aUser.mid"],sid,self.pid_,
      function(data)
          self.parent_:upDataFarm()
      end,
      function(errdata)
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
      end
    )
end
--加速
function CornuFarmItem:addSpeed()
    self.addSpeedRequestId_ = nk.http.addSpeedForTree(nk.userData["aUser.mid"],self.pid_,
        function(data)
          self.parent_:upDataFarm()--加速成功
        end,

        function(errdata)
          if errdata and errdata.errorCode then
            if checkint(errdata.errorCode)==-2 then--加速水不足
              nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "NOT_SPEED_WATER"))
            else
              nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
            end
          else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
          end
        end
    )
end
--解锁
function CornuFarmItem:openLock()
  self.openLockRequestId_ = nk.http.openLock(nk.userData["aUser.mid"], self.pid_, function(data)
    nk.userData["aUser.money"] = checkint(data.money)
    self.parent_:upDataFarm() 
  end, function(errdata)
    -- dump(errdata, "nk.http.openLock.errData :=================")

    if errdata and errdata.errorCode then
      if checkint(errdata.errorCode) == - 6 then--前面的没有解锁
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "OPEN_LOCK_FIAL"))
      elseif checkint(errdata.errorCode) == - 4 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("ROOM", "SEND_CHIP_NOT_ENOUGH_CHIPS"))
      else
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
      end
    else
      nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
    end
  end
  )
end
--收获
function CornuFarmItem:reapMySeed()
  self.reapMySeedRequestId_ = nk.http.reapMySeed(nk.userData["aUser.mid"],self.pid_,
        function(data)
          nk.userData["aUser.money"] = checkint(data.money);
          self.parent_:upDataFarm()
          nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "GETED_COR_MONEY",data.getMoney))
           if checkint(data.getJs) == 1 then
            local updateFun =  function()
              if self and self.parent_ then
                self.parent_:upDataFarm()
              end
            end
            CornuGetSeedPopup.new(updateFun):show(3)
           end
        end,

        function(errdata)
          nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
        end
  )
end
function CornuFarmItem:paopaoMove()

  self.moveUp = function()

      self.moveToId_ = transition.moveTo(self.paopao_, {y = 64, time = .5,onComplete = 
        function()
            self:stopAction(self.moveToId_)
            self.paopao_:pos(0,64)
            self.moveDown()
        end
      })

  end

  self.moveDown = function()

      self.moveToId_ = transition.moveTo(self.paopao_, {y = 54, time = .5,onComplete = 
        function()
              self:stopAction(self.moveToId_)
              self.paopao_:pos(0,54)
              self.moveUp()
        end
      })

  end

  self.moveUp()

end
function CornuFarmItem:setMyData(data)
  self:setDefState()
  self.data_ = data
    if data.lockStatus == 0 then --未解锁状态
        if data.black then--等级尚未开启
            self.black_lock_:show()
            self.state_= STATE_1
        elseif data.needMoney then
            self.green_lock_:show()
            self.state_= STATE_2
        else
            self.black_lock_:show()
            self.state_= STATE_1
        end
    else

      self:paopaoMove()

       if data.canPlant==1 then--可种植状态
          self.state_= STATE_3
          self.paopao_:show()
          self.chanzi_:show()
       else--已种植状态
          if checkint(data.needTime)>0 then --成长状态
              self.state_= STATE_4
              self.tree_:show()
              self.paopao_:show()
              self.time_:show()
              self.timeBg_:show()
              self.speedTip_:show()
              local str_time = os.date("%M:%S", self.data_.needTime);
              self.time_:setString(str_time)
              self.action_ = self:schedule(function ()
                  if checkint(self.data_.needTime) == 0 then
                    self:stopAction(self.action_)
                    self.parent_:upDataFarm()
                    return
                  end
                  self.data_.needTime = checkint(self.data_.needTime)-1;
                  local str = os.date("%M:%S", self.data_.needTime);
                  self.time_:setString(str)
                end,1
              )
          else             --成熟状态
              self.state_= STATE_5
              if checkint(data.type) == 401 then
                  self.sliverFlower_:show()
              elseif checkint(data.type) == 402 then
                  self.goldFlower_:show()
              end
              self.paopao_:show()
              self.hand_:show()
          end
       end
    end
end
function CornuFarmItem:setDefState()
    self.goldFlower_:hide()
    self.sliverFlower_:hide()
    self.tree_:hide()
    self.black_lock_:hide()
    self.green_lock_:hide()
    self.timeBg_:hide()
    self.time_:hide()
    self.paopao_:hide()
    self.hand_:hide()
    self.chanzi_:hide()
    self.speedTip_:hide()
    self:stopAction(self.action_)
    self:stopAction(self.moveToId_)
    self.paopao_:pos(0,54)
end
function CornuFarmItem:setSeedData(data)
  self.seedData_ = data
end
function CornuFarmItem:setPid(id)
  self.pid_ = id
end
function CornuFarmItem:onCleanup()
     nk.http.cancel(self.plantRequestId_)
     nk.http.cancel(self.addSpeedRequestId_)
     nk.http.cancel(self.openLockRequestId_)
     nk.http.cancel(self.reapMySeedRequestId_)
     self:stopAction(self.action_)
end




return CornuFarmItem