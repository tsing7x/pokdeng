--
-- Author: tony
-- Date: 2014-08-08 10:39:19
--

local ExpressionConfig = class("ExpressionConfig")

function ExpressionConfig:ctor()
    self.config_ = {}

    -- local d3 = 1 / 3
    self:addConfig_(1,    2,    -5,    0)
    self:addConfig_(2,    2,    4,    8)
    self:addConfig_(3,    2,    10,    6)
    self:addConfig_(4,    2,    0,    8)
    self:addConfig_(5,    4,    6,    6)
    self:addConfig_(6,    2,    0,    4)
    self:addConfig_(7,    3,    0,    2)
    self:addConfig_(8,    3,    0,    2)
    self:addConfig_(9,    3,    0,    4)
    self:addConfig_(10,    4,    0,    6)
    self:addConfig_(11,    2,    8,    0)
    self:addConfig_(12,    2,    0,    0)
    self:addConfig_(13,    2,    2,    6)
    self:addConfig_(14,    4,    -4,    4)
    self:addConfig_(15,    2,    1,    2)
    self:addConfig_(16,    2,    1,    4)
    self:addConfig_(17,    2,    1,    10)
    self:addConfig_(18,    2,    11,    10)
    self:addConfig_(19,    2,    -2,    6)
    self:addConfig_(20,    2,    14,    4)
    self:addConfig_(21,    2,    4,    4)
    self:addConfig_(22,    2,    6,    0)
    self:addConfig_(23,    11,    0,    0)
    self:addConfig_(24,    4,    0,    0)
    self:addConfig_(25,    2,    0,    0)
    self:addConfig_(26,    2,    12,    2)
    self:addConfig_(27,    3,    0,    0)

    -- 添加付费表情配置,注:后面两项参数保持少数一致--

    -- 表情 狐狸
    self:addConfig_(28, 12, -5, 0)
    self:addConfig_(29, 10, 4, 8)
    self:addConfig_(30, 12, 10, 6)
    self:addConfig_(31, 12, 0, 8)
    self:addConfig_(32, 12, 6, 6)
    self:addConfig_(33, 14, 0, 4)
    self:addConfig_(34, 17, 0, 2)
    self:addConfig_(35, 8, 0, 2)
    self:addConfig_(36, 19, 0, 4)
    self:addConfig_(37, 11, 0, 6)
    self:addConfig_(38, 18, 8, 0)

    -- 表情 兔子
    self:addConfig_(39, 2, -5, 0)
    self:addConfig_(40, 2, 4, 8)
    self:addConfig_(41, 3, 10, 6)
    self:addConfig_(42, 9, 0, 8)
    self:addConfig_(43, 26, 6, 6)
    self:addConfig_(44, 8, 0, 4)
    self:addConfig_(45, 10, 0, 2)
    self:addConfig_(46, 4, 0, 2)
    self:addConfig_(47, 2, 0, 4)
    self:addConfig_(48, 10, 0, 6)
    self:addConfig_(49, 10, 8, 0)
    self:addConfig_(50, 9, 0, 0)
    self:addConfig_(51, 4, 2, 6)
    self:addConfig_(52, 4, -4, 4)
    self:addConfig_(53, 4, 1, 2)
    self:addConfig_(54, 4, 1, 4)
    self:addConfig_(55, 15, 1, 10)
    self:addConfig_(56, 9, 11, 10)
    self:addConfig_(57, 16, -2, 6)
end

function ExpressionConfig:getConfig(id)
    return self.config_[id]
end

function ExpressionConfig:addConfig_(id, frameNum, adjustX, adjustY)
    local config = {}
    config.id = id
    config.frameNum = frameNum
    config.adjustX = adjustX
    config.adjustY = adjustY
    self.config_[id] = config
end

return ExpressionConfig