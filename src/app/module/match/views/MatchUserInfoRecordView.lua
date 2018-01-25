-- Author: thinkeras3@163.com
-- Date: 2015-10-26 10:0:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 获奖记录
local WIDTH = 745
local HEIGHT = 332--318
local MatchRecordItem = import(".MatchRecordItem")
local MatchUserInfoRecordView = class("MatchUserInfoRecordView", function() return display.newNode() end)
function MatchUserInfoRecordView:ctor(updateCallback)
    self.updateCallback_ = updateCallback
    self:setNodeEventEnabled(true)
     cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    display.addSpriteFrames("match.plist", "match.png")
	self.modal_ = display.newScale9Sprite("#common_transparent_skin.png", 0, 0, cc.size(display.width, display.height))
        :addTo(self)
        self.modal_:setTouchEnabled(true)
        self.modal_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.hideSelf_))


	self.background_ = display.newScale9Sprite("#panel_bg.png", 0, 0, cc.size(WIDTH,HEIGHT ))
    :pos(0,-70)
    :addTo(self)

    display.newScale9Sprite("#match_record_bg.png",0,0,cc.size(WIDTH-20,HEIGHT-70))
    :addTo(self)
    :pos(0,-HEIGHT/3+20)

    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)
    

    if not self.closeBtn_ then
        self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
            :pos(WIDTH * 0.5 - 15, HEIGHT * 0.5 - 22 - 70)
            :onButtonClicked(function() 
                    self:onClose()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 99)
    end

    display.newSprite("#match_ticket.png")
    :addTo(self)
    :pos(-WIDTH * 0.5 + 35, HEIGHT * 0.5 - 22 - 75)

    local mytxt_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "TICKET_NUM"), color = cc.c3b(0x86,0x94,0xc1), size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_CENTER)
    :pos(-WIDTH * 0.5 + 70, HEIGHT * 0.5 - 22 - 75)

    local mytxtSize = mytxt_:getContentSize()
    self.myTicket_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "PICS","0"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_CENTER)
    :pos(-WIDTH * 0.5 + 70 + mytxtSize.width +20, HEIGHT * 0.5 - 22 - 75)


    display.newSprite("#tong_big_ticket.png")
    :addTo(self)
    :pos(-WIDTH * 0.5 + 335, HEIGHT * 0.5 - 22 - 75)
    :setScale(.5)

     display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "TICKET_NUM_COMMON"), color = cc.c3b(0x86,0x94,0xc1), size = 20,dimensions = cc.size(200, 24), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(-WIDTH * 0.5 + 485, HEIGHT * 0.5 - 22 - 75)

    self.tongTicket_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "PICS","0"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    :addTo(self)
    :pos(-WIDTH * 0.5 + 565, HEIGHT * 0.5 - 22 - 75)

	-- display.newScale9Sprite("#match_record_content_bg.png", 0, 0, cc.size(WIDTH-20,255 ))
 --    --:pos(0,HEIGHT/2 - TOP_HEIGHT/2)
 --    :addTo(self)

    self.no_record_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH", "AWARD_NONE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    :addTo(self)
    :pos(0,-HEIGHT/3+20)
end

function MatchUserInfoRecordView:onCleanup()
    if self.matchRecordRequestId_ then
        nk.http.cancel(self.matchRecordRequestId_)
    end

    if self.getUserTicketsRequestId_ then
        nk.http.cancel(self.getUserTicketsRequestId_)
    end
    
    display.removeSpriteFramesWithFile("match.plist", "match.png")
end
function MatchUserInfoRecordView:updateView(data)
    if data.highPoint then
        nk.userData.match.highPoint = tonumber(data.highPoint)
        nk.userData["match.highPoint"] = tonumber(data.highPoint)
    end
    if data.point then
        nk.userData.match.point = tonumber(data.point)
        nk.userData["match.point"] = tonumber(data.highPoint)
    end
    self:upDateTicket()
    if self.updateCallback_ then
        self.updateCallback_()
    end
end
function MatchUserInfoRecordView:onShowed()
        -- self.action_ = self:schedule(function ()
        -- self:stopAction(self.action_)

        self.list_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-720* 0.5 , -248 * 0.5, 720, 248),
            direction = bm.ui.ListView.DIRECTION_VERTICAL
        }, 
            MatchRecordItem
    )
    :pos(0,-HEIGHT/3+20)
    :addTo(self)

    self.list_.updateView = handler(self,self.updateView)
    
        self.list_:update()
        self.list_:update()

    --end, 0.5)

   
    self:setLoading(true)
    self.matchRecordRequestId_ = nk.http.getMatchRecord(
    function(data)
        self:setLoading(false) 
        self.list_:setData(data)
        self.no_record_:setVisible(false)
        if data==nil or #data == 0 then
            self.no_record_:setVisible(true)
        end  
    end,
    function(error)
        self:setLoading(false)
        self.no_record_:setVisible(true)
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
    end
    )

    self:upDateTicket()
end

function MatchUserInfoRecordView:upDateTicket()
    local totalTickets = 0
    local tongTickets = 0
    self.getUserTicketsRequestId_ = nk.http.getUserTickets(
        function(data)
            for k,v in pairs(data) do
                
                if checkint(v.pnid) == 7104 then
                    tongTickets = tonumber(v.pcnter)
                else
                    totalTickets = totalTickets + tonumber(v.pcnter)
                end
            end
            self.myTicket_:setString(bm.LangUtil.getText("MATCH", "PICS",totalTickets))
            self.tongTicket_:setString(bm.LangUtil.getText("MATCH", "PICS",tongTickets))
        end,
        function(error)

        end
    )
end
function MatchUserInfoRecordView:show()
	nk.PopupManager:addPopup(self,false,nil,true,false)
    self:onShowed()
end
function MatchUserInfoRecordView:hideSelf_()
	nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
    nk.PopupManager:removePopup(self)
end
function MatchUserInfoRecordView:onClose()
    nk.PopupManager:removePopup(self)
    return self
end
function MatchUserInfoRecordView:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, -50)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end
return MatchUserInfoRecordView	