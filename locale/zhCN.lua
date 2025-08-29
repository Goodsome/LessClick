-- LessClick/locale/zhCN.lua
local L = _G["LessClick_L"] or {}
_G["LessClick_L"] = setmetatable(L, { __index = function(t, k) return rawget(t, k) or k end })
L.Enabled = "已启用"
L.Disabled = "已禁用"