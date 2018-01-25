--
-- Author: tony
-- Date: 2014-07-15 19:05:10
--
local EVENT_NAMES = {}
local E = EVENT_NAMES

E.APP_ENTER_BACKGROUND = "APP_ENTER_BACKGROUND"
E.APP_ENTER_FOREGROUND = "APP_ENTER_FOREGROUND"

E.HALL_LOGIN_SUCC = "HALL_LOGIN_SUCC"
E.HALL_LOGOUT_SUCC = "HALL_LOGOUT_SUCC"
E.HALL_SHOW_MAIN_HALL = "HALL_SHOW_MAIN_HALL"
E.HALL_SHOW_CHOOSE_ROOM = "HALL_SHOW_CHOOSE_ROOM"
E.ENTER_ROOM_WITH_DATA = "ENTER_ROOM_WITH_DATA"
E.ENTER_MATCH_WITH_DATA = "ENTER_MATCH_WITH_DATA"
E.LOGIN_ROOM_SUCC = "LOGIN_ROOM_SUCC"
E.LOGIN_ROOM_FAIL = "LOGIN_ROOM_FAIL"
E.ROOM_CONN_PROBLEM = "ROOM_CONN_PROBLEM"
E.SERVER_STOPPED = "SERVER_STOPPED"
E.LOGOUT_ROOM_SUCC = "LOGOUT_ROOM_SUCC"

E.SVR_CHECK_JION_MATCH = "SVR_CHECK_JION_MATCH"
E.SVR_LOGIN_MATCH_ROOM_OK = "SVR_LOGIN_MATCH_ROOM_OK"
E.SVR_MATCH_BROAD_RANK		= "SVR_MATCH_BROAD_RANK"
E.SVR_LOGIN_MATCH_ROOM_FAIL = "SVR_LOGIN_MATCH_ROOM_FAIL"
E.SVR_MATCH_SET_BET = "SVR_MATCH_SET_BET"
E.SVR_MATCH_QUIT = "SVR_MATCH_QUIT"
E.SVR_MATCH_THIRD_CARD = "SVR_MATCH_THIRD_CARD"
E.SVR_MATCH_DEAL = "SVR_MATCH_DEAL"
E.SVR_MATCH_SEAT_DOWN = "SVR_MATCH_SEAT_DOWN"
E.SVR_MATCH_GAME_START = "SVR_MATCH_GAME_START"
E.SVR_MATCH_PRE_CALL = "SVR_MATCH_PRE_CALL"
E.SVR_MATCH_CARD_NUM = "SVR_MATCH_CARD_NUM"
E.SVR_MATCH_TURN_BET = "SVR_MATCH_TURN_BET" 
E.SVR_MATCH_BET = "SVR_MATCH_BET"
E.SVR_MATCH_CAN_THIRD_CARD = "SVR_MATCH_CAN_THIRD_CARD"
E.SVR_MATCH_OTHER_THIRD_CARD = "SVR_MATCH_OTHER_THIRD_CARD"
E.SVR_MATCH_SHOW_CARD = "SVR_MATCH_SHOW_CARD"
E.SVR_MATCH_BROAD_QUIT = "SVR_MATCH_BROAD_QUIT"
E.SVR_MATCH_POT = "SVR_MATCH_POT"
E.SVR_MATCH_KNOCK_OUT = "SVR_MATCH_KNOCK_OUT"
E.SVR_MATCH_GAME_OVER = "SVR_MATCH_GAME_OVER"
E.SVR_MATCH_COUNT_DOWN = "SVR_MATCH_COUNT_DOWN"
E.SVR_MATCH_AI = "SVR_MATCH_AI"
E.SVR_MATCH_CACEL_AI_RESULT = "SVR_MATCH_CACEL_AI_RESULT"
E.SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME = "SVR_MATCH_LEFT_NUM_FORCE_EXIT_GAME"
E.SVR_MATCH_FORCE_EXIT_GAME_RESULT = "SVR_MATCH_FORCE_EXIT_GAME_RESULT"


E.UI_TAB_CHANGE = "UI_TAB_CHANGE"

E.ROOM_LOAD_HDDJ_NUM = "ROOM_LOAD_HDDJ_NUM"
E.ROOM_REFRESH_HDDJ_NUM = "ROOM_REFRESH_HDDJ_NUM"

E.SEND_DEALER_CHIP_BUBBLE_VIEW = "SEND_DEALER_CHIP_BUBBLE_VIEW"
E.SVR_BROADCAST_ACT_STATE = "SVR_BROADCAST_ACT_STATE" --活动完成
E.SVR_BROADCAST_ADD_EXP = "SVR_BROADCAST_ADD_EXP" --加经验动画

E.OPEN_BANK_POPUP_VIEW = "OPEN_BANK_POPUP_VIEW"
E.SHOW_EXIST_PASSWORD_ICON = "SHOW_EXIST_PASSWORD_ICON"

E.SLOT_BUY_RESULT = "SLOT_BUY_RESULT"
E.SLOT_PLAY_RESULT = "SLOT_PLAY_RESULT"

E.SVR_BROADCAST_BIG_LABA = "SVR_BROADCAST_BIG_LABA" --大喇叭消息

E.HIDE_GIFT_POPUP = "HIDE_GIFT_POPUP" --关闭礼物弹框
E.GET_CUR_SELECT_GIFT_ID = "GET_CUR_SELECT_GIFT_ID" --获取当前礼物ID

E.UPDATE_CUR_SELECT_GIFT_ID = "UPDATE_CUR_SELECT_GIFT_ID" --跟新礼物ID

E.DOUBLE_LOGIN_LOGINOUT = "DOUBLE_LOGIN_LOGINOUT" -- 账号同时登录时退出消息

-- HallServer
E.SVR_DOUBLE_LOGIN = "SVR_DOUBLE_LOGIN"
E.SVR_LOGIN_OK = "SVR_LOGIN_OK"
E.SVR_LOGIN_OK_NEW = "SVR_LOGIN_OK_NEW"
E.SVR_ONLINE = "SVR_ONLINE"
E.SVR_GET_ROOM_OK = "SVR_GET_ROOM_OK"
E.SVR_LOGIN_ROOM_OK = "SVR_LOGIN_ROOM_OK"
E.SVR_LOGIN_ROOM_FAIL = "SVR_LOGIN_ROOM_FAIL"
E.SVR_LOGOUT_ROOM_OK = "SVR_LOGOUT_ROOM_OK"
E.SVR_SEAT_DOWN = "SVR_SEAT_DOWN"
E.SVR_STAND_UP = "SVR_STAND_UP"
E.SVR_OTHER_CARD = "SVR_OTHER_CARD"
E.SVR_SET_BET = "SVR_SET_BET"
E.SVR_MSG = "SVR_MSG"
E.SVR_DEAL = "SVR_DEAL"
E.SVR_LOGIN_ROOM = "SVR_LOGIN_ROOM"
E.SVR_LOGOUT_ROOM = "SVR_LOGOUT_ROOM"
E.SVR_SELF_SEAT_DOWN_OK = "SVR_SELF_SEAT_DOWN_OK"
E.SVR_OTHER_STAND_UP = "SVR_OTHER_STAND_UP"
E.SVR_OTHER_OFFLINE = "SVR_OTHER_OFFLINE"
E.SVR_GAME_START = "SVR_GAME_START"
E.SVR_GAME_OVER = "SVR_GAME_OVER"
E.SVR_BET = "SVR_BET"
E.SVR_CAN_OTHER_CARD = "SVR_CAN_OTHER_CARD"
E.SVR_OTHER_OTHER_CARD = "SVR_OTHER_OTHER_CARD"
E.SVR_SHOW_CARD = "SVR_SHOW_CARD"
E.SVR_CARD_NUM = "SVR_CARD_NUM"
E.SVR_ERROR = "SVR_ERROR"
E.SVR_ROOM_BROADCAST = "SVR_ROOM_BROADCAST"
E.SVR_COMMON_BROADCAST = "SVR_COMMON_BROADCAST"
E.SVR_GET_PERSONAL_ROOM_LIST = "SVR_GET_PERSONAL_ROOM_LIST"
E.SVR_CREATE_PERSONAL_ROOM = "SVR_CREATE_PERSONAL_ROOM"
E.SVR_LOGIN_PERSONAL_ROOM = "SVR_LOGIN_PERSONAL_ROOM"
E.SVR_SEARCH_PERSONAL_ROOM = "SVR_SEARCH_PERSONAL_ROOM"

E.SVR_GET_DEALER_ROOM_OK = "SVR_GET_DEALER_ROOM_OK"
E.SVR_LOGIN_NEW_ROOM_OK = "SVR_LOGIN_NEW_ROOM_OK"

E.UPDATE_SEAT_INVITE_VIEW = "UPDATE_SEAT_INVITE_VIEW"
-- SignIn Events --
E.SIGNIN_GET_DATA_SUCC = "SIGNIN_GET_DATA_SUCC"
E.SIGNIN_GET_DATA_FAIL = "SIGNIN_GET_DATA_FAIL"

E.SIGN_GET_SIGNIN_DATA_SUCC = "SIGN_GET_SIGNIN_DATA_SUCC"
E.SIGN_GET_SIGNIN_DATA_FAIL = "SIGN_GET_SIGNIN_DATA_FAIL"
E.SIGN_REFRESH_ACCUM_SIGNIN_BLOCK = "SIGN_REFRESH_ACCUM_SIGNIN_BLOCK"

-- UnionAct Event --
E.PROMOT_GET_TASK_STATUS_DATA_SUCC = "PROMOT_GET_TASK_STATUS_DATA_SUCC"
E.PROMOT_GET_TASK_STATUS_DATA_FAIL = "PROMOT_GET_TASK_STATUS_DATA_FAIL"

-- UserInfoGiftUse --
E.USERINFO_GIFT_WARE = "USERINFO_GIFT_WARE"

-- StorePopup PropSelectChanged --
E.STORE_GIFT_SELECT_CHANG = "STORE_GIFT_SELECT_CHANG"
E.STORE_PROP_SELECT_CHANG = "STORE_PROP_SELECT_CHANG"

E.ENTER_GRAB_DEALER_ROOM = "ENTER_GRAB_DEALER_ROOM"
E.SVR_SUONA_BROADCAST_RECV = "SVR_SUONA_BROADCAST_RECV"
E.SVR_GET_GRAB_DEALER_ROOM_OK = "SVR_GET_GRAB_DEALER_ROOM_OK"
E.SVR_LOGIN_GRAB_ROOM_OK = "SVR_LOGIN_GRAB_ROOM_OK"
E.SVR_GRAB_ROOM_GAME_START = "SVR_GRAB_ROOM_GAME_START"
E.SVR_LOGIN_GRAB_DELAER_ROOM_FAIL = "SVR_LOGIN_GRAB_DELAER_ROOM_FAIL"
E.SVR_REQUEST_GRAB_DEALER_RESULT = "SVR_REQUEST_GRAB_DEALER_RESULT"
E.SVR_BROADCAST_RE_GRAB_DEALER_USER = "SVR_BROADCAST_RE_GRAB_DEALER_USER"
E.SVR_LOGIN_OK_RE_CONECT = "SVR_LOGIN_OK_RE_CONECT"
E.SVR_BROADCAST_GRAB_PLAYER = "SVR_BROADCAST_GRAB_PLAYER"
E.SVR_BROADCAST_CAN_GRAB_DEALER = "SVR_BROADCAST_CAN_GRAB_DEALER"
E.SVR_EXIT_DELAER_FAIL = "SVR_EXIT_DELAER_FAIL"
E.SVR_WARRING_DEALER_ADD_COIN = "SVR_WARRING_DEALER_ADD_COIN"
E.SVR_PLAYER_ADD_COIN_RESULT = "SVR_PLAYER_ADD_COIN_RESULT"
E.SVR_GRAB_ROOM_LIST_RESULT = "SVR_GRAB_ROOM_LIST_RESULT"
E.SVR_DEALER_SITDOWN_FAIL = "SVR_DEALER_SITDOWN_FAIL"
-- Dokb Refresh Crisis Data --
E.DOKB_LOTRY_LOAD_NEXTROUND_RERESHDATA = "DOKB_LOTRY_LOAD_NEXTROUND_RERESHDATA"

E.SVR_JOIN_MATCH_WAIT = "SVR_JOIN_MATCH_WAIT"
E.SVR_PUSH_MATCH_ROOM = "SVR_PUSH_MATCH_ROOM"
E.SVR_PUSH_CHANGE_MATCH_ROOM = "SVR_PUSH_CHANGE_MATCH_ROOM"
E.SVR_WAIT_MATCH_GAME = "SVR_WAIT_MATCH_GAME"

E.TIME_MATCH_OPEN = "TIME_MATCH_OPEN"
E.TIME_MATCH_PUSH = "TIME_MATCH_PUSH"
E.SVR_TIME_MATCH_RANK = "SVR_TIME_MATCH_RANK"
E.SVR_TIME_MATCH_OFF = "SVR_TIME_MATCH_OFF"
E.SVR_BROAD_DEALER_STAND = "SVR_BROAD_DEALER_STAND"
E.SVR_OFF_LINE_RESULT = "SVR_OFF_LINE_RESULT"

--新玩法荷官小费，表情，老虎机等消耗增加金币，刷新座位携带。
E.UPDATE_SEAT_ANTE_CHIP = "UPDATE_SEAT_ANTE_CHIP"

E.ENABLED_EDITBOX_TOUCH = "ENABLED_EDITBOX_TOUCH" --打开输入框触摸事件
E.DISENABLED_EDITBOX_TOUCH = "DISENABLED_EDITBOX_TOUCH" --关闭输入框触摸事件
return EVENT_NAMES
