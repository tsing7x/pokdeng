function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")

    if nk and nk.OnOff then
        local isReport = nk.OnOff:checkReportError("clientLog")
        if isReport and nk.http and nk.http["getDefaultURL"] then
            local defaultUrl = nk.http.getDefaultURL()
            if defaultUrl ~= nil and (type(defaultUrl) == "string") and string.len(defaultUrl) > 0 then
                local str = (tostring(errorMessage) or "") .. "|" .. (debug.traceback() or "")
                if str and string.len(str) > 0 then
                    str = string.gsub(str,"[%c%s]","")
                    str = string.gsub(str,"\"","")
                    nk.http.reportError(str)
                end
            end
        end
    end

    -- Output Error Log to Screen! --
    if (DEBUG > 0) and nk then
        if not nk.printer_ then
            nk.printer_ = require("app.module.debugtools.ScreenWriter").new()
        end

        if nk.printer_ then
            nk.printer_:showPrinter()
            local errInfo = tostring(errorMessage).."\n"..debug.traceback("", 2)
            nk.printer_:write(errInfo)
        end
    end
    --[[
    	if device.platform == "android" or device.platform == "ios" then
    		local luaError = tostring(errorMessage) or ""
    		local stack = (debug.traceback("", 2)) or ""
    		local errStr = luaError .. " | " .. stack
    		-- local errStr = luaError;
        	cc.analytics:doCommand{command = "reportError",
                args = {errType = "LUAERROR",error = (errStr or "")}}
    	end
    --]]
end

require("umeng_boot")
require("config")
appconfig = require("appconfig")
require("framework.init")

-- require("update.UpdateController").new()
-- require("app.NineKeApp").new():run()
-- package.path = package.path .. ";src/"
-- cc.FileUtils:getInstance():setPopupNotify(false)
require("welcome.WelcomeController").new()
