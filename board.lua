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
	BlueLeader = Card(0, 2, 10, 1)
	RedLeader = Card(0, 2, 10, 2)
	self.grid[1][3] = BlueLeader
	self.grid[9][3] = RedLeader

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
	print(x)
	print(y)
	return self.grid[point.x][point.y]
end

function Board:register_click(mode, target)
	if mode == "board" then

		if self.grid[target.x][target.y] then 
			--We select our own unit
			if self:get_card_at(target).player == self.turn then
				self.selected = target
			--Or we selected an enemy unit
			elseif self.selected and self:isLegalAttack(self.selected, target) then
					self:makeAttack(self.selected, target)
			else
				self.selected=nil
			end
		--Or tried to move
		elseif self.selected and self:isLegalMove(self.selected, target) then
			self:move(self.selected, target)
		--Or we delselect
		else
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
	
	defender:updateHP(-1*attacker.c_attack)
	attacker:updateHP(-1*defender.c_attack)

	self.selected = nil
end

function Board:move(from, to)
	self.grid[to.x][to.y] = self.grid[from.x][from.y]
	self.grid[from.x][from.y] = nil
	self.selected = nil
end

function Board:getLegalMoves(from)
	legalMoves = {}
	-- Call recursive helper function
	self:getLegalMovesR({x = from.x, y = from.y}, {x = from.x, y = from.y}, legalMoves, 2)

	return legalMoves
end

-- recursive helper function that keeps track of the cap
-- and adds legal moves to legalMoves "in place"
-- Disregards illegal moves and avoids duplicates
function Board:getLegalMovesR(from, current, legalMoves, cap)
	-- Can the algorithm continue?
	if cap > 0 then

		if current.x < c.B_LENGTH.x then
			right = {x = current.x + 1, y = current.y}

			-- add the square to legal moves
			if self:isLegalMove(from, right) then
				legalMoves[right] = true
			end

			-- recursively find legal squares from the square
			self:getLegalMovesR(from, right, legalMoves, cap - 1)
		end

		if current.x > 1 then
			print(current.x,current.y)
			left = {x = current.x - 1, y = current.y}

			-- add the square to legal moves
			if self:isLegalMove(from, left) then
				legalMoves[left] = true
			end

			-- recursively find legal squares from the square
			self:getLegalMovesR(from, left, legalMoves, cap - 1)
		end

		if current.y < c.B_LENGTH.y then
			down = {x = current.x, y = current.y + 1}

			-- add the square to legal moves
			if self:isLegalMove(from, down) then
				legalMoves[down] = true
			end

			-- recursively find legal squares from the square
			self:getLegalMovesR(from, down, legalMoves, cap - 1)
		end



		if current.y > 1 then
			up = {x = current.x, y = current.y - 1}

			-- add the square to legal moves
			if self:isLegalMove(from, up) then
				legalMoves[up] = true
			end		

			-- recursively find legal squares from the square
			self:getLegalMovesR(from, up, legalMoves, cap - 1)
		end
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
