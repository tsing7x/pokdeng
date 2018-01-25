--
-- Author: thinkeras3@163.com
-- Date: 2015-11-18 09:57:32
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- Description: 道具item
--
local WIDTH = 238
local HEIGHT = 202
local LOAD_IMG_TAG = 111
local PropsListItem = class("PropsListItem", bm.ui.ListItem)
local TabPageContSize = {
    width = 725,
    height = 246,
}
function PropsListItem:ctor()
	self:setNodeEventEnabled(true)
	PropsListItem.super.ctor(self, WIDTH, HEIGHT)
	self:createNode_()
    self.propImageLoaderId_ = nk.ImageLoader:nextLoaderId()
end
function PropsListItem:createNode_( ... )
	-- 互动道具
    local propIconPaddingLeft = 15
    local propIconPosYShift = 23

    local propIconPosXScaleShift = 20
    self.propIcon_ = display.newSprite("#userInfo_bgPropItem.png")
    self.propIcon_:pos(WIDTH/2,HEIGHT/2)
        :addTo(self)

     self.propIcon_:scale(0.86)
    -- 互动道具图标
    self.PropIcon_ = display.newSprite("#common_transparent_skin.png")
        :pos(self.propIcon_:getContentSize().width * 0.5, self.propIcon_:getContentSize().height * 0.5 + 30)
        :addTo(self.propIcon_)

    -- 道具使用
    self.propUseButton_ = cc.ui.UIPushButton.new({normal = "#userInfo_btnBlue_nor.png" , pressed = "#userInfo_btnBlue_pres.png"}, {scale9 = true})
        :setButtonSize(225, 40)
        :setButtonLabel("normal",display.newTTFLabel({text = bm.LangUtil.getText("STORE","USE"), color = cc.c3b(0xC7, 0xE5, 0xFF), size = 26, align = ui.TEXT_ALIGN_CENTER}))
        :pos(self.propIcon_:getContentSize().width * 0.5, 20)
        :onButtonClicked(buttontHandler(self, self._onUsePropQuickPlay))
        :addTo(self.propIcon_)


    -- 道具标签
    self.propLabel_ = display.newTTFLabel({text = bm.LangUtil.getText("BANK", "BANK_DROP_LABEL"), color = cc.c3b(0x27, 0x90, 0xd5), size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(self.propIcon_:getContentSize().width * 0.5, 65)
        :addTo(self.propIcon_)

    -- 道具数量
    self.propNumberLabel_ = display.newTTFLabel({text = "" , color = styles.FONT_COLOR.GOLDEN_TEXT, size = 26, align = ui.TEXT_ALIGN_CENTER})
        :pos(self.propIcon_:getContentSize().width * 0.5 + 70, 170)
        :addTo(self.propIcon_)

    local propBottomBlockSize = {
        width = TabPageContSize.width,
        height = 48
    }
    -- local propBottomBlock = display.newScale9Sprite("#userInfo_blockBottomDent_2.png", TabPageContSize.width / 2, 
    --     propBottomBlockSize.height / 2, cc.size(propBottomBlockSize.width, propBottomBlockSize.height))
    --     :addTo(self)

    -- local propBottomLabelParam = {
    --     frontSizes = {
    --         desc = 18,
    --         btn = 16
    --     },

    --     colors = {
    --         desc = cc.c3b(121, 121, 121),
    --         btn = display.COLOR_WHITE
    --     }
    -- }

    -- local propDescBottomMagrinLeft = 25
    -- local propDescBottomLabel = display.newTTFLabel({text = bm.LangUtil.getText("USERINFO", "GIFT_BOTTOMTIP"), size = propBottomLabelParam.frontSizes.desc,
    --     color = propBottomLabelParam.colors.desc, align = ui.TEXT_ALIGN_CENTER})
    -- propDescBottomLabel:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER_LEFT])
    -- propDescBottomLabel:pos(propDescBottomMagrinLeft, propBottomBlockSize.height / 2)
    --     propDescBottomLabel:addTo(propBottomBlock)

end
function PropsListItem:onCleanup()
    nk.ImageLoader:cancelJobByLoaderId(self.propImageLoaderId_)
    nk.http.cancel(self.setGiftRequestId_)
end
function PropsListItem:setData(data)
    local propdata = nk.Props:getPropDataByPnid(data.pnid)
    self.itemData_ = propdata

    local oldAvatar = self.PropIcon_:getChildByTag(LOAD_IMG_TAG)
    if oldAvatar then
        oldAvatar:removeFromParent()
    end

    if propdata then
        self.propLabel_:setString(propdata.name.."")
        self.propNumberLabel_:setString("X "..data.pcnter)

         nk.ImageLoader:loadAndCacheImage(
                    self.propImageLoaderId_, 
                    propdata.image, 
                    function(success,sprite)
                        if success then
                            local tex = sprite:getTexture()
                            local texSize = tex:getContentSize()
                            -- self.PropIcon_:setTexture(tex)
                            -- self.PropIcon_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
                            -- self.PropIcon_:setScaleX(90 / texSize.width)
                            -- self.PropIcon_:setScaleY(75 / texSize.height)
                            --self.avatarLoaded_ = true
                            local xxScale = 90/texSize.width
                            local yyScale = 75/texSize.height
                            sprite:scale(xxScale<yyScale and xxScale or yyScale)
                            :addTo(self.PropIcon_,0,LOAD_IMG_TAG)
                        end
                    end, 
                    nk.ImageLoader.CACHE_TYPE_USER_HEAD_IMG
                )
    end
end
function PropsListItem:_onUsePropQuickPlay(evt)
    if self.itemData_ then 

        -- dump(self.itemData_, "self.itemData_:=============") 
        -- self.owner_.useSuonaBroad()
        --1 礼物  2 互动道具 3 小喇叭（还没上线） 4 元宝  5加速剂 6 种种植的盘  7比赛劵  8实物兑换券

        --需要根据不同的礼物类别，使用时作出相应的跳转

        --目前背包里面只战士2,7,8类道具

        --后续有需求，需要更改其他跳转
        if tonumber(self.itemData_.pcid) == 1 then
            self:setGift(self.itemData_)
        elseif tonumber(self.itemData_.pcid) == 2 then
            self.owner_.quickPlay()
        elseif tonumber(self.itemData_.pcid) == 3 then
            self.owner_.useSuonaBroad()
        elseif tonumber(self.itemData_.pcid) == 4 then
            self.owner_.quickPlay()
        elseif tonumber(self.itemData_.pcid) == 5 then
            self.owner_.quickPlay()
        elseif tonumber(self.itemData_.pcid) == 6 then
            self.owner_.quickPlay()
        elseif tonumber(self.itemData_.pcid) == 7 then
            self.owner_.enterChooseMatch()
        elseif tonumber(self.itemData_.pcid) == 8 then
            self.owner_.enterScoreMarket()
        end
    end
end
function PropsListItem:setGift(data)
    self.giftid = data.pnid
    self.setGiftRequestId_  = nk.http.useProps(self.giftid, function(data)
                    -- local callBackBuyData =  json.decode(data)
                    -- dump(data,"data:===============")
                    nk.http.cancel(self.setGiftRequestId_)
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_SUCCESS_TOP_TIP"))
                    nk.userData["aUser.gift"] = self.giftid
                    self.owner_.changeRoomGift()
                end,function()
                    nk.http.cancel(self.setGiftRequestId_)
                    nk.TopTipManager:showTopTip(bm.LangUtil.getText("GIFT", "SET_GIFT_FAIL_TOP_TIP"))
                    
                end)
end
return PropsListItem