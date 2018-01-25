

local DirtyWordFilter = class("DirtyWordFilter")

function DirtyWordFilter:ctor()
	self.isConfigLoaded_ = false
    self.isConfigLoading_ = false
end


function DirtyWordFilter:loadConfigByUrl(url,callback)
	print("DirtyWordFilter:loadConfigByUrl -- url:" .. (url or "nil"))
	if self.url_ ~= url then
        self.url_ = url
        self.isConfigLoaded_ = false
        self.isConfigLoading_ = false
    end
    self.loadGiftConfigCallback_ = callback
    self:loadConfig_()
end

function DirtyWordFilter:loadConfigByTable(dirtyWordLib)
	if dirtyWordLib then
		print("DirtyWordFilter:loadConfigByTable -- ")
		self.dirtyWordLib_ = dirtyWordLib
		self:sortWords(self.dirtyWordLib_)
		self.isConfigLoading_ = false
		self.isConfigLoaded_ = true
	end
end

function DirtyWordFilter:isReady()
	return (self.isConfigLoaded_ == true)
end

function DirtyWordFilter:loadConfig_()
	if not self.isConfigLoaded_ and not self.isConfigLoading_ then
        self.isConfigLoading_ = true
        bm.cacheFile(self.url_ or nk.userData.GIFT_JSON, function(result, content)
            self.isConfigLoading_ = false
            if result == "success" then
                self.isConfigLoaded_ = true
                self.dirtyWordLib_ = json.decode(content)
                self:sortWords(self.dirtyWordLib_)
                if self.loadGiftConfigCallback_ then
                    self.loadGiftConfigCallback_(true, self.dirtyWordLib_)
                end

            else
                if self.loadGiftConfigCallback_ then
                    self.loadGiftConfigCallback_(false)
                end
            end
        end, "dirtylib")
    elseif self.isConfigLoaded_ then
         if self.loadGiftConfigCallback_ then
            self.loadGiftConfigCallback_(true, self.dirtyWordLib_)
        end
    end
end


function DirtyWordFilter:sortWords(tb)
	print("DirtyWordFilter:sortWords -- ")
	table.sort(tb, function(word1,word2)
		return string.utf8len(word1) > string.utf8len(word2)
	end )
end


function DirtyWordFilter:runFilter(str)
	-- str = GameString.convert2UTF8(str)
	if not str or str == "" then
		return ""
	end

	if not self:isReady() then
		return str
	end
	
	for i,v in ipairs(self.dirtyWordLib_) do
		if v and v ~= "" then
			str = string.gsub(str,v,"**");
			--print_string("word: " .. v ..  " tempstr: " .. str);
		end
	end

	return str;
end


return DirtyWordFilter
