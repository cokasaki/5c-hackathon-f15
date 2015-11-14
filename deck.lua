--[[
THE DECK CLASS
]]

class = require 'lib/middleclass'

Deck = class('Deck')


function Deck:initialize(deck)
    self.cards = deck
end

function Deck:draw_card()
    return table.remove()
end

function Deck:empty()
    return (#self.cards > 0)
end

function Deck:size()
    return #self.cards
end
