--
-- Author: viking@boomegg.com
-- Date: 2014-10-29 12:02:13
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local WheelView = class("WheelView", function ()
    return display.newNode()
end)

local WheelSliceView = import(".WheelSliceView")

function WheelView:ctor(width, height)
    self:setNodeEventEnabled(true)
    self.width, self.height = width, height
    self:setupView()
end

function WheelView:setupView()
    --底盘
    self.wheel_ = display.newNode():addTo(self)
    self.views = {}
    local view_ = nil
    local degree = 45

    for i = 1, 8 do
        if i % 2 ~= 0 then
            view_ = WheelSliceView.new(WheelSliceView.YELLOW)
        else
            view_ = WheelSliceView.new(WheelSliceView.PURPLE)
        end

        view_:setRotation(degree * (i - 1))
        view_:addTo(self.wheel_)
        table.insert(self.views, view_)
    end

    --高光
    -- for i = 1, 2 do
    --     local fg = display.newSprite("#wheel_rotate_fg.png")
    --     fg:addTo(self)
    --     fg:setAnchorPoint(cc.p(1, 0))
    --     if i == 2 then
    --         fg:setScale(-1)
    --     end
    -- end

end

function WheelView:setItemData(items)
    self.items_ = items
    print("setItemData", items)
    for i,v in ipairs(items) do
        local view_ = self.views[i]
        view_:setDescText(v.desc)
        view_:setImageUrl(v.url)
        v.index = (i - 1)
    end
end

function WheelView:findItemById(id)
    for i,v in pairs(self.items_) do 
        if id == v.id then
            return self.items_[i]
        end
    end

    return nil
    -- return self.items_[id]
end

function WheelView:setDestDegreeById(id)
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local item = self:findItemById(id)
    local index = item.index

    local randDegree = 0
    local offsetDegree = 5
    if index == 0 then
        randDegree = math.random(-20 + offsetDegree, 20 - offsetDegree)
    else
        local min = 20 + 3 + 45 * (index - 1) + offsetDegree
        local max = min - 3 + 45 - offsetDegree * 2
        randDegree = math.random(min, max)
    end

    print("setDestDegreeById", id, randDegree)
    self.destDegree_ = 360 - randDegree
end

function WheelView:startRotation(callback)
    self.animOverCallback_ = callback
    if self.soundId then
          audio.stopSound(self.soundId)
    end
    self.soundId = nk.SoundManager:playSound(nk.SoundManager.WHEEL_LOOP, false)
    self:rotationByAccelerate()
end

function WheelView:rotationByAccelerate()
    self.wheel_:stopAllActions()
    local sequence = transition.sequence({
        cc.EaseIn:create(cc.RotateBy:create(1, 360), 2.5),
        cc.CallFunc:create(function()
            print("rotationByAccelerate over")
            self:rotationByDefault()
        end),
    })
    self.wheel_:runAction(sequence)
end

function WheelView:rotationByDefault()
    self.wheel_:setRotation(self.destDegree_)
    local sequence = transition.sequence({
        cc.RotateBy:create(0.5, 360),
        cc.CallFunc:create(function()
            print("rotationByDefault over")
            self:rotationByDecelerate()
        end),
    })
    self.wheel_:runAction(sequence)
end

function WheelView:rotationByDecelerate()
    local sequence = transition.sequence({
        cc.EaseOut:create(cc.RotateBy:create(3, 360), 2.5),
        cc.CallFunc:create(function()
            print("rotationByDecelerate over")
            if self.soundId then
                  audio.stopSound(self.soundId)
            end
            if self.animOverCallback_ then
                self.animOverCallback_()
            end
        end),
    })
    self.wheel_:runAction(sequence)
end

function WheelView:onExit()
    self.wheel_:stopAllActions()
    if self.soundId then
          audio.stopSound(self.soundId)
    end
end

return WheelView
