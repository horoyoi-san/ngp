local GameStateEnum = UX.Game.MjGameStateEnum
local MjActionType = UX.Game.MjActionType
local MahjongRoomType = UX.Game.MahjongRoomType
local MahjongRoomState = UX.Game.MahjongRoomState
local PCGType = UX.Game.MjPCGType
local MessageConfig = LTConfig.MessageConfig
local TingHelper = LX6.Mahjong.TingHelper
local MahjongConfig = LTConfig.MahjongConfig
local MahjongPveMahjongNpcTalkConfig = LTConfig.MahjongPveMahjongNpcTalkConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local IndoorConfig = LTConfig.IndoorConfig
local MahjongUtils = L18.Mahjong.MahjongUtils
local ImageAvatar = LTConfig.ImageAvatarConfig
local AgentConfig = LTConfig.AgentConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
C_MaJiangManager = DefClass("C_MaJiangManager", C_MaJiangManager, nil, nil)
local M = C_MaJiangManager

function M:ctor()
	self.gameState = 0
	self.hasHu = false
	self.lastPai = nil
	self.lastSeatID = -1
	self.hanGangID = -1
	self.hanGangPai = nil
	self.lastGangId = -1
	self.baseScore = 100
	self.lastMatchBaseScore = 100
	self.isInGame = false
	self.rankingList = nil
	self.myInfo = nil
	self.tingsPai = -1
	self.tingsInfo = nil
	self.myRankInfo = nil
	self.pveNpcList = {}
	self.npcPidList = {}
	self.eventHandler = {
		[gEventConstants.MAP_CHANGE_TO_INDOOR_MAP] = self:CreateAction(self.OnEvent_MapChangeToIndoorMap),
		[gEventConstants.AFTER_SWITCH_SCENE] = self:CreateAction(self.OnEvent_AfterSwitchScene),
		[gEventConstants.BEFORE_SWITCH_SCENE] = self:CreateAction(self.OnEvent_BeforeSwitchScene)
	}

	for event, func in pairs(self.eventHandler) do
		gMessageManager:AddMessageListener(event, func)
	end

	self.isNewGame = false
	self.store = nil
end

function M:OnEvent_MapChangeToIndoorMap(_, data)
	if not data or data.toIndoorId ~= IndoorConfig.MaJiangRoom then
		self:RemoveNpcInMaJiang()
	end
end

function M:OnEvent_AfterSwitchScene(_, switchType)
	if not self:CheckIsInGame() then
		return
	end

	if switchType == gSwitchSceneType.Reconnect then
		self:OnGameReconnect()
	else
		self:ClearGameState()
	end
end

function M:OnEvent_BeforeSwitchScene(_, switchType)
	if not self:CheckIsInGame() or switchType == gSwitchSceneType.Reconnect then
		return
	end

	self:ClearGameState()
end

function M:Clear()
	self.roomInfo = nil
	self.gameInfo = nil
	self.tingsInfo = nil
	self.tingsPai = -1
	self.store = nil
end

function M:SetRoomInfo(roomInfo)
	self.roomInfo = roomInfo

	for _, playerInfo in ipairs(roomInfo.PlayerInfos) do
		if playerInfo.NpcCultivationId ~= 0 then
			playerInfo.Name = LTConfig.NpcCultivationConfig.GetConfig(playerInfo.NpcCultivationId).Name
		end
	end

	self.roomState = roomInfo.State
	self.roomType = roomInfo.RoomType

	self:SetMySeatAndGameInfo()
end

function M:SetGameInfo(gameInfo)
	self.gameInfo = gameInfo
	self.hasHu = false
	self.newPai = nil

	if gameInfo ~= nil then
		self.myInfo = gameInfo.SeatInfos[self.mySeatID + 1]
		self.lastSeatID = gameInfo.Turn
	end

	self:RefreshGameState()
end

function M:SetMySeatAndGameInfo()
	local roomInfo = self.roomInfo

	if roomInfo == nil then
		return -1
	end

	local seatID = -1
	local gameCount = 0
	local myPid = gPlayerManager.infoBase.bindData.Pid
	local players = roomInfo.PlayerInfos

	for i = 1, 4 do
		local player = players[i]

		if player ~= nil and ulong.equals(myPid, player.Pid) then
			seatID = player.SeatIndex
			gameCount = player.GameCount or 0

			break
		end
	end

	self.mySeatID = seatID
	self.myGameCount = gameCount
end

function M:RefreshGameState()
	local gameInfo = self.gameInfo

	if gameInfo == nil then
		self.gameState = GameStateEnum.Begin

		return
	end

	local state = gameInfo.GameState
	self.gameState = state
	local index = self.mySeatID

	if index < 0 then
		return
	end

	if state == GameStateEnum.Playing then
		local myInfo = gameInfo.SeatInfos[index + 1]

		if #myInfo.HuPais > 0 then
			self.hasHu = true
		end
	end
end

function M:SetInGame(inGame)
	self.isInGame = inGame
end

function M:CheckIsInGame()
	return self.machine ~= nil
end

function M:CheckRedPoint()
	local mahjongInfo = gMaJiangManager.myRankInfo

	if mahjongInfo.MaxRank < 2 then
		return false
	end

	local newReward = {}

	for i = 2, mahjongInfo.MaxRank do
		newReward[i] = 1
	end

	if mahjongInfo.RewardRank then
		for _, v in ipairs(mahjongInfo.RewardRank) do
			newReward[v] = 0
		end
	end

	for _, v in pairs(newReward) do
		if v == 1 then
			return true
		end
	end

	return false
end

function M:SetGameState(state)
	self.gameState = state

	self:RunAction("UpdateTooltips", state)
end

function M:GetMyTings()
	return self:GetTings(self.mySeatID)
end

function M:GetTings(seatID)
	local gameInfo = self.gameInfo

	if gameInfo == nil then
		return
	end

	local a = gCS.LuaUtils.CreateIntList()
	local info = gameInfo.SeatInfos[seatID + 1]
	local holds = TingHelper.CreatePaiList()

	for _, v in ipairs(info.Holds) do
		local paiInfo = TingHelper.CreatePaiInfo(v.Index, v.MType, v.Red)

		holds:Add(paiInfo)
	end

	local seq = TingHelper.CreatePCGSequence()

	for _, v in ipairs(info.Sequence) do
		local pai = TingHelper.CreatePaiInfo(v.Pai.Index, v.Pai.MType, v.Pai.Red)
		local pcgActionInfo = TingHelper.CreatePCGActionInfo(v.Source, pai, v.PCGType)

		seq:Add(pcgActionInfo)
	end

	local tings = TingHelper.Calculate(holds, info.Que, seq)

	return tings
end

function M:GetTingsInfo(paiId)
	local tings = gMaJiangManager:GetMyTings()

	if tings == nil then
		return
	end

	local tingInfo = tings:ToTable()
	local hasTings = tingInfo[paiId] and true or false

	if hasTings then
		local myData = {}
		local paiIcons = MahjongConfig.MahjongSPai

		for _, v in pairs(tingInfo[paiId]:ToTable()) do
			local count = 4 - gMaJiangManager:GetAllMyKnownCount(v.Pai)
			local remain = count > 0 and count or 0
			local ting = {
				TingIcon = paiIcons[v.Pai + 1],
				TingCount = remain,
				TingFan = v.Fan
			}

			table.insert(myData, ting)
		end

		gMaJiangManager.tingsPai = paiId
		gMaJiangManager.tingsInfo = myData
	end

	return hasTings
end

function M:GetAllMyKnownCount(id)
	local gameInfo = self.gameInfo

	if gameInfo == nil then
		return 0
	end

	local count = 0

	for i = 1, 4 do
		local seatInfo = gameInfo.SeatInfos[i]

		for _, v in ipairs(seatInfo.Folds) do
			if v.Index == id then
				count = count + 1
			end
		end

		for _, v in ipairs(seatInfo.Sequence) do
			if v.Pai.Index == id then
				if v.PCGType == PCGType.Peng then
					count = count + 3
				elseif v.PCGType == PCGType.MingGang then
					count = count + 4
				elseif v.PCGType == PCGType.JiaGang then
					count = count + 4
				elseif v.PCGType == PCGType.AnGang then
					count = count + 4
				end
			end
		end

		for _, v in ipairs(seatInfo.HuPais) do
			if v.Index == id then
				count = count + 1
			end
		end
	end

	for _, v in ipairs(self.myInfo.Holds) do
		if v.Index == id then
			count = count + 1
		end
	end

	return count
end

function M:MapIndex(seatIndex)
	local count = 4
	local index = (count + seatIndex - self.mySeatID) % count + 1

	return index
end

function M:RefreshTimeOutByState(elapsedTime)
	local gameState = self.gameState
	local timeOut = -1
	local delta = gCS.TimeManager.ServerUnixTime - elapsedTime

	if gameState == GameStateEnum.HuanPai then
		timeOut = delta + MahjongConfig.MahjongHuansanzhangTime
	elseif gameState == GameStateEnum.DingQue then
		timeOut = delta + MahjongConfig.MahjongDingqueTime
	elseif gameState == GameStateEnum.Playing then
		timeOut = delta + MahjongConfig.MahjongChupaiTime
	end

	self.timeOut = timeOut
end

function M:OnMoPai(seatID, pai, remain)
	local gameInfo = self.gameInfo

	if gameInfo == nil then
		return
	end

	local info = gameInfo.SeatInfos[seatID + 1]
	info.HoldsCount = info.HoldsCount + 1

	if seatID == self.mySeatID then
		local holds = info.Holds
		holds[#holds + 1] = pai
		self.newPai = pai
	end

	gameInfo.Remainders = remain

	self:RunAction("OnMoPai", seatID, pai)
end

function M:RemoveFromHolds(info, seatId, pai, count)
	info.HoldsCount = info.HoldsCount - count

	if seatId ~= self.mySeatID then
		return
	end

	local holds = info.Holds

	for i = #holds, 1, -1 do
		if self:CheckSamePai(pai, holds[i]) then
			table.remove(holds, i)

			count = count - 1

			if count <= 0 then
				break
			end
		end
	end
end

function M:OnChuPai(seatID, pai)
	local gameInfo = self.gameInfo

	if gameInfo == nil then
		return
	end

	local info = gameInfo.SeatInfos[seatID + 1]
	local isMe = seatID == self.mySeatID

	self:RemoveFromHolds(info, seatID, pai, 1)

	if isMe then
		self.newPai = nil
	end

	local folds = info.Folds
	folds[#folds + 1] = pai
	self.lastSeatID = seatID
	self.lastPai = pai
	self.lastGangId = -1
	self.timeOut = gCS.TimeManager.ServerUnixTime + MahjongConfig.MahjongChupaiTime

	self:RunAction("OnChuPai", seatID)
end

function M:RemoveFromLastFolds(pai)
	local gameInfo = self.gameInfo

	if gameInfo == nil or self.lastSeatID < 0 or not self:CheckSamePai(self.lastPai, pai) then
		return
	end

	local folds = gameInfo.SeatInfos[self.lastSeatID + 1].Folds
	local count = #folds

	if self:CheckSamePai(folds[count], pai) then
		table.remove(folds, count)
	end
end

function M:OnHu(seatIDs, pai)
	local gameInfo = self.gameInfo

	if gameInfo == nil then
		return false
	end

	local seatID = seatIDs[1]
	local info = gameInfo.SeatInfos[seatID + 1]
	local lastPai = self.lastPai
	local lastSeatID = self.lastSeatID
	local isQiangGang = lastSeatID < 0 and self.hanGangID >= 0
	local isSelf = #seatIDs == 1 and lastPai == nil

	if lastPai and self.lastGangId == seatID then
		isSelf = true
	end

	local isGangShangKaiHua = isSelf and self.lastGangId == seatID

	if isSelf then
		self:RemoveFromHolds(info, seatID, pai, 1)
	elseif lastSeatID >= 0 then
		self:RemoveFromLastFolds(pai)

		self.lastSeatID = -1
		self.lastPai = nil
	else
		lastSeatID = self.hanGangID

		self:RevertWanGang()
		self:OnHanGangDone()
	end

	if not self.hasHu and seatID == self.mySeatID then
		self.hasHu = true

		self:RunAction("OnMyFirstHu")
	end

	for i = 1, #seatIDs do
		local id = seatIDs[i]
		local hus = gameInfo.SeatInfos[id + 1].HuPais
		hus[#hus + 1] = pai
	end

	self.lastGangId = -1

	self:RunAction("OnHu", seatIDs, isSelf, lastSeatID, isQiangGang, isGangShangKaiHua)
end

function M:OnPeng(seatID, pai)
	local gameInfo = self.gameInfo

	if gameInfo == nil then
		return
	end

	local info = gameInfo.SeatInfos[seatID + 1]

	self:RemoveFromHolds(info, seatID, pai, 2)
	self:RunAction("RefreshHandCardsBySeatID", seatID)
	self:RemoveFromLastFolds(pai)
	self:RunAction("OnRemoveLastFold")
	self:RunAction("RefreshOutCardsBySeatID", self.lastSeatID)

	local seq = info.Sequence
	seq[#seq + 1] = {
		Pai = pai,
		Source = self.lastSeatID,
		PCGType = PCGType.Peng
	}
	self.lastSeatID = -1
	self.lastPai = nil

	self:RunAction("OnPeng", seatID)
end

function M:OnGang(seatID, pai, type)
	local gameInfo = self.gameInfo

	if gameInfo == nil then
		return
	end

	local count = 0
	local info = gameInfo.SeatInfos[seatID + 1]
	local gangs = nil

	if type == MjActionType.AnGang then
		count = 4
		local seq = info.Sequence
		seq[#seq + 1] = {
			Source = -1,
			Pai = pai,
			PCGType = PCGType.AnGang
		}
	elseif type == MjActionType.JiaGang then
		count = 1
		local seq = info.Sequence

		for i = 1, #seq do
			if self:CheckSamePai(seq[i].Pai, pai) then
				seq[i].PCGType = PCGType.JiaGang

				break
			end
		end
	elseif type == MjActionType.MingGang then
		count = 3
		local seq = info.Sequence
		seq[#seq + 1] = {
			Pai = pai,
			Source = self.lastSeatID,
			PCGType = PCGType.MingGang
		}

		self:RemoveFromLastFolds(pai)
		self:RunAction("OnRemoveLastFold")
		self:RunAction("RefreshOutCardsBySeatID", self.lastSeatID)
	end

	local isMe = seatID == self.mySeatID

	self:RemoveFromHolds(info, seatID, pai, count)

	local resetNew = isMe and pai == self.newPai and (type == MjActionType.WangGang or type == MjActionType.AnGang)

	self:RunAction("RefreshHandCardsBySeatID", seatID, false, resetNew)

	self.lastGangId = seatID

	self:RunAction("OnGang", seatID, pai, type)
end

function M:OnHanGang(seatID, pai, type)
	local gameInfo = self.gameInfo

	if gameInfo == nil or type ~= PCGType.JiaGang then
		return
	end

	self.hanGangID = seatID
	self.hanGangPai = pai

	self:OnGang(seatID, pai, MjActionType.JiaGang)
end

function M:OnHanGangDone()
	self.hanGangID = -1
	self.hanGangPai = nil
end

function M:RevertWanGang()
	local gameInfo = self.gameInfo

	if gameInfo == nil or self.hanGangID < 0 then
		return
	end

	local seatID = self.hanGangID
	local pai = self.hanGangPai

	if not pai then
		return
	end

	local info = gameInfo.SeatInfos[seatID + 1]
	local seq = info.Sequence

	for i = 1, #seq do
		if self:CheckSamePai(seq[i].Pai, pai) then
			seq[i].PCGType = PCGType.Peng

			break
		end
	end
end

function M:OnGuo()
	self.lastSeatID = -1
	self.lastPai = nil

	self:RunAction("OnGuo")
end

function M:OnGameCountChange(count)
	self.myGameCount = count
end

function M:OnGameReconnect()
	gDisplayMessageMgr:ShowMessage(MessageConfig.MajiangReconnect, function ()
		gClientToAvatarDelegate:ReconnectGame()
	end, function ()
		self:ExitMaJiang()
	end)
end

function M:OnGameOver(result)
	self.roomState = MahjongRoomState.Idle
	local gameInfo = self.gameInfo

	if gameInfo ~= nil then
		gameInfo.GameState = GameStateEnum.Over
	end

	self.gameState = GameStateEnum.Over
	local roomInfo = self.roomInfo

	if roomInfo ~= nil then
		local flags = roomInfo.HasReady

		for i = 1, #flags do
			flags[i] = false
		end
	end

	self:RunAction("OnGameOver", result)
end

function M:AskCreateFriendModeRoom(notifyToScenePlayers)
	if not gGameSwitch.EnableMahjong or not gGameSwitch.EnableMahjongFriend then
		gDisplayMessageMgr:ShowMessage(MessageConfig.GameSwitchFunctionDisabled)

		return
	end

	if notifyToScenePlayers == nil then
		notifyToScenePlayers = false
	end

	if self.isInGame then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MahjongReconnect, function ()
			gClientToAvatarDelegate:BackToMahjong().Callback = function (errID)
				if errID > 0 then
					print_error("BackToMahjong failed, error =", gCS.Error.GetNameById(errID))

					return
				end

				gClientUtils.CloseMainPhonePanel()
				gMaJiangManager:RefreshMaJiangPanel()
			end

			return true
		end, nil)

		return
	else
		gClientToAvatarDelegate:AskCreateFriendModeRoom(notifyToScenePlayers).Callback = function (errorId, roomID)
			self:AskCreateFriendModeRoomCallback(errorId, roomID)
		end
	end
end

function M:AskCreateFriendModeRoomCallback(errorId, roomID)
	if errorId > 0 then
		gDisplayMessageMgr:DisplayServerMessageId(errorId)

		return
	end

	self.roomType = MahjongRoomType.Friend

	gClientUtils.CloseMainPhonePanel()
	gMaJiangManager:RefreshMaJiangPanel()
end

function M:OnRoomOwnerChange(ownerIndex)
	local roomInfo = self.roomInfo

	if roomInfo == nil then
		return
	end

	roomInfo.RoomOwnerSeatIndex = ownerIndex

	if roomInfo.RoomType == MahjongRoomType.Friend and self.roomState == MahjongRoomState.Idle then
		self:RunAction("RefreshFriendPrepare", self.roomState)
	end
end

function M:OnPlayerExit(pid)
	local roomInfo = self.roomInfo

	if roomInfo == nil then
		return
	end

	local players = roomInfo.PlayerInfos
	local index = -1

	for i = 1, 4 do
		local player = players[i]

		if player ~= nil and ulong.equals(player.Pid, pid) then
			index = i

			break
		end
	end

	if index < 0 then
		return
	end

	roomInfo.HasReady[index] = false
	players[index].exit = true

	if roomInfo.RoomType == MahjongRoomType.Friend and self.roomState == MahjongRoomState.Idle and self.gameState ~= GameStateEnum.Over then
		self.timeOut = nil

		self:RunAction("RemovePlayer", players[index].SeatIndex)
	end
end

local FOUR_PLAYER_TL = "play_Mahjonginviting_npc_4p"

function M:GetAgentIdByNpcId(npcId)
	local maJiangCfg = MahjongPveMahjongNpcTalkConfig.GetConfig(npcId)

	if not maJiangCfg then
		return 0
	end

	return maJiangCfg.AgentId
end

local SMALL_BODY_TYPE = {
	1,
	4,
	7,
	10
}

function M:CheckAgentIsSmallBody(pid)
	local agentCfg = AgentConfig.GetConfig(pid)

	if not agentCfg then
		return false
	end

	local modelCfg = GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)

	if not modelCfg then
		return false
	end

	return table.contains(SMALL_BODY_TYPE, modelCfg.BodyType)
end

function M:CreateNpcInMaJiang(agentId, transform, fashionList)
	if gClientUtils.IsNil(self.machine) or gClientUtils.IsNil(transform) then
		return
	end

	local pos = transform.position
	local eulerAngles = transform.eulerAngles
	local csUnit = gCS.LuaUtils.CreateClientAgentByCfg(agentId, pos, eulerAngles, nil, fashionList)

	if not csUnit then
		print_error("[MaJiangManager] CreateNpcInMaJiang Fail AgentConfig(" .. tostring(agentId) .. ")=", AgentConfig.GetConfig(agentId))
	else
		table.insert(self.npcPidList, csUnit.Pid)

		csUnit.forbidAetherAI = true
	end

	return csUnit
end

function M:RemoveNpcInMaJiang()
	for i = 1, #self.npcPidList do
		if self.npcPidList[i] then
			local csUnit = gCS.SceneDataMgr.GetUnit(self.npcPidList[i])

			if csUnit and csUnit.CanUseRes then
				gCS.BaseUnitUtils.DestroyAgentUnit(csUnit, true, true, true)
			end
		end
	end

	self.npcPidList = {}
end

function M:SetInviteTimelinePos(inviteTimelinePosList)
	if type(inviteTimelinePosList) == "userdata" then
		inviteTimelinePosList = inviteTimelinePosList:ToTable()
	end

	self.inviteTimelinePosList = inviteTimelinePosList
end

function M:PlayInviteNpcTL(callback)
	local npcCultivationList = self.npcCultivationList

	if #npcCultivationList ~= 3 then
		print_error("[MaJiangManager] PlayInviteNpcTL Fail, npcCultivationList=", npcCultivationList)

		return
	end

	self:GetNpcRandomWearFashions(npcCultivationList[1], function (fashionList1)
		self:GetNpcRandomWearFashions(npcCultivationList[2], function (fashionList2)
			self:GetNpcRandomWearFashions(npcCultivationList[3], function (fashionList3)
				self:PlayInviteNpcTLImpl(callback, {
					fashionList1,
					fashionList2,
					fashionList3
				})
			end)
		end)
	end)
end

function M:GetNpcRandomWearFashions(npcCultivationId, callback)
	local cfg = LTConfig.NpcCultivationConfig.GetConfig(npcCultivationId)
	local spiritId = cfg.FightSpiritID

	gClientToGameDelegate:AskGetNpcRandomWearFashions(spiritId).Callback = function (err, list)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			callback({})
		else
			callback(list)
		end
	end
end

function M:PlayInviteNpcTLImpl(callback, fashionListOfList)
	if gClientUtils.IsNil(self.machine) then
		print_error("机关状态不对！self.machine=", self.machine, "可能是 UseMahjongMachine 节点没有触发或者机关已经被销毁了")

		return
	end

	self:RemoveNpcInMaJiang()

	local timelineData = gTimelineManager:Timeline_CreateTimelineData()
	local bindUnitInfos = {}
	local agentList = {}
	local srcModelList = {
		"left",
		"center",
		"right"
	}
	local smallAgent = 0

	for i = 1, #self.pveNpcList do
		local npcId = self.pveNpcList[i]
		local agentId = self:GetAgentIdByNpcId(npcId)

		if self:CheckAgentIsSmallBody(agentId) and i ~= 2 then
			smallAgent = i
		end

		agentList[i] = agentId
	end

	for i, v in ipairs(agentList) do
		local csUnit = self:CreateNpcInMaJiang(v, self.machine.playerTransforms[i], fashionListOfList[i] or 0)

		if csUnit then
			local instanceId = csUnit.Pid
			local bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, instanceId, srcModelList[i], nil)
			bindUnitInfos[i] = bindInfo

			gCS.BaseUnitUtils.SetUnitLogicalHidden(csUnit, true, LX6.Units.LogicalHiddenCause.GamePlay)
		end
	end

	if smallAgent > 0 and smallAgent ~= 2 then
		bindUnitInfos[smallAgent] = bindUnitInfos[2]
		bindUnitInfos[2] = bindUnitInfos[smallAgent]
	end

	timelineData = LX6.TimelineScript.TimelineUtils.Runtime_SetDynamicModelNameAndPersonality(timelineData, agentList)
	timelineData.bindUnitInfos = bindUnitInfos
	timelineData.allmoveTfs = self.inviteTimelinePosList
	self.inviteTimelinePosList = nil

	if callback then
		timelineData.onFinishCb = callback
	end

	function timelineData.onPlayCb()
		if self.machine then
			self.machine.isInDesk = true
		end

		for _, v in ipairs(self.npcPidList) do
			local csUnit = gCS.SceneDataMgr.GetUnit(v)

			if csUnit and csUnit.CanUseRes then
				gCS.BaseUnitUtils.SetUnitLogicalHidden(csUnit, false, LX6.Units.LogicalHiddenCause.GamePlay)
			end
		end
	end

	gTimelineManager:Timeline_LoadAndPlay(FOUR_PLAYER_TL, timelineData)
end

function M:AskStartPveGame(callback)
	self:AskStartMahjongGame(MahjongRoomType.Pve, {}, -1, false, callback)
end

function M:AskInviteNpcFromChat(npcList)
	if npcList == nil or #npcList ~= 3 then
		print_error("[MaJiangManager] AskInviteNpcFromChat bad npcList=", npcList)

		return
	end

	local mahjongNpcList = {}

	for i = 1, #npcList do
		local npc = npcList[i]

		if npc ~= nil then
			local npcCfg = NpcCultivationConfig.GetConfig(npc)

			if npcCfg ~= nil then
				table.insert(mahjongNpcList, npcCfg.MahjongTalkid)
			else
				print_error("[MaJiangManager] NpcCultivationConfig to MajiangTalkConfig failed, npcId =", npc, "@wangpeizhi@corp.netease.com")
			end
		end
	end

	self.npcCultivationList = npcList
	self.pveNpcList = mahjongNpcList

	self:PlayInviteNpcTL(self:CreateAction("_AskInviteNpcFromChat"))
end

function M:_AskInviteNpcFromChat()
	self:AskStartMahjongGame(MahjongRoomType.Npc, self.pveNpcList, -1)
end

function M:AskInviteNpcRide()
	local npcId = gNpcFavorManager:GetRideNpc()

	if npcId == 0 then
		return
	end

	local mahjongNpcList = {}
	local npcCfg = NpcCultivationConfig.GetConfig(npcId)

	table.insert(mahjongNpcList, npcCfg.MahjongTalkid)
	self:AskStartMahjongGame(MahjongRoomType.Npc, mahjongNpcList, -1, true)
end

function M:AskInviteNpcRandom()
	self:AskStartMahjongGame(MahjongRoomType.Npc, {}, -1)
end

function M:GetRewardList()
	local rewardData = {}

	for i = 1, #MahjongConfig.MahjongDivisionReward do
		local data = {
			state = 1,
			score = MahjongConfig.MahjongDivisionLowerLimit[i],
			rank = i + 1,
			rankingName = MahjongConfig.MahjongRankName[i + 1],
			rankingIcon = MahjongConfig.MahjongRankIcon[i + 1],
			dropId = MahjongConfig.MahjongDivisionReward[i]
		}

		table.insert(rewardData, data)
	end

	for i = 1, self.myRankInfo.MaxRank - 1 do
		rewardData[i].state = 2
	end

	if self.myRankInfo.RewardRank then
		for _, v in ipairs(self.myRankInfo.RewardRank) do
			rewardData[v - 1].state = 0
		end
	end

	table.sort(rewardData, function (a, b)
		if a.state ~= b.state then
			return b.state < a.state
		end

		return a.score < b.score
	end)

	local rewardList = {}

	for _, v in ipairs(rewardData) do
		local rewardView = {
			score = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901067).Text, v.score),
			rank = v.rank,
			rankingName = v.rankingName,
			rewardState = v.state,
			dropId = v.dropId,
			icon = v.rankingIcon
		}

		table.insert(rewardList, rewardView)
	end

	return rewardList
end

function M:AskGetMahjongRankReward(rank, callback)
	gClientToGameDelegate:GetMahjongRankReward(rank).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_error("GetMahjongRankReward err:", gCS.Error.GetNameById(err))
		end

		gClientToGameDelegate:AskMahjongInfo().Callback = function (err, data)
			if err ~= MessageConfig.Ok then
				print_error("AskMahjongInfo err:", gCS.Error.GetNameById(err))
			end

			if callback then
				callback(data)
			end

			self.myRankInfo = data
		end
	end
end

function M:RequestMahjongInfo(callback, failCallback)
	gClientToGameDelegate:AskMahjongInfo().Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			print_error("AskMahjongInfo err:", gCS.Error.GetNameById(err))

			if failCallback then
				failCallback()
			end

			return
		end

		self.myRankInfo = data

		if callback then
			callback(data)
		end
	end
end

function M:GetRankingList()
	if self.rankingList and #self.rankingList > 0 then
		return self.rankingList
	end

	local allData = {}
	self.rankingList = {}

	for i = 0, MahjongPveMahjongNpcTalkConfig.count - 1 do
		local cfg = MahjongPveMahjongNpcTalkConfig.LoadAt(i)
		local v = {
			name = cfg.Name,
			score = cfg.Score,
			icon = cfg.SIcon
		}

		table.insert(allData, v)
	end

	table.sort(allData, function (a, b)
		return b.score < a.score
	end)

	local len = math.min(#allData, MahjongConfig.MahjongRankMaxLen)

	for i = 1, len do
		table.insert(self.rankingList, allData[i])
	end

	return self.rankingList
end

function M:GetRankingNameAndIcon(score)
	local v = score or 0
	local limit = MahjongConfig.MahjongDivisionLowerLimit
	local name = MahjongConfig.MahjongRankName
	local icon = MahjongConfig.MahjongRankIcon

	for i = 1, #limit do
		if v < limit[i] then
			return name[i], icon[i]
		end
	end

	return name[#name], icon[#icon]
end

function M:CheckSamePai(a, b)
	if a == nil or b == nil then
		return false
	end

	return a.Index == b.Index and a.Red == b.Red
end

function M:StartMaJiangMachine(machine, instance)
	if type(instance) == "table" then
		self.entityId = instance.entityInstanceId
	else
		self.entityId = instance
	end

	self.machine = machine
end

function M:BeginMajiangGame()
	self.machineInfo = {
		cardBound = self.machine.cardAABBBox.size,
		rotationRange = self.machine.rotationOffsetRange,
		xTransformOffsetRange = self.machine.xTransformOffsetRange,
		zTransformOffsetRange = self.machine.zTransformOffsetRange,
		outCardCount = MahjongConfig.outCardCount,
		outCardRowInterval = MahjongConfig.outCardRowInterval,
		outCardColInterval = MahjongConfig.outCardColInterval,
		cardInterval = MahjongConfig.normalCardInterval
	}

	self.machine:ClearMachine()

	self.emptyList = self.machine:GetCardInsts(144):ToTable()
	self.huEntList = {}
	self.stackEntList = {}
	self.handEntList = {}
	self.pengEntList = {}

	if self.firstEffectId and self.firstEffectId ~= 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.firstEffectId)
	end

	self.firstEffectId = 0

	for i = 0, 3 do
		self.huEntList[i] = {}
		self.stackEntList[i] = {}
		self.handEntList[i] = {}
		self.pengEntList[i] = {}
	end

	self.lastEnt = nil
	self.machine.isInDesk = true
end

function M:ExitMajiangMachine()
	if self.machine then
		self.machine.isInDesk = false
	end

	self:OnReceiveSignal("MajiangFinish")

	if self.firstEffectId and self.firstEffectId ~= 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.firstEffectId)
	end
end

function M:StopMaJiangMachine()
	if self.machine then
		self.machine.isInDesk = false
		self.machine = nil
	end

	if self.entityId then
		self.entityId = nil
	end

	if self.firstEffectId and self.firstEffectId ~= 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.firstEffectId)
	end
end

local MahjongState = {
	SELECTED = 1,
	FIRST = 3,
	GRAY = 2,
	None = 0
}

function M:GetEmptyCard(transform)
	if self.emptyList and #self.emptyList > 0 then
		local ent = self.emptyList[#self.emptyList]

		ent.transform:SetParent(transform)

		ent.transform.localPosition = Vector3.zero
		ent.transform.localRotation = Quaternion.identity
		ent.isCached = false

		table.remove(self.emptyList, #self.emptyList)

		return ent
	end

	return self.machine:GetCardInst(transform)
end

function M:RemoveCard(cardEnt)
	if not cardEnt then
		return
	end

	cardEnt.isCached = true

	table.insert(self.emptyList, cardEnt)
end

function M:ClearMachine()
	if not self.machine then
		return
	end

	for i = 0, 3 do
		self:RemoveEntList(self.huEntList[i])
		self:RemoveEntList(self.stackEntList[i])
		self:RemoveEntList(self.handEntList[i])
		self:RemoveEntList(self.pengEntList[i])
	end
end

function M:RemoveEntList(list)
	if not list then
		return
	end

	for i = 1, #list do
		if list[i] then
			self:RemoveCard(list[i])

			list[i] = nil
		end
	end
end

function M:RefreshStackArea(seat, paiInfos, disableSound)
	if not self.machine or seat < 0 or seat >= 4 then
		return
	end

	local seatTransform = self.machine.mahjongCardTransforms[seat]
	local lastSeatIndex = self:GetSeatIndexBySeatID(self.lastSeatID)

	for i = 1, #paiInfos do
		local cardEnt = nil
		local cardInfo = paiInfos[i]

		if self.stackEntList[seat][i] then
			cardEnt = self.stackEntList[seat][i]
		else
			cardEnt = self:GetEmptyCard(seatTransform)
			self.stackEntList[seat][i] = cardEnt
			cardEnt.transform.localPosition = self:_GetMahjongTransform(i)

			self:_GetMahjongRandomTransform(cardEnt.transform)
		end

		local cardState = cardInfo.isSelected and MahjongState.SELECTED or cardEnt.cardInfo.State

		if cardEnt.cardInfo.State == MahjongState.SELECTED and cardInfo.isSelected == false then
			cardState = MahjongState.None
		end

		if lastSeatIndex == seat and self.lastPai and self:CheckSamePai(self.lastPai, cardInfo) then
			cardState = MahjongState.FIRST

			self:PlayLastCardFx(cardEnt)
		end

		cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(cardInfo.Pai + 1, cardInfo.MType, cardState)
	end

	for i = #paiInfos + 1, #self.stackEntList[seat] do
		if self.stackEntList[seat][i] then
			self:RemoveCard(self.stackEntList[seat][i])

			self.stackEntList[seat][i] = nil
		end
	end

	if disableSound ~= true then
		self:PlaySoundOut()
	end
end

function M:RefreshLastCard(seat)
	if not self.machine or seat < 0 or seat >= 4 then
		return
	end

	local cardEnt = self.stackEntList[seat][#self.stackEntList[seat]]
	local cardInfo = nil

	if self.lastEnt and self.lastEnt.isCached == false then
		cardInfo = self.lastEnt.cardInfo
		cardInfo.State = MahjongState.None
		self.lastEnt.cardInfo = cardInfo
	end

	if cardEnt then
		self.lastEnt = cardEnt
		cardInfo = cardEnt.cardInfo
		cardInfo.State = MahjongState.FIRST
		cardEnt.cardInfo = cardInfo

		self:PlayLastCardFx(cardEnt)
	end
end

function M:RefreshHuArea(seat, paiInfos)
	if not self.machine or seat < 0 or seat >= 4 then
		return
	end

	local seatTransform = self.machine.mahjongCardHuTransforms[seat]
	local lastEnt = nil

	for i = 1, #paiInfos do
		local cardEnt = nil
		local cardInfo = paiInfos[i]

		if self.huEntList[seat][i] then
			cardEnt = self.huEntList[seat][i]
		else
			cardEnt = self:GetEmptyCard(seatTransform)
			self.huEntList[seat][i] = cardEnt
			local localPosition = Vector3.zero
			localPosition.x = -1 * (i - 1) * (self.machineInfo.cardBound.x + self.machineInfo.cardInterval)
			cardEnt.transform.localPosition = localPosition
		end

		cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(cardInfo.Pai + 1, cardInfo.MType, 0)
		lastEnt = cardEnt
	end

	self:PlayHuCardFx(lastEnt)
	self:PlaySoundOut()
end

local PengGangCardType = {
	Horizon = 3,
	HorizonAdd = 4,
	Hide = 2,
	Normal = 1
}

function M:RefreshPengGangArea(seat, paiInfos)
	if not self.machine or seat < 0 or seat >= 4 then
		return
	end

	local seatTransform = self.machine.mahjongCardPengGangTransforms[seat]
	local preX = 0
	local index = 1

	for i = 1, #paiInfos do
		local pgInfo = paiInfos[i]
		local sign = -1
		local type = pgInfo.PCGType
		local cardInfo = pgInfo.Pai

		if type == PCGType.Peng then
			local src = pgInfo.Source
			local delta = (4 + (src - seat) * sign) % 4

			for j = 1, 3 do
				if j == delta then
					preX, index = self:GetOnePengGangCard(seat, cardInfo, preX, seatTransform, index, PengGangCardType.Horizon)
				else
					preX, index = self:GetOnePengGangCard(seat, cardInfo, preX, seatTransform, index, PengGangCardType.Normal)
				end
			end
		elseif type == PCGType.AnGang then
			for j = 1, 4 do
				if j == 1 or j == 4 then
					preX, index = self:GetOnePengGangCard(seat, cardInfo, preX, seatTransform, index, PengGangCardType.Hide)
				else
					preX, index = self:GetOnePengGangCard(seat, cardInfo, preX, seatTransform, index, PengGangCardType.Normal)
				end
			end
		elseif type == PCGType.MingGang then
			local src = pgInfo.Source
			local delta = (4 + (src - seat) * sign) % 4

			if delta == 3 then
				delta = 4
			end

			for j = 1, 4 do
				if j == delta then
					preX, index = self:GetOnePengGangCard(seat, cardInfo, preX, seatTransform, index, PengGangCardType.Horizon)
				else
					preX, index = self:GetOnePengGangCard(seat, cardInfo, preX, seatTransform, index, PengGangCardType.Normal)
				end
			end
		elseif type == PCGType.JiaGang then
			local src = pgInfo.Source
			local delta = (4 + (src - seat) * sign) % 4

			for j = 1, 3 do
				if j == delta then
					_, index = self:GetOnePengGangCard(seat, cardInfo, preX, seatTransform, index, PengGangCardType.Horizon)
					preX, index = self:GetOnePengGangCard(seat, cardInfo, preX, seatTransform, index, PengGangCardType.HorizonAdd)
				else
					preX, index = self:GetOnePengGangCard(seat, cardInfo, preX, seatTransform, index, PengGangCardType.Normal)
				end
			end
		end
	end

	self:PlaySoundPG()
end

function M:GetOnePengGangCard(seat, cardInfo, preX, parent, index, cardType)
	local cardEnt = nil

	if self.pengEntList[seat][index] then
		cardEnt = self.pengEntList[seat][index]
	else
		cardEnt = self:GetEmptyCard(parent)
		self.pengEntList[seat][index] = cardEnt
	end

	local localPosition = Vector3.New(preX, 0, 0)
	cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(cardInfo.Pai + 1, cardInfo.MType, 0)

	if cardType == PengGangCardType.Normal then
		preX = preX + self.machineInfo.cardBound.x
		cardEnt.transform.localRotation = Quaternion.identity
	elseif cardType == PengGangCardType.Hide then
		localPosition.x = preX - 0.002
		preX = preX + self.machineInfo.cardBound.x
		cardEnt.transform.localRotation = Quaternion.Euler(0, -180, 0)
	elseif cardType == PengGangCardType.Horizon then
		localPosition.x = preX + self.machineInfo.cardBound.y / 2 + 0.005
		localPosition.y = self.machineInfo.cardBound.x / 2
		preX = preX + self.machineInfo.cardBound.y + 0.005
		cardEnt.transform.localRotation = Quaternion.Euler(0, 0, 90)
	else
		localPosition.x = preX + self.machineInfo.cardBound.y / 2 + 0.005
		localPosition.y = self.machineInfo.cardBound.x * 3 / 2
		preX = preX + self.machineInfo.cardBound.y + 0.005
		cardEnt.transform.localRotation = Quaternion.Euler(0, 0, 90)
	end

	preX = preX + self.machineInfo.cardInterval
	cardEnt.transform.localPosition = localPosition
	index = index + 1

	return preX, index
end

function M:RefreshHandArea(seat, paiInfos, isVisible)
	if not self.machine or seat < 0 or seat >= 4 then
		return
	end

	local seatTransform = self.machine.mahjongCardOutTransforms[seat]

	for i = 1, #paiInfos do
		local cardEnt = nil
		local cardInfo = paiInfos[i]

		if self.handEntList[seat][i] then
			cardEnt = self.handEntList[seat][i]
		else
			cardEnt = self:GetEmptyCard(seatTransform)
			self.handEntList[seat][i] = cardEnt
			local localPosition = Vector3.zero
			localPosition.x = -1 * (i - 1) * (self.machineInfo.cardBound.x + self.machineInfo.cardInterval)
			cardEnt.transform.localPosition = localPosition
		end

		cardEnt.cardInfo = MahjongUtils.CreateMahjongCardInfo(cardInfo.Pai + 1, cardInfo.MType, 0)
	end

	for i = #paiInfos + 1, #self.handEntList[seat] do
		if self.handEntList[seat][i] then
			self:RemoveCard(self.handEntList[seat][i])

			self.handEntList[seat][i] = nil
		end
	end

	local angles = self.machine.mahjongCardOutTransforms[seat].localRotation.eulerAngles
	local angleX = isVisible and -90 or 0
	self.machine.mahjongCardOutTransforms[seat].localRotation = Quaternion.Euler(angleX, angles.y, 0)
end

function M:_GetMahjongTransform(index)
	local localPosition = Vector3.zero
	local id = index - 1
	localPosition.x = -1 * (id % self.machineInfo.outCardCount) * (self.machineInfo.cardBound.x + self.machineInfo.outCardRowInterval)
	localPosition.z = math.floor(id / self.machineInfo.outCardCount) * (self.machineInfo.cardBound.y + self.machineInfo.outCardColInterval)

	return localPosition
end

function M:_GetMahjongRandomTransform(transform)
	local deltaX = math.random(-1, 1) / 1000
	local deltaZ = math.random(-1, 1) / 1000
	local deltaR = math.random(self.machineInfo.rotationRange.x, self.machineInfo.rotationRange.y)
	local localPosition = transform.localPosition
	localPosition.x = localPosition.x + deltaX
	localPosition.z = localPosition.z + deltaZ
	transform.localPosition = localPosition
	local localRotation = transform.localRotation
	localRotation = Quaternion.Euler(-90, deltaR, localRotation.z)
	transform.localRotation = localRotation
end

function M:GetAllScoreAndMyRecord(actionData)
	local mySeatID = self.mySeatID
	self.finalRecords = {}
	self.finalScores = {
		0,
		0,
		0,
		0
	}

	for i = 1, #actionData do
		local action = actionData[i]
		local score = action.Score
		local targets = action.Targets
		local winner = action.Owner
		self.finalScores[winner + 1] = self.finalScores[winner + 1] + score * #targets

		if winner == mySeatID then
			self.finalRecords[#self.finalRecords + 1] = action
		end

		for j = 1, #targets do
			local loser = targets[j]

			if winner ~= loser then
				self.finalScores[loser + 1] = self.finalScores[loser + 1] - score

				if loser == mySeatID then
					self.finalRecords[#self.finalRecords + 1] = action
				end
			end
		end
	end
end

function M:GetAllRanking()
	local tmp = {}
	self.finalRankings = {}

	for i, v in ipairs(self.finalScores) do
		tmp[i] = {
			value = v,
			rank = i
		}
	end

	table.sort(tmp, function (a, b)
		return b.value < a.value
	end)

	for i, v in ipairs(tmp) do
		v.newRank = i
	end

	table.sort(tmp, function (a, b)
		return a.rank < b.rank
	end)

	for i, v in ipairs(tmp) do
		self.finalRankings[i] = v.newRank
	end
end

function M:GetSeatName(owner)
	local delta = (4 + owner - self.mySeatID) % 4

	return delta > 0 and delta < 4 and MahjongConfig.MahjongSeatOrder[delta] or ""
end

function M:FormatScoreString(score)
	if score >= 0 then
		return gString.Format("+%d", score), true
	else
		return gString.Format("%d", score), false
	end
end

function M:FormatRankScoreString(score)
	local coffStr = "(*" .. gString.Format("%.2f", MahjongConfig.MahjongCoefficient) .. ")"

	if score >= 0 then
		return gString.Format("+%d", score) .. coffStr, true
	else
		return gString.Format("%d", score) .. coffStr, false
	end
end

function M:GetPlayerHeadIcon(player)
	if player.NpcCultivationId ~= nil and player.NpcCultivationId > 0 then
		local headIcon, _ = gNpcFavorManager:GetAgentNpcHeadInfo(player.NpcCultivationId, 0)

		return headIcon
	elseif player.NpcMahjongId ~= nil and player.NpcMahjongId > 0 then
		local imageId = MahjongPveMahjongNpcTalkConfig.GetConfig(player.NpcMahjongId).SIcon

		return imageId
	else
		local cfg = ImageAvatar.GetConfig(player.PzHeadInfo.SystemHeadId)

		return cfg and cfg.SguiImageId or 0
	end

	return 0
end

function M:GetPlayerLiHui(player)
	if player.NpcMahjongId ~= nil and player.NpcMahjongId > 0 then
		local cfg = MahjongPveMahjongNpcTalkConfig.GetConfig(player.NpcMahjongId)

		return cfg and cfg.SImageId or 0
	else
		local cfg = ImageAvatar.GetConfig(player.PzHeadInfo.SystemHeadId)

		return cfg and cfg.SImageId or 0
	end

	return 0
end

function M:GetMahjongHuanpai(index)
	local names = MahjongConfig.MahjongHuanpai

	return names[index] or ""
end

function M:BuildPlayerView(player, view)
	view.name = player.Name
	view.score = player.Score
	view.NpcCultivationId = player.NpcCultivationId
	view.PzHeadInfo = player.PzHeadInfo
	view.hasPlayer = true
	view.NpcMahjongId = player.NpcMahjongId
	view.Pid = player.Pid
end

function M:GetSeatIndex(index)
	return (index + self.mySeatID - 1) % 4
end

function M:GetSeatIndexBySeatID(seatID)
	return (4 + seatID - self.mySeatID) % 4
end

function M:MapIndex(seatIndex)
	local count = #MahjongConfig.SeatNames
	local index = (count + seatIndex - self.mySeatID) % count + 1

	return index
end

function M:RegisterStore(store)
	self.store = store
end

function M:RegisterMiddleStore(store)
	self.middleStore = store
end

function M:UnRegisterMiddleStore()
	self.middleStore = nil
end

function M:UnRegisterStore()
	self.store = nil
end

function M:RefreshSeat(nowSeatId)
	if self.middleStore then
		local seatIndex = self:GetSeatIndexBySeatID(nowSeatId)

		self.middleStore:RefreshSeat(seatIndex)
	end
end

function M:RefreshSeatName(seatNames)
	if self.middleStore then
		self.middleStore:RefreshSeatName(seatNames)
	end
end

function M:RefreshCountDown(countDown)
	if self.middleStore then
		self.middleStore:RefreshCountDown(countDown)
	end
end

function M:RefreshIsShow(isShow)
	if self.middleStore then
		self.middleStore:RefreshIsShow(isShow)
	end
end

function M:SwitchToDetailPage()
	gPanelManager:Close(gPanelId.S_MA_JIANG_FINAL_RANK)
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_FINAL_DETAIL)
end

function M:ClearGameState()
	self:RemoveNpcInMaJiang()

	self.pveNpcList = {}

	gPanelManager:Close(gPanelId.S_MA_JIANG)
	gPanelManager:Close(gPanelId.S_MA_JIANG_FINAL_DETAIL)
	gPanelManager:Close(gPanelId.S_MA_JIANG_TEACH_PANEL)
	self:ExitMajiangMachine()
end

function M:ExitMaJiang()
	self:ClearGameState()
	gClientToAvatarDelegate:Exit()
end

function M:OneMore()
	local npcList = {}

	if gMaJiangManager.roomInfo.RoomType == MahjongRoomType.Npc and not table.isNilOrEmpty(self.pveNpcList) then
		npcList = self.pveNpcList
	end

	self:AskStartMahjongGame(gMaJiangManager.roomInfo.RoomType, npcList, -1)
	gPanelManager:Close(gPanelId.S_MA_JIANG_FINAL_DETAIL)
end

function M:OpenFinal(data)
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_FINAL_RANK, data)
end

function M:OpenRankPanel()
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_RANK_WINDOW_PANEL)
end

function M:OpenRankListPanel()
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_RANKING_PANEL)
end

function M:OpenRewardPanel()
	gPanelManager:CheckShow(gPanelId.S_MA_JIANG_REWARD_PANEL)
end

function M:RunAction(actionName, ...)
	if not actionName or not gMaJiangManager.store or not gMaJiangManager.store.STATE_EnableOnce then
		return
	end

	local action = gMaJiangManager.store[actionName]

	if action ~= nil then
		action(gMaJiangManager.store, ...)
	else
		print_error("MaJiangManager store RunAction Error with ", actionName)
	end
end

function M:RefreshMaJiangPanel(actionName)
	if gMaJiangManager.store and actionName then
		local action = gMaJiangManager.store[actionName]

		if action ~= nil then
			action(gMaJiangManager.store)
		end
	else
		gPanelManager:CheckShowAsync(gPanelId.S_MA_JIANG)
	end
end

function M:OnNewGame()
	if gMaJiangManager.store then
		gMaJiangManager.store:OnNewGame()
	else
		self.isNewGame = true
	end
end

function M:OnPlayerReady()
	if gMaJiangManager.roomType == MahjongRoomType.Friend then
		self:RefreshFriendPrepare(gMaJiangManager.roomState)
	end
end

function M:_ExitMaJiangInGame()
	gClientToAvatarDelegate:Exit()
	self:OnReceiveSignal("MajiangFinishInGame")
end

function M:ExitMaJiangInGame()
	local msgID = nil

	if self.roomState == MahjongRoomState.Idle then
		if self.roomType == MahjongRoomType.Friend then
			msgID = MessageConfig.MahjongLeaveRoom
		end
	else
		msgID = MessageConfig.MahjongLeave
	end

	if msgID ~= nil then
		gDisplayMessageMgr:ShowMessage(msgID, function ()
			self:_ExitMaJiangInGame()
		end, nil)
	else
		self:_ExitMaJiangInGame()
	end
end

function M:PlayDialogVoice(seatIndex, voiceId)
	local agentId = self.npcPidList[seatIndex]

	if agentId and voiceId ~= 0 then
		gDialogManager:PlayDialogVoice(voiceId, agentId)
	end
end

function M:PlaySoundPG()
	gUIUtils:PlaySound(MahjongConfig.pengGangSound)
end

function M:PlaySoundOut()
	gUIUtils:PlaySound(MahjongConfig.outCardSound)
end

function M:AskStartMahjongGame(roomType, npcList, seatIndex, addFavor, callback)
	npcList = npcList or {}
	addFavor = addFavor or false

	self:OnReceiveSignal("StartMahjongGame")

	gClientToGameDelegate:AskStartMahjongGame(roomType, npcList, seatIndex, addFavor).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_error("StartMahjongGame err:", gCS.Error.GetNameById(err))
		end

		if callback then
			callback(err)
		end
	end
end

function M:PlayLastCardFx(cardEnt)
	local offset = MahjongConfig.MahjongLatestCardEffectOffset

	if self.firstEffectId and self.firstEffectId ~= 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.firstEffectId)
	end

	local localOffset = Vector3.New(offset[1], offset[2], offset[3])
	local localEuler = Vector3.New(90, 0, 0)
	self.firstEffectId = gCS.EffectMgr:PlayEffectsOnTransform(MahjongConfig.MahjongLatestCardEffect, cardEnt.transform, Vector3.zero, 0, 0, localOffset, localEuler)
end

function M:PlayHuCardFx(cardEnt)
	if not cardEnt then
		return
	end

	local effectId = MahjongConfig.MahjongHuCardEffect
	local offset = MahjongConfig.MahjongHuCardEffectOffset

	if self.firstEffectId and self.firstEffectId ~= 0 then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.firstEffectId)
	end

	local localOffset = Vector3.New(offset[1], offset[2], offset[3])
	local localEuler = Vector3.New(90, 0, 0)

	gCS.EffectMgr:PlayEffectsOnTransform(effectId, cardEnt.transform, Vector3.zero, 0, 0, localOffset, localEuler)
end

function M:TestCaseFullMachine()
	if not self.machine then
		return
	end

	self.mySeatID = 0
	local cardList = {}
	local handList = {}
	local huList = {}

	for i = 1, 20 do
		table.insert(cardList, {
			Pai = 4,
			isSelected = false,
			MType = UX.Game.MjType.Tong
		})
	end

	for i = 1, 9 do
		table.insert(handList, {
			Pai = 4,
			isSelected = false,
			MType = UX.Game.MjType.Tong
		})
	end

	for i = 1, 3 do
		table.insert(huList, {
			Pai = 4,
			isSelected = false,
			MType = UX.Game.MjType.Tong
		})
	end

	for i = 0, 3 do
		self:RefreshPengGangArea(i, {
			{
				Source = 1,
				PCGType = UX.Game.MjPCGType.JiaGang,
				Pai = {
					Pai = 4,
					MType = UX.Game.MjType.Tong
				}
			}
		})
		self:RefreshStackArea(i, cardList)
		self:RefreshHandArea(i, handList)
		self:RefreshHuArea(i, huList)
	end
end

function M:OnReceiveSignal(msg)
	local signal = {
		signalKey = msg,
		entityInstanceId = self.entityId
	}

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, signal)
end

gMaJiangManager = gMaJiangManager or C_MaJiangManager.new()
