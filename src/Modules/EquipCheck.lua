-- 装备检查模块：检测部位是否缺少附魔、宝石
-- API:
--   EquipCheck.CheckMissingEnchantsAndGems(unit) -> results(table)
--     results 为数组，每个元素包含：
--       {
--         slotId = number,
--         slotName = string,         -- UI 槽位名（例如 "HeadSlot"）
--         displayName = string,      -- 本地化后的槽位名称（例如 "头部"）
--         itemLink = string|nil,
--         missingEnchant = boolean,
--         missingGemCount = number,  -- 缺少的宝石数量（0 表示不缺）
--         totalSockets = number,     -- 物品上总的槽位数
--         filledGems = number        -- 已镶嵌宝石数
--       }

local EquipCheck = {}

-- 将模块绑定到主命名空间，供其他文件调用
local ADDON_NAME = ...
local LC = _G[ADDON_NAME]
if LC then
    LC.EquipCheck = EquipCheck
end

local ENCHANTABLE_SLOTS = {
    HeadSlot = false,
    NeckSlot = false,
    ShoulderSlot = false,
    BackSlot = true,
    ChestSlot = true,
    ShirtSlot = false,
    TabardSlot = false,
    WristSlot = true,
    HandsSlot = false,
    WaistSlot = false,
    LegsSlot = true,
    FeetSlot = true,
    Finger0Slot = true,
    Finger1Slot = true,
    Trinket0Slot = false,
    Trinket1Slot = false,
    MainHandSlot = true,
    SecondaryHandSlot = true,
}

local RECOMMEND_ENCHANTMENT_FOR_SLOTS = {
    BackSlot = "附魔披风 - 吸血尖牙之诵",
    ChestSlot = "附魔胸甲 - 晶脉辉煌",
    WristSlot = "附魔护腕 - 装甲闪避低语",
    LegsSlot = "雷缚护甲片",
    FeetSlot = "附魔靴子 - 斥候进击",
    Finger0Slot = "附魔戒指 - 绚灿精通",
    Finger1Slot = "附魔戒指 - 绚灿精通",
    MainHandSlot = "附魔武器 - 圣誓之韧",
    SecondaryHandSlot = "附魔武器 - 圣誓之韧",
}

-- 扫描的槽位顺序
local SLOT_ORDER = {
    "HeadSlot","NeckSlot","ShoulderSlot","BackSlot","ChestSlot","ShirtSlot","TabardSlot",
    "WristSlot","HandsSlot","WaistSlot","LegsSlot","FeetSlot",
    "Finger0Slot","Finger1Slot","Trinket0Slot","Trinket1Slot",
    "MainHandSlot","SecondaryHandSlot",
}

local function GetSlotIdAndDisplayName(slotName)
    local slotId, texture = GetInventorySlotInfo(slotName)
    -- _G["HEADSLOT"] 这类全局通常用于纸娃娃 UI，但这里用 slotName 自己映射更稳妥
    -- 尝试通过 _G[slotName] 获得 localized name（某些版本没有）
    local display = _G[slotName] or slotName
    return slotId, display
end

local function GetItemLink(unit, slotId)
    return GetInventoryItemLink(unit, slotId)
end

-- 从物品链接中解析附魔 ID（为空或 0 视为无附魔）
local function GetEnchantIdFromLink(itemLink)
    if not itemLink then return nil end
    -- 物品链接格式：|cff...|Hitem:itemId:enchantId:gem1:gem2:gem3:gem4:...|h[name]|h|r
    local enchantStr = itemLink:match("item:%d+:(%-?%d*):")
    if enchantStr and enchantStr ~= "" then
        local n = tonumber(enchantStr)
        if n and n > 0 then
            return n
        end
    end
    return nil
end

-- 统计物品上的总插槽数（包括各类型空插槽）
local function GetTotalSocketCount(itemLink)
    if not itemLink then return 0 end
    -- Dragonflight 及以后：使用 C_Item.GetItemStats；向下兼容旧版全局 GetItemStats
    local stats
    if C_Item and C_Item.GetItemStats then
        stats = C_Item.GetItemStats(itemLink)
    elseif GetItemStats then
        stats = GetItemStats(itemLink)
    end
    if not stats then return 0 end

    local total = 0
    for k, v in pairs(stats) do
        if type(k) == "string" and k:find("EMPTY_SOCKET") and type(v) == "number" then
            total = total + v
        end
    end
    return total
end

-- 统计已镶嵌宝石数
local function GetFilledGemCount(itemLink)
    if not itemLink then return 0 end
    local filled = 0
    -- 最多检查前 4 个宝石位（大多数物品不超过 3-4）
    for i = 1, 4 do
        local gemName, gemLink = GetItemGem(itemLink, i)
        if gemLink ~= nil and gemLink ~= "" then
            filled = filled + 1
        end
    end
    return filled
end

-- 检测单个槽位的附魔与宝石缺失情况
local function InspectSlot(unit, slotName)
    local slotId, displayName = GetSlotIdAndDisplayName(slotName)
    if not slotId then
        return {
            slotId = nil,
            slotName = slotName,
            displayName = displayName,
            itemLink = nil,
            missingEnchant = false,
            missingGemCount = 0,
            totalSockets = 0,
            filledGems = 0,
            error = "InvalidSlot",
        }
    end

    local link = GetItemLink(unit, slotId)
    if not link then
        -- 槽位为空：不判定缺失（交由上层决定是否提示“未装备”）
        return {
            slotId = slotId,
            slotName = slotName,
            displayName = displayName,
            itemLink = nil,
            missingEnchant = false,
            missingGemCount = 0,
            totalSockets = 0,
            filledGems = 0,
            empty = true,
        }
    end

    -- 附魔检测
    local shouldEnchant = ENCHANTABLE_SLOTS[slotName] == true
    local enchantId = GetEnchantIdFromLink(link)
    local missingEnchant = shouldEnchant and (not enchantId)

    -- 宝石检测
    local totalSockets = GetTotalSocketCount(link)
    local filledGems = GetFilledGemCount(link)
    local missingGemCount = 0
    if totalSockets > 0 then
        missingGemCount = math.max(0, totalSockets - filledGems)
    end

    return {
        slotId = slotId,
        slotName = slotName,
        displayName = displayName,
        itemLink = link,
        missingEnchant = missingEnchant,
        missingGemCount = missingGemCount,
        totalSockets = totalSockets,
        filledGems = filledGems,
    }
end

-- 对外方法：检查一个单位（默认 player）所有槽位的缺失情况
function EquipCheck.CheckMissingEnchantsAndGems(unit)
    unit = unit or "player"
    local results = {}

    for _, slotName in ipairs(SLOT_ORDER) do
        local info = InspectSlot(unit, slotName)
        table.insert(results, info)
    end

    return results
end

-- 可选：提供一个便捷方法，只返回缺失项，便于直接生成购物清单
function EquipCheck.GetMissingList(unit)
    local all = EquipCheck.CheckMissingEnchantsAndGems(unit)
    local missing = {}
    for _, e in ipairs(all) do
        if e.itemLink and (e.missingEnchant or e.missingGemCount > 0) then
            table.insert(missing, e)
        end
    end
    return missing
end

-- 新增：根据缺失附魔生成购物清单（按推荐表聚合数量）
function EquipCheck.BuildEnchantShoppingList(unit)
    unit = unit or "player"
    local list = {}
    local missing = EquipCheck.GetMissingList and EquipCheck.GetMissingList(unit) or {}
    local counts = {}

    for _, e in ipairs(missing) do
        if e.missingEnchant then
            local rec = RECOMMEND_ENCHANTMENT_FOR_SLOTS and RECOMMEND_ENCHANTMENT_FOR_SLOTS[e.slotName]
            if rec then
                counts[rec] = (counts[rec] or 0) + 1
            end
        end
    end

    for name, c in pairs(counts) do
        table.insert(list, { name = name, count = c })
    end
    table.sort(list, function(a, b) return (a.name or "") < (b.name or "") end)
    return list
end

-- 将模块导出到你的命名空间
-- 例如：你的主文件里有 MyAddon = MyAddon or {}
-- 然后把这个模块赋给它：
-- MyAddon.EquipCheck = EquipCheck

return EquipCheck