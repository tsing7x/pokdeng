
local channel = require("channel")

local ChannelConfig = 
{
	[1] = 
	{
		["device"] = "android",
		["sid"] = 1,
		["localServerUrl"] = "http://pd.oa.com/platform/androidtl/firstapi.php",
		["onlineServerUrl"] = "http://mvlptlpd01.boyaagame.com/androidtl/platform/androidtl/firstapi.php",
		["onlineTestServerUrl"] = "http://mvlptlpd04.boyaagame.com/androidtl/platform/androidtl/firstapi.php",
		["umengAppkey"] = "559f7c4667e58eb515001a4b",
		["feedback"] = {appid = 4102,game = "pd"}
	},

	[2] = 
	{
		["device"] = "ios",
		["sid"] = 2,
		["localServerUrl"] = "http://pd.oa.com/platform/iostl/firstapi.php",
		["onlineServerUrl"] = "http://mvlptlpd03.boyaagame.com/iostl/platform/iostl/firstapi.php",
		["onlineTestServerUrl"] = "http://mvlptlpd04.boyaagame.com/iostl/platform/iostl/firstapi.php",
		["umengAppkey"] = "55c1c89667e58e6b6e001118",
		["feedback"] = {appid = 9012,game = "pd"}
	},
}


return ChannelConfig[channel]