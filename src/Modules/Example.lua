-- LessClick/src/Modules/Example.lua
local ADDON_NAME = ...
local LC = _G[ADDON_NAME]

-- 这里放一个“减少点击”的示例：自动打开商人修理（仅示例，按需替换）
local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:SetScript("OnEvent", function()
    if not LC.db or not LC.db.enabled then return end
    if CanMerchantRepair and CanMerchantRepair() then
        RepairAllItems(false) -- 先用非公会资金
        LC.log("Auto repaired.")
    end
end)