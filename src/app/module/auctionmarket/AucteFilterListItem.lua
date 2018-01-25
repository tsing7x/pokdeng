local AucteFilterListItem = class("AucteFilterListItem", bm.ui.ListItem)

local WIDTH = 90
local HEIGHT = 34
function AucteFilterListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeEventEnabled(true)
    AucteFilterListItem.super.ctor(self, WIDTH, HEIGHT)
    display.newScale9Sprite("#aucMar_Itemline.png", 0, 0, cc.size(WIDTH,0 ))
    :pos(WIDTH/2,0)
    :addTo(self)

    self.txt_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER,color = cc.c3b(0xff,0x93,0xb3),dimensions = cc.size(WIDTH, HEIGHT)})
    :addTo(self)
    :pos(WIDTH/2,HEIGHT/2)

    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
    :setButtonSize(WIDTH, HEIGHT)
    :pos(WIDTH/2,HEIGHT/2)
    :onButtonClicked(buttontHandler(self, self.selectItem))
    :addTo(self)
    :setTouchSwallowEnabled(false);
end
function AucteFilterListItem:selectItem()
    self:dispatchEvent({name="ITEM_EVENT", data = self.itemData_})
	
end
function AucteFilterListItem:setData(data)
	self.itemData_ = data
	self.txt_:setString(data.name)
end
return AucteFilterListItem