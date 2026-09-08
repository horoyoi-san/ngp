-- Original chunk: @Lua\LuaFiles\LX6\Manager\WeaponSkinManager.lua
-- Decompiled from: 00316_WeaponSkinManager.lua_26a2072a38a2.luajit

local WeaponSkinConfig = LTConfig.WeaponSkinConfig
local WeaponSkinDefaultSkinConfig = LTConfig.WeaponSkinDefaultSkinConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local MessageConfig = LTConfig.MessageConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local WeaponSkinTextInfos = {
	CurrentCharacter = {
		[")\r"] = 89901542,
		Config = TextScriptTextConfig
	},
	AllCharacter = {
		[")\r"] = 89901543,
		Config = TextScriptTextConfig
	},
	AssignedCharacter = {
		[")\r"] = 89901544,
		Config = TextScriptTextConfig
	},
	CharacterRange = {
		[")\r"] = 89901545,
		Config = TextScriptTextConfig
	},
	WeaponRange = {
		[")\r"] = 89901546,
		Config = TextScriptTextConfig
	},
	AllWeaponType = {
		[")\r"] = 89901547,
		Config = TextScriptTextConfig
	},
	AssignedWeapon = {
		[")\r"] = 89901548,
		Config = TextScriptTextConfig
	},
	WeaponTransmog = {
		[")\r"] = 89901549,
		Config = TextScriptTextConfig
	},
	Melee = {
		[")\r"] = 89901554,
		Config = TextScriptTextConfig
	},
	Gun = {
		[")\r"] = 89901555,
		Config = TextScriptTextConfig
	},
	OutwardAppearance = {
		[")\r"] = 89901567,
		Config = TextScriptTextConfig
	},
	DefaultAppearance = {
		[")\r"] = 89901568,
		Config = TextScriptTextConfig
	},
	DefaultAppearanceDesc = {
		[")\r"] = 89901569,
		Config = TextScriptTextConfig
	},
	AllQuality = {
		[")\r"] = 89900400,
		Config = TextScriptTextConfig
	},
	Quality = {
		[")\r"] = 89900649,
		Config = TextScriptTextConfig
	},
	ApplyCharacterTip = {
		["N'pK"] = "\\x911\\xc8\\xe9\\xda\\xc0\\xa0\\xc51YɆ\\xceE1)\\x93\\xc1Y#\\xa84۝\\xbf\\xcdm;\\xa7"
	},
	SkinApplyAllRolesConfirm = {
		[")\r"] = 75109990,
		Config = MessageConfig
	},
	SkinApplyAllWeaponsConfirm = {
		[")\r"] = 75109991,
		Config = MessageConfig
	},
	SkinApplyAllConfirm = {
		[")\r"] = 75109992,
		Config = MessageConfig
	},
	SkinCancelApplied = {
		[")\r"] = 75109993,
		Config = MessageConfig
	},
	WeaponSkinApplied = {
		[")\r"] = 75109994,
		Config = MessageConfig
	}
}
gWeaponSkinManager = gWeaponSkinManager or {}
local M = gWeaponSkinManager

M.GetTextInfos = function(self)
	return WeaponSkinTextInfos
end

M.GetText = function(self, textInfo, ...)
	local text = ""

	if textInfo then
		if textInfo.Config and textInfo.Id then
			local cfg = textInfo.Config.GetConfig(textInfo.Id)

			if cfg then
				text = cfg.Content or cfg.Text or ""
			end
		end

		if text ~= "" and textInfo.Temp then
			text = textInfo.Temp
		end
	end

	if select("#", ...) <= 0 then
		return string.format(text, ...)
	end

	return text
end

M.AskSetWeaponSkins = function(self, spiritIds, sceneItemIds, skinId, callback)
	gClientToGameDelegate:AskSetWeaponSkins(spiritIds, sceneItemIds, skinId).Callback = function (err)
		if callback then
			callback(err)
		end
	end
end

M.AskSyncWeaponSkinToSpirits = function(self, sourceSpiritId, targetSpiritIds, callback)
	gClientToGameDelegate:AskSyncWeaponSkinToSpirits(sourceSpiritId, targetSpiritIds).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		if callback then
			callback(err)
		end
	end
end

M.GetSkinsByTemplate = function(self, sceneItemId)
	local result = {}

	for i = 0, WeaponSkinConfig.count - 1 do
		local cfg = WeaponSkinConfig.LoadAt(i)

		if cfg and cfg.SceneItemId ~= sceneItemId then
			table.insert(result, cfg)
		end
	end

	return result
end

M.GetDefaultSkinByTemplate = function(self, sceneItemId)
	local skins = self:GetSkinsByTemplate(sceneItemId)

	for _, cfg in ipairs(skins) do
		if cfg.IsDefault then
			return cfg
		end
	end

	return nil
end
