--
-- Author: johnny@boomegg.com
-- Date: 2014-08-08 18:38:03
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local TabBarWithIndicator = class("TabBarWithIndicator", function ()
    return display.newNode()
end)

TabBarWithIndicator.HORIZONTAL = 1
TabBarWithIndicator.VERTICAL   = 2

local subTabSelectedColor = cc.c3b(0x27, 0x90, 0xd5)
local subTabDefaultColor = cc.c3b(0xca, 0xca, 0xca)
local subTabSelectedSize = 22
local subTabDefaultSize = 22

function TabBarWithIndicator:ctor(images, texts, textConfigs, scale9, withDrag, direction)
    self.textConfigs_ = textConfigs or     {
            selectedText = {color = subTabSelectedColor, size = subTabSelectedSize}, 
            defaltText = {color = subTabDefaultColor, size = subTabDefaultSize}
        }
    self.scale9_ = scale9 or false
    self.withDrag_ = withDrag or false
    self.direction_ = direction or TabBarWithIndicator.HORIZONTAL

    -- 设置背景与指示器
    if self.scale9_ then
        if type(images.background) == "string" then
            self.background_ = display.newScale9Sprite(images.background)
                :addTo(self)
        else
            self.background_ = images.background:addTo(self)
        end
        self.indicator_ = display.newScale9Sprite(images.indicator)
            :addTo(self)
    else
        if type(images.background) == "string" then
            self.background_ = display.newSprite(images.background)
                :addTo(self)
        else
            self.background_ = images.background:addTo(self)
        end
        self.indicator_ = display.newSprite(images.indicator)
            :addTo(self)
    end
    if self.withDrag_ then
        self.indicator_:setTouchEnabled(true)
        self.indicator_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onIndicatorTouch_))
    end

    -- 设置子按钮与文本标签
    self.subBtns_ = {}
    self.labels_ = {}
    self.dividers_ = {}
    self.btnsNum_ = #texts
    local btnSize = nil
    if self.direction_ == TabBarWithIndicator.HORIZONTAL then
        btnSize = cc.size(self.background_:getContentSize().width / self.btnsNum_, self.background_:getContentSize().height)
    else
        btnSize = cc.size(self.background_:getContentSize().width, self.background_:getContentSize().height / self.btnsNum_)
    end
    
    for i = 1, self.btnsNum_ do
        self.subBtns_[i] = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png"}, {scale9 = true})
            :setButtonSize(btnSize.width, btnSize.height)
            :addTo(self)
            :onButtonClicked(buttontHandler(self, self.onBtnClick_))
        self.subBtns_[i]:setTouchSwallowEnabled(false)
        if self.direction_ == TabBarWithIndicator.HORIZONTAL then
            self.subBtns_[i]:pos((i - 0.5 - self.btnsNum_ * 0.5) * btnSize.width, 0)
        else
            self.subBtns_[i]:pos(0, (self.btnsNum_ * 0.5 - i + 0.5) * btnSize.height)
        end

        self.labels_[i] = display.newTTFLabel({
            text  = texts[i], 
            color = self.textConfigs_.defaltText.color, 
            size  = self.textConfigs_.defaltText.size, 
            align = ui.TEXT_ALIGN_CENTER
        })
            :addTo(self)
        if self.direction_ == TabBarWithIndicator.HORIZONTAL then
            self.labels_[i]:pos((i - 0.5 - self.btnsNum_ * 0.5) * btnSize.width, 0)
        else
            self.labels_[i]:pos(0, (self.btnsNum_ * 0.5 - i + 0.5) * btnSize.height)
        end
    end

    self.selectedTab_ = 1
end

function TabBarWithIndicator:onIndicatorTouch_(evt)
    local name, curX, curY = evt.name, evt.x, evt.y
    if name == "began" then
        self.srcPosY_ = curY
        self.srcPosX_ = curX
        return true
    elseif name == "ended" then
        if self.direction_ == TabBarWithIndicator.HORIZONTAL then
            if curX - self.srcPosX_ > 20 and self.selectedTab_ + 1 <= self.btnsNum_ then
                self:gotoTab(self.selectedTab_ + 1)
            elseif self.srcPosX_ - curX > 20 and self.selectedTab_ - 1 >= 1 then
                self:gotoTab(self.selectedTab_ - 1)
            end
        else
            if self.srcPosY_ - curY > 20 and self.selectedTab_ + 1 <= self.btnsNum_ then
                self:gotoTab(self.selectedTab_ + 1)
            elseif curY - self.srcPosY_ > 20 and self.selectedTab_ - 1 >= 1 then
                self:gotoTab(self.selectedTab_ - 1)
            end
        end
        
    end
end

function TabBarWithIndicator:setTabBarSize(width, height, offsetWidth, offsetHeight)
    assert(self.scale9_, "TabBarWithIndicator:setTabBarSize() - can't change size for non-scale9 tab bar")
    self.background_:setContentSize(cc.size(width, height))
    local btnSize = nil
    if self.direction_ == TabBarWithIndicator.HORIZONTAL then
        self.indicator_:setContentSize(cc.size(width / self.btnsNum_ + (offsetWidth or 0), height + (offsetHeight or 0)))
        btnSize = cc.size(self.background_:getContentSize().width / self.btnsNum_, self.background_:getContentSize().height)
    else
        self.indicator_:setContentSize(width + (offsetWidth or 0), cc.size(height / self.btnsNum_ + (offsetHeight or 0)))
        btnSize = cc.size(self.background_:getContentSize().width, self.background_:getContentSize().height / self.btnsNum_)
    end
    
    for i = 1, self.btnsNum_ do
        self.subBtns_[i]:setButtonSize(btnSize.width, btnSize.height)
        if self.direction_ == TabBarWithIndicator.HORIZONTAL then
            self.subBtns_[i]:pos((i - 0.5 - self.btnsNum_ * 0.5) * btnSize.width, 0)
            self.labels_[i]:pos((i - 0.5 - self.btnsNum_ * 0.5) * btnSize.width, 0)
        else
            self.subBtns_[i]:pos(0, (self.btnsNum_ * 0.5 - i + 0.5) * btnSize.height)
            self.labels_[i]:pos(0, (self.btnsNum_ * 0.5 - i + 0.5) * btnSize.height)
        end
    end

    return self
end

function TabBarWithIndicator:gotoTab(tab, notWithAnim)
    self.labels_[self.selectedTab_]:setTextColor(self.textConfigs_.defaltText.color) -- 常态色
    if tab >= 1 and tab <= self.btnsNum_ then
        if notWithAnim then
            self.selectedTab_ = tab
            self.labels_[self.selectedTab_]:setTextColor(self.textConfigs_.selectedText.color) -- 选中色
            self.indicator_:stopAllActions()
            if self.direction_ == TabBarWithIndicator.HORIZONTAL then
                self.indicator_:setPositionX((tab - 0.5 - self.btnsNum_ * 0.5) * self.background_:getContentSize().width / self.btnsNum_)
            else
                self.indicator_:setPositionY((self.btnsNum_ * 0.5 - tab + 0.5) * self.background_:getContentSize().height / self.btnsNum_)
            end
            if self.callback_ then
                self.callback_(self.selectedTab_)
            end
        else
            local moveToArgs = {
                time = 0.2, 
                onComplete = handler(self, function (obj)
                    obj.selectedTab_ = tab
                    obj.labels_[obj.selectedTab_]:setTextColor(self.textConfigs_.selectedText.color) -- 选中色
                    if obj.callback_ then
                        obj.callback_(obj.selectedTab_)
                    end
                end)
            }
            if self.direction_ == TabBarWithIndicator.HORIZONTAL then
                moveToArgs.x = (tab - 0.5 - self.btnsNum_ * 0.5) * self.background_:getContentSize().width / self.btnsNum_
            else
                moveToArgs.y = (self.btnsNum_ * 0.5 - tab + 0.5) * self.background_:getContentSize().height / self.btnsNum_
            end
            self.indicator_:stopAllActions()
            transition.moveTo(self.indicator_, moveToArgs)
        end
    end
    
    return self
end

function TabBarWithIndicator:onBtnClick_(event)
    local btnId = table.keyof(self.subBtns_, event.target) + 0
    if btnId ~= self.selectedTab_ and btnId >= 1 and btnId <= self.btnsNum_ then
        self:gotoTab(btnId)
    end
end

function TabBarWithIndicator:onTabChange(callback)
    assert(type(callback) == "function", "callback should be a function")
    self.callback_ = callback
    return self
end

return TabBarWithIndicator