C_UrbanAbilityLUTipsStore = DefClass("C_UrbanAbilityLUTipsStore", C_UrbanAbilityLUTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityLUTipsStore = C_UrbanAbilityLUTipsStore
local M = C_UrbanAbilityLUTipsStore

function M:ctor()
	self.aniNameOpen = "S_Vx_UrbanAbilityLUTips_open"
	self.aniName02 = "S_Vx_UrbanAbilityLUTips_open02"
end

function M:OnAwake()
	self.bindData.gotoBtn.luaClick = self:CreateAction("OnBtnClick")
end

function M:OnShow(panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex
	self.spiritId = args.spiritId
	self.info = args.info

	self:SetData()
end

function M:OnEnable()
	self:InitView()
end

function M:OnDisable()
	if self.autoCloseCo then
		coroutine.stop(self.autoCloseCo)

		self.autoCloseCo = nil
	end
end

function M:InitView()
	if self.autoCloseCo then
		coroutine.stop(self.autoCloseCo)

		self.autoCloseCo = nil
	end

	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(5)
		gPanelManager:Close(self.panelId)
	end)
end

function M:SetData()
	local aCfg = LTConfig.UrbanAbilityConfig.GetConfig(self.info.TemplateId)

	if not aCfg then
		return
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, self.aniNameOpen)

	local buffCfg = LTConfig.UrbanAbilityBuffConfig.GetConfig(aCfg.InitBuffId + self.info.Level - 1)
	self.bindData.title = buffCfg.Name
	self.bindData.abilityIcon = aCfg.Icon
	local maxExp = gUrbanAbilityManager:GetAbilityInfoMaxExp(self.info.TemplateId)
	self.bindData.progressText = self.info.Exp .. "/" .. maxExp

	self.bindData.progress:ProgressToValue(self.info.Exp / maxExp)
end

function M:OnClose()
	return
end

function M:OnBtnClick()
	local data = {
		tab = gUrbanAbilityManager.URBANABILITY_PAGE.BASIC_FEATURE,
		urbanAbilityId = self.info.TemplateId
	}

	gPanelManager:CheckShow(gPanelId.S_URBAN_ABILITY_PANEL, data)
end
