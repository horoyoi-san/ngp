C_CoreHudPanelStore = DefClass("C_CoreHudPanelStore", C_CoreHudPanelStore, C_StoreGroup)
GroupName2Class.CoreHudPanelStore = C_CoreHudPanelStore
local M = C_CoreHudPanelStore

function M:ctor()
	self.STATE_MODE = {
		SHOOT = 2,
		PHONE = 1,
		DEFAULT = 0
	}
	self.msgEvents = {
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction("OnPhoneAppShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnPhoneAppHide"),
		[gEventConstants.CHANGE_MY_UNIT] = self:CreateAction("OnCharacterChange")
	}
	self.mgr = gStoreButtonMgr
end

function M:OnAwake()
	self.mgr:OnInit()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnDestroy()
	self.lastHudMode = nil

	self:ClearMessageEvents()
end

function M:OnShow()
	self:SwitchToMode(gCoreHudModeMgr.currMode)
end

function M:OnClose()
	return
end

function M:RegisterOperation(operation)
	return self.mgr:RegisterOperation(operation)
end

function M:UnRegisterOperation(instanceId)
	return self.mgr:UnRegisterOperation(instanceId)
end

function M:SetButtonVisibleBase(btnStore, visible)
	return self.mgr:SetButtonVisibleBase(btnStore, visible)
end

function M:SetButtonInteractableBase(btnStore, interactable)
	return self.mgr:SetButtonInteractableBase(btnStore, interactable)
end

function M:SetButtonControlBase(btnStore, visible, interactable)
	return self.mgr:SetButtonControlBase(btnStore, visible, interactable)
end

function M:OnPhoneAppShow()
	self.bindData:Commit("stateModeCtrl", self.STATE_MODE.PHONE, COMMIT_IMMEDIATELY)
	gCS.ParkourStateModule.SetClientState(LTConfig.ParkourStateConfig.OpenPhone, true)
end

function M:OnPhoneAppHide()
	self.bindData:Commit("stateModeCtrl", self.STATE_MODE.DEFAULT, COMMIT_IMMEDIATELY)
	gCS.ParkourStateModule.SetClientState(LTConfig.ParkourStateConfig.OpenPhone, false)
end

function M:SwitchMainPhoneModeCtrlToShoot(enable)
	if self.bindData.stateModeCtrl == self.STATE_MODE.PHONE then
		return
	end

	self.bindData:Commit("stateModeCtrl", enable and self.STATE_MODE.SHOOT or self.STATE_MODE.DEFAULT, COMMIT_IMMEDIATELY)
end

function M:PlayHudFadeInEffect()
	if self.bindData.fadeInEffectAni then
		local aniName = "S_vx_CoreHudPanel_open"

		gBattleMgr:CommonPlayAniTool(self.bindData.fadeInEffectAni, aniName, 0, 1)
	end
end

function M:SwitchToMode(mode, Immediately)
	if self.STATE_EnableOnce then
		if Immediately then
			self.bindData:Commit("HUDModeCtrl", mode, COMMIT_IMMEDIATELY)
		else
			self.bindData.HUDModeCtrl = mode
		end
	end
end

function M:OnCharacterChange(eventId, data)
	if gCS.MyPlayerManager.PlayerUnit.ClientData.cardId == 15022030 then
		self.bindData.switchCharacterCtrl = 1
	elseif self.bindData.switchCharacterCtrl ~= 0 then
		self.bindData.switchCharacterCtrl = 0
	end
end
