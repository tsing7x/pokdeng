local Panel = import("app.pokerUI.Panel")
local CornucopiaListItem = class("CornucopiaListItem", function()return display.newNode() end)

local WIDTH = 136
local HEIGHT = 148
local TOP_WIDTH = 141
local TOP_HEIGHT = 110
local BOTTOM_HEIGHT = 45
function CornucopiaListItem:ctor(parent)

	self.parent_ = parent;

	self.cor_place_bg_ = display.newScale9Sprite("#cor_place_bg.png",0,0,cc.size(WIDTH,TOP_HEIGHT))
	:addTo(self)
	:pos(0,0)

	self.cor_ingotFlower_ = display.newSprite("#cor_ingot_flower.png")
	:addTo(self)
	:hide()

	self.cor_silverFlower_ = display.newSprite("#cor_silver_flower.png")
	:addTo(self)
	:hide()

	self.cor_tree_ = display.newSprite("#cor_tree.png")
	:addTo(self)
	:hide()

	self.cor_lock_bg = display.newSprite("#cor_lock_bg.png")--锁背景
	:addTo(self)
	:pos(-1,3)
	:hide()

	self.cor_lock_ = display.newSprite("#cor_lock_icon.png")--锁
	:addTo(self)

	self.black_btn = cc.ui.UIPushButton.new("#cor_black_line.png",{scale9 = true})
	:addTo(self)
	:pos(-2,-35)
	:setButtonSize(127,20)
	:setButtonEnabled(false)

	self.write_btn_ = cc.ui.UIPushButton.new("#farm_write_page.png",{scale9 = true})
	:addTo(self)
	:setButtonSize(WIDTH,TOP_HEIGHT)
	:onButtonClicked(buttontHandler(self, self.onClickWriteBtn_))
	:pos(0,0)

	self.cor_bottom_green_bt_ = cc.ui.UIPushButton.new({normal = "#cor_item_bottom_green.png", pressed = "#cor_item_bottom_green.png"}, {scale9 = true})
	:addTo(self)
	:pos(0,-(TOP_HEIGHT*0.5 +BOTTOM_HEIGHT*0.5) +12)
	:setButtonSize(WIDTH,BOTTOM_HEIGHT)
	:onButtonClicked(buttontHandler(self, self.onGreenBtn))
	:hide()


	 self.cor_bottom_orange_bt_ = cc.ui.UIPushButton.new({normal = "#cor_item_bottom_orange.png", pressed = "#cor_item_bottom_orange.png"}, {scale9 = true})
	 :addTo(self)
	-- :setButtonLabel("normal", display.newTTFLabel({text = "เพิ่มความเร็ว", color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
	 :pos(0,-(TOP_HEIGHT*0.5 +BOTTOM_HEIGHT*0.5) +12)
	 :setButtonSize(WIDTH,BOTTOM_HEIGHT)
	 :hide()
	 :onButtonClicked(buttontHandler(self, self.onOrangeBtn))


	self.cor_bottom_black_bt_ = cc.ui.UIPushButton.new({normal = "#cor_item_bottom_black.png", pressed = "#cor_item_bottom_black.png"}, {scale9 = true})
	:addTo(self)
	:hide()
	--:setButtonLabel("normal", display.newTTFLabel({text = "เพิ่มความเร็ว", color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
	:pos(0,-(TOP_HEIGHT*0.5 +BOTTOM_HEIGHT*0.5) +12)
	:setButtonSize(WIDTH,BOTTOM_HEIGHT)
	:setButtonEnabled(false)
	--:hide()

end
function CornucopiaListItem:onClickWriteBtn_()
	if self.open_btn_type == 1 then
		self:onOrangeBtn()
	elseif self.open_btn_type==2 then
		self:onGreenBtn()
	end
end
function CornucopiaListItem:onGreenBtn()
	if self.parent_.m_type == 2 then--不可操纵好友的聚宝盆
		return;
	end
	if self.greenBtnType == 1 then--未解锁状态
		self.parent_:openLock(self.data_.id)
	elseif self.greenBtnType == 2 then--种植
		self.parent_:openSelectSeed(self.data_.id)
	elseif self.greenBtnType  == 3 then--加速
		self.parent_:addSpeed(self.data_.id)
	end
end
function CornucopiaListItem:onOrangeBtn()
	if self.parent_.m_type == 1 then
		self.parent_:getMyTree(self.data_.id)
	else
		self.parent_:getFriendTree(self.friendData.id)
	end
end

function CornucopiaListItem:setData(data)
	self:setDefState()
	self.data_ = nil;
	self:stopAction(self.actions_)
	self:stopAction(self.action_)
	self.data_ = data;
	if data.lockStatus == 0 then--未解锁状态
		if data.needlevel then--等级尚未开启
			self.open_btn_type = 3 --打开的是3号黑色按钮。
			self.cor_lock_bg:show()
			self.cor_bottom_black_bt_:show()
			self.black_btn:show()
			self.black_btn:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","OPENLOCK_CONDITION",data.needlevel), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
			self.cor_bottom_black_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","WAIT_OPEN_LOCK"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
		elseif data.needMoney then
			self.open_btn_type = 2
			self.black_btn:show()
			self.black_btn:setButtonLabel("normal", display.newTTFLabel({text = '- $'..data.needMoney, color = cc.c3b(0xFF, 0xFF, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
			self.greenBtnType = 1;--解锁
			self.cor_bottom_green_bt_:show()
			self.cor_lock_:show()
			self.cor_bottom_green_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","OPEN_LOCK"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
		else -- 以下部分错误数据做容错，没有等级解锁，也没有经验解锁
			self.cor_bottom_black_bt_:show()
			self.cor_lock_:show()
			self.cor_bottom_black_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","WAIT_OPEN_LOCK"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
		end
	else
		if data.canPlant==1 then--可种植状态
			self.greenBtnType = 2;--种植
			self.open_btn_type=2
			self.cor_bottom_green_bt_:show()
			self.cor_bottom_green_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","GORW_TERR"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
		else       --已种植状态
			if checkint(data.needTime)>0 then --成长状态
				self.open_btn_type = 2
				self.greenBtnType = 3;--加速
				self.cor_bottom_green_bt_:show()
				self.black_btn:show()
				self.cor_tree_:show()
				local str_time = os.date("%M:%S", self.data_.needTime);
				self.black_btn:setButtonLabel("normal",display.newTTFLabel({text = ""..str_time, color = cc.c3b(0xFF, 0xFF, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
				self.cor_bottom_green_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","ADD_SPEED"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
				self.action_ = self:schedule(function ()
				 	self.data_.needTime = checkint(self.data_.needTime)-1;
				 	local str = os.date("%M:%S", self.data_.needTime);
            		self.black_btn:setButtonLabel("normal",display.newTTFLabel({text = ""..str, color = cc.c3b(0xFF, 0xFF, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
            		if self.data_.needTime<=0 then
            			self:stopAction(self.action_)
            			self.parent_:getMyCorInfo()
            		end
        		end, 1)  
			else 						--成熟状态
				self.open_btn_type = 1
				self.black_btn:show()
				self.black_btn:setButtonLabel("normal",display.newTTFLabel({text = "+"..self.data_.money, color = cc.c3b(0xFF, 0xFF, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
				self.cor_bottom_orange_bt_:show()
				if self.parent_.m_type == 1 then--自己的可收货
					self.cor_bottom_orange_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","GET_TREE"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
				else
					self.cor_bottom_orange_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","GET_TREE"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
				end	
				if checkint(data.type) == 401 then
					self.cor_silverFlower_:show()
				elseif checkint(data.type) == 402 then
					self.cor_ingotFlower_:show()
				end
			end

		end
	end
end


function CornucopiaListItem:setFriendCorData(data)

	self:setDefState()
	self.friendData = nil;
	self:stopAction(self.action_)
	self:stopAction(self.actions_)
	self.friendData = data;

	if data.lockStatus == 0 then--未解锁状态
		self.open_btn_type = 3
		self.cor_lock_bg:show()
		self.cor_bottom_black_bt_:show()
		self.black_btn:hide()
		self.cor_bottom_black_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","WAIT_OPEN_LOCK"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
	else
		if data.canPlant==1 then--可种植状态
			self.open_btn_type = 2
			self.greenBtnType = 2;--种植
			self.cor_bottom_green_bt_:show()
			self.cor_bottom_green_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","NOT_GROW"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
		else 
			if checkint(data.needTime)>0 then --成长状态
				self.open_btn_type = 2
				self.cor_tree_:show()
				self.black_btn:show()
				self.cor_bottom_green_bt_:show()
				self.cor_bottom_green_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","GORW_ING"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
				self.actions_ = self:schedule(function ()
				 	self.friendData.needTime = checkint(self.friendData.needTime)-1;
				 	local str = os.date("%M:%S", self.friendData.needTime);
            		self.black_btn:setButtonLabel("normal",display.newTTFLabel({text = ""..str, color = cc.c3b(0xFF, 0xFF, 0xFF), size = 20, align = ui.TEXT_ALIGN_CENTER}))
            		if self.friendData.needTime<=0 then
            			self:stopAction(self.actions_)
            			self.parent_:getFriendCorByIndex()
            		end
        		end, 1)  
			else
				self.open_btn_type = 1
				self.cor_bottom_orange_bt_:show()
				if self.parent_.m_type == 2 then--别人的可收货
					self.cor_bottom_orange_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","GET_FRIEND_COR"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
				else
					self.cor_bottom_orange_bt_:setButtonLabel("normal", display.newTTFLabel({text = bm.LangUtil.getText("DORNUCOPIA","GET_TREE"), color = cc.c3b(0xFF, 0xFF, 0xFF), size = 24, align = ui.TEXT_ALIGN_CENTER}))
				end	

				if checkint(data.type) == 401 then
					self.cor_silverFlower_:show()
				elseif checkint(data.type) == 402 then
					self.cor_ingotFlower_:show()
				end
			end
		end
	end
end

function CornucopiaListItem:setDefState()
	self.cor_ingotFlower_:hide()
	self.cor_silverFlower_:hide()
	self.cor_tree_:hide()
	self.cor_lock_bg:hide()
	self.cor_lock_:hide()
	self.cor_bottom_green_bt_:hide()
	self.cor_bottom_orange_bt_:hide()
	self.cor_bottom_black_bt_:hide()
	self.black_btn:hide()
	self.open_btn_type = 0
end

return CornucopiaListItem;