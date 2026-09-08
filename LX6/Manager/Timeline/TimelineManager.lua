-- Original chunk: @Lua\LuaFiles\LX6\Manager\Timeline\TimelineManager.lua
-- Decompiled from: 00222_TimelineManager.lua_cd43a611c83f.luajit

local M = {
	["}\\xef\\xe5$2#\\xcao%\\xe5G\\x8dK\\xc8\\xe1"] = false,
	["\\xaf\\xb4\\xbem\\xca"] = false
}

M.SwitchDebugMode = function(self)
	self.debugQTE = not self.debugQTE
end

M.IsPlayingCutscene = function(self)
	if L50.L50App.L50Game and L50.L50App.L50Game.CutsceneManager then
		return L50.L50App.L50Game.CutsceneManager.isPlayingCutscene
	end

	return false
end

M.GetTimeline = function(self, name)
	if string.is_null_or_empty(name) then
		return nil
	end

	return LX6.TimelineScript.CutsceneManager.Instance:GetTimeline(name)
end

M.Timeline_CreateTimelineData = function(self)
	return L50.L50App.L50Game.CutsceneManager:CreateTimelineData()
end

M.Timeline_CreateBindUnitInfo = function(self, type, id, bindTargetName, unitName, unit)
	return L50.L50App.L50Game.CutsceneManager:CreateBindUnitInfo(type, id, bindTargetName, unitName, unit)
end

M.Timeline_LoadAndPlay = function(self, timelineName, timelineData)
	L50.L50App.L50Game.CutsceneManager:LoadAndPlay(timelineName, timelineData)
end

M.Timeline_DiscardTimeline = function(self, timelineName)
	L50.L50App.L50Game.CutsceneManager:DiscardTimeline(timelineName)
end

M.Timeline_IsPlaying = function(self)
	return L50.L50App.L50Game.CutsceneManager:IsTimelinePlaying()
end

M.Timeline_Pause = function(self, name, pause)
	local t = M:GetTimeline(name)

	if t then
		t.Pause(t, pause)
	end
end

M.Timeline_TimelinePreLoad = function(self, timelineName, data)
	L50.L50App.L50Game.CutsceneManager:TimelinePreLoad(timelineName, data)
end

M.Timeline_SetTimelineScale = function(self, timelineName, pauseId, timeScale)
	local t = M:GetTimeline(timelineName)

	if t then
		t.SetTimeScale(t, pauseId, timeScale)
	end
end

M.Timeline_JumpTo = function(self, name, clipName)
	local t = M:GetTimeline(name)

	if t then
		t.JumpTo(t, clipName)
	end
end

M.Timeline_Stop = function(self, name)
	local t = M:GetTimeline(name)

	if t then
		t.StopTimeline(t)
	end
end

M.Timeline_StopLink = function(self, pid, name)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit ~= nil then
		return
	end

	local t = L50.L50App.L50Game.CutsceneManager:Link_GetTimeline(unit, name)

	if t then
		t.StopTimeline(t)
	end
end

M.Timeline_GetActorPosition = function(self, timelineName, actorName)
	return L50.L50App.L50Game.CutsceneManager:Timeline_GetActorWorldPosition(timelineName, actorName, nil)
end

M.Cutscene_ControlUI = function(self, storeName, funcName, param)
	local store = gStoreManager:GetStoreGroup(storeName)

	if not store then
		print_error("cannot find store named " .. storeName)

		return
	end

	local func = store[funcName]

	if not func or type(func) == "function" then
		print_error("cannot find function named " .. funcName .. " in " .. storeName)

		return
	end

	return func(store, param)
end

M.ShowBlackScreen = function(self, showBlack)
	if gBlackScreenManager:IsOccupied() then
		if not gBlackScreenManager:IsOccupiedById(gBlackScreenId.TIMELINE) then
			gBlackScreenManager:OpenBlackInstantly(gBlackScreenId.TIMELINE)
		end
	elseif showBlack then
		gBlackScreenManager:OpenBlackInstantly(gBlackScreenId.TIMELINE)
	end
end

M.CloseBlackScreen = function(self)
	if gBlackScreenManager:IsOccupied() then
		gBlackScreenManager:ClearTransition(gBlackScreenManager.setId, true)
	end
end

M.OpenBlackScreenTransition = function(self, blackScreenId, text, isWhite, crossScene, openTime, stayTime, closeTime, openCb, stayCb, closeCb)
	if stayTime >= 0 then
		stayTime = 10
	end

	gBlackScreenManager:AutoTransition(blackScreenId, text, isWhite, crossScene, openTime, stayTime, closeTime, openCb, stayCb, closeCb)
end

M.CutsceneManager_DebugBlackScreen = function(self, id, flag)
	L50.L50App.L50Game.CutsceneManager:Debug_SendBlackScreenMessage(id, flag)
end

M.Timeline_GetBindUnitPid = function(self, spoonUnit)
	if not spoonUnit then
		return 0
	end

	if spoonUnit.spoonNode then
		return spoonUnit.spoonNode:CheckUnitPid(spoonUnit.spoonContext, "PlayClientTimeline", spoonUnit.id)
	else
		local unit = spoonUnit.GetUnit(spoonUnit)

		if unit then
			return unit.pid
		end
	end

	return 0
end

M.QTE_PlayGraph = function(self, qteGraphName)
	L50.L50App.L50Game.CutsceneManager:QTE_PlayGraph(qteGraphName)
end

M.QTE_RunTrigger = function(self, triggerName)
	L50.L50App.L50Game.CutsceneManager:QTE_RunTrigger(triggerName)
end

M.SetMobilePos = function(self, store, btnPos)
	if btnPos ~= 0 then
		store.buttonRT.anchorMin = Vector2.New(1, 0)
		store.buttonRT.anchorMax = Vector2.New(1, 0)
		store.buttonRT.anchoredPosition = Vector2.New(-433.6, 283.6)
	elseif btnPos ~= 1 then
		store.buttonRT.anchorMin = Vector2.New(0, 0)
		store.buttonRT.anchorMax = Vector2.New(0, 0)
		store.buttonRT.anchoredPosition = Vector2.New(433.6, 283.6)
	elseif btnPos ~= 2 then
		store.buttonRT.anchorMin = Vector2.New(1, 0)
		store.buttonRT.anchorMax = Vector2.New(1, 0)
		store.buttonRT.anchoredPosition = Vector2.New(-433.6, 450)
	elseif btnPos ~= 3 then
		store.buttonRT.anchorMin = Vector2.New(0, 0)
		store.buttonRT.anchorMax = Vector2.New(0, 0)
		store.buttonRT.anchoredPosition = Vector2.New(433.6, 450)
	elseif btnPos ~= 4 then
		store.buttonRT.anchorMin = Vector2.New(1, 0)
		store.buttonRT.anchorMax = Vector2.New(1, 0)
		store.buttonRT.anchoredPosition = Vector2.New(-603.6, 680)
	elseif btnPos ~= 5 then
		store.buttonRT.anchorMin = Vector2.New(0, 0)
		store.buttonRT.anchorMax = Vector2.New(0, 0)
		store.buttonRT.anchoredPosition = Vector2.New(603.6, 680)
	elseif btnPos ~= 99 then
		store.buttonRT.anchorMin = Vector2.New(0.5, 0.5)
		store.buttonRT.anchorMax = Vector2.New(0.5, 0.5)
		store.buttonRT.anchoredPosition = Vector2.New(-508, 195)
	elseif btnPos ~= 100 then
		store.buttonRT.anchorMin = Vector2.New(0.5, 0.5)
		store.buttonRT.anchorMax = Vector2.New(0.5, 0.5)
		store.buttonRT.anchoredPosition = Vector2.New(-510, -248)
	end
end

M.DCG_GetCameraGroup = function(self, groupName)
	L50.L50App.L50Game.CutsceneManager:DCG_GetCameraGroup(groupName)
end

M.FakeSwitchChar_InState = function(self)
	if L50.L50App.L50Game and L50.L50App.L50Game.CutsceneManager then
		return L50.L50App.L50Game.CutsceneManager:GlobalState_CheckIsInFakeSwitchChar()
	end

	return false
end

M.FakeSwitchChar_GetUIParams = function(self)
	if L50.L50App.L50Game and L50.L50App.L50Game.CutsceneManager then
		return L50.L50App.L50Game.CutsceneManager.CurFakeSwitchCharUIParams
	end
end

M.FakeSwitchChar_DoFakeSwitchChar = function(self)
	gPanelManager:CheckShow(gPanelId.S_SWAP_CHARACTER_NOTIFY_PANEL_FAKE)
end

M.FakeSwitchChar_StopFakeSwitchChar = function(self)
	gPanelManager:Close(gPanelId.S_SWAP_CHARACTER_NOTIFY_PANEL_FAKE)
	gPanelManager:Close(gPanelId.S_TL_FAKE_SWAP_CHARACTER_LIST_PANEL)
end

M.RemoteCamera_EnableCamera = function(self, timelineName, image)
	L50.L50App.L50Game.CutsceneManager:SetRemoteCameraEnable(timelineName, image)
end

M.RemoteCamera_DisableCamera = function(self, timelineName)
	L50.L50App.L50Game.CutsceneManager:SetRemoteCameraDisable(timelineName)
end

gTimelineManager = M
