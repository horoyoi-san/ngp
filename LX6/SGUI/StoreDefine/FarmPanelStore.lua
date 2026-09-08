-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FarmPanelStore.lua
-- Decompiled from: 01837_FarmPanelStore.lua_439abfbcc29a.luajit

C_FarmPanelStore = DefClass("C_FarmPanelStore", C_FarmPanelStore, C_StoreGroup)
GroupName2Class.FarmPanelStore = C_FarmPanelStore
local M = C_FarmPanelStore
local DragEventListener = SGUI.EventSystems.DragEventListener
local ClickEventListener = SGUI.EventSystems.ClickEventListener

M.ctor = function(self)
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

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.bindData.btnBack.luaClick = self.CreateAction(self, "ClosePanel")
end

M.ClosePanel = function(self)
	if self.curTypeStore then
		self.curTypeStore:ClosePanel()
	end

	gSpoonClientMgr:TryCallInnerSignal(self.instanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, self.curGameplayType)

	self.curGameplayType = nil
	self.showData = nil
	self.curTypeStore = nil
	self.playType = -1

	gMiniGameDataManager:ExitSimulatorGame()
end

M.OnShow = function(self, panelId, data)
	self.msgEvents = {
		[gEventConstants.ON_SIMULATOR_GAME_PANEL_AREA_TRIGGER] = self.CreateAction(self, "OnAreaTriggerEvent")
	}

	self.RegisterMessageEvents(self, self.msgEvents)

	self.playType = -1
	local param = data.params

	if param then
		if param.gameplayType then
			self.playType = self.TypeIdMap[param.gameplayType] or -1
		else
			self.playType = -1
			local btnDrag = DragEventListener.Get(self.bindData.interactBtn.gameObject)
			btnDrag.onBeginDrag = self.CreateAction(self, "OnBeginDrag")
			btnDrag.onDrag = self.CreateAction(self, "OnDrag")
			btnDrag.onEndDrag = self.CreateAction(self, "OnEndDrag")
			local clickEventListener = ClickEventListener.Get(self.bindData.interactBtn.gameObject)
			clickEventListener.onClick = self.CreateAction(self, "OnClick")

			self.CheckUpdateEnable(self)

			self.needUpdate = true
		end
	end

	self.curGameplayType = param.gameplayType or "CommonSimulator"

	if self.curTypeStore and self.bindData.tabRect.selectedIndex == self.playType then
		self.curTypeStore:ClosePanel()
	end

	self.showData = param
	self.instanceId = param.data.instanceId
	self.bindData.tabRect.selectedIndex = self.playType

	if param.data.fryTeaType ~= 2 then
		self.bindData.btnBack:SetActive(false)
	end
end

M.OnRenderTab = function(self, index, widget)
	self.curTypeStore = gStoreManager:GetStoreGroup(widget.Store)

	if self.curTypeStore then
		self.curTypeStore:OnShow(nil, self.showData)
	end
end

M.OnClick = function(self)
end

M.OnBeginDrag = function(self)
end

M.OnDrag = function(self)
end

M.OnEndDrag = function(self)
end

M.GameEnd = function(self)
	self.needUpdate = false
end

M.CheckUpdateEnable = function(self)
	gStoreManager:RegisterDynamicOnUpdate(self)
end

M.CheckUpdateDisable = function(self)
	if self.needUpdate then
		return
	end

	gStoreManager:UnregisterDynamicOnUpdate(self)
end

M.OnUpdate = function(self)
	self.CheckUpdateDisable(self)
end

M.RegisterBtnBackCallback = function(self, backCallback)
	self.backBtnCb = backCallback
end

M.OnBtnPress = function(self)
	if gMiniGameDataManager.currentSimulatorGame.context then
		gMiniGameDataManager.currentSimulatorGame.context.IsBtnPress = true
		gMiniGameDataManager.currentSimulatorGame.context.TriggerPress = true
		gMiniGameDataManager.currentSimulatorGame.context._mouseDownPosition = self.pos
	end
end

M.OnBtnRelease = function(self)
	if gMiniGameDataManager.currentSimulatorGame.context then
		gMiniGameDataManager.currentSimulatorGame.context.IsBtnPress = false
		gMiniGameDataManager.currentSimulatorGame.context.TriggerRelease = true
		gMiniGameDataManager.currentSimulatorGame.context._mouseDownPosition = Vector3.zero
	end
end
