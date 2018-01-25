--
-- Author: Tom
-- Date: 2014-12-30 16:41:00
--
local WIDTH = 478
local HEIGHT = 329


local LoginFeedBackListItem = class("FeedbackListItem", bm.ui.ListItem)
LoginFeedBackListItem.WIDTH  = 454
LoginFeedBackListItem.HEIGHT = 70

function LoginFeedBackListItem:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    LoginFeedBackListItem.super.ctor(self, LoginFeedBackListItem.WIDTH, LoginFeedBackListItem.HEIGHT)
    self:setNodeEventEnabled(true)
    self.iconOriginX = 10

    self.container = display.newNode():addTo(self)

    --问题图标
    self.icon = display.newSprite("#help_question_icon.png"):addTo(self.container)
    self.iconSize = self.icon:getContentSize()
    self.icon:pos(self.iconOriginX + self.iconSize.width/2, LoginFeedBackListItem.HEIGHT/2 + self.iconSize.height/2)

    local labelSize = 24
    local questionLabelColor = cc.c3b(0x64, 0x9a, 0xc9)
    local answerLabelColor = cc.c3b(0x27, 0x90, 0xd5)
    local labelSizePadding = 80

    --问题
    self.questionLabel = display.newTTFLabel({
            size = labelSize,
            color = questionLabelColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(LoginFeedBackListItem.WIDTH - labelSizePadding, 0)
        })
        :addTo(self.container)

    --回答
    self.answerLabel = display.newTTFLabel({
            size = labelSize,
            color = answerLabelColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(LoginFeedBackListItem.WIDTH - labelSizePadding, 0)
        })
        :addTo(self.container)
end


function LoginFeedBackListItem:onDataSet(dataChanged, data)
    if dataChanged then
        self.questionLabel:setString(data.content)
        
        local questionLabelSize = self.questionLabel:getContentSize()
        local questionLabelMarginLeft = 12

        self.answerLabel:setString(data.answer)
        
        local answerLabelMarginTop = questionLabelSize.height + 8
        local answerLabelSize = self.answerLabel:getContentSize()

        local padding = 5
        local lineSpacing = 10
        local h = padding * 2 + lineSpacing
        h = h + self.questionLabel:getContentSize().height
        h = h + self.answerLabel:getContentSize().height
        self:setContentSize(cc.size(LoginFeedBackListItem.WIDTH, h))

        self.icon:pos(self.iconOriginX + self.iconSize.width/2, h - self.iconSize.height/2)
        self.questionLabel:pos(self.iconOriginX + self.iconSize.width + questionLabelMarginLeft + questionLabelSize.width/2, 
                    h  - questionLabelSize.height/2)
        self.answerLabel:pos(self.iconOriginX + answerLabelSize.width/2, h - answerLabelSize.height/2 - answerLabelMarginTop)    
    end
end


local LoginFeedBack = class("LoginFeedBack", nk.ui.Panel)
local FeedbackCommon = import("app.module.feedback.FeedbackCommon")
function LoginFeedBack:ctor()
    LoginFeedBack.super.ctor(self,{WIDTH,HEIGHT})

    self:setNodeEventEnabled(true)
    
    local TOP = self.height_*0.5
    local BOTTOM = -self.height_*0.5
    local LEFT = -self.width_*0.5
    local RIGHT = self.width_*0.5
    local TOP_HEIGHT = 64

    self:addCloseBtn()
    -- self.title_ = display.newTTFLabel({text=bm.LangUtil.getText("LOGIN", "FEED_BACK_TITLE"), size=30, color=cc.c3b(0xd7, 0xf6, 0xff), align=ui.TEXT_ALIGN_CENTER})
    --     :pos(0, TOP - 35)
    --     :addTo(self)

    local contentWidth = WIDTH
    local contentHeight = HEIGHT
    local upContentHeight = 200

    local contentPadding = 12 

    --多行输入框
    local inputWidth  = 454
    local inputHeight = 136
    local inputContentSize = 20
    local inputContentColor = cc.c3b(0xca, 0xca, 0xca)
    self.inputEditBox = cc.ui.UIInput.new({
            image = "#common_input_bg.png",
            imagePressed="#common_input_bg_down.png", 
            size = cc.size(inputWidth, inputHeight),
            x = -(contentWidth/2 - contentPadding - inputWidth/2),
            y = 30,
            listener = handler(self, self.onContentEdit_)
        })
        :addTo(self)
    self.inputEditBox:setTouchSwallowEnabled(false)
    self.inputEditBox:setFontColor(inputContentColor)
    self.inputEditBox:setPlaceholderFontColor(inputContentColor)
    self.inputEditBox:setFont(ui.DEFAULT_TTF_FONT, inputContentSize)
    self.inputEditBox:setPlaceholderFont(ui.DEFAULT_TTF_FONT, inputContentSize)
    self.inputEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.inputEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

    self.showContent = display.newTTFLabel({
            text = "",
            size = inputContentSize,
            color = inputContentColor,
            align = ui.TEXT_ALIGN_LEFT,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(inputWidth - 30, inputHeight - 30)
        })
        :addTo(self):pos(-(contentWidth/2 - contentPadding - inputWidth/2), contentHeight/2 - contentPadding - inputHeight/2 - 55)
        :size(inputWidth, inputHeight)
    self.showContent:setString(bm.LangUtil.getText("LOGIN", "FEED_BACK_HINT"))

    self.inputTextBox = display.newNode():pos(17,-70):addTo(self)
    self.input1_ = cc.ui.UIInput.new({
            image = "#common_input_bg.png",
            imagePressed = "#common_input_bg_down.png",
            size = cc.size(323, 38),
            align = ui.TEXT_ALIGN_CENTER
    }):pos(0,0):addTo(self.inputTextBox, 100)
    self.input1_:setFontName(ui.DEFAULT_TTF_FONT)
    self.input1_:setFontSize(20)
    self.input1_:setFontColor(inputContentColor)
    self.input1_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.input1_:setPlaceholderFontSize(20)
    self.input1_:setPlaceholderFontColor(inputContentColor)
    self.input1_:setPlaceHolder(bm.LangUtil.getText("LOGIN", "PHONE_NUMBER"))
    self.input1_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.input1_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    
    display.newSprite("phone_num.png"):pos(-323/2-15, 0):addTo(self.inputTextBox, 101)

    self.sendButton_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png",pressed = "#common_green_btn_down.png"},{scale9 = true})
    :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "SEND"),size = 26,color = cc.c3b(0xd6, 0xff, 0xef),align = ui.TEXT_ALIGN_CENTER}))
    :setButtonSize(132, 41)
    :pos(0, BOTTOM + 37)
    :onButtonClicked(buttontHandler(self, self.sendFeedBackHandler_))
    :addTo(self)





     local listWidth  = 454
    local listHeight = 180

    self.feedbackListNode = display.newNode()
    :addTo(self)
    :hide()
    local listItemTitleColor = cc.c3b(0x56, 0xae, 0xf3)
    local listItemTitleSize = 24
    local noFeedbackHintMarginTop = 24

    --没有反馈提示
    self.noFeedbackHint = display.newTTFLabel({
            text = bm.LangUtil.getText("HELP", "NO_FEED_BACK"),
            color = listItemTitleColor,
            size = listItemTitleSize,
            align = ui.TEXT_ALIGN_CENTER
        })
        :addTo(self.feedbackListNode)
        :hide()

    self.feedbackList = bm.ui.ListView.new({viewRect = cc.rect(-0.5 * listWidth, -0.5 * listHeight, listWidth, listHeight), 
                                direction = bm.ui.ListView.DIRECTION_VERTICAL}, LoginFeedBackListItem):addTo(self.feedbackListNode)
        :pos(0, 0)
    self.feedbackList:setNotHide(true)




   
    self.tabBar_ = nk.ui.TabBarWithIndicator.new(
        {
            background = "#popup_sub_tab_bar_bg.png", 
            indicator = "#popup_sub_tab_bar_indicator.png"
            }, 
        bm.LangUtil.getText("LOGIN", "FEED_BACK_TABBAR_LABEL"), 
        nil, 
        true, 
        true
    )
        self.tabBar_:addTo(self)
    
    
    self.tabBar_:setTabBarSize(300, 40, -4, -4)
    self.tabBar_:pos(0, 120)
    self.tabBar_:onTabChange(handler(self, self.onTabBarChange_))
    self.tabBar_:gotoTab(1, true)




    




    local testDatas = {
        {answer = "12321",content = "454645"},
        {answer = "dadasdad",content = "eewewweq"}
    }


    -- self:setFeedbackList(testDatas)



    self:getFeedBackList();

end

function LoginFeedBack:setFeedbackList(data)
    if data and #data > 0 then 
        self.feedbackListData = data
        self.feedbackList:show()
        self.noFeedbackHint:hide()
        self.feedbackList:setData(data)
        self.feedbackList:update()
    else 
        self.feedbackListData = {}
        self.feedbackList:hide()
        self.noFeedbackHint:show()
    end

end


function LoginFeedBack:onShowed()
    self.feedbackList:setScrollContentTouchRect()
end

function LoginFeedBack:onTabBarChange_(selectedTab)
    self.inputEditBox:setVisible(selectedTab == 1)
    self.showContent:setVisible(selectedTab == 1)
    self.inputTextBox:setVisible(selectedTab == 1)
    self.feedbackListNode:setVisible(selectedTab == 2)
end

function LoginFeedBack:onContentEdit_(event, editbox)
    if event == "began" then
        -- 开始输入
        local displayingText = self.showContent:getString()
        if displayingText == bm.LangUtil.getText("LOGIN", "FEED_BACK_HINT") then
            self.inputEditBox:setText("")
        else
            self.inputEditBox:setText(displayingText)
        end
        self.showContent:setString("")
    elseif event == "changed" then
        -- 输入框内容发生变化
    elseif event == "ended" then
        -- 输入结束
        local text = editbox:getText()
        if text == "" then 
            text = bm.LangUtil.getText("LOGIN", "FEED_BACK_HINT")
        end
        self.showContent:setString(text)
        editbox:setText("")
    elseif event == "return" then
        -- 从输入框返回
    end
end

function LoginFeedBack:sendFeedBackHandler_()
    if self.showContent:getString() ==  bm.LangUtil.getText("LOGIN", "FEED_BACK_HINT") then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_TEXT_MSG"))
        return
    end
    
    local phone = string.trim(self.input1_:getText())
    if string.len(phone) == 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_PHONE_NUM"))
        return 
    end

    local postParam = {
        title = "",
        ftype = 402,
        fwords = "login feedback:"..self.showContent:getString(),
        fcontact = "phone:"..phone
    }

    local postExt

    local lastLoginMid = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_MID)
    if lastLoginMid and string.len(lastLoginMid) > 0 then
        postExt = {}
        postExt.mid = tonumber(lastLoginMid) or nk.Native:getLoginToken()
    end

    FeedbackCommon.sendFeedback(postParam,function(succ,reason)
            if succ then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEED_BACK_SUCCESS"))
                self.showContent:setString(bm.LangUtil.getText("LOGIN", "FEED_BACK_HINT"))
                self:hide()
            else
                if reason == "network" then
                    nk.TopTipManager:showTopTip(bm.LanUtil.getText("COMMON", "BAD_NETWORK"))
                else
                    -- FIXME:其他错误时报错信息
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                end
            end
        end,postExt)    

    local version = BM_UPDATE and BM_UPDATE.VERSION or nk.Native:getAppVersion()
    local params = {
            mod = "Feedback",
            act = "sendEmail",           
            msg = "login feedback: <br />&nbsp;&nbsp;&nbsp;&nbsp;"..self.showContent:getString() .. "<br />".."version: ".. version .."<br />" .."phone: "..phone,
            time = bm.getTime(),           
            sig = crypto.md5(bm.getTime().."feedback_befor_login@#$%^"),
            lid = 1,
            sid = appconfig.ROOT_CGI_SID,
            version = version
        }
    local feedBackUrl = BM_UPDATE.FEEDBACK_URL
    if string.len(feedBackUrl) > 5 then
            bm.HttpService.POST_URL(feedBackUrl,
            params         
        )
    end
end


function LoginFeedBack:getFeedBackList()
    local feedList = {}
    local g = 1
    local postExt

    local lastLoginMid = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_MID)
    if lastLoginMid and string.len(lastLoginMid) > 0 then
        postExt = {}
        postExt.mid = tonumber(lastLoginMid) or nk.Native:getLoginToken()
    end

    FeedbackCommon.getFeedbackList(function(succ,feedbackRetData)

        dump(feedbackRetData,"getFeedBackList=========")
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
            -- self.view_:getFeedbackView():setFeedbackList(feedList)
            self:setFeedbackList(feedList)
        end
    end,postExt)
end


function LoginFeedBack:show()
    self:showPanel_()
end

function LoginFeedBack:hide()
    self:hidePanel_()
end

return LoginFeedBack