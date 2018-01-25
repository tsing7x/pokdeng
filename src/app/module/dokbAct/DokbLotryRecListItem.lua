--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-30 15:39:45
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: DokbLotryRecListItem.lua By TsingZhang.
--

local recListItemParam = {
	WIDTH = 864,
	HEIGHT = 38
}

local DokbLotryRecListItem = class("DokbLotryRecListItem", bm.ui.ListItem)

function DokbLotryRecListItem:ctor()
	-- body
	self:setNodeEventEnabled(true)
	self.super.ctor(self, recListItemParam.WIDTH, recListItemParam.HEIGHT)

	local itemInfoLblParam = {
		frontSizes = {
			gemName = 18,
			lotryCode = 20,
			awarderName = 18,
			myCode = 20
		},
		colors = {
			gemName = display.COLOR_WHITE,
			lotryCode = cc.c3b(163, 248, 101),
			awarderName = display.COLOR_WHITE,
			myCode = display.COLOR_WHITE
		}
	}

	self.gemName_ = display.newTTFLabel({text = "gem Name", size = itemInfoLblParam.frontSizes.gemName, color = itemInfoLblParam.colors.gemName, align = ui.TEXT_ALIGN_CENTER})
		:pos(recListItemParam.WIDTH / 10, recListItemParam.HEIGHT / 2)
		:addTo(self)

	self.lotryCode_ = display.newTTFLabel({text = "lotry Code", size = itemInfoLblParam.frontSizes.lotryCode, color = itemInfoLblParam.colors.lotryCode, align = ui.TEXT_ALIGN_CENTER})
		:pos(recListItemParam.WIDTH * 3 / 10, recListItemParam.HEIGHT / 2)
		:addTo(self)

	self.awarderName_ = display.newTTFLabel({text = "awarder Name", size = itemInfoLblParam.frontSizes.awarderName, color = itemInfoLblParam.colors.awarderName, align = ui.TEXT_ALIGN_CENTER})
		:pos(recListItemParam.WIDTH * 5 / 10, recListItemParam.HEIGHT / 2)
		:addTo(self)

	self.myCodes_ = {}
	local codeWidth = {}

	for i = 1, 3 do
		if i == 3 then
			--todo
			self.myCodes_[i] = display.newTTFLabel({text = "My Code" .. i, size = itemInfoLblParam.frontSizes.myCode, color = itemInfoLblParam.colors.myCode, align = ui.TEXT_ALIGN_CENTER})
		else
			self.myCodes_[i] = display.newTTFLabel({text = "My Code" .. i .. ";", size = itemInfoLblParam.frontSizes.myCode, color = itemInfoLblParam.colors.myCode, align = ui.TEXT_ALIGN_CENTER})
		end
		
		codeWidth[i] = self.myCodes_[i]:getContentSize().width
	end

	local myCodesPosXShf = {
		- (codeWidth[1] + codeWidth[2]) / 2,
		0,
		(codeWidth[2] + codeWidth[3]) / 2
	}

	for i = 1, #self.myCodes_ do
		self.myCodes_[i]:pos(recListItemParam.WIDTH * 4 / 5 + myCodesPosXShf[i], recListItemParam.HEIGHT / 2)
			:addTo(self)
	end

	-- self.getMoreCodeInfoBtn_ = cc.ui.UIPushButton.new({normal = "", pressed = "", disabled = ""}, {scale9 = false})
	-- 	:onButtonClicked(handler(self, self.onGetMoreCodeInfoCallBack_))
	-- 	:pos()
	-- 	:addTo(self)

	local divdLineHeight = 2
	self.divdItemLine_ = display.newScale9Sprite("#dokb_divLine_recItem.png", recListItemParam.WIDTH / 2, 0, cc.size(recListItemParam.WIDTH, divdLineHeight))
		:addTo(self)
	-- self.myCode1_ = display.newTTFLabel({text = "My Code1;", size = itemInfoLblParam.frontSizes.myCode, color = itemInfoLblParam.colors.myCode, align = ui.TEXT_ALIGN_CENTER})

	-- self.myCode2_ = display.newTTFLabel({text = "My Code2;", size = itemInfoLblParam.frontSizes.myCode, color = itemInfoLblParam.colors.myCode, align = ui.TEXT_ALIGN_CENTER})

	-- self.myCode1_ = display.newTTFLabel({text = "My Code3", size = itemInfoLblParam.frontSizes.myCode, color = itemInfoLblParam.colors.myCode, align = ui.TEXT_ALIGN_CENTER})

	-- local code1Width, code2Width, code3Width = self.myCode1_:getContentSize().width, self.myCode2_:getContentSize().width, self.myCode3_:getContentSize().width
end

function DokbLotryRecListItem:onGetMoreCodeInfoCallBack_(evt)
	-- body
end

function DokbLotryRecListItem:onDataSet(isChanged, data)
	-- body
	if isChanged then
		--todo

		-- 着重调整 自己的三个Code的坐标，每次数据来都调整，避免出现逻辑错误。每次都根据数据多少进行显隐操作
		-- 一个编号，使用Code1，隐藏Code2、Code3， 两个编号 使用Code1、Code2，隐藏Code3
		-- 注意UI，如果所选编号中奖，则只改变编号颜色。
		self.gemData_ = data
		self.gemId_ = data.id

		self.gemName_:setString(data.props or "Gem Name.")
		self.lotryCode_:setString(data.treatureCode or bm.LangUtil.getText("DOKB", "LOTRYREC_NOTOPEN"))
		self.awarderName_:setString(data.username or bm.LangUtil.getText("DOKB", "LOTRYREC_NOTOPEN"))
		-- just for test --
		-- data.mycode = {
		-- 	"BJ21545",
		-- 	"KK24536",
		-- 	"AK15255"
		-- }
		-- end --

		if data.mycode and #data.mycode > 0 then
			--todo
			for i = 1, #self.myCodes_ do
				self.myCodes_[i]:setString("")
				self.myCodes_[i]:setTextColor(display.COLOR_WHITE)
			end

			for i = 1, #data.mycode do

				if self.myCodes_[i] then
					--todo
					if i == #data.mycode then
						--todo
						self.myCodes_[i]:setString(data.mycode[i] or "")
					else
						self.myCodes_[i]:setString((data.mycode[i] or "") .. ";")
					end

					if data.treatureCode == data.mycode[i] then
						--todo
						self.myCodes_[i]:setTextColor(cc.c3b(205, 97, 99))
					end
				end
			end

			self:adjMyCodesLblPos(#data.mycode)
		else
			for i = 1, #self.myCodes_ do
				self.myCodes_[i]:setString("")
				self.myCodes_[i]:setTextColor(display.COLOR_WHITE)
			end

			self.myCodes_[1]:setString(bm.LangUtil.getText("DOKB", "LOTRYREC_NOTATTENED"))
			self:adjMyCodesLblPos(1)
		end
	end
end

function DokbLotryRecListItem:adjMyCodesLblPos(codeNum)
	-- body
	local adjMyCodesLblPosByCodeNum = {
			[1] = function()
				-- body
				self.myCodes_[1]:pos(recListItemParam.WIDTH * 4 / 5, recListItemParam.HEIGHT / 2)
			end,

			[2] = function()
				-- body
				local codeWidth1 = self.myCodes_[1]:getContentSize().width
				local codeWidth2 = self.myCodes_[2]:getContentSize().width

				self.myCodes_[1]:pos(recListItemParam.WIDTH * 4 / 5 - codeWidth1 / 2, recListItemParam.HEIGHT / 2)
				self.myCodes_[2]:pos(recListItemParam.WIDTH * 4 / 5 + codeWidth2 / 2, recListItemParam.HEIGHT / 2)
			end,

			[3] = function()
				-- body
				local codeWidth = {}
				for i = 1, #self.myCodes_ do
					codeWidth[i] = self.myCodes_[i]:getContentSize().width
				end

				local myCodesPosXShf = {
					- (codeWidth[1] + codeWidth[2]) / 2,
					0,
					(codeWidth[2] + codeWidth[3]) / 2
				}

				for i = 1, #self.myCodes_ do
					self.myCodes_[i]:pos(recListItemParam.WIDTH * 4 / 5 + myCodesPosXShf[i], recListItemParam.HEIGHT / 2)
				end
			end
		}

	if adjMyCodesLblPosByCodeNum[codeNum] then
		--todo
		adjMyCodesLblPosByCodeNum[codeNum]()
	end
	
end

function DokbLotryRecListItem:onEnter()
	-- body
end

function DokbLotryRecListItem:onExit()
	-- body
end

function DokbLotryRecListItem:onCleanup()
	-- body
end

return DokbLotryRecListItem