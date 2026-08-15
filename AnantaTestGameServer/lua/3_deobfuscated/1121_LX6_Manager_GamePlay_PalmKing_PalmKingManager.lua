local M = {
	STATE = {
		END = 6,
		WAITTING = 5,
		PREPARE = 2,
		HITTING = 3,
		QTE = 4
	},
	HUD_TYPE = {
		PLAY = 2,
		END = 6,
		OPPOSITE_QTE = 7,
		WAIT = 4,
		ROUND = 0,
		DEFEND = 3,
		QTE = 5,
		CHANGE = 1
	},
	PALMKING_SIGNAL = {
		HIGHT = 2,
		END = 5,
		LOW = 4,
		START = 1,
		MID = 3
	},
	RESULT_TEXT = {
		DODGE = 3,
		NORMAL = 4,
		QTE_FAILED = 5,
		BRUISE = 2,
		DEFENCE_BROKEN = 1,
		NONE = 0
	},
	Config = {
		stunnedWaitTime = 2,
		soundFailId = 70601385,
		roundWaitTime = 1,
		soundSuccessId = 70601386,
		endGameTime = 3,
		startGameTime = 4
	}
}

function M:Init()
	self.playingGame = false

	self:InitConfig()
	gPalmKingNpc:Init()
	gPalmKingGamer:Init()
end

function M:InitConfig()
	self.Config.qteNumConfig = LTConfig.PoiGameConfig.Slap_qte_num
	self.Config.maxQTETime = LTConfig.PoiGameConfig.Slap_maxQteTime
	self.Config.waitHittingTime = LTConfig.PoiGameConfig.Slap_maxHit
	self.Config.qteFailBlood = LTConfig.PoiGameConfig.Slap_QteFailDmg
	self.Config.defenceBrokenBlood = LTConfig.PoiGameConfig.Slap_criticalDmg
	local cfg = LTConfig.PoiGameSlapAIConfig.GetConfig(gPalmKingInterface:GetSlapCfgId())
	self.Config.normalDefenceBlood = LTConfig.PoiGameConfig.Slap_normalDmg * cfg.AtkRate
end

function M:GameEnd()
	gPalmKingNpc:StopPlay()
	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = gPalmKingGamer.blood > 0
	})
	gPalmKingInterface:SetHudState(self.HUD_TYPE.WAIT)
	gPalmKingInterface:SetCamera(1, 3)
	self:SetTimer(function ()
		gPalmKingAction:ReturnToPosition()

		if self.waitTimer then
			self.waitTimer:Stop()

			self.waitTimer = nil
		end
	end, M.Config.endGameTime)
	self:ClearData()
end

function M:ClearData()
	gPalmKingInterface:SetCamera(1, -1)
	gPalmKingInterface:SetHudState(self.HUD_TYPE.END)
	gPanelManager:Close(gPanelId.S_PALM_KING_PANEL)

	self.nowState = self.STATE.END
	self.playingGame = false

	if self.waitUITimer then
		self.waitUITimer:Stop()

		self.waitUITimer = nil
	end
end

function M:SetTimer(callback, delay)
	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.waitTimer = Timer.New(callback, delay):Start()
end

function M:GameStart()
	self:SetTimer(function ()
		self:RoundStart(true)
	end, M.Config.startGameTime)
end

function M:RoundStart(isHit)
	self.isHit = isHit
	self.defenceDirection = 1
	self.isHeadDefence = false

	if isHit then
		gPalmKingGamer:StartPrepareHit()
		gPalmKingNpc:StartPrepareBeHit()
	else
		gPalmKingNpc:StartPrepareHit()
		gPalmKingGamer:StartPrepareBeHit()
	end

	gPalmKingInterface:SetHudState(isHit and self.HUD_TYPE.PLAY or self.HUD_TYPE.DEFEND)
	self:SetTimer(function ()
		self.playingGame = true
		self.nowState = self.STATE.PREPARE
		self.maxHitTime = self.Config.waitHittingTime
	end, M.Config.roundWaitTime)
end

function M:GameOver()
	if not self.playingGame then
		return
	end

	if gPalmKingGamer.blood <= 0 or gPalmKingNpc.blood <= 0 then
		self:GameEnd()
	else
		self:ChangePlayer()
	end
end

function M:Update(deltaTime)
	if not self.playingGame then
		return
	end

	self:UpdateState(deltaTime)
	gPalmKingNpc:Update(deltaTime)
end

function M:UpdateState(deltaTime)
	if self.nowState == self.STATE.PREPARE then
		self:UpdatePrepare(deltaTime)
	elseif self.nowState == self.STATE.HITTING then
		self:UpdateHitting(deltaTime)
	elseif self.nowState == self.STATE.QTE then
		self:UpdateQTEing(deltaTime)
	end
end

function M:UpdatePrepare(deltaTime)
	self.maxHitTime = self.maxHitTime - deltaTime
	self.waitHittingTime = self.Config.waitHittingTime

	if self.maxHitTime <= 0 then
		print_debug("准备时间已经过了，必须攻击")
		gPalmKingInterface:OnPalmBtnClick()
	end
end

function M:UpdateHitting(deltaTime)
	self.waitHittingTime = self.waitHittingTime - deltaTime

	if self.waitHittingTime <= 0 then
		print_debug("等待时间已经过了，还没防御 默认选择当前")
		gPalmKingInterface:OnPalmDefenceBtnClick()
	end
end

function M:UpdateQTEing(deltaTime)
	if self.maxQTETime > 0 then
		self.maxQTETime = self.maxQTETime - deltaTime

		gPalmKingInterface:SetQTEProgress(self.maxQTETime)

		if self.maxQTETime < 0 then
			print_debug("到时间了，qte失败")
			self:QtesResult(false)
		end
	end
end

function M:SyncHit(direction, force)
	if self.nowState ~= self.STATE.PREPARE then
		print_debug("错误时间 现在状态: " .. self.nowState)

		return
	end

	if self.nowState == self.STATE.HITTING then
		print_debug("已经在攻击状态，不能重复攻击")

		return
	end

	print_debug("攻击，方向: " .. direction .. ", 力量: " .. force)

	self.hitForce = force
	self.hitDirection = direction
	self.nowState = self.STATE.HITTING

	self:Result()
end

function M:SyncDefence(direction)
	self.defenceDirection = direction
end

function M:ChangePlayer()
	self.nowState = self.STATE.WAITTING

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	gPalmKingNpc:StopPlay()

	if self.isHit then
		gPalmKingInterface:SetHudState(self.HUD_TYPE.CHANGE)
	else
		gPalmKingInterface:SetHudState(self.HUD_TYPE.ROUND)
	end

	self:SetTimer(function ()
		print_debug("换人")
		self:RoundStart(not self.isHit)
	end, M.Config.roundWaitTime)
end

function M:BeginQTE()
	self:GenQTEList()

	self.maxQTETime = self.Config.maxQTETime

	print_debug("进入眩晕抵抗环节，需要完成 " .. self.qteCount .. " 个QTE")
	gPalmKingInterface:SetHudState(self.isHit and self.HUD_TYPE.OPPOSITE_QTE or self.HUD_TYPE.QTE)
end

function M:GenQTEList()
	self.nowState = self.STATE.QTE
	self.qteCount = self:GetQteNum()
	self.qtes = {}

	for i = 1, self.qteCount do
		self.qtes[i] = {
			success = false,
			direction = self:RandomQteDirection()
		}
	end

	self.nowQTEIndex = 1

	gPalmKingInterface:SetQTEList(self.qtes)
	gPalmKingNpc:SyncQtes(self.qtes)
end

function M:IsPerfectDodge()
	return self.defenceDirection == 1 and self.hitDirection == 2 or self.defenceDirection == 2 and self.hitDirection == 1 or self.defenceDirection == 3 and self.hitDirection == 4 or self.defenceDirection == 4 and self.hitDirection == 3
end

function M:IsDefenceBroken()
	return self.defenceDirection == 1 and self.hitDirection == 3 or self.defenceDirection == 3 and self.hitDirection == 1 or self.defenceDirection == 2 and self.hitDirection == 4 or self.defenceDirection == 4 and self.hitDirection == 2
end

function M:IsAbrade()
	return self.defenceDirection == 1 and self.hitDirection == 1 or self.defenceDirection == 4 and self.hitDirection == 1 or self.defenceDirection == 2 and self.hitDirection == 2 or self.defenceDirection == 3 and self.hitDirection == 2 or self.defenceDirection == 2 and self.hitDirection == 3 or self.defenceDirection == 3 and self.hitDirection == 3 or self.defenceDirection == 1 and self.hitDirection == 4 or self.defenceDirection == 4 and self.hitDirection == 4
end

function M:IsHeadDefence()
	local defender = self.isHit and gPalmKingNpc or gPalmKingGamer

	return defender:IsHeadDefence()
end

function M:GetQteNum()
	local cfg = self.Config.qteNumConfig
	local qteNum = 1

	for _, v in pairs(cfg) do
		if v.force <= self.hitForce then
			qteNum = v.num
		end
	end

	print_debug("Force: " .. self.hitForce .. ", QTE数量: " .. qteNum)

	return qteNum
end

function M:RandomQteDirection()
	local directions = {
		1,
		2,
		3,
		4
	}
	local index = math.random(1, #directions)

	return directions[index]
end

function M:SyncQteAction(direction)
	if self.nowState ~= self.STATE.QTE then
		print_debug("错误时间 现在状态: " .. self.nowState)

		return
	end

	print_debug("进行了qte操作" .. direction)
	self:CheckQTE(direction)
end

function M:CheckQTE(direction)
	local soundId = 0

	if direction == self.qtes[self.nowQTEIndex].direction then
		print_debug("QTE成功，方向: " .. direction .. "索引" .. self.nowQTEIndex)
		gPalmKingInterface:SetQTEPos(self.nowQTEIndex)

		self.qtes[self.nowQTEIndex].success = true

		gPalmKingInterface:RefreshQteList(self.qtes)

		if self.nowQTEIndex >= #self.qtes then
			self:QtesResult(true)
		end

		self.nowQTEIndex = self.nowQTEIndex + 1
		soundId = self.Config.soundSuccessId
	else
		print_debug("QTE失败，方向: " .. direction .. " 索引: " .. self.nowQTEIndex)
		self:QtesResult(false)

		soundId = self.Config.soundFailId
	end

	if not self.isHit then
		gSoundMgr:PlaySoundByTid(soundId)
	end
end

function M:QtesResult(success)
	self.nowState = self.STATE.END

	gPalmKingInterface:SetHudState(self.HUD_TYPE.WAIT)

	if success then
		print_debug("QTE成功")
		gPalmKingAction:StunnedDefend(self.hitDirection, self.isHit)
	else
		print_debug("QTE失败")
		gPalmKingAction:StunnedFallen(self.hitDirection, self.isHit)
		self:ApplyDamage(self.Config.qteFailBlood)
		gPalmKingInterface:SetMeHp(gPalmKingGamer.blood)
		gPalmKingInterface:SetOtherHp(gPalmKingNpc.blood)
		gPalmKingInterface:SetResultText(self.RESULT_TEXT.QTE_FAILED, self.Config.qteFailBlood)

		if self.isHit then
			gPalmKingNpc:StopPlay()
		end
	end
end

function M:Result()
	print_debug("攻击方向: " .. self.hitDirection .. ", 防御方向: " .. self.defenceDirection)

	local isPerfectDODGE = false
	local isQTE = false

	gPalmKingInterface:SetHudState(self.HUD_TYPE.WAIT)

	if self.isHit then
		gPalmKingNpc:BeHit(self.hitDirection, self.hitForce)
	end

	if self:IsDefenceBroken() and not self:IsHeadDefence() then
		print_debug("破防")

		isQTE = true

		self:ApplyDamage(self.Config.defenceBrokenBlood)
		self:HandleQTE()

		if self.Config.defenceBrokenBlood < 9999 then
			gPalmKingInterface:SetResultText(self.RESULT_TEXT.DEFENCE_BROKEN, self.Config.defenceBrokenBlood)
		end
	elseif self:IsPerfectDodge() and self:IsHeadDefence() then
		print_debug("完美闪避")

		self.nowState = self.STATE.END

		gPalmKingAction:Defend(self.hitDirection, self.isHit)
		gPalmKingInterface:SetResultText(self.RESULT_TEXT.DODGE, 0)

		isPerfectDODGE = true
	elseif self:IsAbrade() and self:IsHeadDefence() then
		print_debug("擦伤")

		self.nowState = self.STATE.END

		gPalmKingAction:Stunned(self.hitDirection, self.isHit)

		local damage = self.Config.normalDefenceBlood * 0.75

		self:ApplyDamage(damage)
		gPalmKingInterface:SetResultText(self.RESULT_TEXT.BRUISE, damage)
	else
		print_debug("普通命中")

		self.nowState = self.STATE.END

		gPalmKingAction:Stunned(self.hitDirection, self.isHit)
		self:ApplyDamage(self.Config.normalDefenceBlood)
		gPalmKingInterface:SetResultText(self.RESULT_TEXT.NORMAL, self.Config.normalDefenceBlood)
	end

	gPalmKingInterface:SetMeHp(gPalmKingGamer.blood)
	gPalmKingInterface:SetOtherHp(gPalmKingNpc.blood)

	if not isPerfectDODGE then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommonHeavy1", LX6.Audio.ExternalSourceType.Motion_2D)
	end
end

function M:ApplyDamage(damage)
	if self.isHit then
		gPalmKingNpc.blood = gPalmKingNpc.blood - damage
	else
		gPalmKingGamer.blood = gPalmKingGamer.blood - damage
	end
end

function M:HandleQTE()
	self.nowState = self.STATE.WAITTING

	gPalmKingAction:DefenceBroken(self.hitDirection, self.isHit)
	self:SetTimer(function ()
		if gPalmKingGamer.blood <= 0 or gPalmKingNpc.blood <= 0 then
			self.nowState = self.STATE.END

			gPalmKingAction:StunnedDefend(self.hitDirection, self.isHit)
		else
			self:BeginQTE()
		end
	end, self.Config.stunnedWaitTime)
end

function M:PalmKingAttackResultTask()
	print_debug("zxxx   PalmKingAttackResultTask")
end

function M:PalmKingChangeLeftLowerEndTask()
	print_debug("zxxx   PalmKingChangeLeftLowerEndTask")
end

function M:PalmKingChangeLeftUpperEndTask()
	print_debug("zxxx   PalmKingChangeLeftUpperEndTask")
end

function M:PalmKingChangeRightUpperEndTask()
	print_debug("zxxx   PalmKingChangeRightUpperEndTask")
end

function M:PalmKingChangeRightUpperEndTask()
	print_debug("zxxx   PalmKingChangeRightUpperEndTask")
end

function M:PalmKingReturnToPositionEndTask()
	print_debug("zxxx   PalmKingReturnToPositionEndTask")
end

function M:PalmKingDefenceBrokenEndTask()
	print_debug("zxxx   PalmKingDefenceBrokenEndTask")
	M:GameOver()
end

function M:PalmKingDefendEndTask()
	print_debug("zxxx   PalmKingDefendEndTask")
	M:GameOver()
end

function M:PalmKingStunnedEndTask()
	print_debug("zxxx   PalmKingStunnedEndTask")
	M:GameOver()
end

function M:PalmKingStunnedLoopEndTask()
	print_debug("zxxx   PalmKingStunnedLoopEndTask")
	M:GameOver()
end

gPalmKingManager = M
