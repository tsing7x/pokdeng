--
-- Author: tony
-- Date: 2014-08-01 16:31:47
--

local Panel = class("Panel", function()
    return display.newNode()
end)

Panel.SIZE_SMALL = {}
Panel.SIZE_NORMAL = {750, 480}
Panel.SIZE_LARGE = {}

function Panel:ctor(size)
    self.width_, self.height_= size[1], size[2]
    self.background_ = display.newScale9Sprite("#panel_bg.png", 0, 0, cc.size(self.width_, self.height_)):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)
    self.backgroundTex_ = display.newTilesSprite("repeat/panel_repeat_tex.png", cc.rect(0, 0, self.width_ - 3, self.height_ - 3))
        :pos(-(self.width_ - 3) * 0.5, -(self.height_ - 3) * 0.5)
        :addTo(self)
end

function Panel:addCloseBtn()
    if not self.closeBtn_ then
        self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
            :pos(self.width_ * 0.5 - 15, self.height_ * 0.5 - 22)
            :onButtonClicked(function() 
                    self:onClose()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 9)
    end
end

function Panel:showPanel_(isModal, isCentered, closeWhenTouchModel, useShowAnimation)
    nk.PopupManager:addPopup(self, isModal ~= false, isCentered ~= false, closeWhenTouchModel ~= false, useShowAnimation ~= false)
    return self
end

function Panel:hidePanel_()
    nk.PopupManager:removePopup(self)
    return self
end

function Panel:onClose()
    self:hidePanel_()
end

return Panel
