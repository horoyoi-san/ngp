-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CharacterTalentTreePanelStore.lua
-- Decompiled from: 01911_CharacterTalentTreePanelStore.lua_0d225efc6ffb.luajit

local TextScriptTextConfig = LTConfig.TextScriptTextConfig
C_CharacterTalentTreePanelStore = DefClass("C_CharacterTalentTreePanelStore", C_CharacterTalentTreePanelStore, C_CommonTalentTreePanelStore)
GroupName2Class.CharacterTalentTreePanelStore = C_CharacterTalentTreePanelStore
local M = C_CharacterTalentTreePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.OnAwake = function(self)
	M.base.OnAwake(self)

	self.bindData.levelupBtn.luaClick = self.CreateAction(self, self.OnOpenTalentExpPanel)
end

M.OnRenderTalentLevelAndPoint = function(self)
	local currentExp, maxExp, currentLevel = self.mgr:GetCurrentExpInfo()
	local tCfg = TextScriptTextConfig.GetConfig(89900904)
	local nextFan = 0
	self.bindData.isMax, nextFan = self.mgr:CanLevelUp()

	if self.bindData.isMax ~= self.mgr.MAX_STATE.LOCK then
		local tlCfg = TextScriptTextConfig.GetConfig(89901340)
		self.bindData.talentLimitLabel = gString.Format(tlCfg.Text, nextFan)
	end

	self.bindData.avatarTalentCount = currentExp .. "/" .. maxExp
	self.bindData.avatarLevel = gString.Format(tCfg.Text, currentLevel)
	self.bindData.talentProgress.maxValue = maxExp

	self.bindData.talentProgress:ProgressToValue(currentExp)

	self.bindData.canLevelUp = BOOL2CTL[self.bindData.isMax == self.mgr.MAX_STATE.TRUE]
end

M.OnOpenTalentExpPanel = function(self)
	gTalentTreeMgr:OpenTalentExpPanel()
end

M.OnSpiritJobInfoChange = function(self)
	M.base.OnSpiritJobInfoChange(self)
	self.OnRenderTalentLevelAndPoint(self)
end

M.OnShow = function(self, panelId, data)
	gNpcFavorManager:OnRenderHeadAvatar(self.bindData.headAvatar)
	M.base.OnShow(self, panelId, data)
end
