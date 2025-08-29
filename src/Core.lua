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
    if msg == "debug" then
        LC.db.debug = not LC.db.debug
        print("Less Click: debug = " .. tostring(LC.db.debug))
    elseif msg == "on" then
        LC.db.enabled = true
        print("Less Click: enabled")
    elseif msg == "off" then
        LC.db.enabled = false
        print("Less Click: disabled")
    else
        print("|cff33ff99Less Click|r commands:")
        print("/lc on|off - 启用/禁用")
        print("/lc debug - 切换调试模式")
    end
end