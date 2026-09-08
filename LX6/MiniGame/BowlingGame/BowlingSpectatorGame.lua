-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingSpectatorGame.lua
-- Decompiled from: 00645_BowlingSpectatorGame.lua_329fffe83482.luajit

gBowlingSpectatorGame = DefClass("BowlingSpectatorGame", gBowlingSpectatorGame)
local BowlingSpectatorGame = gBowlingSpectatorGame
local OB_TIMELINE_NAME = "gameplay_bowling02_ob"
local bindings_actor_names = {
	[1.0] = "\\x98\\x90JD\\xb3",
	[2.0] = "\\x99\\x9apN\\xb1"
}
local LOAD_TIMEOUT_SECONDS = 10

BowlingSpectatorGame.ctor = function(self, gadgetUId, participants)
	self.gadgetUId = gadgetUId
	self.participants = participants
	self.ownerUnit = nil
	self.timelineInstance = nil
	self.timelineController = nil
	self.isLoaded = false
	self.hasDestroy = false
	self.resolvedUnits = {}
	self.loadCallback = nil
	self.unitLoadHandler = nil
	self.loadTimeoutTimer = nil
end

BowlingSpectatorGame.ResolveParticipantUnit = function(self, p)
	if ulong.Greater(p.Pid or 0, 0) then
		local success, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(p.Pid, ulong.zero)

		if success then
			return gCS.SceneDataMgr.GetUnit(unitId)
		end

		return nil
	elseif ulong.Greater(p.AgentInstanceId or 0, 0) then
		return gCS.SceneDataMgr.GetUnit(p.AgentInstanceId)
	end

	return nil
end

BowlingSpectatorGame.ResolveParticipantUnits = function(self)
	local allReady = true
	self.resolvedUnits = {}

	for i = 1, #self.participants do
		local unit = self.ResolveParticipantUnit(self, self.participants[i])

		if gCS.LuaUtils.IsBaseUnitValid(unit) then
			self.resolvedUnits[i] = unit
		else
			self.resolvedUnits[i] = nil
			allReady = false
		end
	end

	return allReady
end

BowlingSpectatorGame.Load = function(self, onLoaded)
	if self.hasDestroy then
		if onLoaded then
			onLoaded(false)
		end

		return
	end

	if self.isLoaded then
		if onLoaded then
			onLoaded(true)
		end

		return
	end

	self.loadCallback = onLoaded

	self.TryLoadWhenUnitsReady(self)
end

BowlingSpectatorGame.TryLoadWhenUnitsReady = function(self)
	if self.hasDestroy then
		self.FinishLoad(self, false)

		return
	end

	if self.ResolveParticipantUnits(self) then
		self.ClearUnitLoadListener(self)
		self.ClearLoadTimeoutTimer(self)
		self.DoLoadTimeline(self)

		return
	end

	if not self.unitLoadHandler then
		self.unitLoadHandler = self:CreateAction(self.OnUnitLoadComplete)

		gMessageManager:AddMessageListener(gEventConstants.UNIT_LOAD_COMPLETE, self.unitLoadHandler)
	end

	if not self.loadTimeoutTimer then
		self.loadTimeoutTimer = Timer.New(function ()
			print_error("[BowlingSpectatorGame] OB Timeline load timeout (units not ready), gadgetUId:", self.gadgetUId)
			self:FinishLoad(false)
		end, LOAD_TIMEOUT_SECONDS)

		self.loadTimeoutTimer:Start()
	end
end

BowlingSpectatorGame.OnUnitLoadComplete = function(self)
	self.TryLoadWhenUnitsReady(self)
end

BowlingSpectatorGame.DoLoadTimeline = function(self)
	local bindInfos = self.BuildBindUnitInfos(self)

	if table.isNilOrEmpty(bindInfos) then
		print_error("[BowlingSpectatorGame] bindUnitInfos is empty, cannot load OB Timeline")
		self.FinishLoad(self, false)

		return
	end

	local timelineData = gTimelineManager:Timeline_CreateTimelineData()
	timelineData.bindUnitInfos = bindInfos
	timelineData.supportStreamingAnim = false
	timelineData.supportStreamingActor = false
	timelineData.supportStreamingEffect = false
	self.ownerUnit = self:SelectOwnerUnit()

	if gCS.LuaUtils.IsBaseUnitValid(self.ownerUnit) then
		timelineData.linkType = 1
		timelineData.owner = self.ownerUnit
	end

	timelineData.onLoadDoneCallback = self:CreateActionWithArgs(self.OnTimelineLoaded, self.loadCallback)

	gTimelineManager:Timeline_LoadAndPlay(OB_TIMELINE_NAME, timelineData)
end

BowlingSpectatorGame.OnTimelineLoaded = function(self, onLoaded, timeline)
	if self.hasDestroy then
		self.FinishLoad(self, false)

		return
	end

	if not gClientUtils.NotNil(timeline) then
		print_error("[BowlingSpectatorGame] OB Timeline load failed: timeline is nil")
		self.FinishLoad(self, false)

		return
	end

	self.timelineInstance = timeline
	self.timelineController = timeline.GetComponent(timeline, typeof(UnityEngine.Playables.PlayableDirector))

	if not gClientUtils.NotNil(self.timelineController) then
		print_error("[BowlingSpectatorGame] OB Timeline PlayableDirector is nil")

		self.timelineInstance = nil

		self.FinishLoad(self, false)

		return
	end

	local gadgetEntity = gGadgetManager:GetEntitySearchByInstanceId(self.gadgetUId)

	if gCS.LuaUtils.NeqNull(gadgetEntity) then
		local node = gadgetEntity.gameObject.transform:Find("ItemViewNode/BowlingGameNodeRight")

		if gClientUtils.NotNil(node) then
			self.timelineController.transform.position = node.position
			self.timelineController.transform.rotation = node.rotation
		end
	end

	self.isLoaded = true

	self.FinishLoad(self, true)
end

BowlingSpectatorGame.FinishLoad = function(self, success)
	self.ClearUnitLoadListener(self)
	self.ClearLoadTimeoutTimer(self)

	if self.loadCallback then
		local cb = self.loadCallback
		self.loadCallback = nil

		cb(success)
	end
end

BowlingSpectatorGame.BuildBindUnitInfos = function(self)
	local bindInfos = {}

	for i = 1, #self.participants do
		local p = self.participants[i]
		local bindName = bindings_actor_names[p.SeatIndex + 1]

		if bindName then
			if ulong.Greater(p.Pid or 0, 0) then
				local bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, p.Pid, bindName, nil)

				table.insert(bindInfos, bindInfo)
			elseif ulong.Greater(p.AgentInstanceId or 0, 0) then
				local bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, p.AgentInstanceId, bindName, nil)

				table.insert(bindInfos, bindInfo)
			end
		end
	end

	return bindInfos
end

BowlingSpectatorGame.SelectOwnerUnit = function(self)
	for i = 1, #self.participants do
		if ulong.Greater(self.participants[i].Pid or 0, 0) then
			local unit = self.resolvedUnits[i]

			if gCS.LuaUtils.IsBaseUnitValid(unit) then
				return unit
			end
		end
	end

	for i = 1, #self.participants do
		local unit = self.resolvedUnits[i]

		if gCS.LuaUtils.IsBaseUnitValid(unit) then
			return unit
		end
	end

	return nil
end

BowlingSpectatorGame.JumpToLaneClip = function(self, clipName)
	if self.hasDestroy or not self.isLoaded then
		return
	end

	if not gClientUtils.NotNil(self.timelineInstance) or not gClientUtils.NotNil(self.timelineController) then
		return
	end

	if not self.playTimelineOnce then
		self.timelineInstance:PlayTimeline()

		self.playTimelineOnce = true
	end

	self.timelineInstance:JumpTo(clipName)
	self.timelineController:Play()
end

BowlingSpectatorGame.Destroy = function(self)
	if self.hasDestroy then
		return
	end

	self.hasDestroy = true

	self.ClearUnitLoadListener(self)
	self.ClearLoadTimeoutTimer(self)

	self.loadCallback = nil

	if gCS.LuaUtils.IsBaseUnitValid(self.ownerUnit) then
		L50.L50App.L50Game.CutsceneManager:Link_DestroyTimeline(self.ownerUnit, OB_TIMELINE_NAME)
	else
		gTimelineManager:Timeline_Stop(OB_TIMELINE_NAME)
	end

	self.timelineController = nil
	self.timelineInstance = nil
	self.isLoaded = false
end

BowlingSpectatorGame.ClearUnitLoadListener = function(self)
	if self.unitLoadHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.UNIT_LOAD_COMPLETE, self.unitLoadHandler)

		self.unitLoadHandler = nil
	end
end

BowlingSpectatorGame.ClearLoadTimeoutTimer = function(self)
	if self.loadTimeoutTimer then
		self.loadTimeoutTimer:Stop()

		self.loadTimeoutTimer = nil
	end
end
