--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Sai Kaushik S
    saikaishik609@gmail.com

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

local done = false

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.sessionScore = 0
    self.highScores = params.highScores
    self.level = params.level
    self.balls = {}
    self.keys = {}
    self.keysPowerups = {}
    self.ballPowerups = {}

    self.powerupTimeout = love.timer.getTime()

    table.insert(self.balls, params.ball)

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    if (love.timer.getTime() - self.powerupTimeout > 10) then
        if math.random(1, 5) == 1 and lockedBrickExists(self.bricks) == true and self.keys[1] == nil then
            table.insert(self.keysPowerups, spawnKeyPowerup());
        else
            table.insert(self.ballPowerups, spawnBallPowerup());
        end
        self.powerupTimeout = love.timer.getTime()
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for b, ball in pairs(self.balls) do
        self.balls[b]:update(dt)
    end

    for b, ball in pairs(self.ballPowerups) do
        self.ballPowerups[b]:update(dt)
    end

    for k, key in pairs(self.keysPowerups) do
        self.keysPowerups[k]:update(dt)
    end

    for b, ball in pairs(self.balls) do
        if self.balls[b]:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            self.balls[b].y = self.paddle.y - 8
            self.balls[b].dy = -self.balls[b].dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if self.balls[b].x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                self.balls[b].dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.balls[b].x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif self.balls[b].x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                self.balls[b].dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.balls[b].x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        for b, ball in pairs(self.balls) do
            -- only check collision if we're in play
            if brick.inPlay and self.balls[b]:collides(brick) then

                if brick.locked == false then
                    -- add to score
                    self.score = self.score + (brick.tier * 300 + brick.color * 30)
                    self.sessionScore = self.sessionScore + (brick.tier * 300 + brick.color * 30)
                end

                if brick.locked == true and self.keys[1] ~= nil then
                    brick.locked = false
                    table.remove(self.keys)
                end

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.balls[1],
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if self.balls[b].x + 2 < brick.x and self.balls[b].dx > 0 then

                    -- flip x velocity and reset position outside of brick
                    self.balls[b].dx = -self.balls[b].dx
                    self.balls[b].x = brick.x - 8

                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif self.balls[b].x + 6 > brick.x + brick.width and self.balls[b].dx < 0 then

                    -- flip x velocity and reset position outside of brick
                    self.balls[b].dx = -self.balls[b].dx
                    self.balls[b].x = brick.x + 32

                -- top edge if no X collisions, always check
                elseif self.balls[b].y < brick.y then

                    -- flip y velocity and reset position outside of brick
                    self.balls[b].dy = -self.balls[b].dy
                    self.balls[b].y = brick.y - 8

                -- bottom edge if no X collisions or top collision, last possibility
                else

                    -- flip y velocity and reset position outside of brick
                    self.balls[b].dy = -self.balls[b].dy
                    self.balls[b].y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(self.balls[b].dy) < 150 then
                    self.balls[b].dy = self.balls[b].dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health

    for b, ball in pairs(self.balls) do

        if self.balls[b].y >= VIRTUAL_HEIGHT then
            table.remove(self.balls, b)

            if table.maxn(self.balls) < 1 then
                self.health = self.health - 1

                if self.paddle.size > 2 then
                   self.paddle:shrink()
                end

                gSounds['hurt']:play()

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints
                    })
                end
            end
        end

    end

    for b, ball in pairs(self.ballPowerups) do
        if self.ballPowerups[b]:collides(self.paddle) then
            table.remove(self.ballPowerups, b)
            table.insert(self.balls, addBall(self.balls[1]))
            table.insert(self.balls, addBall(self.balls[1]))
            gSounds['power-up']:play()
        end
    end

    for k, key in pairs(self.keysPowerups) do
        if self.keysPowerups[k]:collides(self.paddle) then
            table.remove(self.keysPowerups, k)
            table.insert(self.keys, addKey())
            gSounds['power-up']:play()
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if self.sessionScore > 10000 and self.paddle.size == 2 then
        self.sessionScore = 0
        self.paddle:grow()
    end
    if self.sessionScore > 20000 and self.paddle.size == 3 then
        self.sessionScore = 0
        self.paddle:grow()
    end

end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for b, ball in pairs(self.balls) do
        self.balls[b]:render()
    end

    for p, powerup in pairs(self.ballPowerups) do
        self.ballPowerups[p]:render(dt)
    end

    for k, powerup in pairs(self.keysPowerups) do
        self.keysPowerups[k]:render(dt)
    end

    renderScore(self.score)
    renderHealth(self.health)
    renderKeys(#self.keys)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end