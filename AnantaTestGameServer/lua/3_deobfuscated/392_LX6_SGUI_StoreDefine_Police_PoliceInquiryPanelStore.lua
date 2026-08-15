local static_props = {
	CloseReason = {
		Leave = 5,
		BattleOrFlee = 6,
		Force = 2,
		ReleaseNpc = 4,
		Escort = 7,
		ArrestNpc = 3,
		NpcNotFound = 1
	}
}
C_PoliceInquiryPanelStore = DefClass("C_PoliceInquiryPanelStore", C_PoliceInquiryPanelStore, C_StoreGroup, static_props)
GroupName2Class.PoliceInquiryPanelStore = C_PoliceInquiryPanelStore
local M = C_PoliceInquiryPanelStore
local GameInputManager = LX6.Manager.GameInputManager
local ShowPageCtrl = {
	Search = 2,
	HideAll = 5,
	Base = 0,
	ID = 1,
	SelectFine = 4,
	Fine = 3
}
local InquiryCtrl = {
	Hide = 1,
	Show = 0
}
local FineCtrl = {
	Hide = 0,
	Show = 1
}

function M:ctor()
	self.pcKey1Id = 15
	self.maxBtnCount = 9
	self.OnRenderSubItemFunc = self:CreateAction(self.OnRenderSubItem)
	self.OnSelectedChangedFunc = self:CreateAction(self.OnSelectedChanged)
	self.OnClickSubItemFunc = self:CreateAction(self.OnClickSubItem)
	self.gamepadMode = false
end

function M:OnAwake()
	self.list = self.bindData.list
	self.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
	self.list.luaSimpleClick = self:CreateAction(self.OnClickItem)
	self.list.onGetTIndex = self:CreateAction(self.OnGetItemTIndex)
	self.bindData.topRightOptions.luaSimpleRenderItem = self:CreateAction(self.OnTopRightRenderItem)
	self.bindData.exitButton.luaClick = self:CreateAction(self.Leave)
	self.bindData.selectButton.luaClick = self:CreateAction(self.OnSelectBtnClick)
	self.bindData.foldBtn.luaClick = self:CreateAction(self.OnFoldBtnClick)
	self.ScrollWheel = self:CreateAction(self.OnMouseScrollWheel)
	self.onDialogFinishCallback = nil

	self:RegisterSingleEvent(gEventConstants.DIALOG_SHOW_END, self:CreateAction(self.OnDialogFinish))
	self:InitDataOnAwake()

	self.bindData.showPageCtrl = ShowPageCtrl.Base
	self.bindData.inquiry = InquiryCtrl.Show
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
end

function M:OnStart()
	self.idPanel = self.bindData.idPanel
	self.idPanelStore = gStoreManager:GetStoreGroup(self.idPanel.Store)
	self.searchPanel = self.bindData.searchPanel
	self.searchPanelStore = gStoreManager:GetStoreGroup(self.searchPanel.Store)
	self.finePanel = self.bindData.finePanel
	self.finePanelStore = gStoreManager:GetStoreGroup(self.finePanel.Store)
	self.fineListPanel = self.bindData.fineListPanel
	self.fineListPanelStore = gStoreManager:GetStoreGroup(self.fineListPanel.Store)
end

function M:OnShow(panelId, data)
	self.isShow = true

	self.mgr:CheckHintOptions()

	self.list = self.bindData.list
	self.panelId = panelId

	if data.ToTable then
		data = data:ToTable()
	end

	self.data = data
	self.npcUnit = data.npcUnit

	if self.npcUnit == nil then
		self:Close(M.CloseReason.NpcNotFound)
	end

	self.npcCharacterModule = LX6.Units.Module.Character.AgentCharacterModule.GetModule(self.npcUnit)
	self.mgr.panel = self
	self.allDisable = false

	self:RefreshList()
	self:SetupCamera()

	if data.hideLeaveBtn then
		self.hideLeaveBtn = true

		self.bindData.exitButton:SetActive(false)
	else
		self.hideLeaveBtn = false

		self.bindData.exitButton:SetActive(true)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.ScrollWheel)
	end
end

function M:OnClose()
	self.isShow = false
	self.list = nil
	self.listData = nil
	self.subListData = nil
	self.subList = nil
	self.npcUnit = nil

	if self.data and self.data.closeCallback then
		self.data.closeCallback(self.closeReason)
	end

	gPoliceJobManager.cs:TriggerSpoonFinishExamAction(self.closeReason or C_PoliceInquiryPanelStore.CloseReason.Force)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.ScrollWheel)
	end

	gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.PoliceExamine, nil)
	gMessageManager:SendMessage(gEventConstants.INTERACTION_ACTION_FINISH)
end

function M:OnDestroy()
	self:ClearMessageEvents()

	self.list = nil
	self.subList = nil
end

function M:OnActiveDeviceChange(device)
	local newGamepad = SGUI.GameDevice.KeyboardMouse < device

	if self.gamepadMode ~= newGamepad then
		self.gamepadMode = newGamepad

		if self.bindData.inquiry == InquiryCtrl.Show then
			self:RefreshList(self.allDisable, true)
		end
	end
end

function M:InitDataOnAwake()
	self.selectedIndex = 0
	self.subOptionId = 0
	self.mgr = gPoliceJobManager.examineMgr
	self.actionMgr = self.mgr.actionMgr
	self.closeReason = nil
	self.scaleMax = 1
	self.scaleMin = -1
	self.zoomFactor = 15
	self.OptionTypeToCtrlType = {
		[LTConfig.PoliceConfig.OptionTypeType.Command] = 0,
		[LTConfig.PoliceConfig.OptionTypeType.Search] = 1,
		[LTConfig.PoliceConfig.OptionTypeType.Deal] = 2
	}
end

function M:GetCurrentListData()
	local options = self.mgr:GetCurrentOptions()
	local listData = {}

	for index, option in ipairs(options) do
		local item = {
			hasIcon = true,
			tIndex = option.tIndex,
			optionId = option.cfg.Id,
			index = index,
			text = option.cfg.Option,
			icon = option.cfg.Icon,
			optionCfgId = option.cfg.Id,
			guideId = option.cfg.GuideId,
			subOptions = option.subOptions,
			optionType = option.cfg.OptionType,
			triggered = self.mgr:HasTriggeredOption(option.cfg.Id),
			task = self.mgr:IsOptionGuide(option.cfg.Id),
			taskIconId = self.mgr:GetGuideOptionIconId(),
			enable = option.enable,
			hint = option.hint
		}

		if option.cfg.Message == "Question" then
			item.triggered = self.mgr:HasTriggeredAllQuestion()
		end

		table.insert(listData, item)
	end

	return listData
end

function M:GetCurrentOptionListData()
	local options = self.mgr:GetCurrentTopRightOptions()

	return options
end

function M:RefreshList(allDisable, keepState, force)
	if self.isShow then
		self.bindData.exitButton:SetActive(not self.hideLeaveBtn)

		self.allDisable = allDisable and true or false

		self:ShowPanel(true)

		if keepState then
			if not force then
				local mainBtns = self.list.items:ToTable()

				for i = 1, #mainBtns do
					local mainData = self.listData[i]
					local store = self:GetStoreByWidget(mainBtns[i])
					store.triggeredCtrl = (self.allDisable or not mainData.enable) and 1 or 0
				end

				self.list.visibility = self.allDisable and SGUI.EVisibility.HitTestInvisible or SGUI.EVisibility.Visible

				if self.subList then
					local subBtns = self.subList.items:ToTable()

					for i = 1, #subBtns do
						local subData = self.subListData[i]
						local store = self:GetStoreByWidget(subBtns[i])
						store.triggeredCtrl = self.allDisable and 1 or 0
						store.lockCtrl = (self.allDisable or not subData.enable) and 1 or 0
					end

					self.subList.visibility = self.allDisable and SGUI.EVisibility.HitTestInvisible or SGUI.EVisibility.Visible

					if self.gamepadMode then
						self.subList:SelectItem(-1, false)
					else
						self:SelectItem(math.max(1, self.selectedIndex))
					end
				end

				return
			end
		else
			self.selectedIndex = 0
			self.subOptionId = 0
		end

		self.listData = self:GetCurrentListData()

		self.list:SetSimpleList(#self.listData)

		self.optionListData = self:GetCurrentOptionListData()

		self.bindData.topRightOptions:SetSimpleList(#self.optionListData)

		if self.bindData.showPageCtrl ~= ShowPageCtrl.Fine then
			self.bindData.showPageCtrl = ShowPageCtrl.Base
		end

		self.bindData.inquiry = InquiryCtrl.Show
		local suggestion = self.mgr:GetCurrentSuggestion()

		if suggestion then
			self.bindData.suggestion = suggestion
			self.bindData.suggestionCtrl = 0
		else
			self.bindData.suggestionCtrl = 1
		end

		self.bindData.foldCtrl = self.mgr:IsTopRightMenuFold() and 1 or 0
		self.list.visibility = self.allDisable and SGUI.EVisibility.HitTestInvisible or SGUI.EVisibility.Visible

		gNewGuideMgr:ClearSignal(EGuideSignal.ShowPoliceBodySearch)

		local keepArea = true

		for k, v in pairs(self.listData) do
			if v.optionId == self.subOptionId then
				keepArea = false

				break
			end
		end

		if not self.allDisable and self.mgr.needAutoDoOptionId and self.mgr.needAutoDoOptionId > 0 then
			local autoOptionId = self.mgr.needAutoDoOptionId
			self.mgr.needAutoDoOptionId = nil

			self.mgr:ClickOption(autoOptionId)
		end
	end
end

function M:ShowBasePage()
	if self.isShow then
		self.bindData.showPageCtrl = ShowPageCtrl.Base

		self.bindData.exitButton:SetActive(not self.hideLeaveBtn)
	end
end

function M:SelectItem(index)
	if self.subList == nil or self.subListData == nil or index == nil or index < 1 or index > #self.subListData then
		return
	end

	local targetIndex = self.gamepadMode and 0 or index
	local csIndex = targetIndex - 1
	self.selectedIndex = targetIndex

	self.subList:GoToIndex(csIndex, true)
	self.subList:SelectItem(csIndex, false)
end

function M:OnClickItem(btn, index)
	local data = self.listData[index + 1]

	if self.allDisable or not data.enable then
		return
	end

	if data.subOptions then
		local store = self:GetStoreByWidget(btn)
		self.selectedIndex = 0
		self.subOptionId = data.optionId or 0
		self.subList = store.list
		self.subListData = data.subOptions
		store.list.visibility = (self.allDisable or not data.enable) and SGUI.EVisibility.HitTestInvisible or SGUI.EVisibility.Visible

		store.list:SetSimpleList(#self.subListData)
		self.bindData.selectButton:SetActive(true)
		self:SelectItem(1)
	else
		self:OnListBtnClick(data)

		self.subList = nil
		self.subListData = nil

		self.bindData.selectButton:SetActive(false)
	end
end

function M:OnGetItemTIndex(index)
	local data = self.listData[index + 1]

	return data and data.tIndex or 0
end

function M:OnRenderItem(btn, csIndex)
	local data = self.listData[csIndex + 1]
	local store = self:GetStoreByWidget(btn)
	store.text = data.text
	store.index = csIndex + 1
	store.icon = data.icon
	store.hasIcon = data.hasIcon
	store.guideId = data.guideId or ""
	store.triggeredCtrl = self.allDisable and 1 or 0
	store.type = self.OptionTypeToCtrlType[data.optionType] or 0
	store.task = data.task and 1 or 0
	store.taskIconId = data.taskIconId
	store.hintCtrl = data.hint and 1 or 0

	if csIndex + 1 <= self.maxBtnCount then
		btn:SetPCKeyInfoWithOutTip(self.pcKey1Id + csIndex)
	else
		print_error("警察界面按钮数量太多，超过了", self.maxBtnCount, "个，超出的按钮为", data.text)
	end

	if data.subOptions then
		self.selectedOptionCsIndex = csIndex
		store.list.luaSimpleRenderItem = self.OnRenderSubItemFunc
		store.list.luaSelectedChanged = self.OnSelectedChangedFunc
		store.list.luaSimpleClick = self:CreateAction(self.OnClickSubItem)

		if data.optionId == self.subOptionId then
			self.subList = store.list
			self.subListData = data.subOptions
			self.subList.visibility = (self.allDisable or not data.enable) and SGUI.EVisibility.HitTestInvisible or SGUI.EVisibility.Visible

			self.subList:SetSimpleList(#self.subListData)
			self.bindData.selectButton:SetActive(true)
			self:SelectItem(self.selectedIndex)
			self.list:SelectItem(csIndex, false)
		end
	end

	function store.consoleBackBtn.luaClick()
		self:OnConsoleBackBtnClick(data)
	end
end

function M:OnTopRightRenderItem(btn, csIndex)
	local data = self.optionListData[csIndex + 1]
	local store = self:GetStoreByWidget(btn)
	store.icon = data.iconId
	store.label = data.label

	store.askBtn:SetActive(data.showAsk)

	if data.showAsk then
		store.askBtn.interactable = not self.allDisable

		function store.askBtn.luaClick()
			self:OnAskBtnClick(data)
		end
	end
end

function M:OnAskBtnClick(data)
	self.mgr:ShowAiDialogByFineId(data.optionId, data.fineId)
end

function M:OnConsoleBackBtnClick(data)
	if self.gamepadMode then
		self.list:SelectItem(-1, false)
	end
end

function M:OnRenderSubItem(btn, csIndex)
	local data = self.subListData[csIndex + 1]
	local store = self:GetStoreByWidget(btn)
	store.icon = data.cfg.Icon
	store.text = data.cfg.Option
	store.guideId = data.cfg.GuideId or ""
	store.triggeredCtrl = self.allDisable and 1 or 0
	store.lockCtrl = (self.allDisable or not data.enable) and 1 or 0
end

function M:OnSelectedChanged(list)
	self.selectedIndex = list.selectedIndex + 1
end

function M:OnClickSubItem(btn, csIndex)
	local data = self.subListData[csIndex + 1]

	if self.allDisable or not data.enable then
		return
	end

	self:OnListBtnClick(data)
end

function M:OnSelectBtnClick()
	if self.allDisable or not self.isShow then
		return
	end

	if self.selectedIndex == 0 or self.bindData.showPageCtrl ~= ShowPageCtrl.Base then
		return
	end

	local item = self.subListData[self.selectedIndex]

	if not item.enable then
		return
	end

	self:OnListBtnClick(item)
end

function M:OnFoldBtnClick()
	gPoliceJobManager.examineMgr:SwitchTopRightMenuFold()
end

function M:OnListBtnClick(itemData)
	if itemData.action then
		itemData.action()
	elseif itemData.optionCfgId then
		self.mgr:ClickOption(itemData.optionCfgId)
	else
		print_error_without_stack("item action and optionCfgId is nil, item", itemData, "selectedIndex", self.selectedIndex)
	end
end

function M:OnDialogFinish(_, cfgId)
	if self.onDialogFinishCallback then
		local nextDialog = LTConfig.DialogConfig.GetConfig(cfgId).NextDialog

		if nextDialog == nil or nextDialog == 0 then
			self.onDialogFinishCallback(cfgId)

			self.onDialogFinishCallback = nil
		end
	end
end

function M:ClickQuestion(questionCfg)
	self.mgr.triggeredQuestions[questionCfg.Id] = true

	if not questionCfg.Dialog or questionCfg.Dialog <= 0 then
		return
	end

	function self.onDialogFinishCallback()
		if self.exitQuestionCallback then
			self.exitQuestionCallback()
		end

		self:RefreshList()
	end

	gDialogManager:ShowGeneralDialog(questionCfg.Dialog, DialogSource.Police)
end

function M:OnMouseScrollWheel(context)
	if not self.isShow then
		return
	end

	if not context.performed then
		return
	end

	if not self.STATE_EnableOnce or self.bindData.showPageCtrl ~= ShowPageCtrl.Base or not self.selectedIndex then
		return
	end

	local zoom = context:ReadValueVector2().y

	if zoom > 0 then
		self:SelectItem(self.selectedIndex - 1)
	else
		self:SelectItem(self.selectedIndex + 1)
	end
end

function M:Close(reason, destroyPid)
	self.mgr.isClosingInquirePanel = true

	self.mgr:StopAllWatchdog()
	gPoliceJobManager:CheckWaitOutwardSignal()

	self.closeReason = reason
	local playerUnit = gCS.MyPlayerManager.PlayerUnit

	gCS.UnitStateMgr:RemoveClientState(playerUnit.Pid, LTConfig.UnitStateConfig.OnlyLook)

	if reason ~= C_PoliceInquiryPanelStore.CloseReason.ArrestNpc and reason ~= C_PoliceInquiryPanelStore.CloseReason.Escort then
		if destroyPid ~= playerUnit.Pid then
			gCS.LogicStateMachineManager.SendGameplayEvent(playerUnit, MuGenStates.Logic.GameplayEvent.PoliceExitExamine)
			gPoliceJobManager:SwitchWeaponToCachedWeapon()
		end

		gPoliceJobManager:ChangePoliceStage(gPoliceJobManager.POLICE_STAGE.NONE)

		if self.mgr.unit and destroyPid ~= self.mgr.unit.Pid then
			gCS.BaseUnitUtils.ChangeAuthorityState(self.mgr.unit.Pid, LX6.Units.Module.AuthorityState.Interacting, false)

			if gPoliceJobManager.isDebug then
				print_notice("Police NPC ChangeAuthorityState interacting false, pid " .. tostring(self.mgr.unit.Pid))
			end
		end

		gPoliceJobManager.cs:TryStopMultiInteract()
	end

	if self.mgr.unit and destroyPid ~= self.mgr.unit.Pid then
		gPoliceJobManager.cs:ChangeNpcExamineState(self.mgr.unit.Pid, gPoliceJobManager.CS_EXAMINE_STAGE.NONE)
		gPoliceJobManager:SetNpcExitState(self.mgr.unit.Pid, reason == C_PoliceInquiryPanelStore.CloseReason.Leave and gPoliceJobManager.CS_EXIT_STATE.EXAMINING_EXIT or gPoliceJobManager.CS_EXIT_STATE.NONE)
	end

	gPoliceJobManager.examineMgr.checkShowed = false

	gPanelManager:Close(self.panelId or gPanelId.POLICE_INQUIRY_PANEL)
end

function M:Leave()
	gPoliceJobManager.examineMgr:OptionAction_Leave()
end

function M:ShowPanel(isShow)
	return
end

function M:ShowCheckIdContent(closeCallback)
	self:ShowPanel(true)
	self:HideAll()

	self.bindData.showPageCtrl = ShowPageCtrl.ID
	self.bindData.inquiry = InquiryCtrl.Hide

	self.bindData.exitButton:SetActive(not self.hideLeaveBtn)
	self.idPanelStore:ShowContent(self.npcUnit, self.npcCharacterModule)
	self.idPanelStore:SetCloseCallback(closeCallback)
end

function M:ShowSearchBodyContent(closeCallback)
	self:ShowPanel(true)
	self:HideAll()

	local cfg = {
		Text1 = LTConfig.PoliceConfig.SearchPanelSearchingText,
		Text2 = LTConfig.PoliceConfig.SearchPanelSearchedText
	}
	self.bindData.showPageCtrl = ShowPageCtrl.Search
	self.bindData.inquiry = InquiryCtrl.Hide

	self.bindData.exitButton:SetActive(not self.hideLeaveBtn)
	self.searchPanelStore:ShowSearchBodyContent(self.npcCharacterModule, cfg)
	self.searchPanelStore:SetCloseCallback(closeCallback)
	gNewGuideMgr:NotifySignal(EGuideSignal.ShowPoliceBodySearch)
end

function M:ShowBreathCheckContent(closeCallback)
	self:ShowPanel(true)
	self:HideAll()

	local cfg = {
		Text1 = LTConfig.PoliceConfig.SearchPanelTestingText,
		Text2 = LTConfig.PoliceConfig.SearchPanelTestedText
	}
	self.bindData.showPageCtrl = ShowPageCtrl.Search
	self.bindData.inquiry = InquiryCtrl.Hide

	self.bindData.exitButton:SetActive(not self.hideLeaveBtn)
	self.searchPanelStore:ShowBreathCheckContent(self.npcCharacterModule, cfg)
	self.searchPanelStore:SetCloseCallback(closeCallback)
end

function M:ShowDrugTestContent(closeCallback)
	self:ShowPanel(true)
	self:HideAll()

	local cfg = {
		Text1 = LTConfig.PoliceConfig.SearchPanelTestingText,
		Text2 = LTConfig.PoliceConfig.SearchPanelTestedText
	}
	self.bindData.showPageCtrl = ShowPageCtrl.Search
	self.bindData.inquiry = InquiryCtrl.Hide

	self.bindData.exitButton:SetActive(not self.hideLeaveBtn)
	self.searchPanelStore:ShowDrugTestContent(self.npcCharacterModule, cfg)
	self.searchPanelStore:SetCloseCallback(closeCallback)
end

function M:ShowFineResult(fineList, fineMoney, jobExpInfo, closeCallback)
	self:ShowPanel(true)

	self.bindData.fineCtrl = FineCtrl.Show

	self.finePanelStore:ShowFineResult(fineList, fineMoney, jobExpInfo)
	self.finePanelStore:SetCloseCallback(closeCallback)
end

function M:HideFineResult()
	self.bindData.fineCtrl = FineCtrl.Hide
end

function M:ShowSelectFinePanel(fineTimes, fineInfoDict, fineList, closeCallback)
	self:ShowPanel(true)
	self:HideAll()

	self.bindData.showPageCtrl = ShowPageCtrl.SelectFine
	self.bindData.inquiry = InquiryCtrl.Hide

	self.bindData.exitButton:SetActive(not self.hideLeaveBtn)
	self.fineListPanelStore:Show(fineTimes, fineInfoDict, fineList)
	self.fineListPanelStore:SetCloseCallback(closeCallback)
end

function M:HideAll(rootHide)
	if rootHide then
		self:ShowPanel(false)
	end

	self.bindData.showPageCtrl = ShowPageCtrl.HideAll
	self.bindData.inquiry = InquiryCtrl.Hide

	self.bindData.exitButton:SetActive(false)
end

function M:CanDoAction()
	if self.isShow and self.bindData.showPageCtrl == ShowPageCtrl.Base and self.bindData.inquiry == InquiryCtrl.Show then
		return true
	end

	return false
end

function M:SetupCamera()
	local npcTargetDir = self.data.npcTargetDir
	local facingDir = Vector3.New(npcTargetDir.x, npcTargetDir.y, npcTargetDir.z)

	gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.PoliceExamine, {
		Unit = self.npcUnit,
		Facing = facingDir
	})
	gMessageManager:SendMessage(gEventConstants.POLICE_SWITCH_CAMERA, 1)
end
