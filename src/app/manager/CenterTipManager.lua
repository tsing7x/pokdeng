--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-12-25 16:42:17
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: CenterTipManager By tsing.
--

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local DEFAULT_STAY_TIME = 3
local X_GAP = 100
local Y_GAP = 0
local TIP_HEIGHT = 72
local LABEL_X_GAP = 16
local ICON_SIZE = 56
local LABEL_ROLL_VELOCITY = 80
local BG_CONTENT_SIZE = cc.size(display.width - X_GAP * 2, TIP_HEIGHT)
local Z_ORDER = 1001
local CenterTipManager = class("CenterTipManager")

function CenterTipManager:ctor()
	-- body
	self.container_ = display.newNode()
	self.container_:retain()
    self.container_:setNodeEventEnabled(true)

    self.waitQueue_ = {}
    self.isPlaying_ = false
end

function CenterTipManager:showCenterTip(tipData)
	-- body
	assert(type(tipData) == "table" or type(tipData) == "string", "tipData should be a table")
    if not self.tipBg_ then
        -- 背景
        self.tipBg_ = display.newScale9Sprite("#top_tip_bg.png", 0, 0, BG_CONTENT_SIZE)
            :addTo(self.container_)

        -- 小的裁剪模板（文本 + 图标）
        self.smallStencil_ = display.newDrawNode()
        self.smallStencil_:drawPolygon({
            {-BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP * 2 + ICON_SIZE, -BG_CONTENT_SIZE.height * 0.5}, 
            {-BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP * 2 + ICON_SIZE,  BG_CONTENT_SIZE.height * 0.5}, 
            { BG_CONTENT_SIZE.width * 0.5 - LABEL_X_GAP,  BG_CONTENT_SIZE.height * 0.5}, 
            { BG_CONTENT_SIZE.width * 0.5 - LABEL_X_GAP, -BG_CONTENT_SIZE.height * 0.5}
        })
        self.smallStencil_:retain()

        -- 大的裁剪模板（文本）
        self.bigStencil_ = display.newDrawNode()
        self.bigStencil_:drawPolygon({
            {-BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP, -BG_CONTENT_SIZE.height * 0.5}, 
            {-BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP,  BG_CONTENT_SIZE.height * 0.5}, 
            { BG_CONTENT_SIZE.width * 0.5 - LABEL_X_GAP,  BG_CONTENT_SIZE.height * 0.5}, 
            { BG_CONTENT_SIZE.width * 0.5 - LABEL_X_GAP, -BG_CONTENT_SIZE.height * 0.5}
        })
        self.bigStencil_:retain()

        -- 裁剪容器
        self.clipNode_ = cc.ClippingNode:create():addTo(self.container_)
        self.clipNode_:setStencil(self.bigStencil_)

        -- 文本
        self.label_ = display.newTTFLabel({text = "", size = 28, align = ui.TEXT_ALIGN_CENTER})
            :addTo(self.clipNode_)
    end

    if type(tipData) == "string" then
        -- 过滤重复的消息
        for _, v in pairs(self.waitQueue_) do
            if v.text == tipData then
                return
            end
        end
        table.insert(self.waitQueue_, {text = tipData})
    else
        -- 过滤重复的消息
        for _, v in pairs(self.waitQueue_) do
            if v.text == tipData.text then
                return
            end
        end
        if tipData.image and type(tipData.image) == "userdata" then
            tipData.image:retain()
        end
        table.insert(self.waitQueue_, tipData)
    end
    
    if not self.isPlaying_ then
        self:playNext_()
    end
end

function CenterTipManager:playNext_()
	-- body
	if self.waitQueue_[1] then
        self.currentData_ = table.remove(self.waitQueue_, 1)
    else
        -- 播放完毕
        self.isPlaying_ = false
        return
    end

    -- 设置文本和图标
    local tipData = self.currentData_
    local scrollTime = 0
    if tipData.text then
        self.label_:setString(tipData.text)
        local labelWidth = self.label_:getContentSize().width
        local startXPos = 0
        if tipData.image and type(tipData.image) == "userdata" then
            tipData.image:pos(LABEL_X_GAP + ICON_SIZE * 0.5 - BG_CONTENT_SIZE.width * 0.5 , 0):addTo(self.container_)
            -- 设置对应的裁剪模板
            self.clipNode_:setStencil(self.smallStencil_)
            -- 计算文本滚屏时间
            scrollTime = (labelWidth - (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2 - LABEL_X_GAP - ICON_SIZE)) / LABEL_ROLL_VELOCITY
            if scrollTime > 0 then
                startXPos = labelWidth * 0.5 - BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP + LABEL_X_GAP + ICON_SIZE
                self.label_:pos(startXPos, 0)
                transition.execute(self.label_, cc.MoveTo:create(scrollTime, cc.p(-startXPos + LABEL_X_GAP + ICON_SIZE, 0)), {delay = 1.5})
            else
                scrollTime = 0
                self.label_:pos((LABEL_X_GAP * 2 + ICON_SIZE) * 0.5, 0)
            end
        else
            -- 设置对应的裁剪模板
            self.clipNode_:setStencil(self.bigStencil_)
            -- 计算文本滚屏时间
            scrollTime = (labelWidth - (BG_CONTENT_SIZE.width - LABEL_X_GAP * 2)) / LABEL_ROLL_VELOCITY
            if scrollTime > 0 then
                startXPos = labelWidth * 0.5 - BG_CONTENT_SIZE.width * 0.5 + LABEL_X_GAP
                self.label_:pos(startXPos, 0)
                transition.execute(self.label_, cc.MoveTo:create(scrollTime, cc.p(-startXPos, 0)), {delay = DEFAULT_STAY_TIME * 0.5})
            else
                scrollTime = 0
                self.label_:pos(0, 0)
            end
        end
    end    

    -- 下滑动画
    self.isPlaying_ = true
    self.container_:pos(display.cx, display.cy)
        :addTo(nk.runningScene, Z_ORDER)
        -- :moveTo(0.3, display.cx, display.top - Y_GAP - TIP_HEIGHT * 0.5)

    -- 移除tip定时器
    self.delayScheduleHandle_ = scheduler.performWithDelayGlobal(handler(self, self.delayCallback_), 0.3 + DEFAULT_STAY_TIME + scrollTime)

    local getFrame = display.newSpriteFrame
    if tipData.messageType == 1000 then
        self.label_:setTextColor(cc.c3b(0xff, 0xae, 0x70))
        self.tipBg_:setSpriteFrame(getFrame("common-da-laba-top-tip-icon.png"))
        self.tipBg_:setContentSize(display.width - X_GAP * 2, TIP_HEIGHT)
    else
        self.label_:setTextColor(cc.c3b(0xff, 0xff, 0xff))
        self.tipBg_:setSpriteFrame(getFrame("top_tip_bg.png"))
        self.tipBg_:setContentSize(display.width - X_GAP * 2, TIP_HEIGHT)
    end
end

function CenterTipManager:delayCallback_()
	-- body
	self.delayScheduleHandle_ = nil
	self:onHideComplete_()
    -- if self.container_:getParent() then
    --     transition.moveTo(self.container_, {
    --         x = display.cx, 
    --         y = display.top + TIP_HEIGHT * 0.5, 
    --         time = 0.3, 
    --         onComplete = handler(self, self.onHideComplete_), 
    --     })
		
    -- else
    --     self.container_:pos(display.cx, display.top + TIP_HEIGHT * 0.5)
    --     self:onHideComplete_()
    -- end
end

function CenterTipManager:cleanup()
    -- body
    if self.currentData_ and self.currentData_.image and type(self.currentData_.image) == "userdata" then
        self.currentData_.image:release()
        self.currentData_.image:removeFromParent()
    end

    -- 移除定时器
    if self.delayScheduleHandle_ then
        scheduler.unscheduleGlobal(self.delayScheduleHandle_)
        self.delayScheduleHandle_ = nil
    end

    -- 延迟一秒播放下一条
    scheduler.performWithDelayGlobal(function ()
        self:playNext_()
    end, 1)
    -- print("container removed")
end

function CenterTipManager:onHideComplete_()
	-- body
	self.container_:removeFromParent()
    self:cleanup()
end

return CenterTipManager