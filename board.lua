local class = require 'lib/middleclass'
require 'card'
require 'constants'


function Board:initialize(deck1, deck2)
	self.grid = {}
	for i = 1, B_LENGTH.x do
    	self.grid[i] = {}
    	for j = 1, B_LENGTH.y do
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

function get_Card_At(x, y)
	return self.grid[x][y]
end

function registerClick(mode, action)
	return
end

function move(from_x, from_y, to_x,to_y )
	self.grid[to_x][to_y] = self.grid[from_x][from_y]
end
