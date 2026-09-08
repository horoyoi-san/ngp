-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Dialog\DialogBasePanelStore.lua
-- Decompiled from: 01203_DialogBasePanelStore.lua_b1b2177dad6f.luajit

local GameInputManager = LX6.Manager.GameInputManager
local CS_DialogSGUIUtils = L18.Script.LX6.Dialog.DialogSGUIUtils
local TaskTitleConfig = LTConfig.TaskTitleConfig
C_DialogBasePanelStore = DefClass("C_DialogBasePanelStore", C_DialogBasePanelStore, C_StoreGroup)
GroupName2Class.DialogBasePanelStore = C_DialogBasePanelStore
local M = C_DialogBasePanelStore

M.ctor = function(self)
	self.scaleMax = 1
	self.scaleMin = -1
	self.zoomFactor = 15
	self.DialogContent = nil
	self.DialogComponents = {
		["K\\xad{C\\xb5\\xd0Ukt}D"] = 4,
		["wSϱ\\x8b\\x90\r\\xc7\\xfc"] = 5,
		["&\\xea^ \\xd7?\\xb9O\\xb5S\\xbe\\xa2"] = 3,
		["&\\xea^ \\xd7N\\xe4q\\xa9Y\\xbe\\xb3"] = 7,
		["Ó\\xe0\\xd6\\xe5\\x86\\xe8\\x96)8"] = 6,
		["&\\xea^ \\xd7N\\xe7q\\xa9Y\\xbe\\xb3"] = 8,
		["&\\xea^ \\xd7,\\xbfB\\xb5C\\xa2\\xb3"] = 2
	}
	self.InteractionTypes = {
		[23.0] = 2,
		[10.0] = 3,
		[15.0] = 4,
		[22.0] = 5,
		[8.0] = 6,
		[13.0] = 7,
		[21.0] = 1,
		[14.0] = 0
	}
	self.IsBindListener = false
	self.InteractionTabIconId = {
		[28002471.0] = 1,
		[28017280.0] = 0
	}
end

M.OnAwake = function(self)
	self.ScrollWheel = self.CreateAction(self, "OnMouseScrollWheel")

	if not self.EventHandler then
		self.EventHandler = {
			[gEventConstants.DIALOG_SHOW_BRANCH] = function (eventId, dialogId)
				if self:CheckComponent(self.DialogComponents.DialogBranch) and dialogId ~= self.dialogId then
					self:ShowBranch(true)
				end
			end,
			[gEventConstants.DIALOG_REFRESH_CONTROLLER] = function (eventId, param)
				if self.refreshNextFunc and self.DialogContent then
					self.refreshNextFunc(param.ToTable(param))
				end
			end
		}
	end

	self.startTime = gLogicTime.time
	self.isBranchShow = true

	self.BindListener(self)
end

M.OnActiveDeviceChange = function(self, device)
	if not self.branches then
		return
	end

	for i = 1, #self.branches do
		local data = self.branches[i]

		if not data.btn then
			return
		end

		local store = self:GetDialogComponentStore(data.btn)

		store.pcBtn:SetActive(gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() and data.btn.isSelected and gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.KeyboardMouse)

		store.pcBtn.luaClick = self:CreateActionWithArgs("OnBranchBtnClick", i - 1)

		if self.bindData.IsInteraction ~= 0 then
			self.SetNormalBranchIcon(self, store, data)
		end
	end
end

M.BindListener = function(self)
	if not self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end

		self.mouseScrollCallback = self.CreateAction(self, "OnMouseScroll")

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.ScrollWheel)
		end

		self.IsBindListener = true
	end
end

M.UnbindListener = function(self)
	if self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:RemoveMessageListener(i, v)
		end

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.ScrollWheel)
		end

		self.IsBindListener = false
	end
end

M.OnEnable = function(self)
end

M.OnDisable = function(self)
	self.OnDisable_Contents(self)
end

M.ResetData = function(self)
	self.BanBranchClickTimer = 0
	self.branches = {}
	self.refreshNextFunc = nil
	self.updateFunc = {}
	self.activatedComponent = {}
	self.Tags = nil
	self.DialogBranch = nil
	self.contentText = nil
end

M.OnShow = function(self, panelId, rawdata)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("DialogBasePanelStore:OnShow")
	end

	self.panelId = panelId
	self.isMini = false
	gDialogManager.openedPanels[panelId] = self

	self.SelectDialogContent(self)
	self.SelectDialogContents(self)
	self.RefreshPanel(self, rawdata)
	self.InitContents(self)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.RefreshPanel = function(self, rawdata)
	if not rawdata then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("DialogBasePanelStore:RefreshPanel")
	end

	self.ResetData(self)

	if rawdata.Tags and type(rawdata.Tags) == "table" then
		self.Tags = rawdata.Tags:ToTable()
	else
		self.Tags = rawdata.Tags
	end

	self:InitInfos(rawdata)

	local hasCallInTag = self.Tags and table.contains(self.Tags, "CallIn")

	if self.dialogId and not hasCallInTag then
		gMessageManager:SendMessage(gEventConstants.DIALOG_SHOW_FINISH, self.dialogId)
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.OnDialogDurationChanged = function(self, newDuration)
	self.dialogBranchTime = newDuration
end

M.OnUpdate = function(self)
	if not self.updateFunc then
		return
	end

	for i, v in pairs(self.updateFunc) do
		v()
	end

	self.UpdateContents(self)
end

M.OnClose = function(self)
	self:UnbindListener()
	self:ResetData()

	self.refreshBtnFunc = nil
	gDialogManager.openedPanels[self.panelId] = nil

	gMessageManager:SendMessage(gEventConstants.DIALOG_CLOSE_PANEL, self.dialogId)
end

M.GetDialogComponentStore = function(self, widget)
	if not widget then
		return nil
	end

	return gStoreManager:GetStoreGroup("S_DialogComponentStore"):GetStoreByWidget(widget)
end

M.InitInfos = function(self, data)
	self.dialogId = data.DialogId
	self.nodeId = data.NodeId
	self.dialogType = data.DialogType

	self.InitDialogComponent(self, data)
end

M.SelectDialogContent = function(self)
	if not self.bindData.pcDialogContent or not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.DialogContent = self.bindData.DialogContent

		if self.bindData.pcDialogContent then
			self.bindData.pcDialogContent:SetActive(false)
		end
	else
		self.DialogContent = self.bindData.pcDialogContent

		self.bindData.DialogContent:SetActive(false)
	end
end

M.SelectDialogBranch = function(self, data)
	if data.IsInteraction and self.bindData.DialogBranch_Interaction then
		self.bindData.IsInteraction = 1
		self.DialogBranch = self.bindData.DialogBranch_Interaction

		if self.bindData.DialogBranch then
			self.bindData.DialogBranch:SetActive(false)
		end
	else
		self.bindData.IsInteraction = 0
		self.DialogBranch = self.bindData.DialogBranch

		if self.bindData.DialogBranch_Interaction then
			self.bindData.DialogBranch_Interaction:SetActive(false)
		end
	end
end

M.InitDialogComponent = function(self, data)
	self.bindData.InteractionType = self.InteractionTypes[data.DialogType]

	self.SelectDialogBranch(self, data)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("DialogBasePanelStore:InitContent")
	end

	if self.DialogContent then
		self.contentText = self.ConcatLeftNameAndMessage(self, data)

		self.InitContent(self, self.DialogContent, data)
		table.insert(self.activatedComponent, self.DialogContent)
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("DialogBasePanelStore:InitBranch")
	end

	if self.DialogBranch then
		if data.Branch_Valid then
			self.InitBranch(self, self.DialogBranch, data)
			table.insert(self.activatedComponent, self.DialogComponents.DialogBranch)
		else
			self.ShowBranch(self, false)
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.InitPicture = function(self, widget, InvestigatePhoto)
	local store = self.GetDialogComponentStore(self, widget)

	if InvestigatePhoto and InvestigatePhoto.Length > 2 then
		widget.SetActive(widget, true)

		if InvestigatePhoto[0] ~= 1 then
			store.InvestigateType = 1
			store.photoTextureId = InvestigatePhoto[1]
		else
			store.InvestigateType = 0
			store.photoIconId = InvestigatePhoto[1]
		end
	else
		store.isInvestigateDialog = false
		store.photoTextureId = 0
		store.photoIconId = 0

		widget.SetActive(widget, false)
	end
end

M.AdjustAlignmentByLines = function(self, contentText, text)
	if not contentText then
		return
	end

	slot3 = gCoroutineManager

	slot3:StartCoroutine(function ()
		local lines = CS_DialogSGUIUtils.GetLines(contentText)
		local limit = 3

		while contentText and lines >= 0 and limit <= 0 do
			coroutine.yield(nil)

			lines = CS_DialogSGUIUtils.GetLines(contentText)
			limit = limit - 1
		end

		if not contentText or lines >= 0 then
			return
		end

		if lines <= 1 then
			contentText.alignment = 1025
		else
			contentText.alignment = 1026
		end

		contentText.text = text
	end)
end

M.InitTitleAndShowNext = function(self, widget, data)
	local store = self.GetDialogComponentStore(self, widget)

	if not string.is_null_or_empty(data.Content_Message) then
		if string.is_null_or_empty(data.Content_Title) then
			store.showJob = 0
		else
			store.showJob = 1
			store.job = "/" .. data.Content_Title .. "/"
		end

		if store.NextButton then
			store.NextButton.luaClick = self:CreateAction("OnNextDialogClick")

			store.NextButton:SetActive(data.Content_ShowNext)
		end
	end
end

M.ConcatLeftNameAndMessage = function(self, data)
	local message = nil

	if string.is_null_or_empty(data.Content_LeftName) then
		message = data.Content_Message
	else
		message = "#IDD" .. data.Content_LeftName .. ": #Z" .. data.Content_Message
	end

	return message
end

M.InitContent = function(self, widget, data)
	if not widget then
		return
	end

	widget.SetActive(widget, true)
	self.SetMainContent(self)
end

M.OnAttachContentChanged = function(self)
	local widget = self.DialogContent

	if not widget then
		return
	end

	local finalStr = self.contentText

	if gDialogManager.attachContentText then
		if finalStr then
			finalStr = gDialogManager.attachContentText .. finalStr
		else
			finalStr = gDialogManager.attachContentText
		end
	end

	if string.is_null_or_empty(finalStr) then
		widget.SetActive(widget, false)

		return
	else
		local store = self.GetDialogComponentStore(self, widget)

		widget.SetActive(widget, true)

		store.ContentText.text = finalStr

		self.AdjustAlignmentByLines(self, store.ContentText, store.ContentText.text)
	end
end

M.IsContentBeOccupied = function(self)
	local hudVisible = gPanelManager.currVisibleMode ~= LX6.Manager.VisibleMode.HUD or gPanelManager.currVisibleMode ~= LX6.Manager.VisibleMode.All

	if not hudVisible then
		return 1
	elseif gDriveVehiclesManager:CheckPlayerMainDrive() then
		return 2
	elseif gBattleMgr:HasBattleBottomUIShow() then
		return 0
	elseif not gCS.LuaUtils.IsNonMobileAdaptive() and gCoreHudUIManager:GetBattleSkillVisible(gCoreHudUIManager.skillType.SwitchCharacterWheels) then
		return 0
	elseif not gCS.LuaUtils.IsNonMobileAdaptive() and gBattleMgr.SummonData then
		return 0
	elseif gCoreHudModeMgr.currMode ~= gCoreHudModeMgr.HUD_MODE.KESI then
		return 0
	end

	return 1
end

M.InitFreeContent = function(self, widget)
	local store = self.GetDialogComponentStore(self, widget)

	local func = function()
		local newBottom = self:IsContentBeOccupied()

		if newBottom == store.IsBottom then
			store.IsBottom = newBottom
		end
	end

	table.insert(self.updateFunc, func)
end

M.InitBranchCountDown = function(self, store, data)
	local isBranchTimeBarShow = data.Branch_ShowTime
	self.dialogBranchTime = data.DialogDuration

	if store.branchTimeBar then
		store.branchTimeBar:SetActive(isBranchTimeBarShow)
	end

	self.BanBranchClick = true
	self.ShowBranchTimer = 0
	self.BanBranchClickTimer = 0.2

	local func = function()
		if self.isBranchShow then
			if self.BanBranchClickTimer <= 0 then
				self.BanBranchClickTimer = self.BanBranchClickTimer - gLogicTime.deltaTime

				if self.BanBranchClickTimer < 0 then
					self.BanBranchClick = false
				end
			end

			if isBranchTimeBarShow then
				self.ShowBranchTimer = self.ShowBranchTimer + gLogicTime.deltaTime
				local remainTime = self.dialogBranchTime - self.ShowBranchTimer
				store.branchTimeFill = remainTime / (self.dialogBranchTime + 0.01)
				store.branchTimeText = self:GetTimeTextFromSecond(remainTime)
			end
		end
	end

	table.insert(self.updateFunc, func)
end

M.InitBranch = function(self, widget, data)
	local branchList = data.Branch_DataList
	local store = self.GetDialogComponentStore(self, widget)

	if branchList.Length ~= 0 then
		print_error("对话状态异常，无选项时进行了选项初始化")

		return
	end

	self.branchPos = data.Branch_NpcPos
	self.showBranchCmd = not data.Content_Valid
	store.ShowMouseM = true

	self.InitBranchCountDown(self, store, data)

	store.branchList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderBranchItem")
	store.branchList.luaSimpleClick = self.CreateAction(self, "OnBranchListClick")
	store.branchList.onGetTIndex = self.CreateAction(self, "OnGetTIndex_Branch")
	store.branchList.luaSelectedChanged = self.CreateAction(self, "OnSelectedChanged")
	store.branchList.luaSimpleFocus = self.CreateAction(self, "OnFocusChanged")
	self.pcKeySelectIndex = -1

	for i = 0, branchList.Length - 1 do
		if #self.branches ~= 11 then
			print_error("选项数量过多，DialogId=" .. self.dialogId)

			break
		end

		local item = branchList[i]:ToTable()
		local view = {
			text = item.BranchText,
			iconId = item.IconId,
			colorfulIcon = item.ColorfulIcon or self.bindData.IsInteraction ~= 1,
			isRecorded = item.IsRecorded,
			highlight = item.Highlight,
			index = i,
			viewIndex = item.ViewIndex
		}

		if self.pcKeySelectIndex ~= -1 and not item.isRecorded then
			self.pcKeySelectIndex = i
		end

		table.insert(self.branches, view)
	end

	if not self.DialogBranch or not store then
		return
	end

	self.ShowBranch(self, self.showBranchCmd, true)

	local func = function()
		local phoneOpened = gClientUtils.CheckMainPhoneIsShowing()

		self.DialogBranch:SetActive(self.isBranchShow and not phoneOpened)
	end

	table.insert(self.updateFunc, func)
end

M.CheckComponent = function(self, component)
	if not self.activatedComponent then
		return false
	end

	return table.contains(self.activatedComponent, component)
end

M.SetNormalBranchIcon = function(self, store, data)
	local iconId = data.iconId
	local index = data.index
	local colorful = data.colorfulIcon

	if iconId <= 0 and iconId >= 100 then
		local taskCfg = TaskTitleConfig.GetConfig(iconId)

		if not taskCfg then
			print_error("Task.Title表找不到指定Id，Id=" .. iconId)

			return
		end

		store.iconColor = Color.NewByStr(taskCfg.TaskColor)
		store.iconId = taskCfg.SQuestIcon
	else
		store.iconId = iconId

		if gCS.LuaUtils.IsNonMobileAdaptive() and data.btn.isSelected and not colorful then
			store.iconColor = Color.black
		else
			store.iconColor = Color.white
		end
	end

	if store.quickKey then
		if iconId ~= 28001861 or iconId ~= 28002743 then
			store.showQuickKey = 1
			store.quickKey.luaClick = self.CreateActionWithArgs(self, "OnBranchBtnClick", index)
		else
			store.showQuickKey = 0
		end
	end
end

M.SetInteractBranchIcon = function(self, store, data)
	local iconId = data.iconId
	local index = data.index

	if self.InteractionTabIconId[iconId] then
		store.iconType = 2
		store.AnimIconTab.selectedIndex = self.InteractionTabIconId[iconId]
	elseif iconId <= 0 and iconId >= 100 then
		store.iconType = 1
		local taskCfg = TaskTitleConfig.GetConfig(iconId)

		if not taskCfg then
			print_error("Task.Title表找不到指定Id，Id=" .. iconId)

			return
		end

		store.taskIcon = taskCfg.SQuestIcon
	else
		store.iconType = 0
		store.iconId = iconId
	end

	if store.quickKey then
		if iconId ~= 28001861 or iconId ~= 28002743 then
			store.showQuickKey = 1
			store.quickKey.luaClick = self.CreateActionWithArgs(self, "OnBranchBtnClick", index)
		else
			store.showQuickKey = 0
		end
	end
end

M.RenderNormalBranchItem = function(self, btn, index)
	local store = self.GetDialogComponentStore(self, btn)

	if not store then
		return
	end

	local data = self.branches[index + 1]
	data.btn = btn
	store.text = data.text
	store.showText = not L50.L50App.Scene.DialogManager.IsHideDialogText
	store.branchBtn.luaClick = self:CreateActionWithArgs("OnBranchBtnClick", data.index)
	store.highlight = data.highlight and 1 or 0

	store.pcBtn:SetActive(false)
	self:SetNormalBranchIcon(store, data)

	if data.isRecorded then
		store.TurnGray = 1
	else
		store.TurnGray = 0
	end
end

M.RenderInteractBranchItem = function(self, btn, index)
	local store = self.GetDialogComponentStore(self, btn)

	if not store then
		return
	end

	local data = self.branches[index + 1]
	data.btn = btn
	store.text = data.text
	store.showText = not L50.L50App.Scene.DialogManager.IsHideDialogText
	store.branchBtn.luaClick = self:CreateActionWithArgs("OnBranchBtnClick", data.index)

	store.pcBtn:SetActive(false)
	self:SetInteractBranchIcon(store, data)
end

M.OnRenderBranchItem = function(self, btn, index)
	if self.bindData.IsInteraction ~= 1 then
		self.RenderInteractBranchItem(self, btn, index)
	else
		self.RenderNormalBranchItem(self, btn, index)
	end
end

M.OnGetTIndex = function(self, index)
	return 0
end

M.OnGetTIndex_Branch = function(self, index)
	return self.branches[index + 1].viewIndex
end

M.OnBranchListClick = function(self, btn, index)
	local data = self.branches[index + 1]

	self.OnBranchBtnClick(self, data.index)
end

M.OnBranchBtnClick = function(self, index)
	if #self.branches <= 1 or self.BanBranchClick then
		return
	end

	if index <= #self.branches then
		print_error("对话选项错误，选项不存在，需要检查配置，dialogId=" .. self.dialogId)
	end

	self:ShowBranch(false)
	gMessageManager:SendMessage(gEventConstants.DIALOG_BRANCH_SELECT, {
		index = index + 1,
		dialogId = self.dialogId
	})
end

M.ShowBranchByCircle = function(self, enable)
	if not self.isBranchShow then
		return
	end

	self.DialogBranch:SetActiveFastest(enable)

	local branchStore = self:GetDialogComponentStore(self.DialogBranch)

	if branchStore and branchStore.navArea then
		branchStore.navArea.enabled = enable
	end
end

M.ShowBranch = function(self, enable, force)
	self.showBranchCmd = enable

	if self.isBranchShow ~= enable and not force then
		return
	end

	self.DialogBranch:SetActive(enable)

	local store = self:GetDialogComponentStore(self.DialogBranch)

	if enable then
		store.branchList:SetSimpleList(#self.branches)

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			FrameTimer.New(function ()
				if not self.branches then
					return
				end

				if #self.branches ~= 0 and self.branches[1].btn then
					return
				end

				self.branches[1].btn:SetSelected(true)
				self:OnSelectedChanged(store.branchList)
			end, 5):Start()
		end
	else
		store.branchList:SetSimpleList(0)
	end

	self.isBranchShow = enable
end

M.OnFocusChanged = function(self, btn, index)
	self.ManualChangeSelect(self, index)
end

M.OnSelectedChanged = function(self, list)
	for i = 1, #self.branches do
		local data = self.branches[i]

		if not data.btn then
			return
		end

		local store = self:GetDialogComponentStore(data.btn)

		store.pcBtn:SetActive(gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() and data.btn.isSelected and gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.KeyboardMouse)

		store.pcBtn.luaClick = self:CreateActionWithArgs("OnBranchBtnClick", i - 1)

		if self.bindData.IsInteraction ~= 0 then
			self.SetNormalBranchIcon(self, store, data)
		end
	end
end

M.OnMouseScrollWheel = function(self, context)
	if gCS.LuaUtils.IsInPcOrEditor() then
		if self.nextScrollTime and gLogicTime.unscaledTime >= self.nextScrollTime then
			return
		end

		if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
			return
		end

		if not self.isBranchShow or not self.branches or #self.branches ~= 0 then
			return
		end

		if context.performed then
			local zoom = context.ReadValueVector2(context).y
			local zoomResult = zoom * self.zoomFactor

			if self.scaleMax >= zoomResult then
				self.PcKeyChangeSelect(self, true)
			else
				self.PcKeyChangeSelect(self, false)
			end

			self.nextScrollTime = gLogicTime.unscaledTime + 0.1
		end
	end
end

M.PcKeyChangeSelect = function(self, isUpDir)
	if self.BanBranchClick then
		return
	end

	local newIndex = self.pcKeySelectIndex

	if isUpDir then
		if self.pcKeySelectIndex <= 0 then
			newIndex = self.pcKeySelectIndex - 1
		end
	elseif self.pcKeySelectIndex >= #self.branches - 1 then
		newIndex = self.pcKeySelectIndex + 1
	end

	self.ManualChangeSelect(self, newIndex)
end

M.ManualChangeSelect = function(self, newIndex)
	local oldSelectIndex = self.pcKeySelectIndex
	self.pcKeySelectIndex = newIndex

	if self.pcKeySelectIndex > 0 and oldSelectIndex == self.pcKeySelectIndex then
		local store = self:GetDialogComponentStore(self.DialogBranch)

		store.branchList:SetItemSelected(oldSelectIndex, false)
		store.branchList:SetItemSelected(self.pcKeySelectIndex, true)
	end
end

M.GetTimeTextFromSecond = function(self, duration)
	local minute = math.floor(duration / 60)
	local second = math.floor(duration % 60)

	return string.format("%02d:%02d", minute, second)
end

M.HideDialogContent = function(self)
	self.DialogContent:SetActive(false)
end

M.OnNextDialogClick = function(self)
	if self.banClickTimer and gLogicTime.unscaledTime >= self.banClickTimer then
		return
	end

	self.banClickTimer = gLogicTime.unscaledTime + 0.2

	gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
		["n;m^"] = 1,
		dialogId = self.dialogId
	})
end

local CONTENT_GAP = 10

M.OnRenderContentItem = function(self, btn, index, data)
	btn.SetWidgetFaraway(btn, true)
	gCS.LuaUtils.AdjustLayout(btn)

	local store = self.GetDialogComponentStore(self, btn)
	local id = self.contentIds[index + 1]

	if not id then
		return
	end

	local info = gDialogManager.contentInfos[id]

	if not info then
		return
	end

	if id ~= gDialogManager.mainDialogId and self.panelId ~= LTConfig.PanelConfig.S_DIALOG_22N_PANEL then
		self.SetAvatarAlignText(self, store)
	end

	info.widget = btn
	info.renderStage = 1
	store.ContentText.text = info.message
	store.Style = info.style

	btn.rectTransform:SetAnchoredPositionY(info.lastPosY)
	gDialogManager:Log("面板实例化内容, dialogId=" .. (info.id or 0))
end

M.SelectDialogContents = function(self)
	if self.bindData.ContentList then
		self.contentList = self.bindData.ContentList
	elseif self.DialogContent then
		local contentStore = self.GetDialogComponentStore(self, self.DialogContent)
		self.contentList = contentStore.ContentList
	end
end

M.InitContents = function(self)
	if not self.contentList then
		return
	end

	self.contents = {}
	self.contentIds = {}
	self.contentList.luaRenderItem = self.CreateAction(self, "OnRenderContentItem")
	self.contentList.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
end

M.SetMainContent = function(self)
	gDialogManager:Log("面板更新主对话, dialogId=" .. self.dialogId)
	gDialogManager:SetMainContent(self.nodeId, self.contentText)
end

M.ShouldAppearInList = function(self, info)
	return info == nil and info.stage == 0 and info.stage == 4 and info.stage == 3
end

M.GetAppearPosY = function(self, info, mainInfo)
	if info.id ~= gDialogManager.mainDialogId then
		return 0
	end

	local mainOnPanel = mainInfo and self.contents[mainInfo.id]

	if mainOnPanel and mainInfo.height <= 0 then
		return mainInfo.height + CONTENT_GAP
	end

	return 0
end

M.AddInfoToList = function(self, info, mainInfo)
	if self.contents[info.id] then
		return
	end

	local insertPos = nil

	if info.id ~= gDialogManager.mainDialogId then
		insertPos = 1
	elseif mainInfo and self.contents[mainInfo.id] then
		insertPos = 2
	else
		insertPos = 1
	end

	local appearY = self:GetAppearPosY(info, mainInfo)
	info.lastPosY = appearY
	info.targetPosY = appearY
	self.contents[info.id] = info

	table.insert(self.contentIds, insertPos, info.id)
	self.contentList:InsertElement(insertPos - 1)
	gDialogManager:Log("面板添加附加内容, dialogId=" .. info.id .. " index=" .. insertPos - 1)
end

M.RemoveInfoFromList = function(self, id)
	local _, index = table.find(self.contentIds, id)

	if not index then
		return
	end

	if self.contentList.dataCount >= index then
		print_error("对话面板content数与contentIds不匹配, dialogId=" .. id .. " index=" .. index - 1)

		return
	end

	table.remove(self.contentIds, index)
	self.contentList:RemoveElement(index - 1)

	self.contents[id] = nil

	gDialogManager:Log("面板删除附加内容, dialogId=" .. id .. " index=" .. index - 1)
end

M.SyncContentList = function(self)
	local mainInfo = gDialogManager:GetMainInfo()

	if self:ShouldAppearInList(mainInfo) then
		self.AddInfoToList(self, mainInfo, mainInfo)
	end

	for _, id in ipairs(gDialogManager.contentOrder) do
		local info = gDialogManager.contentInfos[id]

		if self.ShouldAppearInList(self, info) then
			self.AddInfoToList(self, info, mainInfo)
		end
	end

	for id, _ in pairs(self.contents) do
		if not gDialogManager.contentInfos[id] or not gDialogManager.existContentIds[id] then
			self.RemoveInfoFromList(self, id)

			break
		end
	end
end

M.RefreshRenderedItem = function(self, info)
	if info.renderStage == 1 or not info.widget then
		return
	end

	info.renderStage = 2

	self:AdjustAlignmentByLines(self:GetDialogComponentStore(info.widget).ContentText, info.message)
	info.widget:SetWidgetFaraway(false)
end

M.CheckShouldUpdateTargetPos = function(self)
	local mainInfo = gDialogManager:GetMainInfo()

	if mainInfo and mainInfo.stage >= 2 and not mainInfo.widget then
		return false
	end

	for _, info in pairs(self.contents) do
		if info.stage >= 2 and not info.widget then
			return false
		end
	end

	return true
end

M.RecalculateTargetPos = function(self)
	if not self.CheckShouldUpdateTargetPos(self) then
		return
	end

	local mainInfo = gDialogManager:GetMainInfo()
	local nextPosY = 0

	if mainInfo and mainInfo.widget and not gClientUtils.IsNil(mainInfo.widget) then
		self:RefreshRenderedItem(mainInfo)

		mainInfo.height = mainInfo.widget:GetTargetHeight()

		if mainInfo.height <= 0 then
			nextPosY = mainInfo.height + CONTENT_GAP
		end
	end

	for _, id in ipairs(gDialogManager.contentOrder) do
		local info = self.contents[id]

		if info and (info.stage ~= 1 or info.stage ~= 2) and info.widget and not gClientUtils.IsNil(info.widget) then
			self:RefreshRenderedItem(info)

			info.height = info.widget:GetTargetHeight()

			if info.height <= 0 then
				if info.targetPosY >= nextPosY and not Mathf.Approximately(nextPosY, info.targetPosY) then
					info.lastPosY = info.targetPosY
					info.targetPosY = nextPosY
				end

				nextPosY = info.targetPosY + info.height + CONTENT_GAP
			end
		end
	end
end

M.ApplyAnimation = function(self)
	local rate = gDialogManager.blendRate

	for _, info in pairs(self.contents) do
		if info.widget and not gCS.LuaUtils.IsNull(info.widget) and info.stage >= 3 then
			local posY = Mathf.Lerp(info.lastPosY, info.targetPosY, rate)

			info.widget.rectTransform:SetAnchoredPositionY(posY)

			if rate > 1 then
				info.lastPosY = info.targetPosY
			end

			local store = self.GetDialogComponentStore(self, info.widget)

			if info.stage ~= 1 then
				store.ContentText.color = Color.New(1, 1, 1, rate)
			else
				store.ContentText.color = Color.New(1, 1, 1, 1)
			end
		end
	end
end

M.UpdateContents = function(self)
	if gCS.LuaUtils.IsNull(self.contentList) or not self.contentList.luaRenderItem or not self.contentList.bActive then
		return
	end

	self.SyncContentList(self)
	self.RecalculateTargetPos(self)
	self.ApplyAnimation(self)
end

M.OnDisable_Contents = function(self)
	if not self.contentList then
		return
	end

	if self.contents then
		for _, info in pairs(self.contents) do
			if info.widget then
				info.widget = nil
				info.renderStage = 0
			end
		end
	end

	self.contents = {}
	self.contentIds = {}

	if self.panelId and gDialogManager.openedPanels[self.panelId] and not gCS.LuaUtils.IsNull(self.contentList) and self.contentList.onGetTIndex then
		self.contentList:SetList(0)
	end

	if gDialogManager.mainDialogId ~= self.nodeId then
		gDialogManager:RemoveMainContent()
	end
end
