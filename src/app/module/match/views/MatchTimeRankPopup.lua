local MatchTimeRankPopup = class("MatchTimeRankPopup", function()
	return display.newNode();
end)
-- local MatchPopupTabBar = import(".MatchPopupTabBar")
MatchTimeRankPopup.WIDTH = 255;
MatchTimeRankPopup.HEIGHT = 302;

function MatchTimeRankPopup:ctor(matchtype,data)
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    display.addSpriteFrames("match.plist", "match.png")
    self.roominfo_ = data
	local width, height = MatchTimeRankPopup.WIDTH, MatchTimeRankPopup.HEIGHT;
	self.mainContainer_ = display.newNode():addTo(self)
    self.mainContainer_:setContentSize(width, height)
    self.mainContainer_:pos(display.width-width,display.height-height)
    self.mainContainer_:setTouchEnabled(true)
    --self.mainContainer_:setTouchSwallowEnabled(true)
    self.mainContainer_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onContainerTouchHandler_))
    --
    self.bg_ = display.newScale9Sprite("#match_time_rank_base.png", 0, 0, cc.size(width, height)):addTo(self.mainContainer_)
	self.bg_:setTouchEnabled(true);
	self.bg_:setTouchSwallowEnabled(true);

	-- 一级tab bar
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = MatchTimeRankPopup.WIDTH,
            scale = (255 - 20) / 255,
            iconOffsetX = 10, 
            btnText = bm.LangUtil.getText("MATCH", "MATCH_TIME_RANK_TAB"), 
        })
        :setTabBarExtraParam({tabBarHeight = 41})
        :pos(0, height/2-22)
        :addTo(self.mainContainer_)

    self.matchName_ = display.newTTFLabel({text = "5泰铢定人赛", color = cc.c3b(0x71, 0x8A, 0xAF), size = 20,align = ui.TEXT_ALIGN_CENTER})
    :addTo(self.mainContainer_)
    :pos(0,height/2-61)

	self.content_bg_ = display.newScale9Sprite("#match_time_rank_content.png", 0, 0, cc.size(width-20, height-85)):addTo(self.mainContainer_)
	self.content_bg_:pos(0,-34)

	local rankNodeWidth = width-20
	local rankNodeHeight = height-85
	self.rankNode_ = display.newNode():addTo(self.mainContainer_)
	self.rankNode_:setContentSize(width-20, height-85)
	self.rankNode_:pos(0,-34)

	local data = bm.DataProxy:getData(nk.dataKeys.MATCH_DETAIL)
	if data == nil or data.leftPlayerNum == nil then 
		data = {} 
		data.nextAddBaseTime = "00:00"
		data.nextBaseChip = "--"
		data.myRank = "--"
		data.leftPlayerNum = "--"
		data.firstPoints = "--"
		data.avaragePoints = "--"
	end
	--排名
	self.rankLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH","MATCH_TIME_RANK")[1], color = cc.c3b(0x71, 0x8A, 0xAF), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5,rankNodeHeight/2 - 20)

    self.rankLabelSize = self.rankLabel_:getContentSize()
    self.myRank_ = display.newTTFLabel({text = data.myRank.."/"..data.leftPlayerNum, color = cc.c3b(0xda, 0xd3, 0x61), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5 + self.rankLabelSize.width,rankNodeHeight/2 - 20)

    --底注
    self.baseLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH","MATCH_TIME_RANK")[2], color = cc.c3b(0x71, 0x8A, 0xAF), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5,rankNodeHeight/2 - 50)
    self.baseLabelSize = self.baseLabel_:getContentSize()

    local curBaseChip = 0
    if self.roominfo_ then
        curBaseChip = self.roominfo_.curBaseChip
    end
    self.baseChip_ = display.newTTFLabel({text = ""..curBaseChip, color = cc.c3b(0xda, 0xd3, 0x61), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5 + self.baseLabelSize.width,rankNodeHeight/2 - 50)

    --下次底注
    self.nextBaseLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH","MATCH_TIME_RANK")[3], color = cc.c3b(0x71, 0x8A, 0xAF), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5,rankNodeHeight/2 - 80)
    self.nextBaseLabelSize = self.nextBaseLabel_:getContentSize()
    self.nextbaseChip_ = display.newTTFLabel({text = data.nextBaseChip, color = cc.c3b(0xda, 0xd3, 0x61), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5 + self.nextBaseLabelSize.width,rankNodeHeight/2 - 80)

    --第一名积分
    self.firstLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH","MATCH_TIME_RANK")[4], color = cc.c3b(0x71, 0x8A, 0xAF), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5,rankNodeHeight/2 - 110)
    self.firstLabelSize = self.firstLabel_:getContentSize()
    self.firstRank_ = display.newTTFLabel({text = data.firstPoints, color = cc.c3b(0xda, 0xd3, 0x61), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5 + self.firstLabelSize.width,rankNodeHeight/2 - 110)

    --平均积分
    self.avarageLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH","MATCH_TIME_RANK")[5], color = cc.c3b(0x71, 0x8A, 0xAF), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5,rankNodeHeight/2 - 140)
    self.avarageLabelSize = self.avarageLabel_:getContentSize()
    self.avaragePoint_ = display.newTTFLabel({text = data.avaragePoints, color = cc.c3b(0xda, 0xd3, 0x61), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5 + self.avarageLabelSize.width,rankNodeHeight/2 - 140)

    --剩余人数
    self.leftLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("MATCH","MATCH_TIME_RANK")[6], color = cc.c3b(0x71, 0x8A, 0xAF), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5,rankNodeHeight/2 - 170)
    self.leftLabelSize = self.leftLabel_:getContentSize()
    self.leftPlayer_  = display.newTTFLabel({text = ""..data.leftPlayerNum, color = cc.c3b(0xda, 0xd3, 0x61), size = 20,align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.rankNode_)
    :align(display.LEFT_CENTER)
    :pos(-rankNodeWidth/2+5 + self.leftLabelSize.width,rankNodeHeight/2 - 170)

    self.awardNode_ = display.newNode():addTo(self.mainContainer_)
	self.awardNode_:setContentSize(width-20, height-85)
	self.awardNode_:pos(0,-34)

	self.awardLabel_ = display.newTTFLabel({text = "", color = cc.c3b(0xda, 0xd3, 0x61), size = 20,dimensions = cc.size(width-30, height-95),align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.awardNode_)
    --:align(display.LEFT_CENTER)

	if matchtype == nil or matchtype == 0 then
		matchtype = 101
	end
	local data = nk.MatchConfigEx:getMatchDataById(matchtype)
	self.matchName_:setString(data.name)
    

    local str = ""
    if data.prizeDesc then
	    for i=1,#data.prizeDesc do
	    	str = str..bm.LangUtil.getText("MATCH","RANKING_LABEL",i)..':'..data.prizeDesc[i].."\n"
	    end
	end
	str = str..data.prizeTips
	self.awardLabel_:setString(str)
end
function MatchTimeRankPopup:onContainerTouchHandler_(evt)
    self:close();
end
function MatchTimeRankPopup:show()
    nk.PopupManager:addPopup(self,true,false,true,false)
    self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
    return self
end
-- function MatchTimeRankPopup:updata(data)
--     self.roominfo_ = data
--     local curBaseChip = 0
    
--     curBaseChip = self.roominfo_.curBaseChip
    
--     self.baseChip_:setString(""..curBaseChip)
-- end
function MatchTimeRankPopup:close()
	nk.PopupManager:removePopup(self)
    return self
end
function MatchTimeRankPopup:onMainTabChange_(selectedTab)
    self.rankNode_:hide()
    self.awardNode_:hide()
    if selectedTab == 1 then
        self.rankNode_:show()
    elseif selectedTab == 2 then
        self.awardNode_:show()
    end
end
function MatchTimeRankPopup:onCleanup()
	display.removeSpriteFramesWithFile("match.plist", "match.png")
end

return MatchTimeRankPopup