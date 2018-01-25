--
-- Author: viking@boomegg.com
-- Date: 2014-09-12 11:46:07
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local InvitePopup = import("app.module.friend.InviteRecallPopup")

local DailyTasksListItem = class("DailyTasksListItem", bm.ui.ListItem)

local DailyTask = import(".DailyTask")

DailyTasksListItem.WIDTH = 745
DailyTasksListItem.HEIGHT = 95

local labelSize = 22
local labelColor = cc.c3b(0xfe, 0xcb, 0x7b)
local buttonSize = 26
local buttonColor = cc.c3b(0x88, 0x31, 0x25)
local progressSize = 18
local progressColor = cc.c3b(0x2b, 0x12, 0x0d)

function DailyTasksListItem:ctor()
    self:setNodeEventEnabled(true)
    DailyTasksListItem.super.ctor(self, DailyTasksListItem.WIDTH, DailyTasksListItem.HEIGHT)

    local width, height = DailyTasksListItem.WIDTH, DailyTasksListItem.HEIGHT

    --图标
    self.iconWidth, self.iconHeight = 76, 76
    local iconMarginTop, iconMarginLeft = 10, 10
    self.icon = display.newSprite("#dailytasks_default_icon.png"):addTo(self):scale(0.8):pos(self.iconWidth/2 + iconMarginLeft, self.iconHeight/2 + iconMarginTop)

    self.iconLoaderId_ = nk.ImageLoader:nextLoaderId() -- 图标加载id

    --名称
    self.nameLabel = display.newTTFLabel({
            size = labelSize,
            color = labelColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self)
    self.nameLabel:setAnchorPoint(cc.p(0, 0))

    --描述
    self.descLabel = display.newTTFLabel({
            size = labelSize,
            color = labelColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self)
    self.descLabel:setAnchorPoint(cc.p(0, 0))

    --奖励
    self.rewardLabel = display.newTTFLabel({
            size = labelSize,
            color = labelColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self)
    self.rewardLabel:setAnchorPoint(cc.p(0, 0.5))

    --进度
    local progressWidth = 130
    local progressHeight = 20
    local progressMarginRight = 182
    local progressHeightAdjust = 20
    self.progress = nk.ui.ProgressBar.new(
        "#dailytasks_progress_bg.png", 
        "#dailytasks_progress_second.png", 
        {
            bgWidth = progressWidth, 
            bgHeight = progressHeight, 
            fillWidth = progressHeight, 
            fillHeight = progressHeight - 2
        }
    ):addTo(self):setValue(0.0)
    self.progress:setAnchorPoint(cc.p(1, 0.5))
    self.progress:pos(width - progressWidth - progressMarginRight, height/2 - progressHeightAdjust)

    --进度文字 
    self.progressLabel = display.newTTFLabel({
            size = progressSize,
            color = progressColor,
            align = ui.TEXT_ALIGN_CENTER
        }):addTo(self.progress):pos(progressWidth/2, 0) 

    -- 奖励按钮
    -- local buttonWidth = 150
    -- local buttonHeight = 50
    -- self.rewardButton = cc.ui.UIPushButton.new({normal = "#dailytasks_button_icon.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
    --     :setButtonLabel(display.newTTFLabel({
    --         text = bm.LangUtil.getText("DAILY_TASK", "GET_REWARD"), 
    --         size = buttonSize, 
    --         color = buttonColor, 
    --         align = ui.TEXT_ALIGN_CENTER}))
    --     :onButtonClicked(buttontHandler(self, self.onGetReward_))
    --     :addTo(self)
    --     :pos(width - buttonWidth/2 - progressMarginRight, height/2)
    --     :setButtonSize(buttonWidth, buttonHeight)
    --     :hide()

    -- --已经完成
    -- self.finishLabel = display.newTTFLabel({
    --         text = bm.LangUtil.getText("DAILY_TASK", "HAD_FINISH"), 
    --         size = buttonSize, 
    --         color = buttonColor, 
    --         align = ui.TEXT_ALIGN_CENTER,
    --         valign = ui.TEXT_VALIGN_CENTER,
    --         dimensions = cc.size(buttonWidth, buttonHeight)
    --     })
    --     :addTo(self)
    --     :pos(width - buttonWidth/2 - progressMarginRight, height/2)
    --     :hide()

    -- 新的领奖按钮 --
    local getRewardBtnSize = {
        width = 152,
        height = 52
    }
    
    local getRewardBtnMagrinRight = 15
    self.getRewardBtn = cc.ui.UIPushButton.new({normal = "#dailytasks_btnYellow.png", pressed = "#dailytasks_btnYellow.png",
        disabled = "#dailytasks_btnGrey.png"}, {scale9 = true})
        :setButtonSize(getRewardBtnSize.width, getRewardBtnSize.height)
        :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DAILY_TASK", "GO_FINISH"), size = buttonSize, color = buttonColor, align = ui.TEXT_ALIGN_CENTER}))
        :pos(width - getRewardBtnSize.width / 2 - getRewardBtnMagrinRight, height / 2)
        :onButtonClicked(buttontHandler(self, self.onGetReward_))
        :addTo(self)

    -- 默认不可领取  0: 进行中, 1:可领奖, 2:已完成--
    self.rewardState = 0
    --分割线
    local dividerWidth, dividerHeight = width - 4, 2
    display.newScale9Sprite("#dailytasks_divider.png", dividerWidth/2, -dividerHeight/2)
        :addTo(self)
        :size(dividerWidth, dividerHeight)
end

function DailyTasksListItem:onDataSet(dataChanged, data)
    if dataChanged then
        -- print("onDataSet:", data.iconUrl, data.progress, data.target, data.id)
        self.task = data
        local width, height = DailyTasksListItem.WIDTH, DailyTasksListItem.HEIGHT

        -- local h = self.iconHeight

        nk.ImageLoader:loadAndCacheImage(
                self.iconLoaderId_, 
                data.iconUrl, 
                handler(self, self.onIconLoadComplete_)
            )

        --名称
        local iconMarginLeft = 10
        local nameLabelOriginX = 0 + iconMarginLeft + self.iconWidth
        local nameLabelMarginLeft = 10
        local nameLabelMarginTop = 5
        self.nameLabel:setString(data.name)
        self.nameLabel:pos(nameLabelOriginX + nameLabelMarginLeft, height/2 + nameLabelMarginTop)

        --描述
        local nameLabelSize = self.nameLabel:getContentSize()
        local descLabelMarginTop = 10
        self.descLabel:setString(data.desc)
        self.descLabel:pos(nameLabelOriginX + nameLabelMarginLeft, height/2 + nameLabelMarginTop - nameLabelSize.height - descLabelMarginTop)

        --奖励
        local descLabelSize = self.descLabel:getContentSize()
        local rewardLabelOriginX = nameLabelOriginX + nameLabelMarginLeft + 300
        local rewardLabelMarginLeft = 14
        local rewardLabelPosYShift = 20
        self.rewardLabel:setString(data.rewardDesc)
        self.rewardLabel:pos(rewardLabelOriginX + rewardLabelMarginLeft, height / 2 + rewardLabelPosYShift)

        self.progress:setValue(data.progress / data.target)
        self.progressLabel:setString(data.progress .. "/" .. data.target)

        if data.status ==  DailyTask.STATUS_UNDER_WAY then
            -- self.rewardButton:hide()
            -- self.finishLabel:hide()

            self.rewardState = 0
            self.getRewardBtn:setButtonImage("normal", "#dailytasks_btnYellow.png")
            self.getRewardBtn:setButtonImage("pressed", "#dailytasks_btnYellow.png")
            self.getRewardBtn:getButtonLabel():setString(bm.LangUtil.getText("DAILY_TASK", "GO_FINISH"))
            if data.progress == 0 then
                self.progress.fill_:hide()
            end
        elseif data.status ==  DailyTask.STATUS_CAN_REWARD then
            -- self.rewardButton:show()
            -- self.finishLabel:hide()
            -- self.progress:hide()

            self.rewardState = 1
            self.getRewardBtn:setButtonImage("normal", "#dailytasks_btnGreen.png")
            self.getRewardBtn:setButtonImage("pressed", "#common_btnGreenCor_pre.png")
            self.getRewardBtn:getButtonLabel():setString(bm.LangUtil.getText("DAILY_TASK", "GET_REWARD"))
        elseif data.status ==  DailyTask.STATUS_FINISHED then
            -- self.rewardButton:hide()
            -- self.finishLabel:show()
            -- self.progress:hide()

            self.rewardState = 2
            self.getRewardBtn:setButtonEnabled(false)
            self.getRewardBtn:getButtonLabel():setString(bm.LangUtil.getText("DAILY_TASK", "HAD_FINISH"))
        end


        --icon
        if self.tagIcon_ then
            self.tagIcon_:removeFromParent()
        end
        if data.tag == 1 then
            local iconPosX,iconPosY = self.icon:getPosition()
            local iconSize = self.icon:getContentSize()
            self.tagIcon_ = display.newSprite("store_label_hot.png")
            :align(display.LEFT_TOP)
            :pos(iconPosX-iconSize.width/2+2,iconPosY+iconSize.height/2-2)
            :addTo(self)
        end
    end
end

function DailyTasksListItem:onIconLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.icon:setTexture(tex)
        self.icon:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.icon:setScaleX(self.iconWidth / texSize.width)
        self.icon:setScaleY(self.iconHeight / texSize.height)
    end
end

function DailyTasksListItem:onGetReward_()
    -- print("DailyTasksListItem:onGetReward_")
    if self.rewardState == 0 then
        --todo
        local getBtnActionByTaskType = {
            ["wins"] = function()
                -- body

                nk.server:quickPlay()
                self.owner_.closePanel_()
            end,

            ["middleWins"] = function()
                -- body
            end,

            ["seniorWins"] = function()
                -- body
            end,

            ["pokers"] = function()
                -- body
                nk.server:quickPlay()
                self.owner_.closePanel_()
            end,

            ["invites"] = function()
                -- body
                InvitePopup.new():show()
                self.owner_.closePanel_()
                -- if device.platform == "android" or device.platform == "ios" then
                --     cc.analytics:doCommand{command = "event",
                --                 args = {eventId = "hall_Invite_friends", label = "user hall_Invite_friends"}}
                                
                -- end
            end,

            ["invitesucc"] = function()
                -- body
                InvitePopup.new():show()
                self.owner_.closePanel_()
                -- if device.platform == "android" or device.platform == "ios" then
                --     cc.analytics:doCommand{command = "event",
                --                 args = {eventId = "hall_Invite_friends", label = "user hall_Invite_friends"}}
                                
                -- end
            end,

            ["beGrabDealer"] = function()
                -- body
                local currentViewType = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
                local HallController = import("app.module.hall.HallController")

                if nk.runningScene.name == "HallScene" then
                    --todo
                    local roomLevel = nk.getRoomLevelByMoney(nk.userData["aUser.money"])

                    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = {gameLevel = roomLevel}})
                    self.owner_.closePanel_()
                    -- if currentViewType == HallController.MAIN_HALL_VIEW then
                    --     --todo

                    -- elseif currentViewType == HallController.CHOOSE_NOR_VIEW then
                    --     --todo
                    -- elseif currentViewType == HallController.CHOOSE_MATCH_NOR_VIEW then
                    --     --todo
                    -- end
                elseif nk.runningScene.name == "RoomScene" then
                    --todo

                    -- 暂未有房间内场景 任务跳转,待完善！
                    -- Exit Game Nor in Room && GoGrabDealerQuickPlay
                    -- if nk.runningScene.controller.model:isSelfInGame() then
                    --     --todo
                    --     nk.ui.Dialog.new({
                    --         messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    --         hasCloseButton = false,
                    --         callback = function (type)
                    --             if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                    --                 -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                    --                 -- nk.userData.DEFAULT_TAB = 2

                    --                 if nk.runningScene and nk.runningScene.doBackToHall then
                    --                     --todo
                    --                     nk.server:logoutRoom()
                    --                     nk.runningScene:doBackToHall()
                    --                 end

                    --                 -- 待测,直接发送会不会出现视图错误
                    --                 bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = nil}) 
                    --             end
                    --         end
                    --     }):show()
                    -- else
                    --     -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                    --     -- nk.userData.DEFAULT_TAB = 2

                    --     if nk.runningScene and nk.runningScene.doBackToHall then
                    --         --todo
                    --         nk.server:logoutRoom()
                    --         nk.runningScene:doBackToHall()
                    --     end

                    --     -- 待测,直接发送会不会出现视图错误
                    --     bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = nil})
                    -- end
                elseif nk.runningScene.name == "MatchRoomScene" then
                    --todo
                    -- 暂未有比赛场场景任务跳转,待完善！
                    -- Exit Game Match in Room && GoGrabDealerQuickPlay


                elseif nk.runningScene.name == "GrabDealerRoomScene" then
                    --todo
                    -- Do Nothing.
                end
            end,

            ["cashGame"] = function()
                -- body
                local currentViewType = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
                local HallController = import("app.module.hall.HallController")

                if nk.runningScene.name == "HallScene" then
                    --todo
                    if currentViewType == HallController.MAIN_HALL_VIEW then
                        --todo
                        nk.userData.DEFAULT_TAB = 2
                        nk.runningScene.controller_.view_:onNorHallClick()

                    elseif currentViewType == HallController.CHOOSE_NOR_VIEW then
                        --todo
                        local chooseCashViewTab = 2
                        nk.runningScene.controller_.view_.mainTabBar_:gotoTab(chooseCashViewTab)
                    elseif currentViewType == HallController.CHOOSE_MATCH_NOR_VIEW then
                        --todo
                        -- 暂未有,待处理！可能有问题.

                        -- nk.userData.DEFAULT_TAB = 3
                        -- nk.runningScene.controller_.view_:onNorHallClick()
                    end

                    self.owner_.closePanel_()
                elseif nk.runningScene.name == "RoomScene" then
                    --todo
                elseif nk.runningScene.name == "MatchRoomScene" then
                    --todo
                elseif nk.runningScene.name == "GrabDealerRoomScene" then
                    --todo
                end
            end,

            ["matchGame"] = function()
                -- body
                local currentViewType = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
                local HallController = import("app.module.hall.HallController")

                if nk.runningScene.name == "HallScene" then
                    --todo
                    if currentViewType == HallController.MAIN_HALL_VIEW then
                        --todo
                        nk.runningScene.controller_.view_:onMatchHallClick()

                    elseif currentViewType == HallController.CHOOSE_NOR_VIEW then
                        --todo
                        nk.runningScene.controller_:showMainHallView()
                        nk.runningScene.controller_.view_:onMatchHallClick()

                    elseif currentViewType == HallController.CHOOSE_MATCH_NOR_VIEW then
                        --todo
                        -- Do Nothing.
                    end
                    
                    self.owner_.closePanel_()
                elseif nk.runningScene.name == "RoomScene" then
                    --todo
                elseif nk.runningScene.name == "MatchRoomScene" then
                    --todo
                elseif nk.runningScene.name == "GrabDealerRoomScene" then
                    --todo
                end
            end,

            ["recallFriends"] = function()
                -- body
                InvitePopup.new(nil, 2):show()
                self.owner_.closePanel_()
            end
        }

        if self.task.dailyType and getBtnActionByTaskType[self.task.dailyType] then
            --todo
            getBtnActionByTaskType[self.task.dailyType]()
        end

    elseif self.rewardState == 1 then
        --todo
        bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.GET_RWARD, data = self.task})
    end
end

function DailyTasksListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.iconLoaderId_)
end

return DailyTasksListItem