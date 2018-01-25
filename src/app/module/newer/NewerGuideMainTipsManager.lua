--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-08-31 15:06:09
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: NewerGuideMainTipsManager.lua [管理新手指引主要tips动画部分类] By TsingZhang.
--
local NewerGuideMainTipsManager = class("NewerGuideMainTipsManager")

NewerGuideMainTipsManager.ANIM_TAG_INVITE = 1
NewerGuideMainTipsManager.ANIM_TAG_FREECHIP = 2
NewerGuideMainTipsManager.ANIM_TAG_NORMALROOM = 3
NewerGuideMainTipsManager.ANIM_TAG_STORE = 4

function NewerGuideMainTipsManager:ctor(paopTips)
	-- body
	self.paopTipsData_ = paopTips or {}
	-- self.paopTipsData_ = {}

	-- if paopTips then
	-- 	--todo
	-- 	for i = 1, #paopTips do
	-- 		self.paopTipsData_[i] = {}
	-- 		self.paopTipsData_[i].paopTip = paopTips[i]
	-- 		self.paopTipsData_[i].tag = i
	-- 	end
	-- end

	self.paopTipPosSrc_ = {}
	self.paopTipPosDes_ = {}

	self.paopTipParentTargets_ = {}

	self.schedulerPool_ = bm.SchedulerPool.new()
	-- self:addDataObservers()
end

-- 设置paop提醒的初始位置和父节点
function NewerGuideMainTipsManager:setPaopTipOrgPosAndParent(tipsId, pos, target)
	-- body
	if tipsId and self.paopTipsData_[tipsId] then
		--todo
		self.paopTipParentTargets_[tipsId] = target

		local rect = target:convertToWorldSpace(cc.p(pos.x, pos.y))
		-- local paoPoint = nk.runningScene:convertToNodeSpace(rect)

		self.paopTipPosSrc_[tipsId] = rect
		-- dump(self.paopTipPosSrc_[tipsId], "self.paopTipPosSrc_[" .. tipsId .. "] :===================")

		self.paopTipsData_[tipsId].paopTip:pos(rect.x or 0, rect.y or 0)
			:addTo(nk.runningScene, 99)
			
		self.paopTipsData_[tipsId].paopTip:setPaopTipOpacity(0)
	else
		dump("Wrong Index In Array PaopTip!")
	end
end

-- 设置paop提醒的目的坐标
function NewerGuideMainTipsManager:setPaopTipDistPos(tipsId, pos)
	-- body
	if tipsId and self.paopTipsData_[tipsId] then
		--todo
		local rect = self.paopTipParentTargets_[tipsId]:convertToWorldSpace(cc.p(pos.x, pos.y))
		-- local paoPoint = nk.runningScene:convertToNodeSpace(rect)

		self.paopTipPosDes_[tipsId] = rect
	else
		dump("Wrong Index In Array PaopTip!")
	end

end

function NewerGuideMainTipsManager:buildAnims()
	-- body
	if self.paopTipAnimFunc then
		--todo
		self.paopTipAnimFunc = nil
	end

	self.paopTipAnimFunc = {}
	for i = 1, #self.paopTipsData_ do
		self.paopTipAnimFunc[i] = function()
			-- body
			self.paopTipsData_[i].paopTip:pos(self.paopTipPosSrc_[i].x, self.paopTipPosSrc_[i].y)

			self.paopTipsData_[i].paopTip:playFadeInAnim(1.0, 0, 255)

			transition.moveTo(self.paopTipsData_[i].paopTip, {time = 1.0, x = self.paopTipPosDes_[i].x, y = self.paopTipPosDes_[i].y,
	            onComplete = handler(self.paopTipsData_[i].paopTip, function(obj)
	            	-- body
	            	obj:performWithDelay(function()
	            		-- body
	            		-- obj:hide()
	            		obj:setPaopTipOpacity(0)
	            	end, 1.5)
	            end)})
		end
	end
end

function NewerGuideMainTipsManager:playNewerGuideAnim()
	-- body
	self:buildAnims()

	-- for i = 1, #self.paopTipAnimFunc do
	-- 	self.paopTipAnimFunc[i]()
	-- end
	self:playAnimOntology()
end

function NewerGuideMainTipsManager:playAnimOntology()
	-- body
	if #self.paopTipAnimFunc > 0 then
		--todo
		self:playOneRound()

		self.animLoopCallHandler_ = self.schedulerPool_:loopCall(function()
			-- body
			self:playOneRound()
			return true
			
		end, #self.paopTipAnimFunc * 3.5)
	end
end

function NewerGuideMainTipsManager:playNext_()
	-- body
end

function NewerGuideMainTipsManager:playOneRound()
	-- body
	for i = 1, #self.paopTipAnimFunc do
		self.schedulerPool_:delayCall(function()
			-- body
			self.paopTipAnimFunc[i]()
		end, (i - 1) * 3.5)
	end
end

-- @param id: 指定动画Id
function NewerGuideMainTipsManager:onGuideTipsStateChanged(id)
	-- body
	-- id == 0,特殊情况(退出游戏，或者重置key :nk.dataKeys.NEWER_GUIDE_TIP_TAG.GUIDE_TIPSTATE_CHANGE 值的标志),不处理.
	if id == 0 then
		--todo
		return
	end

	if id and nk.dataKeys.NEWER_GUIDE_TIP_TAG[id] then
		--todo
		bm.DataProxy:setData(nk.dataKeys.NEWER_GUIDE_TIP_TAG[id], false)
		nk.userDefault:setBoolForKey(nk.cookieKeys.NEWER_GUIDE_TIP_TAG[id] .. nk.userData["aUser.mid"], false)

		nk.userDefault:flush()
	end

	if self and self.schedulerPool_ then
		--todo
		self.schedulerPool_:clearAll()
		self.schedulerPool_ = nil

		self.schedulerPool_ = bm.SchedulerPool.new()
		-- dump(self.paopTipsData_, "self.paopTipsData_src :=====================")
		self:buildAnims()  -- reBuildAnims Needed! --

		for i = #self.paopTipsData_, 1, - 1 do

			if self.paopTipsData_[i].tag == id then
				--todo
				local paopTipData = table.remove(self.paopTipsData_, i)
				table.remove(self.paopTipPosSrc_, i)
				table.remove(self.paopTipPosDes_, i)
				-- table.remove(self.paopTipParentTargets_, i)
				table.remove(self.paopTipAnimFunc, i)

				paopTipData.paopTip:removeFromParent()
				paopTipData = nil

				self:playNewerGuideAnim()
			end
		end

		
		-- dump(self.paopTipsData_, "self.paopTipsData_des :=====================")
	end
end

function NewerGuideMainTipsManager:addDataObservers()
	-- body
    self.onGuideTipsChangeObserver = bm.DataProxy:addDataObserver(nk.dataKeys.NEWER_GUIDE_TIP_TAG.GUIDE_TIPSTATE_CHANGE, handler(self, self.onGuideTipsStateChanged))
end

function NewerGuideMainTipsManager:dispose()
	-- body
	bm.DataProxy:removeDataObserver(nk.dataKeys.NEWER_GUIDE_TIP_TAG.GUIDE_TIPSTATE_CHANGE, self.onGuideTipsChangeObserver)
    self.schedulerPool_:clearAll()
    self.schedulerPool_ = nil

    for i = 1, #self.paopTipsData_ do
    	self.paopTipsData_[i].paopTip:removeFromParent()
    	self.paopTipsData_[i].paopTip = nil
    end
end

return NewerGuideMainTipsManager