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
	self.grid[to[1]][to[2]] = self.grid[from[1]][from[2]]
	self.grid[from[1]][from[2]] = nil
end
