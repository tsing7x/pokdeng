IS_DEMO = false
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
local is_release = false

if is_release then
    DEBUG    = 0
    CF_DEBUG = 0
    IS_DEMO  = false
else
    DEBUG    = 5
    CF_DEBUG = 5
end

--AppStore支付沙盒模式开关
IS_SANDBOX = false

-- display FPS stats on screen
DEBUG_FPS = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape"

SHOW_SCROLLVIEW_BORDER = false --是否显示边框

-- design resolution
CONFIG_SCREEN_WIDTH  = 960
CONFIG_SCREEN_HEIGHT = 640

-- auto scale mode
local glview = cc.Director:getInstance():getOpenGLView()
local size = glview:getFrameSize()
local w = size.width
local h = size.height

print("w:" .. w .. " -- h: " .. h)
if w / h >= CONFIG_SCREEN_WIDTH / CONFIG_SCREEN_HEIGHT then
    CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
else
    CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
end
