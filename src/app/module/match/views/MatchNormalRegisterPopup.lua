-- Author: thinkeras3@163.com
-- Date: 2016-05-09 10:0:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 用户报名弹窗 -- 新版定时赛
local MatchNormalRegisterPopup = class("MatchNormalRegisterPopup", nk.ui.Panel)
local WIDTH = 695
local HEIGHT = 425
local TOP_HEIGHT = 55

function MatchNormalRegisterPopup:ctor(matchData,callback)
    -- dump(matchData,"MatchNormalRegisterPopup:ctor")
    -- local prizeData = nk.MatchConfigEx:
    self.matchData_ = matchData
    self.callback_ = callback
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    display.addSpriteFrames("newMatch.plist", "newMatch.png")

	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:setNodeEventEnabled(true)

    self:createNode_()
end

function MatchNormalRegisterPopup:createNode_()

	display.newScale9Sprite("#match_new_bg.png", 0, 0, cc.size(WIDTH,HEIGHT ))
    :pos(0,0)
    :addTo(self)
    

	display.newScale9Sprite("#match_new_title.png", 0, 0, cc.size(WIDTH-8,TOP_HEIGHT ))
    :pos(0,HEIGHT/2 - TOP_HEIGHT/2)
    :addTo(self)

    display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "APPLY_1"), color = cc.c3b(0x60, 0xab, 0x36), size = 30,align = ui.TEXT_ALIGN_CENTER})
    :addTo(self)
    :pos(0,HEIGHT/2 - TOP_HEIGHT/2)


    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
            :pos(WIDTH * 0.5 - 22, HEIGHT * 0.5 - 25)
            :onButtonClicked(function() 
                    self:onClose()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 99)

    -- 一级tab bar
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new({
        popupWidth = WIDTH,
        iconOffsetX = 10,
        iconTexture = {
            {"#match_item_rule_down.png", "#match_item_rule_up.png"}, 
            {"#match_item_award_down.png", "#match_item_award_up.png"}
        }, btnText = bm.LangUtil.getText("HALL", "MATCH_REGISTER_TAB")})
        :setTabBarExtraParam({noIconCircle = true})
       :pos(0, 120)
       :addTo(self)

    self.ruleNode_ = display.newNode()
    :addTo(self)
    :hide()
    
    display.newScale9Sprite("#match_apply_content_bg.png", 0, 0, cc.size(WIDTH-68,212 ))
    :pos(0,-30)
    :addTo(self.ruleNode_)

    local ruleStr = self.matchData_ and self.matchData_.rules or ""
    self.matchRule_ = display.newTTFLabel({text = ruleStr, color = cc.c3b(0x89,0xa2,0xc6),dimensions = cc.size(WIDTH-68-40, 212-54), size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.ruleNode_)
    :pos(0,-30)


    self.registerBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png",
		disabled = "#common_btn_disabled.png"}, {scale9 = true})
		:setButtonSize(193, 55)
		:setButtonLabel("normal", display.newTTFLabel({text = T("点击报名"), size = 22,
			color = styles.FONT_COLOR.LIGHT_TEXT, align = ui.TEXT_ALIGN_CENTER}))
		:onButtonClicked(buttontHandler(self, self.onRegisterHandler))
		:pos(193/2,-HEIGHT/2+40)
		:addTo(self.ruleNode_)

	display.newScale9Sprite("#hall_system_info_bg.png",0,0,cc.size(157,51))
	:pos(-193/2-30,-HEIGHT/2+40+2)
	:addTo(self.ruleNode_)

    self.icon1_ = display.newNode()
    :addTo(self.ruleNode_)
    :pos(-193/2-30-35,-HEIGHT/2+40+2)
    -- self.icon1_:setScale(.8)

    self.registerLimit_  =display.newTTFLabel({text = "x 10", color = cc.c3b(0xe9,0xd1,0x61), size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.ruleNode_)
    :pos(-193/2-30+35,-HEIGHT/2+40+2)
    

    self.registerFree_  =display.newTTFLabel({text = T("免费"), color = cc.c3b(0xe9,0xd1,0x61), size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.ruleNode_)
    :pos(-193/2-30,-HEIGHT/2+40+2)

    -- self.matchIconId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    -- self:loadImageTexture(nil)

	self.awardNode_ = display.newNode()
    :addTo(self)
    :hide()

    local CONTENT_BG_WIDTH = WIDTH-68
    display.newScale9Sprite("#match_apply_content_bg.png", 0, 0, cc.size(CONTENT_BG_WIDTH,254 ))
    :pos(0,-50)
    :addTo(self.awardNode_)

    local posY = 40
    self.listBg1 = display.newNode():addTo(self.awardNode_):pos(0,posY)
    self.listBg2 = display.newNode():addTo(self.awardNode_):pos(0,0)
    self.listBg3 = display.newNode():addTo(self.awardNode_):pos(0,-posY)
    self.listBg4 = display.newNode():addTo(self.awardNode_):pos(0,-2*posY)

    local COTENT_ITEM_BG_WIDTH = CONTENT_BG_WIDTH-60
    display.newScale9Sprite("#match_new_award_bg2.png",0,0,cc.size(COTENT_ITEM_BG_WIDTH,40))
    :addTo(self.listBg1)
    display.newScale9Sprite("#match_new_award_bg1.png",0,0,cc.size(COTENT_ITEM_BG_WIDTH,40))
    :addTo(self.listBg2)
    display.newScale9Sprite("#match_new_award_bg2.png",0,0,cc.size(COTENT_ITEM_BG_WIDTH,40))
    :addTo(self.listBg3)
    display.newScale9Sprite("#match_new_award_bg1.png",0,0,cc.size(COTENT_ITEM_BG_WIDTH,40))
    :addTo(self.listBg4)

    --
    display.newTTFLabel({text = T("名次"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.listBg1)
    :align(display.LEFT_CENTER)
    :pos(-COTENT_ITEM_BG_WIDTH/2 + 30,0)
    display.newTTFLabel({text = T("奖励"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.listBg1)
    :pos(COTENT_ITEM_BG_WIDTH/4,0)


    local prizeDesc  
    if self.matchData_ then
        prizeDesc = self.matchData_.prizeDesc
    end

    if not prizeDesc then
        prizeDesc = {}
    end

    local otherRewardtips = self.matchData_ and self.matchData_.otherRewardtips or ""

    display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "RANKING_LABEL",1), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.listBg2)
    :align(display.LEFT_CENTER)
    :pos(-COTENT_ITEM_BG_WIDTH/2 + 30,0)
    display.newTTFLabel({text = (prizeDesc[1] or ""), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.listBg2)
    :pos(COTENT_ITEM_BG_WIDTH/4,0)

    display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "RANKING_LABEL",2), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.listBg3)
    :align(display.LEFT_CENTER)
    :pos(-COTENT_ITEM_BG_WIDTH/2 + 30,0)
    display.newTTFLabel({text = (prizeDesc[2] or ""), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.listBg3)
    :pos(COTENT_ITEM_BG_WIDTH/4,0)

    display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "RANKING_LABEL",3), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.listBg4)
    :align(display.LEFT_CENTER)
    :pos(-COTENT_ITEM_BG_WIDTH/2 + 30,0)
    display.newTTFLabel({text = (prizeDesc[3] or ""), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.listBg4)
    :pos(COTENT_ITEM_BG_WIDTH/4,0)

    display.newTTFLabel({text = (otherRewardtips or ""), color = cc.c3b(0xe9,0xd1,0x61), size = 20, align = ui.TEXT_ALIGN_CENTER,dimensions = cc.size(COTENT_ITEM_BG_WIDTH, 70)})
    :addTo(self.awardNode_)
    :pos(0,-2*posY -20 - 70/2)

    self:checkFitEntry()
end
function MatchNormalRegisterPopup:show()
	self:showPanel_()
end
function MatchNormalRegisterPopup:onShowed()
	-- 延迟设置，防止list出现触摸边界的问题
    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
    if self.list_ then
        self.list_:setScrollContentTouchRect()
    end
end


function MatchNormalRegisterPopup:checkFitEntry()
    local id = self.matchData_ and self.matchData_.id or 0
    local entryData,needTb = self:checkEntryCondition(id)
    self.entryData_ = entryData
    self.needTb_ = needTb

    dump(entryData,"checkFitEntry==11")
    dump(needTb,"checkFitEntry==22")

    if entryData then
        
        local iconPath

        self.registerLimit_:show()
        self.registerFree_:hide()
        -- self.registerLimit_:setString("")

        --找到符合的进入条件
        if entryData.ctype == "ticket" then
            if entryData["id"] == 7101 then
                self.registerLimit_:setString("x" .. entryData["num"])
                iconPath = "#hall_small_ticket_7101.png"
            elseif entryData["id"] == 7104 then
                self.registerLimit_:setString("x" .. entryData["num"])
                iconPath = "#hall_small_ticket_7104.png"
            end
            
        elseif entryData.ctype == "fee" then

            if entryData.entry < 100000 then
                self.registerLimit_:setString(bm.formatNumberWithSplit(entryData.entry))
            else
                self.registerLimit_:setString(bm.formatBigNumber(entryData.entry))
            end

            iconPath = "#hall_small_chip_icon.png"

        elseif entryData.ctype == "point" then
            if entryData.entry < 100000 then
                self.registerLimit_:setString(bm.formatNumberWithSplit(entryData.entry))
            else
                self.registerLimit_:setString(bm.formatBigNumber(entryData.entry))
            end
            iconPath = "#hall_small_cash_icon.png"
        end

        dump(iconPath,"iconPath1111111===========")
        if iconPath then
            self.icon1_:removeAllChildren()
            display.newSprite(iconPath)
            :addTo(self.icon1_)
            self.icon1_:show()
        end
    else
        if #needTb > 0 then
            --需要进入条件，但因数量不足，不能进入,按优先级显示

            self.registerLimit_:show()
            self.registerFree_:hide()

            entryData = needTb[1]
            if entryData.ctype == "ticket" then
                if entryData["id"] == 7101 then
                    self.registerLimit_:setString("x" .. entryData["num"])
                    iconPath = "#hall_small_ticket_7101.png"
                elseif entryData["id"] == 7104 then
                    self.registerLimit_:setString("x" .. entryData["num"])
                    iconPath = "#hall_small_ticket_7104.png"
                end
                
            elseif entryData.ctype == "fee" then
                if entryData.entry < 100000 then
                    self.registerLimit_:setString(bm.formatNumberWithSplit(entryData.entry))
                else
                    self.registerLimit_:setString(bm.formatBigNumber(entryData.entry))
                end

                iconPath = "#hall_small_chip_icon.png"

            elseif entryData.ctype == "point" then
                if entryData.entry < 100000 then
                    self.registerLimit_:setString(bm.formatNumberWithSplit(entryData.entry))
                else
                    self.registerLimit_:setString(bm.formatBigNumber(entryData.entry))
                end
                iconPath = "#hall_small_cash_icon.png"
            end

             dump(iconPath,"iconPath222222222222===========")
            if iconPath then
                self.icon1_:removeAllChildren()
                display.newSprite(iconPath)
                :addTo(self.icon1_)
                self.icon1_:show()
            end
        else
            dump(free,"iconPath33333333333333===========")
            --免费进入

            self.registerLimit_:hide()
            self.registerFree_:show()

            self.icon1_:hide()
            -- self.registerLimit_:setString("免费")
        end
    end
end


function MatchNormalRegisterPopup:onMainTabChange_(selectedTab)
	if selectedTab == 1 then
		self.awardNode_:hide()
		self.ruleNode_:show()
	else
		self.awardNode_:show()
		self.ruleNode_:hide()
	end
end
function MatchNormalRegisterPopup:hide()
	self:hidePanel_()
end
function MatchNormalRegisterPopup:onCleanup()
    nk.http.cancel(self.registerRequestId_)
end
function MatchNormalRegisterPopup:loadImageTexture(data)
    
    --if data.icon1 and string.len(data.icon1) > 0 then
        nk.ImageLoader:loadAndCacheImage(
            self.matchIconId_, 
            "http://mvlptlpd01-static.boyaagame.com/match/icon/icon30.png", 
             handler(self, self.onAvatarLoadComplete), 
              nk.ImageLoader.CACHE_TYPE_MATCH
            )
    --end
end
function MatchNormalRegisterPopup:onAvatarLoadComplete(success, sprite)
    -- do return end
    if success then
        self.icon1_:show()
         local tex = sprite:getTexture()
         local texSize = tex:getContentSize()
         self.icon1_:setTexture(tex)
         self.icon1_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
          --self.icon1_:setScaleX(80 / texSize.width)
          --self.icon1_:setScaleY(80 / texSize.height)
        --  if self.baseData_ and self.baseData_.open == 0 then
        --     self.icon1_:hide()
        -- end
    end
end


-- "condition" = {
-- [19.1075] -                 "fee" = {
-- [19.1077] -                     "entry"       = 0
-- [19.1080] -                     "entrySource" = 1072
-- [19.1084] -                     "num"         = 30
-- [19.1087] -                     "serv"        = 0
-- [19.1090] -                     "servSource"  = 1076
-- [19.1092] -                 }
-- [19.1095] -                 "point" = {
-- [19.1097] -                     "entry"       = ""
-- [19.1099] -                     "entrysource" = ""
-- [19.1101] -                     "serv"        = ""
-- [19.1103] -                     "servsource"  = ""
-- [19.1104] -                 }
-- [19.1106] -                 "tickets" = {
-- [19.1109] -                 }
-- [19.1111] -             }

-- 检查场次进入条件
--优先级 热身门票>通用门票>筹码报名>现金币
-- 7101 热身赛门票
-- 7102 初级赛门票
-- 7104 通用门票
function MatchNormalRegisterPopup:checkEntryCondition(id)
    local matchInfo = nk.MatchConfigEx:getMatchDataById(id)

    dump(matchInfo,"checkEntryCondition")
    if matchInfo and matchInfo.condition then
        local condition = matchInfo.condition

        dump(condition,"condition===")
        local needTb = {}
        local selfPoint = checkint(nk.userData["match.point"])
        local selfHoticket = checkint(nk.userData["match.ticket_7101"])
        local selfNormalTicket = checkint(nk.userData["match.ticket_7104"])
        local selfMoney = checkint(nk.userData["aUser.money"])

        if condition and condition.tickets then
            local hotTicket = checkint(condition.tickets["7101"])
            local normalTicket = checkint(condition.tickets["7104"])
            if hotTicket > 0 then
                table.insert(needTb,{ctype = "ticket",id = 7101,num = hotTicket})
                if selfHoticket >= hotTicket then
                    return {ctype = "ticket",id = 7101,num = hotTicket},needTb
                end
            end

            if normalTicket > 0 then
                table.insert(needTb,{ctype = "ticket",id = 7104, num = normalTicket})
                if selfNormalTicket >= normalTicket then
                    return {ctype = "ticket",id = 7104, num = normalTicket},needTb
                end
            end
        end

        if condition and condition.fee then
            local entry = checkint(condition.fee.entry)
            local serv = checkint(condition.fee.serv)
            if entry > 0 or serv > 0 then
                table.insert(needTb,{ctype = "fee",entry = entry,serv  = 0})
                if selfMoney >= (entry + serv) then
                    return {ctype = "fee",entry = entry,serv  = serv},needTb
                end
            end
        end


        if condition and condition.point then
            local entry = checkint(condition.point.entry)
            local serv = checkint(condition.point.serv)
            if entry > 0 or serv > 0 then
                table.insert(needTb,{ctype = "point",entry = entry,serv  = 0})
                if selfPoint >= (entry + serv) then
                    return {ctype = "point",entry = entry,serv  = serv},needTb
                end
            end
        end

        return nil,needTb

    end

    return nil,{}
end


function MatchNormalRegisterPopup:onRegisterHandler()
    local entryData = self.entryData_
    local needTb = self.needTb_

    local mtype
    local ticketId
    if entryData then
        --找到符合的进入条件
        if entryData.ctype == "fee" then
            mtype = 1
        elseif entryData.ctype == "ticket" then
            mtype = 2
            ticketId = entryData.id
        elseif entryData.ctype == "point" then
            mtype = 3
        end

    else
        if #needTb > 0 then
            --需要进入条件，但因数量不足，不能进入
            entryData = needTb[1]
            if entryData.ctype == "ticket" then
                nk.TopTipManager:showTopTip(T("门票不足"))
            elseif entryData.ctype == "fee" then
                nk.TopTipManager:showTopTip(T("筹码不足"))
            elseif entryData.ctype == "point" then
               nk.TopTipManager:showTopTip(T("现金币不足"))
            end
            return
        else
            --免费进入
            mtype = 1
        end
    end

    if not self.matchData_ then
        return
    end

    dump(self.matchData_,"onRegisterHandler=========")

    local id = self.matchData_.id
    -- local mtype = self.matchData_.type
    -- local timestamp = self.matchData_.mtime.timestamp
    -- local timeStr = os.date("%Y%m%d%H%M",timestamp)
    -- dump(timeStr,"timeStr===")

    self.registerRequestId_ = nk.http.applyMatch(id,mtype,ticketId,
        function(data)
            nk.TopTipManager:showTopTip(T("报名成功"))
            local matchid = data.matchid
            local matchTime = data.matchTime
            local id = data.id
            local money = data.money
            local point = data.point
            local tickets = data.tickets

            if money then
                nk.userData["aUser.money"] = checkint(money)
            end

            if point then
                nk.userData["match.point"] = checkint(point)
            end

            if tickets and type(tickets) == "table" then
                for _,v in pairs(tickets) do
                    local tickKey = "match.ticket_" .. v.pnid
                    nk.userData[tickKey] = checkint(v.pcnter)
                end
            end


            -- local tid = data.tid

            -- dump(matchTime,"剩余时间:")
            -- local matchdata ={matchid = matchid,matchTime = matchTime} 
            -- nk.MatchRegisterControl:add(matchdata)

            -- nk.server:joinMatchWait(matchid)

            -- dump("id:" .. (id or 0) .. " matchid:" .. (matchid or "") .. " matchTime:" .. (time or 0))
            -- local matchdata ={id = id,matchid = matchid,time = matchTime} 
            -- nk.MatchConfigEx:addRegisterMatch(matchdata)
            -- nk.MatchConfigEx:cacheRegisterMatch(matchdata)

            local matchid = data.matchid 
            local tid = data.tid
            bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_MATCH_WITH_DATA, data = {tid = tid,matchid = matchid}})
            self:onClose()

            if self.registerBtn_ then
                self.registerBtn_:setButtonLabelString(T("已报名"))
                self.registerBtn_:setButtonEnabled(false)
            end

            if self.callback_ then
                self.callback_(self.matchData_)
            end

        end,
        function(errordata)
            local errorCode = checkint(errordata.errorCode)
            if errorCode ==  -1 then
                nk.TopTipManager:showTopTip(T("报名失败")..errorCode)
            elseif errorCode == -2 then
                nk.TopTipManager:showTopTip(T("该比赛已经关闭"))
            elseif errorCode == -3 then
                nk.TopTipManager:showTopTip(T("金币不足,请补充金币后再来"))
            elseif errorCode == -4 then
                nk.TopTipManager:showTopTip(T("门票不足"))
            elseif errorCode == -6 then
                nk.TopTipManager:showTopTip(T("报名失败")..errorCode)
            elseif errorCode == -7 then
                nk.TopTipManager:showTopTip(T("报名失败")..errorCode)
            elseif errorCode == -8 then
                nk.TopTipManager:showTopTip(T("报名次数今日达到上限"))
            elseif errorCode == -9 then
                nk.TopTipManager:showTopTip(T("报名失败")..errorCode)
            elseif errorCode == -20 then
                nk.TopTipManager:showTopTip(T("网络错误，请稍后再试")..errorCode)
            elseif errorCode == -21 then
                nk.TopTipManager:showTopTip(T("网络错误，请稍后再试")..errorCode)
            elseif errorCode == -22 then
                nk.TopTipManager:showTopTip(T("网络错误，请稍后再试")..errorCode)
            elseif errorCode == 100 then
                nk.TopTipManager:showTopTip(T("报名失败,该比赛已经开始"))
            elseif errorCode == 101 then
                nk.TopTipManager:showTopTip(T("报名失败,该比赛已经开始"))
            elseif errorCode == 122 then
                nk.TopTipManager:showTopTip(T("报名失败")..errorCode)
            elseif errorCode == 123 then
                nk.TopTipManager:showTopTip(T("您已经报名该比赛"))
            elseif errorCode == 124 then
                nk.TopTipManager:showTopTip(T("该场比赛已经满人"))
            end
        end
    )
end

return MatchNormalRegisterPopup