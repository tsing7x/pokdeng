local Config = {
	QRCodeShowPanelParam = {
		WIDTH = 642,
		HEIGHT = 368,

		frontSizes = {
			title = 32,
			descTop = 22,
			descBottom = 20
		},

		colors = {
			title = cc.c3b(195, 204, 226),
			descTop = cc.c3b(140, 159, 207),
			descBottom = cc.c3b(153, 153, 153)
		}
	},

	HelpPanelParam = {
		WIDTH = 810,
		HEIGHT = 545,

		frontSizes = {
			title = 35,
			tipsTiltle = 22,
			tipsCont = 20
		},

		colors = {
			title = cc.c3b(227, 232, 246),
			tipsTitle = cc.c3b(140, 159, 207),
			tipsCont = cc.c3b(199, 199, 199),
			tipsContNum = cc.c3b(255, 217, 9),
			tipsContQR = cc.c3b(255, 108, 0)
		}
	},

	PSWEntryPanelParam = {
		WIDTH = 642,
		HEIGHT = 370,

		frontSizes = {
			title = 35,
			columDesc = 22,
			contDesc = 20,
			editHint = 25,
			tips = 22,
			btnLabel = 28
		},

		colors = {
			title = cc.c3b(157, 170, 202),
			columDesc = cc.c3b(140, 159, 207),
			contDesc = display.COLOR_WHITE,
			editHint = cc.c3b(193, 193, 193),
			tips = cc.c3b(255, 27, 27),
			btnLabel = display.COLOR_WHITE
		}
	}
}

return Config