--
-- Author: viking@boomegg.com
-- Date: 2014-09-13 21:08:19
--

local DailyTasksEventHandler = class("DailyTasksEventHandler")

local DailyTasksController = import(".DailyTasksController")

--view事件
DailyTasksEventHandler.GET_RWARD = "GET_RWARD"
DailyTasksEventHandler.GET_RWARD_ALREADY = "GET_RWARD_ALREADY"
DailyTasksEventHandler.GET_TASK_LIST = "GET_TASK_LIST"
DailyTasksEventHandler.LOAD_TASK_LIST_ALREAD = "LOAD_TASK_LIST_ALREAD"

--上报事件
DailyTasksEventHandler.REPORT_USE_PROPS = "REPORT_USE_PROPS"
DailyTasksEventHandler.REPORT_USER_PAYS = "REPORT_USER_PAYS"
DailyTasksEventHandler.REPORT_GAME_OVER = "REPORT_GAME_OVER"
DailyTasksEventHandler.REPORT_INVITES   = "REPORT_INVITES"

function DailyTasksEventHandler:ctor()
    self.controller_ = DailyTasksController.new()

    self:addEvents()
end

function DailyTasksEventHandler:addEvents()
    self.getRewardHandler_ = self:addEvent(DailyTasksEventHandler.GET_RWARD, handler(self, self.onGetReward_))
    self.getTaskListHandler_ = self:addEvent(DailyTasksEventHandler.GET_TASK_LIST, handler(self, self.onGetTaskList_))

    self.hallLoginSuccHandler_ = self:addEvent(nk.eventNames.HALL_LOGIN_SUCC, handler(self, self.onLogin_))
    self.hallLogoutSuccHandler_ = self:addEvent(nk.eventNames.HALL_LOGOUT_SUCC, handler(self, self.onLogout_))

    self.userPropsHandler_ = self:addEvent(DailyTasksEventHandler.REPORT_USE_PROPS, handler(self, self.onReportUseProps_))
    self.userPayHandler_ = self:addEvent(DailyTasksEventHandler.REPORT_USER_PAYS, handler(self, self.onReportUserPays_))
    self.gameOverHandler_ = self:addEvent(DailyTasksEventHandler.REPORT_GAME_OVER, handler(self, self.onReportGameOver_))
    self.invitesHandler_ = self:addEvent(DailyTasksEventHandler.REPORT_INVITES, handler(self, self.onReportInvites_))
end

function DailyTasksEventHandler:addEvent(evt, func,tag)
     return bm.EventCenter:addEventListener(evt, func,tag)
end

function DailyTasksEventHandler:onGetTaskList_()
    self.controller_:getTasksListData(false)
end

function DailyTasksEventHandler:onGetReward_(evt)
    -- dump(evt.data,"DailyTasksEventHandler:onGetReward_");
    self.controller_:onGetReward_(evt)
end

function DailyTasksEventHandler:onLogin_()
    -- print("DailyTasksEventHandler:onLogin_")
    self.controller_:setData()
end

function DailyTasksEventHandler:onLogout_()
    
end

function DailyTasksEventHandler:onReportUseProps_()
    self.controller_:incReport("props")
end

function DailyTasksEventHandler:onReportUserPays_(evt)
    self.controller_:addReport("pays", evt.data)
end

function DailyTasksEventHandler:onReportGameOver_(evt)
    -- print("onReportGameOver_", evt.data)
    self.controller_:reportGameOver(evt.data)
end

function DailyTasksEventHandler:onReportInvites_(evt)
    self.controller_:reportInvites(evt.data)
end

function DailyTasksEventHandler:removeEvent()
    bm.EventCenter:removeEventListener(self.getRewardHandler_)
    bm.EventCenter:removeEventListener(self.getTaskListHandler_)

    bm.EventCenter:removeEventListener(self.hallLoginSuccHandler_)
    bm.EventCenter:removeEventListener(self.hallLogoutSuccHandler_)

    bm.EventCenter:removeEventListener(self.userPropsHandler_)
    bm.EventCenter:removeEventListener(self.userPayHandler_)
    bm.EventCenter:removeEventListener(self.gameOverHandler_)
    bm.EventCenter:removeEventListener(self.invitesHandler_)
end

return DailyTasksEventHandler