--
-- 配置选项，
-- 这个文件在热更新完成之后载入，所以这里的值可以被热更新的配置所覆盖
-- Author: tony
-- Date: 2014-12-11 16:06:52
--

local config = {}

--老虎机开关
config.SLOT_ENABLED = true
--圣诞主题
config.CHRISTMAS_THEME_ENABLED = false
--新手教程
config.TUTORIAL_ENABLED = false
--礼物
config.GIFT_SHOP_ENABLED = true
--宋干节
config.SONGKRAN_THEME_ENABLED = false

--博定推广
config.POKDENG_AD_ENABLED = false

--博雅广告联盟
config.POKDENG_ADSCENE_ENABLED = true

--广告SDK，是否由客户端触发领奖
config.ADSCENE_OLD_GET_REWARD = true

--邀请好友分页排序 0 默认排序， 1 随机排序 ， 2 随机后分页
config.INVITE_SORT_TYPE = 2

return config
