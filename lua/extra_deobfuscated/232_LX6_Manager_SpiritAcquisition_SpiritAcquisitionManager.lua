local AgentDataSetsConfig = LTConfig.AgentDataSetsActivityConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local MessageConfig = LTConfig.MessageConfig
local LayerConstants = LX6.Constants.LayerConstants
local bindData = gPlayerManager.infoMinorNpcCultivation.bindData
local PhotoUtils = LX6.Utils.PhotoUtils
local chatType = {
	PosFirst = 1,
	DailyFirst = 2,
	Normal = 0
}
local photoDetectMaxDistanceSqr = 10000
C_SpiritAcquisitionManager = DefClass("C_SpiritAcquisitionManager", C_SpiritAcquisitionManager)
local M = C_SpiritAcquisitionManager

function M:ctor()
	self:DefineAllData()
end

function M:DefineAllData()
	self.npcPresentInfos = {}
	self.possiblePhotoUnit = {}
	self.dialogSelectHandler = nil
	self.currentDialogBranch = nil
	self.currentCfgIdUseInBranchDialog = nil
	self.favorInfos = {}
	self.popupInfoList = {}
end

function M:OnInit()
	function self.dialogSelectHandler(eId, dId)
		self:HandleDialogSelect(dId)
	end

	self:InitInteractionData()

	self.msgEvents = {
		[gEventConstants.PANEL_ON_SHOW] = function (eventId, data)
			self:OnPanelShowOrClose(data, true)
		end,
		[gEventConstants.PANEL_ON_CLOSE] = function (eventId, data)
			self:OnPanelShowOrClose(data, false)
		end
	}

	for event, func in pairs(self.msgEvents) do
		gMessageManager:AddMessageListener(event, func)
	end
end

function M:OnPanelShowOrClose(panelId, show)
	if panelId == gPanelId.S_PHOTO_PANEL then
		if show then
			gLuaClient:RegisterDynamicUpdate("gSpiritAcquisitionManager", self)
		else
			gLuaClient:UnregisterDynamicUpdate("gSpiritAcquisitionManager")
		end
	end
end

function M:OnUpdate()
	self:GetPossibleNpcUnit()
	self:TrySendSpiritLocation()
end

function M:InitInteractionData()
	local meta = {
		__index = function (table, key)
			local mapId = bindData.npcCultivationInfosDic[key]

			if mapId == nil then
				local unlockedMapId = bindData.unlockedNpcCultivationInfosDic[key]

				if bindData.unlockedNpcCultivationInfos[unlockedMapId] then
					return bindData.unlockedNpcCultivationInfos[unlockedMapId]
				end
			end

			if bindData.npcCultivationInfos[mapId] then
				return bindData.npcCultivationInfos[mapId]
			end

			print_error("该角色未当前不可交互且未获得!template = ", key)
		end,
		__newIndex = function (table, key, value)
			print_error("该表仅用于映射至InfoNpcCultivation，禁止主动添加数据!")
		end
	}

	setmetatable(self.favorInfos, meta)
end

function M:ChatFavorable(cfgId, npcUnit)
	local pid = npcUnit.Pid
	local npcInfo = self:GetNpcCultivationInfoByPid(pid)

	if table.isNilOrEmpty(npcInfo) then
		gDisplayMessageMgr:ShowMessageContentDebug("错误的npc，没有获取当前的npcInfo pid = " .. pid)

		return
	end

	if self:OpenFirstInteractionDialog(cfgId, npcUnit, npcInfo) then
		return
	end

	self:OpenNormalInteractionDialog(cfgId, npcUnit)
end

function M:TakePhotoFavorable(npcUnit)
	gTakePhotoUtils.TryTakePhoto(nil, {
		isSelfIeMode = true
	})
	gMessageManager:SendMessage(gEventConstants.NPC_PHONE_INTERACT_FINISH, npcUnit.Pid)
end

function M:GivePresentFavorable(cfgId, data)
	local disabled = data.disabled

	if disabled then
		gDisplayMessageMgr:ShowMessageContent(MessageConfig.GetConfig(65401038).Content)

		return
	end

	gPanelManager:CheckShow(gPanelId.S_DELIVER_GIFTS_PANEL, {
		cfgId = cfgId,
		npcPid = gDialogScriptFunc.currentNpc.Pid
	})
end

function M:CheckRangeNpc()
	local myPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local x = math.floor(myPos.x / 100)
	local xTrend = myPos.x - x * 100 > 50
	local z = math.floor(myPos.z / 100)
	local zTrend = myPos.z - z * 100 > 50
	local xLower = xTrend and x or x - 1
	local xUpper = xTrend and x + 1 or x
	local zLower = zTrend and z or z - 1
	local zUpper = zTrend and z + 1 or z
	local allPossiblePid = {}

	for i = xLower, xUpper do
		for j = zLower, zUpper do
			if j >= 0 and i >= 0 then
				local spotId = i * 100 + j
				local pids = gCS.SpoonAgentMgr:TryGetShowNpcIdsBySpotId(spotId)

				if pids ~= nil then
					for k = 0, pids.Count - 1 do
						table.insert(allPossiblePid, pids[k])
					end
				end
			end
		end
	end

	self.possiblePhotoUnit = {}
	local nowRaid = gRaidDataManager.RaidId

	for _, pid in ipairs(allPossiblePid) do
		local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(pid)

		if not npcSpawn then
			-- Nothing
		else
			local cfgId = npcSpawn.spiritAcquisitionCfgId

			if cfgId <= 0 then
				-- Nothing
			else
				local raidId = AgentDataSetsConfig.GetConfig(cfgId).Raid

				if nowRaid ~= raidId then
					-- Nothing
				else
					local unit = gCS.SceneDataMgr.GetUnit(pid)
					local templateId = self:GetTemplateIdByPid(pid)
					local isCanInteract = gNpcInteracsUtils:CheckIfCanInteract(templateId) and self:CheckIfInteractionTrueSpirit()

					if unit and isCanInteract then
						table.insert(self.possiblePhotoUnit, unit)
					end
				end
			end
		end
	end
end

function M:GetPossibleNpcUnit()
	if not gPanelManager:IsPanelShowing(gPanelId.S_PHOTO_PANEL) then
		return
	end

	table.clear(self.possiblePhotoUnit)

	local unit = gCS.UnitsManager:GetNearestLifeScheduleNpcFromPlayer()

	if unit then
		table.insert(self.possiblePhotoUnit, unit)
	end
end

function M:TrySendSpiritLocation()
	if not gPanelManager:IsPanelShowing(gPanelId.S_PHOTO_PANEL) then
		return
	end

	if not next(self.possiblePhotoUnit) then
		return
	end

	local mainCamera = gCS.CameraDataMgr.MainCamera
	local mainCamPos = mainCamera.transform.position
	local meetDis = {}

	for _, unit in ipairs(self.possiblePhotoUnit) do
		if unit and unit and not unit.IsDestroyed then
			if not gClientUtils.IsNil(unit.HitCollider) then
				local pid = unit.Pid
				local capsuleCollider = unit.HitCollider
				local position = unit.LocalPosition
				local right = Vector3.Cross(position - mainCamPos, Vector3.up):SetNormalize()
				local posList = {
					position - right * capsuleCollider.radius,
					position + right * capsuleCollider.radius,
					position + Vector3.up * capsuleCollider.height - right * capsuleCollider.radius,
					position + Vector3.up * capsuleCollider.height + right * capsuleCollider.radius,
					unit.UpBodyPosition
				}

				for _, pos in ipairs(posList) do
					local distance = Vector3.SqrDistance(unit.LocalPosition, gCS.MyPlayerManager.PlayerUnit.LocalPosition)

					if distance < photoDetectMaxDistanceSqr and not PhotoUtils.RaycastWithGlassCheck(mainCamera.transform.position, pos, LayerConstants.colliderMoveLayer) then
						meetDis[pid] = unit

						break
					end
				end
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.PHOTO_CUSTOM_TARGET, {
		Type = gTakePhotoUtils.PhotoCustomTargetType.Npc,
		MeetDis = meetDis
	})
end

function M:OpenFirstInteractionDialog(cfgId, npcUnit, npcInfo)
	if not AgentDataSetsConfig.GetConfig(cfgId).FirstDialog then
		return false
	end

	local dialogId = AgentDataSetsConfig.GetConfig(cfgId).FirstDialog

	if dialogId == 0 then
		return false
	end

	local firstChatPosList = npcInfo.FirstChatPosList

	if table.find(firstChatPosList, dialogId) then
		return false
	end

	self:OpenInteractionDialog(dialogId, npcUnit)

	return true
end

function M:OpenNormalInteractionDialog(cfgId, npcUnit)
	local mainTag = AgentDataSetsConfig.GetConfig(cfgId).BacicDialog

	gClientToGameDelegate:GetFavorNpcRandomDialog(cfgId, mainTag, 0).Callback = function (err, dId)
		if err ~= LTConfig.MessageConfig.Ok then
			return
		end

		self:OpenInteractionDialog(dId, npcUnit)
	end
end

function M:OpenInteractionDialog(dialogId, npcUnit)
	gMessageManager:SendMessage(gEventConstants.SPIRIT_ACQUISITION_NPC_DIALOG_START, {
		pid = npcUnit.Pid,
		dialogId = dialogId
	})

	local dialogParam = gDialogManager:CreateDialogParam()
	dialogParam.overrideDialogType = 23

	gDialogManager:ShowDialogInteractionActionFinish(dialogId, npcUnit, nil, dialogParam)
end

function M:GetNpcCultivationInfoByPid(pid)
	local templateId = self:GetTemplateIdByPid(pid)

	if not templateId then
		print_error("不存在的templateId配置!, templateId = ", templateId)

		return nil
	end

	local npcInfo = self.favorInfos[templateId]

	if not npcInfo then
		print_error("无法交互的templateId!, templateId = ", templateId)

		return nil
	end

	return npcInfo
end

function M:GetNpcCultivationInfoByTemplateId(tempId)
	local npcInfo = self.favorInfos[tempId]

	if not npcInfo then
		print_error("无法交互的templateId!, templateId = ", tempId)

		return nil
	end

	return npcInfo
end

function M:GetLevelFromFavor(favor)
	local levelList = NpcCultivationConfig.FavorLevel
	local level = 0

	for i = 1, #levelList do
		if levelList[i] <= favor then
			level = i
		end
	end

	if not level then
		return #levelList
	end

	return level
end

function M:GetSpiritAcquisitionIdByPid(pid)
	local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(pid)

	if not npcSpawn then
		return
	end

	local cfgId = npcSpawn.spiritAcquisitionCfgId

	if cfgId <= 0 then
		print_error("不存在的AgentDataSetsConfig Id配置, pid = ", pid)

		return
	end

	return cfgId
end

function M:GetTemplateIdByPid(pid)
	local cfgId = self:GetSpiritAcquisitionIdByPid(pid)

	if not AgentDataSetsConfig.GetConfig(cfgId) then
		return
	end

	local templateId = AgentDataSetsConfig.GetConfig(cfgId).NpccultivationId

	if not templateId or templateId <= 0 then
		print_error("不存在的NpccultivationId配置, pid = ", pid, "cfgId = ", cfgId)

		return
	end

	return templateId
end

function M:GetPresentGiveState()
	local nowCount = bindData.availableGiftSendCount
	local maxCount = NpcCultivationConfig.GiftMaxLimit
	local giftLimit = nowCount <= 0

	return giftLimit, nowCount, maxCount
end

function M:GetCanPresentGiveTimes()
	return bindData.availableGiftSendCount
end

function M:GetSpiritFavorLevel(templateId)
	local npcInfo = self.favorInfos[templateId]

	if not npcInfo then
		print_error("无法交互的templateId!, templateId = ", templateId)

		return 0
	end

	local favor = npcInfo.Favor
	local favorLevel = self:GetLevelFromFavor(favor)

	return favorLevel
end

function M:GetSpiritFavor(pid)
	local npcInfo = self:GetNpcCultivationInfoByPid(pid)

	if not npcInfo then
		return 0
	end

	return npcInfo.Favor
end

function M:GetSpiritFavorByTempId(templateId)
	local npcInfo = self:GetNpcCultivationInfoByTemplateId(templateId)

	if not npcInfo then
		return 0
	end

	return npcInfo.Favor
end

function M:GetSpiritFavorAnim(pid)
	local cfgId = self:GetSpiritAcquisitionIdByPid(pid)
	local cfg = AgentDataSetsConfig.GetConfig(cfgId)

	if cfg == nil then
		return 0
	end

	local templateId = cfg.NpccultivationId
	local npcCfg = NpcCultivationConfig.GetConfig(templateId)
	local npcInfo = self.favorInfos[templateId]

	if not npcInfo then
		print_error("无法交互的templateId!, templateId = ", templateId)

		return 0
	end

	local favor = npcInfo.Favor

	if NpcCultivationConfig.HighFavour <= favor then
		return npcCfg.HighFavourPhotoAction
	elseif NpcCultivationConfig.MidFavour <= favor then
		return npcCfg.MidFavourPhotoAction
	else
		return npcCfg.LowFavourPhotoAction
	end
end

function M:GetNpcPhotoState(pid)
	local cfgId = self:GetSpiritAcquisitionIdByPid(pid)
	local npcInfo = self:GetNpcCultivationInfoByPid(pid)
	local groupNpcPhotoPosList = npcInfo.GroupNpcPhotoPosList
	local singleNpcPhotoPosList = npcInfo.SingleNpcPhotoPosList
	local hasGroup = false
	local hasSingle = false

	for i = 1, #groupNpcPhotoPosList do
		if cfgId == groupNpcPhotoPosList[i] then
			hasGroup = true

			break
		end
	end

	for i = 1, #singleNpcPhotoPosList do
		if cfgId == singleNpcPhotoPosList[i] then
			hasSingle = true

			break
		end
	end

	return hasSingle, hasGroup
end

function M:CheckIfInteractionTrueSpirit()
	local cfgId = gCS.MyPlayerManager.PlayerUnit.ClientData.SubType
	local cfg = FightSpiritConfig.GetConfig(cfgId)

	if not cfg then
		return false
	end

	local templateId = cfg.NpcCultivationRelatedId
	local trueSpirits = NpcCultivationConfig.InteractionTrueSpirit

	for _, id in ipairs(trueSpirits) do
		if id == templateId then
			return true
		end
	end

	return false
end

function M:CheckIfAcquisitionNpc(pid)
	local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(pid)

	if not npcSpawn then
		return false
	end

	local cfgId = npcSpawn.spiritAcquisitionCfgId

	if cfgId <= 0 then
		return false
	end

	return true
end

function M:PopUpFavorUnlock(npcCardId)
	table.insert(self.popupInfoList, npcCardId)

	self.waitCo = coroutine.stop(self.waitCo)
	self.waitCo = coroutine.start(function ()
		coroutine.wait(0.25)

		if LTConfig.PopupConfig.AreaFivePopUpLimitCount <= #self.popupInfoList then
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.FriendShipUnlockedTotal, {
				count = #self.popupInfoList
			})
		else
			for _, popupInfo in ipairs(self.popupInfoList) do
				gNewPopupManager:PushPopup(LTConfig.PopupConfig.FriendShipUnlocked, {
					Param = {
						NpcId = popupInfo
					}
				})
			end
		end

		self.popupInfoList = {}
	end)
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.currentDialogBranch = nil
		self.currentCfgIdUseInBranchDialog = nil

		gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_SHOW_START, self.dialogSelectHandler)
	end
end

gSpiritAcquisitionManager = gSpiritAcquisitionManager or C_SpiritAcquisitionManager.new()
