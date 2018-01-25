--
-- Author: TsingZhang@boyaa.com
-- Date: 2015-11-04 10:10:38
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: SignInModuleN Signature Complement.
--

SignInModuleN = SignInModuleN or {}
SignInModuleN._signInDataList = {}

function SignInModuleN.getSignInDataFromSvr()
	-- body
	local getSignInDataListId = nk.http.getSignInDataNew(
	
		function(data)
			-- dump(data, "nk.http.getSignInDataNew.data :====================")
			SignInModuleN._signInDataList = SignInModuleN.formatSignInData(data)

			bm.EventCenter:dispatchEvent(nk.eventNames.SIGNIN_GET_DATA_SUCC)
		end,

		function(errdata)
			SignInModuleN._signInDataList = nil
			dump(errdata, "errdata : ===============")
			bm.EventCenter:dispatchEvent(nk.eventNames.SIGNIN_GET_DATA_FAIL)
		end)
end

function SignInModuleN.getIsCanSignState()
	-- body
	local canSignInStateId = nk.http.getIsCanSignState(function(data)
		-- body
		-- dump(data, "getIsCanSignState: ==============")
	end,
	function(errData)
		-- body
		dump(errData, "getIsCanSignState.err :====================")
	end)
end

function SignInModuleN.formatSignInData(dataSignIn)
	-- body
	-- dump(dataSignIn, "dataSignIn: ================")

	local signedDays = tonumber(dataSignIn.signNum)  -- 这个值在调用接口修改后变成了String,保险起见！
	-- local signedDays = dataSignIn.signNum
	local isTodaySigned = dataSignIn.todayCanSign == 0 or false

	local todayIndex = isTodaySigned and signedDays or signedDays + 1
	local retDataList = {}

	retDataList.todayIdx = todayIndex

	for i = 1, #dataSignIn.prizelist do
		local signInListItem = dataSignIn.prizelist[i]
		signInListItem._idx = i
		table.insert(retDataList, signInListItem)
	end


	for i = 1, todayIndex do

		if i == todayIndex and not isTodaySigned then
			--todo
			retDataList[i]._isSigned = false
		else
			retDataList[i]._isSigned = true
		end
		
	end

	-- dump(retDataList, "retDataList: ===========")
	return retDataList
end

function SignInModuleN.getSignInDataList()
	-- body

	return SignInModuleN._signInDataList
end

-- 原则上说本地签到数据不应该做手动修改，下面方法仅在每日签到成功后执行一次 --
function SignInModuleN.alterSignInDataByDayIdx(todayIndex)
	-- body
	if SignInModuleN._signInDataList then
		--todo
		SignInModuleN._signInDataList[todayIndex]._isSigned = true
	end
end

return SignInModuleN