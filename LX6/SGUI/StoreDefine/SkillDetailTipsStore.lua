-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SkillDetailTipsStore.lua
-- Decompiled from: 01335_SkillDetailTipsStore.lua_11b17b416dcd.luajit

C_SkillDetailTipsStore = DefClass("C_SkillDetailTipsStore", C_SkillDetailTipsStore, C_StoreGroup)
GroupName2Class.SkillDetailTipsStore = C_SkillDetailTipsStore
local M = C_SkillDetailTipsStore

M.SetData = function(self)
	if self.bindData.text then
		self.bindData.text.text = gUrbanAbilityManager.SkillDetailTips
	end
end

M.OnEnable = function(self)
	self.bindData.text.text = gUrbanAbilityManager.SkillDetailTips
end
