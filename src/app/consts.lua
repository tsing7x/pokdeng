--
-- Author: johnny@boomegg.com
-- Date: 2014-07-16 17:00:08
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

consts = consts or {}


--hall server错误定义
consts.SVR_ERROR = {}
local codes = consts.SVR_ERROR
codes.ERROR_CONNECT_FAILURE = 100 --连接失败
codes.ERROR_HEART_TIME_OUT  = 101 --心跳包超时
codes.ERROR_LOGIN_TIME_OUT  = 102 --登录超时

-- 登录失败原因代码
consts.SVR_LOGIN_FAIL_CODE = {}
codes = consts.SVR_LOGIN_FAIL_CODE
codes.INVALID_MTKEY        = 0x9001 --错误的mtkey
codes.USER_BANNED          = 0x9002 --用户被禁
codes.ROOM_ERR             = 0x9003 --登录桌子错误
codes.ROOM_FULL            = 0x9004 --房间旁观人数到达上限
codes.RECONN_TO_OTHER_ROOM = 0x9005 --重连进入不同的桌子
codes.SOMEONE_ELSE_RELOGIN = 0x9006 --账号被其他人登陆了
codes.MIN_USER_LEVEL_LIMIT = 0x9007 --等级不够
codes.SERVER_STOPPED       = 0x9008 --停服标志
codes.KICKED               = 0x9009 --被踢出
codes.WRONG_PASSWORD       = 0x810A --密码错误
codes.ROOM_NOT_EXISTS      = 0x810B --房间不存在

-- 坐下失败原因代码
consts.SVR_SIT_DOWN_FAIL_CODE = {}
codes = consts.SVR_SIT_DOWN_FAIL_CODE
codes.SEAT_NUMBER_ERROR     = 1 --座位号错误
codes.SEAT_NOT_EMPTY        = 2 --座位上已经有人了
codes.CHIPS_LIMIT 			= 3 --携带筹码超出该场限制
codes.CHIPS_ERROR           = 4 --携带的筹码错误
codes.ON_THEN_SEAT_ERROR    = 5 --在座位上


-- 下注失败原因代码
consts.SVR_BET_FAIL_CODE = {}
codes = consts.SVR_BET_FAIL_CODE
codes.WRONG_STATE    = 0x9301 --游戏状态错误
codes.NOT_YOUR_TURN  = 0x9302 --还没轮到用户下注
codes.NOT_IN_GAME    = 0x9303 --用户没有参与本轮游戏
codes.CANNOT_CHECK   = 0x9304 --不能看牌，有人加注了
codes.WRONG_BET_TYPE = 0x9305 --错误的下注类型
codes.PRE_BET        = 0x9306 --提前下注（开始server强行每个用户下相同数额的筹码数）

--赠送筹码失败原因代码
consts.SVR_SEND_CHIPS_FAIL_CODE = {}
codes = consts.SVR_SEND_CHIPS_FAIL_CODE
codes.NOT_ENOUGH_CHIPS     = 0x9401 --钱数不够，不能赠送
codes.TOO_OFTEN         = 0x9402 --太频繁
codes.TOO_MANY             = 0x9403 --太多了

-- 操作类型
consts.SVR_BET_STATE = {}
local states = consts.SVR_BET_STATE
states.CHECK          = 1 --看牌
states.CALL           = 2 --跟注
states.RAISE          = 3 --加注
states.FOLD           = 4 --弃牌
states.ALL_IN         = 5 --all in
states.PRE_CALL       = 6 --前注
states.SMALL_BLIND    = 7 --小盲
states.BIG_BLIND      = 8 --大盲
states.WAITTING_START = 9 --等待开始
states.WAITTING_BET   = 0 --等待下注

consts.SVR_GAME_STATUS = {}
-- 0牌局已结束 1下注中 2等待用户获取第3张牌
states = consts.SVR_GAME_STATUS
states.BET_ROUND         = 1 --下注
states.GET_POKER 	     = 2 --等待用户获取第3张牌
states.WAIT_GAME_OVER    = 3 --等待结算
states.READY_TO_START    = 0 --本轮游戏结束，马上要开始

consts.SVR_MATCH_GAME_STATUS = {}
states = consts.SVR_MATCH_GAME_STATUS
states.APPLY = 0 --报名
states.PRE_CALL = 1 -- 前注
states.BET_ROUND_1 = 2 -- 第二次下注
states.GET_POKER = 3 -- 等待用户获取第3张牌
states.BET_ROUND_2 = 4 -- 第三次下注
states.WAIT_GAME_OVER = 5 -- 等待游戏结束
states.READY_TO_START = 6 --游戏结束，即将开始下一轮


-- 房间打牌操作类型
consts.CLI_BET_TYPE = {}
local types = consts.CLI_BET_TYPE
types.CHECK = 1
types.CALL  = 2
types.RAISE  = 3
types.FOLD  = 4

-- 房间类型
consts.ROOM_TYPE = {}
types = consts.ROOM_TYPE
types.NORMAL     = 1 -- 普通场
types.PRO        = 2 -- 专业场
types.TOURNAMENT = 3 -- 锦标赛
types.KNOCKOUT   = 4 -- 淘汰赛
types.PROMOTION  = 5 -- 晋级赛
types.MATCH      =  6 -- 比赛场 
types.GRAB       =  7 --上庄场
types.NORMAL_GRAB = 8 --普通抢庄场
types.PERSONAL_NORMAL = 31 --私人房普通场

types.GRAB_GAME_LEVEL = 301 -- 


consts.ROOM_GAME_LEVEL = {}
types = consts.ROOM_GAME_LEVEL
types.PERSONAL_NORMAL_LEVEL = 31 --私人房等级
types.GRAB_ROOM_LEVEL = 301 -- 上庄场等级（普通游戏币场）
types.GRAB_CASH_ROOM_LEVEL = 302 -- 上庄场现金币场


consts.ROOM_TYPE_EX = {}
types = consts.ROOM_TYPE_EX
types.GRAB_CASH = 0   --上庄筹码场
types.GRAB_CHIP = 1   --上庄现金币场


consts.CARD_TYPE = {}
types = consts.CARD_TYPE
types.POINT_CARD       = 1 --点牌
types.STRAIGHT         = 2 --顺子
types.STRAIGHT_FLUSH   = 3 --同花顺
types.THREE_YELLOW     = 4 --三黄
types.THREE_KIND       = 5 --三张
types.POKDENG          = 6 --博定

return consts