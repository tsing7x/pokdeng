--
-- Author: tony
-- Date: 2014-08-06 11:56:22
--
local GrabChatTabPanel = class("GrabChatTabPanel", function() return display.newNode() end)

GrabChatTabPanel.WIDTH = 500
GrabChatTabPanel.HEIGHT = 480
GrabChatTabPanel.PAGE_WIDTH = GrabChatTabPanel.WIDTH - 24
GrabChatTabPanel.PAGE_HEIGHT = GrabChatTabPanel.HEIGHT - 80

function GrabChatTabPanel:ctor(tabTitleLeft, tabTitleRight)
    self.background_ = display.newScale9Sprite("#room_chat_panel_background.png", 0, 0, cc.size(GrabChatTabPanel.WIDTH, GrabChatTabPanel.HEIGHT))
    self.background_:addTo(self)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

    self.container_ = display.newNode():pos(0, -30):addTo(self)
    self:pos(- GrabChatTabPanel.WIDTH * 0.5, GrabChatTabPanel.HEIGHT * 0.5 + 80 + 8)



    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = GrabChatTabPanel.WIDTH + 60 , 
            iconOffsetX = 10, 
            btnText = bm.LangUtil.getText("ROOM", "CHAT_MAIN_TAB_TEXT")
        }
    )
        :pos(0, GrabChatTabPanel.HEIGHT * 0.5 - 32)
        :addTo(self)
    self.mainTabBar_:onTabChange(handler(self, self.onTabChanged_))


end

function GrabChatTabPanel:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
end

function GrabChatTabPanel:hidePanel()
    nk.PopupManager:removePopup(self)
end

function GrabChatTabPanel:onRemovePopup(removeFunc)
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=-GrabChatTabPanel.WIDTH * 0.5, easing="OUT", onComplete=function() 
        removeFunc()
    end})
end

function GrabChatTabPanel:onShowPopup()
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=GrabChatTabPanel.WIDTH * 0.5 + 8, easing="OUT", onComplete=function()
        if self.onShow then
            self:onShow()
        end
        -- local cbox = self:getCascadeBoundingBox()
        -- cbox:setRect(cbox.x, cbox.y, GrabChatTabPanel.WIDTH, GrabChatTabPanel.HEIGHT)
        -- self:setCascadeBoundingBox(cbox)
    end})
end

function GrabChatTabPanel:setPage(index, page)
    if index == 1 then
        if self.page1_ then
            self.page1_:removeFromParent()
        end
        self.page1_ = page:pos(0, -30):addTo(self):hide()
    elseif index == 2 then
        if self.page2_ then
            self.page2_:removeFromParent()
        end
        self.page2_ = page:pos(0, -30):addTo(self):hide()
    end
    self:selectPage(self.selectedIndex_)
end

function GrabChatTabPanel:selectPage(index)
    if self.page1_ and self.page2_ then
        if self.selectedIndex_ ~= index then
            if index == 2 then
                self.page1_:hide()
                self.page2_:show()
                self.selectedIndex_ = 2
            elseif index == 1 then
                self.page1_:show()
                self.page2_:hide()
                self.selectedIndex_ = 1
            end
        end
    elseif self.page1_ then
        self.page1_:show()
        self.selectedIndex_ = 1
    elseif self.page2_ then
        self.page2_:show()
        self.selectedIndex_ = 2
    end
end

function GrabChatTabPanel:onTabChanged_(index)
    print("selecte ", index)
    self:selectPage(index)
end

return GrabChatTabPanel