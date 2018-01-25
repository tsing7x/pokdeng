--
-- Author: johnny@boomegg.com
-- Date: 2014-07-18 17:21:23
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local MatchChipData = class("MatchChipData")

function MatchChipData:ctor(filename, oddOrEven, key)
    self.sprite_ = display.newSprite(filename)
    self.oddOrEven_ = oddOrEven
    self.key_ = key
end

function MatchChipData:getSprite()
    return self.sprite_
end

function MatchChipData:getOddOrEven()
    return self.oddOrEven_
end

function MatchChipData:getKey()
    return self.key_
end

function MatchChipData:retain()
    self.sprite_:retain()
end

function MatchChipData:release()
    self.sprite_:release()
    self.oddOrEven_ = nil
    self.key_ = nil
end

return MatchChipData