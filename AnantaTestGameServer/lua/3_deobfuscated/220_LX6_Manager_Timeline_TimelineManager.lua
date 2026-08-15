local M = {
	isTimelinePlaying = false,
	debugQTE = false
}
local C_CutsceneManager = LX6.TimelineScript.CutsceneManager.Instance
local C_CutscenePreloadManager = LX6.TimelineScript.CutscenePreloadManager.Instance

function M:SwitchDebugMode()
	self.debugQTE = not self.debugQTE
end

function M:IsPlayingCutscene()
	return C_CutsceneManager.isPlayingCutscene
end

function M:GetTimeline(name)
	if string.is_null_or_empty(name) then
		return nil
	end

	return C_CutsceneManager:GetTimeline(name)
end

function M:Timeline_CreateTimelineData()
	return C_CutsceneManager:CreateTimelineData()
end

function M:Timeline_CreateBindUnitInfo(type, id, bindTargetName, unitName, unit)
	return C_CutsceneManager:CreateBindUnitInfo(type, id, bindTargetName, unitName, unit)
end

function M:Timeline_LoadAndPlay(timelineName, timelineData)
	C_CutsceneManager:LoadAndPlay(timelineName, timelineData)
end

function M:Timeline_DiscardTimeline(timelineName)
	C_CutsceneManager:DiscardTimeline(timelineName)
end

function M:Timeline_IsPlaying()
	return C_CutsceneManager:IsTimelinePlaying()
end

function M:Timeline_CheckTimelineIsPlaying(timelineName)
	return C_CutsceneManager:CheckTimelineIsPlaying(timelineName)
end

function M:Timeline_Pause(name, pause)
	local t = M:GetTimeline(name)

	if t then
		t:Pause(pause)
	end
end

function M:Timeline_TimelinePreLoad(timelineName, data)
	C_CutsceneManager:TimelinePreLoad(timelineName, data)
end

function M:Test1()
	local data = self:Timeline_CreateTimelineData()
	data.preloadTimer = 60

	C_CutsceneManager:TimelinePreLoad("xsb_phase3_part3", data)
end

function M:Test2()
	local data = self:Timeline_CreateTimelineData()

	self:Timeline_LoadAndPlay("xsb_phase3_part3", data)
end

function M:Timeline_SetTimelineScale(timelineName, pauseId, timeScale)
	local t = M:GetTimeline(timelineName)

	if t then
		t:SetTimeScale(pauseId, timeScale)
	end
end

function M:Timeline_JumpTo(name, clipName, jumpWithBlend, blendTime)
	local t = M:GetTimeline(name)

	if t then
		if blendTime == nil then
			t:JumpTo(clipName, jumpWithBlend)
		else
			t:JumpTo(clipName, jumpWithBlend, blendTime)
		end

		return
	end
end

function M:Timeline_Stop(name, finishCb, destroyCb)
	local t = M:GetTimeline(name)

	if t then
		t:StopTimeline(finishCb, destroyCb)
	end
end

function M:Timeline_GetActorPosition(timelineName, actorName)
	return C_CutsceneManager:Timeline_GetActorWorldPosition(timelineName, actorName, nil)
end

function M:Timeline_GetActorWorldRotationEuler(timelineName, actorName)
	return C_CutsceneManager:Timeline_GetActorWorldRotationEuler(timelineName, actorName, nil)
end

function M:Timeline_GetWorldPosAndRot(timelineName, actorName)
	return C_CutsceneManager:Timeline_GetWorldPosAndRot(timelineName, actorName, nil, nil)
end

function M:Cutscene_ControlUI(storeName, funcName, param)
	local store = gStoreManager:GetStoreGroup(storeName)

	if not store then
		print_error("cannot find store named " .. storeName)

		return
	end

	local func = store[funcName]

	if not func or type(func) ~= "function" then
		print_error("cannot find function named " .. funcName .. " in " .. storeName)

		return
	end

	return func(store, param)
end

function M:ShowBlackScreen(showBlack)
	if gBlackScreenManager:IsOccupied() then
		if not gBlackScreenManager:IsOccupiedById(gBlackScreenId.TIMELINE) then
			gBlackScreenManager:OpenBlackInstantly(gBlackScreenId.TIMELINE)
		end
	elseif showBlack then
		gBlackScreenManager:OpenBlackInstantly(gBlackScreenId.TIMELINE)
	end
end

function M:CloseBlackScreen()
	if gBlackScreenManager:IsOccupied() then
		gBlackScreenManager:ClearTransition(gBlackScreenManager.setId, true)
	end
end

function M:CutsceneManager_DebugBlackScreen(id, flag)
	C_CutsceneManager:Debug_SendBlackScreenMessage(id, flag)
end

function M:Timeline_GetBindUnitPid(spoonUnit)
	if not spoonUnit then
		return 0
	end

	if spoonUnit.spoonNode then
		return spoonUnit.spoonNode:CheckUnitPid(spoonUnit.spoonContext, "PlayClientTimeline", spoonUnit.id)
	else
		local unit = spoonUnit:GetUnit()

		if unit then
			return unit.pid
		end
	end

	return 0
end

function M:QTE_PlayGraph(qteGraphName)
	C_CutsceneManager:QTE_PlayGraph(qteGraphName)
end

function M:QTE_RunTrigger(triggerName)
	C_CutsceneManager:QTE_RunTrigger(triggerName)
end

function M:DCG_GetCameraGroup(groupName)
	C_CutsceneManager:DCG_GetCameraGroup(groupName)
end

gTimelineManager = M
