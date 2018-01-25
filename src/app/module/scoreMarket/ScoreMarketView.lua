--
-- Author: ThinkerWang
-- Date: 2015-10-23 16:20:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- game score market
local StorePopup = import("app.module.newstore.StorePopup")

local ScoreAddressPopup = import(".ScoreAddressPopup")
local ScoreMarketControl = import(".ScoreMarketControl")
local ExchangeGoodView = import(".ExchangeGoodView")
local ExchangeHelpPopup = import(".ScoreMarketHelpPopup")

local ScoreMarketView = class("ScoreMarketView", function ()
    return display.newNode()
end)

local TOP_RECT_HEIGHT = 90
local LEFT_RECT_WIDTH = 195

local CENTER_CONTENT_BG_WIDHT = 704
local CENTER_CONTENT_BG_HEIGHT = 480

local ScoreMarketRecordItem = import(".ScoreMarketRecordItem")
local ScoreMarketGoodsItem = import(".ScoreMarketGoodsItem")

function ScoreMarketView:ctor(defaultMainTabIdx, defaultSubTabGroupId)
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:setNodeEventEnabled(true)

    self.defaultMainTabIdx_ = defaultMainTabIdx or 1
    self.defaultSubTabGroupId_ = defaultSubTabGroupId
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    self.control_ = ScoreMarketControl.new(self)
    self.isEntering = 1
	self:createNode_()

    -- 友盟统计
     local repArgs = {
        eventId = "ScoreMarketView_Create",
        label = "ScoreMarketView_Create",
    }
    self:reportUmeng_("event",repArgs)
end


function ScoreMarketView:createNode_()
	display.newScale9Sprite("#score_all_bg.png",0, 0, cc.size(display.width,display.height ))
	:addTo(self)
	:pos(display.cx,display.cy)

	display.newScale9Sprite("#score_left_rect.png",0, 0, cc.size(LEFT_RECT_WIDTH,display.height-TOP_RECT_HEIGHT+5 ))
	:addTo(self)
	:pos(display.cx-display.width *.5+LEFT_RECT_WIDTH *.5,display.cy-TOP_RECT_HEIGHT *.5)

	display.newScale9Sprite("#score_top_rect.png",0, 0, cc.size(display.width,TOP_RECT_HEIGHT ))
	:addTo(self)
	:pos(display.cx,display.cy + display.height *.5 - TOP_RECT_HEIGHT *.5)

	self.contentbg_ = display.newScale9Sprite("#score_content_bg.png",0, 0, cc.size(CENTER_CONTENT_BG_WIDHT,CENTER_CONTENT_BG_HEIGHT ))
	:addTo(self)
	:pos(display.cx+100,display.cy-70)

	-- display.newScale9Sprite("#score_my_score_bg.png",0, 0, cc.size(280,40))
	-- :addTo(self)
	-- :pos(display.cx - 115,display.cy+197)

   

    local helpBtn = cc.ui.UIPushButton.new({normal = "#score_question.png", pressed = "#score_question.png"},
        {scale9 = false})
        --:onButtonPressed(handler(self, self.onHelpBtnPreCallBack_))
        --:onButtonRelease(handler(self, self.onHelpBtnRelCallBack_))
        :onButtonClicked(buttontHandler(self, self.onCashExchangeHelpCallBack_))
        :pos(display.cx + 425, display.cy + 197)
        :addTo(self)
        :setButtonLabel("normal", display.newTTFLabel({text = T("什么是实物券  ") , color = cc.c3b(0xff, 0xff, 0xff), size = 22, align = ui.TEXT_ALIGN_LEFT}))
        :setButtonLabelAlignment(display.RIGHT_CENTER)
        :hide()
    -- self.helpQuesIcon_ = display.newSprite("#score_icQues_nor.png")
    --     :addTo(helpBtn)

    -- local myScoreTxt = display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "MYSCORE"), color = cc.c3b(0xff,0xa6,0x00), size = 24,align = ui.TEXT_ALIGN_LEFT})
    --      :pos(display.cx - 235,display.cy+197)
    --      :addTo(self)
    --      :align(display.LEFT_CENTER)
    -- local myScoreTxtSize = myScoreTxt:getContentSize()

    local pointStr = bm.formatNumberWithSplit(nk.userData["match.point"])
    -- self.point_ = display.newTTFLabel({text = ""..pointStr, color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_LEFT})
    --      :pos(display.cx - 235 + myScoreTxtSize.width+ 20,display.cy+197)
    --      :align(display.LEFT_CENTER)
    --      :addTo(self)

	self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#friend_restore_back_up.png", pressed="#friend_restore_back_down.png"})
            :pos(display.cx - display.width/2 + 50,display.cy + display.height/2 -45)
            :onButtonClicked(function() 
                    self:onClose()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 99)

    local leftRectHeight = display.height-TOP_RECT_HEIGHT+5 

  --    self.txtArr_ = {
  --    bm.LangUtil.getText("SCOREMARKET", "SUBTAB4"),
  --    bm.LangUtil.getText("SCOREMARKET", "SUBTAB2"),
  --    bm.LangUtil.getText("SCOREMARKET", "SUBTAB6"),
  --    bm.LangUtil.getText("SCOREMARKET", "SUBTAB7")
  --    }--实物
  --   for i=1,#self.txtArr_ do
  --   	display.newScale9Sprite("#score_left_btn_line.png",0, 0, cc.size(LEFT_RECT_WIDTH-8,4 ))
		-- :addTo(self)
		-- :pos(display.cx-display.width *.5+LEFT_RECT_WIDTH *.5 - 8,display.cy-TOP_RECT_HEIGHT *.5 + leftRectHeight*.5 - i*69)
  --   end
  --   self.btns_ = {}
   
  --   for i=1,#self.txtArr_ do
  --   	self.btns_[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"}, {scale9 = true})
  --       :setButtonSize(LEFT_RECT_WIDTH-8,69)
  --       :setButtonLabel("normal", display.newTTFLabel({text = self.txtArr_[i] , color = cc.c3b(0xff, 0xff, 0xff), size = 28, align = ui.TEXT_ALIGN_CENTER}))
  --       :addTo(self)
  --       :onButtonClicked(buttontHandler(self, self.onBtnClick_))
  --       :pos(display.cx-display.width *.5+LEFT_RECT_WIDTH *.5 - 8,display.cy-TOP_RECT_HEIGHT *.5 + leftRectHeight*.5 - i*69 + 69*.5)
  --   end 

    self.myInfoArr_ = {}
    local fileArr = {"score_new_chipIcon","score_new_cashIcon","score_new_exchangeIcon"}
    for i=1,3 do
        display.newScale9Sprite("#score_info_base.png",0, 0, cc.size(LEFT_RECT_WIDTH-15,44 ))
        :addTo(self)
        :pos(display.cx-display.width *.5+LEFT_RECT_WIDTH *.5 - 8,display.cy-TOP_RECT_HEIGHT *.5 + leftRectHeight*.5 - i*50)

        display.newSprite("#"..fileArr[i]..".png")
        :addTo(self)
        :pos(display.cx-display.width *.5+25,display.cy-TOP_RECT_HEIGHT *.5 + leftRectHeight*.5 - i*50)
        :scale(.8)

        local text = display.newTTFLabel({text = "", color = styles.FONT_COLOR.LIGHT_TEXT, size = 24, align = ui.TEXT_ALIGN_LEFT})
        :pos(display.cx-display.width *.5+48,display.cy-TOP_RECT_HEIGHT *.5 + leftRectHeight*.5 - i*50)
        :addTo(self)
        :align(display.LEFT_CENTER)

        table.insert(self.myInfoArr_,text)
    end

    local chip = ""
    if nk.userData["aUser.money"] < 100000 then
       chip =  bm.formatNumberWithSplit(nk.userData["aUser.money"])
    else
       chip =  bm.formatBigNumber(nk.userData["aUser.money"])
    end
    local ticket = nk.userData["match.ticket"]
    if ticket == nil then ticket = "0" end
    self.myInfoArr_[1]:setString(chip)
    self.myInfoArr_[2]:setString(pointStr)
    self.myInfoArr_[3]:setString(ticket)

    local exchangeCashBtn = cc.ui.UIPushButton.new({normal = "#socre_exchange_cash_icon.png", pressed = "#socre_exchange_cash_icon.png", disabled = "#socre_exchange_cash_icon.png"},
        {scale9 = false})
        :onButtonClicked(buttontHandler(self, self.onCashExchangeCallBack_))
        :pos(display.cx-display.width *.5+155,display.cy-TOP_RECT_HEIGHT *.5 + leftRectHeight*.5 - 2*50)
        :addTo(self)
        exchangeCashBtn:scale(.7)
     -- 一级tab bar
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = 716, 
            iconOffsetX = 30, 
            iconTexture = {
                {"#score_rechage_icon_selected.png", "#score_rechage_icon_unselect.png"}, 
                {"#score_record_icon_selected.png", "#score_record_icon_unselect.png"}
            }, 
            btnText = {bm.LangUtil.getText("SCOREMARKET", "TAB1"), bm.LangUtil.getText("SCOREMARKET", "TAB2")}, 
        })
        :setTabBarExtraParam({tabFrontColor = {cc.c3b(0xfb, 0x68, 0x3c), cc.c3b(0xca, 0xca, 0xca)},
            buttonLabelOffSet = {x = 20, y = 0}, noIconCircle = true})
        :pos(display.cx + 120,display.cy + display.height/2 - 40)--280
        :addTo(self, 10)


    self.addressText_ = display.newTTFLabel({text = bm.LangUtil.getText("SCOREMARKET", "RECEIVE_ADDRESS"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    self.addressBtn_ = cc.ui.UIPushButton.new({normal = "#score_newAddressBtn.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(165, 56)
    :addTo(self)
    :setButtonLabel("normal", self.addressText_)
    :onButtonClicked(handler(self, self.onShowAddressPopul_))
    :pos(display.cx - 300,display.cy + display.height/2 - 40)
    :hide()
    if nk.OnOff:check("matchShopCategoryLimitDisplay") == 1 then
        if checkint(nk.userData["match.point"])>=10 and nk.userData["aUser.mlevel"] >=4 then
            self.addressBtn_:show()
            helpBtn:show()
        end
    end


    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))

    if self.defaultMainTabIdx_ ~= 1 then
        --todo
        self.mainTabBar_:gotoTab(self.defaultMainTabIdx_)
    end
end
function ScoreMarketView:onMainTabChange_(selectedTab)
    if self.selectedTab_ == selectedTab then return end
    self.selectedTab_ = selectedTab
    self:cleanExchangeView()
    -- if self.exchangeGoodView_ then
    --     --todo
    --     self.exchangeGoodView_:removeFromParent()
    --     self.exchangeGoodView_ = nil
    -- end
    
    if self.isEntering == 1 then 
        return 
    end
    -- self:onShowed()

    -- self:createListUI()
    self:createListView_()
end
function ScoreMarketView:onBtnClick_(event)
	local btnId = table.keyof(self.btns_, event.target) + 0
    if btnId == self.selectBid then return end
    self.selectBid = btnId
	self:goTab(btnId)
end
function ScoreMarketView:onShowAddressPopul_(event)
    ScoreAddressPopup.new(self.control_):showPanel()
end

function ScoreMarketView:onCashExchangeCallBack_(evt)
    -- body
    StorePopup.new(2):showPanel()
end

-- function ScoreMarketView:onHelpBtnPreCallBack_(evt)
--     -- body
--     self.helpQuesIcon_:setSpriteFrame(display.newSpriteFrame("score_icQues_pre.png"))
-- end

-- function ScoreMarketView:onHelpBtnRelCallBack_(evt)
--     -- body
--     self.helpQuesIcon_:setSpriteFrame(display.newSpriteFrame("score_icQues_nor.png"))
-- end

function ScoreMarketView:onCashExchangeHelpCallBack_(evt)
    -- body
    ExchangeHelpPopup.new():showPanel()
end

function ScoreMarketView:goTab(bid)
	local posX,posY = self.btns_[bid]:getPosition()
	if not self.selectSprite then
		self.selectSprite = display.newNode()
		:addTo(self)
		display.newScale9Sprite("#score_btn_selected.png")
		:addTo(self.selectSprite)
		display.newScale9Sprite("#score_btn_selected_light.png")
		:addTo(self.selectSprite)
		self.selectTxt = display.newTTFLabel({text = self.txtArr_[bid]["name"] , color = cc.c3b(0xfb, 0x68, 0x3c), size = 32, align = ui.TEXT_ALIGN_CENTER})
		:pos(-10,0)
		:addTo(self.selectSprite)
	end
	self.selectSprite:pos(posX+11,posY)
    self.leftType_ = self.txtArr_[bid]["param"]
    dump(self.leftType_,"score:goTab")
    self.selectTxt:setString(self.txtArr_[bid]["name"])

     if self.isEntering == 1 then 
        return 
    end
   
    self:cleanExchangeView()
    self:createListView_()
    -- if self.selectedTab_ == 1 then
    --     if self.list_ == nil then
    --         -- self:onShowed()
    --         -- self:cleanExchangeView()
    --         self:createListView_()

    --     else
    --         self.control_:getGoods(self.leftType_,
    --         function(data)
    --             self.list_:setData(data)
    --         end
    --         )
    --     end        
    -- else
    --     self.control_:getMyRecord(self.leftType_,
    --     function(data)
    --         self.list_:setData(data)
    --     end
    --     )

    -- end
end




function ScoreMarketView:createTypeTab_(txtArr)
    local leftRectHeight = display.height-TOP_RECT_HEIGHT+5 

     -- self.txtArr_ = {
     -- bm.LangUtil.getText("SCOREMARKET", "SUBTAB4"),
     -- bm.LangUtil.getText("SCOREMARKET", "SUBTAB2"),
     -- bm.LangUtil.getText("SCOREMARKET", "SUBTAB6"),
     -- bm.LangUtil.getText("SCOREMARKET", "SUBTAB7")
     -- }--实物

    local BUTTOM_NUM = 185--新版下调
    self.txtArr_ = txtArr
    for i=0,#self.txtArr_ do
        display.newScale9Sprite("#score_left_btn_line.png",0, 0, cc.size(LEFT_RECT_WIDTH-8,4 ))
        :addTo(self)
        :pos(display.cx-display.width *.5+LEFT_RECT_WIDTH *.5 - 8,display.cy-TOP_RECT_HEIGHT *.5 + leftRectHeight*.5 - i*69- BUTTOM_NUM)
    end
    self.btns_ = {}
   
    for i=1,#self.txtArr_ do
        self.btns_[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(LEFT_RECT_WIDTH-8,69)
        :setButtonLabel("normal", display.newTTFLabel({text = self.txtArr_[i]["name"] , color = cc.c3b(0xff, 0xff, 0xff), size = 28, align = ui.TEXT_ALIGN_CENTER}))
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onBtnClick_))
        :pos(display.cx-display.width *.5+LEFT_RECT_WIDTH *.5 - 8,display.cy-TOP_RECT_HEIGHT *.5 + leftRectHeight*.5 - i*69 + 69*.5 - BUTTOM_NUM)
    end 
end

function ScoreMarketView:createListUI()
    if self.isInit_ then
        self:createListView_()
    else
        self.createListUIRequest_ = function()
            self:createListView_()  -- lua函数闭包原则
        end
    end
end

function ScoreMarketView:createListView_()
    local ItemClass = nil
    if self.selectedTab_ == 1 then
        ItemClass = ScoreMarketGoodsItem
    else
        ItemClass = ScoreMarketRecordItem
    end
    if self.list_ then
        self.list_:removeFromParent()
        self.list_ = nil
    end
    self.list_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-690* 0.5 , -456 * 0.5, 690, 456),
            direction = bm.ui.ListView.DIRECTION_VERTICAL
        }, 
            ItemClass
    )
    :pos(display.cx+100,display.cy-70)
    :addTo(self)
    self.list_:update()
    self.list_:update()
    
    self.list_.controller_ = self.control_
    self.list_.selectGood = handler(self,self.selectGood)

     if self.selectedTab_ == 1 then
        self.control_:getGoods(self.leftType_,
            function(data)
                self.list_:setData(data)
            end
        )
       
        
    else
        self.control_:getMyRecord(self.leftType_,
        function(data)
            self.list_:setData(data)
        end
        )
    end
end


function ScoreMarketView:show()
	nk.PopupManager:addPopup(self,nil,nil,true,false)
    self:setPosition(0,0)
    self:onShowed()
    return self
end
function ScoreMarketView:onShowed()
     -- 添加列表
    self:cleanExchangeView()
    self.isEntering = 0
    -- local ItemClass = nil
    -- if self.selectedTab_ == 1 then
    --     ItemClass = ScoreMarketGoodsItem
    -- else
    --     ItemClass = ScoreMarketRecordItem
    -- end
    -- if self.list_ then
    --     self.list_:removeFromParent()
    --     self.list_ = nil
    -- end
    -- self.list_ = bm.ui.ListView.new(
    --     {
    --         viewRect = cc.rect(-690* 0.5 , -456 * 0.5, 690, 456),
    --         direction = bm.ui.ListView.DIRECTION_VERTICAL
    --     }, 
    --         ItemClass
    -- )
    -- :pos(display.cx+100,display.cy-70)
    -- :addTo(self)
    -- self.list_:update()
    -- self.list_:update()
    
    -- self.list_.controller_ = self.control_
    -- self.list_.selectGood = handler(self,self.selectGood)

    --  if self.selectedTab_ == 1 then
    --     self.control_:getGoods(self.leftType_,
    --         function(data)
    --             self.list_:setData(data)
    --         end
    --     )
       
        
    -- else
    --     self.control_:getMyRecord(self.leftType_,
    --     function(data)
    --         self.list_:setData(data)
    --     end
    --     )
    -- end


    self.isShowed_ = true
    -- if self.createMainUIRequest_ then
    --     self.createMainUIRequest_()
    --     self.createMainUIRequest_ = nil
    -- end
    self.control_:getShopInitInfo(handler(self,self.onGetShopInitInfo))
end


function ScoreMarketView:onGetShopInitInfo(isSucc,data)
    dump(isSucc,"onGetShopInitInfo-isSucc")
    dump(data,"onGetShopInitInfo-data")

    if isSucc then
        self.isInit_ = true
        if data then 
            self:createTypeTab_(data)
            -- self:goTab(1)
            -- if self.createListUIRequest_ then
            --     self.createListUIRequest_()
            --     self.createListUIRequest_ = nil
            -- end
            local subTabIdx = nil
            local itemGroupParam = nil

            for i = 1, #data do
                itemGroupParam = data[i].param
                local itemGroups = string.split(itemGroupParam, ",")

                for j = 1, #itemGroups do
                    if itemGroups[j] == tostring(self.defaultSubTabGroupId_) then
                        --todo
                        subTabIdx = i
                    end
                end
            end


            if subTabIdx then
                --todo
                self:goTab(subTabIdx)
            else
                self:goTab(1)
            end
        end
    end
end

function ScoreMarketView:upDataGoods(leftType)

end

-- function ScoreMarketView:upDataRecordData(leftType)
--     local rData = {}
--     for k,v in pairs(self.recordData_) do
--         if leftType == checkint(v.category) then
--             table.insert(rData,v)
--         end
--     end
--     self.list_:setData(rData)
-- end
function ScoreMarketView:onClose()
	nk.PopupManager:removePopup(self)
	return self
end

function ScoreMarketView:onCleanup()
    if self.control_ then
        self.control_:dispose()
    end
    display.removeSpriteFramesWithFile("scoreMarket_th.plist", "scoreMarket_th.png")
end

function ScoreMarketView:refreshView()
   
     self.control_:getGoods(self.leftType_,
            function(data)
                self.list_:setData(data)
            end
            )

    


    local chip = ""
    if nk.userData["aUser.money"] < 100000 then
       chip =  bm.formatNumberWithSplit(nk.userData["aUser.money"])
    else
       chip =  bm.formatBigNumber(nk.userData["aUser.money"])
    end
    local ticket = nk.userData["match.ticket"]
    if ticket == nil then ticket = "0" end
    local pointStr = bm.formatNumberWithSplit(nk.userData["match.point"])

    self.myInfoArr_[1]:setString(chip)
    self.myInfoArr_[2]:setString(pointStr)
    self.myInfoArr_[3]:setString(ticket)
end

function ScoreMarketView:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(display.cx, display.cy)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function ScoreMarketView:selectGood(data)
    self:cleanExchangeView()
    self.exchangeGoodView_ = ExchangeGoodView.new(self.control_,data)
    :addTo(self)
    self.exchangeGoodView_:setCloseBack(handler(self,self.cleanExchangeView))
    self.contentbg_:hide()
    if self.list_ then
        self.list_:hide()
    end

    --商品点击次数统计
    if data and data.gid and data.category then
        local repArgs = {
            eventId = "ScoreMarketView_selectGood",
            attributes = "gid," .. data.gid or -1,
            counter = 1
        }
        self:reportUmeng_("eventCustom",repArgs)
    end
end
function ScoreMarketView:cleanExchangeView()
    if  self.exchangeGoodView_ then
        self.exchangeGoodView_:removeFromParent()
        self.exchangeGoodView_ = nil
    end
    self.contentbg_:show()
    if self.list_ then
        self.list_:show()
    end
end


function ScoreMarketView:reportUmeng_(command,args)
    if device.platform == "android" or device.platform == "ios" then  
        cc.analytics:doCommand{
                    command = command,
                    args = args
                }
    end 
end

return ScoreMarketView