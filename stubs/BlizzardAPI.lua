---@meta
-- 精简版 WoW API 声明桩，用于开发期智能提示（不会被打包）
-- 适配：Lua 5.1 / Retail + 旧版接口（Settings / InterfaceOptions_*）

-- 基础 UI 类型 ---------------------------------------------------------------

---@class UIObject : table

---@class Region : UIObject
---@class Frame : Region
local Frame = {}

---@class FontString : Region
local FontString = {}

---@class CheckButton : Frame
local CheckButton = {}

-- Frame API（节选）
---@param name string|nil
---@param layer string|nil
---@param inheritsFrom string|nil
---@return FontString
function Frame:CreateFontString(name, layer, inheritsFrom) end

---@param point string
---@param relativeTo UIObject|string|nil
---@param relativePoint string|nil
---@param xOfs number|nil
---@param yOfs number|nil
function Frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs) end

---@param scriptType string
---@param handler fun(self:Frame, ...) | nil
function Frame:SetScript(scriptType, handler) end

-- FontString API（节选）
---@param point string
---@param relativeTo UIObject|string|nil
---@param relativePoint string|nil
---@param xOfs number|nil
---@param yOfs number|nil
function FontString:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs) end

---@param text string
function FontString:SetText(text) end

-- CheckButton API（节选）
---@param checked boolean
function CheckButton:SetChecked(checked) end
---@return boolean
function CheckButton:GetChecked() end

---@class CheckButtonText : FontString
CheckButton.Text = CheckButton.Text or {}
---@param text string
function CheckButton.Text:SetText(text) end

-- 全局构造 ---------------------------------------------------------------

---@param frameType "Frame"|"Button"|"CheckButton"|string
---@param name string|nil
---@param parent Frame|nil
---@param template string|nil
---@return Frame|CheckButton
function CreateFrame(frameType, name, parent, template) end

-- C_Timer ----------------------------------------------------------------
C_Timer = C_Timer or {}

---@param seconds number
---@param callback fun()
function C_Timer.After(seconds, callback) end

-- Retail Settings API ----------------------------------------------------
Settings = Settings or {}

---@class SettingsCategory
---@field ID string

---@param frame Frame
---@param name string
---@return SettingsCategory
function Settings.RegisterCanvasLayoutCategory(frame, name) end

---@param category SettingsCategory
function Settings.RegisterAddOnCategory(category) end

---@param categoryID string
function Settings.OpenToCategory(categoryID) end

-- 旧版接口（InterfaceOptions_*）---------------------------------------------
---@param frame Frame
function InterfaceOptions_AddCategory(frame) end

---@param category Frame|string
function InterfaceOptionsFrame_OpenToCategory(category) end

-- 物品与装备 API（节选，供开发期提示）---------------------------------------
C_Item = C_Item or {}

---获取物品统计（包含空插槽计数等）
---@param itemLink string
---@param statTable table|nil
---@return table<string, number>|nil
function C_Item.GetItemStats(itemLink, statTable) end

---获取槽位信息
---@param slotName string
---@return number slotId, string texture
function GetInventorySlotInfo(slotName) end

---获取单位指定装备槽位的物品链接
---@param unit string
---@param slotId number
---@return string|nil itemLink
function GetInventoryItemLink(unit, slotId) end

---获取物品上第 index 个宝石的信息
---@param itemLink string
---@param index number
---@return string|nil gemName, string|nil gemLink
function GetItemGem(itemLink, index) end