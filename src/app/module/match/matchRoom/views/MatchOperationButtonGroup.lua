--
-- Author: tony
-- Date: 2014-07-18 20:24:15
--
local MatchOperationButtonGroup = class("MatchOperationButtonGroup")

function MatchOperationButtonGroup:ctor()
    self.btns = {}
end

function MatchOperationButtonGroup:add(id, oprBtn)
    self.btns[id] = oprBtn
    oprBtn:onCheck(handler(self, self.onCheck))
end

function MatchOperationButtonGroup:getCheckedId()
    for k, v in pairs(self.btns) do
        if v:isChecked() then
            return k
        end
    end
    return 0
end

function MatchOperationButtonGroup:uncheck()
    for k, v in pairs(self.btns) do
        v:setChecked(false, false)
    end
    if self.onCheckedHandler_ then
        self.onCheckedHandler_(self:getCheckedId())
    end
    return self
end

function MatchOperationButtonGroup:onCheck(btn, isChecked)
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

function MatchOperationButtonGroup:setChecked(id, isChecked)
    local btn = self.btns[id]
    btn:setChecked(isChecked, true)
    return self
end

function MatchOperationButtonGroup:onChecked(handler)
    self.onCheckedHandler_ = handler
    return self
end

return MatchOperationButtonGroup