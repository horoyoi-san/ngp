C_ScratchCardType2Store = DefClass("C_ScratchCardType2Store", C_ScratchCardType2Store, C_ScratchCardType1Store)
GroupName2Class.ScratchCardType2Store = C_ScratchCardType2Store
local M = C_ScratchCardType2Store

function M:GetShowCount()
	return 20
end

function M:GetMaxReward()
	return LTConfig.PoiGameConfig.ScratchType2MaxReward
end

function M:GetRewardTipsList()
	return LTConfig.PoiGameConfig.ScratchType2RewardTipsList
end
