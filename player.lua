--[[
THE PLAYER CLASS
]]

require 'constants'

Player = class('Player')

-- Initializes the player

--num resources
-- 

function Player:initialize()
	self.width = c.B_LENGTH
end