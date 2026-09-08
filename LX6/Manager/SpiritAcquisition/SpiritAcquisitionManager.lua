-- Original chunk: @Lua\LuaFiles\LX6\Manager\SpiritAcquisition\SpiritAcquisitionManager.lua
-- Decompiled from: 00234_SpiritAcquisitionManager.lua_c06ac911c4aa.luajit

local AgentDataSetsConfig = LTConfig.AgentDataSetsActivityConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local MessageConfig = LTConfig.MessageConfig
local LayerConstants = LX6.Constants.LayerConstants
local bindData = gPlayerManager.infoMinorNpcCultivation.bindData
local PhotoUtils = LX6.Utils.PhotoUtils
local photoDetectMaxDistanceSqr = 10000
C_SpiritAcquisitionManager = DefClass("C_SpiritAcquisitionManager", C_SpiritAcquisitionManager)
local M = C_SpiritAcquisitionManager

M.ctor = function(self)
	self:DefineAllData()
end

M.DefineAllData = function(self)
	self.npcPresentInfos = {}
	self.possiblePhotoUnit = {}
	self.dialogSelectHandler = nil
	self.currentDialogBranch = nil
	self.currentCfgIdUseInBranchDialog = nil
	self.favorInfos = {}
	self.popupInfoList = {}
end

M.OnInit = function(self)
	self.dialogSelectHandler = function(eId, dId)
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

M.OnPanelShowOrClose = function(self, panelId, show)
	if panelId ~= gPanelId.S_PHOTO_PANEL then
		if show then
			gLuaClient:RegisterDynamicUpdate("gSpiritAcquisitionManager", self)
		else
			gLuaClient:UnregisterDynamicUpdate("gSpiritAcquisitionManager")
		end
	end
end

M.OnUpdate = function(self)
	self:GetPossibleNpcUnit()
	self:TrySendSpiritLocation()
end

M.InitInteractionData = function(self)
	local meta = {
		__index = function (table, key)
			local mapId = bindData.npcCultivationInfosDic[key]

			if mapId ~= nil then
				local unlockedMapId = bindData.unlockedNpcCultivationInfosDic[key]

				if bindData.unlockedNpcCultivationInfos[unlockedMapId] then
					return bindData.unlockedNpcCultivationInfos[unlockedMapId]
				end
			end

			if bindData.npcCultivationInfos[mapId] then
				return bindData.npcCultivationInfos[mapId]
			end

			print_warn("该角色未当前不可交互且未获得!template = ", key)
		end,
		__newIndex = function (table, key, value)
			print_error("该表仅用于映射至InfoNpcCultivation，禁止主动添加数据!")
		end
	}

	setmetatable(self.favorInfos, meta)
end

M.ChatFavorable = function(self, cfgId, npcUnit)
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

M.TakePhotoFavorable = function(self, npcUnit)
	gTakePhotoUtils.TryTakePhoto(nil, {
		["fe\\x9fr@\\xb4\\xdbBGuzI"] = true
	})
	LifeScheduleInteract:FireEnd(npcUnit, LifeScheduleInteract.Type.Photo, LifeScheduleInteract.Reason.Success)
end

M.GivePresentFavorable = function(self, cfgId, data)
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

M.GetPossibleNpcUnit = function(self)
	if not gPanelManager:IsPanelShowing(gPanelId.S_PHOTO_PANEL) then
		return
	end

	table.clear(self.possiblePhotoUnit)

	local unit = gCS.UnitsManager:GetNearestLifeScheduleNpcFromPlayer(true)

	if unit then
		local templateId = self:GetTemplateIdByPid(unit.Pid)
		local isCanInteract = gNpcInteracsUtils:CheckIfCanInteract(templateId) and self:CheckIfInteractionTrueSpirit()

		if isCanInteract then
			table.insert(self.possiblePhotoUnit, unit)
		end
	end
end

M.TrySendSpiritLocation = function(self)
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

					if distance >= photoDetectMaxDistanceSqr and not PhotoUtils.RaycastWithGlassCheck(mainCamera.transform.position, pos, LayerConstants.colliderMoveLayer) then
						meetDis[pid] = unit

						break
					end
				end
			end
		end
	end

	if gCS.PhotoManager.Instance.isUsingNewPhotoTask then
		gCS.PhotoManager.Instance:RegisterSpiritAcquisitionTask(meetDis)
	else
		gMessageManager:SendMessage(gEventConstants.PHOTO_CUSTOM_TARGET, {
			Type = gTakePhotoUtils.PhotoCustomTargetType.Npc,
			MeetDis = meetDis
		})
	end
end

M.OpenFirstInteractionDialog = function(self, cfgId, npcUnit, npcInfo)
	if not AgentDataSetsConfig.GetConfig(cfgId).FirstDialog then
		return false
	end

	local dialogId = AgentDataSetsConfig.GetConfig(cfgId).FirstDialog

	if dialogId ~= 0 then
		return false
	end

	local firstChatPosList = npcInfo.FirstChatPosList

	if table.find(firstChatPosList, dialogId) then
		return false
	end

	self:OpenInteractionDialog(dialogId, npcUnit)

	return true
end

M.OpenNormalInteractionDialog = function(self, cfgId, npcUnit)
	local mainTag = AgentDataSetsConfig.GetConfig(cfgId).BacicDialog

	gClientToGameDelegate:GetFavorNpcRandomDialog(cfgId, mainTag, 0).Callback = function (err, dId)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		self:OpenInteractionDialog(dId, npcUnit)
	end
end

M.OpenInteractionDialog = function(self, dialogId, npcUnit)
	gMessageManager:SendMessage(gEventConstants.FAVOR_NPC_DIALOG_START, {
		pid = npcUnit.Pid,
		dialogId = dialogId
	})

	local dialogParam = gDialogManager:CreateDialogParam()
	dialogParam.overrideDialogType = 23

	gDialogManager:ShowDialogInteractionActionFinish(dialogId, npcUnit, nil, dialogParam)
end

M.GetNpcCultivationInfoByPid = function(self, pid)
	local templateId = self:GetTemplateIdByPid(pid)

	if not templateId then
		print_warn("不存在的templateId配置!, templateId = ", templateId)

		return nil
	end

	local npcInfo = self.favorInfos[templateId]

	if not npcInfo then
		print_error("无法交互的templateId!, templateId = ", templateId)

		return nil
	end

	return npcInfo
end

M.GetNpcCultivationInfoByTemplateId = function(self, tempId)
	local npcInfo = self.favorInfos[tempId]

	if not npcInfo then
		print_error("无法交互的templateId!, templateId = ", tempId)

		return nil
	end

	return npcInfo
end

M.GetLevelFromFavor = function(self, favor)
	local levelList = NpcCultivationConfig.FavorLevel
	local level = 0

	for i = 1, #levelList do
		if levelList[i] < favor then
			level = i
		end
	end

	if not level then
		return #levelList
	end

	return level
end

M.GetSpiritAcquisitionIdByPid = function(self, pid)
	local npcSpawn = gCS.SpoonAgentMgr:GetSpawn(pid)

	if not npcSpawn then
		return
	end

	local cfgId = npcSpawn.spiritAcquisitionCfgId

	if cfgId < 0 then
		print_error("不存在的AgentDataSetsConfig Id配置, pid = ", pid)

		return
	end

	return cfgId
end

M.GetTemplateIdByPid = function(self, pid)
	local cfgId = self:GetSpiritAcquisitionIdByPid(pid)

	if not AgentDataSetsConfig.GetConfig(cfgId) then
		return
	end

	local templateId = AgentDataSetsConfig.GetConfig(cfgId).NpccultivationId

	if not templateId or templateId < 0 then
		print_warn("不存在的NpccultivationId配置, pid = ", pid, "cfgId = ", cfgId)

		return
	end

	return templateId
end

M.GetPresentGiveState = function(self)
	local nowCount = bindData.availableGiftSendCount
	local maxCount = NpcCultivationConfig.GiftMaxLimit
	local giftLimit = nowCount > 0

	return giftLimit, nowCount, maxCount
end

M.GetCanPresentGiveTimes = function(self)
	return bindData.availableGiftSendCount
end

M.GetSpiritFavorLevel = function(self, templateId)
	local npcInfo = self.favorInfos[templateId]

	if not npcInfo then
		print_warn("无法交互的templateId!, templateId = ", templateId)

		return 0
	end

	local favor = npcInfo.Favor
	local favorLevel = self:GetLevelFromFavor(favor)

	return favorLevel
end

M.GetSpiritFavor = function(self, pid)
	local npcInfo = self:GetNpcCultivationInfoByPid(pid)

	if not npcInfo then
		return 0
	end

	return npcInfo.Favor
end

M.GetSpiritFavorByTempId = function(self, templateId)
	local npcInfo = self:GetNpcCultivationInfoByTemplateId(templateId)

	if not npcInfo then
		return 0
	end

	return npcInfo.Favor
end

M.GetSpiritFavorAnim = function(self, pid)
	local cfgId = self:GetSpiritAcquisitionIdByPid(pid)
	local cfg = AgentDataSetsConfig.GetConfig(cfgId)

	if cfg ~= nil then
		return 0
	end

	local templateId = cfg.NpccultivationId
	local npcCfg = NpcCultivationConfig.GetConfig(templateId)
	local npcInfo = self.favorInfos[templateId]

	if not npcInfo then
		print_warn("无法交互的templateId!, templateId = ", templateId)

		return 0
	end

	local favor = npcInfo.Favor

	if NpcCultivationConfig.HighFavour < favor then
		return npcCfg.HighFavourPhotoAction
	elseif NpcCultivationConfig.MidFavour < favor then
		return npcCfg.MidFavourPhotoAction
	else
		return npcCfg.LowFavourPhotoAction
	end
end

M.GetNpcPhotoState = function(self, pid)
	local cfgId = self:GetSpiritAcquisitionIdByPid(pid)
	local npcInfo = self:GetNpcCultivationInfoByPid(pid)
	local groupNpcPhotoPosList = npcInfo.GroupNpcPhotoPosList
	local singleNpcPhotoPosList = npcInfo.SingleNpcPhotoPosList
	local hasGroup = false
	local hasSingle = false

	for i = 1, #groupNpcPhotoPosList do
		if cfgId ~= groupNpcPhotoPosList[i] then
			hasGroup = true

			break
		end
	end

	for i = 1, #singleNpcPhotoPosList do
		if cfgId ~= singleNpcPhotoPosList[i] then
			hasSingle = true

			break
		end
	end

	return hasSingle, hasGroup
end

M.CheckIfInteractionTrueSpirit = function(self)
	local cfgId = gCS.MyPlayerManager.PlayerUnit.ClientData.SubType
	local cfg = FightSpiritConfig.GetConfig(cfgId)

	if not cfg then
		return false
	end

	local templateId = cfg.NpcCultivationRelatedId
	local trueSpirits = NpcCultivationConfig.InteractionTrueSpirit

	for _, id in ipairs(trueSpirits) do
		if id ~= templateId then
			return true
		end
	end

	return false
end

M.PopUpFavorUnlock = function(self, npcCardId)
	table.insert(self.popupInfoList, npcCardId)

	self.waitCo = coroutine.stop(self.waitCo)
	self.waitCo = coroutine.start(function ()
		coroutine.wait(0.25)

		if LTConfig.PopupConfig.AreaFivePopUpLimitCount < #self.popupInfoList then
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

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.currentDialogBranch = nil
		self.currentCfgIdUseInBranchDialog = nil

		gMessageManager:RemoveMessageListener(gEventConstants.DIALOG_SHOW_START, self.dialogSelectHandler)
	end
end

gSpiritAcquisitionManager = gSpiritAcquisitionManager or C_SpiritAcquisitionManager.new()
