-- http 请求
-- Author: leoluo
-- Date: 2015-05-05 15:00:00
local HttpRequest = {}
local logger = bm.Logger.new("HttpRequest")
local http = bm.HttpService

local shJoins = nil
shJoins = function(data,isSig)
    local str = "[";
    local key = {};
    local sig = 0;

    if data == nil then
        str = str .. "]";
        return str;
    end

    for i,v in pairs(data) do
        table.insert(key,i);
    end
    table.sort(key);
    for k=1,table.maxn(key) do
        sig = isSig;
        local b = key[k];
        if sig ~= 1 and string.sub(b,1,4) == "sig_" then
            sig = 1;
        end
        local obj = data[b];
        local oType = type(obj);
        local s = "";
        if sig == 1 and oType ~= "table" then
            str = string.format("%s&%s=%s",str.."",b,obj);
        end
        if oType == "table" then
            str = string.format("%s%s=%s",str.."",b,shJoins(obj,sig));
        end
    end
    str = str .. "]";
    return str;
end

-- 多维数组转一维数组
local toOneDimensionalTable = nil
toOneDimensionalTable = function(table, prefix, root)
    if prefix == nil then
        prefix = ""
        root = table
    end
    for k,v in pairs(clone(table)) do               
        local rootkey = k
        if prefix ~= "" then
            rootkey = prefix.."."..k
        end

        if type(v) == "table" then
            if #v == 0 then --是kv数组
                toOneDimensionalTable(v, rootkey, root)
                if prefix == "" then
                    root[k] = nil
                end
            end
        else
            if prefix ~= "" then
                root[rootkey] = v
            end
        end
    end  

end

-- 类型批量转换
function typeFilter(table, types)
    for func,keys in pairs(types) do
        for _,key in ipairs(keys) do
            if table[key] ~= nil then
                table[key] = func(table[key])
            end
        end
    end
end

function HttpRequest.init()
    http.clearDefaultParameters()
    http.setDefaultParameter("sid", appconfig.ROOT_CGI_SID)
    if IS_DEMO then
        --如果是本地调试，需要加demo=1
        http.setDefaultParameter("demo",1)
    end
end

function HttpRequest.setLoginType_(loginType)
    local lid = 0
    if loginType == "GUEST" then
        lid = 2
    elseif loginType == "FACEBOOK" then
        lid = 1
    else
        logger:errorf("login Type [%s] is wrong", loginType)       
    end
    http.setDefaultParameter("lid", lid)
    return lid
end

function HttpRequest.setSessionKey(key)
    http.setDefaultParameter("sesskey", key)  
end

function HttpRequest.getDefaultURL()
    return http.getDefaultURL()
end

function HttpRequest.request_(method, param, resultCallback, errorCallback)
    param = param or {}
    return http.POST({method = method, game_param = json.encode(param), sig = crypto.md5(shJoins(param,0))}, 
        function(data)

            -- dump(data, "data :=============")
            local retData = json.decode(data)
            if type(retData) == "table" and retData.code and retData.code == 1 then
                if retData.data then
                    -- toOneDimensionalTable(retData.data)
                    if DEBUG > 4 then
                        dump(retData.data, "retData.data",10)
                    end
                end
                if resultCallback then
                    resultCallback(retData.data)
                end                
                
            else
                if not retData then
                    logger:error("json parse error")
                    if errorCallback then
                        errorCallback({errorCode = 1})
                    end
                    
                else
                    if errorCallback then
                        errorCallback({errorCode = retData.code,retData = retData})
                    end
                    
                end
            end
        end, function(errCode,errMsg)
            local errorData = {}
            if errCode ~= nil then
                errorData.errorCode = errCode
            end

            if errMsg ~= nil then
                errorData.errMsg = errMsg
            end

            if errorCallback then
                errorCallback(errorData)
            end

        end)
end

function HttpRequest.post(params, resultCallback, errorCallback)
    return http.POST(params, resultCallback, errorCallback)
end

function HttpRequest.get(params, resultCallback, errorCallback)
    return http.GET(params, resultCallback, errorCallback)
end


function HttpRequest.post_url(url, params, resultCallback, errorCallback)
    return http.POST_URL(url,params, resultCallback, errorCallback)
end


function HttpRequest.get_url(url, params, resultCallback, errorCallback)
    return http.GET_URL(url,params,resultCallback, errorCallback)
end


function HttpRequest.cancel(requestId)
    http.CANCEL(requestId)
end

-- 登录请求
-- loginType: FACEBOOK|GUEST
-- sitemid: 平台id gueest is mac， facebook is id
-- access_token: facebook access token

function HttpRequest.login(loginType, sitemid, access_token,sesskey, resultCallback, errorCallback)
    local deviceInfo = nk.Native:getDeviceInfo()

    local longitude,latitude = 0,0
    local jwStr = deviceInfo.location
    if jwStr ~= "" and jwStr ~= nil then
        local jwTab = string.split(jwStr,",")
        if jwTab and #jwTab == 2 then
            longitude = jwTab[1]
            latitude = jwTab[2]
        end
        
    end

    local params = {
       sig_sitemid = sitemid,
       sid         = appconfig.ROOT_CGI_SID,
       lid         = HttpRequest.setLoginType_(loginType), 
       mac         = nk.Native:getMacAddr(), --移动终端设备号 
       apkVer      = BM_UPDATE.VERSION, --游戏版本号，如"4.0.1","4.2.1" 
       sdkVer      = '1.0.0', --移动终端设备操作系统， 例如 "android_4.2.1"， "ios_4.1"
       net         = deviceInfo.networkType, --移动终端联网接入方式，例如 "wifi(1)", "2G(2)", "3G(3)", "4G(4)", "离线(-1)"。
       simOperatorName = deviceInfo.simNum, --移动终端设备所使用的网络运营商,如"电信"，"移动"，"联通" 
       machineType = deviceInfo.deviceModel, --移动终端设备机型.如："iphone 4s TD", "mi 2S", "IPAD mini 2" 
       pixel = string.format("%d*%d", display.width, display.height),--移动终端设备屏幕尺寸大小，如“1024*700”      
       idfa = nk.Native:getIDFA() , -- 设备标识 --android 为设备ID，IOS为IDFA
       longitude = longitude, -- 经度
       latitude = latitude    --纬度
    }  
    if loginType == "FACEBOOK" then
        params.access_token = access_token
        if sesskey then
            params.sesskey = sesskey
        end
    end


    -- dump(BM_UPDATE.LOGIN_URL,"HttpRequest.login")

    --如果未能从PHP得到登陆
    if BM_UPDATE.LOGIN_URL == nil then
        BM_UPDATE.LOGIN_URL = nk.userDefault:getStringForKey(nk.cookieKeys.SERVER_LOGIN_URL .. (device.platform))
    end

    if IS_DEMO then
        --如果是本地调试，需要加demo=1
        BM_UPDATE.LOGIN_URL = BM_UPDATE.LOGIN_URL .. "?demo=1"
    end

    -- if IS_PRE_INSTALL==true then
    --     params.channelId = CHANEL_ID;
    -- end
    local g = global_statistics_for_umeng
    local login_check_info = g.login_check_info
    local checkFlistBegin = os.time()
    local checkFlistEnd = 0
    return http.POST_URL(BM_UPDATE.LOGIN_URL, {game_param = json.encode(params), sig = crypto.md5(shJoins(params,0))}, 
        function(data)
            checkFlistEnd = os.time()
            login_check_info.result = "success"
            login_check_info.time = checkFlistEnd - checkFlistBegin
            local retData = json.decode(data)
            if type(retData) == "table" and retData.code and retData.code == 1 then                
                toOneDimensionalTable(retData.data)                
                typeFilter(retData.data, {
                    [tostring] = {'aUser.mavatar', 'aUser.memail', 'aUser.sitemid'},
                    [tonumber] = {
                        'aUser.lid', 'aUser.mid', 'aUser.mlevel', 
                        'aUser.mltime', 'aUser.win',  'aUser.lose','aUser.money', 'aUser.sitmoney', 
                        'isCreate', 'isFirst', 'mid', 'aUser.exp'
                    }
                })
                retData.data.uid = retData.data.mid

                if DEBUG > 4 then
                    dump(retData.data, "retData.data")
                end
                HttpRequest.setSessionKey(retData.data.sesskey)
                http.setDefaultURL(retData.data.gateway)
                if resultCallback then
                   resultCallback(retData.data) 
                end

                nk.userDefault:setStringForKey(nk.cookieKeys.SERVER_LOGIN_URL .. (device.platform), BM_UPDATE.LOGIN_URL)
                
            else
                checkFlistEnd = os.time()
                login_check_info.time = checkFlistEnd - checkFlistBegin
                login_check_info.result = "fail"
                if not retData then
                    logger:error("json parse error")
                    if errorCallback then
                       errorCallback({errorCode = 1}) 
                    end
                    
                else
                    if errorCallback then
                        errorCallback({errorCode = retData.code})
                    end
                    
                end
            end
        end, 
        function(errCode,errMsg)
            local errorData = {}
            if errCode ~= nil then
                errorData.errorCode = errCode
            end

            if errMsg ~= nil then
                errorData.errMsg = errMsg
            end

            if errorCallback then
                errorCallback(errorData)
            end

        end)
end

function HttpRequest.load(resultCallback, errorCallback)
    HttpRequest.request_("GameServer.load", {}, function(data)
       typeFilter(data.bankruptcyGrant,{
                    [tonumber] = {
                        'num', 'maxBmoney', 'bankruptcyTimes', 
                    }

                })

        typeFilter(data.best,{
                    [tostring] = {'maxwcard'},
                    [tonumber] = {
                        'bankruptcy', 'dayplaynum', 'invite','ispay','maxmoney','maxwmoney','mid','mwin','raward','rankMoney' 
                    }
                    
                })

       resultCallback(data)
    end, errorCallback)
end

function HttpRequest.getRoomList(resultCallback, errorCallback)
    HttpRequest.request_("Config.roomList", {}, resultCallback, errorCallback)
end


function HttpRequest.getMemberInfo(uid,resultCallback, errorCallback)
    return HttpRequest.request_("Member.getMemberByMid", {uid = uid}, function(data)
       typeFilter(data.aUser,{
                    [tostring] = {'name','sitemid','mcity','micon'},
                    [tonumber] = {
                        'lid', 'mid', 'mlevel', 
                         'win',  'lose','money', 
                         'exp','msex'
                    }
                })

       typeFilter(data.aBest,{
                    [tostring] = {'maxwcard'},
                    [tonumber] = {'maxmoney', 'maxwmoney','rankMoney'}
                })

       resultCallback(data);
    end, errorCallback)
end


function HttpRequest.getBankruptcyReward(resultCallback, errorCallback)
    return HttpRequest.request_("Bankruptcy.receiveBankruptcy", {}, resultCallback, errorCallback)
end


function HttpRequest.initRegisterAward(resultCallback, errorCallback)
    return HttpRequest.request_("Login.getRAwardLang", {}, resultCallback, errorCallback)
end

function HttpRequest.getRegisterAward(resultCallback, errorCallback)
    return HttpRequest.request_("Login.registrationAward", {}, resultCallback, errorCallback)
end


function HttpRequest.getLeverUpReward(level,resultCallback, errorCallback)
    return HttpRequest.request_("Level.upGrade", {level = level}, resultCallback, errorCallback)
end



function HttpRequest.giftBuy(pnid,tuids,resultCallback,errorCallback)
    return HttpRequest.request_("Props.buyGift", {pnid = pnid,fid = tuids}, resultCallback, errorCallback)
end


function HttpRequest.giftMineInfo(pmodes,resultCallback,errorCallback)
    return HttpRequest.request_("Props.getGiftList", {pmode = pmodes}, resultCallback, errorCallback)
end

function HttpRequest.modifyUserInfo(params,resultCallback,errorCallback)
    -- params: {name = xxx,msex = xxx}
    return HttpRequest.request_("Member.updateMinfo", params, resultCallback, errorCallback)
    
end

function HttpRequest.getUserMessage(resultCallback,errorCallback)
    return HttpRequest.request_("Message.getUserMessage", {}, resultCallback, errorCallback)
end

function HttpRequest.deleteUserMessage(msgId,resultCallback,errorCallback)
    return HttpRequest.request_("Message.deleteUserMessage", {id = msgId}, resultCallback, errorCallback)
end

function HttpRequest.readedUserMessage(msgId,resultCallback,errorCallback)
    return HttpRequest.request_("Message.readedMessage", {id = msgId}, resultCallback, errorCallback)
end

--使用道具/佩戴礼物统一接口
function HttpRequest.useProps(pnid,resultCallback,errorCallback)
    return HttpRequest.request_("Props.useProps", {pnid = pnid}, resultCallback, errorCallback)
end

--获取道具列表
function HttpRequest.getUserProps(pcid,resultCallback,errorCallback)
    return HttpRequest.request_("Props.getUserPropsList", {pcid = pcid}, resultCallback, errorCallback)
end

--获取邀请Id
function HttpRequest.getInviteId(resultCallback,errorCallback)
    return HttpRequest.request_("Invite.getInviteID", {}, resultCallback, errorCallback)
end

function HttpRequest.inviteAddMoney(data,resultCallback,errorCallback)
    return HttpRequest.request_("Invite.inviteAddMoney", data, resultCallback, errorCallback)
end

--上报PHP，领奖500
function HttpRequest.inviteReport(data,resultCallback,errorCallback)
    return HttpRequest.request_("Invite.inviteReport", data, resultCallback, errorCallback)
end

--更新用户头像
function HttpRequest.updateUserIcon(data,resultCallback,errorCallback)
     return HttpRequest.request_("Member.updateUserIcon", data, resultCallback, errorCallback)
end

--请求支付下单
function HttpRequest.callPayOrder(params,resultCallback,errorCallback)
    return HttpRequest.request_("Payment.callPayOrder",params,resultCallback,errorCallback)
end

--请求发货 params:table类型根据需要传参数--必需字段pmode:支付渠道
--[[
        checkout:(signedData,signature)
--]]
function HttpRequest.callClientPayment(params,resultCallback,errorCallback)
    return HttpRequest.request_("Payment.callClientPayment",params,resultCallback,errorCallback)
end

--获取支付渠道配置
function HttpRequest.getPayTypeConfig(version,resultCallback,errorCallback)
    return HttpRequest.request_("Payment.getAllPayList",{apkVer = version},resultCallback,errorCallback)
    --return HttpRequest.request_("Payment.getAllPayList",{apkVer = "1.0.7", channel = {pre = CHANEL_ID}},resultCallback,errorCallback)
end

--荷官小费
function HttpRequest.sendDealerChip(bets,num,resultCallback,errorCallback)
    return HttpRequest.request_("Member.sendDealerTip",{bets = bets,num = num},resultCallback,errorCallback)
end
--荷官小费(加现金币场) type 1 筹码，2现金币
function HttpRequest.sendDealerChipEx(bets, num, roomType, resultCallback, errorCallback)
    return HttpRequest.request_("Member.sendDealerTipInBanker", {bets = bets,num = num,type = roomType}, resultCallback, errorCallback)
end
function HttpRequest.getOnline(resultCallback,errorCallback)
    return HttpRequest.request_("GameServer.getRoomSitNumber",{},resultCallback,errorCallback)
end

function HttpRequest.reportPushToken(pushToken,reportKey,resultCallback,errorCallback)
    local clientData = {}
    if reportKey and (reportKey ~= "") then
        clientData[reportKey] = pushToken

    else
        clientData["clientid"] = pushToken
    end
    return HttpRequest.request_("Member.setClientid",clientData,resultCallback,errorCallback)
end


--破产上报
function HttpRequest.reportBankrupt(bets,roomName,resultCallback,errorCallback)
    local info = {}
    info.uphill_pouring = bets
    info.playground_title = roomName
    info.version_info = BM_UPDATE.VERSION
    return HttpRequest.request_("Bankruptcy.bankruptcyReport",info,resultCallback,errorCallback)
end


--更新用户最佳记录 maxmoney,maxwmoney,maxwcard,bankruptcy,dayplaynum,invite,ispay,mwin
function HttpRequest.updateMemberBest(params,resultCallback,errorCallback)
    local info = {}
    info.multiValue = params
    return HttpRequest.request_("Best.updateMemberBest",info,resultCallback,errorCallback)
end

--兑换码
function HttpRequest.exchangeCode(code,resultCallback,errorCallback)
    return HttpRequest.request_("Invite.checkConversionCode",{code = code},resultCallback,errorCallback)
end


--获取支付记录
function HttpRequest.getPayRecord(resultCallback,errorCallback)
    return HttpRequest.request_("Payment.getUserPayList",{},resultCallback,errorCallback)
end

function HttpRequest.getOnlineNumber(resultCallback,errorCallback)
    return HttpRequest.request_("GameServer.getOnlineNumber",{},resultCallback,errorCallback)
end


--获取转盘次数
function HttpRequest.getWheelInitInfo(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.getRotaryTableNum",{},resultCallback,errorCallback)
end
--分享转盘
function HttpRequest.shareWheel(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.changeLuckCount",{},resultCallback,errorCallback)
end

--获取转盘中奖信息
function HttpRequest.getWheelRewardInfo(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.rotaryTable",{},resultCallback,errorCallback)
end

--获取倒计时宝箱信息
function HttpRequest.getCountDownBoxInfo(resultCallback,errorCallback)
    return HttpRequest.request_("Chest.getChest",{},resultCallback,errorCallback)
end

--领取宝箱奖励信息
function HttpRequest.getCountDownBoxReward(resultCallback,errorCallback)
    return HttpRequest.request_("Chest.receiveChest",{},resultCallback,errorCallback)
end


--获取任务列表
function HttpRequest.getDailyTaskInfo(resultCallback,errorCallback)
    return HttpRequest.request_("Task.getAllTask",{},resultCallback,errorCallback)
end


--获取任务奖励
function HttpRequest.getDailyTaskReward(taskId,resultCallback,errorCallback)
    return HttpRequest.request_("Task.awardTask",{tid = taskId},resultCallback,errorCallback)
end

--获取好友列表
function HttpRequest.getHallFriendList(resultCallback,errorCallback)
    return HttpRequest.request_("Friends.getFriendsList",{getLevel = 1},resultCallback,errorCallback);
end

--赠送好友金币
function HttpRequest.sendCoinForFriend(friendId,resultCallback,errorCallback)
    return HttpRequest.request_("Friends.giveChouma",{fid=friendId},resultCallback,errorCallback)
end

--添加好友
function HttpRequest.addFriend(friendId,resultCallback,errorCallback)
    return HttpRequest.request_("Friends.addFriends",{fid = friendId},resultCallback,errorCallback)
end

--删除好友
function HttpRequest.deleteFriend(friendId,resultCallback,errorCallback)
    return HttpRequest.request_("Friends.deleteFriends",{fid=friendId},resultCallback,errorCallback)
end

--删除的好友List
function HttpRequest.getDeleteFriendsList(resultCallback,errorCallback)
    return HttpRequest.request_("Friends.getHasDelete",{},resultCallback,errorCallback);
end

--恢复好友
function HttpRequest.recoveryFriends(friendId,resultCallback,errorCallback)
    return HttpRequest.request_("Friends.recoveryFriends",{fid = friendId},resultCallback,errorCallback)
end

--获取全服排行
function HttpRequest.getAllServerRank(resultCallback,errorCallback)
    return HttpRequest.request_("Ranking.getRanking",{},resultCallback,errorCallback)
end

--赠送金币
function HttpRequest.sendCoinForRoom(mid,geterId,money,resultCallback,errorCallback)
    local info = {}
    info.mid = mid
    info.geterId = geterId
    info.money = money
    return HttpRequest.request_("Member.sendInHouse",info,resultCallback,errorCallback);
end

--赠送金币(现金币场) 1筹码场，2现金币场
function HttpRequest.sendCoinForRoomEx(mid,geterId,money,roomType,bets,resultCallback,errorCallback)
    local info = {}
    info.mid = mid
    info.geterId = geterId
    info.money = money
    info.type = roomType
    info.bets = bets
    return HttpRequest.request_("Member.sendInHouse",info,resultCallback,errorCallback);
end
--回赠
function HttpRequest.returnSendGift(msgId,resultCallback,errorCallback)
    local info = {}
    info.id = msgId;
   return HttpRequest.request_("Message.repayGift",info,resultCallback,errorCallback);
end
--以下是母亲节活动

--赠送好友茉莉花
function HttpRequest.sendFlowerForFriend(friendId,resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.sendJasmine",{fid = friendId},resultCallback,errorCallback)
end
--茉莉花兑换金币
function HttpRequest.getMoneyByFlower(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.getMoneyByFlower",{},resultCallback,errorCallback)
end
--兑换后分享领取金币
function HttpRequest.shareGetMoney(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.shareGetMoney",{},resultCallback,errorCallback)
end
--活动开关
-- function HttpRequest.getActivityData(resultCallback,errorCallback)
--     return HttpRequest.request_("GameActivity.activityDate",{},resultCallback,errorCallback)
-- end
--获取我的茉莉花数量
function HttpRequest.getMyFlowerNum(resultCallback,errorCallback)
     return HttpRequest.request_("GameActivity.getUserFlower",{},resultCallback,errorCallback)
end
function HttpRequest.feedShareGetReward(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.feedShareReward",{},resultCallback,errorCallback)
end

--上报错误接口
function HttpRequest.reportError(errStr,resultCallback,errorCallback)
    local info = {}
    info.log = errStr
    local time = os.time()
    info.sig = crypto.md5(time .. "|" .. "vanfo")
    info.time = time
    return HttpRequest.request_("GameServer.clientErrorLog",info,resultCallback,errorCallback)
   
end
--聚宝盆
--获取自己的聚宝盆
function HttpRequest.getSelfCornucopia(mid,resultCallback,errorCallback)
    local info = {}
    info.mid = mid;
    return HttpRequest.request_("Bowl.getMyProps",info,resultCallback,errorCallback)
end
--解锁接口
function HttpRequest.openLock(mid,id,resultCallback,errorCallback)
    local info = {}
    info.mid = mid
    info.pnid = id
    return HttpRequest.request_("Bowl.unlockBowl",info,resultCallback,errorCallback)
end
--种种子
function HttpRequest.plantSeed(mid,seedid,plandid,resultCallback,errorCallback)
    local info = {}
    info.mid = mid
    info.seedId = seedid
    info.bowlId = plandid
    return HttpRequest.request_("Bowl.plantSeed",info,resultCallback,errorCallback)
end
--加速
function HttpRequest.addSpeedForTree(mid,plandid,resultCallback,errorCallback)
    local info = {}
    info.mid = mid;
    info.bowlId = plandid;
    return HttpRequest.request_("Bowl.useAccelerators",info,resultCallback,errorCallback)
end
--收获
function HttpRequest.reapMySeed(mid,plandid,resultCallback,errorCallback)
    local info = {}
    info.mid = mid;
    info.bowlId = plandid;
    return HttpRequest.request_("Bowl.reapMySeed",info,resultCallback,errorCallback)
end
--获取聚宝盆好友列表(用等级排行)
function HttpRequest.getLevelRanlIds(mid,resultCallback,errorCallback)
     local info = {}
    info.mid = mid;
    return HttpRequest.request_("Bowl.getLevelRanlIds",info,resultCallback,errorCallback)
end
--获取好友的聚宝盆
function HttpRequest.getFriendCornucopia(mid,resultCallback,errorCallback)
    local info = {}
    info.fid = mid;
    return HttpRequest.request_("Bowl.getBowlStatus",info,resultCallback,errorCallback)
end
--偷取好友的聚宝盆
function HttpRequest.getFriendstealSeed(mid,fid,bowlId,resultCallback,errorCallback)
    local info = {}
    info.mid = mid;
    info.fid = fid;
    info.bowlId = bowlId
    return HttpRequest.request_("Bowl.stealSeed",info,resultCallback,errorCallback)
end

--获取我的收取记录
function HttpRequest.getMyRec(mid, resultCallback, errorCallback)
    -- body
    local info = {}
    info.mid = mid
    return HttpRequest.request_("Bowl.getStealList", info, resultCallback, errorCallback)  -- @param 接口名,顺利返回回调,错误回调
end
--获取我的收获记录（新版）
function HttpRequest.getMyRecord(resultCallback,errorCallback)
    local info = {}
    --info.mid = mid
    return HttpRequest.request_("Bowl.getRecode", info, resultCallback, errorCallback)
end
--拉取主人公告(聚宝盆)
function HttpRequest.getNotice(uid,resultCallback,errorCallback)
    local info = {}
    info.uid = uid
    return HttpRequest.request_("Bowl.getNotice",info,resultCallback,errorCallback)
end
--设置公告
function HttpRequest.setNotice(notice,resultCallback,errorCallback)
    local info = {}
    info.notice = notice
    return HttpRequest.request_("Bowl.setUserNotice",info,resultCallback,errorCallback)
end
--拉取好友留言
function HttpRequest.getFriendsMessage(uid,resultCallback,errorCallback)
    local info = {}
    info.uid = uid
    return HttpRequest.request_("Bowl.getMsg",info,resultCallback,errorCallback)
end
--设置留言
function HttpRequest.sendMsgToFriend(fid,msg,resultCallback,errorCallback)
    local info = {}
    info.fid = fid
    info.msg = msg
    return HttpRequest.request_("Bowl.leaveMsg",info,resultCallback,errorCallback)
    
end
--提醒好友
function HttpRequest.sendPlantMsg(fid,pid,resultCallback,errorCallback)
    local info = {}
    info.fid = fid
    info.bowlid = pid
    return HttpRequest.request_("Bowl.sendPlantMsg",info,resultCallback,errorCallback)
end
function HttpRequest.shareToGetSeed(mid,mode,resultCallback,errorCallback)
    local info = {}
    info.mid = mid
    info.mode=mode
    return HttpRequest.request_("Bowl.shar", info, resultCallback, errorCallback)
    -- body
end

--广告奖励
function HttpRequest.getPokdengAdReward(resultCallback, errorCallback)
    return HttpRequest.request_("Member.addmoney", info, resultCallback, errorCallback)
end

--保险箱取钱
function HttpRequest.bankGetMoney(money,btype,resultCallback,errorCallback)
    local params = {}
    params.money = money or 0
    params.type = btype or "money"
    return HttpRequest.request_("Bank.bankGetMoney",params,resultCallback,errorCallback)
end
--保险箱存钱
function HttpRequest.bankSaveMoney(money,btype,resultCallback,errorCallback)
    local params = {}
    params.money = money or 0
    params.type = btype or "money"
    return HttpRequest.request_("Bank.bankSaveMoney",params,resultCallback,errorCallback)
end
--保险箱设置密码
function HttpRequest.bankSetPassword(password,spassword,resultCallback,errorCallback)
    return HttpRequest.request_("Bank.bankSetPassword",{password = password ,spassword = spassword},resultCallback,errorCallback)
end
--保险箱开锁
function HttpRequest.bankOpenLock(password,resultCallback,errorCallback)
    return HttpRequest.request_("Bank.openLock",{password = password},resultCallback,errorCallback)
end
--删除保险箱锁
function HttpRequest.delPassword(resultCallback,errorCallback)
    return HttpRequest.request_("Bank.delPassword",{},resultCallback,errorCallback)
end

-- SignIn --

-- 新的签到初始化
function HttpRequest.getSignInDataNew(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("GameActivity.newSignLoad", info, resultCallback, errorCallback)
end

-- 新的签到
function HttpRequest.signInTodayNew(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("GameActivity.newSign", info, resultCallback, errorCallback)
end

-- 今天是否可签到
function HttpRequest.getIsCanSignState(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("GameActivity.isCanSign", info, resultCallback, errorCallback)
end

-- 签到初始化 (弃用)
function HttpRequest.getSignInData(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("GameActivity.loadSignIn", info, resultCallback, errorCallback)
end

-- 签到 (弃用)
function HttpRequest.signInToday(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("GameActivity.todaySignInReward", info, resultCallback, errorCallback)
end

-- 领取累计签到奖励 (弃用)
function HttpRequest.getAccumSignInReward(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("GameActivity.allSignReward", info, resultCallback, errorCallback)
end
-- SignIn End --

--连胜五局分享加金币
function HttpRequest.winFiveReward(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.winFivePrize",{},resultCallback,errorCallback)
end
--D后台上报接口
function HttpRequest.Dreport(sendData,resultCallback,errorCallback)
    local info = {reportData = sendData}
    return HttpRequest.request_("GameActivity.frontStatistics",info,resultCallback,errorCallback)
end
--宝箱抽奖
function HttpRequest.openLuckBox(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.luckBox",{},resultCallback,errorCallback)
end
--宝箱10连抽
function HttpRequest.tenOpenLuckBox(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.multiLuckBox",{},resultCallback,errorCallback)
end
--宝箱抽奖记录
function HttpRequest.openLuckBoxRecord(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.getLuckBoxLog",{},resultCallback,errorCallback)
end

-- UnionActPromot -- 
-- 登陆请求,发送三公游戏首次安装时间戳,返回显示开关状态
-- 获取联合推广开关状态
function HttpRequest.getUnionActShowState(state, resultCallback, errorCallback)
    -- body
    -- 重组数据 -- installStatus
    local info = {installStatus = state}

    -- dump(info, "HttpRequest.getUnionActShowState @param :===================")
    return HttpRequest.request_("GameActivity.unionEntrance", info, resultCallback, errorCallback)
end

-- 获取任务状态list
function HttpRequest.getClaimDataList(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("GameActivity.getUTaskStatus", info, resultCallback, errorCallback)
end

-- 领取任务一的奖励
function HttpRequest.claimUnionActRewardOne(installState, resultCallback, errorCallback)
    -- body
    local info = {installStatus = installState}

    return HttpRequest.request_("GameActivity.getUnionPrize1", info, resultCallback, errorCallback)
end

-- 领取任务二的奖励
function HttpRequest.claimUnionActRewardTwo(resultCallback, errorCallback)
    -- body

    return HttpRequest.request_("GameActivity.getUnionPrize2", info, resultCallback, errorCallback)
end

-- 领取任务三的奖励
function HttpRequest.claimUnionActRewardThree(resultCallback, errorCallback)
    -- body

    return HttpRequest.request_("GameActivity.getUnionPrize3", info, resultCallback, errorCallback)
end

-- 领取终极大奖
function HttpRequest.claimUnionActRewardSum(resultCallback, errorCallback)
    -- body

    return HttpRequest.request_("GameActivity.getFinalPrize", info, resultCallback, errorCallback)
end

-- 数据上报 (已弃用)
function HttpRequest.ReportActData(mode, resultCallback, errorCallback)
    -- body

    local info = {}
    info.mode = mode

    return HttpRequest.request_("GameActivity.unionReport", info, resultCallback, errorCallback)
end

-- end --

--随机获取30个在线玩家
function HttpRequest.getOnlinePlayer(resultCallback,errorCallback)
    return HttpRequest.request_("GameServer.getOnlineUserList",{},resultCallback,errorCallback)
end
--广播
function HttpRequest.broadcastUser(fid,type,content,resultCallback,errorCallback)
    local info = {}
    info.fid = fid;
    --info.type = type
    --info.content = content
    return HttpRequest.request_("GameServer.broadcastUser",info,resultCallback,errorCallback)
end
--安装广告应用添加金币
function HttpRequest.adAddMoney(adid,resultCallback,errorCallback)
    return HttpRequest.request_("Sendmoney.adAddmoney",{adid = adid},resultCallback,errorCallback)
end

-- 抽奖 --
function HttpRequest.buySlot(money, resultCallback, errorCallback)
    -- body
    local info = {money = money}

    return HttpRequest.request_("Slot.ernieSlot", info, resultCallback, errorCallback)
end

-- 中奖记录 --
function HttpRequest.querySlotLog(date, resultCallback, errorCallback)
    -- body
    local info = {date = date}

    return HttpRequest.request_("Slot.selectSlotLog", info, resultCallback, errorCallback)
end
-- 活动时间
function HttpRequest.getEggActTime(resultCallback,errorCallback)
    return HttpRequest.request_("GameActivity.eggTime",{},resultCallback,errorCallback)
end
--获取自己最新的礼物Id
function HttpRequest.getUserGift(uid, resultCallback, errorCallback)
    return HttpRequest.request_("Props.getUserGift",{uid = uid}, resultCallback, errorCallback)
end
-----------------------比赛接口start--------------------
--比赛报名
function HttpRequest.applyMatch(id,type,ticketid,resultCallback,errorCallback)
    --[[
        100：开始比赛，比赛状态错误
        101：开始比赛，玩家未达到开赛人数
        120：
        121：
        122：增加比赛失败
        123：玩家已经报过名了
        124：玩家已经满了
        125：
        126：比赛已经开始，不能退赛

    --]]
    local param = {}
    param.id = id
    param.type = type
    param.ticketid = ticketid
    -- param.time = time
    dump(param,"HttpRequest.applyMatch")
    return HttpRequest.request_("Match.register",param,resultCallback,errorCallback)
end
--退赛
function HttpRequest.matchOut(resultCallback,errorCallback)
    return HttpRequest.request_("Match.matchOut",{},resultCallback,errorCallback)
end
--比赛领奖
function HttpRequest.matchGetReward(params,resultCallback,errorCallback)
    return HttpRequest.request_("Match.matchReward",params,resultCallback,errorCallback)
end
--获取用户用户拥有的门票
function HttpRequest.getUserTickets(resultCallback,errorCallback)
    return HttpRequest.request_("Match.getUserMatchTickets",{},resultCallback,errorCallback)
end
--比赛记录
function HttpRequest.getMatchRecord(resultCallback,errorCallback)
    return HttpRequest.request_("Match.getAllMatchLog",{},resultCallback,errorCallback)
end
-----------------------比赛接口end----------------------
function HttpRequest.saveUserAddress(userAddrInfo,resultCallback,errorCallback)
    return HttpRequest.request_("Match.saveAddress",userAddrInfo,resultCallback,errorCallback)
end
function HttpRequest.getUserAddress(resultCallback,errorCallback)
    return HttpRequest.request_("Match.getUserAddress",{},resultCallback,errorCallback)
end
function HttpRequest.getMyExchangeRecord(category,resultCallback,errorCallback)
    return HttpRequest.request_("Match.getExchangeLog",{category = category},resultCallback,errorCallback)
end
function HttpRequest.exchangeGoodById(gid,category,resultCallback,errorCallback)
    return HttpRequest.request_("Match.exchange",{gid = gid,category = category},resultCallback,errorCallback)
end
function HttpRequest.getShopGoods(category,resultCallback,errorCallback)
    return HttpRequest.request_("Match.getShopGoods",{category = category},resultCallback,errorCallback)
end

--获取兑换商城初始化信息
function HttpRequest.getShopInitInfo(resultCallback,errorCallback)
    return HttpRequest.request_("Match.shopInit",{},resultCallback,errorCallback)
end


function HttpRequest.getFreeApplyMatchNum(id,resultCallback,errorCallback)
    return HttpRequest.request_("Match.getMidTodayRegisterByFeeNum",{id = id},resultCallback,errorCallback)
end
function HttpRequest.getMatchExitLeftTime(id,resultCallback,errorCallback)
    return HttpRequest.request_("Match.getMidMatchRegisterTime",{id = id},resultCallback,errorCallback)
end

--获取比赛场在线人数
function HttpRequest.getMatchOnlineNum(configVer,resultCallback,errorCallback)
    return HttpRequest.request_("Match.getMatchInfo",{version = configVer},resultCallback,errorCallback)
end

--请求比赛场邀请广播
function HttpRequest.matchBroadcastRoomReq(resultCallback,errorCallback)
    return HttpRequest.request_("Match.broadcastToTable", {}, resultCallback, errorCallback)
end

-- PropShop --
-- 获取道具商城数据DataList
function HttpRequest.getPropShopProdList(resultCallback, errorCallback)
    return HttpRequest.request_("Props.getProsShopList", info, resultCallback, errorCallback)
end

-- 购买道具包
function HttpRequest.buyProps(propPackId, resultCallback, errorCallback)
     return HttpRequest.request_("Props.buyProps", {id = propPackId}, resultCallback, errorCallback)
end
-- PropShop --

-- 广告推广点击上报 --
function HttpRequest.reportAdPromot(clickType, resultCallback, errorCallback)
    -- body
    local param = {}
    param.type = clickType
    return HttpRequest.request_("GameServer.popadreport", param, resultCallback, errorCallback)
end

-- 获取比赛场泡泡信息
function HttpRequest.getMatchPaopInfo(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Match.getTipsMsg", param, resultCallback, errorCallback)
end


--根据传入的字段获取相应的信息
function HttpRequest.getInfoByKeys(keysTb,resultCallback, errorCallback)
    if not keysTb then
        return
    end
    local keysStr = table.concat(keysTb,",")
    return HttpRequest.request_("Member.getInfoByClient", {paramString = keysStr}, resultCallback, errorCallback)
end

-- SuonaUseFunc --
-- 发送小喇叭广播 --
function HttpRequest.broadcastSuonaMsg(msg, resultCallback, errorCallback)
    -- body
    local param = {}
    param.pnid = 3001  -- 小喇叭道具Id
    param.ext = msg

    return HttpRequest.request_("Props.useProps", param, resultCallback, errorCallback)
end

-- 获取小喇叭记录(仅显示近50条)
function HttpRequest.getSuonaMsgRecord(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Props.getBroccastRecode", {}, resultCallback, errorCallback)
end
-- end --

-- Payment Expression --
-- 使用付费表情 --
function HttpRequest.usePaymentExpr(exprUseParam, resultCallback, errorCallback)
    -- body
    local param = {}
    param.bets = exprUseParam.roomBets
    param.roomType = exprUseParam.roomType 
    param.type = exprUseParam.QExprId

    return HttpRequest.request_("Props.useQFacial", param, resultCallback, errorCallback)
end


--获取拍卖数据
function HttpRequest.getAuctionCenterData(category,curPage,pageNum,sortkey,order,resultCallback, errorCallback)
    local param = {}
    param.category = category or 0 -- 类型: 0全部  1现金币 2兑换券
    param.offset = curPage or 1  -- 请求页码
    param.limit = pageNum or 20    --每页请求的数量
    param.sortkey = sortkey or "time"   --排序关键字 time 添加时间 pre 低价 price 当前价
    param.order = order or 0 -- 0 正序 1倒序
    return HttpRequest.request_("Auction.getAuctionCenterData", param, resultCallback, errorCallback)
end



--获取我的拍卖数据
function HttpRequest.getMyAuctionData(category,resultCallback,errorCallback)
    return HttpRequest.request_("Auction.getMyAuctionItem",{category = category},resultCallback,errorCallback)
end

--[[
添加拍卖
"code": 1 //成功
        -1等级不足
        -2拍卖物品不足
        -3在拍物品已经达三件
        -4更新拍卖物品数量失败
        -5 更新数据库失败
--]]
function HttpRequest.addAuctSellProdData(params, resultCallback, errorCallback)
    local param = {}
    param.type = params.prodType
    param.num = params.num
    param.expire = params.expireTime
    param.flag = params.auctType
    param.money = params.auctStartPrice
    
    return HttpRequest.request_("Auction.addAuctionItem", param, resultCallback, errorCallback)
end



-- 获取一口价列表数据
function HttpRequest.getAuctionFixedPriceData(category,curPage,pageNum,sortkey,order,resultCallback, errorCallback)
    local param = {}
    param.category = category or 0 -- 类型: 0全部  1现金币 2兑换券
    param.offset = curPage or 1  -- 请求页码
    param.limit = pageNum or 20    --每页请求的数量
    param.sortkey = sortkey or "time"   --排序关键字 time 添加时间 pre 低价 price 当前价
    param.order = order or 0 -- 0 正序 1倒序
    return HttpRequest.request_("Auction.getOnePriceData", param, resultCallback, errorCallback)
end

--获取可拍卖的物品数据
function HttpRequest.getCanAuctionData(resultCallback, errorCallback)
   return HttpRequest.request_("Auction.getCanAuction", {}, resultCallback, errorCallback)
end

--[[ 
    竞拍接口
     "code": 1 //成功
            -1没有这个物品
            -2参数错误
            -3筹码不足
            -4扣钱失败
            -5出价低于底价
            -6已过期
            -7出价低于目前价格
            -8已近被拍走
            -9等级不足
--]]
function HttpRequest.auctProd(params, resultCallback, errorCallback)
    local param = {}
    param.itemid = params.itemId
    param.flag = params.auctType
    param.money = params.auctPrice
    return HttpRequest.request_("Auction.auction", param, resultCallback, errorCallback)
end

function HttpRequest.getAuctionRecordData(category,resultCallback,errorCallback)
     return HttpRequest.request_("Auction.getAuctionLog",{category = category},resultCallback,errorCallback)
end

-- 获取拍卖时间开关状态.
function HttpRequest.getAuctionInitInfo(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Auction.init", {}, resultCallback, errorCallback)
end

--现金币场赢现金币上报
function HttpRequest.sendWinPoint(roomid,winmoney,resultCallback,errorCallback)
    local info = {}
    info.roomid = roomid;
    info.win = winmoney
    return HttpRequest.request_("Broadcast.sendWinPointNotice",info,resultCallback,errorCallback)
end

--获取连续7天没有登录的好友
function HttpRequest.getRecallFriends(mid,resultCallback,errorCallback)
    local info = {}
    info.mid = mid
    return HttpRequest.request_("Login.getRecalledFriends",info,resultCallback,errorCallback)
end
--召回数据初始化
function HttpRequest.getInitializeRecall(mid,resultCallback,errorCallback)
    local info = {}
    info.mid = mid
    return HttpRequest.request_("Login.initializeRecall",info,resultCallback,errorCallback)
end
--通知后端已给玩家发送过FB平台召回推送
function HttpRequest.recallFriends(mid,sitemids,resultCallback,errorCallback)
    local info = {}
    info.mid = mid
    info.sitemids = sitemids
    return HttpRequest.request_("Login.recallFriendsAward",info,resultCallback,errorCallback)
end

function HttpRequest.reportHasInvitedUserInfo(headImgMD5Info, resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Invite.cacheHasInvitedKey", {info = headImgMD5Info}, resultCallback, errorCallback)
end

function HttpRequest.getFriendFliterData(data, resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Invite.filterInviteList", {data = data}, resultCallback, errorCallback)
end

--上庄场表情配置
function HttpRequest.getGrabRoomList(resultCallback, errorCallback)
    return HttpRequest.request_("Config.bankerRoomList", {}, resultCallback, errorCallback)
end
--上庄场广播邀请
function HttpRequest.sendGrabBroadCast(baseChip,resultCallback,errorCallback)
    local info = {}
    info.baseChip = baseChip
    return HttpRequest.request_("Broadcast.bankerroomBroadcastToTable",info,resultCallback,errorCallback)
end
-- 版本更新初始化信息
function HttpRequest.GetUpdateVerInitInfo(resultCallback, errorCallback)
    return HttpRequest.request_("Updateversion.load", {}, resultCallback, errorCallback)
end

--获取更新奖励
function HttpRequest.GetUpdateVerReward(resultCallback, errorCallback)
    return HttpRequest.request_("Updateversion.getPrize", {}, resultCallback, errorCallback)
end

-- 拉取首冲优惠礼包订单
function HttpRequest.getPaymentList(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Payment.firstpayCfg", {}, resultCallback, errorCallback)
end
-- end --

-- 上报首冲优惠数据 -- @param :evtType : 1.满足条件的人数上报, 2.成功展示出来看见
function HttpRequest.reportFirstPayData(evtType, resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Payment.reportFirstPay", {flag = evtType}, resultCallback, errorCallback)
end
-- end --

-- 拉取优惠充值大礼包数据 --
function HttpRequest.getAlmRechargePaymentList(packType, resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Payment.payBagCfg", {type = packType}, resultCallback, errorCallback)
end
-- End --

-- Dokb Req -- 
-- Get ActList --
function HttpRequest.getDokbActList(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Gettreasure.treasureList", {}, resultCallback, errorCallback)
end

-- Attend Act --
function HttpRequest.attendActDokb(id, resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Gettreasure.startTreasure", {id = id}, resultCallback, errorCallback)
end

-- LotryRecTermId --
function HttpRequest.getDokbLotryRecTermId(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Gettreasure.treasureDay", {}, resultCallback, errorCallback)
end

-- Get LotryRec --
function HttpRequest.getDokbLotryRec(termId, resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Gettreasure.resultRecord", {time = termId}, resultCallback, errorCallback)
end

-- Get MyRec --
function HttpRequest.getDokbMyAtdRec(resultCallback, errorCallback)
    -- body
    return HttpRequest.request_("Gettreasure.awardList", {}, resultCallback, errorCallback)
end

-- Get Reward --
function HttpRequest.getDokbMyReward(id, resultCallback, errorCallback)
    -- body
    local param = {}
    param.rewardId = id

    return HttpRequest.request_("Gettreasure.getAward", param, resultCallback, errorCallback)
end
-- End --


--新比赛--
------定时赛列表----
function HttpRequest.getTimeMatchList(mtype,resultCallback,errorCallback)
    local tb = {}
    tb.type = mtype
    return HttpRequest.request_("Match.getMatchCfg",tb,resultCallback,errorCallback)
end

--获取定时赛报名人数
function HttpRequest.getTimeMatchPeople(tb,resultCallback,errorCallback)
    local param = {}
    param.times = tb
    return HttpRequest.request_("Match.getTimeMatchPeople",param,resultCallback,errorCallback)
end

--[[报名定时赛
-1//缺少参数
-2//这个比赛场已经关闭
-3//钱不满足报名条件
-4//比赛门票不满足报名条件
-6//扣钱失败 报名失败
-7//扣报名券失败 报名失败
-8//报名次数今天达到限制
-9//报名时间不对
-20//php $mid 或者 $type 没传给server    (直接提示网络错误)
-21//php SendData失败  没连接上server (直接提示网络错误)
-22//php socket_recv PHP接收server数据失败    (直接提示网络错误)
100//开始比赛，比赛状态错误
101;//开始比赛，玩家未达到开赛人数
122//增加比赛失败
123//玩家已经报过名了
124//玩家已经满了
--]]
function HttpRequest.registerMatch(id,type,ticketid,time,resultCallback,errorCallback)
    local param = {}
    param.id = id
    param.type = type
    param.ticketid = ticketid
    param.time = time
    
    --test--
    --param = {id = 101, type = 1,time = "201605311430"}
    return HttpRequest.request_("Match.register",param,resultCallback,errorCallback)
end


--获取已报名的比赛场次信息
function HttpRequest.getRegisteredMatchInfo(resultCallback,errorCallback)
    return HttpRequest.request_("Match.getTimeMatchInStartTime",{},resultCallback,errorCallback)
end

--定时赛退赛
function HttpRequest.outMatch(matchid,resultCallback,errorCallback)
    return HttpRequest.request_("Match.matchOut",{matchid = matchid},resultCallback,errorCallback)
end
--比赛大厅各数据信息
function HttpRequest.matchHallInfo(resultCallback,errorCallback)
    return HttpRequest.request_("Member.getMatchInfoByMid",{},resultCallback,errorCallback)
end

function HttpRequest.ticketTransfer(resultCallback,errorCallback)
    return HttpRequest.request_("Props.ticketTransformPoint",{},resultCallback,errorCallback)
end


--新手引导奖励初始化信息
function HttpRequest.newerInit(resultCallback,errorCallback)
    return HttpRequest.request_("Login.initFirstDayPlayingCardsRecorder",{},resultCallback,errorCallback)
end


function HttpRequest.newerPlay(resultCallback,errorCallback)
    return HttpRequest.request_("Login.firstDayPlayingCardsAward",{},resultCallback,errorCallback)
end

function HttpRequest.newerNextDayReward(resultCallback,errorCallback)
    return HttpRequest.request_("Login.registrationNextDayAward",{},resultCallback,errorCallback)
end

return HttpRequest