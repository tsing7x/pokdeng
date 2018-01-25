local Config = {
	TipsPanelParam = {
		WIDTH = 646,
		HEIGHT = 260,

		LabelTitleMagrinTop = 15,
		LabelTitleFrontSize = 25,
		-- LabelTitleColor = cc.c3b(167, 167, 167)

		LabelShownMagrinLeft = 15,
		LabelShownMagrinRight = 10,
		LabelShonMagrinLines = 8,
		TipsLabelFrontSize = 22,

		BtnFrontSize = 25
	},

	FirstChargePanelParam = {
		WIDTH = 675,
		HEIGHT = 375,

		frontSizes = {
			title = 26,
			viceTitle = 18,
			tipsBottom = 20,
			goStroeBtn = 22
		},

		colors = {
			title = cc.c3b(255, 193, 143),
			viceTitle = display.COLOR_BLACK,
			tipsbottom = cc.c3b(176, 176, 176),
			tipsBluePay = cc.c3b(92, 184, 255),
			goStroeBtn = display.COLOR_WHITE
		}
	},

	FirChgListViewParam = {
		WIDTH = 620,
		HEIGHT = 215
	},

	FirChgListItemParam = {
		WIDTH = 605,
		HEIGHT = 110,

		frontSizes = {
			labelPrice = 20,
			labelAvgPrice = 16,
			labelBtn = 22
		},

		colors = {
			labelPrice = display.COLOR_BLACK,
			labelAvgPrice = cc.c3b(176, 176, 176),
			labelBtn = display.COLOR_WHITE
		}
	},

	ReChagePanelParam = {
		WIDTH = 748,
		HEIGHT = 410,

		frontSizes = {
			title = 26,
			viceTitle = 18,
			goStroeBtn = 25
		},

		colors = {
			title = cc.c3b(208, 208, 208),
			viceTitle = display.COLOR_BLACK,
			goStroeBtn = display.COLOR_WHITE
		}
	},

	RechgListViewParam = {
		WIDTH = 715,
		HEIGHT = 230
	},

	RechgListItemParam = {
		WIDTH = 698,
		HEIGHT = 110,

		frontSizes = {
			labelPrice = 20,
			labelAvgPrice = 16,
			labelBtn = 25
		},

		colors = {
			labelPrice = display.COLOR_BLACK,
			labelAvgPrice = cc.c3b(176, 176, 176),
			labelBtn = display.COLOR_WHITE
		}
	}
}

return Config