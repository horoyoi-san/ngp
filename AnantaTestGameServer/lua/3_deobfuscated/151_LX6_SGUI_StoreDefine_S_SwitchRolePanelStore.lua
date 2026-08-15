C_S_SwitchRolePanelStore = DefClass("C_S_SwitchRolePanelStore", C_S_SwitchRolePanelStore, C_StoreGroup)
GroupName2Class.S_SwitchRolePanelStore = C_S_SwitchRolePanelStore
local M = C_S_SwitchRolePanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.startTime = 0
	self.IsShow = false
end

function M:OnShow(panelId, data)
	gLoadingManager:SwitchRole_SetSwitchRolePanel(self)
	self:ShowPhoneDialogUI(data.fightSpiritId)
	self:SetLeftRTCam(data.leftRTCam)

	self.bindData.state = 0
end

function M:OnClose()
	return
end

function M:ShowPhoneDialogUI(fightSpiritId)
	self.fightSpiritId = fightSpiritId
	local fightSpiritCfg = LTConfig.FightSpiritConfig.GetConfig(self.fightSpiritId)
	local avatarId = fightSpiritCfg and fightSpiritCfg.SHeadIconID or LTConfig.PhoneConfig.ContactDefaultSAvatarId
	local name = fightSpiritCfg and fightSpiritCfg.Name or ""

	if fightSpiritCfg and fightSpiritCfg.Id == LTConfig.FightSpiritConfig.DefaultMale or fightSpiritCfg.Id == LTConfig.FightSpiritConfig.DefaultFemale then
		name = gPlayerManager.infoLogin.bindData.name or ""
	end

	self:SetMaskEnable(true)
	self:RefreshAvatarIconAndName(avatarId, name)
end

function M:SetMaskEnable(isEnable)
	self.bindData.isMask = isEnable and 1 or 0
end

function M:RefreshAvatarIconAndName(avatarId, avatarName)
	if self.bindData then
		self.bindData.headIcon = avatarId
		self.bindData.headName = avatarName
	end
end

function M:HidePhoneDialogUI()
	self:SetMaskEnable(false)
end

function M:SetLeftRTCam(rtCamera)
	self.bindData.leftRT:SetCamera(rtCamera, true)
end

function M:SetRightRTCam(rtCamera)
	self.bindData.rightRT:SetCamera(rtCamera, true)
end

function M:SetPhaseOneThird()
	self.bindData.state = 1
end

function M:SetPhaseHalf()
	self.bindData.state = 3
end

function M:SetPhaseRight()
	self.bindData.state = 2
end

function M:ReleaseRTManual()
	if self.bindData and self.bindData.rightRT then
		self.bindData.rightRT:ReleaseRT(true)
		self.bindData.rightRT:SetCamera(nil)
	end
end
