local ScoreMarketControl = class("ScoreMarketControl")

function ScoreMarketControl:ctor(view)
    self.view_ = view
end

function ScoreMarketControl:saveUserAddress(info)
	self.view_:setLoading(true)
	nk.http.saveUserAddress(info,
		function(data)
			self.view_:setLoading(false)
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "SAVEADDRESS_SUCCESS"))
		end,

		function(error)
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "SAVEADDRESS_FAIL"))
			self.view_:setLoading(false)
		end
	)

end

function ScoreMarketControl:getUserAddress(callback)
	nk.http.getUserAddress(function(data)
		callback(data)

	end, function(error)

	end)

end

--初始化
function ScoreMarketControl:getShopInitInfo(callback)
	self.initRequestId_ = nk.http.getShopInitInfo(function(data)
		dump(data, "nk.http.getShopInitInfo.retData :======================")
		if callback then
			callback(true,data)
		end
	end,function(errData)
		dump(errData, "nk.http.getShopInitInfo.errData :======================")
		if callback then
			callback(false,errData)
		end
		
	end)
end

function ScoreMarketControl:getMyRecord(leftType,callback)
	self.view_:setLoading(true)
	nk.http.getMyExchangeRecord(leftType,
		function(data)
			self.view_:setLoading(false)
			callback(data)
		end,

		function(error)
			self.view_:setLoading(false)
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
		end
	)

end

function ScoreMarketControl:getGoods(leftType,callback)
	 self.view_:setLoading(true)
	 self.getShopGoodsReqId_ = nk.http.getShopGoods(leftType,
        function(data)
           dump(data,"goods_match")
           self.view_:setLoading(false)
           self.getShopGoodsReqId_ = nil
            local groupData = {}
			local temp = {}
			for i=1,#data,3 do
				temp = {}
				temp[1] = data[i]
				temp[2] = data[i+1]
				temp[3] = data[i+2]
				table.insert(groupData,temp)
			end
           callback(groupData)
        end,
        function(errordata)
        	self.getShopGoodsReqId_ = nil
        	self.view_:setLoading(false)
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
        end
        )
end


function ScoreMarketControl:dispose()
	if self.exchangeGoodByIdReqId_ then
		nk.http.cancel(self.exchangeGoodByIdReqId_)
		self.exchangeGoodByIdReqId_ = nil
	end

	if self.getShopGoodsReqId_ then
		nk.http.cancel(self.getShopGoodsReqId_)
		self.getShopGoodsReqId_ = nil
	end
end

function ScoreMarketControl:buyGood(itemData,callback)
	
	if self.exchangeGoodByIdReqId_ then
		return
	end
	self.view_:setLoading(true)
	self.exchangeGoodByIdReqId_ = nk.http.exchangeGoodById(itemData.gid,itemData.category,
		function(data)
			self.exchangeGoodByIdReqId_ = nil
			self.view_:setLoading(false)
			nk.userData["match.point"] = tonumber(data.point)
			nk.userData["aUser.money"] = tonumber(data.money)
			nk.userData["match.ticket"] = tonumber(data.ticket)
			self.view_:refreshView()
			if callback then
				callback(data)
			end
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "EXCHANGE_SUCCESS_TIP"))
		end,

		function(errordata)
			self.view_:setLoading(false)
			self.exchangeGoodByIdReqId_ = nil
			local retData = errordata.retData
			
			local checkDiffData = function(cdata)
				local cashStr
				local ticketStr
				local otherTicketStr
				local chipStr
				local diffStrTb = {}

				if checkint(cdata.diffMoney) > 0 then
					chipStr = bm.LangUtil.getText("SCOREMARKET", "CHIP_NUM",checkint(cdata.diffMoney))
					table.insert(diffStrTb,chipStr)
				end

				if checkint(cdata.diffPoint) > 0 then
					cashStr = bm.LangUtil.getText("SCOREMARKET", "CASH_NUM",checkint(cdata.diffPoint))
					table.insert(diffStrTb,cashStr)
				end

				if checkint(cdata.diffOtherTicket) > 0 then
					otherTicketStr = bm.LangUtil.getText("SCOREMARKET", "OTHER_TICKET_NUM",checkint(cdata.diffOtherTicket))
					table.insert(diffStrTb,otherTicketStr)
				end

				if checkint(cdata.diffTicket) > 0 then
					ticketStr = bm.LangUtil.getText("SCOREMARKET", "TICKET_NUM",checkint(cdata.diffTicket))
					table.insert(diffStrTb,ticketStr)
				end

				return diffStrTb,cdata
			end

			local diffStr
			local diffData
			if retData and retData.data then
				local data = retData.data
				local stb,dffData = checkDiffData(data)
				if stb and #stb > 0 then
					diffStr = table.concat(stb,",")
				end
				diffData = dffData
			end


			if errordata.errorCode == -3 then -- 物品库存不足
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "NOTENOUGH_LEFT_CNT"))
			elseif errordata.errorCode == -7 then --现金币数量不足，无法兑换
				-- nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "NOTENOUGH_SCORE"))

				if diffStr and diffData then
					 nk.ui.Dialog.new({
				        messageText = bm.LangUtil.getText("SCOREMARKET", "NEED_TIP",diffStr), 
				        secondBtnText = bm.LangUtil.getText("SCOREMARKET", "TO_PLAY"), 
				        closeWhenTouchModel = true,
				        callback = function (type)
				            if type == nk.ui.Dialog.SECOND_BTN_CLICK then

				            	if self and self.doJump then
				            		--todo
				            		if nk.userData["match.point"] < 10 then
					                	--现金币小于10个，跳转到定时赛界面
					                	-- dump("code:" .. errordata.errorCode,"a jump...")
				                		local timMatchTag = "timMatch"
					                	self:doJump(timMatchTag)
					                	-- self.view_:onClose()
					                	nk.PopupManager:removeAllPopup()
					                else
					                	--现金币大于等于10个
					                	--a:现金币不足，跳转到现金币场界面
					                	-- dump("code:" .. errordata.errorCode,"b jump...")
				                		local ChooseCashRoomTag = "cashRoomChoose"
										self:doJump(ChooseCashRoomTag)
										nk.PopupManager:removeAllPopup()
										-- self.view_:onClose()
					                end
				            	end
				            end
				        end,
				    }):show()

				end

			elseif errordata.errorCode == -8 then --券数量不足
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "NOTENOUGH_SCORE_2"))
			elseif errordata.errorCode == -11 then --兑换超过限制
				if errordata.retData and errordata.retData["data"] then
					local edata = errordata.retData["data"]
					local limit = edata["limit"] or 1
					local allLimit = edata["allLimit"] or 1
					-- nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "TIME_LIMIT",limit,allLimit))

					 nk.ui.Dialog.new({
				        messageText = bm.LangUtil.getText("SCOREMARKET", "NUM_LIMIT_TIP"), 
				        secondBtnText = bm.LangUtil.getText("SCOREMARKET", "TO_PLAY"),  
				        closeWhenTouchModel = true,
				        callback = function (type)
				            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
				                --[[
				                	--a,现金币小于10个，点击继续玩牌跳转到定时赛界面
									--b,现金币大于10个，点击继续玩牌跳转到现金币场页面
				                --]]
				                if self and self.doJump then
				                	--todo
				                	if nk.userData["match.point"] < 10 then
					                	-- a 跳转
					                	-- dump("code:" .. errordata.errorCode,"a jump...")
					                	local timMatchTag = "timMatch"
					                	self:doJump(timMatchTag)
					                	-- self.view_:onClose()
					                	nk.PopupManager:removeAllPopup()
					                else
					                	-- a 跳转
					                	-- dump("code:" .. errordata.errorCode,"b jump...")
					                	local ChooseCashRoomTag = "cashRoomChoose"
										self:doJump(ChooseCashRoomTag)
										-- self.view_:onClose()
										nk.PopupManager:removeAllPopup()
					                end
				                end
				            end
				        end,
				    }):show()
				end

			elseif errordata.errorCode == - 12 then --筹码不足，无法兑换
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("SCOREMARKET", "NOTENOUGH_SCORE_3"))
			elseif errordata.errorCode == - 13 then
				-- nk.TopTipManager:showTopTip(T("兑换券不足"))
				if diffStr and diffData then
					 nk.ui.Dialog.new({
				        messageText = bm.LangUtil.getText("SCOREMARKET", "NEED_TIP",diffStr), 
				        secondBtnText = bm.LangUtil.getText("SCOREMARKET", "TO_GET"),  
				        closeWhenTouchModel = true,
				        callback = function (type)
				            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
				                --实物券不足，跳转到定时赛场界面
				                -- dump("code:" .. errordata.errorCode,"jump 定时赛场")
				                if self and self.doJump then
				                	--todo
				                	local timMatchTag = "timMatch"
				                	self:doJump(timMatchTag)
				                	-- self.view_:onClose()
				                	nk.PopupManager:removeAllPopup()
				                end
				            end
				        end,
				    }):show()

				end
			elseif errordata.errorCode == - 15 then
				if diffStr and diffData then
					 nk.ui.Dialog.new({
				        messageText = bm.LangUtil.getText("SCOREMARKET", "NEED_TIP",diffStr), 
				        secondBtnText = bm.LangUtil.getText("SCOREMARKET", "TO_GET"),  
				        closeWhenTouchModel = true,
				        callback = function (type)
				            if type == nk.ui.Dialog.SECOND_BTN_CLICK then
				                --[[
				                	a、现金币小于10个，跳转到定时赛页面
									b、现金币不小于10个且现金币不足，不管够不够实物券，跳转到现金币场界面
									c、现金币足够，实物券不足，跳转到定时赛界面
				                --]]

				                if self and self.doJump then
				                	--todo
				                	if nk.userData["match.point"] < 10 then
					                	-- a 跳转
					                	-- dump("code:" .. errordata.errorCode,"a jump...")
					                	local timMatchTag = "timMatch"
					                	self:doJump(timMatchTag)
					                	-- self.view_:onClose()
					                	nk.PopupManager:removeAllPopup()
					                else
					                	if checkint(diffData.diffPoint)>0 then
					                		-- b 跳转
					                		-- dump("code:" .. errordata.errorCode,"b jump...")
					                		local ChooseCashRoomTag = "cashRoomChoose"
											self:doJump(ChooseCashRoomTag)
											-- self.view_:onClose()
											nk.PopupManager:removeAllPopup()
					                	else
					                		-- c 跳转
					                		-- dump("code:" .. errordata.errorCode,"c jump...")
					                		local timMatchTag = "timMatch"
						                	self:doJump(timMatchTag)
						                	-- self.view_:onClose()
						                	nk.PopupManager:removeAllPopup()
					                	end
					                end
				                end
				            end
				        end
				    }):show()

				end
			else
				nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
			end
		end
	)
end



function ScoreMarketControl:doJump(action)
	local HallController = import("app.module.hall.HallController")
	
	local currentViewType = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
    local runningScene = nk.runningScene

    if runningScene.name == "HallScene" then
    	if currentViewType == HallController.MAIN_HALL_VIEW then
    		--todo
    		if action == "cashRoomChoose" then
    			--todo
    			nk.userData.DEFAULT_TAB = 2
                runningScene.controller_.view_:onNorHallClick()
    		elseif action == "timMatch" then
    			--todo
    			runningScene.controller_.view_:onMatchHallClick()
    		end
    	elseif currentViewType == HallController.CHOOSE_NOR_VIEW then
    		--todo
    		if action == "cashRoomChoose" then
    			--todo
    			if nk.userData.DEFAULT_TAB ~= 2 then
    				--todo
    				local cashRoomChooseTabIdx = 2
    				runningScene.controller_.view_.mainTabBar_:gotoTab(cashRoomChooseTabIdx)
    			end
    		elseif action == "timMatch" then
    			--todo
    			runningScene.controller_:showMainHallView()
                runningScene.controller_.view_:onMatchHallClick()
    		end
    	elseif currentViewType == HallController.CHOOSE_MATCH_NOR_VIEW then
    		--todo
    		if action == "cashRoomChoose" then
    			--todo
    			nk.userData.DEFAULT_TAB = 2

    			runningScene.controller_:showMainHallView()
                runningScene.controller_.view_:onNorHallClick()
    		elseif action == "timMatch" then
    			--todo
    			if runningScene.controller_.view_.MATCH_TYPE_SELECTED ~= runningScene.controller_.view_.MATCH_TYPE_TIME then
    				--todo
    				runningScene.controller_.view_.mainTabBar_:gotoTab(runningScene.controller_.view_.MATCH_TYPE_TIME)
    			end
    		end
    	end
    elseif runningScene.name == "RoomSceneEx" then
    	--todo
    	if action == "cashRoomChoose" then
    		--todo
    		if runningScene.controller_.model:isSelfInGame() and runningScene.controller_.model:hasCardActive() then
                --todo
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then

                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                            nk.userData.DEFAULT_TAB = 2

                            if runningScene and runningScene.doBackToHall then
                                --todo
                                nk.server:logoutRoom()
                                runningScene:doBackToHall()
                            end
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                nk.userData.DEFAULT_TAB = 2

                if runningScene and runningScene.doBackToHall then
                    --todo
                    nk.server:logoutRoom()
                    runningScene:doBackToHall()
                end
            end
    	elseif action == "timMatch" then
    		--todo
    		if runningScene.controller_.model:isSelfInGame() and runningScene.controller_.model:hasCardActive() then
                --todo
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then

                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)

                            if runningScene and runningScene.doBackToHall then
                                --todo
                                nk.server:logoutRoom()
                                runningScene:doBackToHall()
                            end
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)

                if runningScene and runningScene.doBackToHall then
                    --todo
                    nk.server:logoutRoom()
                    runningScene:doBackToHall()
                end
            end
    	end

    elseif runningScene.name == "MatchRoomScene" then
    	--todo
    	if action == "cashRoomChoose" then
    		--todo
            if runningScene.controller_.model:isSelfInMatch() then
                --todo
                if runningScene.controller_.model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
                    --todo

                    local requestBackToHall = function()
                        nk.http.matchOut(function(data)

                            if data and data.money then
                                nk.userData["aUser.money"] = tonumber(data.money)
                            end

                            if runningScene and runningScene.doBackToHall then
                                --todo
                                runningScene:doBackToHall()
                            end
                        end, function(errorCode)
                            nk.TopTipManager:showTopTip(T("退赛失败,请继续比赛"))
                        end)
                    end

                    nk.http.getMatchExitLeftTime(runningScene.controller_.model.roomInfo.matchType, function(data)
                        
                        -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                        nk.userData.DEFAULT_TAB = 2

                        if tonumber(data.remainTime) > 0 then
                            local MatchExitTipPopup = import("app.module.match.views.MatchExitTipPopup")
                            MatchExitTipPopup.new(requestBackToHall, data.remainTime):show()
                        else
                            requestBackToHall()
                        end
                    end, function(errordata)
                        -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                        nk.userData.DEFAULT_TAB = 2

                        requestBackToHall()
                    end)

                else
                    -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                    nk.userData.DEFAULT_TAB = 2

                    nk.server:matchExitGetLeftTime()
                end

            else
                -- bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                nk.userData.DEFAULT_TAB = 2

                if runningScene.controller_.model:isSelfKnockOut() then
                    --如果被淘汰出局，需要调用退赛协议
                    nk.server:matchQuit()
                end
                
                if runningScene and runningScene.doBackToHall then
                    --todo
                    runningScene:doBackToHall()
                end
            end
    	elseif action == "timMatch" then
    		--todo
    		if runningScene.controller_.model:isSelfInMatch() then
                --todo
                if runningScene.controller_.model.gameInfo.gameStatus == consts.SVR_MATCH_GAME_STATUS.APPLY then
                    --todo

                    local requestBackToHall = function()
                        nk.http.matchOut(function(data)

                            if data and data.money then
                                nk.userData["aUser.money"] = tonumber(data.money)
                            end

                            if runningScene and runningScene.doBackToHall then
                                --todo
                                runningScene:doBackToHall()
                            end
                        end, function(errorCode)
                            nk.TopTipManager:showTopTip(T("退赛失败,请继续比赛"))
                        end)
                    end

                    nk.http.getMatchExitLeftTime(runningScene.controller_.model.roomInfo.matchType, function(data)
                        
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        if tonumber(data.remainTime) > 0 then
                            local MatchExitTipPopup = import("app.module.match.views.MatchExitTipPopup")
                            MatchExitTipPopup.new(requestBackToHall, data.remainTime):show()
                        else
                            requestBackToHall()
                        end

                    end,function(errordata)
                        bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                        requestBackToHall()
                    end)

                else
                    bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)

                    nk.server:matchExitGetLeftTime()
                end

            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)

                if runningScene.controller_.model:isSelfKnockOut() then
                    --如果被淘汰出局，需要调用退赛协议
                    nk.server:matchQuit()
                end
                
                if runningScene and runningScene.doBackToHall then
                    --todo
                    runningScene:doBackToHall()
                end
            end
    	end

    elseif runningScene.name == "GrabDealerRoomScene" then
    	--todo
    	if action == "cashRoomChoose" then
    		--todo
    		if runningScene.controller_.model:isSelfInGame() and runningScene.controller_.model:hasCardActive() then
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                            nk.userData.DEFAULT_TAB = 2

                            nk.server:logoutRoom()
                           -- self:doBackToHall()
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_NOR_VIEW)
                nk.userData.DEFAULT_TAB = 2

                nk.server:logoutRoom()
               -- self:doBackToHall()
            end

    	elseif action == "timMatch" then
    		--todo
    		if runningScene.controller_.model:isSelfInGame() and runningScene.controller_.model:hasCardActive() then
                nk.ui.Dialog.new({
                    messageText = bm.LangUtil.getText("ROOM", "EXIT_IN_GAME_MSG"), 
                    hasCloseButton = false,
                    callback = function (type)
                        if type == nk.ui.Dialog.SECOND_BTN_CLICK then
                            bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)
                            nk.server:logoutRoom()
                           -- self:doBackToHall()
                        end
                    end
                }):show()
            else
                bm.DataProxy:setData(nk.dataKeys.CURRENT_HALL_VIEW, HallController.CHOOSE_MATCH_NOR_VIEW)             
                nk.server:logoutRoom()
               -- self:doBackToHall()
            end
    	end
    end
end

return ScoreMarketControl