local M = {
	State = {
		BeHit = 4,
		Waiting = 3,
		Sleep = 1,
		Preparing = 2,
		Qte = 5
	},
	Config = {
		headDefenceRate = 0.5
	}
}

function M:Init()
	self.nowState = self.State.Sleep
	self.id = gPalmKingInterface:GetSlapCfgId()
	self.blood = gPalmKingInterface:GetOtherMaxHp()

	gPalmKingInterface:SetOtherHp(self.blood)
	self:InitConfig(self.id)
end

function M:InitConfig(id)
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
	gPalmKingManager.Config.normalDefenceBlood = cfg.Atk
end

function M:StartPrepareBeHit()
	print_debug("NPC准备--被打")

	self.isDefence = true
	self.nowDirection = 2
	self.waitingDefenceTime = self:GetNextDefenceTime()

	print_debug("NPC等待防御时间 ：" .. self.waitingDefenceTime)
	gPalmKingAction:PrepareDefend(self.nowDirection, true)
	self:StartPlay()
end

function M:StartPrepareHit()
	print_debug("NPC准备--攻击")

	self.isDefence = false
	self.nowDirection = 1

	gPalmKingAction:Attack(self.nowDirection, true)
	gPalmKingInterface:SetCamera(2, 1)

	self.playerhittime = math.random(self.Config.hitTime.min * 1000, self.Config.hitTime.max * 1000) / 1000

	self:StartPlay()
end

function M:StartPlay()
	self.nowDirection = 1

	print_debug("NPC开始游戏，进入等待状态")

	self.nowState = self.State.Preparing
	self.waitingChangeTime = self:GetNextThinkTime()

	print_debug("NPC思考切换架势时间 ：" .. self.waitingChangeTime)
end

function M:Update(deltatime)
	if self.nowState == self.State.Preparing then
		self:UpdatePreparingState(deltatime)
	elseif self.nowState == self.State.Qte then
		self:UpdateQteState(deltatime)
	end
end

function M:UpdatePreparingState(deltatime)
	self.waitingChangeTime = self.waitingChangeTime - deltatime

	if self.waitingChangeTime <= 0 then
		self:ChangeDefence()
	end

	if self.isDefence then
		self.waitingDefenceTime = self.waitingDefenceTime - deltatime

		if self.waitingDefenceTime <= 0 then
			self:ActionDefence()
		end
	else
		self.playerhittime = self.playerhittime - deltatime

		if self.playerhittime <= 0 then
			print_debug("NPC开始攻击，方向: " .. self.nowDirection)
			self:ActionHit()
		end
	end
end

function M:UpdateQteState(deltatime)
	if self.qteThinkTime > 0 then
		self.qteThinkTime = self.qteThinkTime - deltatime
	end

	if self.qteThinkTime <= 0 then
		self:QTEOnce()
	end
end

function M:ChangeDefence()
	self.waitingChangeTime = self:GetNextThinkTime()
	self.nowDirection = self:GetRandomDirection()

	if self.isDefence then
		local cheat = math.random()

		if cheat < self.Config.cheatRate then
			self.nowDirection = gPalmKingGamer.hitDir

			print_debug("NPC读取玩家方向: " .. self.nowDirection)
		else
			print_debug("NPC随机选择防御方向: " .. self.nowDirection)
		end
	else
		print_debug("NPC准备攻击方向" .. self.nowDirection)
	end

	gPalmKingAction:Change(self.nowDirection, true)
end

function M:ActionDefence()
	print_debug("npc闪避 start")

	self.waitingDefenceTime = self:GetNextDefenceTime()
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

function M:ActionHit()
	gPalmKingInterface:SetCamera(2, 2)
	gPalmKingAction:Attack(self.nowDirection, true)
	print_debug("NPC开始攻击，方向: " .. self.nowDirection)
	gPalmKingManager:SyncHit(self.nowDirection, gPalmKingInterface:GetCurForce())

	self.nowState = self.State.Waiting
end

function M:GetQTEActionTime()
	local config = self.Config.qteActionTime
	local time = math.random(config.min * 1000, config.max * 1000) / 1000

	return time
end

function M:GetNextThinkTime()
	local config = self.Config.thinkTime
	local time = math.random(config.min, config.max)

	return time
end

function M:GetNextDefenceTime()
	local config = self.Config.defenceTime
	local time = math.random(config.min, config.max)

	return time
end

function M:GetRandomDirection()
	return math.random(1, 4)
end

function M:BeHit(direction, force)
	if not direction or not force then
		print_debug("BeHit参数错误")

		return false
	end

	self.nowState = self.State.BeHit

	gPalmKingAction:PrepareDefend(self.nowDirection, true)
	gPalmKingManager:SyncDefence(self.nowDirection)
	print_debug("NPC防御，方向: " .. self.nowDirection)
end

function M:IsHeadDefence()
	return self.isHeadDefence
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

function M:StopPlay()
	self.nowState = self.State.Sleep
end

function M:QTEOnce()
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

	if cheat < cheatRate then
		qteDirection = qteshowdirection

		print_debug("NPC作弊成功，读取了qte: " .. qteshowdirection)
	else
		qteDirection = self:RandomQteDirection()

		print_debug("NPC随机选择qte方向: " .. self.nowDirection)
	end

	gPalmKingManager:SyncQteAction(qteDirection)

	self.qteThinkTime = self:GetQTEActionTime()

	print_debug("NPC需要思考时间: " .. self.qteThinkTime .. " 秒")

	return qteDirection
end

function M:SyncQtes(qtes)
	self.qtes = qtes

	if self.isDefence then
		self.nowState = self.State.Qte
		self.qteThinkTime = self:GetQTEActionTime()
		self.qteActionCount = 0
	else
		self.nowState = self.State.Sleep
	end

	self.qteCount = #qtes

	print_debug(self.qtes)
	print_debug("NPC收到QTE列表，数量: " .. self.qteCount)
end

gPalmKingNpc = M
