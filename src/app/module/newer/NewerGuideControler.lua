
local NewerPlayPopup = import("app.module.newer.NewerPlayPopup")
local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")

local NewerGuideControler = class("NewerGuideControler")


local instance

function NewerGuideControler:getInstance()
    instance = instance or NewerGuideControler.new()
    return instance
end

function NewerGuideControler:ctor()
	self.schedulerPool_ = bm.SchedulerPool.new()

	-- dump(self.schedulerPool_,"NewerGuideControler:ctor")
	self:addEvents()
	self:bindDataObserver()

end


function NewerGuideControler:init(newerDay)

	self.newerDay_ = newerDay
	self:requestInit()
end


function NewerGuideControler:setFirstRewardFlag(firstRewardFlag)
	self.firstRewardFlag_ = firstRewardFlag
end

function NewerGuideControler:getFirstRewardFlag(firstRewardFlag)
	return self.firstRewardFlag
end


function NewerGuideControler:isRunning()
	return (checkint(self.newerDay_) > 0)
end


function NewerGuideControler:getNewerDay()
	return (checkint(self.newerDay_))
end


function NewerGuideControler:isNextRewardDone()
	return self.isNextRewardDone_
end

function NewerGuideControler:requestInit()
	if self.isInit_ then
		return 
	end

	local retryLimit = 6
    local initFunc
    initFunc = function()
    		if self.initRequestId_ then
    			-- return
    			nk.http.cancel(self.initRequestId_)
    			self.initRequestId_ = nil
    		end
            self.initRequestId_ = nk.http.newerInit(function(data)
                self.initRequestId_ = nil
                self.isInit_ = true

				dump(data,"newerInit====")
				self.remainTime_ = data.diifToNext
				self.isNextRewardDone_ = (1 == data.isNextDayTaskDone) and true or false
				if not data.diifToNext or data.diifToNext >= 999 then
					self.isPlayTaskFinish_ = true
				end


				bm.DataProxy:setData(nk.dataKeys.NEWER_GUIDE_DAY,self.newerDay_)
				
            end,function(errData)
                self.initRequestId_ = nil
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
                        initFunc()
                    end, 2)
                else
                   
                end

            end)
    end

    initFunc()

end


 function NewerGuideControler:bindDataObserver()
 	if not self.onDataObserver_ then
 		self.onDataObserver_ = bm.DataProxy:addDataObserver(nk.dataKeys.SIT_OR_STAND, handler(self, self.sitStatusFunc))
 	end
    
end
 
function NewerGuideControler:unbindDataObserver()
	if self.onDataObserver_ then
		bm.DataProxy:removeDataObserver(nk.dataKeys.SIT_OR_STAND, self.onDataObserver_)
		self.onDataObserver_ = nil
	end
    
end

function NewerGuideControler:sitStatusFunc(sitData)

	if 1 ~= self:getNewerDay() then
		return
	end

	--牌局任务已经全部完成
	if self.isPlayTaskFinish_ then
		return
	end 

	--比赛场忽略玩牌计数
	if "MatchRoomScene" == nk.runningScene.name or "RoomScene" == nk.runningScene.name then
		return
	end

	-- dump(sitData,"sitStatusFunc")
	if not sitData then 
		return
	end
	local isSit = sitData.inSeat
    if isSit then
        self:sitDownFunc(sitData) 
    else 
        self:standUpFunc(sitData)
    end
end


function NewerGuideControler:sitDownFunc(sitData)
	-- local isSit = sitData.inSeat
	-- local seatId = sitData.seatId
	-- local ctx = sitData.ctx

	if self:checkShowNewerTaskFinishIcon() then
		self:showNewerTaskFinishIcon(sitData)
	end
end

function NewerGuideControler:standUpFunc(sitData)
	local isSit = sitData.inSeat
	local seatId = sitData.seatId
	local ctx = sitData.ctx

	self:hideNewerTaskFinishIcon()
end




function NewerGuideControler:addEvents()
	if not self.gameOverHandler_ then
		self.gameOverHandler_ = bm.EventCenter:addEventListener(nk.DailyTasksEventHandler.REPORT_GAME_OVER, handler(self, self.onReportGameOver_))
	end
	
end

function NewerGuideControler:removeEvents()
	if self.gameOverHandler_ then
		bm.EventCenter:removeEventListener(self.gameOverHandler_)
		self.gameOverHandler_ = nil
	end
	
end


function NewerGuideControler:onReportGameOver_(evt)
	if "MatchRoomScene" == nk.runningScene.name then
		return
	end

	local data = evt.data
	dump(data,"NewerGuideControler:onReportGameOver_")

	if 1 ~= self:getNewerDay() then
		return
	end

	--牌局任务已经全部完成
	if self.isPlayTaskFinish_ then
		return
	end

	---[[
	self.remainTime_ = self.remainTime_ - 1


	-- if self.remainTime_ <= 0 then
		if self:checkShowNewerTaskFinishIcon() then
			
			self:showNewerTaskFinishIcon(data)
		end
	-- end


	--]]

	-- local desNum = self.needTb_[(self.rtime_ + 1)] or 0
	-- if desNum > 0 then
	-- 	--还有未完成的玩牌任务

	-- 	self.curNum_ = self.curNum_ + 1

	-- 	if self.curNum_ >= desNum then
			--请求HTTP领奖
			-- self.playRequestId_ = nk.http.newerPlay(function(data)
			-- 	self.playRequestId_  = nil


			-- 	self.realNum_ = data.realNum
			-- 	self.markNum_ = data.markNum
			-- 	self.curNum_ = self.realNum_ - self.markNum_
				
			-- 	self.rtime_ = data.rtime


			-- end,function(errData)
			-- 	self.playRequestId_ = nil
			-- end)

		-- 	if self:checkShowNewerTaskFinishIcon() then
		-- 		self:showNewerTaskFinishIcon()
		-- 	end
		-- end
	-- end

end

function NewerGuideControler:dispose(clean)
	if self.schedulerPool_ then
		self.schedulerPool_:clearAll()
	end
	
	if self.initRequestId_ then
		nk.http.cancel(self.initRequestId_)
		self.initRequestId_ = nil
	end

	if self.playRequestId_ then
		nk.http.cancel(self.playRequestId_)
		self.playRequestId_ = nil
	end


	self:hideNewerTaskFinishIcon()

	self.isInit_ = nil
	self.newerDay_ = 0
	self.isPlayTaskFinish_ = nil
	self.isNextRewardDone_ = nil
	self.firstRewardFlag_ = nil
	self.remainTime_ = 999

	bm.DataProxy:setData(nk.dataKeys.NEWER_GUIDE_DAY,0)



	self:destoryAnim()


	if clean then
		self:removeEvents()
		self:unbindDataObserver()
	end


end


function NewerGuideControler:destoryAnim()
 		if self.animNode_ then
 			self.animNode_:removeFromParent()
 			self.animNode_ = nil
 		end
end


--判断是否显示任务完成图标
function NewerGuideControler:checkShowNewerTaskFinishIcon()
	if not self.isPlayTaskFinish_ and (self.remainTime_ and self.remainTime_ <= 0) then
			return true
	end

	return false
end

--显示新手玩牌任务完成图标
function NewerGuideControler:showNewerTaskFinishIcon(sitData)
	if self.taskBtnNode_ then
		-- self.taskBtnNode_:removeFromParent()
		-- self.taskBtnNode_ = nil
		return
	end

	if not sitData then
		self:hideNewerTaskFinishIcon()
		return
	end

	local isSit = sitData.inSeat
	local seatId = sitData.seatId
	local ctx = sitData.ctx

	local seatView = ctx.seatManager:getSelfSeatView() 
	local seatViewSize = seatView:getContentSize()

	
	-- local tempX,tempY = seatView:getPosition()
	-- local parent = ctx.scene.nodes.seatNode

	local tempX,tempY = -100, 55
	local parent = seatView

	self.taskBtnNode_ = display.newNode()
	:pos(tempX, tempY)
	:addTo(parent,100)

	display.newSprite("newerguide/newer_play_light.png")
	:addTo(self.taskBtnNode_)

	display.newSprite("newerguide/newer_play_start.png")
	:addTo(self.taskBtnNode_)

	 cc.ui.UIPushButton.new({normal = "newerguide/newer_play_up.png", pressed = "newerguide/newer_play_down.png"})
        
        :addTo(self.taskBtnNode_)
        :onButtonClicked(buttontHandler(self, self.onNewerTaskIconClick))

    self.taskBtnNode_:setNodeEventEnabled(true)
    self.taskBtnNode_.onCleanup = function()
    	--按钮被销毁时候调用
    	self.taskBtnNode_ = nil
    end
end


function NewerGuideControler:hideNewerTaskFinishIcon()
	if self.taskBtnNode_ then
		self.taskBtnNode_:removeFromParent()
		self.taskBtnNode_ = nil
	end
end


function NewerGuideControler:requestPlayReward()
	local retryLimit = 6
    local playRewardFunc
    playRewardFunc = function()
    		if self.playRequestId_ then
    			-- return
    			nk.http.cancel(self.playRequestId_)
    			self.playRequestId_ = nil
    		end

            self.playRequestId_ = nk.http.newerPlay(function(data)
                self.playRequestId_ = nil
             	local addMoney = checkint(data.addMoney)
             	local money = checkint(data.money)

				self.remainTime_ = data.diifToNext
				if not data.diifToNext or data.diifToNext >= 999 then
					self.isPlayTaskFinish_ = true
				end

				--显示奖励弹框，并隐藏完成按钮--
				self:hideNewerTaskFinishIcon()

				local pdata = {}
				pdata.addMoney = addMoney
				pdata.isAnim = true
				if self.isPlayTaskFinish_ then
					pdata.contentFlag = 2
					pdata.nextAddMoney = 200000
				else
					pdata.contentFlag = 1
				end
				NewerPlayPopup.new():show(pdata)


            end,function(errData)
                self.playRequestId_ = nil
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
                        playRewardFunc()
                    end, 1)
                else
                   --多次请求无果，移除完成按钮
                   self:hideNewerTaskFinishIcon()
                end

            end)
    end

    playRewardFunc()

end



function NewerGuideControler:onNewerTaskIconClick()
	--请求HTTP领奖
	if 1 ~= self:getNewerDay() then
		return
	end

	if self.isPlayTaskFinish_ then
		return
	end

	self:requestPlayReward()
end



function NewerGuideControler:requestNextDayReward()
	local retryLimit = 6
    local nextDayFunc
    nextDayFunc = function()
    		if self.nextDayRequestId_ then
    			-- return
    			nk.http.cancel(self.nextDayRequestId_)
    			self.nextDayRequestId_ = nil
    		end

            self.nextDayRequestId_ = nk.http.newerNextDayReward(function(data)
                self.nextDayRequestId_ = nil
    --           
    		local addMoney = checkint(data.addMoney)
    		local money = checkint(data.money)
    		-- local props = 
    		self.isNextRewardDone_ = true

    		bm.DataProxy:setData(nk.dataKeys.NEWER_GUIDE_DAY,self.newerDay_)

    		if addMoney > 0 then

    			local runningScene = nk.runningScene
		        self.animNode_ = display.newNode():
		        addTo(runningScene,100)
		        :pos(display.cx,display.cy)
                local animation = CommonRewardChipAnimation.new()
                    :addTo(self.animNode_)
                local changeChipAnim = nk.ui.ChangeChipAnim.new(checkint(addMoney))
                    :addTo(self.animNode_)  
                    
                self.schedulerPool_:delayCall(function ()
                nk.userData["aUser.money"] = nk.userData["aUser.money"] + addMoney
                -- nk.userData["aUser.money"] = money

                self:destoryAnim()
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("NEWER", "GET_REWARD_SUCC"))
                end, 1.5)    
    			
    		end

            end,function(errData)
                self.nextDayRequestId_ = nil
                retryLimit = retryLimit - 1
                if retryLimit > 0 then
                    self.schedulerPool_:delayCall(function()
                        nextDayFunc()
                    end, 1)
                else
                   --多次请求无果
                   --
                end

            end)
    end

    nextDayFunc()
end


return NewerGuideControler