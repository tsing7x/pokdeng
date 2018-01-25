--
-- Author: tony
-- Date: 2014-08-06 11:56:22
--
local MatchChatTabPanel = class("MatchChatTabPanel", function() return display.newNode() end)

MatchChatTabPanel.WIDTH = 500
MatchChatTabPanel.HEIGHT = 480
MatchChatTabPanel.PAGE_WIDTH = MatchChatTabPanel.WIDTH - 24
MatchChatTabPanel.PAGE_HEIGHT = MatchChatTabPanel.HEIGHT - 80

function MatchChatTabPanel:ctor(tabTitleLeft, tabTitleRight)
    self.background_ = display.newScale9Sprite("#room_chat_panel_background.png", 0, 0, cc.size(MatchChatTabPanel.WIDTH, MatchChatTabPanel.HEIGHT))
    self.background_:addTo(self)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)

    self.container_ = display.newNode():pos(0, -30):addTo(self)
    self:pos(- MatchChatTabPanel.WIDTH * 0.5, MatchChatTabPanel.HEIGHT * 0.5 + 80 + 8)



    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = MatchChatTabPanel.WIDTH + 60 , 
            iconOffsetX = 10, 
            btnText = bm.LangUtil.getText("ROOM", "CHAT_MAIN_TAB_TEXT")
        }
    )
        :pos(0, MatchChatTabPanel.HEIGHT * 0.5 - 32)
        :addTo(self)
    self.mainTabBar_:onTabChange(handler(self, self.onTabChanged_))


end

function MatchChatTabPanel:showPanel()
    nk.PopupManager:addPopup(self, true, false, true, false)
end

function MatchChatTabPanel:hidePanel()
    nk.PopupManager:removePopup(self)
end

function MatchChatTabPanel:onRemovePopup(removeFunc)
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=-MatchChatTabPanel.WIDTH * 0.5, easing="OUT", onComplete=function() 
        removeFunc()
    end})
end

function MatchChatTabPanel:onShowPopup()
    self:stopAllActions()
    transition.moveTo(self, {time=0.3, x=MatchChatTabPanel.WIDTH * 0.5 + 8, easing="OUT", onComplete=function()
        if self.onShow then
            self:onShow()
        end
        -- local cbox = self:getCascadeBoundingBox()
        -- cbox:setRect(cbox.x, cbox.y, MatchChatTabPanel.WIDTH, MatchChatTabPanel.HEIGHT)
        -- self:setCascadeBoundingBox(cbox)
    end})
end

function MatchChatTabPanel:setPage(index, page)
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

function MatchChatTabPanel:selectPage(index)
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

function MatchChatTabPanel:onTabChanged_(index)
    print("selecte ", index)
    self:selectPage(index)
end

return MatchChatTabPanel