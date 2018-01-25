local CornuFarmView = class("CornuFarmView", 
function()
	return display.newNode() 
end)

local PLANT_WIDHT = 124
local PLANT_HEIGHT = 78

local CornuFarmItem = import(".CornuFarmItem")
local CornuFriendFarmItem = import(".CornuFriendFarmItem")



function CornuFarmView:ctor(parent,index)
    self:setNodeEventEnabled(true)
  --index =1 代表是自己的农场，index=2代表是好友的农场
    self.parent_ = parent
	  display.newSprite("#cor_cor_blackBg.png")
   	:addTo(self)

   	self.pot_ = {}
   	for i=1,9 do
      local item
      if index == 1 then
   		  item = CornuFarmItem.new(self)
      else
        item = CornuFriendFarmItem.new(self)
      end
   		table.insert(self.pot_,item)
   	end
   	
   	self.pot_[1]:pos(0,PLANT_HEIGHT+5):addTo(self)
    self.pot_[2]:pos(90,40):addTo(self)
    self.pot_[3]:pos(185,-15):addTo(self)
    self.pot_[4]:pos(-95,35):addTo(self)
   	self.pot_[5]:pos(0,-10):addTo(self)
    self.pot_[6]:pos(90,-60):addTo(self)
   	
   	self.pot_[7]:pos(-190,-15):addTo(self)
   	self.pot_[8]:pos(-100,-60):addTo(self)
   	self.pot_[9]:pos(0,-(PLANT_HEIGHT+25)-5):addTo(self)


   	
   
   


    -- self.pot_[1]:pos(0,PLANT_HEIGHT+5):addTo(self)
    -- self.pot_[5]:pos(0,-10):addTo(self)
    -- self.pot_[9]:pos(0,-(PLANT_HEIGHT+25)-5):addTo(self)

    -- self.pot_[4]:pos(-95,35):addTo(self)
    -- self.pot_[8]:pos(-100,-60):addTo(self)
    -- self.pot_[7]:pos(-190,-15):addTo(self)

    -- self.pot_[2]:pos(90,40):addTo(self)
    -- self.pot_[6]:pos(90,-60):addTo(self)
    -- self.pot_[3]:pos(185,-15):addTo(self)
end

function CornuFarmView:onCleanup()

end
function CornuFarmView:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :addTo(self)
                :scale(.5)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end
function CornuFarmView:setMyBlow(data)
   local blowdata = data.bowl
   local seeddata = {jininfo = data.jininfo,yininfo = data.yininfo, shortinfo = data.shortinfo}
   for i=1,9 do
      local item = self.pot_[i]
      if blowdata["60"..i] then
        item:setMyData(blowdata["60"..i])
        item:setSeedData(seeddata)
        item:setPid("60"..i)
      end
   end
end

function CornuFarmView:setFriendBlow(data,fid)
    for i=1,9 do
      local item = self.pot_[i]
      if data["60"..i] then
        item:setMyData(data["60"..i])
        item:setPid("60"..i)
        item:setFid(fid)
      end
   end
end

function CornuFarmView:upDataFarm()
   self.parent_:getSelfCor()
end
return CornuFarmView