
local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")

local WIDTH = 704
local HEIGHT = 174

local NewerPlayPopup = class("NewerPlayPopup",function()
	return display.newNode()
end)

function NewerPlayPopup:ctor()
	self:createNodes_()
end

function NewerPlayPopup:createNodes_()
	self.background_ = display.newScale9Sprite("newerguide/newer_play_bg.png", 0, 0, cc.size(WIDTH, HEIGHT)):addTo(self)
	-- self.background_ = display.newSprite("newerguide/newer_play_bg.png"):addTo(self)
    self.background_:setTouchEnabled(true)
    self.background_:setTouchSwallowEnabled(true)

    local bgSize = self.background_:getContentSize()
    local bagIconPosX,bagIconPosY = - bgSize.width *0.5,-bgSize.height * 0.5
    local bagIcon = display.newSprite("newerguide/newer_bag_icon.png")
    :addTo(self)
    :align(display.LEFT_BOTTOM,bagIconPosX,bagIconPosY)


    local bagIconSize = bagIcon:getContentSize()
    local titleLabelPosX,titleLabelPosY = bagIconPosX + bagIconSize.width + 30,bgSize.height * 0.5 - 20
    local titleLabel = display.newTTFLabel({text = bm.LangUtil.getText("NEWER", "PLAY_TITLE"), size = 26, color = cc.c3b(0xff, 0xd3, 0x34), align = ui.TEXT_ALIGN_RIGHT})
    :addTo(self)
    :align(display.LEFT_TOP,titleLabelPosX,titleLabelPosY)

    local titleLabelSize = titleLabel:getContentSize()
    local contentLabelPosX,contentLabelPosY = titleLabelPosX,titleLabelPosY - titleLabelSize.height
    local contentLabelSize = {width = 405,height = 78}
    self.contentLabel_  = display.newTTFLabel({text = bm.LangUtil.getText("NEWER", "PLAY_REWARD_CONTENT",5000), size = 24, color = cc.c3b(0xb3, 0xc0, 0xd0),dimensions = cc.size(contentLabelSize.width, contentLabelSize.height), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self)
    :align(display.LEFT_TOP,contentLabelPosX,contentLabelPosY)

    local exitLabelPosX,exitLabelPosY = contentLabelPosX + contentLabelSize.width,contentLabelPosY - contentLabelSize.height
    local exitLabel = display.newTTFLabel({text = bm.LangUtil.getText("NEWER", "PLAY_EXIT_TIP"), size = 24, color = cc.c3b(0xb3, 0xc0, 0xd0), align = ui.TEXT_ALIGN_RIGHT})
    :addTo(self)
    :align(display.RIGHT_TOP,exitLabelPosX,exitLabelPosY)
end

function NewerPlayPopup:show(data)
    self.showData_ = data
    self:showPanel_()

    if self.showData_ and self.showData_.addMoney then
        local str;
        local contentFlag = self.showData_.contentFlag
        if (not contentFlag or contentFlag == 1) then
            str = bm.LangUtil.getText("NEWER", "PLAY_REWARD_CONTENT_1",checkint(self.showData_.addMoney))

        elseif contentFlag == 2 then
            str = bm.LangUtil.getText("NEWER", "PLAY_REWARD_CONTENT_2",checkint(self.showData_.addMoney),checkint(self.showData_.nextAddMoney))

        end
        self.contentLabel_:setString(str)
    end

end


function NewerPlayPopup:onShowed()
    if self.showData_ and self.showData_.isAnim and self.showData_.addMoney then
        self:playRewardAnim(self.showData_.addMoney)
    end

    self:performWithDelay(function ()
       self:hidePanel_()
    end, 4.5)   
end


function NewerPlayPopup:showPanel_(isModal, isCentered, closeWhenTouchModel, useShowAnimation)
    nk.PopupManager:addPopup(self, isModal ~= false, isCentered ~= false, closeWhenTouchModel ~= false, useShowAnimation ~= false)
    return self
end

function NewerPlayPopup:hidePanel_()
    nk.PopupManager:removePopup(self)
    return self
end

function NewerPlayPopup:onClose()
    self:hidePanel_()
end


function NewerPlayPopup:destoryAnim()
        if self.animation_ then
            self.animation_:removeFromParent()
            self.animation_ = nil
        end

        if self.changeChipAnim_ then
            self.changeChipAnim_:removeFromParent()
            self.changeChipAnim_ = nil
        end
end


function NewerPlayPopup:playRewardAnim(addMoney)
    if checkint(addMoney) == 0 then
        return
    end
    --保证第二次打开不播动画
    self:performWithDelay(function ()
                nk.userData["aUser.money"] = nk.userData["aUser.money"] + addMoney
                self:destoryAnim()
            end, 1.8)    
    self.animation_ = CommonRewardChipAnimation.new()
        :addTo(self)
    self.changeChipAnim_ = nk.ui.ChangeChipAnim.new(checkint(addMoney))
        :addTo(self)   
end


return NewerPlayPopup