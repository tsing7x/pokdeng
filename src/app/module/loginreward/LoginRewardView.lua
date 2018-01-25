--
-- Author: shanks
-- Date: 2014.09.03
--
local SignInContPopup = import("app.module.signIn.SignInContPopup")

local LoginRewardView = class("LoginRewardView", function()
    return display.newNode()
    end)

local CommonRewardChipAnimation = import("app.login.CommonRewardChipAnimation")

local logger = bm.Logger.new("LoginRewardView")

local WINDOW_WIDTH = 860
local WINDOW_HEIGHT = 530
local BG_TOP_HEIGHT = 60
local BG_MIDDLE_HEIGHT = 360
local BG_BOTTOM_HEIGHT = 110

function LoginRewardView:ctor()
    -- just for lot
    -- print("welcome")
    -- logger:debug("welcome")

    -- self.close = false
    self:setNodeEventEnabled(true)
    -- bg - top
    display.newScale9Sprite("#login_reward_bg_top.png", 0, 0, cc.size(WINDOW_WIDTH, BG_TOP_HEIGHT))
        :pos(0, WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT * 0.5)
        :addTo(self)
        :setTouchEnabled(true)

    -- bg - top, title
    display.newTilesSprite("repeat/login_reward_bg_texture_up.png", cc.rect(0, 0, WINDOW_WIDTH, BG_TOP_HEIGHT))
        :pos(- WINDOW_WIDTH * 0.5, WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT * 0.5 - BG_TOP_HEIGHT * 0.5)
        :addTo(self)

    self.closeBtn_ = cc.ui.UIPushButton.new({normal = "#panel_black_close_btn_up.png", pressed="#panel_black_close_btn_down.png"})
            :pos(WINDOW_WIDTH * 0.5, WINDOW_HEIGHT * 0.5 )
            :onButtonClicked(function()
                    nk.SoundManager:playSound(nk.SoundManager.CLOSE_BUTTON)
                    self:hide_()
                end)
            :addTo(self)

    -- bg - middle
    display.newScale9Sprite("#login_reward_bg_middle.png", 0, 0, cc.size(WINDOW_WIDTH, BG_MIDDLE_HEIGHT))
        :pos(0, WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT - BG_MIDDLE_HEIGHT * 0.5)
        :addTo(self)
        :setTouchEnabled(true)

    -- bg - middle, title
    display.newTilesSprite("repeat/login_reward_bg_texture_middle.png", cc.rect(0, 0, WINDOW_WIDTH, BG_MIDDLE_HEIGHT))
        :pos(- WINDOW_WIDTH * 0.5,  WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT - BG_MIDDLE_HEIGHT * 0.5 - BG_MIDDLE_HEIGHT * 0.5)
        :addTo(self)

    -- bg - bottom
    display.newScale9Sprite("#login_reward_bg_bottom.png", 0, 0, cc.size(WINDOW_WIDTH, BG_BOTTOM_HEIGHT))
        :pos(0, - WINDOW_HEIGHT * 0.5 + BG_BOTTOM_HEIGHT * 0.5)
        :addTo(self)
        :setTouchEnabled(true)

    -- bg - bottom, title
    display.newTilesSprite("repeat/login_reward_bg_texture_up.png", cc.rect(0, 0, WINDOW_WIDTH, BG_BOTTOM_HEIGHT))
        :pos(- WINDOW_WIDTH * 0.5,  - WINDOW_HEIGHT * 0.5 + BG_BOTTOM_HEIGHT * 0.5 - BG_BOTTOM_HEIGHT * 0.5)
        :addTo(self)

    -- title
    local title = display.newTTFLabel({text = bm.LangUtil.getText("LOGINREWARD", "TITLE"), color = cc.c3b(0xff, 0xff, 0xac),
        size = 30, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT * 0.5)
        :addTo(self)

    -- title bg left
    display.newSprite("#login_reward_title_bg_left.png")
        :pos(- title:getContentSize().width * 0.5 - 144 * 0.5 - 10, WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT * 0.5)
        :addTo(self)

    -- title bg right
    display.newSprite("#login_reward_title_bg_right.png")
        :pos(title:getContentSize().width * 0.5 + 144 * 0.5 + 10, WINDOW_HEIGHT * 0.5 - BG_TOP_HEIGHT * 0.5)
        :addTo(self)

    -- reward
    display.newTTFLabel({text = bm.LangUtil.getText("LOGINREWARD", "REWARD", nk.userData.loginReward.addMoney or 0),
        color = cc.c3b(0xff, 0xe9, 0x66), size = 36, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 180)
        :addTo(self)    

    -- reward - add
    display.newTTFLabel({text = bm.LangUtil.getText("LOGINREWARD", "REWARD_ADD"), color = cc.c3b(0xd9, 0x9b, 0x66),
        size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, 145)
        :addTo(self)

    -- reward detail
    for i=1, 6, 1 do
        local x = 70 + (i - 4) * 138
        local y = 0
        local mass
        if i <= nk.userData.loginReward.day then 
            -- bg
            display.newScale9Sprite("#login_reward_item_has_award.png", 0, 0, cc.size(130, 212))
            :pos(x, y + (212 - 170) * 0.5)
            :addTo(self)

            -- days 
            display.newTTFLabel({text = bm.LangUtil.getText("LOGINREWARD", "DAYS", (i)), color = cc.c3b(0xff, 0x00, 0x05), size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(x, y + 60)
            :addTo(self)

            -- reward
            display.newTTFLabel({text = "+" .. nk.userData.loginReward.days[i], color = cc.c3b(0xff, 0x00, 0x05), size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(x, y - 70)
            :addTo(self)

            -- chip mass
            mass = display.newSprite("#common_chip_mass_10"..(i - 1)..".png")
            :addTo(self)
            mass:pos(x, y - 50 + mass:getContentSize().height * 0.5)
        else
            -- bg
            display.newScale9Sprite("#login_reward_item_not_award.png", 0, 0, cc.size(130, 170))
            :pos(x, y)
            :addTo(self)

            -- days
            display.newTTFLabel({text = bm.LangUtil.getText("LOGINREWARD", "DAYS", (i)), color = cc.c3b(0xff, 0xba, 0x82), size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(x, y + 60)
            :addTo(self)

            -- reward
            display.newTTFLabel({text = "+" .. nk.userData.loginReward.days[i], color = cc.c3b(0x36, 0x03, 0x00), size = 24, align = ui.TEXT_ALIGN_CENTER})
            :pos(x, y - 70)
            :addTo(self)

            -- chip mass
            -- 很奇葩啊，:setOpacity提到前面就不行了
            mass = display.newSprite("#common_chip_mass_10"..(i - 1)..".png")
            :addTo(self)
            mass:pos(x, y - 50 + mass:getContentSize().height * 0.5)
            mass:setOpacity(255 * 0.3)
        end 

        if i == 6 then
            -- bg
            display.newSprite("#login_reward_item_add.png")
            :pos(x + 130 * 0.5, y + 170 * 0.5)
            :addTo(self)
        end    
    end

    -- prompt
    display.newTTFLabel({text = bm.LangUtil.getText("LOGINREWARD", "PROMPT", nk.userData.loginReward.days[6]), color = cc.c3b(0xdd, 0x92, 0x5c), size = 24, align = ui.TEXT_ALIGN_CENTER})
        :pos(0, -120)
        :addTo(self)

    -- share btn
    local btnWidthIntel = 450

    self.shareBtn_ = cc.ui.UIPushButton.new({normal = "#login_reward_share_btn_up.png", pressed = "#login_reward_share_btn_down.png"}, {scale9=true})
        :setButtonSize(200, 60)
        :setButtonLabel(display.newTTFLabel({text=bm.LangUtil.getText("COMMON", "PLAYGAME_NOW"), size=30, color=cc.c3b(0xd7, 0xf6, 0xff), align=ui.TEXT_ALIGN_CENTER}))
        :pos(- btnWidthIntel / 2, -210)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onShare))

    self.signInRewardBtn_ = cc.ui.UIPushButton.new({normal = "#login_reward_share_btn_up.png", pressed = "#login_reward_share_btn_down.png"}, {scale9 = true})
        :setButtonSize(200, 60)
        :setButtonLabel(display.newTTFLabel({text = bm.LangUtil.getText("HALL", "SIGN_IN"), size = 30, color = cc.c3b(0xd7, 0xf6, 0xff), align = ui.TEXT_ALIGN_CENTER}))
        :onButtonClicked(buttontHandler(self, self.onSignInClkCallBack))
        :pos(btnWidthIntel / 2, - 210)
        :addTo(self)

    -- 播放动画期间触摸边上不让弹框关闭
    self.canClose_ = false
    self:playRewardAnim()
end

-- todo
function LoginRewardView:onShare()

    -- 去除分享！
    -- if nk.userData.loginReward.addMoney then
    --     self.shareBtn_:setButtonEnabled(false)

    --      -- local feedData = clone(bm.LangUtil.getText("FEED", "LOGIN_REWARD"))
    --      -- feedData.name = bm.LangUtil.formatString(feedData.name, nk.userData.loginReward.addMoney)
    --      -- nk.Facebook:shareFeed(feedData, function(success, result)
    --      --     logger:debug("FEED.LOGIN_REWARD result handler -> ", success, result)
    --      --     if not success then
    --      --         self.shareBtn_:setButtonEnabled(true)
    --      --         nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
    --      --     else
    --      --         nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
    --      --     end
    --      -- end)

    --     nk.sendFeed:login_reward_(function()
    --         self.shareBtn_:setButtonEnabled(true)
    --     end)
    -- end

    self:hide_()
    nk.server:quickPlay()
end

function LoginRewardView:onSignInClkCallBack()
    -- body

    SignInContPopup.new():show()
    self:hide_()
end

function LoginRewardView:show_(callback)
    self.callback_ = callback
    nk.PopupManager:addPopup(self, true,true,true,true)
    return self
end

function LoginRewardView:hide_()
    self.canClose_ = true
    nk.PopupManager:removePopup(self)
    return self
end

function LoginRewardView:onRemovePopup(removeFunc)

    if self.callback_ then
        self.callback_({action = "action_close"})
    end
    
    if self.canClose_ then
        removeFunc()
        display.removeSpriteFramesWithFile("loginreward_texture.plist", "loginreward_texture.png")
    end
end

function LoginRewardView:playRewardAnim()
    if nk.userData.loginReward.ret == 1 then
        --保证第二次打开不播动画
        nk.userData.loginReward.ret = -1

        -- Already Get Reward, Modify To Unget State.
        -- nk.userData["aUser.money"] = nk.userData["aUser.money"] - checkint(nk.userData.loginReward.addMoney)

        self:performWithDelay(function ()
                    self.canClose_ = true 
                    nk.userData["aUser.money"] = nk.userData["aUser.money"] + checkint(nk.userData.loginReward.addMoney or 0)
                end, 1.5)    
        self.animation_ = CommonRewardChipAnimation.new()
            :addTo(self)
        self.changeChipAnim_ = nk.ui.ChangeChipAnim.new(checkint(nk.userData.loginReward.addMoney))
            :addTo(self)

    end
        
end


return LoginRewardView