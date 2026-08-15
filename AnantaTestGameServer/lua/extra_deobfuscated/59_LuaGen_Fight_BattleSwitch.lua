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
	Test1 = 2,
	Test5 = 6,
	Test4 = 5,
	Test3 = 4,
	Test2 = 3,
	Normal = 1
}
M.CurrentChangeSpiritMode = M.ChangeSpiritMode.Test4
M.SpecifiedEffectLevel = {
	Original = 2,
	Low = 5,
	High = 3,
	Middle = 4,
	None = 1
}
M.CustomSwitch = {
	{
		active = false,
		name = "协同反制(闪避反击)"
	},
	{
		active = false,
		name = "测试开关2"
	},
	{
		active = false,
		name = "测试开关3"
	},
	{
		active = false,
		name = "测试开关4"
	},
	{
		active = false,
		name = "测试开关5"
	},
	{
		active = false,
		name = "测试开关6"
	}
}
M.CurrentSpecifiedEffectLevel = M.SpecifiedEffectLevel.None
M.CurrentSpecifiedEffectPlatform = true

function M.SetCurrentSpecifiedEffect(level, isPC)
	M.CurrentSpecifiedEffectLevel = level
	M.CurrentSpecifiedEffectPlatform = isPC

	if M.CurrentSpecifiedEffectLevel == M.SpecifiedEffectLevel.None then
		gCS.EffectLoader.OverrideEffectLevel(false, nil, isPC)
	elseif M.CurrentSpecifiedEffectLevel == M.SpecifiedEffectLevel.Original then
		gCS.EffectLoader.OverrideEffectLevel(true, nil, isPC)
	elseif M.CurrentSpecifiedEffectLevel == M.SpecifiedEffectLevel.High then
		gCS.EffectLoader.OverrideEffectLevel(true, EffectLevel.HIGH, isPC)
	elseif M.CurrentSpecifiedEffectLevel == M.SpecifiedEffectLevel.Middle then
		gCS.EffectLoader.OverrideEffectLevel(true, EffectLevel.MIDDLE, isPC)
	elseif M.CurrentSpecifiedEffectLevel == M.SpecifiedEffectLevel.Low then
		gCS.EffectLoader.OverrideEffectLevel(true, EffectLevel.LOW, isPC)
	end
end

function M:GMSetCurrentSpecifiedEffect(level, isPC)
	M.SetCurrentSpecifiedEffect(level, isPC)
end

function M.SetCurrentSpecifiedEffectPlatform(isPC)
	M.SetCurrentSpecifiedEffect(M.CurrentSpecifiedEffectLevel, isPC)
end

function M.SetCurrentSpecifiedEffectLevel(level)
	M.SetCurrentSpecifiedEffect(level, M.CurrentSpecifiedEffectPlatform)
end

function M.OnChangeChangeSpiritMode()
	for i = 1, #gBattleSpiritMgr.battleSpiritList do
		if gBattleSwitch.CurrentChangeSpiritMode == gBattleSwitch.ChangeSpiritMode.Test4 then
			gClientToGameSceneDelegate:AskAddClientBuff(gBattleSpiritMgr.battleSpiritList[i].pid, LTConfig.BuffConfig.ChangeSkillIgnoreFightStateCheck)
		else
			gClientToGameSceneDelegate:AskRemoveClientBuff(gBattleSpiritMgr.battleSpiritList[i].pid, LTConfig.BuffConfig.ChangeSkillIgnoreFightStateCheck)
		end
	end
end

gBattleSwitch = M

return M
