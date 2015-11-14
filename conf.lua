--[[

CONFIGURATIONS FILE FOR 5C HACKATHON F15

]]

require "constants"

function love.conf(t)
    t.title = "LABWS: A Scatalogical Sojourn Into Space"
    --t.version =
    t.window.width = c.SCREEN_W
    t.window.height = c.SCREEN_H
    t.modules.physics = false
    t.modules.mouse = true
    t.modules.joystick = false
    t.modules.sound = true
end
