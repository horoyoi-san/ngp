-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_GameplayReady.lua
-- Decompiled from: 00708_LinkManager_GameplayReady.lua_09145485b93d.luajit

local MessageConfig = LTConfig.MessageConfig
local LinkPrepareActionConfig = LTConfig.LinkPrepareActionConfig
local M = C_LinkManager

M.CheckPlayerIsReady = function(self, memberId)
	local linkGame = self.GetCurrentLinkGame(self)

	if not linkGame then
		return false
	end

	return linkGame.CheckPlayerIsReady(linkGame, memberId)
end

M.GetVehicleId = function(self, memberId)
	local linkGame = self.GetCurrentLinkGame(self)

	if not linkGame then
		return 0
	end

	return linkGame.GetVehicleId(linkGame, memberId)
end

M.GetMatchNumber = function(self, memberId)
	local mode = UX.Game.LinkMode.Match

	return self.LinkMemberIndex[mode] and self.LinkMemberIndex[mode][memberId] or 0
end

M.GetCharacterId = function(self, memberId)
	local linkGame = self.GetCurrentLinkGame(self)

	if not linkGame then
		return 0
	end

	return linkGame.GetCharacterId(linkGame, memberId)
end

M.GetPoseId = function(self, memberId)
	local linkGame = self.GetCurrentLinkGame(self)

	if not linkGame then
		return 1
	end

	return linkGame.GetPoseId(linkGame, memberId)
end

M.SetReadyInfo = function(self, memberId, readyInfo)
	if self.currentLinkGame and self.currentLinkGame.PrepareInfos then
		self.currentLinkGame.PrepareInfos[memberId] = readyInfo
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
end

M.CheckIsBlockReady = function(self)
	local linkGame = self.GetCurrentLinkGame(self)

	if not linkGame then
		return false
	end

	return linkGame.CheckIsBlockReady(linkGame)
end

M.AskReadyToPlay = function(self, isReady)
	if self.useNewStage then
		self.AskStageConfirm(self, LTConfig.LinkStageConfig.Prepare, isReady)
	else
		gClientToGameDelegate:AskReadyToPlay(isReady and 0 or 1).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end
	end
end

M.AskChangePrepareInfo = function(self, info, callback)
	slot3 = gClientToGameDelegate

	slot3:AskChangePrepareSetting(info).Callback = function (err)
		if err == MessageConfig.Ok then
			print_warn("AskChangePrepareInfo failed, error =", gCS.Error.GetNameById(err))

			if callback then
				callback(false)
			end

			return
		end

		if callback then
			callback(true)
		end
	end
end

M.OnGetMatchInfo = function(self, matchInfo)
	self.matchInfo = matchInfo
end

M.GetSelfUnitPid = function(self)
	return self.cs:GetSelfUnit()
end
