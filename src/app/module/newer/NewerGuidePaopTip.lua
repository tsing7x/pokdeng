--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-08-29 16:39:12
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: NewerGuidePaopTip by TsingZhang.
--

local NewerGuidePaopTip = class("NewerGuidePaopTip", function()
	-- body
	return display.newNode()
end)

-- STANDARD POS --
NewerGuidePaopTip.LEFT_CENTER = 1; NewerGuidePaopTip.CENTER_LEFT = 1  -- 居左中
NewerGuidePaopTip.BOTTOM_CENTER = 2; NewerGuidePaopTip.CENTER_BOTTOM = 2  -- 居底中
NewerGuidePaopTip.RIGHT_CENTER = 3; NewerGuidePaopTip.CENTER_RIGHT = 3  -- 居右中
NewerGuidePaopTip.TOP_CENTER = 4; NewerGuidePaopTip.CENTER_TOP = 4  -- 居顶中

-- ARROW POS DIRECTION --
NewerGuidePaopTip.DIRECTION_TOP = 1  -- 方位顶部
NewerGuidePaopTip.DIRECTION_BOTTOM = 2  -- 方位底部
NewerGuidePaopTip.DIRECTION_LEFT = 3  -- 方位左部
NewerGuidePaopTip.DIRECTION_RIGHT = 4  -- 方位右部

-- ARROW MAGRIN TOWARD --
NewerGuidePaopTip.TOWARD_UP = 1  -- 朝向上
NewerGuidePaopTip.TOWARD_DOWN = 2  -- 朝向下
NewerGuidePaopTip.TOWARD_LEFT = 3  -- 朝向左
NewerGuidePaopTip.TOWARD_RIGHT = 4  -- 朝向右

-- 内部参数 --
local ARROW_DIRECTION_HORIZONTAL = 1
local ARROW_DIRECTION_VERTIACL = 2

-- @param tipsLabel: tips文本标签, Needed!; arrowAlign: 箭头指示对齐方式, arrowAlign
-- 可能出现的参数 1. type(arrowAlign) == "number" [STANDARD POS] <详见参数 STANDARD POS>

-- 2.type(arrowAlign) == "table" 要求数据格式:
-- 	{direction: [ARROW POS DIRECTION] <详见参数 ARROW POS DIRECTION>,
-- 		toward: [ARROW MAGRIN TOWARD] <详见参数 ARROW MAGRIN TOWARD>,
-- 		magrin: type(magrin) == "number", 箭头固定边距距离.
-- 	}

-- magrins 文字距离边框边缘的边距,可能出现的参数 1.type(magrins) == "number" 统一设置内部距离上下左右的边距,
-- 2.type(magrins) == "table", 数据格式:
-- {left: type(left) == "number", 左边距;
-- 	right: type(right) == "number", 右边距;
-- 	top: type(top) == "number", 上边距;
-- 	bottom: type(bottom) == "number", 下边距.
-- }
function NewerGuidePaopTip:ctor(tipsLabel, arrowAlign, magrins)
	-- body
	local tipsLabelNil = display.newTTFLabel({text = "tips", size = 28, align = ui.TEXT_ALIGN_CENTER})

	self.tipsLabel_ = tipsLabel or tipsLabelNil
	self:buildView(arrowAlign, magrins)
end

function NewerGuidePaopTip:buildView(align, magrins)
	-- body
	-- self.tipsLabel_ = display.newTTFLabel({text = self.text_, size = 28, align = ui.TEXT_ALIGN_CENTER})

	local tipsLabelContSize = self.tipsLabel_:getContentSize()

	local borderSize = {
		width = 0,
		height = 0
	}
	if type(magrins) == "number" then
		--todo
		borderSize.width = tipsLabelContSize.width + magrins * 2
		borderSize.height = tipsLabelContSize.height + magrins * 2

	elseif type(magrins) == "table" then
		--todo
		borderSize.width = tipsLabelContSize.width + (magrins.left or 0) + (magrins.right or 0)
		borderSize.height = tipsLabelContSize.height + (magrins.top or 0) + (magrins.bottom or 0)

		self.tipsLabel_:pos((magrins.left - magrins.right) / 2, (magrins.bottom - magrins.top) / 2)
	else
		dump("Wrong type magrins！")
	end

	-- ngtip_bordMain.png
	self.borderMain_ = display.newScale9Sprite("#ngtip_bordMain.png", 0, 0,
		cc.size(borderSize.width, borderSize.height))
		:addTo(self)

	self.tipsLabel_:addTo(self)

	self.tipsArrow_ = display.newSprite("#ngtip_arrowDown.png")

	local tipsArrowSize = self.tipsArrow_:getContentSize()
	local tipsArrowPosFix = 1.8

	self.arrowDirection_ = 0  -- 默认无意义的箭头指示值

	if type(align) == "number" then
		--todo
		local adjArrowPos = {
			[NewerGuidePaopTip.LEFT_CENTER] = function()
				-- body
				self.tipsArrow_:rotation(90)
				self.tipsArrow_:pos(- borderSize.width / 2 - tipsArrowSize.height / 2 + tipsArrowPosFix, 0)
					:addTo(self)

				self.arrowDirection_ = ARROW_DIRECTION_HORIZONTAL
			end,

			[NewerGuidePaopTip.BOTTOM_CENTER] = function()
				-- body
				-- self.tipsArrow_:rotation(90)
				self.tipsArrow_:pos(0, - borderSize.height / 2 - tipsArrowSize.height / 2 + tipsArrowPosFix)
					:addTo(self)

				self.arrowDirection_ = ARROW_DIRECTION_VERTIACL
			end,

			[NewerGuidePaopTip.RIGHT_CENTER] = function()
				-- body
				self.tipsArrow_:rotation(270)
				self.tipsArrow_:pos(borderSize.width / 2 + tipsArrowSize.height / 2 - tipsArrowPosFix, 0)
					:addTo(self)

				self.arrowDirection_ = ARROW_DIRECTION_HORIZONTAL
			end,

			[NewerGuidePaopTip.TOP_CENTER] = function()
				-- body
				self.tipsArrow_:flipY(true)
				self.tipsArrow_:pos(0, borderSize.height / 2 + tipsArrowSize.height / 2 - tipsArrowPosFix)
					:addTo(self)

				self.arrowDirection_ = ARROW_DIRECTION_VERTIACL
			end
		}

		if adjArrowPos[align] then
			--todo
			adjArrowPos[align]()
		end

	elseif type(align) == "table" then
		--todo
		local setArrowPos = {
			[NewerGuidePaopTip.DIRECTION_TOP] = function(toward, magrin)
				-- body
				-- toward == NewerGuidePaopTip.TOWARD_LEFT or toward == NewerGuidePaopTip.TOWARD_RIGHT
				self.tipsArrow_:flipY(true)

				if toward == NewerGuidePaopTip.TOWARD_LEFT then
					--todo
					self.tipsArrow_:pos(- (borderSize.width / 2 - magrin - tipsArrowSize.width / 2), borderSize.height / 2 +
						tipsArrowSize.height / 2 - tipsArrowPosFix)
						:addTo(self)
				elseif toward == NewerGuidePaopTip.TOWARD_RIGHT then
					--todo
					self.tipsArrow_:pos(borderSize.width / 2 - magrin - tipsArrowSize.width / 2, borderSize.height / 2 +
						tipsArrowSize.height / 2 - tipsArrowPosFix)
						:addTo(self)
				else
					dump("Wrong toward Value！")
				end

				self.arrowDirection_ = ARROW_DIRECTION_VERTIACL
			end,

			[NewerGuidePaopTip.DIRECTION_BOTTOM] = function(toward, magrin)
				-- body
				-- toward == NewerGuidePaopTip.TOWARD_LEFT or toward == NewerGuidePaopTip.TOWARD_RIGHT

				if toward == NewerGuidePaopTip.TOWARD_LEFT then
					--todo
					self.tipsArrow_:pos(- (borderSize.width / 2 - magrin - tipsArrowSize.width / 2), - borderSize.height / 2 -
						tipsArrowSize.height / 2 + tipsArrowPosFix)
						:addTo(self)
				elseif toward == NewerGuidePaopTip.TOWARD_RIGHT then
					--todo
					self.tipsArrow_:pos(borderSize.width / 2 - magrin - tipsArrowSize.width / 2, - borderSize.height / 2 -
						tipsArrowSize.height / 2 + tipsArrowPosFix)
						:addTo(self)
				else
					dump("Wrong toward Value！")
				end

				self.arrowDirection_ = ARROW_DIRECTION_VERTIACL
			end,

			[NewerGuidePaopTip.DIRECTION_LEFT] = function(toward, magrin)
				-- body
				-- toward == NewerGuidePaopTip.TOWARD_UP or toward == NewerGuidePaopTip.TOWARD_DOWN

				self.tipsArrow_:rotation(90)

				if toward == NewerGuidePaopTip.TOWARD_UP then
					--todo
					self.tipsArrow_:pos(- borderSize.width / 2 - tipsArrowSize.height / 2 + tipsArrowPosFix,
						borderSize.height / 2 -	magrin - tipsArrowSize.width / 2)
						:addTo(self)
				elseif toward == NewerGuidePaopTip.TOWARD_DOWN then
					--todo
					self.tipsArrow_:pos(- borderSize.width / 2 - tipsArrowSize.height / 2 + tipsArrowPosFix,
						- (borderSize.height / 2 - magrin - tipsArrowSize.width / 2))
						:addTo(self)
				else
					dump("Wrong toward Value！")
				end

				self.arrowDirection_ = ARROW_DIRECTION_HORIZONTAL
			end,

			[NewerGuidePaopTip.DIRECTION_RIGHT] = function(toward, magrin)
				-- body
				-- toward == NewerGuidePaopTip.TOWARD_UP or toward == NewerGuidePaopTip.TOWARD_DOWN

				self.tipsArrow_:rotation(270)

				if toward == NewerGuidePaopTip.TOWARD_UP then
					--todo
					self.tipsArrow_:pos(borderSize.width / 2 + tipsArrowSize.height / 2 - tipsArrowPosFix,
						borderSize.height / 2 -	magrin - tipsArrowSize.width / 2)
						:addTo(self)
				elseif toward == NewerGuidePaopTip.TOWARD_DOWN then
					--todo
					self.tipsArrow_:pos(borderSize.width / 2 + tipsArrowSize.height / 2 - tipsArrowPosFix,
						- (borderSize.height / 2 - magrin - tipsArrowSize.width / 2))
						:addTo(self)
				else
					dump("Wrong toward Value！")
				end

				self.arrowDirection_ = ARROW_DIRECTION_HORIZONTAL
			end
		}

		if align.direction and setArrowPos[align.direction] then
			--todo
			setArrowPos[align.direction](align.toward or 0, align.magrin or 0)
		end

	else
		dump("Wrong Type align！")
	end

end

function NewerGuidePaopTip:setTipsFontSize(size)
	-- body
	self.tipsLabel_:setSystemFontSize(size or 28)

	return self
end

function NewerGuidePaopTip:setTipsColor(ccc3Color)
	-- body
	self.tipsLabel_:setTextColor(ccc3Color or display.COLOR_WHITE)

	return self
end

function NewerGuidePaopTip:setPaopTipOpacity(opacity)
	-- body
	self.tipsLabel_:opacity(opacity)
	self.borderMain_:opacity(opacity)
	self.tipsArrow_:opacity(opacity)
	return self
end

function NewerGuidePaopTip:getPaopTipSize()
	-- body
	local size = {}

	local tipsArrowPosFix = 1.8
	if self.arrowDirection_ == ARROW_DIRECTION_HORIZONTAL then
		--todo
		size.width = self.borderMain_:getContentSize().width + self.tipsArrow_:getContentSize().height - tipsArrowPosFix
		size.height = self.borderMain_:getContentSize().height

	elseif self.arrowDirection_ == ARROW_DIRECTION_VERTIACL then
		--todo
		size.width = self.borderMain_:getContentSize().width
		size.height = self.borderMain_:getContentSize().height + self.tipsArrow_:getContentSize().height - tipsArrowPosFix
	
	else
		size.width = 0
		size.height = 0
	end

	return size
end

function NewerGuidePaopTip:getPaopTipLabelString()
	-- body
	return self.tipsLabel_:getString() or "nil"
end

function NewerGuidePaopTip:playFadeInAnim(time, delay, opacity)
	-- body
	-- self.tipsLabel_:opacity(0)
	-- self.borderMain_:opacity(0)
	-- self.tipsArrow_:opacity(0)

	transition.fadeIn(self.tipsLabel_, {time = time, delay = delay, opacity = opacity})
	transition.fadeIn(self.borderMain_, {time = time, delay = delay, opacity = opacity})
	transition.fadeIn(self.tipsArrow_, {time = time, delay = delay, opacity = opacity})
	return self
end

-- 若需要修改本类内部元素或属性,请在这里添加接口;待完善...

return NewerGuidePaopTip