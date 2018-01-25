
local WIDTH = 676
local HEIGHT = 218+10

local ITEM_HEIGHT = 218
local ITEM_WIDTH = 208

local ICON_WIDTH = 100
local ICON_HEIGHT = 100

local TAG_LOAD_IMG = 111

local TAG_SCORE_GOODS_BG = 168
local TAG_SCORE_GOODS_BG_2 = 169
local TAG_ICON_CONTAINER = 109
local TAG_GOOD_NAME = 99
local TAG_LEFT_NUM = 119
local TAG_PRICE = 299
local TAG_PRICE_2 = 300
local TAG_SPECIAL_PRICE = 33
local TAG_CASH_ICON = 888
local TAG_CHIP_ICON = 889
local TAG_TICKET_ICON = 890
local TAG_ORIG_PRICE = 100
local TAG_DISCOUNT_PRICE = 101
local TAG_DELETE_LINE = 102
local TAG_LABEL_DISC = 103

local ScoreMarketGoodsItem = class("ScoreMarketGoodsItem", bm.ui.ListItem)


function ScoreMarketGoodsItem:ctor()
	self:setNodeEventEnabled(true)
	ScoreMarketGoodsItem.super.ctor(self, WIDTH, HEIGHT)

	self.itemArr_ = {}

	self.loaderIdArr_ = {}

    self.btnArr_ = {}
	for i=1,3 do
		self.itemArr_[i] = self:createSingleItem(i)
		self.itemArr_[i]:addTo(self)
	end

	self.itemArr_[2]
    :pos(WIDTH/2,HEIGHT/2)

    self.itemArr_[1]
    :pos(WIDTH/2 - ITEM_WIDTH - 15,HEIGHT/2)

    self.itemArr_[3]
    :pos(WIDTH/2 + ITEM_WIDTH + 15,HEIGHT/2)

   for i=1,3 do
       self.btnArr_[i] = self:createSingleBtn(i)
   end

     self.btnArr_[2]
     :pos(WIDTH/2,HEIGHT/2)

     self.btnArr_[1]
     :pos(WIDTH/2 - ITEM_WIDTH - 15,HEIGHT/2)

     self.btnArr_[3]
     :pos(WIDTH/2 + ITEM_WIDTH + 15,HEIGHT/2)

end
function ScoreMarketGoodsItem:createSingleBtn(index)
    local btn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png",pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(ITEM_WIDTH,ITEM_HEIGHT)
        :addTo(self)
        --:pos(WIDTH/2,HEIGHT/2)
       :onButtonClicked(buttontHandler(self, self.onBtnClick_))
        -- :onButtonPressed(function(evt) self.btnClickCanceled_ = false end ) 
        -- :onButtonRelease(function(evt) self.btnClickCanceled_ = true end )
        -- :onButtonClicked(function(evt) if not self.btnClickCanceled_ then end end)
       btn:setTouchSwallowEnabled(false);


    return btn
end
function ScoreMarketGoodsItem:createSingleItem(index)
	local tempNode = display.newNode()
	display.newScale9Sprite("#score_goods_bg.png",0, 0, cc.size(ITEM_WIDTH,ITEM_HEIGHT))
    :addTo(tempNode)
    :setTag(TAG_SCORE_GOODS_BG)

    display.newScale9Sprite("#score_goods_bg2.png",0, 0, cc.size(ITEM_WIDTH,ITEM_HEIGHT))
    :addTo(tempNode)
    :setTag(TAG_SCORE_GOODS_BG_2)
    
    display.newSprite("#score_item_light.png")
    :addTo(tempNode)
    :pos(0,15)
    display.newSprite("#common_transparent_skin.png")
    :addTo(tempNode)
    :pos(0,20)
    :setTag(TAG_ICON_CONTAINER)
    display.newTTFLabel({text = "name" , color = cc.c3b(0xff, 0xff, 0xff), size = 20,align = ui.TEXT_ALIGN_CENTER})
  	:addTo(tempNode)
  	:pos(0,ITEM_HEIGHT/2 - 20)
  	:setTag(TAG_GOOD_NAME)
  	display.newTTFLabel({text = "left number" , color = cc.c3b(0xff, 0xff, 0xff), size = 20,align = ui.TEXT_ALIGN_CENTER})
  	:addTo(tempNode)
  	:pos(0,-ITEM_HEIGHT/2 + 65)
    :setTag(TAG_LEFT_NUM)

  --楼下2个文本都是价格的，需求所迫，
  --实物奖励文本实在太长
  --要做分行操作，所以定宽定高
	display.newTTFLabel({text = "8888" , color = cc.c3b(0xff, 0xff, 0xff), size = 18,align = ui.TEXT_ALIGN_CENTER})
	:addTo(tempNode)
	:pos(0,-ITEM_HEIGHT/2 + 25)
 -- :align(display.LEFT_CENTER)
  :setTag(TAG_PRICE)

  display.newTTFLabel({text = "8888" , color = cc.c3b(0xff, 0xff, 0xff), size = 18,align = ui.TEXT_ALIGN_CENTER})
  :addTo(tempNode)
  --:align(display.LEFT_CENTER)
  :pos(0,-ITEM_HEIGHT/2 + 25)
  :setTag(TAG_PRICE_2)

    -- display.newTTFLabel({text = "8888" , color = cc.c3b(0xff, 0xff, 0xff), size = 18,dimensions = cc.size(203, 45),align = ui.TEXT_ALIGN_CENTER})
    -- :addTo(tempNode)
    -- :pos(0,-ITEM_HEIGHT/2 + 25)
    -- :setTag(TAG_SPECIAL_PRICE)

    local small_cash_icon = display.newSprite("#cash_icon.png")
    :addTo(tempNode)
    :pos(0,-ITEM_HEIGHT/2 + 25)
    --:align(display.RIGHT_CENTER)
    small_cash_icon:setTag(TAG_CASH_ICON)
    small_cash_icon:scale(.9)

    local small_chip_icon_ = display.newSprite("#score_small_chip_icon.png")
    :addTo(tempNode)
    :pos(0,-ITEM_HEIGHT/2 + 25)
    --:align(display.RIGHT_CENTER)
    small_chip_icon_:setTag(TAG_CHIP_ICON)
    small_chip_icon_:scale(.8)

    display.newSprite("#score_small_ticket_icon.png")
    :addTo(tempNode)
   -- :align(display.RIGHT_CENTER)
    :pos(0,-ITEM_HEIGHT/2 + 25)
    :setTag(TAG_TICKET_ICON)

	display.newScale9Sprite("#common_transparent_skin.png",0,0,cc.size(WIDTH,24))
    :addTo(tempNode)
    :pos(ITEM_WIDTH,ITEM_HEIGHT)


  display.newTTFLabel({text = "" , color = cc.c3b(0xff, 0xff, 0xff), size = 18,align = ui.TEXT_ALIGN_CENTER})
  :addTo(tempNode)
  :pos(0,-ITEM_HEIGHT/2 + 25)
    :setTag(TAG_ORIG_PRICE)


  display.newTTFLabel({text = "" , color = cc.c3b(0xff, 0xff, 0xff), size = 18,align = ui.TEXT_ALIGN_CENTER})
  :addTo(tempNode)
  :pos(0,-ITEM_HEIGHT/2 + 25)
    :setTag(TAG_DISCOUNT_PRICE)

  display.newRect(1, 2, {fill=true, fillColor=cc.c4f(0xF9 / 0xff, 0xBA / 0xff, 0x22 / 0xff, 1)})
  :pos(25,-ITEM_HEIGHT/2 + 25)
  :addTo(tempNode)
  :hide()
  :setTag(TAG_DELETE_LINE)

  local iconDisc = display.newSprite("#score_label_discount.png")
  :addTo(tempNode)
  :hide()
  

  local size = iconDisc:getContentSize()
  iconDisc:pos(-ITEM_WIDTH/2 + size.width/2,ITEM_HEIGHT/2-size.height/2)
  :setTag(TAG_LABEL_DISC)

    
   
    ---local btn = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png",pressed = "#rounded_rect_10.png"}, {scale9 = true})
     ---   :setButtonSize(ITEM_WIDTH,ITEM_HEIGHT)
        --:setButtonLabel("normal", display.newTTFLabel({text = "实物" , color = cc.c3b(0xff, 0xff, 0xff), size = 28, align = ui.TEXT_ALIGN_CENTER}))
     ---   :addTo(tempNode)
     --   :onButtonClicked(buttontHandler(self, self.onBtnClick_))
        --:onButtonPressed(function(evt) self.btnClickCanceled_ = false end ) 
        --:onButtonRelease(function(evt) self.btnClickCanceled_ = true end )
        --:onButtonClicked(function(evt) if not self.btnClickCanceled_ then end end)
      --  :setTouchSwallowEnabled(false);

    --table.insert(self.btnArr_,btn)

    --dump(self.btnArr_,"ssssssss")
       
    return tempNode
end
function ScoreMarketGoodsItem:onBtnClick_(event)

    
	 local btnId = table.keyof(self.btnArr_, event.target) + 0

     --nk.TopTipManager:showTopTip(''..btnId)
     local clickItemData = self.data_[btnId]
     --self.owner_.controller_:buyGood(clickItemData)


     if tonumber(clickItemData.num )== 0 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "NOLEFT"))
            return
        end

     if clickItemData.exchangeMethod == "point" then
        if tonumber(nk.userData["match.point"])< tonumber(clickItemData.price ) then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "NOTENOUGHTIPS"))
            return
        end
     end

    self.owner_.selectGood(clickItemData)

      -- nk.ui.Dialog.new({
      --               messageText = "确认兑换"..clickItemData.giftname.."?", 
      --               secondBtnText = "确定", 
      --               callback = function (type)
      --                   if type == nk.ui.Dialog.SECOND_BTN_CLICK then
      --                       self.owner_.controller_:buyGood(clickItemData)
      --                   end
      --               end
      --           })
      --               :show()
end
function ScoreMarketGoodsItem:setData(data)
    self.data_ = data
    for i=1,3 do
       self:upDateGoodItem(self.btnArr_[i], self.itemArr_[i],data[i])
    end
    
end

--以下老版本刷新ITEM作废，重写。
-- function ScoreMarketGoodsItem:upDateItem(btn,itemNode,data)
--     if data == nil then
--         btn:setVisible(false)
--         itemNode:setVisible(false)
--         return
--     end
--     itemNode:setVisible(true)
--     btn:setVisible(true)
-- 	local goodsName = itemNode:getChildByTag(TAG_GOOD_NAME)
-- 	goodsName:setString(data.giftname)

-- 	local iconContainer  = itemNode:getChildByTag(TAG_ICON_CONTAINER)
-- 	local loadId_ = nk.ImageLoader:nextLoaderId()
--     table.insert(self.loaderIdArr_,loadId_)

--     local oldAvatar = iconContainer:getChildByTag(TAG_LOAD_IMG)
--     if oldAvatar then
--         oldAvatar:removeFromParent()
--     end

--     local price = itemNode:getChildByTag(TAG_PRICE)
--     local specialPrice = itemNode:getChildByTag(TAG_SPECIAL_PRICE)
--     local icon = itemNode:getChildByTag(TAG_CASH_ICON)
--     local chip_icon = itemNode:getChildByTag(TAG_CHIP_ICON)
--     chip_icon:hide()
--     icon:show()


--     local orgiPrice = itemNode:getChildByTag(TAG_ORIG_PRICE)
--     local discPrice = itemNode:getChildByTag(TAG_DISCOUNT_PRICE)
--     local deleLine = itemNode:getChildByTag(TAG_DELETE_LINE)
--     local iconDisc = itemNode:getChildByTag(TAG_LABEL_DISC)

--     local backNormal = itemNode:getChildByTag(TAG_SCORE_GOODS_BG)
--     local backSpecial = itemNode:getChildByTag(TAG_SCORE_GOODS_BG_2)
--     if data.category == 3 then
--       -- price:setString(data.price)
--       backNormal:setVisible(false)
--       backSpecial:setVisible(true)
--       icon:setVisible(false)
--       price:setVisible(false)
--       specialPrice:setVisible(true)
--       specialPrice:setString(data.giftname.."\n".. bm.LangUtil.getText("SCOREMARKET","EXCHANGE_TICKET",data.price))



--       --打折显示
--       specialPrice:setVisible(false)
--       orgiPrice:show()
--       orgiPrice:setString(bm.LangUtil.getText("SCOREMARKET","EXCHANGE_TICKET",(data.originalPrice or 0)))
--       orgiPrice:pos(0,-ITEM_HEIGHT/2 + 25)
--       deleLine:hide()
--       discPrice:hide()
--       iconDisc:hide()

--        if data.discount then
--         dump(data.discount,"data.discount")
--         if 1 ~= data.discount then
--             local offPrice = math.ceil(data.originalPrice * data.discount)
--             discPrice:setString(bm.LangUtil.getText("SCOREMARKET","EXCHANGE_TICKET",offPrice))
--             orgiPrice:pos(15,-ITEM_HEIGHT/2 + 35)
--             discPrice:pos(15,-ITEM_HEIGHT/2 + 15)
--             deleLine:show()
--             discPrice:show()
--             iconDisc:show()
--             deleLine:pos(15,-ITEM_HEIGHT/2 + 35)
--             deleLine:setScaleX(orgiPrice:getContentSize().width)
--         end
--       end

--     else
--         backNormal:setVisible(true)
--         backSpecial:setVisible(false)
--         icon:setVisible(true)
--         price:setVisible(true)
--         specialPrice:setVisible(false)
--         price:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGENUM",data.price))
--         local priceSize = price:getContentSize()
--         icon:pos(-priceSize.width/2,-ITEM_HEIGHT/2 + 25)
--         price:pos(15,-ITEM_HEIGHT/2 + 25)
--         chip_icon:pos(-priceSize.width/2,-ITEM_HEIGHT/2 + 25)


--         --打折显示
--         price:setVisible(false)
--         orgiPrice:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGENUM",(data.originalPrice or 0)))
--         local orgiPriceSize = orgiPrice:getContentSize()
--         icon:pos(-orgiPriceSize.width/2,-ITEM_HEIGHT/2 + 25)
--         orgiPrice:pos(15,-ITEM_HEIGHT/2 + 25)
--         --originalPrice,discount
--         deleLine:hide()
--         discPrice:hide()
--         iconDisc:hide()

--         if data.exchangeMethod == "chip" then
--           icon:hide()
--           chip_icon:show()
--           price:setVisible(true)
--           specialPrice:setVisible(false)
--           --bm.formatNumberWithSplit(data.price)
--           local money ;
--           if tonumber(data.price)< 100000 then
--             money  = bm.formatNumberWithSplit(data.price)
--           else
--             money = bm.formatBigNumber(tonumber(data.price))
--             -- money  = bm.formatNumberWithSplit(data.price)
--           end
--           price:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGE_CHIP",money))
--           --discPrice:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGE_CHIP",data.price))
--           orgiPrice:hide()
--           local priceSize = price:getContentSize()
--           icon:pos(-priceSize.width/2,-ITEM_HEIGHT/2 + 25)
--           price:pos(15,-ITEM_HEIGHT/2 + 25)
--           chip_icon:pos(-priceSize.width/2,-ITEM_HEIGHT/2 + 25)
--         end


--         if data.discount then
--           dump(data.discount,"data.discount")
--           if 1 ~= data.discount then
--               local offPrice = data.originalPrice * data.discount
--               discPrice:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGENUM",offPrice))
--               orgiPrice:pos(15,-ITEM_HEIGHT/2 + 35)
--               discPrice:pos(15,-ITEM_HEIGHT/2 + 15)
--               deleLine:show()
--               iconDisc:show()
--               discPrice:show()
--               deleLine:pos(15,-ITEM_HEIGHT/2 + 35)
--               deleLine:setScaleX(orgiPrice:getContentSize().width)
--           end
--         end
--     end
    

--     local leftNum = itemNode:getChildByTag(TAG_LEFT_NUM)
--     leftNum:setString(bm.LangUtil.getText("SCOREMARKET","EXCHANGE_LEFT_CNT",data.num))
--     if tonumber(data.num) >99 then
--         leftNum:setString(bm.LangUtil.getText("SCOREMARKET","GOODSFULL"))
--     end
--     if tonumber(data.num) ==0 then
--         leftNum:setString(bm.LangUtil.getText("SCOREMARKET","NOLEFT"))
--     end
    

--     if string.len(data.imgurl) > 5 then
--         -- if self.loadImageHandle_ then
--         --     scheduler.unscheduleGlobal(self.loadImageHandle_)
--         --     self.loadImageHandle_ = nil
--         -- end
--         --self.loadImageHandle_ = scheduler.performWithDelayGlobal(function()
--                -- self.loadImageHandle_ = nil
--                 nk.ImageLoader:loadAndCacheImage(
--                     loadId_, 
--                     data.imgurl, 
--                     function(success,sprite)
--                     	if success then
--                     		local tex = sprite:getTexture()
-- 				            local texSize = tex:getContentSize()
-- 					        -- iconContainer:setTexture(tex)
-- 					        -- iconContainer:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
-- 					        -- iconContainer:setScaleX(ICON_WIDTH / texSize.width)
-- 					        -- iconContainer:setScaleY(ICON_HEIGHT / texSize.height)
-- 					        --self.avatarLoaded_ = true

--                             local xxScale = ICON_WIDTH/texSize.width
--                             local yyScale = ICON_HEIGHT/texSize.height
--                             sprite:scale(xxScale<yyScale and xxScale or yyScale)
--                             :addTo(iconContainer,0,TAG_LOAD_IMG)
--                     	end
--                     end)
--         --    end, 0.1 * self.index_)
--     end
-- end

-- function ScoreMarketGoodsItem:onAvatarLoadComplete_(success, sprite)
-- 	if success then
--         local tex = sprite:getTexture()
--         local texSize = tex:getContentSize()
--         self.avatar_:setTexture(tex)
--         self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
--         self.avatar_:setScaleX(57 / texSize.width)
--         self.avatar_:setScaleY(57 / texSize.height)
--         self.avatarLoaded_ = true
--     end
-- end
function ScoreMarketGoodsItem:upDateGoodItem(btn,itemNode,data)
    if data == nil then
        btn:setVisible(false)
        itemNode:setVisible(false)
        return
    end
    itemNode:setVisible(true)
    btn:setVisible(true)
    local goodsName = itemNode:getChildByTag(TAG_GOOD_NAME)
    goodsName:setString(data.giftname)

    local iconContainer  = itemNode:getChildByTag(TAG_ICON_CONTAINER)
    local loadId_ = nk.ImageLoader:nextLoaderId()
    table.insert(self.loaderIdArr_,loadId_)

    local oldAvatar = iconContainer:getChildByTag(TAG_LOAD_IMG)
    if oldAvatar then
        oldAvatar:removeFromParent()
    end

    local price = itemNode:getChildByTag(TAG_PRICE)
    local other_price = itemNode:getChildByTag(TAG_PRICE_2)
    --local specialPrice = itemNode:getChildByTag(TAG_SPECIAL_PRICE)
    local cash_icon = itemNode:getChildByTag(TAG_CASH_ICON)
    local chip_icon = itemNode:getChildByTag(TAG_CHIP_ICON)
    local ticket_icon = itemNode:getChildByTag(TAG_TICKET_ICON)
   

    local orgiPrice = itemNode:getChildByTag(TAG_ORIG_PRICE):hide()
    local discPrice = itemNode:getChildByTag(TAG_DISCOUNT_PRICE):hide()
    local deleLine = itemNode:getChildByTag(TAG_DELETE_LINE):hide()
    local iconDisc = itemNode:getChildByTag(TAG_LABEL_DISC):hide()

    local backNormal = itemNode:getChildByTag(TAG_SCORE_GOODS_BG)
    local backSpecial = itemNode:getChildByTag(TAG_SCORE_GOODS_BG_2):hide()

    local leftNum = itemNode:getChildByTag(TAG_LEFT_NUM)
    leftNum:setString(bm.LangUtil.getText("SCOREMARKET","EXCHANGE_LEFT_CNT",data.num))
    if tonumber(data.num) >99 then
        leftNum:setString(bm.LangUtil.getText("SCOREMARKET","GOODSFULL"))
    end
    if tonumber(data.num) ==0 then
        leftNum:setString(bm.LangUtil.getText("SCOREMARKET","NOLEFT"))
    end
    --加载商品图片
    if string.len(data.imgurl) > 5 then
                nk.ImageLoader:loadAndCacheImage(
                    loadId_, 
                    data.imgurl, 
                    function(success,sprite)
                      if success then
                        local tex = sprite:getTexture()
                        local texSize = tex:getContentSize()
        

                            local xxScale = ICON_WIDTH/texSize.width
                            local yyScale = ICON_HEIGHT/texSize.height
                            sprite:scale(xxScale<yyScale and xxScale or yyScale)
                            :addTo(iconContainer,0,TAG_LOAD_IMG)
                      end
                  end)
    end

    chip_icon:hide()
    cash_icon:hide()
    ticket_icon:hide()
    price:hide()
    other_price:hide()
    
    local priceData = data.price
    --如果商品价格是一个数字，代表单种货币兑换
    --如果是一个Json，是2种货币结合兑换
    if checkint(priceData)>0 then
        --金币兑换
        if data.exchangeMethod == "chip" then

            chip_icon:show()
            price:show()
            price:pos(15,-ITEM_HEIGHT/2 + 25)

            local money;
            if tonumber(priceData)< 100000 then
              money  = bm.formatNumberWithSplit(data.price)
            else
              money = bm.formatBigNumber(tonumber(data.price))
            end
            price:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGE_CHIP",money))
            local priceSize = price:getContentSize()
            chip_icon:pos(-priceSize.width/2,-ITEM_HEIGHT/2 + 25)

        --现金币兑换
        elseif data.exchangeMethod == "point" then

            cash_icon:show()
            price:show()
            price:pos(15,-ITEM_HEIGHT/2 + 25)

            local cash;
            if tonumber(priceData) < 100000 then
              cash  = bm.formatNumberWithSplit(data.price)
            else
              cash = bm.formatBigNumber(tonumber(data.price))
            end
            price:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGENUM",cash))
            local priceSize = price:getContentSize()
            cash_icon:pos(-priceSize.width/2,-ITEM_HEIGHT/2 + 25)

        end
    else

      priceData = json.decode(priceData)
        --现金币＋筹码　
        if checkint(priceData.money) > 0  and checkint(priceData.point)>0 then
          chip_icon:show()
          cash_icon:show()
          price:show()
          other_price:show()
          price:pos(15,-ITEM_HEIGHT/2 + 35)
          other_price:pos(15,-ITEM_HEIGHT/2 + 15)
         

          local cash;
          if tonumber(priceData.point)< 100000 then
            cash  = bm.formatNumberWithSplit(priceData.point)
          else
            cash = bm.formatBigNumber(tonumber(priceData.point))
          end
          price:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGENUM",cash))
          local priceSize = price:getContentSize()
          cash_icon:pos(-priceSize.width/2,-ITEM_HEIGHT/2 + 35)

          local money;
          if tonumber(priceData.money)< 100000 then
            money  = bm.formatNumberWithSplit(priceData.money)
          else
            money = bm.formatBigNumber(tonumber(priceData.money))
          end
          other_price:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGE_CHIP",money))
          local priceSize = other_price:getContentSize()
          chip_icon:pos(-priceSize.width/2,-ITEM_HEIGHT/2 + 15)

          --自适应上下对齐
          local cashPos_x,cashPos_y = cash_icon:getPosition()
          local chipPos_x,chipPos_y = chip_icon:getPosition()
          local gap = cashPos_x - chipPos_x

          if gap  > 0 then
              cash_icon:pos(cashPos_x - gap, cashPos_y)
              price:pos(15 - gap,-ITEM_HEIGHT/2 + 35)
          else
              chip_icon:pos(chipPos_x + gap, chipPos_y)
              other_price:pos(15 + gap,-ITEM_HEIGHT/2 + 15)
          end


        --现金币+兑换券
        elseif checkint(priceData.point) > 0 and checkint(priceData.ticket)> 0 then
          ticket_icon:show()
          cash_icon:show()
          price:show()
          other_price:show()
          price:pos(15,-ITEM_HEIGHT/2 + 35)
          other_price:pos(15,-ITEM_HEIGHT/2 + 15)
         
          local cash;
          if tonumber(priceData.point)< 100000 then
            cash  = bm.formatNumberWithSplit(priceData.point)
          else
            cash = bm.formatBigNumber(tonumber(priceData.point))
          end
          price:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGENUM",cash))
          local priceSize = price:getContentSize()
          
          --price:pos( 15 - (ITEM_WIDTH - priceSize.width)/2 , -ITEM_HEIGHT/2 + 35)
          cash_icon:pos(-priceSize.width/2,-ITEM_HEIGHT/2 + 35)


          local ticket;
          if tonumber(priceData.ticket)< 100000 then
            ticket  = bm.formatNumberWithSplit(priceData.ticket)
          else
            ticket = bm.formatBigNumber(priceData.ticket)
          end
          other_price:setString(bm.LangUtil.getText("SCOREMARKET","RECHANGE_TICKET",ticket))
          local priceSize = other_price:getContentSize()

         -- other_price:pos( 15 - (ITEM_WIDTH - priceSize.width)/2 , -ITEM_HEIGHT/2 + 15)
          ticket_icon:pos(-priceSize.width/2,-ITEM_HEIGHT/2 + 15)

          --自适应上下对齐
          local cashPos_x,cashPos_y = cash_icon:getPosition()
          local ticketPos_x,ticketPos_y = ticket_icon:getPosition()
          local gap = cashPos_x - ticketPos_x

          if gap  > 0 then
              --cash_icon:pos(cashPos_x - gap, cashPos_y)
              --price:pos(15 - gap,-ITEM_HEIGHT/2 + 35)
              cash_icon:setPositionX(cashPos_x - gap)
              price:setPositionX(15 - gap)
          else
              --ticket_icon:pos(ticketPos_x + gap, ticketPos_y)
              --other_price:pos(15 + gap,-ITEM_HEIGHT/2 + 15)
              ticket_icon:setPositionX(ticketPos_x + gap)
              other_price:setPositionX(15 + gap)
          end
        end
    end

end
function ScoreMarketGoodsItem:onCleanup(  )
    -- body
    for i=1,#self.loaderIdArr_ do
        nk.ImageLoader:cancelJobByLoaderId(self.loaderIdArr_[i])
    end
end
return ScoreMarketGoodsItem