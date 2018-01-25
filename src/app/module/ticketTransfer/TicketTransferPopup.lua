

local TicketTransferPopup = class("TicketTransferPopup",function()
	return display.newNode()
end)

local WIDTH = 830
local HEIGHT = 400

local CONTENT_WIDTH = 785
local CONTENT_HEIGHT = 335

local TICKETS_IDS = {7101,7102,7104}

function TicketTransferPopup:ctor()

	self:setNodeEventEnabled(true)
	display.addSpriteFrames("ticketTransfer_texture.plist","ticketTransfer_texture.png")
	self.background_ = display.newScale9Sprite("#bg.png",0,0,cc.size(WIDTH,HEIGHT)):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)
	self.bg_ = display.newScale9Sprite("#bg.png",0,0,cc.size(WIDTH,HEIGHT))
	-- self.bg_:setCapInsets(cc.rect(250, 32, 4, 4))
    self.bg_:addTo(self)

    local bgIcon = display.newSprite("#bgIcon.png")
    local bgIconSize = bgIcon:getContentSize()
    bgIcon:pos(WIDTH/2 - bgIconSize.width/2,HEIGHT/2 - bgIconSize.height/2)
    :addTo(self)


    local title = display.newSprite("#title.png")
    :addTo(self)
    local titleSize = title:getContentSize()
    title:pos(0,HEIGHT/2 - 5)

    local startPos = {x = -CONTENT_WIDTH/2,y = CONTENT_HEIGHT/2}
    local tip1_title = display.newSprite("#tipTitle1.png")
    :align(display.TOP_LEFT,startPos.x,startPos.y)
    :addTo(self)

    local hSpeace = 5
    local tip1TitleSize = tip1_title:getContentSize()

    local tip1Label1Pos = {x = startPos.x,y = startPos.y - tip1TitleSize.height - hSpeace}
    local tip1 = bm.LangUtil.getText("TICKETTRANSFER", "TIPS_1")
    local tip2 = bm.LangUtil.getText("TICKETTRANSFER", "TIPS_2","1:1")
    local tip3 = bm.LangUtil.getText("TICKETTRANSFER", "TIPS_3")
    local tip4 = "4、" .. bm.LangUtil.getText("TICKETTRANSFER", "TIPS_4","2016.08.31")
    local tip5 = bm.LangUtil.getText("TICKETTRANSFER", "TIPS_5")

    local tempStr = string.format("1、%s\n2、%s\n3、%s",tip1,tip2,tip3)
    local tip1_label_1 = display.newTTFLabel({
	    text = tempStr,
	    -- font = "Arial",
	    size = 16,
	    color = cc.c3b(255, 255, 255), -- 使用纯红色
	    align = ui.TEXT_ALIGN_LEFT,
	    valign = ui.TEXT_VALIGN_TOP,
	    dimensions = cc.size(CONTENT_WIDTH, 0)
	})
	:align(display.TOP_LEFT,tip1Label1Pos.x,tip1Label1Pos.y)
	:addTo(self)

	local tip1_label_1Size = tip1_label_1:getContentSize()
	local tip1Label2Pos = {x = startPos.x,y = tip1Label1Pos.y - tip1_label_1Size.height - hSpeace}
	local tip1_label_2 = display.newTTFLabel({
	    text = tip4,
	    -- font = "Arial",
	    size = 16,
	    color = cc.c3b(0xf3, 0xe0, 0x03), -- 使用纯红色
	    align = ui.TEXT_ALIGN_LEFT,
	    valign = ui.TEXT_VALIGN_TOP,
	    dimensions = cc.size(CONTENT_WIDTH, 0)
	})
	:align(display.TOP_LEFT,tip1Label2Pos.x,tip1Label2Pos.y)
	:addTo(self)

	local tip1_label_2Size = tip1_label_2:getContentSize()
	local tip2_titlePos = {x = startPos.x,y = tip1Label2Pos.y - tip1_label_2Size.height -hSpeace}

	local tip2_title = display.newSprite("#tipTitle2.png")
    :align(display.TOP_LEFT,tip2_titlePos.x,tip2_titlePos.y)
    :addTo(self)

    local tip2_titleSize = tip2_title:getContentSize()

 
    local tickKey = string.format("match.ticket_%s",7104)
    local tickNum = checkint(nk.userData[tickKey])

    local ticketNumLabelPos = {x = startPos.x + tip2_titleSize.width+10,y = tip2_titlePos.y}
    self.ticketNumLabel_ = display.newTTFLabel({
	    text = bm.LangUtil.getText("TICKETTRANSFER","TICKET_NUM",0),
	    -- font = "Arial",
	    size = 20,
	    color = cc.c3b(0xff, 0xff, 0xff), 
	    align = ui.TEXT_ALIGN_LEFT,  
	})
	:align(display.TOP_LEFT,ticketNumLabelPos.x,ticketNumLabelPos.y)
	:addTo(self)




    local tip2_label_1Pos = {x = startPos.x,y = tip2_titlePos.y - tip2_titleSize.height - hSpeace}
    local tip2_label_1 = display.newTTFLabel({
	    text = tip5,
	    -- font = "Arial",
	    size = 16,
	    color = cc.c3b(0xf3, 0xe0, 0x03), -- 
	    align = ui.TEXT_ALIGN_LEFT,
	    valign = ui.TEXT_VALIGN_TOP,
	    dimensions = cc.size(CONTENT_WIDTH, 0)
	})
	:align(display.TOP_LEFT,tip2_label_1Pos.x,tip2_label_1Pos.y)
	:addTo(self)

	local tip2_label_1Size = tip2_label_1:getContentSize()
	local transIconPos = {x = startPos.x,y = tip2_label_1Pos.y - tip2_label_1Size.height}
	local transIcon = display.newSprite("#transIcon.png")
	:align(display.TOP_LEFT,transIconPos.x,transIconPos.y)
	:addTo(self)

	local transIconSize = transIcon:getContentSize()
	local transBtnPos = {x = startPos.x + transIconSize.width+10,y = transIconPos.y - transIconSize.height/2 - 15}
	local transBtnSize = {width = 198,height = 76}

	self.transBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png",disabled = "#common_btn_disabled.png"}, {scale9 = true})
        :setButtonSize(transBtnSize.width, transBtnSize.height) -- 8像素的透明边缘
        :align(display.CENTER_LEFT,transBtnPos.x,transBtnPos.y)
		:addTo(self)
		:setButtonLabel(display.newTTFLabel({
	    text = bm.LangUtil.getText("TICKETTRANSFER", "TRANS_BTN_LABEL"),
	    -- font = "Arial",
	    size = 32,
	    color = cc.c3b(0xff, 0xff, 0xff), -- 使用纯红色
	}))
        :onButtonClicked(buttontHandler(self, self.onTransBtnClick))

    self:addCloseBtn()

    

    local cashNumLabelPos = {x = startPos.x + transIconSize.width - 100,y = transIconPos.y - transIconSize.height + 5}
    self.cashNumLabel_ = display.newTTFLabel({
	    text = string.format("x%s",tickNum),
	    -- font = "Arial",
	    size = 20,
	    color = cc.c3b(0xff, 0xff, 0xff), -- 使用纯红色
	    -- align = ui.TEXT_ALIGN_LEFT,
	    -- valign = ui.TEXT_VALIGN_TOP,
	    -- dimensions = cc.size(CONTENT_WIDTH, 0)
	})
	-- :align(display.TOP_LEFT,cashNumLabelPos.x,cashNumLabelPos.y)
	:pos(cashNumLabelPos.x,cashNumLabelPos.y)
	:addTo(self)

	self:addDataObservers()
	self:getMatchHallInfo()
end



function TicketTransferPopup:addCloseBtn()

	local closeBtn = cc.ui.UIPushButton.new({normal = "#closeBtn.png", pressed="#closeBtn.png"})
            :pos(WIDTH * 0.5 - 22, HEIGHT * 0.5 - 22)
            :onButtonClicked(function() 
                    self:onClose()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 99)
end


function TicketTransferPopup:show()
	self:showPanel_(true,true,true,true)
end

function TicketTransferPopup:showPanel_(isModal, isCentered, closeWhenTouchModel, useShowAnimation)
    nk.PopupManager:addPopup(self, isModal ~= false, isCentered ~= false, closeWhenTouchModel ~= false, useShowAnimation ~= false)
    return self
end

function TicketTransferPopup:hidePanel_()
    nk.PopupManager:removePopup(self)
    return self
end

function TicketTransferPopup:onClose()
    self:hidePanel_()
end



function TicketTransferPopup:onCleanup()

	self:removeDataObserver()
	if self.requestMatchInfoId_ then
		nk.http.cancel(self.requestMatchInfoId_)
		self.requestMatchInfoId_ = nil
	end
	display.removeSpriteFramesWithFile("ticketTransfer_texture.plist","ticketTransfer_texture.png")

end

function TicketTransferPopup:getMatchHallInfo()
    local retryLimit = 3
    local loadConfigFunc
    requestFun = function()
            self.requestMatchInfoId_ = nk.http.matchHallInfo(function(data)
                self.requestMatchInfoId_ = nil
               -- if checkint(data.money) < 100000 then
               --      self.moneyLabel_:setString(bm.formatNumberWithSplit(checkint(data.money)))
               --  else
               --      self.moneyLabel_:setString(bm.formatBigNumber(checkint(data.money)))
               --  end
                nk.userData["match.point"] = checkint(data.point)
                -- self.cashLabel_:setString(bm.formatBigNumber(nk.userData["match.point"]))
                nk.userData["match.highPoint"] = checkint(data.highPoint)
                -- self.clubLabel_:setString(bm.formatBigNumber(nk.userData["match.highPoint"]))
                local tickets = data.tickets
                for i=1,#tickets do
                    local item = tickets[i]
                    -- if item.pnid == "7101" then
                    --     self.normalTicketLabel_:setString(item.pcnter)
                    -- elseif item.pnid == "7104" then
                    --     self.specialTicketLabel_:setString(item.pcnter)

                    -- elseif item.pnid == "7102" then
                    --     self.chujiTicketLabel_:setString(item.pcnter)
                    -- end

                    local tickKey = "match.ticket_" .. item.pnid
                    nk.userData[tickKey] = checkint(item.pcnter)
                    -- dump(nk.userData[tickKey],"getMatchHallInfo=========")
                end

            end,function(errData)
                self.requestMatchInfoId_ = nil
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    nk.schedulerPool:delayCall(function()
                        requestFun()
                    end, 1)
                else
                   
                end

            end)
    end

    requestFun()
end



function TicketTransferPopup:onTransBtnClick()
	self.transferRequestId_ =  nk.http.ticketTransfer(function(data)

			if not data then
				return 
			end

			local money = data.money
            local point = data.point
            local tickets = data.tickets
            local addpoint = data.addpoint



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

            


            nk.TopTipManager:showTopTip(bm.LangUtil.getText("TICKETTRANSFER", "SUCCESS",checkint(addpoint)))
	end,function(errData)
		nk.TopTipManager:showTopTip(bm.LangUtil.getText("TICKETTRANSFER", "FAIL"))
	end)
end


function TicketTransferPopup:addDataObservers()

	for _,v in pairs(TICKETS_IDS) do
        local propertyKey = string.format("match.ticket_%s",v)
        local ticketObserverHandle = string.format("ticket_%s_handle_",v)
        self[ticketObserverHandle] = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, propertyKey, handler(self, function (obj, pcnter)
   
            -- if v == 7101 then
            -- 	self.ticketNumLabel_:setString(pcnter)
            -- elseif v == 7104 then
            --     self.ticketNumLabel_:setString(pcnter)

            -- elseif v == 7102 then
            --     self.ticketNumLabel_:setString(pcnter)
            -- end
            if v == 7104 then
				self.ticketNumLabel_:setString(bm.LangUtil.getText("TICKETTRANSFER","TICKET_NUM",checkint(pcnter)))
				self.cashNumLabel_:setString(bm.LangUtil.getText("TICKETTRANSFER","CASH_NUM",checkint(pcnter)))
				self.transBtn_:setButtonEnabled((checkint(pcnter) > 0))
            end
            
        
        end))

    end

	
end

function TicketTransferPopup:removeDataObserver()
	for _,v in pairs(TICKETS_IDS) do
        local propertyKey = string.format("match.ticket_%s",v)
        local ticketObserverHandle = string.format("ticket_%s_handle_",v)
        bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, propertyKey, self[ticketObserverHandle])
    end
end

return TicketTransferPopup