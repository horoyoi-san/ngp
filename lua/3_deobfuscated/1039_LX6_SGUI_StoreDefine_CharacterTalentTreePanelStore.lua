local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_CharacterTalentTreePanelStore = DefClass("C_CharacterTalentTreePanelStore", C_CharacterTalentTreePanelStore, C_CommonTalentTreePanelStore)
GroupName2Class.CharacterTalentTreePanelStore = C_CharacterTalentTreePanelStore
local M = C_CharacterTalentTreePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:OnAwake()
	M.base.OnAwake(self)

	self.bindData.levelupBtn.luaClick = self:CreateAction(self.OnCharacterTalentLevelup)
end

function M:OnRenderTalentLevelAndPoint()
	local currentExp, maxExp, currentLevel = self.mgr:GetCurrentExpInfo()
	local tCfg = TextScriptTextConfig.GetConfig(89900904)
	local nextFan = 0
	self.bindData.isMax, nextFan = self.mgr:CanLevelUp()

	if self.bindData.isMax == self.mgr.MAX_STATE.LOCK then
		local tlCfg = TextScriptTextConfig.GetConfig(89901340)
		self.bindData.talentLimitLabel = gString.Format(tlCfg.Text, nextFan)
	end

	self.bindData.avatarTalentCount = currentExp .. "/" .. maxExp
	self.bindData.sumTalentExp = self.mgr.commonTalentExp
	self.bindData.avatarLevel = gString.Format(tCfg.Text, currentLevel)
	self.bindData.talentProgress.maxValue = maxExp

	self.bindData.talentProgress:ProgressToValue(currentExp)

	self.bindData.canLevelUp = BOOL2CTL[self.mgr:CheckHasEnoughExp2LevelUp()]
end

function M:OnSpiritJobInfoChange()
	M.base.OnSpiritJobInfoChange(self)
	self:OnRenderTalentLevelAndPoint()
end

function M:OnShow(panelId, data)
	gNpcFavorManager:OnRenderHeadAvatar(self.bindData.headAvatar)
	M.base.OnShow(self, panelId, data)
end

function M:OnCharacterTalentLevelup()
	local currentExp, maxExp, _ = self.mgr:GetCurrentExpInfo()
	local needExp = math.min(maxExp - currentExp, self.mgr.commonTalentExp)

	self.mgr:OnCharacterTalentLevelup(needExp)
end
