C_S_Dart3D_GameStartStore = DefClass("C_S_Dart3D_GameStartStore", C_S_Dart3D_GameStartStore, C_StoreGroup)
GroupName2Class.S_Dart3D_GameStartStore = C_S_Dart3D_GameStartStore
local M = C_S_Dart3D_GameStartStore

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.bindData.myNameText.text = gDartsGameManager.currentDartsGame.playerList[1].playerName
	self.bindData.otherNameText.text = gDartsGameManager.currentDartsGame.playerList[2].playerName

	if gDartsGameManager.currentDartsGame.playModeDetail == 1 then
		self.bindData.gameType = 4
	elseif gDartsGameManager.currentDartsGame.playModeDetail == 2 then
		self.bindData.gameType = 0
	elseif gDartsGameManager.currentDartsGame.playModeDetail == 3 then
		self.bindData.gameType = 1
	elseif gDartsGameManager.currentDartsGame.playModeDetail == 4 then
		self.bindData.gameType = 2
	end
end

function M:OnClose()
	return
end
