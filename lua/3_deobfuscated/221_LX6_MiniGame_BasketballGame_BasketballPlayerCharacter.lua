local static_props = {
	QTE_STATUS = {
		EARLY_OR_LATE = 3,
		PERFECT = 1,
		NOT_BAD = 2
	}
}
gBasketballPlayerCharacter = DefClass("BasketballPlayerCharacter", gBasketballPlayerCharacter, gBasketballCharacter, static_props)
local BasketballPlayerCharacter = gBasketballPlayerCharacter

function BasketballPlayerCharacter:InitData(basketballRackList)
	BasketballPlayerCharacter.base.InitData(self, basketballRackList)
	self:SetPerfectSensitivity()

	self.playerIndex = 1
end

function BasketballPlayerCharacter:SetPerfectSensitivity()
	local basketballShootConfig = self:GetBasketballShootConfig()
	self.earlyRangePercent = basketballShootConfig.EarlyRange
	self.soSoRangePercent = basketballShootConfig.SoSoRange
	self.goodRangePercent = basketballShootConfig.GoodRange
	self.perfectRangePercent = basketballShootConfig.PerfectRange
	self.lateRangePercent = basketballShootConfig.LateRange
	local perfectSensitivity = gBasketballGameUtils.GetPerfectSensitivity()
	local reducePerfect = (1 - perfectSensitivity) * self.perfectRangePercent
	self.goodRangePercent = self.goodRangePercent + reducePerfect / 2
	self.lateRangePercent = self.lateRangePercent + reducePerfect / 2
	self.perfectRangePercent = self.perfectRangePercent - reducePerfect
	local perfectBeginPercent = self.earlyRangePercent + self.soSoRangePercent + self.goodRangePercent
	local perfectEndPercent = perfectBeginPercent + self.perfectRangePercent
	self.perfectBeginTime = self.totalShootTweenTime * perfectBeginPercent
	self.perfectEndTime = self.totalShootTweenTime * perfectEndPercent
	self.perfectPercent = perfectBeginPercent + self.perfectRangePercent / 2
	self.perfectTime = self.totalShootTweenTime * self.perfectPercent
end

function BasketballPlayerCharacter:GetAgentId()
	local fightSpiritId = gCS.MyPlayerManager.PlayerUnit.NpcId
	local fightSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(fightSpiritId)

	return fightSpiritCfg.AgentId
end

function BasketballPlayerCharacter:LoadCharacterModel()
	local sexType = gPlayerManager.infoLogin.bindData.sexType
	local agentId = self:GetAgentId()

	gCS.UnitsManager:GetDialogModelByAgentId(function (baseUnit, _)
		BasketballPlayerCharacter.base.OnCharacterLoadCompleted(self, baseUnit)

		if not self.hasDestroy then
			local virtualCamera = self.virtualCamera
			virtualCamera.Follow = baseUnit.ModelSlot.body

			virtualCamera.gameObject:SetActive(true)
		end
	end, sexType, agentId, false, true, true, gBattleSpiritMgr.currentSpiritTemplateId)
end

function BasketballPlayerCharacter:GetBasketballShootConfig()
	local agentId = self:GetAgentId()
	local agentCfg = LTConfig.AgentConfig.GetConfig(agentId)
	local modelId = agentCfg.GeneralModelId

	return gBasketballGameUtils.GetBasketballShootConfigByModelId(modelId)
end

function BasketballPlayerCharacter:ExecuteShootKeyDown()
	if self:CheckCanShoot() then
		self.hasShootFlag = true
		self.qteTimerValue = 0

		self:PlayShootAnimation()

		return true
	else
		self.hasShootFlag = nil
		self.qteTimerValue = nil
	end
end

function BasketballPlayerCharacter:ExecuteShootKeyLongPress()
	if self.qteTimerValue then
		local progress, qteStatus = nil
		self.qteTimerValue = self.qteTimerValue + Time.deltaTime

		if self.qteTimerValue <= self.perfectTime then
			progress = self.qteTimerValue / self.perfectTime
		elseif self.qteTimerValue <= self.perfectEndTime then
			progress = 1 - (self.qteTimerValue - self.perfectEndTime) / self.perfectTime
		elseif self.qteTimerValue <= self.totalShootTweenTime then
			local oriBegin = self.perfectEndTime
			local oriEnd = self.totalShootTweenTime
			local mapBegin = 1 - (self.perfectEndTime - self.perfectTime) / self.perfectTime
			local mapEnd = 0.5
			progress = self:MapQteTime(self.qteTimerValue, oriBegin, oriEnd, mapBegin, mapEnd)
		end

		if self.hasShootFlag and self.perfectEndTime <= self.qteTimerValue then
			self.hasShootFlag = nil
			qteStatus = BasketballPlayerCharacter.QTE_STATUS.EARLY_OR_LATE

			self:ExecuteShoot(self.totalShootTweenTime)
		end

		return progress, qteStatus
	end
end

function BasketballPlayerCharacter:MapQteTime(x, oriBegin, oriEnd, mapBegin, mapEnd)
	return mapBegin + (x - oriBegin) * (mapEnd - mapBegin) / (oriEnd - oriBegin)
end

function BasketballPlayerCharacter:ExecuteShootKeyUp()
	if not self.hasShootFlag then
		return nil
	end

	local qteStatus = nil

	if self.qteTimerValue < self.earlyRangePercent * self.totalShootTweenTime then
		local canCancelShoot = not self:IsPlayAnimation(self.animConst.sShoot) and not self:IsPlayAnimation(self.animConst.sPrepareShoot) and self.animator:IsInTransition(0)

		if canCancelShoot then
			qteStatus = BasketballPlayerCharacter.QTE_STATUS.EARLY_OR_LATE

			self.animator:SetBool(self.animConst.bCancelShoot, true)
		else
			print_warn("@liulijun04 动画已经播到投篮，但是 QTE 判定在过早区间")

			qteStatus = BasketballPlayerCharacter.QTE_STATUS.NOT_BAD
			local qteTimerValue = self.earlyRangePercent * self.totalShootTweenTime + 0.01
			self.autoShootCoroutine = coroutine.start(function ()
				coroutine.wait(self.perfectBeginTime - self.qteTimerValue)
				self:ExecuteShoot(qteTimerValue)
			end)
		end
	elseif self.qteTimerValue < self.perfectBeginTime then
		qteStatus = BasketballPlayerCharacter.QTE_STATUS.NOT_BAD
		local qteTimerValue = self.qteTimerValue
		self.autoShootCoroutine = coroutine.start(function ()
			coroutine.wait(self.perfectBeginTime - self.qteTimerValue)
			self:ExecuteShoot(qteTimerValue)
		end)
	elseif self.qteTimerValue <= self.perfectEndTime then
		qteStatus = BasketballPlayerCharacter.QTE_STATUS.PERFECT

		self:ExecuteShoot(self.qteTimerValue)
	else
		qteStatus = BasketballPlayerCharacter.QTE_STATUS.EARLY_OR_LATE
	end

	self.hasShootFlag = nil
	self.qteTimerValue = nil

	return qteStatus
end

function BasketballPlayerCharacter:OnExecuteShoot(shootType)
	BasketballPlayerCharacter.base.OnExecuteShoot(self, shootType)

	if shootType == gBasketballCharacter.SHOOT_TYPE.THREE then
		gMessageManager:SendMessage(gEventConstants.BASKETBALL_GAME_PLAYER_MAKE_PREFECT_SHOOT)
	end
end

function BasketballPlayerCharacter:ExecuteShoot(qteValue)
	local shootType = self:GetShootTypeByQteValue(qteValue)

	self:StartShoot(shootType, qteValue)
	self:SetPerfectSensitivity()
end

function BasketballPlayerCharacter:GetShootTypeByQteValue(qteValue)
	if gGmUtils.basketballGameShootType and gGmUtils.basketballGameShootType > 0 then
		return gGmUtils.basketballGameShootType
	end

	local tempRangeValue = self.earlyRangePercent * self.totalShootTweenTime

	if qteValue <= tempRangeValue then
		return self:GetShootTypeByHitRateList(LTConfig.PoiGameConfig.Basket_EarlyRate)
	end

	tempRangeValue = tempRangeValue + self.soSoRangePercent * self.totalShootTweenTime

	if qteValue <= tempRangeValue then
		return self:GetShootTypeByHitRateList(LTConfig.PoiGameConfig.Basket_SoSoRate)
	end

	tempRangeValue = tempRangeValue + self.goodRangePercent * self.totalShootTweenTime

	if qteValue <= tempRangeValue then
		return self:GetShootTypeByHitRateList(LTConfig.PoiGameConfig.Basket_GoodRate)
	end

	tempRangeValue = tempRangeValue + self.perfectRangePercent * self.totalShootTweenTime

	if qteValue <= tempRangeValue then
		return self:GetShootTypeByHitRateList(LTConfig.PoiGameConfig.Basket_PerfectRate)
	end

	return self:GetShootTypeByHitRateList(LTConfig.PoiGameConfig.Basket_LateRate)
end

function BasketballPlayerCharacter:SendRefreshViewMessage(shootType, basketballType, score, isValidTime, addBonus)
	local isClutchShot = score and self:CheckIsClutchShot(basketballType, score)
	local isBuzzerBeat = score and not isClutchShot and self:CheckIsBuzzerBeat(score)

	gMessageManager:SendMessage(gEventConstants.BASKETBALL_GAME_REFRESH_PLAYER_VIEW, {
		totalScore = self.score,
		currentScore = score,
		countdown = self.countdown,
		shootType = shootType,
		basketballType = basketballType,
		isBuzzerBeat = isBuzzerBeat,
		isClutchShot = isClutchShot,
		isValidTime = isValidTime,
		addBonus = addBonus
	})
end

function BasketballPlayerCharacter:ExecuteAfterShootLogic(shootType, basketballType, isValidTime)
	local score = gBasketballGameUtils.GetCurOriginalScoreByType(shootType)
	local resultScore, addBonus = gBasketballGameUtils.GetCurResultScore(basketballType, score, self.hasBonusBuff)

	if score > 0 and basketballType == gBasketball.BASKETBALL_TYPE.TIME and self.countdown > 0 then
		self.countdown = self.countdown + self.addTimeInterval
	end

	self.score = self.score + resultScore

	self:SendRefreshViewMessage(shootType, basketballType, score, isValidTime, addBonus)
	self:SendOnBallHitStim(shootType)

	self.hasBonusBuff = gBasketballGameUtils.CheckHasBonusBuff(shootType)
end

function BasketballPlayerCharacter:CheckShootConflict()
	return gBasketballGameManager.currentGame:CheckShootTimeConflict(true)
end

function BasketballPlayerCharacter:CheckIsBuzzerBeat(score)
	return self:IsGameOver() and score > 0
end

function BasketballPlayerCharacter:CheckIsClutchShot(basketballType, score)
	local resultScore = gBasketballGameUtils.GetCurResultScore(basketballType, score)
	local npcCharacter = gBasketballGameManager.currentGame:GetNpcCharacter()
	local npcScore = npcCharacter.score
	local isNpcGameOver = npcCharacter:IsGameOver()

	return self:IsGameOver() and isNpcGameOver and npcScore < self.score and npcScore >= self.score - resultScore
end

function BasketballPlayerCharacter:GameEnd()
	BasketballPlayerCharacter.base.GameEnd(self)
	gMessageManager:SendMessage(gEventConstants.BASKETBALL_GAME_PLAYER_OVER)
end
