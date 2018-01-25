--
-- Author: TsingZhang@boyaa.com
-- Date: 2016-05-11 16:44:17
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: ChooseProRoomListItem.lua By TsingZhang, Compatiable For GrabRoomChoose && CashRoomChoose.
--

local ChooseProRoomListItem = class("ChooseProRoomListItem", bm.ui.ListItem)

local ProRoomItemParam = {
	HEIGHT = 90,
	PADDING_EACH_SIDE = 20,
	BUTTON_WIDTH = 164
}

function ChooseProRoomListItem:ctor()
	-- body
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self:setNodeEventEnabled(true)

	ChooseProRoomListItem.super.ctor(self, display.width - ProRoomItemParam.PADDING_EACH_SIDE * 2, ProRoomItemParam.HEIGHT)

	self.itemBg_ = nil
	-- local roomChosItemGapVertical = 8
	local itemChildGap = 0

	if self.proRoomType_ == 0 then
		--todo
		-- CashRoomItem.
		-- itemBgTexPath = "#chipChos_bg_itemCashRoom.png"
		-- itemButTexPath.nor = "#chipChos_btnBlue_itemCashRoom_nor.png"
		-- itemButTexPath.pre = "#chipChos_btnBlue_itemCashRoom_pre.png"

		-- self.itemBg_ = display.newSprite("#chipChos_bg_itemCashRoom.png")
		-- 	:pos((display.width - ProRoomItemParam.PADDING_EACH_SIDE * 2 - ProRoomItemParam.BUTTON_WIDTH) / 2 - itemChildGap,
		-- 		ProRoomItemParam.HEIGHT / 2)
		-- 	:addTo(self)
		-- local bgTex = cc.Director:getInstance():getTextureCache():addImage("chipChos_bg_itemCashRoom.png")
		-- local bgTex = display.newSpriteFrame("chipChos_bg_itemCashRoom.png"):getTexture()

		-- local frameLeftHalf = cc.SpriteFrame:createWithTexture(bgTex, cc.rect(0, 0, 380, 103))
		-- local frameRightHalf = cc.SpriteFrame:createWithTexture(bgTex, cc.rect(380, 0, 761, 103))

		-- self.bgItemLeftHalf_ = display.newSprite(frameLeftHalf)
		-- 	:pos(380 / 2, ProRoomItemParam.HEIGHT / 2)
		-- 	:addTo(self)

		-- self.bgItemLeftHalf_:setTextureRect(cc.rect(0, 0, 380, 103))

		self.itemBg_ = display.newScale9Sprite("#chipChos_bg_itemCashRoom.png", (self.width_ - ProRoomItemParam.BUTTON_WIDTH) / 2 - itemChildGap,
			ProRoomItemParam.HEIGHT / 2, cc.size(self.width_ - ProRoomItemParam.BUTTON_WIDTH - itemChildGap, ProRoomItemParam.HEIGHT))
			:addTo(self)

		local decPosFix = {
			x = 6,
			y = 1
		}

		local itemDecor = display.newSprite("#chipChos_dec_itemBgCashRoom.png")
		itemDecor:pos(itemDecor:getContentSize().width / 2 + decPosFix.x, ProRoomItemParam.HEIGHT / 2 + decPosFix.y)
			:addTo(self.itemBg_)

		local btnEntryLabelParam = {
			frontSize = 36,
			color = display.COLOR_WHITE
		}
		self.itemBtnEntry_ = cc.ui.UIPushButton.new({normal = "#chipChos_btnBlue_itemCashRoom_nor.png", pressed = "#chipChos_btnBlue_itemCashRoom_pre.png"}, {scale9 = true})
			:setButtonSize(ProRoomItemParam.BUTTON_WIDTH, ProRoomItemParam.HEIGHT)
			:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_ENTER"), size = btnEntryLabelParam.frontSize, color = btnEntryLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
			:onButtonClicked(buttontHandler(self, self.onEntryRoomCallBack_))
			:pos(self.width_ - ProRoomItemParam.BUTTON_WIDTH / 2, ProRoomItemParam.HEIGHT / 2)
			:addTo(self)
	else
		-- GrabRoomItem.
		-- itemBgTexPath = "#hall_match_list_room_bg.png"
		-- itemButTexPath.nor = "#hall_apply_match_btn_up.png"
		-- itemButTexPath.pre = "#hall_apply_match_btn_down.png"
		self.itemBg_ = display.newScale9Sprite("#hall_match_list_room_bg.png", (self.width_ - ProRoomItemParam.BUTTON_WIDTH) / 2 - itemChildGap,
			ProRoomItemParam.HEIGHT / 2, cc.size(self.width_ - ProRoomItemParam.BUTTON_WIDTH - itemChildGap, ProRoomItemParam.HEIGHT))
			:addTo(self)

		local btnEntryLabelParam = {
			frontSize = 35,
			color = cc.c3b(135, 67, 22)
		}

		self.itemBtnEntry_ = cc.ui.UIPushButton.new({normal = "#hall_apply_match_btn_up.png", pressed = "#hall_apply_match_btn_down.png"}, {scale9 = true})
			:setButtonSize(ProRoomItemParam.BUTTON_WIDTH, ProRoomItemParam.HEIGHT)
			:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("HALL", "PERSONAL_ROOM_ENTER"), size = btnEntryLabelParam.frontSize, color = btnEntryLabelParam.color, align = ui.TEXT_ALIGN_CENTER}))
			:onButtonClicked(buttontHandler(self, self.onEntryRoomCallBack_))
			:pos(self.width_ - ProRoomItemParam.BUTTON_WIDTH / 2, ProRoomItemParam.HEIGHT / 2)
			:addTo(self)
	end

	local roomInfoDisplayAreaSizeWidth = self.width_ - ProRoomItemParam.BUTTON_WIDTH  -- 2 * i - 1

	-- Head Avatar --
	self.avatarBg_ = display.newSprite("#chipChos_bg_avatar.png")
	self.avatarBg_:pos(roomInfoDisplayAreaSizeWidth / 12, ProRoomItemParam.HEIGHT / 2)
		:addTo(self)

	local avatarBgSize = self.avatarBg_:getContentSize()

	local avartarContMagrins = 4
	local avatarDisplaySize = {
		width = avatarBgSize.width - avartarContMagrins * 2,
		height = avatarBgSize.height - avartarContMagrins * 2
	}

	self.avatar_ = display.newSprite("#common_female_avatar.png")
		:pos(avatarBgSize.width / 2, avatarBgSize.height / 2)
		:addTo(self.avatarBg_)

	self.avatar_:scale(avatarDisplaySize.width / self.avatar_:getContentSize().width)

	self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId()
	local sexIconPosFix = {
		x = 12,
		y = 16
	}

	self.sexIcon_ = display.newSprite("#icon_female.png")
		:pos(avatarBgSize.width - sexIconPosFix.x, sexIconPosFix.y)
		:addTo(self.avatarBg_)

	local hintLabelParam = nil
	local infoLabelParam = nil

	if self.proRoomType_ == 0 then
		--todo
		hintLabelParam = {
			frontSize = 25,
			color = cc.c3b(104, 50, 0)
		}

		infoLabelParam = {
			frontSize = 22,
			color = cc.c3b(104, 50, 0)
		}
	else
		hintLabelParam = {
			frontSize = 25,
			color = styles.FONT_COLOR.LIGHT_TEXT
		}

		infoLabelParam = {
			frontSize = 22,
			color = display.COLOR_WHITE
		}
	end

	self.noDealerHint_ = display.newTTFLabel({text = T("空庄"), color = hintLabelParam.color, size = hintLabelParam.frontSize, align = ui.TEXT_ALIGN_CENTER})
		:pos(self.avatarBg_:getPositionX(), self.avatarBg_:getPositionY())
		:addTo(self)
		:hide()

	-- Main Info --
	-- local infoLabelParam = {
	-- 	frontSize = 22,
	-- 	color = display.COLOR_WHITE
	-- }
	self.moneyPosses_ = display.newTTFLabel({text = "0", size = infoLabelParam.frontSize, color = infoLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(roomInfoDisplayAreaSizeWidth / 12 * 3, ProRoomItemParam.HEIGHT / 2)
		:addTo(self)

	local iconMagrinLbl = 5
	local currencyIcon = nil
	local currencyIconPosXShift = 40

	if self.proRoomType_ == 0 then
		--todo
		currencyIcon = display.newSprite("#hall_small_cash_icon.png")
			:pos(roomInfoDisplayAreaSizeWidth / 12 * 5 - currencyIconPosXShift, ProRoomItemParam.HEIGHT / 2)
			:addTo(self)
	else
		currencyIcon = display.newSprite("#hall_small_chip_icon.png")
			:pos(roomInfoDisplayAreaSizeWidth / 12 * 5 - currencyIconPosXShift, ProRoomItemParam.HEIGHT / 2)
			:addTo(self)
	end

	self.anteMoney_ = display.newTTFLabel({text = "0", size = infoLabelParam.frontSize, color = infoLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
	self.anteMoney_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
	self.anteMoney_:pos(currencyIcon:getPositionX() + currencyIcon:getContentSize().width / 2 + iconMagrinLbl, currencyIcon:getPositionY())
		:addTo(self)
	-- local antGroupShownWidth = self.currencyIcon_:getContentSize().width + iconMagrinLbl + self.anteMoney_:getContentSize().width

	-- self.currencyIcon_:setPositionX(roomInfoDisplayAreaSizeWidth / 12 * 5 - (antGroupShownWidth - self.currencyIcon_:getContentSize().width) / 2)
	-- self.anteMoney_:pos(roomInfoDisplayAreaSizeWidth / 12 * 5 + (antGroupShownWidth - self.anteMoney_:getContentSize().width) / 2, ProRoomItemParam.HEIGHT / 2)
	-- 	:addTo(self)

	self.minMoneyToEntry_ = display.newTTFLabel({text = "0", size = infoLabelParam.frontSize, color = infoLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(roomInfoDisplayAreaSizeWidth / 12 * 7, ProRoomItemParam.HEIGHT / 2)
		:addTo(self)

	self.entryThre_ = display.newTTFLabel({text = "0", size = infoLabelParam.frontSize, color = infoLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
		:pos(roomInfoDisplayAreaSizeWidth / 12 * 9, ProRoomItemParam.HEIGHT / 2)
		:addTo(self)

	local onLineProgressUIParam = {
		width = 124,
		height = 32,
		magrinHeight = 4,
		fillWidthInit = 16
	}

	-- local progressBgHeight = 32
	-- local progressHeightMagrin = 2

	self.onlineProgress_ = nk.ui.ProgressBar.new("#chipChos_bgPrgb_onLine.png", "#chipChos_rectPrgb_onLine.png", 
        {bgWidth = onLineProgressUIParam.width, bgHeight = onLineProgressUIParam.height, fillWidth = onLineProgressUIParam.fillWidthInit,
        	fillHeight = onLineProgressUIParam.height - onLineProgressUIParam.magrinHeight})
		:pos(roomInfoDisplayAreaSizeWidth / 12 * 11 - onLineProgressUIParam.width / 2, ProRoomItemParam.HEIGHT / 2)
		:addTo(self)
		:setValue(0.5)

	local onLineNumTTFColor = display.COLOR_WHITE
	self.onLineNum_ = display.newTTFLabel({text = "0/0", size = infoLabelParam.frontSize, color = onLineNumTTFColor, align = ui.TEXT_ALIGN_CENTER})
		:pos(onLineProgressUIParam.width / 2, 0)
		:addTo(self.onlineProgress_)
end

function ChooseProRoomListItem:onDataSet(isChanged, data)
	-- body
	-- dump(data, "ChooseProRoomListItem:onDataSet.data :==========================")
	if isChanged then
		--todo
		-- local ante = bm.formatBigNumber(data.ante)
		self.moneyPosses_:setString(bm.formatBigNumber(data.ante or 0))  -- 上庄资产
		self.anteMoney_:setString(bm.formatBigNumber(data.basechip or 0))  -- 底注

		-- 调整底注和Currency Icon坐标
		-- local roomInfoDisplayAreaSizeWidth = self.width_ - ProRoomItemParam.BUTTON_WIDTH
		-- local iconMagrinLbl = 5
		-- local antGroupShownWidth = self.currencyIcon_:getContentSize().width + iconMagrinLbl + self.anteMoney_:getContentSize().width

		-- self.currencyIcon_:setPositionX(roomInfoDisplayAreaSizeWidth / 12 * 5 - (antGroupShownWidth - self.currencyIcon_:getContentSize().width) / 2)
		-- self.anteMoney_:setPositionX(roomInfoDisplayAreaSizeWidth / 12 * 5 + (antGroupShownWidth - self.anteMoney_:getContentSize().width) / 2)

		self.minMoneyToEntry_:setString(bm.formatBigNumber(data.minante or 0)) -- min上庄值

		self.entryThre_:setString(bm.formatBigNumber(data.door or 0))  -- 上庄门槛

		self.onlineProgress_:setValue((data.userCount or 0) / (data.seatcout or 10))  -- 在线人数ProgressBar
		self.onLineNum_:setString(tostring(data.userCount or 0) .. "/" .. (data.seatcout or 10))

		-- data.userinfo = ""
		if not data.userinfo or string.len(data.userinfo) < 5 then
			--todo
			self.avatarBg_:hide()
			-- self.avatar_:hide()
			-- self.sexIcon_:hide()
			self.noDealerHint_:show()
		else
			local userinfoData = json.decode(data.userinfo)
			if userinfoData then
				--todo
				self.avatarBg_:show()
				self.avatar_:show()
				self.sexIcon_:show()

				local imgUrl = userinfoData.mavatar
				if string.find(imgUrl, "facebook") then
	                if string.find(imgUrl, "?") then
	                    imgUrl = imgUrl .. "&width=100&height=100"
	                else
	                    imgUrl = imgUrl .. "?width=100&height=100"
	                end
	            end

	            if checkint(userinfoData.msex) ~= 1 then
		            self.sexIcon_:setSpriteFrame(display.newSpriteFrame("female_icon.png"))
		            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
		        else
		            self.sexIcon_:setSpriteFrame(display.newSpriteFrame("male_icon.png"))
		            self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
		        end

		        if userinfoData.mavatar then
		            nk.ImageLoader:loadAndCacheImage(self.userAvatarLoaderId_, imgUrl, handler(self, self.onAvatarLoadComplete_), 
		                nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG)
		        end
			end
		end
	end
end

function ChooseProRoomListItem:onAvatarLoadComplete_(success, sprite)
	-- body
	if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()

        if self and self.avatar_ then
            --todo
            self.avatar_:setTexture(tex)
            self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))

            local avatarBgSize = self.avatarBg_:getContentSize()

			local avartarContMagrins = 4
			local avatarDisplaySize = {
				width = avatarBgSize.width - avartarContMagrins * 2,
				height = avatarBgSize.height - avartarContMagrins * 2
			}

			self.avatar_:scale(avatarDisplaySize.width / texSize.width)
            -- self.avatar_:setScaleX(57 / texSize.width)
            -- self.avatar_:setScaleY(57 / texSize.height)
            -- self.avatarLoaded_ = true
        end
    end
end

-- @Param roomType: other, GrabRoomItem; 0, CashRoomItem.
function ChooseProRoomListItem:setItemRoomType(roomType)
	-- body
	self.proRoomType_ = roomType
end

function ChooseProRoomListItem:onEntryRoomCallBack_(evt)
	-- body
	self:dispatchEvent({name="ITEM_EVENT", data = self.data_})
end

function ChooseProRoomListItem:onEnter()
	-- body
end

function ChooseProRoomListItem:onExit()
	-- body
	nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
end

function ChooseProRoomListItem:onCleanup()
	-- body
end

return ChooseProRoomListItem