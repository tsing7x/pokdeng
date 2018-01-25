
local MessageData = class("MessageData")

-- 相当于static
MessageData.hasNewMessage = false
MessageData.newMsgType = {}

function MessageData:ctor()
    self:requestMessageData()
end

function MessageData:requestMessageData()

    self.requestMessageDataId = nk.http.getUserMessage(handler(self, self.onGetMessageData),function() end)


    --[[
    self.requestMessageDataId = bm.HttpService.POST(
    {
        mod = "user", 
        act = "getmsg", 
    }, 
    handler(self, self.onGetMessageData), 
    function (data)
        
    end
    )
--]]
end

function MessageData:onGetMessageData(data)
    MessageData.hasNewMessage = false
    if data then
        -- local jsonData = json.decode(data)
        for i=1, #data, 1 do
            if checkint(data[i].c) ~= 1 then
                MessageData.hasNewMessage = true
                -- break
                MessageData.newMsgType[(#MessageData.newMsgType+1)] = checkint(data[i].b)
            end
        end    
    end

    bm.DataProxy:setData(nk.dataKeys.NEW_MESSAGE, MessageData.hasNewMessage)
end

return MessageData