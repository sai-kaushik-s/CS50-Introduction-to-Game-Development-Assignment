--[[
    PauseState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

PauseState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function PauseState:enter(params)
    sounds['music']:pause()
    bird = params.bird
    pairPipes = params.pairPipes
    timer = params.timer
    score = params.score
    lastY = params.lastY

    scrolling = false
end

function PauseState:exit()
    sounds['music']:play()
    scrolling = true
end

function PauseState:update(dt)
    -- kick off music
    
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('p') then
        gStateMachine:change('play', {
            bird = bird,
            pairPipes = pairPipes,
            timer = timer,
            score = score,
            lastY = lastY,
        })
    end
end

function PauseState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Paused', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press p to Play Again!', 0, 200, VIRTUAL_WIDTH, 'center')
end