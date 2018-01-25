local CornuHomePageView = class("CornuHomePageView", 
function()
	return display.newNode() 
end)

local NOTICE_WIDTH = 240
local NOTICE_HEIGHT = 134

local MESSAGE_HEIGHT = 293
local NOTICE_TITLE_H = 26

local WIDTH = 842
local HEIGHT = 444

local WORDS_BG_WIDTH = 154
local WORDS_BG_HEIGHT = 32

local CornuMessageBoardItem = import(".CornuMessageBoardItem")
local CornuFarmView = import(".CornuFarmView")
function CornuHomePageView:ctor(parent)
    self.parent_ = parent
	self:setNodeEventEnabled(true)

	--我的公告

    self.myNoticeEx_ = display.newNode()
    :align(display.TOP_LEFT)
    :pos(-WIDTH/2+NOTICE_WIDTH/2 +10,HEIGHT/2-NOTICE_HEIGHT/2-5)
    :addTo(self)
    :hide()

    self.notice_bgEx_ = display.newScale9Sprite("#cor_small_bg_ex.png", 0, 0, cc.size(NOTICE_WIDTH,NOTICE_HEIGHT))
     :addTo(self.myNoticeEx_)
     self.notice_titleEx_ = display.newScale9Sprite("#cor_small_title_ex.png", 0, 0, cc.size(NOTICE_WIDTH,NOTICE_TITLE_H))
     :addTo(self.myNoticeEx_)
     :pos(0,NOTICE_HEIGHT/2-NOTICE_TITLE_H/2)

	self.myNotice_ = display.newNode():addTo(self)
	:align(display.TOP_LEFT)
	:pos(-WIDTH/2+NOTICE_WIDTH/2 +10,HEIGHT/2-NOTICE_HEIGHT/2-5)

    

	self.notice_bg_ = display.newScale9Sprite("#cor_small_bg.png", 0, 0, cc.size(NOTICE_WIDTH,NOTICE_HEIGHT))
    :addTo(self.myNotice_)
    self.notice_title_ = display.newScale9Sprite("#cor_small_title.png", 0, 0, cc.size(NOTICE_WIDTH,NOTICE_TITLE_H))
    :addTo(self.myNotice_)
    :pos(0,NOTICE_HEIGHT/2-NOTICE_TITLE_H/2)

     
    --cc.c3b(0x5A, 0x7C, 0xAE)
    display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","HOMEPAGE")[1], color = cc.c3b(0xff, 0xff, 0xff), size = 20,dimensions = cc.size(NOTICE_WIDTH, 0), align = ui.TEXT_ALIGN_CENTER})
    :addTo(self.myNotice_)
    :pos(0,NOTICE_HEIGHT/2-NOTICE_TITLE_H/2)

    self.myNoticeText_ = display.newTTFLabel({text = "", color = cc.c3b(0xff, 0xff, 0xff), size = 20,dimensions = cc.size(NOTICE_WIDTH, NOTICE_HEIGHT-2*NOTICE_TITLE_H), align = ui.TEXT_ALIGN_LEFT})
    :addTo(self.myNotice_)
    :align(display.TOP_LEFT)
    :pos(-NOTICE_WIDTH/2,NOTICE_HEIGHT/2-NOTICE_TITLE_H)

    self.editBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(110, 25)
    :align(display.TOP_LEFT)
    :pos(0,-NOTICE_HEIGHT/2 + 25)
   -- :onButtonClicked(buttontHandler(self, self.onEditBtn_))
    :setButtonLabel("normal", display.newTTFLabel({text = T("重新编辑>>"), color = cc.c3b(0xff,0xff,0xff), size = 20, align = ui.TEXT_ALIGN_CENTER}))
    :addTo(self.myNotice_)

    self.confirmBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
    :setButtonSize(110, 25)
    :align(display.TOP_LEFT)
    :pos(0,-NOTICE_HEIGHT/2 + 25)
    :onButtonClicked(buttontHandler(self, self.confirmTextBtn_))
    :setButtonLabel("normal", display.newTTFLabel({text = T("确认提交>>"), color = cc.c3b(0xff,0xff,0xff), size = 20, align = ui.TEXT_ALIGN_CENTER}))
    :addTo(self.myNotice_)
    :hide()

    self.noticeEdit_ = cc.ui.UIInput.new({image = "#common_transparent_skin.png",listener = handler(self, self.onNoticeEdit_), size = cc.size(110, 25)})
        :align(display.TOP_LEFT)
        --:pos(-NOTICE_WIDTH/2,NOTICE_HEIGHT/2-NOTICE_TITLE_H)
        :pos(0,-NOTICE_HEIGHT/2 + 25)
        :addTo(self.myNotice_)
    self.noticeEdit_:setFont(ui.DEFAULT_TTF_FONT, 20)
    self.noticeEdit_:setPlaceholderFont(ui.DEFAULT_TTF_FONT, 20)
    self.noticeEdit_:setMaxLength(128)
    self.noticeEdit_:setPlaceholderFontColor(cc.c3b(0x89, 0xa2, 0xc6))
    self.noticeEdit_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.noticeEdit_:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.noticeEdit_:setPlaceHolder("")
    --self.noticeEdit_:hide()


    --好友留言
    self.myMessage_ = display.newNode():addTo(self)
	:align(display.TOP_LEFT)
	:pos(-WIDTH/2+NOTICE_WIDTH/2 +10,HEIGHT/2-MESSAGE_HEIGHT/2-10 -NOTICE_HEIGHT)

	display.newScale9Sprite("#cor_small_bg.png", 0, 0, cc.size(NOTICE_WIDTH,MESSAGE_HEIGHT))
    :addTo(self.myMessage_)
    display.newScale9Sprite("#cor_small_title.png", 0, 0, cc.size(NOTICE_WIDTH,NOTICE_TITLE_H))
    :addTo(self.myMessage_)
    :pos(0,MESSAGE_HEIGHT/2-NOTICE_TITLE_H/2)

     display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","HOMEPAGE")[2], color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(NOTICE_WIDTH, 0), align = ui.TEXT_ALIGN_CENTER})
    :addTo(self.myMessage_)
    :pos(0,MESSAGE_HEIGHT/2-NOTICE_TITLE_H/2)

    

    local headSprite = display.newNode()
    :addTo(self)
    :pos(-190,180)
    :scale(1.1)
    local posY = 0
    -- 头像
    self.avatar_ = display.newSprite("#common_male_avatar.png")
        :scale(57 / 100)
        :pos(60, posY)
        :addTo(headSprite)
    self.avatarBg_ = display.newSprite("#ranking_avatar_bg.png")
        :pos(60, posY)
        :addTo(headSprite)
    self.genderIcon_ = display.newSprite("#male_icon.png")
        :pos(84, posY - 20)
        :addTo(headSprite)
        :scale(0.8)
    self.userAvatarLoaderId_ = nk.ImageLoader:nextLoaderId() -- 头像加载id


    if checkint(nk.userData["aUser.msex"]) ~= 1 then
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("female_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    else
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("male_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
    end
    local imgurl = nk.userData["aUser.micon"]
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





    local posX = -80
    self.goldWordsBg_ = display.newScale9Sprite("#cor_words_bg.png",0,0,cc.size(WORDS_BG_WIDTH,WORDS_BG_HEIGHT))
    :addTo(self)
    :align(display.TOP_LEFT)
    :pos(posX,213)

    self.silverWordBg_ = display.newScale9Sprite("#cor_words_bg.png",0,0,cc.size(WORDS_BG_WIDTH,WORDS_BG_HEIGHT))
    :addTo(self)
    :align(display.TOP_LEFT)
    :pos(posX+WORDS_BG_WIDTH+10,213)

    self.quickPotionBg_ = display.newScale9Sprite("#cor_words_bg.png",0,0,cc.size(WORDS_BG_WIDTH,WORDS_BG_HEIGHT))
    :addTo(self)
    :align(display.TOP_LEFT)
    :pos(posX+2*WORDS_BG_WIDTH+20,213)

    self.coinWordsBg_ = display.newScale9Sprite("#cor_words_bg.png",0,0,cc.size(WORDS_BG_WIDTH,WORDS_BG_HEIGHT))
    :addTo(self)
    :align(display.TOP_LEFT)
    :pos(posX,175)


    display.newSprite("#cor_gold_seed.png")
    :addTo(self.goldWordsBg_)
   	:pos(30,25)

   	display.newSprite("#cor_sliver_seed.png")
    :addTo(self.silverWordBg_)
   	:pos(25,20)

   	display.newSprite("#cor_quick_potion.png")
    :addTo(self.quickPotionBg_)
   	:pos(30,20)

   	display.newSprite("#cor_coin_icon.png")
    :addTo(self.coinWordsBg_)
   	:pos(25,20)

   	self.goldSeedTxt_ = display.newTTFLabel({text = "0", color = cc.c3b(0xef,0xc4,0x0d), size = 20, align = ui.TEXT_ALIGN_LEFT})
   	:align(display.CENTER_LEFT)
   	:addTo(self.goldWordsBg_)
   	:pos(60,16)

   	self.silverSeedTxt_ = display.newTTFLabel({text = "0", color = cc.c3b(0x6d,0xba,0xff), size = 20, align = ui.TEXT_ALIGN_LEFT})
   	:align(display.CENTER_LEFT)
   	:addTo(self.silverWordBg_)
   	:pos(60,16)

   	self.quickPotionTxt_ = display.newTTFLabel({text = "0", color = cc.c3b(0x57,0xea,0xff), size = 20, align = ui.TEXT_ALIGN_LEFT})
   	:align(display.CENTER_LEFT)
   	:addTo(self.quickPotionBg_)
   	:pos(60,16)

   	self.myCoinTxt_ = display.newTTFLabel({text = "0", color = cc.c3b(0xff,0x42,0x0a), size = 20, align = ui.TEXT_ALIGN_LEFT})
   	:align(display.CENTER_LEFT)
   	:addTo(self.coinWordsBg_)
   	:pos(60,16)


   	self.farmView_ = CornuFarmView.new(self,1)
   	:addTo(self)
   	:pos(124,-40)




   	self:onShowed()


    
end

function CornuHomePageView:onItemEvent_(evt)
    local mid = evt.data.mid
    self.parent_:goFriendById(mid)
end
function CornuHomePageView:onShowed()
	local LIST_HEIGHT = MESSAGE_HEIGHT - NOTICE_TITLE_H
	if self.list_ then
		self.list_:removeFromParent()
		self.list_ = nil
	end
	self.list_ = bm.ui.ListView.new(
    		{
                viewRect = cc.rect(-NOTICE_WIDTH * 0.5, -LIST_HEIGHT * 0.5, NOTICE_WIDTH, LIST_HEIGHT)
            }, 
            CornuMessageBoardItem
    )
    :addTo(self.myMessage_)
    --:pos(NOTICE_WIDTH/2,-LIST_HEIGHT/2)
    :pos(0,-10)

    self.list_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))

    self:setNoticeLoading(true)
    self.requestMyNotice_ = nk.http.getNotice(nk.userData["aUser.mid"],
        function(data)
            self:setNoticeLoading(false)
            if data.notice == nil then
                data.notice = T("欢迎来到我这农场")
            end
            self.myNoticeText_:setString(""..data.notice)
        end,
        function(errordata)

        end
    )

    self:setMessageLoading(true)
    self.getFriendsMesaage_ = nk.http.getFriendsMessage(
        nk.userData["aUser.mid"],
        function(data)
            self:setMessageLoading(false)
            self.list_:setData(data)
            self.list_:update()
        end,

        function(errordata)

        end

    )
    self:getSelfCor()
end
function CornuHomePageView:getSelfCor()
    self.myCoinTxt_:setString(bm.formatNumberWithSplit(nk.userData["aUser.money"]))
    self.farmView_:setLoading(true)
    self.getMyCorRequest_ = nk.http.getSelfCornucopia(nk.userData["aUser.mid"],
        function(data)
            self.farmView_:setLoading(false)
            self.farmView_:setMyBlow(data)
            self.goldSeedTxt_:setString(""..data.jininfo.num)
            self.silverSeedTxt_:setString(""..data.yininfo.num)
            self.quickPotionTxt_:setString(''..data.shortinfo.num)
        end,

        function(errordata)

        end
    )
end

function CornuHomePageView:onCleanup()
    nk.http.cancel( self.requestMyNotice_)
    nk.http.cancel( self.setNoticeRequest_)
    nk.http.cancel( self.getFriendsMesaage_)
    nk.http.cancel( self.getMyCorRequest_)
end
function CornuHomePageView:onNoticeEdit_(event)
    if event == "began" then
        -- 开始输入

        self.notice_bg_:hide()
         --self.notice_bgEx_:show()
         self.notice_title_:hide()
        -- self.notice_titleEx_:show()
        self.myNoticeEx_:show()




        self.editBtn_:hide()
         self.noticeEdit_:hide()
         self.confirmBtn_:show()
         
         


    elseif event == "changed" then
        -- 输入框内容发生变化self.addressEdit_

        -- self.notice_bg_:hide()
        --  --self.notice_bgEx_:show()
        --  self.notice_title_:hide()
        -- -- self.notice_titleEx_:show()
        -- self.myNoticeEx_:show()
       

         local text = self.noticeEdit_:getText()
         self.changeText_ = text
         self.myNoticeText_:setString(text)
         -- self.noticeEdit_:setText("")

         -- self.editBtn_:hide()
         -- self.noticeEdit_:hide()
         -- self.confirmBtn_:show()

         

    elseif event == "ended" then
        -- 输入结束
        self.noticeEdit_:setText("")
    elseif event == "return" then
        -- 从输入框返回
        -- print(self.editAddress_)
        self.noticeEdit_:setText("")
    end
end
function CornuHomePageView:onEditBtn_()
	-- self.noticeEdit_:show()
	-- self.confirmBtn_:show()
	-- self.myNoticeText_:hide()
	-- self.editBtn_:hide()
end
function CornuHomePageView:confirmTextBtn_()
	self.noticeEdit_:show()
	self.confirmBtn_:hide()
	self.editBtn_:show()

    self.notice_bg_:show()
    --self.notice_bgEx_:hide()
    self.notice_title_:show()
    --self.notice_titleEx_:hide()
    self.myNoticeEx_:hide()

	self:setNoticeLoading(true)

    self.setNoticeRequest_ = nk.http.setNotice(self.changeText_,
        function()
            self:setNoticeLoading(false)
        end,
        function()

        end
    )
end

function CornuHomePageView:setNoticeLoading(isLoading)
    if isLoading then
        if not self.notice_juhua_ then
            self.notice_juhua_ = nk.ui.Juhua.new()
                --:pos(NOTICE_WIDTH/2, NOTICE_HEIGHT/2+20)
                :addTo(self.myNotice_)
                :scale(.5)
        end
    else
        if self.notice_juhua_ then
            self.notice_juhua_:removeFromParent()
            self.notice_juhua_ = nil
        end
    end
end

function CornuHomePageView:setMessageLoading(isLoading)
    if isLoading then
        if not self.message_juhua_ then
            self.message_juhua_ = nk.ui.Juhua.new()
                --:pos(NOTICE_WIDTH/2, MESSAGE_HEIGHT/2+20)
                :addTo(self.myMessage_)
                :scale(.5)
        end
    else
        if self.message_juhua_ then
            self.message_juhua_:removeFromParent()
            self.message_juhua_ = nil
        end
    end
end
function CornuHomePageView:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()
        self.avatar_:setTexture(tex)
        self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
        self.avatar_:setScaleX(57 / texSize.width)
        self.avatar_:setScaleY(57 / texSize.height)
        self.avatarLoaded_ = true
    end
end
return CornuHomePageView