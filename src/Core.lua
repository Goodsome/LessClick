local ADDON_NAME = ...
local LC = {}
_G[ADDON_NAME] = LC

LC.version = "@project-version@"

local defaults = {
    enabled = true,
    debug = false,
}

local function applyDefaults(dst, src)
    if type(dst) ~= "table" then dst = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = applyDefaults(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

local function log(msg, ...)
    if LC.db and LC.db.debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Less Click|r: " .. string.format(tostring(msg), ...))
    end
end
LC.log = log

-- 调试：检查装备附魔与宝石缺失并输出到聊天
function LC.DebugEquipCheck(unit)
    unit = unit or "player"
    if not LC or not LC.EquipCheck then
        print("Less Click: EquipCheck 模块未加载")
        return
    end
    local results = LC.EquipCheck.CheckMissingEnchantsAndGems(unit)
    local uname = UnitName and (UnitName(unit) or unit) or unit
    print(("|cff33ff99Less Click|r: EquipCheck -> %s"):format(uname))
    local any = false
    for _, e in ipairs(results) do
        if e.itemLink then
            local msgs = {}
            if e.missingEnchant then table.insert(msgs, "缺附魔") end
            if e.missingGemCount and e.missingGemCount > 0 then
                table.insert(msgs, ("缺宝石x%d"):format(e.missingGemCount))
            end
            if #msgs > 0 then
                any = true
                print(("- %s: %s %s"):format(e.displayName or e.slotName, table.concat(msgs, "/"), e.itemLink))
            end
        elseif e.empty then
            -- 如需提示未装备可取消注释
            -- print(("- %s: 未装备"):format(e.displayName or e.slotName))
        end
    end
    if not any then
        print(" - 所有可检查的部位均已完整（无缺失）")
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        if not LessClickDB then LessClickDB = {} end
        LessClickDB = applyDefaults(LessClickDB, defaults)
        LC.db = LessClickDB
        log("Initialized. Version %s", LC.version)
    elseif event == "PLAYER_LOGIN" then
        if LC.db.enabled then
            log("Enabled")
            -- TODO: 启用你的便捷功能
        end
    end
end)

SLASH_LESSCLICK1 = "/lessclick"
SLASH_LESSCLICK2 = "/lc"
SlashCmdList.LESSCLICK = function(msg)
    msg = (msg or ""):match("^%s*(.-)%s*$")
    local sub, arg = msg:match("^(%S+)%s*(.*)$")
    sub = sub or ""
    if sub == "debug" then
        LC.db.debug = not LC.db.debug
        print("Less Click: debug = " .. tostring(LC.db.debug))
    elseif sub == "on" then
        LC.db.enabled = true
        print("Less Click: enabled")
    elseif sub == "off" then
        LC.db.enabled = false
        print("Less Click: disabled")
    elseif sub == "ec" or sub == "equip" or sub == "equipcheck" then
        local unit = (arg and arg ~= "") and arg or "player"
        if not LC.DebugEquipCheck then
            print("Less Click: DebugEquipCheck 未就绪")
        else
            LC.DebugEquipCheck(unit)
        end
    else
        print("|cff33ff99Less Click|r commands:")
        print("/lc on|off - 启用/禁用")
        print("/lc debug - 切换调试模式")
        print("/lc ec [unit] - 检查装备缺少的附魔与宝石（默认 player）")
    end
end