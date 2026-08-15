local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local M = {}

function M.CheckMakeAShootByType(shootType)
	return M.CheckThreePointShoot(shootType) or M.CheckTwoPointShoot(shootType)
end

function M.GetBasketballShootConfigByModelId(modelId)
	local count = LTConfig.PoiGameBasketballShootConfig.count

	for i = 0, count - 1 do
		local config = LTConfig.PoiGameBasketballShootConfig.LoadAt(i)

		if config.FightSpiritID == modelId then
			return config
		end
	end

	local generalModelConfig = LTConfig.GeneralModelConfig.GetConfig(modelId)
	local bodyType = generalModelConfig.BodyType
	local cfg = LTConfig.PoiGameBasketballShootConfig.GetConfig(bodyType)

	if cfg == nil then
		coroutine.start(function ()
			for _ = 0, 100 do
				print_error("@liulijun04 没有在 PoiGame 表 BasketballShoot 中找到模型" .. modelId .. "对应的配置")
				coroutine.step()
			end
		end)
	end

	return cfg
end

function M.GetCurOriginalScoreByType(shootType)
	local score = 0

	if M.CheckThreePointShoot(shootType) then
		score = 3
	elseif M.CheckTwoPointShoot(shootType) then
		score = 2
	end

	return score
end

function M.GetCurResultScore(basketballType, score, hasBonusBuff)
	local addBonus = 1

	if basketballType == gBasketball.BASKETBALL_TYPE.BONUS then
		addBonus = LTConfig.PoiGameConfig.Basket_Bonus
	end

	if hasBonusBuff then
		addBonus = addBonus + 1
	end

	return score * addBonus, addBonus
end

function M.CheckThreePointShoot(shootType)
	return shootType == gBasketballCharacter.SHOOT_TYPE.THREE
end

function M.CheckTwoPointShoot(shootType)
	return shootType == gBasketballCharacter.SHOOT_TYPE.TWO_A or shootType == gBasketballCharacter.SHOOT_TYPE.TWO_B
end

function M.CheckZeroPointShoot(shootType)
	return shootType == gBasketballCharacter.SHOOT_TYPE.ZERO_A or shootType == gBasketballCharacter.SHOOT_TYPE.ZERO_B or shootType == gBasketballCharacter.SHOOT_TYPE.ZERO_C
end

function M.GetPerfectSensitivity()
	local tid = gBattleSpiritMgr.currentSpiritTemplateId
	local attr = gSpiritManager:GetUrbanAttr(tid)

	return Formula_cs:CalBasketballNoteSensitivity(attr)
end

function M.CheckHasBonusBuff(showType)
	local threePoint = M.CheckThreePointShoot(showType)

	return threePoint and gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.BuffConfig.BasketballBuffId)
end

gBasketballGameUtils = M
