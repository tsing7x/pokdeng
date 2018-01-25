--
-- Author: johnny@boomegg.com
-- Date: 2014-08-14 22:11:43
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local MatchHddjController = class("MatchHddjController")

local RoomViewPosition = import(".views.MatchRoomViewPosition")
local SeatPosition = RoomViewPosition.SeatPosition

function MatchHddjController:ctor(container)
    self.container_ = container
    self.loadedHddjIds_ = {}
    self.loadingHddj_ = {}
    self:refreshHddjNum()
    self.loadHddjNumEventListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.ROOM_LOAD_HDDJ_NUM, handler(self, self.loadHddjNum))
    self.refreshHddjNumEventListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.ROOM_REFRESH_HDDJ_NUM, handler(self, self.refreshHddjNum))
end

function MatchHddjController:dispose()
    for k, v in pairs(self.loadedHddjIds_) do
        --print("removeAnimationCache hddjAnim" .. k)
        display.removeAnimationCache("hddjAnim" .. k)
        --print("removeSpriteFramesWithFile hddjs/hddj-" .. k .. ".plist", "hddjs/hddj-" .. k .. ".png")
        display.removeSpriteFramesWithFile("hddjs/hddj-" .. k .. ".plist", "hddjs/hddj-" .. k .. ".png")
    end
    self.loadedHddjIds_ = nil
    self.loadingHddj_ = nil
    self.isDisposed_ = true
    bm.EventCenter:removeEventListener(self.loadHddjNumEventListenerId_)
    bm.EventCenter:removeEventListener(self.refreshHddjNumEventListenerId_)
end

function MatchHddjController:loadHddjNum()
    if not nk.userData.hddjNum then
        self:refreshHddjNum()
    end
end

function MatchHddjController:refreshHddjNum()
    if not self.isHddjNumLoading_ then
        self.isHddjNumLoading_ = true
        nk.userData.hddjNum = nil
        local request
        request = function(times)

            --获取道具数量
            nk.http.getUserProps(2,function(pdata)
                if pdata then
                    for _,v in pairs(pdata) do
                        if tonumber(v.pnid) == 2001 then
                            nk.userData.hddjNum = checkint(v.pcnter)
                            break
                        end
                    end
                end
                
            end,function()
                if times > 0 then
                    request(times - 1)
                else
                    self.isHddjNumLoading_ = false
                end
            end)

            --[[
            bm.HttpService.POST({mod="user", act="getUserFun"}, function(ret)
                self.isHddjNumLoading_ = false
                local num = tonumber(ret)
                if num then
                    nk.userData.hddjNum = num
                end
            end,
            function()
                if times > 0 then
                    request(times - 1)
                else
                    self.isHddjNumLoading_ = false
                end
            end)
            --]]
        end
        request(3)
    end
end

function MatchHddjController:playHddj(fromPositionId, toPositionId, hddjId, completeCallback)
    if self.isDisposed_ then
        return
    elseif hddjId == 1 then
        return self:playEgg(fromPositionId, toPositionId, completeCallback)
    elseif hddjId == 10 then
        return self:playTissue(fromPositionId, toPositionId, completeCallback)
    elseif hddjId == 4 then
        return self:playKiss(fromPositionId, toPositionId, completeCallback)
    else
        return self:playHddjAnim(hddjId, fromPositionId, toPositionId, completeCallback)
    end
end

MatchHddjController.hddjConfig = {
    [2] = {frameNum=13, x=35, y=30, iconX=35 + 48, iconY=30 + 38, soundDelay=0.2},
    [3] = {frameNum=14, },
    [5] = {frameNum=12, y=12},
    [6] = {frameNum=14, iconScale=0.8, curvePath=true, delay=0, rotation=3, x=0, y=-10, iconX=0, iconY=10, soundDelay=0.2},
    [7] = {frameNum=13, scale=1.6, iconScale=1.6, x=0, y=10, iconX=-38 * 1.6, iconY=-20},
    [8] = {frameNum=15, x=-4, y=0, iconX=44, iconY=26, soundDelay=0.2},
    [9] = {frameNum=17, delay=0, x=0, y=0, iconX=0, iconY=0},
    [21] = {frameNum = 8, iconScale = 1.6, scale = .5, delay = 0, x = 0, y = 0, iconX = 0, iconY = 0},
    [22] = {frameNum = 11, iconScale = 1.6, scale = .5, delay = 0, x = 0, y = 0, iconX = 0, iconY = 0}
}

function MatchHddjController:playHddjAnim(hddjId, fromPositionId, toPositionId, completeCallback)
    local container = display.newNode():addTo(self.container_)
    local animName = "hddjAnim" ..hddjId
    if self.loadedHddjIds_[hddjId] then
        print(animName .. " loaded")
        self.loadedHddjIds_[hddjId] = bm.getTime()
        local anim = display.getAnimationCache(animName)
        self:playHddjAnim_(hddjId, container, anim, fromPositionId, toPositionId, completeCallback)
    elseif self.loadingHddj_[hddjId] then
        print(animName .. " loading")
        table.insert(self.loadingHddj_[hddjId], function(anim)
            self:playHddjAnim_(hddjId, container, anim, fromPositionId, toPositionId, completeCallback)
        end)
    else
        print(animName .. " not loading")
        self.loadingHddj_[hddjId] = {}
        table.insert(self.loadingHddj_[hddjId], function(anim)
            self:playHddjAnim_(hddjId, container, anim, fromPositionId, toPositionId, completeCallback)
        end)
        display.addSpriteFrames("hddjs/hddj-" .. hddjId .. ".plist", "hddjs/hddj-" .. hddjId .. ".png", function()
            print(animName .. " texture loaded")
            if self.isDisposed_ then
                display.removeSpriteFramesWithFile("hddjs/hddj-" .. hddjId .. ".plist", "hddjs/hddj-" .. hddjId .. ".png")
            else
                local config = MatchHddjController.hddjConfig[hddjId]
                local frameNum = config.frameNum
                local loop = config.loop
                local frames = display.newFrames("hddj-" .. hddjId .. "-%04d.png", 1, frameNum, loop)
                 local anim = display.newAnimation(frames, 1 / 10)
                 display.setAnimationCache(animName, anim)
                while #self.loadingHddj_[hddjId] > 0 do
                    self.loadingHddj_[hddjId][1](display.getAnimationCache(animName))
                    table.remove(self.loadingHddj_[hddjId], 1)
                end
                self.loadingHddj_[hddjId] = nil
                self.loadedHddjIds_[hddjId] = bm.getTime()
                local keys = table.keys(self.loadedHddjIds_)
                if #keys > 4 then
                    table.sort(keys, function(o1, o2)
                        return self.loadedHddjIds_[o1] < self.loadedHddjIds_[o2]
                    end)
                    local delNum = #keys - 4
                    for i = 1, delNum do
                        local id = keys[i]
                        self.loadedHddjIds_[id] = nil
                        display.removeAnimationCache("hddjAnim" .. id)
                        display.removeSpriteFramesWithFile("hddjs/hddj-" .. id .. ".plist", "hddjs/hddj-" .. id .. ".png")
                    end
                end
            end
        end)
    end
    return container
end

function MatchHddjController:playHddjAnim_(hddjId, container, anim, fromPositionId, toPositionId, completeCallback)
    print("playHddjAnim_", hddjId, container, anim, fromPositionId, toPositionId)
    local config = MatchHddjController.hddjConfig[hddjId]
    local icon = display.newSprite("#hddj_" .. hddjId .. ".png"):scale(config.iconScale or 1)
    icon:pos(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y)
    icon:addTo(container)
    if config.curvePath then
        local distance = cc.pGetDistance(cc.p(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y), cc.p(SeatPosition[toPositionId].x + (config.iconX or 0), SeatPosition[toPositionId].y + (config.iconY or 0)))
        local bconfig = {
            cc.p((SeatPosition[fromPositionId].x + SeatPosition[toPositionId].x + (config.iconX or 0)) * 0.5, (SeatPosition[fromPositionId].y + SeatPosition[toPositionId].y + (config.iconY or 0)) * 0.5 + distance * 0.16),
            cc.p((SeatPosition[fromPositionId].x + SeatPosition[toPositionId].x + (config.iconX or 0)) * 0.5, (SeatPosition[fromPositionId].y + SeatPosition[toPositionId].y + (config.iconY or 0)) * 0.5 + distance * 0.16),
            cc.p(SeatPosition[toPositionId].x + (config.iconX or 0), SeatPosition[toPositionId].y + (config.iconY or 0))
        }
        icon:runAction(transition.sequence({
            cc.EaseInOut:create(cc.BezierTo:create(1, bconfig), 2),
            cc.DelayTime:create(config.delay or 0.1),
            cc.CallFunc:create(function()
                    icon:removeFromParent()
                    if not config.soundDelay then
                        nk.SoundManager:playHddjSound(hddjId)
                    end
                end)
        }))
    else
        icon:runAction(transition.sequence({
            cc.EaseOut:create(cc.MoveTo:create(1, cc.p(SeatPosition[toPositionId].x + (config.iconX or 0), SeatPosition[toPositionId].y + (config.iconY or 0))), 1),
            cc.DelayTime:create(config.delay or 0.1),
            cc.CallFunc:create(function()
                    icon:removeFromParent()
                    if not config.soundDelay then
                        nk.SoundManager:playHddjSound(hddjId)
                    end
                end)
        }))
    end

    if config.rotation then
        if SeatPosition[fromPositionId].x < SeatPosition[toPositionId].x then
            icon:rotateBy(1, 360 * config.rotation)
        else
            icon:rotateBy(1, -360 * config.rotation)
        end
    end

    local ani = display.newSprite():scale(config.scale or 1)
        :pos(SeatPosition[toPositionId].x + (config.x or 0), SeatPosition[toPositionId].y + (config.y or 0))
        :addTo(container)

    ani:playAnimationOnce(anim, true, function()
            completeCallback()
        end, 1 + (config.delay or 0.1))
    if config.soundDelay then
        ani:runAction(transition.sequence({
                cc.DelayTime:create(1 + (config.delay or 0.1) + config.soundDelay),
                cc.CallFunc:create(function()
                        nk.SoundManager:playHddjSound(hddjId)
                    end)
            }))
    end
end

function MatchHddjController:playTissue(fromPositionId, toPositionId, completeCallback)
    local tissueSpr = display.newSprite("#hddj_tissue.png")
        :pos(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y)
        :scale(1.4)
        :addTo(self.container_)
    local baseTime = 0.6
    tissueSpr:runAction(transition.sequence(
        {
            cc.EaseOut:create(cc.MoveTo:create(1, cc.p(SeatPosition[toPositionId].x - 40, SeatPosition[toPositionId].y)), 1),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                    nk.SoundManager:playHddjSound(10)
                end),
            cc.Repeat:create(
                transition.sequence(
                    {
                        cc.MoveTo:create(0.5, cc.p(SeatPosition[toPositionId].x + 40, SeatPosition[toPositionId].y)), 
                        cc.MoveTo:create(0.5, cc.p(SeatPosition[toPositionId].x - 40, SeatPosition[toPositionId].y)), 
                    }
                ), 
                3
            ), 
            cc.CallFunc:create(function ()
                completeCallback()
            end)
        }
    ))
    return tissueSpr
end

function MatchHddjController:playEgg(fromPositionId, toPositionId, completeCallback)
    local eggContainer = display.newNode():addTo(self.container_)
    local eggIconSpr = display.newSprite("#hddj_egg_icon.png")
        :scale(1.4)
        :pos(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y)
        :addTo(eggContainer)
    local distance = cc.pGetDistance(cc.p(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y), cc.p(SeatPosition[toPositionId].x, SeatPosition[toPositionId].y + 20))
    local config = {
        cc.p((SeatPosition[fromPositionId].x + SeatPosition[toPositionId].x) * 0.5, (SeatPosition[fromPositionId].y + SeatPosition[toPositionId].y + 20) * 0.5 + distance * 0.15),
        cc.p((SeatPosition[fromPositionId].x + SeatPosition[toPositionId].x) * 0.5, (SeatPosition[fromPositionId].y + SeatPosition[toPositionId].y + 20) * 0.5 + distance * 0.15),
        cc.p(SeatPosition[toPositionId].x, SeatPosition[toPositionId].y + 20)
    }

    eggIconSpr:runAction(transition.sequence({
        cc.EaseInOut:create(cc.BezierTo:create(1, config), 2),
        cc.CallFunc:create(function()
            eggIconSpr:removeFromParent()

            nk.SoundManager:playHddjSound(1)

            local eggSpr = display.newSprite("#hddj_egg.png")
                :pos(SeatPosition[toPositionId].x, SeatPosition[toPositionId].y + 20)
                :scale(1.4)
                :addTo(eggContainer)
            transition.scaleTo(eggSpr, {time = 1.5, scaleY = 1.2 * 1.4})
            transition.fadeOut(eggSpr, {time = 0.5, delay = 1})
            transition.moveTo(eggSpr, {
                time = 1.5, 
                y = SeatPosition[toPositionId].y - 30, 
                onComplete = function ()
                    completeCallback()
                end
            })
        end)
    }))
    if SeatPosition[fromPositionId].x < SeatPosition[toPositionId].x then
        eggIconSpr:rotateBy(1, 360 * 3)
    else
        eggIconSpr:rotateBy(1, -360 * 3)
    end
    return eggContainer
end

function MatchHddjController:playKiss(fromPositionId, toPositionId, completeCallback)
    local kissLipSpr = display.newSprite("#hddj_kiss_lip_icon.png")
        :pos(SeatPosition[fromPositionId].x, SeatPosition[fromPositionId].y)
        :scale(1.4)
        :addTo(self.container_)
    kissLipSpr:runAction(transition.sequence({
            cc.DelayTime:create(1.2),
            cc.CallFunc:create(function()
                nk.SoundManager:playHddjSound(4)
            end)
        }))
    kissLipSpr:runAction(transition.sequence({
        cc.EaseOut:create(cc.MoveTo:create(1, cc.p(SeatPosition[toPositionId].x, SeatPosition[toPositionId].y)), 1),
        cc.Repeat:create(
            transition.sequence(
                {
                    cc.ScaleTo:create(0.5, 1.4 * 1.4), 
                    cc.CallFunc:create(function ()
                        local kissHeartSpr = display.newSprite("#hddj_kiss_heart.png")
                            :pos(0, 0)
                            :scale(1.4)
                            :addTo(kissLipSpr)
                        local ptArr = {
                            cc.p(26, 20),
                            cc.p(26 - 4 * 1.4, 40),
                            cc.p(26 + 4 * 1.4, 60),
                            cc.p(26 - 4 * 1.4, 80)
                            -- cc.p(26 + 4 * 1.4, 100)
                        }

                        transition.execute(kissHeartSpr, cc.CatmullRomTo:create(0.8, ptArr), {
                            onComplete = function ()
                                kissHeartSpr:removeFromParent()
                            end
                        })
                    end), 
                    cc.ScaleTo:create(0.5, 1.4), 
                }
            ), 
            3
        ), 
        cc.CallFunc:create(function ()
            completeCallback()
        end)
    }))
    return kissLipSpr
end

return MatchHddjController