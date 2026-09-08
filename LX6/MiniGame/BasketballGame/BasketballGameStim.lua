-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BasketballGame\BasketballGameStim.lua
-- Decompiled from: 00591_BasketballGameStim.lua_29b11ddbca18.luajit

gBasketballGameStim = DefClass("BasketballGameStim", gBasketballGameStim)
local BasketballGameStim = gBasketballGameStim

BasketballGameStim.ctor = function(self)
	self.npcList = {}
	self.ballList = {}
	self.playerList = {}
	self.behaviorName = "BasketballAudience"

	self.Init(self)
end

BasketballGameStim.Init = function(self)
	self.alive = true
	slot1 = LX6.Units.Module.StimManager.Instance

	slot1:TriggerAgentStim(LTConfig.AgentStimTriggerByAgentConfig.AudienceCheer, gCS.MyPlayerManager.PlayerUnit)

	self.updateCo = coroutine.start(function ()
		while self.alive do
			self:UpdateNpcList()
			self:UpdatePlayerPos()
			self:UpdateBallPos()
			coroutine.step()
		end
	end)
end

BasketballGameStim.GameEnd = function(self)
	self.SendEventToNpcBehavior(self, "GameEnd")

	self.alive = false

	coroutine.stop(self.updateCo)

	self.updateCo = nil
	self.npcUnitMap = nil
end

BasketballGameStim.AddPlayer = function(self, index, trans)
	self.playerList[index] = trans
end

BasketballGameStim.UpdateNpcList = function(self)
	local pedList = gCS.SpoonBTBridge.GetPedList()
	local npcList = pedList and pedList:ToTable() or {}
	self.npcUnitMap = {}

	for _, npc in ipairs(npcList) do
		self.npcUnitMap[npc.Pid] = gCS.SceneDataMgr.GetUnit(npc.Pid)
	end
end

BasketballGameStim.UpdatePlayerPos = function(self)
	for i, player in ipairs(self.playerList) do
		if gClientUtils.NotNil(player) then
			self.SetUnitBehaviorVector3(self, "playerPos" .. i, player.position)
		end
	end
end

BasketballGameStim.UpdateBallPos = function(self)
	for i, ball in pairs(self.ballList) do
		if gClientUtils.NotNil(ball) then
			self.SetUnitBehaviorVector3(self, "ballPos" .. i, ball.position)
		end
	end
end

BasketballGameStim.OnBallShoot = function(self, playerIndex, ballTrans)
	self.ballList[playerIndex] = ballTrans

	self.SendEventToNpcBehavior(self, "shoot" .. playerIndex)
end

BasketballGameStim.OnBallHit = function(self, playerIndex)
	self.ballList[playerIndex] = nil

	self.SendEventToNpcBehavior(self, "hit" .. playerIndex)
end

BasketballGameStim.OnPerfectHit = function(self, playerIndex)
	self.SendEventToNpcBehavior(self, "perfect" .. playerIndex)
end

BasketballGameStim.SendEventToNpcBehavior = function(self, eventName)
	if self.npcUnitMap then
		for pid, npcUnit in pairs(self.npcUnitMap) do
			if npcUnit then
				gCS.SpoonBTBridge.SendEventToNpcBehavior(pid, self.behaviorName, eventName)
			end
		end
	end
end

BasketballGameStim.SetUnitBehaviorVector3 = function(self, valName, val)
	if self.npcUnitMap then
		for pid, npcUnit in pairs(self.npcUnitMap) do
			if gCS.LuaUtils.IsBaseUnitValid(npcUnit) then
				gCS.SpoonBTBridge.SetUnitBehaviorVector3ToUX(pid, self.behaviorName, valName, val)
			end
		end
	end
end
