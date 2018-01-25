
PromotActModule = PromotActModule or {}
PromotActModule._claimStatusList = {}

function PromotActModule.getDataListSvr()
	-- body
	-- PromotActModule._claimStatusList = {}
	local getUnionActDataListId = nk.http.getClaimDataList(
		function(data)
			-- body

			-- dump(data, "getClaimDataList.data :========================")
			PromotActModule._claimStatusList = PromotActModule.formateDataList(data)
			bm.EventCenter:dispatchEvent(nk.eventNames.PROMOT_GET_TASK_STATUS_DATA_SUCC)
		end,

		function(errData)
			-- body
			-- dump(errData, "getClaimDataList.errData :======================")
			PromotActModule._claimStatusList = nil
			bm.EventCenter:dispatchEvent(nk.eventNames.PROMOT_GET_TASK_STATUS_DATA_FAIL)
		end)

	PromotActModule._appInstallState = PromotActModule.getAppInstallState()
end

function PromotActModule.formateDataList(dataList)
	-- body

	local claimStatusList = {}

	local playRound = dataList.playNum
	local inviteNum = dataList.inviteNum

	local finalRewardStatu = dataList.status[#dataList.status]

	local getFinishNumByIdx = {
		[1] = function()
			-- body
			return nil
		end,

		[2] = function()
			-- body
			return playRound
		end,

		[3] = function()
			-- body
			return inviteNum
		end
	}

	for i = 1, 3 do
		local statuItem = {}
		statuItem.state = dataList.status[i]
		statuItem.finishNum = getFinishNumByIdx[i]()

		table.insert(claimStatusList, statuItem)
	end

	claimStatusList.finalRewardStatu = finalRewardStatu

	return claimStatusList

end

function PromotActModule.refreshDataList()
	-- body
end

function PromotActModule.getClaimStatuListData()
	-- body
	return PromotActModule._claimStatusList
end

function PromotActModule.getAppInstallState()
	-- body

	local ninekeGamePackageName = "com.boomegg.nineke"
	local isAppInstalled, gameInstallInfo = nk.Native:isAppInstalled(ninekeGamePackageName)
	return isAppInstalled
end

-- makeFakeData Not Necessary --
function PromotActModule.makeFakeDatas()
	-- body
end

return PromotActModule