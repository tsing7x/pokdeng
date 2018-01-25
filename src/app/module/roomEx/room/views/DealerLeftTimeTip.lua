local DealerLeftTimeTip = class("DealerLeftTimeTip", function() return display.newNode() end)
local GrabDealerBuyInPopup = import(".DealerBuyInPopup")
function DealerLeftTimeTip:ctor(callback)
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self.callback_ = callback
    self:createNode_()
    
end
function DealerLeftTimeTip:createNode_()
	
	display.newScale9Sprite("#grab_tip_line.png", 0, 0, cc.size(display.width, 90))
    :addTo(self)
    :pos(display.cx,display.cy+30)

    local LEFT_GAP = display.cx-180
    self.grabLeftTxt_ = display.newTTFLabel({text = T("上庄倒计时: "), color = cc.c3b(0xff, 0xff, 0xff), size = 30, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_CENTER)
    :pos(LEFT_GAP,display.cy+30)

    local leftTxtSize = self.grabLeftTxt_:getContentSize()
    local grableftTimeTxt_X = LEFT_GAP + leftTxtSize.width;
    self.grabLeftTime_ = display.newTTFLabel({text = "0"..T("秒"), color = cc.c3b(0xff, 0xff, 0xff), size = 45, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_CENTER)
    :pos(grableftTimeTxt_X,display.cy+30)

    local grabLeftTimeTxtSize = self.grabLeftTime_:getContentSize()
    self.buttonPictrue = display.newSprite("#grab_dealer_tips_btn.png")
    :addTo(self)
    :align(display.LEFT_CENTER)
    :pos(grableftTimeTxt_X+grabLeftTimeTxtSize.width+50,display.cy+30)
    
    local ButtonSize = cc.size(131,62)
     cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
       :align(display.LEFT_CENTER)
       :setButtonSize(ButtonSize.width-10,ButtonSize.height-7)
       :addTo(self)
       :pos(grableftTimeTxt_X+grabLeftTimeTxtSize.width+50+5,display.cy+30)
       :onButtonClicked(buttontHandler(self, self.onGrabDealer))

    
end

function DealerLeftTimeTip:showTime(lefttime,door,iscash)
    self.door_ = door or 30000
    self.leftTime_ =  lefttime
    self.iscash_ = iscash
    self:stopAction(self.action_)
    self.grabLeftTime_:setString(self.leftTime_..T("秒"))
    self.action_ = self:schedule(function ()
                    self.leftTime_ = self.leftTime_ - 1
                    if self.leftTime_< 0 then 
                        self:stopAction(self.action_)
                        if self.callback_ then
                            self.callback_()
                        end
                    end
                    self.grabLeftTime_:setString(""..self.leftTime_..T("秒"))
                end, 1)
end
function DealerLeftTimeTip:onGrabDealer()
    local myMoney = nk.userData["aUser.money"]
    if self.iscash_ == 1 then
        myMoney = nk.userData['match.point']
    end
    if myMoney - self.door_ < 0 then
        if self.iscash_ == 1 then
            nk.TopTipManager:showTopTip(T("现金币不足"))
        else
            nk.TopTipManager:showTopTip(T("金币不足"))
        end
        return
    end

    if self.iscash_ == 1 then
        nk.server:userGrabDealer(myMoney)
        return
    else
        nk.server:userGrabDealer(myMoney)
        return
    end
            GrabDealerBuyInPopup.new({
                    isCash  = self.iscash_,
                    minBuyIn = self.door_,
                    maxBuyIn = myMoney,
                    isAutoBuyin = false,
                    callback = function(buyinChips, isAutoBuyin1)
                        nk.server:userGrabDealer(buyinChips)
                    end
            }):showPanel()
end
function DealerLeftTimeTip:onCleanup()
	self:stopAction(self.action_)
end

return DealerLeftTimeTip