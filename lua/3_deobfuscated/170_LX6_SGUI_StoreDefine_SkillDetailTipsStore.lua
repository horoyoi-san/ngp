C_SkillDetailTipsStore = DefClass("C_SkillDetailTipsStore", C_SkillDetailTipsStore, C_StoreGroup)
GroupName2Class.SkillDetailTipsStore = C_SkillDetailTipsStore
local M = C_SkillDetailTipsStore

function M:SetData()
	if self.bindData.text then
		self.bindData.text.text = gUrbanAbilityManager.SkillDetailTips
	end
end

function M:OnEnable()
	self.bindData.text.text = gUrbanAbilityManager.SkillDetailTips
end
