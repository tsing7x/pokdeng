--
-- Author: viking@boomegg.com
-- Date: 2014-09-12 10:27:04
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local DailyTasksPopup = class("DailyTasksPopup", function()
    return display.newNode()
end)

local DailyTasksListItem = import(".DailyTasksListItem")

DailyTasksPopup.WIDTH = 755 -- 750
DailyTasksPopup.HEIGHT = 485 -- 480

DailyTasksPopup.LOAD_TASK_LIST_ALREAD_EVENT_TAG = 99100
DailyTasksPopup.GET_REWARD_ALREAD_EVENT_TAG = 99101
DailyTasksPopup.ON_REWARD_ALREAD_EVENT_TAG = 99102

function DailyTasksPopup:ctor()
    display.addSpriteFrames("dailytasks.plist", "dailytasks.png")

    self:setupView()
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.LOAD_TASK_LIST_ALREAD, handler(self, self.loadDataCallback), DailyTasksPopup.LOAD_TASK_LIST_ALREAD_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.GET_RWARD, handler(self, self.onGetReward_), DailyTasksPopup.GET_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.GET_RWARD_ALREADY, handler(self, self.onGetRewardAlready_), DailyTasksPopup.ON_REWARD_ALREAD_EVENT_TAG)

    self:addNodeEventListener(cc.NODE_EVENT, function(event)
            if event.name == "exit" then
                    self:exit()
            end
       end)
end

function DailyTasksPopup:exit()
    display.removeSpriteFramesWithFile("dailytasks.plist", "dailytasks.png")
    bm.EventCenter:removeEventListenersByTag(DailyTasksPopup.LOAD_TASK_LIST_ALREAD_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(DailyTasksPopup.GET_REWARD_ALREAD_EVENT_TAG)
    bm.EventCenter:removeEventListenersByTag(DailyTasksPopup.ON_REWARD_ALREAD_EVENT_TAG)
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

function DailyTasksPopup:setupView()
    local width, height = DailyTasksPopup.WIDTH, DailyTasksPopup.HEIGHT

    --背景
    self.background_ = display.newScale9Sprite("#dailytasks_bg.png", 0, 0, cc.size(width, height)):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    local texPadding = 0
    display.newTilesSprite("repeat/dailytasks_repeat_tex.png", cc.rect(0, 0, width - texPadding, height - texPadding))
        :pos(-(width - texPadding) * 0.5, -(height - texPadding) * 0.5)
        :addTo(self)

    --顶部
    local titleMarginTop = 15
    local titleHeight = 65
    local titleIcon = display.newSprite("#dailytasks_title_icon.png"):addTo(self)
    titleIcon:pos(0, height/2 - titleIcon:getContentSize().height/2 + titleMarginTop)

    --内容
    local container = display.newNode():addTo(self)

    local bottomMargin = 15
    local contentPadding = 12
    local contentWidth = width - contentPadding * 2
    local contentHeight = height - titleHeight - bottomMargin

    --内容背景
    display.newScale9Sprite("#dailytasks_content_bg.png"):addTo(container):size(contentWidth, contentHeight):pos(0, height/2 - titleHeight - contentHeight/2)

    --内容列表
    self.listPosY_ = height/2 - titleHeight - contentHeight/2
    DailyTasksListItem.WIDTH = contentWidth
    self.taskListView = bm.ui.ListView.new({viewRect = cc.rect(-0.5 * contentWidth, -0.5 * contentHeight, contentWidth, contentHeight), 
                                direction = bm.ui.ListView.DIRECTION_VERTICAL}, DailyTasksListItem):addTo(container)
        :pos(0, self.listPosY_)

    self.taskListView.closePanel_ = function()
        -- body
        self:onClose()
    end
    self:getTasksListData()

    local padding = 15
    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed="#panel_black_close_btn_down.png"})
            :pos(width * 0.5 - padding, height * 0.5 - padding)
            :onButtonClicked(function()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                    self:close()
                end)
            :addTo(self)
end

function DailyTasksPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function DailyTasksPopup:close()
    nk.PopupManager:removePopup(self)
    return self
end

function DailyTasksPopup:onClose()
    self:close()
end

function DailyTasksPopup:onShowed()
    if self.taskListView then
        self.taskListView:setScrollContentTouchRect()
        self.taskListView:update()
    end
end

function DailyTasksPopup:getTasksListData()
    self:setLoading(true)
    bm.EventCenter:dispatchEvent(nk.DailyTasksEventHandler.GET_TASK_LIST)
end

function DailyTasksPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, self.listPosY_)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function DailyTasksPopup:loadDataCallback(evt)
    self:setLoading(false)
    -- dump(evt.data, "loadDataCallback.evt.data :=====================")
    self.taskListView:setData(evt.data)
end

function DailyTasksPopup:onGetReward_()
    self:setLoading(true)
end

function DailyTasksPopup:onGetRewardAlready_(evt)
    self:setLoading(false)
    self.taskListView:setData(nil)

    -- dump(evt.data, "onGetRewardAlready_.evt.data :=====================")
    self.taskListView:setData(evt.data)
end

return DailyTasksPopup