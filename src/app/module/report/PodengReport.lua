--
-- Author: ThinkerWang
-- Date: 2015-08-27 21:14:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- game report for D servicer

local PodengReport = class("PodengReport")

PodengReport.eventTable = import(".PodengReportConfig")

function PodengReport:ctor()
	self.sendData = {}
	self.schedulerPool = bm.SchedulerPool.new()
	self:startTimer_()
end
function PodengReport:startTimer_()
	self.schedulerPool:delayCall(function()
     	
     	if self.sendData and #self.sendData > 0 then
     		if nk and nk.http then
     			nk.http.Dreport(self.sendData, 
     				function(data) 
     					self.sendData = {}
     				end, 
     				function(data)
     					self.sendData = {}
     				 end);
     		end
     	end
		self.schedulerPool:clearAll()
	    self:startTimer_()
     end, 60)
end


function PodengReport:report(eventObj)
	table.insert(self.sendData,eventObj)
end

function PodengReport:stopTimer_()
	self.schedulerPool:clearAll()
end

return PodengReport