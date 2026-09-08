-- Original chunk: @Lua\LuaGen\Fight\BattleSwitch.lua
-- Decompiled from: 00257_BattleSwitch.lua_abb3878d88d4.luajit

local EffectLevel = LX6.Quality.EffectLevel
local M = gBattleSwitch or {}
M.UseCShapeShield = false
M.ShanBiBreakTimeSwitch = false
M.FeiSuoAttackSwitch = true
M.JumpAttackSwitch = true
M.ChangeDodgeAttackSwitch = false
M.NormalAttackBreakSwitch = false
M.BasicAttackSwitch = true
M.FightSpiritBigSkillSwitch = true
M.ERCombinSwitch = false
M.ERCombinSwitch2 = false
M.SkillNotCDSwitch = false
M.ReplaceDodgeBtnToMindPower = false
M.ChangeSpiritMode = {
	["y\\xab\\xb1\\xbb\\xe7"] = 2,
	["y\\xab\\xb1\\xbb\\xe3"] = 6,
	["y\\xab\\xb1\\xbb\\xe2"] = 5,
	["y\\xab\\xb1\\xbb\\xe5"] = 4,
	["y\\xab\\xb1\\xbb\\xe4"] = 3,
	["2G\\x83\\x83\\x82M"] = 1
}
M.CurrentChangeSpiritMode = M.ChangeSpiritMode.Test4
M.SpecifiedEffectLevel = {
	["\\x84\\xa3\\xacc0\\xff?"] = 2,
	["\\xa2gq"] = 5,
	["R+zS"] = 3,
	["1A\\x95\\x8a\\x8fD"] = 4,
	["T-s^"] = 1
}
M.CustomSwitch = {
	{
		["K\\x85\\x87\\x95D"] = false,
		["t#p^"] = "\\x86h\\xa0\\xe0\"\\xd8\\xcd\\xe95m\\xf24\\xa8w\\xed\\xc1g\\x81\\xec\\xc2ˇ"
	},
	{
		["K\\x85\\x87\\x95D"] = false,
		["t#p^"] = "\\x846\\xb4\\xa4\\xc5%\\x99j\\xa1$\\xb3c\\xe4"
	},
	{
		["K\\x85\\x87\\x95D"] = false,
		["t#p^"] = "\\x846\\xb4\\xa4\\xc5%\\x99j\\xa1$\\xb3c\\xe5"
	},
	{
		["K\\x85\\x87\\x95D"] = false,
		["t#p^"] = "\\x846\\xb4\\xa4\\xc5%\\x99j\\xa1$\\xb3c\\xe2"
	},
	{
		["K\\x85\\x87\\x95D"] = false,
		["t#p^"] = "\\x846\\xb4\\xa4\\xc5%\\x99j\\xa1$\\xb3c\\xe3"
	},
	{
		["K\\x85\\x87\\x95D"] = false,
		["t#p^"] = "\\x846\\xb4\\xa4\\xc5%\\x99j\\xa1$\\xb3c\\xe0"
	}
}
M.CurrentSpecifiedEffectLevel = M.SpecifiedEffectLevel.None
M.CurrentSpecifiedEffectPlatform = true

M.SetCurrentSpecifiedEffect = function(level, isPC)
	M.CurrentSpecifiedEffectLevel = level
	M.CurrentSpecifiedEffectPlatform = isPC

	if M.CurrentSpecifiedEffectLevel ~= M.SpecifiedEffectLevel.None then
		gCS.EffectLoader.OverrideEffectLevel(false, nil, isPC)
	elseif M.CurrentSpecifiedEffectLevel ~= M.SpecifiedEffectLevel.Original then
		gCS.EffectLoader.OverrideEffectLevel(true, nil, isPC)
	elseif M.CurrentSpecifiedEffectLevel ~= M.SpecifiedEffectLevel.High then
		gCS.EffectLoader.OverrideEffectLevel(true, EffectLevel.HIGH, isPC)
	elseif M.CurrentSpecifiedEffectLevel ~= M.SpecifiedEffectLevel.Middle then
		gCS.EffectLoader.OverrideEffectLevel(true, EffectLevel.MIDDLE, isPC)
	elseif M.CurrentSpecifiedEffectLevel ~= M.SpecifiedEffectLevel.Low then
		gCS.EffectLoader.OverrideEffectLevel(true, EffectLevel.LOW, isPC)
	end
end

M.GMSetCurrentSpecifiedEffect = function(self, level, isPC)
	M.SetCurrentSpecifiedEffect(level, isPC)
end

M.SetCurrentSpecifiedEffectPlatform = function(isPC)
	M.SetCurrentSpecifiedEffect(M.CurrentSpecifiedEffectLevel, isPC)
end

M.SetCurrentSpecifiedEffectLevel = function(level)
	M.SetCurrentSpecifiedEffect(level, M.CurrentSpecifiedEffectPlatform)
end

M.OnChangeChangeSpiritMode = function()
	for i = 1, #gBattleSpiritMgr.battleSpiritList do
		if gBattleSwitch.CurrentChangeSpiritMode ~= gBattleSwitch.ChangeSpiritMode.Test4 then
			gClientToGameSceneDelegate:AskAddClientBuff(gBattleSpiritMgr.battleSpiritList[i].pid, LTConfig.BuffConfig.ChangeSkillIgnoreFightStateCheck)
		else
			gClientToGameSceneDelegate:AskRemoveClientBuff(gBattleSpiritMgr.battleSpiritList[i].pid, LTConfig.BuffConfig.ChangeSkillIgnoreFightStateCheck)
		end
	end
end

gBattleSwitch = M

return M
