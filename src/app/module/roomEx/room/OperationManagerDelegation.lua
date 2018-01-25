--
-- Author: tony
-- Date: 2014-07-17 15:20:01
local OperationManager = import(".OperationManager")
local OperationManagerEx = import(".OperationManagerEx")

local OperationManagerDelegation = class("OperationManagerDelegation")
function OperationManagerDelegation:ctor()
    
end

function OperationManagerDelegation:createNodes()
    --聊天按钮

end

function OperationManagerDelegation:init(isAllin)
    
    if self.oprManager and isAllin ~= self.perAllin_ then
        self.oprManager:dispose()
        self.scene.nodes.oprNode:removeAllChildren()
        self.oprManager = nil
    end
    if not self.oprManager and isAllin and isAllin == 1 then   
        self.oprManager = OperationManagerEx.new()
        self:initdata()
    elseif not self.oprManager and isAllin and isAllin ~= 1 then
        self.oprManager = OperationManager.new()
        self:initdata()
    end

            

    self.perAllin_ = isAllin
end

function OperationManagerDelegation:initdata()
    rawset(self.oprManager, "ctx", self.ctx)
            for k, v in pairs(self.ctx) do
                if k ~= "export" and v ~= self.oprManager then
                    rawset(self.oprManager, k, v)
                end
            end

            self.oprManager:createNodes()
end

function OperationManagerDelegation:setLatestChatMsg(msg)
    if self.oprManager then
        return self.oprManager:setLatestChatMsg(msg)
    end
end

function OperationManagerDelegation:startLoading()
    if self.oprManager then
        return self.oprManager:startLoading()
    end
end

function OperationManagerDelegation:stopLoading()
    if self.oprManager then
        return self.oprManager:stopLoading()
    end
end

function OperationManagerDelegation:dispose()
    if self.oprManager then
        return self.oprManager:dispose()
    end
end

function OperationManagerDelegation:showOperationButtons(animation)
     if self.oprManager then
        return self.oprManager:showOperationButtons(animation)
    end
end

function OperationManagerDelegation:hideOperationButtons(animation)
     if self.oprManager then
        return self.oprManager:hideOperationButtons(animation)
    end
end

function OperationManagerDelegation:showExtOperationView(animation)
     if self.oprManager then
        return self.oprManager:showExtOperationView(animation)
    end
end

function OperationManagerDelegation:showHandcardCallback_()
     if self.oprManager then
        return self.oprManager:showHandcardCallback_()
    end
end

function OperationManagerDelegation:blockOperationButtons()
     if self.oprManager then
        return self.oprManager:blockOperationButtons()
    end
end

function OperationManagerDelegation:resetAutoOperationStatus()
     if self.oprManager then
        return self.oprManager:resetAutoOperationStatus()
    end
end

function OperationManagerDelegation:updateOperationStatus()
     if self.oprManager then
        return self.oprManager:updateOperationStatus()
    end
end

function OperationManagerDelegation:setSliderStatus(minRaiseChips, maxRaiseChips)
     if self.oprManager then
        return self.oprManager:setSliderStatus(minRaiseChips, maxRaiseChips)
    end
end

--无法操作的状态
function OperationManagerDelegation:disabledStatus_()
     if self.oprManager then
        return self.oprManager:disabledStatus_()
    end
end

function OperationManagerDelegation:getQuickCallValue_(minBet)
     if self.oprManager then
        return self.oprManager:getQuickCallValue_(minBet)
    end
end

--下注
function OperationManagerDelegation:selfCanRaiseStatus_(minRaiseChips, maxRaiseChips)
     if self.oprManager then
        return self.oprManager:selfCanRaiseStatus_(minRaiseChips, maxRaiseChips)
    end
end

--要牌
function OperationManagerDelegation:getPokerStatus_()
     if self.oprManager then
        return self.oprManager:getPokerStatus_()
    end
end

function OperationManagerDelegation:getPokerForceStatus_()
     if self.oprManager then
        return self.oprManager:getPokerForceStatus_()
    end
end

-- 将要要牌
function OperationManagerDelegation:willGetPokerStatus_()
     if self.oprManager then
        return self.oprManager:willGetPokerStatus_()
    end
end 

function OperationManagerDelegation:quickCall1Handler(evt)
     if self.oprManager then
        return self.oprManager:quickCall1Handler(evt)
    end
end 

function OperationManagerDelegation:quickCall2Handler(evt)
     if self.oprManager then
        return self.oprManager:quickCall2Handler(evt)
    end
end

function OperationManagerDelegation:quickCall3Handler(evt)
     if self.oprManager then
        return self.oprManager:quickCall3Handler(evt)
    end
end

function OperationManagerDelegation:getPokerClickHandler(evt)
     if self.oprManager then
        return self.oprManager:getPokerClickHandler(evt)
    end
end

function OperationManagerDelegation:notGetPokerClickHandler(evt)
     if self.oprManager then
        return self.oprManager:notGetPokerClickHandler(evt)
    end
end

--最小下注
function OperationManagerDelegation:callMiniClickHandler(evt)
     if self.oprManager then
        return self.oprManager:callMiniClickHandler(evt)
    end
end

-- 下注
function OperationManagerDelegation:setBet_(bet)
     if self.oprManager then
        return self.oprManager:setBet_(bet)
    end
end

function OperationManagerDelegation:raiseRangeClickHandler(evt)
     if self.oprManager then
        return self.oprManager:raiseRangeClickHandler(evt)
    end
end

-- 勾选了自动看牌跟注等，在这里自动发包
function OperationManagerDelegation:applyAutoOperation_()
     if self.oprManager then
        return self.oprManager:applyAutoOperation_()
    end
end

function OperationManagerDelegation:onRaiseSliderButtonClicked_(tag)
     if self.oprManager then
        return self.oprManager:onRaiseSliderButtonClicked_(tag)
    end
end

function OperationManagerDelegation:onBackgroundClicked()
     if self.oprManager then
        return self.oprManager:onBackgroundClicked()
    end
end

return OperationManagerDelegation