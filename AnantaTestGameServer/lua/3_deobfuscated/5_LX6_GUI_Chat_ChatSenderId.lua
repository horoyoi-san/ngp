local M = {}

function M.New(chatCfg)
	if chatCfg == nil then
		return {}
	end

	if chatCfg.IsPlayerMessage then
		if L50.Chat.ChatManager.PlayerSelf < chatCfg.AsNpcCultivation then
			return M.NewNpc(chatCfg.AsNpcCultivation)
		end

		return M.NewPlayer()
	else
		return M.NewNpc(chatCfg.NPCid)
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

function M.eq(lhs, rhs)
	if lhs and rhs then
		if lhs.pid then
			return lhs.pid == rhs.pid
		else
			return lhs.npcId == rhs.npcId
		end
	else
		return lhs == rhs
	end
end

function M.neq(lhs, rhs)
	return not M.eq(lhs, rhs)
end

ChatSenderId = M
