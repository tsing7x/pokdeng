--
-- Author: tony
-- Date: 2014-08-18 16:49:49
--
local FacebookPluginAndroid = class("FacebookPluginAndroid")
local logger = bm.Logger.new("FacebookPluginAndroid")

function FacebookPluginAndroid:ctor()
    self.loginResultHandler_ = handler(self, self.onLoginResult_)
    self.invitableFriendsResultHandler_ = handler(self, self.onInvitableFriendsResult_)
    self.sendInvitesResultHandler_ = handler(self, self.onSendInvitesResult_)
    self.shareFeedResultHandler_ = handler(self, self.onShareFeedResult_)
    self.getRequestIdHandler_ = handler(self, self.onGetRequestIdResult_)

    self:call_("setLoginCallback", {self.loginResultHandler_}, "(I)V")
    self:call_("setInvitableFriendsCallback", {self.invitableFriendsResultHandler_}, "(I)V")
    self:call_("setSendInvitesCallback", {self.sendInvitesResultHandler_}, "(I)V")
    self:call_("setShareFeedResultCallback", {self.shareFeedResultHandler_}, "(I)V")
    self:call_("setGetRequestIdResultCallback", {self.getRequestIdHandler_}, "(I)V")

    self.cacheData_ = {}
end

function FacebookPluginAndroid:login(callback)
    self.loginCallback_ = callback
    self:call_("login", {}, "()V")
end

function FacebookPluginAndroid:logout()
    self.cacheData_ = {}
    self:call_("logout", {}, "()V")
end

function FacebookPluginAndroid:getInvitableFriends(callback,limit)
    self.getInvitableFriendsCallback_ = callback
    limit = limit and (limit .. "") or "200"
    if self.cacheData_['getInvitableFriendsCallback_'] == nil then
        self:call_("getInvitableFriends", {limit}, "(Ljava/lang/String;)V")
    else
        self:onInvitableFriendsResult_(self.cacheData_['getInvitableFriendsCallback_'])
    end
end

function FacebookPluginAndroid:sendInvites(data, toID, title, message, callback)
    self.sendInvitesCallback_ = callback  
    self:call_("sendInvites", {data, toID, title, message}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
end

function FacebookPluginAndroid:shareFeed(params, callback)
    self.shareFeedCallback_ = callback
    self:call_("shareFeed", {json.encode(params)}, "(Ljava/lang/String;)V")
end

function FacebookPluginAndroid:updateAppRequest()
    self.updateInviteRetryTimes_ = 3
    self:call_("getRequestId", {}, "()V")
end

function FacebookPluginAndroid:onGetRequestIdResult_(result)
    logger:debugf("onGetRequestIdResult_ %s", result)

    if result == "canceled" or result == "failed" then return end

    result = json.decode(result)
    if result and result.requestData and result.requestId then
        if string.find(result.requestData,"oldUserRecall") ~= nil then
            local localData = string.gsub(result.requestData,"oldUserRecall","")
            cc.analytics:doCommand{
                command = "eventCustom",
                args = {
                    eventId = "invite_olduser_success_count",
                    attributes = "type,invite_olduser_success",
                    counter = 1
                }
            }


            do return end
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
            --             self:call_("deleteRequestId", {result.requestId}, "(Ljava/lang/String;)V")
            --         end
            --     end, 
            --     function ()
            --         if self.updateInviteRetryTimes_ > 0 then
            --             self:onGetRequestIdResult_(result)
            --             self.updateInviteRetryTimes_ = self.updateInviteRetryTimes_ - 1
            --         end
            --     end
            -- )

        elseif string.find(result.requestData,"typeMouther")~= nil then
            local stringTab = string.split(result.requestData,";")
            local d = {};
            d.data = stringTab[1];
            d.requestid = result.requestId;
            d.event="flower";
            nk.http.inviteAddMoney(d,function(data)
                    self:call_("deleteRequestId", {result.requestId}, "(Ljava/lang/String;)V")
            end,function()
                if self.updateInviteRetryTimes_ > 0 then
                    self:onGetRequestIdResult_(result)
                    self.updateInviteRetryTimes_ = self.updateInviteRetryTimes_ - 1
                end
            end)

        else
            local d = {};
            d.data = result.requestData;
            d.requestid = result.requestId;

            nk.http.inviteAddMoney(d,function(data)
                -- local retData = json.decode(data)
                -- if retData and retData.ret and retData.ret == 0 then
                    -- 删除requestId
                    self:call_("deleteRequestId", {result.requestId}, "(Ljava/lang/String;)V")
                -- end
            end,function(errData)
                if self.updateInviteRetryTimes_ > 0 then
                    self:onGetRequestIdResult_(result)
                    self.updateInviteRetryTimes_ = self.updateInviteRetryTimes_ - 1
                end
            end)

           
        end
    end
end

function FacebookPluginAndroid:onShareFeedResult_(result)
    logger:debugf("onShareFeedResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if self.shareFeedCallback_ then
        self.shareFeedCallback_(success, result)
    end
end

function FacebookPluginAndroid:onSendInvitesResult_(result)
    logger:debugf("onSendInvitesResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if success then        
        result = json.decode(result)        
    end
    if self.sendInvitesCallback_ then
        self.sendInvitesCallback_(success, result)
    end
end

function FacebookPluginAndroid:onInvitableFriendsResult_(result)
    logger:debugf("onInvitableFriendsResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if success then
        self.cacheData_['getInvitableFriendsCallback_'] = result
        result = json.decode(result)
    end
    if self.getInvitableFriendsCallback_ then        
        self.getInvitableFriendsCallback_(success, result)
    end
end

function FacebookPluginAndroid:onLoginResult_(result)
    logger:debugf("onLoginResult_ %s", result)
    local success = (result ~= "canceled" and result ~= "failed")
    if success then
        local jsonObj = json.decode(result)
        if jsonObj ~= nil then
            result = jsonObj
        end
        
    end
    if self.loginCallback_ then
        self.loginCallback_(success, result)
    end
end

function FacebookPluginAndroid:call_(javaMethodName, javaParams, javaMethodSig)
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/boyaa/cocoslib/facebook/FacebookBridge", javaMethodName, javaParams, javaMethodSig)
        if not ok then
            if ret == -1 then
                logger:errorf("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
            elseif ret == -2 then
                logger:errorf("call %s failed, -2 无效的签名", javaMethodName)
            elseif ret == -3 then
                logger:errorf("call %s failed, -3 没有找到指定的方法", javaMethodName)
            elseif ret == -4 then
                logger:errorf("call %s failed, -4 Java 方法执行时抛出了异常", javaMethodName)
            elseif ret == -5 then
                logger:errorf("call %s failed, -5 Java 虚拟机出错", javaMethodName)
            elseif ret == -6 then
                logger:errorf("call %s failed, -6 Java 虚拟机出错", javaMethodName)
            end
        end
        return ok, ret
    else
        logger:debugf("call %s failed, not in android platform", javaMethodName)
        return false, nil
    end
end

return FacebookPluginAndroid
