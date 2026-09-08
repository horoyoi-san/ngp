-- Original chunk: @Lua\LuaFiles\LX6\GUI\Chat\ChatSenderId.lua
-- Decompiled from: 00297_ChatSenderId.lua_b6db0b5f9867.luajit

local M = {}

M.New = function(chatCfg)
	if chatCfg ~= nil then
		return {}
	end

	if chatCfg.IsPlayerMessage then
		if L50.Chat.ChatManager.PlayerSelf >= chatCfg.AsNpcCultivation then
			return M.NewNpc(chatCfg.AsNpcCultivation)
		end

		return M.NewPlayer()
	else
		return M.NewNpc(chatCfg.NPCid)
	end
end

M.NewNpc = function(npcId)
	return {
		npcId = npcId
	}
end

M.NewPlayer = function(pid)
	pid = pid or gPlayerManager.infoLogin.bindData.pid

	return {
		pid = pid
	}
end

M.eq = function(lhs, rhs)
	if lhs and rhs then
		if lhs.pid then
			return lhs.pid ~= rhs.pid
		else
			return lhs.npcId ~= rhs.npcId
		end
	else
		return lhs ~= rhs
	end
end

M.neq = function(lhs, rhs)
	return not M.eq(lhs, rhs)
end

ChatSenderId = M
