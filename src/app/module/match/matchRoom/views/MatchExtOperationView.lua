--
-- Author: viking@boomegg.com
-- Date: 2014-09-17 11:53:34
--

local MatchExtOperationView = class("ExtOprationView", function()
    return display.newNode()
end)

local OperationButton = import(".MatchOperationButton")

MatchExtOperationView.WIDTH = display.width * 0.7 - 16
MatchExtOperationView.HEIGHT = 72

function MatchExtOperationView:ctor(seatManager)
    self.seatManager_ = seatManager
    self:setupView()
end

function MatchExtOperationView:setupView()
    local width, height = MatchExtOperationView.WIDTH, MatchExtOperationView.HEIGHT

    -- 亮出手牌
    self.showHandCardBtn = OperationButton.new()
        :setEnabled(true)
        :setLabel(bm.LangUtil.getText("ROOM", "SHOW_HANDCARD"))
        :setCheckMode(false)
        :onTouch(handler(self, self.onShowHandcard_))
        :addTo(self)
        :pos(width/2 - OperationButton.BUTTON_WIDTH/2, 0)
end

function MatchExtOperationView:setShowHandcardCallback(showHandcardCallback)
    self.showHandcardCallback_ = showHandcardCallback
    return self
end

function MatchExtOperationView:onShowHandcard_(evt)
    if evt == bm.TouchHelper.CLICK then
        print("show handcard")
        if self.showHandcardCallback_ then
            self.showHandcardCallback_()
        end
        self:showHandCardAnimation()
        nk.socket.RoomSocket:showHandcard()
    end
end

function MatchExtOperationView:showHandCardAnimation()
    local seatView_ = self.seatManager_:getSelfSeatView()
    seatView_:showHandCardsAnimation()
end

return MatchExtOperationView