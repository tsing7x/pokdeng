-- -- Author: thinkeras3@163.com
-- -- Date: 2015-10-19 16:0:39
-- -- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- -- 排行榜弹窗

local MatchRankPopup = class("MatchRankPopup",nk.ui.Panel)
local MatchRankItem = import(".MatchRankItem")
local MatchRankAwardItem = import(".MatchRankAwardItem")
local WIDTH = 616
local HEIGHT = 424
local TOP_HEIGHT = 56
function MatchRankPopup:ctor(ctx)
    self.ctx_ = ctx
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    display.addSpriteFrames("match.plist", "match.png")
	self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(true)
    self:setNodeEventEnabled(true)
	self:createNode_()
    
end

function MatchRankPopup:createNode_()
	display.newScale9Sprite("#match_dialog.png", 0, 0, cc.size(WIDTH,HEIGHT ))
    :pos(0,0)
    :addTo(self)
    

	display.newScale9Sprite("#match_dialogTop.png", 0, 0, cc.size(WIDTH-8,TOP_HEIGHT ))
    :pos(0,HEIGHT/2 - TOP_HEIGHT/2)
    :addTo(self)


    -- 一级tab bar
    self.mainTabBar_ = nk.ui.CommonPopupTabBar.new(
        {
            popupWidth = 616, 
            iconOffsetX = 10, 
            scale = 0.7,
            iconTexture = {
                {"#friend_rank_tab_icon_selected.png", "#friend_rank_tab_icon_unselected.png"}, 
                {"#all_rank_tab_icon_selected.png", "#all_rank_tab_icon_unselected.png"}
            }, 
            btnText = {bm.LangUtil.getText("MATCH", "RANK_BOARD"),bm.LangUtil.getText("MATCH", "RANK_AWARD")}, 
        }
    )
        :pos(0, HEIGHT * 0.5 - nk.ui.CommonPopupTabBar.TAB_BAR_HEIGHT * 0.5+ 5)
        :addTo(self, 10)

    self.mainTabBar_:setScale(.7)    

        --{"#match_rank_tab_icon_selected.png", "#match_rank_tab_icon_unselected.png"}, 
          --      {"#match_rankgift_tab_icon_selected.png", "#match_rankgift_tab_icon_unselected.png"}
    

    
    --:pos(WIDTH/2,ITEM_HEIGHT/2)


    display.newScale9Sprite("#match_rank_content.png",0,0,cc.size(WIDTH-20,320))
    :addTo(self)
    :pos(0,-35)--

    display.newTTFLabel({text = bm.LangUtil.getText("MATCH","CURRENT_SELF_RANK"), color = cc.c3b(0x89, 0xa2, 0xc6), size = 20,align = ui.TEXT_ALIGN_CENTER})
    :addTo(self)
    :pos(-50,HEIGHT/3-5)

    self.rank_ = display.newTTFLabel({text = "1", color = styles.FONT_COLOR.LIGHT_TEXT, size = 20,align = ui.TEXT_ALIGN_CENTER})
    :addTo(self)
    :pos(50,HEIGHT/3-5)

    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
            :pos(WIDTH * 0.5 - 22, HEIGHT * 0.5 - 25)
            :onButtonClicked(function() 
                    self:onClose()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 99)


    --self.selectedTab_ = 1;
end

function MatchRankPopup:show()
	self:showPanel_()
end

function MatchRankPopup:onShowed()
    
     self.mainTabBar_:onTabChange(handler(self, self.onMainTabChange_))
     self:onMainTabChange_(1)


     -- 添加列表
end
function MatchRankPopup:onMainTabChange_(selectedTab)
    if self.selectedTab_ == selectedTab then
        return
    end
    self.selectedTab_ = selectedTab
    if self.list_ then
        self.list_:removeFromParent()
        self.list_ = nil
    end

    local ItemClass = nil;
    if self.selectedTab_ == 1 then
        ItemClass = MatchRankItem
    else
        ItemClass = MatchRankAwardItem
    end
    self.list_ = bm.ui.ListView.new(
        {
            viewRect = cc.rect(-596* 0.5 , -320 * 0.5, 596, 320),
            direction = bm.ui.ListView.DIRECTION_VERTICAL
        }, 
            ItemClass
    )
    :pos(0, -35)
    :addTo(self)
    
        self.list_:update()
        self.list_:update()

    if self.selectedTab_ == 1 then
        local data = bm.DataProxy:getData(nk.dataKeys.MATCH_RANK)
        if data == nil then
            data = {}
            data.rankList = {} 
        end
        self.list_:setData(data.rankList or {})
        for k,v in pairs(data.rankList) do
        if nk.userData["aUser.mid"] == checkint(v.uid) then
            self.rank_:setString(v.rank.."")
        end
    end
    else
        local matchPrizeData = nk.MatchConfigEx:getPrizeDataById(self.ctx_.model.roomInfo.matchType)
        local prizeData = {}
        for i,v in pairs(matchPrizeData) do
            table.insert(prizeData,{rank = i,desc = v})
        end
        self.list_:setData(prizeData)
    end
end
function MatchRankPopup:onCleanup()
	display.removeSpriteFramesWithFile("match.plist", "match.png")
end

return MatchRankPopup