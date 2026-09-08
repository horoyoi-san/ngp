-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AchievementPopOutPanelStore.lua
-- Decompiled from: 01591_AchievementPopOutPanelStore.lua_898de9706272.luajit

local AchievementConfig = LTConfig.AchievementConfig
local AchievementFirstCategoryConfig = LTConfig.AchievementFirstCategoryConfig
C_AchievementPopOutPanelStore = DefClass("C_AchievementPopOutPanelStore", C_AchievementPopOutPanelStore, C_StoreGroup)
GroupName2Class.AchievementPopOutPanelStore = C_AchievementPopOutPanelStore
local M = C_AchievementPopOutPanelStore

M.ctor = function(self)
	self.areaIndex = 0
	self.achieveId = 0
	self.delayTime = 3
	self.timer = nil
end

M.OnAwake = function(self)
	self.bindData.backHit.luaClick = self.CreateAction(self, "OnEnterPanel")
end

M.OnShow = function(self, panelId, data)
	local param = data.Param
	self.callback = data.CallBack
	self.achieveId = param.achieveId
	self.areaIndex = data.areaIndex

	self.RefreshUI(self, self.achieveId)

	if self.timer then
		self.timer:Stop()
	end

	self.timer = Timer.New(function ()
		if gPanelManager:IsPanelShowing(self.m_Id) then
			self:OnBackBtnClick()
		end
	end, self.delayTime):Start()
end

M.RefreshUI = function(self, achieveId)
	local cfg = AchievementConfig.GetConfig(achieveId)

	if cfg then
		self.bindData.nameLabel = cfg.Name
		local firstCfg = AchievementFirstCategoryConfig.GetConfig(cfg.FirstCategoryType)

		if firstCfg then
			self.bindData.iconId = firstCfg.SAchievementLogo
			self.bindData.quality = cfg.Quality
		end
	else
		print_error("Achievement 中不存在 id " .. (achieveId or 0))
	end
end

M.OnClose = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnEnterPanel = function(self)
	self:OnBackBtnClick()
	gPanelManager:CheckShow(gPanelId.S_ACHIEVEMENT_DETAIL, {
		id = self.achieveId
	})
end
