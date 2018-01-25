
-- Author: jacob@boomegg.com
-- Date: 2014-09-28 10:57:15
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
local WIDTH = 800
local HEIGHT = 468
local TOP_HEIGHT = 64
local Panel = nk.ui.Panel
local ExchangeCode = class("ExchangeCode", Panel)

local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")
local logger = bm.Logger.new("ExchangeCode")

function ExchangeCode:ctor()
    ExchangeCode.super.ctor(self, {WIDTH, HEIGHT})
    display.addSpriteFrames("ecode.plist", "ecode.png")
    self:setNodeEventEnabled(true)
    
    local TOP = self.height_*0.5
    local BOTTOM = -self.height_*0.5
    local LEFT = -self.width_*0.5
    local RIGHT = self.width_*0.5

    display.newScale9Sprite("#popup_tab_bar_selected_bg.png", 0, 0, cc.size(WIDTH, 60))
        :pos(0, TOP - 30)
        :addTo(self)
    display.newTilesSprite("repeat/panel_repeat_tex.png", cc.rect(-WIDTH/2, -TOP_HEIGHT/2, WIDTH, TOP_HEIGHT))
        :pos(-WIDTH/2,HEIGHT/2 - TOP_HEIGHT)
        :addTo(self)

    self.title_ = display.newTTFLabel({text=bm.LangUtil.getText("ECODE", "TITLE"), size=30, color=cc.c3b(0x64, 0x9a, 0xc9), align=ui.TEXT_ALIGN_CENTER})
        :pos(0, TOP - 30)
        :addTo(self)
        
    self.editCode_ = cc.ui.UIInput.new({
        size = cc.size(520, 62),
        align=ui.TEXT_ALIGN_CENTER,
        image="#common_input_bg.png",
        imagePressed="#common_input_bg_down.png",
        x = LEFT+277,
        y = TOP - 110,
        listener = handler(self, self.onCodeEdit_)
    })
    self.editCode_:setFontName(ui.DEFAULT_TTF_FONT)
    self.editCode_:setFontSize(30)
    self.editCode_:setFontColor(cc.c3b(0xd7, 0xf6, 0xff))
    self.editCode_:setPlaceholderFontName(ui.DEFAULT_TTF_FONT)
    self.editCode_:setPlaceholderFontSize(30)
    self.editCode_:setPlaceholderFontColor(cc.c3b(0xb7, 0xc8, 0xd4))
    self.editCode_:setPlaceHolder(bm.LangUtil.getText("ECODE", "EDITDEFAULT"))
    -- self.editCode_:setPlaceHolder("กรุณากรอกหมายเลขหรัสโบนัสค่ะ")  -- Hot Update Test --
    self.editCode_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.editCode_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editCode_:addTo(self)

    self.exchangeButton_ = cc.ui.UIPushButton.new({normal= "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"},{scale9 = true})
        :setButtonSize(220, 62)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("ECODE", "EXCHANGE"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.onExchangeHandler))
        :pos(277, TOP - 110)
        :addTo(self)

    self.contentBackground_ = display.newScale9Sprite("#panel_overlay.png", 0, 0, cc.size(WIDTH-32, 230))
        :pos(0, TOP -270)
        :addTo(self)

    self.exchangeReward_ = display.newSprite("#ecode_icon.png")
        :pos(LEFT+180,-50)
        :addTo(self)

    self.desc_ = display.newTTFLabel({text=bm.LangUtil.getText("ECODE", "DESC"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_LEFT, valign=ui.TEXT_VALIGN_TOP,dimensions=cc.size(420, 230)}):addTo(self)
    self.desc_:setAnchorPoint(cc.p(0.5, 1))
    self.desc_:pos(RIGHT-235, TOP-166)

    self.fansButton_ = cc.ui.UIPushButton.new({normal= "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png"},{scale9 = true})
        :setButtonSize(765, 45)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("ECODE", "FANS"), size=24, color=cc.c3b(0xb2, 0xdc, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(handler(self, self.fansOnClick))
        :pos(0, BOTTOM + 43)
        :addTo(self)

    self:addCloseBtn()

end

function ExchangeCode:onExchangeHandler()
       -- local _trimed = string.trim(self.codeEdit_)
       -- print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
       -- print(self.codeEdit_)
       -- print(_trimed)
       -- print(string.len(_trimed))
       -- print(string.len(string.trim(self.codeEdit_)))
    if tonumber(self.codeEdit_)==nil or string.len(string.trim(self.codeEdit_)) < 6 or string.len(string.trim(self.codeEdit_)) > 8 then
       nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_FAILED"))
    else 
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new():pos(0, 0):addTo(self)
        end

        self.exchangeRequestId_ = nk.http.exchangeCode(string.trim(self.codeEdit_),function(callData)
            self.exchangeRequestId_ = nil
            self:clearJuhua()  
            if callData and callData.msg then
                -- self.codeReward = callData.addMoney .." "..bm.LangUtil.getText("STORE", "TITLE_CHIP")
                
                nk.ui.Dialog.new({
                messageText = bm.LangUtil.getText("ECODE", "SUCCESS",callData.msg), 
                secondBtnText = bm.LangUtil.getText("COMMON", "SHARE"),
                hasFirstButton = false,
                callback = function (type)
                       if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                           self:onShare()
                       end
                   end
                }):show()

               
               if callData.addMoney then
                    
                    self.animation_ = CommonRewardChipAnimation.new()
                    :addTo(self)
                    self.changeChipAnim_ = nk.ui.ChangeChipAnim.new(callData.addMoney)
                    :addTo(self)
               end
                
               

            end
        end,function(errData)
            self.exchangeRequestId_ = nil
            self:clearJuhua()
            if errData then

                -- dump(errData, "exchangeCode.errData :=====================")
                if errData.errorCode == -1 then
                    self.codeReward = ""
                    --nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_USED"))     --1 兑换过了
                    nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ECODE", "ERROR_USED",self.codeReward),
                    secondBtnText = bm.LangUtil.getText("COMMON", "SHARE"),
                    hasFirstButton = false,
                    callback = function (type)
                           if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                               self:onShare()
                           end
                       end
                    }):show()
                elseif errData.errorCode == -4 then
                     nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_END"))          --3 领完了
                elseif errData.errorCode == -6 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_INVALID"))      --2 过期了
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_FAILED"))       --其他错误
                end
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_FAILED"))       --其他错误
            end
        end)



        --[[
        bm.HttpService.POST(
        {
             mod = "exchangeCode", 
            act = "exchange",
            code=string.trim(self.codeEdit_)
         },
        function (data)
            logger:debug("Jacob")
            logger:debug("ExchangeCode", data)
            local callData = json.decode(data)
            self:clearJuhua()            
            if callData ~= nil and callData.ret == 0 then
            local p1, p2 = self:getItem(callData)
            self.codeReward=p1
            nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("ECODE", "SUCCESS",self.codeReward), 
            secondBtnText = bm.LangUtil.getText("COMMON", "SHARE"),
            hasFirstButton = false,
            callback = function (type)
                   if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                       self:onShare()
                   end
               end
            }):show()
            
                if p2 then  --没筹码就不播动画
                self.animation_ = CommonRewardChipAnimation.new()
                :addTo(self)
                self.changeChipAnim_ = nk.ui.ChangeChipAnim.new(p2)
                :addTo(self)
                end

            elseif callData ~= nil and callData.ret == 1 then
            self.codeReward = self:getItem(callData)
            --nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_USED"))     --1 兑换过了
            nk.ui.Dialog.new({
            messageText = bm.LangUtil.getText("ECODE", "ERROR_USED",self.codeReward),
            secondBtnText = bm.LangUtil.getText("COMMON", "SHARE"),
            hasFirstButton = false,
            callback = function (type)
                   if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                       self:onShare()
                   end
               end
            }):show()

            elseif callData ~= nil and callData.ret == 2 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_INVALID"))      --2 过期了
            elseif callData ~= nil and callData.ret == 3 then
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_END"))          --3 领完了
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("ECODE", "ERROR_FAILED"))
            end
        end,
        function (data)
            self:clearJuhua()
        end
        )

        --]]
    end
end

function ExchangeCode:getItem(val)
    local index=1
    local itemName=""
    local chips
    while val.rwd[index] do
        if val.rwd[index]["key"]=="chips" then
            chips=itemName..val.rwd[index]["val"]
            itemName=itemName..val.rwd[index]["val"].." "..bm.LangUtil.getText("STORE", "TITLE_CHIP")
        elseif val.rwd[index]["key"]=="fun_face" then
            itemName=itemName..val.rwd[index]["val"].." "..bm.LangUtil.getText("STORE", "TITLE_PROP")
        else
            itemName=itemName..val.rwd[index]["val"]..val.rwd[index]["key"]---需要本地化的物品名称
        end
        index = index +1
    end
    return itemName,chips
end  

-- 清除菊花
function ExchangeCode:clearJuhua()
    if self.juhua_ then
        self.juhua_:removeFromParent()
        self.juhua_ = nil
    end
end

function ExchangeCode:onCodeEdit_(event)
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化是
        self.codeEdit_ = self.editCode_:getText()
        print(self.codeEdit_)
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
        print(self.codeEdit_)
    end
end

function ExchangeCode:onShare() 

    -- local feedData = clone(bm.LangUtil.getText("FEED", "EXCHANGE_CODE"))
    -- feedData.name = bm.LangUtil.formatString(feedData.name, self.codeReward)
    -- nk.Facebook:shareFeed(feedData, function(success, result)
    -- logger:debug("FEED.EXCHANGE_CODE result handler -> ", success, result)
    --      if not success then
    --          self.shareBtn_:setButtonEnabled(true)
    --          nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
    --      else
    --          nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
    --      end
    -- end)
    nk.sendFeed:exchange_code_(self.codeReward,function()
        self.shareBtn_:setButtonEnabled(true)
    end
    )
end

function ExchangeCode:fansOnClick()
    print("setting fans on click")
    device.openURL(bm.LangUtil.getText("ABOUT", "FANS_OPEN"))
end
function ExchangeCode:hide()
    self:hidePanel_()
end

function ExchangeCode:show(times,subsidizeChips)
    
    self:showPanel_()
end

function ExchangeCode:onEnter()
end

function ExchangeCode:onExit()
    display.removeSpriteFramesWithFile("ecode.plist", "ecode.png")
end

function ExchangeCode:onCleanup()
    if self.exchangeRequestId_ then
        nk.http.cancel(self.exchangeRequestId_)
        self.exchangeRequestId_ = nil
    end
end

return ExchangeCode
