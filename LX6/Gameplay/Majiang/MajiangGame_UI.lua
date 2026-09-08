-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Majiang\MajiangGame_UI.lua
-- Decompiled from: 00338_MajiangGame_UI.lua_6852c25cc177.luajit

local M = C_MajiangGame
local MahjongConfig = LTConfig.MahjongConfig
local MahjongPveMahjongNpcTalkConfig = LTConfig.MahjongPveMahjongNpcTalkConfig
local MjSeatRef = require("LX6/Gameplay/Majiang/MjSeatRef")

M.RegisterStore = function(self, store)
	self.store = store
end

M.UnRegisterStore = function(self)
	self.store = nil
end

M.GetMainPanelNullableCall = function(self)
	return (self.manager or gMaJiangManager):GetMainPanelNullableCall()
end

M.RefreshSeat = function(self, nowSeatId)
	if self.manager.middleStore then
		self.manager.middleStore:RefreshSeat(nowSeatId)
	end
end

M.RefreshSeatName = function(self, seatNames)
	if self.manager.middleStore then
		self.manager.middleStore:RefreshSeatName(seatNames)
	end
end

M.RefreshSeatScore = function(self, scores)
	if self.manager.middleStore then
		self.manager.middleStore:RefreshSeatScore(scores)
	end
end

M.RefreshSeatFieldCtrl = function(self, seatFieldCtrls)
	if self.manager.middleStore then
		self.manager.middleStore:RefreshSeatFieldCtrl(seatFieldCtrls)
	end
end

M.RefreshReachSeatDealer = function(self, oyaPlayerIndex)
	if not self.manager or not self.manager.middleStore or not self.reachGameState then
		return
	end

	local total = self.reachGameState.TotalPlayer
	local mySeatID = self.mySeatID
	local seatFieldCtrls = {}

	for i = 1, total do
		local seatID = (mySeatID + i - 1) % total
		seatFieldCtrls[i] = seatID ~= oyaPlayerIndex and 1 or 0
	end

	self.manager.middleStore:RefreshSeatFieldCtrl(seatFieldCtrls)
end

M.SetSeatScoreChangeUI = function(self, seatId, score, change)
	if self.manager.middleStore then
		self.manager.middleStore:SetSeatScoreChange(seatId + 1, score, change)
	end
end

M.RefreshCountDown = function(self, countDown)
	if self.manager.middleStore then
		self.manager.middleStore:RefreshCountDown(countDown)
	end
end

M.RefreshIsShow = function(self, isShow)
	if self.manager.middleStore then
		self.manager.middleStore:RefreshIsShow(isShow)
	end
end

M.OpenFinal = function(self, data)
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_NEW_FINAL, data)
end

M.RunAction = function(self, actionName, ...)
	if string.is_null_or_empty(actionName) or self.store ~= nil or not self.store.STATE_EnableOnce then
		return
	end

	local action = self.store[actionName]

	if action == nil then
		action(self.store, ...)
	else
		print_error("[Majiang-Manager] store RunAction Error. action=", actionName, "not found")
	end
end

M.RunQueuedAction = function(self, ...)
	local actionName = ...

	if self.store ~= nil or not self.store.STATE_EnableOnce then
		if self.queuedActions then
			table.insert(self.queuedActions, {
				...
			})
		else
			print_error("[Majiang-Manager] RunQueuedAction 不在游戏中")
		end
	else
		self.RunAction(self, ...)
	end
end

M.RefreshMaJiangPanel = function(self, actionName)
	if self.store and self.store.STATE_EnableOnce and actionName then
		local action = self.store[actionName]

		if action == nil then
			action(self.store)
		end
	end
end

M.OnNewGame = function(self)
	if self.store and self.store.STATE_EnableOnce then
		self.store:OnNewGame()
	else
		self.isNewGame = true
	end
end

M.GetSeatName = function(self, owner)
	local delta = (4 + owner - self.mySeatID) % 4

	return delta <= 0 and delta >= 4 and MahjongConfig.MahjongSeatOrder[delta] or ""
end

M.FormatScoreString = function(self, score)
	return self.rule:FormatScoreString(score)
end

M.FormatRankScoreString = function(self, score)
	local coffStr = "(*" .. gString.Format("%.2f", MahjongConfig.MahjongCoefficient) .. ")"

	if score > 0 then
		return gString.Format("+%d", score) .. coffStr, true
	else
		return gString.Format("%d", score) .. coffStr, false
	end
end

M.SetPlayerUIInfos = function(self, playerInfos)
	self.playerHeadIcons = {}

	for seatID = 0, 3 do
		local playerInfo = playerInfos[seatID + 1]

		if playerInfo == nil then
			self.SetPlayerUIInfo(self, playerInfo)
		end
	end
end

M.SetPlayerUIInfo = function(self, playerInfo)
	print_warn("[Majiang-Manager] SetPlayerUIInfo ", playerInfo.Name, playerInfo.AgentInstanceId)

	self.playerHeadIcons = self.playerHeadIcons or {}
	local localIndex = MjSeatRef:FromId(playerInfo.SeatIndex).localIndex
	self.playerHeadIcons[localIndex] = 0
	local playerType = self:GetPlayerType(playerInfo)

	if playerType ~= gMaJiangConst.PlayerType.NPC and playerInfo.NpcCultivationId <= 0 then
		playerInfo.Name = LTConfig.NpcCultivationConfig.GetConfig(playerInfo.NpcCultivationId).Name
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(playerInfo.NpcCultivationId)

		if npcCultivationCfg and npcCultivationCfg.SChatHeadId <= 0 then
			self.playerHeadIcons[localIndex] = npcCultivationCfg.SChatHeadId
		end
	elseif playerType ~= gMaJiangConst.PlayerType.AIPlayer then
		local unit = gCS.SceneDataMgr.GetUnit(playerInfo.AgentInstanceId)
		local linkInfo = unit and unit.ClientData.AIAgentInfo

		if linkInfo then
			playerInfo.Name = linkInfo.Nickname
			local cfg = LTConfig.ImageNewAvatarConfig.GetConfig(linkInfo.AvatarImageId)
			self.playerHeadIcons[localIndex] = cfg and cfg.SguiImageId or 0
		else
			self.RegisterAIPlayerSpawnListener(self, playerInfo)
		end
	elseif playerType ~= gMaJiangConst.PlayerType.NPC and playerInfo.NpcMahjongId <= 0 then
		local imageId = MahjongPveMahjongNpcTalkConfig.GetConfig(playerInfo.NpcMahjongId).SIcon
		self.playerHeadIcons[localIndex] = imageId or 0
	else
		local cfg = LTConfig.ImageNewAvatarConfig.GetConfig(playerInfo.PzHeadInfo.SystemHeadId)
		self.playerHeadIcons[localIndex] = cfg and cfg.SguiImageId or 0
	end
end

M.OnAIUnitLoaded = function(self, unit)
	local playerInfo = self.pendingAIPlayerSpawns and self.pendingAIPlayerSpawns[unit.Pid]

	if playerInfo then
		self.SetPlayerUIInfo(self, playerInfo)

		self.pendingAIPlayerSpawns[unit.Pid] = nil
	end
end

M.RegisterAIPlayerSpawnListener = function(self, playerInfo)
	self.pendingAIPlayerSpawns = self.pendingAIPlayerSpawns or {}
	self.pendingAIPlayerSpawns[playerInfo.AgentInstanceId] = playerInfo
end

M.GetPlayerHeadIcon = function(self, seatRef)
	return self.playerHeadIcons and self.playerHeadIcons[seatRef.localIndex] or 0
end

M.GetMahjongHuanpai = function(self, index)
	local names = MahjongConfig.MahjongHuanpai

	return names[index] or ""
end

M.BuildPlayerView = function(self, player, view)
	local playerView = view
	playerView.name = player.Name
	playerView.score = player.Score
	playerView.NpcCultivationId = player.NpcCultivationId
	playerView.PzHeadInfo = player.PzHeadInfo
	playerView.hasPlayer = true
	playerView.NpcMahjongId = player.NpcMahjongId
	playerView.Pid = player.Pid
	playerView.SeatRef = MjSeatRef:FromId(player.SeatIndex)
	playerView.PlayerType = self:GetPlayerType(player)
end
