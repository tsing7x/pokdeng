
local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")
local NewerGuidePopup = class("NewerGuidePopup",function()
	return display.newNode()
end)

local WIDTH = 676
local HEIGHT = 288

function NewerGuidePopup:ctor()

	-- self:addCloseBtn()
	self:createNodes_()
end

function NewerGuidePopup:createNodes_()
	local bgLeft = display.newSprite("newerguide/new_bg.png")
	:addTo(self)
	bgLeft:setScaleX(-1)
	bgLeft:setAnchorPoint(cc.p(0, 0.5))
	bgLeft:setTouchEnabled(true)
    bgLeft:setTouchSwallowEnabled(true)

	local bgRight = display.newSprite("newerguide/new_bg.png")
	:addTo(self)
	bgRight:setAnchorPoint(cc.p(0, 0.5))
	bgRight:setTouchEnabled(true)
    bgRight:setTouchSwallowEnabled(true)


    local bgLeftSize = bgLeft:getContentSize()
    local bg2 = display.newSprite("newerguide/newer_bg2.png")
    :addTo(self)
    bg2:setAnchorPoint(cc.p(0, 0.5))
    bg2:pos(-bgLeftSize.width + 15,0)

    local girlPosX,girlPosY = -bgLeftSize.width + 5,-bgLeftSize.height *0.5
    self.girl_ = display.newSprite("newerguide/newer_girl.png")
    :addTo(self)
    self.girl_:setAnchorPoint(cc.p(0, 0))
    self.girl_:pos(girlPosX,girlPosY)
    :hide()


    local bagIconPosX,bagIconPosY = -bgLeftSize.width + 5,0
    self.bagIcon_ = display.newSprite("newerguide/newer_bag_icon.png")
    :addTo(self)
    self.bagIcon_:setAnchorPoint(cc.p(0, 0.5))
    self.bagIcon_:pos(bagIconPosX,bagIconPosY)
    :hide()

    local girlSize = self.girl_:getContentSize()
    local titlePosX,titlePosY = girlPosX + girlSize.width,80
    local title = display.newSprite("newerguide/newer_tip_title.png")
    :addTo(self)
    title:setAnchorPoint(cc.p(0, 0.5))
    title:pos(titlePosX,titlePosY)

    local titleSize = title:getContentSize()
    local tipLabelPosX,tipLabelPosY = titlePosX,titlePosY - titleSize.height * 0.5
    local tipLabelSize = {width = 373,height = 125}

    self.tipLabel_ = display.newTTFLabel({text = "", size = 24, color = cc.c3b(0x8e, 0x0a, 0xae),dimensions = cc.size(tipLabelSize.width, tipLabelSize.height), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    self.tipLabel_:setAnchorPoint(cc.p(0, 1.0))
    self.tipLabel_:pos(tipLabelPosX,tipLabelPosY)

    local exitLabelPosX,exitLabelPosY = tipLabelPosX + tipLabelSize.width,tipLabelPosY - tipLabelSize.height
    local exitLabel = display.newTTFLabel({text = bm.LangUtil.getText("NEWER", "GUIDE_EXIT_TIP"), size = 24, color = cc.c3b(0x8e, 0x0a, 0xae), align = ui.TEXT_ALIGN_RIGHT})
    :addTo(self)
    exitLabel:setAnchorPoint(cc.p(1.0, 1.0))
    exitLabel:pos(exitLabelPosX,exitLabelPosY)
end


function NewerGuidePopup:addCloseBtn()
    if not self.closeBtn_ then
        self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_close_btn_up.png", pressed="#panel_close_btn_down.png"})
            :pos(WIDTH * 0.5 - 15, HEIGHT * 0.5 - 22)
            :onButtonClicked(function() 
                    self:onClose()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                end)
            :addTo(self, 99)
    end
end



function NewerGuidePopup:show(data)
    self.showData_ = data
    self.tipLabel_:setString((data and data.content or ""))
    if data and data.iconFlag == 2 then
        self.bagIcon_:show()
        self.girl_:hide()
    else
        self.bagIcon_:hide()
        self.girl_:show()
    end
    self:showPanel_()
end


function NewerGuidePopup:onShowed()
    if self.showData_ and self.showData_.isAnim and self.showData_.addMoney then
        self:playRewardAnim(self.showData_.addMoney)
    end
end


function NewerGuidePopup:showPanel_(isModal, isCentered, closeWhenTouchModel, useShowAnimation)
    nk.PopupManager:addPopup(self, isModal ~= false, isCentered ~= false, closeWhenTouchModel ~= false, useShowAnimation ~= false)
    return self
end

function NewerGuidePopup:hidePanel_()
    nk.PopupManager:removePopup(self)
    return self
end

function NewerGuidePopup:onClose()
    self:hidePanel_()
end

function NewerGuidePopup:onRemovePopup(removePopupFunc)
    if self.showData_ and self.showData_.onClose then
        self.showData_.onClose()
    end
    removePopupFunc()
end

function NewerGuidePopup:destoryAnim()
        if self.animation_ then
            self.animation_:removeFromParent()
            self.animation_ = nil
        end

        -- if self.changeChipAnim_ then
        --     self.changeChipAnim_:removeFromParent()
        --     self.changeChipAnim_ = nil
        -- end
end


function NewerGuidePopup:playRewardAnim(addMoney)
    if checkint(addMoney) == 0 then
        return
    end
    
    --保证第二次打开不播动画
    self:performWithDelay(function ()
                -- nk.userData["aUser.money"] = nk.userData["aUser.money"] + addMoney
                self:destoryAnim()
            end, 1.8)    
    self.animation_ = CommonRewardChipAnimation.new()
        :addTo(self)
    -- self.changeChipAnim_ = nk.ui.ChangeChipAnim.new(checkint(addMoney))
    --     :addTo(self)   
end



return NewerGuidePopup