-- Original chunk: @Lua\LuaFiles\LX6\Service\MahjongToClientImpl.lua
-- Decompiled from: 02356_MahjongToClientImpl.lua_201143129d96.luajit

slot0 = gRpcChecker
local MahjongToClientImpl = slot0:CreateRpcImpl()

MahjongToClientImpl.SyncInMjGame = function(inGame, isOnLogin, roomType)
	if gMaJiangManager.isInServerGame and not inGame then
		gMaJiangManager:DestroyGame("SyncInMjGame")

		return
	end

	gMaJiangManager:SetInServerGame(inGame)

	if inGame then
		gMaJiangManager:Temp_EnsureGame()
		gMaJiangManager:Temp_TryBeginMajiangGameAfterReceiveServerData()
	end

	if inGame and not isOnLogin then
		slot3 = gClientToGameDelegate

		slot3:BackToMahjong().Callback = function (errID)
			if errID ~= 0 then
				return
			end

			print_error("BackToMahjong failed, error =", gCS.Error.GetNameById(errID))
		end
	end
end

MahjongToClientImpl.SendCustomHotPatchMahjongToClient = function(data)
end

return MahjongToClientImpl
