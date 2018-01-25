--
 --已选按钮带重复点击事件的扩展
--
local CheckBoxButtonGroupEx = class("CheckBoxButtonGroupEx")

CheckBoxButtonGroupEx.BUTTON_SELECT_CHANGED = "BUTTON_SELECT_CHANGED"
CheckBoxButtonGroupEx.BUTTON_SELECT_REPEAT_CLICKED = "BUTTON_SELECT_REPEAT_CLICKED"

function CheckBoxButtonGroupEx:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.buttons_ = {}
    self.buttonId_ = {}
    self.currentSelectedIndex_ = 0
end

function CheckBoxButtonGroupEx:addButton(button, id)
    self.buttons_[#self.buttons_ + 1] = button
    if id then
        self.buttonId_[#self.buttonId_ + 1] = id
    end
    button:onButtonClicked(buttontHandler(self, self.onButtonStateChanged_))
    button:onButtonStateChanged(handler(self, self.onButtonStateChanged_))
    return self
end

function CheckBoxButtonGroupEx:getButtonById(id)
    for i, v in pairs(self.buttonId_) do
        if tostring(v) == tostring(id) then
            return self.buttons_[i]
        end
    end
end

function CheckBoxButtonGroupEx:reset()
    self:removeAllEventListeners()
    while self:getButtonsCount() > 0 do
        self:removeButtonAtIndex(self:getButtonsCount())
    end
end

function CheckBoxButtonGroupEx:removeButtonAtIndex(index)
    assert(self.buttons_[index] ~= nil, "CheckBoxButtonGroupEx:removeButtonAtIndex() - invalid index")

    local button = self.buttons_[index]
    button:removeSelf()
    table.remove(self.buttons_, index)
    table.remove(self.buttonId_, index)

    if self.currentSelectedIndex_ == index then
        self:updateButtonState_(nil)
    elseif index < self.currentSelectedIndex_ then
        self:updateButtonState_(self.buttons_[self.currentSelectedIndex_ - 1])
    end
    return self
end

function CheckBoxButtonGroupEx:getButtonAtIndex(index)
    return self.buttons_[index]
end

function CheckBoxButtonGroupEx:getButtonsCount()
    return #self.buttons_
end

function CheckBoxButtonGroupEx:addButtonSelectChangedEventListener(callback)
    return self:addEventListener(CheckBoxButtonGroupEx.BUTTON_SELECT_CHANGED, callback)
end

function CheckBoxButtonGroupEx:onButtonSelectChanged(callback)
    self:addButtonSelectChangedEventListener(callback)
    return self
end


function CheckBoxButtonGroupEx:addButtonSelectRepeatClickEventListener(callback)
    return self:addEventListener(CheckBoxButtonGroupEx.BUTTON_SELECT_REPEAT_CLICKED, callback)
end


function CheckBoxButtonGroupEx:onButtonRepeatClicked( callback )
    self:addButtonSelectRepeatClickEventListener(callback)
    return self
end

function CheckBoxButtonGroupEx:onButtonStateChanged_(event)
    if event.name == cc.ui.UICheckBoxButton.STATE_CHANGED_EVENT and event.target:isButtonSelected() == false then
        return
    end


    self:updateButtonState_(event.target,event)
end

function CheckBoxButtonGroupEx:updateButtonState_(clickedButton,event)
    local currentSelectedIndex = 0
    for index, button in ipairs(self.buttons_) do
        if button == clickedButton then
            currentSelectedIndex = index
            if not button:isButtonSelected() then
                button:setButtonSelected(true)
            end
        else
            if button:isButtonSelected() then
                button:setButtonSelected(false)
            end
        end
    end
   
    if self.currentSelectedIndex_ ~= currentSelectedIndex then
        local last = self.currentSelectedIndex_
        self.currentSelectedIndex_ = currentSelectedIndex
        self:dispatchEvent({name = CheckBoxButtonGroupEx.BUTTON_SELECT_CHANGED, selected = currentSelectedIndex, last = last})
    else
        if event and event.name == cc.ui.UICheckBoxButton.STATE_CHANGED_EVENT  then
            self:dispatchEvent({name = CheckBoxButtonGroupEx.BUTTON_SELECT_REPEAT_CLICKED, selected = self.currentSelectedIndex_, last = self.currentSelectedIndex_})
        end
    end
end


return CheckBoxButtonGroupEx