local BehaviorInteractManager = LX6.Manager.BehaviorInteractManager
local bit = require("bit")
local StaticProps = {}
C_BehaviorInteractManager = DefClass("C_BehaviorInteractManager", C_BehaviorInteractManager, nil, StaticProps)
local M = C_BehaviorInteractManager

function M:ctor()
	self.cs_mgr = BehaviorInteractManager.Instance
	self.cs_mgr.luaMgr = self
	self.checkSignal = 0
	self.entityInstanceId = ulong.zero
end

function M:OnExit()
	self.cs_mgr:OnExit()

	self.checkSignal = 0
end

function M:CheckInInteract()
	return self.cs_mgr.signal == 0
end

function M:CheckBehaviorInteract(signal)
	local flag = bit.lshift(1, signal)

	return bit.band(self.checkSignal, flag) == 0
end

function M:RegisterEntityInstanceId(instanceId)
	self.entityInstanceId = instanceId
end

function M:StopBehaviorInteract()
	self.cs_mgr:StopBehaviorInteract()
end

function M:RegisterBehaviorUnit(pid)
	self.cs_mgr.registerPid = pid
end

function M:StartBehaviorInteract(name)
	self.cs_mgr:StartBehaviorInteract(name)
end

function M:SetSignalByIndex(index)
	self.cs_mgr:SetSignalByIndex(index)
end

function M:SetCacheBoolInfo(name, value)
	self.cs_mgr:SetCacheBoolInfo(name, value)
end

function M:GetCacheBoolInfo(name)
	return self.cs_mgr:GetCacheBoolInfo(name)
end

function M:SwitchCameraView(cameraId)
	if not self.store then
		self.store = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")
	end

	if self.store.STATE_EnableOnce then
		self.store:OnSwitchCameraView(cameraId)
	end
end

function M:ShowPlayHud(groupId)
	self.checkSignal = self.cs_mgr.checkSignal

	gPanelManager:CheckShow(gPanelId.GAMEPLAY_HUD_PRO_PANEL, {
		fromBehvior = true,
		groupId = groupId
	})
end

function M:HidePlayHud()
	gPanelManager:Close(gPanelId.GAMEPLAY_HUD_PRO_PANEL)
end

function M:RefreshButton()
	if not self.store then
		self.store = gStoreManager:GetStoreGroup("GameplayHudProPanelStore")
	end

	if self.store.STATE_EnableOnce then
		local inInteraction = self.cs_mgr.signal == 0
		self.checkSignal = self.cs_mgr.checkSignal

		self.store:SetBtnBackState(inInteraction)
		self.store:RefreshBtnState()
	end
end

function M:SendRegEntitySignal(signal)
	if not ulong.equals(self.entityInstanceId, ulong.zero) then
		gSpoonClientMgr:TryCallInnerSignal(self.entityInstanceId, signal)
	end
end

function M:InvokeGlobalEntitySignal(signal)
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = signal
	})
end

gBehaviorInteractManager = gBehaviorInteractManager or C_BehaviorInteractManager.new()
