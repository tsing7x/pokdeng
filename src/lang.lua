--
-- Author: Johnny Lee
-- Date: 2014-07-08 10:52:57
--

local lang = {}
local L    = lang
local TT, TT1

L.COMMON   = {}
L.LOGIN    = {}
L.HALL     = {}
L.ROOM     = {}
L.STORE    = {}
L.USERINFO = {}
L.FRIEND   = {}
L.RANKING  = {}
L.MESSAGE  = {}
L.SETTING  = {}
L.LOGINREWARD = {}
L.HELP     = {}
L.UPDATE   = {}
L.ABOUT    = {}
L.DAILY_TASK = {}
L.COUNTDOWNBOX = {}
L.NEWESTACT = {}
L.FEED = {}
L.ECODE = {}
L.WHEEL = {}
L.BANK = {}
L.SLOT = {}
L.UPGRADE = {}
L.GIFT = {}
L.CRASH = {}
L.DORNUCOPIA = {}
L.POKDENG_AD = {}
L.CGAMEREVIEW = {}
L.CPURCHGUIDE = {}
L.CSIGNIN = {}
L.BOXACT = {}
L.CUNIONACT = {}
L.NEWSTACT = {}
L.MATCH = {}
L.SUONA = {}
L.GRAB_DEALER = {}
L.AUCTION_MARKET = {}
L.GUCURECALL = {}
L.DOKB = {}
L.RECVADDR = {}
L.TICKETTRANSFER = {}
L.NEWER = {}
L.LOYKRATH = {}

-- COMMON MODULE
L.COMMON.LEVEL = T("Lv.{1}")
L.COMMON.ASSETS = T("${1}")
L.COMMON.CONFIRM = T("确定")
L.COMMON.CANCEL = T("取消")
L.COMMON.AGREE = T("同意")
L.COMMON.REJECT = T("拒绝")
L.COMMON.RETRY = T("重试")
L.COMMON.NOTICE = T("温馨提示")
L.COMMON.BUY = T("购买")
L.COMMON.SEND = T("发送")
L.COMMON.BAD_NETWORK = T("网络不给力")
L.COMMON.REQUEST_DATA_FAIL = T("网络不给力，获取数据失败，请重试！")
L.COMMON.ROOM_FULL = T("现在该房间旁观人数过多，请换一个房间")
L.COMMON.USER_BANNED = T("您的账户被冻结了，请你反馈或联系管理员")
L.COMMON.MAX_MONEY_HISTORY = T("历史最高资产: {1}")
L.COMMON.MAX_POT_HISTORY = T("赢得最大奖池: {1}")
L.COMMON.WIN_RATE_HISTORY = T("历史胜率: {1}%%")
L.COMMON.BEST_CARD_TYPE_HISTORY = T("历史最佳牌型:")
L.COMMON.LEVEL_UP_TIP = T("恭喜你升到{1}级, 获得奖励:{2}")
L.COMMON.MY_PROPS = T("我的道具:")
L.COMMON.SHARE = T("分  享")
L.COMMON.PLAYGAME_NOW = T("立即玩牌")  -- ไปเล่นไพ่
L.COMMON.GET_REWARD = T("领取奖励")
L.COMMON.BUY_CHAIP = T("购买")
L.COMMON.LOGOUT = T("登出")
L.COMMON.QUIT_DIALOG_TITLE = T("确认退出")
L.COMMON.QUIT_DIALOG_MSG = T("真的确认退出游戏吗？淫家好舍不得滴啦~\\(≧▽≦)/~")
L.COMMON.QUIT_DIALOG_CONFIRM = T("忍痛退出")
L.COMMON.QUIT_DIALOG_CANCEL = T("我点错了")
L.COMMON.LOGOUT_DIALOG_TITLE = T("确认退出登录")
L.COMMON.LOGOUT_DIALOG_MSG = T("真的要退出登录吗？")
L.COMMON.NOT_ENOUGH_MONEY_TO_PLAY_NOW_MSG = T("您的筹码不足最小买入{1}，您需要补充筹码后重试。")
L.COMMON.NOT_ENOUGH_CASH_TO_PLAY_NOW_MSG = T("您的现金币不足最小买入{1}，您需要补充现金币后重试。")
L.COMMON.USER_SILENCED_MSG = T("您的帐号已被禁言，您可以在帮助-反馈里联系管理员处理")
L.COMMON.OTHER = T("其他")
L.COMMON.BE_BANNED = T("你的号被封了,请联系客服")
L.COMMON.ERROR_HEART_TIME_OUT = T("服务器响应超时")
L.COMMON.ERROR_LOGIN_TIME_OUT = T("服务器登录超时")
L.COMMON.ERROR_CONNECT_FAILURE = T("服务器连接失败")
L.COMMON.ERROR_NETWORK_FAILURE = T("与服务器失去连接,请查看您的网络连接后再次连接")
L.COMMON.ERROR_NOTICE = T("错误提示")
L.COMMON.RETRY_PLEASE = T("请重试")
L.COMMON.ERROR_NETWORK_RECONNECT = T("网络状况不佳{1}正在链接网络")
-- LOGIN MODULE
L.LOGIN.FB_LOGIN = T("FB账户登录")
L.LOGIN.GU_LOGIN = T("游客账户登录")
L.LOGIN.USE_DEVICE_NAME_TIP = T("您是否允许我们使用您的设备名称\n作为游客账户的昵称并上传到游戏服务器？")
L.LOGIN.REWARD_SUCCEED = T("领取奖励成功")
L.LOGIN.REWARD_FAIL = T("领取失败")
L.LOGIN.REIGSTER_REWARD_FIRST_DAY = T("第一天")
L.LOGIN.REGISTER_REWARD_SECOND_DAY = T("第二天")
L.LOGIN.REGISTER_REWARD_THIRD_DAY = T("第三天")
L.LOGIN.LOGINING_MSG = T("正在登录游戏...")
L.LOGIN.CANCELLED_MSG = T("登录已经取消")
L.LOGIN.FEED_BACK_HINT     = T("กรุณาแจ้งปัญหาโดยละเอียดพร้อมเบอร์โทรของท่าน ทางทีมงานจะรีบติดต่อท่านเพื่อแก้ปัญหาเข้าเกมไม่ได้โดยเร็ว ขอบคุณค่ะ ")
L.LOGIN.FEED_BACK_TITLE    = T("ฟีดแบค")
L.LOGIN.PHONE_NUMBER       = T(" โปรดกรอกเบอร์โทร (ต้องกรอก)")
L.LOGIN.DOUBLE_LOGIN_MSG = T("您的账户在其他地方登录")
L.LOGIN.FEED_BACK_TABBAR_LABEL =  {
    T("反馈"), 
    T("处理结果")
}

L.LOGIN.CLEAR_CACHE_TIP = T("点击一键清理按钮后,可以清理游戏中的缓存,是否确认清理？")  -- กดปุ่ม "ล้างแคช" เข้าเกมส์ได้สะดวกยิ่งขึ้น  ยืนยันที่จะล้าง?
-- HALL MODULE
L.HALL.USER_ONLINE = T("当前在线人数{1}")
L.HALL.INVITE_FRIEND = T("邀请FB好友+{1}")
L.HALL.DAILY_BONUS = T("登录奖励")
L.HALL.DAILY_MISSION = T("每日任务")
L.HALL.NEWEST_ACTIVITY = T("最新活动")
L.HALL.LUCKY_WHEEL = T("幸运转转转")
L.HALL.SIGN_IN = T("签到领奖")  -- ลงชื่อรับรางวัล

L.HALL.NOTOPEN=T("暂未开放 敬请期待")
L.HALL.STORE_BTN_TEXT = T("商城")
L.HALL.FRIEND_BTN_TEXT = T("好友")
L.HALL.RANKING_BTN_TEXT = T("排行榜")
L.HALL.SCORE_MARKET_BTN_TEXT = T("兑换")
L.HALL.MAX_BUY_IN_TEXT = T("最大买入{1}")
L.HALL.MIN_BUY_IN_TEXT = T("最小买入{1}")
L.HALL.MIN_IN_TO_ROOM_TEXT = T("最小入场{1}")
L.HALL.PRE_CALL_TEXT = T("前注")
L.HALL.SEARCH_ROOM_INPUT_ROOM_NUMBER_ERROR = T("你输入的房间号码有误")
L.HALL.SEARCH_ROOM_INPUT_ROOM_NUMBER_EMPTY = T("房间号码不能为空")
L.HALL.SEARCH_ROOM_NUMBER_IS_WRONG= T("你输入的房间位数不对")
L.HALL.SEARCH_ROOM_INPUT_CORRECT_ROOM_NUMBER= T("请输入房间号码")
L.HALL.ROOM_LEVEL_TEXT = {
    T("普通场"),
    T("现金币场"),
    T("私人房")
}

L.HALL.CHOOSE_ROOM_SUONA_USE_TIP = T("点击这里使用小喇叭 >>") -- กดส่งลำโพงทั่วเซิร์ฟ >>

L.HALL.CHOOSE_NORROOM_GROUP_TEXT = {
    T("庄家"),
    T("上庄资产"),
    T("底注"),
    T("入场门槛"),
    T("MIN上庄值"),
    T("在线人数")
}

L.HALL.CHOOSE_NORROOM_QUICK_START = T("快速进入")

L.HALL.ROOM_LIST_TAB_TEXT = {
    T("热门比赛"),
    T("常规赛"),
    T("敬请期待")
}
L.HALL.MATCH_REGISTER_TAB = {
    T("规则"),
    T("奖励")
}
L.HALL.GRAB_ROOM_OPEN_SOON = T("全新上庄玩法火热研发中，敬请期待下个版本")

L.HALL.PERSONAL_ROOM_TITLE = T("私人房")
L.HALL.PERSONAL_ROOM_CREATE_CHIP_ROOM = T("创建筹码房间")
L.HALL.PERSONAL_ROOM_CREATE_ROOM = T("创建房间")
L.HALL.PERSONAL_ROOM_INVITE_FRIEND = T("邀请好友")
L.HALL.PERSONAL_ROOM_QRCODE = T("扫码推荐")
L.HALL.PERSONAL_ROOM_ENTER = T("进入")
L.HALL.PERSONAL_ENTER_PSW_ERR = T("密码错误")
L.HALL.PERSONAL_ROOM_LEVEL_TEXT = {
    T("初级场"), 
    T("中级场")
}
L.HALL.PERSONAL_ROOM_CREATE = {
    T("房间名称: "),  -- ชื่อห้อง:
    T("房间底注: "),
    T("房间密码: "),
    T("赢家服务费: "),
    T("房间最小进入: "),
    T("输入房间名称"),
    T("请输入6位数密码"),  -- กรุณากรอกรหัสผ่าน 6 หลัก
    T("不填则没有密码")
}

L.HALL.PERSONAL_ROOM_LIST_TITLE = 
{
    T("房间ID"),
    T("房间名称"),
    T("底注"),
    T("最小进入"),
    T("服务费"),
    T("密码"),
    T("房间人数")
}

L.HALL.PERSONAL_ROOM_INVITE_PLAY = {
    T("好友"),
    T("在线玩家")
}
L.HALL.PERSONAL_ROOM_LINECALL = T("用LINE叫TA")
L.HALL.PERSONAL_ROOM_INVITE_ONLINE = {
    T("在线"),
    T("离线"),
    T("大厅"),
    T("房间游戏中"),
    T("发送成功"),
    T("发送失败")
}
L.HALL.PERSONAL_ROOM_TOP_TIPS = {
    T("接受邀请"),
    T("稍后接受")
}
L.HALL.PERSONAL_NOROOM = T("房间不存在")
L.HALL.PERSONAL_CREATE_ROOM_TIPS = T("ทุกรอบในห้องชิป ผู้ชนะต้องจ่ายค่าบริการ=ชิปที่ชนะ*10%% นำเข้าต่ำสุด=เดิมพัน*20เท่า")
-- {
    --T("私人房每局收取没人一定比例的服务费: 底注 X 10%%"),
    --T("最小进入=底注 X 20")
    -- T("ทุกรอบในห้องชิป ผู้ชนะต้องจ่ายค่าบริการ=ชิปที่ชนะ*10%%"),
    -- T("นำเข้าต่ำสุด=เดิมพัน*20เท่า")
-- }
L.HALL.PERSONAL_ROOM_DEF_ROOMNAME = T("小欢欢")
L.HALL.PERSONAL_ROOM_INVITE_CONTENT = T("{1}邀请您进入私人房")
L.HALL.PERSONAL_ROOM_NOT_ENOUGH = T("您的金币不足，不能创建该底注场私人房")
L.HALL.PERSONAL_ROOM_CANT_CHANGEROOM = T("私人房不可换桌")  -- ห้องส่วนตัวไม่สามารถเปลี่ยนโต๊ะได้ค่ะ

-- Vice PersonelRoom Popups --
L.HALL.PERSONAL_ROOM_QRSCAN_TIP_TOP = T("扫描二维码下载'搏定牌'游戏")  -- สแกน QR Code โหลดเกมส์ไพ่ป๊อกเด้ง
L.HALL.PERSONAL_ROOM_QRSCAN_TIP_BOTTOM = T("把二维码给朋友扫一扫,即可下载搏定牌游戏,一起玩更开心")  -- ให้เพื่อนสแกน QR Code โหลดเกมส์ไพ่ป๊อกเด้ง เล่นด้วยกันสนุกยิ่งขึ้น!
L.HALL.PERSONAL_ROOM_HELP_TITLE = T("私人房功能介绍")  -- คำอธิบายห้องส่วนตัว
L.HALL.PERSONAL_ROOM_HELP_TIPS_TITLE = {
    T("1. 什么是私人房？"),  -- 1. ห้องส่วนตัวคืออะไร?
    T("2. 筹码房间和积分房间有什么区别？"),  -- 2. ห้องชิปและห้องคะแนนมีความแตกต่างกันอย่างไร?
    T("3. 临时积分输完后怎么办？"),  -- 3. หากคะแนนสะสมชั่วคราวของคุณหมดจะทำอย่างไร?
    T("4. 二维码有什么用？")  -- 4. QR Code มีประโยชน์อะไรบ้าง?
}
L.HALL.PERSONAL_ROOM_HELP_TIPS_CONT = {
    T("私人房是玩家和朋友间游戏的私密房间,可以设定密码避免陌生人打扰。"),  -- คือห้องส่วนตัวของผู้เล่นและเพื่อนๆ สามารถตั้งรหัสห้องได้เพื่อไม่ให้คนอื่นเข้าไปรบกวน
    T("两种房间区别是结算货币不同。‘筹码房间’输赢使用“游戏筹码”结算。‘积分房间’输赢使用‘临时积分’ 结算,不消耗游戏筹码。临时积分是一种临时结算代币,只在积分房间内有效,退出积分房间则清零。"), 
        -- ความแตกต่างของ 2 ห้องนี้อยู่ที่ชิป หากแพ้ชนะใน“ห้องชิป” จะใช้ชิปเกมส์ในการคิดผลรวม ส่วน“ห้องคะแนน” จะใช้“คะแนนชั่วคราว”ในการคิดผลรวม คะแนนชั่วคราวนั้นใช้ในการคิดผลรวมชั่วคราวแทนการใช้ชิปเกมส์ ใช้ได้เฉพาะในห้องคะแนนเท่านั้น หากออกจากห้องคะแนน คะแนนทั้งหมดจะถูกหักเป็น 0
    T("输完后可以在房间内申请添加,申请后系统会记录玩家申请次数及总数。"),  -- หากแพ้หมด สามารถยื่นเรื่องขอเพิ่มคะแนนได้ ระบบจะบันทึกจำนวนครั้งในการยื่นเรื่องและคะแนนที่ได้ทั้งหมดของคุณไว้
    T("可以把二维码展示给朋友让其扫码快速下载游戏,朋友下载后就可以和你一起游戏了。")  -- สามารถส่งให้เพื่อนสแกน QR Code เพื่อทำการโหลดเกมส์ไพ่ป๊อกเด้งได้ หลังเพื่อนโหลดเสร็จ ก็สามารถเข้าเกมส์มาเล่นกับคุณได้ทันที
}

L.HALL.PERSONAL_ROOM_ENTRY_TITLE = T("请输入房间密码")  -- ใส่รหัสห้อง
-- L.HALL.PERSONAL_ROOM_ENTRY_ROOM_NAME = T("房间名称:")  -- ชื่อห้อง:
L.HALL.PERSONAL_ROOM_ENTRY_ROOM_ID = T("房间 id:")  -- ID ห้อง:

-- L.HALL.PERSONAL_ROOM_ENTRY_EDIT_HINT = T("请输入6位数密码")  -- กรุณากรอกรหัสผ่าน 6 หลัก
L.HALL.PERSONAL_ROOM_ENTRY_WRONG_PSW_TIP = T("密码输入有误！")  -- รหัสไม่ถูกต้องค่ะ!
L.HALL.PERSONAL_ROOM_ENTRY_ENTER_ROOM = T("进入房间")  -- เข้าห้อง

L.HALL.PERSONAL_HALL_TIPS = {
    T("创建自己的房间邀请好友一起游戏"),
    T("你可以分享游戏的二维码给好友，方便快速下载")
}
-- Vice PersonelRoom Popups end --

-- Hall NewstActPaopTip --
L.HALL.NEWSTACT_PAOPTIP = T("点击领取免费筹码")  -- กดรับชิปฟรี

L.HALL.PLAYER_LIMIT_TEXT = {
    T("9\n人"), 
    T("5\n人")
}
L.HALL.SHARE_CONWIN_FIVE = T("太棒了！您在游戏中连胜了5局，快去分享成就给伙伴们吧，还能获得5000游戏币，或许还有更大惊喜等着你，一定要分享哟！")
L.HALL.SHARE_FIVE_CARD = T("今天,您得到5倍牌型!如此成就必须炫耀炫耀 ")

L.ROOM.INFO_UID = T("ID {1}")
L.ROOM.INFO_LEVEL = T("Lv.{1}")
L.ROOM.INFO_RANKING = T("排名:  {1}")
L.ROOM.INFO_WIN_RATE = T("胜率:  {1}%%")
L.ROOM.INFO_SEND_CHIPS = T("赠送筹码")
L.ROOM.ADD_FRIEND = T("加为好友")
L.ROOM.DEL_FRIEND = T("删除好友")
L.ROOM.FOLLOW = T("关注")
L.ROOM.UN_FOLLOW = T("取消关注")
L.ROOM.ADD_FRIEND_FAILED_MSG = T("添加好友失败")
L.ROOM.DELE_FRIEND_SUCCESS_MSG = T("删除好友成功")
L.ROOM.DELE_FRIEND_FAIL_MSG = T("删除好友失败")
L.ROOM.SEND_CHIP_NOT_NORMAL_ROOM_MSG = T("只有普通场才可以赠送筹码")
L.ROOM.SELF_CHIP_NO_ENOUGH_SEND_DELEAR = T("你的筹码不够多，不足给荷官小费")
L.ROOM.SEND_CHIP_NOT_IN_SEAT = T("坐下才可以赠送筹码")
L.ROOM.SEND_CHIP_NOT_ENOUGH_CHIPS = T("钱不够啊")
L.ROOM.SEND_CHIP_TOO_OFTEN = T("赠送的太频繁了")
L.ROOM.SEND_CHIP_TOO_MANY = T("赠送的太多了")
L.ROOM.SEND_HDDJ_IN_MATCH_ROOM_MSG = T("比赛场不能发送互动道具")
L.ROOM.SEND_HDDJ_NOT_IN_SEAT = T("坐下才能发送互动道具")
L.ROOM.SEND_HDDJ_NOT_ENOUGH = T("您的互动道具数量不足，赶快去商城购买吧")
L.ROOM.SEND_EXPRESSION_MUST_BE_IN_SEAT = T("坐下才可以发送表情")
L.ROOM.CHAT_FORMAT = T("{1}: {2}")
L.ROOM.ROOM_INFO = T("{1} {2}/前注{3}")
L.ROOM.NO_BIG_LA_BA = T("暂无喇叭,是否立即购买？")
L.ROOM.SEND_BIG_LABA_MESSAGE_FAIL = T("发送大喇叭消息失败")
L.ROOM.USER_CARSH_REWARD_DESC = T("您获得了{1}筹码的破产补助，终身只有三次机会获得，且用且珍惜")
L.ROOM.USER_CARSH_BUY_CHIP_DESC = T("您也可以立即购买，输赢只是转瞬的事")
L.ROOM.USER_CARSH_REWARD_COMPLETE_DESC = T("您已经领完所有破产补助，您可以去商城购买筹码，每天登录还有免费筹码赠送哦！")
L.ROOM.USER_CARSH_REWARD_COMPLETE_BUY_CHIP_DESC = T("输赢乃兵家常事，不要灰心，立即购买筹码，重整旗鼓。")
L.ROOM.WAIT_NEXT_ROUND = T("请等待下一局开始")
L.ROOM.LOGIN_ROOM_FAIL_MSG = T("登录房间失败")
L.ROOM.BUYIN_ALL_POT= T("全下")
L.ROOM.BUYIN_3QUOT_POT = T("2/3")
L.ROOM.BUYIN_HALF_POT = T("1/2")
L.ROOM.BUYIN_TRIPLE = T("1/3")
L.ROOM.CHAT_TAB_SHORTCUT = T("快捷聊天")
L.ROOM.CHAT_TAB_HISTORY = T("聊天记录")
L.ROOM.INPUT_HINT_MSG = T("点击输入聊天内容")
L.ROOM.CHAT_SHORTCUT = {
  T("大家好!"),
  T("初来乍到，多多关照"),
  T("我等到花儿都谢了"),
  T("ALL IN 他!!"),
  T("你的牌打得太好了!"),
  T("冲动是魔鬼，淡定!"),
  T("求跟注，求ALL IN!"),
  T("送点钱给我吧!"),
  T("哇，你抢钱啊!"),
  T("又断线，网络太差了!")
}

L.ROOM.OFF_LINE_TIPS_1 =    T("您刚刚离线异常,自动玩牌期间赢收了{1}筹码")
L.ROOM.OFF_LINE_TIPS_2 =    T("您刚刚离线异常,自动玩牌期间亏损了{1}筹码")
L.ROOM.OFF_LINE_TIPS_3 =    T("您刚刚离线异常,自动玩牌期间赢收了{1}现金币")
L.ROOM.OFF_LINE_TIPS_4 =    T("您刚刚离线异常,自动玩牌期间亏损了{1}现金币")

--买入弹框
L.ROOM.BUY_IN_TITLE = T("买入筹码")
L.ROOM.BUY_IN_BALANCE_TITLE = T("您的账户余额:")
L.ROOM.BUY_IN_MIN = T("最低买入")
L.ROOM.BUY_IN_MAX = T("最高买入")
L.ROOM.BUY_IN_AUTO = T("筹码不足时自动买入")
L.ROOM.BUY_IN_BTN_LABEL = T("买入坐下")
L.ROOM.BACK_TO_HALL = T("返回大厅")
L.ROOM.CHANGE_ROOM = T("换  桌")
L.ROOM.SETTING = T("设  置")
L.ROOM.SIT_DOWN_NOT_ENOUGH_MONEY = T("您的筹码不足当前房间的最小携带，您可以点击自动换桌系统帮你选择房间或者补足筹码重新坐下。")
L.ROOM.AUTO_CHANGE_ROOM = T("自动换桌")
L.ROOM.USER_INFO_ROOM = T("个人信息")
L.ROOM.CHARGE_CHIPS = T("补充筹码")
L.ROOM.ENTERING_MSG = T("正在进入，请稍候...\n有识尚需有胆方可成赢家")
L.ROOM.OUT_MSG = T("正在退出，请稍候...")
L.ROOM.CHANGING_ROOM_MSG = T("正在更换房间..")
L.ROOM.CHANGE_ROOM_FAIL = T("更换房间失败，是否重试？")
L.ROOM.STAND_UP_IN_GAME_MSG = T("请在本局结束后站起, 强制站起按“输牌”处理, 你确定要站起吗?")
L.ROOM.STAND_UP_TIPS = T("本局结束站起")
L.ROOM.EXIT_IN_GAME_MSG = T("请在本局结束后退出, 强制退出按“输牌”处理, 你确定要退出吗?") 
L.ROOM.CHANGE_ROOM_IN_GAME_MSG = T("请在本局结束后换桌, 强制换桌按“输牌”处理, 你确定要换桌吗?") 
L.ROOM.NET_WORK_PROBLEM_DIALOG_MSG = T("与服务器的连接中断，是否尝试重新连接？")
L.ROOM.RECONNECT_MSG = T("正在重新连接..")

L.ROOM.AUTO_CHECK = T("自动看牌")
L.ROOM.AUTO_CHECK_OR_FOLD = T("看或弃")
L.ROOM.AUTO_FOLD = T("自动弃牌")
L.ROOM.AUTO_CALL_ANY = T("跟任何注")
L.ROOM.FOLD = T("弃  牌")
L.ROOM.ALL_IN = T("ALL IN")
L.ROOM.CALL = T("跟  注")
L.ROOM.CALL_NUM = T("跟注 {1}")
L.ROOM.SMALL_BLIND = T("小盲")
L.ROOM.BIG_BLIND = T("大盲")
L.ROOM.RAISE = T("加  注")
L.ROOM.RAISE_NUM = T("加注 {1}")
L.ROOM.CHECK = T("看  牌")
L.ROOM.GET_POKER = T("要牌")
L.ROOM.NOT_GET_POKER = T("不要牌")
L.ROOM.AUTO_GET_POKER = T("自动要牌")
L.ROOM.AUTO_NOT_GET_POKER = T("自动不要牌")


L.ROOM.TIPS = {
    T("小提示：游客用户点击自己的头像弹框或者性别标志可更换头像和性别哦"),
    T("小经验：当你牌比对方小的时候，你会输掉已经押上的所有筹码"),
    T("高手养成：所有的高手，在他会三公游戏之前，一定是一个三公游戏的菜鸟"),
    T("有了好牌要加注，要掌握优势，主动进攻。"),
    T("留意观察对手，不要被对手的某些伎俩所欺骗。"),
    T("要打出气势，让别人怕你。"),
    T("控制情绪，赢下该赢的牌。"),
    T("游客玩家可以自定义自己的头像。"),
    T("小提示：设置页可以设置进入房间是否自动买入坐下。"),
    T("小提示：设置页可以设置是否震动提醒。"),
    T("忍是为了下一次All In。"),
    T("冲动是魔鬼，心态好，好运自然来。"),
    T("风水不好时，尝试换个位置。"),
    T("输牌并不可怕，输掉信心才是最可怕的。"),
    T("你不能控制输赢，但可以控制输赢的多少。"),
    T("用互动道具砸醒长时间不反应的玩家。"),
    T("运气有时好有时坏，知识将伴随你一生。"),
    T("诈唬是胜利的一大手段，要有选择性的诈唬。"),
    T("下注要结合池底，不要看绝对数字。"),
    T("All In是一种战术，用好并不容易。")
}
L.ROOM.SHOW_HANDCARD = T("亮出手牌")
L.ROOM.DEALER_SPEEK_ARRAY = {
    T("祝您牌运亨通，{1}"),
    T("祝您好运连连，{1}"),
    T("您人真好，{1}"),
    T("真高兴能为您服务，{1}"),
    T("衷心的感谢您，{1}")
}
L.ROOM.SERVER_UPGRADE_MSG = T("服务器正在升级中，请稍候..")
L.ROOM.USER_CRSH_POP_TITLE = T("破产了")
L.ROOM.CHAT_MAIN_TAB_TEXT = {
    T("消息"), 
    T("消息记录")
}
L.ROOM.KICKED_BY_ADMIN_MSG = T("您已被管理员踢出该房间")
L.ROOM.KICKED_BY_USER_MSG = T("您被用户{1}踢出了房间")
L.ROOM.TO_BE_KICKED_BY_USER_MSG = T("您被用户{1}踢出房间，本局结束之后将自动返回大厅")

-- Expressions --
L.ROOM.EXPRE_TABTEXT = {
    T("常规表情"),  -- อีโมทั่วไป
    T("狐狸表情"),  --  อีโมจิ้งจอกเจ้าเล่ห์
    T("兔子表情")  -- อีโมกระต่ายคิกข
}

L.ROOM.EXPRE_FREE_USE_TIP = T("全场免费使用")  -- ใช้ได้ฟรีทุกห้อง
L.ROOM.EXPRE_PAID_USE_TIP = T("单次使用费{1}筹码")  -- ค่าใช้จ่าย {1} ชิป/ครั้ง
L.ROOM.EXPRE_USED_FIALD_TIP = T("表情使用失败,请重试")  -- ใช้อีโมล้มเหลวค่ะ กรุณาลองใหม่อีกครั้งค่ะ 
L.ROOM.EXPRE_USED_NOT_MONEY = T("筹码不足，付费表情使用失败，请稍后再试")

L.ROOM.NOT_ENOUGH_MONEY_SENDCHIPS = T("您没有多余的筹码赠送了,请稍后再试")  -- คุณมีชิปไม่พอส่งให้เพื่อน กรุณาส่งใหม่ทีหลังค่ะ

-- MatchRoom --
L.MATCH.MATCH_ROOM_HELP_TITLE = T("比赛场说明")  -- กติกาห้องแข่งขัน
L.MATCH.MATCH_ROOM_HELP_TIPS_TITLE = {
    T("1. 怎么参加比赛?"),  -- 1. จะเข้าร่วมการแข่งขันได้อย่างไร?
    T("2. 怎么获取比赛门票?"),  -- 2. ตั๋วแข่งขันจะหามาจากที่ใดได้บ้าง?
    T("3. 比赛规则是什么?"),  -- 3. การแข่งขันมีกติกาอะไรบ้าง?
    T("4. 积分是什么?"),  -- 4. คะแนนคืออะไร?
    T("5. 比赛怎么玩?")  -- 5. ห้องแข่งขันเล่นอย่างไร?
}
L.MATCH.MATCH_EXIT_TIP = T("您确认要退出本场比赛吗?")

L.MATCH.MATCH_ROOM_HELP_TIPS_CONT = {
    T("比赛分为“付费比赛”和“免费比赛”两种方式。付费比赛需要消耗 “筹码” 或者 “参赛门票”。每场比赛官方会收取一定比例的筹码作为服务费;"),
        -- ไพ่ป๊อกเด้งมีการแข่งขัน 2 แบบ คือ \n  1.การแข่งขันแบบจ่ายค่าเข้าร่วม \n  2.การแข่งขันแบบฟรี ซึ่งการแข่งขันแบบจ่ายค่าเข้าร่วมนั้นจะใช้ “ชิป” หรือ “ตั๋วแข่งขัน” เป็นค่าเข้าร่วมการแข่งขัน ซึ่งการแข่งขันแต่ละรอบ ระบบจะมีการเก็บค่าบริการตามสัดส่วนที่กำหนด
    T("比赛门票有2种获取方式:\n    1.参加低级别的比赛取得名次后可获取高级别的比赛门票;\n    2.在商城储值购买“比赛门票”;"),
        -- วิธีการหาตั๋วแข่งขันมี 2 วิธี ดังนี้ \n  1.เข้าร่วมการแข่งขันในห้องระดับต่ำ หลังได้แรงค์กิ้งตามที่ระบบกำหนด จะได้รับตั๋วแข่งขันที่มีสิทธิ์เข้าแข่งในห้องระดับสูงฟรี \n  2.สามารถหาซื้อ “ตั๋วแข่งขัน” ได้ใน “ห้าง”
    T("比赛采用搏定牌的比牌规则。原来是闲家和庄家进行比牌判断输赢,但在比赛中是玩家和玩家进行比牌,所有玩家下注的积分算作桌面奖池,最大牌型的玩家赢得桌面奖池全部积分。"),
        -- การแข่งขันป๊อกเด้งใช้กติกาการเทียบไพ่แบบเดิม ต่างกันตรงที่จากเดิมเจ้าและผู้เล่นเทียบไพ่หาผู้แพ้ชนะ แต่ในห้องแข่งขันจะเปลี่ยนเป็นผู้เล่นแข่งขันกับผู้เล่นด้วยกันเอง คะแนนที่ใช้ในการเดิมพันของผู้เล่นทุกท่านจะถือเป็นคะแนนกองกลาง ใครชนะได้ไพ่ใหญ่สุด ผู้นั้นจะได้รับคะแนนกองกลางทั้งหมด
    T("积分是搏定比赛玩法采用的筹码代币,每场比赛所有玩家初始携带的积分相同,积分输完后自动站起并淘汰出局。最后根据站起的顺序决定排名名次。"),
        -- คือคะแนนที่ใช้เล่นแทนชิปในห้องแข่งขัน ผู้เล่นทุกท่านในทุกห้องแข่งขันจะนำเข้าคะแนนเท่ากัน คะแนนใครหมดก่อนจะถูกให้ยืนขึ้นอัตโนมัติและคัดออกจากการแข่งขัน หลังจากนั้นจะวัดผลแรงค์กิ้งตามลำดับต่อไป
    T("每局开始时所有玩家先下注一定积分到桌面奖池作为前注,下注额度和当前底注相同;\n" .. 
            "荷官开始顺时针方向发牌,每人2张牌。为了增强趣味性,每人2张牌中的其中一张亮为明牌给其他玩家看到;\n" .. 
            "发完牌后玩家开始轮流下注。下注规则是:上家选择下注积分,则下家下注额度不能少于上家下注额度（可以等于）,下家也可以选择弃牌;\n" .. 
            "所有玩家第一轮下注完成后选择是否继续要牌。（已弃牌玩家本轮判输不再要牌）;\n" ..
            "荷官依次给要牌玩家发第三张牌。为了增强趣味性第三张牌依然为明牌;\n" .. 
            "第三张牌发完后桌面玩家开始第二次轮流下注;\n" .. 
            "第二轮下注完毕后所有玩家亮牌进行比牌,最大牌型玩家获胜,赢得桌面奖池;\n" .. 
            "玩家输完积分后自动站起,根据出局的顺序决定排名并颁奖。")

    -- หลังเริ่มการแข่งขัน ผู้เล่นทุกท่านจะวางเดิมพันแรกไว้เป็นคะแนนกองกลาง โดยจำนวนคะแนนที่จะวางเดิมพันจะเท่ากับคะแนนเดิมพันปัจจุบัน\n
    -- สาวแจกไพ่เริ่มแจกไพ่ตามเข็มนาฬิกา ทุกท่านจะได้รับไพ่ 2 ใบ เพื่อให้การแข่งขันมีความสนุกและน่าตื่นเต้นมากขึ้น ไพ่ที่แจกให้ผู้เล่นนั้นจะมี 1 ใบเป็นไพ่หงาย ทุกท่านสามารถเห็นไพ่หงายของคู่แข่งได้\n
    -- หลังแจกไพ่เสร็จ ผู้เล่นจะผลัดกันวางเดิมพัน กติการการวางเดิมพันคือ: ผู้เล่นก่อนหน้าเลือกจำนวนคะแนนที่จะวางเดิมพัน ผู้เล่นท่านถัดไปจะต้องวางเดิมพันที่มีจำนวนห้ามต่ำกว่าจำนวนเดิมพันของผู้เล่นก่อนหน้า (เดิมพันเท่ากันได้) หรือผู้เล่นท่านถัดไปสามารถเลือกหมอบได้ \n
    -- หลังจากผู้เล่นทุกท่านทำการวางเดิมพันรอบที่ 1 เสร็จแล้ว สามารถเลือกที่จะจั่วไพ่ได้ (ผู้เล่นที่หมอบถือว่าแพ้ในรอบการแข่งขันนี้แล้ว จะทำการจั่วไพ่ไม่ได้)\n
    -- สาวแจกไพ่ทำการแจกไพ่ใบที่ 3 ให้กับผู้เล่นที่จั่วไพ่ เพื่อให้การแข่งขันน่าลุ้นมากยิ่งขึ้น ไพ่ใบที่ 3 จะเป็นไพ่หงาย ผู้เล่นทุกท่านสามารถมองเห็นได้\n
    -- เมื่อไพ่ใบที่ 3 แจกเสร็จแล้ว ผู้เล่นทุกท่านจะผลัดกันวางเดิมพันรอบที่ 2\n
    -- เมื่อวางเดิมพันรอบที่ 2 เสร็จแล้ว จะเริ่มทำการเทียบไพ่ โดยผู้เล่นที่ได้ไพ่ใหญ่สุดจะเป็นผู้ชนะ ได้รับคะแนนชิปกองกลางทั้งหมด\n
    -- ผู้เล่นที่แข่งจนคะแนนหมด จะถูกให้ยืนขึ้นอัตโนมัติ หลังจากนั้นจะวัดผลแรงค์กิ้งตามลำดับต่อไป
}

L.MATCH.GAME_START = T("比赛开始了")
L.MATCH.WAIT_FOR_GAME = T("等待开赛...")
L.MATCH.EXIT_TIP = {
    T("退赛说明:"),
    T('1.当前状态为"等待开赛"，强制退赛将不予返还报名费用。请您耐心等待;'),
    T("2.避免您等待时间过久，再过 {1} 秒后如还未开赛则可以免费退赛。"),
    T("注意：筹码报名的玩家仅返还报名费用，服务费用不再返还。门票报名的玩家返还门票。")
}
L.MATCH.EXIT_GAME = {
    T("我要退赛"),
    T("继续比赛")
}

L.MATCH.APPLY_1 = T("报名比赛")
L.MATCH.APPLY_2 = T("报名")
L.MATCH.CANCEL = T("取消")
L.MATCH.APPLYED = T("已报名")

L.MATCH.MORE_AWARD = T("更多奖励")
L.MATCH.JOIN_BY_TICKETN = T("使用门票参赛")
L.MATCH.JOIN_BY_CHIPS = T("使用筹码参赛")
L.MATCH.JOIN_FEE = T("参赛费:")
L.MATCH.SERVICE_FEE = T("服务费:")
L.MATCH.FREE = T("免费")
L.MATCH.YOU_CHIPS = T("您的筹码:")
L.MATCH.YOU_TICKETS = T("您的门票数:")
L.MATCH.PICS = T("{1}张")
L.MATCH.NUM = T("数:")
L.MATCH.CAN_JOIN_NUM_BY_CHIPS = T("可使用筹码报名次数:")
L.MATCH.CAN_JOIN_NUM_BY_FREE = T("可免费报名次数:")
L.MATCH.APPLY_FAIL = T("报名失败{1}")
L.MATCH.CHIP_NO_ENOUGH = T("金币不足")
L.MATCH.TICKET_NO_ENOUGH = T("门票不足")
L.MATCH.APPLY_FREE_OVER = T("今天免费报名次数已经用完，请明天再来")
L.MATCH.APPLY_CHIPS_OVER = T("今天筹码报名次数已经用完，请尝试其他报名方式")

L.MATCH.RANK_BOARD = T("排行榜")
L.MATCH.RANK_AWARD = T("排行奖励")
L.MATCH.RANKING = T("名次")
L.MATCH.AWARD_TIME = T("获奖时间")
L.MATCH.AWARD_GET = T("领奖")
L.MATCH.RANK_TIPS = T("{1} 参加 {2}  获得第 {3} 名")
L.MATCH.AWARD_SUCC = T("领取成功")
L.MATCH.AWARD_CONTENT = T("奖励内容")
L.MATCH.CONGRATULATION = T("恭喜您获得了第{1}名的好成绩，向朋友们炫耀一下吧！")
L.MATCH.NONE = T("无")
L.MATCH.RETURN = T("返回")
L.MATCH.LOOKER = T("留下旁观")
L.MATCH.SHARE = T("分享")
L.MATCH.AWARD_UPPER_LIMIT = T("您短时间内多次获得该名次，超过当日颁奖上限，请明天再来.")
L.MATCH.PLAY_AGAIN = T("您离冠军并不遥远，调整好状态再来一局吧")
L.MATCH.TICKET_NUM = T("门票张数: ")
L.MATCH.TICKET_NUM_COMMON = T("通用门票张数: ")
L.MATCH.AWARD_NONE = T("暂无获奖记录")
L.MATCH.CURRENT_SELF_RANK = T("当前排名:")
L.MATCH.CURRENT_MATCH_BASE = T("当前底注:")
L.MATCH.NEXT_MATCH_BASE = T("下轮底注:") 
L.MATCH.HOW_RANK = T("第 {1} 名")
L.MATCH.PLAY_GAME_LEFT_NUM = T("请不要频繁强制退赛，再过{1}局后才可退赛")
L.MATCH.FORCE_EXIT_GAME_TIPS = {
    T("退赛提示"),
    T("当前状态为‘已经开赛’，强制退赛将不会获得比赛名次及奖励!"),
    T("您确定要强制退赛吗？")
}
L.MATCH.TIME_PUSH_TIPS = T("你报名的{1},还有{2}秒钟开赛,请玩家赶紧到比赛场集合")

L.MATCH.MATCH_TIME_RANK = {
    T("我的排名:"),
    T("当前底注:"),
    T("下次底注:"),
    T("当前第一名积分:"),
    T("所有人平均积分:"),
    T("当前剩余人数:")
}
L.MATCH.FORCE_EXIT_BUTTON = {
    T("强制退赛"),
    T("继续比赛")
}
L.MATCH.MATCH_TIME_RANK_TAB = {
    T("详情"),
    T("奖励")
}
--การแข่งกำลังจะเริ่ม รีบมาเข้าร่วมแล้วเอารางวัลใหญ่กัน!
L.MATCH.RECOMMEND_PUSH_TIP = T("比赛即将开赛，马上参赛赢取大奖！")
L.MATCH.JOIN_MATCH = T("参加比赛")  --ร่วมแข่ง
L.MATCH.INVITE_HAD_SEND_TIP = T("邀请已发布，请等待用户加入")
L.MATCH.INVITE_FRIEND_JOIN_MATCH = T("邀请朋友比赛")
L.MATCH.OPEN_TIME = T("开赛时间")
L.MATCH.OPEN_SOON = T("即将开赛")
L.MATCH.RANKING_LABEL = T("第{1}名")


TT = {}
L.COMMON.CARD_TYPE = TT
TT1 = {}

TT[1] = TT1
TT[2] = T("顺子")
TT[3] = T("同花顺")
TT[4] = T("三黄")
TT[5] = T("三张")
TT[6] = T("博定")
TT1[0] = T("0点")
TT1[1] = T("1点")
TT1[2] = T("2点")
TT1[3] = T("3点")
TT1[4] = T("4点")
TT1[5] = T("5点")
TT1[6] = T("6点")
TT1[7] = T("7点")
TT1[8] = T("8点")
TT1[9] = T("9点")
TT = {}
L.ROOM.SIT_DOWN_FAIL_MSG = TT
TT["IP_LIMIT"] = T("坐下失败，同一IP不能坐下")
TT["SEAT_NOT_EMPTY"] = T("坐下失败，该桌位已经有玩家坐下。")
TT["CHIPS_ERROR"] = T("坐下失败, 携带的筹码不正确。")
TT["CHIPS_LIMIT"] = T("筹码超出该场限制，快去更高场次游戏吧")
TT["OTHER"] = T("坐下失败.")

L.HALL.ERROR_TABLE_NOT_EXIST = T("桌子不存在")
L.HALL.ERROR_USER_IN_TABLE = T("您正在房间内")
L.HALL.ERROR_NOT_ENOUGH_MONEY = T("筹码太少，不能进场")
L.HALL.ERROR_TOO_MUCH_MONEY = T("筹码太多，不能进场")

L.HALL.GUIDE_ROOM_TIP = T("进入{1}场玩牌赢得更多哦")

L.ROOM.SERVER_STOPPED_MSG = T("系统正在停服维护, 请耐心等候")
L.STORE.NOT_SUPPORT_MSG = T("您的账户暂不支持支付")
L.STORE.PURCHASE_SUCC_AND_DELIVERING = T("已支付成功，正在进行发货，请稍候..")
L.STORE.PURCHASE_CANCELED_MSG = T("支付已经取消")
L.STORE.PURCHASE_FAILED_MSG = T("支付失败")
L.STORE.PURCHASE_FAILED_MSG_2 = T("此卡无效或输入有误，请重试。")
L.STORE.DELIVERY_FAILED_MSG = T("网络故障，系统将在您下次打开商城时重试。")
L.STORE.DELIVERY_SUCC_MSG = T("发货成功，感谢您的购买。")
L.STORE.TITLE_STORE = T("商城")
L.STORE.TITLE_CHIP = T("筹码")
L.STORE.TITLE_PROP = T("互动道具")
L.STORE.TITLE_CASH = T("现金币")
L.STORE.TITLE_TICKET = T("通用门票")
L.STORE.TITLE_GIFT = T("礼物")  -- ของขวัญ
L.STORE.TITLE_MY_PROP = T("我的道具")
L.STORE.TITLE_HISTORY = T("储值记录")  -- บันทึกการเติมเงิน
L.STORE.RATE_CHIP = T("1{2}={1}筹码")
L.STORE.FORMAT_CHIP = T("{1}筹码")  -- ชิป {1}
L.STORE.FORMAT_TICKET = T("{1}张")
L.STORE.REMAIN = T("剩余：{1}{2}")
L.STORE.INTERACTIVE_PROP = T("互动道具")
L.STORE.BUY = T("购买")
L.STORE.USE = T("使用")
L.STORE.BUY_CHIPS = T("购买{1}筹码")
L.STORE.BUY_CASHS = T("购买 {1} 现金币")  -- ซื้อ {1} ชิปเงินสด
L.STORE.BUY_TICKETS = T("购买 {1} 比赛门票")  -- ซื้อ {1} คูปองรวม
L.STORE.BUY_GIFTBAGS = T("购买 {1}TH 大礼包")  -- ซื้อ {1} บาทแพคเกจใหญ่

L.STORE.RECORD_STATUS = {
    T("已下单"),
    T("已发货"),
    T("已退款")
}
L.STORE.USE_SUCC_MSG = T("道具使用成功")
L.STORE.USE_FAIL_MSG = T("道具使用失败")
L.STORE.NO_PRODUCT_HINT = T("暂无商品")
L.STORE.NO_BUY_HISTORY_HINT = T("暂无支付记录")
L.STORE.MY_CHIPS = T("我的筹码 {1}")
L.STORE.BUSY_PURCHASING_MSG = T("正在购买，请稍候..")
L.STORE.CARD_INPUT_SUBMIT = "TOP UP"

L.STORE.BUY_PROPPACK_SUCC = T("购买道具包成功")  -- ซื้อไอเทมสำเร็จค่ะ
L.STORE.BUY_PROP_FAILD = T("购买失败")  -- ซื้อไอเทมล้มเหลวค่ะ
L.STORE.PROPITEM_DESC = T("内含10种与玩家互动的魔法表情,可在房间内与其他玩家互动.")  -- มีอีโมเมจิกพิเศษ 10 อย่าง ที่สามารถใช้เล่นกับเพื่อนได้ในห้อง.
L.STORE.PROP_PACK = T("互动表情包 *") -- แพ็คเกจอีโม *
L.STORE.CHECK_BUY = T("是否购买{1}?")
L.STORE.CHECK_PERFER_BUY = T("是否购买{1} +{2}筹码加赠优惠?")
L.STORE.SURE_COST_BUY = T("花{1}购买")  -- จ่าย {1}บาทซื้อชิป

L.BANK.BANK_POPUP_TOP_TITIE = T("个人银行")
L.BANK.BANK_GIFT_LABEL = T("我的礼物")

-- login reward
L.LOGINREWARD.TITLE = T("连续登录奖励")
L.LOGINREWARD.REWARD = T("今日奖励{1}筹码")
L.LOGINREWARD.REWARD_ADD = T("(FB登录多加100000筹码)")
L.LOGINREWARD.PROMPT = T("连续登录可获得更多奖励，最高每天{1}游戏币奖励")
L.LOGINREWARD.DAYS = T("{1}天")
L.LOGINREWARD.NO_REWARD = T("三次注册礼包领取完成后即可领取")
-- USERINFO MODULE
L.USERINFO.MAX_MONEY_HISTORY = T("历史最高资产:")
L.USERINFO.MAX_POT_HISTORY = T("赢得最大奖池:")
L.USERINFO.WIN_RATE_HISTORY = T("历史胜率:")
L.USERINFO.INFO_RANKING = T("排名:")
L.USERINFO.BEST_CARD_TYPE_HISTORY = T("历史最佳牌型:")
L.USERINFO.MY_PROPS = T("我的道具:")
L.USERINFO.MY_PROPS_TIMES = "X{1}"
L.USERINFO.EXPERIENCE_VALUE = "{1}/{2}" --经验值

-- Modify By Tsing --
L.USERINFO.TAB_INDEX_TEXT = {
    T("游戏信息"),  -- ข้อมูลเกมส์
    -- T("私人银行"),  --
    L.STORE.TITLE_MY_PROP,
    L.BANK.BANK_GIFT_LABEL,  --
    L.BANK.BANK_POPUP_TOP_TITIE
    -- T("道具背包")  -- 
}

L.USERINFO.DEALROUND = T("牌局数:")  -- จำนวนรอบไพ่:
L.USERINFO.INCOME_TODAY = T("今日收益:")  -- ชิปที่ได้วันนี้:
L.USERINFO.CHIPMATCH_MEDAL = T("筹码比赛奖牌")  -- ไพ่รางวัล
L.USERINFO.INSPECMATCH_CLUB = T("实物比赛奖杯")  -- ถ้วยรางวัล
L.USERINFO.NOT_GETREWARD_YET = T("暂未获奖")  -- ยังไม่มีรางวัลค่ะ
L.USERINFO.BANK_NOT_OPEN_YET = T("银行功能暂未开放!")  -- ฟังก์ชั่นธนาคารยังไม่เปิดให้บริการค่ะ!
L.USERINFO.BANK_VERIFY_CODE = T("请验证密码!")  -- กรุณายืนยันรหัสค่ะ!
L.USERINFO.BANK_VERIFY_NOW = T("现在验证")  -- ยืนยันตอนน
L.USERINFO.BANK_USE_TIP1 = T("1.使用步骤:输入操作金额数目>选择[存钱]或[取钱]")  -- 1.วิธีการใช้:กรอกจำนวนเงินที่ต้องการ> เลือก[ฝาก] หรือ [ถอน]
L.USERINFO.BANK_USE_TIP2 = T("2.取钱时需要收取2%%的管理费")  -- 2.หากถอนเงินจะต้องเสียค่าบริการ 2%% ค่ะ
L.USERINFO.BANK_USE_TIP3 = T("2.现金币保险箱仅限付费用户使用")

-- L.USERINFO.GIFT_CENTERTIP = T("点击选中既可在牌桌上展示才礼物")
L.USERINFO.GIFT_BOTTOMTIP = T("进入道具商城可使用筹码购买各种游戏道具和礼物")  -- สามารถใช้ชิปในการซื้อไอเทมและของขวัญทุกชนิดได้ที่ห้าง
-- L.GIFT.NO_GIFT_TIP  -- 暂时没有礼物
L.USERINFO.GIFT_GO_SHOP = T(">>礼物商城")  -- >>ห้างของขวัญ
L.USERINFO.PROP_GO_SHOP = T(">>道具商城")  -- >>ห้างไอเทม


-- FRIEND MODULE
L.FRIEND.NO_FRIEND_TIP = T("暂无好友\n立即邀请好友可获得丰厚筹码赠送！")
L.FRIEND.SEND_CHIP = T("赠送筹码")
L.FRIEND.SEND_CHIP_WITH_NUM = T("赠送{1}筹码")
L.FRIEND.SEND_CHIP_SUCCESS = T("您成功给好友赠送了{1}筹码。")
L.FRIEND.SEND_CHIP_TOO_POOR = T("您的筹码太少了，请去商城购买筹码后重试。")
L.FRIEND.SEND_CHIP_COUNT_OUT = T("您今天已经给该好友赠送过筹码了，请明天再试。")
L.FRIEND.INVITE_DESCRIPTION = T("每邀请一位Facebook好友,可立即获赠{1}筹码。FaceBook好友接受邀请并成功登录游戏,您还可以额外获得{2}筹码奖励,多劳多送。\n\n同时,被邀请的好友登录游戏后也可获赠{3}筹码的注册礼包,赠送的筹码由系统免费发放。")
    -- คุณจะได้รับรางวัล {1} ชิปฟรีต่อการเชิญเพื่อน FB 1 ท่าน หากเพื่อนตอบรับคำเชิญเข้าเล่นเกมส์ คุณจะได้รับรางวัลชิปฟรีเพิ่มอีก {2} ชิป ยิ่งขยันเชิญเพื่อน ยิ่งได้ชิปฟรีมากขึ้น ส่วนเพื่อนที่เข้าเกมส์จะได้รับรางวัลลงทะเบียนฟรี {3} ชิป ซึ่งระบบจะส่งชิปเข้าบัญชีอัตโนมัติ
L.FRIEND.INVITE_REWARD_TIP = T("您已累计获得了{1}筹码的邀请奖励，多劳多得，天天都有哦！")
L.FRIEND.INVITE_WITH_FB = T("Facebook\n邀请")
L.FRIEND.INVITE_WITH_SMS = T("短信邀请")
L.FRIEND.INVITE_WITH_MAIL = T("邮件邀请")
L.FRIEND.INVITE_WITH_LINE = T("Line邀请")
L.FRIEND.SELECT_ALL = T("全选")
L.FRIEND.DESELECT_ALL = T("取消全选")
L.FRIEND.SEND_INVITE = T("邀请")
L.FRIEND.INVITE_SUBJECT = T("您绝对会喜欢")
L.FRIEND.INVITE_CONTENT = T("为您推荐一个既刺激又有趣的扑克游戏，我给你赠送了{1}的筹码礼包，注册即可领取，快来和我一起玩吧！http://dwz.cn/Gc7zQ")
    -- ป๊อกเด้งมันส์ๆ เพื่อนเล่นเพียบ เข้าเล่นเกมส์รับไปเลย {1} ชิป มาเล่นด้วยกันนะ! https://goo.gl/hdX7vp
L.FRIEND.RECALL_SUBJECT = T("您有一个回归礼包等待您领取")  -- เข้าเกมส์ใหม่รับรางวัลใหญ่ 1 ชุด
L.FRIEND.RECALL_CONTENT = T("好久没见到你了,搏定现在全新升级,更有现金币场模拟真实线下玩牌体验,现在回来即可领取回归礼包一份,快回来一起玩吧！")
    --  [ไพ่ป๊อกเด้ง] อัพเดทใหม่เหมือนเล่นจริงนอกระบบ กลับมาตอนนี้รับรางวัล!
L.FRIEND.INVITE_SELECT_TIP = T("您已选择了{1}位好友 发送邀请即可获得{2}筹码的奖励")
L.FRIEND.INVITE_FRIENDS_NUM_LIMIT_TIP = T("一次邀请最多选取50位好友")
L.FRIEND.INVITE_SUCC_TIP = T("成功发送了邀请，获得{1}的奖励！")
L.FRIEND.CANNOT_SEND_MAIL = T("您还没有设置邮箱账户，现在去设置吗？")
L.FRIEND.CANNOT_SEND_SMS = T("对不起，无法调用发送短信功能！")
L.FRIEND.INVITE_CONTENT2 = T("博定刺激好玩,好友在等你,进来玩吧")
L.FRIEND.MAIN_TAB_TEXT = {
    T("我的好友"), 
    T("邀请好友")
}
L.FRIEND.INVITE_TAB = {
    T("邀请拿金币"),
    T("召回送礼包")  -- สะกิดเพื่อนแจกชิป
}
L.FRIEND.INVITE_RECALL_INFO = {
    T("1.连续7天未登录的好友可被召回"),
    T("2.好友回归进入游戏可获得回归大礼包一份")
}
L.FRIEND.RECALL_SELECT_NUM = T("已选{1}个好友")
L.FRIEND.INVITE_RECALL_INFO3 = T("3.3万筹码奖励每天最多可获得两次(今日：{1})")  -- 3.30K ชิปทุกวันรับได้เพียง 2 ครั้ง (วันนี้：{1})

L.FRIEND.TOO_MANY_FRIENDS_TO_ADD_FRIEND_MSG = T("您的好友已达到600上限，请删除部分后重新添加")
L.FRIEND.INVITE_OLD_USER_TIP = T("您需要使用FB账号登陆才能发送邀请")
L.FRIEND.RESTORE_TEXT = T("注：恢复界面可恢复之前删除的好友")
L.FRIEND.RESTORE_BTN_TIP = T("恢复好友")
L.FRIEND.RETURN_BTN_TIP = T("返回")
L.FRIEND.RESTORE_NO_DATA = T("您没有可恢复的好友")
L.FRIEND.SEARCH_FRIEND = T("请输入FB好友名称")
L.FRIEND.CANT_TRACE_FRIEND = T("好友当前位置不可被追踪,请稍后再试")  -- ตอนนี้ยังติดตามเพื่อนไม่ด้

-- RANKING MODULE
L.RANKING.TRACE_PLAYER = T("追踪玩家")
L.RANKING.HALL = T("大厅")
L.RANKING.OFF_LINE = T("离线")
L.RANKING.MAIN_TAB_TEXT = {
    T("好友排行"), 
    T("总排行榜")
}
L.RANKING.SUB_TAB_TEXT_FRIEND = {
    T("筹码排行"), 
    T("等级排行"),
    T("现金币排行")
}
L.RANKING.SUB_TAB_TEXT_GLOBAL = {
    T("筹码排行"), 
    T("等级排行"),
    T("盈利排行"),
    T("现金币排行")
}

-- SETTING MODULE
L.SETTING.TITLE = T("设置")
L.SETTING.NICK = T("昵称")
L.SETTING.LOGOUT = T("登出")
L.SETTING.SOUND_VIBRATE = T("声音和震动")
L.SETTING.SOUND = T("声音")
L.SETTING.VIBRATE = T("震动")
L.SETTING.OTHER = T("其他")
L.SETTING.AUTO_SIT = T("进入房间自动坐下")
L.SETTING.AUTO_BUYIN = T("自动买入")
L.SETTING.APP_STORE_GRADE = T("喜欢我们，打分鼓励")
L.SETTING.CHECK_VERSION = T("检测更新")
L.SETTING.CURRENT_VERSION = T("当前版本号：V{1}")
L.SETTING.ABOUT = T("关于")
L.SETTING.FANS = T("官方粉丝页")
L.HELP.TITLE = T("帮助")
L.HELP.SUB_TAB_TEXT = {
    T("问题反馈"),
    T("常见问题"),
    T("基本规则"),
    T("说明")
}
L.HELP.FEED_BACK_HINT = T("您在游戏中碰到的问题或者对游戏有任何意见或者建议,我们都欢迎您给我们反馈。\n" ..
    "客服联系方式: \n" ..
    "邮件:Pokdengfeedback@boyaa.com \n" ..
    "电话:026700909或026700919转0(接通时间：09.00-18.00 周一到周日)\n" ..
    "粉丝页:https://www.facebook.com/pokdengtl/")

-- หากพบเจอปัญหาหรือมีคำแนะนำใดๆ แจ้งรายละเอียดพร้อมแคปภาพให้เราได้เสมอค่ะ \n
-- ติดต่อฝ่ายบริการลูกค้า->>\n
-- อีเมล์: Pokdengfeedback@boyaa.com\n
-- เบอร์โทร: 026700909/026700919 กด 0(เวลาทำการ: จันทร์-อาทิตย์ เวลา 09.00-18.00 น.)\n
-- แฟนเพจ:https://www.facebook.com/pokdengtl/

L.HELP.NO_FEED_BACK = T("您现在还没有反馈记录")
L.HELP.FEED_BACK_SUCCESS = T("反馈成功!")
L.HELP.UPLOADING_PIC_MSG = T("正在上传图片，请稍候..")
L.HELP.MUST_INPUT_FEEDBACK_TEXT_MSG = T("请输入反馈内容")
L.HELP.MUST_INPUT_FEEDBACK_PHONE_NUM = T("请输入手机号码")
L.HELP.FAQ = {
    {
        T("วีธิอื่นติดต่อฝ่ายบริการลูกค้า:"),
        T("หากพบเจอปัญหาหรือมีคำแนะนำใดๆ แจ้งรายละเอียดพร้อมแคปภาพให้เราได้เสมอค่ะ \n" ..
            "ติดต่อฝ่ายบริการลูกค้า->>\n" ..
            "อีเมล์: Pokdengfeedback@boyaa.com\n" ..
            "เบอร์โทร: 026700909/026700919 กด 0(เวลาทำการ: จันทร์-อาทิตย์ เวลา 09.00-18.00 น.)\n" ..
            "แฟนเพจ:https://www.facebook.com/pokdengtl/")
    },
    {
        T("รับชิปฟรีได้ที่ไหน?"),
        T("คุณสามารถรับชิปฟรีได้จาก รางวัลล็อกอิน รางวัลอัพเลเวล รางวัลภารกิจ รางวัลเชิญเพื่อน โบนัสแฟนส์  และรางวัลกิจกรรมต่างๆ เป็นต้น")
    },
    {
        -- "ซื้อชิปอย่างไร",
        -- {
        --     "กดปุ่ม",
        --     "แล้วเลือกยอดชิปที่ท่านต้องการ")
        -- }
        T("ซื้อชิปอย่างไร?"),
        T('กดปุ่ม "ห้าง" แล้วเลือกช่องทางการเติมเงินและยอดชิปที่ต้องการซื้อ')
    },
    {
        T("อยากเป็นแฟนส์ ทำอย่างไร?"),
        T('กดปุ่ม "ตั้งค่า" เลือก "หน้าแฟนส์" หรือเข้าไปที่ https://www.facebook.com/pokdengtl แล้วกดไลค์เพจ ระบบแจกโบนัสแฟนส์ทุกวัน')
    },
    {
        T("ล็อกเอาท์เกมส์อย่างไร?"),
        T('กดปุ่ม "ตั้งค่า" แล้วเลือก "ล็อกเอาท์"')
    },
    {
        T("เปลี่ยนชื่อ เพศ และรูปประจำตัวได้อย่างไร?"),
        T('สามารถเปลี่ยนได้เฉพาะบัญชีนักเที่ยวเท่านั้น โดยกด "รูปประจำตัว" และเลือกตั้งค่าตามระบบ')
    },
    
}

L.HELP.RULE = {
    {
        T("เงื่อนไขการพิจารณาไพ่ที่อยู่ระดับเดียวกัน"),
        ""
    },

    {
        T("翻倍规则"),
        ""
    },

    {
        T("รูปแบบไพ่ แต้ม และดอก"),
        T("●หากไพ่ 2 ใบรวมกันได้ 8 หรือ 9 จะถือว่าได้รูปแบบไพ่ใหญ่สุดคือไพ่ป๊อก หากไพ่ป๊อกที่ได้มีดอกเดียวกัน ผลแพ้ชนะจะ *2 เท่า หากได้แต้มไพ่เหมือนกันและรวมกันได้ไพ่ป๊อก การนับเด้งจะนับ *2 เท่าเช่นกัน\n") .. 
        T("●ไพ่ 3 ใบที่มีแต้มเดียวกันรวมกันได้ไพ่รูปแบบตอง ผลแพ้ชนะจะ *5 เท่า\nรูปแบบไพ่ตอง เรียงจากใหญ่ไปเล็ก ดังนี้ : A>K>Q>J>10>9>8>7>6>5>4>3>2\n") .. 
        T("●ไพ่ 3 ใบที่รวมกันในกลุ่ม J/Q/K คือไพ่สามเหลือง ผลแพ้ชนะจะ *3 เท่าหากได้รูปแบบไพ่สามเหลืองเหมือนกันจะทำการเทียบแต้มที่ใหญ่ที่สุด (เช่น KQQ>QQJ, KKQ>KQQ)\n") .. 
        T("●ไพ่ 3 ใบที่มีแต้มเรียงกันและมีดอกเดียวกัน ถือว่าเป็นไพ่เรียงดอก ผลแพ้ชนะจะ *5 เท่า\n") .. 
        T("●ไพ่ 3 ใบที่มีแต้มเรียงกัน แต่ดอกไม่เหมือนกัน ถือว่าเป็นไพ่เรียง ผลแพ้ชนะจะ *3 เท่า\nกรณีพิเศษ มีดังนี้: A23 ไม่ถือว่าเป็นไพ่เรียง โดย KQA ถือว่าเป็นไพ่เรียงที่ใหญ่ที่สุด และ234 เป็นไพ่เรียงที่เล็กที่สุด\nรูปแบบไพ่เรียง เรียงจากใหญ่ไปเล็ก ดังนี้ : KQA>JQK>10JQ>910J>8910>789>.......>234\n") ..
        T("●ไพ่ 2-3 ใบที่ไม่ได้รวมกันเป็นไพ่รูปแบบพิเศษข้างต้น ถือว่าเป็นไพ่ธรรมดา ผลแพ้ชนะไม่นับเด้ง ไพ่ชนิดนี้จะเทียบไพ่จากแต้ม หากไพ่รวมกันได้แต้มมากกว่า 10 ให้นับแต้มหลักหน่วยเท่านั้น\nรูปแบบไพ่ธรรมดา เรียงจากใหญ่ไปเล็ก ดังนี้  : 9>8>7>6>5>4>3>2>1>0")
    },

    {
        T("服务费收取说明"),  -- เกี่ยวกับค่าบริการ
        T("普通场中收取获胜玩家的3%%\n") ..  -- จะถูกเก็บค่าบริการ 3%% จากผู้ชนะในห้องธรรมดา\n
        T("上庄场筹码收取获胜玩家的5%%\n") ..  -- จะถูกเก็บค่าบริการ 5%% จากผู้ชนะในห้องเจ้า\n
        T("上庄现金币场最低收取获胜的玩家1现金币")  -- จะถูกเก็บค่าบริการ 5% จากผู้ชนะในห้องชิปเงินสด ซึ่งจำนวนค่าบริการต่ำสุดคือ 1 ชิปเงินสด
    },

    {
        T("เดิมพันและเล่นอย่างไร"),
        T("●หลักการเข้าห้องเกมส์: แต่ละห้องจะมีการเดิมพันขั้นต่ำและยอดนำเข้า หากมีชิปพอสำหรับการเดิมพันขั้นต่ำ จะสามารถเข้าห้องที่เลือกได้\nหากยอดชิปมีจำนวนมากเป็นพิเศษ ห้องเดิมพันขั้นต่ำจะไม่สามารถเข้าได้\nจำนวนเดิมพันขั้นต่ำสามารถตรวจสอบดูได้ตามห้องระดับต่างๆ\n") .. 
        T("●หลังเข้าห้องเกมส์ จะต้องกดเลือกจำนวนชิปที่จะนำเข้าโต๊ะ หรือสามารถเลือกจำนวนชิปตามที่ระบบจัดให้ได\n") .. 
        T("●ขณะนั่งลงรอเล่น หากเกมส์รอบนั้นกำลังเล่นอยู่ จำเป็นจะต้องรอรอบต่อไป ถึงจะสามารถเล่นได\n") .. 
        T("●เวลาเริ่มเกมส์ แต่ละท่านจะมีเวลา 6 วินาทีในการเลือกจำนวนเดิมพัน โดยระบบมีการจัดเรียงปุ่มเดิมพันแบบเร็วให้ท่านทั้งหมด 3 ปุ่มด้วยกัน\n") .. 
        T("●หลังผู้เล่นวางเงินเดิมพันเรียบร้อยแล้ว ผู้เล่นจะทำการแจกไพ่ 2 ใบตามเข็มนาฬิกา หากผู้เล่นท่านใดได้ไพ่ป๊อก ระบบจะทำการเปิดไพ่และไม่สามารถรับไพ่ได้อีก หลังแจกไพ่เสร็จ ผู้เล่นที่ไม่ได้ไพ่ป๊อก มีสิทธิ์ที่จะรับไพ่ได้อีก 1 ใบ (จะรับหรือไม่รับก็ได้) โดยเจ้ามือจะทำการแจกไพ่ตามเข็มนาฬิกาให้กับผู้ที่รับไพ่เพิ่มอีกรอบ หลังจากนั้นจะถือว่าได้แจกไพ่ครบแล้ว\n")
    },
    {
        T("เทียบไพ่และวัดผลแพ้ชนะอย่างไร?"),
        T("●หลังแจกไพ่เสร็จ ผู้เล่นทั้งหมดจะทำการเทียบไพ่กับเจ้ามือ หากไพ่ของตนใหญ่กว่าเจ้ามือจะถือว่าชนะ หากไพ่เล็กกว่าจะถือว่าแพ\n") .. 
        T("●แพ้ชนะเท่าใดขึ้นอยู่กับจำนวนชิปที่เดิมพันและไพ่ที่ได\n") .. 
        T("●เวลาเดิมพัน สามารถเลือกจำนวนชิปที่จะเดิมพันได้ หรือจะกดปุ่มเดิมพันที่ระบบจัดเตรียมไว้ให้ก็ได้เช่นกัน")
    },
    {
        T("刷分作弊行为"),--
        T("进行任何破坏博雅游戏公平性或者占其他人的便宜，或其他影响游戏正常秩序的行为，如主动使用外挂或被动刷分、合伙作弊、使用游戏外挂或者其他的作弊软件、利用BUG（又叫“漏洞”或者“缺陷”）来获得不正当的非法利益，或者利用互联网或其他方式，广告软件将游戏外挂、作弊软件、BUG公之于众等行为 \n") .. 
        T("\n")..
        T("什么是刷分？\n")..
        T("玩家使用作弊软件或手动开多个账户利用系统BUG获得游戏币或免费发放获得游戏币（如每日登陆、移动赠送好友筹码等），且该用户的账号无正常游戏行为（打牌记录等），即属于刷分\n")..
        T("\n")..
        T("处罚标准及方式 :\n")..
        T("1. 暂时冻结账号（根据情节轻重冻结1~N天不等）\n")..
        T("2. 发游戏公告对用户进行违规行为告知并暂时扣除非法获得游戏币。如用户有异议可进行申诉，可将疑问发至邮箱：Pokdengfeedback@boyaa.com 。申诉检查成功后未曾有任何问题玩家可补还暂扣游戏币，但是将在通过审核三天之后补币。")
    },
    {
        T("骚扰行为"),--
        T("(1)在博雅游戏当中进行恶意刷屏、恶意耗时等恶意破坏游戏公共秩序的行为； \n") .. 
        T("(2)发表、转发、传播含有谩骂、诅咒、诋毁、攻击、诽谤、骚扰博雅和/或第三方内容的，或者含有封建迷信、淫秽、色情、下流、恐怖、暴力、凶杀、赌博、反动、扇动民族仇恨、危害祖国统一、颠覆国家政权等让人反感、厌恶的内容的非法言论，或者设置含有上述内容的网名、游戏角色名；？\n")..
        T("\n")..
        T("处罚标准及方式 :\n").. 
        T("1.核实违规行为\n")..
        T("2. 如证据属实，将根据情节由轻到重对用户进行处罚（禁言、禁止登陆、封停账号）")
    },
    {
        T("广告行为"),--
        T("进行任何诸如发布广告、销售商品的商业行为，或者通过游戏内广播进行任何非法的侵害博雅利益的行为，如贩卖游戏币、游戏道具、外挂或倒币、刷币等； \n") .. 
        T("\n")..
        T("处罚标准及方式 :\n").. 
        T("1.核实违规行为\n")..
        T("2. 如证据属实，将根据情节由轻到重对用户进行处罚（禁言、禁止登陆、封停账号）")
    },
    {
        T("盗号行为"),--
        T("盗取其它玩家账号或道具者\n") .. 
        T("\n")..
        T("处罚标准及方式 :\n").. 
        T("1. 暂时冻结账号（根据情节轻重冻结1~N天不等)\n")..
        T("2. 发游戏公告对用户进行违规行为告知并暂时扣除非法获得游戏币\n")..
        T("3. 如用户有异议可通过邮箱 Pokdengfeedback@boyaa.com 进行申诉，情况属实后申诉成功可补还暂扣游戏币。")
    },
    {
        T("倒币行为"),--
        T("利用牌桌输牌等形式，进行游戏币的转移、售卖。\n") .. 
        T("\n")..
        T("什么是倒币？\n").. 
        T("玩家通过作弊、刷分、盗币等行为获得非法游戏币并通过非正常牌局再次导出到其他账号的即是倒币行为。\n")..
        T("\n")..
        T("什么是作弊行为？\n")..
        T(" (1)多次无故弃牌的异常牌局\n")..
        T(" (2)多个账号游戏币集中到单个账号中\n")..
        T(" (3)免费获得游戏币导出\n")..
        T("补充:所有正常渠道获得游戏币均只能在通过游戏正常功能个人使用,不能通过任何形式转交给第三方! \n")..
        T("\n")..
        T("处罚标准及方式 :\n").. 
        T("1. 暂时冻结账号（根据情节轻重冻结1~N天不等）\n")..
        T("2. 发游戏公告对用户进行违规行为告知并暂时扣除非法获得游戏币。如用户有异议可通过邮箱 Pokdengfeedback@boyaa.com  进行申诉，申诉成功可补还暂扣游戏币。\n")..
        T("注释：如果有玩家反馈被其他人盗币，如果情况属实，将暂扣对方游戏币三天，如果对方没有反馈反对意见，将补偿给反馈者应得的游戏币。")
    },
    {
        T("侵犯知识产权"),--
        T("（1）删除或修改博雅游戏上的版权信息，或者伪造ICP/IP地址或者数据包的名称；\n") .. 
        T("（2）进行编译、反编译、反向工程或者以其他方式破解博雅游戏的行为；\n") .. 
        T("（3）利用博雅游戏故意传播恶意程序或电脑病毒，或者利用博雅游戏发表、转发、传播侵犯第三方知识产权、肖像权、姓名权、名誉权、隐私或其他合法权益的文字、图片、照片、程序、视频、图象和/或动画等资料，发布假冒博雅游戏官方网站网址或链接\n") .. 
        T("\n")..
        T("处罚标准及方式 :\n").. 
        T("系统将直接回收该账号使用权，并根据情节严重来决定是否提起法律诉讼")
    },
    {
        T("其他违规行为"),--
        T("利用劫持功能变数名称服务器等技术非法侵入、破坏博雅游戏之服务器软件系统，或者修改、增加、删除、窃取、截留、替换博雅游戏之客户端和/或服务器软件系统中的数据，或者非法挤占博雅游戏之服务器空间，或者实施其他的使之超负荷运行等行为\n") .. 
        T("\n")..
        T("处罚标准及方式 :\n").. 
        T("系统将直接回收该账号使用权，并根据情节严重来决定是否提起法律诉讼")
    },
    
}
L.HELP.LEVEL = {
    {
        T("วิธีรับค่า Exp."),
        T("๑)เข้าห้องแล้วนั่งลงเล่นไพ่เป็นช่องทางสำคัญในการรับค่า Exp.\n") .. 
        T("๑)ค่า Exp. ที่ได้รับจะอิงตามผลแพ้ชนะของแต่ละรอบ หากเล่นเยอะก็จะได้ค่า Exp.เยอะ ระบบไม่มีลิมิตจำกัดจำนวนค่า Exp.\n") .. 
        T("๑)หากเป็นเจ้ามือ ค่า Exp.ที่ได้รับจะมากขึ้นถึง 50-200%%\n") .. 
        T("๑)วิธีคิดค่า Exp.\n") .. 
        T("๑)ค่า Exp.ที่เจ้ามือจะได้รับ = จำนวนรอบที่เล่น *3\n") .. 
        T("๑)ค่า Exp.ที่ผู้ชนะจะได้รับ = จำนวนรอบที่เล่น *2\n") .. 
        T("๑)ค่า Exp.ที่ผู้แพ้จะได้รับ = จำนวนรอบที่เล่น *1")
    }    
}

L.HELP.CASH_COIN =
{
    T("说明"),
    T("๑)什么是‘现金币’：‘现金币’可在商城兑换奖励，参加比赛获得名次后会奖励现金币.\n") .. 
    T("๑)什么是‘冠军积分’：‘冠军积分’是搏定牌高手的证明，只有获得比赛名次后才会奖励冠军积分.\n") .. 
    T("๑)什么是筹码：筹码是‘搏定牌’游戏的结算货币，玩家可以储值获得，也可以在游戏内领取小额的免费筹码奖励\n")
}


L.UPDATE.TITLE = T("发现新版本")
L.UPDATE.DO_LATER = T("以后再说")
L.UPDATE.UPDATE_NOW = T("立即升级")
L.UPDATE.HAD_UPDATED = T("您已经安装了最新版本")
L.ABOUT.TITLE = T("关于")
L.ABOUT.UID = T("当前玩家ID: {1}")
L.ABOUT.VERSION = T("版本号：V{1}")
L.ABOUT.FANS = T("官方粉丝页：")
L.ABOUT.FANS_URL = "https://www.facebook.com/pokdengtl"
L.ABOUT.FANS_OPEN = "https://www.facebook.com/pokdengtl"
L.ABOUT.SERVICE = T("服务条款与隐私策略")
L.ABOUT.COPY_RIGHT = "Copyright © 2016 Boyaa Interactive International Limited."

L.DAILY_TASK.GET_REWARD = T("领取")  -- รับชิป
L.DAILY_TASK.HAD_FINISH = T("已完成")
L.DAILY_TASK.GO_FINISH = T("去完成")  --  ไปทำ
L.DAILY_TASK.COMPLETE_REWARD = T("恭喜你完成了任务：{1}")
L.DAILY_TASK.GET_TASKREWARD_SUCC = T("成功获得{1}筹码、{2}经验值奖励")  -- รับรางวัล {1}ชิป 、{2}ค่าExp. สำเร็จค่ะ
-- count down box
L.COUNTDOWNBOX.TITLE = T("倒计时宝箱")
L.COUNTDOWNBOX.SITDOWN = T("坐下才可以继续计时。")
L.COUNTDOWNBOX.FINISHED = T("您今天的宝箱已经全部领取，明天还有哦。")
L.COUNTDOWNBOX.NEEDTIME = T("再玩{1}分{2}秒，您将获得{3}筹码。")
L.COUNTDOWNBOX.REWARD = T("恭喜您获得宝箱奖励{1}筹码。")
L.COUNTDOWNBOX.NEXT_REWARD = T("解锁下个宝箱即可领取{1}筹码")
L.USERINFO.UPLOAD_PIC_NO_SDCARD = T("没有安装SD卡，无法使用头像上传功能")
L.USERINFO.UPLOAD_PIC_PICK_IMG_FAIL = T("获取图像失败")
L.USERINFO.UPLOAD_PIC_UPLOAD_FAIL = T("上传头像失败，请稍后重试")
L.USERINFO.UPLOAD_PIC_IS_UPLOADING = T("正在上传头像，请稍候...")
L.USERINFO.UPLOAD_PIC_UPLOAD_SUCCESS = T("上传头像成功")

-- 活动 --
L.NEWESTACT.ACT_TABLE = {
    T("เชิญแจกเมล็ดพันธุ์"),  -- เชิญแจกเมล็ดพันธุ์
    T("เล่นไพ่ฟรีชิป"),  -- แข่งชิงไอโฟน 6
    T("ฟาร์มชิปเก็บเมล็ด"), -- ฟาร์มชิป(筹码农场)  
    
    T("เปิดตัวเร็วๆนี้"),--每日任务
    T("ตีไข่ทอง"), --砸金蛋
    T("买一赠一"), -- ซื้อ 1 แถม 1 -- 买一赠一
    T("เล่นไพ่ฟรีชิปเงินสด") -- แจกทองสื่อรัก  送金饰
    
}
L.NEWESTACT.NO_ACT = T("暂无活动")
L.NEWESTACT.TITLE = T("最新活动")
L.NEWESTACT.LOADING = T("加载中...")

-- end --
L.FEED.SHARE_SUCCESS = T("分享成功")
L.FEED.SHARE_FAILED = T("分享失败")
L.FEED.LOGIN_REWARD = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/boding/loginReward.jpg",
    message = "",
}
L.FEED.EXCHANGE_CODE = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "http://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/EXCHANGE_CODE1.jpg",
    message = "",
}
L.FEED.WHEEL_ACT = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/boding/rotaryTable.jpg",
    message = "",
}
L.FEED.WHEEL_REWARD = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/boding/rotaryTable.jpg",
    message = "",
}
L.FEED.UPGRADE_REWARD = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "http://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/levelUp/level{1}.png",
    message = "",
}
L.FEED.LOGIN_REGISTER = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/boding/register.jpg",
    message = "",
}
L.FEED.FREE_COIN = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/boding/introduction.jpg",
    message = "",
}
L.FEED.FLOWER_INTRODUCE = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/boding/motherDay.jpg",
    message = "",
}
L.FEED.FLOWER_GETEDREWARD = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/qePwlV",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/boding/motherDay.jpg",
    message = "",
}

L.FEED.COR_GETED_SPEED_WATER = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/jiasu.jpg",
    message = "",
}
L.FEED.COR_GETED_INGOT = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/jinseed.jpg",
    message = " ",
}
L.FEED.COR_GETED_SILVER = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/Xo3hyd",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/yinseed.jpg",
    message = "",
}
L.FEED.COR_SHARE_MY_COR = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/qePwlV",
    picture = "https://d147wns3pm1voh.cloudfront.net/static/nineke/nineke/images/feed/myfarm.jpg",
    message = " ",
}
L.FEED.CON_WIN_FIVE = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/qePwlV",
    picture = "https://d2ohj77wyj9jfx.cloudfront.net/images/androidtl/feed/win5.jpg",
    message = "",
}
L.FEED.FIVE_MUL_CARD = {
    name = T(" "),
    caption = T(" "),
    link = "https://goo.gl/qePwlV",
    picture = "https://d2ohj77wyj9jfx.cloudfront.net/images/androidtl/feed/5time.png",
    message = "",
}

L.FEED.UNIONACT_FINAL_REWARD = {
    name = T(" "),  -- ตื่นเต้นอ่ะ ได้ทองคำ แถมเงินหนักอึ้งเลย!!!
    caption = T(" "),  -- ดีใจจัง ฉันได้ของขวัญหายาก "ไพ่ทองคำเก้าเกไทย" ในเกมส์ไพ่ป๊อกเด้ง แถมชิปอีก 200000 ฟรี มาลองกันดูสิ!
    link = "https://play.google.com/store/apps/details?id=com.boyaa.pokdeng",
    picture = "https://d2ohj77wyj9jfx.cloudfront.net/images/androidtl/feed/union.jpg",
    message = "",
}
L.FEED.WIN_MATCH = {
    name = T(" "),  -- ยินดีกับ XXX ด้วยค่ะ คุณได้ที่ Ｘ ในเกมส์การแข่งขันป๊อกเด้ง เพื่อนๆมาร่วมให้กำลังใจกันทีนะ!~
    caption = T(" "),  -- ดีใจจัง ฉันได้ของขวัญหายาก "ไพ่ทองคำเก้าเกไทย" ในเกมส์ไพ่ป๊อกเด้ง แถมชิปอีก 200000 ฟรี มาลองกันดูสิ!
    link = "https://play.google.com/store/apps/details?id=com.boyaa.pokdeng",
    picture = "https://d2ohj77wyj9jfx.cloudfront.net/images/androidtl/feed/union.jpg",
    message = "",
}

-- message
L.MESSAGE.TAB_TEXT = {
    T("好友消息"), 
    T("系统消息")
}
L.MESSAGE.EMPTY_PROMPT = T("您现在没有消息记录")
L.MESSAGE.FREE_SEND = T("免费回赠")
--奖励兑换码
L.ECODE.TITLE = T("奖励兑换")
L.ECODE.EDITDEFAULT = T("请输入礼包兑换码")  -- กรุณากรอกหมายเลขหรัสโบนัสค่ะ
L.ECODE.DESC = T("关注粉丝页可免费领取奖励兑换码,我们还会不定期在官方粉丝页推出各种精彩活动,谢谢关注。\n\n粉丝页地址 https://www.facebook.com/pokdengtl")
L.ECODE.EXCHANGE = T("兑  奖")
L.ECODE.SUCCESS = T("恭喜您，兑奖成功！\n您获得了{1}")
L.ECODE.ERROR_FAILED = T("兑奖失败，请确认您的兑换码是否输入正确！")
L.ECODE.ERROR_INVALID = T("兑奖失败，您的兑换码已经失效。")
L.ECODE.ERROR_USED = T("兑奖失败，每个兑换码只能兑换一次。\n您已经兑换到了{1}")
L.ECODE.ERROR_END = T("领取失败，本次奖励已经全部领光了，关注我们下次早点来哦")
L.ECODE.FANS = T("关注粉丝页")
--大转盘
L.WHEEL.SHARE = T("分享")
L.WHEEL.SHARE_GET = T("分享+1")
L.WHEEL.SHARE_GET_CHANCE = T("获得一次抽奖机会")
L.WHEEL.SHARE_BOTTOM_TIP = {T("点此分享即可额外获得1次转盘机会，每日前2次生效"),
T("每日前2次生效")}
L.WHEEL.SHARE_BOTTOM_TIP2 = {T("开心大转盘，好东西要和朋友一起分享哦"),
T("_")}

L.WHEEL.REMAIN_COUNT = T("剩余抽奖数")
L.WHEEL.TIME = T("次")
L.WHEEL.DESC1 = T("每天登录即可免费获得3次抽奖机会")
L.WHEEL.DESC2_PRE = T("每次")
L.WHEEL.DESC2_POST = T("中奖")
L.WHEEL.DESC3 = T("绝不落空，最高可赢取一千万筹码。")
L.WHEEL.DESC4 = T("立即开始吧，点击开始抽奖按钮！")
L.WHEEL.PLAY = T("开始\n抽奖")
L.WHEEL.REWARD = {
    T("中大奖了!"),
    T("恭喜您,抽中{1}的奖励。")
}
L.WHEEL.DESC_LIST = {
    T("每日转盘说明: "),
    T("1、每日最多可抽取3次"),
    T("2、首次转盘可直接抽取"),
    T("3、后续转盘每3分钟抽取1次"),
    "",
    T("当前状态:")
}
L.WHEEL.STATUS1 = T("可以抽奖")
L.WHEEL.STATUS2 = T("3次已抽完，请明日再来")

--银行
L.BANK.BANK_BUTTON_LABEL = T("银行")
L.BANK.BANK_DROP_LABEL = T("我的道具")
L.BANK.BANK_LABA_LABEL = T("喇叭")
L.BANK.BANK_TOTAL_CHIP_LABEL = T("银行内资产")
L.BANK.SAVE_BUTTON_LABEL = T("存钱")
L.BANK.DRAW_BUTTON_LABEL = T("取钱")
L.BANK.CANCEL_PASSWORD_SUCCESS_TOP_TIP = T("取消密码成功")
L.BANK.CANCEL_PASSWORD_FAIL_TOP_TIP = T("取消密码失败")
L.BANK.EMPYT_CHIP_NUMBER_TOP_TIP = T("请输入金额")
L.BANK.USE_BANK_NO_VIP_TOP_TIP = T("你不是VIP用户不能使用保险箱功能")
L.BANK.USE_BANK_SAVE_CHIP_SUCCESS_TOP_TIP = T("存钱成功")
L.BANK.USE_BANK_SAVE_CHIP_FAIL_TOP_TIP = T("存钱失败")
L.BANK.USE_BANK_DRAW_CHIP_SUCCESS_TOP_TIP = T("取钱成功")
L.BANK.USE_BANK_DRAW_CHIP_FAIL_TOP_TIP = T("取钱失败")
L.BANK.BANK_INPUT_TEXT_DEFAULT_LABEL = T("请输入密码")
L.BANK.BANK_CONFIRM_INPUT_TEXT_DEFAULT_LABEL = T("请再次输入密码")
L.BANK.BANK_INPUT_PASSWORD_ERROR = T("你输入的密码有误，请从新输入")
L.BANK.BANK_SET_PASSWORD_TOP_TITLE = T("设置密码")
L.BANK.BANK_SET_PASSWORD_SUCCESS_TOP_TIP = T("设置密码成功")
L.BANK.BANK_SET_PASSWORD_FAIL_TOP_TIP = T("设置密码失败")
L.BANK.BANK_LEVELS_DID_NOT_REACH = T("你的等级没有达到五级，不能使用保险箱")  -- บัญชีของคุณยังไม่ถึง Lv.5  ไม่สามารถใช้ธนาคารได้ค่ะ
L.BANK.BANK_CANCEL_OR_SETING_PASSWORD = T("取消或者设置密码")
L.BANK.BANK_FORGET_PASSWORD_FEEDBACK = T("忘记密码请向管理员反馈")
L.BANK.BANK_FORGET_PASSWORD_BUTTON_LABEL = T("忘记密码")
L.BANK.BANK_SETTING_PASSWORD_BUTTON_LABEL = T("设置密码")
L.BANK.BANK_CACEL_PASSWORD_BUTTON_LABEL = T("取消密码")
L.BANK.BANK_TOP_LIMIT_TIP = T("ฝากถอนได้มากสุดครั้งละ 2B  ชิป")--操作金币不能大于20亿
L.BANK.BANK_SQL_ERROR = T("ดำเนินการล้มเหลว กรุณาติดต่อศูนย์บริการลูกค้าค่ะ")--联系客服
L.BANK.BANK_CAN_NOT_USE_IN_ROOM = T("请不要在房间内使用保险箱")
L.BANK.BANK_LIMIT_NUM_TIP = T("您今天的存钱次数已到上限({1}/{2})")
L.BANK.BANK_SUB_TABBAR_TEXT = {
    T("筹码"), 
    T("现金币"),
}
L.BANK.BANK_NEED_PAY = T("现金币保险箱仅限付费用户使用")
--老虎机
L.SLOT.NOT_ENOUGH_MONEY = T("老虎机购买失败,你的筹码不足")
L.SLOT.NOT_ENOUGH_MONEY_IN_POKECT = T("您坐下后账户剩余筹码小于{1},无法下注！")  -- หลังนั่งลง ชิปของคุณมีน้อยกว่า {1} เดิมพันไม่ได้ค่ะ!
L.SLOT.NOT_ENOUGH_MONEY_IN_POKECT2= T("您坐下后账户剩余筹码太少，无法下注！")
L.SLOT.SYSTEM_ERROR = T("老虎机购买失败，系统出现错误")
L.SLOT.PLAY_WIN = T("你赢得了{1}筹码")
L.SLOT.TOP_PRIZE = T("玩家 {1} 玩老虎机抽中大奖，获得筹码{2}")
L.SLOT.FLASHBAR_TIP = T("头奖：{1}")
L.SLOT.FLASHBAR_WIN = T("你赢了：{1}")
L.SLOT.AUTO = T("自动")
L.SLOT.PLAY_LOSE = T("未中奖,再来一次吧")
--升级弹框
L.UPGRADE.OPEN = T("打开")
L.UPGRADE.SHARE = T("分享")
L.UPGRADE.GET_REWARD = T("获得{1}")
L.GIFT.SET_SELF_BUTTON_LABEL = T("设为我的礼物")
L.GIFT.BUY_TO_TABLE_GIFT_BUTTON_LABEL = T("买给牌桌x{1}")
L.GIFT.CURRENT_SELECT_GIFT_BUTTON_LABEL = T("你当前选择的礼物")
L.GIFT.PRESENT_GIFT_BUTTON_LABEL = T("赠送")
L.GIFT.DATA_LABEL = T("天")
L.GIFT.DATA_LABEL_NUM = T("颗")  -- เมล็ด
L.GIFT.SELECT_EMPTY_GIFT_TOP_TIP = T("请选择礼物")
L.GIFT.BUY_GIFT_SUCCESS_TOP_TIP = T("购买礼物成功")
L.GIFT.BUY_GIFT_FAIL_TOP_TIP = T("购买礼物失败")
L.GIFT.FAILD_NOTENOUGH_MONEY = T("筹码不足,购买失败")  -- ชิปมีไม่พอ ซื้อของขวัญล้มเหลว
L.GIFT.SET_GIFT_SUCCESS_TOP_TIP = T("设置礼物成功")
L.GIFT.SET_GIFT_FAIL_TOP_TIP = T("设置礼物失败")
L.GIFT.PRESENT_GIFT_SUCCESS_TOP_TIP = T("赠送礼物成功")
L.GIFT.PRESENT_GIFT_FAIL_TOP_TIP = T("赠送礼物失败")
L.GIFT.PRESENT_TABLE_GIFT_SUCCESS_TOP_TIP = T("赠送牌桌礼物成功")
L.GIFT.PRESENT_TABLE_GIFT_FAIL_TOP_TIP = T("赠送牌桌礼物失败")
L.GIFT.NO_GIFT_TIP = T("暂时没有礼物")
L.GIFT.MY_GIFT_MESSAGE_PROMPT_LABEL = T("点击选中既可在牌桌上展示才礼物")
L.GIFT.SUB_TAB_TEXT_SHOP_GIFT = {
    T("热销"), 
    T("新品"),  -- สินค้าใหม่
    T("节日"),
    T("其他")
}
L.GIFT.SUB_TAB_TEXT_MY_GIFT = {
    T("自己购买"), 
    T("牌友赠送"),
    T("特别赠送")
}

L.GIFT.MAIN_TAB_TEXT = {
    T("商城礼物"), 
    T("我的礼物")
}

-- 小喇叭 --
L.SUONA.SUONAUSE_TOPTIP = T("<<点击这里使用小喇叭")  -- <<กดส่งลำโพงทั่วเซิร์ฟ
L.SUONA.SAY = T(" 说:")  --  พูดว่า:
L.SUONA.TAB_TEXT = {
    T("广播"),  -- ลำโพง
    T("广播记录")  -- บันทึกลำโพง
}
L.SUONA.MAXMSGLENTH_TIP = T("请输入,限223字节以内")  -- กรุณากรอก จำกัดภายใน 223 ตัวอักษร
L.SUONA.USE_MAIN_TIPS = {
    T("1.每发送一条全服广播需消耗小喇叭*1"),  -- 1.ทุกครั้งที่ส่งลำโพง 1 ข้อความทั่วเซิร์ฟ ต้องจ่าย 10M ชิป
    T("2.每人每3分钟内只可发放一条全服广播"),  -- 2.ทุกๆ 3 นาทีสามารถส่งลำโพงทั่วเซิร์ฟได้ 1 ข้อความเท่านั้น/คน
    T("3.在线的人均可看到广播发言，大胆告白吧")  -- 3.ผู้เล่นที่ออนไลน์ทุกท่านสามารถมองเห็นข้อความจากลำโพงได้  อยากบอกอะไรก็เขียนเลย
}

L.SUONA.USE_TIP_BOTTOM = T("小喇叭在兑换商城兑换")  -- กรุณาใช้ลำโพงอย่างเหมาะสม และเขียนด้วยข้อความที่สุภาพเท่านั้น
L.SUONA.MSGREC_TIP_BOTTOM = T("仅显示最近50条喇叭记录")  -- จะแสดงเฉพาะ 50 ข้อความล่าสุดเท่านั้น
L.SUONA.EMPTY_MSG_TIP = T("小喇叭内容不能为空！")  -- กรุณากรอกข้อความในลำโพงค่ะ!
L.SUONA.TOLONG_MSG_TIP = T("您发送的内容过长,请重新编辑！")  -- ข้อความยาวเกินไปค่ะ กรุณากรอกใหม่อีกครั้งค่ะ!
L.SUONA.NOTENOUGH_MONEY_TOSEND_TIP = T("您的筹码不足,有钱更能博得意中人的欢心哦!")  -- ชิปของคุณมีไม่พอค่ะ ชิปยิ่งเยอะ ยิ่งได้หัวใจจากคนที่รักนะ
L.SUONA.WAITFOR_MONEY_UPDATE_TIP = T("加载中，请稍后！")  -- กำลังโหลดอยู่ กรุณารอสักครู่ค่ะ
L.SUONA.SENDFREQ_TOOHIGH_TIP = T("您刚刚发过言啦,休息一会再来吧！")  -- คุณส่งข้อความแล้วเมื่อสักครู่ กรุณาพักก่อนแล้วค่อยส่งใหม่ค่ะ!
L.SUONA.BADNETWORK_TIP = T("网络异常发送失败，请重试")  -- เน็ตผิดปกติ ส่งข้อความล้มเหลว กรุณาลองใหม่อีกครั้งค่ะ

-- 农场 -- 
L.DORNUCOPIA.FARM = T("农场") -- ฟาร์ม
L.DORNUCOPIA.MAIN_TAB_TEXT = {
    T("我的聚宝盆"),--ฟาร์มชิปของฉัน
    T("好友聚宝盆"),--ฟาร์มชิปของเพื่อน
    T("收获记录"),--บันทึกเก็บเกี่ยว
    T("农场说明")
}

L.DORNUCOPIA.GUEST_CANT_ACCESS_TIP = T("请先登陆FB帐户，种植元宝种子可获得海量筹码")  -- กรุณาล็อกอินบัญชี FB ปลูกเมล็ดพันธ์จะได้รับชิปฟรีมหาศาล
L.DORNUCOPIA.LEVEL_CANT_ACCESS_TIP = T("等级满3级才能玩筹码农场哦")
L.DORNUCOPIA.BUTTOM_TIPS = T("收获好友的成熟元宝是获得元宝种子的主要方式")--เก็บเกี่ยวผลิตผลของเพื่อน เป็นวิธีหลักในการสะสมเมล็ดพันธุ์
L.DORNUCOPIA.SHARE_SEED = T("分享得种子")--แชร์รับฟรีเมล็ดพันธุ
L.DORNUCOPIA.CHECK_INFO = T("点击查看聚宝盆说明")--กดดูคำอธิบาย
L.DORNUCOPIA.INFOMATION = {
    T("聚宝盆说明:"),--คำอธิบาย: 
    T("1、每日首次登录即可获得银元宝种子1颗"),--1.ล็อกอินบัญชีครั้งแรกของวันรับฟรีเมล็ดเงิน 1 เมล็ด
    T("2、每日首次分享即可获得银元宝种子1颗"),--2.แชร์ฟาร์มชิปหรือของหายากในฟาร์มครั้งแรกของวันสำเร็จ รับฟรีเมล็ดเงิน 1 เมล็ด
    T("3、收获好友成熟元宝时，有较高几率获得元宝种子"),--3.เวลาเก็บเกี่ยวผลิตผลของเพื่อน มีโอกาสสูงที่จะได้รับเมล็ดพันธุ์
    T("4、元宝种子种植于聚宝盆中，成熟后可获得大量筹码"),--4.เมล็ดพันธุ์จะปลูกในฟาร์มชิป หลังสุกจะได้รับชิปฟรีเพียบ
    T("5、加速药剂可加快种子成熟时间"),--5.ปุ๋ยเพิ่มความเร็วสามารถย่นระยะเวลาสุกของเมล็ดพันธุ์ได้
    T("6、收获自己的成熟元宝时，有几率获得加速药剂"),--6.หลังเก็บเกี่ยวผลิตผลของตัวเอง มีโอกาสสูงที่จะได้รับปุ๋ยเพิ่มความเร็ว
    T("7、游客不可参与种植，请先登录FB帐户")--7.บัญชีนักเที่ยวไม่สามารถปลูกเมล็ดพันธุ์ได้ กรุณาล็อกอินบัญชี FB
}
L.DORNUCOPIA.GETED_REWARD = T("成熟奖励: ${1}")--ผลิตผลที่ได้
L.DORNUCOPIA.NEED_TIME = T("成长时间: {1} Min")--เวลาเก็บ
L.DORNUCOPIA.LEFT_NUM = T("剩余数量: {1}")--เหลือ
L.DORNUCOPIA.ADDSPEEDTIME = T("缩减种子20Min成熟时间")--ย่นระยะเวลาสุก 20 นาที
L.DORNUCOPIA.MY_SEED_WORDS = T("我的元宝种子")--เมล็ดพันธุ์ของฉัน
L.DORNUCOPIA.SELECT_SEED_TITLE  = T("请选择种植对象")--กรุณากดเลือกเมล็ดพันธุ์
L.DORNUCOPIA.GETEDREWARD_TITLE  = T("种植小能手")--นักปลูกมือโปร
L.DORNUCOPIA.LOGINFB_TITLE      =T("请先登录")--กรุณาล็อกอินก่อน
L.DORNUCOPIA.GETREWARD_TXT2 = T("恭喜您额外收获了稀有道具【银元宝种子】，种植于【聚宝盆】可收获丰富筹码，快把这个好消息告诉你的朋友吧！")
--ยินดีด้วยค่ะ คุณขุดเจอ [เมล็ดเงิน] ของหายากนี้สามารถปลูกได้ที่ฟาร์ม คุณจะได้รับรางวัลชิปฟรีไม่อั้น รีบไปบอกข่าวกับเพื่อนๆของคุณกันเถอะ!
L.DORNUCOPIA.GETREWARD_TXT1 = T("恭喜您额外收获了稀有道具【金元宝种子】，种植于【聚宝盆】可收获海量筹码，快把这个好消息告诉你的朋友吧！")
--ยินดีด้วยค่ะ คุณขุดเจอ [เมล็ดทอง] ของหายากนี้สามารถปลูกได้ที่ฟาร์ม คุณจะได้รับรางวัลชิปฟรีไม่อั้น รีบไปบอกข่าวกับเพื่อนๆของคุณกันเถอะ!
L.DORNUCOPIA.GETREWARD_TXT3 = T("恭喜您额外收获了稀有道具【加速化肥】，使用即可缩减【元宝种子】收获时间，快把这个好消息告诉你的朋友吧！")
--ยินดีด้วยค่ะ คุณขุดเจอ [ปุ๋ยเพิ่มความเร็ว] ของหายากนี้สามารถย่นระยะเวลาสุกของเมล็ดพันธุ์ที่ปลูกได้ รีบไปบอกข่าวกับเพื่อนๆของคุณกันเถอะ!
L.DORNUCOPIA.GETEDREWARD_BUTTOM_TIP = T("每日首次分享可获得银元宝种子1颗")
--แชร์ฟาร์มชิปหรือของหายากในฟาร์มครั้งแรกของวันสำเร็จ รับฟรีเมล็ดเงิน 1 เมล็ด
L.DORNUCOPIA.PLEASE_LOGIN_TIP = T("Sorry，游客不可参与种植，请先登录FB帐户！")
--ขอโทษค่ะ บัญชีนักเที่ยวไม่สามารถปลูกเมล็ดพันธุ์ได้ กรุณาล็อกอินบัญชี FB!
L.DORNUCOPIA.QUICK_LOGIN = T("立即登录")
--ล็อกอินทันที
L.DORNUCOPIA.LOGIN_TIPS=T("登录FB，享受更多优惠，体验更完善")
--ล็อกอินบัญชี FB รับสิทธิพิเศษมากมาย มันส์กันได้แบบฟินๆ
L.DORNUCOPIA.GORW_TERR = T("种植")
--ปลูก
L.DORNUCOPIA.ADD_SPEED = T("加速")
--เพิ่มความเร็ว
L.DORNUCOPIA.GET_TREE = T("收获")
--เก็บ
L.DORNUCOPIA.OPEN_LOCK = T("解锁")
--ปลดล็อค
L.DORNUCOPIA.OPENLOCK_CONDITION = T("LV.{1}解锁")
--LV.{} ปลดล็อค
L.DORNUCOPIA.OPENLOCK_MONEY = T("解锁费用")
--ค่าปลดล็อค
L.DORNUCOPIA.WAIT_OPEN_LOCK = T("待解锁")
--รอปลดล็อค
L.DORNUCOPIA.NO_OPEN_LOCK = T("未解锁")
--ยังไม่ปลดล็อค
L.DORNUCOPIA.OPEN_LOCK_SUCC = T("成功解锁")
--ปลดล็อคสำเร็จ
L.DORNUCOPIA.GORW_TERR_SUCC = T("种植成功")
--ปลูกสำเร็จ
L.DORNUCOPIA.ADD_SPEED_SUCC = T("加速成功")
--เพิ่มความเร็วสำเร็จ
L.DORNUCOPIA.GETED_COR_MONEY = T("收获了 {1} 筹码")
--เก็บได้ {1} ชิป
L.DORNUCOPIA.GETED_FRIEND_MONEY = T("偷到了好友 {1} 筹码")
--ขโมยเพื่อนได้ {1} ชิป
L.DORNUCOPIA.GETED_FIRNED_FIAL = T("您已经收过了，快提醒好友收获吧")
--คุณเก็บผลิตผลไปแล้ว รีบบอกเพื่อนให้มาเก็บผลิตผลของเขากันเถอะ
L.DORNUCOPIA.GET_FRIEND_COR = T("偷他的")
--ขโมย
L.DORNUCOPIA.GORW_ING = T("成长中")
--กำลังเติบโต
L.DORNUCOPIA.NOT_GROW = T("未种植")
--ยังไม่ได้ปลูก
L.DORNUCOPIA.OPEN_LOCK_FIAL = T("请先解锁前面的筹码农场")
--กรุณาปลดล็อคด้านหน้าก่อน
L.DORNUCOPIA.NOT_SEED = T("种子不足")
--เมล็ดพันธุ์ไม่พอค่ะ
L.DORNUCOPIA.NOT_SPEED_WATER = T("加速药水不足")
--ปุ๋ยเพิ่มความเร็วไม่พอค่ะ
L.DORNUCOPIA.GETED_SILVER = T("获得1颗银种子")
--ได้รับเมล็ดตำลึงเงิน 1 เมล็ด
L.DORNUCOPIA.GETED_FIRNED_FIAL2 = T("不能再偷了，再偷就没了")


L.DORNUCOPIA.DATE = T("日期")   --วันที่
L.DORNUCOPIA.TIME = T("时间")   --เวลา
L.DORNUCOPIA.SEED = T("种子")   --เมล็ดพันธุ์
L.DORNUCOPIA.REAPER = T("收获人")  -- ผู้เก็บเกี่ยว
L.DORNUCOPIA.CORNUM = T("数量")--ได
L.DORNUCOPIA.HIES_FARM = T("聚宝盆")  --ฟาร์มของเขา
L.DORNUCOPIA.GOLD_SEED = T("金元宝种子")  --เมล็ดทอง
L.DORNUCOPIA.SILVER_SEED = T("银元宝种子")  --เมล็ดเงิน
L.DORNUCOPIA.QUICK_POTION = T("加速药水")

L.DORNUCOPIA.GET_FRIEND_SEED_FAIL = T("偷取失败，请刷新后重试")

L.DORNUCOPIA.EXPLAIN_INFO = {
    T("> 筹码农场的作用"),
    T("可以种植元宝种子，成熟后可收获大量筹码"),
    T("> 农场道具说明"),
    T("> 其他规则"),
    T("1、FB用户满3级即可解锁筹码农场"),
    T("2、解锁后每日首次登录即可获得1颗银种子"),
    T("3、偷去好友的成熟种子是获得元宝种子的主要方式，好友越多方可赚取更多筹码"),
    T("4、离线时种植金种子，下次登录可直接获得可观的筹码"),
    T("5、合理安排种植和收获时间，可最大额度获得筹码奖励"),
    T("道具名称"),
    T("道具说明"),
    T("获得方法"),
    T("种植于筹码农场，成熟后最高可获得50000筹码"),
    T("种植于筹码农场，成熟后最高可获得20000筹码"),
    T("可缩减当前种子20分钟的成熟时间"),
    T("偷取好友的种子有较高的几率获得"),
    T("偷取好友的种子有一定的几率获得"),
    T("收获种子有一定几率获得")
}
L.DORNUCOPIA.HOMEPAGE = {
    T("农场公告"),
    T("好友留言")
}
L.DORNUCOPIA.RECORD_MESSAGE = {
    T("{1}收获了银种子，获得了{2}筹码"),
    T("{1}收获了金种子，获得了{2}筹码"),
    T("{1}偷取了好友{2}的银种子，获得了{3}筹码"),
    T("{1}偷取了好友{2}的金种子，获得了{3}筹码"),
    T("{1}好友{2}偷取了我的银种子，失去了{3}筹码"),
    T("{1}好友{2}偷取了我的金种子，失去了{3}筹码")
}
L.DORNUCOPIA.OPEN_LOCK_TIPS = T("解锁需要消耗{1}筹码，确定解锁码?")
L.DORNUCOPIA.HINT_FRIEND = {
    T("提醒好友成功"),
    T("该农场暂未解锁或者已经种植了种子"),
    T("今天该地已经提醒过了")
}
L.DORNUCOPIA.HALL_TIPS = T("您获得一个可银种子，参与种植即可收获海量筹码，快去试试吧！")
L.BOXACT.MY_COIN = T("ชิปของฉัน:")--ชิปของฉัน: 我的筹码
L.BOXACT.ACT_TIME = T("ระยะเวลากิจกรรม:")--活动时间
L.BOXACT.RECORD = T("บันทึกรางวัล")--获奖记录
L.BOXACT.NOT_ENOUGH_MONEY = T("ขออภัยค่ะ ชิปของคุณมีไม่พอ ไม่สามารถร่วมกิจกรรมได้ กรุณาไปสะสมชิปก่อนแล้วค่อยมาเล่นใหม่ค่ะ")--不好意思，您的筹码不足，无法参加本次宝箱活动，请储值后再来吧！
L.BOXACT.TEN_REWARD = T("รายการรางวัล")--获奖名单
L.BOXACT.TAB_TEXT = {
    T("เวลา"),--时间
    T("รางวัล")--奖励
}
-- 牌局回顾 -- 
L.CGAMEREVIEW.NO_GAME_DATA = T("暂无牌局数据")  -- ไม่มีบันทึกข้อมูลไพ่

-- 破产
L.CRASH.PROMPT_LABEL = T("您获得{1}筹码的破产救济金，同时还获得当日充值优惠一次，立即充值，重振雄风！")
L.CRASH.THIRD_TIME_LABEL = T("您获得最后一次{1}筹码的破产救济金，同时还获得当日充值优惠一次，立即满血复活，再战江湖！")
L.CRASH.OTHER_TIME_LABEL = T("您已经领完所有破产救济金了，您可以去商城购买筹码，每天登录还有免费筹码赠送哦！")
L.CRASH.TITLE = T("你破产了！") 
L.CRASH.CHIPS_TIPS = T("破产救济")

L.CRASH.CHIPS = T("{1}游戏币")
L.CRASH.CHIPS_INFO = T("({1}天内仅限{2}次)")
L.CRASH.INVITE = T("FB邀请")
L.CRASH.INVITE_INFO = T("(邀请1个新朋友并成功进游戏)")
L.CRASH.RECALL = T("FB招回")
L.CRASH.RECALL_INFO = T("(成功召回1个老用户回归游戏)")
L.CRASH.GET = T("领取")
-- L.CRASH.PRODUCT = T("{1}游戏币\n{2}THB")
L.CRASH.PRODUCT = T("{1}\n{2}")
L.CRASH.GET_REWARD = T("获得{1}游戏币")
L.CRASH.E2P_TIP = T("仅限E2P")
L.CRASH.BLUEPAY_TIP = T("仅限BluePay")

L.CRASH.LOSE_ALL = T("输光啦!!")
L.CRASH.GET_BANK_MONEY = T("取点钱出来快速翻本!")
L.CRASH.OPEN_BANK = T("保险箱")


L.POKDENG_AD.REWARD_SUCC = T("领取奖励成功，获得{1}游戏币")
L.POKDENG_AD.REWARD_EVER = T("已领取过奖励")
L.POKDENG_AD.REWARD_FAIL = T("领取失败")

-- 支付引导 & 进入房间提示
L.CPURCHGUIDE.ROOM_CHIPS_NEED_RANGE = T("当前底注的房间 ({1}底注) 仅适合筹码范围{2}~{3}的玩家。")  -- ห้องเดิมพัน ({1}) ที่ท่านเลือก สำหรับผู้เล่นที่มีชิป {2}~{3}
L.CPURCHGUIDE.ROOM_CHIPS_NEED_RANGE2 = T("当前底注的房间 ({1}底注) 仅适合筹码大于{2}的玩家。")
L.CPURCHGUIDE.PRAISE_AND_GUIDE = T("您是高手中的高手,请移步至高级别房间游戏。")  -- ฝีมือท่านสุดยอดเลย กรุณาไปห้องระดับสูงกว่า 

L.CPURCHGUIDE.BLESSES = T("祝您游戏愉快:)")  -- ขอให้มีความสุขนะจ๊ะ
L.CPURCHGUIDE.GO_NOW = T("现在就去 >>")  -- เล่นตอนนี้ >>

-- L.CPURCHGUIDE.PAY_TIPS = T("注:储值成功后加送筹码自动发放到账户,仅限BluePay支付方式")  -- คำเตือน:หลังเติมเงินสำเร็จชิปที่เพิ่มให้ 500%% จะส่งเข้าบัญชีอัตโนมัติ จำกัดเฉพาะช่องทาง BluePay เท่านั้น
L.CPURCHGUIDE.CHARGE = T("充值")  -- เติม
L.CPURCHGUIDE.FIRST_CHARGE_FAVFIVE_TIMES = T("首次送500%%") -- ครั้งแรก ฟรี 500%%
L.CPURCHGUIDE.CHARGE_NOW_FAVFIVE_TIMES = T("现充值BluePay享受500%%特惠")  -- เติม BluePay ครั้งแรก ฟรี 500%%
L.CPURCHGUIDE.FAV_ONLY_ONCE = T("优惠仅限一次哦!")  -- โอกาสมีเพียง 1 ครั้งเท่านั้นนะ!
L.CPURCHGUIDE.CHIPS_NOT_ENOUGH = T("Sorry筹码不足以入场！")  -- ขอโทษค่ะ ชิปมีไม่พอเข้าห้อง!
L.CPURCHGUIDE.BANKRUPT_TIP = T("Sorry您破产啦！")  -- ขอโทษค่ะ คนล้มละลายแล้ว!
L.CPURCHGUIDE.GET_CHARGE = T("获取")  -- ซื้อทันที
L.CPURCHGUIDE.CHARGE_ANY_FIRST = T("首次充值任意订单")  -- ครั้งแรก ไม่ว่าเท่าใดก็ได้
L.CPURCHGUIDE.ALWAYS_GET_FIVE_TIMES_REWARD = T("均可获得500%%加送优惠")  -- รับชิปฟรีเพิ่ม 500%%
L.CPURCHGUIDE.QUICK_CHARGE_FOR_PERFER = T("快捷储值,面值越高越优惠")  -- เติมชิปแบบเร็ว เติมยิ่งเยอะยิ่งคุ้ม

L.CPURCHGUIDE.CHARGE_FIRST_ANYBILL_FOR_DOUBLE_REWARD = T("首次储值任意订单,均可获得100%%的充值加送,额度越高越划算!")  -- ไม่ว่าซื้อจำนวนเท่าใดก็ได้ครั้งแรก รับฟรีเพิ่มอีก 100%% ยิ่งเติมเยอะ ยิ่งคุ้ม！
L.CPURCHGUIDE.CHARGE_FIRST_ONLY_DOUBLE_REWARD = T("首充优惠100%% 仅限一次哦！")  -- เติมเงินครั้งแรกแถม 100%% จำกัดครั้งเดียวเท่านั้น!
L.CPURCHGUIDE.CHIP_NOT_ENOUGH_FOR_DOUBLE_REWARD = T("筹码不足入场,现在储值劲享100%%加送优惠！")  -- ชิปไม่พอเข้าห้อง เติมชิปแถมฟรีอีก 100%%!
L.CPURCHGUIDE.BANKRUPT_FOR_DOUBLE_REWARD = T("您破产啦,现在储值劲享100%%加送优惠！")  -- คุณล้มละลายแล้ว เติมชิปแถมฟรีอีก 100%%!

L.CPURCHGUIDE.OTHER_PAY_BILL = T("其它订单 >>")  -- สินค้าอื่นๆ >>

L.CPURCHGUIDE.CHIPS_NUM = T("{1}筹码")  -- {1}ชิป
L.CPURCHGUIDE.CHIP_AVG = T("1THB = {1}筹码")  -- 1THB = {1}ชิป
L.CPURCHGUIDE.MORE_PAY_WAYS = T("更多支付方式")  -- ช่องทางเติมเงินอื่นๆ

L.CPURCHGUIDE.CASHCOIN_QUANT = T("现金币")
L.CPURCHGUIDE.MTACH_TICKET_USETIP = T("报名参赛>夺取实物券>兑换实物奖励")  -- ลงชื่อร่วมแข่ง>แย่งคูปอง>แลกรางวัลจริง
L.CPURCHGUIDE.USE_MATCH_TICKET_REG_PREF = T("现金币是游戏里的重要通用货币")  -- ชิปเงินสดเป็นเงินสกุลสำคัญที่สุดในเกมส์
L.CPURCHGUIDE.FIRCHRG_REWARDS = {
    T("轻松获得 {1}筹码"),  -- {1} ชิป รับได้ง่ายๆ
    T("{1} 现金币，玩转现金币场")  -- ชิปเงินสด {1} บาท มันส์ระทึกใจที่ห้องชิปเงินสด
}

L.CPURCHGUIDE.GETREWARD_BYPRICE = T("{1}฿立即抢")  -- แย่งซื้อ {1} บาททันที
L.CPURCHGUIDE.RECHGALM_CANTACCESS = T("本礼包还没到购买时间,请在指定时间内购买！")  -- แพ็คเกจนี้ยังไม่ถึงเวลาซื้อ กรุณาซื้อตามเวลาที่กำหมดค่ะ

-- SignIn Translations --
L.CSIGNIN.V_USER_TIPS = T("您是Vip用户,可享受[Vip*2]双倍奖励")  -- Vip มีสิทธิ์รับรางวัล X2
L.CSIGNIN.UNV_USER_TIPS = T("储值任意订单即可成为Vip用户")  -- เติมเงินไม่จำกัดจำนวน รับสิทธิ์ Vip
L.CSIGNIN.ACCUM_SIGNIN_REWARD = T("累计签到礼包")  -- รางวัลลงชื่อสะสม
L.CSIGNIN.DAYS_NEED_TO_GET_REWARD = T("还差{1}天领取") -- อีก {1} วันถึงรับได้
L.CSIGNIN.CANT_GET_ACCUM_REWARD = T("累计天数不足,不能领奖")  -- จำนวนวันไม่พอ ไม่สามารถรับรางวัลได้ค่ะ
L.CSIGNIN.SUCC_GET_ACCUM_REWARD = T("成功领取{1}日累计签到礼包")  -- รับรางวัลลงชื่อสะสมครบ {1} วันสำเร็จ
L.CSIGNIN.FAILD_TO_SIGNIN = T("签到失败,请重试")  -- ลงชื่อล้มเหลว กรุณาลองใหม่อีกครั้ง
L.CSIGNIN.SUCC_SIGNIN_AND_GET = T("签到成功,获得")  -- ลงชื่อสำเร็จ ได้รับ
L.CSIGNIN.ACCUM_REWARD_TIPS = {
    T("1.储值任意订单即为Vip用户"),  -- 1.เติมเงินไม่จำกัดจำนวน รับสิทธิ์ VIP
    T("2.成为Vip用户,可享[Vip*2]双倍奖励"),  -- 2.VIP มีสิทธิ์รับรางวัล X2
    T("3.累计签到天数可领取累计签到礼包")  -- 3.วันลงชื่อครบตามจำนวนที่กำหนด ก็รับรางวัลไปเลย
}

-- L.CSIGNIN.ACCUM_REWARD_TIPS1 = T("1.储值任意订单即为Vip用户")  -- 1.เติมเงินไม่จำกัดจำนวน รับสิทธิ์ VIP
-- L.CSIGNIN.ACCUM_REWARD_TIPS2 = T("2.成为Vip用户,可享[Vip*2]双倍奖励")  -- 2.VIP มีสิทธิ์รับรางวัล X2
-- L.CSIGNIN.ACCUM_REWARD_TIPS3 = T("3.累计签到天数可领取累计签到礼包")  -- 3.วันลงชื่อครบตามจำนวนที่กำหนด ก็รับรางวัลไปเลย
L.CSIGNIN.ACCUM_SIGNIN_DAYS = T("累计天数")  -- วันลงชื่อสะสม
L.CSIGNIN.REWARD_CONTENT = T("奖励内容")  -- รางวัล
L.CSIGNIN.CHIPNUM_SLIVERSEEDNUM_GOLDSEEDNUM = T("{1} 筹码 + 银元宝种子 * {2} + 金元宝种子 * {3}")  -- {1} ชิป + เมล็ดตำลึงเงิน * {2} + เมล็ดตำลึงทอง * {3}
L.CSIGNIN.GET_ALL_ACCUMREWARD = T("已领完所有奖励")  -- รับรางวัลทั้งหมดแล้ว

L.CSIGNIN.SIGNIN_MAIN_TITLE = T("每日签到领奖，越签奖励越高")  -- ลงชื่อรับรางวัลทุกวัน ยิ่งทำต่อเนื่อง รางวัลยิ่งเยอะ!
L.CSIGNIN.SIGNIN_MAIN_TIPS_BOTOOM = T("每月签到第7天，送绝版专属礼物")  -- ทุกเดือนลงชื่อถึงครั้งที่ 7 หรือลงชื่อครบทั้งหมด จะได้รับของขวัญพิเศษ
L.CSIGNIN.REWARD_DESC_TIPS = {
    T("1.签到依次顺序领奖，每月1号0点重置签到次数;"),  -- 1.ลงชื่อรับรางวัลตามลำดับ   ระบบจะเซ็ตจำนวนวันลงชื่อเป็น 0 ทุกเดือนในวันที่ 1 เวลา 00:00 น.
    T("2.越往后签，奖励越高;"),  -- 2.ยิ่งลงชื่อต่อเนื่อง รางวัลยิ่งใหญ่.
    T("3.每月第7次签到或满签即可获得绝版签到礼物;")  -- 3.ทุกเดือนลงชื่อถึงครั้งที่ 7 หรือลงชื่อครบทั้งหมด จะได้รับของขวัญพิเศษ.
}
-- L.CSIGNIN.SIGNIN_SUCC_GET = T("签到成功,获得") -- ลงชื่อสำเร็จ ได้รับ
L.CSIGNIN.OP = T("绝版") -- พิเศษ
L.CSIGNIN.SIGNIN_GIFT = T("礼物")   -- ของขวัญ
L.CSIGNIN.SIGNIN_GIFT_SPEC = T("专属礼物") -- เทพธิดาลัคกี้
L.CSIGNIN.GIFT_CROWN = T("皇冠")  -- มงกุฎ
L.CSIGNIN.GIFT_WEALTH = T("财神爷")  -- ไฉ่ซิ่งเอี๊ย
-- L.CSIGNIN.SIGNIN_QUANTIF = {
--     T(""),
--     T(""),
--     T("")
-- }

-- NEWSTACT Center! --
L.NEWSTACT.DOUBLE_CLICK_EXIT = T("再次点击退出活动中心！")  -- กดอีกครั้งเพื่อออกศูนย์กิจกรรม

-- CUNIONACT --
L.CUNIONACT.GET_REWARD_FAILED = T("领取失败,请重试！")  -- รับรางวัลล้มเหลว กรุณาลองใหม่อีกครั้ง!
L.CUNIONACT.TASK_ONGOING = T("进行中")  -- กำลังทำ
L.CUNIONACT.INSTALL_GAME_TIPS = T("下载并安装三公[{1}]")  -- โหลดและติดตั้ง เกมส์เก้าเกไทย [{1}]
L.CUNIONACT.GAME_PLAYROUND_TIPS = T("在三公中玩30局牌[{1}]")  -- เล่นเกมส์ เก้าเกไทย 30 รอบ [{1}]
L.CUNIONACT.GAME_INVITE_TIPS = T("在三公中成功邀请两位好友[{1}]")  -- เชิญเพื่อนใน เกมส์เก้าเกไทย สำเร็จ 2 ท่าน [{1}]
L.CUNIONACT.GAME_DOWNLOAD_GOOGLEPLAY_HINT = T("下载三公")  -- โหลดเกมส์เก้าเกไทย
L.CUNIONACT.GAME_ENTER_HINT = T("进入三公")  -- เข้าเกมส์
L.CUNIONACT.GET_IMMEDIATELY = T("立即领取")  -- รับทันที
L.CUNIONACT.HAS_DOWNLOAD = T("已下载")  -- โหลดแล้ว
L.CUNIONACT.GAME_GO_DOWNLOAD = T("立即下载")  -- โหลดทันที
L.CUNIONACT.UNIONACT_HELP = T("三公 搏定 联合送礼活动说明")  -- คำอธิบาย
L.CUNIONACT.REWARD_GET_TIPS = {
    T("1.在搏定中,完成[下载+玩牌+邀请]三公游戏即可完成活动目标、获得奖励"),  -- 1.[โหลดเกมส์+เล่นไพ่+เชิญเพื่อนเกมส์เก้าเกไทย] ในเกมส์ไพ่ป๊อกเด้ง สำเร็จภารกิจ รับฟรีรางวัล！
    T("2.活动目标1,2,3需逐次完成"),  -- 2.ภารกิจ 1,2 และ 3 จะต้องทำทีละขั้นตอนจนครบ
    T("3.每完成一个目标即可领取奖励，全部完成即可领取稀有专属礼物，具体奖励设定如下:")  -- 3. สำเร็จภารกิจทุกครั้ง สามารถรับรางวัลฟรี หากสำเร็จทุกภารกิจ รับไปเลยของขวัญหายาก “ไพ่เก้าเกทองคำ” รายละเอียดรางวัลมีดังนี้ :
}
L.CUNIONACT.GOALS = T("目标")  -- ภารกิจ
L.CUNIONACT.REWARD = T("奖励")  -- รางวัล
L.CUNIONACT.GOALS_NEED = {
    T("下载"), --  โหลดเกมส์และติดตั้งเก้าเกไทย
    T("玩牌30局"),  -- เล่นไพ่ 30 รอบ
    T("邀请2好友"),  -- เชิญเพื่อน 2 คน
    T("全部完成")  -- สำเร็จทั้งหมด
}
L.CUNIONACT.REWARDS_DETAIL = {
    T("60K筹码+30次互动道具"),  -- 60K ชิป+ไอเทม 30 ครั้ง
    T("80K筹码+20颗银元宝"),  -- 80K ชิป+เมล็ดตำลึงเงิน 20 เมล็ด
    T("120K筹码+10颗金元宝"),  -- 120K ชิป+เมล็ดตำลึงทอง 10 เมล็ด
    T("200K筹码+专属礼物")  -- 200K ชิป+ไพ่เก้าเกทองคำ
}
L.CUNIONACT.GET_REWARD_SUCC_TIPS = {
    T("领奖成功,您获得60K筹码+30次道具"),  -- รับรางวัลสำเร็จ คุณได้รับ 60K ชิป+ไอเทม 30 ครั้ง
    T("领奖成功,您获得80K筹码+银元宝20个"),  -- รับรางวัลสำเร็จ คุณได้รับ 80K ชิป+เมล็ดตำลึงเงิน 20 เมล็ด
    T("领奖成功,您获得120K筹码+金元宝10个")  -- รับรางวัลสำเร็จ คุณได้รับ 120K ชิป+เมล็ดตำลึงทอง 10 เมล็ด
}

L.CUNIONACT.SHARE_DESC = T("恭喜您成功获得了终极礼包 200K筹码+稀有三公专属礼物！")  -- ยินดีด้วยค่ะ คุณสำเร็จภารกิจได้รับ รางวัลใหญ่ 200K ชิป+ไพ่ทองคำเก้าเกไทย!

L.ROOM.WAIT_FOR_GAME = T("等待其他玩家进入私人房")
L.SCOREMARKET = {}
-- 积分兑换奖励
L.SCOREMARKET.TAB1 = T("兑换奖品")
L.SCOREMARKET.TAB2 = T("兑换记录")
L.SCOREMARKET.SUBTAB1 = T("游戏礼包")
L.SCOREMARKET.SUBTAB2 =T("现金卡")
L.SCOREMARKET.SUBTAB3 = T("Line Coins")
L.SCOREMARKET.SUBTAB4 = T("实物")
L.SCOREMARKET.SUBTAB5 = T("幸运大转盘")
L.SCOREMARKET.SUBTAB6 = T("礼品")
L.SCOREMARKET.SUBTAB7 = T("情人节专柜") -- รางวัลสื่อรัก -- 情人节专柜
L.SCOREMARKET.COPY = T("复制")
L.SCOREMARKET.COPY_SUCCESS = T("复制成功！")

L.SCOREMARKET.MYSCORE = T("我的现金币:")

L.SCOREMARKET.COMMINGTIPS = T("尊敬的用户，测试期间Line Coins与现金卡的兑换暂未开放，您可积累积分，待比赛场正式上线时参与兑换")
L.SCOREMARKET.NORECORD = T("暂无兑奖记录...")
L.SCOREMARKET.LEFTWORD = T("剩余数量：{1}")
L.SCOREMARKET.NOLEFT = T("已经抢光")
L.SCOREMARKET.GOODSFULL = T("奖品充足")
L.SCOREMARKET.RECHANGENUM = T("{1} 现金币")
L.SCOREMARKET.RECHANGE_CHIP = T("{1} 筹码")
L.SCOREMARKET.RECHANGE_TICKET = T("{1} 兑换券")
L.SCOREMARKET.NOTENOUGHTIPS = T("对不起，您的现金币不足")
L.SCOREMARKET.RECHANGECONFIRM = T("您确认要使用{1}现金币兑换{2}")
L.SCOREMARKET.JOIN_LUCKTURN = T("我要參加")
L.SCOREMARKET.RECEIVE_ADDRESS = T("收货地址")
L.SCOREMARKET.RECEIVE_INFOS = T("收货信息")
L.SCOREMARKET.SAVE_ADDRESS = T("保存")
L.SCOREMARKET.USER_NAME = T("你的姓名")
L.SCOREMARKET.USER_SEX = T("您的性别")
L.SCOREMARKET.MOBEL_TEL = T("手机号码")
L.SCOREMARKET.DETAIL_ADDRESS = T("详细地址")
L.SCOREMARKET.EMAIL = T("电子邮箱")
L.SCOREMARKET.FEMALE = T("女士")
L.SCOREMARKET.MAN = T("男士")
L.SCOREMARKET.SAVEADDRESS_FAIL = T("保存收货地址失败")
L.SCOREMARKET.SAVEADDRESS_SUCCESS = T("保存收货地址成功")

L.SCOREMARKET.CONSUME_SCORE = T("您将花费 {1} 积分兑换")
L.SCOREMARKET.CONFIRM_ADDRESS_TIP = T("请确认收货信息，确保无误！")
L.SCOREMARKET.CONFIRM_EXCHANGE = T("确认兑换")
L.SCOREMARKET.EXCHANGE = T("兑换")
L.SCOREMARKET.MODIFY_INFO = T("修改信息>>")
L.SCOREMARKET.EXCHANGE_CONDITION = T("兑换条件")
L.SCOREMARKET.EXCHANGE_CONDITION_DESC = T("消耗 {1} 现金币可获得")
L.SCOREMARKET.EXCHANGE_CONDITION_DESC_2 = T("消耗 {1} 兑换券可获得")
L.SCOREMARKET.EXCHANGE_CONDITION_DESC_3 = T("消耗 {1} 金币可获得")
L.SCOREMARKET.EXCHANGE_LEFT_CNT = T("剩余数量:{1}")
L.SCOREMARKET.NOTENOUGH_SCORE = T("您的现金币不足，快去参加比赛赢取现金币吧")
L.SCOREMARKET.NOTENOUGH_SCORE_2 = T("您的兑换券不足，快去参加比赛赢取兑换券吧")
L.SCOREMARKET.NOTENOUGH_SCORE_3 = T("您的筹码不足，快去赢取筹码吧")
L.SCOREMARKET.NOTENOUGH_GOODS = T("已被抢完，我们会尽快添加库存！")
L.SCOREMARKET.EXCHANGE_TICKET = T("实物兑换券 x {1}")
L.SCOREMARKET.NOTENOUGH_LEFT_CNT = T("已被抢光")
L.SCOREMARKET.EXCHANGE_SUCCESS_DESC = T("恭喜您 {1} 兑换成功，我们的客服将于3个工作日内与您联系，请你保持手机畅通")
L.SCOREMARKET.EXCHANGE_SUCCESS_TIP = T("兑换成功！")
L.SCOREMARKET.EXCHANGE_CONFIRM = T("确认")
L.SCOREMARKET.ALERT_WRITEADDRESS = T("请填写 {1}")
L.SCOREMARKET.TIME_LIMIT = T("当前兑换物品每天仅可兑换{1}次，每天总兑换次数不得超过{2}次!")
L.SCOREMARKET.CITY = {
    "กรุงเทพฯ",
    "บุรีรัมย์",
    "ชัยภูมิ",
    "จันทบุรี",
    "เชียงใหม่",
    "เชียงราย",
    "ชลบุรี",
    "ชุมพร",
    "หาดใหญ่",
    "หัวหิน",
    "กำแพงเพชร", 
    "ลำปาง", 
    "เลย",
    "ลพบุรี",
    "นครนายก",
    "นครปฐม",
    "นครราชสีมา",
    "นครสวรรค์",
    "หนองคาย",
    "พัทยา",
    "ประจวบคีรีขันธ์",
    "ระยอง",
    "พิษณุโลก", 
    "ภูเก็ต",
    "สุโขทัย",
    "ระนอง",
    "สามพราน",
    "สระบุรี",
    "สงขลา",
    "สุพรรณบุรี",
    "ตาก",
    "อุดรธานี",
    "ตรัง",
    "หนองบัวลำภู",
    "อุตรดิตถ์",
    "พัทลุง",
    "ปราจีนบุรี",
    "สุรินทร์"
}
L.SCOREMARKET.EXCHANGE_NOTICE = T("兑换须知")  -- คำอธิบายการแลก
L.SCOREMARKET.EXCHANGE_HELP_QUESTIONS = {
    T("1.收货地址"),  -- 1."ชิปเงินสด"คืออะไร？
    T("2.兑换流程"),
    T("3.点卡及实物奖励兑换说明"),  -- 2.แลกรางวัลจริงอย่างไร？
    T("4.兑换问题反馈")
    
}
L.SCOREMARKET.EXCHANGE_HELP_ANSWER = {
    T("兑换点卡或实物奖励前，请先确定自己的收货信息，因信息错误导致的奖励发放失败官方概不负责。实物奖励兑换后，将在10天内有工作人员与您联系确认兑换信息领取奖励。"),
    T("确定收货信息 > 选择想要兑换的商品 > 确定兑换 > 进入兑换记录 > 领取奖励。虚拟奖励兑换后无需领取，兑换成功后自动获得"),
    -- "ชิปเงินสด" สามารถแลกรางวัลในห้างได้ หากได้อันดับในห้องแข่ง จะได้ชิปเงินสดเป็นรางวัล.
    T("兑换点卡或实物奖励时，除需要等价的现金币外，还需要少量的实物券,实物券：可通过比赛、虚拟道具兑换及其它活动获得，配合现金币可兑换点卡及实物奖励"),
    -- ชิปเงินสดที่ได้จากการเล่นห้องแข่งหรือห้องชิปเงินสด สามารถนำไปแลกได้โดยกดเข้า【ห้างแลก】แล้ว【เลือกสินค้าที่อยากแลก】สุดท้ายกด【แลกทันที】 เพื่อแลกสินค้า หากแลกสำเร็จสามารถรับรางวัลได้โดยกด【บันทึกการแลก】
    T("客服联系方式:打开FB,搜索搏定,找到搏定粉丝页,直接在上面发问;或者打开右下角“系统”,点击“问号”,进行发问。")
    -- หากมีปัญหาหรือคำถามใดๆ กรุณาติดต่อแอดมินโดยเข้า Facebook คนหาเพจแอพ【ไพ่ป๊อกเด้ง】 แล้วส่งฟีดเบคผ่าน【ข้อความ】นะคะ หรือฟีดแบคผ่านเกมส์ก็ได้ค่ะ.
}

L.SCOREMARKET.CHIP_NUM = T("{1}筹码")
L.SCOREMARKET.CASH_NUM = T("{1}个现金币")
L.SCOREMARKET.OTHER_TICKET_NUM = T("{1}个兑换券")
L.SCOREMARKET.TICKET_NUM = T("{1}个实物券")
L.SCOREMARKET.NEED_TIP = T("你还差{1}就可以兑换此商品")
L.SCOREMARKET.TO_GET =T("去获得")
L.SCOREMARKET.TO_PLAY =T("继续玩牌")
L.SCOREMARKET.NUM_LIMIT_TIP = T("尊敬的牌友你好，今天您的兑换次数已用完")

L.GRAB_DEALER.EXCHANGE_DEALER = T("欢迎上庄,{1}局之后更新庄家位")
L.GRAB_DEALER.WHO_GRAB = T("{1} 抢庄啦!")
L.GRAB_DEALER.GRAB_ROOM_PUSH_TIP = T("玩筹码场玩久了，来现金币场赢取更丰厚的奖励吧。")
L.GRAB_DEALER.GRAB_ROOM_NOT_MONEY = T("您的现金币不足该房间的最小买入，请补充现金币后游戏")

L.GRAB_DEALER.GRAB_ROOM_NOT_MONEY2 = T("需要{1}筹码才可以上庄哦")
L.GRAB_DEALER.GRAB_ROOM_NOT_CASH = T("需要{1}现金币才可以上庄哦，请补充现金币后游戏")

L.GRAB_DEALER.INVITE_HAD_SEND_TIP = T("邀请已发布")
L.GRAB_DEALER.INVITE_TO_GRAB = T("邀请")

L.AUCTION_MARKET.EXPIRE_TIP = T("已过期")
L.AUCTION_MARKET.OVER_TIP = T("已结束")
L.AUCTION_MARKET.FIXED_PRICE = T("一口价")
L.AUCTION_MARKET.AUCTIONEER = T("拍卖人")
L.AUCTION_MARKET.FIXED_PRICE_AUCTION = T("一口价竞拍")
L.AUCTION_MARKET.NORMAL_AUCTION = T("普通竞拍")
L.AUCTION_MARKET.SURE_AUCTION_1 = T("确定竞拍")
L.AUCTION_MARKET.SURE_AUCTION_2 = T("确定拍卖")
L.AUCTION_MARKET.SURE_AUCTION_BOTTOM_TIP = T("确定竞拍即可立即获得物品完成交易")
L.AUCTION_MARKET.TIME_OVER_BOTTOM_TIP = T("时间结束时无人超过你的出价,则由您获得该物品")
L.AUCTION_MARKET.NOT_ENOUGH_MONEY_FOR_FIXED_PRICE = T("您的筹码低于该物品一口价竞拍价格,请重新选择竞拍！")
L.AUCTION_MARKET.AUCTION_SUCC_FOR_WAIT = T("竞拍成功,请耐心等待！")
L.AUCTION_MARKET.AUCTION_FAIL_FOR_EXPIRE = T("竞拍物品已过期")
L.AUCTION_MARKET.AUCTION_FAIL_FOR_GONE = T("竞拍物品已被拍走！")
L.AUCTION_MARKET.AUCTION_FAIL_FOR_RETRY = T("竞拍失败,请重试！")
L.AUCTION_MARKET.AUCTION_FAIL_FOR_HAS_AUCTION = T("您正在竞拍(买)此物品，换一个试试吧！")
L.AUCTION_MARKET.AUCTION_FAIL_FOR_NEW_PRICE = T("已有新的竞价,请重新参与竞拍！")
L.AUCTION_MARKET.AUCTION_FAIL_FOR_LESS_MONEY = T("筹码不足竞拍，请重新选择")
L.AUCTION_MARKET.AUCTION_NOW = T("立即竞拍")
L.AUCTION_MARKET.NOT_DATA_TIP = T("暂无任何拍卖品")
L.AUCTION_MARKET.NOT_RECODE_TIP = T("暂无任何拍卖记录")
L.AUCTION_MARKET.NOT_ENOUGH_LEVEL_FOR_FIXED_PRICE = T("满10级才可参与一口价竞拍,请再接再厉！")
L.AUCTION_MARKET.NOT_ENOUGH_MONEY_FOR_FIXED_PRICE = T("您的筹码不足10M,不能参与一口价竞拍！")
L.AUCTION_MARKET.AUCTION_HELP_TITLE = T("拍卖行规则说明")

L.AUCTION_MARKET.AUCTION_HELP_ITEM_STRING = 
{
    T("1.仅有现金币、和实物兑换卡才可被拍卖"),
    T("2.拍卖或竞拍失败会反还拍卖物品或竞拍筹码，请放心参与"),
    T("3.拍卖行以筹码做为唯一货币，只可使用筹码参与竞拍"),
    T("4.满10级才可参与一口价拍卖和竞拍，一天可设置3单一口价"),
    T("5.成功拍卖的物品，需收取拍卖方成交价的10%%做为手续费")
}

L.AUCTION_MARKET.AUCTION_HELP_DES_TITLE = 
{
    T("拍卖中心"),
    T("一口价"),
    T("我的拍卖"),
    T("拍卖记录")
}

L.AUCTION_MARKET.AUCTION_HELP_DES_CONTENT = 
{
    T("展示所有常规拍卖，供您参与竞拍"),
    T("展示所有一口价拍卖，竞拍立即交易成功"),
    T("展示或添加自己要拍卖的物品，包含一口价"),
    T("记录自己最近参与的拍卖或竞拍")
}


L.AUCTION_MARKET.FILTER_BAR_LABELS_1 = 
{
    T("拍卖物品"),
    T("拍卖数量"),
    -- T("拍卖人"),
    T("初始价"),
    T("当前竞价"),
    T("剩余时间"),
    T("竞拍人"),
    T(" ")
}

L.AUCTION_MARKET.FILTER_BAR_LABELS_2 = 
{
    T("拍卖物品"),
    T("拍卖数量"),
    -- T("拍卖人"),
    T("初始价"),
    T("拍卖模式"),
    T("剩余时间"),
    T("竞拍人"),
    T(" ")
}

L.AUCTION_MARKET.EMPTY = T("空")
L.AUCTION_MARKET.ADD = T("添加竞拍")
L.AUCTION_MARKET.IS_AUCTIONING = T("拍卖中")

L.AUCTION_MARKET.READING_TITLE = T("拍卖须知")
L.AUCTION_MARKET.READING_CONTENT = 
{
    T("1、确定拍卖后不可取消，请谨慎操作"),
    T("2、计时结束流拍的物品会自动返还至账户"),
    T("3、成功拍卖后，系统将取消10%%的手续费"),
    T("4、仅可拍卖现金币、实物兑换卡2钟道具"),
    T("5、参与拍卖视为同意以上守则，祝大家游戏愉快"),
}


L.AUCTION_MARKET.MY_EXCHANGEABLE_ITEM_TITLE= T("我的实物兑换卡:")
L.AUCTION_MARKET.MY_EXCHANGEABLE_ITEM_TIP = T("暂无实物兑换卡")

L.AUCTION_MARKET.TYPE_NORMAL = T("普通")
L.AUCTION_MARKET.TYPE_FIX_PRICE = T("一口价")
L.AUCTION_MARKET.STATE_SUCC =T ("竞拍成功")
L.AUCTION_MARKET.STATE_FAIL = T("竞拍失败")
L.AUCTION_MARKET.STATE_SUCC_FOR_AUCTION = T("拍卖成功")
L.AUCTION_MARKET.STATE_FAIL_FOR_AUCTION = T("拍卖失败")

L.AUCTION_MARKET.TIME_HOUR = T("小时")
L.AUCTION_MARKET.AUCTION_POP_TAB_STR =
{
    T("普通拍卖"),
    T("一口价拍卖")
}

L.AUCTION_MARKET.NOT_OPEN = T("暂未开放")
L.AUCTION_MARKET.SELECT_TIME = T("选择拍卖时长:")
L.AUCTION_MARKET.INPUT_NUM = T("输入拍卖数量:")
L.AUCTION_MARKET.NOT_ENOUGH_NUM_FOR_RETRY = T("你的物品数量不足,请重新输入")
L.AUCTION_MARKET.LACK_TO_AUCTION = T("暂无可拍卖的物品")
L.AUCTION_MARKET.SELECT_TO_AUCTION = T("选择拍卖物品:")

L.AUCTION_MARKET.INPUT_ORG_PRICE = T("输入初始价")

L.AUCTION_MARKET.PRICING_TIP_1 = T("参与一口价拍卖的物品定价不得低于10M")
L.AUCTION_MARKET.PRICING_TIP_2 = T("不得低于10M")
L.AUCTION_MARKET.PRICING_TIP_3 = T("满10级才可参与一口价竞拍,请再接再厉")
L.AUCTION_MARKET.PRICING_TIP_4 = T("确定拍卖后不可取消,请谨慎操作")
L.AUCTION_MARKET.PRICING_TIP_5 = T("已成功添加拍卖！")
L.AUCTION_MARKET.PRICING_TIP_6 = T("每天最多可设置三次一口价拍卖,请明日再来！")
L.AUCTION_MARKET.PRICING_TIP_7 = T("添加拍卖失败,请重试！")

L.AUCTION_MARKET.NICK = T("昵称:")
L.AUCTION_MARKET.AVERAGE_PRICE = T("均价:{1}筹码")

L.GUCURECALL.WELCOME_BACK = T("欢迎回家")  -- ยินดีต้อนรับกลับกลุ่มป๊อกเด้ง
L.GUCURECALL.WELCOME_GREETS = T("亲爱的牌友您好，最近这段时间很忙碌吧。欢迎回家。我们为您准备了丰厚的回归礼包。")
    -- สวัสดีผู้เล่นที่รักทุกท่าน ช่วงนี้ยุ่งใช่ไหมจ๊ะ ทีมงานป๊อกเด้งขอต้อนรับกลับสู่เกมส์ รางวัลต้อนรับของคุณเตรียมพร้อมแล้ว!
L.GUCURECALL.CLKTO_GET = T("点击领取")  -- กดรับ
L.GUCURECALL.REWARD_HDDJ = T("互动道具")  -- อีโมทั่วไป
L.GUCURECALL.REWARD_CHIP = T("筹码") -- ชิป
L.GUCURECALL.REWARD_CASH = T("现金币")  -- 
L.GUCURECALL.REWARD_SILVER_SEED = T("银元宝种子")

L.RECVADDR.RECV_INFO = T("收货信息")
L.RECVADDR.INFO_INS = {
    T("你的姓名："),
    T("你的性别："),
    T("详细地址："),
    T("手机号码："),
    T("电子邮箱：")
}
L.RECVADDR.ENSURE_INFO = T("确定信息可以联系到我")
L.RECVADDR.UPDATE_INFO = T("更新收货信息")
L.RECVADDR.DISCLAIM = T("温馨提示:请认真填写,因信息错误导致领奖失败,官方概不负责")

L.DOKB.DOKB_PAGE_INDEX = {
    T("夺宝列表"),  -- รารการ
    T("开奖记录"),  -- บันทึกรางวัล
    T("我的奖励")
}
L.DOKB.CHECK_HELP_TIP = T("查看夺宝说明")

L.DOKB.TERM_SERIAL_NUMBER = T("第{1}期")

L.DOKB.GEMSTATE_FINISH = T("今日夺宝结束,欢迎明天再来")  -- ชิงสมบัติรอบนี้จบแล้วค่ะ
L.DOKB.GEMSTATE_UNDERWAY = T("夺宝进行中.....")
L.DOKB.GEMSTATE_WAIT = T("已颁奖, {1}后开始下一轮") -- รอบหน้าจะเริ่มเวลา {1} น.
L.DOKB.LOTRY_MEET = T("满")
L.DOKB.PEOP = T("人次")
L.DOKB.LOTRY_TERM_STATE = T("开奖[每日{1}/{2}次]")
L.DOKB.PEOP_JONINED = T("已参与人次")
L.DOKB.PEOP_REST = T("剩余人次")
L.DOKB.ATTENED_NOW = T("立即夺宝")
L.DOKB.ATTENED_CURRENCY = T("夺宝单位: {1}现金币 + {2}筹码")

L.DOKB.LOTRYREC_GROUP_NAME = {
    T("夺宝物品"),
    T("中奖编号"),
    T("获奖用户"),
    T("我的夺宝编号")
}
L.DOKB.LOTRYREC_NORECTIP = T("暂未有记录")
L.DOKB.LOTRYREC_NOTOPEN = T("未开奖")
L.DOKB.LOTRYREC_NOTATTENED = T("未参与")

L.DOKB.MYREC_GROUP_NAME = {
    T("夺宝期号"),
    T("夺宝物品"),
    T("中奖编号"),
    T("过期时间"),
    T("领奖查询")
}
L.DOKB.MYREC_NORECTIP = T("暂未获奖")
L.DOKB.MYREC_TERM_NUM = T("{1}期")
L.DOKB.MYREC_GET_REWARD = T("领取奖励")
L.DOKB.MYREC_GETTED = T("已领取")
L.DOKB.MYREC_EXPIRED = T("已过期")
L.DOKB.MYREC_SUCC_GET_REWARD = T("领奖成功")
L.DOKB.MYREC_GETTED_REWARD = T("领取成功")
L.DOKB.MYREC_FAILD_EXPIRED = T("领奖失败,奖励已过期！")
L.DOKB.MYREC_FAILD_BAD_NETWORK = T("网络错误,领奖失败！")

L.DOKB.HELP_INSTRUCT = T("夺宝玩法说明")
L.DOKB.HELP_CONT_TITLES = {
    T("1.参与流程"),
    T("2.具体说明")
}
L.DOKB.HELP_CONT_DETAIL1 = T("参加夺宝>获得夺宝编号>满足参与人次后开奖>查询获奖编号>领取奖励")
L.DOKB.HELP_CONT_DETAIL2 = {
    T("每日玩牌后才可参与夺宝;"),
    T("满足夺宝单价即可参与夺宝,不同物品的参与单价不同;"),
    T("夺宝后可获得夺宝编号，满足参与人次后根据夺宝编号确定最终奖励获得者;"),
    T("一场夺宝同一个用户可多次参与，但不参超过3次;"),
    T("夺宝奖品根据运营需要会有不定期调整，属于正常现象;"),
    T("可在开奖记录中查询自己的夺宝编号，以及中奖获得者;"),
    T("中奖后在我的奖励中领取奖励，实物奖励的需要填写相关信息;"),
    T("请在中奖日起7天内完成领取，逾期视为自行放弃;"),
    T("实物奖励将在7天内完成采购并联系中奖玩家核对领取方式.")
}
L.DOKB.HELP_TIPSBOT = T("博定确保会给大家一个公平公正的夺宝环境,欢迎监督,请放心参与")

L.DOKB.ATTENED_COST = T("确定花费{1}现金币 + {2}筹码参与此次夺宝吗？")
L.DOKB.ATTENDED_PEOPREST = T("剩余参与人次: {1}")
L.DOKB.ATTENED_ENSURE = T("确定夺宝")
L.DOKB.ATTENDED_ARGTERM = T("我已了解夺宝规划,自愿参加夺宝")
L.DOKB.ATTENDED_FAILD_NOTENOUGH_PEOP = T("参与人次不足,请刷新！")
L.DOKB.ATTENED_FAILD_FINISHED = T("夺宝失败,本期夺宝活动已结束！")
L.DOKB.ATTENED_FAILD_EXPIRED = T("夺宝失败,宝物已过期！")

L.DOKB.ATTRESULT_SUCC = T("恭喜您夺宝成功,您的夺宝编号为:")
L.DOKB.ATTRESULT_FAILD_CURRENCY_SHORT = T("夺宝失败,您的现金币或筹码不足.")
L.DOKB.ATTRESULT_FAILD_TIMEFULL = T("夺宝失败,您已经夺宝该物品三次啦")
L.DOKB.ATTRESULT_CHANGE_ANOTHER = T("换一个试试吧！")
L.DOKB.ATTRESULT_CHECKNO_TIP = T("可在开奖记录中查询自己的夺宝编号,祝您中奖")
L.DOKB.ATTRESULT_GETKNOWN = T("我知道了")


L.TICKETTRANSFER.SUCCESS = T("兑换成功，恭喜您获得了{1}现金币")
L.TICKETTRANSFER.FAIL = T("兑换失败，请稍后重试")
L.TICKETTRANSFER.TIPS_1 = T("即日起将取消通用门票的使用及购买")
L.TICKETTRANSFER.TIPS_2 = T("通用门票可{1}兑换为现金币，报名参与比赛")
L.TICKETTRANSFER.TIPS_3 = T("现金币是玩现金币场，兑换实物奖励不可或缺的货币")
L.TICKETTRANSFER.TIPS_4 = T("未完成转换的，将于{1}由系统自动完成转换，请悉知")
L.TICKETTRANSFER.TIPS_5 = T("转换现金币不会导致您的资产有任何亏损")
L.TICKETTRANSFER.TRANS_BTN_LABEL = T("立即换")
L.TICKETTRANSFER.TICKET_NUM = T("{1}张")
L.TICKETTRANSFER.CASH_NUM = T("{1}现金币")


L.NEWER.GUIDE_HALL_BTN_LABEL_1 = T("明日登录立即领取200000")
L.NEWER.GUIDE_HALL_BTN_LABEL_2 = T("点击立即领取200000")

L.NEWER.GUIDE_REWARD_CONTENT_1 = T("恭喜您免费获得{1}筹码\n次日登陆还可再获得{2}，记得回来领取哦！")
L.NEWER.GUIDE_REWARD_CONTENT_2 = T("明日登陆即可领取{1}筹码，仅限明天当日，记得来哦")
L.NEWER.GUIDE_EXIT_TIP = T("点击任意位置即可关闭")

L.NEWER.PLAY_REWARD_CONTENT_1 = T("恭喜您玩牌获得{1}筹码,继续玩牌奖励更多，仅限今天哦!\n(奖励已自动到账)")
L.NEWER.PLAY_REWARD_CONTENT_2 = T("恭喜您玩牌获得{1}筹码,新手成长奖励已全部领完,明日登陆还可直接领取{2}，不要错过哦！")
L.NEWER.PLAY_EXIT_TIP = T("5秒后自动消失")
L.NEWER.PLAY_TITLE = T("搏定新手成长奖励")

L.NEWER.GET_REWARD_SUCC = T("领奖成功")
-- L.NEWER.GET_REWARD_FAILED = T("领奖失败")
L.NEWER.NOT_MEET_LEVEL_TIP = T("满3级后才开放，快点击快速开始玩牌升级吧！")  -- Lv.3 ถึงเปิด กดเริ่มทันทีเพื่อเล่นไพ่อัพ Lv. กัน
L.NEWER.OPEN_HIGHER_LV3 = T("LV.3级后开启")  -- Lv.3 ถึงเปิด
L.NEWER.QUICK_PLAY_TIP = T("点击此处快速入场开始游戏")  -- กดเริ่มเกมส์ทันที
L.NEWER.CARD_TYPE_TIP = T("点此查看牌型比牌说明")  -- กดดูคำอธิบายรูปแบบไพ่
L.NEWER.MAIN_TIPS = {
    T("点此可邀请好友获得筹码"),  -- กดเชิญเพื่อนเพื่อรับชิป
    T("点此可参与获取免费筹码"),  -- กดรับชิปฟรี
    T("点此进入房间大厅自主选场"),  -- กดเลือกห้องเอง
    T("点此可直接购买筹码")  -- กดเติมชิป
}



L.NEWER.GUIDE_HALL_CASH_TIP = T("玩牌赢现金币，即有机会兑换实物奖励")
L.NEWER.GUIDE_ROOM_CASH_WIN = T("累积现金币可在兑换商城中兑换实物奖励")
L.NEWER.GUIDE_ROOM_TO_DEALER = T("点击立即上庄,赢钱更快更刺激")

L.LOYKRATH.PROP_NOT_ENOUGH = T("您还没有这个节日限定道具,快去参加水灯节活动获得吧！")
L.LOYKRATH.PROP_USE_FAIL = T("使用水灯互动道具失败！")

L.LOYKRATH.NAUGHTY_UTTERS = {
    T("水灯节快乐"),
    T("希望好运到来"),
    T("希望每个人都幸福")
}
return lang