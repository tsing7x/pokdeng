--
-- Author: Jonah0608@gmail.com
-- Date: 2015-08-13 15:53:06
--
local PokdengAdPopup = class("PokdengAdPopup",function()
    return display.newNode()
end)

local WIDTH = 650
local HEIGHT = 415

function PokdengAdPopup:ctor()
    self:setupView()
end

function PokdengAdPopup:setupView()
    display.newScale9Sprite("#pokdeng_ad_popup_bg.png", 0, 0, cc.size(WIDTH, HEIGHT)):addTo(self)
    
    local closeBtnWidth = 52
    local closeBtnHeight = 52
    cc.ui.UIPushButton.new({normal="#pokdeng_ad_popup_close_btn.png"})
        :addTo(self)
        :pos((WIDTH - closeBtnWidth)/2,(HEIGHT - closeBtnHeight) / 2)
        :onButtonClicked(function()
                self:onCloseBtnListener_()
            end)

    display.newSprite("#pokdeng_ad_popup_title.png")
        :pos(0, HEIGHT / 2 - 27)
        :addTo(self)
    display.newSprite("#pokdeng_ad_popup_content.png")
        :pos(0,-10)
        :addTo(self)
    display.newSprite("#pokdeng_ad_popup_girl.png")
        :pos(-260,30)
        :addTo(self)

    local goMarketTime = nk.userDefault:getStringForKey("AD_GO_MARKET_TIME","0")
    local rewardTime = nk.userDefault:getStringForKey("AD_GET_REWARD_TIME" , "0")
    local status = "gomarket"

    local duringtime = os.time() - tonumber(goMarketTime)

    if tonumber(goMarketTime) > 0 and duringtime > 60 * 10 then
        status = "getreward"
    end

    if tonumber(rewardTime) > 0 then
        status = "rewardOK"
    end

    if status == "gomarket" then
        self.goMarketBtn_ = cc.ui.UIPushButton.new({normal="#pokdeng_ad_popup_go_market.png"})
            :pos(50,-90)
            :addTo(self)
            :onButtonClicked(function()
                    self:onGoMarketClicked_()
                end)
    elseif status == "getreward" then
        self.getRewardBtn_ = cc.ui.UIPushButton.new({normal="#pokdeng_ad_popup_getreward.png"})
            :pos(50,-90)
            :addTo(self)
            :onButtonClicked(function()
                    self:getRewardClicked_()
                end)
    elseif status == "rewardOK" then
        cc.ui.UIPushButton.new({normal="#pokdeng_ad_popup_getreward_ok.png"})
            :pos(50,-90)
            :addTo(self)
    end

end


function PokdengAdPopup:onGoMarketClicked_()
    local time = os.time()
    nk.userDefault:setStringForKey("AD_GO_MARKET_TIME",tostring(time))
    device.openURL("https://play.google.com/store/apps/details?id=com.boomegg.nineke")
    self:hide()
end

function PokdengAdPopup:getRewardClicked_()
    self.rewardRequest_ = nk.http.getPokdengAdReward(
        function(data)
            if data ~= nil then
                local money = data.money
                local addMoney = data.addMoney

                if addMoney > 0 then
                    str = bm.LangUtil.getText("POKDENG_AD","REWARD_SUCC",addMoney or 0)
                    self:getRewardSucc_()
                    nk.TopTipManager:showTopTip(str)
                end

            end
        end,
        function(errData)
            if errData and (checkint(errData.errorCode) == -2) then
                local str1 = bm.LangUtil.getText("POKDENG_AD","REWARD_EVER")
                self:getRewardSucc_()
                nk.TopTipManager:showTopTip(str1)
            else
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("POKDENG_AD","REWARD_FAIL"))
            end  
        end
        )
end

function PokdengAdPopup:getRewardSucc_()
    local time = os.time()
    nk.userDefault:setStringForKey("AD_GET_REWARD_TIME",tostring(time))
    if self.getRewardBtn_ then
        self.getRewardBtn_:hide()
    end
    cc.ui.UIPushButton.new({normal="#pokdeng_ad_popup_getreward_ok.png"})
            :pos(50,-90)
            :addTo(self)

end

function PokdengAdPopup:onCloseBtnListener_()
    self:hide()
end

function PokdengAdPopup:show()
    nk.PopupManager:addPopup(self)
    return self
end

function PokdengAdPopup:hide()
    nk.PopupManager:removePopup(self)
    return self
end

function PokdengAdPopup:onShowed()
end

function PokdengAdPopup:onCleanup()
end

return PokdengAdPopup