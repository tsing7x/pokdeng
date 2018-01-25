--
-- Author: johnny@boomegg.com
-- Date: 2014-07-11 15:54:34
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--[[
    用法：
    nk.PopupManager:addPopup(StorePopup.new())，默认模态、居中、点击模态关闭
]]

local PopupManager = class("PopupManager")
local Z_ORDER = 1000

function PopupManager:ctor()
    -- 数据容器
    self.popupStack_ = {}

    -- 视图容器
    self.container_ = display.newNode()
    self.container_:retain()
    self.container_:setNodeEventEnabled(true)
    self.container_.nodeCleanup_ = true
    self.container_.onCleanup = handler(self, function (obj)
        -- 移除模态
        if obj.modal_ then
            obj.modal_:removeFromParent()
            obj.modal_ = nil
        end

        -- 移除所有弹框
        for k, popupData in pairs(obj.popupStack_) do
            if popupData.popup then
                popupData.popup:removeFromParent()
            end
            obj.popupStack_[k] = nil
        end
        self.zOrder_ = 2
    end)

    -- zOrder
    self.zOrder_ = 2
end

function PopupManager:onModalTouch_()
    -- 获取最上层的弹框
    local popupData = self.popupStack_[#self.popupStack_]
    if popupData and popupData.popup and popupData.closeWhenTouchModel then
        nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        self:removePopup(popupData.popup)
    end
end

-- 添加一个弹框
function PopupManager:addPopup(popup, isModal, isCentered, closeWhenTouchModel, useShowAnimation)
    if isModal == nil then isModal = true end
    if isCentered == nil then isCentered = true end
    if not isModal then
        closeWhenTouchModel = false
    elseif closeWhenTouchModel == nil then
        closeWhenTouchModel = true
    end

    -- 添加模态
    if isModal and not self.modal_ then
        self.modal_ = display.newScale9Sprite("#modal_texture.png", 0, 0, cc.size(display.width, display.height))
            :pos(display.cx, display.cy)
            :addTo(self.container_)
        self.modal_:setTouchEnabled(true)
        self.modal_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onModalTouch_))
    end

    -- 居中弹框
    if isCentered then
        popup:pos(display.cx, display.cy)
    end

    -- 添加至场景
    if self:hasPopup(popup) then
        self:removePopup(popup)
    end
    table.insert(self.popupStack_, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal})
    if useShowAnimation ~= false then
        popup:scale(0.2)
        if popup.onShowed then
            transition.scaleTo(popup, {time = 0.5, easing = "BACKOUT", scale = 1, onComplete=function() popup:onShowed() end})
        else
            transition.scaleTo(popup, {time = 0.5, easing = "BACKOUT", scale = 1})
        end
    end
    popup:addTo(self.container_, self.zOrder_)
    self.zOrder_ = self.zOrder_ + 2
    if not self.container_:getParent() then
        self.container_:addTo(nk.runningScene, Z_ORDER)
    end
    
    -- 更改模态的zOrder
    if isModal then
        self.modal_:setLocalZOrder(popup:getLocalZOrder() - 1)
    end

    if popup.onShowPopup then
        popup:onShowPopup()
    end

    bm.EventCenter:dispatchEvent(nk.eventNames.DISENABLED_EDITBOX_TOUCH)
end

-- 移除指定弹框
function PopupManager:removePopup(popup)
    if popup then
        -- 从场景移除，删除数据
        bm.EventCenter:dispatchEvent(nk.eventNames.ENABLED_EDITBOX_TOUCH)
        local removePopupFunc = function()
            popup:removeFromParent()
            self.zOrder_ = self.zOrder_ - 2
            local bool, index = self:hasPopup(popup)
            table.remove(self.popupStack_, index)
            if #self.popupStack_ == 0 then
                if self.modal_ then
                    self.modal_:removeFromParent()
                    self.modal_ = nil
                end
                
                self.container_:removeFromParent()
            else
                -- 更改模态的zOrder
                local needModal = false
                for _, popupData in pairs(self.popupStack_) do
                    if popupData.isModal then
                        needModal = true
                        self.modal_:setLocalZOrder(popupData.popup:getLocalZOrder() - 1)
                        break
                    end
                end
                if not needModal then
                    self.modal_:removeFromParent()
                    self.modal_ = nil
                end
            end
        end
        if popup.onRemovePopup then
            popup:onRemovePopup(removePopupFunc)
        else
            removePopupFunc()
        end
    end
end

-- 移除所有弹框
function PopupManager:removeAllPopup()
    self.container_:removeFromParent()
end

-- Determines if a popup is contained in popup stack
function PopupManager:hasPopup(popup)
    for i, popupData in ipairs(self.popupStack_) do
        if popupData.popup == popup then
            return true, i
        end
    end
    return false, 0
end

-- Determines if a popup is the top-most pop-up.
function PopupManager:isTopLevelPopUp(popup)
    if self.popupStack_[#self.popupStack_].popup == popup then
        return true
    else
        return false
    end
end

function PopupManager:removeTopPopupIf()
    if #self.popupStack_ > 0 then
        local p = self.popupStack_[#self.popupStack_]
        if p.closeWhenTouchModel then
            self:removePopup(p.popup)
            return true
        end
    end
    return false
end

return PopupManager