-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Police\PoliceInquiryPanelStore.lua
-- Decompiled from: 01235_PoliceInquiryPanelStore.lua_ac71c1c0fcdf.luajit

local static_props = {
	CloseReason = {
		["a\\xab\\xa3\\xb9\\xb3"] = 5,
		["Mw\\xb8c@\\xb7\\xddULv{I"] = 6,
		["k\\xa1\\xb0\\xac\\xb3"] = 2,
		["a_¸\\x85\\xbd*\\xd9\\xeb"] = 4,
		["9[\\x92\\x81\\x91U"] = 7,
		["bU~l]\n?;"] = 3,
		["\\xb1$#w\\x89g\\xd6\"\\xa4\\xbd"] = 1
	}
}
C_PoliceInquiryPanelStore = DefClass("C_PoliceInquiryPanelStore", C_PoliceInquiryPanelStore, C_StoreGroup, static_props)
GroupName2Class.PoliceInquiryPanelStore = C_PoliceInquiryPanelStore
local M = C_PoliceInquiryPanelStore
local GameInputManager = LX6.Manager.GameInputManager
local ShowPageCtrl = {
	["/M\\x90\\x9c\\x80I"] = 2,
	["\\xf1\\xd2?(\\xfd"] = 5,
	["X#n^"] = 0,
	[")-"] = 1,
	["`_¸\\x87\\x9e\r\\xc7\\xed"] = 4,
	["\\+s^"] = 3
}
local InquiryCtrl = {
	["R+y^"] = 1,
	["I*rL"] = 0
}
local FineCtrl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}

M.ctor = function(self)
	self.pcKey1Id = 15
	self.maxBtnCount = 9
	self.OnRenderSubItemFunc = self.CreateAction(self, self.OnRenderSubItem)
	self.OnSelectedChangedFunc = self.CreateAction(self, self.OnSelectedChanged)
	self.OnClickSubItemFunc = self.CreateAction(self, self.OnClickSubItem)
	self.gamepadMode = false
end

M.OnAwake = function(self)
	self.list = self.bindData.list
	self.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
	self.list.luaSimpleClick = self:CreateAction(self.OnClickItem)
	self.list.onGetTIndex = self:CreateAction(self.OnGetItemTIndex)
	self.bindData.topRightOptions.luaSimpleRenderItem = self:CreateAction(self.OnTopRightRenderItem)
	self.bindData.topRightOptions.onGetTIndex = self:CreateAction(self.OnTopRightGetTIndex)
	self.bindData.exitButton.luaClick = self:CreateAction(self.Leave)
	self.bindData.selectButton.luaClick = self:CreateAction(self.OnSelectBtnClick)
	self.bindData.foldBtn.luaClick = self:CreateAction(self.OnFoldBtnClick)
	self.ScrollWheel = self:CreateAction(self.OnMouseScrollWheel)
	self.onDialogFinishCallback = nil

	self:RegisterSingleEvent(gEventConstants.DIALOG_SHOW_END, self:CreateAction(self.OnDialogFinish))
	self:InitDataOnAwake()

	self.bindData.showPageCtrl = ShowPageCtrl.Base
	self.bindData.inquiry = InquiryCtrl.Show
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	local messageEvents = {
		[gEventConstants.POLICE_EXAM_EMOTION_CHANGE] = self:CreateAction(self.RefreshTopRightList)
	}

	self:RegisterMessageEvents(messageEvents)
end

M.OnStart = function(self)
	self.idPanel = self.bindData.idPanel
	self.idPanelStore = gStoreManager:GetStoreGroup(self.idPanel.Store)
	self.searchPanel = self.bindData.searchPanel
	self.searchPanelStore = gStoreManager:GetStoreGroup(self.searchPanel.Store)
	self.finePanel = self.bindData.finePanel
	self.finePanelStore = gStoreManager:GetStoreGroup(self.finePanel.Store)
	self.fineListPanel = self.bindData.fineListPanel
	self.fineListPanelStore = gStoreManager:GetStoreGroup(self.fineListPanel.Store)
end

M.OnShow = function(self, panelId, data)
	self.isShow = true

	self.mgr:CheckHintOptions()

	self.list = self.bindData.list
	self.panelId = panelId

	if data.ToTable then
		data = data.ToTable(data)
	end

	self.data = data
	self.npcUnit = data.npcUnit

	if self.npcUnit ~= nil then
		self.Close(self, M.CloseReason.NpcNotFound)
	end

	self.npcCharacterModule = LX6.Units.Module.Character.AgentCharacterModule.GetModule(self.npcUnit)
	self.mgr.panel = self
	self.allDisable = false

	self.RefreshList(self)
	self.SetupCamera(self)

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

	gPoliceJobManager:CloseExamineBlackScreen()
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "policePanelOpen", true)
end

M.OnClose = function(self)
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

	if self.teleportBlackScreenTimer then
		self.teleportBlackScreenTimer:Stop()

		self.teleportBlackScreenTimer = nil
	end

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "policePanelOpen", false)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.list = nil
	self.subList = nil
end

M.OnActiveDeviceChange = function(self, device)
	local newGamepad = SGUI.GameDevice.KeyboardMouse <= device

	if self.gamepadMode == newGamepad then
		self.gamepadMode = newGamepad

		if self.bindData.inquiry ~= InquiryCtrl.Show then
			self.RefreshList(self, self.allDisable, true)
		end
	end
end

M.InitDataOnAwake = function(self)
	self.selectedIndex = 0
	self.subOptionId = 0
	self.mgr = gPoliceJobManager.examineMgr
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

M.GetCurrentListData = function(self)
	local options = self.mgr:GetCurrentOptions()
	local listData = {}

	for index, option in ipairs(options) do
		local item = {
			["\\xd1\\xda4+\\xff"] = true,
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

		table.insert(listData, item)
	end

	return listData
end

M.GetCurrentOptionListData = function(self)
	local options = self.mgr:GetCurrentTopRightOptions()

	return options
end

M.RefreshList = function(self, allDisable, keepState, force)
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
						self.SelectItem(self, math.max(1, self.selectedIndex))
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

		if self.bindData.showPageCtrl == ShowPageCtrl.Fine then
			self.bindData.showPageCtrl = ShowPageCtrl.Base
		end

		self.bindData.inquiry = InquiryCtrl.Show
		local suggestion, fakePersonSuggestion = self.mgr:GetCurrentSuggestion()

		if fakePersonSuggestion then
			self.bindData.fakeSuggestion = suggestion
			self.bindData.suggestionCtrl = 2
		elseif suggestion then
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
			if v.optionId ~= self.subOptionId then
				keepArea = false

				break
			end
		end
	end
end

M.ShowBasePage = function(self)
	if self.isShow then
		self.bindData.showPageCtrl = ShowPageCtrl.Base

		self.bindData.exitButton:SetActive(not self.hideLeaveBtn)
	end
end

M.SelectItem = function(self, index)
	if self.subList ~= nil or self.subListData ~= nil or index ~= nil or index <= 1 or index <= #self.subListData then
		return
	end

	local targetIndex = self.gamepadMode and 0 or index
	local csIndex = targetIndex - 1
	self.selectedIndex = targetIndex

	self.subList:GoToIndex(csIndex, true)
	self.subList:SelectItem(csIndex, false)
end

M.OnClickItem = function(self, btn, index)
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

M.OnGetItemTIndex = function(self, index)
	local data = self.listData[index + 1]

	return data and data.tIndex or 0
end

M.OnRenderItem = function(self, btn, csIndex)
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

	if csIndex + 1 < self.maxBtnCount then
		btn.SetPCKeyInfoWithOutTip(btn, self.pcKey1Id + csIndex)
	else
		print_error("警察界面按钮数量太多，超过了", self.maxBtnCount, "个，超出的按钮为", data.text)
	end

	if data.subOptions then
		self.selectedOptionCsIndex = csIndex
		store.list.luaSimpleRenderItem = self.OnRenderSubItemFunc
		store.list.luaSelectedChanged = self.OnSelectedChangedFunc
		store.list.luaSimpleClick = self.CreateAction(self, self.OnClickSubItem)

		if data.optionId ~= self.subOptionId then
			self.subList = store.list
			self.subListData = data.subOptions
			self.subList.visibility = (self.allDisable or not data.enable) and SGUI.EVisibility.HitTestInvisible or SGUI.EVisibility.Visible

			self.subList:SetSimpleList(#self.subListData)
			self.bindData.selectButton:SetActive(true)
			self:SelectItem(self.selectedIndex)
			self.list:SelectItem(csIndex, false)
		end
	end

	store.consoleBackBtn.luaClick = function()
		self:OnConsoleBackBtnClick(data)
	end
end

M.OnTopRightRenderItem = function(self, btn, csIndex)
	local data = self.optionListData[csIndex + 1]
	local store = self.GetStoreByWidget(self, btn)

	if data.tIndex ~= 1 then
		store.label = data.label
	else
		store.icon = data.iconId
		store.label = data.label

		store.askBtn:SetActive(data.showAsk)

		if data.showAsk then
			store.askBtn.interactable = not self.allDisable

			store.askBtn.luaClick = function()
				self:OnAskBtnClick(data)
			end
		end
	end
end

M.OnTopRightGetTIndex = function(self, index)
	local data = self.optionListData[index + 1]

	return data.tIndex
end

M.RefreshTopRightList = function(self)
	if self.isShow then
		self.optionListData = self:GetCurrentOptionListData()

		self.bindData.topRightOptions:SetSimpleList(#self.optionListData)
	end
end

M.OnAskBtnClick = function(self, data)
	self.mgr:ShowAiDialogByFineId(data.optionId, data.fineId)
end

M.OnConsoleBackBtnClick = function(self, data)
	if self.gamepadMode then
		self.list:SelectItem(-1, false)
	end
end

M.OnRenderSubItem = function(self, btn, csIndex)
	local data = self.subListData[csIndex + 1]
	local store = self:GetStoreByWidget(btn)
	store.icon = data.cfg.Icon
	store.text = data.cfg.Option
	store.guideId = data.cfg.GuideId or ""
	store.triggeredCtrl = self.allDisable and 1 or 0
	store.lockCtrl = (self.allDisable or not data.enable) and 1 or 0
end

M.OnSelectedChanged = function(self, list)
	self.selectedIndex = list.selectedIndex + 1
end

M.OnClickSubItem = function(self, btn, csIndex)
	local data = self.subListData[csIndex + 1]

	if self.allDisable or not data.enable then
		return
	end

	self.OnListBtnClick(self, data)
end

M.OnSelectBtnClick = function(self)
	if self.allDisable or not self.isShow then
		return
	end

	if self.selectedIndex ~= 0 or self.bindData.showPageCtrl == ShowPageCtrl.Base then
		return
	end

	local item = self.subListData[self.selectedIndex]

	if not item.enable then
		return
	end

	self.OnListBtnClick(self, item)
end

M.OnFoldBtnClick = function(self)
	gPoliceJobManager.examineMgr:SwitchTopRightMenuFold()
end

M.OnListBtnClick = function(self, itemData)
	if itemData.action then
		itemData.action()
	elseif itemData.optionCfgId then
		self.mgr:ClickOption(itemData.optionCfgId)
	else
		print_error_without_stack("item action and optionCfgId is nil, item", itemData, "selectedIndex", self.selectedIndex)
	end
end

M.OnDialogFinish = function(self, _, cfgId)
	if self.onDialogFinishCallback then
		local nextDialog = LTConfig.DialogConfig.GetConfig(cfgId).NextDialog

		if nextDialog ~= nil or nextDialog ~= 0 then
			self.onDialogFinishCallback(cfgId)

			self.onDialogFinishCallback = nil
		end
	end
end

M.OnMouseScrollWheel = function(self, context)
	if not self.isShow then
		return
	end

	if not context.performed then
		return
	end

	if not self.STATE_EnableOnce or self.bindData.showPageCtrl == ShowPageCtrl.Base or not self.selectedIndex then
		return
	end

	local zoom = context.ReadValueVector2(context).y

	if zoom <= 0 then
		self.SelectItem(self, self.selectedIndex - 1)
	else
		self.SelectItem(self, self.selectedIndex + 1)
	end
end

M.Close = function(self, reason)
	self.closeReason = reason

	gPanelManager:Close(self.panelId or gPanelId.POLICE_INQUIRY_PANEL)
end

M.Leave = function(self)
	self.mgr:ClickOption(LTConfig.PoliceConfig.Leave)
end

M.ShowPanel = function(self, isShow)
end

M.ShowCheckIdContent = function(self, closeCallback)
	self:ShowPanel(true)
	self:HideAll()

	self.bindData.showPageCtrl = ShowPageCtrl.ID
	self.bindData.inquiry = InquiryCtrl.Hide

	self.bindData.exitButton:SetActive(not self.hideLeaveBtn)
	self.idPanelStore:ShowContent(self.npcUnit, self.npcCharacterModule)
	self.idPanelStore:SetCloseCallback(closeCallback)
end

M.ShowSearchBodyContent = function(self, closeCallback)
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

M.ShowBreathCheckContent = function(self, closeCallback)
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

M.ShowDrugTestContent = function(self, closeCallback)
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

M.ShowFineResult = function(self, fineList, fineMoney, jobExpInfo, closeCallback)
	self:ShowPanel(true)

	self.bindData.fineCtrl = FineCtrl.Show

	self.finePanelStore:ShowFineResult(fineList, fineMoney, jobExpInfo)
	self.finePanelStore:SetCloseCallback(closeCallback)
end

M.HideFineResult = function(self)
	self.bindData.fineCtrl = FineCtrl.Hide
end

M.ShowSelectFinePanel = function(self, fineTimes, fineInfoDict, fineList, closeCallback)
	if self.bindData.showPageCtrl ~= ShowPageCtrl.SelectFine and self.bindData.inquiry ~= InquiryCtrl.Hide then
		return
	end

	self:ShowPanel(true)
	self:HideAll()

	self.bindData.showPageCtrl = ShowPageCtrl.SelectFine
	self.bindData.inquiry = InquiryCtrl.Hide

	self.bindData.exitButton:SetActive(not self.hideLeaveBtn)
	self.fineListPanelStore:Show(fineTimes, fineInfoDict, fineList)
	self.fineListPanelStore:SetCloseCallback(closeCallback)
end

M.HideAll = function(self, rootHide)
	if rootHide then
		self.ShowPanel(self, false)
	end

	self.bindData.showPageCtrl = ShowPageCtrl.HideAll
	self.bindData.inquiry = InquiryCtrl.Hide

	self.bindData.exitButton:SetActive(false)
end

M.CanDoAction = function(self)
	if self.isShow and self.bindData.showPageCtrl ~= ShowPageCtrl.Base and self.bindData.inquiry ~= InquiryCtrl.Show then
		return true
	end

	return false
end

M.SetupCamera = function(self)
	local npcTargetDir = self.data.npcTargetDir
	local facingDir = Vector3.New(npcTargetDir.x, npcTargetDir.y, npcTargetDir.z)

	gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.PoliceExamine, {
		Unit = self.npcUnit,
		Facing = facingDir
	})
	gMessageManager:SendMessage(gEventConstants.POLICE_SWITCH_CAMERA, 1)
end
