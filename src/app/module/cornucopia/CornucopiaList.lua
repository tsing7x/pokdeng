local Panel = import("app.pokerUI.Panel")
local CornucopiaListItem = import(".CornucopiaListItem")
local LoginFbDialog  = import(".LoginFbDialog")
local CornucopiaList = class("CornucopiaList", function()return display.newNode() end)
	-- body
 local WIDTH = 722
 local HEIGHT = 312
 local SIDE_GAP = 70
 local ROW_SIDE_GAP = 15
 local ITEM_WIDTH = 136
 local GAP = 15
function CornucopiaList:ctor(parentNode)
    self.parentNode_ = parentNode

    self.buttton_tab_ = {}

    local item = nil;
    item = CornucopiaListItem.new(self)
    :addTo(self)
    :pos(-(WIDTH/2)+SIDE_GAP+ITEM_WIDTH/2,95)
    table.insert(self.buttton_tab_,item)

    item = CornucopiaListItem.new(self)
    :addTo(self)
    :pos(-(WIDTH/2)+SIDE_GAP+ITEM_WIDTH/2 + ITEM_WIDTH+GAP,95)
    table.insert(self.buttton_tab_,item)

    item = CornucopiaListItem.new(self)
    :addTo(self)
    :pos((WIDTH/2)-SIDE_GAP-ITEM_WIDTH/2 - ITEM_WIDTH-GAP,95)
    table.insert(self.buttton_tab_,item)

    item = CornucopiaListItem.new(self)
    :addTo(self)
    :pos((WIDTH/2)-SIDE_GAP-ITEM_WIDTH/2,95)
    table.insert(self.buttton_tab_,item)

    item = CornucopiaListItem.new(self)
    :addTo(self)
    :pos(-(WIDTH/2)+SIDE_GAP+ITEM_WIDTH/2,-55)
    table.insert(self.buttton_tab_,item)

    item = CornucopiaListItem.new(self)
    :addTo(self)
    :pos(-(WIDTH/2)+SIDE_GAP+ITEM_WIDTH/2 + ITEM_WIDTH+GAP,-55)
    table.insert(self.buttton_tab_,item)

    item = CornucopiaListItem.new(self)
    :addTo(self)
    :pos((WIDTH/2)-SIDE_GAP-ITEM_WIDTH/2 - ITEM_WIDTH-GAP,-55)
    table.insert(self.buttton_tab_,item)

    item = CornucopiaListItem.new(self)
    :addTo(self)
    :pos((WIDTH/2)-SIDE_GAP-ITEM_WIDTH/2,-55)
    table.insert(self.buttton_tab_,item)

    self.left_row = cc.ui.UIPushButton.new("#cor_change_row.png")
    :addTo(self)
    :onButtonClicked(buttontHandler(self,self.onLeftBtnClick_))
    :pos(-(WIDTH/2)+2*ROW_SIDE_GAP,0)

    self.right_row = cc.ui.UIPushButton.new("#cor_row_right.png")
    :addTo(self)
    :pos((WIDTH/2) - 2*ROW_SIDE_GAP,0)
    :onButtonClicked(buttontHandler(self,self.onRightBtnClick_))



    self.friendHead = display.newNode()
    :addTo(self);
    -- 头像
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(57 / 100)
        :pos(-323, 115)
        :addTo(self.friendHead)
    self.avatarBg_ = display.newSprite("#ranking_avatar_bg.png")
        :pos(-323, 115)
        :scale(90 / 100)
        :addTo(self.friendHead)
    self.genderIcon_ = display.newSprite("#male_icon.png")
        :pos(-299, 95)
        :addTo(self.friendHead)
        :scale(0.7)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id
    self.nick_ =  display.newTTFLabel({text = "", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER})
    :align(display.LEFT_CENTER, -356, 115-43)
    :addTo(self.friendHead)

    self.nick_:setString(nk.Native:getFixedWidthText("", 20, ("ddddd" or "ddddd"), 67))
end

function CornucopiaList:show(ctype)
    self.m_type = ctype;
    self:allItemStatus(false)
    if ctype == 1 then
        self:allItemStatus(true)
        self:typeVisible(false)
        self:getMyCorInfo()
    else
        if self.friendIdArr_ == nil then--请求拉取好友id接口
             self.parentNode_.controller_:getLevelRanlIds()
        else
            if #self.friendIdArr_>0 then
                 self:getFriendCorInfo(self.currentIndex_)
                  --self:setButtonVisible(self.currentIndex_,#self.friendIdArr_)
                  self:allItemStatus(true)
                  self.friendHead:show()
            else
                self.friendHead:hide()
                self:allItemStatus(false)
                self:setButtonVisible(1,#self.friendIdArr_)
            end
            
        end
        
    end
end
function CornucopiaList:allItemStatus(boo)
    for i=1,8 do
        local item = self.buttton_tab_[i]
        if boo then 
            item:show()
        else
            item:hide()
        end
    end
end
function CornucopiaList:getMyCorInfo()
    self.parentNode_.controller_:getSelfCornucopia()
end
function CornucopiaList:getFriendCorInfo(index)
    if index== nil then
        self.currentIndex_ = 1;
    else
        self.currentIndex_ = index
    end
    if self.findId then
        for i=1,#self.friendIdArr_ do 
            if checkint(self.findId) == checkint(self.friendIdArr_[i].mid) then
                self.currentIndex_ = i;
            end
        end
    end
   self.findId = nil;
   self:setButtonVisible(self.currentIndex_,#self.friendIdArr_)
   self:getFriendCorByIndex()
end
function CornucopiaList:getFriendCorByIndex()
     local fid = self.friendIdArr_[self.currentIndex_].mid
     self.fid = fid;
    if checkint(fid) > 0 then
        self.parentNode_.controller_:getFriendCornucopia(fid);
    end
end
function CornucopiaList:setButtonVisible(index,totalIndex)
    if totalIndex==0 or totalIndex == 1 then
        self.left_row:hide()
        self.right_row:hide()
        return;
    end

    if index == 1 then
        self.left_row:hide()
        self.right_row:show()
    end
    if index > 1 and index<totalIndex then
        self.left_row:show()
        self.right_row:show()
    end
    if index == totalIndex then
        self.left_row:show()
        self.right_row:hide()
    end

end
function CornucopiaList:typeVisible(boo)
    if boo then
        self.right_row:show()
        self.left_row:show()
        self.friendHead:show()
    else
        self.left_row:hide()
        self.right_row:hide()
        self.friendHead:hide()
    end
end
function CornucopiaList:setFriendList(idArr)
    self.friendIdArr_ = idArr
    self.currentIndex_ = 1
    if self.m_type == 2 then
        if #self.friendIdArr_ > 0 then
            self:getFriendCorInfo(1)
            --self:setButtonVisible(1,#self.friendIdArr_)
            self:allItemStatus(true)
            self.friendHead:show()
        else
             self:allItemStatus(false)
             self.friendHead:hide()
             self:setButtonVisible(1,#self.friendIdArr_)
        end
        
    end
end
function CornucopiaList:setFindId(id)
    self.findId = id;
end
function CornucopiaList:onLeftBtnClick_()
    self.currentIndex_  = self.currentIndex_ - 1;
    self:setButtonVisible(self.currentIndex_,#self.friendIdArr_)
     self:getFriendCorInfo(self.currentIndex_)
end
function CornucopiaList:onRightBtnClick_()
    self.currentIndex_ = self.currentIndex_ + 1;
    self:setButtonVisible(self.currentIndex_,#self.friendIdArr_)
    self:getFriendCorInfo(self.currentIndex_)
end
function CornucopiaList:setMyData(data)
    if self.m_type == 2 then

        return ;
    end
    if data then
        for i=1,8 do
            local item = self.buttton_tab_[i]
            item:setData(data["60"..i]);
        end
    end
end
function CornucopiaList:setFriendCorData(data)
    self.friendData_ = data;
    self.nick_:setString(nk.Native:getFixedWidthText("", 20, (self.friendData_.userinfo.name or ""), 67))
    if data then
        for i=1,8 do
            local item = self.buttton_tab_[i]
            item:setFriendCorData(data["60"..i]);
        end
    end
    
     if checkint(data.userinfo.msex) ~= 1 then
         self.genderIcon_:setSpriteFrame(display.newSpriteFrame("female_icon.png"))
         self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
     else
         self.genderIcon_:setSpriteFrame(display.newSpriteFrame("male_icon.png"))
         self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
     end

    if data.userinfo.micon and string.len(data.userinfo.micon) > 5 then
        --self.schedulerPool_:delayCall(function()
            nk.ImageLoader:loadAndCacheImage(
            self.userAvatarLoaderId_, 
            data.userinfo.micon, 
            handler(self, self.onAvatarLoadComplete_), 
            nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
        )
        --end, 0.5 + 0.1 * self.index_)
    end 
end
function CornucopiaList:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(57 / texSize.width)
        self.avatar_:setScaleY(57 / texSize.height)
        self.avatarLoaded_ = true
    end
end
function CornucopiaList:onItemDeactived()
    if self.created_ then
        nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
        if self.avatarLoaded_ then
            self.avatarLoaded_ = false
            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
            self.avatar_:scale(57 / 100)
            self.avatarDeactived_ = true
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
    end
end
function CornucopiaList:openLock(id)
    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    if lastLoginType == "GUEST" then
        LoginFbDialog.new(self.parentNode_):show()
        return
    end
    self.parentNode_.controller_:openLock(id)
end
function CornucopiaList:openSelectSeed(id)
    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    if lastLoginType == "GUEST" then
        LoginFbDialog.new(self.parentNode_):show()
        return
    end
    self.parentNode_:openSelectSeed(id);
end
function CornucopiaList:addSpeed(id)
    self.parentNode_:addSpeed(id);
end
function CornucopiaList:getMyTree(plandId)
     local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    if lastLoginType == "GUEST" then
        LoginFbDialog.new(self.parentNode_):show()
        return
    end
    self.parentNode_.controller_:reapMySeed(plandId)
end
function CornucopiaList:getFriendTree(plandId)
     self.parentNode_.controller_:stealFriendSeed(self.fid,plandId)
end
return CornucopiaList