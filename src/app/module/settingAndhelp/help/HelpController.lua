--
-- Author: viking@boomegg.com
-- Date: 2014-08-28 16:35:21
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local HelpController = class("HelpController")

local FeedbackCommon = import("app.module.feedback.FeedbackCommon")

HelpController.FEED_BACK  = 1
HelpController.FAQ        = 2
HelpController.RULE       = 3
HelpController.LEVEL      = 4

function HelpController:ctor(helpView)
    self.view_ = helpView
end

function HelpController:onTabChanged(selectedTab)
    self:onTabChangedVisible_(selectedTab)
    if selectedTab == HelpController.FEED_BACK then
        self:feedBack()
    elseif selectedTab == HelpController.FAQ then
        self:faq()
    elseif selectedTab == HelpController.RULE then
        self:rule()
    elseif selectedTab == HelpController.LEVEL then
        self:level()
    end
end

function HelpController:feedBack()
    
end

function HelpController:faq()
    -- body
end

function HelpController:rule()
    -- body
end

function HelpController:level()
    -- body
end

function HelpController:onTabChangedVisible_(selectedTab)
    if self.view_:getFeedbackView() then self.view_:getFeedbackView():setVisible(selectedTab == HelpController.FEED_BACK) end
    if self.view_:getFaqListView() then self.view_:getFaqListView():setVisible(selectedTab == HelpController.FAQ) end
    if self.view_:getRuleListView() then self.view_:getRuleListView():setVisible(selectedTab == HelpController.RULE) end
    if self.view_:getLevelListView() then self.view_:getLevelListView():setVisible(selectedTab == HelpController.LEVEL) end
end

function HelpController:getFeedbackListData()
    local feedList = {}
    local g = 2
    bm.HttpService.POST(
        {
            mod = "feedback",
            act = "getList"
        },
        function(data)
            if data then
                local feedbackRetData = json.decode(data)
                if feedbackRetData.ret == 0 then
                    -- self.view_:getFeedbackView():setFeedbackList(feedbackRetData.data)
                    for i = 1, #feedbackRetData.data do
                        table.insert(feedList,feedbackRetData.data[i])
                    end
                end
            end
            g = g - 1
            if g == 0 then
                table.sort(feedList,function(a,b) return a.mtime > b.mtime end)

                if self.view_ and self.view_.getFeedbackView then
                    --todo
                    self.view_:getFeedbackView():setFeedbackList(feedList)
                end
            end
        end,
        function()
            g = g - 1
            if g == 0 then
                table.sort(feedList,function(a,b) return a.mtime > b.mtime end)

                if self.view_ and self.view_.getFeedbackView then
                    --todo
                    self.view_:getFeedbackView():setFeedbackList(feedList)
                end
            end
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
        end
        )

    FeedbackCommon.getFeedbackList(function(succ,feedbackRetData)
        if succ then
            for i = 1, #feedbackRetData.data do
                table.insert(feedList,feedbackRetData.data[i])
            end
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
        end
        g = g - 1
        if g == 0 then
            table.sort(feedList,function(a,b) return a.mtime > b.mtime end)
            if self.view_ and self.view_.getFeedbackView then
                --todo
                self.view_:getFeedbackView():setFeedbackList(feedList)
            end
        end
    end)
    
end

function HelpController:getFaqListData()
    local data = bm.LangUtil.getText("HELP", "FAQ")
    self.view_:getFaqListView():setData(data)
end

function HelpController:getRuleListData()
    local data = bm.LangUtil.getText("HELP", "RULE")
    self.view_:getRuleListView():setData(data)
end

function HelpController:getLevelListData()
    local data = bm.LangUtil.getText("HELP", "LEVEL")
    local levelData = nk.Level:getLevelConfigData()   
    if levelData then
        data[2] = {T("升级奖励"),{{"LV", T("称号"), T("所有EXP"), T("升级奖励")}}}
        table.insertto(data[2][2], levelData)        
    end

    if levelData then
        data[3] = bm.LangUtil.getText("HELP","CASH_COIN")
    else
        -- data[2] = bm.LangUtil.getText("HELP","CASH_COIN")
    end
    self.view_:getLevelListView():setData(data)
end

return HelpController