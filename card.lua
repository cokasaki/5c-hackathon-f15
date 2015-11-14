--[[
THE CARD CLASS
]]

Card = class('Card')

-- set the cards attributes and stats
function Card:initialize(cost, attack, health, player)
	self.cost = cost
	self.attack = attack
	self.health = health
	self.player = player
	self.current_attack = attack
	self.current_health = health
end