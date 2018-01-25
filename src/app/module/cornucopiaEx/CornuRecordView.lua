local CornuRecordView = class("CornuRecordView", 
function()
	return display.newNode() 
end)
local CornuRecordItem = import(".CornuRecordItem")
local WIDTH = 835
local HEIGHT = 430
function CornuRecordView:ctor(parent)
    self:setNodeEventEnabled(true)
    self.parent_ = parent
	self.list_ = bm.ui.ListView.new(
    		{
                viewRect = cc.rect(-WIDTH * 0.5, -HEIGHT * 0.5, WIDTH, HEIGHT)
            }, 
            CornuRecordItem
    )
    :addTo(self)

    
    self.list_:addEventListener("ITEM_EVENT", handler(self, self.onItemEvent_))
    --self.list_:setData({1,2,3,4,5,6,7,6,5,3,1,2,3,4,5,6,7,6,5,3})

    self.notRecord_ = display.newTTFLabel({text = T("暂无记录"), color = cc.c3b(0x5A, 0x7C, 0xAE), size = 20,dimensions = cc.size(WIDTH, 0), align = ui.TEXT_ALIGN_CENTER})
    :addTo(self)
    --:pos(0,HEIGHT/2)

    self:onShowed()
end
function CornuRecordView:onItemEvent_(evt)
    local mid = evt.data.fid
    self.parent_:goFriendById(mid)
end
function CornuRecordView:onShowed()
	self:setLoading(true)--
	self.myRecordReqId_ = nk.http.getMyRecord(

		function(data)
            self.myRecordReqId_ = nil
			self:setLoading(false)
			if data==nil or data == "" then
				self.notRecord_:show()
			else
				self.notRecord_:hide()
				self.list_:setData(data)
				self.list_:update()
			end
		end,

		function (error)
            self.myRecordReqId_ = nil
			nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"))
		end

	)
end

function CornuRecordView:onCleanup()
    if self.myRecordReqId_ then
        nk.http.cancel(self.myRecordReqId_)
        self.myRecordReqId_ = nil
    end
    
end
function CornuRecordView:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ = nk.ui.Juhua.new()
                :pos(0, 0)
                :addTo(self)
        end
    else
        if self.juhua_ then
            self.juhua_:removeFromParent()
            self.juhua_ = nil
        end
    end
end
return CornuRecordView