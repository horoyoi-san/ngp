-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\BehaviorInteractManager.lua
-- Decompiled from: 02222_BehaviorInteractManager.lua_b5b83ab9a1c3.luajit

local BehaviorInteractManager = LX6.Manager.BehaviorInteractManager
local bit = require("bit")
local StaticProps = {}
C_BehaviorInteractManager = DefClass("C_BehaviorInteractManager", C_BehaviorInteractManager, nil, StaticProps)
local M = C_BehaviorInteractManager

M.ctor = function(self)
	self.cs_mgr = BehaviorInteractManager.Instance
	self.cs_mgr.luaMgr = self
	self.checkSignal = 0
	self.entityInstanceId = ulong.zero
end

M.OnExit = function(self)
	self.cs_mgr:OnExit()

	self.checkSignal = 0
end

M.CheckInInteract = function(self)
	return self.cs_mgr.signal ~= 0
end

M.CheckBehaviorInteract = function(self, signal)
	local flag = bit.lshift(1, signal)

	return bit.band(self.checkSignal, flag) ~= 0
end

M.RegisterEntityInstanceId = function(self, instanceId)
	self.entityInstanceId = instanceId
end

M.StopBehaviorInteract = function(self)
	self.cs_mgr:StopBehaviorInteract()
end

M.RegisterBehaviorUnit = function(self, pid)
	self.cs_mgr.registerPid = pid
end

M.StartBehaviorInteract = function(self, name)
	self.cs_mgr:StartBehaviorInteract(name)
end

M.SetSignalByIndex = function(self, index)
	self.cs_mgr:SetSignalByIndex(index)
end

M.SetCacheBoolInfo = function(self, name, value)
	self.cs_mgr:SetCacheBoolInfo(name, value)
end

M.GetCacheBoolInfo = function(self, name)
	return self.cs_mgr:GetCacheBoolInfo(name)
end

M.SwitchCameraView = function(self, cameraId)
	if not self.store then
		self.store = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")
	end

	if self.store.STATE_EnableOnce then
		self.store:OnSwitchCameraView(cameraId)
	end
end

M.ShowPlayHud = function(self, groupId)
	self.checkSignal = self.cs_mgr.checkSignal

	gPanelManager:CheckShow(gPanelId.GAMEPLAY_HUD_PRO_PANEL, {
		["\\x99&/2Z\\x98I\\xcf>\\xa5\\xab"] = true,
		groupId = groupId
	})
end

M.HidePlayHud = function(self)
	gPanelManager:Close(gPanelId.GAMEPLAY_HUD_PRO_PANEL)
end

M.RefreshButton = function(self)
	if not self.store then
		self.store = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")
	end

	if self.store.STATE_EnableOnce then
		local inInteraction = self.cs_mgr.signal ~= 0
		self.checkSignal = self.cs_mgr.checkSignal

		self.store:SetBtnBackState(inInteraction)
		self.store:RefreshBtnState()
	end
end

M.SendRegEntitySignal = function(self, signal)
	if not ulong.equals(self.entityInstanceId, ulong.zero) then
		gSpoonClientMgr:TryCallInnerSignal(self.entityInstanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, signal)
	end
end

M.InvokeGlobalEntitySignal = function(self, signal)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = signal
	})
end

gBehaviorInteractManager = gBehaviorInteractManager or C_BehaviorInteractManager.new()
