--
-- Author: johnny@boomegg.com
-- Date: 2014-08-23 17:50:02
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local FacebookPluginIos = class("FacebookPluginIos")
local logger = bm.Logger.new("FacebookPluginIos")

function FacebookPluginIos:ctor()
    luaoc.callStaticMethod("FacebookBridge", "initFB")
    self.cacheData_ = {}
end

function FacebookPluginIos:login(callback)
    self.loginCallback_ = callback
    luaoc.callStaticMethod("FacebookBridge", "login", {listener = handler(self, self.onLoginResult_)})
end

function FacebookPluginIos:onLoginResult_(tokenData)
    if self.loginCallback_ then
        -- tokenData["result"]  success/closed/failed
        local success = (tokenData and tokenData["result"] == "success")
        self.loginCallback_(success, tokenData)
    end
end

function FacebookPluginIos:logout()
    luaoc.callStaticMethod("FacebookBridge", "logout")
    self.cacheData_ = {}
end

function FacebookPluginIos:shareFeed(args, callback)
    if type(args) == "table" then
        self.shareFeedCallback_ = callback
        args.listener = handler(self, self.onShareFeedResult_)
        luaoc.callStaticMethod("FacebookBridge", "shareFeed", args);
    end
end

function FacebookPluginIos:onShareFeedResult_(status)
    print("Send feed with "..status)
    if self.shareFeedCallback_ then
        local success = (status ~= "failed" and status ~= "canceled")
        self.shareFeedCallback_(success, status)
    end
end

function FacebookPluginIos:getInvitableFriends(callback,limit)
    self.getInvitableFriendsCallback_ = callback
     limit = limit and (limit .. "") or "350"
    if self.cacheData_['getInvitableFriendsCallback_'] == nil then
        luaoc.callStaticMethod("FacebookBridge", "getInvitableFriends", {limit = limit,listener = handler(self, self.onGetInvitableFriendsResult_)})
    else
        self:onGetInvitableFriendsResult_(self.cacheData_['getInvitableFriendsCallback_'])        
    end   
end

function FacebookPluginIos:onGetInvitableFriendsResult_(invitabledFriends)
    --[[
        invitabledFriends = {
            {name = "yipang", id = "sdksl988fjf7fhjak", url = "www.caoliu.com"}, 
            {name = "erpang", id = "sdksl988fjf7fhjak", url = "www.caoliu.com"}, 
            {name = "sanpang", id = "sdksl988fjf7fhjak", url = "www.caoliu.com"}
        }
    ]]
    self.cacheData_['getInvitableFriendsCallback_'] = invitabledFriends
    if self.getInvitableFriendsCallback_ then
        local success = (invitabledFriends and type(invitabledFriends) == "table")
        self.getInvitableFriendsCallback_(success, invitabledFriends)
    end
end

function FacebookPluginIos:sendInvites(data, toIds, title, message, callback)
    self.sendInvitesCallback_ = callback
    luaoc.callStaticMethod("FacebookBridge", "sendInvites", {
        listener = handler(self, self.onsendInvitesResult_), 
        data = data, 
        toIds = toIds, 
        title = title, 
        message = message
    })
end

function FacebookPluginIos:onsendInvitesResult_(result)
    if result and self.sendInvitesCallback_ then
        local success = (result and result.requestId ~= "")
        self.sendInvitesCallback_(success, result)
    end
end

function FacebookPluginIos:updateAppRequest()
    luaoc.callStaticMethod("FacebookBridge", "getRequestId", {listener = handler(self, self.onGetRequestId_)})
    self.updateInviteRetryTimes_ = 3
end

function FacebookPluginIos:onGetRequestId_(result)
    -- dump(result,"iOS onGetRequestIdResult_ result")
    -- dump(type(result),"iOS onGetRequestIdResult_ result type")
 
    if (result ~= nil) and (type(result) == "table") and (result.requestData) and (result.requestId) then
        -- 老用户召回
        if string.find(result.requestData, 'oldUserRecall') ~= nil then
            local localData = string.gsub(result.requestData,"oldUserRecall","")
            cc.analytics:doCommand {
                command = 'eventCustom',
                args = {
                    eventId    = "invite_olduser_success_count",
                    attributes = "type,invite_olduser_success",
                    counter    = 1,
                },
            }
            -- bm.HttpService.POST(
            --     {
            --         mod = "recall",
            --         act = "update",
            --         data = localData,
            --         requestid = result.requestId
            --     },
            --     function (data)
            --         local retData = json.decode(data)
            --         if retData and retData.ret and retData.ret == 0 then
            --             -- 删除requestId
            --             luaoc.callStaticMethod("FacebookBridge", "deleteRequestId", {requestId = result.requestId})
            --         end
            --     end,
            --     function ()
            --         if self.updateInviteRetryTimes_ > 0 then
            --             self:onGetRequestIdResult_(result)
            --             self.updateInviteRetryTimes_ = self.updateInviteRetryTimes_ - 1
            --         end
            --     end
            -- )
        else
            -- 邀请新用户
            local d = {};
            d.data = result.requestData;
            d.requestid = result.requestId;
            nk.http.inviteAddMoney(d,function(data)
                luaoc.callStaticMethod("FacebookBridge", "deleteRequestId", {requestId = result.requestId})
            end,function(errData)
                if self.updateInviteRetryTimes_ > 0 then
                    self:onGetRequestId_(result)
                    self.updateInviteRetryTimes_ = self.updateInviteRetryTimes_ - 1
                end
            end)


          
        end

    end
end

return FacebookPluginIos
