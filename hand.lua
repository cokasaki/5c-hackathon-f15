--[[
THE HAND CLASS
]]

class = require 'lib/middleclass'

Hand = class('Hand')


function Hand:initialize(deck)
    self.cards = {}
    self.deck = deck
end

function Hand:draw_card()
    if #self.cards < 6 and not self.deck:empty() then
        table.insert(self.cards, self.deck:draw_card())
    end
end

function Hand:remove_card(card)
    table.remove(self.cards, card)
end

function Hand:size()
    return #self.cards
end