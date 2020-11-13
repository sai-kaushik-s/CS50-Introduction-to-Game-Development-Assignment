--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Sai Kaushik S
    saikaishik609@gmail.com

    Represents the screen where we can view all high scores previously recorded.
]]

InstructionState = Class{__includes = BaseState}

function InstructionState:enter(params)
    self.highScores = params.highScores
end

function InstructionState:update(dt)
    -- return to the start screen if we press escape
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()
        
        gStateMachine:change('paddle-select', {
            highScores = self.highScores
        })
    end
    if love.keyboard.wasPressed('escape') then
        gStateMachine:change('start', {
            highScores = self.highScores
        })
    end
end

function InstructionState:render()
    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(128/255, 0/255, 0/255, 255/255)
    love.graphics.printf('Instructions', 0, 20, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("1. Use your left and right arrow keys to move your paddle.",
        0, 50, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("2. Eack brick gives you different scores. There striped bricks give you the highest scores. \nSome of the brick might be locked.",
        0, 65, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("3. Power-ups keep dropping from the top. There are two power-ups -- the ball and the key power-ups. The ball power-up gives you twho additional balls and the key power-up gives you a key which can be used to unlock any locked brickd in your layout.",
        0, 87.5, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("4. The paddle expands everytime you cross 30,000 points and shrinks everythime you lose. You also get a health increase if your cross a threshold of 100,000 which keeps doubling as you cross this threshold.",
        0, 120, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("5. To pause the game, press the space bar",
        0, 150, VIRTUAL_WIDTH, 'center')
    
    love.graphics.setColor(103/255, 255/255, 255/255, 255/255)
    love.graphics.printf("Press Enter or Return to go to the paddle selecton page!",
        0, VIRTUAL_HEIGHT - 54, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Escape to return to the main menu!",
        0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')
end
