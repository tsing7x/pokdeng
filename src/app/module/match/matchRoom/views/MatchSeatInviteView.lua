
--
-- Author: thinkeras3@163.com
-- Date: 2015-09-01 20:26:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
--



local MatchSeatInviteView = class("MatchSeatInviteView", function() 
    return display.newNode()
end)

MatchSeatInviteView.CLICKED = "MatchSeatInviteView.CLICKED"
MatchSeatInviteView.WIDTH = 108
MatchSeatInviteView.HEIGHT = 164

function MatchSeatInviteView:ctor(ctx)
	self.ctx_ = ctx
   -- self:retain()
	

	bm.EventCenter:addEventListener(nk.eventNames.UPDATE_SEAT_INVITE_VIEW, handler(self, self.onReciveData))

    local lastLoginType = nk.userDefault:getStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE)
    
    if lastLoginType ==  "FACEBOOK" then
        if nk.Facebook then
             nk.Facebook:getInvitableFriends(handler(self, self.onGetData_,nk.userData.inviteFriendLimit))
         else
            self:stopAll()
         end
    else
        self:stopAll()
    end
end
function MatchSeatInviteView:createNode_()
	self.background_ = display.newScale9Sprite("#room_seat_bg.png", 0, 0, cc.size(MatchSeatInviteView.WIDTH, MatchSeatInviteView.HEIGHT)):addTo(self, 2)
    self.image_ = display.newNode():add(display.newSprite("#common_male_avatar.png"), 1, 1):pos(0, 0)--:addTo(self)
    --4 用户头像剪裁节点
    self.clipNode_ = cc.ClippingNode:create()

    local stencil = display.newDrawNode()
    local pn = {{-50, -50}, {-50, 50}, {50, 50}, {50, -50}}  
    local clr = cc.c4f(255, 0, 0, 255)  
    stencil:drawPolygon(pn, clr, 1, clr)

    self.clipNode_:setStencil(stencil)
    self.clipNode_:addChild(self.image_, 2, 2)
    self.clipNode_:addTo(self, 4, 4)

    --5 头像灰色覆盖
    self.cover_ = display.newRect(100, 100, {fill=true, fillColor=cc.c4f(0, 0, 0, 0.6)})
        :addTo(self, 5, 5)
        :hide()
    self.nick_ = display.newTTFLabel({text = "", size = 24, align = ui.TEXT_ALIGN_CENTER, color=cc.c3b(0xff, 0xd1, 0x00)})
    :pos(0, 66)
    :addTo(self, 7, 7)

    cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
    :setButtonSize(100, 30)
    :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("FRIEND", "SEND_INVITE"), size=20, color=cc.c3b(0xff, 0xff, 0xff), align=ui.TEXT_ALIGN_CENTER}))
    :addTo(self,2)
    :pos(0,-66)
    :onButtonClicked(buttontHandler(self, self.onInviteClick_))
end
function MatchSeatInviteView:setViewInfo_(data)
     local nickName = nk.Native:getFixedWidthText("", 24, self.tempFriend.name, 110)
	self.nick_:setString(nickName)
	if string.len(data.url) > 5 then
	    local imgurl = data.url
	    if string.find(imgurl, "facebook") then
		    if string.find(imgurl, "?") then
		        imgurl = imgurl .. "&width=100&height=100"
		    else
		        imgurl = imgurl .. "?width=100&height=100"
		    end
		end
		self.seatImageLoaderId_ = nk.ImageLoader:nextLoaderId()
	    nk.ImageLoader:loadAndCacheImage(self.seatImageLoaderId_,
	        imgurl, 
	        handler(self,self.userImageLoadCallback_),
	        nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
	    )
	end
end
function MatchSeatInviteView:userImageLoadCallback_(success, sprite)
    if success and self.image_ then
        local img = self.image_:getChildByTag(1)
        if img then
            img:removeFromParent()
        end
        local spsize = sprite:getContentSize()
        if spsize.width > spsize.height then
            sprite:scale(100 / spsize.width)
        else
            sprite:scale(100 / spsize.height)
        end
        spsize = sprite:getContentSize()
        local seatSize = self:getContentSize()
        
        sprite:pos(seatSize.width * 0.5, seatSize.height * 0.5):addTo(self.image_, 1, 1)
    end
end
function MatchSeatInviteView:onGetData_(success, friendData, filterStr)
    if success then
    	if #friendData == 0 then

    	else
            self:createNode_()
            self.isInited = true;
            


            local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
            --logger:debug("invitedNames:" .. invitedNames)        
            --self.pageNum_ = checkint(nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_PAGE, 0))        

            if invitedNames ~= "" then
                local namesTable = string.split(invitedNames, "#")
                if namesTable[1] ~= os.date("%Y%m%d") then
                   -- logger:debug("clear invited names")
                    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
                    
                    -- if nk.config.INVITE_SORT_TYPE == 2 then
                    --     -- 保存页数                
                    --     self.pageNum_ = self.pageNum_ + 1
                    --     if self.pageNum_ > math.ceil(#friendData / 50) then
                    --         self.pageNum_ = 1
                    --     end   
                    --     nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_PAGE, self.pageNum_)
                    -- end
                    nk.userDefault:flush()
                else
                    table.remove(namesTable, 1)
                    for _, name in pairs(namesTable) do
                        local i, max = 1, #friendData
                        while i <= max do
                            if friendData[i].name == name then
                                table.remove(friendData, i)
                                i = i - 1
                                max = max - 1
                            end
                            i = i + 1
                        end
                    end
                    -- if nk.config.INVITE_SORT_TYPE == 2 and pageNum == 0 then
                    --     --self.pageNum_ = 1
                    --     nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_PAGE, pageNum)
                    --     nk.userDefault:flush()
                    -- end
                end
            end
            --friendData = {{id=1,name="thinker",url = ""},{id=2,name="vanfo",url=""},{id=3,name="seanYang",url = ""}}
            self.friendData_ = friendData;

	    	--local index = checkint(math.random(#self.friendData_))
            --dump(friendData,"friendData=====")
	    	--self.tempFriend = self.friendData_[index];
	    	--self:setViewInfo_(self.tempFriend)
	    end
    end

end
function MatchSeatInviteView:changeFriend() 
    local index = checkint(math.random(#self.friendData_))
    self.tempFriend = self.friendData_[index];
    self:setViewInfo_(self.tempFriend)
end
function MatchSeatInviteView:onInviteClick_()
	local toIds = ""
    local names = ""
	local toIdArr = {}
    local nameArr = {}
    self.clickedData = self.tempFriend;
    --self:changeFriend()
    --self:runTime()
    self.lastTid_ = self.ctx_.model.roomInfo.tid;

    
    self:stopAll()
    table.insert(toIdArr, self.clickedData.id)
    table.insert(nameArr, self.clickedData.name)
    dump(self.tempFriend.id,"id")
    dump(self.tempFriend.name,"name")
    toIds = table.concat(toIdArr, ",")
    names = table.concat(nameArr, "#")


    -- for i, v in ipairs( self.friendData_ ) do
    --                             if self.friendData_[i].id == self.clickedData.id then
    --                                 table.remove(self.friendData_,i)
    --                             end
    --                         end

    -- dump(self.friendData_,"self.friendData_")
    -- do return end
   
	nk.http.getInviteId(
            function (data)
                local retData = data;
                local requestData = ""
                requestData = retData.sk

                 nk.Facebook:sendInvites(
                    requestData, 
                    toIds, 
                    bm.LangUtil.getText("FRIEND", "INVITE_SUBJECT"), 
                    bm.LangUtil.getText("FRIEND", "INVITE_CONTENT", "100K"), 
                    function (success, result)
                        if success then
                            -- 保存邀请过的名字
                            if names ~= "" then
                                local invitedNames = nk.userDefault:getStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, "")
                                local today = os.date("%Y%m%d")
                                if invitedNames == "" or string.sub(invitedNames, 1, 8) ~= today then
                                    invitedNames = today .."#" .. names
                                else
                                    invitedNames = invitedNames .. "#" .. names
                                end
                                nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_INVITED_NAMES, invitedNames)
                                nk.userDefault:flush()
                            end
                        	-- 去掉最后一个逗号
                            if result.toIds then
                                local idLen = string.len(result.toIds)
                                if idLen > 0 and string.sub(result.toIds, idLen, idLen) == "," then
                                    result.toIds = string.sub(result.toIds, 1, idLen - 1)
                                end
                            end

                            for i, v in ipairs( self.friendData_ ) do
                                if self.friendData_[i].id == self.clickedData.id then
                                    table.remove(self.friendData_,i)
                                end
                            end

                            local postData = {
                                data = requestData, 
                                requestid = result.requestId, 
                                toIds = result.toIds, 
                                source = "register"
                            }
                            nk.http.inviteReport(
                                postData, 
                                function (data)
                                end
                            )
                        end
                    end,
                   	function()

                   	end
                  )
            end,
            function()
            	nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end
    )
                
end

function MatchSeatInviteView:onReciveData(evt)
	self.ctx_ = evt.data.ctx;
	local seatId = evt.data.seatId;
	local standUpSeatId = evt.data.standUpSeatId;

    --没有初始化完成，一切都是个屁
    if not self.isInited then
        return
    end
    if not self.friendData_ then
        return
    end 	
	--如果已经已经有显示出ui，并且不等于新坐下的玩家ID，不操作
	if seatId and self.isShow and seatId ~= self.inviteSeatId then
		return
	end

	--如果有人站起，并且ui已经显示出来，不操作
	if standUpSeatId and self.isShow and self.ctx_.model:isSelfInSeat() then   
		return
	end
	self:stopAction(self.actions_)
	self:hide()
    self.isShow = false;
	self.inviteSeatId = nil;

    if #self.friendData_ == 0 then
        dump("没有人了")
        return
    end
	self.actions_ = self:schedule(function ()
		local emptySeatId = self.ctx_.seatManager:getEmptySeatId()
		if emptySeatId and self.ctx_.model:isSelfInSeat() and self.lastTid_ ~= self.ctx_.model.roomInfo.tid then
			self:show()
            self.isShow = true;
		    local seatView_ = self.ctx_.seatManager:getSeatView(emptySeatId)
		    self.inviteSeatId = emptySeatId;
		    local tempX,tempY = seatView_:getPosition()
		    self:pos(tempX,tempY)
		    self:stopAction(self.actions_)
            self:changeFriend()
            self:runTime()
		else
			self:stopAll()
		end
	end,1)
end
function MatchSeatInviteView:runTime()
    self:stopAction(self.actions_)
    self.actions_ = self:schedule(function ()
        self:changeFriend()
        self:runTime()
    end,20)
end
function MatchSeatInviteView:onCleanup()
	bm.EventCenter:removeEventListener(nk.eventNames.UPDATE_SEAT_INVITE_VIEW)
end
-- function MatchSeatInviteView:dispose()
--     self:stopAction(self.actions_)
--     self:release()
-- end
function MatchSeatInviteView:stopAll()
            self.inviteSeatId = nil
            self:hide()
            self.isShow = false;
            self:stopAction(self.actions_)
end
return MatchSeatInviteView