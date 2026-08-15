local FactionConfig = LTConfig.FactionConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local GameConfig = LTConfig.GameConfig
local SpiritCaseConfig = LTConfig.SpiritCaseConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local sqrt3 = math.sqrt(3)
local MAX_INTEGER = 1000000000
C_SwapCharacterListPanelStore = DefClass("C_SwapCharacterListPanelStore", C_SwapCharacterListPanelStore, C_StoreGroup)
GroupName2Class.SwapCharacterListPanelStore = C_SwapCharacterListPanelStore
local M = C_SwapCharacterListPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.freeList = nil
	self.content = nil
	self.viewOffset = nil
	self.freeListItem = {}
	self.freeListItemStore = {}
	self.selectedStore = nil
	self.lastSelectedStore = nil
	self.space = GameConfig.CharListTemplateSpace
	self.insideWidth = GameConfig.CharListeInsideWidth
	self.boundaryWidth = GameConfig.CharListBoundaryWidth
	self.selectedChar = 0
	self.selectedIndex = 0
	self.clickSelectIndex = 0
	self.minDistanceToCenter = MAX_INTEGER
	self.nearestCenterItemIndex = 0
	self.lastNearestCenterItemIndex = 0
	self.needSwitch = false
	self.hintBtn = nil
	self.factionLimit = 0
	self.showSpiritSet = {}
	self.needUpdateScrollPos = false
	self.moveValue = {
		x = 0,
		y = 0
	}
	self.mouseSpeed = GameConfig.CharListMouseSpeed
	self.joyStickSpeed = GameConfig.CharListControllerSpeed
	self.mouseStopTime = 0
	self.allowMouseStop = false
	self.returnTime = GameConfig.CharListSnappingTime
	self.stopTime = 0
	self.emptyTex = nil
	self.isCursor = false
	self.lastChangeTime = 0
	self.hasTaskRole = false
	self.initFinished = false
	self.isAskSwitch = false
	self.notifyData = {}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
end

function M:OnGroupEnable()
	self.content = self.bindData.scrollRect.content
	local swapFreeListStore = gStoreManager:GetStoreGroup("SwapFreeListStore"):GetStoreByWidget(self.content)
	self.freeList = swapFreeListStore.freeList

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		swapFreeListStore.freeList.luaClick = self:CreateAction("OnClickSwapFreeList")
	end

	swapFreeListStore.freeList.luaRenderItem = self:CreateAction("OnRenderSwapFreeListItem")

	function swapFreeListStore.freeList.onGetTIndex(_)
		return 0
	end

	self.isCursor = gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.KeyboardMouse
end

function M:OnShow(panelId, data)
	self.initFinished = false
	self.isAskSwitch = false
	self.stopTime = 0

	gCS.LuaUtils.SwapChaHideLayer(true)
	gUrbanAbilityManager:GetAllSpiritPanelData()
	self.bindData:EnableImmediatelyCommit(true)

	self.factionLimit = FactionConfig.DispositionDontSwitch
	gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled = false
	self.bindData.mouseMove.luaGamePadInputChanged = self:CreateAction("OnMouseMove")

	self:BuildCharacterData()

	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false

	gLoadingManager:SwitchTeleport_TryOpenBlur()
end

function M:OnClose()
	if self.clickSelectIndex and self.freeListItem[self.clickSelectIndex] then
		self.freeListItem[self.clickSelectIndex]:SetSelected(false)
	end

	gCS.LuaUtils.SwapChaHideLayer(false)

	self.bindData.showDetailsCtrl = 0
	gCS.CameraDataMgr.cameraControllerManager.IsZoomEnabled = true

	if self.lastSelectedStore then
		self.lastSelectedStore.selectedCtrl = 0
	end

	if self.selectedStore then
		self.selectedStore.selectedCtrl = 0
	end

	self:SwitchCharacterWhenClose()

	if not self.isAskSwitch then
		gLoadingManager:SwitchTeleport_TryCloseBlur()
	end

	self.hintBtn = nil
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
end

function M:OnUpdate()
	if not self.initFinished then
		return
	end

	self.minDistanceToCenter = MAX_INTEGER

	self:HandleItemSize()

	if not self.needUpdateScrollPos then
		if self.returnTime < self.stopTime then
			self.stopTime = 0

			if self.nearestCenterItemIndex ~= 0 then
				self:GotoSelectItemPos(false)

				self.moveValue.x = 0
				self.moveValue.y = 0
				self.lastNearestCenterItemIndex = self.nearestCenterItemIndex
			elseif self.minDistanceToCenter > 10000 then
				self:GotoSelectItemPos(false)

				self.lastNearestCenterItemIndex = self.nearestCenterItemIndex
				self.canMove = false
			end
		end

		self.stopTime = self.stopTime + Time.deltaTime
	else
		self.stopTime = 0

		if self.canMove then
			self:UpdateScrollPos()
		end
	end

	if self.minDistanceToCenter < 0.01 and not self.canMove then
		self.canMove = true
	end

	self:SetSelectHint()
end

function M:RegisterWidget()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.switchBtn.luaClick = self:CreateAction("OnClickSwitchBtn")

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.scrollRect.luaEndDrag = self:CreateAction("OnScrollRectEndDrag")
	end

	self.bindData.joyStickMove.luaGamePadInputChanged = self:CreateAction("OnJoyStickMove")
	self.bindData.notifyList.luaSimpleRenderItem = self:CreateAction("OnNotifyListRender")
end

function M:OnClickCloseBtn()
	self.needSwitch = false

	gPanelManager:Close(self.m_Id)
end

function M:OnClickSwitchBtn()
	if self.bindData.btnCtrl == 1 or self.bindData.btnCtrl == 2 then
		return
	end

	gPanelManager:Close(self.m_Id)
	self:SwitchCharacter()
end

function M:OnClickSwapFreeList(btn, index)
	if self.clickSelectIndex ~= 0 then
		self.freeListItem[self.clickSelectIndex]:SetSelected(false)
	end

	self.clickSelectIndex = index + 1

	if btn ~= nil then
		self.hintBtn = btn
	end

	local data = self.showSpiritSet[index + 1]
	self.hintBtn = btn

	self:RefreshSelectInfo(data)
	self.freeListItem[self.clickSelectIndex]:SetSelected(true)
end

function M:OnRenderSwapFreeListItem(btn, index)
	local x, y = self:CalIndexPosition(index + 1)

	btn.transform:SetLocalPosition(x, y, 0)

	self.freeListItem[index + 1] = btn

	if index + 1 == self.selectedIndex then
		self:GotoSelectItemPos(true)

		self.initFinished = true
	end

	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SwapAvatarTemplate"):GetStoreById(id)

	if store then
		self.freeListItemStore[index + 1] = store
		local data = self.showSpiritSet[index + 1]
		local cfg = FightSpiritConfig.GetConfig(data.cfg)
		store.avatarIconId = cfg.SHeadIconID
		store.bgColor = Color.NewByStr(cfg.CharListTemplateBgColor)

		if not data.isUnlock then
			if data.isKnow then
				store.stageCtrl = 1
				store.ownCtrl = 1
				store.notifyCtrl = 0

				return
			else
				store.stageCtrl = 1
				store.ownCtrl = 2
				store.notifyCtrl = 0

				return
			end
		end

		btn.interactable = true

		if self.hasTaskRole then
			if data.taskAllow then
				store.ownCtrl = 0
			else
				store.ownCtrl = 3
			end
		else
			store.ownCtrl = 0
		end

		local startAniTime = store.ani:GetClip("vx_S_AvatarTemplate_SelectingRing_guide_open").length

		store.ani:Play("vx_S_AvatarTemplate_SelectingRing_guide_open")

		if data.isGuide then
			store.guideCtrl = 1
			store.guideText = string.format(TextScriptTextConfig.GetConfig(89901262).Text, cfg.Name)

			gLuaTimeMgrUtils.Delay(function ()
				store.ani:Play("vx_S_AvatarTemplate_SelectingRing_guide_loop")
			end, startAniTime)
		else
			store.guideCtrl = 0

			store.ani:Stop()
		end

		if data.isCurrent then
			store.stageCtrl = 0
			store.notifyCtrl = 0

			return
		end

		store.stageCtrl = 1
		local hasNotify = false

		if data.messageCount and data.messageCount > 0 then
			store.notifyCtrl = 4
			hasNotify = true
		end

		if data.taskInfo then
			local taskInfo = data.taskInfo

			if taskInfo[2] then
				store.notifyCtrl = 3
				hasNotify = true
			end

			if taskInfo[6] then
				store.notifyCtrl = 2
				hasNotify = true
			end

			if taskInfo[1] then
				store.notifyCtrl = 1
				hasNotify = true
			end
		end

		if data.disabled then
			store.notifyCtrl = 5
			hasNotify = true
		end

		if not hasNotify then
			store.notifyCtrl = 0
		end
	end
end

function M:OnHoverSwapFreeList(index)
	self.hintBtn = self.freeListItem[index + 1]

	self:OnClickSwapFreeList(nil, index)
end

function M:OnUnHoverSwapFreeList(index)
	self.clickSelectIndex = 0
	self.bindData.showDetailsCtrl = 0
	self.needSwitch = false
	self.hintBtn = nil
end

function M:OnPCClickSwapFreeList(btn, index)
	self.clickSelectIndex = index + 1
	local data = self.showSpiritSet[index + 1]

	if data.isDisable or not data.isUnlock then
		return
	end

	self:RefreshSelectInfo(data)
	gPanelManager:Close(self.m_Id)
end

function M:OnScrollRectEndDrag()
	return
end

function M:OnMouseMove(context)
	if not self.bActive then
		self.needUpdateScrollPos = false
		self.moveValue.x = 0
		self.moveValue.y = 0

		return
	end

	if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
		return
	end

	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.needUpdateScrollPos = true

		if math.abs(value.x) > 5 then
			self.moveValue.x = value.x
		else
			self.moveValue.x = 0
		end

		if math.abs(value.y) > 5 then
			self.moveValue.y = value.y
		else
			self.moveValue.y = 0
		end
	end

	if context.canceled then
		self.needUpdateScrollPos = false
	end
end

function M:OnJoyStickMove(context)
	if not self.bActive then
		self.needUpdateScrollPos = false
		self.moveValue.x = 0
		self.moveValue.y = 0

		return
	end

	if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		return
	end

	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.needUpdateScrollPos = true
		self.moveValue.x = value.x
		self.moveValue.y = value.y

		if math.abs(self.moveValue.x) < 0.01 and math.abs(self.moveValue.y) < 0.01 then
			self.needUpdateScrollPos = false
		end
	end

	if context.canceled then
		self.needUpdateScrollPos = false
		self.moveValue.x = 0
		self.moveValue.y = 0
	end
end

function M:UpdateScrollPos()
	if not self.viewOffset then
		return
	end

	local norm = math.sqrt(self.moveValue.x * self.moveValue.x + self.moveValue.y * self.moveValue.y)

	if norm < 0.1 then
		return
	end

	self.moveValue.x = self.moveValue.x / norm
	self.moveValue.y = self.moveValue.y / norm
	local speed = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() and self.joyStickSpeed or self.mouseSpeed
	local offset = self.content.transform.localPosition + self.viewOffset
	offset.x = offset.x - self.moveValue.x * speed
	offset.y = offset.y - self.moveValue.y * speed

	self.bindData.scrollRect:GoToPos(offset, false)
end

function M:OnNotifyListRender(btn, index)
	local data = self.notifyData[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SwapNotifyTemplate"):GetStoreById(id)

	if store then
		store.notifyCtrl = data.notifyType
	end
end

local function spiritSort(a, b)
	return a.cfg < b.cfg
end

local function spiritSortUnlock(a, b)
	local aAcquainted = gAgentTrustManager:GetIfAcquainted(a.agentId)
	local bAcquainted = gAgentTrustManager:GetIfAcquainted(b.agentId)

	if aAcquainted and not bAcquainted then
		return true
	elseif not aAcquainted and bAcquainted then
		return false
	else
		return a.cfg < b.cfg
	end

	return a.cfg < b.cfg
end

function M:BuildCharacterData()
	table.clear(self.showSpiritSet)

	if gSpiritManager:CheckHasTaskRole() then
		self.hasTaskRole = true
	else
		self.hasTaskRole = false
	end

	self:NormalBuildData()
	self.freeList:SetList(#self.showSpiritSet)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:RefreshSelectInfo(self.showSpiritSet[self.selectedIndex])
	end

	self:CalHexagonBounding(#self.showSpiritSet)
end

function M:NormalBuildData()
	local allSpirit = {}
	local allSpiritDic = {}

	for i = 0, FightSpiritConfig.count - 1 do
		local cfg = FightSpiritConfig.LoadAt(i)

		if cfg.Id ~= FightSpiritConfig.DefaultMale and cfg.Id ~= FightSpiritConfig.DefaultFemale and cfg.CanJoin then
			allSpiritDic[cfg.Id] = false

			table.insert(allSpirit, cfg.Id)
		end
	end

	local mainCharacter = {}
	local importCharacter = {}
	local normalCharacter = {}
	local unlockCharacter = {}

	gSpiritManager:Foreach(function (spirit)
		if spirit.config then
			if not spirit.config.CanJoin then
				return
			end

			local disabled = false
			local spiritFactionCfg = LTConfig.AgentConfig.GetConfig(spirit.config.AgentId)
			local Faction = nil

			if spiritFactionCfg then
				Faction = spiritFactionCfg.Faction
			end

			if spirit.config.DispositionDontSwitch and Faction and Faction > 0 then
				local factionInfo = gPlayerManager.infoAchievement.bindData.FactionInfoDic[Faction]

				if factionInfo and factionInfo.DispositionLevel <= self.factionLimit then
					disabled = true
				end
			end

			local isImportant = spirit.config.Important

			if spirit.config.Id == FightSpiritConfig.DefaultMale or spirit.config.Id == FightSpiritConfig.DefaultFemale then
				table.insert(mainCharacter, {
					isMain = true,
					isUnlock = true,
					cfg = spirit.config.Id,
					isCurrent = spirit.config.Id == gBattleSpiritMgr.currentSpiritTemplateId,
					disabled = disabled
				})
			elseif isImportant then
				table.insert(importCharacter, {
					isUnlock = true,
					cfg = spirit.config.Id,
					isCurrent = spirit.config.Id == gBattleSpiritMgr.currentSpiritTemplateId,
					disabled = disabled
				})
			else
				table.insert(normalCharacter, {
					isUnlock = true,
					cfg = spirit.config.Id,
					isCurrent = spirit.config.Id == gBattleSpiritMgr.currentSpiritTemplateId,
					disabled = disabled
				})
			end

			allSpiritDic[spirit.config.Id] = true
		end
	end)

	for _, id in ipairs(allSpirit) do
		if not allSpiritDic[id] then
			local agentId = FightSpiritConfig.GetConfig(id).AgentId
			local isKnow = gAgentTrustManager:GetIfAcquainted(agentId)

			table.insert(unlockCharacter, {
				isCurrent = false,
				disabled = false,
				isUnlock = false,
				cfg = id,
				isKnow = isKnow,
				agentId = agentId
			})
		end
	end

	table.sort(importCharacter, spiritSort)
	table.sort(normalCharacter, spiritSort)
	table.sort(unlockCharacter, spiritSortUnlock)

	for _, data in ipairs(mainCharacter) do
		table.insert(self.showSpiritSet, data)
	end

	for _, data in ipairs(importCharacter) do
		table.insert(self.showSpiritSet, data)
	end

	for _, data in ipairs(normalCharacter) do
		table.insert(self.showSpiritSet, data)
	end

	for _, data in ipairs(unlockCharacter) do
		table.insert(self.showSpiritSet, data)
	end

	local roles = gSpiritManager:GetTaskRoles()
	local hasRoles = #roles > 0

	for i = 1, #self.showSpiritSet do
		if self.hasTaskRole then
			local id = self.showSpiritSet[i].cfg
			local needReplace = false
			local replaceRole = nil

			for _, role in ipairs(roles) do
				if role.FightSpiritId == id then
					needReplace = true
					replaceRole = role

					break
				end
			end

			if needReplace then
				local data = {
					cfg = replaceRole.FightSpiritId
				}
				data.isCurrent = data.cfg == gBattleSpiritMgr.currentSpiritTemplateId
				data.disabled = false
				data.isUnlock = true
				data.isMain = replaceRole.isMain
				data.isCase = replaceRole.isCase
				data.spiritCaseId = replaceRole.SpiritCaseId
				data.isGuide = replaceRole.isGuide
				data.roleId = replaceRole.Id
				data.taskAllow = true
				self.showSpiritSet[i] = data
			end
		end

		local data = self.showSpiritSet[i]

		if data.isCurrent then
			self.selectedChar = data.cfg
			self.selectedIndex = i

			if self.hasTaskRole then
				data.taskAllow = true
			end
		end

		if gSpiritManager:CheckIsTempSpirit(data.cfg) then
			data.isUnlock = true
			data.disabled = false
			data.isTemp = true
		end

		if not hasRoles then
			local npcId = FightSpiritConfig.GetConfig(data.cfg).NpcCultivationRelatedId

			if npcId and npcId > 0 and not data.disabled and not data.isCurrent then
				local messageCount = gNpcChatUtils.GetUncompletedChatAndDialogCount(npcId)
				data.messageCount = messageCount
			end

			local taskInfo = gMapSubSystem_Task:GetFightSpiritAvailableTaskTitles(data.cfg)

			if not table.isNilOrEmpty(taskInfo) then
				data.taskInfo = taskInfo
			end
		end
	end
end

function M:TaskBuildData()
	local roles = gSpiritManager:GetTaskRoles()

	for _, role in ipairs(roles) do
		local data = {
			cfg = role.FightSpiritId
		}
		data.isCurrent = data.cfg == gBattleSpiritMgr.currentSpiritTemplateId
		data.disabled = false
		data.isUnlock = true
		data.isMain = role.isMain
		data.isCase = role.isCase
		data.spiritCaseId = role.SpiritCaseId
		data.isGuide = role.isGuide
		data.roleId = role.Id

		if data.isMain then
			table.insert(self.showSpiritSet, 1, data)
		else
			table.insert(self.showSpiritSet, data)
		end
	end

	for index, data in ipairs(self.showSpiritSet) do
		if data.isCurrent then
			self.selectedChar = data.cfg
			self.selectedIndex = index
		end

		if gSpiritManager:CheckIsTempSpirit(data.cfg) then
			data.isUnlock = true
			data.disabled = false
			data.isTemp = true
		end
	end
end

function M:HandleCursor()
	local uiPos = gCS.LuaUtils.TransformScreenPointToUI(self.bindData.rootRt, UnityEngine.Input.mousePosition)

	self.bindData.cursorRt.transform:SetLocalPosition(uiPos)
end

function M:RefreshSelectInfo(data)
	if not data then
		return
	end

	local selectFlag = nil
	selectFlag = gCS.LuaUtils.IsNonMobileAdaptive()

	if self.freeListItemStore[self.selectedIndex] and selectFlag then
		if self.lastSelectedStore then
			self.lastSelectedStore.selectedCtrl = 0
		end

		self.lastSelectedStore = self.selectedStore
		self.selectedStore = self.freeListItemStore[self.selectedIndex]
		self.selectedStore.selectedCtrl = 1
	end

	if not data.isUnlock then
		if data.isKnow then
			self.bindData.showDetailsCtrl = 2
			self.selectedChar = 0
			self.needSwitch = false

			return
		else
			self.bindData.showDetailsCtrl = 3
			self.selectedChar = 0
			self.needSwitch = false

			return
		end
	end

	self.selectedChar = data.cfg
	local cfg = FightSpiritConfig.GetConfig(self.selectedChar)
	local lightColor = Color.NewByStr(cfg.CharListTemplateBgColor)

	SGUI.UNavigationMgr.Inst:SetLightBarColor(lightColor)

	self.bindData.showDetailsCtrl = 1
	self.bindData.nameText = data.isMain and gPlayerManager.infoLogin.bindData.name or cfg.Name

	if data.isTemp then
		self:RefreshTempSpirit(cfg)

		return
	end

	if data.isCase then
		self:RefreshCaseSpirit(data)

		return
	end

	local spirit = gSpiritManager:GetSpirit(data.cfg)

	if not spirit then
		print_error("spirit数据不存在！", data.cfg)
	end

	local spiritInfo = spirit.SpiritInfo
	self.bindData.proficiencyNumberText = gUrbanAbilityManager:GetAbilitySumExp(spiritInfo.SpiritAbilities)

	if data.disabled then
		self.bindData.statusCtrl = 1
		self.needSwitch = false
	elseif data.isCurrent then
		self.bindData.statusCtrl = 2
		self.needSwitch = false
	elseif self.hasTaskRole and not data.taskAllow then
		self.bindData.statusCtrl = 3
		self.bindData.switchBtn.interactable = false
		self.needSwitch = false
	else
		self.bindData.statusCtrl = 0
		self.bindData.switchBtn.interactable = true
		self.needSwitch = true
	end

	table.clear(self.notifyData)

	if data.taskInfo and data.taskInfo then
		local taskInfo = data.taskInfo

		if taskInfo[1] then
			table.insert(self.notifyData, {
				notifyType = 0
			})
		end

		if taskInfo[6] then
			table.insert(self.notifyData, {
				notifyType = 1
			})
		end

		if taskInfo[2] then
			table.insert(self.notifyData, {
				notifyType = 2
			})
		end
	end

	if data.messageCount and data.messageCount > 0 then
		self.bindData.messageCtrl = 1
		self.bindData.messageNumText = string.format(TextScriptTextConfig.GetConfig(89901265).Text, data.messageCount)

		table.insert(self.notifyData, {
			notifyType = 3
		})
	else
		self.bindData.messageCtrl = 0
	end

	if #self.notifyData > 0 then
		self.bindData.notifyCtrl = 1
	else
		self.bindData.notifyCtrl = 0
	end

	self.bindData.notifyList:SetSimpleList(#self.notifyData)

	local urbanAttrs = gUrbanAbilityManager:GetUrbanAttrs(data.cfg)

	if not urbanAttrs then
		return
	end

	for i, v in ipairs(urbanAttrs) do
		self.bindData.radar:SetVertexValue(i - 1, v)

		self.bindData["radarText" .. i] = v
	end

	local jobInfo = spiritInfo.SpiritJobInfo
	local jobId = jobInfo.CurrentJob

	if jobId == LTConfig.UrbanJobConfig.Jobless then
		for i, v in pairs(jobInfo.AvailableJobs) do
			if i ~= LTConfig.UrbanJobConfig.Jobless then
				jobId = i

				break
			end
		end
	end

	if jobId == LTConfig.UrbanJobConfig.Jobless then
		self.bindData.jobsIcon:SetActive(false)
	else
		self.bindData.jobsIcon:SetActive(true)

		local jobCfg = LTConfig.UrbanJobConfig.GetConfig(jobId)

		if not jobCfg then
			print_error("该角色职业配置不存在！spirit:", data.cfg, " jobId:", jobId)

			return
		end

		self.bindData.jobIconId = jobCfg.Icon
	end
end

function M:RefreshTempSpirit(cfg)
	local abilities = cfg.UrbanAttribute
	local sum = 0

	for i = 1, #abilities do
		sum = sum + abilities[i]
	end

	for i, v in ipairs(abilities) do
		self.bindData.radar:SetVertexValue(i - 1, v)

		self.bindData["radarText" .. i] = v
	end

	self.bindData.jobsIcon:SetActive(false)

	self.needSwitch = true
end

function M:RefreshCaseSpirit(data)
	local cfg = SpiritCaseConfig.GetConfig(data.spiritCaseId)
	local abilities = cfg.UrbanAttribute
	local sum = 0

	for i = 1, #abilities do
		sum = sum + abilities[i]
	end

	for i, v in ipairs(abilities) do
		self.bindData.radar:SetVertexValue(i - 1, v)

		self.bindData["radarText" .. i] = v
	end

	self.bindData.jobsIcon:SetActive(false)

	self.needSwitch = true
end

function M:GotoSelectItemPos(instant)
	local selectedItem = self.freeListItem[self.selectedIndex]

	if not selectedItem then
		return
	end

	self.bindData.scrollRect:GoToPos(selectedItem.transform.localPosition * -1, instant)
end

function M:SwitchCharacterWhenClose()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self:SwitchCharacter()
	end
end

function M:SwitchCharacter()
	local canSwitch = true

	if not self.needSwitch then
		canSwitch = false
	end

	if self.selectedChar == 0 then
		canSwitch = false
	end

	if gBattleSpiritMgr.currentSpiritTemplateId == self.selectedChar then
		canSwitch = false
	end

	if canSwitch then
		local cfg = FightSpiritConfig.GetConfig(self.selectedChar)
		local lightColor = Color.NewByStr(cfg.CharListTemplateBgColor)

		if self.hasTaskRole then
			local data = nil

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				data = self.showSpiritSet[self.selectedIndex]
			else
				data = self.showSpiritSet[self.clickSelectIndex]
			end

			gClientToGameSceneDelegate:AskSwitchSpiritByTaskRole(data.roleId).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gLoadingManager:SwitchTeleport_TryCloseBlur()
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				SGUI.UNavigationMgr.Inst:SetLightBarColor(lightColor)
			end
		else
			SGUI.UNavigationMgr.Inst:SetLightBarColor(lightColor)
			gLoadingManager:SwitchTeleport_BeginShow(self.selectedChar)
		end

		self.selectedChar = 0
	else
		local cfg = FightSpiritConfig.GetConfig(gBattleSpiritMgr.currentSpiritTemplateId)
		local lightColor = Color.NewByStr(cfg.CharListTemplateBgColor)

		SGUI.UNavigationMgr.Inst:SetLightBarColor(lightColor)
	end

	self.isAskSwitch = canSwitch
end

function M:SetSelectHint()
	if not self.hintBtn then
		self.bindData.selectFxCtrl = 0

		return
	end

	local worldPos = self.hintBtn.transform.position
	local localPos = self.bindData.selectFxRootTrans.transform:InverseTransformPoint(worldPos)

	self.bindData.selectFxTrans.transform:SetLocalPosition(localPos)

	self.bindData.selectFxCtrl = 1
end

local function CAL_HEXAGON_LAYER_INITIAL_POINT_INDEX(layer)
	if layer == 1 then
		return 1
	end

	return 3 * layer * layer - 9 * layer + 8
end

local pi = math.pi
local hexagonDirectionVectorCache = {}

local function GET_HEXAGON_DIRECTION_VECTOR(dir)
	if not hexagonDirectionVectorCache[dir] then
		hexagonDirectionVectorCache[dir] = Vector3.New(math.sin((2 * dir - 1) * pi / 6), math.cos((2 * dir - 1) * pi / 6), 0)
	end

	return hexagonDirectionVectorCache[dir]
end

local hexagonVertexVectorCache = {
	Vector3.New(-1, 0, 0),
	Vector3.New(-0.5, sqrt3 / 2, 0),
	Vector3.New(0.5, sqrt3 / 2, 0),
	Vector3.New(1, 0, 0),
	Vector3.New(0.5, -sqrt3 / 2, 0),
	Vector3.New(-0.5, -sqrt3 / 2, 0)
}

local function GET_HEXAGON_VERTEX_VECTOR(x)
	return hexagonVertexVectorCache[x]
end

local function GET_LAYER_VERTEX_INDEX(index, layerInitIndex, layer)
	if layer == 1 then
		return 1
	end

	return math.floor((index - layerInitIndex) / (layer - 1)) + 1
end

local function GET_LAYER_STEPS_NUM(index, layerInitIndex, layer)
	if layer == 1 then
		return 0
	end

	return (index - layerInitIndex) % (layer - 1)
end

function M:CalHexagonLayer(index)
	local layer = 1
	local layerInitialPointIndex = CAL_HEXAGON_LAYER_INITIAL_POINT_INDEX(layer)

	if index < layerInitialPointIndex then
		return layer
	end

	while layerInitialPointIndex <= index do
		layer = layer + 1
		layerInitialPointIndex = CAL_HEXAGON_LAYER_INITIAL_POINT_INDEX(layer)
	end

	return layer - 1
end

function M:CalIndexPosition(index)
	local layer = self:CalHexagonLayer(index)
	local layerSpace = self.space * (layer - 1)
	local layerInitIndex = CAL_HEXAGON_LAYER_INITIAL_POINT_INDEX(layer)
	local layerVertexIndex = GET_LAYER_VERTEX_INDEX(index, layerInitIndex, layer)
	local layerNearestVertexX = GET_HEXAGON_VERTEX_VECTOR(layerVertexIndex).x * layerSpace
	local layerNearestVertexY = GET_HEXAGON_VERTEX_VECTOR(layerVertexIndex).y * layerSpace
	local layerDirectionVectorX = GET_HEXAGON_DIRECTION_VECTOR(layerVertexIndex).x * self.space
	local layerDirectionVectorY = GET_HEXAGON_DIRECTION_VECTOR(layerVertexIndex).y * self.space
	local layerStepsNum = GET_LAYER_STEPS_NUM(index, layerInitIndex, layer)

	return layerNearestVertexX + layerStepsNum * layerDirectionVectorX, layerNearestVertexY + layerStepsNum * layerDirectionVectorY
end

function M:CalHexagonBounding(num)
	local layer = self:CalHexagonLayer(num)
	local boundHorizontal = self.space * layer
	local boundVertical = self.space * layer * sqrt3 / 2
	self.content.rectTransform.sizeDelta = Vector2.New(boundHorizontal * 2, boundVertical * 2)
end

function M:HandleItemSize()
	self.viewOffset = self.bindData.scrollRect:GetScrollViewLocalPosition()
	local offset = self.content.transform.localPosition + self.viewOffset

	for index, btn in ipairs(self.freeListItem) do
		local offsetToViewCenter = btn.transform.localPosition + offset
		local norm = offsetToViewCenter.x * offsetToViewCenter.x + offsetToViewCenter.y * offsetToViewCenter.y

		if norm < self.minDistanceToCenter then
			self.minDistanceToCenter = norm
			self.nearestCenterItemIndex = index
		end

		if norm > self.insideWidth * self.insideWidth and norm < self.boundaryWidth * self.boundaryWidth then
			local dis = math.sqrt(norm)
			local scale = Mathf.Clamp(1 - (dis - self.insideWidth) / (self.boundaryWidth - self.insideWidth), 0, 1)
			scale = math.sqrt(scale) + 0.1

			btn.transform:SetLocalScale(scale, scale, 1)
		elseif norm <= self.insideWidth * self.insideWidth then
			btn.transform:SetLocalScale(1.1, 1.1, 1)
		elseif norm >= self.boundaryWidth * self.boundaryWidth then
			btn.transform:SetLocalScale(0, 0, 1)
		end
	end

	if Time.time - self.lastChangeTime > 0.1 then
		self.lastChangeTime = Time.time
		self.selectedIndex = self.nearestCenterItemIndex
		local data = self.showSpiritSet[self.selectedIndex]

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.hintBtn = self.freeListItem[self.selectedIndex]

			self:RefreshSelectInfo(data)
		end
	end
end
