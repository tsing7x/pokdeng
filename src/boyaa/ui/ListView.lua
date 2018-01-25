--
-- Author: johnny@boomegg.com
-- Date: 2014-08-17 16:28:28
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

--[[
    bm.ui.ListView.new(
        {
            viewRect = cc.rect(-240, -160, 480, 320),
            direction = bm.ui.ScrollView.DIRECTION_HORIZONTAL
        }, 
        ItemClass -- 继承于ListItem
    )
        :setData({1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,})
        :addTo(self)
]]

local ScrollView = import(".ScrollView")
local ListView = class("ListView", ScrollView)

function ListView:ctor(params, itemClass)
    ListView.super.ctor(self, params)

    -- 滚动容器
    self.content_ = display.newNode()

    self:setScrollContent(self.content_)
    self:setItemClass(itemClass)
end

function ListView:onScrolling()
    if self.items_ and self.viewRectOriginPoint_ then
        if self.direction_ == ScrollView.DIRECTION_VERTICAL then
            for _, item in ipairs(self.items_) do
                local tempWorldPt = self.content_:convertToWorldSpace(cc.p(item:getPosition()))
                if tempWorldPt.y > self.viewRectOriginPoint_.y + self.viewRect_.height or tempWorldPt.y < self.viewRectOriginPoint_.y - item.height_ then
                    item:hide()
                    if item.onItemDeactived then
                        if tempWorldPt.y - (self.viewRectOriginPoint_.y + self.viewRect_.height) > self.viewRect_.height or self.viewRectOriginPoint_.y - item.height_ - tempWorldPt.y > self.viewRect_.height then
                            item:onItemDeactived()
                        end
                    end
                else
                    item:show()
                    if item.lazyCreateContent then
                        item:lazyCreateContent()
                    end
                end
            end
        elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
            for _, item in ipairs(self.items_) do
                local tempWorldPt = self.content_:convertToWorldSpace(cc.p(item:getPosition()))
                if tempWorldPt.x > self.viewRectOriginPoint_.x + self.viewRect_.width or tempWorldPt.x < self.viewRectOriginPoint_.x - item.width_ then
                    item:hide()
                    if item.onItemDeactived then
                        if tempWorldPt.x - (self.viewRectOriginPoint_.x + self.viewRect_.width) > self.viewRect_.width or self.viewRectOriginPoint_.x - item.width_ - tempWorldPt.x > self.viewRect_.width then
                            item:onItemDeactived()
                        end
                    end
                else
                    item:show()
                    if item.lazyCreateContent then
                        item:lazyCreateContent()
                    end
                end
            end
        end
    end
end

-- 设置数据
function ListView:setData(data)
    self.data_ = data
    local oldItemNum = self.itemNum_ or 0
    self.itemNum_ = self.data_ and #self.data_ or 0

    -- 如果已创建items，移除多余的item
    if self.items_ then
        if oldItemNum > self.itemNum_ then
            for i = self.itemNum_ + 1, oldItemNum do
                table.remove(self.items_):removeFromParent()
            end
        end
    else
        self.items_ = {}
    end

    -- 创建item
    local contentSize = 0
    local itemResizeHandler = handler(self, self.onItemResize_)
    local itemEventHandler = handler(self, self.onItemEvent_)
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        for i = 1, self.itemNum_ do
            if not self.items_[i] then
                self.items_[i] = self.itemClass_.new()
                    :addTo(self.content_)
                if self.items_[i].addEventListener then
                    self.items_[i]:addEventListener("RESIZE", itemResizeHandler)
                    self.items_[i]:addEventListener("ITEM_EVENT", itemEventHandler)
                end
            end
            if self.isNotHide_ then
                self.items_[i]:show()
            end
            self.items_[i]:setOwner(self)
            self.items_[i]:setIndex(i)
            self.items_[i]:setData(self.data_[i])
            contentSize = contentSize + self.items_[i]:getContentSize().height
        end

        -- 先定第一个item的位置，再设置其他item位置
        if self.itemNum_ > 0 then
            local size = self.items_[1]:getContentSize()
            self.items_[1]:pos(-size.width * 0.5, contentSize * 0.5 - size.height)
            for i = 2, self.itemNum_ do
                size = self.items_[i]:getContentSize()
                self.items_[i]:pos(-size.width * 0.5, self.items_[i - 1]:getPositionY() - size.height)
            end
        end
        self.content_:setContentSize(cc.size(self.content_:getCascadeBoundingBox().width, contentSize))
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        for i = 1, self.itemNum_ do
            if not self.items_[i] then
                self.items_[i] = self.itemClass_.new()
                    :addTo(self.content_)
                if self.items_[i].addEventListener then
                    self.items_[i]:addEventListener("RESIZE", itemResizeHandler)
                    self.items_[i]:addEventListener("ITEM_EVENT", itemEventHandler)
                end
            end
            if self.isNotHide_ then
                self.items_[i]:show()
            end
            self.items_[i]:setOwner(self)
            self.items_[i]:setIndex(i)
            self.items_[i]:setData(self.data_[i])
            contentSize = contentSize + self.items_[i]:getContentSize().width
        end
        
        -- 先定第一个item的位置，再设置其他item位置
        if self.itemNum_ > 0 then
            local size = self.items_[1]:getContentSize()
            self.items_[1]:pos(-contentSize * 0.5, -size.height * 0.5)
            for i = 2, self.itemNum_ do
                local prevSize = size
                size = self.items_[i]:getContentSize()
                self.items_[i]:pos(self.items_[i - 1]:getPositionX() + prevSize.width, -size.height * 0.5)
            end
        end
        self.content_:setContentSize(cc.size(contentSize, self.content_:getCascadeBoundingBox().height))
    end

    -- 更新滚动容器
    self:update()

    return self
end

function ListView:getData()
    return self.data_
end

-- 往后追加item
function ListView:appendData(data)
    if not self.data_ then
        self.data_ = {}
    end
    for _,v in pairs(data) do
        self.data_[#self.data_+1] = v;
    end
    local curP = self.currentPlace_
    self:setData(self.data_)
    self:scrollTo(curP)
end

--更新某一项item
function ListView:updateData(index,data)
    if self.data_[index] and self.items_[index] then
        self.data_[index] = data
        self.items_[index]:setData(data)
    end
end

function ListView:onItemResize_()
    -- 创建item
    local curP = self.currentPlace_
    local contentSize = 0
    if self.direction_ == ScrollView.DIRECTION_VERTICAL then
        for i = 1, self.itemNum_ do
            contentSize = contentSize + self.items_[i]:getContentSize().height
        end
        --self.content_:setContentSize(cc.size(self.content_:getContentSize().width, contentSize))
        -- 先定第一个item的位置，再设置其他item位置
        local size = self.items_[1]:getContentSize()
        self.items_[1]:pos(-size.width * 0.5, contentSize * 0.5 - size.height)
        local pX, pY = -size.width * 0.5, contentSize * 0.5 - size.height
        for i = 2, self.itemNum_ do
            size = self.items_[i]:getContentSize()
            pY = pY - size.height
            self.items_[i]:pos(pX, pY)
        end
        self.content_:setContentSize(cc.size(self.content_:getCascadeBoundingBox().width, contentSize))
    elseif self.direction_ == ScrollView.DIRECTION_HORIZONTAL then
        for i = 1, self.itemNum_ do
            contentSize = contentSize + self.items_[i]:getContentSize().width
        end
        self.content_:setContentSize(cc.size(contentSize, self.content_:getContentSize().height))
        -- 先定第一个item的位置，再设置其他item位置
        local size = self.items_[1]:getContentSize()
        self.items_[1]:pos(-contentSize * 0.5, -size.height * 0.5)
        local pX, pY = -contentSize * 0.5, -size.height * 0.5
        for i = 2, self.itemNum_ do
            size = self.items_[i]:getContentSize()
            pX = pX + size.width
            self.items_[i]:pos(pX, pY)
        end
        self.content_:setContentSize(cc.size(contentSize, self.content_:getCascadeBoundingBox().height))
    end

    -- 更新滚动容器
    self:update()
    self:scrollTo(curP)
    return self
end

function ListView:onItemEvent_(evt)
    self:dispatchEvent(evt)
end

function ListView:getListItem(index)
    if self.items_ then
        return self.items_[index]
    end
end

function ListView:setItemClass(class)
    self.itemClass_ = class

    return self
end

return ListView