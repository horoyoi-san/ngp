local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local NPCChatNpcConfig = LTConfig.NPCChatNpcConfig
local DialogNpcInfo = require("LX6/GUI/Dialog/DialogNpcInfo")

if not gDialogMainChatManager then
	local M = {
		cachedNpcDialogInfos = {}
	}
end

function M:GetNpcChatInfo(npcId)
	if ulong.check(npcId) then
		npcId = ulong.tonum2(npcId)
	end

	if self.cachedNpcDialogInfos[npcId] then
		return self.cachedNpcDialogInfos[npcId]
	end

	local npcCultivationCfg = NpcCultivationConfig.GetConfig(npcId)

	if npcCultivationCfg == nil then
		local normalNpcCfg = NPCChatNpcConfig.GetConfig(npcId)

		if normalNpcCfg == nil then
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

local function CheckCanShowDialog()
	return (gBlackScreenManager.blackPanel == nil or gBlackScreenManager.blackPanel.state == 0) and gPanelManager:VisibleModeAll()
end

function M:OnPanelVisibleChange()
	if gPlayerManager.infoLogin.bindData.pid == nil then
		return
	end

	if not CheckCanShowDialog() then
		return
	end

	Timer.New(function ()
		if CheckCanShowDialog() then
			gNpcChatManager:CheckUncompletedChatAndDialog(true)
		end
	end, 0.1):Start()
end

gDialogMainChatManager = M
