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
	self.max_health = health
	self.c_attack = attack
	self.c_health = health
end

function Card:updateHP(val)
	self.c_health = self.c_health + val
	if self.c_health < 1 then
		self = nil
	elseif self.c_health > self.max_health then
		self.c_health = self.smax_health
	end
end

function Card:buff_Atk(val)
	self.c_attack = self.c_attack + val
end

function Card:buff_hp(val)
	self.max_health = self.max_health + val
	self.updateHP(val)
end

