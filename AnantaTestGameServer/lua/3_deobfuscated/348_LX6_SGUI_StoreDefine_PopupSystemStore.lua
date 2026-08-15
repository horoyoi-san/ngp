local SystemUnlockConfig = LTConfig.SystemUnlockConfig
C_PopupSystemStore = DefClass("C_PopupSystemStore", C_PopupSystemStore, C_StoreGroup)
GroupName2Class.PopupSystemStore = C_PopupSystemStore
local M = C_PopupSystemStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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

function M:OnExit()
	gPanelManager:Close(self.m_Id)
end

function M:OnShow(panelId, data)
	local cfg = SystemUnlockConfig.GetConfig(data and data.id or 0)
	self.bindData.systemName = cfg.Description
	self.bindData.PopupPic = data and data.PopupPic
	self.bindData.contentName = data and data.PopupName
	local duration = LTConfig.DropConfig.SpecialDropShowTime
	self.timer = Timer.New(function ()
		self:OnExit()
	end, duration):Start()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	return
end
