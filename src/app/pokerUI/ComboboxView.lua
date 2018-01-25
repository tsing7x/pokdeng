--
-- Author: XT
-- Date: 2015-09-21 20:11:59
-- http://blog.csdn.net/a102111/article/details/43236947
-- local ScoreComboItem = import("app.module.scoremarket.ScoreComboItem")
local ComboboxView = class("ComboboxView", function()
	return display.newNode()
end)

function ComboboxView:ctor(params, popListCallBack, itemClkCallBack)
	self.lblSize_ = params.lblSize or 22
	self.borderSize_ = params.borderSize or cc.size(160, 42)
	self.lblcolor_ = params.lblcolor or cc.c3b(0,0,0)
	self.barRes_ = params.barRes or "#sm_combo_bar.png"
	self.borderRes_ = params.borderRes or "#sm_combo_border.png"
	self.itemCls_ = params.itemCls
	self.listWidth_ = params.listWidth
	self.listHeight_ = params.listHeight
	self.listOffX_ = params.listOffX or 0
	self.listOffY_ = params.listOffY or 0
	self.isNotScaleBar_ = params.barNoScale or false

	self.lblAnchPt_ = params.lblAnchPot or display.CENTER
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	-- 新增关键事件回调！
	self.popListCallBack_ = popListCallBack 
	self.itemClkCallBack_ = itemClkCallBack

	self.borderBg_ = display.newScale9Sprite(self.borderRes_, 0, 0, self.borderSize_)
		:addTo(self, 1)
	--
	self.icon_ = nil
	local px = nil

	if self.isNotScaleBar_ then
	 	--todo
	 	local iconMagrinRight = params.barMagrin or 0
	 	self.icon_ = display.newSprite(self.barRes_)
	 	
	 	px = self.borderSize_.width / 2 - self.icon_:getContentSize().width / 2 - iconMagrinRight
	 	self.icon_:pos(px, 0)
	 		:addTo(self, 2)
	else
		px = self.borderSize_.width*0.5 - 42*0.5
		self.icon_ = display.newScale9Sprite(self.barRes_, px, 0, cc.size(42,42), cc.rect(7,7,30,30)):addTo(self, 2)
	end 
	--
	self.lbl_ = display.newTTFLabel({
		text = "name",
		color = self.lblcolor_,
		size = self.lblSize_,
		align = ui.TEXT_ALIGN_LEFT,
		dimensions=cc.size(self.borderSize_.width-self.borderSize_.height, 0)
	})

	self.lbl_:setAnchorPoint(display.ANCHOR_POINTS[self.lblAnchPt_])

	if self.lblAnchPt_ == display.CENTER_LEFT then
		--todo
		self.lbl_:pos(- self.borderSize_.width / 2 + 20, 0)
	else
		self.lbl_:pos(0, 0)
	end

	self.lbl_:addTo(self, 3)
	-- common_input_bg.png common_transparent_skin.png
	self.btn_ = cc.ui.UIPushButton.new({normal="#common_transparent_skin.png", pressed="#common_transparent_skin.png"}, {scale9=true})
		:setButtonSize(self.borderSize_.width, self.borderSize_.height)
		:pos(0, 0)
		:onButtonPressed(function(evt)
			self.icon_:pos(px+1, -1)
		end)
		:onButtonRelease(function(evt)
			self.icon_:pos(px, 0)
			if evt.touchInTarget then
				nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
				self:onBtnClicked_()
			end
		end)
		:onButtonClicked(function(evt)
			
		end)
		:addTo(self, 5)
	self:addDropList_()
end


function ComboboxView:addDropList_()
	if not self.list_ then
        self.list_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-self.listWidth_ * 0.5, -self.listHeight_ * 0.5, self.listWidth_, self.listHeight_),
                direction=bm.ui.ListView.DIRECTION_VERTICAL,
            }, 
            self.itemCls_
        )
        :pos(self.listOffX_, -self.listHeight_*0.5+self.listOffY_)
        :addTo(self, 99)

        self.list_:hide()
	    self:onShowed()

	    self.list_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
	end
end

function ComboboxView:onBtnPressed_()
	local getFrame = display.newSpriteFrame;
	-- local frame = getFrame("common_red_btn_down.png");
	if frame then
    	-- self.icon_:setSpriteFrame(frame)
    	-- self.icon_:setSpriteFrame(frame)
	end
	-- self.icon_:setSpriteFrame(display.newSpriteFrame("common_red_btn_down.png"))
end

function ComboboxView:onBtnRelease_()
    local getFrame = display.newSpriteFrame;
	-- local frame = getFrame("common_red_btn_up.png");
	if frame then
    	-- self.icon_:setSpriteFrame(frame) 
    	-- setSpriteFrame 支持九宫格模式
    	-- setSpriteFrame 支持普通newSprite()模式
	end
	-- self.icon_:setSpriteFrame(display.newSpriteFrame("common_red_btn_up.png"))
end

function ComboboxView:onBtnClicked_()
	if self.popListCallBack_ then
		--todo
		self.popListCallBack_()
	end
	
	if self.isNewData_ then
		self.list_:setData(self.data_,true)
		self.isNewData_ = nil
	end

	if self.list_:isVisible() then
		self:hideList()
	else
		bm.EventCenter:dispatchEvent(nk.eventNames.DISENABLED_EDITBOX_TOUCH)
		self.list_:show()

		self:addModule()
	end
end

function ComboboxView:hideList()
	if self.list_ then
		self.list_:hide()
		if self.modal_ then
	        self.modal_:removeFromParent()
	        self.modal_ = nil
	    end

	    bm.EventCenter:dispatchEvent(nk.eventNames.ENABLED_EDITBOX_TOUCH)
	end
end

function ComboboxView:setData(value,defaultStr)
	local data = {}
    for i = 1,#value do
        data[i] = {}
        data[i].id = i
        data[i].selected = false
        data[i].title = value[i]
    end
	self.data_ = data
	self.isNewData_ = true
	self.lbl_:setString(defaultStr or "")

	return self
end

function ComboboxView:setText(value)
	self.lbl_:setString(value or "")
end

function ComboboxView:getText()
	return self.lbl_:getString();
end

function ComboboxView:onShowed()
	if self.list_ then
		self.list_:setScrollContentTouchRect()
        self.list_:update()
    end
end

function ComboboxView:onItemEvent_(evt)
    if evt.type == "DROPDOWN_LIST_SELECT" then
        if self.itemClkCallBack_ then
            self.itemClkCallBack_(evt.data)
        end
        self.lbl_:setString(evt.data.title or "")
    end
    self:hideList()
end

function ComboboxView:addModule()
    if not self.modal_ then
        self.modal_ = display.newScale9Sprite("#modal_texture.png", 0, 0, cc.size(display.width*1.5, display.height*1.5))
            :pos(0, 0)
            :addTo(self, - 9)
        self.modal_:setTouchEnabled(true)
        self.modal_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.hideList))
    end    
end

return ComboboxView;