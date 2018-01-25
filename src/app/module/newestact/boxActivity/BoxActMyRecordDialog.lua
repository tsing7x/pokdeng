local Panel = import("app.pokerUI.Panel")
local BoxActRecordItem = import(".BoxActRecordItem")
local BoxActMyRecordDialog = class("BoxActMyRecordDialog", Panel)

local WIDTH = 585
local HEIGHT = 360

local LIST_WIDTH = 570
local LIST_HEIGHT =38*7 --7*40--274
function BoxActMyRecordDialog:ctor()
	self.background_ = display.newScale9Sprite("#actBox_tipBg1.png", 0, 0, cc.size(WIDTH,HEIGHT))
	:addTo(self)
	self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

  display.newScale9Sprite("#actBox_title_bg.png", 0, 0, cc.size(WIDTH-10,HEIGHT-10))
  :addTo(self)

    display.newTTFLabel({text = bm.LangUtil.getText("BOXACT","TEN_REWARD"), color = cc.c3b(0x6c, 0x28, 0x03), size = 26, align = ui.TEXT_ALIGN_CENTER})
	:addTo(self)
	:pos(0,150)

    display.newScale9Sprite("#actBox_redBox.png", 0, 0, cc.size(LIST_WIDTH-30,LIST_HEIGHT))
    :addTo(self)
    :pos(0,0)

	display.newTTFLabel({text = bm.LangUtil.getText("BOXACT","TAB_TEXT")[1], color = cc.c3b(0xFF, 0xFF, 0xFF), size = 22, align = ui.TEXT_ALIGN_CENTER})
	:addTo(self)
	:pos(-WIDTH/4,120)
	display.newTTFLabel({text = bm.LangUtil.getText("BOXACT","TAB_TEXT")[2], color = cc.c3b(0xFF, 0xFF, 0xFF), size = 22, align = ui.TEXT_ALIGN_CENTER})
	:addTo(self)
	:pos(WIDTH/4,120)



	-- 添加列表
    self.list_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-LIST_WIDTH* 0.5 , -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
            direction = bm.ui.ListView.DIRECTION_VERTICAL
        }, 
            BoxActRecordItem
    )
    :pos(0, -35)
    :addTo(self)


   --  self.lv = cc.ui.UIListView.new {
   --  	viewRect = cc.rect(-LIST_WIDTH* 0.5 , -LIST_HEIGHT * 0.5, LIST_WIDTH, LIST_HEIGHT),
   --  	direction = bm.ui.ListView.DIRECTION_VERTICAL
   --  }
   --  for i=1,20 do
   --  	local item = self.lv:newItem()
   --  	local content = BoxActRecordItem.new()
   --  	item:addContent(content)
   --  	item:setItemSize(566, 38)
   --  	self.lv:addItem(item)
   --  end
   -- self.lv:reload()
   -- self.lv:addTo(self)
   -- :pos(0, -30)

    display.newSprite("#actBox_recordMask.png")--, 0, 0, cc.size(LIST_WIDTH+15,HEIGHT),cc.rect(22,325,555,32))
    :addTo(self)
    :pos(1,-80)

    


	self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed="#panel_black_close_btn_down.png"})
    :pos(WIDTH/2 -5, HEIGHT/2-10)
    :onButtonClicked(function()
        nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        self:onClose()
    	end)
    :addTo(self)

    self:noRecordView(true)

end

function BoxActMyRecordDialog:onShowed()
	if self.list_ then
		 --self.list_:setData({1,2,2,5,6,6,7,7,7,7,7,7,7,7,7})
		 --self.list_:update()
		 -- self.list_:update()
     self.openRecordRequest_ = nk.http.openLuckBoxRecord(

      function(data)
        nk.http.cancel(self.openRecordRequest_)
        if data and #data ~= 0 then
          self:noRecordView(false)
          self.list_:setData(data)
          self.list_:update()
          self.list_:update()
        end
      end,

      function (errordata)
          -- body
          nk.http.cancel(self.openRecordRequest_)
      end
      )
	end
end
function BoxActMyRecordDialog:noRecordView(isShow)
  if isShow then
      self.norecordtxt_ = display.newTTFLabel({text = "ยังไม่มีบันทึก", color = cc.c3b(0xFF, 0xFF, 0xFF), size = 22, align = ui.TEXT_ALIGN_CENTER})
      :addTo(self)
  else
      if self.norecordtxt_ then
        self.norecordtxt_:removeFromParent()
        self.norecordtxt_ = nil
      end
  end
end
function BoxActMyRecordDialog:show()
    self:showPanel_()
    return self
end
return BoxActMyRecordDialog