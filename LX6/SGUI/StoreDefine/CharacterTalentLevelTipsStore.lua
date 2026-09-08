-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CharacterTalentLevelTipsStore.lua
-- Decompiled from: 01476_CharacterTalentLevelTipsStore.lua_522d1c6a0de5.luajit

local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local TalentTreeConfig = LTConfig.TalentTreeConfig
C_CharacterTalentLevelTipsStore = DefClass("C_CharacterTalentLevelTipsStore", C_CharacterTalentLevelTipsStore, C_StoreGroup)
GroupName2Class.CharacterTalentLevelTipsStore = C_CharacterTalentLevelTipsStore
local M = C_CharacterTalentLevelTipsStore

M.ctor = function(self)
	self.favorMgr = gNpcFavorManager
end

M.OnAwake = function(self)
end

M.OnShow = function(self, panelId, data)
	local agentType = self.favorMgr:GetAgentTypeByFightSpiritId(data.spiritId)
	local _, _, level = gTalentTreeMgr:GetCurrentExpInfo(data.spiritId)

	gNpcFavorManager:OnRenderHeadAvatar(self.bindData.head, agentType, 0)

	self.bindData.titleLabel = gString.Format(TextScriptTextConfig.GetConfig(89901296).Text, level)
	self.bindData.descLabel = gString.Format(TextScriptTextConfig.GetConfig(89901295).Text, data.diff)

	Timer.New(function ()
		gPanelManager:Close(self.m_Id)
	end, TalentTreeConfig.CommonTalentPopupShowTime):Start()
end

M.OnClose = function(self)
end
