local Panel = import("app.pokerUI.Panel")

local CornuCheckInfoView = class("CornuCheckInfoView", function()return display.newNode() end)
local POPUP_WIDTH = 872
local POPUP_HEIGHT = 544
local TITLE_GAP = 30
local InvitePopup         = import("app.module.friend.InviteRecallPopup")
function CornuCheckInfoView:ctor()
	self:setNodeEventEnabled(true)

	display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[1], color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(POPUP_WIDTH-50, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(10,(POPUP_HEIGHT-100)/2-30)


    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[2], color = cc.c3b(0x55, 0x6A, 0x88), size = 20,dimensions = cc.size(POPUP_WIDTH-50, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(10,(POPUP_HEIGHT-100)/2-30-TITLE_GAP)

    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[3], color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(POPUP_WIDTH-50, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(10,(POPUP_HEIGHT-100)/2-30-2*TITLE_GAP)

    display.newScale9Sprite("#cor_small_bg.png", 0, 0, cc.size(790,200))
    :addTo(self)
    :pos(0,15)

    display.newScale9Sprite("#cor_small_title.png", 0, 0, cc.size(790,38))
    :addTo(self)
    :pos(0,95)

    display.newScale9Sprite("#cor_mini_line.png", 0, 0, cc.size(790,5))
    :addTo(self)
    :pos(0,30)

    display.newScale9Sprite("#cor_mini_line.png", 0, 0, cc.size(790,5))
    :addTo(self)
    :pos(0,-25)

    display.newSprite("#cor_gold_seed.png")
    :addTo(self)
    :pos(-790/2 +35+8, 55)

    display.newSprite("#cor_sliver_seed.png")
    :addTo(self)
    :pos(-790/2+35 +5, 0)

    display.newSprite("#cor_quick_potion.png")
    :addTo(self)
    :pos(-790/2+35 , -55)

    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[10], color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(790/3, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(-250 + 60,93)

    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[11], color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(790/3, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(-250+790/3 + 60,93)

    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[12], color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(790/3, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(-250+790*2/3 + 60,93)

    ---
    local POSITION_X = -250
    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","GOLD_SEED"), color = cc.c3b(0xe9, 0xC6, 0x0d), size = 20,dimensions = cc.size(160, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(POSITION_X,50)
    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[13], color = cc.c3b(0x55, 0x6A, 0x88), size = 20,dimensions = cc.size(790/3+60, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(POSITION_X+175 + 40,50)
    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[17], color = cc.c3b(0x55, 0x6A, 0x88), size = 20,dimensions = cc.size(790/3, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(POSITION_X+160 + 30 + 790/3+60,50)
    ---------------
    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","SILVER_SEED"), color = cc.c3b(0x72, 0xa3, 0xc2), size = 20,dimensions = cc.size(160, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(POSITION_X,0)
    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[14], color = cc.c3b(0x55, 0x6A, 0x88), size = 20,dimensions = cc.size(790/3+60, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(POSITION_X+175 + 40,0)
    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[16], color = cc.c3b(0x55, 0x6A, 0x88), size = 20,dimensions = cc.size(790/3, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(POSITION_X+160 + 30 + 790/3+60,0)
-------
    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","QUICK_POTION"), color = cc.c3b(0x3b, 0xC4, 0xd8), size = 20,dimensions = cc.size(160, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(POSITION_X,-50)
    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[15], color = cc.c3b(0x55, 0x6A, 0x88), size = 20,dimensions = cc.size(790/3+60, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(POSITION_X+175 + 40,-50)
    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[18], color = cc.c3b(0x55, 0x6A, 0x88), size = 20,dimensions = cc.size(790/3, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(POSITION_X+160 + 30 + 790/3+60,-50)


    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[4], color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(POPUP_WIDTH-50, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(10,-(POPUP_HEIGHT-100)/2+125)

    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[5], color = cc.c3b(0x55, 0x6A, 0x88), size = 20,dimensions = cc.size(POPUP_WIDTH-50, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(10,-(POPUP_HEIGHT-100)/2+125-TITLE_GAP)

    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[6], color = cc.c3b(0x55, 0x6A, 0x88), size = 20,dimensions = cc.size(POPUP_WIDTH-50, 0), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :pos(10,-(POPUP_HEIGHT-100)/2+125-2*TITLE_GAP)

    local tempTxt_ = display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","EXPLAIN_INFO")[7], color = cc.c3b(0x55, 0x6A, 0x88), size = 20, align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.TOP_LEFT)
    :pos(-(POPUP_WIDTH-50)/2+10,-(POPUP_HEIGHT-100)/2+125-3*TITLE_GAP+10)

    local size = tempTxt_:getContentSize()
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(120, 30)
    :align(display.TOP_LEFT)
    :pos(-(POPUP_WIDTH-50)/2+10+size.width,-(POPUP_HEIGHT-100)/2+125-3*TITLE_GAP+13)
    :onButtonClicked(buttontHandler(self, self.inviteBtn_))
    :setButtonLabel("normal", display.newTTFLabel({text = T("邀请好友>>"), color = cc.c3b(0xf0,0xff,0x00), size = 20, align = ui.TEXT_ALIGN_CENTER}))
    :addTo(self)
end
function CornuCheckInfoView:inviteBtn_()
    InvitePopup.new():show()
end
function CornuCheckInfoView:onCleanup()

end

return CornuCheckInfoView