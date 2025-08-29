-- LessClick/locale/enUS.lua
local L = {}
_G["LessClick_L"] = setmetatable(L, {
    __index = function(t, k) return rawget(t, k) or k end
})
L.Enabled = "Enabled"
L.Disabled = "Disabled"