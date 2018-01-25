--
-- Author: tony
-- Date: 2014-08-28 15:14:46
--
local GameCardRecordPopup = class("GameCardRecordPopup", function() return display.newNode() end)
local CardRecordItem = import(".CardRecordItem")
GameCardRecordPopup.WIDTH = 260
GameCardRecordPopup.HEIGHT = 640



-- end --


function GameCardRecordPopup:ctor()

	 -- self:setTouchEnabled(true)
  --   self:setTouchSwallowEnabled(true)
    display.addSpriteFrames("gameCardRecord.plist", "gameCardRecord.png")

    -- self:pos(-GameCardRecordPopup.WIDTH/2,GameCardRecordPopup.HEIGHT/2)

   	self.bg_ = display.newSprite("#gameRecordBg.png")
   	:addTo(self)

    self.bg_:setTouchEnabled(true)
    self.bg_:setTouchSwallowEnabled(true)

   	display.newSprite("#cardRecordTitle.png")
   	:addTo(self)
   	:pos(0,GameCardRecordPopup.HEIGHT/2-52/2)

   	--bm.LangUtil.getText("CGAMEREVIEW", "NO_GAME_DATA")
   	display.newTTFLabel({text = T("你"), size = 26, color = cc.c3b(0x96,0xa4,0xcb), align = ui.TEXT_ALIGN_CENTER})
   	:addTo(self)
   	:pos(-260/4,GameCardRecordPopup.HEIGHT/2-52/2)
   	display.newTTFLabel({text = T("庄家"), size = 26, color = cc.c3b(0x96,0xa4,0xcb), align = ui.TEXT_ALIGN_CENTER})
   	:addTo(self)
   	:pos(260/4,GameCardRecordPopup.HEIGHT/2-52/2)

    self.row_ = display.newSprite("#gameRecord_row.png")
    :addTo(self)
    :pos(0,-GameCardRecordPopup.HEIGHT/2+10)
    :hide()


   	--self:pos(GameCardRecordPopup.WIDTH/2+display.width,GameCardRecordPopup.HEIGHT/2)

    
end


function GameCardRecordPopup:setupViews()
    
end

function GameCardRecordPopup:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)

   
end

function GameCardRecordPopup:hidePanel()
    nk.PopupManager:removePopup(self)
end

function GameCardRecordPopup:onRemovePopup(removeFunc)
    self:stopAllActions()
   

    --向右侧移动消失
  --   transition.moveTo(self, {time=0.3, x=GameCardRecordPopup.WIDTH/2+display.width, easing="OUT", onComplete=function() 
  --       removeFunc()

  --       display.removeSpriteFramesWithFile("gameCardRecord.plist", "gameCardRecord.png")
        
  --       if self.cardRecordWatcher_ then
		-- 	bm.DataProxy:removeDataObserver(nk.dataKeys.NEW_CARD_RECORD, self.cardRecordWatcher_)
		-- end
  --   end})

   transition.moveTo(self, {time=0.3, x=-GameCardRecordPopup.WIDTH/2, easing="OUT", onComplete=function() 
        removeFunc()

        display.removeSpriteFramesWithFile("gameCardRecord.plist", "gameCardRecord.png")
        
        if self.cardRecordWatcher_ then
          bm.DataProxy:removeDataObserver(nk.dataKeys.NEW_CARD_RECORD, self.cardRecordWatcher_)
        end

        -- if self.touch_node_ then
        --   self.touch_node_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))
        -- end

    end})
end

function GameCardRecordPopup:onShowPopup()
    self:stopAllActions()
    
    --从右侧出来
    -- transition.moveTo(self, {time=0.3, x=display.width-GameCardRecordPopup.WIDTH/2, easing="OUT", onComplete=function()
    --     if self.onShow then
    --         self:onShow()
    --     end
    -- end})
    --从左侧出来
    self:pos(0-GameCardRecordPopup.WIDTH/2, display.cy)
    transition.moveTo(self, {time=0.3, x=GameCardRecordPopup.WIDTH/2, easing="OUT", onComplete=function()
        if self.onShow then
             self:onShow()
        end
        -- if self.touch_node_ then
        --   self.touch_node_:show()
        -- end
         --self:onShowed()
     end})
end


function GameCardRecordPopup:onShowed()
    if self.recordList_ then
        self.recordList_:update()
    end
   -- local size = self:getCascadeBoundingBox().size;
    --print("the size is ===="..size.width);
end

function GameCardRecordPopup:onShow()

	if not self.cardRecordWatcher_ then
    local recordInfo = bm.DataProxy:getData(nk.dataKeys.NEW_CARD_RECORD)
    self:updateListView(recordInfo)
		self.cardRecordWatcher_ = bm.DataProxy:addDataObserver(nk.dataKeys.NEW_CARD_RECORD, handler(self, self.updateListView))
	end
	
end

function GameCardRecordPopup:updateListView(data)

	if not self.recordList_ then
        local LIST_WIDTH = 260
        local LIST_HEIGHT = 640-52
        self.recordList_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_WIDTH * 0.5, -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT)
                --direction = 1
            }, 
            CardRecordItem
            
        )
        :addTo(self)
        :pos(0,-26)
        --  
      -- self.touch_node_ = display.newScale9Sprite("#common_transparent_skin.png",0,0,cc.size(130,display.height))
      -- :addTo(self)
      -- :pos(GameCardRecordPopup.WIDTH-130/2,0)
      -- self.touch_node_:setTouchEnabled(true)
      -- self.touch_node_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch_))

  end

  self.recordList_:setData(data)
  
  if data and #data>5 then
    self.row_:show()
  else

    self.row_:hide()
  end
  if self.recordList_ then
     self.recordList_:setScrollContentTouchRect()
     self.recordList_:update()
	end


        
end

-- function GameCardRecordPopup:onTouch_()
 
--      nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
--      nk.PopupManager:removePopup(self)
-- end
return GameCardRecordPopup