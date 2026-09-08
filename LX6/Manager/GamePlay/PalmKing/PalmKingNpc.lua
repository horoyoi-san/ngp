-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\PalmKing\PalmKingNpc.lua
-- Decompiled from: 02229_PalmKingNpc.lua_adb99e09257a.luajit

local M = {
	State = {
		["o\\xab\\x8a\\xa6\\xa2"] = 4,
		["\\xee\\xda\t*\\xf6"] = 3,
		["~\\xa2\\xa7\\xaa\\xa6"] = 1,
		["sUiyO?"] = 2,
		["\\xbf|c"] = 5
	},
	Config = {
		["+/!\\xe0W\\x9d\\xf11\\xa6,\\xe3\\xc0\\xe7`\\xfe"] = 0.5
	}
}

M.Init = function(self)
	self.nowState = self.State.Sleep
	self.id = gPalmKingInterface:GetSlapCfgId()
	self.blood = gPalmKingInterface:GetOtherMaxHp()

	gPalmKingInterface:SetOtherHp(self.blood)
	self:InitConfig(self.id)
end

M.InitConfig = function(self, id)
	local cfg = LTConfig.PoiGameSlapAIConfig.GetConfig(id)
	self.Config.thinkTime = {
		min = cfg.ThinkTime[1],
		max = cfg.ThinkTime[2]
	}
	self.Config.changeratevalue = cfg.ChangeRate
	self.Config.cheatRate = cfg.CheatRate
	self.Config.qteActionTime = {
		min = cfg.QTEThinkTime[1],
		max = cfg.QTEThinkTime[2]
	}
	self.Config.qteCheatRate = cfg.QteCheatRate
	self.Config.defenceRate = cfg.DefenceRate
	self.Config.defenceTime = {
		min = cfg.DefenceTime[1],
		max = cfg.DefenceTime[2]
	}
	self.Config.hitTime = {
		min = cfg.NPCAtkTime[1],
		max = cfg.NPCAtkTime[2]
	}
	self.Config.perfectRate = cfg.PerfectRate or 0
	gPalmKingManager.Config.normalDefenceBlood = cfg.Atk
end

M.StartPrepareBeHit = function(self)
	print_debug("NPC准备--被打")

	self.isDefence = true
	self.nowDirection = 2
	self.waitingDefenceTime = self:GetNextDefenceTime()

	print_debug("NPC等待防御时间 ：" .. self.waitingDefenceTime)
	gPalmKingAction:PrepareDefend(self.nowDirection, true)
	self:StartPlay()
end

M.StartPrepareHit = function(self)
	print_debug("NPC准备--攻击")

	self.isDefence = false
	self.nowDirection = 1

	gPalmKingAction:Attack(self.nowDirection, true)
	gPalmKingInterface:SetCamera(2, 1)

	self.playerhittime = math.random(self.Config.hitTime.min * 1000, self.Config.hitTime.max * 1000) / 1000

	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_FRONT_COUNTDOWN_PANEL, {
		["\\x96'0m\\x93U\\xfd8\\xbd\\xb7"] = true,
		countDownSecondNum = self.playerhittime + gPalmKingManager.Config.roundWaitTime
	})
	self:StartPlay()
end

M.StartPlay = function(self)
	self.nowDirection = 1

	print_debug("NPC开始游戏，进入等待状态")

	self.nowState = self.State.Preparing
	self.waitingChangeTime = self.GetNextThinkTime(self)

	print_debug("NPC思考切换架势时间 ：" .. self.waitingChangeTime)
end

M.Update = function(self, deltatime)
	if self.nowState ~= self.State.Preparing then
		self.UpdatePreparingState(self, deltatime)
	elseif self.nowState ~= self.State.Qte then
		self.UpdateQteState(self, deltatime)
	end
end

M.UpdatePreparingState = function(self, deltatime)
	self.waitingChangeTime = self.waitingChangeTime - deltatime

	if self.waitingChangeTime < 0 then
		self.ChangeDefence(self)
	end

	if self.isDefence then
		self.waitingDefenceTime = self.waitingDefenceTime - deltatime

		if self.waitingDefenceTime < 0 then
			self.ActionDefence(self)
		end
	else
		self.playerhittime = self.playerhittime - deltatime

		if self.playerhittime < 0 then
			print_debug("NPC开始攻击，方向: " .. self.nowDirection)
			self.ActionHit(self)
		end
	end
end

M.UpdateQteState = function(self, deltatime)
	if self.qteThinkTime <= 0 then
		self.qteThinkTime = self.qteThinkTime - deltatime
	end

	if self.qteThinkTime < 0 then
		self.QTEOnce(self)
	end
end

M.ChangeDefence = function(self)
	self.waitingChangeTime = self.GetNextThinkTime(self)
	local targetDirection = self.GetRandomDirection(self)

	if self.isDefence then
		local cheat = math.random()

		if cheat >= self.Config.cheatRate then
			targetDirection = gPalmKingGamer.hitDir

			print_debug("NPC读取玩家方向: " .. self.nowDirection)
		else
			print_debug("NPC随机选择防御方向: " .. self.nowDirection)
		end
	else
		print_debug("NPC准备攻击方向" .. self.nowDirection)
	end

	if self.nowDirection == targetDirection then
		gPalmKingAction:Change(self.nowDirection, true)
	end
end

M.ActionDefence = function(self)
	print_debug("npc闪避 start")

	self.waitingDefenceTime = self.GetNextDefenceTime(self)
	self.isHeadDefence = true

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.waitTimer = Timer.New(function ()
		print_debug("npc闪避 end")

		self.isHeadDefence = false
	end, LTConfig.PoiGameConfig.Slap_DefenceDurationTime):Start()
end

M.ActionHit = function(self)
	gPalmKingInterface:SetCamera(2, 2)
	gPalmKingAction:Attack(self.nowDirection, true)
	print_debug("NPC开始攻击，方向: " .. self.nowDirection)
	gPalmKingManager:SyncHit(self.nowDirection, gPalmKingInterface:GetCurForce())

	self.nowState = self.State.Waiting

	gPanelManager:Close(gPanelId.S_CHALLENGE_FRONT_COUNTDOWN_PANEL)

	if gPalmKingGamer.blood > 0 or gPalmKingNpc.blood < 0 then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			["PNkgO:!"] = "Ɋ\\xca\\xe7ٜ\\xff\\x8b+-"
		})
	end
end

M.GetQTEActionTime = function(self)
	local config = self.Config.qteActionTime
	local time = math.random(config.min * 1000, config.max * 1000) / 1000

	return time
end

M.GetNextThinkTime = function(self)
	local config = self.Config.thinkTime
	local time = math.random(config.min, config.max)

	return time
end

M.GetNextDefenceTime = function(self)
	local config = self.Config.defenceTime
	local time = math.random(config.min, config.max)

	return time
end

M.GetRandomDirection = function(self)
	return math.random(1, 4)
end

M.BeHit = function(self, direction, force)
	if not direction or not force then
		print_debug("BeHit参数错误")

		return false
	end

	self.nowState = self.State.BeHit

	gPalmKingAction:PrepareDefend(self.nowDirection, true)
	gPalmKingManager:SyncDefence(self.nowDirection)
	print_debug("NPC防御，方向: " .. self.nowDirection)
end

M.IsHeadDefence = function(self)
	return self.isHeadDefence
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

M.StopPlay = function(self)
	self.nowState = self.State.Sleep
end

M.QTEOnce = function(self)
	if not self.qteActionCount then
		self.qteActionCount = 0
	end

	self.qteActionCount = self.qteActionCount + 1
	local qteDirection = 0
	local cheatRate = self.Config.qteCheatRate
	local cheat = math.random()

	print_debug(self.qteActionCount)

	if not self.qtes[self.qteActionCount] then
		return
	end

	local qteshowdirection = self.qtes[self.qteActionCount].direction

	if cheat >= cheatRate then
		qteDirection = qteshowdirection

		print_debug("NPC作弊成功，读取了qte: " .. qteshowdirection)
	else
		qteDirection = self.RandomQteDirection(self)

		print_debug("NPC随机选择qte方向: " .. self.nowDirection)
	end

	gPalmKingManager:SyncQteAction(qteDirection)

	self.qteThinkTime = self:GetQTEActionTime()

	print_debug("NPC需要思考时间: " .. self.qteThinkTime .. " 秒")

	return qteDirection
end

M.SyncQtes = function(self, qtes)
	self.qtes = qtes

	if self.isDefence then
		self.nowState = self.State.Qte
		self.qteThinkTime = self.GetQTEActionTime(self)
		self.qteActionCount = 0
	else
		self.nowState = self.State.Sleep
	end

	self.qteCount = #qtes

	print_debug(self.qtes)
	print_debug("NPC收到QTE列表，数量: " .. self.qteCount)
end

gPalmKingNpc = M
