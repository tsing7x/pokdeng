--
-- Author: johnny@boomegg.com
-- Date: 2014-07-31 16:47:47
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--[[
    用法：
    1. 纯文本：nk.CommonTipManager:showTopTip("我就是我，不一样的烟火")
    2. 文本加图标：nk.CommonTipManager:showTopTip({text = "我就是我，不一样的花朵", image = display.newSprite("top_tip_icon.png")})
]]
local CommonSignalIndicator = import("app.module.common.views.CommonSignalIndicator")

local CommonTipManager = class("CommonTipManager")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local DEFAULT_STAY_TIME = 3
local X_GAP = 100
local Y_GAP = 0
local TIP_HEIGHT = 72
local LABEL_X_GAP = 16
local ICON_SIZE = 56
local LABEL_ROLL_VELOCITY = 80
local BG_CONTENT_SIZE = cc.size(display.width - X_GAP * 2, TIP_HEIGHT)
local Z_ORDER = 1001

function CommonTipManager:ctor()
    -- 视图容器
    self.container_ = display.newNode()
    self.container_:retain()
    self.container_:setNodeEventEnabled(true)
    self.container_.onCleanup = handler(self, function (obj)
       
        if self.commonSignalIndicator_ then
            self.commonSignalIndicator_:removeFromParent()
            self.commonSignalIndicator_ = nil
        end
    end)

end


function CommonTipManager:playReconnectingAnim(isconnecting,str)
    str = str or ""
    if isconnecting then
        if not self.container_:getParent() then
            self.container_:pos(display.cx, display.cy):addTo(nk.runningScene, Z_ORDER)
        end

        if not self.commonSignalIndicator_ then
            self.commonSignalIndicator_  = CommonSignalIndicator.new()
                                           
                                            :addTo(self.container_)
        end
        self.commonSignalIndicator_:showNetWordTips(str)
    else
        if self.commonSignalIndicator_ then
            self.commonSignalIndicator_:removeFromParent()
            self.commonSignalIndicator_ = nil
        end

        if self.container_:getParent() then
            self.container_:removeFromParent()
        end

    end

end


return CommonTipManager