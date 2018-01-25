--
-- Author: tony
-- Date: 2014-07-18 20:24:15
--
local GrabOperationButtonGroup = class("GrabOperationButtonGroup")

function GrabOperationButtonGroup:ctor()
    self.btns = {}
end

function GrabOperationButtonGroup:add(id, oprBtn)
    self.btns[id] = oprBtn
    oprBtn:onCheck(handler(self, self.onCheck))
end

function GrabOperationButtonGroup:getCheckedId()
    for k, v in pairs(self.btns) do
        if v:isChecked() then
            return k
        end
    end
    return 0
end

function GrabOperationButtonGroup:uncheck()
    for k, v in pairs(self.btns) do
        v:setChecked(false, false)
    end
    if self.onCheckedHandler_ then
        self.onCheckedHandler_(self:getCheckedId())
    end
    return self
end

function GrabOperationButtonGroup:onCheck(btn, isChecked)
    if isChecked then
        for k, v in pairs(self.btns) do
            if v ~= btn then
                v:setChecked(false, false)
            end
        end
    end
    if self.onCheckedHandler_ then
        self.onCheckedHandler_(self:getCheckedId())
    end
end

function GrabOperationButtonGroup:setChecked(id, isChecked)
    local btn = self.btns[id]
    btn:setChecked(isChecked, true)
    return self
end

function GrabOperationButtonGroup:onChecked(handler)
    self.onCheckedHandler_ = handler
    return self
end

return GrabOperationButtonGroup