--
-- Author: thinkeras3@163.com
-- Date: 2015-08-10 14:11:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
--
local Panel = import("app.pokerUI.Panel")
local CornucopiaPopup = class("CornucopiaPopup", Panel)
local CornucopiaInfoDialog = import(".CornucopiaInfoDialog")
local CornucopiaPopupController = import(".CornucopiaPopupController")
local SeedInfoDialog = import(".SeedInfoDialog")
local LoginFbDialog  = import(".LoginFbDialog")
local SelectSeedDialog = import(".SelectSeedDialog")
local GetedRewardDialog = import(".GetedRewardDialog")
local CornucopiaList  = import(".CornucopiaList")
local CronMyRecList = import(".CornListMyRec")

local PADDING = 16
local POPUP_WIDTH = 760
local POPUP_HEIGHT = 510

local SEED_Y = 175
local SEED_WIDTH = 77
local SEED_HEIGHT = 50

function CornucopiaPopup:ctor(tab)
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    display.addSpriteFrames("farm.plist", "farm.png")
    self:setNodeEventEnabled(true)
	 CornucopiaPopup.super.ctor(self, {760, 520})
	self:createNodes_()
    self.controller_ = CornucopiaPopupController.new(self)
    --self.controller_:getLevelRanlIds()
    if tab then
        if tab == 1 then
            self:onMyCor_()
        elseif tab == 2 then
            self:onMyFriendsCor_()
        elseif tab==3 then
            self:onMyRecordCor_()
        end
        self.current_page_ = tab;
    else
         self:onMyCor_()
         self.current_page_=1;
    end
end
function CornucopiaPopup:createNodes_()
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

     self.shareSeedBg_ = display.newScale9Sprite("#cor_words_bg.png", 0, 0,cc.size(180,20))
     :pos(-270,228)--
     :addTo(self)

     local shareX,shareY = self.shareSeedBg_:getPosition();
     shareX = shareX+(180/2)
     self.share_btn_ = cc.ui.UIPushButton.new("#cor_share_btn.png")
     :pos(shareX,shareY)
     :addTo(self)
     :onButtonClicked(buttontHandler(self,self.shareBtnClick_))

     display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","SHARE_SEED"), color = cc.c3b(0x1f, 0x8d, 0xea), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :addTo(self)
     :pos(shareX-103,shareY+3)

     self.questionTxtBg_ = display.newScale9Sprite("#cor_words_bg.png", 0, 0,cc.size(145,20))
     :pos(270,228)
     :addTo(self)

     local questionX,questionY = self.questionTxtBg_:getPosition();
     questionX= questionX -(155/2);--
     self.question_btn_ = cc.ui.UIPushButton.new("#cor_question_btn.png")
     :pos(questionX,questionY)
     :addTo(self)
     :onButtonClicked(buttontHandler(self,self.checkInfoClick_))

     display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","CHECK_INFO"), color = cc.c3b(0x67, 0xcd, 0x32), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :addTo(self)
     :pos(questionX+73,questionY+3)

     display.newScale9Sprite("#cor_words_bg.png", 0, 0,cc.size(720,80))
     :pos(0,173)
     :addTo(self)

------------------
     cc.ui.UIPushButton.new("#cor_ingot.png")
     :pos(-310,SEED_Y+3)
     :addTo(self)
     :onButtonClicked(buttontHandler(self,self.ingotSeedClick_))

     cc.ui.UIPushButton.new("#cor_silver.png")
     :pos(-80,SEED_Y)
     :addTo(self)
     :onButtonClicked(buttontHandler(self,self.silverSeedClick_))

     cc.ui.UIPushButton.new("#cor_water.png")
     :pos(165,SEED_Y-2)
     :addTo(self)
     :onButtonClicked(buttontHandler(self,self.speedSeedClick_))

     self.ingotLeftNum_txt_ = display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","LEFT_NUM"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :addTo(self)
     :pos(-310+78,SEED_Y+3)

     self.silverLeftNum_txt_ = display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","LEFT_NUM"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :addTo(self)
     :pos(-80+78,SEED_Y+3)

     self.speedLeftNum_ = display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","LEFT_NUM"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
     :addTo(self)
     :pos(165+78,SEED_Y+3)

----
	local labelPosX = -self.width_ * 0.5 + 12 * 2 +140
    local labelPosY = self.height_ * 0.5 - 12 * 3 +58
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
        :pos(labelPosX + 445 ,labelPosY - 190)
        :addTo(self)    
    self.my_record_Button_ = cc.ui.UIPushButton.new({normal = "#cor_record_btn_up.png", pressed = "#cor_recrod_btn_down.png"})
        :pos(labelPosX + 358,labelPosY - 172)
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
        :pos(labelPosX + 235 ,labelPosY - 190)
        :addTo(self)
    self.myFriendsCorButton_ = cc.ui.UIPushButton.new({normal = "#cor_friend_btn_up.png", pressed = "#cor_friend_btn_down.png"})
        :pos(labelPosX + 124,labelPosY - 172)
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

        --箭头
        self.row_ = display.newSprite("#cor_row.png")
        :pos(0,80)
        :addTo(self)

        --内容背景
        display.newScale9Sprite("#cor_words_bg.png",0,0,cc.size(722,312))
        :pos(0 ,-80)
        :addTo(self)

     self.container_ = display.newNode()
     :addTo(self)
     :pos(0,-80)
     
        display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","BUTTOM_TIPS"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :addTo(self)
        :pos(0,-245)



    --关闭按钮
    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#cor_close_btn_up.png", pressed = "#cor_close_btn_down.png"})
        :align(display.CENTER)
        :pos(POPUP_WIDTH/2-5,POPUP_HEIGHT/2-5)
        :onButtonClicked(function() 
            self:onClose()
            nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
        end)
        :addTo(self)

       
end
function CornucopiaPopup:onMyCor_()
    if self.current_page_ == 1 then  return end;
    if self.current_page_ == 3 then
        if self._myRecList then
            --todo
            self._myRecList:removeFromParent()
        end
    end
    self.current_page_ = 1

    if self.cornucopiaList_ == nil then
        self.cornucopiaList_ = CornucopiaList.new(self)
        self.cornucopiaList_:addTo(self.container_)
    end
    self.cornucopiaList_:show(1)
	self.row_:pos(-235,80)
    self:setButtonDef()
    self.myCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
    self.myCorButton_:setButtonImage("normal", "#cor_my_cor_btn_down.png", true)
    self.myCorButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[1], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
end
function CornucopiaPopup:onMyFriendsCor_()
    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    if lastLoginType == "GUEST" then
        LoginFbDialog.new(self):show()
        return
    end
     if self.current_page_ == 2 then  return end;
     if self.current_page_ == 3 then
        if self._myRecList then
            --todo
            self._myRecList:removeFromParent()
        end
    end
    self.current_page_ = 2
    if self.cornucopiaList_ == nil then
        self.cornucopiaList_ = CornucopiaList.new(self)
        self.cornucopiaList_:addTo(self.container_)
    end
    self.cornucopiaList_:show(2)
	self.row_:pos(0,80)
    self:setButtonDef()
    self.my_friendsCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
    self.myFriendsCorButton_:setButtonImage("normal", "#cor_friend_btn_down.png", true)
    self.myFriendsCorButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[2], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
end
function CornucopiaPopup:onMyRecordCor_()

     local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    if lastLoginType == "GUEST" then
        LoginFbDialog.new(self):show()
        return
    end

    local CronMyRecListContentSize = {
        width = 690,
        height = 288
    }

    if self.current_page_ == 3 then  return end;
    if self.cornucopiaList_ then 
       self.cornucopiaList_:removeFromParent()
       self.cornucopiaList_ = nil
    end

    self._myRecList = CronMyRecList.new(self)
     -- 这里添加我的记录列表 -- 
    -- self.cornucopiaList_ = CronMyRecList.new()
    self._myRecList:pos(- CronMyRecListContentSize.width / 2, - CronMyRecListContentSize.height / 2)
    :addTo(self.container_)

    self.current_page_ = 3
	self.row_:pos(235,80)
    self:setButtonDef()
	self.my_cor_record_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
	self.my_record_Button_:setButtonImage("normal", "#cor_recrod_btn_down.png", true)
	self.my_record_Button_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[3], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
end
function CornucopiaPopup:checkInfoClick_()
    CornucopiaInfoDialog.new():show()
end

function CornucopiaPopup:shareBtnClick_()
    
    -- local feedData = clone(bm.LangUtil.getText("FEED", "COR_SHARE_MY_COR"))
    --         nk.Facebook:shareFeed(feedData, function(success, result)
    --         print("FEED.FREE_COIN result handler -> ", success, result)
    --         if not success then
    --             nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
    --          else
    --             nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS")) 
    --             self.controller_:shareToGetSeed(1) 
    --          end
    --     end)
    nk.sendFeed:share_my_cor_(function()
        self.controller_:shareToGetSeed(1) 
        end)
end

function CornucopiaPopup:setButtonDef()
    self.myCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-up-line.png"))
    self.myCorButton_:setButtonImage("normal", "#cor_my_cor_btn_up.png", true)
    self.myCorButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[1], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))

    self.my_friendsCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-up-line.png"))
    self.myFriendsCorButton_:setButtonImage("normal", "#cor_friend_btn_up.png", true)
    self.myFriendsCorButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[2], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))

    self.my_cor_record_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-up-line.png"))
    self.my_record_Button_:setButtonImage("normal", "#cor_record_btn_up.png", true)
    self.my_record_Button_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[3], color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
end

function CornucopiaPopup:show()
    self:showPanel_()
end
function CornucopiaPopup:ingotSeedClick_()
    SeedInfoDialog.new():show(1,self.myCorData_.jininfo)
    --LoginFbDialog.new():show()
end
function CornucopiaPopup:silverSeedClick_()
   SeedInfoDialog.new():show(2,self.myCorData_.yininfo)
   --GetedRewardDialog.new():show(2)
end
function CornucopiaPopup:speedSeedClick_()
    SeedInfoDialog.new():show(3,self.myCorData_.shortinfo)
   --SelectSeedDialog.new():show()
end
function CornucopiaPopup:setMyCorData(data)
    self.myCorData_ = data;
    self.ingotLeftNum_txt_:setString(bm.LangUtil.getText("DORNUCOPIA","LEFT_NUM",self.myCorData_.jininfo.num))
    self.silverLeftNum_txt_:setString(bm.LangUtil.getText("DORNUCOPIA","LEFT_NUM",self.myCorData_.yininfo.num))
    self.speedLeftNum_:setString(bm.LangUtil.getText("DORNUCOPIA","LEFT_NUM",self.myCorData_.shortinfo.num))
   if self.cornucopiaList_ ~= nil then
        self.cornucopiaList_:setMyData(self.myCorData_.bowl)
   end 
end

function CornucopiaPopup:setFriendCorData(data)
    if self.cornucopiaList_ ~= nil then
        self.cornucopiaList_:setFriendCorData(data)
   end 
end
function CornucopiaPopup:setMyRecListData(data)
    -- body
    self._myRecDataList = data

    if self._myRecList then
        --todo
        self._myRecList:setListData(data)
    end

end
function CornucopiaPopup:openSelectSeed(id)
    SelectSeedDialog.new(self,self.myCorData_):show(id)
end
function CornucopiaPopup:addSpeed(id)
    self.controller_:addSpeed(id)
end
function CornucopiaPopup:setFriendList(idArr)
    if self.cornucopiaList_ then
        self.cornucopiaList_:setFriendList(idArr)
    end
end
function CornucopiaPopup:toFriendCor(fid)
     if self.current_page_ == 2 then  return end;
     if self.current_page_ == 3 then
        if self._myRecList then
            --todo
            self._myRecList:removeFromParent()
        end
    end
    self.current_page_ = 2
    if self.cornucopiaList_ == nil then
        self.cornucopiaList_ = CornucopiaList.new(self)
        self.cornucopiaList_:addTo(self.container_)
    end
    self.cornucopiaList_:setFindId(fid)
    self.cornucopiaList_:show(2)
    self.row_:pos(0,80)
    self:setButtonDef()
    self.my_friendsCor_line_:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("user-info-desc-button-background-down-line.png"))
    self.myFriendsCorButton_:setButtonImage("normal", "#cor_friend_btn_down.png", true)
    self.myFriendsCorButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","MAIN_TAB_TEXT")[2], color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER}))
    
end
function CornucopiaPopup:setLoading(isLoading)
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
function CornucopiaPopup:onCleanup()
    self.controller_:dispose()
end
return CornucopiaPopup