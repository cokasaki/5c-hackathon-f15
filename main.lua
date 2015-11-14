-- THE MAIN FILE FOR 5C HACKATHON FALL 2015


-- IMPORT ANY NECESSARY FILES/PACKAGES
gamestate = require 'lib/hump.gamestate'
require 'constants'



-- initialize everything at the start of the game
function love.load(arg)
    board = 0
    p_one = 0
    p_two = 0
end



-- update the game through a timestep 'dt'
function love.update(dt)
    -- do nothing
end



-- draw the game to the screen
function love.draw()
    draw_board()
end



-- registers a click of the mous
function love.mousepressed(x,y,click)

    if y < c.B_POS.y + c.B_LENGTH*c.SQ_LENGTH and y > c.B_POS.y then

    end
end


------------- MISCELLANEOUS FUNCTIONS ----------------

-- checks to see if the click occurred on the board
function try_board(x,y)

end

-- checks to see if the click occurred on a hand
function try_hand(x,y)

end

---------------- DRAWING FUNCTIONS -------------------

-- draws a players hand to the screen
function draw_hand()

end

-- draws the board to the screen
function draw_board()
    b = {x = c.B_POS.x,y = c.B_POS.y}
    length = c.SQ_LENGTH

    for i=1,c.B_LENGTH.x do
        for j=1,c.B_LENGTH.y do

            -- draw a rectangle to delineate the space
            x_pos = b.x + (i-1)*length
            y_pos = b.y + (j-1)*length
            love.graphics.setColor(colors.RED)
            love.graphics.rectangle("line",x_pos,y_pos,length,length)
        end
    end
end
