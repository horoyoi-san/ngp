-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BackCircleSystemStore.lua
-- Decompiled from: 01921_BackCircleSystemStore.lua_effecb61e988.luajit

local MobileMenuCircleMenuConfig = LTConfig.MobileMenuCircleMenuConfig
local AtmosphereManager = LX6.Manager.AtmosphereManager
local TaskShortCutConfig = LTConfig.TaskShortCutConfig
local PanelRedDotConfig = LTConfig.PanelRedDotConfig
local MobileMenuSGuiConfig = LTConfig.MobileMenuSGuiConfig
C_BackCircleSystemStore = DefClass("C_BackCircleSystemStore", C_BackCircleSystemStore, C_BackCircleBase)
GroupName2Class.BackCircleSystemStore = C_BackCircleSystemStore
local M = C_BackCircleSystemStore

M.DefineAllVariables = function(self)
	self.SELECT_MODE = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.LEFT_MODE = {
		["2g\\xa3\\xa3\\xa2m"] = 0,
		["h\\x96\\x96\\x9d\\x97"] = 1
	}
	self.needNotifySystemControls = false
	self.sysReady = false
	self.sysFirstSelect = false
	self.sysTimeLastUpdate = 0
	self.SysTimeUpdateInterval = 30
	self.SelectIndex = 0
	self.sysRight = {}
	self.sysLeft = {}
	self.sysLeftExtra = {}
	self.sysItemMap = {}
	self.sysTaskConfigId = nil
	self.sysTaskAction = nil
	self.sysTaskIndex = 0
	self.leftExtraMode = false

	self.sysCmpFunc = function(a, b)
		return a.cfg.Rank <= b.cfg.Rank
	end

	self.RightNumIndex = 7
	self.LeftNumIndex = 9
	self.LeftExtraNumIndex = 10
	self.SYS_RIGHT_ID = 30
	self.SYS_LEFT_ID = 50
	self.LOCAL_CIRCLE_INFO_PATH = "LocalCircleInfo"
end

M.DefineAllEnumsAutoGen = function(self)
	self.sysLeftModeEnum = {
		["\\x9e"] = 1,
		["\\x9f"] = 0
	}
	self.sysSelectModeEnum = {
		["\\x99"] = 4,
		QY = 10,
		["\\x9f"] = 2,
		["\\x9a"] = 7,
		["\\x9e"] = 3,
		["\\x9b"] = 6,
		["\\x94"] = 9,
		["\\x98"] = 5,
		["\\x9c"] = 1,
		["\\x95"] = 8,
		["T-s^"] = 0
	}
	self.sysStartSelectEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.sysTimeCtrlEnum = {
		["\\xdc\\xd5!\\xf5"] = 1,
		["\\xaf\\xb8\\xaah2\\xfb7"] = 0
	}
	self.sysTaskCtrlEnum = {
		["GBjh[Ch"] = 10,
		["\\xaf\\xb4\\xaa2\\xeaa"] = 2,
		["\\xaf\\xb4\\xaa2\\xeak"] = 8,
		["\\xaf\\xb4\\xaa2\\xea`"] = 3,
		["\\xaf\\xb4\\xaa2\\xeaj"] = 9,
		["\\xaf\\xb4\\xaa2\\xeac"] = 0,
		["\\xaf\\xb4\\xaa2\\xeae"] = 6,
		["\\xaf\\xb4\\xaa2\\xeab"] = 1,
		["\\xaf\\xb4\\xaa2\\xead"] = 7,
		["\\xaf\\xb4\\xaa2\\xeag"] = 4,
		["\\xaf\\xb4\\xaa2\\xeaf"] = 5
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.sysLeftModeEnum = nil
	self.sysSelectModeEnum = nil
	self.sysStartSelectEnum = nil
	self.sysTimeCtrlEnum = nil
	self.sysTaskCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.InitSystemMenu(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.TASK_SHORTCUT_CHANGE] = self.CreateAction(self, "OnTaskShortcutChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.sysCloseBtnPC.luaClick = self.CreateAction(self, "CloseCircleNoEvent")
	self.bindData.sysCloseBtnPad.luaClick = self.CreateAction(self, "CloseCircleNoEvent")
	self.bindData.sysConfirmBtnPC.luaClick = self.CreateAction(self, "CloseCircle")
	self.bindData.sysConfirmBtnPad.luaClick = self.CreateAction(self, "CloseCircle")
	self.bindData.sysMouseMoveRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMouseMove")
	self.bindData.sysRightStickRespond.luaGamePadInputChanged = self.CreateAction(self, "OnStickMove")
	self.bindData.sysFeedbackBtn.luaClick = self.CreateAction(self, "OnFeedbackBtnClick")
	self.bindData.sysSurveyBtn.luaClick = self.CreateAction(self, "OnSurveyBtnClick")
	self.bindData.sysChatBtn.luaClick = self.CreateAction(self, "OnChatBtnClick")
	self.bindData.sysCarSummonBtn.luaClick = self.CreateAction(self, "OnCarSummonBtnClick")
	self.bindData.sysMilkVehicleBtn.luaClick = self.CreateAction(self, "OnMilkVehicleBtnClick")
end

M.RefreshSystemStuntState = function(self)
	local state = gUIFunctionStateManager:GetFeedbackEnable()[1]

	self.bindData.sysFeedbackBtn:SetActive(state)

	state = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Survey)

	self.bindData.sysSurveyBtn:SetActive(state)

	state = gUIFunctionStateManager:GetChatEnable()[1]

	self.bindData.sysChatBtn:SetActive(state)
end

M.OnFeedbackBtnClick = function(self)
	if not self.localCircleInfo.FeedbackShowOnce then
		self.localCircleInfo.FeedbackShowOnce = true
		self.needSave = true
		self.needNotifySystemControls = true
	end

	gMainPhoneFunctionAction.OpenFeedback()
end

M.OnSurveyBtnClick = function(self)
end

M.OnChatBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.SOCIAL_CHAT_HOME_PANEL)
end

M.OnCarSummonBtnClick = function(self)
	if not gCallPhoneUtils.CheckCallCarEnable() then
		return
	end

	self.CallCarCircleTrigger(self)
end

M.OnMilkVehicleBtnClick = function(self)
	if not gCallPhoneUtils.CheckMilkCarEnable() then
		return
	end

	self.MilkVehicleCircleTrigger(self)
end

M.InitSystemMenu = function(self)
	for i = 0, MobileMenuCircleMenuConfig.count - 1 do
		local cfg = MobileMenuCircleMenuConfig.LoadAt(i)

		if cfg.Id >= self.SYS_RIGHT_ID then
			if cfg.IsShow then
				self.sysRight[cfg.Id] = cfg
			end
		elseif cfg.Id >= self.SYS_LEFT_ID then
			if cfg.IsShow then
				self.sysLeft[cfg.Id] = cfg
			end
		elseif cfg.IsShow then
			self.sysLeftExtra[cfg.Id] = {
				["F\\x90\\x8c\\x8fD"] = false,
				cfg = cfg
			}
		end
	end
end

M.UpdateSystemTime = function(self, force)
	if self.sysFirstSelect and not force then
		return
	end

	if force or self.SysTimeUpdateInterval >= Time.time - self.sysTimeLastUpdate then
		self.sysTimeLastUpdate = Time.time
		local gameTime = AtmosphereManager.Instance:GetGameTime()
		local min = math.floor(gameTime / 60 % 60)
		local hour = math.floor(gameTime / 3600)
		self.bindData.sysTimeHour = gString.Format("%02d", hour)
		self.bindData.sysTimeMinute = gString.Format("%02d", min)
		self.bindData.sysTimePeriod = hour >= 12 and "am" or "pm"
	end
end

M.DefineInitVector = function(self)
	self.InitVector = Vector2.New(0, 1)
	self.EachAngle = 30
end

M.OnCircleOpen = function(self, data)
	self.localCircleInfo = data.localInfo
	self.circleOpen = true
	self.sysReady = false
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	self.needSave = false
	self.needNotifySystemControls = false
	self.sysFirstSelect = false

	self:UpdateSystemTime(true)
	self:RefreshSystemStuntState()
	self:RebuildCircleView()
end

M.OnCircleClose = function(self)
	self.circleOpen = false

	if self.needSave then
		self.needSave = false

		gUIUtils:SaveLuaTableToJsonWithPid(self.LOCAL_CIRCLE_INFO_PATH, self.localCircleInfo)
	end

	if self.needNotifySystemControls then
		self.needNotifySystemControls = false

		gStoreManager:GetStoreGroup("CoreHudSystemControlStore"):RefreshHighlightAnimeState()
	end

	table.clear(self.sysItemMap)
end

M.CloseTrigger = function(self)
	local item = self.sysItemMap[self.SelectIndex]

	if item and item.cfg and item.enable then
		if self.leftExtraMode then
			if self.SelectIndex ~= 8 or self.SelectIndex ~= 9 then
				self.bindData["sysBtnEx" .. self.SelectIndex]:LuaSimulateClick()
			else
				self.bindData["sysBtn" .. self.SelectIndex]:LuaSimulateClick()
			end
		else
			self.bindData["sysBtn" .. self.SelectIndex]:LuaSimulateClick()
		end

		if self.SelectIndex ~= self.sysTaskIndex and self.sysTaskAction then
			gDialogAction:RunCodeByTask(self.sysTaskAction)
		elseif item.cfg.AppId <= 0 then
			self.AppCircleTrigger(self, item.cfg)
		else
			self[item.cfg.Circle .. "CircleTrigger"](self, item.cfg)
		end
	end
end

M.DoUpdate = function(self)
	self.UpdateArrowSelect(self)
	self.UpdateSystemTime(self)
end

M.UpdateArrowSelect = function(self)
	if self.updateSelect then
		self.UpdateSmoothMoveVector(self)

		local index, angle = self.GetArrowSelect(self, self.moveVector)

		if (self.bindData.sysStartSelect ~= nil or self.bindData.sysStartSelect ~= self.SELECT_MODE.FALSE) and not self.sysFirstSelect then
			self.sysFirstSelect = true
			self.bindData.sysTimeCtrl = 0
		end

		self.bindData.sysStartSelect = self.SELECT_MODE.TRUE
		self.bindData.sysSelectMode = index
		self.bindData.sysArrowAngle = -angle
		self.SelectIndex = index
		local item = self.sysItemMap[index]

		if item and item.enable then
			self.bindData.sysTitle = item.cfg.Name
			self.bindData.sysTextInfo = item.cfg.Description

			if item.enable and not item.glowed and item.cfg.IsShowGuide then
				item.glowed = true
				self.bindData["sysGlow" .. index] = false
				self.localCircleInfo["SysCircle." .. item.cfg.Circle .. ".Glowed"] = true
				self.needSave = true
			end
		else
			self.bindData.sysTitle = ""
			self.bindData.sysTextInfo = ""
		end
	end
end

M.GetArrowSelect = function(self, moveVector)
	local angle = self.CalculateAngle(self, self.InitVector, moveVector)
	local calAngle = angle + self.EachAngle / 2

	if angle >= 0 then
		angle = angle + 360
	end

	if calAngle >= 0 then
		calAngle = calAngle + 360
	end

	local index = math.floor(calAngle / self.EachAngle) + 1

	if index >= 8 then
		return index, angle
	end

	if self.leftExtraMode then
		if index <= 8 and index >= 12 then
			return 19 - index, angle
		end
	else
		calAngle = calAngle - self.EachAngle / 2
		index = math.floor(calAngle / self.EachAngle) + 1

		if index <= 8 and index >= 11 then
			return 18 - index, angle
		end
	end

	return 0, angle
end

M.RebuildCircleView = function(self)
	self.SelectIndex = 0

	self:RefreshSystemCircle()

	self.bindData.sysSelectMode = self.SelectIndex
	self.bindData.sysStartSelect = self.SELECT_MODE.FALSE
	self.bindData.sysTimeCtrl = self.sysFirstSelect and 0 or 1
	self.bindData.sysTitle = ""
	self.bindData.sysTextInfo = ""

	self:ClearSmoothMove()
	self:ResetMoveVector()
end

M.RefreshSystemCircle = function(self)
	if self.sysReady then
		return
	end

	self.sysItemMap = {}
	self.sysTaskIndex = 0
	self.leftExtraMode = false
	local curRight = {}
	local checkTask = false

	if self.sysTaskConfigId and self.sysRight[self.sysTaskConfigId] then
		checkTask = true
	end

	for id, cfg in pairs(self.sysRight) do
		if cfg.AppId <= 0 then
			table.insert(curRight, {
				cfg = cfg,
				enable = self.AppCheckEnable(self, cfg),
				glowed = self.localCircleInfo["SysCircle." .. cfg.Circle .. ".Glowed"]
			})
		elseif not self[cfg.Circle .. "CheckEnable"] then
			print_error(cfg.Circle, "功能还没实现，请找策划解决@shaoyunsa")
		else
			table.insert(curRight, {
				cfg = cfg,
				enable = self[cfg.Circle .. "CheckEnable"](self, cfg),
				glowed = self.localCircleInfo["SysCircle." .. cfg.Circle .. ".Glowed"]
			})
		end
	end

	table.sort(curRight, self.sysCmpFunc)

	for i = #curRight, 8, -1 do
		table.remove(curRight, i)
	end

	if checkTask then
		for i = 1, #curRight do
			if curRight[i].cfg.Id ~= self.sysTaskConfigId then
				self.sysTaskIndex = i

				break
			end
		end
	end

	checkTask = false

	if self.sysTaskConfigId and self.sysLeft[self.sysTaskConfigId] then
		checkTask = true
	end

	local curLeft = {}

	for id, cfg in pairs(self.sysLeft) do
		if cfg.AppId <= 0 then
			table.insert(curLeft, {
				cfg = cfg,
				enable = self.AppCheckEnable(self, cfg),
				glowed = self.localCircleInfo["SysCircle." .. cfg.Circle .. ".Glowed"]
			})
		elseif not self[cfg.Circle .. "CheckEnable"] then
			print_error(cfg.Circle, "功能还没实现，请找策划解决@shaoyunsa")
		else
			table.insert(curLeft, {
				cfg = cfg,
				enable = self[cfg.Circle .. "CheckEnable"](self, cfg),
				glowed = self.localCircleInfo["SysCircle." .. cfg.Circle .. ".Glowed"]
			})
		end
	end

	table.sort(curLeft, self.sysCmpFunc)

	for i = #curLeft, 3, -1 do
		table.remove(curLeft, i)
	end

	if checkTask then
		for i = 1, #curLeft do
			if curLeft[i].cfg.Id ~= self.sysTaskConfigId then
				self.sysTaskIndex = self.RightNumIndex + i

				break
			end
		end
	end

	checkTask = false

	for i = 1, self.RightNumIndex do
		table.insert(self.sysItemMap, curRight[i] or false)
	end

	for i = self.RightNumIndex + 1, self.LeftNumIndex do
		table.insert(self.sysItemMap, curLeft[i - self.RightNumIndex] or false)
	end

	if self.sysTaskConfigId and self.sysLeftExtra[self.sysTaskConfigId] then
		checkTask = true
	end

	if checkTask then
		local cfg = self.sysLeftExtra[self.sysTaskConfigId]

		if cfg.AppId <= 0 then
			table.insert(self.sysItemMap, {
				cfg = cfg,
				enable = self.AppCheckEnable(self, cfg),
				glowed = self.localCircleInfo["SysCircle." .. cfg.Circle .. ".Glowed"]
			})

			self.leftExtraMode = true
			self.sysTaskIndex = self.LeftExtraNumIndex
		elseif not self[cfg.Circle .. "CheckEnable"] then
			print_error(cfg.Circle, "功能还没实现，请找策划解决@shaoyunsa")
			table.insert(self.sysItemMap, false)
		else
			table.insert(self.sysItemMap, {
				cfg = cfg,
				enable = self[cfg.Circle .. "CheckEnable"](self, cfg),
				glowed = self.localCircleInfo["SysCircle." .. cfg.Circle .. ".Glowed"]
			})

			self.leftExtraMode = true
			self.sysTaskIndex = self.LeftExtraNumIndex
		end
	else
		table.insert(self.sysItemMap, false)
	end

	for i = 1, #self.sysItemMap do
		local item = self.sysItemMap[i]

		self.OnRenderSysCircleItem(self, i, item)
	end

	self.bindData.sysLeftMode = self.leftExtraMode and self.LEFT_MODE.EXTRA or self.LEFT_MODE.NORMAL
	self.bindData.sysTaskCtrl = self.sysTaskIndex

	if self.sysTaskIndex <= 0 then
		local taskIconId = 0
		local cfg = LTConfig.TaskConfig.GetConfig(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])

		if cfg then
			taskIconId = gTaskManager.TaskSIconId[cfg.Title]
		end

		self.bindData["sysTaskIcon" .. self.sysTaskIndex] = taskIconId
	end

	self.sysReady = true
end

M.OnRenderSysCircleItem = function(self, index, item)
	if item and item.cfg then
		local redCfg = nil
		local redDotKey = ""
		local mobileMenuSGuiCfg = LTConfig.MobileMenuSGuiConfig.GetConfig(item.cfg.AppId)

		if mobileMenuSGuiCfg then
			redCfg = PanelRedDotConfig.GetConfig(mobileMenuSGuiCfg.RedDotId)
		end

		if redCfg then
			self.bindData["sysRedId" .. index] = item.enable and mobileMenuSGuiCfg.RedDotId or 0
		else
			if item.enable and item.cfg.AppId <= 0 then
				redDotKey = ("PhoneAppItemRedDot:%d"):format(item.cfg.AppId)
			end

			self.bindData["sysRedKey" .. index] = redDotKey
		end

		self.bindData["sysIcon" .. index] = item.cfg.Icon
		self.bindData["sysGlow" .. index] = item.enable and not item.glowed and item.cfg.IsShowGuide
		self.bindData["sysGuide" .. index] = item.cfg.GuideId or ""

		if self.leftExtraMode then
			if index ~= 8 or index ~= 9 then
				self.bindData["sysBtnEx" .. index].interactable = item.enable
			else
				self.bindData["sysBtn" .. index].interactable = item.enable
			end
		else
			self.bindData["sysBtn" .. index].interactable = item.enable
		end
	else
		self.bindData["sysIcon" .. index] = 0
		self.bindData["sysRedKey" .. index] = ""
		self.bindData["sysGlow" .. index] = false
		self.bindData["sysGuide" .. index] = ""

		if self.leftExtraMode then
			if index ~= 8 or index ~= 9 then
				self.bindData["sysBtnEx" .. index].interactable = false
			else
				self.bindData["sysBtn" .. index].interactable = false
			end
		else
			self.bindData["sysBtn" .. index].interactable = false
		end
	end
end

M.AppCheckEnable = function(self, cfg)
	return gMainPhoneUtils.CheckAppCanShow(cfg.AppId)
end

M.RoleCheckEnable = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.LingListId)
end

M.TaskCheckEnable = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.TaskId)
end

M.BagCheckEnable = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.PackageId) and gUIFunctionStateManager:GetPackageEnable()[2]
end

M.YanjieCheckEnable = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.SocialNetworkId)
end

M.PhoneCheckEnable = function(self)
	return gUIFunctionStateManager:GetPhoneEnable()[2] and gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.CallPhoneId) and gMainPhoneUtils.CheckAppCanInteractable(MobileMenuSGuiConfig.CallPhoneId)
end

M.MessageCheckEnable = function(self, cfg)
	return gMainPhoneUtils.CheckAppCanShow(cfg.AppId)
end

M.CameraCheckEnable = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.TakePhotoId)
end

M.PhotoCheckEnable = function(self)
	return true
end

M.MilkVehicleCheckEnable = function(self)
	return gCoreHudUIManager:GetBattleSkillInteractable(gCoreHudUIManager.skillType.MilkCar)
end

M.CallCarCheckEnable = function(self)
	return gCoreHudUIManager:GetBattleSkillInteractable(gCoreHudUIManager.skillType.PhoneCall)
end

M.InteractionCheckEnable = function(self)
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.HUDPlayerMotionEntrance)
end

M.ScanCheckEnable = function(self)
	return gUIFunctionStateManager:GetScanEnable()[2]
end

M.TalentTreeCheckEnable = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.TalentTreeId)
end

M.GuideCheckEnable = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.TeachingId)
end

M.BubbleCheckEnable = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.SocialMediaId)
end

M.ChatCheckEnable = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.ChatId)
end

M.OnlineCheckEnable = function(self, cfg)
	return gMainPhoneUtils.CheckAppCanShow(cfg.AppId)
end

M.AppCircleTrigger = function(self, cfg)
	gMainPhoneUtils.OnAppItemClick(cfg.AppId)
end

M.RoleCircleTrigger = function(self)
	gUIFunctionStateManager:OpenXuWei()
end

M.TaskCircleTrigger = function(self)
	gUIFunctionStateManager:OpenTaskList()
end

M.BagCircleTrigger = function(self, cfg)
	gUIFunctionStateManager:OpenPackage()
	gMainPhoneUtils.OnAppItemClick(cfg.AppId)
end

M.YanjieCircleTrigger = function(self)
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.SocialNetworkId)
end

M.PhoneCircleTrigger = function(self)
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.CallPhoneId)
end

M.CameraCircleTrigger = function(self)
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.TakePhotoId)
end

M.PhotoCircleTrigger = function(self)
	gUIUtils:CommonShowPhoto({
		["\\xd0\\xd6\r\\xf5"] = 0
	})
end

M.MilkVehicleCircleTrigger = function(self)
	gCallPhoneUtils.OnMilkCarSummonBtnClick()
end

M.CallCarCircleTrigger = function(self)
	gCallPhoneUtils.OnCarSummonBtnClick()
end

M.InteractionCircleTrigger = function(self)
	return gMainPhoneFunctionAction.OpenCharMotionPanel()
end

M.ScanCircleTrigger = function(self)
	gUIFunctionStateManager:Scan()
end

M.TalentTreeCircleTrigger = function(self)
	return gUIFunctionStateManager:TalentTreeOpenTrigger()
end

M.GuideCircleTrigger = function(self)
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.TeachingId)
end

M.BubbleCircleTrigger = function(self)
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.SocialMediaId)
end

M.MessageCircleTrigger = function(self)
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.MessageId)
end

M.ChatCircleTrigger = function(self)
	return gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.ChatId)
end

M.OnlineCircleTrigger = function(self, cfg)
	return gMainPhoneUtils.OnAppItemClick(cfg.AppId)
end

M.OnTaskShortcutChange = function(self, eventId, data)
	local isShow = data.isShow or false
	local preCfgId = self.sysTaskConfigId

	if isShow then
		local NewValue = data.NewValue
		local cfgId = data.cfgId

		if not NewValue then
			if data.pcKeyId ~= 164 then
				cfgId = 1
			elseif data.pcKeyId ~= 8 then
				cfgId = 2
			elseif data.pcKeyId ~= 165 then
				cfgId = 3
			elseif data.pcKeyId ~= 168 then
				cfgId = 4
			else
				cfgId = 1
			end
		end

		local inputCfg = TaskShortCutConfig.GetConfig(cfgId)

		if not inputCfg then
			self.sysTaskConfigId = nil
			self.sysTaskAction = nil
		else
			self.sysTaskConfigId = inputCfg.CircleId
			self.sysTaskAction = inputCfg.Action
		end
	else
		self.sysTaskConfigId = nil
		self.sysTaskAction = nil
	end

	self.sysReady = self.sysReady and preCfgId ~= self.sysTaskConfigId

	if self.STATE_EnableOnce and self.circleOpen and not self.sysReady then
		self.RefreshSystemCircle(self)
		self.RebuildCircleView(self)
	end
end
