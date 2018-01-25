local HallController = import("app.module.hall.HallController")

local StorePopup = import("app.module.newstore.StorePopup")
local GiftShopPopup = import("app.module.gift.GiftShopPopup")
local FriendPopup = import("app.module.friend.FriendPopup")
local SettingAndHelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local DailyTasksPopup = import("app.module.dailytasks.DailyTasksPopup")
local RankingPopup = import("app.module.ranking.RankingPopup")
local ExchangeCodePopup = import("app.module.exchangecode.ExchangeCode")
local UserInfoPopup = import("app.module.userInfo.UserInfoPopup")
local InvitePopup = import("app.module.friend.InviteRecallPopup")
local CornucopiaPopup = import("app.module.cornucopiaEx.CornuPopup")
-- local NewestActPopup = import("app.module.newestact.NewestActPopup")
local SignInContPopup = import("app.module.signIn.SignInContPopup")

local ByActivityJump = class("ByActivityJump")

function ByActivityJump:ctor()
	-- body
end

function ByActivityJump:doJump(jumpInfo)
	-- body
	
    if not jumpInfo then
        --todo
        return
    end

	local currentViewType = bm.DataProxy:getData(nk.dataKeys.CURRENT_HALL_VIEW)
    local runningScene = nk.runningScene

	local getJumpSenceByTargetInst = {
        ["lobby"] = function()
            -- body

            -- 跳转到普通场不在这里处理，由target == "room" 去处理
            if runningScene.name == "HallScene" then
            	--todo
            	if currentViewType == HallController.MAIN_HALL_VIEW then
            		--todo

            		if jumpInfo.desc == "private" then
            			--todo
            			runningScene.controller_.view_:onProHallClick()
            		end

            		if jumpInfo.desc == "match" then
            			--todo

                        runningScene.controller_.view_:onMatchHallClick()
            			-- dump("No MatchRoom Yet!")
            		end

                    if jumpInfo.desc == "grabdealer" then
                        --todo

                        nk.userData.DEFAULT_TAB = 1
                        runningScene.controller_.view_:onNorHallClick()
                    end

                    if jumpInfo.desc == "goCash" then
                        --todo

                        nk.userData.DEFAULT_TAB = 2
                        runningScene.controller_.view_:onNorHallClick()
                    end

            		return
            	end

                -- 暂时未有调用下面逻辑 --
            	if currentViewType == HallController.CHOOSE_NOR_VIEW then
            		--todo

                    -- 目前还未有在选场界面的活动中心展示 --
            		if jumpInfo.desc == "private" then
            			--todo
                        runningScene.controller_:showMainHallView()
            			runningScene.controller_.view_:onProHallClick()
            		end

            		if jumpInfo.desc == "match" then
            			--todo
                        runningScene.controller_:showMainHallView()
                        runningScene.controller_.view_:onMatchHallClick()
            			-- dump("No MatchRoom Yet!")
            		end

                    if jumpInfo.desc == "grabdealer" then
                        --todo

                        nk.userData.DEFAULT_TAB = 1
                        runningScene.controller_:showMainHallView()
                        runningScene.controller_.view_:onNorHallClick()
                    end

                    if jumpInfo.desc == "goCash" then
                        --todo

                        nk.userData.DEFAULT_TAB = 2
                        runningScene.controller_:showMainHallView()
                        runningScene.controller_.view_:onNorHallClick()
                    end

            		if jumpInfo.desc == nil then
            			--todo
            			runningScene.controller_:showMainHallView()
            		end

            		return
            	end

                -- 暂时未有调用 --
            	if currentViewType == HallController.CHOOSE_PERSONAL_NOR_VIEW then
            		--todo

                    -- 目前还未有在选场界面的活动中心展示 --
            		if jumpInfo.desc == nil then
            			--todo
            			runningScene.controller_:showMainHallView()
            		end

            		if jumpInfo.desc == "match" then
            			--todo
                        runningScene.controller_:showMainHallView()
                        runningScene.controller_.view_:onMatchHallClick()
            			-- dump("No MatchRoom Yet!")
            		end

                    if jumpInfo.desc == "grabdealer" then
                        --todo
                        
                        nk.userData.DEFAULT_TAB = 1
                        runningScene.controller_:showMainHallView()
                        runningScene.controller_.view_:onNorHallClick()
                    end

                    if jumpInfo.desc == "goCash" then
                        --todo

                        nk.userData.DEFAULT_TAB = 2
                        runningScene.controller_:showMainHallView()
                        runningScene.controller_.view_:onNorHallClick()
                    end

            		return
            	end

            	-- 比赛场加入后，考虑加入比赛场的跳转
            	if currentViewType == HallController.CHOOSE_MATCH_NOR_VIEW then
            		--todo
                    -- 目前还未有在选场界面的活动中心展示 --
            		if self._desc == nil then
            			--todo
            			runningScene.controller_:showMainHallView()
            		end

            		if self._desc == "private" then
            			--todo
                        runningScene.controller_:showMainHallView()
            			runningScene.controller_.view_:onProHallClick()
            		end

                    if jumpInfo.desc == "grabdealer" then
                        --todo
                        
                        nk.userData.DEFAULT_TAB = 1
                        runningScene.controller_:showMainHallView()
                        runningScene.controller_.view_:onNorHallClick()
                    end

                    if jumpInfo.desc == "goCash" then
                        --todo

                        nk.userData.DEFAULT_TAB = 2
                        runningScene.controller_:showMainHallView()
                        runningScene.controller_.view_:onNorHallClick()
                    end

            		return
            	end
            end

            -- Set Null For Temporary --
            if runningScene.name == "RoomSceneEx" then
            	--todo
            end

            if runningScene.name == "MatchRoomScene" then
                --todo
            end

            if runningScene.name == "GrabDealerRoomScene" then
                --todo
            end
            -- end --
        end,

        ["room"] = function()
            -- body
            if runningScene.name == "HallScene" then
            	--todo

            	if jumpInfo.desc == "game" then
            		--todo
            		-- dump("Incorrect Param!")

            		nk.server:quickPlay()
            	else
            		self:gotoGivenRoomByIns(jumpInfo.desc) -- 直接玩牌。暂时木有选场操作！
            	end
            end

            -- 暂时处理,后面可能会加上比赛场景和私人房、上庄场的跳转逻辑 --
            if runningScene.name == "RoomSceneEx" then
            	--todo
            	if jumpInfo.desc == "game" then
            		--todo
            		runningScene.onChangeRoomClick_()
            	else
            		dump("Incorrect Param!")
            	end
            end

            -- Set Null For Temporary --
            if runningScene.name == "MatchRoomScene" then
                --todo
            end

            if runningScene.name == "GrabDealerRoomScene" then
                --todo
            end
            -- end --
        end,

        ["store"] = function()
            -- body
            GiftShopPopup.new():show()
        end,

        ["friend"] = function()
            -- body
            FriendPopup.new():show()
        end,

        ["feedback"] = function()
            -- body
            SettingAndHelpPopup.new(false, true, 1):show()
        end,

        ["task"] = function()
            -- body
            DailyTasksPopup.new():show()
        end,

        ["rank"] = function()
            -- body
            RankingPopup.new():show()
        end,
    
        ["propstore"] = function()
            -- body
            ExchangeCodePopup.new():show()
        end,

        ["info"] = function()
            -- body
            -- if runningScene.name == "RoomScene" then
            -- 	--todo
            -- 	UserInfoPopup.new():show(true, roomTableInfo)
            -- end

        	UserInfoPopup.new():show(false)
        end,

        ["invite"] = function()
        	-- body
        	InvitePopup.new():show()
        end,

        ["farm"] = function()
        	-- body
        	CornucopiaPopup.new():show()
        end,

        ["sign"] = function()
        	-- body
            SignInContPopup.new():show()

        	-- if runningScene.name == "HallScene" then
        	-- 	--todo
        	-- 	NewestActPopup.new(4, function(action, param)
		       --      if action == "playnow" then
		       --          runningScene.controller_:getEnterRoomData(nil, true)
		       --      elseif action == "gotoChoseRoomView" then
		       --          runningScene.controller_:showChooseRoomView(param)
		       --      elseif action == "invite" then

		       --          if runningScene.controller_.view_ and runningScene.controller_.view_.onInviteBtnClick then
		       --              runningScene.controller_.view_:onInviteBtnClick()
		       --          end

		       --      elseif action == "openShop" then
		       --          if runningScene.controller_.view_ and runningScene.controller_.view_.onStoreBtnClicked then
		       --              -- self:onStoreBtnClicked()
		       --              StorePopup.new(nil,PURCHASE_TYPE.BLUE_PAY):showPanel()
		       --          end
		       --      end
		       --  end):show()
        	-- end

        	-- if runningScene.name == "RoomScene" then
        	-- 	--todo
        	-- 	dump("Not In HallScene!")
        	-- end

        end,
		--{"type":"coin","count":"10","target":"recharge"}"
        ["recharge"] = function()
        	-- body

        	StorePopup.new():showPanel()
        end,

        ["shareFB"] = function()

            -- dump(jumpInfo.desc, "Desc :====")

            -- local shareInfoDesc = jumpInfo.desc

            -- dump(shareInfoDesc, "shareInfoDesc:")
            -- -- body
            -- local shareInfo = {}
            -- shareInfo.name = shareInfoDesc.name
            -- shareInfo.caption = shareInfoDesc.caption
            -- shareInfo.link = shareInfoDesc.link
            -- shareInfo.picture = shareInfoDesc.picture
            -- shareInfo.message = shareInfoDesc.message
            
            -- jumpInfo.desc.picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/jinseed.jpg"
            nk.sendFeed:actCenter_share_fb(jumpInfo.desc, function()
                -- body
                -- 这里后面可能会加上统计。
            end,
            function ()
                -- body
            end)
        end,

        ["openLink"] = function()
            -- body
            if jumpInfo.desc and string.len(jumpInfo.desc) >= 5 then
                --todo
                device.openURL(jumpInfo.desc)
            end
        end
    }

    if getJumpSenceByTargetInst[jumpInfo.target] then
        --todo
        getJumpSenceByTargetInst[jumpInfo.target]()
    end
end

function ByActivityJump:gotoGivenRoomByIns(desc)
	-- body
	-- 将desc调整为roomLevel，选定指定范围内的场次进入！

	-- dump(desc, "desc :==============")
	local roomLevelRangeTable = string.split(desc, "-")

	local minLevelMin, minLevelMax = tonumber(roomLevelRangeTable[1]), tonumber(roomLevelRangeTable[2])

	local roomEnterMaxLevel = nk.getRoomLevelByMoney2(nk.userData["aUser.money"])
	local roomEnterMinLevel = nk.getRoomLevelMinByMoney(nk.userData["aUser.money"])

	local enterRoomLevel = nil
	if roomEnterMaxLevel and roomEnterMinLevel then
		--todo
		if minLevelMax <= roomEnterMaxLevel and minLevelMax >= roomEnterMinLevel and minLevelMin <= roomEnterMinLevel then
			--todo
			enterRoomLevel = math.random(roomEnterMinLevel, minLevelMax)

			nk.server:getRoomAndLogin(enterRoomLevel, 0)

			return
		end

		if minLevelMin >= roomEnterMinLevel and minLevelMax <= roomEnterMaxLevel then
			--todo
			enterRoomLevel = math.random(minLevelMin, minLevelMax)

			nk.server:getRoomAndLogin(enterRoomLevel, 0)
			return
		end

		if minLevelMin >= roomEnterMinLevel and minLevelMin >= roomEnterMaxLevel and minLevelMax >= roomEnterMaxLevel then
			--todo
			enterRoomLevel = math.random(minLevelMin, roomEnterMaxLevel)

			nk.server:getRoomAndLogin(enterRoomLevel, 0)
			return
		end

		dump("No Room In this Range Choose!")
	else
		dump("Can Not Enter Any Room!")
	end

end

return ByActivityJump