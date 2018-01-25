--
-- Author: johnny@boomegg.com
-- Date: 2014-08-22 11:43:10
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--
-- Description: UserInfoPopup. Modify by Tsing.

local UserInfoPanelParam = {
    WIDTH = 745,
    HEIGHT = 472
}

-- local PADDING = 16
local TabPageContSize = {
    width = 725,
    height = 246,
}

local ButtonGroupParam = {
    WIDTH = {
        normal = 179,
        pressed = 180
    },

    HEIGHT = {
        normal = 48,
        pressed = 51
    }
}

local BtnGroupIconImg = {
    {normal = "userInfo_bagMain_normal.png", selected = "userInfo_bagMain_pressed.png"},
    {normal = "userInfo_bagBank_normal.png", selected = "userInfo_bagBank_pressed.png"},
    {normal = "userInfo_bagGift_normal.png", selected = "userInfo_bagGift_pressed.png"},
    {normal = "userInfo_bagPack_normal.png", selected = "userInfo_bagPack_pressed.png"}
}

-- local StorePopup = import("app.module.newstore.StorePopup")
local GiftStorePopup = import("app.module.newstore.GiftStorePopup")
local HelpPopup = import("app.module.settingAndhelp.SettingAndHelpPopup")
local PassWordPopUp = import("app.module.room.bank.PassWordPopUp")
local ModifyBankPassWordPopup = import("app.module.room.bank.ModifyBankPassWordPopup")
local UpgradePopup = import("app.module.upgrade.UpgradePopup")
local LoadGiftControl = import("app.module.gift.LoadGiftControl")
-- local GiftShopPopup = import("app.module.gift.GiftShopPopup")
-- local ChatMsgPanel = import("app.module.room.views.ChatMsgPanel")

local SuonaUsePopup = import("app.module.suona.SuonaUsePopup")
local MatchUserInfoRecordView = import("app.module.match.views.MatchUserInfoRecordView")
local ScoreMarketView = import("app.module.scoreMarket.ScoreMarketView")
local TextureHandler = import(".TextureHandler")
local MyGiftListItem = import(".MyGiftListItem")
local PropsListItem = import(".PropsListItem")
local UserInfoPopupController = import(".UserInfoPopupController")
local logger = bm.Logger.new("UserInfoPopup")

local UserInfoPopup = class("UserInfoPopup", nk.ui.Panel)

function UserInfoPopup:ctor(defaultTabIndex,popupParams)
    self._controller = UserInfoPopupController.new(self)

    UserInfoPopup.super.ctor(self, {UserInfoPanelParam.WIDTH, UserInfoPanelParam.HEIGHT})

    self._defaultTabIndex = defaultTabIndex or 1
    self.popupParams_ = popupParams

    self._controller:setWareGiftId(nk.userData["aUser.gift"])
    -- self._giftWaredId = nk.userData["aUser.gift"]
    self:setNodeEventEnabled(true)
    TextureHandler.loadTexture()

    self:drawUserInfoMainBlock()
    self:drawTabBarBlockBelow()

    self._controller:getHddjNum()
    -- -- 添加数据观察器
    self:addPropertyObservers_()

    -- -- 更新实时数据
    self:loadUpdateData()

    -- -- 更新互动道具
    -- 弃用，已在前面更新
    -- self:updateHDDJData()

    -- -- 跟新喇叭数量
    -- self:updateLaBaData()
end

function UserInfoPopup:drawUserInfoMainBlock()
    -- body
    local titleBlockFrontParam = {
        frontSizes = {
            name = 30,
            UID = 22
        },
        colors = {
            name = cc.c3b(137, 162, 198),
            UID = cc.c3b(197, 220, 244)
        }
    }

    local titleBlockSizeFixEachSide = 0

    local titleBlockSize = {
        width = 745 - titleBlockSizeFixEachSide * 2,
        height = 55
    }

    local titleBlockPosYShift = 0
    local titleBlock = display.newScale9Sprite("#userInfo_titleBlock.png", 0, UserInfoPanelParam.HEIGHT / 2 - titleBlockSize.height / 2 - titleBlockPosYShift,
        cc.size(titleBlockSize.width, titleBlockSize.height))
        :addTo(self)

    self:addCloseBtn()

    local avatarPaddingTopLeft = 16
    local avatarBgSize = {
        width = 106,
        height = 106
    }

    -- 头像
    local avatarPosX = - self.width_ / 2 + 54 + avatarPaddingTopLeft
    local avatarPosY = self.height_ / 2 - 54 - avatarPaddingTopLeft
    self.avatarBg_ = display.newScale9Sprite("#user_info_avatar_bg.png", 0, 0, cc.size(avatarBgSize.width, avatarBgSize.height))
        :pos(avatarPosX, avatarPosY)
        :addTo(self)

    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :pos(avatarPosX, avatarPosY)
        :addTo(self)

    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id

    local cameraImgPosShift = {
        x = 37,
        y = 36
    }
    local cameraImage = display.newSprite("#userInfo_icCamera.png")
        :pos(avatarPosX + cameraImgPosShift.x, avatarPosY - cameraImgPosShift.y)
        :addTo(self)
        :hide()

    local refreshHeadImage = display.newSprite("refreshHeadIcon.png")
        :pos(avatarPosX + cameraImgPosShift.x, avatarPosY - cameraImgPosShift.y)
        :addTo(self)
        :hide()

    -- -- init analytics
    -- if device.platform == "android" or device.platform == "ios" then
    --     cc.analytics:start("analytics.UmengAnalytics")
    -- end
        
    if not nk.userData.canEditAvatar then
        cameraImage:hide()
        refreshHeadImage:show()
    else
        cameraImage:show()
        refreshHeadImage:hide()
    end

    if nk.userData.UPLOAD_PIC and nk.userData.canEditAvatar then
        self.uploadPicBtn_ = cc.ui.UIPushButton.new("#transparent.png", {scale9 = true})
            :setButtonSize(avatarBgSize.width, avatarBgSize.height)
            :onButtonClicked(handler(self, self._onUserHeadImgUpload))
            :pos(avatarPosX, avatarPosY)
            :addTo(self)
    end

    if not nk.userData.canEditAvatar then
        self.refreshPicBtn_ = cc.ui.UIPushButton.new("#transparent.png", {scale9 = true})
            :setButtonSize(avatarBgSize.width, avatarBgSize.height)
            :onButtonClicked(handler(self, self.onRefreshUserHeadClick))
            :pos(avatarPosX, avatarPosY)
            :addTo(self)
    end

    -- 性别图标
    local iconPosX = - self.width_ / 2 + 108 + avatarPaddingTopLeft + 28
    local iconPosY = self.height_ / 2 - avatarPaddingTopLeft
    self.genderIconCrcle_ = display.newSprite("#male_icon_with_bg.png")
    self.genderIconCrcle_:pos(iconPosX + 20, iconPosY - 12):addTo(self)
    self.genderIconCrcle_:scale(0.9)

    self.genderIcon_ = display.newSprite("#icon_male.png")
    self.genderIcon_:pos(iconPosX + 20, iconPosY - 12):addTo(self)

    self.genderIcon_:scale(1.1)
    if nk.userData.canEditAvatar then
        bm.TouchHelper.new(self.genderIconCrcle_, handler(self, self.onGenderIconClick_))
    end

    -- self.genderIconLine_ = display.newScale9Sprite("#user-info-desc-modify-nick-line.png", 0, 0, cc.size(340,1))
    --     self.genderIconLine_:pos(0, iconPosY - 46):addTo(self)


    local labelPosX = iconPosX + 28
    local labelPosY = iconPosY

    --  -- 礼物
    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
       self.giftImage_ = cc.ui.UIPushButton.new({normal = "#gift-icon-up.png",pressed = "#gift-icon-down.png"})
           :pos(iconPosX - 131, labelPosY - 56)
           :addTo(self)

            -- 这一句后面可能要做处理！
            :onButtonClicked(buttontHandler(self, self.openGiftPopUpHandler))

        self.seatGiftImageLoaderId_ = nk.ImageLoader:nextLoaderId()

        if self.giftUrlReqId_ then
            LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
        end
        self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(nk.userData["aUser.gift"], function(url)
            self.giftUrlReqId_ = nil

            if url and string.len(url) > 5 then
                nk.ImageLoader:cancelJobByLoaderId(self.seatGiftImageLoaderId_)
                nk.ImageLoader:loadAndCacheImage(self.seatGiftImageLoaderId_, url, 
                    handler(self,self.userGiftImageLoadCallback_), nk.ImageLoader.CACHE_TYPE_GIFT)
            end
        end)
    end
    
    -- uid标签
    display.newTTFLabel({text = "UID:" .. nk.userData.uid, color = titleBlockFrontParam.colors.UID, size = titleBlockFrontParam.frontSizes.UID, align = ui.TEXT_ALIGN_CENTER})
        :pos(labelPosX + 76 + 240 + 40 + 90, labelPosY - 12)
        :addTo(self)

    -- 昵称标签
    self.nickEdit_ = cc.ui.UIInput.new({image = "#common_transparent_skin.png", listener = handler(self, self.onNickEdit_), size = cc.size(360, 40)})
        :align(display.LEFT_CENTER, labelPosX + 15, labelPosY - 12)
        :addTo(self)
    self.nickEdit_:setFont(ui.DEFAULT_TTF_FONT, titleBlockFrontParam.frontSizes.name)
    self.nickEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, titleBlockFrontParam.frontSizes.name)
    self.nickEdit_:setMaxLength(15)
    self.nickEdit_:setPlaceholderFontColor(titleBlockFrontParam.colors.name)
    self.nickEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.nickEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    if not nk.userData.canEditAvatar then
        self.nickEdit_:setTouchEnabled(false)
    end

    nk.EditBoxManager:addEditBox(self.nickEdit_)
    -- 编辑按钮
    local editNickBtn = cc.ui.UIPushButton.new("#userInfo_btnNickNameEdit.png")
        -- :onButtonClicked(handler(self, self._onEditNickNameBtnCallBack))
        :pos(labelPosX + 345, labelPosY - 12)
        :addTo(self)

    -- local editNameTouchModeSize = {
    --     width = 275,
    --     height = 40
    -- }

    -- local editNickNameBtnTouchMode = cc.ui.UIPushButton.new("#common_transparent_skin.png", {scale9 = true})
    --     :setButtonSize(editNameTouchModeSize.width, editNameTouchModeSize.height)
    --     :pos(labelPosX + 15 + editNameTouchModeSize.width / 2, labelPosY - 12)
    --     :addTo(self)

    -- editNickNameBtnTouchMode:setTouchSwallowEnabled(false)

    editNickBtn:setTouchSwallowEnabled(false)
        -- :onButtonClicked(handler(self, self.onLevelHelpClick_))
    if not nk.userData.canEditAvatar then
        editNickBtn:hide()
    end

    local userPersonalInfoFrontParam = {
        frontSizes = {
            chip = 26,
            champScore = 26,
            cash = 26,
            level = 24,
            experience = 14
        },

        colors = {
            chip = cc.c3b(255, 157, 31),
            champScore = cc.c3b(210, 56, 75),
            cash = styles.FONT_COLOR.GOLDEN_TEXT,
            level = cc.c3b(199, 229, 255),
            experience = cc.c3b(32, 152, 222)
        }
    }

    -- 筹码图标
    display.newSprite("#userInfo_coinChip.png")
        :pos(iconPosX + 8, iconPosY - 62)
        :addTo(self)

    -- 筹码数值
    self.chip_ = display.newTTFLabel({text = bm.formatNumberWithSplit( nk.userData["aUser.money"]), 
        color = userPersonalInfoFrontParam.colors.chip, size = userPersonalInfoFrontParam.frontSizes.chip, align = ui.TEXT_ALIGN_RIGHT})
    self.chip_:setAnchorPoint(cc.p(0, 0.5))
    self.chip_:pos(iconPosX + 32, iconPosY - 62)
    self.chip_:addTo(self)

    -- 冠军积分图标
    display.newSprite("#userInfo_coinPoint.png")
        :pos(iconPosX + 8 + 248, iconPosY - 110)
        :addTo(self)

    -- 冠军积分数值
    self.champion_score_ = display.newTTFLabel({text = "", color = userPersonalInfoFrontParam.colors.champScore,
        size = userPersonalInfoFrontParam.frontSizes.champScore, align = ui.TEXT_ALIGN_RIGHT})
    self.champion_score_:setAnchorPoint(cc.p(0, 0.5))
    self.champion_score_:pos(iconPosX + 8 + 248 + 25, iconPosY - 110)
    self.champion_score_:addTo(self)


    -- 现金币图标
    display.newSprite("#userInfo_coinMatch.png")
        :pos(iconPosX + 8 , iconPosY - 110)
        :addTo(self)

    -- 现金币数值
    self.cash_ = display.newTTFLabel({text = "", color = userPersonalInfoFrontParam.colors.cash, size = userPersonalInfoFrontParam.frontSizes.cash, align = ui.TEXT_ALIGN_RIGHT})
    self.cash_:setAnchorPoint(cc.p(0, 0.5))
    self.cash_:pos(iconPosX + 38, iconPosY - 110)
    self.cash_:addTo(self)

    -- 帮助按钮
    self.cashHelpBtn = cc.ui.UIPushButton.new({normal = "#userInfo_helpQMark_normal.png", pressed = "#userInfo_helpQMark_pressed.png"})
        :pos(iconPosX + 8 + 248 + 25 + 288, iconPosY - 110)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onCashCoinHelpClick))

    -- 等级标签
    local lv = nk.Level:getLevelByExp(nk.userData['aUser.exp']);
    self.level_ = display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "LEVEL", (lv or nk.userData['aUser.mlevel'])), color = userPersonalInfoFrontParam.colors.level,
        size = userPersonalInfoFrontParam.frontSizes.level, align = ui.TEXT_ALIGN_CENTER})
    self.level_:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    self.level_:pos(iconPosX + 8 + 248 + 25 + 5, iconPosY - 62)
    self.level_:addTo(self)

    --等级图标
    display.newSprite("#userInfo_icExp.png")
        :pos(self.level_:getPositionX() - 28, iconPosY - 62)
        :addTo(self)

    -- 经验值条
    self.expProgBar_ = nk.ui.ProgressBar.new("#userInfo_expBarBg.png", "#userInfo_expBarFiller.png", 
        {bgWidth = 225, bgHeight = 15, fillWidth = 15, fillHeight = 15})
        :pos(iconPosX + 8 + 248 + 25 + 5 + 60, labelPosY - 62)
        :addTo(self)
        :setValue(nk.Level:getLevelUpProgress(nk.userData["aUser.exp"]))

    local ratio, progress, all = nk.Level:getLevelUpProgress(nk.userData["aUser.exp"])
    -- 经验值标签
    self.experience_ = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO","EXPERIENCE_VALUE", progress, all), color = userPersonalInfoFrontParam.colors.experience,
        size = userPersonalInfoFrontParam.frontSizes.experience, align = ui.TEXT_ALIGN_CENTER})
    self.experience_:pos(iconPosX + 8 + 248 + 25 + 5 + 60 + 225 / 2, iconPosY - 62)
    self.experience_:addTo(self)

    self.expProgBar_:setScaleY(.8)

    -- dividLine --
    local divideLineSize = {
        width = UserInfoPanelParam.WIDTH,
        height = 4
    }
    self._divideLine = display.newScale9Sprite("#userInfo_splitLine.png", 0, iconPosY - 110 - 28,
        cc.size(divideLineSize.width, divideLineSize.height))
        :addTo(self)
end

function UserInfoPopup:drawTabBarBlockBelow()
    -- body
    local tabMagrins = {
        leftRightSide = 10,
        top = 10,
        each = 3
    }

    local tabButtonImgSel = {
        "#userInfo_tabSel_left.png",
        "#userInfo_tabSel_middle.png",
        "#userInfo_tabSel_middle.png",
        "#userInfo_tabSel_right.png"
    }

    local tabLabelCont = bm.LangUtil.getText("USERINFO", "TAB_INDEX_TEXT")

    -- dump(tabLabelCont, "tabLabelCont:===============")
    -- local tabLabelCont = {
    --     "aaaaaaaa",
    --     "bbbbbbbbbb",
    --     "cccccc",
    --     "dddcddd"
    -- }

    local tabButtonLabelParam = {
        frontSize = 16,
        colors = {
            nor = cc.c3b(31, 157, 234),
            press = display.COLOR_WHITE
        }
    }

    local btnIconImgMagrinLeft = 10
    
    local pageContBgPosYShift = 100
    local tabPageContBg = display.newScale9Sprite("#userInfo_blockDent_1.png", 0, - pageContBgPosYShift,
        cc.size(TabPageContSize.width, TabPageContSize.height))
        :addTo(self)

    self._tabPageContainer = display.newNode()
        :addTo(tabPageContBg)

    self._tabBtnGroup = nk.ui.CheckBoxButtonGroup.new()

    self.tabButtonGroup = {}

    local tabSelBgLightSizeHAdjust = 15
    for i = 1, 4 do
        self.tabButtonGroup[i] = cc.ui.UICheckBoxButton.new({
            on = tabButtonImgSel[i],
            off = "#userInfo_blockDent_1.png",
            }, {scale9 = true})
            :setButtonSize(ButtonGroupParam.WIDTH.normal, ButtonGroupParam.HEIGHT.normal)

        self.tabButtonGroup[i]:setAnchorPoint(display.ANCHOR_POINTS[display.TOP_CENTER])
        self.tabButtonGroup[i]:pos(- UserInfoPanelParam.WIDTH / 2 + tabMagrins.leftRightSide + ButtonGroupParam.WIDTH.normal / 2 * (2 * i - 1) + tabMagrins.each * (i - 1),
            self._divideLine:getPositionY() - tabMagrins.top)
            :addTo(self)

        self.tabButtonGroup[i].icon = display.newSprite("#" .. BtnGroupIconImg[i].normal)
        self.tabButtonGroup[i].icon:pos(- ButtonGroupParam.WIDTH.normal / 2 + btnIconImgMagrinLeft + self.tabButtonGroup[i].icon:getContentSize().width / 2,
            - ButtonGroupParam.HEIGHT.normal / 2)
            :addTo(self.tabButtonGroup[i])

        self.tabButtonGroup[i].label = display.newTTFLabel({text = tabLabelCont[i], size = tabButtonLabelParam.frontSize,
            color = tabButtonLabelParam.colors.nor, align = ui.TEXT_ALIGN_CENTER})
            :pos((btnIconImgMagrinLeft + self.tabButtonGroup[i].icon:getContentSize().width) / 2, - ButtonGroupParam.HEIGHT.normal / 2)
            :addTo(self.tabButtonGroup[i])

        self.tabButtonGroup[i].selBgLight = display.newScale9Sprite("#userInfo_bgTabSel.png", 0,
            - (ButtonGroupParam.HEIGHT.normal + tabSelBgLightSizeHAdjust) / 2, cc.size(ButtonGroupParam.WIDTH.normal, ButtonGroupParam.HEIGHT.normal + tabSelBgLightSizeHAdjust))
        :addTo(self.tabButtonGroup[i])
        -- self.tabButtonGroup[i].selBgLight:setTouchSwallowEnabled(false)
        self.tabButtonGroup[i].selBgLight:hide()

        self._tabBtnGroup:addButton(self.tabButtonGroup[i])
    end

    self._tabBtnGroup:onButtonSelectChanged(handler(self, self._onTabChangeCallBack))

    -- 个人详细信息
    self.InfoView_ = display.newNode()
        :addTo(self._tabPageContainer)

    -- 银行面板
    self.bankView_ = display.newNode()
        :addTo(self._tabPageContainer)

    -- 礼物标签页
    self.giftView_ = display.newNode()
        :addTo(self._tabPageContainer)

    -- -- 道具面板
    self.propView_ = display.newNode()
        :addTo(self._tabPageContainer)
    
    -- 默认全部不显示
    self.InfoView_:hide()
    self.bankView_:hide()
    self.giftView_:hide()
    self.propView_:hide()

    self:renderUserInfoView()
    self:renderBankView()
    self:renderGiftView()
    self:renderPropView()

    self._tabBtnGroup:getButtonAtIndex(self._defaultTabIndex):setButtonSelected(true)
end

function UserInfoPopup:renderUserInfoView()
    -- body
    local LabelMagrinLeft = 25
    local LabelMarinEachLine = 38

    local labelPosX = LabelMagrinLeft
    local labelPosY = TabPageContSize.height - LabelMarinEachLine

    local userGameInfoDescFrontSize = 24
    -- local titleLabelColor = 
    local userGameInfoDescColor = cc.c3b(189, 217, 242)

    -- InfoView --
    -- local userInfoTitleLabel = display.newTTFLabel({text = "aaaaaaaaaaaaaaa", size = 24, --[[color = ,]] align = ui.TEXT_ALIGN_CENTER})
    -- userInfoTitleLabel:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    -- userInfoTitleLabel:pos(labelPosX, labelPosY)
    --     :addTo(self.InfoView_)

    -- 历史胜率
    local winRate = 0.0
    if nk.userData["aUser.win"] > 0 then
        winRate = math.round((nk.userData["aUser.win"] / (nk.userData["aUser.win"] + nk.userData["aUser.lose"])) * 1000) / 10
    end
    self.winRateLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "WIN_RATE_HISTORY"), color = userGameInfoDescColor, size = userGameInfoDescFrontSize, align = ui.TEXT_ALIGN_CENTER})
    self.winRateLabel_:align(display.LEFT_CENTER, labelPosX, labelPosY)
    self.winRateLabel_:addTo(self.InfoView_)

    self.winRate_ = display.newTTFLabel({text = "", color = userGameInfoDescColor, size = userGameInfoDescFrontSize, align = ui.TEXT_ALIGN_CENTER})
    self.winRate_:align(display.LEFT_CENTER, self.winRateLabel_:getPositionX() + self.winRateLabel_:getContentSize().width , labelPosY)
    self.winRate_:addTo(self.InfoView_)

    -- 牌局数 --
    self.dealRoundsLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "DEALROUND"), size = userGameInfoDescFrontSize, color = userGameInfoDescColor, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, labelPosX, labelPosY - LabelMarinEachLine)
        :addTo(self.InfoView_)

    self.dealRounds_ = display.newTTFLabel({text = "", size = userGameInfoDescFrontSize, color = userGameInfoDescColor, align = ui.TEXT_ALIGN_CENTER})
        :align(display.LEFT_CENTER, labelPosX + self.dealRoundsLabel_:getContentSize().width, labelPosY - LabelMarinEachLine)
        :addTo(self.InfoView_)


    -- 收益 --
    self.incomeTodayLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "INCOME_TODAY"), size = userGameInfoDescFrontSize, color = userGameInfoDescColor, align = ui.TEXT_ALIGN_CENTER})
        :align(display.CENTER_LEFT, labelPosX, labelPosY - LabelMarinEachLine * 2)
        :addTo(self.InfoView_)

    self.incomeToday_ = display.newTTFLabel({text = "", size = userGameInfoDescFrontSize, color = userGameInfoDescColor, align = ui.TEXT_ALIGN_CENTER})
        :align(display.CENTER_LEFT, labelPosX + self.incomeTodayLabel_:getContentSize().width, labelPosY - LabelMarinEachLine * 2)
        :addTo(self.InfoView_)
    -- -- 排名
    -- self.rankingLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "INFO_RANKING"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, labelPosX, labelPosY - LabelMarinEachLine * 2)
    --     :addTo(self.InfoView_)

    -- self.ranking_ = display.newTTFLabel({text = "", color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, self.rankingLabel_:getPositionX() + self.rankingLabel_:getContentSize().width, labelPosY - LabelMarinEachLine * 2)
    --     :addTo(self.InfoView_)

    -- 赢得最大奖池
    self.historyAwardLabel = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "MAX_POT_HISTORY"), color = userGameInfoDescColor, size = userGameInfoDescFrontSize, align = ui.TEXT_ALIGN_CENTER})
    self.historyAwardLabel:align(display.LEFT_CENTER, labelPosX, labelPosY - LabelMarinEachLine * 3)
    self.historyAwardLabel:addTo(self.InfoView_)

    self.historyAward = display.newTTFLabel({text = bm.formatNumberWithSplit(nk.userData.maxaward), color = userGameInfoDescColor, size = userGameInfoDescFrontSize, align = ui.TEXT_ALIGN_CENTER})
    self.historyAward:align(display.LEFT_CENTER, self.historyAwardLabel:getPositionX() + self.historyAwardLabel:getContentSize().width, labelPosY - LabelMarinEachLine * 3)
    self.historyAward:addTo(self.InfoView_)

    -- 历史最高资产
    self.historyPopertyLabel = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "MAX_MONEY_HISTORY"), color = userGameInfoDescColor, size = userGameInfoDescFrontSize, align = ui.TEXT_ALIGN_CENTER})
    self.historyPopertyLabel:align(display.LEFT_CENTER, labelPosX, labelPosY - LabelMarinEachLine * 4)
    self.historyPopertyLabel:addTo(self.InfoView_)

    self.historyPoperty = display.newTTFLabel({text = bm.formatNumberWithSplit(nk.userData.maxmoney), color = userGameInfoDescColor, size = userGameInfoDescFrontSize, align = ui.TEXT_ALIGN_CENTER})
    self.historyPoperty:align(display.LEFT_CENTER , self.historyPopertyLabel:getPositionX() + self.historyPopertyLabel:getContentSize().width , labelPosY - LabelMarinEachLine * 4)
    self.historyPoperty:addTo(self.InfoView_)

    -- -- 历史最佳牌型
    -- display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "BEST_CARD_TYPE_HISTORY"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER})
    --     :align(display.LEFT_CENTER, 64, labelPosY - 106)
    --     :addTo(self.InfoView_)

    -- -- 牌型扑克
    -- if nk.userData.best and nk.userData.best["maxwcard"] ~= "" then
    --     local vals = string.sub(nk.userData.best["maxwcard"], 1, 6)
    --     local len = math.floor(string.len(vals)/2)

    --     local cards = {}
    --     for i=1,len do
    --         cards[i] = string.sub(vals,2*i - 1,2*i)
    --     end

    --     -- local cards = {
    --     --     string.sub(vals, 1, 2), 
    --     --     string.sub(vals, 3, 4), 
    --     --     string.sub(vals, 5, 6)
    --     -- }
    --     local cardNode = display.newNode()
    --         :pos(64, labelPosY - 166)
    --         :addTo(self.InfoView_)
    --     local PokerCard = nk.ui.PokerCard
    --     local pokerCards = {}
    --     for i = 1, len do
    --         pokerCards[i] = PokerCard.new()
    --             :setCard(tonumber(string.sub(cards[i], 1, 1), 16) * 16 + tonumber(string.sub(cards[i], 2, 2), 16))
    --             :showFront()
    --             :scale(0.6)
    --             :pos(24 + (i - 1) * 72, 0)
    --             :addTo(cardNode)
    --     end
    -- end
    
    -- User MatchInfo --
    local rewardWallMagrins = {
        right = 16,
        top = 16,
        each = 16
    }

    local rewardWallContSize = {
        width = 295,
        height = 105
    }

    local rewardWallTitleSize = {
        width = 295,
        height = 25
    }

    local userMatchInfoLabelParam = {
        frontSizes = {
            title = 20,
            num = 16,
            tip = 18
        },

        colors = {
            title = cc.c3b(184, 186, 189),
            num = display.COLOR_WHITE,
            tip = cc.c3b(184, 186, 189)
        }
    }

    self.medalNode = display.newNode()
    :addTo(self.InfoView_)
    :pos(TabPageContSize.width - rewardWallMagrins.right - rewardWallContSize.width / 2,
        TabPageContSize.height - rewardWallMagrins.top - rewardWallContSize.height / 2)
    self.medalNode:setVisible(false)

    display.newScale9Sprite("#userInfo_blockDent_2.png", TabPageContSize.width - rewardWallMagrins.right - rewardWallContSize.width / 2,
        TabPageContSize.height - rewardWallMagrins.top - rewardWallContSize.height / 2, cc.size(rewardWallContSize.width, rewardWallContSize.height))
    :addTo(self.InfoView_)

    display.newScale9Sprite("#userInfo_blockTitleDent_2.png", TabPageContSize.width - rewardWallMagrins.right - rewardWallTitleSize.width / 2,
        TabPageContSize.height - rewardWallMagrins.top - rewardWallTitleSize.height / 2, cc.size(rewardWallTitleSize.width, rewardWallTitleSize.height))
    :addTo(self.InfoView_)

    display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "CHIPMATCH_MEDAL"), color = userMatchInfoLabelParam.colors.title, size = userMatchInfoLabelParam.frontSizes.title, align = ui.TEXT_ALIGN_CENTER})
    :addTo(self.InfoView_)
    :pos(TabPageContSize.width - rewardWallMagrins.right - rewardWallContSize.width / 2,
        TabPageContSize.height - rewardWallMagrins.top - rewardWallTitleSize.height / 2)

    local noMedalTextShownSize = {
        width = 295,
        height = 25
    }

    self.notMedalTxt_ = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "NOT_GETREWARD_YET"), color = userMatchInfoLabelParam.colors.tip, size = userMatchInfoLabelParam.frontSizes.tip,
        dimensions=cc.size(noMedalTextShownSize.width, noMedalTextShownSize.height),align = ui.TEXT_ALIGN_CENTER})
        :pos(TabPageContSize.width - rewardWallMagrins.right - rewardWallContSize.width / 2,
            TabPageContSize.height - rewardWallMagrins.top - rewardWallContSize.height / 2)
        :addTo(self.InfoView_)
    self.notMedalTxt_:setVisible(false)

    local medalIconPosAdjust = {
        between = 88,
        height = 5
    }

    display.newSprite("#userInfo_matchMedal_1.png")
        :addTo(self.medalNode)
        :pos(- medalIconPosAdjust.between,- medalIconPosAdjust.height)

    display.newSprite("#userInfo_matchMedal_2.png")
        :addTo(self.medalNode)
        :pos(0, - medalIconPosAdjust.height)

    display.newSprite("#userInfo_matchMedal_3.png")
        :addTo(self.medalNode)
        :pos(medalIconPosAdjust.between, - medalIconPosAdjust.height)

    self._medalNumLabel = {}

    local medalNumLabelPosYShift = 25
    for i = 1, 3 do
        self._medalNumLabel[i] = display.newTTFLabel({text = "*0", size = userMatchInfoLabelParam.frontSizes.num, color = userMatchInfoLabelParam.colors.num, align = ui.TEXT_ALIGN_CENTER})
            :pos(- medalIconPosAdjust.between * (2 - i)-10, - medalNumLabelPosYShift-5)
            :addTo(self.medalNode)
    end

    local moreMedalRewardFlag = display.newSprite("#userInfo_flagMoreReward.png")
        :addTo(self.medalNode)
    moreMedalRewardFlag:pos(rewardWallContSize.width / 2 - moreMedalRewardFlag:getContentSize().width / 2, - rewardWallContSize.height / 2 + moreMedalRewardFlag:getContentSize().height / 2)

    self.clubNode = display.newNode()
        :addTo(self.InfoView_)
        :pos(TabPageContSize.width - rewardWallMagrins.right - rewardWallContSize.width / 2,
            TabPageContSize.height - rewardWallMagrins.top - rewardWallContSize.height / 2 * 3 - rewardWallMagrins.each)
    self.clubNode:setVisible(false)

    display.newScale9Sprite("#userInfo_blockDent_2.png", TabPageContSize.width - rewardWallMagrins.right - rewardWallContSize.width / 2,
        TabPageContSize.height - rewardWallMagrins.top - rewardWallContSize.height / 2 * 3 - rewardWallMagrins.each, cc.size(rewardWallContSize.width, rewardWallContSize.height))
    :addTo(self.InfoView_)

    display.newScale9Sprite("#userInfo_blockTitleDent_2.png", TabPageContSize.width - rewardWallMagrins.right - rewardWallContSize.width / 2,
        TabPageContSize.height - rewardWallMagrins.top - rewardWallContSize.height / 2 * 2 - rewardWallMagrins.each - rewardWallTitleSize.height / 2, cc.size(rewardWallTitleSize.width, rewardWallTitleSize.height))
    :addTo(self.InfoView_)

    display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "INSPECMATCH_CLUB"), color = userMatchInfoLabelParam.colors.title, size = userMatchInfoLabelParam.frontSizes.title, align = ui.TEXT_ALIGN_CENTER})
    :addTo(self.InfoView_)
    :pos(TabPageContSize.width - rewardWallMagrins.right - rewardWallContSize.width / 2,
        TabPageContSize.height - rewardWallMagrins.top - rewardWallContSize.height / 2 * 2 - rewardWallMagrins.each - rewardWallTitleSize.height / 2)

    self.notClubTxt_ = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "NOT_GETREWARD_YET") , color = userMatchInfoLabelParam.colors.tip, size = userMatchInfoLabelParam.frontSizes.tip, dimensions=cc.size(298, 25),align = ui.TEXT_ALIGN_CENTER})
        :pos(TabPageContSize.width - rewardWallMagrins.right - rewardWallContSize.width / 2,
            TabPageContSize.height - rewardWallMagrins.top - rewardWallContSize.height / 2 * 3 - rewardWallMagrins.each)
        :addTo(self.InfoView_)
    self.notClubTxt_:setVisible(false)

    local clubRewardPosXFix = 5

    display.newSprite("#userInfo_matchClub_1.png")
    :addTo(self.clubNode)
    :pos(- medalIconPosAdjust.between + clubRewardPosXFix, 0)

    display.newSprite("#userInfo_matchClub_2.png")
    :addTo(self.clubNode)
    :pos(clubRewardPosXFix, 0)

    display.newSprite("#userInfo_matchClub_3.png")
    :addTo(self.clubNode)
    :pos(medalIconPosAdjust.between + clubRewardPosXFix, 0)

    self._clubNumLabel = {}

    local clubNumLabelPosYShift = 38
    for i = 1, 3 do
        self._clubNumLabel[i] = display.newTTFLabel({text = "*0", size = userMatchInfoLabelParam.frontSizes.num, color = userMatchInfoLabelParam.colors.num, align = ui.TEXT_ALIGN_CENTER})
            :pos(-medalIconPosAdjust.between * (2 - i), - clubNumLabelPosYShift)
            --   - medalIconPosAdjust.between * (2 - i)-10
            :addTo(self.clubNode)
    end

    local moreClubRewardFlag = display.newSprite("#userInfo_flagMoreReward.png")
        :addTo(self.clubNode)
    moreClubRewardFlag:pos(rewardWallContSize.width / 2 - moreClubRewardFlag:getContentSize().width / 2, - rewardWallContSize.height / 2 + moreClubRewardFlag:getContentSize().height / 2)


    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png",pressed = "#common_transparent_skin.png"}, {scale9 = true})
        :setButtonSize(rewardWallContSize.width, rewardWallContSize.height * 2 + rewardWallMagrins.each)
        :addTo(self.InfoView_)
        :pos(TabPageContSize.width - rewardWallMagrins.right - rewardWallContSize.width / 2,
            TabPageContSize.height - rewardWallMagrins.top - rewardWallContSize.height - rewardWallMagrins.each / 2)
        :onButtonClicked(buttontHandler(self, self.onBtnCheckMoreRecord_))
end

function UserInfoPopup:renderBankView()
    -- body
    -- baknView --
    local bankMainBlockSize = {
        width = 710,
        height = 235
    }

    local bankViewMainBlock = display.newScale9Sprite("#userInfo_blockDent_1.png", TabPageContSize.width / 2, TabPageContSize.height / 2, cc.size(bankMainBlockSize.width, bankMainBlockSize.height))
        :addTo(self.bankView_)

    local bankDescLabelMagrins = {
        top = 20,
        left = 25,
        eachLine = 5
    }

    local bankMainBlockPaddings = {
        left = 8,
        bottom = 8
    }

    local descLabelParam = {
        frontSize = 16,
        color = cc.c3b(120, 121, 122)
    }

    local descLabelOne = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "BANK_USE_TIP1"), size = descLabelParam.frontSize, color = descLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
    descLabelOne:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    descLabelOne:pos(bankDescLabelMagrins.left, bankMainBlockSize.height - bankDescLabelMagrins.top - descLabelOne:getContentSize().height / 2)
        :addTo(bankViewMainBlock)

    local descLabelTwo = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "BANK_USE_TIP3"), size = descLabelParam.frontSize, color = descLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
    descLabelTwo:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    descLabelTwo:pos(bankDescLabelMagrins.left, bankMainBlockSize.height - bankDescLabelMagrins.top - descLabelOne:getContentSize().height - bankDescLabelMagrins.eachLine - descLabelTwo:getContentSize().height / 2)
        :addTo(bankViewMainBlock)
    -- descLabelTwo:hide()
    local bankInputBgSize = {
        width = 456,
        height = 42
    }

    local bankInputBoxPaddingTop = 80
    local bankInputBg = display.newScale9Sprite("#userInfo_bankDigitInputBg.png", bankMainBlockPaddings.left + bankDescLabelMagrins.left + bankInputBgSize.width / 2,
        TabPageContSize.height - bankInputBoxPaddingTop - bankInputBgSize.height / 2, cc.size(bankInputBgSize.width, bankInputBgSize.height))
        :addTo(self.bankView_)

    local deleteBtnSize = {
        width = 58,
        height = 38
    }

    -- 银行删除按钮
    self.deleteButton_ = cc.ui.UIPushButton.new("#userInfo_btnBankDelete.png")
        :pos(bankMainBlockPaddings.left + bankDescLabelMagrins.left + bankInputBgSize.width - deleteBtnSize.width / 2,
            TabPageContSize.height - bankInputBoxPaddingTop - bankInputBgSize.height / 2)
        :onButtonClicked(buttontHandler(self, self.onDeleteChipNumberClick_))
        :addTo(self.bankView_)

    -- 显示筹码显示区域
    local inputTxtColor = display.COLOR_BLACK
    self.textInputChip = display.newTTFLabel({text = "0", size = 28, color = inputTxtColor, align = ui.TEXT_ALIGN_CENTER})
    -- self.textInputChip:setAnchorPoint(cc.p(0, 0.5))
    self.textInputChip:pos(bankMainBlockPaddings.left + bankDescLabelMagrins.left + bankInputBgSize.width / 2, TabPageContSize.height - bankInputBoxPaddingTop - bankInputBgSize.height / 2)
    self.textInputChip:addTo(self.bankView_)

    local firstNumber = {1 ,2 , 3 , 4 ,5}
    self.curString = ""

    local ButtonMagrins = {
        bottom = 22,
        between = 4
    }

    local digitBtnSize = {
        width = 88,
        height = 45
    }

    for i= 1, 5 do
        local firstRowBtn = cc.ui.UIPushButton.new({normal = "#userInfo_btnBankDigit.png", pressed = "#userInfo_btnBankDigit.png"}, {scale9 = true})
            :setButtonSize(digitBtnSize.width, digitBtnSize.height)
            :pos(bankMainBlockPaddings.left + bankDescLabelMagrins.left + digitBtnSize.width / 2 * (2 * i - 1) + ButtonMagrins.between * (i - 1),
                ButtonMagrins.bottom + digitBtnSize.height / 2 * 3 + ButtonMagrins.between)
            :setButtonLabel(display.newTTFLabel({text = firstNumber[i], color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER}))
            -- :setButtonLabelString(firstNumber[i])
            :onButtonClicked(buttontHandler(self, self.modifyInputLabel))
            :addTo(self.bankView_)
    end

    local secondNumber = {6 ,7, 8 , 9 ,0}
    for i = 1, 5 do
        local secondRowBtn = cc.ui.UIPushButton.new({normal = "#userInfo_btnBankDigit.png", pressed = "#userInfo_btnBankDigit.png"}, {scale9 = true})
            :setButtonSize(digitBtnSize.width, digitBtnSize.height)
            :pos(bankMainBlockPaddings.left + bankDescLabelMagrins.left + digitBtnSize.width / 2 * (2 * i - 1) + ButtonMagrins.between * (i - 1),
                ButtonMagrins.bottom + digitBtnSize.height / 2)
            :setButtonLabel(display.newTTFLabel({text = secondNumber[i], color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER}))
            :onButtonClicked(buttontHandler(self, self.modifyInputLabel))
            :addTo(self.bankView_)
    end


    

    local bankBtnRightPaddingRight = 30

    local bankMoneyShownBgSzie = {
        width = 198,
        height = 66
    }

    local bankSaveDrawMoneyBtnSize = {
        width = 180,
        height = 45
    }
    -- 存钱 下面btn
    self.bankSaveButton= cc.ui.UIPushButton.new({normal = "#userInfo_btnGreen.png", pressed = "#userInfo_btnGreen.png", disabled = "#userInfo_btnDisable.png"}, {scale9 = true})
        :setButtonSize(bankSaveDrawMoneyBtnSize.width, bankSaveDrawMoneyBtnSize.height)
        :pos(TabPageContSize.width - bankBtnRightPaddingRight - bankSaveDrawMoneyBtnSize.width / 2, ButtonMagrins.bottom + bankSaveDrawMoneyBtnSize.height / 2)
        :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","SAVE_BUTTON_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.saveChipClick_))
        :addTo(self.bankView_)

    self.buttonEnabled_ = true
        
    -- 取钱
    self.bankDrawButton = cc.ui.UIPushButton.new({normal = "#userInfo_btnGreen.png", pressed = "#userInfo_btnGreen.png", disabled = "#userInfo_btnDisable.png"}, {scale9 = true})
        :setButtonSize(bankSaveDrawMoneyBtnSize.width, bankSaveDrawMoneyBtnSize.height)
        :pos(TabPageContSize.width - bankBtnRightPaddingRight - bankSaveDrawMoneyBtnSize.width / 2, ButtonMagrins.bottom + bankSaveDrawMoneyBtnSize.height / 2 * 3 + ButtonMagrins.between)
        :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","DRAW_BUTTON_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.drawChipClick_))
        :addTo(self.bankView_)

    local bankMoneyShownBgPosYShift = 3
    -- 有密码的时候
    self.existPassWordIcon_ = cc.ui.UIPushButton.new({normal = "#userInfo_bankPswExist_nor.png", pressed = "#userInfo_bankPswExist_pres.png"})
        :pos(TabPageContSize.width - bankBtnRightPaddingRight - bankSaveDrawMoneyBtnSize.width / 2,
        ButtonMagrins.bottom + bankSaveDrawMoneyBtnSize.height * 2 + ButtonMagrins.between * 2 + bankMoneyShownBgSzie.height / 2 + bankMoneyShownBgPosYShift)
        :onButtonClicked(buttontHandler(self, self.onCancelAndSettingPasswordClicked_))
        :addTo(self.bankView_)
        :hide()

    -- 没有密码的时候
    self.inExistPassWordIcon_ = cc.ui.UIPushButton.new({normal = "#userInfo_bankNoPsw_nor.png", pressed = "#userInfo_bankNoPsw_pres.png"})
        :pos(self.existPassWordIcon_:getPositionX(), self.existPassWordIcon_:getPositionY())
        :onButtonClicked(buttontHandler(self, self.onSetPassWordClick_))
        :addTo(self.bankView_)
        :hide()

    -- 有密码的时候和没有密码时候图标不同
    if nk.userData["aUser.bankLock"] == 1 then
        self.existPassWordIcon_:show()
    else
        self.inExistPassWordIcon_:show()
    end

    local bankChipLabelPosYShift = 15
    -- 银行资产标签
    local bankChipLabel = display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_TOTAL_CHIP_LABEL"), color = cc.c3b(0x27, 0x90, 0xd5), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(self.existPassWordIcon_:getPositionX() - 10, self.existPassWordIcon_:getPositionY() + bankChipLabelPosYShift)
        :addTo(self.bankView_)

    local bankChipPosYShift = 13
    -- 银行内总的筹码数量
    self.bankChip = display.newTTFLabel({text = bm.formatNumberWithSplit(nk.userData["aUser.bankMoney"]), color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(self.existPassWordIcon_:getPositionX(), self.existPassWordIcon_:getPositionY() - bankChipPosYShift)
        :addTo(self.bankView_)

    local bankDisableTipParam = {
        frontSizes = {
            notOpen = 26,
            levelNotReach = 26,
            verifyCode = 26,
            btn = 22
        },

        color = display.COLOR_WHITE
    }

    self._showBankNotOpenTxt = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "BANK_NOT_OPEN_YET"), size = bankDisableTipParam.frontSizes.notOpen,
        color = bankDisableTipParam.color, align = ui.TEXT_ALIGN_CENTER})
        :pos(TabPageContSize.width / 2, TabPageContSize.height / 2)
        :addTo(self._tabPageContainer)

    self._showBankNotOpenTxt:hide()

    self.bankNotOpenTooLowLevelLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("BANK", "BANK_LEVELS_DID_NOT_REACH"), size = bankDisableTipParam.frontSizes.levelNotReach,
        color = bankDisableTipParam.color, align = ui.TEXT_ALIGN_CENTER})
        :pos(TabPageContSize.width / 2, TabPageContSize.height / 2)
        :addTo(self._tabPageContainer)

    self.bankNotOpenTooLowLevelLabel_:hide()

    local verifyBanCodeLabelPosYShift = 30
    self._verifyBankPswLabel = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "BANK_VERIFY_CODE"), size = bankDisableTipParam.frontSizes.verifyCode,
        color = bankDisableTipParam.color, align = ui.TEXT_ALIGN_CENTER})
        :pos(TabPageContSize.width / 2, TabPageContSize.height / 2 + verifyBanCodeLabelPosYShift)
        :addTo(self._tabPageContainer)

    self._verifyBankPswLabel:hide()

    local verifyBtnSize = {
        width = 136,
        height = 48
    }

    local verifyBtnPosYShift = 25

    self._verifyNowBtn = cc.ui.UIPushButton.new("#userInfo_btnGreen.png", {scale9 = true})
        :setButtonSize(verifyBtnSize.width, verifyBtnSize.height)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "BANK_VERIFY_NOW"), size = bankDisableTipParam.frontSizes.btn, color = bankDisableTipParam.color, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self._onVerifyBankPswCallBack))
        :pos(TabPageContSize.width / 2, TabPageContSize.height / 2 - verifyBtnPosYShift)
        :addTo(self._tabPageContainer)

    self._verifyNowBtn:hide()


    if self.bankSubTabBar_ == nil then
        self.bankSubTabBar_ = nk.ui.TabBarWithIndicator.new(
            {
                background = "#popup_sub_tab_bar_bg.png", 
                indicator = "#popup_sub_tab_bar_indicator.png"
            }, 
            bm.LangUtil.getText("BANK", "BANK_SUB_TABBAR_TEXT"), 
            nil, 
            true, 
            true
    )
        self.bankSubTabBar_:addTo(self.bankView_)
    end

    self.bankSubTabBar_:setTabBarSize(180, 44, -4, -4)
    self.bankSubTabBar_:pos(bankMainBlockSize.width - 114, bankMainBlockSize.height -25)
    self.bankSubTabBar_:onTabChange(handler(self, self.onBankSubTabChange_))
    self.bankSubTabBar_:gotoTab(1, true)


    self:updateBankButtonStatue()

    if not nk.OnOff:check("pointBank") then
        self.bankSubTabBar_:hide()
    else
        self.bankSubTabBar_:show()
    end

    -- Save Ino --

    -- local bankMoneyShownBgPosYShift = 3
    -- local bankMoneyShownBg = display.newScale9Sprite("userInfo/userInfo_editTxtBlockBank.png", TabPageContSize.width - bankBtnRightPaddingRight - bankSaveDrawMoneyBtnSize.width / 2,
    --     ButtonMagrins.bottom + bankSaveDrawMoneyBtnSize.height * 2 + ButtonMagrins.between * 2 + bankMoneyShownBgSzie.height / 2 + bankMoneyShownBgPosYShift, cc.size(bankMoneyShownBgSzie.width, bankMoneyShownBgSzie.height))
    --     :addTo(self.bankView_)

    -- -- -- 银行内总的筹码数量
    -- self.bankChip = display.newTTFLabel({text = bm.formatNumberWithSplit(nk.userData["aUser.bankMoney"]), color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(bankMoneyShownBgSzie.width / 2, bankMoneyShownBgSzie.height / 2)
    --     :addTo(bankMoneyShownBg)
    
    -- end --


    

end

function UserInfoPopup:renderGiftView()
    -- body
    -- giftView --
    local giftMainBlockMagrinTop = 10
    local giftMainBlockSize = {
        width = 710,
        height = 182
    }

    local giftShownMainBlock = display.newScale9Sprite("#userInfo_blockDent_1.png", TabPageContSize.width / 2,
        TabPageContSize.height - giftMainBlockMagrinTop - giftMainBlockSize.height / 2, cc.size(giftMainBlockSize.width, giftMainBlockSize.height))
        :addTo(self.giftView_)

    local giftBottomBlockSize = {
        width = TabPageContSize.width,
        height = 48
    }
    local giftBottomBlock = display.newScale9Sprite("#userInfo_blockBottomDent_2.png", TabPageContSize.width / 2, giftBottomBlockSize.height / 2,
        cc.size(giftBottomBlockSize.width, giftBottomBlockSize.height))
        :addTo(self.giftView_)

    local giftDescBottomMagrinLeft = 20

    local giftDescbottomLabelFrontSize = 18
    local giftDescbottomLabelColor = cc.c3b(121, 121, 121)

    local giftDescbottomLabel = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "GIFT_BOTTOMTIP"), size = giftDescbottomLabelFrontSize, color = giftDescbottomLabelColor, align = ui.TEXT_ALIGN_CENTER})
    giftDescbottomLabel:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    giftDescbottomLabel:pos(giftDescBottomMagrinLeft, giftBottomBlockSize.height / 2)
        :addTo(giftBottomBlock)

    local giftBottomBtnSize = {
        width = 180,
        height = 42
    }

    local giftBottomBtnMagrinRight = 18

    local giftBtnLabelFrontSize = 16
    local giftBtnLabelFrontColor = display.COLOR_WHITE

    local giftBottomBtn = cc.ui.UIPushButton.new("#userInfo_btnGreen.png", {scale9 = true})
        :setButtonSize(giftBottomBtnSize.width, giftBottomBtnSize.height)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "GIFT_GO_SHOP"), size = giftBtnLabelFrontSize, color = giftBtnLabelFrontColor, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self._onGiftGoStore))
        :pos(giftBottomBlockSize.width - giftBottomBtnMagrinRight - giftBottomBtnSize.width / 2, giftBottomBlockSize.height / 2)
        :addTo(giftBottomBlock)

    local subTabBarMyGiftParam = {
        width = 520,
        height = 36,
        offsetX = - 4,
        offsetY = - 4
    }

    local subTabBarMyGiftPaddingTop = 20
    self.subTabBarMyGift_ = nk.ui.TabBarWithIndicator.new({background = "#popup_sub_tab_bar_bg.png", indicator = "#popup_sub_tab_bar_indicator.png"}, 
            bm.LangUtil.getText("GIFT", "SUB_TAB_TEXT_MY_GIFT"), nil, true, true)
    self.subTabBarMyGift_:addTo(self.giftView_)

    self.subTabBarMyGift_:setTabBarSize(subTabBarMyGiftParam.width, subTabBarMyGiftParam.height, subTabBarMyGiftParam.offsetX, subTabBarMyGiftParam.offsetY)
    self.subTabBarMyGift_:pos(TabPageContSize.width / 2, TabPageContSize.height - subTabBarMyGiftPaddingTop - subTabBarMyGiftParam.height / 2)
    self.subTabBarMyGift_:onTabChange(handler(self, self._onSubTabMyGiftChange))
    self.subTabBarMyGift_:gotoTab(1, true)

    local giftDescCenterLabelSize = 16
    local giftDescCenterLabelColor = cc.c3b(91, 130, 178)

    local giftDescCenter = display.newTTFLabel({text = bm.LangUtil.getText("GIFT", "MY_GIFT_MESSAGE_PROMPT_LABEL"), size = giftDescCenterLabelSize, color = giftDescCenterLabelColor, align = ui.TEXT_ALIGN_CENTER})
    giftDescCenter:pos(TabPageContSize.width / 2, TabPageContSize.height - subTabBarMyGiftPaddingTop - subTabBarMyGiftParam.height - giftDescCenter:getContentSize().height / 2)
        :addTo(self.giftView_)

    local myGiftListViewParam = {
        width = 690,
        height = 110
    }

    local myGiftListViewPaddingBottom = 65

    self._myGiftListView = bm.ui.ListView.new({viewRect = cc.rect(- myGiftListViewParam.width / 2, - myGiftListViewParam.height / 2, myGiftListViewParam.width, myGiftListViewParam.height),
        direction = bm.ui.ListView.DIRECTION_HORIZONTAL}, MyGiftListItem)
        :pos(TabPageContSize.width / 2, myGiftListViewPaddingBottom + myGiftListViewParam.height / 2)
        :addTo(self.giftView_)

    local noGiftLabelParam = {
        frontSize = 25,
        color = display.COLOR_WHITE
    }

    self._noGiftOnShownTxt = display.newTTFLabel({text = bm.LangUtil.getText("GIFT", "NO_GIFT_TIP"), size = noGiftLabelParam.frontSize, color = noGiftLabelParam.color, align = ui.TEXT_ALIGN_CENTER})
        :pos(TabPageContSize.width / 2, myGiftListViewPaddingBottom + myGiftListViewParam.height / 2)
        :addTo(self.giftView_)

    self._noGiftOnShownTxt:hide()
end

function UserInfoPopup:renderPropView()
    -- body
    -- propView --
    local propBgBlockSize = {
        width = 710,
        height = 182
    }

    local propBgBlockMagrinBottom = 55

    self.propBackground = display.newScale9Sprite("#userInfo_blockDent_2.png", 0, 0, cc.size(propBgBlockSize.width, propBgBlockSize.height))
        :pos(TabPageContSize.width / 2, propBgBlockMagrinBottom + propBgBlockSize.height / 2)
        :addTo(self.propView_)

    -- 喇叭
    -- self.laBaIcon_ = display.newSprite("#user-info-prop-background-icon.png")
    --     :pos(0, labelPosY - 185)
    --     :addTo(self.propView_)
    -- self.laBaIcon_:setVisible(false)
    
    -- 喇叭互动道具图标
    -- self.laPropIcon_ = display.newSprite("#user-info-big-laba-icon.png")
    --     :pos(self.laBaIcon_:getContentSize().width * 0.5, self.laBaIcon_:getContentSize().height * 0.5 + 40)
    --     :addTo(self.laBaIcon_)

    -- 喇叭使用按钮
    -- self.laBuyButton_ = cc.ui.UIPushButton.new({normal = "#user-info-prop-blue-up.png" , pressed = "#user-info-prop-blue-down.png"}, {scale9 = true})
    --     :setButtonSize(225, 40)
    --     :setButtonLabel("normal",display.newTTFLabel({text = bm.LangUtil.getText("STORE","BUY"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
    --     :pos(self.laBaIcon_:getContentSize().width * 0.5, 19)
    --     :onButtonClicked(buttontHandler(self, self.buyPropHandler_))
    --     :addTo(self.laBaIcon_)

    -- 喇叭标签
    -- self.laBaLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("BANK", "BANK_LABA_LABEL") , color = cc.c3b(0x27, 0x90, 0xd5), size = 26, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(self.laBaIcon_:getContentSize().width * 0.5, 65)
    --     :addTo(self.laBaIcon_)

    -- 喇叭数量
    -- self.laNumberLabel_ = display.newTTFLabel({text = "X0" , color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(self.laBaIcon_:getContentSize().width * 0.5 + 70, 170)
    --     :addTo(self.laBaIcon_)

    -- VIP
    -- self.vipIcon_ = display.newSprite("#user-info-prop-background-icon.png")
    --     :pos(self.laBaIcon_:getPositionX() + self.laBaIcon_:getContentSize().width +10 , labelPosY - 185)
    --     :addTo(self.propView_)
    --     :hide()

    -- VIP 互动道具图标
    -- self.laPropIcon_ = display.newSprite("#user-info-prop-icon.png")
    --     :pos(self.vipIcon_:getContentSize().width * 0.5, self.vipIcon_:getContentSize().height * 0.5 + 30)
    --     :addTo(self.vipIcon_)
    --     :hide()

    -- VIP购买
    -- self.vipBuyButton_ = cc.ui.UIPushButton.new({normal = "#user-info-prop-blue-up.png" , pressed = "#user-info-prop-blue-down.png"}, {scale9 = true})
    --     :setButtonSize(225, 40)
    --     :setButtonLabel("normal",display.newTTFLabel({text = bm.LangUtil.getText("STORE","BUY"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
    --     :pos(self.vipIcon_:getContentSize().width * 0.5, 19)
    --     :addTo(self.vipIcon_)
    --     :hide()

    -- VIP标签
    -- self.vipLabel_ = display.newTTFLabel({text = "VIP" , color = cc.c3b(0x27, 0x90, 0xd5), size = 26, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(self.vipIcon_:getContentSize().width * 0.5, 65)
    --     :addTo(self.vipIcon_)
    --     :hide()

    -- VIP数量
    -- self.vipNumberLabel_ = display.newTTFLabel({text = "X60" , color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(self.vipIcon_:getContentSize().width * 0.5 + 70, 170)
    --     :addTo(self.vipIcon_)
    --     :hide()

    -- 互动道具
    local propIconPaddingLeft = 15
    local propIconPosYShift = 23

    -- local propIconPosXScaleShift = 20
    -- self.propIcon_ = display.newSprite("#userInfo_bgPropItem.png")
    -- self.propIcon_:pos(propIconPaddingLeft + self.propIcon_:getContentSize().width / 2 - propIconPosXScaleShift, TabPageContSize.height / 2 + propIconPosYShift)
    --     :addTo(self.propView_)

    --  self.propIcon_:scale(0.86)
    -- -- 互动道具图标
    -- self.PropIcon_ = display.newSprite("#userInfo_icProp.png")
    --     :pos(self.propIcon_:getContentSize().width * 0.5, self.propIcon_:getContentSize().height * 0.5 + 30)
    --     :addTo(self.propIcon_)

    -- -- 道具使用
    -- self.propUseButton_ = cc.ui.UIPushButton.new({normal = "#userInfo_btnBlue_nor.png" , pressed = "#userInfo_btnBlue_pres.png"}, {scale9 = true})
    --     :setButtonSize(225, 40)
    --     :setButtonLabel("normal",display.newTTFLabel({text = bm.LangUtil.getText("STORE","USE"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
    --     :pos(self.propIcon_:getContentSize().width * 0.5, 20)
    --     :onButtonClicked(buttontHandler(self, self._onUsePropQuickPlay))
    --     :addTo(self.propIcon_)


    -- -- 道具标签
    -- self.propLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("BANK", "BANK_DROP_LABEL"), color = cc.c3b(0x27, 0x90, 0xd5), size = 26, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(self.propIcon_:getContentSize().width * 0.5, 65)
    --     :addTo(self.propIcon_)

    -- -- 道具数量
    -- self.propNumberLabel_ = display.newTTFLabel({text = "" , color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER})
    --     :pos(self.propIcon_:getContentSize().width * 0.5 + 70, 170)
    --     :addTo(self.propIcon_)

    local propBottomBlockSize = {
        width = TabPageContSize.width,
        height = 48
    }
    local propBottomBlock = display.newScale9Sprite("#userInfo_blockBottomDent_2.png", TabPageContSize.width / 2, 
        propBottomBlockSize.height / 2, cc.size(propBottomBlockSize.width, propBottomBlockSize.height))
        :addTo(self.propView_)

    local propBottomLabelParam = {
        frontSizes = {
            desc = 18,
            btn = 16
        },

        colors = {
            desc = cc.c3b(121, 121, 121),
            btn = display.COLOR_WHITE
        }
    }

    self.propsList_ = bm.ui.ListView.new({viewRect = cc.rect(- 710 / 2, - 184 / 2, 710, 184),
        direction = bm.ui.ListView.DIRECTION_HORIZONTAL}, PropsListItem)
        :pos(TabPageContSize.width / 2, propBgBlockMagrinBottom + propBgBlockSize.height / 2)
        :addTo(self.propView_)
    self.propsList_.quickPlay = handler(self, self._onUsePropQuickPlay)
    self.propsList_.enterScoreMarket = handler(self,self._enterScoreMarket)
    self.propsList_.enterChooseMatch = handler(self,self._enterChooseMatch)
    self.propsList_.changeRoomGift = handler(self,self._changeRoomGift)
    self.propsList_.useSuonaBroad = handler(self, self.onSuonaUseCallBack_)

    -- local ScoreMarketView = import("app.module.scoreMarket.ScoreMarketView")


    local propDescBottomMagrinLeft = 25
    local propDescBottomLabel = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "GIFT_BOTTOMTIP"), size = propBottomLabelParam.frontSizes.desc,
        color = propBottomLabelParam.colors.desc, align = ui.TEXT_ALIGN_CENTER})
    propDescBottomLabel:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    propDescBottomLabel:pos(propDescBottomMagrinLeft, propBottomBlockSize.height / 2)
        :addTo(propBottomBlock)


    local propBottomBtnSize = {
        width = 180,
        height = 42
    }

    local propBottomBtnMagrinRight = 16
    local propBottomBtnPosYShift = 2

    local propBottomBtn = cc.ui.UIPushButton.new("#userInfo_btnGreen.png", {scale9 = true})
        :setButtonSize(propBottomBtnSize.width, propBottomBtnSize.height)
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "PROP_GO_SHOP"), size = propBottomLabelParam.frontSizes.btn, color = propBottomLabelParam.colors.btn, align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.buyPropHandler_))
        :pos(propBottomBlockSize.width - propBottomBtnMagrinRight - propBottomBtnSize.width / 2, propBottomBlockSize.height / 2 - propBottomBtnPosYShift)
        :addTo(propBottomBlock)
end

function UserInfoPopup:showPageCont(pageIdx)
    -- body

    local drawPageContByIdx = {
        [1] = function()
            -- body
            -- 首先移除保险箱暂未开放Label
            self._showBankNotOpenTxt:hide()
            self._verifyBankPswLabel:hide()
            self.bankNotOpenTooLowLevelLabel_:hide()
            self._verifyNowBtn:hide()

            self.InfoView_:show()
            self.bankView_:hide()
            self.giftView_:hide()
            self.propView_:hide()

        end,

        [2] = function()
            -- body
            -- self.bankView_:show()
            self._showBankNotOpenTxt:hide()
            self._verifyBankPswLabel:hide()
            self.bankNotOpenTooLowLevelLabel_:hide()
            self._verifyNowBtn:hide()

            self.InfoView_:hide()
            self.bankView_:hide()
            self.giftView_:hide()
            self.propView_:show()
            self:upDatePropsList()

        end,

        [3] = function()
            -- body
            self._showBankNotOpenTxt:hide()
            self._verifyBankPswLabel:hide()
            self.bankNotOpenTooLowLevelLabel_:hide()
            self._verifyNowBtn:hide()

            self:setLoading(true)
            self._controller:getMyGiftData()

            self.InfoView_:hide()
            self.bankView_:hide()
            self.giftView_:show()
            self.propView_:hide()
        end,

        [4] = function()
            -- body
            self.InfoView_:hide()
            self.giftView_:hide()
            self.propView_:hide()
            local isOpenBank = nk.OnOff:check("bank")
            -- if not isOpenBank then
            --     -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL","NOTOPEN"))
            --     -- 可能要给个提示Label：暂未开放
            --     -- self.bankView_:hide()
            --     self._showBankNotOpenTxt:show()

            --     return
            --     -- 加载未开放提示Label到self._tabPageContainer

            -- end

            local userLevelFact = nk.Level:getLevelByExp(nk.userData["aUser.exp"])
            if userLevelFact < 5 then
                -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","BANK_LEVELS_DID_NOT_REACH"))

                -- self.bankView_:hide()
                -- 加载未开放提示Label到self._tabPageContainer
                -- self._showBankNotOpenTxt:show()
                self.bankNotOpenTooLowLevelLabel_:show()
            else
                if nk.userData["aUser.bankLock"] == 0 then
                    self.bankView_:show()
                    -- self.InfoView_:hide()
                    -- self.giftView_:hide()
                    -- self.propView_:hide()
                else
                    if nk.userData["aUser.bankLock"] == 1 then

                        --有密码情况下先输入密码方可显示保险箱
                        PassWordPopUp.new():show()

                        self._verifyBankPswLabel:show()
                        self._verifyNowBtn:show()
                    end
                end
            end
        end
    }

    drawPageContByIdx[pageIdx]()
end

function UserInfoPopup:addPropertyObservers_()
    self.nickObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.name", function (name)
        self.nickEdit_:setPlaceHolder(nk.Native:getFixedWidthText("", 24, name, 160))
    end)
    self.sexObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.msex", function (sex)
        if sex == 2 or sex == 0 then
            self.selectedGender_ = 2
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("icon_female.png"))
            self.genderIconCrcle_:setSpriteFrame(display.newSpriteFrame("female_icon_with_bg.png"))
        else
            self.selectedGender_ = 1
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("icon_male.png"))
            self.genderIconCrcle_:setSpriteFrame(display.newSpriteFrame("male_icon_with_bg.png"))
        end
    end)
    self.moneyObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", function (money)
        if not money then return end
        if self.chip_ then
            self.chip_:setString(bm.formatNumberWithSplit(money))
        end
    end)
    self.expObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.exp", function (exp)
        if not exp then return end
        local ratio, progress, all = nk.Level:getLevelUpProgress(exp)
        if self.expProgBar_ then
            self.expProgBar_:setValue(ratio)
        end
        if self.experience_ then
            self.experience_:setString(bm.LangUtil.getText("USERINFO","EXPERIENCE_VALUE",progress,all))
        end
    end)

    self.levelObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.exp", function (exp)
         if not exp then return end
         local lv = nk.Level:getLevelByExp(exp)
        if self.level_ then
            self.level_:setString(bm.LangUtil.getText("COMMON", "LEVEL", lv))
        end
    end)

    -- self.levelObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.mlevel", function (lv)
    --     if not lv then return end
    --     if self.level_ then
    --         self.level_:setString(bm.LangUtil.getText("COMMON", "LEVEL", lv))
    --     end
    -- end)
    self.avatarUrlObserverHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", function (micon)
        if string.len(micon) <= 5 then
            if nk.userData["aUser.msex"] == 2 or nk.userData["aUser.msex"] == 0 then
                self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
            else
                self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
            end
        else
            local imgurl = micon
            if string.find(imgurl, "facebook") then
                if string.find(imgurl, "?") then
                    imgurl = imgurl .. "&width=100&height=100"
                else
                    imgurl = imgurl .. "?width=100&height=100"
                end
            end
            nk.ImageLoader:loadAndCacheImage(
                self.userAvatarLoaderId_, 
                imgurl, 
                handler(self, self.onAvatarLoadComplete_), 
                nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
            )
        end
    end)
    -- self.nextRwdLevelHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "nextRwdLevel", function (nextRwdLevel)
    --     if nextRwdLevel ~= 0 then
    --         -- self.helpBtn:hide()
    --         -- self.upgradeBtn:show()
    --     else
    --         -- self.helpBtn:show()
    --         -- self.upgradeBtn:hide()
    --     end
    -- end)

    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        self.giftImageHandle_ = bm.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "aUser.gift", function (nextRwdLevel)
            if self.giftUrlReqId_ then
                LoadGiftControl:getInstance():cancel(self.giftUrlReqId_)
            end
            self.giftUrlReqId_ = LoadGiftControl:getInstance():getGiftUrlById(nk.userData["aUser.gift"], function(url)
                self.giftUrlReqId_ = nil
                if url and string.len(url) > 5 then
                    nk.ImageLoader:cancelJobByLoaderId(self.seatGiftImageLoaderId_)
                    nk.ImageLoader:loadAndCacheImage(self.seatGiftImageLoaderId_,
                        url, 
                        handler(self,self.userGiftImageLoadCallback_),
                        nk.ImageLoader.CACHE_TYPE_GIFT
                    )
                end
            end)
        
        end)
    end
    
end

function UserInfoPopup:show(isInRoom, tableMessage, quickPlayHandler,isInGame)
    self.isInRoom_ = isInRoom
    self.isInGame_ = isInGame
    -- 暂时注释，保留后面可能使用！
    if self.isInRoom_ and tableMessage then
        self.tableAllUid = tableMessage.tableAllUid
        self.toUidArr = tableMessage.toUidArr
        self.tableNum = tableMessage.tableNum
        self.isCash_ = tableMessage.isCash
        -- self.minMoney = tableMessage.minMoney
    end

    self._quickPlayHandler = quickPlayHandler
    self:showPanel_()
    nk.cacheKeyWordFile()
end

function UserInfoPopup:onShowed()
    -- body
    self._myGiftListView:update()
    self._myGiftListView:update()
    self.propsList_:update()
end

function UserInfoPopup:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(104 / texSize.width)
        self.avatar_:setScaleY(104 / texSize.height)
    end
end

function UserInfoPopup:_onTabChangeCallBack(evt)
    -- body
    local buttonLabelFrontColor = {
        normal = cc.c3b(31, 157, 234),
        selected = display.COLOR_WHITE
    }

    if not self._selectedIndex then
        --todo
        self._selectedIndex = evt.selected
        self.tabButtonGroup[self._selectedIndex]:setButtonSize(ButtonGroupParam.WIDTH.pressed, ButtonGroupParam.HEIGHT.pressed)

        self.tabButtonGroup[self._selectedIndex].icon:setSpriteFrame(display.newSpriteFrame(BtnGroupIconImg[self._selectedIndex].selected))
        self.tabButtonGroup[self._selectedIndex].label:setTextColor(buttonLabelFrontColor.selected)
        self.tabButtonGroup[self._selectedIndex].selBgLight:show()
    end

    local isChanged = self._selectedIndex ~= evt.selected

    if isChanged then
        --todo
        self.tabButtonGroup[self._selectedIndex]:setButtonSize(ButtonGroupParam.WIDTH.normal, ButtonGroupParam.HEIGHT.normal)
        self.tabButtonGroup[evt.selected]:setButtonSize(ButtonGroupParam.WIDTH.pressed, ButtonGroupParam.HEIGHT.pressed)

        -- 修改前一个页面为常态。
        self.tabButtonGroup[self._selectedIndex].icon:setSpriteFrame(display.newSpriteFrame(BtnGroupIconImg[self._selectedIndex].normal))
        self.tabButtonGroup[self._selectedIndex].label:setTextColor(buttonLabelFrontColor.normal)
        self.tabButtonGroup[self._selectedIndex].selBgLight:hide()

        -- 修改当前点击页面为按下状态
        self.tabButtonGroup[evt.selected].icon:setSpriteFrame(display.newSpriteFrame(BtnGroupIconImg[evt.selected].selected))
        self.tabButtonGroup[evt.selected].label:setTextColor(buttonLabelFrontColor.selected)
        self.tabButtonGroup[evt.selected].selBgLight:show()

        if self._selectedIndex == 3 then
            --todo

            -- 当前一个页面tabIndex == 3 的时候上报礼物

            self._controller:wareGiftBySelectedId(self.isInRoom_)

            -- if self._giftWaredId ~= nk.userData["aUser.gift"] then
            --     --todo
            --     -- 当前一个页面tabIndex == 3 的时候上报礼物
            --     nk.http.useProps(nk.userData["aUser.gift"], function(data)
            --         -- local callBackBuyData =  json.decode(data)
            --         -- dump(data,"data:===============")
            --         nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_SUCCESS_TOP_TIP"))
            --         self._giftWaredId = nk.userData["aUser.gift"]

            --         if self.isInRoom_ then
            --             --todo
            --             nk.server:updateRoomGift(nk.userData["aUser.gift"], nk.userData.uid)
            --         end
            --     end,function()
            --         nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_FAIL_TOP_TIP"))
            --         self._giftWaredId = nil
            --     end)
            -- end
        end

        self._selectedIndex = evt.selected

    end

    self:showPageCont(self._selectedIndex)

end

function UserInfoPopup:onNickEdit_(event)
    if event == "began" then
        -- 开始输入
    elseif event == "changed" then
        -- 输入框内容发生变化
        local text = self.nickEdit_:getText()
        local filteredText = nk.keyWordFilter(text)
        if filteredText ~= text then
            self.nickEdit_:setText(filteredText)
        end
        self.editNick_ = string.trim(self.nickEdit_:getText())
        print(self.editNick_)
    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
        print(self.editNick_)
    end
end

function UserInfoPopup:_onEditNickNameBtnCallBack(evt)
    -- body
end

function UserInfoPopup:onRefreshUserHeadClick()
    dump("onRefreshUserHeadClick===")
    nk.clearMyHeadImgCache()
    local micon = nk.userData["aUser.micon"]
    nk.userData["aUser.micon"] = micon
end

function UserInfoPopup:_onUserHeadImgUpload()
    -- body
    -- 统计点击的次数
    if device.platform == "android" or device.platform == "ios" then
        cc.analytics:doCommand{command = "event",
            args = {eventId = "change_avatar_click"}, label = "user Upload Avatar_click"}
    end

    nk.Native:pickImage(function(success, result)
        logger:debug("nk.Native:pickImage callback ", success, result)

        if success then
            if bm.isFileExist(result) then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_IS_UPLOADING"))

                local iconKey = "~#kevin&^$xie$&boyaa"
                local time = os.time()
                local sig = crypto.md5(nk.userData.uid .. "|" .. appconfig.ROOT_CGI_SID .. "|" .. time .. iconKey)
                local extraParam = {
                    {"sid", appconfig.ROOT_CGI_SID},
                    {"mid", nk.userData.uid},
                    {"time", time},
                    {"sig", sig}}

                if IS_DEMO then
                    table.insert(extraParam, {"demo", 1})
                end

                network.uploadFile(function(evt)
                    if evt.name == "completed" then

                        local request = evt.request
                        local code = request:getResponseStatusCode()
                        local ret = request:getResponseString()
                        logger:debugf("REQUEST getResponseStatusCode() = %d", code)
                        logger:debugf("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString())
                        logger:debugf("REQUEST getResponseDataLength() = %d", request:getResponseDataLength())
                        logger:debugf("REQUEST getResponseString() =\n%s", ret)

                        local retTable = json.decode(ret)
                        if retTable.code == 1 and retTable.iconname then
                            local iconname = retTable.iconname
                            nk.http.updateUserIcon({iconname = iconname},
                                function(ret1)
                                    if ret1 then
                                        local imgURL = ret1.micon or ""
                                        nk.userData.b_picture = imgURL
                                        nk.userData.m_picture = imgURL
                                        nk.userData["aUser.micon"] = imgURL

                                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_SUCCESS"))
                                        if self and self.isInRoom_ then
                                            --nk.socket.RoomSocket:sendSrvChangeHead(nk.userData.uid, imgURL)
                                        end

                                    -- else
                                    --     nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_FAIL"))
                                    end
                                end,

                                function()
                                    -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
                                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_FAIL"))
                                end)
                        else
                            nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_UPLOAD_FAIL"))
                        end
                        -- 统计统计换头像成功花费的时间
                        if device.platform == "android" or device.platform == "ios" then
                            cc.analytics:doCommand{command = "event",
                                       args = {eventId = "change_avatar_time"}, label = "user Upload avatar_time"}
                        end

                        os.remove(result)
                    end
                end,

                nk.userData.UPLOAD_PIC, {
                    fileFieldName = "upload",
                    filePath = result,
                    contentType = "Image/jpeg",
                    extra = extraParam
                })
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_PICK_IMG_FAIL"))
            end
        else
            if result == "nosdcard" then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_NO_SDCARD"))
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("USERINFO", "UPLOAD_PIC_PICK_IMG_FAIL"))
            end
        end
    end)
end

function UserInfoPopup:modifyInputLabel(evt)
    if self.bankSubSelectTab_ == 1 then
        local myRealMoney = nk.userData["aUser.money"]
        if self.isInRoom_ and self.isInGame_ then
            myRealMoney = nk.userData["aUser.money"] - 0 -- (nk.userData['aUser.anteMoney'] or 0)
        end

        if (string.len(self.curString) > 0) and (tonumber(self.curString) >= math.max( myRealMoney,nk.userData["aUser.bankMoney"])) then
            return 
        end
        local label = evt.target:getButtonLabel()
        self.curString = self.curString..label:getString()
        self.textInputChip:setString(bm.formatNumberWithSplit(self.curString))
        if tonumber(self.curString) > math.max( myRealMoney,nk.userData["aUser.bankMoney"]) then -- 如果输入的钱大于银行中的钱或者身上的钱让它置为两者较大的数额
            self.textInputChip:setString(bm.formatNumberWithSplit(math.max( myRealMoney,nk.userData["aUser.bankMoney"])))
        elseif self.curString == "00" then -- 如果连续两次都输入0 只让显示一个0
            local currentString = string.sub(self.curString,0,1)
            self.curString = currentString
        end
        
        if self.curString and string.len(self.curString) > 0 and  tonumber(self.curString) > 0 then
            if (myRealMoney > nk.userData["aUser.bankMoney"]) and  (tonumber(self.curString) > nk.userData["aUser.bankMoney"])  then
                self.bankDrawButton:setButtonEnabled(false)
            elseif (nk.userData["aUser.bankMoney"] >  myRealMoney) and (tonumber(self.curString) >  myRealMoney) then
                self.bankSaveButton:setButtonEnabled(false)
            end
        end
    else
        local myRealMoney = nk.userData["match.point"]
        -- if self.isInRoom_ then
        --   myRealMoney = nk.userData["aUser.money"] - (nk.userData['aUser.anteMoney'] or 0)
        -- end

        if (string.len(self.curString) > 0) and (tonumber(self.curString) >= math.max( myRealMoney,nk.userData["aUser.bankPoint"])) then
            return 
        end
        local label = evt.target:getButtonLabel()
        self.curString = self.curString..label:getString()
        self.textInputChip:setString(bm.formatNumberWithSplit(self.curString))
        if tonumber(self.curString) > math.max( myRealMoney,nk.userData["aUser.bankPoint"]) then -- 如果输入的钱大于银行中的钱或者身上的钱让它置为两者较大的数额
            self.textInputChip:setString(bm.formatNumberWithSplit(math.max( myRealMoney,nk.userData["aUser.bankPoint"])))
        elseif self.curString == "00" then -- 如果连续两次都输入0 只让显示一个0
            local currentString = string.sub(self.curString,0,1)
            self.curString = currentString
        end
        
        if self.curString and string.len(self.curString) > 0 and  tonumber(self.curString) > 0 then
            if ( myRealMoney > nk.userData["aUser.bankPoint"]) and  (tonumber(self.curString) > nk.userData["aUser.bankPoint"])  then
                self.bankDrawButton:setButtonEnabled(false)
            elseif (nk.userData["aUser.bankPoint"] >  myRealMoney) and (tonumber(self.curString) >  myRealMoney) then
                self.bankSaveButton:setButtonEnabled(false)
            end
        end



    end
    
end

function UserInfoPopup:onDeleteChipNumberClick_()
    if self.curString == "0" then
        return 
    end

    if self.bankSubSelectTab_ ==  1 then
        local myRealMoney = nk.userData["aUser.money"];
        if self.isInRoom_ and self.isInGame_ then
          myRealMoney = nk.userData["aUser.money"] -0 -- (nk.userData['aUser.anteMoney'] or 0)
        end
        
        local curLength = string.len(self.curString)
        local currentString = string.sub(self.curString,0,curLength-1)
        self.curString = currentString
        self.textInputChip:setString(bm.formatNumberWithSplit(self.curString))
        if self.curString and string.len(self.curString) > 0 and tonumber(self.curString) > 0 then
            if ( myRealMoney > nk.userData["aUser.bankMoney"]) and  (tonumber(self.curString) <  myRealMoney) then
                if nk.userData["aUser.bankMoney"] ~= 0 and  (tonumber(self.curString) <= nk.userData["aUser.bankMoney"]) then
                    self.bankDrawButton:setButtonEnabled(true)
                else
                    self.bankDrawButton:setButtonEnabled(false)
                end
            elseif (nk.userData["aUser.bankMoney"] >  myRealMoney) and (tonumber(self.curString) < nk.userData["aUser.bankMoney"])  then
                if  myRealMoney ~= 0 and (tonumber(self.curString) <=  myRealMoney) then
                    self.bankSaveButton:setButtonEnabled(true)
                else
                    self.bankSaveButton:setButtonEnabled(false)
                end
            end
        end




    else
        local myRealMoney = nk.userData["match.point"];
        -- if self.isInRoom_ then
        --   myRealMoney = nk.userData["aUser.money"] - (nk.userData['aUser.anteMoney'] or 0)
        -- end
        
        local curLength = string.len(self.curString)
        local currentString = string.sub(self.curString,0,curLength-1)
        self.curString = currentString
        self.textInputChip:setString(bm.formatNumberWithSplit(self.curString))
        if self.curString and string.len(self.curString) > 0 and tonumber(self.curString) > 0 then
            if ( myRealMoney > nk.userData["aUser.bankPoint"]) and  (tonumber(self.curString) <  myRealMoney) then
                if nk.userData["aUser.bankPoint"] ~= 0 and  (tonumber(self.curString) <= nk.userData["aUser.bankPoint"]) then
                    self.bankDrawButton:setButtonEnabled(true)
                else
                    self.bankDrawButton:setButtonEnabled(false)
                end
            elseif (nk.userData["aUser.bankPoint"] >  myRealMoney) and (tonumber(self.curString) < nk.userData["aUser.bankPoint"])  then
                if  myRealMoney ~= 0 and (tonumber(self.curString) <=  myRealMoney) then
                    self.bankSaveButton:setButtonEnabled(true)
                else
                    self.bankSaveButton:setButtonEnabled(false)
                end
            end
        end


    end
    
end


function UserInfoPopup:onOpenBankClick_()
    -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("HALL","NOTOPEN"))
    -- do return end
    if not nk.OnOff:check("bank") then
        local tipTxt = nk.OnOff:checkTip("bank")
        local defaultTxt = bm.LangUtil.getText("HALL","NOTOPEN")
        if tipTxt then
            defaultTxt = tipTxt
        end
        nk.TopTipManager:showTopTip(defaultTxt)
        return
    end

    if nk.userData["aUser.mlevel"] < 5 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","BANK_LEVELS_DID_NOT_REACH"))
    else
        local getFrame = display.newSpriteFrame
        if (not self.bankChangeFlag) and (nk.userData["aUser.bankLock"]==0) then
            self.bankButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-down.png"))
            self.bankButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_BUTTON_LABEL"), color = cc.c3b(0x27, 0x90, 0xd5), size = 26, align = ui.TEXT_ALIGN_CENTER}))
            self.bankButton_:setButtonImage("normal", "#user-info-desc-bank-down.png", true)
            self.bankButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-down-line.png"))

            self.propButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
            self.propButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_DROP_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
            self.propButton_:setButtonImage("normal", "#user-info-desc-prop-up.png", true)
            self.propButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

            self.giftButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
            self.giftButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_GIFT_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
            self.giftButton_:setButtonImage("normal", "#user-info-desc-gift-up.png", true)
            self.giftButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

            self.bankChangeFlag =true 
            self.propChangeFlag = false

            self.bankView_:show()
            self.InfoView_:hide()
            self.downLine:hide()
            self.propView_:hide()
        else
            if nk.userData["aUser.bankLock"]==1  and not self.passWordFlag then
                 PassWordPopUp.new():show()
             end 
            self.bankButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
            self.bankButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_BUTTON_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
            self.bankButton_:setButtonImage("normal", "#user-info-desc-bank-up.png", true)
            self.bankButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

            self.propButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
            self.propButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_DROP_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
            self.propButton_:setButtonImage("normal", "#user-info-desc-prop-up.png", true)
            self.propButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

            self.bankChangeFlag = false 
            self.propChangeFlag = false 
            -- self.passWordFlag 置为false,为了连续点击弹出密码框
            self.passWordFlag = false

            self.bankView_:hide()
            self.InfoView_:show()
            self.downLine:show()
            self.propView_:hide()
        end
    end

end

function UserInfoPopup:onLevelHelpClick_()
    HelpPopup.new(false,true,4):show()
end

function UserInfoPopup:onCashCoinHelpClick()
    HelpPopup.new(false, true, 4):show()

    -- if self.paopao_ then
    --     self.paopao_:removeFromParent()
    --     self.paopao_ = nil
    -- else
    --     self.paopao_ = nk.ui.PaoPaoTips.new("现金币可在积分商城兑换实物奖励", 24)
    --     :addTo(self)
    --     :pos(-20,145)
    -- end
end

function UserInfoPopup:onUpgradeClick_()
    if nk.userData.nextRwdLevel and nk.userData.nextRwdLevel ~= 0 then
        display.addSpriteFrames("upgrade_texture.plist", "upgrade_texture.png", function()
            UpgradePopup.new(nk.userData.nextRwdLevel):show()
        end)
    end
    
end

function UserInfoPopup:onBtnCheckMoreRecord_()
    local updateCallback = function()
        self.champion_score_:setString(bm.formatNumberWithSplit(nk.userData['match.highPoint']))
        self.cash_:setString(bm.formatNumberWithSplit(nk.userData['match.point']))
    end
    MatchUserInfoRecordView.new(updateCallback):show()
end

function UserInfoPopup:setPropsData(pdata)
    -- dump(pdata,"props list")
    self.propsListData_ = pdata
end
function UserInfoPopup:upDatePropsList()
    if self.propsListData_ then
        self.propsList_:setData(self.propsListData_)
    end
end

function UserInfoPopup:onOpenPropClick_()
    local getFrame = display.newSpriteFrame
    if (not self.propChangeFlag)  then
        self.propButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-down.png"))
        self.propButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_DROP_LABEL"), color = cc.c3b(0x27, 0x90, 0xd5), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        self.propButton_:setButtonImage("normal", "#user-info-desc-prop-down.png", true)
        self.propButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-down-line.png"))
        self.bankButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
        self.bankButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_BUTTON_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        self.bankButton_:setButtonImage("normal", "#user-info-desc-bank-up.png", true)
        self.bankButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

        self.giftButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
        self.giftButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_GIFT_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        self.giftButton_:setButtonImage("normal", "#user-info-desc-gift-up.png", true)
        self.giftButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

        self.propChangeFlag =true 
        self.bankChangeFlag = false 
        self.propView_:show()
        self:upDatePropsList()
        self.InfoView_:hide()
        self.bankView_:hide()
        self.downLine:hide()
    else
        self.propButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
        self.propButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_DROP_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        self.propButton_:setButtonImage("normal", "#user-info-desc-prop-up.png", true)
        self.propButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

        self.bankButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
        self.bankButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_BUTTON_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        self.bankButton_:setButtonImage("normal", "#user-info-desc-bank-up.png", true)
        self.bankButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

        self.propChangeFlag = false 
        self.bankChangeFlag = false
        self.bankView_:hide()
        self.propView_:hide()
        self.InfoView_:show()
        self.downLine:show()
    end
end

function UserInfoPopup:onOpenGiftClick_()
    local getFrame = display.newSpriteFrame
    if (not self.giftChangeFlag)  then
        self.bankButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
        self.bankButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_BUTTON_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        self.bankButton_:setButtonImage("normal", "#user-info-desc-bank-up.png", true)
        self.bankButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

        self.propButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
        self.propButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_DROP_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        self.propButton_:setButtonImage("normal", "#user-info-desc-prop-up.png", true)
        self.propButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

        self.propChangeFlag = false
        self.bankChangeFlag = false 
        self.giftChangeFlag = true
        self.propView_:hide()
        self.InfoView_:show()
        self.bankView_:hide()
        self.downLine:hide()

    else

        self.bankButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
        self.bankButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_BUTTON_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        self.bankButton_:setButtonImage("normal", "#user-info-desc-bank-up.png", true)
        self.bankButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

        self.propButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-up.png"))
        self.propButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_DROP_LABEL"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        self.propButton_:setButtonImage("normal", "#user-info-desc-prop-up.png", true)
        self.propButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-up-line.png"))

        self.propChangeFlag = false 
        self.bankChangeFlag = false
        self.giftChangeFlag = false
        self.bankView_:hide()
        self.propView_:hide()
        self.InfoView_:show()
        self.downLine:show()
    end
    -- if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        if self.isInRoom_ then
            GiftShopPopup.new(2):show(self.isInRoom_,nk.userData.uid,self.tableAllUid,self.tableNum,self.toUidArr)
        else
            GiftShopPopup.new(2):show(self.isInRoom_,nk.userData.uid)
        end
        
    -- end
    
end

function UserInfoPopup:_onUsePropQuickPlay()
    -- body
    if not self.isInRoom_ then
        --todo
        if self._quickPlayHandler then
            --todo
            self._quickPlayHandler()
        else
            nk.server:quickPlay()
        end
    end
    
    self:hidePanel_()
end
function UserInfoPopup:_enterScoreMarket()
    if self.isInRoom_ then
        --算了，不提示了
       -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("",""))
    else
        display.addSpriteFrames("scoreMarket_th.plist", "scoreMarket_th.png", function()
                 ScoreMarketView.new():show()
            end)
    end
    self:hidePanel_()
end
function UserInfoPopup:_enterChooseMatch()
    if self.isInRoom_ then
        --算了，不提示了
       -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("",""))
    else
        if self.popupParams_ and self.popupParams_.enterMatch then
            self.popupParams_.enterMatch()
        end
    end
    self:hidePanel_()
end
--个人道具里面改变自己的挂饰...
function UserInfoPopup:_changeRoomGift()
    if self.isInRoom_ then
        nk.server:updateRoomGift(nk.userData["aUser.gift"], nk.userData.uid)
    end
end

function UserInfoPopup:onSuonaUseCallBack_()
    -- body
    SuonaUsePopup.new():show()
    self:hidePanel_()
end

function UserInfoPopup:buyPropHandler_()

    local inRoomInfo = {}
    inRoomInfo.isInRoom = self.isInRoom_
    inRoomInfo.toUid = nk.userData.uid
    inRoomInfo.toUidArr = self.toUidArr
    inRoomInfo.tableNum = self.tableNum
    inRoomInfo.allTabId = self.tableAllUid

    if not self.toUidArr then
        --todo
        inRoomInfo.isInRoom = false
    end

    -- local showPagePropIndx = 3
    local subPageProp = 2
    -- StorePopup.new(showPagePropIndx, nil, subPageProp):showPanel(nil, inRoomInfo)
    GiftStorePopup.new(subPageProp):showPanel(nil, inRoomInfo)

    self:hidePanel_()

end

function UserInfoPopup:_onGiftGoStore()
    -- body
    -- local giftShopPageIndx = 1

    -- GiftShopPopup.new(giftShopPageIndx):show(self.isInRoom_,nk.userData.uid)
    local inRoomInfo = {}
    inRoomInfo.isInRoom = self.isInRoom_
    inRoomInfo.toUid = nk.userData.uid
    inRoomInfo.toUidArr = self.toUidArr
    inRoomInfo.tableNum = self.tableNum
    inRoomInfo.allTabId = self.tableAllUid

    if not self.toUidArr then
        --todo
        inRoomInfo.isInRoom = false
    end

    -- local showPageGift = 3
    -- StorePopup.new(showPageGift):showPanel(nil, inRoomInfo)
    GiftStorePopup.new():showPanel(nil, inRoomInfo)

    self:hidePanel_()
end

function UserInfoPopup:_onSubTabMyGiftChange(subTabIndx)
    -- body
    self._controller:onGiftSubTabChanged(subTabIndx)
end

function UserInfoPopup:checkPassWordSuccess()
    self._verifyBankPswLabel:hide()
    self._verifyNowBtn:hide()


    self.bankView_:show()
    --  self.passWordFlag 不让第二次点击输入密码框弹出来
    self._isBankPswSetting = false
    -- local getFrame = display.newSpriteFrame
    -- self.bankButtonBackground_:setSpriteFrame(getFrame("user-info-desc-button-background-down.png"))
        -- self.bankButton_:setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("BANK","BANK_BUTTON_LABEL"), color = cc.c3b(0x27, 0x90, 0xd5), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        -- self.bankButton_:setButtonImage("normal", "#user-info-desc-bank-down.png", true)
        -- self.bankButtonBackgroundLine_:setSpriteFrame(getFrame("user-info-desc-button-background-down-line.png"))
        -- self.InfoView_:hide()
        -- self.downLine:hide()
end

function UserInfoPopup:onCancelAndSettingPasswordClicked_()

    if self._isBankPswSetting then
        --todo
        return
    end

    nk.ui.Dialog.new({
        hasCloseButton = true,
        messageText = bm.LangUtil.getText("BANK", "BANK_CANCEL_OR_SETING_PASSWORD"), 
        firstBtnText = bm.LangUtil.getText("BANK", "BANK_CACEL_PASSWORD_BUTTON_LABEL"),
        secondBtnText = bm.LangUtil.getText("BANK", "BANK_SETTING_PASSWORD_BUTTON_LABEL"), 
        callback = function (type)
            if type == nk.ui.Dialog.FIRST_BTN_CLICK then
                self._isBankPswSetting = true
                self:CancelPassWordClick_()
            elseif type == nk.ui.Dialog.SECOND_BTN_CLICK then
                self._isBankPswSetting = true
                self:onSetPassWordClick_()
            end
        end
    }):show()
end

function UserInfoPopup:CancelPassWordClick_()
    --self.cancelPasswordRequestId_ = bm.HttpService.POST({mod="bank", act="canclePWD", token = crypto.md5(nk.userData.uid..nk.userData.mtkey..os.time().."*&%$#@123++web-ipoker)(abc#@!<>;:to"), time =os.time()},
    self.cancelPasswordRequestId_ = nk.http.delPassword(
        function(data) 
            self.cancelPasswordRequestId_ = nil
            local callData = data
                nk.userData["aUser.bankLock"] = 0 
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","CANCEL_PASSWORD_SUCCESS_TOP_TIP"))
                self.existPassWordIcon_:hide()
                self.inExistPassWordIcon_:show()
                
                self._isBankPswSetting = false
        end, function(data)
            self.cancelPasswordRequestId_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))

            self._isBankPswSetting = false
        end)
end

function UserInfoPopup:saveChipClick_()
    if self.buttonEnabled_==false then
        return
    end
    
    if self.isInRoom_ then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_CAN_NOT_USE_IN_ROOM"))
        return
    end
    if self.curString == "" or tonumber(self.curString) == 0 or string.len(self.curString) == 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "EMPYT_CHIP_NUMBER_TOP_TIP"))
        return 
    end
    local money = string.gsub(self.textInputChip:getString(),",","")
    if checkint(money) == 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "EMPYT_CHIP_NUMBER_TOP_TIP"))
        return
    end
    if checkint(money) > 2000000000 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_TOP_LIMIT_TIP"))
        return
    end
    self.buttonEnabled_ = false
    self:setLoading(true)
    local btype = ((self.bankSubSelectTab_ == 2) and "point" or "money")
    self.saveRequestId_ = nk.http.bankSaveMoney(money,btype,
        function(data)
            self:setLoading(false)
            self.buttonEnabled_  = true 
            self.saveRequestId_ = nil
            local callData = data
            if callData then
                   -- nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","USE_BANK_NO_VIP_TOP_TIP"))
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","USE_BANK_SAVE_CHIP_SUCCESS_TOP_TIP"))
                    if self.bankSubSelectTab_ == 1 then
                        self.bankChip:setString(bm.formatNumberWithSplit(callData.bankmoney))
                    else
                        self.bankChip:setString(bm.formatNumberWithSplit(callData.bankpoint))
                    end
                    -- self.bankChip:setString(bm.formatNumberWithSplit(callData.bankmoney))
                    nk.userData["aUser.bankMoney"] = callData.bankmoney
                    nk.userData["aUser.money"] = callData.gameMoney
                    nk.userData["aUser.bankPoint"] = callData.bankpoint
                    nk.userData['match.point'] = callData.gamePoint
                    if nk.userData.match then
                        nk.userData.match.point = callData.gamePoint
                    end
                    if not self.isInRoom then
                        self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"] ))
                    else
                        self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"] ))
                        --self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]-(nk.userData['aUser.anteMoney'] or 0) ))
                    end
                    --self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]))

                    self.cash_:setString(bm.formatNumberWithSplit(nk.userData['match.point']))

                    self.textInputChip:setString("0")
                    self.curString = "0"
                    self:updateBankButtonStatue()
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","USE_BANK_SAVE_CHIP_FAIL_TOP_TIP"))
            end
        end, function(errorData)
            self:setLoading(false)
            self.buttonEnabled_  = true
            self.saveRequestId_ = nil
            if errorData then
                if errorData and checkint(errorData.errorCode) == -3 then
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","BANK_SQL_ERROR"))  
                elseif errorData.errorCode == -7 then
                    if errorData.retData and errorData.retData.data and errorData.retData.data then
                        local limit = errorData.retData.data.limitNum or 3
                        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","BANK_LIMIT_NUM_TIP",limit,limit))

                        -- nk.TopTipManager:showTopTip(string.format("วันนี้จำนวนรอบฝากชิปของคุณถึงขีดจำกัดแล้ว(%s/%s)",limit,limit))   
                    end
                    
                else
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","USE_BANK_SAVE_CHIP_FAIL_TOP_TIP")..errorData.errorCode)  
                end  
            else
                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end
        end)
        
end

function UserInfoPopup:drawChipClick_()
    if self.buttonEnabled_  == false then
        return
    end
    
    if self.isInRoom_ then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_CAN_NOT_USE_IN_ROOM"))
        return
    end
    if string.len(self.curString) == 0  then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "EMPYT_CHIP_NUMBER_TOP_TIP"))
        return 
    end
    local money = string.gsub(self.textInputChip:getString(),",","")
    if checkint(money) == 0 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "EMPYT_CHIP_NUMBER_TOP_TIP"))
        return
    end
    if checkint(money) > 2000000000 then
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_TOP_LIMIT_TIP"))
        return
    end
    self.buttonEnabled_  = false
    self:setLoading(true)
    local btype = ((self.bankSubSelectTab_ == 2) and "point" or "money")
    self.drawRequestId_ = nk.http.bankGetMoney(money,btype,
    function(data) 
        self:setLoading(false)
        self.buttonEnabled_  = true
        self.drawRequestId_ = nil
        local callData = data
        if callData then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "USE_BANK_DRAW_CHIP_SUCCESS_TOP_TIP"))
                if self.bankSubSelectTab_ == 1 then
                    self.bankChip:setString(bm.formatNumberWithSplit(callData.bankmoney))
                else
                    self.bankChip:setString(bm.formatNumberWithSplit(callData.bankpoint))
                end

                -- self.bankChip:setString(bm.formatNumberWithSplit(callData.bankmoney))
                nk.userData["aUser.bankMoney"] = callData.bankmoney
                nk.userData["aUser.money"] = callData.gameMoney
                nk.userData["aUser.bankPoint"] = callData.bankpoint
                nk.userData['match.point'] = callData.gamePoint
                if nk.userData.match then
                    nk.userData.match.point = callData.gamePoint
                end
                if self.isInRoom_ and self.isInGame_  then
                   -- self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]-(nk.userData['aUser.anteMoney'] or 0) ))
                    self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"] ))
                else
                    self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"] ))
                end

                self.cash_:setString(bm.formatNumberWithSplit(nk.userData['match.point']))
                
                self.textInputChip:setString("0")
                self.curString = "0"
                self:updateBankButtonStatue()
        else
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "USE_BANK_DRAW_CHIP_FAIL_TOP_TIP"))
        end
    end, function()
        self:setLoading(false)
        self.buttonEnabled_  = true
        self.drawRequestId_ = nil
        if errorData then
            if errorData and checkint(errorData.errorCode) == -4 then
                 nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK","BANK_SQL_ERROR")) 
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "USE_BANK_DRAW_CHIP_FAIL_TOP_TIP")..errorData.errorCode)
            end
        else
           nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
        end
    end)
    
end

function UserInfoPopup:showExistPassWordIcon()
    if nk.userData["aUser.bankLock"] == 1 then
        self.existPassWordIcon_:show()
        self.inExistPassWordIcon_:hide()
    else
        self.existPassWordIcon_:hide()
        self.inExistPassWordIcon_:show()
    end

    self._isBankPswSetting = false
end

function UserInfoPopup:onSetPassWordClick_()

    ModifyBankPassWordPopup.new():show(handler(self, self.onModifyBankPswCloseCallBack_))
end

function UserInfoPopup:_onVerifyBankPswCallBack()
    -- body
    PassWordPopUp.new():show()
end

function UserInfoPopup:onModifyBankPswCloseCallBack_()
    -- body
    self._isBankPswSetting = false
end

function UserInfoPopup:onBankSubTabChange_(selectedTab)
    dump(selectedTab,"UserInfoPopup:onBankSubTabChange_=========")
    local ispaylog = nk.userData.best and nk.userData.best.paylog == 1 or false
    if not ispaylog and (selectedTab == 2) then
        self.bankSubTabBar_:gotoTab(1,true)
        --未付费用户
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("BANK", "BANK_NEED_PAY"))
        return
    end

    self.bankSubSelectTab_ = selectedTab or 1
    if selectedTab == 1 then
        self.bankChip:setString(bm.formatNumberWithSplit(nk.userData["aUser.bankMoney"]))
    else
        self.bankChip:setString(bm.formatNumberWithSplit(nk.userData["aUser.bankPoint"]))
    end

    self.curString = "0"
    self.textInputChip:setString(bm.formatNumberWithSplit(self.curString))
    self:updateBankButtonStatue()
    
end

function UserInfoPopup:onGenderIconClick_(target, evt)
    if evt == bm.TouchHelper.CLICK then
        nk.SoundManager:playSound(nk.SoundManager.CLICK_BUTTON)
        if self.selectedGender_ == 2 then  -- female
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("icon_male.png"))
            self.genderIconCrcle_:setSpriteFrame(display.newSpriteFrame("male_icon_with_bg.png"))
            if string.len(nk.userData["aUser.micon"]) <= 5 then
                self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
            end

            self.selectedGender_ = 1
        else
            self.genderIcon_:setSpriteFrame(display.newSpriteFrame("icon_female.png"))
            self.genderIconCrcle_:setSpriteFrame(display.newSpriteFrame("female_icon_with_bg.png"))
            if string.len(nk.userData["aUser.micon"]) <= 5 then
                self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
            end

            self.selectedGender_ = 2
        end
    end
end

function UserInfoPopup:userGiftImageLoadCallback_(success, sprite)
    if success then
        if not self.giftImage_ then
            return
        end
         local tex = sprite:getTexture()
         local texSize = tex:getContentSize()
         self.giftImage_:setButtonImage("normal",tex)
         self.giftImage_:setButtonImage("pressed",tex)
         self.giftImage_:scale(0.5)
    end
end

function UserInfoPopup:openGiftPopUpHandler()
    -- if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
    --     if self.isInRoom_ then
    --         GiftShopPopup.new(2):show(self.isInRoom_, nk.userData.uid,self.tableAllUid, self.tableNum,self.toUidArr)
    --     else
    --         GiftShopPopup.new(2):show(self.isInRoom_, nk.userData.uid)
    --     end
    -- end

    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        --todo
        local inRoomInfo = {}
        inRoomInfo.isInRoom = self.isInRoom_
        inRoomInfo.toUid = nk.userData.uid
        inRoomInfo.toUidArr = self.toUidArr
        inRoomInfo.tableNum = self.tableNum
        inRoomInfo.allTabId = self.tableAllUid

        if not self.toUidArr then
            --todo
            inRoomInfo.isInRoom = false
        end
    
        -- local showPagePropIndx = 3
        -- StorePopup.new(showPagePropIndx):showPanel(nil, inRoomInfo)
        GiftStorePopup.new():showPanel(nil, inRoomInfo)
        
        self:hidePanel_()
    end
    
end

function UserInfoPopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, 0)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end

function UserInfoPopup:updateBankButtonStatue()

    if self.bankSubSelectTab_ ==  1 then
        if nk.userData["aUser.bankMoney"] == 0 then
            self.bankDrawButton:setButtonEnabled(false)
        else
            self.bankDrawButton:setButtonEnabled(true)
        end
        if nk.userData["aUser.money"] == 0 then
            self.bankSaveButton:setButtonEnabled(false)
        else
            self.bankSaveButton:setButtonEnabled(true)
        end

    else
        if nk.userData["aUser.bankPoint"] == 0 then
            self.bankDrawButton:setButtonEnabled(false)
        else
            self.bankDrawButton:setButtonEnabled(true)
        end
        if nk.userData["money.point"] == 0 then
            self.bankSaveButton:setButtonEnabled(false)
        else
            self.bankSaveButton:setButtonEnabled(true)
        end
    end
end

function UserInfoPopup:setHddjNum(num)
    --self.propNumberLabel_:setString(bm.LangUtil.getText("USERINFO", "MY_PROPS_TIMES",num or 0))
end

function UserInfoPopup:loadUpdateData()
    self.rankingRequestId_ = nk.http.getMemberInfo(nk.userData["aUser.mid"], function(retData)
            if retData then

                -- dump(retData, "getMemberInfo.retData :=================", 5)
                nk.userData["aUser.name"] = retData.aUser.name or nk.userData["aUser.name"] or ""
                --if self.isInRoom_ == false then
                nk.userData["aUser.money"] = retData.aUser.money or nk.userData["aUser.money"] or 0
                --end

                nk.userData["aUser.gift"] = retData.aUser.gift or nk.userData["aUser.gift"] or 0
                nk.userData["aUser.mlevel"] = retData.aUser.mlevel or nk.userData["aUser.mlevel"] or 1
                nk.userData["aUser.exp"] = retData.aUser.exp or nk.userData["aUser.exp"] or 0
                nk.userData["aUser.win"] = retData.aUser.win or nk.userData["aUser.win"] or 0
                nk.userData["aUser.lose"] = retData.aUser.lose or nk.userData["aUser.lose"] or 0
                nk.userData["aUser.msex"] = retData.aUser.msex or nk.userData["aUser.msex"] or 0
                nk.userData["aUser.micon"] = retData.aUser.micon or nk.userData["aUser.micon"] or ""
                nk.userData["aUser.mcity"] = retData.aUser.mcity or nk.userData["aUser.mcity"] or 0
                
                nk.userData["aBest.maxmoney"] = retData.aBest.maxmoney or nk.userData["aBest.maxmoney"] or 0
                nk.userData["aBest.maxwmoney"] = retData.aBest.maxwmoney or nk.userData["aBest.maxwmoney"] or 0
                nk.userData["aBest.maxwcard"] = retData.aBest.maxwcard or nk.userData["aBest.maxwcard"] or 0
                nk.userData["aBest.rankMoney"] = retData.aBest.rankMoney or nk.userData["aBest.rankMoney"] or 0

                nk.userData["match"] = retData.match
                nk.userData['match.point'] = retData.match.point
                nk.userData['match.highPoint'] = retData.match.highPoint

                --如果最高资产与当前资产不一致，更新
                if nk.userData["aUser.money"] > nk.userData["aBest.maxmoney"] then
                    nk.userData["aBest.maxmoney"] = nk.userData["aUser.money"]
                    local info = {}
                    info.maxmoney = nk.userData["aBest.maxmoney"]
                    nk.http.updateMemberBest(info)
                    retData.aBest.maxmoney = nk.userData["aBest.maxmoney"]
                end

                if self then
                    --todo
                    if self.historyPoperty then
                        --todo
                        self.historyPoperty:setString(bm.formatNumberWithSplit(retData.aBest.maxmoney))
                    end

                    if self.historyAward then
                        --todo
                        self.historyAward:setString(bm.formatNumberWithSplit(retData.aBest.maxwmoney))
                    end
                
                    --self.chip_:setString(bm.formatNumberWithSplit(retData.aUser.money))   
                    if self.isInRoom_ and self.isInGame_ then
                        if self.isCash_ == 1 then
                            self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]))
                            self.cash_:setString(bm.formatNumberWithSplit(nk.userData['match.point']-(nk.userData['aUser.anteMoney'] or 0)))
                        else
                            self.cash_:setString(bm.formatNumberWithSplit(nk.userData['match.point']))
                            self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]))
                            --self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"] - (nk.userData['aUser.anteMoney'] or 0)))
                        end
                    else
                        self.chip_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]))
                        self.cash_:setString(bm.formatNumberWithSplit(nk.userData['match.point']))
                    end
                    self.level_:setString(T("Lv.%d",nk.Level:getLevelByExp(retData.aUser.exp)))
                    self.winRate_:setString((retData.aUser.win + retData.aUser.lose > 0 and math.round(retData.aUser.win * 100 / (retData.aUser.win + retData.aUser.lose)) or 0) .."%")

                    self.dealRounds_:setString(tostring(retData.aUser.win) .. "/" .. tostring(retData.aUser.win + retData.aUser.lose))

                    self.incomeToday_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"] - (retData.aUser.lastMoney or 0)))

                    self.champion_score_:setString(bm.formatNumberWithSplit(nk.userData['match.highPoint']))
                    

                    if nk.userData["match"] then  
                        local medalData = nk.userData["match"]["honor"]["medal"]
                        local haveMedal = 0
                        for k,v in pairs(medalData) do
                            if checkint(v)> 0 then
                                 haveMedal = 1
                             end
                        end
                        
                        -- dump(medalData, "medalData:===============")
                        for i = 1, 3 do

                            self._medalNumLabel[i]:setString("x" ..medalData[tostring(i)])-- 
                        end
                        
                        if haveMedal == 1 then
                            self.medalNode:setVisible(true)
                            self.notMedalTxt_:setVisible(false)
                        else
                            self.medalNode:setVisible(false)
                            self.notMedalTxt_:setVisible(true)
                        end

                        local clubData = nk.userData["match"]["honor"]["cup"]

                        -- dump(clubData, "clubData:====================")
                        local haveclub = 0
                        for k,v in pairs(clubData) do
                            if checkint(v)> 0 then
                                 haveclub = 1
                             end
                        end
                        
                        for i = 1, 3 do

                            self._clubNumLabel[i]:setString("x" ..clubData[tostring(i)] )--
                        end

                        if haveclub == 1 then
                            self.clubNode:setVisible(true)
                            self.notClubTxt_:setVisible(false)
                        else
                            self.clubNode:setVisible(false)
                            self.notClubTxt_:setVisible(true)
                        end
                    end
                end
            end

            end,function()
            self.rankingRequestId_ = nil
        end)
end

function UserInfoPopup:updateHDDJData()
    self.hddjNumRequestId_ = nk.http.getUserProps(2,function(pdata)
        if pdata then
            for _,v in pairs(pdata) do
                if tonumber(v.pnid) == 2001 then
                    nk.userData.hddjNum = checkint(v.pcnter)
                    break
                end
            end
        end
        
    end,function()
        
    end)
end

function UserInfoPopup:updateLaBaData()
    do return end
    self.laBaNumberRequestId_ = bm.HttpService.POST({mod="user", act="getUserProps",id = 32},
        function(data) 
            self.laBaNumberRequestId_ = nil
            local callData = json.decode(data)
            if callData and #callData > 0 and callData[1].b then
                self.laNumberLabel_:setString("X"..callData[1].b)
                self.laBaUseNumber_ = callData[1].b
                if (self.isInRoom_ and callData[1].b > 0) then
                    self.laBuyButton_:setButtonLabel("normal",display.newTTFLabel({text = bm.LangUtil.getText("STORE","USE"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
                    self.laBuyButton_:setButtonImage("normal", "#user-info-prop-green-up.png")
                    self.laBuyButton_:setButtonImage("pressed", "#user-info-prop-green-down.png")
                else
                    self.laBuyButton_:setButtonLabel("normal",display.newTTFLabel({text = bm.LangUtil.getText("STORE","BUY"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
                    self.laBuyButton_:setButtonImage("normal", "#user-info-prop-blue-up.png")
                    self.laBuyButton_:setButtonImage("pressed", "#user-info-prop-blue-down.png")
                end
            else
                self.laNumberLabel_:setString("X0")
            end
        end, function()
            self.laBaNumberRequestId_ = nil
        end)
end

function UserInfoPopup:removePropertyObservers_()
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.name", self.nickObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.msex", self.sexObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.micon", self.avatarUrlObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.money", self.moneyObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.exp", self.expObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.mlevel", self.levelObserverHandle_)
    bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "nextRwdLevel", self.nextRwdLevelHandle_)
    if ((nk.config.GIFT_SHOP_ENABLED) and (nk.userData.GIFT_SHOP == 1)) then
        bm.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "aUser.gift", self.giftImageHandle_)
    end
end

function UserInfoPopup:onEnter()
    -- body
    self.openBankView_ = bm.EventCenter:addEventListener(nk.eventNames.OPEN_BANK_POPUP_VIEW, handler(self, self.checkPassWordSuccess))
    self.showExistPassWordIcon_ = bm.EventCenter:addEventListener(nk.eventNames.SHOW_EXIST_PASSWORD_ICON, handler(self, self.showExistPassWordIcon))
end

function UserInfoPopup:onExit()
    -- body
    self._controller:dispose()
    self:removePropertyObservers_()
    nk.ImageLoader:cancelJobByLoaderId(self.userAvatarLoaderId_)
    bm.EventCenter:removeEventListener(self.openBankView_)
    bm.EventCenter:removeEventListener(self.showExistPassWordIcon_)

    TextureHandler.removeTexture()
end

function UserInfoPopup:onCleanup()
    
    -- 一般地，在UI的Exit 和cleanUp方法里不做更新数据(尤其是本地数据更新)操作，因为UI类有可能在数据回调的地方被销毁，导致本地数据错误。
    if (self.selectedGender_ and self.selectedGender_ ~= nk.userData["aUser.msex"]) or (self.editNick_ and self.editNick_ ~= nk.userData["aUser.name"]) then
       
        local params = {}
        if self.selectedGender_ and self.selectedGender_ ~= nk.userData["aUser.msex"] then
            params.msex = self.selectedGender_
        end

        if self.editNick_ and self.editNick_ ~= nk.userData["aUser.name"] then
            params.name = self.editNick_
        end

        nk.http.modifyUserInfo(params)

        --[[
        bm.HttpService.POST(
            {
                mod = "user", 
                act = "modifyInfo", 
                nick = self.editNick_, 
                s = self.selectedGender_
            }
        )
        --]]
        if self.selectedGender_ and self.selectedGender_ ~= nk.userData["aUser.msex"] then
            nk.userData["aUser.msex"] = self.selectedGender_
            if string.len(nk.userData["aUser.micon"]) <= 5 then
                nk.userData["aUser.micon"] = nk.userData["aUser.micon"]
            end
        end
        if self.editNick_ and self.editNick_ ~= nk.userData["aUser.name"] then
            nk.userData["aUser.name"] = self.editNick_
        end
    end

    nk.EditBoxManager:removeEditBox(self.nickEdit_)
    if self.rankingRequestId_ then
        nk.http.cancel(self.rankingRequestId_)
        self.rankingRequestId_ = nil
    end
    if self.laBaNumberRequestId_ then
        nk.http.cancel(self.laBaNumberRequestId_)
        self.laBaNumberRequestId_ = nil
    end

    if self._selectedIndex == 3 then
        --todo

        -- 当前一个页面tabIndex == 3 的时候上报礼物
        self._controller:wareGiftBySelectedId(self.isInRoom_)
    end

end

return UserInfoPopup
