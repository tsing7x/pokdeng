--
-- Author: VanfoHuang
-- Date: 2016-07-04 10:00:00
--

-- dump("load welComeScene")
local WelcomeScene = class("WelcomeScene", function()
    return display.newScene("WelcomeScene")
end)

function WelcomeScene:ctor(controller)
    self.controller_ = controller
    self:setNodeEventEnabled(true)
    -- display.replaceScene(self)
end

function WelcomeScene:showWelcomePage()
    -- dump("showWelcomePage123")
    -- dump(CCVideoPlayer,"CCVideoPlayer")

    self:stopAutoCleanup()
    self:startAutoCleanup()

    self.videoPlayer_ = ccexp.VideoPlayer:create()
    -- dump(self.videoPlayer_,"CCVideoPlayer")
    -- dump((self.videoPlayer_ == nil),"showWelcomePage")
    self.videoPlayer_:size(display.width, display.height)
    self.videoPlayer_:pos(display.width / 2, display.height / 2)
    self.videoPlayer_:setFullScreenEnabled(true)
    self.videoPlayer_:addTo(self)
    self.videoPlayer_:setFileName("res/logo_1280_720_en.mp4")
    self.videoPlayer_:addEventListener(handler(self, self.onVideoEventCallback))
    self.videoPlayer_:play()
end

function WelcomeScene:onVideoEventCallback(sener, eventType)
    -- dump(sener,"WelcomeScene:onVideoEventCallback-sener")
    -- dump(eventType,"WelcomeScene:onVideoEventCallback-eventType")
    if eventType == ccexp.VideoPlayerEvent.PLAYING then
        dump("PLAYING")
    elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
        dump("PAUSED")
    elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
        dump("STOPPED")
    elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
        dump("COMPLETED")
        -- self:removeVideoPlayer()
        self:enterGame()
    end
end

--预防某些情况出错导致停留在欢迎动画界面，不能进入游戏，开启超时自动清理
-- 视频时长约4秒
function WelcomeScene:startAutoCleanup()
    -- dump(os.time(),"startAutoCleanup")

    self.autoCleanupAction_ = self:performWithDelay(function()
        -- dump(os.time(),"startAutoCleanup complete")
        self:stopAutoCleanup()
        self:removeVideoPlayer()
        self:enterGame()
    end, 8)
end

function WelcomeScene:removeVideoPlayer()
    if self.videoPlayer_ then
        self.videoPlayer_:removeFromParent()
        self.videoPlayer_ = nil
    end
end

function WelcomeScene:stopAutoCleanup()
    -- dump(os.time(),"stopAutoCleanup")
    if self.autoCleanupAction_ then
        self:stopAction(self.autoCleanupAction_)
        self.autoCleanupAction_ = nil
    end
end

function WelcomeScene:enterGame()
    require("update.UpdateController").new()
end

function WelcomeScene:onEnter()
end

function WelcomeScene:onExit()
    self:stopAutoCleanup()
    self:removeVideoPlayer()
end

function WelcomeScene:onCleanup()
end

return WelcomeScene