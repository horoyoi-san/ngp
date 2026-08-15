local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local TalentTreeConfig = LTConfig.TalentTreeConfig
C_CharacterTalentLevelTipsStore = DefClass("C_CharacterTalentLevelTipsStore", C_CharacterTalentLevelTipsStore, C_StoreGroup)
GroupName2Class.CharacterTalentLevelTipsStore = C_CharacterTalentLevelTipsStore
local M = C_CharacterTalentLevelTipsStore

function M:ctor()
	self.favorMgr = gNpcFavorManager
end

function M:OnAwake()
	return
end

function M:OnShow(panelId, data)
	local agentType = self.favorMgr:GetAgentTypeByFightSpiritId(data.spiritId)
	local _, _, level = gTalentTreeMgr:GetCurrentExpInfo(data.spiritId)

	gNpcFavorManager:OnRenderHeadAvatar(self.bindData.head, agentType, 0)

	self.bindData.titleLabel = gString.Format(TextScriptTextConfig.GetConfig(89901296).Text, level)
	self.bindData.descLabel = gString.Format(TextScriptTextConfig.GetConfig(89901295).Text, data.diff)

	Timer.New(function ()
		gPanelManager:Close(self.m_Id)
	end, TalentTreeConfig.CommonTalentPopupShowTime):Start()
end

function M:OnClose()
	return
end
