--
-- Author: Devin
-- Date: 2014-10-09 15:34:33
-- 更新展现界面

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local upd = require("update.init")

local UpdateView = class("UpdateView", function ()
    return display.newNode()
end)

local DOTS_NUM         = 30
local LOGO_RADIUS      = 94
local LOGO_POS_X = display.cx - 300
local LOGO_POS_Y = 0
local LOGO_SCALE = 1

local PRO_POS_X = display.cx - 260
local PRO_POS_Y = - display.cy + 133
local PRO_WIDTH = 450
local PRO_HEIGHT = 12

function UpdateView:ctor(scaleNum)
    self:setNodeEventEnabled(true)
    -- 背景
    display.newSprite("main_hall_bg.jpg")
        :scale(scaleNum)
        :addTo(self, 0)

    display.addSpriteFrames("update_texture.plist", "update_texture.png")

    self.tableNode_ = display.newNode()
        :addTo(self)

    local gameTable = display.newSprite("#login_game_table.png")
        :scale(scaleNum)
        :addTo(self.tableNode_)
    local tableWidth = gameTable:getContentSize().width
    if display.width * 0.75 > tableWidth then
        self.visibleTableWidth_ = tableWidth
        gameTable:align(display.LEFT_CENTER, display.cx - tableWidth, 0)
    else
        self.visibleTableWidth_ = display.width * 0.75
        gameTable:align(display.LEFT_CENTER, - display.cx * 0.5, 0)
    end
    self.tableNode_:pos(- display.cx + self.visibleTableWidth_ - 200, 0)

    self.logoBatchNode_ = display.newBatchNode("update_texture.png")
        :addTo(self.tableNode_)
    -- 圆点
    self.dots_ = {}
    for i = 1, DOTS_NUM do
        self.dots_[i] = display.newSprite("#login_rotary_dot.png")
            :pos(LOGO_POS_X + math.sin((i - 1) * math.pi / 15) * LOGO_RADIUS * LOGO_SCALE, LOGO_POS_Y +
                math.cos((i - 1) * math.pi / 15) * LOGO_RADIUS * LOGO_SCALE)
            :opacity(0)
            :addTo(self.logoBatchNode_)
    end
    
    local logPosAdjust = {
        x = 0,
        y = - 14
    }

    -- 游戏logo
    display.newSprite("#game_logo.png")
        :pos(LOGO_POS_X + logPosAdjust.x, LOGO_POS_Y - logPosAdjust.y)
        :addTo(self.logoBatchNode_)
        :scale(LOGO_SCALE)

    --进度条
    PRO_WIDTH = PRO_WIDTH * scaleNum
    self.progress = display.newScale9Sprite("#update_proBg.png")
    self.progress:addTo(self)
    self.progress:pos(PRO_POS_X, PRO_POS_Y)
    self.progress:setContentSize(cc.size(PRO_WIDTH, PRO_HEIGHT))
    self.progressBar = display.newScale9Sprite("#update_proBar.png"):addTo(self.progress)
    self.progressBar:setAnchorPoint(0, 0.5)
    self.progressBar:setPosition(0, PRO_HEIGHT / 2)
    self.prolight = display.newSprite("#update_Prolight.png")
    self.prolight:setAnchorPoint(0, 0.5)
    self.prolight:addTo(self.progressBar)

    self.progressLabel = display.newTTFLabel({text = "", size = 21, color = cc.c3b(255, 255, 255), align = ui.TEXT_ALIGN_CENTER,
            x = PRO_POS_X, y = PRO_POS_Y + 30})
    self:addChild(self.progressLabel)

    self.speedLabel = display.newTTFLabel({text = "", size = 18, color = cc.c3b(81, 169, 236), align = ui.TEXT_ALIGN_LEFT,
            x = PRO_POS_X - PRO_WIDTH/2, y = PRO_POS_Y - 20})
    self:addChild(self.speedLabel)

    self.totalLabel = display.newTTFLabel({text = "", size = 18, color = cc.c3b(81, 169, 236), align = ui.TEXT_ALIGN_RIGHT,
            x = PRO_POS_X + PRO_WIDTH/2, y = PRO_POS_Y - 30})
    self:addChild(self.totalLabel)
    self:setProgress(0)

    -- copyright
    self.copyrightLabel_ = display.newTTFLabel({text = upd.lang.getText("UPDATE", "COPY_RIGHT"), color = cc.c3b(0x00, 0x6d, 0x32), 
        size = 18, align = ui.TEXT_ALIGN_RIGHT})
        :align(display.RIGHT_BOTTOM, display.cx - 104, - (display.cy - 4))
        :addTo(self)

    -- poker girl
    display.addSpriteFrames("girl_texture.plist","girl_texture.png")
    self.pokerGirlBatchNode_ = display.newBatchNode("girl_texture.png")
        :addTo(self)
    display.newSprite("#poker_girl.png")
        :addTo(self.pokerGirlBatchNode_)
        :schedule(handler(self, self.pokerGirlBlink_), 5)
    self.pokerGirlBatchNode_:pos(- display.cx / 2 + 48, 0):scale(scaleNum)

    self.versionLabel = display.newTTFLabel({text = "V1.0.0.0", color = cc.c3b(0x00, 0x6d, 0x32), size = 18, align = ui.TEXT_ALIGN_RIGHT})
        :align(display.RIGHT_BOTTOM, display.cx - 3, -(display.cy - 4))
        :addTo(self)

    self:playDotsAnim()
end

-- poker girl眨眼动画
function UpdateView:pokerGirlBlink_()
    local blinkSpr = display.newSprite("#poker_girl_blink_half.png")
        :pos(- 31.4, 235.8)
        :addTo(self.pokerGirlBatchNode_)
    blinkSpr:performWithDelay(function ()
        blinkSpr:setSpriteFrame(display.newSpriteFrame("poker_girl_blink_all.png"))
    end, 0.05)  -- 0.05
    blinkSpr:performWithDelay(function ()
        blinkSpr:setSpriteFrame(display.newSpriteFrame("poker_girl_blink_half.png"))
    end, 0.15) -- 0.15
    blinkSpr:performWithDelay(function ()
        blinkSpr:removeFromParent()
    end, 0.20) -- 0.20
end

--资源总大小文本框
function UpdateView:setTotalLabel(total)
    self.totalLabel:setString(upd.lang.getText("UPDATE", "DOWNLOAD_SIZE", total))
    self.totalLabel:pos(PRO_POS_X + PRO_WIDTH / 2 - self.totalLabel:getContentSize().width / 2, PRO_POS_Y - 20)
end

--tips文字
function UpdateView:setTipsLabel(msg)
    self.progressLabel:setVisible(true)
    self.progressLabel:setString(msg)
end

--设置版本号
function UpdateView:setVersion(version)
    if version and #(string.split(version, ".")) == 3 then
        version = version .. ".0"
    end
    self.versionLabel:setString("V" .. version)
    self.copyrightLabel_:align(display.RIGHT_BOTTOM, display.cx - 6 - self.versionLabel:getContentSize().width, - (display.cy - 4))
end

--设置进度条是否可见
function UpdateView:setBarVisible(bool)
    self.progress:setVisible(bool)
    self.progressLabel:setVisible(bool)
    self.speedLabel:setVisible(bool)
    self.totalLabel:setVisible(bool)
end

--设置进度条，坐标为左对齐
local lastProNum
local lastSpeed
function UpdateView:setProgress(proNum,speed)

    self.proLines = {}

    if proNum > 1 then
        proNum = 1
    end
    if speed ~= lastSpeed then
        lastSpeed = speed
        if speed then
            self.speedLabel:setString(upd.lang.getText("UPDATE", "SPEED", speed))
            self.speedLabel:pos(PRO_POS_X - PRO_WIDTH/2 + self.speedLabel:getContentSize().width/2,PRO_POS_Y - 20)
        end
    end
    if lastProNum == proNum then
        return
    end
    lastProNum = proNum
    if proNum > 0 then
        self:setTipsLabel(upd.lang.getText("UPDATE", "DOWNLOAD_PROGRESS", checkint(proNum * 100)))
    else
        --self:setTipsLabel("")
    end

    local wid = PRO_WIDTH*proNum
    if proNum <= 0 then
        self.progressBar:setVisible(false)
        return
    else
        self.progressBar:setVisible(true)
        if wid <= 36 then
            self.prolight:pos(19,6)
        else
            self.prolight:pos(wid - 17, 6)
        end
    end

    local curLines = checkint((wid - 15)/27)
    local lines = #self.proLines
    if curLines > #self.proLines then
        lines = curLines
    end
    for i = 1,lines do
        if curLines>=i then
            if not self.proLines[i] then
                self.proLines[i] = display.newSprite("#update_ProLines.png")
                self.proLines[i]:setAnchorPoint(0,0)
                self.proLines[i]:addTo(self.progressBar)
            end

            self.proLines[i]:pos(27*(i - 1) + 15, 0)
        elseif self.proLines[i] then
            self.proLines[i]:removeFromParent()
            self.proLines[i] = nil
        end
    end
    if wid <= 36 then
        wid = 36
    end
    self.progressBar:setContentSize(cc.size(wid,PRO_HEIGHT))
end

function UpdateView:playDotsAnim()
    self:stopDotsAnim_()
    self.firstDotId_ = 1
    self.dotsSchedulerHandle_ = scheduler.scheduleGlobal(handler(self, function (obj)

        if obj and obj.dots_ then
            --todo
            obj.dots_[obj.firstDotId_]:runAction(transition.sequence({cc.FadeTo:create(0.3, 255), cc.FadeTo:create(0.3, 32)}))

            local secondDotId = obj.firstDotId_ + DOTS_NUM * 0.5
            if secondDotId > DOTS_NUM then
                secondDotId = secondDotId - DOTS_NUM
            end
            
            obj.dots_[secondDotId]:runAction(transition.sequence({cc.FadeTo:create(0.3, 255), cc.FadeTo:create(0.3, 32)}))
            obj.firstDotId_ = obj.firstDotId_ + 1

            if obj.firstDotId_ > DOTS_NUM then
                obj.firstDotId_ = 1
            end
        end
    end), 0.05)
end

function UpdateView:stopDotsAnim_()
    for _, dot in ipairs(self.dots_) do
        dot:opacity(0)
        dot:stopAllActions()
    end

    if self.dotsSchedulerHandle_ then
        scheduler.unscheduleGlobal(self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
end

function UpdateView:playLeaveScene(callback)
    self.progressLabel:setVisible(false)
    transition.moveTo(self.tableNode_, {x = display.right + display.width * 0.5, time = 0.5, onComplete = callback})
end

function UpdateView:onEnter()
    -- body
end

function UpdateView:onExit()
    -- body
end

function UpdateView:onCleanup()
    self:stopDotsAnim_()
    if self.dotsSchedulerHandle_ then
        scheduler.unscheduleGlobal(self.dotsSchedulerHandle_)
        self.dotsSchedulerHandle_ = nil
    end
end

return UpdateView