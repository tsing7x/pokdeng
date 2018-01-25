
-- 公共参数部分 --
local itemPosX = 5

local divLineWidth = 255
local divLineHeight = 2

local itemMagrinTopBottom = 10

local containerPosYFix = 0
local scrollViewPosYFix = 5
-- end --

local config = import(".Config")
-- local panel = nk.ui.Panel
local ViewItem = import("app.module.gameReview.ViewItem")
local GameReviewPopup = class("GameReviewPopup", function()
	-- body

	return display.newNode()
end)

function GameReviewPopup:ctor()
	-- body

	-- self:setContentSize(cc.size(config.PanelParam.WIDTH, config.PanelParam.HEIGHT))

	self:setNodeEventEnabled(true)
	self.background_ = display.newScale9Sprite("#panel_bg.png", display.cx + config.PanelParam.WIDTH / 2, 
		display.cy - config.PanelParam.HEIGHT / 2 - config.PanelParam.backgroundShownMagrinTop, 
		cc.size(config.PanelParam.WIDTH, config.PanelParam.HEIGHT))
	:addTo(self)

	self.background_:setTouchEnabled(true)
	self.background_:setTouchSwallowEnabled(true)

	self:setupViews()

end


function GameReviewPopup:onCleanup()
	if self.cardRecordWatcher_ then
		bm.DataProxy:removeDataObserver(nk.dataKeys.ROOM_CARD_RECORD, self.cardRecordWatcher_)
	end
end

function GameReviewPopup:setupViews()
	-- body

	local recordInfo = bm.DataProxy:getData(nk.dataKeys.ROOM_CARD_RECORD)

	-- recordInfo = nil

	-- dump(recordInfo, "recordInfo : =========================")
	if recordInfo then

		local itemNum = #recordInfo
	
		-- local fakeParamList = config.makeFakeItemParamList()
		self._scrollContent = display.newNode()

		self._container = display.newNode():addTo(self._scrollContent)
 		for i = 1, itemNum do
 			local listItem = ViewItem.new(recordInfo[i])

 			if i == 1 then
 				--todo
 				listItem:pos(itemPosX, 0)
 			else
 				listItem:pos(itemPosX, config.ListViewItemParam.HEIGHT * (i - 1) + itemMagrinTopBottom * 2 * (i - 1))
 				local divLineSp = display.newScale9Sprite("#pop_up_split_line.png", 0, 0, cc.size(divLineWidth, divLineHeight))
 				divLineSp:pos(config.ListViewItemParam.WIDTH / 2, config.ListViewItemParam.HEIGHT * (i - 1) + itemMagrinTopBottom * (2 * i - 3))
 				divLineSp:addTo(self._container)
 			end
 			listItem:addTo(self._container)
 	end

 	self._container:pos(- config.ListViewItemParam.WIDTH / 2, -(config.ListViewItemParam.HEIGHT * itemNum + itemMagrinTopBottom * 2 * (itemNum - 1)) / 2 + containerPosYFix)
	self._reviewList = bm.ui.ScrollView.new({viewRect = cc.rect(- config.ListViewParam.WIDTH / 2, - config.ListViewParam.HEIGHT / 2, config.ListViewParam.WIDTH, config.ListViewParam.HEIGHT),
		scrollContent = self._scrollContent, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
        :pos(config.ListViewParam.WIDTH / 2, config.ListViewParam.HEIGHT / 2  + scrollViewPosYFix)
        :addTo(self.background_)

    -- self._reviewList:retain()
    else
    	self._noGameReviewLabel = display.newTTFLabel({text = bm.LangUtil.getText("CGAMEREVIEW", "NO_GAME_DATA"), size = config.noGameReviewTTFLabelParam.FrontSize, color = config.noGameReviewTTFLabelParam.Color, align = ui.TEXT_ALIGN_CENTER})
    	:pos(config.PanelParam.WIDTH / 2, config.PanelParam.HEIGHT / 2)
    	:addTo(self.background_)

    	-- self._noGameReviewLabel:retain()
    end
end

function GameReviewPopup:show()
	-- body
	if not self.cardRecordWatcher_ then
		self.cardRecordWatcher_ = bm.DataProxy:addDataObserver(nk.dataKeys.ROOM_CARD_RECORD, handler(self, self.updateListView))
	end
	nk.PopupManager:addPopup(self, true, true, true, false)
	
	return self
end


function GameReviewPopup:updateListView(recordInfo)
	-- body

	
	if recordInfo and #recordInfo > 0 then
		if self._reviewList then
			--todo
			-- self._reviewList:retain()
			self._reviewList:removeFromParent()
			-- self._reviewList:autorelease()
			self._reviewList = nil
		end
		
		if self._noGameReviewLabel then
			--todo
			-- self._noGameReviewLabel:retain()
			self._noGameReviewLabel:removeFromParent()
			-- self._noGameReviewLabel:autorelease()
			self._noGameReviewLabel = nil
		end

		local itemNum = #recordInfo
	
		-- local fakeParamList = config.makeFakeItemParamList()
		self._scrollContent = display.newNode()

		self._container = display.newNode():addTo(self._scrollContent)
 		for i = 1, itemNum do
 			local listItem = ViewItem.new(recordInfo[i])

 			if i == 1 then
 				--todo
 				listItem:pos(itemPosX, 0)
 			else
 				listItem:pos(itemPosX, config.ListViewItemParam.HEIGHT * (i - 1) + itemMagrinTopBottom * 2 * (i - 1))
 				local divLineSp = display.newScale9Sprite("#pop_up_split_line.png", 0, 0, cc.size(divLineWidth, divLineHeight))
 				divLineSp:pos(config.ListViewItemParam.WIDTH / 2, config.ListViewItemParam.HEIGHT * (i - 1) + itemMagrinTopBottom * (2 * i - 3))
 				divLineSp:addTo(self._container)
 			end
 			listItem:addTo(self._container)
 	end

 	self._container:pos(- config.ListViewItemParam.WIDTH / 2, -(config.ListViewItemParam.HEIGHT * itemNum + itemMagrinTopBottom * 2 * (itemNum - 1)) / 2 + containerPosYFix)
	self._reviewList = bm.ui.ScrollView.new({viewRect = cc.rect(- config.ListViewParam.WIDTH / 2, - config.ListViewParam.HEIGHT / 2, config.ListViewParam.WIDTH, config.ListViewParam.HEIGHT),
		scrollContent = self._scrollContent, direction = bm.ui.ScrollView.DIRECTION_VERTICAL})
        :pos(config.ListViewParam.WIDTH / 2, config.ListViewParam.HEIGHT / 2  + scrollViewPosYFix)
        :addTo(self.background_)

    --self._reviewList:retain()
	else

		if self._reviewList then
			--todo
			-- self._reviewList:retain()
			self._reviewList:removeFromParent()
			--self._reviewList:autorelease()
			self._reviewList = nil
		end
		
		if self._noGameReviewLabel then
			--todo
			--self._noGameReviewLabel:autorelease()
		else
		self._noGameReviewLabel = display.newTTFLabel({text = bm.LangUtil.getText("CGAMEREVIEW", "NO_GAME_DATA"), size = config.noGameReviewTTFLabelParam.FrontSize, color = config.noGameReviewTTFLabelParam.Color, align = ui.TEXT_ALIGN_CENTER})
    		:pos(config.PanelParam.WIDTH / 2, config.PanelParam.HEIGHT / 2)
    		:addTo(self.background_)

    	-- self._noGameReviewLabel:retain()
		end
		
	end
end

function GameReviewPopup:hidePanel()
	-- body
	if self.cardRecordWatcher_ then
		bm.DataProxy:removeDataObserver(nk.dataKeys.ROOM_CARD_RECORD, self.cardRecordWatcher_)
	end
	
	-- nk.PopupManager:removePopup(self)
end

function GameReviewPopup:onShowPopup()
	-- body


	self:stopAllActions()

	-- self:pos(display.size.width / 2 + config.PanelParam.WIDTH, display.y - config.PanelParam.HEIGHT / 2 - config.PanelParam.backgroundShownMagrinTop)
	transition.moveTo(self, {time = config.animationTime, x = display.size.width / 2 - config.PanelParam.WIDTH - config.PanelParam.backgroundShownMagrinRight, easing = "OUT", onComplete = function()
		-- body
		if self.onShowed then
			--todo
			self:onShowed()
		end
	end})

	-- self._reviewList:setScrollContentTouchRect()
end

function GameReviewPopup:onShowed()
	-- body
	if self._reviewList then
		--todo
		self._reviewList:setScrollContentTouchRect()
	end
end

function GameReviewPopup:onRemovePopup(onRemoveCallBack)
	-- body
	self:stopAllActions()
    transition.moveTo(self, {time = config.animationTime, x = display.cx + config.PanelParam.WIDTH / 2, easing="OUT", onComplete=function() 
        onRemoveCallBack()
        self:hidePanel()
    end})
end

return GameReviewPopup