--
-- Author: ThinkerWang
-- Date: 2016-05-24 11:14:50
-- Copyright: Copyright (c) 2016, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 定时赛报名管理器
-- 开放报名新增比赛，退赛删除比赛，比赛推送

local MatchRegisterControl = class("MatchRegisterControl")
local MatchRegisterItem = import("app.module.match.matchRegisterManager.MatchRegisterItem")

function MatchRegisterControl:ctor()
	-- self.matchPool_ = {}
	-- self.schedulerPool = bm.SchedulerPool.new()
	-- self:startCheck()
    self:addDataObservers()
    
end


function MatchRegisterControl:addDataObservers()
    if not self.timeMatchPushListenerId_ then
        self.timeMatchPushListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.TIME_MATCH_PUSH, handler(self, self.onTimeMatchPush_))
    end

    if not self.appForegroundListenerId_ then
        self.appForegroundListenerId_ = bm.EventCenter:addEventListener(nk.eventNames.APP_ENTER_FOREGROUND, handler(self, self.onEnterForeground_))
    end
end


function MatchRegisterControl:onEnterForeground_()
    local isConfigLoaded =nk.MatchConfigEx:isConfigLoaded()
    local matchDatas = nk.MatchConfigEx:getMatchDatas()
    if isConfigLoaded and #matchDatas > 0 then
        -- nk.http.getRegisteredMatchInfo(function(data)
        --     dump(data,"getRegisteredMatchInfo")

        --     for _,v in pairs(data) do
        --         nk.MatchConfigEx:addRegisterMatch(v)

        --     end
        -- end,function(errData)
            
        -- end)
    end
end

function MatchRegisterControl:onTimeMatchPush_(evt)
    local data = evt.data
    if data then
        self:showMatchTip(data)
    end
end



function MatchRegisterControl:removeDataObserver()
    if self.timeMatchPushListenerId_ then
        bm.EventCenter:removeEventListener(self.timeMatchPushListenerId_)
        self.timeMatchPushListenerId_ = nil
    end

    if self.appForegroundListenerId_ then
        bm.EventCenter:removeEventListener(self.appForegroundListenerId_)
        self.appForegroundListenerId_ = nil
    end
end


function MatchRegisterControl:dispose()
    self:removeDataObserver()
end


function MatchRegisterControl:setTipClickHandler(callback)
    self.tipClickHandler_ = callback
end


function MatchRegisterControl:showMatchTip(matchData)
	local left = matchData.time  - os.time()
	local matchid = matchData.matchid
    local id = matchData.id
    local time = matchData.time
    local isSameEnd = matchData.isSameEnd
    local matchInfo = nk.MatchConfigEx:getMatchDataById(id)
    local matchName = matchInfo and matchInfo.name or ""

    local runningScene = nk.runningScene

    -- if not isSameEnd then
        -- local str = string.format("你报名的%s,还有%s秒钟开赛,请玩家赶紧到比赛场集合",matchName,left)
        nk.TopTipExManager:showTopTip({text = bm.LangUtil.getText("MATCH", "TIME_PUSH_TIPS",matchName,left), messageType = 1001})
        nk.TopTipExManager:setLblColor_(styles.FONT_COLOR.LIGHT_TEXT)
    -- else
        -- if runningScene.name ~= "HallScene" then
        -- elseif runningScene.name == "RoomScene" then
        -- elseif runningScene.name == "MatchRoomScene" then
        -- elseif runningScene.name == "GrabDealerRoomScene" then
        --     local str = string.format("你报名的%s,还有%s秒钟,就要开赛。比赛时间到将自动进入比赛场，请玩家赶紧到比赛场集合",matchName,left)
        --     nk.ui.Dialog.new({
        --         hasCloseButton = true,
        --         messageText = (str or ""), 
        --         firstBtnText = "退赛",
        --         secondBtnText = "确认", 
        --         callback = function (type)
        --             if type == nk.ui.Dialog.FIRST_BTN_CLICK then
                        
        --             elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
        --                 dump(matchid,"matchid")
        --                 dump(id,"id")
        --                 dump(time,"time")
        --                 nk.server:joinMatchWait(matchid)
        --                 -- nk.MatchConfigEx:delRegisterMatch(id,matchid,time)
        --                 -- if self.tipClickHandler_ then
        --                 --     self.tipClickHandler_(id,matchid,time)
        --                 -- end
        --             end
        --         end
        --     }):show()

        -- end

    -- end


	-- self.exButton_ = cc.ui.UIPushButton.new({normal = "#common_btn_aqua.png", pressed = "#common_btn_aqua.png", disabled = "#common_btn_disabled.png"},
 --            {scale9 = true})
 --        :setButtonSize(120, 48)
 --        :setButtonLabel("normal", display.newTTFLabel({text = "Go>>>", size = 20, color = styles.FONT_COLOR.LIGHT_TEXT,
 --            align = ui.TEXT_ALIGN_CENTER}))
 --        :onButtonClicked(
 --            function()
 --                nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
 --                dump(matchid,"matchid")
 --                dump(id,"id")
 --                dump(time,"time")
 --                nk.server:joinMatchWait(matchid)
 --                nk.MatchConfigEx:delRegisterMatch(id,matchid,time)
 --                if self.tipClickHandler_ then
 --                    self.tipClickHandler_(id,matchid,time)
 --                end

 --            end
 --        )

 --        nk.TopTipExManager:showTopTip({text = "距离比赛还有:"..left.."秒", messageType = 1001, button = self.exButton_})
 --        nk.TopTipExManager:setLblColor_(styles.FONT_COLOR.LIGHT_TEXT)
end

return MatchRegisterControl