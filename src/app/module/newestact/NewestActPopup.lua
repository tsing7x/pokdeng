--
-- Author: tony
-- Date: 2014-09-10 10:55:40
--

local config = import(".Config")
-- local StorePopup = import("app.module.newstore.StorePopup")
-- local FriendPopup = import("app.module.friend.FriendPopup")
-- local HallController = import("app.module.hall.HallController")
-- local InvitePopup = import("app.module.friend.InvitePopup")
local QuickPurchaseServiceManager = import("app.module.newstore.QuickPurchaseServiceManager")
local PURCHASE_TYPE = import("app.module.newstore.PURCHASE_TYPE")
local BoxActivity = import(".boxActivity.BoxActPopup")
-- local MatchApplyPopup = import("app.module.match.views.MatchApplyPopup")

local NewestActPopup = class("NewestActPopup", function() 
    return display.newNode() 
end)

function NewestActPopup:ctor(defaultTabIndex, callback)

    local panelHeightFix = 16

    local bgTopSize = {
        width = config.PanelParam.WIDTH,
        height = 60
    }

    self:setNodeEventEnabled(true)
    display.addSpriteFrames("newestact.plist", "newestact.png")

    self.callback_ = callback

    self.backgroundCenter_ = display.newScale9Sprite("#newestact_center_background.png", 0, 0, cc.size(config.PanelParam.WIDTH, config.PanelParam.HEIGHT - panelHeightFix)):addTo(self)
    self.backgroundCenter_:setTouchEnabled(true)
    self.backgroundCenter_:setTouchSwallowEnabled(true)

    -- self.cover_ = display.newTilesSprite("repeat/newestact_cover_repeat.png", cc.rect(0,  0, W - 4, H - 4)):pos(LEFT + 2, BOTTOM + 2):addTo(self)
    
    self.backgroundTop_ = display.newScale9Sprite("#newestact_top_background.png", 0, config.PanelParam.HEIGHT / 2 - bgTopSize.height / 2, cc.size(bgTopSize.width, bgTopSize.height)):addTo(self)
    
    local contContainerPosXFix = 5

    self.actContainer = display.newNode():addTo(self)
    self.actContainer:pos(0, - contContainerPosXFix)

    -- for i = 1, 4 do
        
    -- end

    local BottomRadioMagrinEach = 2

    self.tabBtn1_ = cc.ui.UICheckBoxButton.new({
                on = "#newestact_tab_btn_left_selected.png",
                off = "#newestact_tab_btn_left_normal.png",
                off_disabled = "#newestact_tab_btn_left_disabled.png",
            }, {scale9=true})
        :setButtonSize(config.BtnGroupBottomParam.WIDTH, config.BtnGroupBottomParam.HEIGHT.normal)
        :pos(- config.PanelParam.WIDTH / 2 + config.BtnGroupBottomParam.WIDTH / 2, - config.PanelParam.HEIGHT / 2)
        :addTo(self)
    self.tabBtn1_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_BOTTOM])

    self.tabBtn2_ = cc.ui.UICheckBoxButton.new({
                on = "#newestact_tab_btn_mid_selected.png",
                off = "#newestact_tab_btn_mid_normal.png",
                off_disabled = "#newestact_tab_btn_mid_disabled.png",
            }, {scale9=true})
        :setButtonSize(config.BtnGroupBottomParam.WIDTH, config.BtnGroupBottomParam.HEIGHT.normal)
        :pos(- config.PanelParam.WIDTH / 2 + config.BtnGroupBottomParam.WIDTH * 3 / 2 + BottomRadioMagrinEach * 1, - config.PanelParam.HEIGHT / 2)
        :addTo(self)
    self.tabBtn2_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_BOTTOM])

    self.tabBtn3_ = cc.ui.UICheckBoxButton.new({
                 on = "#newestact_tab_btn_mid_selected.png",
                off = "#newestact_tab_btn_mid_normal.png",
                off_disabled = "#newestact_tab_btn_mid_disabled.png",
            }, {scale9=true})
        :setButtonSize(config.BtnGroupBottomParam.WIDTH, config.BtnGroupBottomParam.HEIGHT.normal)
        :pos(- config.PanelParam.WIDTH / 2 + config.BtnGroupBottomParam.WIDTH * 5 / 2 + BottomRadioMagrinEach * 2, - config.PanelParam.HEIGHT / 2)
        :addTo(self)
    self.tabBtn3_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_BOTTOM])

    self.tabBtn4_ = cc.ui.UICheckBoxButton.new({
                 on = "#newestact_tab_btn_mid_selected.png",
                off = "#newestact_tab_btn_mid_normal.png",
                off_disabled = "#newestact_tab_btn_right_disabled.png",
            }, {scale9=true})
        :setButtonSize(config.BtnGroupBottomParam.WIDTH, config.BtnGroupBottomParam.HEIGHT.normal)
        :pos(- config.PanelParam.WIDTH / 2 + config.BtnGroupBottomParam.WIDTH * 7 / 2 + BottomRadioMagrinEach * 3, - config.PanelParam.HEIGHT / 2)
        :addTo(self)
    self.tabBtn4_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_BOTTOM])

    local titleLabelParam = {
        FrontSize = 30,
        Color = cc.c3b(0xff, 0xff, 0xac),
        MagrinTop = 30
    }

    local titleSprWidth = 144
    local titleSprPosXShift = 12

    self.title_ = display.newTTFLabel({size=titleLabelParam.FrontSize, color=titleLabelParam.Color, text=bm.LangUtil.getText("NEWESTACT", "TITLE")}):pos(0, config.PanelParam.HEIGHT / 2 - titleLabelParam.MagrinTop):addTo(self)
    local titleWidth = self.title_:getContentSize().width
    self.titleIconLeft_ = display.newSprite("#newestact_top_icon.png", -(titleWidth / 2 + titleSprWidth / 2 + titleSprPosXShift) , self.title_:getPositionY()):addTo(self)
    self.titleIconRight_ = display.newSprite("#newestact_top_icon.png", titleWidth / 2 + titleSprWidth / 2 + titleSprPosXShift , self.title_:getPositionY()):addTo(self):rotation(180)

    -- self.imgClip_ = cc.ClippingNode:create()
    --     :pos(LEFT + 262 * 0.5 + 24, 12)
    --     :addTo(self)
    -- self.imgClip_:setStencil(display.newScale9Sprite("#rounded_rect_10.png", 0, 0, cc.size(260, 260)))
    --self.imgContainer_ = display.newNode():addTo(self.imgClip_)
    self.imgLoaderId_ = nk.ImageLoader:nextLoaderId()
   -- self.imgFrame_ = display.newScale9Sprite("#newestact_img_frame.png", self.imgClip_:getPositionX(), self.imgClip_:getPositionY(), cc.size(264, 264)):addTo(self)

    local tabBtnLabelParam = {
        FrontSize = 30,
        color = cc.c3b(0x88, 0x31, 0x25)
    }

    self.tabBtnLabel1_ = display.newTTFLabel({size = tabBtnLabelParam.FrontSize, color = tabBtnLabelParam.color, text=bm.LangUtil.getText("NEWESTACT", "LOADING")})
        :pos(self.tabBtn1_:getPositionX(), - config.PanelParam.HEIGHT / 2 + config.BtnGroupBottomParam.HEIGHT.normal / 2):addTo(self)
    self.tabBtnLabel2_ = display.newTTFLabel({size=tabBtnLabelParam.FrontSize, color=tabBtnLabelParam.color, text=bm.LangUtil.getText("NEWESTACT", "LOADING")})
        :pos(self.tabBtn2_:getPositionX(), - config.PanelParam.HEIGHT / 2 + config.BtnGroupBottomParam.HEIGHT.normal / 2):addTo(self)
    self.tabBtnLabel3_ = display.newTTFLabel({size=tabBtnLabelParam.FrontSize, color=tabBtnLabelParam.color, text=bm.LangUtil.getText("NEWESTACT", "LOADING")})
        :pos(self.tabBtn3_:getPositionX(), - config.PanelParam.HEIGHT / 2 + config.BtnGroupBottomParam.HEIGHT.normal / 2):addTo(self)
    self.tabBtnLabel4_ = display.newTTFLabel({size=tabBtnLabelParam.FrontSize, color=tabBtnLabelParam.color, text=bm.LangUtil.getText("NEWESTACT", "LOADING")})
        :pos(self.tabBtn4_:getPositionX(), - config.PanelParam.HEIGHT / 2 + config.BtnGroupBottomParam.HEIGHT.normal / 2):addTo(self)

    self.btnGroup_ = nk.ui.CheckBoxButtonGroup.new()
    self.btnGroup_:onButtonSelectChanged(handler(self, self.onTabChange_))
    self.btnGroup_:addButton(self.tabBtn1_)
    self.btnGroup_:addButton(self.tabBtn2_)
    self.btnGroup_:addButton(self.tabBtn3_)
    self.btnGroup_:addButton(self.tabBtn4_)
    self.defaultTabIndex_ = defaultTabIndex or 1
    -- self.btnGroup_:getButtonAtIndex(1):setButtonEnabled(false)
    -- self.btnGroup_:getButtonAtIndex(2):setButtonEnabled(false)
    -- self.btnGroup_:getButtonAtIndex(3):setButtonEnabled(false)
    -- self.btnGroup_:getButtonAtIndex(4):setButtonEnabled(false)

    local splitLineWidth = 2
    local splitPosXShift = 1
    self.split1_ = display.newSprite("#newestact_tab_btn_split.png", - config.PanelParam.WIDTH / 2 + config.BtnGroupBottomParam.WIDTH + splitPosXShift, - config.PanelParam.HEIGHT / 2 + config.BtnGroupBottomParam.HEIGHT.normal / 2):addTo(self)
    self.split2_ = display.newSprite("#newestact_tab_btn_split.png", - config.PanelParam.WIDTH / 2 + config.BtnGroupBottomParam.WIDTH * 2 + splitLineWidth + splitPosXShift, - config.PanelParam.HEIGHT / 2 + config.BtnGroupBottomParam.HEIGHT.normal / 2):addTo(self)
    self.split3_ = display.newSprite("#newestact_tab_btn_split.png", - config.PanelParam.WIDTH / 2 + config.BtnGroupBottomParam.WIDTH * 3 + splitLineWidth * 2 + splitPosXShift, - config.PanelParam.HEIGHT / 2 + config.BtnGroupBottomParam.HEIGHT.normal / 2):addTo(self)

    -- self.scrollContainer_ = bm.ui.ScrollView.new({viewRect=cc.rect(540 * -0.5, 250 * -0.5, 540, 250), scrollContent=display.newNode()})
    --     :pos(156, 48)
    --     :addTo(self)

    -- self.rewardBtn_ = cc.ui.UIPushButton.new({normal="#newestact_yellow_btn_up.png", pressed="#newestact_yellow_btn_down.png"}, {scale9=true})
    --     :setButtonLabel(display.newTTFLabel({size=30, color=cc.c3b(0xff, 0xd2, 0x88), text=""}))
    --     :setButtonSize(200, 62)
    --     :pos(RIGHT - 32 - 200 * 0.5, BOTTOM + 62 * 0.5 + 96)
    --     :onButtonClicked(buttontHandler(self, self.onRewardButtonClicked_))
    --     :addTo(self)
    --     :hide()

    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed="#panel_black_close_btn_down.png"})
        :pos(config.PanelParam.WIDTH / 2, config.PanelParam.HEIGHT / 2)
        :onButtonClicked(function()
                nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                self:onClose_()
            end)
        :addTo(self)

    self:loadData_()


    if not self.quickPay_ then

        self.quickPay_ = QuickPurchaseServiceManager.new()
        -- self.bigJuhua_ = nk.ui.Juhua.new():addTo(self)
        self.quickPay_:loadPayConfig(handler(self, self.onLoadPayConfig_))

    end

end


function NewestActPopup:onLoadPayConfig_(ret)
    -- dump(self.quickPay_, "self.quickPay_ :===================")

    if ret == 0 then
        local isServiceAvailable = self.quickPay_:isServiceAvailable(PURCHASE_TYPE.LINE_PAY)
        local service = self.quickPay_:getPurchaseService(PURCHASE_TYPE.LINE_PAY)
        -- local isPay = (nk.userData.best) and (nk.userData.best.ispay == 1) or false

        -- dump(isServiceAvailable,"isServiceAvailable==")
        -- dump(service,"service")
        if isServiceAvailable and service then
           self:createPayDiscount(true)
        else
            self:createPayDiscount(false)
        end
    else
        self:createPayDiscount(false)
    end
end


function NewestActPopup:createPayDiscount(isShowPay)

    self.isShowPay_ = isShowPay

    local tab3Str = (isShowPay == true) and bm.LangUtil.getText("NEWESTACT", "ACT_TABLE")[6] or bm.LangUtil.getText("NEWESTACT", "ACT_TABLE")[7] or bm.LangUtil.getText("NEWESTACT", "NO_ACT")

    -- self.btnGroup_:getButtonAtIndex(3):setButtonEnabled(isShowPay)

    self.tabBtnLabel3_:setString(tab3Str)

    -- local tabLabel4Str = bm.LangUtil.getText("NEWESTACT", "ACT_TABLE")[2]
    -- self.tabBtnLabel4_:setString(tabLabel4Str)
   
end

function NewestActPopup:onExit()
    display.removeSpriteFramesWithFile("newestact.plist", "newestact.png")
    nk.schedulerPool:delayCall(function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end, 0.1)
end

function NewestActPopup:onClose_()
    self:hide()
end

function NewestActPopup:onCleanup()
    if self.quickPay_ then
        self.quickPay_:autoDispose()
        self.quickPay_ = nil
    end
end
function NewestActPopup:loadData_()
    self:createTabs_({})
    -- if nk.userData["open"] and nk.userData["open"]["mother"] then
    --     self.motherDayOpen = 1;
    -- else
    --     self.motherDayOpen = 0
    -- end
    -- if self.selectedIndex_==1 and self.motherDayOpen == 1 then
    --     if self.motherDayAct==nil then 
    --         self.motherDayAct = import("app.module.newestact.MothersDayActPopup").new(self);
    --     end
    --      local isFristRequest = bm.DataProxy:getData(nk.dataKeys.CHANGE_FLOWER)
    --      dump(isFristRequest,"isFristRequest")
    --      if isFristRequest == nil then
    --         self.motherDayAct:loadData()
    --      end
    --     self.motherDayAct:addTo(self.actContainer)
    --     self.onChangeFlowerDataObserver = bm.DataProxy:addDataObserver(nk.dataKeys.CHANGE_FLOWER, handler(self, self.changeFlowerData))
    -- end
end

function NewestActPopup:changeFlowerData()
    if self.motherDayAct then
        self.motherDayAct:loadData()
    end
end

function NewestActPopup:onRewardButtonClicked_(evt)
    self:buttonCodeHandler_(self.currentData_.button_code, self.currentData_.button_url)
end
    
--[[
0:    调领奖弹框
1:    playnow
2:    打开商城
4:    进高级场房间  
12:    打开好友邀请(游客打开好友弹框的邀请TAG， Facebook登录用户直接弹出邀请对话框)
16: 去appstore打分
17: 打开网页
]]
function NewestActPopup:buttonCodeHandler_(code, url, ctype)
    -- if code == 0 then
    --     if url then
    --         if not self.juhua_ then
    --             self.juhua_ = nk.ui.Juhua.new():addTo(self)
    --             local param = bm.HttpService.cloneDefaultParams()
    --             if ctype then
    --                 param.type = ctype
    --             end
    --             bm.HttpService.POST_URL(url, param, handler(self, self.rewardResultHandler),
    --                 function()
    --                     nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    --                     if self.juhua_ then
    --                         self.juhua_:removeFromParent()
    --                         self.juhua_ = nil
    --                     end
    --                 end)
    --         end
    --     end
    -- elseif code == 1 then
    --     self.callback_("playnow")
    --     self:hide()
    -- elseif code == 2 then
    --     StorePopup.new():showPanel()
    --     self:hide()
    -- elseif code == 4 then
    --     self.callback_("gotoChoseRoomView", HallController.CHOOSE_PRO_VIEW)
    --     self:hide()
    -- elseif code == 12 then
    --     local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    --     if lastLoginType == "FACEBOOK" then
    --         InvitePopup.new():show()
    --     else
    --         FriendPopup.new(2):show()
    --         self:hide()
    --     end
    -- elseif code == 16 then
    --     if nk.userData.commentUrl then
    --         device.openURL(nk.userData.commentUrl)
    --     end
    -- elseif code == 17 then
    --     if url and string.len(url) > 0 then
    --         device.openURL(url)
    --     end
    -- else
    --     self:hide()
    -- end
end

function NewestActPopup:rewardResultHandler(result)
    if self.juhua_ then
        self.juhua_:removeFromParent()
        self.juhua_ = nil
    end
    local jsn = json.decode(result)
    if jsn and jsn.message then
        nk.ui.Dialog.new({
                messageText = jsn.message,
                titleText = jsn.title,
                callback = function()
                    self:hide()
                end,
            })
            :show()
    end
end

function NewestActPopup:onTabChange_(evt)

    -- lazy way --
    local changed = self.selectedIndex_ ~= evt.selected
    self.selectedIndex_ = evt.selected
    self.tabBtn1_:setButtonSize(config.BtnGroupBottomParam.WIDTH, (self.selectedIndex_ == 1) and config.BtnGroupBottomParam.HEIGHT.pressed or config.BtnGroupBottomParam.HEIGHT.normal)
    self.tabBtn2_:setButtonSize(config.BtnGroupBottomParam.WIDTH, (self.selectedIndex_ == 2) and config.BtnGroupBottomParam.HEIGHT.pressed or config.BtnGroupBottomParam.HEIGHT.normal)
    self.tabBtn3_:setButtonSize(config.BtnGroupBottomParam.WIDTH, (self.selectedIndex_ == 3) and config.BtnGroupBottomParam.HEIGHT.pressed or config.BtnGroupBottomParam.HEIGHT.normal)
    self.tabBtn4_:setButtonSize(config.BtnGroupBottomParam.WIDTH, (self.selectedIndex_ == 4) and config.BtnGroupBottomParam.HEIGHT.pressed or config.BtnGroupBottomParam.HEIGHT.normal)
    if changed then
       -- self.imgContainer_:removeAllChildren()
        -- local data = self.data_[self.selectedIndex_]
        -- self.currentData_ = data
        -- if data then
        --     nk.ImageLoader:loadAndCacheImage(self.imgLoaderId_, data.img1, handler(self, self.onImgLoaded_), nk.ImageLoader.CACHE_TYPE_ACT)
        --     self.scrollContainer_:setScrollContent(self:createContent_(data))
        --     if data.button == 1 then
        --         self.rewardBtn_:setButtonLabelString(data.button_cont):show()
        --     else
        --         self.rewardBtn_:hide()
        --     end
        -- end
        self.actContainer:removeAllChildren()
        self.signInContent_ = nil

        local contImgPosYShift = 10
        if self.selectedIndex_== 4 then

            -- if self.isShowPay_ then
            --     local actAdView = cc.ui.UIImage.new("#act_ad"..(self.selectedIndex_)..".jpg")
            --     :align(display.CENTER)
            --     :pos(0, contImgPosYShift)
            --     :addTo(self.actContainer)
            --     actAdView:setTouchEnabled(true)
            --     actAdView:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onAdTouch_))

            -- else

            --     local actAdView = cc.ui.UIImage.new("#newactad.jpg")
            --     :align(display.CENTER)
            --     :pos(0, contImgPosYShift)
            --     :addTo(self.actContainer)
            --     -- actAdView:setTouchEnabled(true)

            --     local actionBtnSize = {
            --         width = 152,
            --         height = 52
            --     }

            --     local actionBtnMagrins = {
            --         right = 25,
            --         bottom = 15
            --     }

            --     local actionBtn = cc.ui.UIPushButton.new({normal = "#common_dark_blue_btn_up.png", pressed = "#common_dark_blue_btn_down.png", disabled = "#common_btn_disabled.png"}, 
            --         {scale9 = true})
            --         :setButtonSize(actionBtnSize.width, actionBtnSize.height)
            --         :setButtonLabel("normal", display.newTTFLabel({text = "现在就去", size = 18, align = ui.TEXT_ALIGN_CENTER}))
            --         :onButtonClicked(handler(self, self.onGoMatchRoomBtnCallBack_))
            --         :pos(actAdView:getContentSize().width - actionBtnMagrins.right - actionBtnSize.width / 2, actionBtnMagrins.bottom + actionBtnSize.height / 2)
            --         :addTo(actAdView)
            --     -- actAdView:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onAdTouch_))

            -- end

            -- local actAdView = cc.ui.UIImage.new("#newactad.jpg")
            --     :align(display.CENTER)
            --     :pos(0, contImgPosYShift)
            --     :addTo(self.actContainer)
            --     actAdView:setTouchEnabled(true)
            --     actAdView:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onAdTouch_))


        elseif self.selectedIndex_ == 2 then
            self:createBoxAcitvity()
        elseif self.selectedIndex_ == 3 then
            local imgName = "#act_ad6.jpg"
            if self.isShowPay_ then
                imgName = "#act_ad"..(self.selectedIndex_)..".jpg"
            end

            local actAdView = cc.ui.UIImage.new(imgName)
            actAdView:align(display.CENTER)
                :pos(0, contImgPosYShift)
                :addTo(self.actContainer)
                actAdView:setTouchEnabled(true)
                actAdView:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onAdTouch_))

        else
            local actAdView = cc.ui.UIImage.new("#act_ad"..(self.selectedIndex_)..".jpg")
            actAdView:align(display.CENTER)
                :pos(0, contImgPosYShift)
                :addTo(self.actContainer)
                actAdView:setTouchEnabled(true)
                actAdView:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onAdTouch_))
        end

       -- self.imgContainer_:hide()
        --self.imgClip_:hide()
       -- self.imgFrame_:hide()
       -- self.cover_:hide()
    end
end
function NewestActPopup:createBoxAcitvity()
    if nk.OnOff:check("luckBox") then
        display.addSpriteFrames("boxact_th.plist", "boxact_th.png", function()
            self.boxPopup_ = BoxActivity.new(self)
            self.boxPopup_:addTo(self.actContainer)
        end)

        self.tabBtnLabel2_:setString(bm.LangUtil.getText("NEWESTACT", "ACT_TABLE")[5])
    else
        self.tabBtnLabel2_:setString(bm.LangUtil.getText("NEWESTACT", "ACT_TABLE")[3])
        local actAdView = cc.ui.UIImage.new("#act_ad"..(self.selectedIndex_)..".jpg")
        :align(display.CENTER)
        :pos(0, 10)
        :addTo(self.actContainer)
        actAdView:setTouchEnabled(true)
        actAdView:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onAdTouch_))
    end


end

function NewestActPopup:onAdTouch_(evt)
    -- local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY


    -- self.callback_(self.selectedIndex_)

    if self.callback_ then
        if self.selectedIndex_ == 1 then
            self.callback_("invite")
        elseif self.selectedIndex_ == 4 then
            self.callback_("goMatchRoom")

            self:hide()

        elseif self.selectedIndex_ == 3 then
            --todo
            -- self.callback_("clkActCenter")

            
            if self.isShowPay_ then
                self.callback_("openShop",{purchaseType = PURCHASE_TYPE.LINE_PAY})
                self:hide()
                -- device.openURL("https://th.mol.com/page.php?id=20160121d2RK9VB")
            else
                --self.callback_("openScoreMarket")
                
                
                self.callback_("openGrab")

                self:hide() 

            end
            
        end
        
        
    end


    
end

function NewestActPopup:createTabs_(dataArr)
    self.data_ = dataArr
    -- self.defaultTabIndex_ = math.max(1, math.min(self.defaultTabIndex_, #dataArr))
    -- self.defaultTabIndex_ =1;
    for i = 1, 4 do
        local data = dataArr[i]
        --self.btnGroup_:getButtonAtIndex(i):setButtonEnabled(data ~= nil)
        self["tabBtnLabel" .. i .. "_"]:setString(data and data.title or bm.LangUtil.getText("NEWESTACT", "ACT_TABLE")[i])
    end
    self.btnGroup_:getButtonAtIndex(self.defaultTabIndex_):setButtonSelected(true)

    if nk.OnOff:check("luckBox") then
        self.tabBtnLabel2_:setString(bm.LangUtil.getText("NEWESTACT", "ACT_TABLE")[5])
    else
        self.tabBtnLabel2_:setString(bm.LangUtil.getText("NEWESTACT", "ACT_TABLE")[3])
    end

    -- self.tabBtnLabel3_:setString(bm.LangUtil.getText("NEWESTACT", "ACT_TABLE")[4])

    
end

function NewestActPopup:createContent_(data)
    return display.newTTFLabel({size=22, color=cc.c3b(0xff, 0xff, 0xac), text=data.time .. "\n" ..data.cont, dimensions=cc.size(540, 0)})
end

function NewestActPopup:onImgLoaded_(success, sprite)
    -- if success then
    --     self.imgContainer_:removeAllChildren()
    --     local spsize = sprite:getContentSize()
    --     if spsize.width > spsize.height then
    --         sprite:scale(264 / spsize.width)
    --     else
    --         sprite:scale(264 / spsize.height)
    --     end
    --     sprite:addTo(self.imgContainer_)
    -- end
end

function NewestActPopup:show()
    nk.PopupManager:addPopup(self, true, true, true, true)
end

function NewestActPopup:hide()
    bm.DataProxy:removeDataObserver(nk.dataKeys.CHANGE_FLOWER,self.onChangeFlowerDataObserver)
    nk.PopupManager:removePopup(self)
end


function NewestActPopup:onShowed()
    if self.signInContent_ then
        --todo

        if self.signInContent_.onShowed then
            --todo
            self.signInContent_:onShowed()
        end
    end
end

function NewestActPopup:createFirstPage()
    

    local isShowSignIn = nk.OnOff:check("signIn")
    -- isShowSignIn = false

    if isShowSignIn then
        --todo
        -- return SignInCont.new()

        local pageSprShiftY = 10

        local pageSprite = display.newNode()

        cc.ui.UIImage.new("#act_ad2.jpg")
            :align(display.CENTER)
            :pos(0, pageSprShiftY)
            :addTo(pageSprite)

        return pageSprite
    else
        local pageSprShiftY = 10

        local BtnSize = {
            width = 167,
            height = 55
        }

        local BtnPos = {
            x = 290,
            y = - 109
        }


        local pageSprite = display.newNode()
         cc.ui.UIImage.new("#act_ad3.jpg")
         :align(display.CENTER)
         :pos(0, pageSprShiftY)
         :addTo(pageSprite)

         -- local newsActAdSpr = display.newSprite("#newactad.jpg")
         --    -- :align(display.CENTER)
         --    :pos(0, pageSprShiftY)
         --    :addTo(pageSprite)
         
         cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
         :setButtonSize(BtnSize.width, BtnSize.height)
         :onButtonClicked(buttontHandler(self,self.goAppStore))
         :addTo(pageSprite)
         :pos(BtnPos.x, BtnPos.y)
         return pageSprite
    end
    
end
function NewestActPopup:goAppStore()
    device.openURL("https://goo.gl/dNRlbG")
end
return NewestActPopup