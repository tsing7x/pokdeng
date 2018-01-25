--
-- Author: Jonah0608@gmail.com
-- Date: 2015-05-11 11:30:01
--

local channelInfo = require("channelConfig")
local PHPServerUrl = {
    { name="内网测试",url=channelInfo.localServerUrl},
    { name="线上测试",url=channelInfo.onlineTestServerUrl},
    { name="预演环境",url=channelInfo.prePublishServerUrl},
    { name="正式环境",url=channelInfo.onlineServerUrl}
}

return PHPServerUrl