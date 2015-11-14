--[[
THE CARD CLASS
]]

class = require 'lib/middleclass'

Card = class('Card')

-- set the cards attributes and stats
function Card:initialize(cost, attack, health, player)
	self.cost = cost
	self.attack = attack
	self.health = health
	self.player = player
	self.c_attack = attack
	self.c_health = health
end