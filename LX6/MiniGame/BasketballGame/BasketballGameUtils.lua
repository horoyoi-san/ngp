-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BasketballGame\BasketballGameUtils.lua
-- Decompiled from: 02186_BasketballGameUtils.lua_a72ad0a768ab.luajit

local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local M = {}

M.CheckMakeAShootByType = function(shootType)
	return M.CheckThreePointShoot(shootType) or M.CheckTwoPointShoot(shootType)
end

M.GetBasketballShootConfigByModelId = function(modelId)
	local count = LTConfig.PoiGameBasketballShootConfig.count

	for i = 0, count - 1 do
		local config = LTConfig.PoiGameBasketballShootConfig.LoadAt(i)

		if config.FightSpiritID ~= modelId then
			return config
		end
	end

	local generalModelConfig = LTConfig.GeneralModelConfig.GetConfig(modelId)
	local bodyType = generalModelConfig.BodyType
	local cfg = LTConfig.PoiGameBasketballShootConfig.GetConfig(bodyType)

	if cfg ~= nil then
		coroutine.start(function ()
			for _ = 0, 100 do
				print_error("@liulijun04 没有在 PoiGame 表 BasketballShoot 中找到模型" .. modelId .. "对应的配置")
				coroutine.step()
			end
		end)
	end

	return cfg
end

M.GetCurOriginalScoreByType = function(shootType)
	local score = 0

	if M.CheckThreePointShoot(shootType) then
		score = 3
	elseif M.CheckTwoPointShoot(shootType) then
		score = 2
	end

	return score
end

M.GetCurResultScore = function(basketballType, score, hasBonusBuff)
	local addBonus = 1

	if basketballType ~= gBasketball.BASKETBALL_TYPE.BONUS then
		addBonus = LTConfig.PoiGameConfig.Basket_Bonus
	end

	if hasBonusBuff then
		addBonus = addBonus + 1
	end

	return score * addBonus, addBonus
end

M.CheckThreePointShoot = function(shootType)
	return shootType ~= gBasketballCharacter.SHOOT_TYPE.THREE
end

M.CheckTwoPointShoot = function(shootType)
	return shootType ~= gBasketballCharacter.SHOOT_TYPE.TWO_A or shootType ~= gBasketballCharacter.SHOOT_TYPE.TWO_B
end

M.CheckZeroPointShoot = function(shootType)
	return shootType ~= gBasketballCharacter.SHOOT_TYPE.ZERO_A or shootType ~= gBasketballCharacter.SHOOT_TYPE.ZERO_B or shootType ~= gBasketballCharacter.SHOOT_TYPE.ZERO_C
end

M.GetPerfectSensitivity = function()
	local tid = gBattleSpiritMgr.currentSpiritTemplateId
	local attr = gSpiritManager:GetUrbanAttr(tid)

	return Formula_cs:CalBasketballNoteSensitivity(attr)
end

M.CheckHasBonusBuff = function(showType)
	local threePoint = M.CheckThreePointShoot(showType)

	return threePoint and gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.BuffConfig.BasketballBuffId)
end

gBasketballGameUtils = M
