-- Original chunk: @Lua\LuaFiles\LX6\Manager\MiniGame\MiniGameDataManager.lua
-- Decompiled from: 00512_MiniGameDataManager.lua_7c307e81b7f4.luajit

local M = {
	["\\xf4\\x9b\\xe98\\xef\r\\xef\\xbb\\xee\\x8d2-"] = 0
}

M.OnInit = function(self)
	self.toiletNpcRecord = {}
	self.safeDriveScore = 0
	self.curBalloonGadgetId = 0
	self.curWashMachineId = 0
	self.curWashingSpeed = 2
	self.curWashingLayer = 0
	self.hasSetWashingLayer = false
end

M.GetSafeDriveScore = function(self)
	return self.safeDriveScore
end

M.SetToiletNpcResult = function(self, npcPid, result)
	if not self.toiletNpcRecord[npcPid] then
		self.toiletNpcRecord[npcPid] = {
			result = false
		}
	end

	self.toiletNpcRecord[npcPid].result = result
end

M.GetToiletNpcResult = function(self, npcPid)
	if self.toiletNpcRecord[npcPid] ~= nil then
		return false
	end

	return self.toiletNpcRecord[npcPid].result or false
end

M.SimulatorEventType = {
	["lIIgJ:?"] = 3,
	["3F\\xb5\\x9c\\x82F"] = 2,
	["\\xf6\\xd57'\\xfa"] = 0,
	["\\xb0::\\x94O\\xfd%\\xab\\xbe"] = 1
}
M.SimulatorGameType = {
	[":Z\\x88\\xba\\x86@"] = 0,
	["\\xe9\\xda*!\\xf0"] = 1,
	["\\xea\\xde*!\\xf0"] = 1,
	["?]\\x85\\xba\\x86@"] = 1,
	["T-s^"] = -1
}

M.ExitSimulatorGame = function(self)
	gPanelManager:Close(gPanelId.S_FARM_PANEL)

	if self and self.currentSimulatorGame then
		self.currentSimulatorGame:CleanGame()

		self.currentSimulatorGame = nil
	end
end

M.StartSimulatorGame = function(self, gameType, data)
	gPanelManager:CheckShow(gPanelId.S_FARM_PANEL, {
		params = {
			gameplayType = gameType,
			data = data
		}
	})
end

M.StartBBQGame = function(self, sceneNodeGo, entityInstanceId)
	if not gBBQGameManager then
		print_error("[MiniGameDataManager] gBBQGameManager 未初始化")

		return
	end

	gBBQGameManager:StartBBQGame(sceneNodeGo, entityInstanceId)
end

M.AddPlayerSingleScore = function(self, playerId, singleScore)
	gMessageManager:SendMessage(gEventConstants.SEND_BBQ_PLAYER_SINGLE_SCORE, {
		playerId = playerId,
		singleScore = singleScore
	})
end

M.SetLayer = function(self, layer)
	if not self.hasSetWashingLayer then
		self.curWashingLayer = layer
		self.hasSetWashingLayer = true
	end
end

M.StartWashingMachine = function(self, data)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore and data then
		local entityInstanceId = data.instanceId
		self.curWashingSpeed = data.paramTransitionSpeed

		if self.curWashingSpeed < 0 then
			self.curWashingSpeed = 2
		end

		self.curWashMachineId = entityInstanceId

		gSpoonClientMgr:ReleaseContextEvent(entityInstanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
			["PNkgO:!"] = "p\\x89\\x98\\x92ݳ\\xcd2\\xa7:(\\xbc3",
			entityInstanceId = entityInstanceId
		})
		gameplayControlStore:StopGameplayByType(gHUDGameplayType.WASHING_MACHINE)
		gameplayControlStore:StartGameplayByType(gHUDGameplayType.WASHING_MACHINE)
	end
end

M.StopWashingMachine = function(self)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if ulong.equals(self.curWashMachineId, 0) then
		return
	end

	self.hasSetWashingLayer = false

	if gameplayControlStore then
		LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(true, gBanId.WASHING_MACHINE)
		LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, gBanId.WASHING_MACHINE)
		gameplayControlStore:StopGameplayByType(gHUDGameplayType.WASHING_MACHINE)
		gSpoonClientMgr:ReleaseContextEvent(self.curWashMachineId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
			["PNkgO:!"] = "4+3\\xec^\\x99\\xf4<\\xa1!\\xe3\\xd7\\xfe}\\xef",
			entityInstanceId = self.curWashMachineId
		})

		self.curWashMachineId = 0
		self.curWashingSpeed = 2
	end
end

M.GmStartXiWu = function(self, isStart)
	if isStart then
		gPanelManager:CheckShow(gPanelId.XIWU_MAIN_PANEL, {
			s1ZV = true
		})
	else
		gPanelManager:Close(gPanelId.XIWU_MAIN_PANEL)
	end
end

M.GmEndPullWash = function(self)
	local store = gStoreManager:GetStoreGroup("PulloutRadishStore")

	store:GameEnd(true)
end

M.StartBalloon = function(self, data)
	self.curBalloonGadgetId = data.gadgetId

	gPanelManager:CheckShow(gPanelId.BALLOON_PANEL, data)
end

M.StopBalloon = function(self)
	self.curBalloonGadgetId = 0

	LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(true, gBanId.BALLOON_GAME)
	LX6.GUI.GuiMgr.Instance:SetDisableJoystick(false, gBanId.BALLOON_GAME)

	local store = gStoreManager:GetStoreGroup("BalloonGameStore")

	if store then
		store.OnGameEnd(store)
	end
end

M.StartShoulderPole = function(self)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore then
		gameplayControlStore.StopGameplayByType(gameplayControlStore, gHUDGameplayType.SHOULDER_POLE)
		gameplayControlStore.StartGameplayByType(gameplayControlStore, gHUDGameplayType.SHOULDER_POLE)
	end
end

M.StopShoulderPole = function(self)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore then
		gameplayControlStore.StopGameplayByType(gameplayControlStore, gHUDGameplayType.SHOULDER_POLE)
	end
end

M.PauseShoulderPole = function(self)
	self.StopShoulderPole(self)
end

M.ResumeShoulderPole = function(self)
	self.StartShoulderPole(self)
end

M.SetNiRenGameResult = function(self, result)
	self.niRenGameResult = result
end

M.GetNiRenGameResult = function(self)
	if self.niRenGameResult ~= nil then
		return {
			["\\xf0\\x93\\xe2\\xc4\\xee\\x91ٛ0-"] = 0,
			parts = {
				[0] = 0,
				1,
				2,
				3
			}
		}
	end

	return self.niRenGameResult
end

M.StartNiRenFighter = function(self, data)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore then
		gameplayControlStore.StopGameplayByType(gameplayControlStore, gHUDGameplayType.NIREN_FIGHTER)
		gameplayControlStore.StartGameplayByType(gameplayControlStore, gHUDGameplayType.NIREN_FIGHTER, data)
	end
end

M.StopNiRenFighter = function(self)
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if gameplayControlStore then
		gameplayControlStore.StopGameplayByType(gameplayControlStore, gHUDGameplayType.NIREN_FIGHTER)
	end
end

gMiniGameDataManager = M
