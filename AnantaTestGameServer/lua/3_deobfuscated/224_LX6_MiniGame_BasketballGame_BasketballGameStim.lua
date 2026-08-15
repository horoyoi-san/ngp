gBasketballGameStim = DefClass("BasketballGameStim", gBasketballGameStim)
local BasketballGameStim = gBasketballGameStim

function BasketballGameStim:ctor()
	self.npcList = {}
	self.ballList = {}
	self.playerList = {}
	self.behaviorName = "BasketballAudience"

	self:Init()
end

function BasketballGameStim:Init()
	self.alive = true

	LX6.Units.Module.StimManager.Instance:TriggerAgentStim(LTConfig.AgentStimTriggerByAgentConfig.AudienceCheer, gCS.MyPlayerManager.PlayerUnit)

	self.updateCo = coroutine.start(function ()
		while self.alive do
			self:UpdateNpcList()
			self:UpdatePlayerPos()
			self:UpdateBallPos()
			coroutine.step()
		end
	end)
end

function BasketballGameStim:GameEnd()
	self:SendEventToNpcBehavior("GameEnd")

	self.alive = false

	coroutine.stop(self.updateCo)

	self.updateCo = nil
	self.npcUnitMap = nil
end

function BasketballGameStim:AddPlayer(index, trans)
	self.playerList[index] = trans
end

function BasketballGameStim:UpdateNpcList()
	local pedList = gCS.SpoonBTBridge.GetPedList()
	local npcList = pedList and pedList:ToTable() or {}
	self.npcUnitMap = {}

	for _, npc in ipairs(npcList) do
		self.npcUnitMap[npc.Pid] = gCS.SceneDataMgr.GetUnit(npc.Pid)
	end
end

function BasketballGameStim:UpdatePlayerPos()
	for i, player in ipairs(self.playerList) do
		self:SetUnitBehaviorVector3("playerPos" .. i, player.position)
	end
end

function BasketballGameStim:UpdateBallPos()
	for i, ball in pairs(self.ballList) do
		if gClientUtils.NotNil(ball) then
			self:SetUnitBehaviorVector3("ballPos" .. i, ball.position)
		end
	end
end

function BasketballGameStim:OnBallShoot(playerIndex, ballTrans)
	self.ballList[playerIndex] = ballTrans

	self:SendEventToNpcBehavior("shoot" .. playerIndex)
end

function BasketballGameStim:OnBallHit(playerIndex)
	self.ballList[playerIndex] = nil

	self:SendEventToNpcBehavior("hit" .. playerIndex)
end

function BasketballGameStim:OnPerfectHit(playerIndex)
	self:SendEventToNpcBehavior("perfect" .. playerIndex)
end

function BasketballGameStim:SendEventToNpcBehavior(eventName)
	if self.npcUnitMap then
		for pid, npcUnit in pairs(self.npcUnitMap) do
			if npcUnit then
				gCS.SpoonBTBridge.SendEventToNpcBehavior(pid, self.behaviorName, eventName)
			end
		end
	end
end

function BasketballGameStim:SetUnitBehaviorVector3(valName, val)
	if self.npcUnitMap then
		for pid, npcUnit in pairs(self.npcUnitMap) do
			if npcUnit and not npcUnit.IsDestroyed then
				gCS.SpoonBTBridge.SetUnitBehaviorVector3ToUX(pid, self.behaviorName, valName, val)
			end
		end
	end
end
