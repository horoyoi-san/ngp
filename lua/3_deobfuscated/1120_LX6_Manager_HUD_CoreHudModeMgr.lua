C_CoreHudModeMgr = DefClass("C_CoreHudModeMgr", C_CoreHudModeMgr, nil, StaticProps)
local M = C_CoreHudModeMgr

function M:ctor()
	self.HUD_MODE = {
		ANDROID = 3,
		GAMEPLAY = 2,
		EXPLORATION = 0,
		BASEVEHICLE = 1
	}
	self.currMode = self.HUD_MODE.EXPLORATION
	self.hudModeStack = {}
end

function M:PushHudMode(id, mode, Immediately)
	print_notice("CoreHudModeMgr:PushHudMode:", id, mode, Immediately)

	if #self.hudModeStack > 0 and self.hudModeStack[#self.hudModeStack].id == id then
		table.remove(self.hudModeStack, #self.hudModeStack)
		table.insert(self.hudModeStack, {
			id = id,
			mode = mode
		})
		self:SwitchToMode(mode, Immediately)
	end

	for i = #self.hudModeStack, 1, -1 do
		local control = self.hudModeStack[i]

		if control.id == id then
			table.remove(self.hudModeStack, i)

			break
		end
	end

	table.insert(self.hudModeStack, {
		id = id,
		mode = mode
	})
	self:OnStackHide(self.currMode)
	self:SwitchToMode(mode, Immediately)
end

function M:PopHudMode(id, Immediately)
	print_notice("CoreHudModeMgr:PopHudMode:", id, Immediately, #self.hudModeStack, #self.hudModeStack > 0 and self.hudModeStack[#self.hudModeStack].id == id or false)

	if #self.hudModeStack == 0 then
		return
	end

	if self.hudModeStack[#self.hudModeStack].id == id then
		table.remove(self.hudModeStack, #self.hudModeStack)

		local control = self.hudModeStack[#self.hudModeStack]
		local mode = self.HUD_MODE.EXPLORATION

		if control then
			mode = control.mode
		end

		self:SwitchToMode(mode, Immediately)
		self:OnStackShow(self.currMode)
	else
		for i = #self.hudModeStack, 1, -1 do
			local control = self.hudModeStack[i]

			if control.id == id then
				table.remove(self.hudModeStack, i)

				break
			end
		end
	end
end

function M:SwitchToMode(mode, Immediately)
	if self.currMode == mode then
		return
	end

	self.currMode = mode

	print_notice("CoreHudModeMgr:SwitchToMode:", mode, Immediately)

	if mode == self.HUD_MODE.BASEVEHICLE or mode == self.HUD_MODE.EXPLORATION then
		gUIFunctionStateManager:GameplaySetCharacterSwitch(true)
	else
		gUIFunctionStateManager:GameplaySetCharacterSwitch(false)
	end

	if mode == self.HUD_MODE.BASEVEHICLE then
		LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gPanelId.S_CORE_HUD_PANEL)

		gInteractionManager.driveMode = true
	else
		LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gPanelId.S_CORE_HUD_PANEL)

		gInteractionManager.driveMode = false
	end

	gStoreManager:GetStoreGroup("CoreHudPanelStore"):SwitchToMode(mode, Immediately)
end

function M:OnStackHide(mode)
	if mode == self.HUD_MODE.GAMEPLAY then
		local store = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

		if store.OnStackHide then
			store:OnStackHide()
		end
	end
end

function M:OnStackShow(mode)
	if mode == self.HUD_MODE.GAMEPLAY then
		local store = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

		if store.OnStackShow then
			store:OnStackShow()
		end
	end
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		table.clear(self.hudModeStack)

		self.currMode = self.HUD_MODE.EXPLORATION
	end
end

gCoreHudModeMgr = gCoreHudModeMgr or C_CoreHudModeMgr.new()
