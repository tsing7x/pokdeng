--
-- Author: johnny@boomegg.com
-- Date: 2014-07-18 17:21:23
-- Copyright: Copyright (c) 2014, BOOMEGG INTERACTIVE CO., LTD All rights reserved.
--

local GrabChipData = class("GrabChipData")

function GrabChipData:ctor(filename, oddOrEven, key)
    self.sprite_ = display.newSprite(filename)
    self.oddOrEven_ = oddOrEven
    self.key_ = key
end

function GrabChipData:getSprite()
    return self.sprite_
end

function GrabChipData:getOddOrEven()
    return self.oddOrEven_
end

function GrabChipData:getKey()
    return self.key_
end

function GrabChipData:retain()
    self.sprite_:retain()
end

function GrabChipData:release()
    self.sprite_:release()
    self.oddOrEven_ = nil
    self.key_ = nil
end

return GrabChipData