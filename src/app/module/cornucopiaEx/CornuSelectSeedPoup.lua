-- Author: thinkeras3@163.com
-- Date: 2015-08-11 17:31:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 选择种子框
local Panel = import("app.pokerUI.Panel")
local CornuSelectSeedPoup = class("CornuSelectSeedPoup", Panel)
local DEFAULT_WIDTH = 540
local DEFAULT_HEIGHT = 360
local TOP_HEIGHT = 68
local PADDING = 32
local BTN_HEIGHT = 72
function CornuSelectSeedPoup:ctor(data,callback)
    self.data_= data
    self.callback_ = callback
   -- self.parent_ = parent
     cc.Director:getInstance():getTextureCache():removeUnusedTextures()
     self:setNodeEventEnabled(true)
     self:setTouchSwallowEnabled(false)
	 CornuSelectSeedPoup.super.ctor(self, {540,360})
     self:addCloseBtn()
     display.newScale9Sprite("#cor_words_bg.png", 0, 0, cc.size(self.width_ - PADDING * 0.5, self.height_ - PADDING * 0.25 - TOP_HEIGHT))
     :addTo(self)
     :pos(0,-30)

     display.newTTFLabel({
            text = bm.LangUtil.getText("DORNUCOPIA","SELECT_SEED_TITLE"),
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 26,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :pos(0, self.height_ * 0.5 - TOP_HEIGHT * 0.5)
       	:addTo(self)

       	cc.ui.UIPushButton.new("#cor_ingot.png")
       	:pos(-120,0)
       	:addTo(self)
       	:onButtonClicked(buttontHandler(self,self.ingotSeedClick_))
       	cc.ui.UIPushButton.new("#cor_silver.png")
       	:pos(120,0)
       	:addTo(self)
       	:onButtonClicked(buttontHandler(self,self.silverSeedClick_))

       	display.newTTFLabel({
            text = bm.LangUtil.getText("DORNUCOPIA","LEFT_NUM",self.data_.jininfo.num),
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 22,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :pos(-120,-70)
        :addTo(self)

        display.newTTFLabel({
            text = bm.LangUtil.getText("DORNUCOPIA","LEFT_NUM",self.data_.yininfo.num),
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 22,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :pos(120,-70)
        :addTo(self)
end
function CornuSelectSeedPoup:show(id)
  self.tid = id;
	self:showPanel_()
end
function CornuSelectSeedPoup:ingotSeedClick_()
  if self.data_.jininfo.num == 0 then
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA","NOT_SEED"))
    return
  end
    --self.parent_.controller_:plantSeed(self.tid,402)
    self.callback_(402)
    self:onClose()
end

function CornuSelectSeedPoup:silverSeedClick_()
  if self.data_.yininfo.num == 0 then
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA","NOT_SEED"))
    return
  end
    self.callback_(401)
  --self.parent_.controller_:plantSeed(self.tid,401)
   self:onClose()
end
return CornuSelectSeedPoup