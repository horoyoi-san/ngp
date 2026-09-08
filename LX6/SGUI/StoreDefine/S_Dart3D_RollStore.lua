-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_Dart3D_RollStore.lua
-- Decompiled from: 01392_S_Dart3D_RollStore.lua_c7868253a965.luajit

C_S_Dart3D_RollStore = DefClass("C_S_Dart3D_RollStore", C_S_Dart3D_RollStore, C_StoreGroup)
GroupName2Class.S_Dart3D_RollStore = C_S_Dart3D_RollStore
local M = C_S_Dart3D_RollStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	gDartsGameManager:ShowOrHideQuad(false)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	gDartsGameManager:ShowOrHideQuad(true)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	local dartsGame = gDartsGameManager.currentDartsGame

	if dartsGame and dartsGame.online and dartsGame.isGameTypeRandom then
		self.PlayRollAnimAndOpenSelect(self)
	end
end

M.PlayRollAnimAndOpenSelect = function(self)
	local dartsGame = gDartsGameManager.currentDartsGame

	if not dartsGame then
		return
	end

	local playModeDetail = dartsGame.playModeDetail
	local clipName = nil

	if playModeDetail ~= dartsGame.DartsGameModeDetailType.HIGH_SCORE then
		clipName = "S_Dart3D_roll_HighScore"
	elseif playModeDetail ~= dartsGame.DartsGameModeDetailType.P301 then
		clipName = "S_Dart3D_roll_301"
	elseif playModeDetail ~= dartsGame.DartsGameModeDetailType.P501 then
		clipName = "S_Dart3D_roll_501"
	end

	if clipName and self.bindData.rollAnim then
		local clip = self.bindData.rollAnim:GetClip(clipName)
		local clipLength = clip and clip.length or 0

		self.bindData.rollAnim:Play(clipName)

		self.rollAnimCo = coroutine.start(function ()
			coroutine.wait(clipLength)
			coroutine.wait(3)
			gPanelManager:CheckShow(gPanelId.S_DART_SELECT_PANEL)

			self.rollAnimCo = nil
		end)

		return
	end

	gPanelManager:CheckShow(gPanelId.S_DART_SELECT_PANEL)
end

M.OnClose = function(self)
	if self.rollAnimCo then
		coroutine.stop(self.rollAnimCo)

		self.rollAnimCo = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
