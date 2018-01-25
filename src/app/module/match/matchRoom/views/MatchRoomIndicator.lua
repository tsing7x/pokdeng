-- Author: thinkeras3@163.com
-- Date: 2015-11-03 15:0:39
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 比赛房间右上角排名底注指示器

local WIDTH  = 260
local HEIGHT = 75
local MatchRankPopup = import("app.module.match.views.MatchRankPopup")
local MatchTimeRankPopup = import("app.module.match.views.MatchTimeRankPopup")
local MatchRoomIndicator = class("MatchRoomIndicator",function()
	return display.newNode()
end)

function MatchRoomIndicator:ctor(ctx)
	self.ctx = ctx
    self:setNodeEventEnabled(true)

    local posX = display.right
    self.container_ = display.newNode()
    :addTo(self)
    :pos(posX-WIDTH/2 - 10,display.top - HEIGHT/2 - 10)
    display.newScale9Sprite("#match_room_indicator.png", 0, 0, cc.size(WIDTH,HEIGHT))
    :addTo(self.container_)
    
    self.ranktxt_ = display.newTTFLabel({text =  bm.LangUtil.getText("MATCH", "CURRENT_SELF_RANK").." ", color = cc.c3b(0xFF, 0xFF, 0xFF), size = 18, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.container_)
    :pos(-WIDTH/2 + 10,15)
    :align(display.LEFT_CENTER)

    local ranktxtSize = self.ranktxt_:getContentSize()
    self.rank_ = display.newTTFLabel({text = "0/0", color = styles.FONT_COLOR.GOLDEN_TEXT, size = 18, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.container_)
    :align(display.LEFT_CENTER)
    :pos(-WIDTH/2+ 10 + ranktxtSize.width,15)
    

    local baseStr = bm.LangUtil.getText("MATCH", "CURRENT_MATCH_BASE").." 0"
    self.baseChip_ = display.newTTFLabel({text = baseStr, color = cc.c3b(0xFF, 0xFF, 0xFF), size = 18, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.container_)
    :align(display.LEFT_CENTER)
    :pos(-WIDTH/2+ 10,-15)




    local baseChipSize = self.baseChip_:getContentSize()
    self.leftTime_ = display.newTTFLabel({text = "00:00", color = cc.c3b(0xFF, 0xFF, 0xFF), size = 18, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.container_)
    :pos(-WIDTH/2+ 10 + baseChipSize.width+20,-15)
    :align(display.LEFT_CENTER)

    local nextBase = bm.LangUtil.getText("MATCH", "NEXT_MATCH_BASE").." 0"
    self.nextBaseChip_ = display.newTTFLabel({text = nextBase, color = cc.c3b(0xFF, 0xFF, 0xFF), size = 18, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.container_)
    :align(display.LEFT_CENTER)
    :pos(-WIDTH/2+ 10,-15)
    :hide()

    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(WIDTH, HEIGHT)
        :onButtonClicked(buttontHandler(self, self.onShowRankPoup))
        :addTo(self.container_)

    --self:upDateTime(100)

    
end
function MatchRoomIndicator:upDateRank()

end


function MatchRoomIndicator:setMatchRoomIndicator(data)
    local rankList = data.rankList;
    local myRank = 0
    local total = #rankList
    for k,v in pairs(rankList) do
        if nk.userData["aUser.mid"] == checkint(v.uid) then
            myRank = v.rank
        end
    end
    self.rank_:setString(""..myRank.."/"..total)

    local curBaseChip = data.curBaseChip
    self.baseChip_:setString(bm.LangUtil.getText("MATCH", "CURRENT_MATCH_BASE").." "..bm.formatBigNumber(curBaseChip))

    local baseChipSize = self.baseChip_:getContentSize()
    self.leftTime_:pos(-WIDTH/2+ 10 + baseChipSize.width+ 20,-15)
    local nextAddBaseTime = tonumber(data.nextAddBaseTime)
    self.nextBaseChipNum_ = tonumber(data.nextBaseChip)

    self.baseChip_:show()
    self.leftTime_:show()
    self.nextBaseChip_:hide()
    
    self:upDateTime(nextAddBaseTime)
end
function MatchRoomIndicator:setTimeMatchIndicator(data)
            -- {name = "curBaseChip",type = T.INT},
            -- {name = "nextAddBaseTime",type = T.INT},
            -- {name = "nextBaseChip",type = T.INT},
            -- {name = "myRank",type = T.INT},
            -- {name = "leftPlayerNum",type = T.INT},
            -- {name = "firstPoints",type = T.INT},
            -- {name = "avaragePoints",type = T.INT}
    self.data_ = data
    local myRank = data.myRank
    local total = data.leftPlayerNum
    self.rank_:setString(""..myRank.."/"..total)

    local curBaseChip = data.curBaseChip
    self.baseChip_:setString(bm.LangUtil.getText("MATCH", "CURRENT_MATCH_BASE").." "..bm.formatBigNumber(curBaseChip))

    local baseChipSize = self.baseChip_:getContentSize()
    self.leftTime_:pos(-WIDTH/2+ 10 + baseChipSize.width+ 20,-15)
    local nextAddBaseTime = tonumber(data.nextAddBaseTime)
    self.nextBaseChipNum_ = tonumber(data.nextBaseChip)

    self.baseChip_:show()
    self.leftTime_:show()
    self.nextBaseChip_:hide()
    
    self:upDateTime(nextAddBaseTime)
end

function MatchRoomIndicator:upDateTime(lefttime)
    --self.leftTime_:setString("00:00")
    self:stopAction(self.action_)
    if lefttime == 0 then return end
	local lefttimeNum = checkint(lefttime)
	self.action_ = self:schedule(function ()
		local str = os.date("%M:%S", checkint(lefttimeNum));
		self.leftTime_:setString(str)
		lefttimeNum = lefttimeNum - 1
		 if lefttimeNum < 0 then

            self.baseChip_:hide()
            self.leftTime_:hide()
            self.nextBaseChip_:show()
            self.nextBaseChip_:setString(bm.LangUtil.getText("MATCH", "NEXT_MATCH_BASE")..self.nextBaseChipNum_)

		 	self:stopAction(self.action_)
		end
	end,1)
end
function MatchRoomIndicator:onCleanup()
   self:stopAction(self.action_)
end
function MatchRoomIndicator:onShowRankPoup()
    if self.ctx.model.roomInfo.matchType> 100 then
        local matchType = self.ctx.model.roomInfo.matchType
        MatchTimeRankPopup.new(matchType,self.data_):show()
    else
        MatchRankPopup.new(self.ctx):show()
    end
end

return MatchRoomIndicator