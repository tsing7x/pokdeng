

local CardRecordItem = class("CardRecordItem", bm.ui.ListItem)

local ITEM_WIDTH = 258
local ITEM_HEIGHT = 118

local HandPoker = import("app.module.room.model.HandPoker")

function CardRecordItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self:setNodeEventEnabled(true)
	CardRecordItem.super.ctor(self,ITEM_WIDTH, ITEM_HEIGHT)

	self.bg_ = display.newSprite("#gameRecordItemBg.png")
	:addTo(self)
    :pos(ITEM_WIDTH/2,ITEM_HEIGHT/2+20)

     

    
end





function CardRecordItem:onDataSet(dataChanged, data)

    self.data_ = data

     
    if self:getIndex()%2 == 0 then
        self.bg_:hide()
    else
        self.bg_:show()
    end

    self:deleteCards()

    local result = self.data_[3]   
    if not result then result = 0 end

    local isDealer = self.data_[4]

    local selfHandPoker =HandPoker.new()
    selfHandPoker:setCards(self.data_[1])
    local point = selfHandPoker:getTypeLabel()

    

    local dealerHandPoker =HandPoker.new()
    dealerHandPoker:setCards(self.data_[2])
    local point = dealerHandPoker:getTypeLabel()

    local pokerCard = nk.ui.PokerCard
    local selfCards = self.data_[1]
    self.pokerCardList = {}
    self.cardIndex_ = 0
    for i = 1,#selfCards do

        self.pokerCardList[i] = pokerCard.new()
                        :setCard(selfCards[i])
                        :showFront()
        self.pokerCardList[i]:scale(.6)
        self.pokerCardList[i]:addTo(self)
        :pos(20+i*15,ITEM_HEIGHT/2+10)
        self.cardIndex_ = i
    end

    --博定设置
    if selfHandPoker:isPokdeng() then
        local point = selfHandPoker:getPoint()
        self.selfPokdengIcon = display.newSprite("#pokdeng"..point..".png"):addTo(self)
        :pos(50+self.cardIndex_*15,ITEM_HEIGHT/2+30)
        self.selfPokdengIcon:scale(.7)
    end

    --倍数设置
    local X = selfHandPoker:getX() 
    if X>1 then
        self.Xbg = display.newSprite("#X_bg.png"):addTo(self)
        self.Xbg:scale(.7)
        :pos(60+self.cardIndex_*15,ITEM_HEIGHT/2+40)
        self.xIcon = display.newSprite("#X"..X..".png"):addTo(self)
        self.xIcon:scale(.7)
        :pos(60+self.cardIndex_*15,ITEM_HEIGHT/2+40)
    end

  


    self.dealerPokerList = {}
    local dealerCards = self.data_[2]
     self.cardIndex_ = 0
    for i = 1,#dealerCards do

        self.dealerPokerList[i] = pokerCard.new()
                        :setCard(dealerCards[i])
                        :showFront()
        self.dealerPokerList[i]:scale(.6)
        self.dealerPokerList[i]:addTo(self)
        :pos(ITEM_WIDTH/2+20+i*15,ITEM_HEIGHT/2+10)
         self.cardIndex_ = i
    end

    --博定设置
    if dealerHandPoker:isPokdeng() then
        local point = dealerHandPoker:getPoint()
        self.dealerPokdengIcon = display.newSprite("#pokdeng"..point..".png"):addTo(self)
        :pos(ITEM_WIDTH/2+50+self.cardIndex_*15,ITEM_HEIGHT/2+30)
        self.dealerPokdengIcon:scale(.7)
    end
    
    --倍数设置
    local X = dealerHandPoker:getX() 
    if X>1 then
        self.d_Xbg = display.newSprite("#X_bg.png"):addTo(self)
        self.d_Xbg:scale(.7)
        :pos(ITEM_WIDTH/2+60+self.cardIndex_*15,ITEM_HEIGHT/2+40)
        self.d_xIcon = display.newSprite("#X"..X..".png"):addTo(self)
        self.d_xIcon:scale(.7)
        :pos(ITEM_WIDTH/2+60+self.cardIndex_*15,ITEM_HEIGHT/2+40)
    end


    
    if isDealer then 
            if result>0 then
                self.icon_bg_ = display.newSprite("#gameRecord_win_bg.png")
                :addTo(self)
                :pos(25,ITEM_HEIGHT/2-5)

                self.icon_ = display.newSprite("#gameRecord_win_icon.png")
                :addTo(self)
                :pos(25,ITEM_HEIGHT/2-5)

                self.d_icon_bg = display.newSprite("#gameRecord_win_bg.png")
                :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)
                :addTo(self)
                self.d_icon = display.newSprite("#gameRecord_win_icon.png")
                :addTo(self)
                :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)
            elseif result==0 then
                 self.icon_bg_ = display.newSprite("#gameRecord_dogfall_bg.png")
                :addTo(self)
                :pos(25,ITEM_HEIGHT/2-5)

                self.icon_ = display.newSprite("#gameRecord_dogfall_icon.png")
                :addTo(self)
                :pos(25,ITEM_HEIGHT/2-5)

                self.d_icon_bg = display.newSprite("#gameRecord_dogfall_bg.png")
                :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)
                :addTo(self)
                self.d_icon = display.newSprite("#gameRecord_dogfall_icon.png")
                :addTo(self)
                :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)

            else
                self.icon_bg_ = display.newSprite("#gameRecord_lose_bg.png")
                :addTo(self)
                :pos(25,ITEM_HEIGHT/2-5)

                self.icon_ = display.newSprite("#gameRecord_lose_icon.png")
                :addTo(self)
                :pos(25,ITEM_HEIGHT/2-5)


                self.d_icon_bg = display.newSprite("#gameRecord_lose_bg.png")
                :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)
                :addTo(self)
                self.d_icon = display.newSprite("#gameRecord_lose_icon.png")
                :addTo(self)
                :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)

            end



        return 
    end


    --以下为输赢设置。。。
    if result>0 then
        self.icon_bg_ = display.newSprite("#gameRecord_win_bg.png")
        :addTo(self)
        :pos(25,ITEM_HEIGHT/2-5)

        self.icon_ = display.newSprite("#gameRecord_win_icon.png")
        :addTo(self)
        :pos(25,ITEM_HEIGHT/2-5)

        self.d_icon_bg = display.newSprite("#gameRecord_lose_bg.png")
        :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)
        :addTo(self)
        self.d_icon = display.newSprite("#gameRecord_lose_icon.png")
        :addTo(self)
        :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)

    elseif result==0 then
        self.icon_bg_ = display.newSprite("#gameRecord_dogfall_bg.png")
        :addTo(self)
        :pos(25,ITEM_HEIGHT/2-5)

        self.icon_ = display.newSprite("#gameRecord_dogfall_icon.png")
        :addTo(self)
        :pos(25,ITEM_HEIGHT/2-5)

        self.d_icon_bg = display.newSprite("#gameRecord_dogfall_bg.png")
        :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)
        :addTo(self)
        self.d_icon = display.newSprite("#gameRecord_dogfall_icon.png")
        :addTo(self)
        :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)
    else
        self.icon_bg_ = display.newSprite("#gameRecord_lose_bg.png")
        :addTo(self)
        :pos(25,ITEM_HEIGHT/2-5)

        self.icon_ = display.newSprite("#gameRecord_lose_icon.png")
        :addTo(self)
        :pos(25,ITEM_HEIGHT/2-5)


        self.d_icon_bg = display.newSprite("#gameRecord_win_bg.png")
        :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)
        :addTo(self)
        self.d_icon = display.newSprite("#gameRecord_win_icon.png")
        :addTo(self)
        :pos(ITEM_WIDTH/2+25,ITEM_HEIGHT/2-5)
    end

end


function CardRecordItem:deleteCards()


    if self.dealerPokerList then
        for i = 1,#self.dealerPokerList do
            self.dealerPokerList[i]:removeFromParent()
        end
    end
    if self.pokerCardList then
        for i = 1,#self.pokerCardList do
            self.pokerCardList[i]:removeFromParent()
        end
    end

    if self.icon_bg_ then
        self.icon_bg_:removeFromParent()
        self.icon_:removeFromParent()
        self.d_icon:removeFromParent()
        self.d_icon_bg:removeFromParent()

        self.icon_bg_ = nil
    end

    if self.dealerPokdengIcon then
        self.dealerPokdengIcon:removeFromParent()
        self.dealerPokdengIcon = nil
    end

    if self.selfPokdengIcon then
        self.selfPokdengIcon:removeFromParent()
        self.selfPokdengIcon = nil
    end

    if self.xIcon then
        self.Xbg:removeFromParent()
        self.xIcon:removeFromParent()
        self.Xbg = nil
        self.xIcon = nil
    end
    if self.d_xIcon then
        self.d_xIcon:removeFromParent()
        self.d_Xbg:removeFromParent()
        self.d_xIcon = nil
        self.d_Xbg = nil
    end
end


function CardRecordItem:onCleanup()
    self:deleteCards()
end
return CardRecordItem