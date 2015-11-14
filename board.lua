local class = require 'lib/middleclass'
require 'card'
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
	--self.p1Hand = Hand()
	--self.p1Hand.draw()
end

function Board:get_card_at(x, y)
	return self.grid[x][y]
end

function Board:register_click(mode, action)
	if mode == "board" then
		if (not self.selected and self.grid[action[1]][action[2]]) then
			self.selected = action
		
		elseif self.selected then
			if self:isLegalMove(self.selected, action) then
				self:move(self.selected, action)
			end
			elseif self:isLegalAttack(self.selected,action) then
				self:makeAttack(self.selected,action)
			end
		end
	
	elseif mode == "hand_one" then
		-- do nothing
	elseif mode == "hand_two" then
		-- do nothing
	end
end

function Board:makeAttack(from, to):
	attacker = self.grid[from.x][from.y]
	defender = self.grid[to.x][to.y]
	
	defender.c_Health = defender.c_Health - attacker.c_attack
	attacker.c_Health = attacker.c_attack - defender.c_attack

function Board:move(from, to)
	self.grid[to.x][to.y] = self.grid[from.x][from.y]
	self.grid[from.x][from.y = nil
end

function Board:getLegalMoves(from)
	legalMoves = {}
	-- Call recursive helper function
	self:getLegalMoves(from, legalMoves, 2)
	return legalMoves
end

-- recursive helper function that keeps track of the cap
-- and adds legal moves to legalMoves "in place"
function Board:getLegalMoves(from, legalMoves, cap)
	-- Can the algorithm continue?
	if cap > 0 then
		left = (from.x + 1, from.y)
		right = (from.x - 1, from.y)
		up = (from.x, from.y + 1)
		down = (from.x, from.y - 1)

		-- add the four adjacent squares
		table.insert( (legalMoves, left) = true)
		table.insert( (legalMoves, right) = true)
		table.insert( (legalMoves, up) = true)
		table.insert( (legalMoves, down) = true)

		-- recursively find legal squares from each of
		-- the four adjacent options
		getLegalMoves(left, legalMoves, cap - 1)
		getLegalMoves(right, legalMoves, cap - 1)
		getLegalMoves(up, legalMoves, cap - 1)
		getLegalMoves(down, legalMoves, cap - 1)
	end
end

function Board:isLegalAttack(from, target)
	return math.abs(from.x - target.x) == 1 or math.abs(from.y - target.y) == 1
end

function Board:distance(from, to)
	return math.abs(from.x - to.x) + math.abs(from.y - to.y)
end

function Board:isLegalMove(from, to)
	distance = self.distance(from, to)
	if distance >= 1 and distance <=2 and self.grid[to.x][to.y] == nil then
		return true
	else
		return false
	-- Make sure that to ~= from
	-- Check to see if to is occupied
	-- Make sure that distance <= 2
end
