C_UrbanAbilityWuxueTipsStore = DefClass("C_UrbanAbilityWuxueTipsStore", C_UrbanAbilityWuxueTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityWuxueTipsStore = C_UrbanAbilityWuxueTipsStore
local M = C_UrbanAbilityWuxueTipsStore

function M:ctor()
	return
end

function M:OnAwake()
	self:RegisterWidget()
end

function M:OnShow(panelId, data)
	if not data then
		return
	end

	self:SetWuxueInfo(data)
	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(self.m_Id)
	end, 3)
end

function M:OnClose()
	self.bindData.wuxueName = ""
	self.bindData.iconId = 0
end

function M:RegisterWidget()
	return
end

function M:SetWuxueInfo(data)
	if not data.fightSkillId then
		return
	end

	local fightSkillCfg = LTConfig.FightSkillConfig.GetConfig(data.fightSkillId)

	if not fightSkillCfg then
		return
	end

	self.bindData.wuxueName = fightSkillCfg.Name
	self.bindData.iconId = fightSkillCfg.IconId
	self.bindData.qualityCtrl = fightSkillCfg.Quality
	local skillTypeCfg = LTConfig.FightSkillFightSkillTypeConfig.GetConfig(fightSkillCfg.FightSkillType)

	if skillTypeCfg then
		self.bindData.typeText = skillTypeCfg.Name
	end
end
