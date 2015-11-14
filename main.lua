-- THE MAIN FILE FOR 5C HACKATHON FALL 2015


-- IMPORT ANY NECESSARY FILES/PACKAGES
gamestate = require 'lib/hump.gamestate'
require 'constants'
require 'board'
require 'card'
require 'deck'



-- initialize everything at the start of the game
function love.load(arg)
    love.graphics.setBlendMode("replace")

    deck1 = Deck({Card(1,1,1,1),
                  Card(2,2,2,1),
                  Card(3,3,3,1),})

    deck2 = Deck({Card(1,1,1,2),
                  Card(2,2,2,2),
                  Card(3,3,3,2),})


    board = Board(deck1, deck2)
end



-- update the game through a timestep 'dt'
function love.update(dt)
    -- do nothing
end



-- draw the game to the screen
function love.draw()
    if board.selected then
        draw_legal_moves()
    end
    draw_grid()
    draw_cards()
    draw_hand_one()
    draw_hand_two()
    draw_end_turn()
    draw_res_one()
    draw_res_two()
end



-- registers a click of the mous
function love.mousepressed(x,y,click)

    if on_board(x,y) then
        board:register_click("board", get_board_index(x,y))
    elseif on_end_turn(x,y) then
        board:register_click("end_turn")
    elseif on_hand_one(x,y) then
        board:register_click("hand_one", get_hand_one(x,y))
    elseif on_hand_two(x,y) then
        board:register_click("hand_two", get_hand_two(x,y))
    end


end


------------- MISCELLANEOUS FUNCTIONS ----------------

-- checks to see if the click occurred on the board
function on_board(x,y)

    if x < c.B_POS.x then
        return false
    elseif x > c.B_POS.x + c.B_LENGTH.x*c.SQ_LENGTH then
        return false
    elseif y < c.B_POS.y then
        return false
    elseif y > c.B_POS.y + c.B_LENGTH.y*c.SQ_LENGTH then
        return false
    end

    return true

end

-- gets the indices corresponding to a click on the board
function get_board_index(x,y)

    b_x = x - c.B_POS.x
    b_y = y - c.B_POS.y

    return {x = math.ceil(b_x/c.SQ_LENGTH),
            y = math.ceil(b_y/c.SQ_LENGTH)}

end

-- checks to see if the click occured on the end-turn button
function on_end_turn(x,y)
    x_corner = c.B_POS.x + (c.B_LENGTH.x+1)*c.SQ_LENGTH
    y_corner = c.B_POS.y + (1/2)*c.B_LENGTH.y*c.SQ_LENGTH

    return x > x_corner and x < x_corner + c.SQ_LENGTH and
           y > y_corner and y < y_corner + c.SQ_LENGTH
end

-- checks to see if the click occurred on player one's hand
function on_hand_one(x,y)


end

-- gets the index corresponding to a click on player one's hand
function get_hand_index_one(x,y)

end

-- checks to see if the click occurred on player two's hand
function on_hand_two(x,y)

end

-- gets the index corresponding to a click on player two's hand
function get_hand_index_two(x,y)

end

---------------- DRAWING FUNCTIONS -------------------

-- draws player one's resources to the screen
function draw_res_one()
    love.graphics.setColor(colors.RES)
    for i = 1, board.p1Mana, 1 do
        if board.p1Mana % 2 == 0 then
            love.graphics.circle(400 + (i - board.p1Mana)*c.SQ_LENGTH, c.P_ONE_RES.y, c.RADIUS)
        else
            love.graphics.circle(375 + (i - board.p1Mana)*c.SQ_LENGTH, c.P_ONE_RES.y, c.RADIUS)
        end
    end
    
end

-- draws player one's hand to the screen
function draw_hand_one()
    love.graphics.setColor(colors.P_ONE)
    hand_size = board.p1Hand:size()
    for i = 1, hand_size, 1 do
        love.graphics.circle("fill", 375 + (i - hand_size)*c.SQ_LENGTH, c.P_ONE_RES.y, c.RADIUS)
    end
end

-- draws player two's resources to the screen
function draw_res_two()
    love.graphics.setColor(colors.RES) 
    for i = 1, board.p1Mana, 1 do
        love.graphics.circle("fill", 375 + (i - board.p1Mana)*c.SQ_LENGTH, c.P_ONE_RES.y, c.RADIUS)
    end
end

-- draws player two's hand to the screen
function draw_hand_two()
    love.graphics.setColor(colors.P_TWO)
    hand_size = board.p2Hand:size()
   for i = 1, hand_size, 1 do
        love.graphics.circle("fill", 375 + (i - hand_size)*50, c.P_ONE_RES.y, c.RADIUS)
    end
end

-- fuck stems
function draw_legal_moves()

    b = {x = c.B_POS.x,y = c.B_POS.y}
    length = c.SQ_LENGTH

    legal_moves = board:getLegalMoves(board.selected)

    for _,move in ipairs(legal_moves) do
        x_pos = b.x + (move.x-1)*length
        y_pos = b.y + (move.y-1)*length
        love.graphics.setColor(colors.HIGHLIGHTED)
        love.graphics.rectangle("fill",x_pos,y_pos,length,length)
    end
end

-- draws the grid to the screen
function draw_grid()
    b = {x = c.B_POS.x,y = c.B_POS.y}
    length = c.SQ_LENGTH

    for i=1,c.B_LENGTH.x do
        for j=1,c.B_LENGTH.y do

            -- draw a rectangle to delineate the space
            x_pos = b.x + (i-1)*length
            y_pos = b.y + (j-1)*length
            love.graphics.setColor(colors.WHITE)
            love.graphics.rectangle("line",x_pos,y_pos,length,length)

        end
    end
end

-- draws all the cards to the screen
function draw_cards()
    b = {x = c.B_POS.x,y = c.B_POS.y}
    length = c.SQ_LENGTH

    for i=1,c.B_LENGTH.x do
        for j=1,c.B_LENGTH.y do

            x_pos = b.x + (i-1)*length
            y_pos = b.y + (j-1)*length
            draw_card(x_pos,y_pos,{x = i,y = j})

        end
    end
end

-- draws the endturn button to the screen
function draw_end_turn()
    x = c.B_POS.x + (c.B_LENGTH.x+1)*c.SQ_LENGTH
    y = c.B_POS.y + (1/2)*c.B_LENGTH.y*c.SQ_LENGTH

    love.graphics.setColor(colors.BUTTON)
    love.graphics.rectangle("fill",x,y,c.SQ_LENGTH,c.SQ_LENGTH)
end

-- draws a card at a particular position
function draw_card(x_off,y_off,pos)
    -- draw anything that exists in that space
    contents = board:get_card_at(pos)
    if contents then
        -- draw a circle for the card
        if contents.player == 1 then
            love.graphics.setColor(colors.P_ONE)
        else 
            love.graphics.setColor(colors.P_TWO)
        end
        c_x = x_off + length/2
        c_y = y_off + length/2
        love.graphics.circle("fill",c_x,c_y,c.RADIUS)

        -- draw the card's stats
        att = contents.attack
        hp = contents.c_health
        stat_string = att.."/"..hp
        love.graphics.setColor(colors.WHITE)
        love.graphics.setBlendMode("alpha")
        love.graphics.printf(stat_string,c_x-c.RADIUS,c_y-c.TEXT_OFFSET,2*c.RADIUS,"center")
        love.graphics.setBlendMode("replace")
    end
end

