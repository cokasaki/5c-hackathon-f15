--[[
THE DECK CLASS
]]

class = require 'lib/middleclass'

Deck = class('Deck')


function Deck:initialize(deck)
    self.cards = deck
end

function Deck:draw_card()
    index = math.random(1,#self.cards)
    to_return = table.remove(self.cards,index)
    return to_return
end

function Deck:empty()
    return #self.cards == 0
end

function Deck:size()
    return #self.cards
end
