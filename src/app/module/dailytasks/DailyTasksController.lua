--
-- Author: viking@boomegg.com
-- Date: 2014-09-12 11:59:00
--

local DailyTasksController = class("DailyTasksController")

local DailyTasksDB = import(".DailyTasksDB")
local DailyTask = import(".DailyTask")

local Types = {
    "wins", "middleWins", "seniorWins", "pokers", "invites", "invitesucc", "beGrabDealer",
    "cashGame", "matchGame", "recallFriends"
}

function DailyTasksController:ctor()
    self.taskMap = {}
    self.taskProgressMap = {}
    self.allTaskList = {}
    self.finishTaskCount = 0
    self.progressReady = false
    self.taskReady = false

    self.dbHelper = DailyTasksDB.new()
end

function DailyTasksController:isReady()
    return self.progressReady and self.taskReady
end

function DailyTasksController:setData()
    self.taskMap = nil
    self.taskProgressMap = nil
    self.allTaskList = nil
    self.taskMap = {}
    self.taskProgressMap = {}
    for _, v in ipairs(Types) do
        if not self.taskProgressMap[v] then
            rawset(self.taskProgressMap, v, 0)
        end
    end

    self.finishTaskCount = 0
    self.progressReady = false
    self.taskReady = false    
    self.schedulerPool = bm.SchedulerPool.new()
    self.isBusy = false

    self.schedulerPool:delayCall(function()
        self:getTasksListData(true)
    end, 0.5)
end

function DailyTasksController:getTasksListData(init)
    if  not self.isBusy then
        self.isBusy = true
        self.allTaskList = nil
        self.allTaskList = {}

        self:setProgressFromDB()

        nk.http.getDailyTaskInfo(
            function(retData)
                if retData then
                    -- dump(retData, "getDailyTaskInfo.retData :==================")
                    self:setTaskDataFromJSONObject(retData, init)
                end
            end,
            function(errData)
                dump(errData, "getDailyTaskInfo.errData :==================")
                if not init then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end)

    end
end

function DailyTasksController:setProgressFromDB()
    self.dbHelper:readFromDB(self.taskProgressMap)
    self.progressReady = true
    -- print("self.progressReady", self.progressReady)
end


function DailyTasksController:sortTaskDataList(list)
    table.sort(list,function(t1,t2)
        return t1.sort < t2.sort
    end)
end

function DailyTasksController:setTaskDataFromJSONObject(list, init)
    -- print("setTaskDataFromJSONObject:")

    
    self:processProperty(list, "wins")
    -- self:processProperty(list, "middleWins")--中级场胜利次数
    -- self:processProperty(list, "seniorWins")
    self:processProperty(list, "pokers")--玩牌局数
    self:processProperty(list, "beGrabDealer")  -- 上庄场当庄
    self:processProperty(list, "cashGame")  -- 现金币场玩牌
    self:processProperty(list, "matchGame")  -- 参加比赛
    self:processProperty(list, "recallFriends")  -- 好友召回
    -- self:processProperty(list, "pays")--支付任务
    self:processProperty(list, "invites")--邀请任务
    -- self:processProperty(list, "props")--互动道具任务
    -- self:processProperty(list, "shares")--分享
    -- self:processProperty(list, "levels")
    -- self:processProperty(list,"invitesucc") -- 邀请成功

    self:sortTaskDataList(self.allTaskList)
    self.taskReady = true
    if not init then
        bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.LOAD_TASK_LIST_ALREAD,
            data = self.allTaskList})
    end

    self.isBusy = false
end

function DailyTasksController:processProperty(tasklist, taskJsonId, isInRoom)
    local jsonTask = tasklist[taskJsonId]
    if jsonTask then
        local task = DailyTask.new()
        task:fromJSON(jsonTask)
        rawset(task, "dailyType", taskJsonId)

        if not self.taskProgressMap[taskJsonId] then
            rawset(self.taskProgressMap, taskJsonId, 0)
        end

        if jsonTask.progress then
            rawset(self.taskProgressMap, taskJsonId, jsonTask.progress)
        end

        rawset(self.taskMap, taskJsonId, task)

        if task.status == DailyTask.STATUS_UNDER_WAY or task.status == DailyTask.STATUS_CAN_REWARD then
            if self.taskProgressMap[taskJsonId] >= task.target then
                self.finishTaskCount = self.finishTaskCount + 1
                task.status = DailyTask.STATUS_CAN_REWARD
                rawset(task, "progress", task.target)
                self.dbHelper:update(taskJsonId, task.target)
            else
                rawset(task, "progress", self.taskProgressMap[taskJsonId])
            end
        end

        table.insert(self.allTaskList, task)
    end
end

function DailyTasksController:inc(type)
    self:add(type, 1)
end

function DailyTasksController:add(type, add)
    local count = self.taskProgressMap[type]
    if not count or count <= 0 then
        self:report(type, add)
    else
        self:report(type, count + add)
    end
end

function DailyTasksController:incReport(type)
    if self:isReady() then
        self:inc(type)
    end
end

function DailyTasksController:addReport(type, add)
    if self:isReady() then
        self:add(type, add)
    end
end

function DailyTasksController:report(type, value)
    self.taskProgressMap[type] = value
    if self:isReady() then
        local task = self.taskMap[type]
        if task then
            if task.status == DailyTask.STATUS_UNDER_WAY then
                if value >= task.target then
                    self.finishTaskCount = self.finishTaskCount + 1
                    task.progress = task.target
                    task.status = DailyTask.STATUS_CAN_REWARD
                    self:setRoomToptip(task)
                else
                    task.progress = value
                    self:updateProgress()
                end
            end
        end

        self.dbHelper:update(type, value)
    end
end

function DailyTasksController:setRoomToptip(task)
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("DAILY_TASK", "COMPLETE_REWARD", task.name)..task.rewardDesc)
end

function DailyTasksController:updateProgress()
    -- body
end

function DailyTasksController:onGetReward_(evt)
    local task = evt.data
    
    -- dump(task, "DailyTasksController:onGetReward_:===============")
    nk.http.getDailyTaskReward(task.id,
        function(retData)
            -- dump(retData, "getDailyTaskReward.retData :================")
                -- local retData = json.decode(data)
                if retData then
                    local key = -1
                    for k,v in pairs(self.allTaskList) do
                        if v.id == task.id then
                            print("task id:", v.id, task.id)
                            key = k
                            break
                        end
                    end
                    table.remove(self.allTaskList, key)

                    if self.finishTaskCount >= 1 then
                        self.finishTaskCount = self.finishTaskCount - 1
                    end

                    if retData.money and retData.addMoney then
                        nk.userData["aUser.money"] = retData.money

                        if retData.exp and retData.addExp then
                            --todo
                            nk.userData["aUser.exp"] = retData.exp
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("DAILY_TASK", "GET_TASKREWARD_SUCC", 
                                bm.formatBigNumber(retData.addMoney), retData.addExp)) 
                        end
                        
                    end

                    task.status = DailyTask.STATUS_FINISHED
                    table.insert(self.allTaskList, task)
                end
                bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.GET_RWARD_ALREADY, data = self.allTaskList})
            end,
            function(errData)
                dump(errData, "getDailyTaskReward.errData :================", 10)
                if errData and errData.errorCode then
                    local errorCode = errData.errorCode

                    if errorCode == -1 or errorCode == -13 then
                        local key = -1
                        for k,v in pairs(self.allTaskList) do
                            if v.id == task.id then
                                print("task id:", v.id, task.id)
                                key = k
                                break
                            end
                        end
                        table.remove(self.allTaskList, key)

                        if errorCode == -1 then
                            task.status = DailyTask.STATUS_FINISHED
                        elseif errorCode == -13 then
                            local errRetData = errData.retData
                            if errRetData and errRetData.data and errRetData.data.task then
                                local retTask = errRetData.data.task
                                -- local oldProgress = task.progress
                                task:fromJSON(retTask)
                                -- task.progress = oldProgress
                                task.progress = retTask.progress
                                task.status = DailyTask.STATUS_UNDER_WAY
                            end
                           
                        end
                        table.insert(self.allTaskList, task)
                        bm.EventCenter:dispatchEvent({name = nk.DailyTasksEventHandler.GET_RWARD_ALREADY, data = self.allTaskList})
                    end
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
               
            end)
end

function DailyTasksController:reportGameOver(data)
    print("onReportGameOver 00", self.progressReady, self.taskReady)
    if self:isReady() then
        print("onReportGameOver 01")
        self:inc("pokers")

        if data.selfWin then

            self:inc("wins")

            -- local roomField = data.roomInfo.roomField
            -- if roomField == 1 then
            --     self:inc("wins")
            -- elseif  roomField == 2 then
            --     self:inc("middleWins")
            -- elseif roomField == 3 then
            --     self:inc("seniorWins")
            -- end
        end
    end
end


function DailyTasksController:reportInvites(data)
    if self:isReady() then
        local count = checkint(data.count)
        if count > 0 then
            print("reportInvites count:" .. count)
            for i = 1,count do
                self:inc("invites")
            end
        end  
    end
end

return DailyTasksController