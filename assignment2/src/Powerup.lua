--[[
    GD50
    Breakout Remake

    -- Power-up Class --

    Author: Sai Kaushik S
    saikaishik609@gmail.com

    Represents a powerup that drop down from the top which either provides more balls
    or the keys to unlock the locked brick spawned in the level There are two types of 
    power-ups used, one provides extra two balls and the other provides a key that unlocks 
    the locked bricks. 
]]

Powerup = Class{}

function Powerup:init()
    self.width = 16
    self.height = 16

    self.x = math.random(32, VIRTUAL_WIDTH - 32)

    self.y = 0
    self.dy = 20
end

function Powerup:setSkin()
    -- if the power-up is a ball
    if self.type == 'ball' then
        self.skin = 1
    -- if the power-up is a key
    else
        self.skin = 2
    end
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
end

function Powerup:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerup'][self.skin], self.x, self.y)
end