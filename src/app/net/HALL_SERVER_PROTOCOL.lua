--
-- Author: LeoLuo
-- Date: 2015-05-09 10:03:08
--

local T = bm.PACKET_DATA_TYPE
local P = {}

local HALL_SERVER_PROTOCOL = P
P.CONFIG = {}
P.CONFIG.CLIENT = {}
P.CONFIG.SERVER = {}
local CLIENT = P.CONFIG.CLIENT
local SERVER = P.CONFIG.SERVER

----------------------------------------------------------------
------------------------- 客户端请求  --------------------------
----------------------------------------------------------------
P.CLI_LOGIN                      = 0x0116    --登录大厅
CLIENT[P.CLI_LOGIN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "userInfo", type = T.STRING}
    }
}

P.CLI_GET_ONLINE                 = 0x0311    --客户端请求获取各等级场在线人数
CLIENT[P.CLI_LOGIN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "userInfo", type = T.STRING}
    }
}

P.CLI_GET_ROOM                   = 0x0113    --获取房间id
CLIENT[P.CLI_GET_ROOM] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.INT},   --桌子等级
        {name = "type", type = T.BYTE},   --登陆类型，0--随机登陆，1--指定桌子登陆
        {name = "targetid", type = T.INT} --目标桌子ID，0表示随机登陆
    }
}

P.CLI_CHANGE_ROOM               = 0x0115  --用户请求换桌
CLIENT[P.CLI_CHANGE_ROOM] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.INT},   --桌子等级
        {name = "tid", type = T.INT} --原来的桌子id
    }
}

    
P.CLI_LOGIN_ROOM                 = 0x1001    --登录房间
CLIENT[P.CLI_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},   --桌子ID
        {name = "uid", type = T.INT},   --用户ID
        {name = "mtkey", type = T.STRING}, --需要验证的key
        {name = "strinfo", type = T.STRING}, --用户个人信息
        {name = "extrainfo", type = T.STRING} --用户个人附加信息
    }
}


P.CLI_LOGOUT_ROOM                = 0x1002    --用户请求离开房间
CLIENT[P.CLI_LOGOUT_ROOM] = nil


P.CLI_SEAT_DOWN                  = 0x1013    --用户请求坐下
CLIENT[P.CLI_SEAT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},   -- 座位ID
        {name = "ante", type = T.INT64},    -- 携带金额      
        {name = "autoBuyin", type = T.INT}  -- 自动买入
    }
}

P.CLI_STAND_UP                   = 0x1004    --用户请求站立
CLIENT[P.CLI_STAND_UP] = nil

P.CLI_OTHER_CARD                 = 0x1005    --用户请求第三张牌
CLIENT[P.CLI_OTHER_CARD] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT} --是否需要第三张牌，0--不需要，1--需要
    }
}

P.CLI_SET_BET                    = 0x1006    --用户下注
CLIENT[P.CLI_SET_BET] = {
    ver = 1,
    fmt = {
        {name = "ante", type = T.INT64} --下注
    }
}

P.CLI_SEND_MSG                   = 0x1007    --用户请求房间内聊天
CLIENT[P.CLI_SEND_MSG] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, --聊天类型，目前无区分，默认为0；/*0--字符，1--表情*/
        {name = "strChat", type = T.STRING} --聊天内容
    }
}


P.CLI_SEND_ROOM_BROADCAST                   = 0x1050   --发送房间广播
CLIENT[P.CLI_SEND_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "info", type = T.STRING} -- 发送内容json
    }
}


P.CLI_GET_PERSONAL_ROOM_LIST            = 0x0117 -- 请求私人房列表
CLIENT[P.CLI_GET_PERSONAL_ROOM_LIST] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT}, -- 房间等级
        {name = "page",type = T.SHORT}, -- 页码
        {name = "num",type = T.SHORT} -- 每次请求的数量
    }
}

P.CLI_CREATE_PERSONAL_ROOM              = 0x0118  -- 请求创建私人房
CLIENT[P.CLI_CREATE_PERSONAL_ROOM] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT}, -- 房间等级
        {name = "baseChip",type = T.INT}, -- 房间底注
        {name = "roomName",type = T.STRING}, -- 房间名称
        {name = "pwd",type = T.STRING} -- 房间密码
    }
}

P.CLI_SEARCH_PERSONAL_ROOM              = 0x0119    --请求搜索私人房
CLIENT[P.CLI_SEARCH_PERSONAL_ROOM] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT}, -- 房间等级
        {name = "tableID",type = T.INT}, -- 房间ID
    }
}

P.CLI_LOGIN_PERSONAL_ROOM             = 0x0120    --请求登录私人房
CLIENT[P.CLI_LOGIN_PERSONAL_ROOM] = {
    ver = 1,
    fmt = {
        {name = "level", type = T.SHORT}, -- 房间等级
        {name = "tableID",type = T.INT}, -- 桌子ID
        {name = "pwd",type = T.STRING}, -- 房间密码
    }
}

------------------------比赛场-----------------------------
P.CLI_CHECK_JION_MATCH               = 0x0215      -- 客户端确认比赛报名信息
CLIENT[P.CLI_CHECK_JION_MATCH] = {
    ver = 1,
    fmt = {
        {name = "matchid",type = T.INT} --比赛场ID
    }
}

P.CLI_LOGIN_MATCH_ROOM                  = 0x7051    -- 客户端请求登录比赛场
CLIENT[P.CLI_LOGIN_MATCH_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tid",type = T.INT},--比赛场桌子ID
        {name = "uid",type = T.INT},--用户ID
        {name = "matchid",type = T.INT},--比赛场ID
        {name = "strinfo",type = T.STRING} --用户信息
    }
}

P.CLI_JOIN_ROOM_WAIT = 0x0217               --(定时赛)用户确认进场等待
CLIENT[P.CLI_JOIN_ROOM_WAIT] = {
    ver = 1,
    fmt = {
        {name = "matchid",type = T.INT}--比赛场桌子ID
    }
}

P.CLI_MATCH_SET_BET                    = 0x7053    --用户下注
CLIENT[P.CLI_MATCH_SET_BET] = {
    ver = 1,
    fmt = {
        {name = "betState",type = T.INT},--(1看牌 2跟注 3加注 4弃牌,5allin)
        {name = "anteNum", type = T.INT} --下注
        
    }
}

P.CLI_MATCH_QUIT                    = 0x7055    --用户退赛
CLIENT[P.CLI_MATCH_QUIT] = nil



P.CLI_MATCH_THIRD_CARD                    = 0x7057    --用户要牌
CLIENT[P.CLI_MATCH_THIRD_CARD] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT} --是否需要第三张牌，0--不需要，1--需要
    }
}



P.CLI_MATCH_CANCEL_AI               = 0x7817    --用户取消托管
CLIENT[P.CLI_MATCH_CANCEL_AI]=nil


P.CLI_MATCH_GET_LEFT_GAME_EXIT = 0x7825         --用户获取自己玩多少局可以强制退赛
CLIENT[P.CLI_MATCH_GET_LEFT_GAME_EXIT]=nil

P.CLI_MATCH_PORCE_EXIT_GAME = 0x7827                  --玩家强制退赛
CLIENT[P.CLI_MATCH_PORCE_EXIT_GAME]=nil

------------------------比赛场-----------------------------

-----------------------上庄玩法-------------------------
-- P.CLI_REQUEST_GRAB_ROOM_LIST =  0x0125      --请求房间列表
-- CLIENT[P.CLI_REQUEST_GRAB_ROOM_LIST]    = {
--     ver = 1,
--     fmt = {
--         {name = "level", type = T.SHORT},   --等级
--         {name = "page", type = T.SHORT},   --页码
--         {name = "num", type = T.SHORT}, --数量
--         {name = "cash", type = T.INT} -- 0非现金币场 1现金币场 2混合
--     }
-- }

P.CLI_LOGIN_GRAB_DEALER_ROOM =  0x1054      --用户请求登录
CLIENT[P.CLI_LOGIN_GRAB_DEALER_ROOM]    = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT},   --桌子ID
        {name = "uid", type = T.INT},   --用户ID
        {name = "mtkey", type = T.STRING}, --需要验证的key
        {name = "strinfo", type = T.STRING}, --用户个人信息
        {name = "extrainfo", type = T.STRING} --用户个人附加信息
    }
}


P.CLI_REQUEST_GRAB_DEALER =     0x1055      --玩家请求上庄
CLIENT[P.CLI_REQUEST_GRAB_DEALER]     = {
    ver = 1,
    fmt = {
        {name = "handCoin",type = T.INT64}--携带筹码
    }
}  

P.CLI_DEALER_ADD_COIN =         0x1059   --上庄玩家补币
CLIENT[P.CLI_DEALER_ADD_COIN]     = {
    ver = 1,
    fmt = {
        {name = "addCoin",type = T.INT64}--追加金币
    }
}   

P.CLI_REQUEST_GRAB_ROOM_LIST_NEW = 0x0126  -- 拉取上庄场列表(新协议) 
CLIENT[P.CLI_REQUEST_GRAB_ROOM_LIST_NEW]     = {
    ver = 1,
    fmt = 
    {
        {name = "page",type = T.SHORT}, --页码
        {name = "num",type = T.SHORT}, -- 请求总数量
        {name = "cash",type = T.INT}, --0非现金币场 1现金币场 2混合
        {name = "isnew",type = T.INT} -- 新版列表
    }
}

-----------------------------------------------------------
-------------------  服务端返回  --------------------------
-----------------------------------------------------------
P.SVR_DOUBLE_LOGIN               = 0x0203    --用户重复登陆
SERVER[P.SVR_DOUBLE_LOGIN] = nil


P.SVR_LOGIN_OK                   = 0x0201    --登录成功
SERVER[P.SVR_LOGIN_OK] = {
    ver = 1,
    fmt = {
        {name = "levelCount", type = T.INT},--等级场个数
        {name = "tid", type = T.INT}, --桌子ID，0表示无桌子，第一次登陆; 不为0时则表示需要重连
        {name = "ip", type = T.STRING}, --忽略
        {name = "port", type = T.INT},
    }
}

P.SVR_LOGIN_OK_NEW              = 0x202       --登录成功
SERVER[P.SVR_LOGIN_OK_NEW] = {
    ver = 1,
    fmt = {
        {name = "levelCount", type = T.INT},--等级场个数
        {name = "tid", type = T.INT}, --桌子ID，0表示无桌子，第一次登陆; 不为0时则表示需要重连
        {name = "ip", type = T.STRING}, --忽略
        {name = "port", type = T.INT},
        {name = "matchid", type = T.INT}, -- 比赛场ID
    }
}
P.SVR_LOGIN_OK_RE_CONECT = 0x204           --登录成功(最新版，登录，重连都是它)
SERVER[P.SVR_LOGIN_OK_RE_CONECT] = {
    ver = 1,
    fmt = {
        {name = "levelCount", type = T.INT},--等级场个数
        {name = "tid", type = T.INT}, --桌子ID，0表示无桌子，第一次登陆; 不为0时则表示需要重连
        {name = "ip", type = T.STRING}, --忽略
        {name = "port", type = T.INT},
        {name = "type", type = T.INT}, -- 类型
        {name = "extStr",type = T.STRING,depends=function(ctx) return (ctx.type == 2 or ctx.type ==4) end },--JSON串，里面可能包含matchid
    }
}
P.SVR_ONLINE                     = 0x0311    --服务器返回客户端各等级场在线人数
SERVER[P.SVR_ONLINE] = {
    ver = 1,
    fmt = {
        {  
            name = "levelOnlines", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "level", type = T.INT},   --等级场ID
                {name = "userCount", type = T.INT} --在线人数
            }
        }
    }
}

P.SVR_GET_ROOM_OK                = 0x0210    --获取房间id结果
SERVER[P.SVR_GET_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT}, --桌子ID
        {name = "ip", type = T.STRING}, --忽略
        {name = "port", type = T.INT}
    }
}


P.SVR_LOGIN_ROOM_OK              = 0x2001    --登录房间OK
SERVER[P.SVR_LOGIN_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tableId", type = T.INT},--桌子ID
        {name = "tableLevel", type = T.INT},   --桌子level     
        {name = "tableStatus", type = T.BYTE}, --桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌
        {name = "dealerSeatId", type = T.INT},--庄家座位Id
        {name = "curDealSeatId", type = T.INT},--如果为发第三张牌时，为当前询问发牌的座位
        {name = "baseAnte", type = T.INT64},--底注
        {name = "totalAnte", type = T.INT64},--桌子上的总筹码数量
        {name = "userAnteTime", type = T.BYTE}, -- 下注等待时间
        {name = "extraCardTime", type = T.BYTE}, -- 询问发第三张牌等待时间
        {name = "maxSeatCnt", type = T.BYTE}, -- 总的座位数量
        {name = "minAnte", type = T.INT64},--最小携带
        {name = "maxAnte", type = T.INT64},--最大携带
        {name = "defaultAnte", type = T.INT64},--默认携带
        {  
            name = "playerList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "uid", type = T.INT},--用户ID
                {name = "seatId", type = T.INT},--用户座位ID
                --{
                --"msex":"0",
                --"money":50000,
                --"mavatar":"",
                --"name":"deviceModel",
                --"sitemid":"C4:6A:B7:61:7E:F8",
                --"mlevel":1
                --}
                {name = "userInfo", type = T.STRING},--用户信息
                {name = "anteMoney", type = T.INT64},--用户携带
                {name = "nCurAnte", type = T.INT64},--当次下注
                {name = "nWinTimes", type = T.INT},--玩家的赢次数
                {name = "nLoseTimes", type = T.INT},--玩家的输次数
                {name = "isOnline", type = T.BYTE}, --（其他用户连接状态） 0--用户掉线   1--用户在线
                {name = "isPlay", type = T.BYTE},  -- 是否在玩牌
                {name = "isOutCard", type = T.INT}, -- 1 亮牌  0 不亮牌
                {name = "cardsCount", type = T.INT}, --用户手牌数量
                {name = "card1", type = T.BYTE, depends=function(ctx, row) return row.isOutCard == 1 end},--扑克牌数值, 无为0
                {name = "card2", type = T.BYTE, depends=function(ctx, row) return row.isOutCard == 1 end},
                {name = "card3", type = T.BYTE, depends=function(ctx, row) return row.isOutCard == 1 end}               
            }
        }
    }
}


P.SVR_LOGIN_ROOM_FAIL            = 0x2011    --登录房间失败
SERVER[P.SVR_LOGIN_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errno", type = T.INT}
    }
}

P.SVR_LOGOUT_ROOM_OK             = 0x1008    --登出房间OK
SERVER[P.SVR_LOGOUT_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "money", type = T.INT64}--用户金币值
    }
}

P.SVR_SELF_SEAT_DOWN_OK                  = 0x2003
SERVER[P.SVR_SELF_SEAT_DOWN_OK] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT}   --0--成功，非0--失败   
    }
}

P.SVR_STAND_UP                   = 0x2004    --用户请求站起
SERVER[P.SVR_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.INT},--0--成功，非0--失败
        {name = "seatId", type = T.INT},--座位ID
        {name = "money", type = T.INT64}--用户金币值
    }
}

P.SVR_OTHER_CARD                 = 0x2005    --用户请求第三张牌结果
SERVER[P.SVR_OTHER_CARD] = {
    ver = 1,
    fmt = {      
        {name = "card", type = T.BYTE}
    }
}

P.SVR_SET_BET                    = 0x2006    --用户请求修改底注结果
SERVER[P.SVR_SET_BET] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},-- 0--成功，1--失败
        {name = "errno", type = T.INT, depends=function(ctx) return ctx.ret == 1 end}
    }
}

P.SVR_MSG                        = 0x2007    --服务器广播房间内聊天
SERVER[P.SVR_MSG] = {
    ver = 1,
    fmt = {
        {name = "type", type = T.INT}, -- 聊天类型，目前无区分，默认为0；/*0--字符，1--表情*/
        {name = "strChat", type = T.STRING} --聊天内容
    }
}

P.SVR_DEAL                       = 0x2008    --发牌,通知玩家手牌
SERVER[P.SVR_DEAL] = {
    ver = 1,
    fmt = {
        {  
            name = "cards", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {type = T.BYTE},   --扑克牌数值          
            }
        }
    }
}

P.SVR_LOGIN_ROOM                 = 0x6001    --服务器广播用户登陆房间
SERVER[P.SVR_LOGIN_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INI},--用户ID
        {name = "userInfo", type = T.STRING},--用户个人信息
        {name = "anteMoney", type = T.INT64},--用户金币值
        {name = "winTimes", type = T.INT},--用户赢次数
        {name = "loseTimes", type = T.INT}--用户输次数
    }   
}

P.SVR_LOGOUT_ROOM                = 0x6002    --服务器广播用户登出房间
SERVER[P.SVR_LOGOUT_ROOM] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}     
    }
}


P.SVR_SEAT_DOWN            = 0x6003    --服务器广播用户坐下
SERVER[P.SVR_SEAT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},--用户ID
        {name = "seatId", type = T.INT},--座位ID
        {name = "anteMoney", type = T.INT64}, -- 携带金额
        {name = "money", type = T.INT64}, --身上的总钱数,包括携带的值    
        {name = "userInfo", type = T.STRING}, --用户个人信息       
        {name = "winTimes", type = T.INT},--用户赢次数
        {name = "loseTimes", type = T.INT}--用户输次数
    }
}

P.SVR_OTHER_STAND_UP             = 0x6004    --服务器广播用户站起
SERVER[P.SVR_OTHER_STAND_UP] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "seatId", type = T.INT}           
    }
}

P.SVR_OTHER_OFFLINE              = 0x6005    --服务器广播用户掉线
SERVER[P.SVR_OTHER_OFFLINE] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT}       
    }
}

P.SVR_GAME_START                 = 0x6006    --服务器广播游戏开始
SERVER[P.SVR_GAME_START] = {
    ver = 1,
    fmt = {
        {name = "dealerSeatId", type = T.INT}, --庄家座位Id
        {  
            name = "anteMoneyList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "seatId", type = T.INT},  --座位ID
                {name = "anteMoney", type = T.INT64} --用户携带
            }
        }
    }
}

P.SVR_GAME_OVER                  = 0x6007    --服务器广播牌局结束，结算结果
SERVER[P.SVR_GAME_OVER] = {
    ver = 1,
    fmt = {
        {  
            name = "playerList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "uid", type = T.INT},--用户ID
                {name = "seatId", type = T.INT},--玩家座位
                {name = "trunMoney", type = T.INT64}, --用户金币变化值               
                {name = "anteMoney", type = T.INT64},--携带金额
                {name = "getExp", type = T.INT},--变化的经验值
                {  
                    name = "cards", type = T.ARRAY,
                    lengthType = T.INT,
                    fmt = {
                        {type = T.BYTE}   --扑克牌数值          
                    }
                }
            }
        }
    }
}

P.SVR_BET                   = 0x6008    --服务器广播玩家下注
SERVER[P.SVR_BET] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "nCurAnte", type = T.INT64}--下注金额
    }
}

P.SVR_CAN_OTHER_CARD             = 0x6009    --服务器广播可以开始获取第三张牌
SERVER[P.SVR_CAN_OTHER_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT}       
    }
}

P.SVR_OTHER_OTHER_CARD           = 0x6010    --服务器广播其它用户操作获取第三张牌结果
SERVER[P.SVR_OTHER_OTHER_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "type", type = T.INT} --是否需要第三张牌，0--不需要，1--需要 
    }
}

P.SVR_SHOW_CARD                  = 0x6011    --服务器广播用户亮牌
SERVER[P.SVR_SHOW_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {  
            name = "cards", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {type = T.BYTE},   --扑克牌数值          
            }
        }        
    }
}

P.SVR_CARD_NUM                   = 0x6012  --服务器广播发牌开始
SERVER[P.SVR_CARD_NUM] =  {
    ver = 1,
    fmt = {
        {name = "totalAnte", type = T.INT64} --桌子上的总筹码数量
    }
}

P.SVR_ROOM_BROADCAST            = 0x6013       --房间内广播
SERVER[P.SVR_ROOM_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "uid", type = T.INT},
        {name = "info", type = T.STRING}
    } 
}

P.SVR_COMMON_BROADCAST          = 0x402         --服务器单播，充值成功,系统消息等
SERVER[P.SVR_COMMON_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "mtype", type = T.SHORT},
        {name = "info", type = T.STRING}
    } 
}


P.SVR_GET_PERSONAL_ROOM_LIST = 0x0117         -- 服务器回应私人房列表
SERVER[P.SVR_GET_PERSONAL_ROOM_LIST] = {
    ver = 1,
    fmt = {
        {name = "total_pages", type = T.SHORT},
        {name = "cur_pages", type = T.SHORT},
        {  
            name = "roomlist", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "roomID",type = T.SHORT}, 
                {name = "tableID",type = T.INT},
                {name = "ownerUID",type = T.INT},
                {name = "roomName",type = T.STRING},
                {name = "baseChip",type = T.INT},
                {name = "fee",type = T.INT},
                {name = "minAnte",type = T.INT64},   
                {name = "maxAnte",type = T.INT64}, 
                {name = "userCount",type = T.SHORT}, 
                {name = "hasPwd",type = T.BYTE},   
                {name = "createTm",type = T.INT},        
            }
        }   
    } 
}

P.SVR_CREATE_PERSONAL_ROOM              = 0x0118 -- 服务器回应创建私人房间
SERVER[P.SVR_CREATE_PERSONAL_ROOM] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},
        {name = "roomID", type = T.SHORT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "tableID", type = T.INT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "ownerUID", type = T.INT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "roomName", type = T.STRING,depends=function(ctx) return ctx.ret == 0 end},
        {name = "baseChip", type = T.INT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "fee", type = T.INT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "minAnte", type = T.INT64,depends=function(ctx) return ctx.ret == 0 end},
        {name = "maxAnte", type = T.INT64,depends=function(ctx) return ctx.ret == 0 end},
        {name = "userCount", type = T.SHORT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "createTm", type = T.INT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "hasPwd", type = T.BYTE,depends=function(ctx) return ctx.ret == 0 end},
        {name = "pwd",type = T.STRING,depends = function(ctx) return (ctx.ret == 0 and ctx.hasPwd == 1) end} -- 房间密码
    } 
}


P.SVR_SEARCH_PERSONAL_ROOM              = 0x0119 -- 服务器回应搜索私人房
SERVER[P.SVR_SEARCH_PERSONAL_ROOM] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.BYTE},
        {name = "roomID", type = T.SHORT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "tableID", type = T.INT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "ownerUID", type = T.INT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "roomName", type = T.STRING,depends=function(ctx) return ctx.ret == 0 end},
        {name = "baseChip", type = T.INT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "fee", type = T.INT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "minAnte", type = T.INT64,depends=function(ctx) return ctx.ret == 0 end},
        {name = "maxAnte", type = T.INT64,depends=function(ctx) return ctx.ret == 0 end},
        {name = "userCount", type = T.SHORT,depends=function(ctx) return ctx.ret == 0 end},
        {name = "hasPwd", type = T.BYTE,depends=function(ctx) return ctx.ret == 0 end},
        {name = "createTm", type = T.INT,depends=function(ctx) return ctx.ret == 0 end}
    } 
}


P.SVR_LOGIN_PERSONAL_ROOM        = 0x0120    -- 服务器回应登录房间
SERVER[P.SVR_LOGIN_PERSONAL_ROOM] = {
    ver = 1,
    fmt = {
        {name = "ret", type = T.SHORT},
        {name = "tid", type = T.INT},
        {name = "ip", type = T.STRING},
        {name = "port", type = T.INT},
    } 
}

P.SVR_SUONA_BROADCAST = 0x0403  -- 服务器广播小喇叭
SERVER[P.SVR_SUONA_BROADCAST] = {
    ver = 1,
    fmt = {
        {name = "msg_info", type = T.STRING}
    }
}

P.SVR_OFF_LINE_RESULT = 0x7009 --服务器通知玩家离线时输赢情况
SERVER[P.SVR_OFF_LINE_RESULT] = {  -- 服务器通知玩家离线时输赢情况
    ver = 1,
    fmt = {
        {name = "iscash", type = T.INT},
        {name = "totalMoney", type = T.INT64}
    }
}
------------------------比赛场-----------------------------
P.SVR_CHECK_JION_MATCH              = 0x0216      -- 服务端回应确认比赛报名信息
SERVER[P.SVR_CHECK_JION_MATCH] = {
    ver = 1,
    fmt = {
        {name = "matchid",type = T.INT}, --比赛场ID
        {name = "tid",type = T.INT} --桌子ID
    }
}
P.SVR_JOIN_MATCH_WAIT   = 0x0218    --(定时赛)服务器回复用户确认进场
SERVER[P.SVR_JOIN_MATCH_WAIT] = {
    ver = 1,
    fmt = {
        {name = "error",type = T.INT} --0 成功
    }
}
P.SVR_PUSH_MATCH_ROOM  = 0x0219     --(定时赛)服务器广播推送进场
SERVER[P.SVR_PUSH_MATCH_ROOM] = {
    ver = 1,
    fmt = {
        {name = "matchid",type = T.INT}, --比赛场ID
        {name = "tableid",type = T.INT}, --桌子ID
        {name = "leftTime",type = T.INT} --比赛倒计时
    }
}
P.SVR_PUSH_CHANGE_MATCH_ROOM = 0x7829 --(定时赛)服务器推送换桌
SERVER[P.SVR_PUSH_CHANGE_MATCH_ROOM] = {
    ver = 1,
    fmt = {
        {name = "tableId",type = T.INT},--桌子ID
        {name = "matchId",type = T.INT}, --比赛场ID
        {name = "speakerSeatId",type = T.INT}, -- 发言玩家座位ID
        {name = "tableStatus",type = T.BYTE},--桌子当前状态 0报名 1前注 2第二次下注 3第三张牌 4第三次下注 5亮牌延时等待结束状态 6牌局结束
        {name = "matchType",type = T.BYTE},--比赛类型1、免费赛，2、热身赛，3、初级赛，4、xx活动赛
        {name = "userAnteTime",type = T.BYTE},--下注等待时间
        {name = "extraCardTime",type = T.BYTE},--询问发第三张牌等待时间
        {name = "maxSeatCnt",type = T.BYTE},--总的座位数量
        {name = "baseAnte",type = T.INT},--前注(随着时间变化而变化)
        {name = "nextAddBaseTm",type = T.INT},--多少秒以后要升级前注
        -- {name = "maxBetPoints",type = T.INT},-- 桌上最大下注额(每个人拿自己最大下注与这个值对比,就知道还需跟注多少)
        -- {name = "activeSeatId",type = T.INT},--哪个位置正在下注或拿牌
        -- {
        --     name = "potList", type = T.ARRAY, --奖池数组
        --     lengthType = T.INT,
        --     fmt = {
        --         {name = "potIdx",type = T.INT},
        --         {name = "potChips",type = T.INT},
        --     }
        -- },
        {
            name = "playerList",type = T.ARRAY,  --当前坐下玩家数组
            lengthType = T.INT,
            fmt = 
            {
                {name = "uid",type = T.INT},--用户ID
                {name = "seatId",type = T.INT},--用户座位ID
                {name = "userInfo",type = T.STRING},--用户信息
                {name = "seatChips",type = T.INT}--剩余积分
                -- {name = "totalBet",type = T.INT},--总下注额
                -- {name = "curBet",type = T.INT},      --当前下注额
                -- {name = "betState",type = T.INT},-- 下注类型 (1看牌 2跟注 3加注 4弃牌 5all in)
                -- {
                --     name = "cards",type = T.ARRAY,
                --     lengthType = T.INT,
                --     fmt = 
                --     {
                --         {type = T.BYTE}
                --     }

                -- }
            }

        },
       -- {name = "isAI", type = T.INT}
    }
}
P.SVR_WAIT_MATCH_GAME = 0x7830          --(定时赛) 服务器广播该桌进入暂停，等待合桌
SERVER[P.SVR_WAIT_MATCH_GAME] = nil

P.SVR_TIME_MATCH_OFF = 0x0220           --(定时赛)服务器临时关闭比赛,人数不够被迫关闭
SERVER[P.SVR_TIME_MATCH_OFF] = {
    ver = 1,
    fmt = {
        {name = "matchid",type = T.INT} --比赛场ID
    }
}

P.SVR_LOGIN_MATCH_ROOM_OK                 = 0x7052    --服务器回应登录比赛场
SERVER[P.SVR_LOGIN_MATCH_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tableId",type = T.INT},--桌子ID
        {name = "matchId",type = T.INT}, --比赛场ID
        {name = "speakerSeatId",type = T.INT}, -- 发言玩家座位ID
        {name = "tableStatus",type = T.BYTE},--桌子当前状态 0报名 1前注 2第二次下注 3第三张牌 4第三次下注 5亮牌延时等待结束状态 6牌局结束
        {name = "matchType",type = T.BYTE},--比赛类型1、免费赛，2、热身赛，3、初级赛，4、xx活动赛
        {name = "userAnteTime",type = T.BYTE},--下注等待时间
        {name = "extraCardTime",type = T.BYTE},--询问发第三张牌等待时间
        {name = "maxSeatCnt",type = T.BYTE},--总的座位数量
        {name = "baseAnte",type = T.INT},--前注(随着时间变化而变化)
        {name = "nextAddBaseTm",type = T.INT},--多少秒以后要升级前注
        {name = "maxBetPoints",type = T.INT},-- 桌上最大下注额(每个人拿自己最大下注与这个值对比,就知道还需跟注多少)
        {name = "activeSeatId",type = T.INT},--哪个位置正在下注或拿牌
        {
            name = "potList", type = T.ARRAY, --奖池数组
            lengthType = T.INT,
            fmt = {
                {name = "potIdx",type = T.INT},
                {name = "potChips",type = T.INT},
            }
        },
        {
            name = "playerList",type = T.ARRAY,  --当前坐下玩家数组
            lengthType = T.INT,
            fmt = 
            {
                {name = "uid",type = T.INT},--用户ID
                {name = "seatId",type = T.INT},--用户座位ID
                {name = "userInfo",type = T.STRING},--用户信息
                {name = "seatChips",type = T.INT},--剩余积分
                {name = "totalBet",type = T.INT},--总下注额
                {name = "curBet",type = T.INT},      --当前下注额
                {name = "betState",type = T.INT},-- 下注类型 (1看牌 2跟注 3加注 4弃牌 5all in)
                {
                    name = "cards",type = T.ARRAY,
                    lengthType = T.INT,
                    fmt = 
                    {
                        {type = T.BYTE}
                    }

                }
            }

        },
        {name = "isAI", type = T.INT}
    }
}

P.SVR_LOGIN_MATCH_ROOM_FAIL                 = 0x7059    --服务器回应登录比赛场失败
SERVER[P.SVR_LOGIN_MATCH_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errno",type = T.INT},


    }
}


P.SVR_MATCH_SET_BET                           = 0x7054  -- 服务器回应下注结果
SERVER[P.SVR_MATCH_SET_BET] = {
    ver = 1,
    fmt = {
        {name = "errno",type = T.INT}, -- (1下注参数错误 2非下注状态 3不可看牌 4下注额不够) 
    }
}

P.SVR_MATCH_QUIT                              = 0x7056   -- 服务器回应退出比赛
SERVER[P.SVR_MATCH_QUIT] = {
    ver = 1,
    fmt = {
        {name = "errno",type = T.INT},
    }
}

P.SVR_MATCH_THIRD_CARD                 = 0x7058    --服务器返回第三张牌
SERVER[P.SVR_MATCH_THIRD_CARD] = {
    ver = 1,
    fmt = {      
        {name = "card", type = T.BYTE}
    }
}


P.SVR_MATCH_DEAL                       = 0x7091    --发牌,通知玩家手牌
SERVER[P.SVR_MATCH_DEAL] = {
    ver = 1,
    fmt = {
        {  
            name = "cards", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {type = T.BYTE},   --扑克牌数值          
            }
        }
    }
}


P.SVR_MATCH_SEAT_DOWN            = 0x7801    --服务器广播用户坐下
SERVER[P.SVR_MATCH_SEAT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},--座位ID
        {name = "uid", type = T.INT},--用户ID
        {name = "seatChips", type = T.INT}, -- 比赛积分
        {name = "userInfo", type = T.STRING}, --用户个人信息       
    }
}



P.SVR_MATCH_GAME_START                 = 0x7802    --服务器广播游戏开始
SERVER[P.SVR_MATCH_GAME_START] = {
    ver = 1,
    fmt = {
            {name = "speakerSeatId",type = T.INT}, -- 发言玩家座位ID
            {name = "baseAnte",type = T.INT} -- 当前底注
    }

}

P.SVR_MATCH_PRE_CALL                 = 0x7803    --服务器广播下前注
SERVER[P.SVR_MATCH_PRE_CALL] = {
    ver = 1,
    fmt = {
        {  
            name = "preCallArr", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "uid",type = T.INT},   --用户ID  
                {name = "seatId",type = T.INT},   --用户桌位ID   
                {name = "nCurAnte",type = T.INT},   --自动扣的前注   
                {name = "seatChips",type = T.INT},   --剩余积分          
            }
        }
    }
}



P.SVR_MATCH_CARD_NUM                   = 0x7804  --服务器广播发牌开始
SERVER[P.SVR_MATCH_CARD_NUM] =  {
    ver = 1,
    fmt = {
            {
                name = "cardlist",type = T.ARRAY,
                lengthType = T.INT,
                fmt = {
                    {name = "seatId",type = T.INT},
                    {name = "card",type = T.BYTE},
                }
            }
    }
}


P.SVR_MATCH_TURN_BET                   = 0x7805  -- 服务器广播轮到谁下注
SERVER[P.SVR_MATCH_TURN_BET] = {
    ver = 1,
    fmt = {
        {name = "tableStatus",type = T.BYTE},--桌子当前状态 0报名 1前注 2第二次下注 3第三张牌 4第三次下注 5亮牌延时等待结束状态 6牌局结束
        {name = "seatId",type = T.INT},
        {name = "callChips",type = T.INT}
    }
}

P.SVR_MATCH_BET                   = 0x7806    --服务器广播玩家下注
SERVER[P.SVR_MATCH_BET] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "betState",type = T.INT},-- (1看牌 2跟注 3加注 4弃牌 5all in)
        {name = "betPoint", type = T.INT},--下注额
        {name = "seatChips",type = T.INT},--剩余积分
        {name = "totalBet",type = T.INT},--该玩家总下注额
        {name = "maxBetPoints",type = T.INT} --桌上最大下注额(每个人拿自己最大下注与这个值对比,就知道还需跟注多少)
    }
}


P.SVR_MATCH_CAN_THIRD_CARD             = 0x7807    --服务器广播到谁考虑拿第三张牌
SERVER[P.SVR_MATCH_CAN_THIRD_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT}       
    }
}

P.SVR_MATCH_OTHER_THIRD_CARD           = 0x7808    --服务器广播其它用户操作获取第三张牌结果
SERVER[P.SVR_MATCH_OTHER_THIRD_CARD] = {
    ver = 1,
    fmt = {
        {name = "seatId", type = T.INT},
        {name = "type", type = T.INT}, --是否需要第三张牌，0--不需要，1--需要 
        {name = "card",type = T.BYTE,depends=function(ctx) return ctx.type == 1 end}
    }
}

P.SVR_MATCH_SHOW_CARD                   = 0x7809    -- 广播所有玩家亮牌并结束
SERVER[P.SVR_MATCH_SHOW_CARD] = {
    ver = 1,
    fmt = {
        {
            name = "playerList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = 
            {
                {name = "uid",type = T.INT},
                {name = "seatId",type = T.INT},
                {name = "turnPoints",type = T.INT},
                {name = "seatChips",type = T.INT},
                {
                    name = "cards",type = T.ARRAY,
                    lengthType = T.INT,
                    fmt = 
                    {
                        {type = T.BYTE}
                    }
                }
            }

        },
        {
            name = "potsList",type = T.ARRAY,
            lengthType = T.INT,
            fmt = 
            {
                {name = "potIdx",type = T.INT},--奖池编号
                {name = "points",type = T.INT},--奖池中当前的总积分
                {
                    name = "playerList",type = T.ARRAY,
                    lengthType = T.INT,
                    fmt = 
                    {
                        {name="uid",type = T.INT},
                        {name="seatId",type = T.INT},
                        {name="winPoints",type = T.INT},--该用户在这个奖池赢的积分
                    }
                }
            }

            
            
        }
       
    }
}


P.SVR_MATCH_BROAD_QUIT                          = 0x7810  -- 广播玩家退赛
SERVER[P.SVR_MATCH_BROAD_QUIT ] = {
    ver = 1,
    fmt = {
        {name = "seatId",type = T.INT}
    }
}



P.SVR_MATCH_POT                           = 0x7811  -- 每一轮下注完后收奖池广播
SERVER[P.SVR_MATCH_POT ] = {
    ver = 1,
    fmt = {
        {
            name = "potList",type = T.ARRAY,
            lengthType = T.INT,
            fmt = 
            {
                {name = "potIdx",type = T.INT},  --奖池编号
                {name = "potChips",type = T.INT},  -- 奖池中当前的总积分
            }
        }
    }
}


P.SVR_MATCH_KNOCK_OUT                           = 0x7812  -- 广播玩家淘汰
SERVER[P.SVR_MATCH_KNOCK_OUT] = {
    ver = 1,
    fmt = {
        {name = "seatId",type = T.INT},
        {name = "rank",type = T.INT}
    }
}


P.SVR_MATCH_GAME_OVER                           = 0x7813   -- 广播比赛结束
SERVER[P.SVR_MATCH_GAME_OVER] = {
    ver = 1,
    fmt = {
        {
            name = "ranklist",type = T.ARRAY,
            lengthType = T.INT,
            fmt = 
            {
                {name = "uid",type = T.INT},
                {name = "rank",type = T.INT} --名次
            }
        }
    }
}

P.SVR_MATCH_BROAD_RANK                          = 0x7814    --服务器广播比赛排行
SERVER[P.SVR_MATCH_BROAD_RANK]  = {
    ver = 1,
    fmt = {
            {name = "curBaseChip",type = T.INT},
            {name = "nextAddBaseTime",type = T.INT},
            {name = "nextBaseChip",type = T.INT},
            {
                name = "rankList",type = T.ARRAY,
                lengthType = T.INT,
                fmt = 
                {
                    {name = "rank",type = T.INT}, --名次
                    {name = "uid",type = T.INT},
                    {name = "leftPoints", type = T.INT},
                    {name = "userinfo",type = T.STRING}
                }
            }

    }
}
P.SVR_TIME_MATCH_RANK                       = 0x7831   --(定时赛)服务器广播比赛排行
SERVER[P.SVR_TIME_MATCH_RANK]  = {
    ver = 1,
    fmt = {
            {name = "curBaseChip",type = T.INT},
            {name = "nextAddBaseTime",type = T.INT},
            {name = "nextBaseChip",type = T.INT},
            {name = "myRank",type = T.INT},
            {name = "leftPlayerNum",type = T.INT},
            {name = "firstPoints",type = T.INT},
            {name = "avaragePoints",type = T.INT}
    }
}

P.SVR_MATCH_COUNT_DOWN                           = 0x7815     -- 比赛开始前广播倒计时
SERVER[P.SVR_MATCH_COUNT_DOWN] = {
    ver = 1,
    fmt = {
        {name = "countDown",type = T.INT}
    }
}

P.SVR_MATCH_AI                      = 0x7816   --用户托管
SERVER[P.SVR_MATCH_AI] = nil



P.SVR_MATCH_CACEL_AI_RESULT               = 0x7818   --用户取消托管回复
SERVER[P.SVR_MATCH_CACEL_AI_RESULT] = {
    ver = 1,
    fmt = {
        {name = "errno",type = T.INT}
    }
}
P.SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME = 0x7826         --  玩家获取自己玩多局可以强制退赛回复
SERVER[P.SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME] = {
    ver = 1,
    fmt = {
        {name = "leftNum",type = T.INT}
    }
}

P.SVR_MATCH_FORCE_EXIT_GAME_RESULT               = 0x7828   --玩家强制退赛回复
SERVER[P.SVR_MATCH_FORCE_EXIT_GAME_RESULT] = {
    ver = 1,
    fmt = {
        {name = "errno",type = T.INT}
    }
}
------------------------比赛场-----------------------------

------------------------上庄玩法---------------------------
P.SVR_GRAB_ROOM_LIST_RESULT                 = 0x0126       --服务器返回抢庄房间列表
SERVER[P.SVR_GRAB_ROOM_LIST_RESULT] = {
    ver = 1,
    fmt = {
        {name = "total_pages", type = T.SHORT},--总页数
        {name = "cur_pages", type = T.SHORT},--当前页数
        {  
            name = "roomlist", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "bankId",type = T.INT},--庄家ID
                {name = "userinfo",type = T.STRING},--庄家信息
                {name = "ante",type = T.INT64},--庄家携带
                {name = "basechip",type = T.INT64},--当前底注
                {name = "door",type = T.INT64},--上庄门槛
                {name = "minante",type = T.INT64},--最小携带
                {name = "tableId",type = T.INT},--桌子id
                {name = "userCount",type = T.INT},--坐下人数
                {name = "seatcout",type = T.INT},--座位数量
                {name = "level",type = T.INT}, -- 场次等级
                {name = "rmType",type = T.INT} -- 场次类型 现金币场/筹码场

            }
        }

    }
}
P.SVR_GET_GRAB_DEALER_ROOM_OK                = 0x0211    --获取抢庄房间id结果
SERVER[P.SVR_GET_GRAB_DEALER_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT}, --桌子ID
        {name = "ip", type = T.STRING}, --忽略
        {name = "port", type = T.INT}
    }
}
P.SVR_GET_DEALER_ROOM_OK                = 0x0212    --获取房间id结果(新玩法)
SERVER[P.SVR_GET_DEALER_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tid", type = T.INT}, --桌子ID
        {name = "ip", type = T.STRING}, --忽略
        {name = "port", type = T.INT}
    }
}
P.SVR_LOGIN_GRAB_ROOM_OK              = 0x1075    --登录上庄场房间OK
SERVER[P.SVR_LOGIN_GRAB_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tableId", type = T.INT},--桌子ID
        {name = "tableLevel", type = T.INT},   --桌子level     
        {name = "tableStatus", type = T.BYTE}, --桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌
        {name = "dealerSeatId", type = T.INT},--庄家座位Id
        {name = "curDealSeatId", type = T.INT},--如果为发第三张牌时，为当前询问发牌的座位
        {name = "baseAnte", type = T.INT64},--底注
        {name = "totalAnte", type = T.INT64},--桌子上的总筹码数量
        {name = "userAnteTime", type = T.BYTE}, -- 下注等待时间
        {name = "extraCardTime", type = T.BYTE}, -- 询问发第三张牌等待时间
        {name = "maxSeatCnt", type = T.BYTE}, -- 总的座位数量
        {name = "minAnte", type = T.INT64},--最小携带
        {name = "maxAnte", type = T.INT64},--最大携带
        {name = "defaultAnte", type = T.INT64},--默认携带
        {name = "highBet",type = T.INT64},--最高下注额
        {name = "rmType",type = T.INT},--房间类型，筹码场还是上庄场
        {  
            name = "playerList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "uid", type = T.INT},--用户ID
                {name = "seatId", type = T.INT},--用户座位ID
                --{
                --"msex":"0",
                --"money":50000,
                --"mavatar":"",
                --"name":"deviceModel",
                --"sitemid":"C4:6A:B7:61:7E:F8",
                --"mlevel":1
                --}
                {name = "userInfo", type = T.STRING},--用户信息
                {name = "anteMoney", type = T.INT64},--用户携带
                {name = "nCurAnte", type = T.INT64},--当次下注
                {name = "nWinTimes", type = T.INT},--玩家的赢次数
                {name = "nLoseTimes", type = T.INT},--玩家的输次数
                {name = "isOnline", type = T.BYTE}, --（其他用户连接状态） 0--用户掉线   1--用户在线
                {name = "isPlay", type = T.BYTE},  -- 是否在玩牌
                {name = "isOutCard", type = T.INT}, -- 1 亮牌  0 不亮牌
                {name = "cardsCount", type = T.INT}, --用户手牌数量
                {name = "card1", type = T.BYTE, depends=function(ctx, row) return row.isOutCard == 1 end},--扑克牌数值, 无为0
                {name = "card2", type = T.BYTE, depends=function(ctx, row) return row.isOutCard == 1 end},
                {name = "card3", type = T.BYTE, depends=function(ctx, row) return row.isOutCard == 1 end}               
            }
        },
        {name = "grabDealerLeftTime", type = T.INT},--上庄倒计时
        {name = "grabDoor",type = T.INT64}  --上庄门槛
    }
}

P.SVR_LOGIN_GRAB_DELAER_ROOM_FAIL            = 0x1053    --登录上庄房间失败
SERVER[P.SVR_LOGIN_GRAB_DELAER_ROOM_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errno", type = T.INT}
    }
}

P.SVR_GRAB_ROOM_GAME_START                 = 0x1076    --服务器广播上庄房间游戏开始
SERVER[P.SVR_GRAB_ROOM_GAME_START] = {
    ver = 1,
    fmt = {
        {name = "dealerSeatId", type = T.INT}, --庄家座位Id
        {  
            name = "anteMoneyList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "seatId", type = T.INT},  --座位ID
                {name = "anteMoney", type = T.INT64}, --用户携带
                {name = "money",type = T.INT64} -- 玩家金币(现金币)总额
            }
        },
        {name = "firstSeatId", type = T.INT}        --首先发牌的座位id
    }
}

P.SVR_REQUEST_GRAB_DEALER_RESULT                = 0x1056        --上庄回复
SERVER[P.SVR_REQUEST_GRAB_DEALER_RESULT] = {
    ver = 1,
    fmt = {
        {name = "errno",type = T.INT}                   --0：成功，302筹码不足
    }
}

P.SVR_BROADCAST_CAN_GRAB_DEALER =                0x1065  --广播用户可以进行抢庄（显示抢庄按钮）
SERVER[P.SVR_BROADCAST_CAN_GRAB_DEALER] = {
    ver = 1,
    fmt = {
        {name = "errno",type = T.INT}                   --0:开启抢庄，1:关闭抢庄
    }
}

P.SVR_BROADCAST_RE_GRAB_DEALER_USER             = 0x1057        --广播抢庄倒计时
SERVER[P.SVR_BROADCAST_RE_GRAB_DEALER_USER] = {  
    ver = 1,
    fmt = {
        {name = "lefttime",type = T.INT}                   
    }
}


P.SVR_BROADCAST_GRAB_PLAYER                     = 0x1064    ---服务器广播抢庄玩家
SERVER[P.SVR_BROADCAST_GRAB_PLAYER ]    = {
    ver = 1,
    fmt = {
        {name = "id",type = T.INT},
        {name = "handCoin",type = T.INT64},
        {name = "leftTurn",type = T.INT}, --剩余游戏轮次
        {name = "userName",type = T.STRING}                          
    }
}         

P.SVR_WARRING_DEALER_ADD_COIN                   = 0x1058        --server通知庄家补币
SERVER[P.SVR_WARRING_DEALER_ADD_COIN] = {
    ver = 1,
    fmt = {
        {name = "addCoin",type = T.INT64}                   --补币金额
    }
}
P.SVR_PLAYER_ADD_COIN_RESULT                = 0x1060        --庄家补币回复(成功则广播)
SERVER[P.SVR_PLAYER_ADD_COIN_RESULT] = {
    ver = 1,
    fmt = {
        {name = "errno",type = T.INT} ,                  --0 成功
        {name = "dealerHandCoin",type = T.INT64,depends=function(ctx) return ctx.errno == 0 end}                   --庄家当前携带
    }
}
P.SVR_EXIT_DELAER_FAIL                = 0x1061        --庄家退出失败
SERVER[P.SVR_EXIT_DELAER_FAIL] = {
    ver = 1,
    fmt = {
        {name = "errno",type = T.INT}                   --错误码
    }
}
P.SVR_DEALER_SITDOWN_FAIL =             0x1070          --请求成功的上庄玩家坐下失败
SERVER[P.SVR_DEALER_SITDOWN_FAIL] = nil

P.SVR_BROAD_DEALER_STAND = 0x7008       --server通知庄家即将站起
SERVER[P.SVR_BROAD_DEALER_STAND] = nil
------------------------上庄玩法---------------------------


P.SVR_LOGIN_NEW_ROOM_OK              = 0x1078    --登录新玩法房间OK
SERVER[P.SVR_LOGIN_NEW_ROOM_OK] = {
    ver = 1,
    fmt = {
        {name = "tableId", type = T.INT},--桌子ID
        {name = "tableLevel", type = T.INT},   --桌子level     
        {name = "tableStatus", type = T.BYTE}, --桌子当前状态 0牌局已结束 1下注中 2等待用户获取第3张牌
        {name = "dealerSeatId", type = T.INT},--庄家座位Id
        {name = "curDealSeatId", type = T.INT},--如果为发第三张牌时，为当前询问发牌的座位
        {name = "baseAnte", type = T.INT64},--底注
        {name = "totalAnte", type = T.INT64},--桌子上的总筹码数量
        {name = "userAnteTime", type = T.BYTE}, -- 下注等待时间
        {name = "extraCardTime", type = T.BYTE}, -- 询问发第三张牌等待时间
        {name = "maxSeatCnt", type = T.BYTE}, -- 总的座位数量
        {name = "minAnte", type = T.INT64},--最小携带
        {name = "maxAnte", type = T.INT64},--最大携带
        {name = "defaultAnte", type = T.INT64},--默认携带
        {name = "highBet",type = T.INT64},--最高下注额
        {name = "miniBet",type = T.INT64},--最小all in值
        {name = "enterLimit",type =T.INT64},--入场门槛
        {  
            name = "playerList", type = T.ARRAY,
            lengthType = T.INT,
            fmt = {
                {name = "uid", type = T.INT},--用户ID
                {name = "seatId", type = T.INT},--用户座位ID
                --{
                --"msex":"0",
                --"money":50000,
                --"mavatar":"",
                --"name":"deviceModel",
                --"sitemid":"C4:6A:B7:61:7E:F8",
                --"mlevel":1
                --}
                {name = "userInfo", type = T.STRING},--用户信息
                {name = "anteMoney", type = T.INT64},--用户携带
                {name = "nCurAnte", type = T.INT64},--当次下注
                {name = "nWinTimes", type = T.INT},--玩家的赢次数
                {name = "nLoseTimes", type = T.INT},--玩家的输次数
                {name = "isOnline", type = T.BYTE}, --（其他用户连接状态） 0--用户掉线   1--用户在线
                {name = "isPlay", type = T.BYTE},  -- 是否在玩牌
                {name = "isOutCard", type = T.INT}, -- 1 亮牌  0 不亮牌
                {name = "cardsCount", type = T.INT}, --用户手牌数量
                {name = "card1", type = T.BYTE, depends=function(ctx, row) return row.isOutCard == 1 end},--扑克牌数值, 无为0
                {name = "card2", type = T.BYTE, depends=function(ctx, row) return row.isOutCard == 1 end},
                {name = "card3", type = T.BYTE, depends=function(ctx, row) return row.isOutCard == 1 end}               
            }
        },
        {name = "grabDealerLeftTime", type = T.INT},--上庄倒计时
        {name = "grabDoor",type = T.INT64},  --上庄门槛
        {name = "betPro",type = T.INT}    --下注比例(新需求:玩家在取ALL IN值时候优先考虑下注比例)
    }
}
--心跳
P.CLISVR_HEART_BEAT              = 0x0110    --server心跳包

return HALL_SERVER_PROTOCOL