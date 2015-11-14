--[[
THE CARD CLASS
]]

Card = class('Card')

-- set the cards attributes and stats
function Card:initialize(cost, attack, defense, health, player)
	self.cost = cost
	self.attack = attack
	self.defense = defense
	self.health = health
	self.player = player
	self.current_attack = attack
	self.current_health = health
end