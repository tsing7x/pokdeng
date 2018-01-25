
---预留左边10个像素，右边75个像素
--[[

local LIST_NODE_HEIGHT = 480

local ITEM_LEN = (display.width-85)/7

local LIST_VIEW_WIDTH = display.width-85

local LIST_VIEW_HEIGHT = LIST_NODE_HEIGHT - 80

local ChooseGrabRoomView = class("ChooseGrabRoomView", function ()
    return display.newNode()
end)

local LIST_NODE_POSY = (display.height  - LIST_NODE_HEIGHT)/2

local ChooseGrabRoomItem = import(".ChooseGrabRoomItem")

local GrabDealerHelpPopup = import("app.module.grabDealer.views.GrabDealerHelpPopup")
local GRAB_ROOM_LIST_PAGE_ITEMS_NUM = 20

function ChooseGrabRoomView:ctor(controller)
    self.isCreateFirst_ = true

    self:setNodeEventEnabled(true)
    self.controller_ = controller
    self.roomListNode_ = display.newNode()
    :addTo(self)
    local listBg = display.newScale9Sprite("#perListBg.png",0,0,cc.size(display.width,LIST_NODE_HEIGHT))
    :addTo(self.roomListNode_)
    self.roomListNode_:pos(0,-LIST_NODE_POSY)

    self.checkbtnSprite_ = display.newSprite("#grab_check_game.png")
    :addTo(self)
    :hide()
    :pos(-display.width/2 + 193/2 + 35, LIST_NODE_HEIGHT/2 -LIST_NODE_POSY +18)

    local checkbtnSize = self.checkbtnSprite_:getContentSize()
    self.checkBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(checkbtnSize.width-10, checkbtnSize.height-10)
        :setButtonLabel(display.newTTFLabel({text=T("点击查看玩法介绍"), size=20, color=cc.c3b(0xfe, 0xfe, 0xfc), align=ui.TEXT_ALIGN_CENTER}))
        :pos(-display.width/2 + 193/2 + 35, LIST_NODE_HEIGHT/2 -LIST_NODE_POSY +18)
        :addTo(self)
        :onButtonClicked(buttontHandler(self, self.checkGameInfo_))
        :hide()

    local txtArr = {
        T("当前庄家"),
        T("庄家携带"),
        T("底注场次"),
        T("上庄门槛"),
        T("最小携带"),
        T("房间人数")
    }

    self.titleArr = {}
    for i=1,#txtArr do
        local label = display.newTTFLabel({text=txtArr[i], size=20, color=cc.c3b(0xfe, 0xfe, 0xfc),dimensions = cc.size(ITEM_LEN, 0), align=ui.TEXT_ALIGN_LEFT})
        :align(display.LEFT_CENTER)
        :addTo(self.roomListNode_)
        :pos(-(display.width/2)+ 10+(i-1)*ITEM_LEN + 35,  LIST_NODE_HEIGHT/2-30)
        table.insert(self.titleArr,label)
    end


   self:createListView_()

    local gapX = ITEM_LEN - 163

    self.startGameSprite_ = display.newSprite("#grab_start_game.png")
    :addTo(self.roomListNode_)
    :align(display.LEFT_CENTER)
    :pos(-(display.width/2)+ 10+(7-1)*ITEM_LEN + gapX+ 35, LIST_NODE_HEIGHT/2-30)
   

    local startGameSpriteSize = self.startGameSprite_:getContentSize()
    self.startGameBtn_ = cc.ui.UIPushButton.new({normal = "#common_transparent_skin.png", pressed = "#rounded_rect_10.png"}, {scale9 = true})
        :setButtonSize(startGameSpriteSize.width-10, startGameSpriteSize.height-10)
        :setButtonLabel(display.newTTFLabel({text=T("快速加入"), size=22, color=cc.c3b(0xfe, 0xfe, 0xfc), align=ui.TEXT_ALIGN_CENTER}))
        :pos(-(display.width/2)+ 10+(7-1)*ITEM_LEN + gapX + 5 + 35, LIST_NODE_HEIGHT/2-30)
        :addTo(self.roomListNode_)
        :align(display.LEFT_CENTER)
        :onButtonClicked(buttontHandler(self, self.onPlayGrabGame))
        

    self.cur_pages = 0
    self.total_pages = 1
        
 end 


 function ChooseGrabRoomView:setIsCreateFirst(value)
    self.isCreateFirst_ = value
 end

 function ChooseGrabRoomView:getIsCreateFirst()
    return self.isCreateFirst_
 end



 function ChooseGrabRoomView:createListView_(isAnim,datas)


     if not self.roomList_ then
     self.roomList_ = bm.ui.ListView.new(
            {
                viewRect = cc.rect(-LIST_VIEW_WIDTH * 0.5, -LIST_VIEW_HEIGHT * 0.5, LIST_VIEW_WIDTH, LIST_VIEW_HEIGHT),
                upRefresh = handler(self, self.onRoomListUpFrefresh_)
            }, 
            ChooseGrabRoomItem
        )
        :pos(0, -25)-- -35
        :addTo(self.roomListNode_)

        self.roomList_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    end

    if datas then
        if isAnim then
            for _,v in pairs(datas) do
                if type(v) == "table" then
                    v.isAnim = true
                end
            end
        end
        -- self.roomList_:setData(datas)
        self.roomList_:appendData(datas)
        -- self:refleshRoomList()
    end

end


function ChooseGrabRoomView:reset()
    self.cur_pages = 0
    self.total_pages = 1
    self.roomListDatas_ = {}
end

function ChooseGrabRoomView:checkGameInfo_()
    GrabDealerHelpPopup.new():show()
end
function ChooseGrabRoomView:showGrabList(isAnim)
   

    if not isAnim then
        self.roomListNode_:pos(0,-LIST_NODE_POSY)
        self.checkbtnSprite_:show()
        self.checkBtn_:show()
        -- self:requestRoomListDataByPage()
        return
    end
   
    self.roomListNode_:pos(0,-display.height)
    self.checkbtnSprite_:hide()
    self.checkBtn_:hide()
    local anitime = self.controller_:getAnimTime()
     transition.moveTo(self.roomListNode_, {time =0.6 , y = -LIST_NODE_POSY, delay = anitime,easing = "BACKOUT",onComplete=
        handler(self,self.onRoomListShowAnimComplete)})
end
function ChooseGrabRoomView:onRoomListShowAnimComplete()
    self.checkbtnSprite_:show()
    self.checkBtn_:show()
    self:showed()
    self:requestRoomListDataByPage()
end




function ChooseGrabRoomView:showed()

    -- self.roomList_:update()
    -- self.roomList_:update()

    -- if self.roomListDatas_ then
    --      self:createListView_(false,self.roomListDatas_)
    -- end
   
end
function ChooseGrabRoomView:onPlayGrabGame(evt)
    --
    --
    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = nil})
end
function ChooseGrabRoomView:onSetGrabRoomList(data)
    -- dump(data,"onSetGrabRoomList")

    local emptyRoomTb = {}
    local notEmptyRoomTb = {}
    local desTb = {}
    local cashTb = {}

    --筛选大法
    -- 1；筛选302等级现金币场出来，置顶显示
    -- 2；筛选301普通场，分空桌和有人桌
    for i,v in ipairs(data.roomlist) do
        if v.level == consts.ROOM_GAME_LEVEL.GRAB_CASH_ROOM_LEVEL then
            table.insert(cashTb,v)
        end
    end
    for _,v in pairs(data.roomlist) do
        if v.userCount > 0  then
            if v.level ~= consts.ROOM_GAME_LEVEL.GRAB_CASH_ROOM_LEVEL then
                table.insert(notEmptyRoomTb,v)
            end
        else
            if v.level ~= consts.ROOM_GAME_LEVEL.GRAB_CASH_ROOM_LEVEL then
                table.insert(emptyRoomTb,v)
            end
        end
    end

    -- dump(notEmptyRoomTb,"notEmptyRoomTb")
    -- dump(emptyRoomTb,"emptyRoomTb")

    self:sortRoomList(notEmptyRoomTb)
    self:sortRoomList(emptyRoomTb)
    self:sortCashList(cashTb)
    if nk.OnOff:check("cashRoom") then
        table.insertto(desTb,cashTb)
    end
    table.insertto(desTb,notEmptyRoomTb)
    table.insertto(desTb,emptyRoomTb)
    data.roomlist = desTb



    local total_pages = data.total_pages
    local cur_pages = data.cur_pages
    local roomlist = data.roomlist
    local isAnim = false

    local oldPage = self.cur_pages
    self.total_pages = data.total_pages
    self.cur_pages = data.cur_pages

    if not self.roomListDatas_ then
        self.roomListDatas_ = {}
    end

    -- dump(self.roomListDatas_,"self.roomListDatas_")
    -- dump(roomlist,"self.roomListDatas222_")

    local tempArr = {}
    local count = 0
    local newTableId
    local oldTableId
    for _,new in pairs(roomlist) do
        count = 0
        newTableId = tonumber(new.tableId) or -1
        for __,old in pairs(self.roomListDatas_) do
            oldTableId = tonumber(old.tableId) or -1

            -- dump(newTableId,"newTableId")
            -- dump(oldTableId,"oldTableId")
            -- dump(oldTableId == newTableId," === ")
            if (oldTableId ~= -1 and newTableId ~= -1 ) and (oldTableId == newTableId) then
                -- dump("old000","old000")
                break
            end
            count = count + 1
           
        end
        if count == #self.roomListDatas_ then
            table.insert(tempArr,new)
        end
       
    end

    -- dump(tempArr,"filltempArr")
    table.insertto(self.roomListDatas_,tempArr)
    self:createListView_(isAnim,tempArr)


   
end

function ChooseGrabRoomView:onRoomListUpFrefresh_()
    self:requestRoomListDataByPage()
end



function ChooseGrabRoomView:requestRoomListDataByPage()
    if self.cur_pages >= self.total_pages then
        dump("not data","requestGrabRoomListDataByPage")
        return
    end

    self.cur_pages = self.cur_pages + 1
    nk.server:requestGrabRoomList(2,self.cur_pages,GRAB_ROOM_LIST_PAGE_ITEMS_NUM)
end


function ChooseGrabRoomView:sortRoomList(tb)
    table.sort(tb,function(t1,t2)
        if t1.basechip > t2.basechip then
            return true
        elseif t1.basechip == t2.basechip then
            if t1.userCount > t2.userCount then
                return true
            elseif t1.userCount == t2.userCount then
                if t1.ante > t2.ante then
                    return true
                else
                    return false

                end

            else
                return false
            end
        else
            return false
        end
    end)
        
end

function ChooseGrabRoomView:sortCashList(tb)
    table.sort(tb,function(t1,t2)
        if t1.basechip > t2.basechip then
            return false
        elseif t1.basechip == t2.basechip then      
                if t1.userCount > t2.userCount then
                    return true
                else
                    return false
                end
        else
            return true
        end
    end)
end

function ChooseGrabRoomView:onCleanup()
    -- self.isCreateFirst_ = false
end


function ChooseGrabRoomView:onItemEvent_(evt)
    local data = evt.data
   -- local sendData = {tid = data.tableId,gameLevel = data.level}
    bm.EventCenter:dispatchEvent({name = nk.eventNames.ENTER_GRAB_DEALER_ROOM, data = data})
end
return ChooseGrabRoomView

--]]