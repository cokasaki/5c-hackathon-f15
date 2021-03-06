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
	RedLeader = Card(0, 2, 10, 1, 'summoner')
	BlueLeader = Card(0, 2, 10, 2, 'summoner')
	RedLeader.canMove = true
	RedLeader.canAttack = true
	self.grid[1][3] = RedLeader
	self.grid[9][3] = BlueLeader

	self.turn = 1

	self.p1maxMana = 2
	self.p2maxMana = 3

	self.p1Mana = 2
	self.p2Mana = 3

	self.devMana = true

	self.selected = nil
	self.selectedType = nil

	self.p1Deck = deck1
	self.p1Hand = Hand(self.p1Deck)
	self.p1Hand:draw_card()
	self.p1Hand:draw_card()
	self.p1Hand:draw_card()

	self.p2Deck = deck2
	self.p2Hand = Hand(self.p2Deck)
	self.p2Hand:draw_card()
	self.p2Hand:draw_card()
	self.p2Hand:draw_card()

	self.winner = 0
end

function Board:get_card_at(point)
	return self.grid[point.x][point.y]
end

function Board:register_click(mode, target)
	if mode == "board" then
		if self.selected == nil and self.grid[target.x][target.y] then
			if self:get_card_at(target).player == self.turn then
				self.selected = target
				self.selectedType = "onBoard"
			end
		elseif self.selectedType == "onBoard" then
			if self:isLegalAttack(self.selected, target) then
				self:makeAttack(self.selected, target)
			elseif self:isLegalMove(self.selected, target) then
				self:move(self.selected, target)
			else
				self.selected = nil
				self.selectedType = nil
			end

		elseif self.selectedType == 'fromHand' then
			if self.turn == 1 then
				hand = self.p1Hand
			else
				hand = self.p2Hand
			end

			if hand.cards[self.selected].type == 'minion' then
				if self:canSummon(target, self.selected) then
					self:summon(self.selected, target)
					self.selected = nil
					self.selectedType = nil
				end

			else --handle spell
				if self:canCast(target, self.selected) then
					self:cast(self.selected, target)
				end
			self.selected = nil
			self.selectedType = nil
			end
		
		else
			self.selected = nil
			self.selectedType = nil
		end 

			
	elseif mode == "hand_one" then
		if self.turn == 1 then
			if self.selected == target and self.devMana and self.p1maxMana < 9 then
				self.p1maxMana = self.p1maxMana + 1
				self.devMana = false
				self.p1Hand:remove_card(target)
				self.selected = nil
				self.selectedType = nil
			else
				self.selected = target
				self.selectedType = 'fromHand'
			end
		end

	elseif mode == "hand_two" then
		if self.turn == 2 then
			if self.selected == target and self.devMana and self.p2maxMana < 9 then
				self.p2maxMana = self.p2maxMana + 1
				self.devMana = true
				self.p2Hand:remove_card(target)
				self.selected = nil
				self.selectedType = nil
			else
				self.selected = target
				self.selectedType = 'fromHand'
			end
		end
	elseif mode == "end_turn" then
		self:switchTurns()
	end
end

function Board:summon(index, target)
	if self.turn == 1 then
		hand = self.p1Hand
		card = hand.cards[index]
		self.p1Mana = self.p1Mana - card.cost
	else 
		hand = self.p2Hand
		card = hand.cards[index]
		self.p2Mana = self.p2Mana - card.cost

	end
	self.grid[target.x][target.y] = card
	hand:remove_card(index)
	self.selected = nil
end

-- Returns true if the spot target is empty
-- and if the player whose turn it is has
-- a card adjacent to the target square
function Board:canSummon(target, cardIndex)
	if self.turn == 1 then
		if self.p1Hand.cards[cardIndex].cost > self.p1Mana then
			return false
		end
	else
		if self.p2Hand.cards[cardIndex].cost > self.p2Mana then
			return false
		end
	end

	if self:get_card_at(target) then
		return false
	end

	for _,off in ipairs(c.ADJACENT) do
		x_pos = target.x + off.x
		y_pos = target.y + off.y
		to = {x = x_pos,y = y_pos}
		if self:onBoard(to) then
			-- Avoids trying to access member variable of nil variable
			if self.grid[to.x][to.y] then
				-- Checks to see if the current player has a card at this location
				if self.grid[to.x][to.y].player == self.turn then
					return true
				end
			end
		end
	end

	return false

end

function Board:cast(index, target)
	-- Only applies to minions
	-- check cost
	if self.turn == 1 then
		hand = self.p1Hand
		spellCard = hand.cards[index]
		self.p1Mana = self.p1Mana - spellCard.cost
	else
		hand = self.p2Hand
		spellCard = hand.cards[index]
		self.p2Mana = self.p2Mana - spellCard.cost
	end
	targetCard = self.grid[target.x][target.y]
	targetCard.attack = targetCard.attack + spellCard.attack
	targetCard.max_health = targetCard.max_health + spellCard.max_health
	targetCard.c_health = targetCard.c_health + spellCard.health
	
	hand:remove_card(index)
	self.selected = nil
	self.selectedType = nil
end

-- Returns true if the spot target is empty
-- and if the player whose turn it is has
-- a card adjacent to the target square
function Board:canCast(target, cardIndex)
	if self.turn == 1 then
		if self.p1Hand.cards[cardIndex].cost > self.p1Mana then
			return false
		end
	else
		if self.p2Hand.cards[cardIndex].cost > self.p2Mana then
			return false
		end
	end

	if not self:get_card_at(target) then
		return false
	end

	targetCard = self.grid[target.x][target.y]

	if targetCard.type == "minion" then
		return true
	end		

	return false

end

function Board:switchTurns()
	self.selected = nil
	self.selectedType = nil
	if self.turn == 1 then
		self.turn = 2
		self.p2Mana = self.p2maxMana
		self.p1Hand:draw_card()
		self.p1Hand:draw_card()
	else
		self.turn = 1
		self.p1Mana = self.p1maxMana
		board.p2Hand:draw_card()
		board.p2Hand:draw_card()
	end
	self.devMana = true
	for i = 1, c.B_LENGTH.x do
    	for j = 1, c.B_LENGTH.y do
       		if self.grid[i][j] then
       			if self.grid[i][j].player == self.turn then
       				self.grid[i][j].canMove = true
       				self.grid[i][j].canAttack = true
       			end
       		end
    	end
	end 
end

function Board:makeAttack(from, to)
	attacker = self.grid[from.x][from.y]
	defender = self.grid[to.x][to.y]

	defender:updateHP(-1*attacker.c_attack)
	attacker:updateHP(-1*defender.c_attack)

	if defender.c_health < 1 then
		if defender.type == 'summoner' then
			self.winner = self.turn
		end
		self.grid[to.x][to.y] = nil
	end

	if attacker.c_health < 1 then
		if attacker.type == 'summoner' then
			if self.winner ~= 0 then
				self.winner = 3
			else
				if self.turn == 1 then
					self.winner = 2
				else
					self.winner = 1
				end
			end
		end

		self.grid[from.x][from.y] = nil
	end

	attacker.canAttack = false
	attacker.canMove = false

	self.selected = nil
	self.selectedType = nil
end


function Board:move(from, to)
	cardToMove = self.grid[from.x][from.y]
	self.grid[to.x][to.y] = cardToMove
	cardToMove.canMove = false
	self.grid[from.x][from.y] = nil
	self.selected = nil
	self.selectedType = nil

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

function Board:getLegalAttacks(from)
	legalAttacks = {}
	for _,off in ipairs(c.ADJACENT) do
		x_pos = from.x + off.x
		y_pos = from.y + off.y
		target = {x = x_pos,y = y_pos}
		if self:isLegalAttack(from, target) then
			table.insert(legalAttacks,target)
		end
	end

	return legalAttacks
end

function Board:getLegalTargets()
	legalTargets = {}
	for i=1,c.B_LENGTH.x do
		for j=1,c.B_LENGTH.y do
			pos = {x=i,y=j}
			card = self:get_card_at(pos)
			if card then
				if card.player == board.turn then
					table.insert(legalTargets,pos)
				end
			end
		end
	end

	return legalTargets
end

function Board:getLegalPlacements()
	legalPlacements = {}
	for i=1,c.B_LENGTH.x do
		for j=1,c.B_LENGTH.y do
			pos = {x=i,y=j}
			card = self:get_card_at(pos)
			if not card then
				for _,off in ipairs(c.ADJACENT) do
					x_pos = pos.x + off.x
					y_pos = pos.y + off.y
					adj = {x = x_pos,y = y_pos}
					if self:onBoard(adj) then
						adjCard = self:get_card_at(adj)
						if adjCard then
							if adjCard.player == self.turn then
								table.insert(legalPlacements,pos)
								break
							end
						end
					end
				end
			end
		end
	end

	return legalPlacements
end


function Board:isLegalAttack(from, target)
	if self:onBoard(target) then
		if self.grid[target.x][target.y] then
			from_card = self:get_card_at(from)
			target_card = self:get_card_at(target)
			if not from_card.canAttack then
				return false 
			elseif from_card.player == target_card.player then
				return false
			else
				return math.abs(from.x - target.x) <= 1 and math.abs(from.y - target.y) <= 1
			end
		else
			return false
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
	if dist >= 1 and dist <=2 and not self.grid[to.x][to.y] and self:get_card_at(from).canMove then
	    return true
	else
	    return false
	end
end




