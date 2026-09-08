-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityWuxueTipsStore.lua
-- Decompiled from: 01139_UrbanAbilityWuxueTipsStore.lua_435caae0be77.luajit

C_UrbanAbilityWuxueTipsStore = DefClass("C_UrbanAbilityWuxueTipsStore", C_UrbanAbilityWuxueTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityWuxueTipsStore = C_UrbanAbilityWuxueTipsStore
local M = C_UrbanAbilityWuxueTipsStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.RegisterWidget(self)
end

M.OnShow = function(self, panelId, data)
	if not data then
		return
	end

	self.SetWuxueInfo(self, data)
	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(self.m_Id)
	end, 3)
end

M.OnClose = function(self)
	self.bindData.wuxueName = ""
	self.bindData.iconId = 0
end

M.RegisterWidget = function(self)
end

M.SetWuxueInfo = function(self, data)
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
