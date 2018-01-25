--
-- Author: tony
-- Date: 2014-08-01 10:35:58
--
local functions = {}

function functions.getCardDesc(handCard)
    if handCard then
        local value = bit.band(handCard, 0x0F)
        local variety = bit.band(handCard, 0xF0)       

        local p = ""
        if variety == 0x0 then
            p = "梅花"
        elseif variety == 0x10 then
            p = "方块"
        elseif variety == 0x20 then
            p = "红桃"
        elseif variety == 0x30 then
            p = "黑桃"
        end

        if value >= 2 and value <= 10 then
            p = p .. value
        elseif value == 11 then
            p = p .. "J"
        elseif value == 12 then
            p = p .. "Q"
        elseif value == 13 then
            p = p .. "K"
        elseif value == 1 then
            p = p .. "A"
        end

        if p == "" then
            return "无"
        else
            return p
        end
    else
        return "无"
    end
end

function functions.cacheKeyWordFile()
    if not functions.keywords then
        bm.cacheFile(nk.userData['urls.keyword'], function(result, content)
            if result == "success" then
                functions.keywords = json.decode(content)
            end
        end, "keywordfilter")
    end
end

function functions.keyWordFilter(message, replaceWord)
    local replaceWith = replaceWord or "**"
    if not functions.keywords then
        functions.cacheKeyWordFile()
    else
        local searchMsg = string.lower(message)
        for i,v in pairs(functions.keywords) do
            local keywords = string.lower(v)
            local limit = 50
            while true do
                limit = limit - 1
                if limit <= 0 then
                    break
                end
                local s, e = string.find(searchMsg, keywords)
                if s and s > 0 then
                    searchMsg = string.sub(searchMsg, 1, s - 1) .. replaceWith ..string.sub(searchMsg, e + 1)
                    message = string.sub(message, 1, s - 1) .. replaceWith .. string.sub(message, e + 1)
                else
                    break
                end
            end
        end
    end
    return message
end

function functions.badNetworkToptip()
    nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
end

function functions.getUserInfo(default)
    local userInfo = nil
    if default ~= true then
        userInfo = {
            mavatar = nk.userData['aUser.micon'], 
            name = nk.userData['aUser.name'],
            mlevel = nk.userData['aUser.mlevel'],
            mlose = nk.userData['aUser.lose'],
            mwin = nk.userData['aUser.win'],
            money = nk.userData['aUser.money'], 
            msex = nk.userData['aUser.msex'],
            mexp = nk.userData['aUser.exp'],
            sitemid = nk.userData['aUser.sitemid'],
            giftId = nk.userData['aUser.gift'],
            sid = tonumber(nk.userData['aUser.sid']),
            lid = tonumber(nk.userData['aUser.lid']),
            cash = tonumber(nk.userData["match.point"]),
            rankMoney = nk.userData["best"]~=nil and (tonumber(nk.userData["best"].rankMoney)) or 0
        }
        
    else
        userInfo = {
            mavatar = "", 
            name = T("游戏玩家"),
            mlevel = 3,
            mlose = 0,
            mwin = 0,
            money = 10000, 
            msex = 1,
            mexp = 100,
            sitemid = 0,
            giftId = 0,
            sid = 1,
            lid = 1
        }
    end
    return userInfo 
end

--limit:九人场还是五人场
--tab:哪个选项卡：对应以前初级，中级，高级
function functions.getRoomDatasByLimitAndTab(limit,tab)

   dump("getRoomDatasByLimitAndTab-limit:" .. limit .. " tab:" .. tab)
    local tb = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
    local tempTb = {}
    for group,v in pairs(tb) do
        dump(group,"getRoomDatasByLimitAndTab-group")
        if group == limit then
            for tabGroup,vv in pairs(v) do
                dump(tabGroup,"getRoomDatasByLimitAndTab-tabGroup")
                if tabGroup == tab then
                    for __,data in pairs(vv) do
                        local temp = {}
                        temp.roomType = tonumber(data[1])
                        temp.blind = tonumber(data[2])
                        temp.minBuyIn = tonumber(data[3])
                        temp.maxBuyIn = tonumber(data[4])
                        temp.limit = tonumber(data[5])
                        temp.online = tonumber(data[6])
                        temp.fee = tonumber(data[7])
                        temp.sendChips=string.split(data[8],",") or {1,10,50,500}
                        temp.roomGroup = tonumber(__)
                        temp.recmax = tonumber(data[9])  -- 场次推荐最大资产值
                        temp.slot = string.split(data[10],",") or {40,120,300}
                        temp.exprDiscount = tonumber(data[11])  -- 付费表情折扣率

                        if data[12] then
                            local quickRateGroup = string.split(data[12],":")
                            for i,v in ipairs(quickRateGroup) do
                                local tempRate = string.split(v,",")
                                local desRate = {}
                                for __,vv in ipairs(tempRate) do
                                    table.insert(desRate,tonumber(vv))
                                end
                                quickRateGroup[i]  = desRate

                            end
                            temp.quickRateGroup = quickRateGroup
                        end
                        temp.enterLimit = tonumber(data[13])--房间入场门槛值

                        temp.fast = string.split(data[17],",") --快速开始上下限

                        --选场场次引导动画资产范围
                        if data[18] then
                            guideTb = string.split(data[18],",")
                            temp.roomGuideRange = {min = tonumber(guideTb[1]),max = tonumber(guideTb[2])}
                        end

                        -- 房间内引导资产下一场次阀值
                        temp.roomGroupNext = tonumber(data[19])
                        temp.rType = tonumber(data[20]) or 1  --房间类型，普通筹码场，还是现金币场

                        table.insert(tempTb,temp)

                    end
                    break
                end

            end
            break
        end 
    end

    return tempTb

end

-- 获取荷官小费
function functions.getRoomDataByLevel(level)
    local tb = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
    local temp
    for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___,vv in pairs(v) do
                if (tonumber(vv[1])) == (tonumber(level)) then
                    temp = {}
                    temp.roomType = tonumber(vv[1])
                    temp.blind = tonumber(vv[2])
                    temp.minBuyIn = tonumber(vv[3])
                    temp.maxBuyIn = tonumber(vv[4])
                    temp.limit = tonumber(vv[5])
                    temp.online = tonumber(vv[6])
                    temp.fee = tonumber(vv[7])
                    temp.sendChips=string.split(vv[8],",") or {1,10,50,500}
                    temp.roomGroup = tonumber(__)
                    temp.recmax = tonumber(vv[9])  -- 场次推荐最大资产值
                    temp.slot = string.split(vv[10],",") or {40,120,300}
                    temp.exprDiscount = tonumber(vv[11])  -- 付费表情折扣率

                    if vv[12] then
                        local quickRateGroup = string.split(vv[12],":")
                        for i,v in ipairs(quickRateGroup) do
                            local tempRate = string.split(v,",")
                            local desRate = {}
                            for __,vv in ipairs(tempRate) do
                                table.insert(desRate,tonumber(vv))
                            end
                            quickRateGroup[i]  = desRate

                        end
                        temp.quickRateGroup = quickRateGroup
                    end
                    temp.enterLimit = tonumber(vv[13])--房间入场门槛值

                    temp.fast = string.split(vv[17],",") --快速开始上下限

                    --选场场次引导动画资产范围
                    if vv[18] then
                        guideTb = string.split(vv[18],",")
                        temp.roomGuideRange = {min = tonumber(guideTb[1]),max = tonumber(guideTb[2])}
                    end

                    -- 房间内引导资产下一场次阀值
                    temp.roomGroupNext = tonumber(vv[19])
                    temp.rType = tonumber(vv[20]) or 1  --房间类型，普通筹码场，还是现金币场
                    temp.isAllIn = tonumber(vv[21]) or 0 --是否开启all in
                    return temp
                end
            end
            
        end 
    end
    return temp
end


--根据用户资产范围获取推荐房间
function functions.getRoomLevelByMoney2(money)
    local tb = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
    local firstData = nil --找不到场次就返回最小场次

     for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___,vv in pairs(v) do
               local roomType = vv[20]
               if not firstData and roomType == 1 then firstData = tonumber(vv[1]) end
               if money >= checkint(vv[9]) and roomType == 1 then
                    local fast  = string.split(vv[17],",")
                    local min = checkint(fast[1])
                    local max = checkint(fast[2])

                    if money >= min and (money < max or max == 0 ) then
                        
                         return tonumber(vv[1])
                    end

               end
            end
            
        end 
    end

    return firstData
end

function functions.getRoomLevelByCash(cash)
    local tb = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
    local temp = {}
     for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___,vv in pairs(v) do
               local roomType = vv[20]
               -- if roomType == 2 then
               --   return tonumber(vv[1])
               -- end
               if cash >= checkint(vv[9]) and roomType == 2 then
                    local fast  = string.split(vv[17],",")
                    local min = checkint(fast[1])
                    local max = checkint(fast[2])
                    if cash >= min and (cash <= max or max == 0 ) then
                        
                         return tonumber(vv[1])
                    end

               end
            end
            
        end 
    end
   
end



function functions.getRoomLevelByMoney(money)
    local tb = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
    -- local temp = {}
    -- dump(tb, "TABLE_CONF : ===================", 6)
    for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___,vv in pairs(v) do
               if money <= tonumber(vv[5]) or tonumber(vv[5]) == 0 then
                    return tonumber(vv[1])
               end
            end
            
        end 
    end
end

function functions.getRoomLevelMinByMoney(money)
    -- body

    local tb = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
    for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___, vv in pairs(v) do
                if money <= tonumber(vv[4]) or tonumber(vv[4]) == 0 then
                    --todo
                    return tonumber(vv[1])
                end
            end
        end 
    end
end

function functions.getGuideChipRoomLevelByMoney(money)
    local tb = bm.DataProxy:getData(nk.dataKeys.TABLE_CONF)
    for _,group in pairs(tb) do
        for __,v in pairs(group) do
            for ___, vv in pairs(v) do
                --筹码场里找
                if (1 == vv[20]) and vv[18] then
                    guideTb = string.split(vv[18],",")
                    local min = checkint(guideTb[1])
                    local max = checkint(guideTb[2])

                    if money >= min and (money < max or max == 0)then
                        return vv[1],vv
                    end
                end

                
            end
        end 
    end
    return nil,nil
end

function functions.subStr2TbByWidth(font, size, text, width)
    if not nk or not nk.Native then

        return {text}
    end
    local tb = {}
    local orgText = text
    local orgLen =  string.utf8len(text)
    local tempLen = 0
    local tempStr = ""
    local remainStr = orgText
    local len = 0
    repeat
        tempStr = nk.Native:getFixedWidthText(font, size, remainStr, width)
        tempLen = string.utf8len(tempStr)
        len = len + tempLen
        table.insert(tb,tempStr)
        remainStr = string.utf8sub(orgText,len+1)
     
    until(len >= orgLen)

    return tb

end

-- function functions.serverTableIDToClientTableID(table_id)
--     local server_id = table_id
--     -- 右移16位为server_id
--     bit.brshift(server_id, 16)
--     local real_table_id = table_id
--     bit.band(0x0000ffff, real_table_id)
    
--     return tostring(server_id) .. tostring(real_table_id)
-- end

-- -- 规定前3位为server_id (table_id_str为玩家输入ID)
-- function functions.clientTableIDToServerTableID(table_id_str)
--     local len = string.len(table_id_str)    
--     -- 异常 输入的只能为数字什么的判断
--     if len <= 3 then
--         --return error!!
--         return
--     end
--     local server_str = string.sub(table_id_str, 1, 4)
--     local real_table_id_str = string.sub(table_id_str, 4, len)
    
--     local server_id = tonumber(server_str)
--     local real_table_id = tonumber(real_table_id_str)
--     bit.blshift(server_id, 16)
--     return  server_id + real_table_id
-- end

-- 清除登陆缓存 --
-- 待加入清除 nk.cookieKeys.LOGIN_SESSKEY 的方式(需用到tinyXml2 库进行xml遍历操作)
function functions.clearLoginCache()
    nk.userDefault:setStringForKey(nk.cookieKeys.LAST_LOGIN_TYPE, "")
    nk.userDefault:setStringForKey(nk.cookieKeys.FACEBOOK_ACCESS_TOKEN, "")
    -- nk.userDefault:setStringForKey(nk.cookieKeys.LOGIN_SESSKEY .. nk.userData["aUser.sitemid"], "")

    -- local isCacheFileExist = nk.userDefault:isXMLFileExist()
    -- local defaultCacheFilePath = nk.userDefault:getXMLFilePath()

    nk.userDefault:flush()
end

function functions.clearMyHeadImgCache()
    local mIcon = nk.userData["aUser.micon"]
    if mIcon then
        --todo
        local imgurl = nil
        if string.find(mIcon, "facebook") then
            if string.find(mIcon, "?") then
                imgurl = mIcon .. "&width=100&height=100"
            else
                imgurl = mIcon .. "?width=100&height=100"
            end
        end

        if string.len(mIcon) > 0 then
            --todo
            local hash = crypto.md5(imgurl)
            local path = device.writablePath .. "cache" .. device.directorySeparator .. "headpics" .. device.directorySeparator .. hash
            -- dump("path :" .. path)
            if bm.isFileExist(path) then
                dump("File Exist! To Remove.")
                local tex = cc.Director:getInstance():getTextureCache():addImage(path)
                if tex then
                    --删除缓存
                    cc.Director:getInstance():getTextureCache():removeTexture(tex)
                    tex = nil
                end
                os.remove(path)
            end     
        end
    else
        dump("error in aUser.micon!")
    end
end


function functions.str2CharTb(str)
    
    local tb = {}
    if str then
        local len = string.len(str)
        for i = 1,len do
            tb[i] = string.sub(str,i,1)
        end
    end
    
    return tb

end

function functions.exportMethods(target)
    for k, v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end

return functions
