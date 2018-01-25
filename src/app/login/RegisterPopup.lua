--
-- Author: Tom
-- Date: 2014-09-01 11:35:08
--

local WIDTH = 750
local HEIGHT = 480
local LEFT = -WIDTH * 0.5
local TOP = HEIGHT * 0.5
local RIGHT = WIDTH * 0.5
local BOTTOM = -HEIGHT * 0.5

local logger = bm.Logger.new("RegisterPopup")

local RegisterPopup = class("RegisterPopup", function()
    return display.newNode()
end)

local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")

local PADDING = 12

function RegisterPopup:ctor()

    --底色背景
    self.background_down_ = display.newScale9Sprite("#register_reward_background_down.png", 0, 0, cc.size(WIDTH, HEIGHT)):addTo(self)
    self.background_down_:setTouchEnabled(true)
    self.background_down_:setTouchSwallowEnabled(true)

     --上面的背景
    self.background_up_ = display.newScale9Sprite("#register_reward_background_up.png", 0, 0, cc.size(WIDTH-30, HEIGHT-80)):addTo(self)
    self.background_up_:setTouchEnabled(true)
    self.background_up_:pos(0, TOP - 260)
    self.background_up_:setTouchSwallowEnabled(true)

     self:setNodeEventEnabled(true)

    -- 标题
    self.logo_ = display.newSprite("#register_reward_title_logo.png")
        :pos(0, TOP - 20)
        :addTo(self)

    -- 最下面的领奖按钮
    self.rewardButton_ = cc.ui.UIPushButton.new({normal = "#register_reward_button_up.png", pressed = "#register_reward_button_down.png"}, {scale9 = true})
        :pos(0, BOTTOM + 80)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onRewardButtonHandler))
    self.rewradButtonIcon = display.newSprite("#register_reward_button_icon.png")
        :pos(LEFT + 270, BOTTOM + 80)
        :addTo(self)
    self.rewardButtonLabel = display.newTTFLabel({text = bm.LangUtil.getText("COMMON", "GET_REWARD"), color = cc.c3b(0xbc, 0x1d, 0x1d), size = 42, align = ui.TEXT_ALIGN_CENTER})
        :pos(LEFT + 420, BOTTOM + 80)
        :addTo(self)

    -- 中间的奖励区域
    self.middleRewardZoneImage_ = display.newSprite("#register_reward_dark_reward_zone_background.png")
        :pos(0, TOP - 210)
        :addTo(self)
    -- 中間獎勵天數背景
    self.middleRewardDayImage_ = display.newSprite("#register_reward_days_dark_background.png")
        :pos(0, TOP - 110)
        :addTo(self)
    -- 第二天
    self.middleRewardDayLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_SECOND_DAY"), color = cc.c3b(0x4e, 0x21, 0x14), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, TOP - 110)
        :addTo(self)

    -- 中间奖励描述
    self.middleRewardDescLabel_ = display.newTTFLabel({text = "", color = cc.c3b(0xa1, 0x60, 0x4a), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, TOP - 300)
        :addTo(self)

    -- 左边的奖励区域
    self.leftRewardZoneImage_ = display.newSprite("#register_reward_dark_reward_zone_background.png")
        :pos(LEFT + 140, TOP - 210)
        :addTo(self)
        -- 左邊獎勵天數背景
    self.leftRewardDayImage_ = display.newSprite("#register_reward_days_dark_background.png")
        :pos(LEFT + 140, TOP - 110)
        :addTo(self)
        -- 第一天
    self.leftRewardDayLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("LOGIN", "REIGSTER_REWARD_FIRST_DAY"), color = cc.c3b(0x4e, 0x21, 0x14), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(LEFT + 140, TOP - 110)
        :addTo(self)
    -- 左边的奖励描述
    self.leftRewardDescLabel_ = display.newTTFLabel({text = "", color = cc.c3b(0xa1, 0x60, 0x4a), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(LEFT + 140, TOP - 300)
        :addTo(self)


    -- 右边的奖励区域
    self.rightRewardZoneImge_ = display.newSprite("#register_reward_dark_reward_zone_background.png")
        :pos(RIGHT - 140, TOP - 210)
        :addTo(self)
    -- 右邊獎勵天數背景
    self.rightRewardDayImage_ = display.newSprite("#register_reward_days_dark_background.png")
        :pos(RIGHT - 140, TOP - 110)
        :addTo(self)
    -- 第三天
    self.rightRewardDayLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("LOGIN", "REGISTER_REWARD_THIRD_DAY"), color = cc.c3b(0x4e, 0x21, 0x14), size = 22, align = ui.TEXT_ALIGN_CENTER})
        :pos(RIGHT - 140, TOP - 110)
        :addTo(self)
    -- 左边的奖励描述
    self.rightRewardDescLabel_ = display.newTTFLabel({text = "", color = cc.c3b(0xa1, 0x60, 0x4a), size = 20, align = ui.TEXT_ALIGN_CENTER})
        :pos(RIGHT - 140, TOP - 300)
        :addTo(self)

    self:loadData()

end

function RegisterPopup:loadData()
    local getFrame = display.newSpriteFrame

    print("nk.userData.loginRewardStep",nk.userData.loginRewardStep)
    -- 更新窗体背景颜色以及奖励描述值
    if nk.userData.loginRewardStep ~= nil and nk.userData.loginRewardStep > 0 then
        if  nk.userData.loginRewardStep == 1 then
            self.leftRewardZoneImage_:setSpriteFrame(getFrame("register_reward_ligth_reward_zone_background.png"))
            self.leftRewardDayImage_:setSpriteFrame(getFrame("register_reward_days_light_background.png"))
            self.leftRewardDayLabel_:setTextColor(cc.c3b(0xff, 0xae, 0x70))
            self.leftRewardDescLabel_:setTextColor(cc.c3b(0xfe, 0xcb, 0x7b))
        elseif  nk.userData.loginRewardStep == 2 then
            self.leftRewardZoneImage_:setSpriteFrame(getFrame("register_reward_ligth_reward_zone_background.png"))
            self.leftRewardDayImage_:setSpriteFrame(getFrame("register_reward_days_light_background.png"))
            self.leftRewardDayLabel_:setTextColor(cc.c3b(0xff, 0xae, 0x70))
            self.leftRewardDescLabel_:setTextColor(cc.c3b(0xfe, 0xcb, 0x7b))


            self.middleRewardZoneImage_:setSpriteFrame(getFrame("register_reward_ligth_reward_zone_background.png"))
            self.middleRewardDayImage_:setSpriteFrame(getFrame("register_reward_days_light_background.png"))
            self.middleRewardDayLabel_:setTextColor(cc.c3b(0xff, 0xae, 0x70))
            self.middleRewardDescLabel_:setTextColor(cc.c3b(0xfe, 0xcb, 0x7b))


        elseif  nk.userData.loginRewardStep == 3 then
            self.leftRewardZoneImage_:setSpriteFrame(getFrame("register_reward_ligth_reward_zone_background.png"))
            self.leftRewardDayImage_:setSpriteFrame(getFrame("register_reward_days_light_background.png"))
            self.leftRewardDayLabel_:setTextColor(cc.c3b(0xff, 0xae, 0x70))
            self.leftRewardDescLabel_:setTextColor(cc.c3b(0xfe, 0xcb, 0x7b))


            self.middleRewardZoneImage_:setSpriteFrame(getFrame("register_reward_ligth_reward_zone_background.png"))
            self.middleRewardDayImage_:setSpriteFrame(getFrame("register_reward_days_light_background.png"))
            self.middleRewardDayLabel_:setTextColor(cc.c3b(0xff, 0xae, 0x70))
            self.middleRewardDescLabel_:setTextColor(cc.c3b(0xfe, 0xcb, 0x7b))

            self.rightRewardZoneImge_:setSpriteFrame(getFrame("register_reward_ligth_reward_zone_background.png"))
            self.rightRewardDayImage_:setSpriteFrame(getFrame("register_reward_days_light_background.png"))
            self.rightRewardDayLabel_:setTextColor(cc.c3b(0xff, 0xae, 0x70))
            self.rightRewardDescLabel_:setTextColor(cc.c3b(0xfe, 0xcb, 0x7b))
        end
    end

    if not self.juhua_ then
        self.juhua_ = nk.ui.Juhua.new():pos(0, 0):addTo(self)
    end



    self.initRequestId_ = nk.http.initRegisterAward(function(callData)
        if callData then
            self.leftRewardDescLabel_:setString(callData[1][1].."\n"..callData[1][2])
            self.middleRewardDescLabel_:setString(callData[2][1].."\n"..callData[2][2])
            self.rightRewardDescLabel_:setString(callData[3][1].."\n"..callData[3][2])

        end
         self:clearJuhua()
    end,function()
        self:clearJuhua()
        self.initRequestId_ = nil
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
    end);

    --[[
    bm.HttpService.POST(
        {
             mod = "registerReward" , 
            act = "text"
         },
        function (data)
            logger:debug("tom")
            logger:debug("registerReward  text", data)
            local callData = json.decode(data)
            if callData.ret == 0 and callData.ret ~= nil then
                self.leftRewardDescLabel_:setString(callData["1"][1].."\n"..callData["1"][2])
                self.middleRewardDescLabel_:setString(callData["2"][1].."\n"..callData["2"][2])
                self.rightRewardDescLabel_:setString(callData["3"][1].."\n"..callData["3"][2])
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            end
            self:clearJuhua()
        end,
        function (data)
            self:clearJuhua()
        end)
    --]]
end
-- 清除菊花
function RegisterPopup:clearJuhua()
    if self.juhua_ then
        self.juhua_:removeFromParent()
        self.juhua_ = nil
    end
end


function RegisterPopup:hide_()
    nk.PopupManager:removePopup(self)
    display.removeSpriteFramesWithFile("register_reward.plist", "register_reward.png")
end


function RegisterPopup:onCleanup()
    if self.initRequestId_ then
        nk.http.cancel(self.initRequestId_)
    end

    if self.rewardRequestId_ then
        nk.http.cancel(self.rewardRequestId_)
    end
end

function RegisterPopup:onRewardButtonHandler()

    if not self.juhua_ then
        self.juhua_ = nk.ui.Juhua.new():pos(0, 0):addTo(self)
    end

    self.rewardRequestId_ = nk.http.getRegisterAward(function(callData)
        if callData then
            local times = checkint(callData.times)
            local addmoney = checkint(callData.addMoney)
            local money = checkint(callData.money)
            -- local props = callData.props
            -- local propList = props.propList
            -- propList =
            -- {
            --     pcnter,pexpire,pmode,pnid,psmid
            -- }

           

            -- dump("addmoney:".. callData.addmoney .. " money:" .. callData.money .. " times:" .. callData.times,"getRegisterAward================");

            nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "REWARD_SUCCEED"))
            nk.userData["aUser.money"] = money
            nk.userData.loginRewardStep = -1

            self.animation_ = CommonRewardChipAnimation.new()
            :addTo(self)
            self.changeChipAnim_ = nk.ui.ChangeChipAnim.new(addmoney)
            :addTo(self)
            nk.SoundManager:playSound(nk.SoundManager.CHIP_DROP)
            if self.juhua_ then
                self.juhua_:removeFromParent()
                self.juhua_ = nil
                self:performWithDelay(function ()
                    self:hide_()
                end, 1)
            end

            -- local feedData = clone(bm.LangUtil.getText("FEED", "LOGIN_REGISTER"))
            -- nk.Facebook:shareFeed(feedData, function(success, result)
            -- print("FEED.LOGIN_REGISTER result handler -> ", success, result)
            -- if not success then
              
            --  else
                 
            --  end
            -- end)

            -- nk.sendFeed:login_register_()  -- 去除分享。
        end
     end,function()
        self.rewardRequestId_ = nil
        nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "REWARD_FAIL"))
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            self:hide_()
        end
    end
    )
    
    --[[
    bm.HttpService.POST(
        {
             mod = "registerReward" , 
            act = "reward"
         },
         function (data)
             logger:debug("tom")
            logger:debug("registerReward  reward", data)
            local callData = json.decode(data)
            print("chipschipschipschipschipschipschips",callData)
            if callData.ret ~= nil and callData.ret == 2 then
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "REWARD_SUCCEED"))
                nk.userData.money = nk.userData.money + callData.chips
                -- self:performWithDelay(function ()
                --     nk.userData.money = nk.userData.money + callData.chips
                -- end, 1.5)
                self.animation_ = CommonRewardChipAnimation.new()
                :addTo(self)
                self.changeChipAnim_ = nk.ui.ChangeChipAnim.new(callData.chips)
                :addTo(self)
                nk.SoundManager:playSound(nk.SoundManager.CHIP_DROP)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("LOGIN", "REWARD_FAIL"))
            end
            if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
            self:performWithDelay(function ()
                self:hide_()
            end, 1)
    end
        end,
        function (data)
            if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
            nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
            self:hide_()
    end
        end)

    --]]
end

return RegisterPopup
