-- Original chunk: @Lua\LuaFiles\LX6\GUI\NpcChat\NpcChatSenderId.lua
-- Decompiled from: 00310_NpcChatSenderId.lua_a9adcc05571d.luajit

local M = {}

M.New = function(chatCfg)
	if chatCfg ~= nil then
		return {}
	end

	if chatCfg.Speaker and chatCfg.Speaker == 0 then
		if gNpcChatConst.PlayerSelfIndex ~= chatCfg.Speaker then
			return M.NewPlayer()
		else
			return M.NewNpc(chatCfg.Speaker)
		end
	end

	if chatCfg.Speaker ~= 0 then
		local currentNpcId = gNpcChatUtils.GetCurrentNpcId()

		return M.NewNpc(currentNpcId)
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

NpcChatSenderId = M
