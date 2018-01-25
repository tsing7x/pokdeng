--
-- Author: tony
-- Date: 2014-11-17 16:40:50
--
local PurchaseServiceBase = class("PurchaseServiceBase")

function PurchaseServiceBase:ctor(name)
    self.logger = bm.Logger.new(name or "PurchaseServiceBase")
    self.schedulerPool_ = bm.SchedulerPool.new()
end

function PurchaseServiceBase:init(config)
end

function PurchaseServiceBase:autoDispose()
end

--callback(payType, isComplete, data)
function PurchaseServiceBase:loadChipProductList(callback)
end

--callback(payType, isComplete, data)
function PurchaseServiceBase:loadPropProductList(callback)
end

function PurchaseServiceBase:loadTicketProductList(callback)
    -- body
end

function PurchaseServiceBase:loadCashProductList(callback)
    -- body
end

function PurchaseServiceBase:makePurchase(pid, callback)
end

function PurchaseServiceBase:prepareEditBox(input1, input2, submitBtn)
end

function PurchaseServiceBase:onInputCardInfo(productType, input1, input2, submitBtn, callback)
end

function PurchaseServiceBase:createJavaMethodInvoker(javaClassName)
    if device.platform ~= "android" then
        self.logger:debugf("call %s failed, not in android platform", javaMethodName)
        return function()
            return false, nil
        end
    end
    return function(javaMethodName, javaParams, javaMethodSig)
        local ok, ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
        if not ok then
            -- or math.abs(ret)
            local error_info = {
                [-1] = "-1 不支持的参数类型或返回值类型",
                [-2] = "-2 无效的签名"                ,
                [-3] = "-3 没有找到指定的方法"        ,
                [-4] = "-4 Java 方法执行时抛出了异常" ,
                [-5] = "-5 Java 虚拟机出错"           ,
                [-6] = "-6 Java 虚拟机出错"           ,
            }
            local e = error_info[ret] or 'unknown'
            self.logger:errorf('call %s failed, ' .. e, javaMethodName)
        end
        return ok, ret
    end
end


function PurchaseServiceBase:createOcMethodInvoker(ocClassName)
    if device.platform ~= "ios" then
        self.logger:debugf("call %s failed, not in ios platform", ocMethodName)
        return function()
            return false, nil
        end
    end
    return function(ocMethodName, ocParams)
        local ok, ret = luaoc.callStaticMethod(ocClassName, ocMethodName, ocParams)
        if not ok then
            -- or math.abs(ret)
            local error_info = {
                [-1] = "-1 INVALID PARAMETERS" ,
                [-2] = "-2 CLASS NOT FOUND"     ,
                [-3] = "-3 METHOD NOT FOUND"    ,
                [-4] = "-4 EXCEPTION OCCURRED" ,
                [-5] = "-5 INVALID METHOD SIGNATURE"   
            }
            local e = error_info[ret] or 'unknown'
            self.logger:errorf('call %s failed, ' .. e, javaMethodName)
        end
        return ok, ret
    end
end


return PurchaseServiceBase
