local FakeDatas = {
	name = {
		[1] = "Aken",
		[2] = "Bcon",
		[3] = "Bitk",
		[4] = "T-Bag"
	},

	point = {
		[1] = 20000,
		[2] = 25623,
		[3] = 58642,
		[4] = 83268,
		[5] = 48326
	},

	reward = {
		[1] = 812325,
		[2] = 851353,
		[3] = 521235,
		[4] = 152342
	},

	basePokerCardParam = {
		color = {
			[1] = "0",  -- 梅花
			[2] = "1",	-- 方块
			[3] = "2",	-- 红桃
			[4] = "3"	-- 黑桃
		},

		point = {
			[1] = "1",
			[2] = "2",
			[3] = "3",
			[4] = "4",
			[5] = "5",
			[6] = "6",
			[7] = "7",
			[8] = "8",
			[9] = "9",
			[10] = "A",
			[11] = "B",
			[12] = "C",
			[13] = "D"
		}
	},

	winFlag = {
		[1] = true,
		[2] = false
	}
}

local Config = {
	PanelParam = {
		WIDTH = 275,
		HEIGHT = 542,
		backgroundShownMagrinBottom = 35,
		backgroundShownMagrinTop = 15,
		backgroundShownMagrinRight = 0
	},

	ListViewParam = {
		WIDTH = 265,
		HEIGHT = 530
	},

	WinLoseShowParam = {
		WIDTH = 403,
		HEIGHT = 95
	},

	ListViewItemParam = {
		WIDTH = 265,
		HEIGHT = 75,
	},

	ListViewItemNum = 10,

	animationTime = 0.3,

	noGameReviewTTFLabelParam = {
		FrontSize = 25,
		Color = cc.c3b(207, 211, 231)
	}


}

function Config.makeFakeWinLoseData()
	-- body
	local fakeWinLoseData = {}
	local fakeDataItem = {}

	for i = 1, 2 do
		fakeDataItem = {
			name = FakeDatas.name[math.random(1, 4)],
			pokerCards = {
				[1] = FakeDatas.basePokerCardParam.color[math.random(1, 4)] .. FakeDatas.basePokerCardParam.point[math.random(1, 13)],
				[2] = FakeDatas.basePokerCardParam.color[math.random(1, 4)] .. FakeDatas.basePokerCardParam.point[math.random(1, 13)],
				[3] = FakeDatas.basePokerCardParam.color[math.random(1, 4)] .. FakeDatas.basePokerCardParam.point[math.random(1, 13)]
			},
			isWin = FakeDatas.winFlag[math.random(1, 2)]
		}

		table.insert(fakeWinLoseData, fakeDataItem)
	end

	return fakeWinLoseData
end

function Config.makeFakeItemParamList()
	local fakeParamTable = {}

	local listItemData = {}

	for i = 1, Config.ListViewItemNum do
		listItemData = {
			headUrl = nil,
			name = FakeDatas.name[math.random(1, 4)],
			point = FakeDatas.point[math.random(1, 5)],
			reward = FakeDatas.reward[math.random(1, 4)],
			pokerCards = {
				[1] = FakeDatas.basePokerCardParam.color[math.random(1, 4)] .. FakeDatas.basePokerCardParam.point[math.random(1, 13)],
				[2] = FakeDatas.basePokerCardParam.color[math.random(1, 4)] .. FakeDatas.basePokerCardParam.point[math.random(1, 13)],
				[3] = FakeDatas.basePokerCardParam.color[math.random(1, 4)] .. FakeDatas.basePokerCardParam.point[math.random(1, 13)]
			},
			isWin = FakeDatas.winFlag[math.random(1, 2)]
		}

		table.insert(fakeParamTable, listItemData)
	end
	return fakeParamTable
end

-- test --
function Config.testLog()
	-- body
	-- log(FakeDatas.basePokerCardParam.color[math.random(1, 4)] .. FakeDatas.basePokerCardParam.point[math.random(1, 13)])
end
-- test --

return Config