local CornuRecordItem = class("CornuRecordItem", bm.ui.ListItem)

local WIDTH = 842
local HEIGHT = 38
function CornuRecordItem:ctor()
    self:setNodeEventEnabled(true)
    CornuRecordItem.super.ctor(self, WIDTH, HEIGHT)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    -- display.newScale9Sprite("#cor_words_bg.png", 0, 0, cc.size(WIDTH,HEIGHT))
    -- :addTo(self)
    -- :pos(WIDTH/2,HEIGHT/2)

    self.text_ = display.newTTFLabel({text = "", color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(WIDTH-20, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.CENTER_LEFT)
    :pos(10,HEIGHT/2)

    self.btn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(120, 30)
    :align(display.CENTER_LEFT)
    :pos(WIDTH-130,HEIGHT/2)
    :onButtonClicked(buttontHandler(self, self.goFriend_))
    :setButtonLabel("normal", display.newTTFLabel({text = T("去偷他>>"), color = cc.c3b(0xf0,0xff,0x00), size = 20, align = ui.TEXT_ALIGN_CENTER}))
    :addTo(self)
    
end
function CornuRecordItem:goFriend_(evt)
    self:dispatchEvent({name="ITEM_EVENT", data = self.data_})
end
function CornuRecordItem:onCleanup()
	
end
function CornuRecordItem:onDataSet(changedata,data)
    self.data_ = data
    local date = ""..data.date.." "..data.time.." "
    local name = data.fnickname
    if name then
        local str = nk.Native:getFixedWidthText("", 20, (name or ""), 105)
        name = str
    end
    local getMoney = ""..data.getmoney

    if checkint(data.msgtype)==1 then
        if checkint(data.type) == 401 then
            local mode = bm.LangUtil.getText("DORNUCOPIA", "RECORD_MESSAGE")[1]
            local str = bm.LangUtil.formatString(mode,date,getMoney)
            self.text_:setString(str)
            self.btn_:hide()
        else
            local mode = bm.LangUtil.getText("DORNUCOPIA", "RECORD_MESSAGE")[2]
            local str = bm.LangUtil.formatString(mode,date,getMoney)
            self.text_:setString(str)
            self.btn_:hide()
        end
    elseif checkint(data.msgtype) == 2 then
        self.btn_:show()
        if checkint(data.type) == 401 then
            local mode = bm.LangUtil.getText("DORNUCOPIA", "RECORD_MESSAGE")[5]
            local str = bm.LangUtil.formatString(mode,date,name,getMoney)
            self.text_:setString(str)
        else
             local mode = bm.LangUtil.getText("DORNUCOPIA", "RECORD_MESSAGE")[6]
            local str = bm.LangUtil.formatString(mode,date,name,getMoney)
            self.text_:setString(str)
        end
    elseif checkint(data.msgtype) == 3 then
        self.btn_:hide()
         if checkint(data.type) == 401 then
            local mode = bm.LangUtil.getText("DORNUCOPIA", "RECORD_MESSAGE")[3]
            local str = bm.LangUtil.formatString(mode,date,name,getMoney)
            self.text_:setString(str)
        else
             local mode = bm.LangUtil.getText("DORNUCOPIA", "RECORD_MESSAGE")[4]
            local str = bm.LangUtil.formatString(mode,date,name,getMoney)
            self.text_:setString(str)
        end
    end

    -- "{1}收获了银种子，获得了{2}筹码"
    -- "{1}收获了金种子，获得了{2}筹码"

    -- "{1}偷取了好友{2}的银种子，获得了{3}筹码"
    -- "{1}偷取了好友{2}的金种子，获得了{3}筹码"

    -- "{1}好友{2}偷取了我的银种子，失去了{3}筹码"
    -- "{1}好友{2}偷取了我的金种子，失去了{3}筹码"
end
return CornuRecordItem