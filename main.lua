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

    -- Cost: 2 -> 6
    -- 

    deck1 = Deck({Card(1,1,1,1,"minion"),
                  Card(2,2,2,1,"minion"),
                  Card(3,3,3,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),})

    deck2 = Deck({Card(1,1,1,1,"minion"),
                  Card(2,2,2,1,"minion"),
                  Card(3,3,3,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),
                  Card(1,1,1,1,"minion"),})




    board = Board(deck1, deck2)
end



-- update the game through a timestep 'dt'
function love.update(dt)
    -- do nothing
end



-- draw the game to the screen
function love.draw()

    if board.winner > 0 then
        draw_winner(board.winner)
        return
    end

    if board.selectedType then
        if board.selectedType == "onBoard" then
            draw_legal_moves()
            --draw_legal_attacks()
        elseif board.selectedType == "fromHand" then
            if board.turn == 1 then
                hand = board.p1Hand
            else 
                hand = board.p2Hand
            end

            if hand.cards[board.selected].type == "minion" or 
               hand.cards[board.selected].type == "summoner" then
                draw_legal_placements()
            end
        end
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
        board:register_click("hand_one", get_hand_index_one(x,y))
    elseif on_hand_two(x,y) then
        board:register_click("hand_two", get_hand_index_two(x,y))
    end


end


------------- MISCELLANEOUS FUNCTIONS ----------------


function cart_distance(x1,y1,x2,y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

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
    hand_size = board.p1Hand:size()
    positions = get_sym_pos(hand_size,c.P_ONE_HAND.y)
    for _,pos in ipairs(positions) do 
        if cart_distance(x,y,pos.x,pos.y) < c.RADIUS then return true end
    end
    return false
end

-- gets the index corresponding to a click on player one's hand
function get_hand_index_one(x,y)
    hand_size = board.p1Hand:size()
    positions = get_sym_pos(hand_size,c.P_ONE_HAND.y)
    for i = 1,hand_size do 
        pos = positions[i]
        if cart_distance(x,y,pos.x,pos.y) < c.RADIUS then return i end
    end
end

-- checks to see if the click occurred on player two's hand
function on_hand_two(x,y)
    hand_size = board.p2Hand:size()
    positions = get_sym_pos(hand_size,c.P_TWO_HAND.y)
    for _,pos in ipairs(positions) do 
        if cart_distance(x,y,pos.x,pos.y) < c.RADIUS then return true end
    end
    return false
end

-- gets the index corresponding to a click on player two's hand
function get_hand_index_two(x,y)
    hand_size = board.p2Hand:size()
    positions = get_sym_pos(hand_size,c.P_TWO_HAND.y)
    for i = 1,hand_size do 
        pos = positions[i]
        if cart_distance(x,y,pos.x,pos.y) < c.RADIUS then return i end
    end
end

---------------- DRAWING FUNCTIONS -------------------

-- gets symmetric x-positions at which to draw circles
function get_sym_pos(num,y_pos)
    positions = {}
    start = 0

    if num%2 == 0 then
        start = c.SCREEN_W/2 - c.SQ_LENGTH/2 - ((num/2)-1)*c.SQ_LENGTH
    else
        start = c.SCREEN_W/2 - (num-1)/2*c.SQ_LENGTH
    end

    for i=1,num do
        table.insert(positions, {x = start + (i-1)*c.SQ_LENGTH, y = y_pos})
    end

    return positions
end

-- draws player one's resources to the screen
function draw_res_one()
    love.graphics.setColor(colors.RES)
    positions = get_sym_pos(board.p1maxMana,c.P_ONE_RES.y)
    for i=1,board.p1Mana do
        pos = positions[i]
        love.graphics.circle("fill", pos.x, pos.y, c.RADIUS)
    end
    for i=board.p1Mana+1,board.p1maxMana do
        pos = positions[i]
        love.graphics.circle("line", pos.x, pos.y, c.RADIUS)
    end
end

-- draws player one's hand to the screen
function draw_hand_one()
    love.graphics.setColor(colors.P_ONE)
    hand_size = board.p1Hand:size()
    positions = get_sym_pos(hand_size,c.P_ONE_HAND.y)
    for i=1,hand_size do 
        pos = positions[i]
        if board.turn == 1 then
            card = board.p1Hand.cards[i]
            draw_card(pos.x,pos.y,card)
            love.graphics.setColor(colors.GOLD)
            love.graphics.circle("fill", pos.x, pos.y - 1.75*c.RADIUS, c.RADIUS/2)
            love.graphics.setColor(colors.WHITE)
            love.graphics.setBlendMode("alpha")
            love.graphics.printf(card.cost,pos.x-c.RADIUS,pos.y-2.1*c.RADIUS,2*c.RADIUS,"center")
            love.graphics.setBlendMode("replace")
        else
            love.graphics.circle("fill", pos.x, pos.y, c.RADIUS)
        end
    end
end

-- draws player two's resources to the screen
function draw_res_two()
    love.graphics.setColor(colors.RES)
    positions = get_sym_pos(board.p2maxMana,c.P_TWO_RES.y)
    for i=1,board.p2Mana do
        pos = positions[i]
        love.graphics.circle("fill", pos.x, pos.y, c.RADIUS)
    end
    for i=board.p2Mana+1,board.p2maxMana do
        pos = positions[i]
        love.graphics.circle("line", pos.x, pos.y, c.RADIUS)
    end
end

-- draws player two's hand to the screen
function draw_hand_two()
    love.graphics.setColor(colors.P_TWO)
    hand_size = board.p2Hand:size()
    positions = get_sym_pos(hand_size,c.P_TWO_HAND.y)
    for i=1,hand_size do 
        pos = positions[i]
        if board.turn == 2 then
            card = board.p2Hand.cards[i]
            draw_card(pos.x,pos.y,card)
            love.graphics.setColor(colors.GOLD)
            love.graphics.circle("fill", pos.x, pos.y + 1.75*c.RADIUS, c.RADIUS/2)
            love.graphics.setColor(colors.WHITE)
            love.graphics.setBlendMode("alpha")
            love.graphics.printf(card.cost,pos.x-c.RADIUS,pos.y+1.4*c.RADIUS,2*c.RADIUS,"center")
            love.graphics.setBlendMode("replace")
        else
            love.graphics.circle("fill", pos.x, pos.y, c.RADIUS)
        end
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
        love.graphics.setColor(colors.CAN_MOVE)
        love.graphics.rectangle("fill",x_pos,y_pos,length,length)
    end
end

function draw_legal_placements()

    b = {x = c.B_POS.x,y = c.B_POS.y}
    length = c.SQ_LENGTH

    legal_moves = board:getLegalPlacements()

    for _,move in ipairs(legal_moves) do
        x_pos = b.x + (move.x-1)*length
        y_pos = b.y + (move.y-1)*length
        love.graphics.setColor(colors.CAN_PLACE)
        love.graphics.rectangle("fill",x_pos,y_pos,length,length)
    end
end

function draw_legal_attacks()

    b = {x = c.B_POS.x,y = c.B_POS.y}
    length = c.SQ_LENGTH

    legal_moves = board:getLegalAttacks(board.selected)

    for _,move in ipairs(legal_moves) do
        x_pos = b.x + (move.x-1)*length
        y_pos = b.y + (move.y-1)*length
        love.graphics.setColor(colors.CAN_ATTACK)
        love.graphics.rectangle("fill",x_pos,y_pos,length,length)
    end
end

function draw_legal_targets(spell)

    b = {x = c.B_POS.x,y = c.B_POS.y}
    length = c.SQ_LENGTH

    legal_moves = spell:getLegalTargets(board)

    for _,move in ipairs(legal_moves) do
        x_pos = b.x + (move.x-1)*length
        y_pos = b.y + (move.y-1)*length
        love.graphics.setColor(colors.CAN_TARGET)
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
            draw_card_on_grid(x_pos,y_pos,{x = i,y = j})

        end
    end
end

-- draws the endturn button to the screen
function draw_end_turn()
    x = c.B_POS.x + (c.B_LENGTH.x+1)*c.SQ_LENGTH
    y = c.B_POS.y + (1/2)*(c.B_LENGTH.y-1)*c.SQ_LENGTH
 
    if board.turn == 1 then
        love.graphics.setColor(colors.P_ONE)
    else
        love.graphics.setColor(colors.P_TWO)
    end
    love.graphics.rectangle("line",x,y,c.SQ_LENGTH,c.SQ_LENGTH)
    love.graphics.setColor(colors.WHITE)
    love.graphics.setColor(colors.WHITE)
    love.graphics.setBlendMode("alpha")
    love.graphics.printf("END TURN",x,y+(4.5/20)*c.SQ_LENGTH,c.SQ_LENGTH,"center")
    love.graphics.setBlendMode("replace")
end

-- draws a card at a particular position
function draw_card(x,y,card)
    -- draw a circle for the card
    if card.player == 1 then
        love.graphics.setColor(colors.P_ONE)
    else 
        love.graphics.setColor(colors.P_TWO)
    end

    if card.type == "minion" then
        love.graphics.circle("fill",x,y,c.RADIUS)
    elseif card.type == "summoner" then
        love.graphics.rectangle("fill",x-c.SQ_LENGTH/2+1,y-c.SQ_LENGTH/2+1,c.SQ_LENGTH-2,c.SQ_LENGTH-2)
    end

    -- draw the card's stats
    att = card.attack
    hp = card.c_health
    stat_string = att.."/"..hp
    love.graphics.setColor(colors.WHITE)
    love.graphics.setBlendMode("alpha")
    love.graphics.printf(stat_string,x-c.RADIUS,y-c.TEXT_OFFSET,2*c.RADIUS,"center")
    love.graphics.setBlendMode("replace")
end

-- draws a card onto the board
function draw_card_on_grid(x_off,y_off,pos)
    -- draw anything that exists in that space
    contents = board:get_card_at(pos)
    length = c.SQ_LENGTH
    if contents then
        -- draw the card
        c_x = x_off + length/2
        c_y = y_off + length/2
        draw_card(c_x,c_y,contents)
    end
end

function draw_winner(winner)
    love.graphics.setColor(colors.WHITE)
    love.graphics.setBlendMode("alpha")
    if winner == 1 then
        love.graphics.printf("PLAYER ONE WINS", 0, c.SCREEN_H/2, c.SCREEN_W, "center") --,0,10,10)
    elseif winner == 2 then
        love.graphics.printf("PLAYER TWO WINS", 0, c.SCREEN_H/2, c.SCREEN_W, "center") --,0,10,10)
    else
        love.graphics.printf("I'M TIRED AND THIS GAME IS TIED", 0, c.SCREEN_H/2, c.SCREEN_W, "center") --,0,10,10)
    end
end



