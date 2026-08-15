local LayerConstants = LX6.Constants.LayerConstants
local M = {
	lingDetailsCount = 0,
	IsShowCardAndSkill = false,
	dialogNextCanClickTime = 0,
	TYPE_ALL_GOLD = 3,
	useNewModel = false,
	TYPE_UNBIND_MONEY = 2,
	packageSortCDStartTime = 0,
	isInCameraFocus = false,
	useMainCircleMenu = true,
	roomMapSceneId = 0,
	isDrinkNpcShowDialog = false,
	cardShowDoubleUI = false,
	drinkNpcId = 0,
	isClickGuildMask = false,
	showQuestPanelNewTask = false,
	TYPE_ALL_MONEY = 1,
	defaultFocalPoint = 4,
	autoDoTaskId = 0,
	drinkNpcCultivationId = 0,
	LOCAL_OPENED_PANEL_PATH = "OpenedPanel",
	isShowTaskPanelHint = false,
	dialogEndCanNpcTalkNextTime = 0,
	DIALOG_END_CAN_NPC_TALK_NEXT_CD = 0.5,
	showQuestPanelWhenSwitchScene = false,
	countTime = 0,
	changePeaceAreaMsgCDTime = 0,
	canClickTopMenuExtend = true,
	isShowDrinkNpcDialog = false,
	isMenuAniPlayed = false,
	CAMERA_EFFECT_TIME = 0.5,
	dialogEndWithBlack = false,
	TYPE_UNBIND_GOLD = 4,
	CHANGE_PEACE_AREA_CD = 2,
	showSpriteMsgDelay = 0,
	lastVoiceEffect = 0,
	waitShowXiaoQianHint = 0,
	ShopAlwaysShowAnimation = false,
	isPlayXiaoAni = false,
	LastDialogBranchSelect = 0,
	alwaysShowCardAndSkill = false,
	npcDialogStart = false,
	currentNavData = {},
	gainLingEffectList = {},
	recordDilaogCutscenes = {},
	recordSelections = {},
	CommonFilterSaveInfo = {},
	enemyRouteEffect = {
		isPlaying = false,
		effectData = {}
	},
	choujiangData = {
		drawCount = 0
	},
	needUnlockPanel = {},
	takePhotoFocusUnit = {},
	Init = function (self)
		gMessageManager:RegisterEventHandlers(self.eventHandle)

		self.OpenedPanelTable = gUIUtils:LoadJsonToLuaTable(self.LOCAL_OPENED_PANEL_PATH) or {}
	end,
	OnBeforeSwitchScene = function (self, switchType)
		if gSwitchSceneType.Image <= switchType then
			if self.hpPanel2 then
				self.hpPanel2:DestroyAll()
			end

			self.gainLingEffectList = {}
			self.npcPre = nil
			self.npcFacingDirectionPre = nil
			self.dialogToPos = nil
			self.lastVoiceEffect = 0
			self.sceneNpcList = nil
			self.currentNavData = {}

			if self.delaySetUIMaskTimer then
				gLuaTimeMgrUtils.CancelUnitDelay(self.delaySetUIMaskTimer)

				self.delaySetUIMaskTimer = nil
			end

			self.dialogEndWithBlack = false
			self.cardShowDoubleUI = false
			self.isInCameraFocus = false
			self.playcontrolReconnectData = nil
		end

		if switchType == gSwitchSceneType.KickToLogin then
			self.isClickGuildMask = false

			self:SetCircleMenuEnable(true)

			self.waitShowXiaoQianHint = 0
			self.isMenuAniPlayed = false
			self.packageSelectItemId = 0
			self.autoDoTaskId = 0

			if self.quickMenuPanel then
				self.quickMenuPanel.isExtend = false
			end

			self.needUnlockPanel = {}
			self.mjMatchTimestamp = nil
			self.promptQueue = nil
		end
	end,
	SetCircleMenuEnable = function (self, isEnable)
		self.useMainCircleMenu = isEnable

		if self.quickMenuPanel then
			self.quickMenuPanel.OnCircleMenuEnableChange(isEnable)
		end
	end
}
M.eventHandle = {
	[gEventConstants.PANEL_ON_CLOSE] = function (eventId, data)
		local panelID = data

		M:OnEnterGamePromptClose(panelID)
	end,
	[gEventConstants.DIALOG_START] = function ()
		M.recordDilaogCutscenes = {}
	end,
	[gEventConstants.DIALOG_INTERRUPT] = function ()
		if gCS.LightSettings.Instance then
			gCS.LightSettings.Instance:CoverColorIntensity(false, 1)
		end

		gCS.CameraDataMgr.forceShaderLOD_High = false
	end,
	[gEventConstants.AFTER_SWITCH_SCENE] = function (eventId, switchType)
		if switchType == gSwitchSceneType.NewScene then
			M.changePeaceAreaMsgCDTime = Time.time + M.CHANGE_PEACE_AREA_CD

			if gGameManager.Env.isEditor then
				gCS.LuaUtils.ForceUpdateAllUIAnchor()
			end
		end
	end,
	[gEventConstants.LOADING_FINISHED] = function (eventId, switchType)
		if gSwitchSceneType.Image <= switchType then
			M:ShowEnterGamePrompt()
		end
	end,
	[gEventConstants.ON_PLAYER_NAV_END] = function ()
		M.currentNavData = {}
	end,
	[gEventConstants.PANEL_ON_SHOW] = function (eventId, data)
		if gRaidDataManager.RaidId > 0 and gGFManager:IsUIMask() and gGFManager.CanClickInGuidePanelIds[data] then
			local go = gLuaDataManager.guiMgr.panelCache:GetUICacheObject(data)

			if go then
				SGUITools.SetLayer(go, LayerConstants.Default)
			end
		end
	end,
	[gEventConstants.MAP_CHANGE_ROOM_MAP] = function (eventId, data)
		M.roomMapSceneId = data
	end,
	[gEventConstants.ATMOSPHERE_SWITCH] = function ()
		return
	end,
	[gEventConstants.CONFIG_HOT_FIX] = function (eventId, data)
		M.dialogCutsceneHideUnitDic = nil
	end,
	[gEventConstants.SHOP_ANIMATION_ALWAYS_SHOW] = function ()
		M.ShopAlwaysShowAnimation = true
	end
}

function M:AddEnterGamePrompt(panelID, data, index, filterFunc, cb)
	local promptQueue = self.promptQueue

	if promptQueue == nil then
		promptQueue = {}
		self.promptQueue = promptQueue
	end

	for i = 1, #promptQueue do
		local chunk = promptQueue[i].data

		if chunk[1] == panelID then
			chunk[2] = data

			return
		end
	end

	promptQueue[#promptQueue + 1] = {
		index = index,
		data = {
			panelID,
			data
		},
		filterFunc = filterFunc,
		cb = cb
	}

	table.sort(promptQueue, function (a, b)
		return a.index < b.index
	end)
end

function M:RemoveEnterGamePromptPanelID(panelID)
	local promptQueue = self.promptQueue

	if promptQueue == nil then
		return
	end

	for i = 1, #promptQueue do
		local chunk = promptQueue[i].data

		if chunk[1] == panelID then
			table.remove(promptQueue, i)

			return
		end
	end
end

function M:OnEnterGamePromptClose(panelID)
	local promptQueue = self.promptQueue

	if promptQueue == nil or #promptQueue == 0 then
		return
	end

	local head = promptQueue[1].data

	if head[1] ~= panelID then
		return
	end

	table.remove(promptQueue, 1)

	if #promptQueue > 0 then
		self:ShowEnterGamePrompt()
	else
		gMessageManager:SendMessage(gEventConstants.ENABLE_BARRAGE, true)
	end
end

function M:ShowEnterGamePrompt()
	local promptQueue = self.promptQueue

	if promptQueue == nil or #promptQueue == 0 then
		gMessageManager:SendMessage(gEventConstants.ENABLE_BARRAGE, true)

		return
	end

	if promptQueue[1].filterFunc and promptQueue[1].filterFunc() ~= true then
		table.remove(promptQueue, 1)

		if #promptQueue > 0 then
			self:ShowEnterGamePrompt()
		else
			gMessageManager:SendMessage(gEventConstants.ENABLE_BARRAGE, true)
		end

		return
	end

	local head = promptQueue[1].data

	if head[1] > 0 then
		gPanelManager:CheckShow(head[1], head[2])
	end

	if promptQueue[1].cb then
		promptQueue[1].cb()
		table.remove(promptQueue, 1)
	end
end

function M:GetLockUITrans(panelId, rootName)
	if gLuaUIMgr.ui_panel_Livehouse_GamePanel then
		return gLuaUIMgr.ui_panel_Livehouse_GamePanel.bindData.effectLockTransform
	end

	return nil
end

function M:CheckPhotoTaskExit(taskId)
	return self.takePhotoFocusUnit[taskId] ~= nil
end

function M:CheckPhotoTaskFinish(taskId, uniqueId)
	if not self.takePhotoFocusUnit[taskId] then
		return false
	end

	return self.takePhotoFocusUnit[taskId][uniqueId] ~= nil
end

function M:SetTransparentMask(val)
	if gLuaUIMgr.delaySetUIMaskTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(gLuaUIMgr.delaySetUIMaskTimer)

		gLuaUIMgr.delaySetUIMaskTimer = nil
	end

	if val == 0 then
		gLuaUIMgr.delaySetUIMaskTimer = gLuaTimeMgrUtils.Delay(function ()
			gGFManager:SetTouchMask(true, gTouchMaskId.SERVER_CUSTOM_DATA)

			gLuaUIMgr.delaySetUIMaskTimer = nil
		end, 1)
	elseif val == 1 then
		gGFManager:SetTouchMask(false, gTouchMaskId.SERVER_CUSTOM_DATA)
	end
end

gLuaUIMgr = M
