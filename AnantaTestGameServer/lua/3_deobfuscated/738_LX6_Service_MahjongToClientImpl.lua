local MahjongToClientImpl = gRpcChecker:CreateRpcImpl()

function MahjongToClientImpl.SyncInMjGame(inGame, isOnLogin, roomType)
	gMaJiangManager:SetInGame(inGame)

	if not isOnLogin or not gMaJiangManager:CheckIsInGame() then
		return
	end

	if inGame then
		gClientToAvatarDelegate:BackToMahjong().Callback = function (errID)
			if errID == 0 then
				return
			end

			print_error("BackToMahjong failed, error =", gCS.Error.GetNameById(errID))
		end
	end
end

function MahjongToClientImpl.SendCustomHotPatchMahjongToClient(data)
	return
end

return MahjongToClientImpl
