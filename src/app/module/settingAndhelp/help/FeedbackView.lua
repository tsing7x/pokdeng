--
-- Author: viking@boomegg.com
-- Date: 2014-08-28 15:25:08
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FeedbackView = class("FeedbackView", function ()
    return display.newNode()
end)

local FeedbackListItem = import(".listItems.FeedbackListItem")
local FeedbackCommon = import("app.module.feedback.FeedbackCommon")
local logger = bm.Logger.new("FeedbackView")

FeedbackView.feedbackInfo = {
    uid = "",
    tid = "",
    model = ""
}

function FeedbackView:ctor(helpView)
    self:setNodeEventEnabled(true)
    self.helpView_ = helpView
    self.feedbackListData = {}
    self.viewRectWidth_, self.viewRectHeight_ = helpView.viewRectWidth, helpView.viewRectHeight
    self.controller_ = helpView.controller_
    self:setupView()

    FeedbackCommon.initFeedback()
end

function FeedbackView:setupView()
    local contentWidth = self.viewRectWidth_
    local contentHeight = self.viewRectHeight_
    local upContentHeight = 200

    local contentPadding = 12 

    --多行输入框
    local inputWidth  = 570
    local inputHeight = upContentHeight - 30
    local inputContentSize = 18
    local inputContentColor = cc.c3b(0xca, 0xca, 0xca)
    self.inputEditBox = cc.ui.UIInput.new({
            image = "#common_input_bg.png",
            imagePressed="#common_input_bg_down.png", 
            size = cc.size(inputWidth, inputHeight),
            x = -(contentWidth/2 - contentPadding - inputWidth/2),
            y = contentHeight/2 - contentPadding - inputHeight/2,
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
        :addTo(self):pos(-(contentWidth/2 - contentPadding - inputWidth/2), contentHeight/2 - contentPadding - inputHeight/2)
        :size(inputWidth, inputHeight)
    self.showContent:setString(bm.LangUtil.getText("HELP", "FEED_BACK_HINT"))

    --上传图片
    self.uploadPicBtnWidth = 145
    self.uploadPicBtnHeight = 105
    self.uploadPicIcon_ = display.newSprite("#help_upload_pic_icon.png"):align(display.CENTER, 8, 0)
    display.newScale9Sprite("#panel_overlay.png", contentWidth/2 - contentPadding - self.uploadPicBtnWidth/2, contentHeight/2 - contentPadding - self.uploadPicBtnHeight/2, cc.size(self.uploadPicBtnWidth, self.uploadPicBtnHeight)):addTo(self)
    self.uploadPicBtn = cc.ui.UIPushButton.new({normal = "#transparent.png", pressed = "#common_button_pressed_cover.png"}, {scale9 = true})
        :addTo(self)
        :setButtonSize(self.uploadPicBtnWidth, self.uploadPicBtnHeight)
        :pos(contentWidth/2 - contentPadding - self.uploadPicBtnWidth/2, contentHeight/2 - contentPadding - self.uploadPicBtnHeight/2)
        :onButtonClicked(buttontHandler(self, self.onUploadPic_))
        :add(self.uploadPicIcon_)
    self.uploadPicBtn:setTouchSwallowEnabled(false)

    --确定上传
    local sendBtnHeight = 45
    self.sendBtn = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png", disabled="#common_btn_disabled.png"}, {scale9 = true})
        :addTo(self)
        :setButtonSize(self.uploadPicBtnWidth, sendBtnHeight)
        :pos(contentWidth/2 - self.uploadPicBtnWidth/2 - contentPadding, contentHeight/2 - self.uploadPicBtnHeight - 2 * contentPadding - sendBtnHeight/2)
        :onButtonClicked(buttontHandler(self, self.onSend_))
        :setButtonLabel("normal", display.newTTFLabel({
            text = bm.LangUtil.getText("COMMON", "SEND"),
            size = 26,
            color = cc.c3b(0xd6, 0xff, 0xef),
            align = ui.TEXT_ALIGN_CENTER
        }))
        self.sendBtn:setTouchSwallowEnabled(false)


    --罪恶的分割线
    local dividerWidth = 692
    local dividerHeight = 2
    local downContentHeight = contentHeight - upContentHeight
    local downContentOrignY = contentHeight/2 - downContentHeight
    --上面
    display.newScale9Sprite("#pop_up_split_line.png", 0,  contentHeight/2 - dividerHeight/2)
        :addTo(self)
        :size(dividerWidth, dividerHeight)
    --中间
    display.newScale9Sprite("#pop_up_split_line.png", 0, -downContentOrignY - dividerHeight/2)
        :addTo(self)
        :size(dividerWidth, dividerHeight)    

    --反馈列表
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
        :addTo(self):hide()
    self.noFeedbackHint:pos(0, - downContentOrignY - (dividerHeight + noFeedbackHintMarginTop + self.noFeedbackHint:getContentSize().height/2))

    FeedbackListItem.WIDTH = contentWidth
    local feedbackListMarginTop, feedbackListMarginBottom = 4, 4
    local feedbackListHeight = downContentHeight - feedbackListMarginTop - feedbackListMarginBottom
    self.feedbackList = bm.ui.ListView.new({viewRect = cc.rect(-0.5 * contentWidth, -0.5 * feedbackListHeight, contentWidth, feedbackListHeight), 
                                direction = bm.ui.ListView.DIRECTION_VERTICAL}, FeedbackListItem):addTo(self)
        :pos(0, - downContentOrignY - (dividerHeight + feedbackListHeight/2) - feedbackListMarginTop):hide()
    self.feedbackList:setNotHide(true)
end

function FeedbackView:onUploadPic_()
    print("feedback upload pic")
    nk.Native:pickupPic(function(success, result)
        logger:debug("nk.Native:pickupPic callback ", success, result)
        if success then
            self.picSuccess = true
            self.picFilePath = result
            --设置上传图片
            if self.uploadPic then
                cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
                self.uploadPic:removeFromParent()
                self.uploadPic = nil
            end
            local setImageSize = function(width, height, sprite)
                local sX = width / sprite:getContentSize().width
                local sY = height/ sprite:getContentSize().height
                local scale = math.min(sX, sY)
                sprite:scale(scale*0.9)
            end
            self.uploadPic = display.newSprite(self.picFilePath):addTo(self.uploadPicBtn)
            setImageSize(self.uploadPicBtnWidth, self.uploadPicBtnHeight, self.uploadPic)
            self.uploadPicIcon_:setVisible(false)
        else
            if result == "nosdcard" then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_NO_SDCARD"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_PICK_IMG_FAIL"))
            end
        end
    end)
end

function FeedbackView:onSend_()
    print("feedback send")
    if self.showContent:getString() ==  bm.LangUtil.getText("HELP", "FEED_BACK_HINT") then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "MUST_INPUT_FEEDBACK_TEXT_MSG"))
        return
    end
    self.sendBtn:setButtonEnabled(false)
    -- if self.picSuccess then
    --     self:upLoadPicNetWork()
    -- else
    --     self:uploadContentNoPic()
    -- end
    self:onFeedback("1",self.showContent:getString())
end

function FeedbackView:onFeedback(type, content)
    local postParam = {
        title = "",
        ftype = type,
        fwords = content,
        fcontact = "",
    }
    FeedbackCommon.sendFeedback(postParam,function(succ,result)
        if succ then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEED_BACK_SUCCESS"))
            if self.picSuccess then
                self:uploadImg(result.ret.fid, self.picFilePath)
            else
                self:sendFeedbackSucc_()
            end
        else
            if result == "network" then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            else
                -- FIXME:其他错误时报错信息
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end
        end
        self.sendBtn:setButtonEnabled(true)
    end)
    self:updateListView()
end

function FeedbackView:uploadImg(fid,picFilePath)
    FeedbackCommon.uploadPic(fid,picFilePath,function(succ, result)
            if succ then
                self:sendFeedbackSucc_()
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end
        end)
end

function FeedbackView:sendFeedbackSucc_()
    self.showContent:setString(bm.LangUtil.getText("HELP", "FEED_BACK_HINT"))
    self.uploadPicIcon_:setVisible(true)
    if self.uploadPic then
        cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
        self.uploadPic:removeFromParent()
        self.uploadPic = nil
    end
end

function FeedbackView:upLoadPicNetWork()
    local userData = nk.userData
    local uploadURL = userData.UPLOAD_PIC
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "UPLOADING_PIC_MSG"))

    network.uploadFile(function(evt)
        if evt.name == "completed" then
                local request = evt.request
                local ret = request:getResponseString()
                logger:debugf("REQUEST getResponseStatusCode() = %d", request:getResponseStatusCode())
                logger:debugf("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString())
                 logger:debugf("REQUEST getResponseDataLength() = %d", request:getResponseDataLength())
                logger:debugf("REQUEST getResponseString() =\n%s", ret)
                local retTable = json.decode(ret)
                if retTable then
                    self:onFeedback_("1000", self.showContent:getString(), retTable.url, retTable.key)
                else
                    self.sendBtn:setButtonEnabled(true)
                end
            end
        end,
        uploadURL,
        {
            fileFieldName = "upload",
            filePath = self.picFilePath,
            contentType = "Image/jpeg",
            extra={
                {"mtkey", userData.mtkey},
                {"skey", userData.skey},
                {"uid", userData.uid},
            }
        }
    )
end

function FeedbackView:uploadContentNoPic()
    self:onFeedback_("1000", self.showContent:getString())
end

function FeedbackView:onFeedback_(type, content, url, key)
    local params = {
            mod = "feedback",
            act = "setNew",
            type = type,
            content = content,
            url = url,
            key = key,
        }
    bm.HttpService.POST(
        params,
        function (data)
            local feedbackRetData = json.decode(data)
            if feedbackRetData.ret == 0 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("HELP", "FEED_BACK_SUCCESS"))
                self.showContent:setString(bm.LangUtil.getText("HELP", "FEED_BACK_HINT"))
                self.uploadPicIcon_:setVisible(true)
                if self.uploadPic then
                    cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
                    self.uploadPic:removeFromParent()
                    self.uploadPic = nil
                end
            end
            self.sendBtn:setButtonEnabled(true)
        end,
        function ()
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            self.sendBtn:setButtonEnabled(true)
        end
    )

    self:updateListView()
end

function FeedbackView:updateListView()
    table.insert(self.feedbackListData, 1, {answer = "", content = self.showContent:getString()})
    self.feedbackList:setData(self.feedbackListData)
end

function FeedbackView:onContentEdit_(event, editbox)
    if event == "began" then
        -- 开始输入
        local displayingText = self.showContent:getString()
        if displayingText == bm.LangUtil.getText("HELP", "FEED_BACK_HINT") then
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
            text = bm.LangUtil.getText("HELP", "FEED_BACK_HINT")
        end
        self.showContent:setString(text)
        editbox:setText("")
    elseif event == "return" then
        -- 从输入框返回
    end
end

function FeedbackView:setFeedbackList(data)
    if data and #data > 0 then 
        self.feedbackListData = data
        self.feedbackList:show()
        self.noFeedbackHint:hide()
        self.feedbackList:setData(data)
    else 

        self.feedbackList:hide()
        self.noFeedbackHint:show()
    end
end

function FeedbackView:getFeedbackList()
    return self.feedbackList
end

function FeedbackView:onShowed()
    self.feedbackList:setScrollContentTouchRect()
end

function FeedbackView:onCleanup()
    if self.uploadPic then
        cc.Director:getInstance():getTextureCache():removeTexture(self.uploadPic:getTexture())
        self.uploadPic:removeFromParent()
        self.uploadPic = nil
    end
end

return FeedbackView