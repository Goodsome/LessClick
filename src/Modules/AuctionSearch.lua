-- LessClick/src/Modules/AuctionSearch.lua
-- 在拍卖行打开时，于界面右侧显示一个面板，并在底部中央放置“搜索”按钮

local ADDON_NAME = ...
local LC = _G[ADDON_NAME]

local AuctionModule = {}
LC.AuctionModule = AuctionModule

local panel -- 持有右侧面板

local function EnsureBlizzardAuctionUILoaded()
    if not IsAddOnLoaded or not UIParentLoadAddOn then return end
    if not IsAddOnLoaded("Blizzard_AuctionHouseUI") then
        pcall(UIParentLoadAddOn, "Blizzard_AuctionHouseUI")
    end
end

-- 默认搜索关键字（调试用）
local DEFAULT_SEARCH_TEXT = "卓越珠宝师的底座"

-- 触发拍卖行文本搜索（使用 Blizzard 自带搜索栏逻辑，兼容 11.2）
local function StartAHTextSearch(searchText)
    EnsureBlizzardAuctionUILoaded()
    local ah = _G.AuctionHouseFrame
    if not ah or not ah.SearchBar or not ah.SearchBar.SearchBox then
        return
    end
    searchText = (searchText and searchText ~= "") and searchText or DEFAULT_SEARCH_TEXT

    -- 写入搜索框文本
    ah.SearchBar.SearchBox:SetText(searchText)

    -- 优先点击搜索按钮
    local clicked = false
    if ah.SearchBar.SearchButton and ah.SearchBar.SearchButton:IsShown() and ah.SearchBar.SearchButton:IsEnabled() then
        ah.SearchBar.SearchButton:Click()
        clicked = true
    end

    -- 兼容：直接调用 StartSearch 或触发回车脚本
    if not clicked then
        if ah.SearchBar.StartSearch then
            ah.SearchBar:StartSearch(searchText)
            clicked = true
        else
            local onEnter = ah.SearchBar.SearchBox:GetScript("OnEnterPressed")
            if onEnter then onEnter(ah.SearchBar.SearchBox) end
        end
    end
end

-- =========================
-- 购物清单数据与列表 UI
-- =========================

-- 默认购物清单（可通过 SetShoppingList 覆盖）
local shoppingList = {
    { name = DEFAULT_SEARCH_TEXT, count = 1 },
}

-- 外部接口：设置购物清单
function AuctionModule.SetShoppingList(list)
    if type(list) == "table" then
        shoppingList = list
    else
        shoppingList = {}
    end
    if AuctionModule.RefreshList then
        AuctionModule.RefreshList()
    end
end

-- 列表行缓存
local listContainer
local listRows = {}
local MAX_ROWS = 10
local ROW_HEIGHT = 24
local ROW_GAP = 4

-- 构建列表区域与行
local function BuildListArea(parent)
    if listContainer then return end

    listContainer = CreateFrame("Frame", nil, parent)
    -- 位于标题下方，底部给按钮留白
    listContainer:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -44)
    listContainer:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -12, 48)

    for i = 1, MAX_ROWS do
        local row = CreateFrame("Frame", nil, listContainer)
        row:SetSize(1, ROW_HEIGHT)
        if i == 1 then
            row:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", listContainer, "TOPRIGHT", 0, 0)
        else
            row:SetPoint("TOPLEFT", listRows[i-1], "BOTTOMLEFT", 0, -ROW_GAP)
            row:SetPoint("TOPRIGHT", listRows[i-1], "BOTTOMRIGHT", 0, -ROW_GAP)
        end

        -- 放大镜按钮
        local btn = CreateFrame("Button", nil, row)
        btn:SetSize(18, 18)
        btn:SetPoint("LEFT", row, "LEFT", 0, 0)
        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints(true)
        tex:SetTexture("Interface\\COMMON\\UI-Searchbox-Icon")
        btn.tex = tex
        btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

        -- 名称（同时承载数量展示，如：物品名 * 2）
        local nameFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameFS:SetPoint("LEFT", btn, "RIGHT", 6, 0)
        nameFS:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        nameFS:SetJustifyH("LEFT")
        if nameFS.SetWordWrap then nameFS:SetWordWrap(false) end
        nameFS:SetText("")

        btn:SetScript("OnClick", function()
            if row.itemName and row.itemName ~= "" then
                StartAHTextSearch(row.itemName)
            end
        end)

        -- 在名称区域覆盖一个透明按钮：点击名称也可搜索
        local nameBtn = CreateFrame("Button", nil, row)
        nameBtn:SetPoint("TOPLEFT", btn, "TOPRIGHT", 6, 0)
        nameBtn:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
        nameBtn:SetScript("OnClick", function()
            if row.itemName and row.itemName ~= "" then
                StartAHTextSearch(row.itemName)
            end
        end)
        -- 可选：鼠标悬停高亮名称
        nameBtn:SetScript("OnEnter", function()
            nameFS:SetTextColor(1, 0.82, 0) -- 类似高亮色
        end)
        nameBtn:SetScript("OnLeave", function()
            nameFS:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
        end)

        row.nameFS = nameFS
        row.searchBtn = btn
        listRows[i] = row
    end
end

-- 刷新列表内容
local function RefreshListUI()
    if not listRows or #listRows == 0 then return end
    local items = shoppingList or {}
    for i = 1, MAX_ROWS do
        local row = listRows[i]
        local data = items[i]
        if data then
            row:Show()
            local itemName = data.name or data.itemName or ""
            local count = tonumber(data.count or data.qty or 0) or 0
            row.itemName = itemName
            local text = itemName
            if count and count > 0 then
                text = string.format("%s * %d", itemName, count)
            end
            row.nameFS:SetText(text)
            if row.searchBtn then row.searchBtn:SetEnabled(itemName ~= "") end
        else
            row.itemName = nil
            row.nameFS:SetText("")
            row:Hide()
        end
    end
end

AuctionModule.RefreshList = RefreshListUI

-- 从装备检查生成购物清单并刷新右侧列表
function AuctionModule.UpdateShoppingListFromEquipCheck()
    local equip = LC and LC.EquipCheck
    if not equip then return end

    local list = {}
    if equip.BuildEnchantShoppingList then
        list = equip.BuildEnchantShoppingList("player")
    end

    AuctionModule.SetShoppingList(list or {})
end

local function CreateRightPanel(parent)
    -- parent 为 AuctionHouseFrame；面板父级改为 UIParent，避免被拍卖行内部区域裁剪
    if not panel then
        panel = CreateFrame("Frame", "LessClickAHSidePanel", UIParent, "BackdropTemplate")
        panel:SetSize(320, 460)
        panel:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        if panel.SetBackdropColor then
            panel:SetBackdropColor(0, 0, 0, 0.6)
        end
        panel:SetFrameStrata("HIGH")
        if panel.SetClampedToScreen then panel:SetClampedToScreen(true) end

        -- 标题
        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 12, -12)
        title:SetText("Less Click 拍卖助手")

        -- 构建购物清单 UI
        BuildListArea(panel)
    end

    -- 每次确保重新锚定到拍卖行外部右侧
    panel:ClearAllPoints()
    panel:SetPoint("TOPLEFT", parent, "TOPRIGHT", 8, 0)

    -- 锚定后刷新列表展示
    if AuctionModule and AuctionModule.RefreshList then
        AuctionModule.RefreshList()
    end

    return panel
end

local function ShowPanel()
    EnsureBlizzardAuctionUILoaded()
    local parent = _G.AuctionHouseFrame
    if not parent then
        -- 极少数情况下框架尚未构建，稍后再试
        C_Timer.After(0.05, function()
            if _G.AuctionHouseFrame then
                CreateRightPanel(_G.AuctionHouseFrame):Show()
            end
        end)
        return
    end
    CreateRightPanel(parent):Show()
end

local function HidePanel()
    if panel then panel:Hide() end
end

-- 事件处理：打开/关闭拍卖行
local f = CreateFrame("Frame")
f:RegisterEvent("AUCTION_HOUSE_SHOW")
f:RegisterEvent("AUCTION_HOUSE_CLOSED")
f:SetScript("OnEvent", function(_, event)
    if event == "AUCTION_HOUSE_SHOW" then
        if LC and LC.db and LC.db.enabled then
            ShowPanel()
            if AuctionModule and AuctionModule.UpdateShoppingListFromEquipCheck then
                AuctionModule.UpdateShoppingListFromEquipCheck()
            end
        end
    elseif event == "AUCTION_HOUSE_CLOSED" then
        HidePanel()
    end
end)
