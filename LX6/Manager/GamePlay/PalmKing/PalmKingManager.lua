-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\PalmKing\PalmKingManager.lua
-- Decompiled from: 02227_PalmKingManager.lua_fabdaab25fb4.luajit

local M = {
	STATE = {
		["\\xabFB"] = 6,
		["\\x9c\\x90,\\x9f^\\xd0"] = 5,
		["\\xe9\\xe91-?\\xd4"] = 2,
		["\\xf1\\xf2 )7\n\\xd6"] = 3,
		["\\xbf\\C"] = 4
	},
	HUD_TYPE = {
		["J\\b"] = 2,
		["\\xabFB"] = 6,
		["@F\\x9cX\\x9b\\xc6bUKJi"] = 7,
		["MTo"] = 4,
		["\\x81\\x97\\x81\\x92"] = 0,
		["8m\\xb7\\xab\\xade"] = 3,
		["\\xbf\\C"] = 5,
		["?`\\xb0\\xa0\\xa4d"] = 1
	},
	PALMKING_SIGNAL = {
		["e\\x87\\x85\\x87\\x82"] = 2,
		["\\xabFB"] = 5,
		["\\xa2GQ"] = 4,
		["~\\x9a\\x83\\x9d\\x82"] = 1,
		["\\xa3AB"] = 3
	},
	RESULT_TEXT = {
		["i\\x81\\x86\\x88\\x93"] = 3,
		["2g\\xa3\\xa3\\xa2m"] = 4,
		["bn낢)\\x91(\\xec\\xcc"] = 5,
		[">z\\xa4\\xa7\\xb0d"] = 2,
		["ÿ7\\xc922\\xc3$Ⱥ©"] = 1,
		["T\rS~"] = 0
	},
	Config = {
		["\\x8c;51|\\xbb@\\xd0;\\x83\\xbd"] = 70601385,
		["5#\"\\xf6r\\x8c\\xf2\\xba:\\xef\\xe1\\xe3]\\xff"] = 70350038,
		["zTz\\x8dK\\xf4F?oSgs\\xf22{\\xdcE"] = 70350040,
		["\\x9a:$y\\x90D\\xed>\\xa7\\xbc"] = 3,
		["0>5\\xea}\\x9d\\xf3\\xa9&\\xf2\\xc6\\xefy\\xfe"] = 2,
		["\\xecJ\"\\xe7\\xbfU\\x95_\\xbd\\xb3"] = 1,
		["\\xf4\\x95\\xe2\"\\xf3\\xe9\\x8d\\xfe\\x91\t,"] = 70650472,
		["5#\"\\xf6r\\x8c\\xf2\\xa7=\\xeb\\xf3\\xea]\\xff"] = 70350039,
		["\\xf7^>\\xf7\\xbbD\\x95_\\xbd\\xb3"] = 4
	}
}

M.Init = function(self)
	self:StopQTEResultTimer()

	self.playingGame = false

	self:InitConfig()
	gPalmKingNpc:Init()
	gPalmKingGamer:Init()
end

M.InitConfig = function(self)
	self.Config.qteNumConfig = LTConfig.PoiGameConfig.Slap_qte_num
	self.Config.maxQTETime = LTConfig.PoiGameConfig.Slap_maxQteTime
	self.Config.waitHittingTime = LTConfig.PoiGameConfig.Slap_maxHit
	self.Config.qteFailBlood = LTConfig.PoiGameConfig.Slap_QteFailDmg
	self.Config.bruiseRate = LTConfig.PoiGameConfig.Slap_bruiseRate
	self.Config.normalRate = LTConfig.PoiGameConfig.Slap_normalRate
	self.Config.defenceBrokenRate = LTConfig.PoiGameConfig.Slap_defenceBrokenRate
	self.Config.aiNormalForceMin = LTConfig.PoiGameConfig.Slap_aiNormalForceMin
	self.Config.aiNormalForceMax = LTConfig.PoiGameConfig.Slap_aiNormalForceMax
	self.Config.aiPerfectForceMax = LTConfig.PoiGameConfig.Slap_aiPerfectForceMax
	local cfg = LTConfig.PoiGameSlapAIConfig.GetConfig(gPalmKingInterface:GetSlapCfgId())
	self.Config.normalDefenceBlood = LTConfig.PoiGameConfig.Slap_normalDmg * cfg.AtkRate
end

M.GenAiDamageFactor = function(self)
	local perfectRate = gPalmKingNpc.Config.perfectRate or 0

	if math.random() >= perfectRate then
		local lo = self.Config.aiNormalForceMax
		local hi = self.Config.aiPerfectForceMax

		return lo + math.random() * (hi - lo)
	else
		local lo = self.Config.aiNormalForceMin
		local hi = self.Config.aiNormalForceMax

		return lo + math.random() * (hi - lo)
	end
end

M.CalcDefenceDamage = function(self, rate)
	local damage = self.Config.normalDefenceBlood * rate

	if not self.isHit then
		damage = damage * self.GenAiDamageFactor(self)
	end

	return damage
end

M.GameEnd = function(self)
	gPalmKingNpc:StopPlay()

	slot1 = gPanelManager

	slot1:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = gPalmKingGamer.blood >= 0
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

M.ClearData = function(self)
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

M.SetTimer = function(self, callback, delay)
	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.waitTimer = Timer.New(callback, delay):Start()
end

M.StopQTEResultTimer = function(self)
	if self.qteResultTimer then
		self.qteResultTimer:Stop()

		self.qteResultTimer = nil
	end
end

M.GameStart = function(self)
	self.SetTimer(self, function ()
		self:RoundStart(true)
	end, M.Config.startGameTime)
end

M.RoundStart = function(self, isHit)
	gPanelManager:Close(gPanelId.S_CHALLENGE_FRONT_COUNTDOWN_PANEL)

	self.isHit = isHit
	self.defenceDirection = 1
	self.isHeadDefence = false

	if isHit then
		gPalmKingGamer:StartPrepareHit()
		gPalmKingNpc:StartPrepareBeHit()
		gPanelManager:CheckShow(gPanelId.S_CHALLENGE_FRONT_COUNTDOWN_PANEL, {
			["\\x96'0m\\x93U\\xfd8\\xbd\\xb7"] = true,
			countDownSecondNum = self.Config.waitHittingTime + M.Config.roundWaitTime
		})
	else
		gPalmKingNpc:StartPrepareHit()
		gPalmKingGamer:StartPrepareBeHit()
	end

	slot2 = gPalmKingInterface

	slot2:SetHudState(isHit and self.HUD_TYPE.PLAY or self.HUD_TYPE.DEFEND)
	self:SetTimer(function ()
		self.playingGame = true
		self.nowState = self.STATE.PREPARE
		self.maxHitTime = self.Config.waitHittingTime
	end, M.Config.roundWaitTime)
end

M.GameOver = function(self)
	if not self.playingGame then
		return
	end

	if gPalmKingGamer.blood > 0 or gPalmKingNpc.blood < 0 then
		self.GameEnd(self)
	else
		self.ChangePlayer(self)
	end
end

M.Update = function(self, deltaTime)
	if not self.playingGame then
		return
	end

	self:UpdateState(deltaTime)
	gPalmKingNpc:Update(deltaTime)
end

M.UpdateState = function(self, deltaTime)
	if self.nowState ~= self.STATE.PREPARE then
		self.UpdatePrepare(self, deltaTime)
	elseif self.nowState ~= self.STATE.HITTING then
		self.UpdateHitting(self, deltaTime)
	elseif self.nowState ~= self.STATE.QTE then
		self.UpdateQTEing(self, deltaTime)
	end
end

M.UpdatePrepare = function(self, deltaTime)
	self.maxHitTime = self.maxHitTime - deltaTime
	self.waitHittingTime = self.Config.waitHittingTime

	if self.maxHitTime < 0 then
		print_debug("准备时间已经过了，必须攻击")
		gPalmKingInterface:OnExecuteAttack()
	end
end

M.UpdateHitting = function(self, deltaTime)
	self.waitHittingTime = self.waitHittingTime - deltaTime

	if self.waitHittingTime < 0 then
		print_debug("等待时间已经过了，还没防御 默认选择当前")
		gPalmKingInterface:OnPalmDefenceBtnClick()
	end
end

M.UpdateQTEing = function(self, deltaTime)
	if self.maxQTETime <= 0 then
		self.maxQTETime = self.maxQTETime - deltaTime

		gPalmKingInterface:SetQTEProgress(self.maxQTETime)

		if self.maxQTETime < 0 then
			print_debug("到时间了，qte失败")
			self.ResolveQTE(self, false)
		end
	end
end

M.SyncHit = function(self, direction, force)
	if self.nowState == self.STATE.PREPARE then
		print_debug("错误时间 现在状态: " .. self.nowState)

		return
	end

	if self.nowState ~= self.STATE.HITTING then
		print_debug("已经在攻击状态，不能重复攻击")

		return
	end

	print_debug("攻击，方向: " .. direction .. ", 力量: " .. force)

	self.hitForce = force
	self.hitDirection = direction
	self.nowState = self.STATE.HITTING

	self.Result(self)
end

M.SyncDefence = function(self, direction)
	self.defenceDirection = direction
end

M.ChangePlayer = function(self)
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

	self.SetTimer(self, function ()
		print_debug("换人")
		self:RoundStart(not self.isHit)
	end, M.Config.roundWaitTime)
end

M.BeginQTE = function(self)
	self:GenQTEList()

	self.maxQTETime = self.Config.maxQTETime

	print_debug("进入眩晕抵抗环节，需要完成 " .. self.qteCount .. " 个QTE")
	gPalmKingInterface:SetHudState(self.isHit and self.HUD_TYPE.OPPOSITE_QTE or self.HUD_TYPE.QTE)
end

M.GenQTEList = function(self)
	self.nowState = self.STATE.QTE
	self.qteCount = self.GetQteNum(self)
	self.qtes = {}

	for i = 1, self.qteCount do
		self.qtes[i] = {
			["\\xca\\xce7\\xe2"] = false,
			direction = self.RandomQteDirection(self)
		}
	end

	self.nowQTEIndex = 1

	gPalmKingInterface:SetQTEList(self.qtes)
	gPalmKingNpc:SyncQtes(self.qtes)
end

M.IsSameDirection = function(self)
	return self.defenceDirection ~= 1 and self.hitDirection ~= 1 or self.defenceDirection ~= 2 and self.hitDirection ~= 2 or self.defenceDirection ~= 3 and self.hitDirection ~= 3 or self.defenceDirection ~= 4 and self.hitDirection ~= 4
end

M.IsDiagonal = function(self)
	return self.defenceDirection ~= 1 and self.hitDirection ~= 4 or self.defenceDirection ~= 3 and self.hitDirection ~= 2 or self.defenceDirection ~= 2 and self.hitDirection ~= 3 or self.defenceDirection ~= 4 and self.hitDirection ~= 1
end

M.IsAdjacent = function(self)
	return self.defenceDirection ~= 1 and self.hitDirection ~= 2 or self.defenceDirection ~= 1 and self.hitDirection ~= 3 or self.defenceDirection ~= 2 and self.hitDirection ~= 1 or self.defenceDirection ~= 2 and self.hitDirection ~= 4 or self.defenceDirection ~= 3 and self.hitDirection ~= 1 or self.defenceDirection ~= 3 and self.hitDirection ~= 4 or self.defenceDirection ~= 4 and self.hitDirection ~= 2 or self.defenceDirection ~= 4 and self.hitDirection ~= 3
end

M.IsHeadDefence = function(self)
	local defender = self.isHit and gPalmKingNpc or gPalmKingGamer

	return defender:IsHeadDefence()
end

M.GetQteNum = function(self)
	local cfg = self.Config.qteNumConfig
	local qteNum = 1

	for _, v in pairs(cfg) do
		if v.force < self.hitForce then
			qteNum = v.num
		end
	end

	print_debug("Force: " .. self.hitForce .. ", QTE数量: " .. qteNum)

	return qteNum
end

M.RandomQteDirection = function(self)
	local directions = {
		1,
		2,
		3,
		4
	}
	local index = math.random(1, #directions)

	return directions[index]
end

M.SyncQteAction = function(self, direction)
	if self.nowState == self.STATE.QTE then
		print_debug("错误时间 现在状态: " .. self.nowState)

		return
	end

	print_debug("进行了qte操作" .. direction)
	self.CheckQTE(self, direction)
end

M.CheckQTE = function(self, direction)
	local soundId = 0
	local success = direction ~= self.qtes[self.nowQTEIndex].direction

	if success then
		print_debug("QTE成功，方向: " .. direction .. "索引" .. self.nowQTEIndex)

		soundId = self.Config.soundSuccessId
	else
		print_debug("QTE失败，方向: " .. direction .. " 索引: " .. self.nowQTEIndex)

		soundId = self.Config.soundFailId
	end

	self.ResolveQTE(self, success)

	if not self.isHit then
		gSoundMgr:PlaySoundByTid(soundId)
	end
end

M.ResolveQTE = function(self, success)
	local qteIndex = self.nowQTEIndex
	self.nowState = self.STATE.WAITTING

	if self.isHit then
		gPalmKingNpc.nowState = gPalmKingNpc.State.Waiting
	end

	gPalmKingInterface:SetQTEPos(qteIndex)

	local duration = gPalmKingInterface:PlayQTEResult(qteIndex, success)

	self:StopQTEResultTimer()

	self.qteResultTimer = Timer.New(function ()
		self.qteResultTimer = nil

		if not success then
			self:QtesResult(false)

			return
		end

		self.qtes[qteIndex].success = true

		gPalmKingInterface:RefreshQteList(self.qtes)

		if qteIndex > #self.qtes then
			self:QtesResult(true)

			return
		end

		self.nowQTEIndex = qteIndex + 1
		self.nowState = self.STATE.QTE

		if self.isHit then
			gPalmKingNpc.nowState = gPalmKingNpc.State.Qte
		end
	end, duration):Start()
end

M.QtesResult = function(self, success)
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

M.Result = function(self)
	print_debug("攻击方向: " .. self.hitDirection .. ", 防御方向: " .. self.defenceDirection)
	gPalmKingInterface:SetHudState(self.HUD_TYPE.WAIT)

	if self.isHit then
		gPalmKingNpc:BeHit(self.hitDirection, self.hitForce)
	end

	local resultType = self.CalcResultType(self)

	if resultType ~= self.RESULT_TEXT.DODGE then
		self.HandlePerfectDodge(self)
	elseif resultType ~= self.RESULT_TEXT.BRUISE then
		self.HandleBruise(self)
	elseif resultType ~= self.RESULT_TEXT.NORMAL then
		self.HandleNormalHit(self)
	elseif resultType ~= self.RESULT_TEXT.DEFENCE_BROKEN then
		self.HandleDefenceBroken(self)
	end

	gPalmKingInterface:SetMeHp(gPalmKingGamer.blood)
	gPalmKingInterface:SetOtherHp(gPalmKingNpc.blood)

	if resultType == self.RESULT_TEXT.DODGE then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommonHeavy1", LX6.Audio.ExternalSourceType.Motion_2D)
	end
end

M.CalcResultType = function(self)
	local isHeadDefence = self.IsHeadDefence(self)

	if self.IsDiagonal(self) then
		return isHeadDefence and self.RESULT_TEXT.DODGE or self.RESULT_TEXT.BRUISE
	elseif self.IsAdjacent(self) then
		return isHeadDefence and self.RESULT_TEXT.BRUISE or self.RESULT_TEXT.NORMAL
	elseif self.IsSameDirection(self) then
		return isHeadDefence and self.RESULT_TEXT.NORMAL or self.RESULT_TEXT.DEFENCE_BROKEN
	end

	return self.RESULT_TEXT.NONE
end

M.HandlePerfectDodge = function(self)
	print_debug("完美闪避")

	self.nowState = self.STATE.END

	gPalmKingAction:Defend(self.hitDirection, self.isHit)
	gPalmKingInterface:SetResultText(self.RESULT_TEXT.DODGE, 0)
end

M.HandleBruise = function(self)
	print_debug("擦伤")

	self.nowState = self.STATE.END

	gPalmKingAction:Stunned(self.hitDirection, self.isHit)

	local damage = self:CalcDefenceDamage(self.Config.bruiseRate)

	self:ApplyDamage(damage)
	gPalmKingInterface:SetResultText(self.RESULT_TEXT.BRUISE, damage)
	self:PlayHitVibrate(self.RESULT_TEXT.BRUISE)
end

M.HandleNormalHit = function(self)
	print_debug("普通命中")

	self.nowState = self.STATE.END

	gPalmKingAction:Stunned(self.hitDirection, self.isHit)

	local damage = self:CalcDefenceDamage(self.Config.normalRate)

	self:ApplyDamage(damage)
	gPalmKingInterface:SetResultText(self.RESULT_TEXT.NORMAL, damage)
	self:PlayHitVibrate(self.RESULT_TEXT.NORMAL)
end

M.HandleDefenceBroken = function(self)
	print_debug("破防")

	local damage = self.CalcDefenceDamage(self, self.Config.defenceBrokenRate)

	self.ApplyDamage(self, damage)
	self.HandleQTE(self)

	if damage >= 9999 then
		gPalmKingInterface:SetResultText(self.RESULT_TEXT.DEFENCE_BROKEN, damage)
	end

	self.PlayHitVibrate(self, self.RESULT_TEXT.DEFENCE_BROKEN)
end

M.ApplyDamage = function(self, damage)
	gPalmKingInterface:PlayDamage(self.isHit, damage)

	if self.isHit then
		gPalmKingNpc.blood = gPalmKingNpc.blood - damage
	else
		gPalmKingGamer.blood = gPalmKingGamer.blood - damage
	end
end

M.PlayHitVibrate = function(self, resultType)
	local vibrateId = nil

	if resultType ~= self.RESULT_TEXT.BRUISE then
		vibrateId = self.Config.vibrateBruiseId
	elseif resultType ~= self.RESULT_TEXT.NORMAL then
		vibrateId = self.Config.vibrateNormalId
	elseif resultType ~= self.RESULT_TEXT.DEFENCE_BROKEN then
		vibrateId = self.Config.vibrateDefenceBrokenId
	end

	if vibrateId then
		gSoundMgr:PlaySoundByTid(vibrateId)
	end
end

M.HandleQTE = function(self)
	self.nowState = self.STATE.WAITTING
	slot1 = gPalmKingAction

	slot1:DefenceBroken(self.hitDirection, self.isHit)
	self:SetTimer(function ()
		if gPalmKingGamer.blood > 0 or gPalmKingNpc.blood < 0 then
			self.nowState = self.STATE.END

			gPalmKingAction:StunnedDefend(self.hitDirection, self.isHit)
		else
			self:BeginQTE()
		end
	end, self.Config.stunnedWaitTime)
end

M.PalmKingAttackResultTask = function(self)
	print_debug("zxxx   PalmKingAttackResultTask")
end

M.PalmKingChangeLeftLowerEndTask = function(self)
	print_debug("zxxx   PalmKingChangeLeftLowerEndTask")
end

M.PalmKingChangeLeftUpperEndTask = function(self)
	print_debug("zxxx   PalmKingChangeLeftUpperEndTask")
end

M.PalmKingChangeRightUpperEndTask = function(self)
	print_debug("zxxx   PalmKingChangeRightUpperEndTask")
end

M.PalmKingChangeRightUpperEndTask = function(self)
	print_debug("zxxx   PalmKingChangeRightUpperEndTask")
end

M.PalmKingReturnToPositionEndTask = function(self)
	print_debug("zxxx   PalmKingReturnToPositionEndTask")
end

M.PalmKingDefenceBrokenEndTask = function(self)
	print_debug("zxxx   PalmKingDefenceBrokenEndTask")
	M:GameOver()
end

M.PalmKingDefendEndTask = function(self)
	print_debug("zxxx   PalmKingDefendEndTask")
	M:GameOver()
end

M.PalmKingStunnedEndTask = function(self)
	print_debug("zxxx   PalmKingStunnedEndTask")
	M:GameOver()
end

M.PalmKingStunnedLoopEndTask = function(self)
	print_debug("zxxx   PalmKingStunnedLoopEndTask")
	M:GameOver()
end

gPalmKingManager = M
