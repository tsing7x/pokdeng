--
-- Author: thinkeras3@163.com
-- Date: 2015-08-10 14:11:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
--
local Panel = import("app.pokerUI.Panel")
local CornuPopup = class("CornuPopup", Panel)
local CornuCheckInfoView = import(".CornuCheckInfoView")
local CornuRecordView = import(".CornuRecordView")
local CornuHomePageView = import(".CornuHomePageView")
local CornuFriendsView = import(".CornuFriendsView")

local PADDING = 16
local POPUP_WIDTH = 872
local POPUP_HEIGHT = 544


function CornuPopup:ctor(tab)
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    display.addSpriteFrames("farm_ex.plist", "farm_ex.png")
    self:setNodeEventEnabled(true)
	 CornuPopup.super.ctor(self, {POPUP_WIDTH, POPUP_HEIGHT})
	self:createNodes_()
end
function CornuPopup:createNodes_()
	--大背景
	self.panelOverlay_ = display.newScale9Sprite("#transparent.png", 0, 0, cc.size(self.width_, self.height_ - (nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT + PADDING * 2)))
         :align(display.CENTER, 0, self.height_ * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT - PADDING)
         :addTo(self)
    --左侧花
    self.flowerBg_ = display.newSprite("#cor_flower.png")
     :align(display.CENTER)
     :pos(-POPUP_WIDTH/2-15,POPUP_HEIGHT/2-125)
     :addTo(self)
     --标题背景花
     display.newSprite("#cor_title_bg.png")
     :align(display.CENTER)
     :pos(-192,POPUP_HEIGHT/2+15)
     :addTo(self)
     --反转背景花
     display.newSprite("#cor_title_bg.png")
     :align(display.CENTER)
     :pos(192,POPUP_HEIGHT/2+15)
     :addTo(self)
     :setScaleX(-1)

     --title
     self.flowerBg_ = display.newSprite("#cor_title.png")
     :align(display.CENTER)
     :pos(0,POPUP_HEIGHT/2+10)
     :addTo(self)

    --关闭按钮
    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#cor_close_btn_up.png", pressed = "#cor_close_btn_down.png"})
        :align(display.CENTER)
        :pos(POPUP_WIDTH/2-5,POPUP_HEIGHT/2-5)
        :onButtonClicked(function() 
            self:onClose()
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        end)
        :addTo(self)


    ----
    local labelPosX = -self.width_ * 0.5 + 12 * 2 +120
    local labelPosY = self.height_ * 0.5 - 12 * 3 +163
-- 点击我的聚宝盆
    self.myCor_line_ = display.newSprite("#user-info-desc-button-background-up-line.png")
        :pos(labelPosX -10 ,labelPosY - 190)
        :addTo(self)
    self.myCorButton_ = cc.ui.UIPushButton.new({normal = "#cor_my_cor_btn_up.png", pressed="#cor_my_cor_btn_down.png"})
        :pos(labelPosX - 110,labelPosY - 172)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[1], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[1], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(90, 0)
        :onButtonPressed(function()
                local getFrame = display.newSpriteFrame
                self.myCor_line_:setSpriteFrame(getFrame("user-info-desc-button-background-down-line.png"))
            end)
        :onButtonRelease(function()
                local getFrame = display.newSpriteFrame
                self.myCor_line_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))
            end)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onMyCor_))

       -- 点击我的记录
    self.my_cor_record_line_ = display.newSprite("#user-info-desc-button-background-up-line.png")
        :pos(labelPosX + 435 ,labelPosY - 190)
        :addTo(self)    
    self.my_record_Button_ = cc.ui.UIPushButton.new({normal = "#cor_record_btn_up.png", pressed = "#cor_recrod_btn_down.png"})
        :pos(labelPosX + 348,labelPosY - 172)
        :setButtonLabel("normal",display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[3], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed",display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[3], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(90, 0)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onMyRecordCor_))
        :onButtonPressed(function()
                self.my_cor_record_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
            end)
        :onButtonRelease(function ()
                self.my_cor_record_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-up-line.png"))
            end)


    -- 点击好友聚宝盆
    self.my_friendsCor_line_ = display.newSprite("#user-info-desc-button-background-up-line.png")
        :pos(labelPosX + 225 ,labelPosY - 190)
        :addTo(self)
    self.myFriendsCorButton_ = cc.ui.UIPushButton.new({normal = "#cor_friend_btn_up.png", pressed = "#cor_friend_btn_down.png"})
        :pos(labelPosX + 114,labelPosY - 172)
        :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[2], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("normal",display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[2], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed",display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[2], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(100, 0)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onMyFriendsCor_))
        :onButtonPressed(function()
                self.my_friendsCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
            end)
        :onButtonRelease(function ()
                self.my_friendsCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-up-line.png"))
            end)


       -- 点击查看信息
    self.check_info_line_ = display.newSprite("#user-info-desc-button-background-up-line.png")
        :pos(labelPosX + 635 ,labelPosY - 190)
        :addTo(self)    
    self.check_info_Button_ = cc.ui.UIPushButton.new({normal = "#cor_infomation_up.png", pressed = "#cor_infomation_down.png"})
        :pos(labelPosX + 572,labelPosY - 172)
        :setButtonLabel("normal",display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[4], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed",display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[4], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabelOffset(90, 0)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onCheckGameInfo))
        :onButtonPressed(function()
                self.my_cor_record_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
            end)
        :onButtonRelease(function ()
                self.my_cor_record_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-up-line.png"))
            end)

--
    self.content_ = display.newSprite()
    :addTo(self)
    :pos(0,-30)
    --大背景
    display.newScale9Sprite("#cor_big_bg.png", 0, 0, cc.size(POPUP_WIDTH-30,POPUP_HEIGHT-100))
     :align(display.CENTER) 
     :addTo(self.content_)


    self:onMyCor_()
       
end

function CornuPopup:onMyCor_()
    if self.current_page_ == 1 then  return end;
    if self.current_view_ then
        self.current_view_:removeFromParent()
        self.current_view_ = nil
    end
    self.current_page_ = 1
    self.current_view_ = CornuHomePageView.new(self):addTo(self.content_)
    -- if self.current_page_ == 3 then
    --     if self._myRecList then
    --         --todo
    --         self._myRecList:removeFromParent()
    --     end
    -- end
    -- self.current_page_ = 1

    -- if self.cornucopiaList_ == nil then
    --     self.cornucopiaList_ = CornucopiaList.new(self)
    --     self.cornucopiaList_:addTo(self.container_)
    -- end
    -- self.cornucopiaList_:show(1)
    -- self.row_:pos(-235,80)
    self:setButtonDef()
    self.myCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
    self.myCorButton_:setButtonImage("normal", "#cor_my_cor_btn_down.png", true)
    self.myCorButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[1], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
end
function CornuPopup:onMyFriendsCor_()
    -- local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    -- if lastLoginType == "GUEST" then
    --     LoginFbDialog.new(self):show()
    --     return
    -- end
     if self.current_page_ == 2 then  return end;
     if self.current_view_ then
        self.current_view_:removeFromParent()
        self.current_view_ = nil
    end
    self.current_view_ = CornuFriendsView.new(self,self.goFid_):addTo(self.content_)
    self.current_page_ = 2
    self.goFid_ = 0
    --  if self.current_page_ == 3 then
    --     if self._myRecList then
    --         --todo
    --         self._myRecList:removeFromParent()
    --     end
    -- end
    -- self.current_page_ = 2
    -- if self.cornucopiaList_ == nil then
    --     self.cornucopiaList_ = CornucopiaList.new(self)
    --     self.cornucopiaList_:addTo(self.container_)
    -- end
    -- self.cornucopiaList_:show(2)
    -- self.row_:pos(0,80)
    self:setButtonDef()
    self.my_friendsCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
    self.myFriendsCorButton_:setButtonImage("normal", "#cor_friend_btn_down.png", true)
    self.myFriendsCorButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[2], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
end
function CornuPopup:onMyRecordCor_()

    --  local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    -- if lastLoginType == "GUEST" then
    --     LoginFbDialog.new(self):show()
    --     return
    -- end

    -- local CronMyRecListContentSize = {
    --     width = 690,
    --     height = 288
    -- }

    if self.current_page_ == 3 then  return end;
    if self.current_view_ then
        self.current_view_:removeFromParent()
        self.current_view_ = nil
    end
    self.current_page_ = 3
    self.current_view_ = CornuRecordView.new(self)
    :addTo(self.content_)
    -- if self.cornucopiaList_ then 
    --    self.cornucopiaList_:removeFromParent()
    --    self.cornucopiaList_ = nil
    -- end

    -- self._myRecList = CronMyRecList.new(self)
     -- 这里添加我的记录列表 -- 
    -- self.cornucopiaList_ = CronMyRecList.new()
    -- self._myRecList:pos(- CronMyRecListContentSize.width / 2, - CronMyRecListContentSize.height / 2)
    -- :addTo(self.container_)

    --self.current_page_ = 3
   -- self.row_:pos(235,80)
    self:setButtonDef()
    self.my_cor_record_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
    self.my_record_Button_:setButtonImage("normal", "#cor_recrod_btn_down.png", true)
    self.my_record_Button_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[3], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
end

function CornuPopup:onCheckGameInfo()

    if self.current_page_ == 4 then return end
    if self.current_view_ then
        self.current_view_:removeFromParent()
        self.current_view_ = nil
    end
    self.current_page_ = 4
    self.current_view_ = CornuCheckInfoView.new():addTo(self.content_)
    self:setButtonDef()
    self.check_info_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
    self.check_info_Button_:setButtonImage("normal", "#cor_infomation_down.png", true)
    self.check_info_Button_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[4], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
end

function CornuPopup:setButtonDef()
    self.myCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-up-line.png"))
    self.myCorButton_:setButtonImage("normal", "#cor_my_cor_btn_up.png", true)
    self.myCorButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[1], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))

    self.my_friendsCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-up-line.png"))
    self.myFriendsCorButton_:setButtonImage("normal", "#cor_friend_btn_up.png", true)
    self.myFriendsCorButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[2], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))

    self.my_cor_record_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-up-line.png"))
    self.my_record_Button_:setButtonImage("normal", "#cor_record_btn_up.png", true)
    self.my_record_Button_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[3], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))

    self.check_info_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-up-line.png"))
    self.check_info_Button_:setButtonImage("normal", "#cor_infomation_up.png", true)
    self.check_info_Button_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[4], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
end
function CornuPopup:show()
    self:showPanel_()
end

function CornuPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, 0)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function CornuPopup:onShowed()
    if self.current_view_ then

        self.current_view_:onShowed()
    end
end
function CornuPopup:goFriendById(mid)
    self.goFid_ = mid
    self:onMyFriendsCor_()
end
function CornuPopup:onCleanup()
    
end
return CornuPopup