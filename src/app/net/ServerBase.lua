--
-- Author: LeoLuo
-- Date: 2015-05-09 09:59:20
--
local ServerBase = class("ServerBase")

ServerBase.EVT_PACKET_RECEIVED     = "ServerBase.EVT_PACKET_RECEIVED"
ServerBase.EVT_CONNECTED         = "ServerBase.EVT_CONNECTED"
ServerBase.EVT_CONNECT_FAIL        = "ServerBase.EVT_CONNECT_FAIL"
ServerBase.EVT_CLOSED             = "ServerBase.EVT_CLOSED"
ServerBase.EVT_ERROR             = "ServerBase.EVT_ERROR"

function ServerBase:ctor(name, protocol)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.PROTOCOL = protocol
    
    self.socket_ = bm.SocketService.new(name, protocol)
    self.socket_:addEventListener(bm.SocketService.EVT_PACKET_RECEIVED, handler(self, self.onPacketReceived))
    self.socket_:addEventListener(bm.SocketService.EVT_CONN_SUCCESS, handler(self, self.onConnected))
    self.socket_:addEventListener(bm.SocketService.EVT_CONN_FAIL, handler(self, self.onConnectFailure))
    self.socket_:addEventListener(bm.SocketService.EVT_ERROR, handler(self, self.onError))
    self.socket_:addEventListener(bm.SocketService.EVT_CLOSED, handler(self, self.onClosed))
    self.socket_:addEventListener(bm.SocketService.EVT_CLOSE, handler(self, self.onClose))
    self.name_ = name
    self.shouldConnect_ = false
    self.isConnected_ = false
    self.isConnecting_ = false
    self.isProxy_ = false
    self.isPaused_ = false
    self.delayPackCache_ = nil
    self.retryLimit_ = 3
    self.heartBeatSchedulerPool_ = bm.SchedulerPool.new()

    self.logger_ = bm.Logger.new(self.name_)
end

function ServerBase:setOption(opt,value)
    if self.socket_ then
        self.socket_:setOption(opt,value)
    end
end


function ServerBase:isConnected()
    return self.isConnected_
end

function ServerBase:isConnecting()
    return self.isConnecting_
end

function ServerBase:connect(ip, port, retryConnectWhenFailure,ipv6)
    self.shouldConnect_ = true
    self.ip_ = ip
    self.port_ = port
    self.ipv6_ = ipv6
    if self:isConnected() then
        self.logger_:debug("isConnected true")
    elseif self.isConnecting_ then
        self.logger_:debug("isConnecting true")
    else
        self.isConnecting_ = true       
        self.logger_:debugf("direct connect to %s:%s", self.ip_, self.port_)
        self.socket_:connect(self.ip_, self.port_, retryConnectWhenFailure,self.ipv6_)
        
    end
end

function ServerBase:disconnect(noEvent)
    self.shouldConnect_ = false
    self.isConnecting_ = false
    self.isConnected_ = false
    self.ip_ = nil
    self.port_ = nil
    self:unscheduleHeartBeat()
    self.socket_:disconnect(noEvent)
    -- if noEvent then
    --     self.logger_:error("noEvent true")
    -- end
end

function ServerBase:pause()
    self.isPaused_ = true
    self.logger_:debug("paused event dispatching")
end

function ServerBase:resume()
    self.isPaused_ = false
    self.logger_:debug("resume event dispatching")
    if self.delayPackCache_ and #self.delayPackCache_ > 0 then
        for i, v in ipairs(self.delayPackCache_) do
            self:dispatchEvent({name=ServerBase.EVT_PACKET_RECEIVED, packet=v})
        end
        self.delayPackCache_ = nil
    end
end

function ServerBase:createPacketBuilder(cmd)
    return self.socket_:createPacketBuilder(cmd)
end

function ServerBase:send(pack)
    if self:isConnected() then
        self.socket_:send(pack)
    else
        self.logger_:error("sending packet when socket is not connected")

        
        if self.ip_ and self.port_ then
            if (not self:isConnected()) and (not self:isConnecting()) then
                
                if not self:reconnect_() then        
                    self:onAfterConnectFailure()
                    self:dispatchEvent({name=ServerBase.EVT_CONNECT_FAIL})
                end
            end
        end
        
    end
end

function ServerBase:onConnected(evt)
    --print("ServerBase connected")
    self.isConnected_ = true
    self.isConnecting_ = false
    self.heartBeatTimeoutCount_ = 0
    if self.isProxy_ then
        -- local buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_BIG)
        -- buf:writeStringBytes("ES")
        -- buf:writeUShort(0x6001)
        -- buf:writeUShort(1)
        -- buf:writeUShort(0)
        -- local ip = tostring(self.ip_) or ""
        -- buf:writeUInt(#ip + 1)
        -- buf:writeStringBytes(ip)
        -- buf:writeByte(0)
        -- buf:writeUInt(self.port_ or 0)
        -- buf:setPos(7)
        -- buf:writeUShort(buf:getLen() - 8)
        -- self.logger_:debugf("BUILD PACKET ==> %x(%s) [%s]", 0x6001, buf:getLen(), cc.utils.ByteArray.toString(buf, 16))
        -- self:send(buf)
    end
    self.retryLimit_ = 3
    self:onAfterConnected()
    self:dispatchEvent({name=ServerBase.EVT_CONNECTED})
end

function ServerBase:scheduleHeartBeat(command, interval, timeout)
    self.heartBeatCommand_ = command
    self.heartBeatTimeout_ = timeout
    self.heartBeatTimeoutCount_ = 0
    self.heartBeatSchedulerPool_:clearAll()
    self.heartBeatSchedulerPool_:loopCall(handler(self, self.onHeartBeat_), interval)
end

function ServerBase:unscheduleHeartBeat()
    self.heartBeatTimeoutCount_ = 0
    self.heartBeatSchedulerPool_:clearAll()
end

function ServerBase:buildHeartBeatPack()
    self.logger_:debug("not implemented method buildHeartBeatPack")
    return nil
end

function ServerBase:onHeartBeatTimeout(timeoutCount)
    self.logger_:debug("not implemented method onHeartBeatTimeout")
end

function ServerBase:onHeartBeatReceived(delaySeconds)
    self.logger_:debug("not implemented method onHeartBeatReceived")
end

function ServerBase:onHeartBeat_()
    local heartBeatPack = self:buildHeartBeatPack()
    if heartBeatPack then
        self.heartBeatPackSendTime_ = bm.getTime()
        self:send(heartBeatPack)
        self.heartBeatTimeoutId_ = self.heartBeatSchedulerPool_:delayCall(handler(self, self.onHeartBeatTimeout_), self.heartBeatTimeout_)
        self.logger_:debug("send heart beat packet")
    end
    return true
end

function ServerBase:onHeartBeatTimeout_()
    self.heartBeatTimeoutId_ = nil
    self.heartBeatTimeoutCount_ = (self.heartBeatTimeoutCount_ or 0) + 1
    self:onHeartBeatTimeout(self.heartBeatTimeoutCount_)
    self.logger_:debug("heart beat timeout", self.heartBeatTimeoutCount_)
end

function ServerBase:onHeartBeatReceived_()
    local delaySeconds = bm.getTime() - self.heartBeatPackSendTime_
    if self.heartBeatTimeoutId_ then
        self.heartBeatSchedulerPool_:clear(self.heartBeatTimeoutId_)
        self.heartBeatTimeoutId_ = nil
        self.heartBeatTimeoutCount_ = 0
        self:onHeartBeatReceived(delaySeconds)
        self.logger_:debug("heart beat received", delaySeconds)
    else
        self.logger_:debug("timeout heart beat received", delaySeconds)
    end
end

function ServerBase:onConnectFailure(evt)
    self.isConnected_ = false
    self.logger_:debug("connect failure ...")    
    if not self:reconnect_() then        
        self:onAfterConnectFailure()
        self:dispatchEvent({name=ServerBase.EVT_CONNECT_FAIL})
    end
end

function ServerBase:onError(evt)
    self.isConnected_ = false
    self.socket_:disconnect(true)
    self.logger_:debug("data error ...")    
    if not self:reconnect_() then       
        self:onAfterDataError()
        self:dispatchEvent({name=ServerBase.EVT_ERROR})
    end
end

function ServerBase:onClosed(evt)
    self.isConnected_ = false
    self:unscheduleHeartBeat()
    if self.shouldConnect_ then
        if not self:reconnect_() then
            self:onAfterConnectFailure()
            self:dispatchEvent({name=ServerBase.EVT_CONNECT_FAIL})
            self.logger_:debug("closed and reconnect fail")
        else
            self.logger_:debug("closed and reconnecting")
        end
    else
        self.logger_:debug("closed and do not reconnect")
        self:dispatchEvent({name=ServerBase.EVT_CLOSED})
    end
end

function ServerBase:onClose(evt)
    self:unscheduleHeartBeat()
end

function ServerBase:reconnect_()
    self.socket_:disconnect(true)
    self.retryLimit_ = self.retryLimit_ - 1
    local isRetrying = true    
    if self.retryLimit_ > 0 or self.retryConnectWhenFailure_ then
        self.onReconnnecting()
        self.socket_:connect(self.ip_, self.port_, self.retryConnectWhenFailure_,self.ipv6_)
    else
        isRetrying = false
        self.isConnecting_ = false
    end    
    return isRetrying
end


function ServerBase:onReconnnecting()
    -- body
end

function ServerBase:onPacketReceived(evt)
    local pack = evt.data
    if pack.cmd == self.heartBeatCommand_ then
        if self.heartBeatTimeoutId_ then
            self:onHeartBeatReceived_()
        end
    else
        self:onProcessPacket(pack)
        if self.isPaused_ then
            if not self.delayPackCache_ then
                self.delayPackCache_ = {}
            end
            self.delayPackCache_[#self.delayPackCache_ + 1] = pack
            self.logger_:debugf("%s paused cmd:%x", self.name_, pack.cmd)
        else
            self.logger_:debugf("%s dispatching cmd:%x", self.name_, pack.cmd)
            local ret, errMsg = pcall(function() self:dispatchEvent({name=ServerBase.EVT_PACKET_RECEIVED, packet=evt.data}) end)
            if errMsg then
                self.logger_:errorf("%s dispatching cmd:%x error %s", self.name_, pack.cmd, errMsg)
            end            
        end
    end
end

function ServerBase:onProcessPacket(pack)
    self.logger_:debug("not implemented method onProcessPacket")
end

function ServerBase:onAfterConnected()
    self.logger_:debug("not implemented method onAfterConnected")
end

function ServerBase:onAfterConnectFailure()
    self.logger_:debug("not implemented method onAfterConnectFailure")
end

function ServerBase:onAfterDataError()
    self:onAfterConnectFailure()
    self.logger_:debug("not implemented method onAfterDataError")
end

return ServerBase