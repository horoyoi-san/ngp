local CS_DialogManager = L18.Script.LX6.Dialog.DialogManager
local GameInputManager = LX6.Manager.GameInputManager
local CS_DialogSGUIUtils = L18.Script.LX6.Dialog.DialogSGUIUtils
local TaskTitleConfig = LTConfig.TaskTitleConfig
local Screen = UnityEngine.Screen
C_DialogBasePanelStore = DefClass("C_DialogBasePanelStore", C_DialogBasePanelStore, C_StoreGroup)
GroupName2Class.DialogBasePanelStore = C_DialogBasePanelStore
local M = C_DialogBasePanelStore

function M:ctor()
	self.scaleMax = 1
	self.scaleMin = -1
	self.zoomFactor = 15
	self.DialogContent = nil
	self.DialogComponents = {
		DialogBranch = 4,
		DialogHint = 5,
		DialogContent = 3,
		Dialog22Phone = 7,
		DialogPhonetip = 6,
		Dialog21Phone = 8,
		DialogPicture = 2
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
end

function M:OnAwake()
	self.ScrollWheel = self:CreateAction("OnMouseScrollWheel")

	if not self.EventHandler then
		self.EventHandler = {
			[gEventConstants.DIALOG_SHOW_BRANCH] = function (eventId, dialogId)
				if self:CheckComponent(self.DialogComponents.DialogBranch) and dialogId == self.dialogId then
					self:ShowBranch(true)
				end
			end,
			[gEventConstants.DIALOG_REFRESH_CONTROLLER] = function (eventId, param)
				if self.refreshNextFunc and self.DialogContent then
					self.refreshNextFunc(param:ToTable())
				end
			end
		}
	end

	self.startTime = gLogicTime.time
	self.isBranchShow = true

	self:BindListener()
end

function M:BindListener()
	if not self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end

		self.mouseScrollCallback = self:CreateAction("OnMouseScroll")

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.ScrollWheel)
		end

		self.IsBindListener = true
	end
end

function M:UnbindListener()
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

function M:OnEnable()
	return
end

function M:OnDisable()
	return
end

function M:ResetData()
	self.BanBranchClickTimer = 0
	self.branches = {}
	self.refreshNextFunc = nil
	self.updateFunc = {}
	self.activatedComponent = {}
	self.Tags = nil
	self.DialogContent = nil
	self.DialogBranch = nil
	self.contentText = nil
end

function M:OnShow(panelId, rawdata)
	self.panelId = panelId
	gDialogManager.openedPanels[panelId] = self

	self:RefreshPanel(rawdata)
end

function M:RefreshPanel(rawdata)
	if not rawdata then
		return
	end

	self:ResetData()

	if rawdata.Tags and type(rawdata.Tags) ~= "table" then
		self.Tags = rawdata.Tags:ToTable()
	else
		self.Tags = rawdata.Tags
	end

	self:InitInfos(rawdata)
	gMessageManager:SendMessage(gEventConstants.DIALOG_SHOW_FINISH, self.dialogId)
end

function M:OnUpdate()
	if not self.updateFunc then
		return
	end

	for i, v in pairs(self.updateFunc) do
		v()
	end
end

function M:OnClose()
	self:UnbindListener()
	self:ResetData()

	self.refreshBtnFunc = nil
	gDialogManager.openedPanels[self.panelId] = nil

	gMessageManager:SendMessage(gEventConstants.DIALOG_CLOSE_PANEL, self.dialogId)
end

function M:GetDialogComponentStore(widget)
	return gStoreManager:GetStoreGroup("S_DialogComponentStore"):GetStoreByWidget(widget)
end

function M:InitInfos(data)
	self.dialogId = data.DialogId
	self.dialogType = data.DialogType

	self:InitDialogComponent(data)
end

function M:SelectDialogContent(data)
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

function M:SelectDialogBranch(data)
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

function M:InitDialogComponent(data)
	self.bindData.InteractionType = self.InteractionTypes[data.DialogType]

	self:SelectDialogContent(data)
	self:SelectDialogBranch(data)

	if self.DialogContent then
		if data.Content_Valid then
			self.contentText = self:ConcatLeftNameAndMessage(data)

			self:InitContent(self.DialogContent, data)
			table.insert(self.activatedComponent, self.DialogContent)
		else
			self.DialogContent:SetActive(false)
		end
	end

	if self.DialogBranch then
		if data.Branch_Valid then
			self:InitBranch(self.DialogBranch, data)
			table.insert(self.activatedComponent, self.DialogComponents.DialogBranch)
		else
			self:ShowBranch(false)
		end
	end
end

function M:InitPicture(widget, InvestigatePhoto)
	local store = self:GetDialogComponentStore(widget)

	if InvestigatePhoto and InvestigatePhoto.Length >= 2 then
		widget:SetActive(true)

		if InvestigatePhoto[0] == 1 then
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

		widget:SetActive(false)
	end
end

function M:AdjustAlignmentByLines(contentText, text)
	if string.contains(text, "\n") then
		contentText.alignment = 1026
		contentText.text = text

		return
	end

	if contentText then
		gCoroutineManager:StartCoroutine(function ()
			local lines = -1
			local limit = 10

			while contentText and lines < 0 and limit > 0 do
				lines = CS_DialogSGUIUtils.GetLines(contentText, contentText.text)

				if lines < 0 then
					coroutine.yield(nil)
				end

				limit = limit - 1
			end

			if lines >= 0 then
				if lines > 1 then
					contentText.alignment = 1025
				else
					contentText.alignment = 1026
				end

				contentText.text = text
			end
		end)
	end
end

function M:InitTitleAndShowNext(widget, data)
	local store = self:GetDialogComponentStore(widget)

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

function M:ConcatLeftNameAndMessage(data)
	local message = nil

	if string.is_null_or_empty(data.Content_LeftName) then
		message = data.Content_Message
	else
		message = "#IDD" .. data.Content_LeftName .. ": #Z" .. data.Content_Message
	end

	return message
end

function M:InitContent(widget, data)
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
		widget:SetActive(false)

		return
	else
		local store = self:GetDialogComponentStore(widget)

		widget:SetActive(true)

		store.ContentText.text = finalStr

		self:AdjustAlignmentByLines(store.ContentText, store.ContentText.text)
	end
end

function M:OnAttachContentChanged()
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
		widget:SetActive(false)

		return
	else
		local store = self:GetDialogComponentStore(widget)

		widget:SetActive(true)

		store.ContentText.text = finalStr

		self:AdjustAlignmentByLines(store.ContentText, store.ContentText.text)
	end
end

function M:IsContentBeOccupied()
	if gBattleMgr:HasBattleBottomUIShow() then
		return 0
	elseif not gCS.LuaUtils.IsNonMobileAdaptive() and gUIFunctionStateManager:GetCharacterSwitchEnable()[1] then
		return 0
	elseif not gCS.LuaUtils.IsNonMobileAdaptive() and gBattleMgr.SummonData then
		return 0
	end

	return 1
end

function M:InitFreeContent(widget)
	local store = self:GetDialogComponentStore(widget)

	local function func()
		local newBottom = self:IsContentBeOccupied()

		if newBottom ~= store.IsBottom then
			store.IsBottom = newBottom
			store.ContentText.text = store.ContentText.text .. " "

			FrameTimer.New(function ()
				if store.ContentText ~= nil then
					self:AdjustAlignmentByLines(store.ContentText, store.ContentText.text)
				end
			end, 1):Start()
		end
	end

	table.insert(self.updateFunc, func)
end

function M:InitBranchCountDown(store, data)
	local isBranchTimeBarShow = data.Branch_ShowTime
	self.dialogBranchTime = data.DialogDuration

	if store.branchTimeBar then
		store.branchTimeBar:SetActive(isBranchTimeBarShow)
	end

	self.BanBranchClick = true
	self.ShowBranchTimer = self.dialogBranchTime
	self.BanBranchClickTimer = 0.2

	local function func()
		if self.isBranchShow then
			if self.BanBranchClickTimer > 0 then
				self.BanBranchClickTimer = self.BanBranchClickTimer - gLogicTime.deltaTime

				if self.BanBranchClickTimer <= 0 then
					self.BanBranchClick = false
				end
			end

			if isBranchTimeBarShow then
				self.ShowBranchTimer = self.ShowBranchTimer - gLogicTime.deltaTime
				store.branchTimeFill = self.ShowBranchTimer / (self.dialogBranchTime + 0.01)
				store.branchTimeText = self:GetTimeTextFromSecond(self.ShowBranchTimer)
			end
		end
	end

	table.insert(self.updateFunc, func)
end

function M:InitBranch(widget, data)
	local branchList = data.Branch_DataList
	local store = self:GetDialogComponentStore(widget)

	if branchList.Length == 0 then
		print_error("对话状态异常，无选项时进行了选项初始化")

		return
	end

	self.branchPos = data.Branch_NpcPos
	self.showBranchCmd = not data.Content_Valid
	store.ShowMouseM = true

	self:InitBranchCountDown(store, data)

	store.branchList.luaSimpleRenderItem = self:CreateAction("OnRenderBranchItem")
	store.branchList.luaSimpleClick = self:CreateAction("OnBranchListClick")
	store.branchList.onGetTIndex = self:CreateAction("OnGetTIndex")
	store.branchList.luaSelectedChanged = self:CreateAction("OnSelectedChanged")
	self.pcKeySelectIndex = -1

	for i = 0, branchList.Length - 1 do
		local item = branchList[i]:ToTable()
		local view = {
			text = item.BranchText,
			iconId = item.IconId,
			colorfulIcon = item.ColorfulIcon or self.bindData.IsInteraction == 1,
			isRecorded = item.IsRecorded,
			highlight = item.Highlight,
			index = i
		}

		if self.pcKeySelectIndex == -1 and not item.isRecorded then
			self.pcKeySelectIndex = i
		end

		table.insert(self.branches, view)
	end

	if not self.DialogBranch or not store then
		return
	end

	self:ShowBranch(self.showBranchCmd, true)
end

function M:CheckComponent(component)
	if not self.activatedComponent then
		return false
	end

	return table.contains(self.activatedComponent, component)
end

function M:SetBranchIcon(store, data)
	local iconId = data.iconId
	local index = data.index
	local colorful = data.colorfulIcon

	if iconId > 0 and iconId < 100 then
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
		if iconId == 28001861 or iconId == 28002743 then
			store.showQuickKey = 1
			store.quickKey.luaClick = self:CreateActionWithArgs("OnBranchBtnClick", index)
		else
			store.showQuickKey = 0
		end
	end
end

function M:OnRenderBranchItem(btn, index)
	local store = self:GetDialogComponentStore(btn)

	if not store then
		return
	end

	local data = self.branches[index + 1]
	data.btn = btn
	store.text = data.text
	store.showText = not CS_DialogManager.Instance.IsHideDialogText
	store.branchBtn.luaClick = self:CreateActionWithArgs("OnBranchBtnClick", data.index)
	store.highlight = data.highlight and 1 or 0

	store.pcBtn:SetActive(false)
	self:SetBranchIcon(store, data)

	if data.isRecorded then
		store.TurnGray = 1
	else
		store.TurnGray = 0
	end
end

function M:OnGetTIndex(index)
	return 0
end

function M:OnBranchListClick(btn, index)
	local data = self.branches[index + 1]

	self:OnBranchBtnClick(data.index)
end

function M:OnBranchBtnClick(index)
	if #self.branches < 1 or self.BanBranchClick then
		return
	end

	if index > #self.branches then
		print_error("对话选项错误，选项不存在，需要检查配置，dialogId=" .. self.dialogId)
	end

	self:ShowBranch(false)
	gMessageManager:SendMessage(gEventConstants.DIALOG_BRANCH_SELECT, {
		index = index + 1,
		dialogId = self.dialogId
	})
end

function M:ShowBranchByCircle(enable)
	if not self.isBranchShow then
		return
	end

	self.DialogBranch:SetActiveFastest(enable)

	local branchStore = self:GetDialogComponentStore(self.DialogBranch)

	if branchStore and branchStore.navArea then
		branchStore.navArea.enabled = enable
	end
end

function M:ShowBranch(enable, force)
	self.showBranchCmd = enable

	if self.isBranchShow == enable and not force then
		return
	end

	self.DialogBranch:SetActive(enable)

	local store = self:GetDialogComponentStore(self.DialogBranch)

	if enable then
		store.branchList:SetSimpleList(#self.branches)

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			FrameTimer.New(function ()
				self.branches[1].btn:SetSelected(true)
				self:OnSelectedChanged(store.branchList)
			end, 5):Start()
		end
	else
		store.branchList:SetSimpleList(0)
	end

	self.isBranchShow = enable
end

function M:OnSelectedChanged(list)
	for i = 1, #self.branches do
		local data = self.branches[i]

		if not data.btn then
			return
		end

		local store = self:GetDialogComponentStore(data.btn)

		store.pcBtn:SetActive(gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() and data.btn.isSelected and gCS.LuaUtils.GetActiveDevice() == SGUI.GameDevice.KeyboardMouse)

		store.pcBtn.luaClick = self:CreateActionWithArgs("OnBranchBtnClick", i - 1)

		self:SetBranchIcon(store, data)
	end
end

function M:OnMouseScrollWheel(context)
	if gCS.LuaUtils.IsInPcOrEditor() then
		if self.nextScrollTime and gLogicTime.unscaledTime < self.nextScrollTime then
			return
		end

		if SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() then
			return
		end

		if not self.isBranchShow or not self.branches or #self.branches == 0 then
			return
		end

		if context.performed then
			local zoom = context:ReadValueVector2().y
			local zoomResult = zoom * self.zoomFactor

			if self.scaleMax < zoomResult then
				self:PcKeyChangeSelect(true)
			else
				self:PcKeyChangeSelect(false)
			end

			self.nextScrollTime = gLogicTime.unscaledTime + 0.1
		end
	end
end

function M:PcKeyChangeSelect(isUpDir)
	if self.BanBranchClick then
		return
	end

	local oldSelectIndex = self.pcKeySelectIndex

	if isUpDir then
		if self.pcKeySelectIndex > 0 then
			self.pcKeySelectIndex = self.pcKeySelectIndex - 1
		end
	elseif self.pcKeySelectIndex < #self.branches - 1 then
		self.pcKeySelectIndex = self.pcKeySelectIndex + 1
	end

	if self.pcKeySelectIndex >= 0 then
		local store = self:GetDialogComponentStore(self.DialogBranch)

		store.branchList:SetItemSelected(oldSelectIndex, false)
		store.branchList:SetItemSelected(self.pcKeySelectIndex, true)
	end
end

function M:GetTimeTextFromSecond(duration)
	local minute = math.floor(duration / 60)
	local second = math.floor(duration % 60)

	return string.format("%02d:%02d", minute, second)
end

function M:HideDialogContent()
	self.DialogContent:SetActive(false)
end

function M:OnNextDialogClick()
	if self.banClickTimer and gLogicTime.unscaledTime < self.banClickTimer then
		return
	end

	self.banClickTimer = gLogicTime.unscaledTime + 0.2

	gMessageManager:SendMessage(gEventConstants.DIALOG_PANEL_CLICK, {
		type = 1,
		dialogId = self.dialogId
	})
end
