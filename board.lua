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
	for _,off in ipairs(c.TWO_RANGE) do
		x_pos = from.x + off.x
		y_pos = from.y + off.y
		to = {x = x_pos,y = y_pos}
		if self:onBoard(to) then
			if self:isLegalMove(from,to) then
				table.insert(legalMoves, to)
			end
		end
	end

	return legalMoves
end

function Board:isLegalAttack(from, target)
	if self.grid[target.x][target.y] then
		from_card = self:get_card_at(from)
		target_card = self:get_card_at(target)
		if from_card.player == target_card.player then
			return false
		else
			return math.abs(from.x - target.x) <= 1 and math.abs(from.y - target.y) <= 1
		end
	else
		return false
	end
end

function Board:distance(from, to)
	return math.abs(from.x - to.x) + math.abs(from.y - to.y)
end

function Board:onBoard(point)
	return point.x >= 1 and point.x <= c.B_LENGTH.x and point.y >= 1 and point.y <= c.B_LENGTH.y
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

function Board:isLegalMoveR(from, to, current, cap)

end
