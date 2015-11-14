local class = require 'lib/middleclass'
require 'card'
require 'hand'
require 'constants'

Board = class('Board')

function Board:initialize(deck1, deck2)
	self.grid = {}
	for i = 1, c.B_LENGTH.x do
    	self.grid[i] = {}
    	for j = 1, c.B_LENGTH.y do
        	self.grid[i][j] = nil -- Fill the values here
    	end
	end
	BlueLeader = Card(0, 2, 25, 1)
	RedLeader = Card(0, 2, 25, 2)
	self.grid[1][3] = RedLeader
	self.grid[9][3] = BlueLeader

	self.turn = 1

	self.p1Mana = 0
	self.p2Mana = 0

	self.selected = nil
	self.p1Deck = deck1
	self.p1Hand = Hand(self.p1Deck)
	self.p1Hand:draw_card()

	self.p2Deck = deck2
	self.p2Hand = Hand(self.p2Deck)
end

function Board:get_card_at(point)
	return self.grid[point.x][point.y]
end

function Board:register_click(mode, action)
	if mode == "board" then
		if (not self.selected and self.grid[action.x][action.y]) then
			self.selected = action
		
		elseif self.selected then
			if self.selected == action then
				self.selected = nil
			elseif self:isLegalMove(self.selected, action) then
				self:move(self.selected, action)
			elseif self:isLegalAttack(self.selected,action) then
				self:makeAttack(self.selected,action)
			end

			self.selected = nil
		end
	
	elseif mode == "hand_one" then
		-- do nothing
	elseif mode == "hand_two" then
		-- do nothing
	end
end

function Board:makeAttack(from, to)
	attacker = self.grid[from.x][from.y]
	defender = self.grid[to.x][to.y]
	
	defender.c_health = defender.c_health - attacker.c_attack
	attacker.c_health = attacker.c_health - defender.c_attack
end

function Board:move(from, to)
	self.grid[to.x][to.y] = self.grid[from.x][from.y]
	self.grid[from.x][from.y] = nil
end

function Board:getLegalMoves(from)
	legalMoves = {}
	-- Call recursive helper function
	self:getLegalMovesR(from, from, legalMoves, 2)

	return legalMoves
end

-- recursive helper function that keeps track of the cap
-- and adds legal moves to legalMoves "in place"
-- Disregards illegal moves and avoids duplicates
function Board:getLegalMovesR(from, current, legalMoves, cap)
	-- Can the algorithm continue?
	if cap > 0 then
		left = {x = current.x + 1, y = current.y}
		right = {x = current.x - 1, y = current.y}
		up = {x = current.x, y = current.y + 1}
		down = {x = current.x, y = current.y - 1}

		-- add the four adjacent squares
		if self:isLegalMove(from, left) then
			legalMoves[left] = true
		end

		if self:isLegalMove(from, right) then
			legalMoves[right] = true
		end

		if self:isLegalMove(from, up) then
			legalMoves[up] = true
		end

		if self:isLegalMove(from, down) then
			legalMoves[down] = true
		end		
		-- recursively find legal squares from each of
		-- the four adjacent options
		getLegalMovesR(from, left, legalMoves, cap - 1)
		getLegalMovesR(from, right, legalMoves, cap - 1)
		getLegalMovesR(from, up, legalMoves, cap - 1)
		getLegalMovesR(from, down, legalMoves, cap - 1)
	end
end


function Board:isLegalAttack(from, target)
	if self.grid[target.x][target.y] then
		from_card = self:get_card_at(from)
		target_card = self:get_card_at(target)
		if from_card.player == target_card.player then
			return false
		else
			return math.abs(from.x - target.x) == 1 or math.abs(from.y - target.y) == 1
		end
	else
		return false
	end
end

function Board:distance(from, to)
	return math.abs(from.x - to.x) + math.abs(from.y - to.y)
end

function Board:isLegalMove(from, to)
	dist = self:distance(from, to)
	if dist >= 1 and dist <=2 and not self.grid[to.x][to.y] then
		return true
	else
		return false
	end
	-- Make sure that to ~= from
	-- Check to see if to is occupied
	-- Make sure that distance <= 2
end
