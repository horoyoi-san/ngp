C_FarmPanelStore = DefClass("C_FarmPanelStore", C_FarmPanelStore, C_StoreGroup)
GroupName2Class.FarmPanelStore = C_FarmPanelStore
local M = C_FarmPanelStore
local DragEventListener = SGUI.EventSystems.DragEventListener
local ClickEventListener = SGUI.EventSystems.ClickEventListener

function M:ctor()
	self.DEFINE_DynamicOnUpdate = true
	self.TypeIdMap = {
		CommonSimulator = gMiniGameDataManager.SimulatorGameType.None,
		FryTea = gMiniGameDataManager.SimulatorGameType.FryTea,
		PackTea = gMiniGameDataManager.SimulatorGameType.PackTea
	}
	self.playType = -1
	self.showData = nil
	self.needUpdate = false
end

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.bindData.btnBack.luaClick = self:CreateAction("ClosePanel")
end

function M:ClosePanel()
	if self.curTypeStore then
		self.curTypeStore:ClosePanel()
	end

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = self.curGameplayType
	})

	self.curGameplayType = nil
	self.showData = nil
	self.curTypeStore = nil
	self.playType = -1

	gMiniGameDataManager:ExitSimulatorGame()
end

function M:OnShow(panelId, data)
	self.msgEvents = {
		[gEventConstants.ON_SIMULATOR_GAME_PANEL_AREA_TRIGGER] = self:CreateAction("OnAreaTriggerEvent")
	}

	self:RegisterMessageEvents(self.msgEvents)

	self.playType = -1
	local param = data.params

	if param then
		if param.gameplayType then
			self.playType = self.TypeIdMap[param.gameplayType] or -1
		else
			self.playType = -1
			local btnDrag = DragEventListener.Get(self.bindData.interactBtn.gameObject)
			btnDrag.onBeginDrag = self:CreateAction("OnBeginDrag")
			btnDrag.onDrag = self:CreateAction("OnDrag")
			btnDrag.onEndDrag = self:CreateAction("OnEndDrag")
			local clickEventListener = ClickEventListener.Get(self.bindData.interactBtn.gameObject)
			clickEventListener.onClick = self:CreateAction("OnClick")

			self:CheckUpdateEnable()

			self.needUpdate = true
		end
	end

	self.curGameplayType = param.gameplayType or "CommonSimulator"

	if self.curTypeStore and self.bindData.tabRect.selectedIndex ~= self.playType then
		self.curTypeStore:ClosePanel()
	end

	self.showData = param
	self.bindData.tabRect.selectedIndex = self.playType
end

function M:OnRenderTab(index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(nil, self.showData)
	end
end

function M:OnClick()
	return
end

function M:OnBeginDrag()
	return
end

function M:OnDrag()
	return
end

function M:OnEndDrag()
	return
end

function M:GameEnd()
	self.needUpdate = false
end

function M:CheckUpdateEnable()
	gStoreManager:RegisterDynamicOnUpdate(self)
end

function M:CheckUpdateDisable()
	if self.needUpdate then
		return
	end

	gStoreManager:UnregisterDynamicOnUpdate(self)
end

function M:OnUpdate()
	self:CheckUpdateDisable()
end

function M:RegisterBtnBackCallback(backCallback)
	self.backBtnCb = backCallback
end

function M:OnBtnPress()
	if gMiniGameDataManager.currentSimulatorGame.context then
		print_error("press!!!")

		gMiniGameDataManager.currentSimulatorGame.context.IsBtnPress = true
		gMiniGameDataManager.currentSimulatorGame.context.TriggerPress = true
		gMiniGameDataManager.currentSimulatorGame.context._mouseDownPosition = self.pos
	end
end

function M:OnBtnRelease()
	if gMiniGameDataManager.currentSimulatorGame.context then
		print_error("release!!!")

		gMiniGameDataManager.currentSimulatorGame.context.IsBtnPress = false
		gMiniGameDataManager.currentSimulatorGame.context.TriggerRelease = true
		gMiniGameDataManager.currentSimulatorGame.context._mouseDownPosition = Vector3.zero
	end
end
