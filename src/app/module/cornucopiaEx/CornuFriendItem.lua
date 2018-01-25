local CornuFriendItem = class("CornuFriendItem", bm.ui.ListItem)

local WIDTH = 100
local HEIGHT = 110
function CornuFriendItem:ctor()
    self:setNodeEventEnabled(true)
    --self:setTouchSwallowEnabled(false)
    CornuFriendItem.super.ctor(self, WIDTH, HEIGHT)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    local headSprite = display.newNode()
    :addTo(self)
    :pos(-WIDTH/2+25,70/2+20)
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
--common_transparent_skin
    cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#common_transparent_skin.png"}, {scale9 = true})
    :setButtonSize(71, 71)
    :pos(WIDTH/2-7,HEIGHT/2+5)
    :onButtonClicked(buttontHandler(self, self.onGoFriend))
    :addTo(self)
    :setTouchSwallowEnabled(false)

    self.light_ = display.newSprite("#cor_head_light.png"):addTo(self)
    :pos(WIDTH/2-8,70/2+20)
    :scale(.8)

    self.light_:hide()
end 

function CornuFriendItem:onGoFriend()
    --self.light_:show()
    self:dispatchEvent({name="ITEM_EVENT", data = self.data_})
end
function CornuFriendItem:onDataSet(dataChanged, data)
    
    self.data_ = data

    if data.light==1 then
        self.light_:show()
    else
        self.light_:hide()
    end
     -- 设置头像
    if checkint(data.msex) ~= 1 then
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("female_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_female_avatar.png"))
    else
        self.genderIcon_:setSpriteFrame(display.newSpriteFrame("male_icon.png"))
        self.avatar_:setSpriteFrame(display.newSpriteFrame("common_male_avatar.png"))
    end

    local imgurl = data.micon
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

function CornuFriendItem:onAvatarLoadComplete_(success, sprite)
    if success then
        local tex = sprite:getTexture()
        local texSize = tex:getContentSize()

        if self and self.avatar_ then
            --todo
            self.avatar_:setTexture(tex)
            self.avatar_:setTextureRect(cc.rect(0, 0, texSize.width, texSize.height))
            self.avatar_:setScaleX(57 / texSize.width)
            self.avatar_:setScaleY(57 / texSize.height)
        end
        self.avatarLoaded_ = true
    end
end
function CornuFriendItem:onCleanup()

end
return CornuFriendItem