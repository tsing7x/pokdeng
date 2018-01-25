-- Author: thinkeras3@163.com
-- Date: 2015-08-11 17:31:50
-- Copyright: Copyright (c) 2015, BOYAA INTERACTIVE CO., LTD All rights reserved.
-- 获得奖励框
local Panel = import("app.pokerUI.Panel")
local CornuGetSeedPopup = class("CornuGetSeedPopup", Panel)

local DEFAULT_WIDTH = 580
local DEFAULT_HEIGHT = 400
local TOP_HEIGHT = 68
local PADDING = 32
local BTN_HEIGHT = 72

function CornuGetSeedPopup:ctor(updatefun)
    self.updateFun_ = updatefun
     cc.Director:getInstance():getTextureCache():removeUnusedTextures()
     self:setNodeEventEnabled(true)
     self:setTouchSwallowEnabled(false)
	 CornuGetSeedPopup.super.ctor(self, {580,400})
     self:addCloseBtn()--

     display.newScale9Sprite("#cor_words_bg.png", 0, 0, cc.size(self.width_ - PADDING * 0.5, self.height_ - PADDING * 0.25 - TOP_HEIGHT))
     :addTo(self)
     :pos(0,-30)

     display.newTTFLabel({
            text = bm.LangUtil.getText("DORNUCOPIA","GETEDREWARD_TITLE"),
            color = styles.FONT_COLOR.LIGHT_TEXT,
            size = 26,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :pos(0, self.height_ * 0.5 - TOP_HEIGHT * 0.5)
       	:addTo(self)

    self.secondBtn_ = cc.ui.UIPushButton.new({normal = "#common_green_btn_up.png", pressed = "#common_green_btn_down.png"}, {scale9 = true})
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.onButtonClick_))
        :setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("WHEEL","SHARE"), color = styles.FONT_COLOR.LIGHT_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER}))
        :setButtonLabel("pressed", display.newTTFLabel({text = bm.LangUtil.getText("WHEEL","SHARE"), color = styles.FONT_COLOR.GREY_TEXT, size = 30, align = ui.TEXT_ALIGN_CENTER}))

    local buttonWidth = 280
    self.secondBtn_:setButtonSize(buttonWidth, BTN_HEIGHT):pos(0, -DEFAULT_HEIGHT * 0.5 + PADDING + BTN_HEIGHT * 0.5)

    	-- display.newTTFLabel({
     --        text = bm.LangUtil.getText("DORNUCOPIA","GETEDREWARD_BUTTOM_TIP"),
     --        color = styles.FONT_COLOR.LIGHT_TEXT,
     --        size = 20,
     --        align = ui.TEXT_ALIGN_CENTER,
     --    })
     --   	:addTo(self)
     --   	:pos(0,-175)
end
function CornuGetSeedPopup:onButtonClick_()
  if self.seedType_ == 1 then


       -- local feedData = clone(bm.LangUtil.getText("FEED", "COR_GETED_INGOT"))
       --        nk.Facebook:shareFeed(feedData, function(success, result)
       --        print("FEED.FREE_COIN result handler -> ", success, result)
       --        if not success then
       --            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
                  
       --         else
       --            nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS"))
       --            self.controller_:shareToGetSeed(2)  
       --         end
       --    end)
        nk.sendFeed:get_ingot_(handler(self,function(obj)
                    obj:shareToGetSeed(2)
                  end),function( ... )
                    self.onClose()
                  end)



  elseif self.seedType_ == 2 then

      -- local feedData = clone(bm.LangUtil.getText("FEED", "COR_GETED_SILVER"))
      --       nk.Facebook:shareFeed(feedData, function(success, result)
      --       print("FEED.FREE_COIN result handler -> ", success, result)
      --       if not success then
      --           nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
               
      --        else
      --          self.parent_.controller_:shareToGetSeed(3)
      --           nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS")) 
      --        end
      --   end)
      nk.sendFeed:get_silver_(handler(self,function(obj)
                obj:shareToGetSeed(3)
              end),function()
                self:onClose()
              end)


    
  else
    


    -- local feedData = clone(bm.LangUtil.getText("FEED", "COR_GETED_SPEED_WATER"))
    --         nk.Facebook:shareFeed(feedData, function(success, result)
    --         print("FEED.FREE_COIN result handler -> ", success, result)
    --         if not success then
    --             nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_FAILED"))
               
    --          else
    --            self.parent_.controller_:shareToGetSeed(4)
    --             nk.TopTipManager:showTopTip(bm.LangUtil.getText("FEED", "SHARE_SUCCESS")) 
    --          end
    --     end)
    nk.sendFeed:use_speed_(
      handler(self,function(obj)
              obj:shareToGetSeed(4)
            end),function( ... )
              self:onClose()
            end
      )
  end
end
function CornuGetSeedPopup:show(seedType)
  self.seedType_ = seedType;
	self:showPanel_()

	local pictrue;
	local str;
     if seedType == 1 then
          pictrue= display.newSprite("#cor_ingot.png")
         str = bm.LangUtil.getText("DORNUCOPIA","GETREWARD_TXT1")
     elseif seedType==2 then
          pictrue= display.newSprite("#cor_silver.png")
          str = bm.LangUtil.getText("DORNUCOPIA","GETREWARD_TXT2")
     else
          pictrue= display.newSprite("#cor_water.png")
          str = bm.LangUtil.getText("DORNUCOPIA","GETREWARD_TXT3")
     end
      display.newTTFLabel({text = str, color = cc.c3b(0xC7, 0xE5, 0xFF), size = 24, dimensions=cc.size(300, 140),align = ui.TEXT_ALIGN_LEFT})
      :addTo(self)
      :pos(50,0)
     pictrue:addTo(self)
     pictrue:pos(-180,0)
end

function CornuGetSeedPopup:shareToGetSeed(mode)
  local uid = nk.userData["aUser.mid"]
  self.shareToGetSeedRequest_ = nk.http.shareToGetSeed(
    uid,
    mode,
    function(data)
      if data and data.getseed then
        if checkint(data.getseed)==1 then
          nk.TopTipManager:showTopTip(bm.LangUtil.getText("DORNUCOPIA", "GETED_SILVER"))
          if self.updateFun_ then
            self.updateFun_()
          end
          
        end
      end

      self:onClose()
    end,
    function(errorCode)
        self:onClose()
    end

  )
end
return CornuGetSeedPopup