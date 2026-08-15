local AchievementConfig = LTConfig.AchievementConfig
local AchievementFirstCategoryConfig = LTConfig.AchievementFirstCategoryConfig
C_AchievementPopOutPanelStore = DefClass("C_AchievementPopOutPanelStore", C_AchievementPopOutPanelStore, C_StoreGroup)
GroupName2Class.AchievementPopOutPanelStore = C_AchievementPopOutPanelStore
local M = C_AchievementPopOutPanelStore

function M:ctor()
	self.areaIndex = 0
	self.achieveId = 0
	self.delayTime = 3
	self.timer = nil
end

function M:OnAwake()
	self.bindData.backHit.luaClick = self:CreateAction("OnEnterPanel")
end

function M:OnShow(panelId, data)
	local param = data.Param
	self.callback = data.CallBack
	self.achieveId = param.achieveId
	self.areaIndex = data.areaIndex

	self:RefreshUI(self.achieveId)

	if self.timer then
		self.timer:Stop()
	end

	self.timer = Timer.New(function ()
		if gPanelManager:IsPanelShowing(self.m_Id) then
			self:OnBackBtnClick()
		end
	end, self.delayTime):Start()
end

function M:RefreshUI(achieveId)
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

function M:OnClose()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function M:OnBackBtnClick()
	gPanelManager:Close(self.m_Id)
end

function M:OnEnterPanel()
	self:OnBackBtnClick()
	gPanelManager:CheckShow(gPanelId.S_ACHIEVEMENT_DETAIL, {
		id = self.achieveId
	})
end
