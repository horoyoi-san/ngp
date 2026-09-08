-- Original chunk: @Lua\LuaFiles\LX6\GUI\Dialog\DialogMainChatManager.lua
-- Decompiled from: 00312_DialogMainChatManager.lua_2a7c08fa0fb1.luajit

local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local NPCChatNpcConfig = LTConfig.NPCChatNpcConfig
local DialogNpcInfo = require("LX6/GUI/Dialog/DialogNpcInfo")

if not gDialogMainChatManager then
	local M = {
		cachedNpcDialogInfos = {}
	}
end

M.GetNpcChatInfo = function(self, npcId)
	if ulong.check(npcId) then
		npcId = ulong.tonum2(npcId)
	end

	if self.cachedNpcDialogInfos[npcId] then
		return self.cachedNpcDialogInfos[npcId]
	end

	local npcCultivationCfg = NpcCultivationConfig.GetConfig(npcId)

	if npcCultivationCfg ~= nil then
		local normalNpcCfg = NPCChatNpcConfig.GetConfig(npcId)

		if normalNpcCfg ~= nil then
			print_warn("NPC聊天报错, NpcCultivation NPCChatNpc两个表都没查到，请相关策划查聊天表，NPC ID", npcId)

			return nil
		end

		local info = DialogNpcInfo.new(npcId, false, normalNpcCfg)
		self.cachedNpcDialogInfos[npcId] = info

		return info
	end

	local info = DialogNpcInfo.new(npcId, true, npcCultivationCfg)
	self.cachedNpcDialogInfos[npcId] = info

	return info
end

local CheckCanShowDialog = function()
	return (gBlackScreenManager.blackPanel ~= nil or gBlackScreenManager.blackPanel.state ~= 0) and gPanelManager:VisibleModeAll()
end

M.OnPanelVisibleChange = function(self)
	if gPlayerManager.infoLogin.bindData.pid ~= nil then
		return
	end

	if not CheckCanShowDialog() then
		return
	end

	Timer.New(function ()
		if CheckCanShowDialog() then
			gNpcChatManager:ScheduleCheckUncompletedChatAndDialog()
		end
	end, 0.1):Start()
end

gDialogMainChatManager = M
