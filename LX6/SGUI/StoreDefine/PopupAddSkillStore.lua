-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PopupAddSkillStore.lua
-- Decompiled from: 00796_PopupAddSkillStore.lua_78398acbc84b.luajit

local UrbanJobConfig = LTConfig.UrbanJobConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local UrbanJobJobClassConfig = LTConfig.UrbanJobJobClassConfig
C_PopupAddSkillStore = DefClass("C_PopupAddSkillStore", C_PopupAddSkillStore, C_StoreGroup)
GroupName2Class.PopupAddSkillStore = C_PopupAddSkillStore
local M = C_PopupAddSkillStore

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
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnExit = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnShow = function(self, panelId, data)
	local jobId = data.jobId
	local cfg = UrbanJobConfig.GetConfig(jobId)

	if not cfg and jobId == 0 then
		return
	end

	self.bindData.addLabel = gUIUtils:GetNumberStr(data.diff)

	if jobId ~= 0 then
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

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
