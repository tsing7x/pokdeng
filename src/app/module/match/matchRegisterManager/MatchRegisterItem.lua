-- Author: ThinkerWang
-- Date: 2016-05-24 21:14:50
-- Copyright: Copyright (c) 2016, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 单个比赛

local MatchRegisterItem = class("MatchRegisterItem")

function MatchRegisterItem:ctor(matchData,parent)
	self.isStart_ = true
	self.matchData_ = matchData
	self.matchId_ = matchData.matchid;
	self.leftTime_ = checkint(matchData.matchTime)
	self.parent_ = parent
	self.schedulerPool = bm.SchedulerPool.new()
	self:checkLeftTime()
end
function MatchRegisterItem:checkLeftTime()
	if self.leftTime_ > 0 then
		self.schedulerPool:delayCall(function()
     	self.leftTime_ = self.leftTime_-1
     	if self.leftTime_==120 then
     		self.parent_:showMatchTip({leftTime = self.leftTime_,matchid = self.matchId_})
     	elseif self.leftTime_==60 then
     		self.parent_:showMatchTip({leftTime = self.leftTime_,matchid = self.matchId_})
     	elseif self.leftTime_ == 30 then
     		self.parent_:showMatchTip({leftTime = self.leftTime_,matchid = self.matchId_})
     	elseif self.leftTime_ == 10 then
     		self.parent_:showMatchTip({leftTime = self.leftTime_,matchid = self.matchId_})
     	elseif self.leftTime_ == 0 then
			self.schedulerPool:clearAll()
			self.isStart_ = false
		end
	    
	    self:checkLeftTime()
     end, 1)
	end
end
function MatchRegisterItem:getMatchState()
	return self.isStart_
end

return MatchRegisterItem