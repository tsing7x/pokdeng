--
-- Author: tony
-- Date: 2014-08-08 10:39:19
--

local MatchExpressionConfig = class("MatchExpressionConfig")

function MatchExpressionConfig:ctor()
    self.config_ = {}

    local d3 = 1 / 3
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
end

function MatchExpressionConfig:getConfig(id)
    return self.config_[id]
end

function MatchExpressionConfig:addConfig_(id, frameNum, adjustX, adjustY)
    local config = {}
    config.id = id
    config.frameNum = frameNum
    config.adjustX = adjustX
    config.adjustY = adjustY
    self.config_[id] = config
end

return MatchExpressionConfig