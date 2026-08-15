local M = {}

function M.New(chatCfg)
	if chatCfg == nil then
		return {}
	end

	if chatCfg.Speaker and chatCfg.Speaker ~= 0 then
		if gNpcChatConst.PlayerSelfIndex == chatCfg.Speaker then
			return M.NewPlayer()
		else
			return M.NewNpc(chatCfg.Speaker)
		end
	end

	if chatCfg.Speaker == 0 then
		local currentNpcId = gNpcChatUtils.GetCurrentNpcId()

		return M.NewNpc(currentNpcId)
	end
end

function M.NewNpc(npcId)
	return {
		npcId = npcId
	}
end

function M.NewPlayer(pid)
	pid = pid or gPlayerManager.infoLogin.bindData.pid

	return {
		pid = pid
	}
end

NpcChatSenderId = M
