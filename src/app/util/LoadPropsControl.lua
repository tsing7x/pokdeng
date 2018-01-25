local LoadPropsControl =  class("LoadPropsControl")
local instance

function LoadPropsControl:getInstance()
    instance = instance or LoadPropsControl.new()
    return instance
end

function LoadPropsControl:ctor()
    self.requestId_ = 0
    self.requests_ = {}
    self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end
function LoadPropsControl:loadConfig(url, callback)
    if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadPropsConfigCallback_ = callback
    self:loadConfig_()
end
function LoadPropsControl:loadConfig_()
    if not self.isConfigLoaded_ and not self.isConfigLoading_ then
        self.isConfigLoading_ = true
        bm.cacheFile(self.url_ or nk.userData.PROPS_JSON, 
	        function(result, content)
	            self.isConfigLoading_ = false
	            if result == "success" then
	                self.isConfigLoaded_ = true
	                self.propsConfigData_ = json.decode(content) 
	                if self.loadPropsConfigCallback_ then
	                    self.loadPropsConfigCallback_(true, self.propsConfigData_)
	                end
	            else
	                if self.loadPropsConfigCallback_ then
	                    self.loadPropsConfigCallback_(false)
	                end
	            end
	        end, "props")
    elseif self.isConfigLoaded_ then
         if self.loadPropsConfigCallback_ then
            self.loadPropsConfigCallback_(true, self.propsConfigData_)
        end
    end
end
function LoadPropsControl:getPropDataByPnid(pnid)
	local pdata = nil
	if self.propsConfigData_ then
		for i=1,#self.propsConfigData_ do
			local itemdata = self.propsConfigData_[i]
			if tonumber(pnid) == tonumber(itemdata.pnid) then
				pdata = itemdata
			end
		end
	end
	return pdata
end
function LoadPropsControl:cancel(requestId)
    self.requests_[requestId] = nil
end
return LoadPropsControl