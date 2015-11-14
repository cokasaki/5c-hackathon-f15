--[[
THE SPELL CLASS
]]

require 'card'

Spell = class('Spell',Card)

function Spell:initialize(cost)
    self.cost = cost
end

--------------------

Damage = class('Damage', Spell)

functopm

--------------------

AOE_Damage