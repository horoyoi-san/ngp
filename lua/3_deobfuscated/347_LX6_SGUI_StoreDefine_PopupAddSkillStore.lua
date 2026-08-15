local UrbanJobConfig = LTConfig.UrbanJobConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local UrbanJobJobClassConfig = LTConfig.UrbanJobJobClassConfig
C_PopupAddSkillStore = DefClass("C_PopupAddSkillStore", C_PopupAddSkillStore, C_StoreGroup)
GroupName2Class.PopupAddSkillStore = C_PopupAddSkillStore
local M = C_PopupAddSkillStore

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
	local jobId = data.jobId
	local cfg = UrbanJobConfig.GetConfig(jobId)

	if not cfg and jobId ~= 0 then
		return
	end

	self.bindData.addLabel = gUIUtils:GetNumberStr(data.diff)

	if jobId == 0 then
		self.bindData.nameLabel = TextScriptTextConfig.GetConfig(89901331).Text
	else
		local cCfg = UrbanJobJobClassConfig.GetConfig(cfg.JobClass)
		self.bindData.nameLabel = gString.Format(TextScriptTextConfig.GetConfig(89901253).Text, cCfg.ClassName)
	end

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
