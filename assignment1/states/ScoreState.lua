--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

local Gold = love.graphics.newImage('gold.png')
local Silver = love.graphics.newImage('silver.png')
local Bronze = love.graphics.newImage('bronze.png')

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)    
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oops! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    if self.score > 2 then
        if self.score < 5 then
            love.graphics.draw(Bronze, VIRTUAL_WIDTH / 2 - 29.625, VIRTUAL_HEIGHT / 2 - 25, 0, 0.25)
        elseif self.score < 7 then
            love.graphics.draw(Silver, VIRTUAL_WIDTH / 2 - 29.625, VIRTUAL_HEIGHT / 2 - 25, 0, 0.24)
        else
            love.graphics.draw(Gold, VIRTUAL_WIDTH / 2 - 29.625, VIRTUAL_HEIGHT / 2 - 25, 0, 0.22)
        end
    end

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 200, VIRTUAL_WIDTH, 'center')
end