-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\GooseImitation\GooseImitationManager.lua
-- Decompiled from: 00620_GooseImitationManager.lua_9fbcf8d977c2.luajit

C_GooseImitationManager = DefClass("C_GooseImitationManager", C_GooseImitationManager)
local GooseImitationManager = C_GooseImitationManager

GooseImitationManager.CreateGameCs = function(self, cfg)
	if self.currentCfg then
		self:ExitGameCs()
	end

	self.currentCfg = cfg

	gPanelManager:CheckShow(gPanelId.S_GOOSE_IMITATION_PANEL, cfg)
end

GooseImitationManager.ExitGameCs = function(self)
	self.currentCfg = nil
	local store = gStoreManager:GetStoreGroup("GooseImitationStore")

	if store then
		store:ForceExit()
	end

	gPanelManager:Close(gPanelId.S_GOOSE_IMITATION_PANEL)
end

GooseImitationManager.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
end

GooseImitationManager.OnBeforeSwitchScene = function(self, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType < gSwitchSceneType.Reconnect then
		return
	end

	if gGooseImitationManager.currentCfg then
		gGooseImitationManager:ExitGameCs()
	end
end

gGooseImitationManager = gGooseImitationManager or C_GooseImitationManager.new()
