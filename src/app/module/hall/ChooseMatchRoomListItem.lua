local ChooseMatchRoomListItem = class("ChooseMatchRoomListItem", bm.ui.ListItem)

ChooseMatchRoomListItem.ITEM_HEIGHT = 90
ChooseMatchRoomListItem.BUTTON_WIDHT = 168

function ChooseMatchRoomListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self:setNodeEventEnabled(true)
	ChooseMatchRoomListItem.super.ctor(self,display.width - 40, ChooseMatchRoomListItem.ITEM_HEIGHT)
	self.bg_ = display.newScale9Sprite("#hall_match_list_room_bg.png",0,0,cc.size(display.width-40-ChooseMatchRoomListItem.BUTTON_WIDHT,ChooseMatchRoomListItem.ITEM_HEIGHT))
	:addTo(self)
	:pos((display.width - 40-ChooseMatchRoomListItem.BUTTON_WIDHT)/2,ChooseMatchRoomListItem.ITEM_HEIGHT/2)
	-- :opacity(0)

	self.btn_ = cc.ui.UIPushButton.new({normal = "#hall_apply_match_btn_up.png", pressed = "#hall_apply_match_btn_down.png",disabled = "#hall_apply_match_btn_disable.png"})
    :onButtonClicked(buttontHandler(self, self.applyClick_))
    :pos((display.width - 40)-ChooseMatchRoomListItem.BUTTON_WIDHT/2, ChooseMatchRoomListItem.ITEM_HEIGHT/2)
    :addTo(self)
    -- :opacity(0)
    self.btn_:setTouchSwallowEnabled(false)

    --styles.FONT_COLOR.LIGHT_TEXT
    self.buttonLabel = display.newTTFLabel({text = T("报名"), color =cc.c3b(0x87,0x43,0x61) , size = 28, align = ui.TEXT_ALIGN_CENTER})
    -- :opacity(0)
    self.btn_:setButtonLabel("normal", self.buttonLabel)

    self.icon1_ = display.newSprite("#popup_tab_bar_bg.png")
    :addTo(self)
    :pos(60,45)
    -- :opacity(0)

    self.matchName_ = display.newTTFLabel({text = T("百钻疯狂赛"), color =styles.FONT_COLOR.LIGHT_TEXT , size = 20, align = ui.TEXT_ALIGN_LEFT})
    :align(display.LEFT_CENTER)
    :addTo(self)
    :pos(130,60)
    -- :opacity(0)

    self.playerIcon_ = display.newSprite("#hall_match_list_playerIcon.png")
         :align(display.LEFT_CENTER, 130, 25)
         :addTo(self)
         -- :opacity(0)

    self.playerCountLabel_ = display.newTTFLabel({text = "0", color = cc.c3b(0xaF, 0xff, 0x51), size = 18, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, 130+35, 25)
        :addTo(self)
        -- :opacity(0)


    self.infoBg_ = display.newScale9Sprite("#hall_match_item_info_bg.png",0,0,cc.size(210,66))
    :addTo(self)
    :pos(display.cx,45)
    -- :opacity(0)

    self.infoLabel_  = display.newTTFLabel({text = "奖励通过邮件领取 2分钟开赛", color = styles.FONT_COLOR.LIGHT_TEXT, size = 18,dimensions = cc.size(210, 66), align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx,45)
        :addTo(self)
        -- :opacity(0)


    -- self.timeLabel_ = display.newTTFLabel({text = "", color = styles.FONT_COLOR.LIGHT_TEXT, size = 18,dimensions = cc.size(210, 66), align = ui.TEXT_ALIGN_CENTER})
    --     :pos(display.cx+180,45)
    --     :addTo(self)
       

    self.matchIconId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    -- self:loadImageTexture(nil)


    self:createTimeNode()
end


function ChooseMatchRoomListItem:createTimeNode()
    self.timeNode_ = display.newNode()
    :pos(display.cx+180,35)
    :addTo(self)

    local timeTitle = display.newTTFLabel({text = "即将开赛", color = styles.FONT_COLOR.LIGHT_TEXT, size = 18, align = ui.TEXT_ALIGN_CENTER})
    :pos(30,35)
    :addTo(self.timeNode_)

    local minBg = display.newSprite("#timebg.png")
    :pos(0,0)
    :addTo(self.timeNode_)

    self.minLabel_ = display.newTTFLabel({text = "00", color = cc.c3b(0xFF, 0x00, 0x00), size = 18,dimensions = cc.size(210, 66), align = ui.TEXT_ALIGN_CENTER})
    :pos(0,0)
    :addTo(self.timeNode_)

    local secBg = display.newSprite("#timebg.png")
    :pos(56,0)
    :addTo(self.timeNode_)

    self.secLabel_ = display.newTTFLabel({text = "00", color = cc.c3b(0xFF, 0x00, 0x00), size = 18,dimensions = cc.size(210, 66), align = ui.TEXT_ALIGN_CENTER})
    :pos(56,0)
    :addTo(self.timeNode_)


    local timeSepBg = display.newSprite("#timeSep.png")
    :pos(28,0)
    :addTo(self.timeNode_)
end


function ChooseMatchRoomListItem:loadImageTexture(data)
    
    if data.icon1 and string.len(data.icon1) > 0 then
        nk.ImageLoader:loadAndCacheImage(
            self.matchIconId_, 
            (data.icon1 or "http://mvlptlpd01-static.boyaagame.com/match/icon/icon30.png"), 
            handler(self, self.onAvatarLoadComplete), 
            nk.ImageLoader.CACHE_TYPE_MATCH
            )
    end
end
function ChooseMatchRoomListItem:onAvatarLoadComplete(success, sprite)
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
function ChooseMatchRoomListItem:applyClick_()
    self:dispatchEvent({name="ITEM_EVENT", data = self.data_})
end
function ChooseMatchRoomListItem:onCleanup()
	if self.matchIconId_ then
        nk.ImageLoader:cancelJobByLoaderId(self.matchIconId_)
        self.matchIconId_ = nil
    end
end


function ChooseMatchRoomListItem:countFun()
    
    if self.action_ then
        self:stopAction(self.action_)
    end

    if self.remainTime_ > 0 then
        self.timeNode_:show()  
        self.action_ = self:schedule(function ()
            self.remainTime_ = self.remainTime_ - 1
            self:showTime()
        end, 1)
    else
        -- self.timeLabel_:setString("已开赛")
        self.timeNode_:hide()  
    end
      

end

function ChooseMatchRoomListItem:showTime() 

    if self.remainTime_ > 0 then
        local timeTb = bm.TimeUtil:getTimeDayTb(self.remainTime_)
        
        local min = string.format("%02d", (timeTb.min or 0))
        local sec = string.format("%02d", (timeTb.sec or 0))

        self.minLabel_:setString(min)
        self.secLabel_:setString(sec)

    else
        self.minLabel_:setString("00")
        self.secLabel_:setString("00")

    end
    
end

function ChooseMatchRoomListItem:onDataSet(dataChanged, data)


    do return end

    self.data_ = data
    -- if checkint(data) == 1 then
    -- 	 transition.fadeIn(self.bg_, {time = .8,opacity = 255, delay = 0.8})
    -- 	 transition.fadeIn(self.btn_, {time = .8,opacity = 255, delay = 0.8})
    --      transition.fadeIn(self.icon1_, {time = .8,opacity = 255, delay = 0.8})
    --      transition.fadeIn(self.matchName_, {time = .8,opacity = 255, delay = 0.8})
    --      transition.fadeIn(self.playerIcon_, {time = .8,opacity = 255, delay = 0.8})
    --      transition.fadeIn(self.playerCountLabel_, {time = .8,opacity = 255, delay = 0.8})
    --      transition.fadeIn(self.infoBg_, {time = .8,opacity = 255, delay = 0.8})
    --      transition.fadeIn(self.infoLabel_, {time = .8,opacity = 255, delay = 0.8})
    --      transition.fadeIn(self.buttonLabel,{time = .8,opacity = 255, delay = 0.8})
    -- end

    self.matchName_:setString(data.name or "")

    local timeArr = string.split(data.mtime.time,":")
    local timeStr = os.date("%H:%M",data.mtime.timestamp)

    -- if timeArr then
        -- local timeStr = string.format("%s:%s",(timeArr[1] or "00"),(timeArr[2] or "00"))
        if data.mtime.day and data.mtime.round > 0 then
            timeStr  = os.date("%Y-%m-%d %H:%M", data.mtime.timestamp)
        end
        self.infoLabel_:setString("开赛时间:\n" .. timeStr)
    -- end

    

    local  desTime = data.mtime.timestamp

    local leftTime =  desTime - ((os.time()- data.clientTime) + data.serverTime)
    -- dump(leftTime,"开赛剩余时间:")
    self.remainTime_ = leftTime

    local leftTimeTb = bm.TimeUtil:getTimeDayTb(leftTime)
    dump(leftTimeTb,"difftime")
    if (leftTimeTb.day <= 0  and leftTimeTb.hour < 1)then
        --相隔小于1小时的显示倒计时
        self:showTime()
        self:countFun()
        -- self.timeNode_:show()
    else
        --相隔大于一小时及以上的不显示倒计时
        if self.action_ then
            self:stopAction(self.action_)

            self.action_ = nil
        end
        -- self.timeLabel_:setString("")

        self.timeNode_:hide()

        --启动显示倒计时的定时器
        local delay = leftTime - 3599
        self.remainTime_ = self.remainTime_ - delay

        -- dump(delay,"相隔大于1小时 delay:")
        -- dump(self.remainTime_,"相隔大于1小时 self.remainTime_:")
        self:dealShowCountDown(delay)
    end

	-- transition.moveTo(self.btn_, {time = 0.5, y = ChooseMatchRoomListItem.ITEM_HEIGHT/2})
	-- transition.moveTo(self.bg_, {time = 0.5, y = ChooseMatchRoomListItem.ITEM_HEIGHT/2})

    self:loadImageTexture(data)


    if data.playerCount then
        -- dump(data.playerCount,"data.playerCount==")
        self.playerCountLabel_:setString(data.playerCount .. "")
    end


    if data.isReg then
        self.buttonLabel:setString("已报名")
        self.btn_:setButtonEnabled(false)
    else
        self.buttonLabel:setString("报名")
        self.btn_:setButtonEnabled(true)
    end
	
end


function ChooseMatchRoomListItem:dealShowCountDown(delay)
    if self.isShowCountAction_ then
        self:stopAction(self.isShowCountAction_)
    end
    self.isShowCountAction_ = self:performWithDelay(handler(self,self.onDealShowCountDown),delay)
end

function ChooseMatchRoomListItem:onDealShowCountDown()
    -- self.remainTime_ = 3600
    local leftTime = self.remainTime_
    local leftTimeTb = bm.TimeUtil:getTimeDayTb(leftTime)
    -- dump(leftTimeTb,"onDealShowCountDown")
    if (leftTimeTb.day <= 0  and leftTimeTb.hour < 1)then
        -- 相隔小于1小时的显示倒计时
        self:showTime()
        self:countFun()
    end
end

return ChooseMatchRoomListItem