--
-- Author: ThinkerWang
-- Date: 2015-09-14 12:14:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Create personal room dialog

local Panel = import("app.pokerUI.Panel")

local CreateRoomPopup = class("CreateRoomPopup", Panel)

local PasswordPanel = import(".ImputPasswordPanel")

local PersonelRoomHelpPopup = import(".PersonelRoomHelpPopup")

local SCALE_VALUE = 1
local WIDTH = 810 *SCALE_VALUE
local HEIGHT = 542 *SCALE_VALUE
local TOP_HEIGHT = 52 *SCALE_VALUE

local CONTENT_WIDHT = 780 *SCALE_VALUE
local CONTENT_HEIGHT = 400 *SCALE_VALUE

local BUTTON_BOTTOM_GAP = 42 *SCALE_VALUE

local BUTTON_W = 230  *SCALE_VALUE
local BUTTON_H = 55 *SCALE_VALUE

local TEXT_WIDTH = 200 
local TEXT_HEIGHT = 50 

local TEXT_LEFT = 225
local TEXT_TOP = 120
local TEXT_GAP = 55

local TEXT_BG_HEIGHT = 52 *0.8


function CreateRoomPopup:ctor()
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
	self:createNode_()
end

function CreateRoomPopup:createNode_()
	display.newScale9Sprite("#per_createBg.png", 0, 0, cc.size(WIDTH,HEIGHT ))
    :pos(0,0)
    :addTo(self)
    

	display.newScale9Sprite("#per_createTiltbg.png", 0, 0, cc.size(WIDTH-10,TOP_HEIGHT ))
    :pos(0,HEIGHT/2 - TOP_HEIGHT/2)
    :addTo(self)

    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#per_closeBtn.png", pressed="#per_closeBtn.png"})
    :pos(WIDTH * 0.5 - 30, HEIGHT * 0.5 - 27)
    :onButtonClicked(function() 
        self:onClose()
        nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
    end)
    :addTo(self, 99)
    

    display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_TITLE"), color = cc.c3b(0xC5, 0xdc, 0xF4), size = 24})
    :addTo(self)
    :pos(0,HEIGHT/2 - TOP_HEIGHT/2)
    

    self.contentBg_ = display.newScale9Sprite("#per_content_bg.png", 0, 0, cc.size(CONTENT_WIDHT,CONTENT_HEIGHT ))
    :pos(0, 10)
    :addTo(self)
    self.contentBg_:setTouchEnabled(true)
    self.contentBg_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onHidePasswordView_))

    self.createChipRoomText_ = display.newTTFLabel({text = bm.LangUtil.getText("HALL","PERSONAL_ROOM_CREATE_CHIP_ROOM"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 20, align = ui.TEXT_ALIGN_CENTER})
    cc.ui.UIPushButton.new({normal = "#per_createRoomBtn_normal.png", pressed = "#per_createRoomBtn_click.png"}, {scale9 = true})
    :setButtonSize(BUTTON_W, BUTTON_H)
    :addTo(self)
    :setButtonLabel("normal", self.createChipRoomText_)
    :onButtonClicked(buttontHandler(self, self.onCreateChipRoom_))
    :pos(0,-HEIGHT/2 + BUTTON_BOTTOM_GAP)

    for i=1,5 do
    	display.newTTFLabel({text = bm.LangUtil.getText("HALL","PERSONAL_ROOM_CREATE")[i], color = cc.c3b(0xC5, 0xdc, 0xF4), size = 20, dimensions = cc.size(TEXT_WIDTH, TEXT_HEIGHT),align = ui.TEXT_ALIGN_RIGHT})
    	:addTo(self)
    	:pos(-TEXT_LEFT,TEXT_TOP-(i-1)*TEXT_GAP)
    	:setContentSize(TEXT_WIDTH,TEXT_HEIGHT)
    end
  

    display.newScale9Sprite("#per_text_bg.png", 0, 0, cc.size( 352,TEXT_BG_HEIGHT))
    :pos(-90, TEXT_TOP)
    :align(display.LEFT_CENTER)
    :addTo(self)

    self.baseChipBg_ = display.newScale9Sprite("#per_text_bg.png", 0, 0, cc.size( 220,TEXT_BG_HEIGHT))
    :pos(-90, TEXT_TOP - TEXT_GAP)
    :align(display.LEFT_CENTER)
    :addTo(self)
    self.baseChipBg_:setTouchEnabled(true)
    self.baseChipBg_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onBaseChipTouch_))

    display.newScale9Sprite("#per_text_bg.png", 0, 0, cc.size( 220,TEXT_BG_HEIGHT))
    :pos(-90, TEXT_TOP - 2*TEXT_GAP)
    :align(display.LEFT_CENTER)
    :addTo(self)

    self.serviceCharge_ = display.newTTFLabel({text = "10%", color = cc.c3b(0xff, 0xd2, 0x00), size = 20, dimensions = cc.size(TEXT_WIDTH, TEXT_HEIGHT),align = ui.TEXT_ALIGN_LEFT})
    	:addTo(self)
    	:pos(10,TEXT_TOP-(4-1)*TEXT_GAP)
    	--:setContentSize(TEXT_WIDTH,TEXT_HEIGHT)


    self.lowBuyIn_ = display.newTTFLabel({text = "2000", color = cc.c3b(0xff, 0xd2, 0x00), size = 20, dimensions = cc.size(TEXT_WIDTH, TEXT_HEIGHT),align = ui.TEXT_ALIGN_LEFT})
    	:addTo(self)
    	:pos(10,TEXT_TOP-(5-1)*TEXT_GAP)
    	--:setContentSize(TEXT_WIDTH,TEXT_HEIGHT)

    cc.ui.UIPushButton.new("#per_questions.png")
    :addTo(self)
    :onButtonClicked(buttontHandler(self, self.onCheckPersonalRoomInfo_))
    :pos(46,-66)
    :setScale(0.8)
    

     self.editRoomName_ = cc.ui.UIInput.new({
        size = cc.size(352, TEXT_BG_HEIGHT),
        align=ui.TEXT_ALIGN_LEFT,
        image="#transparent.png",
        x = 90,
        y = TEXT_TOP,
        listener = handler(self, self.onRoomNameEdit_)
    })

    self.editRoomName_:setMaxLength(330)
    self.editRoomName_:setContentSize(cc.size(352, TEXT_BG_HEIGHT))
    self.editRoomName_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editRoomName_:setFontSize(25)
    self.editRoomName_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editRoomName_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editRoomName_:setPlaceholderFontSize(25)
    self.editRoomName_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editRoomName_:setPlaceHolder(bm.LangUtil.getText("HALL", "PERSONAL_ROOM_CREATE")[6])
    self.editRoomName_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editRoomName_:setReturnType(cc.KEYBOARD_RETURNTYPE_GO)
    self.editRoomName_:addTo(self) 



    self.editRoomPassWord_ = cc.ui.UIInput.new({
        size = cc.size(220, TEXT_BG_HEIGHT),
        align=ui.TEXT_ALIGN_LEFT,
        image="#transparent.png",
        x = 0+20,
        y = TEXT_TOP - 2*TEXT_GAP,
        listener = handler(self, self.onRoomPassWordEdit_)
    })

    self.editRoomPassWord_:setMaxLength(220)
    self.editRoomPassWord_:setContentSize(cc.size(220, TEXT_BG_HEIGHT))
    self.editRoomPassWord_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editRoomPassWord_:setFontSize(25)
    self.editRoomPassWord_:setFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editRoomPassWord_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editRoomPassWord_:setPlaceholderFontSize(25)
    self.editRoomPassWord_:setPlaceholderFontColor(cc.c3b(0x92, 0x8d, 0x8d))
    self.editRoomPassWord_:setPlaceHolder(bm.LangUtil.getText("HALL", "PERSONAL_ROOM_CREATE")[7])
    self.editRoomPassWord_:setReturnType(cc.KEYBOARD_RETURNTYPE_GO)
    self.editRoomPassWord_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editRoomPassWord_:addTo(self) 
    --dimensions = cc.size(247, TEXT_HEIGHT),
    display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_CREATE")[8], color = cc.c3b(0xC5, 0xdc, 0xF4), size = 20, align = ui.TEXT_ALIGN_LEFT})
    	:addTo(self)
    	:pos(250,TEXT_TOP-(3-1)*TEXT_GAP-5)
    	--:setContentSize(TEXT_WIDTH,TEXT_HEIGHT)


    self.baseChipLabel_ = display.newTTFLabel({text = "100", color = cc.c3b(0x92, 0x8d, 0x8d), size = 25, dimensions = cc.size(TEXT_WIDTH, TEXT_HEIGHT),align = ui.TEXT_ALIGN_LEFT})
    	:addTo(self)
    	:pos(20,TEXT_TOP-(2-1)*TEXT_GAP)
    	--:setContentSize(TEXT_WIDTH,TEXT_HEIGHT)
    self.curString = "100"
    self.imputString = ""
end
function CreateRoomPopup:onRoomNameEdit_(event)
	if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化是
        self.roomNameEdit_ = self.editRoomName_:getText()
    elseif event == "ended" then
        
    elseif event == "returnGo" then
    elseif event == "return" then
        -- 从输入框返回
    end
end
function CreateRoomPopup:onRoomPassWordEdit_(event)
	if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化是
        self.roomPasswordEdit_ = self.editRoomPassWord_:getText()
    elseif event == "ended" then
        
    elseif event == "returnGo" then
    elseif event == "return" then
        -- 从输入框返回
    end
end
function CreateRoomPopup:onCleanup( ... )
	-- body
end

function CreateRoomPopup:show(gid)
    self:showPanel_()
    return self
end
function CreateRoomPopup:onShowed()

end
function CreateRoomPopup:onBaseChipTouch_()
    if not self.passwordView_ then 
        self.editRoomPassWord_:setTouchEnabled(false)
        self.passwordView_ = PasswordPanel.new(self):addTo(self)
        self.passwordView_.onCleanupOut = function()
            self.editRoomPassWord_:setTouchEnabled(true)
        end


    else
        self.passwordView_:removeFromParent()
        self.passwordView_ = nil
    end
    --self.imputString = ""
    if self.infoTips_ then
        self.infoTips_:removeFromParent()
        self.infoTips_ = nil
    end
end
function CreateRoomPopup:onHidePasswordView_()
    if self.passwordView_ then
        self.passwordView_:removeFromParent()
        self.passwordView_ = nil
    end
    if self.infoTips_ then
        self.infoTips_:removeFromParent()
        self.infoTips_ = nil
    end
end
function CreateRoomPopup:onCreateChipRoom_()

    local roomName_ = ""
    local roomPassword_ = ""
    local roomBaseChips = tonumber(self.curString)

	if not self.roomNameEdit_ or #self.roomNameEdit_ == 0 or self.roomNameEdit_ == " " then
        roomName_ = bm.LangUtil.getText("HALL","PERSONAL_ROOM_DEF_ROOMNAME")
	else
        roomName_ = self.roomNameEdit_;
    end

	if not self.roomPasswordEdit_ or #self.roomPasswordEdit_==0 or self.roomPasswordEdit_== " " then
        roomPassword_ = nil;
	else
        roomPassword_ = self.roomPasswordEdit_;
    end

    if roomPassword_ ~= nil and string.len(string.trim(roomPassword_)) ~= 6 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL","PERSONAL_ROOM_CREATE")[7])
        return
    end

    if nk.userData["aUser.money"]< 20 * tonumber(self.curString) then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL", "PERSONAL_ROOM_NOT_ENOUGH"))
        return
    end

	nk.server:createPersonalRoom(nil,roomBaseChips,roomName_,roomPassword_)

    self:onClose()
end

function CreateRoomPopup:changeBaseChip_(label)
    --self.baseChip_ 底注
    --self.lowBuyIn_ 最小进入 *20
    --self.serviceCharge_ 服务费 1/10
    if string.len(self.imputString) ==0 and label:getString() == "0" then
        --nk.TopTipManager:showTopTip("fuck dandan")
        return
    end
    self.imputString = self.imputString..label:getString()
    self.curString =self.imputString.."00"
    if tonumber(self.curString) >= 1000000 then
        self.curString = "1000000"
        self.imputString = "10000"
    end
    --self.baseChipLabel_:setString(bm.formatNumberWithSplit(self.curString))
    self:setOtherNum_()
end

--local fuckyou = 1
function CreateRoomPopup:onOk_()
    self:onHidePasswordView_()
    --fuckyou = fuckyou+1
    --nk.TopTipExManager:showTopTip({text = "您的好友xxx邀请您到其私人房一起游戏"..fuckyou,buttonLabel = "ตอบรับคำเชิญ",callback = function()  end})
end

function CreateRoomPopup:onDelete_()
    if self.curString == "100" then
        self.imputString = ""
        return 
    end
    if #self.imputString == 1 then
        self.curString = "100"
        self.imputString = ""
        self:setOtherNum_()
        return
    end

    local curLength = string.len(self.imputString)
    local currentString = string.sub(self.imputString,0,curLength-1)
    self.imputString = currentString
    self.curString = self.imputString.."00"
    self:setOtherNum_()
    
end

function CreateRoomPopup:setOtherNum_()
    self.baseChipLabel_:setString(bm.formatNumberWithSplit(self.curString))
    self.lowBuyIn_:setString(20 * tonumber(self.curString))
    -- self.serviceCharge_:setString(1/10 * tonumber(self.curString))
end

function CreateRoomPopup:onCheckPersonalRoomInfo_()
    if not self.infoTips_  then
        self.infoTips_ = display.newNode();
        display.newScale9Sprite("#per_tipsbg.png", 0, 0, cc.size(280,130 ))
        :addTo(self.infoTips_)
        self.infoTips_:addTo(self)
        self.infoTips_:pos(220,-100)
        local str = ""
        -- for i=1,2 do
            str = str..bm.LangUtil.getText("HALL","PERSONAL_CREATE_ROOM_TIPS")
        -- end
        display.newTTFLabel({text =str , color = cc.c3b(0xC5, 0xdc, 0xF4), size = 20, dimensions = cc.size(270, 120),align = ui.TEXT_ALIGN_LEFT})
        :addTo(self.infoTips_)
    else
        self.infoTips_:removeFromParent()
        self.infoTips_ = nil
    end
end
return CreateRoomPopup