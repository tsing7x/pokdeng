

local WinCardAnim = class("WinCardAnim", function ()
    return display.newNode()
end)


WinCardAnim.s_nodeW = 330

WinCardAnim.s_nodeH = 110




function WinCardAnim:ctor()
    -- 打开node event
    self:setNodeEventEnabled(true)
end


function WinCardAnim:show(datas)


    if not self.bg_ then
        self.bg_ = display.newScale9Sprite("#panel_bg.png",0,0,cc.size(WinCardAnim.s_nodeW,WinCardAnim.s_nodeH))
        :align(display.CENTER)
        :addTo(self)
    end

    if not self.cardNode1_ then
        self.cardNode1_ = display.newNode()
            :pos(-130,-12)
            :addTo(self)
    end


    if not self.playerLabel_ then
        self.playerLabel_ = display.newTTFLabel({text = (data1.name or ""), color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_LEFT})
        :pos(0,50)
        :addTo(self.cardNode1_)
    else
        self.playerLabel_:setString(nk.Native:getFixedWidthText("", 26, data1.name, 98))
    end


    if not self.icon1 then
        self.icon1 = display.newSprite("#flag_win-gr.png")
        :pos(100,50)
        :addTo(self.cardNode1_)
    end


    local PokerCard = nk.ui.PokerCard
    local cardData1 = data1.cards
    if not self.pokerCards1_ then
        self.pokerCards1_=  {}
         for i = 1, #cardData1 do
            self.pokerCards1_[i] = PokerCard.new()
                :setCard(cardData1[i])
                :showFront()
                :scale(0.6)
                :pos((i - 1) * 50, 0)
                :addTo(self.cardNode1_)
        end

    else
         for i = 1, #cardData1 do
            self.pokerCards1_[i]:setCard(cardData1[i])
        end
    end
   


    if not self.cardNode2_ then
        self.cardNode2_ = display.newNode()
            :pos(28,-12)
            :addTo(self)
    end

     if not self.dealerLabel_ then
        self.dealerLabel_ = display.newTTFLabel({text = (data2.name or ""), color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_LEFT})
        :pos(0,50)
        :addTo(self.cardNode2_)
    else
        self.dealerLabel_:setString(nk.Native:getFixedWidthText("", 26, data2.name, 98))
    end


    local PokerCard = nk.ui.PokerCard
    local cardData2 = data2.cards
    if not self.pokerCards2_ then
        self.pokerCards2_ = {}
         for i = 1, #cardData2 do
            self.pokerCards2_[i] = PokerCard.new()
                :setCard(cardData2[i])
                :showFront()
                :scale(0.6)
                :pos((i - 1) * 50, 0)
                :addTo(self.cardNode2_)
        end


    else
        for i = 1, #cardData1 do
            self.pokerCards2_[i]:setCard(cardData2[i])
        end


    end

    if not self.icon2 then
        self.icon2 = display.newSprite("#flag_lose-gr.png")
        :pos(100,50)
        :addTo(self.cardNode2_)
    end
   

    





end





function WinCardAnim:hide()
    self:pos(display.cx - WinCardAnim.s_nodeW/2,display.height- (WinCardAnim.s_nodeH/2)-18)
    transition.moveTo(self, {time = 2, x = display.width + (WinCardAnim.s_nodeW/2)})
end

function WinCardAnim:onEnter()
    -- 添加至舞台开始
    self:pos(display.width + WinCardAnim.s_nodeW/2,display.height - (WinCardAnim.s_nodeH/2)-18)
    transition.moveTo(self, {time = 2, x = display.width -(WinCardAnim.s_nodeW/2)})
end

function WinCardAnim:onExit()
    -- 从舞台移除停止动画
end

function WinCardAnim:dispose()

end

return WinCardAnim