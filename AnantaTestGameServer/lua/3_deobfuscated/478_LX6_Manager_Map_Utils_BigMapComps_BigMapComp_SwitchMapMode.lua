BigMapComp_SwitchMapMode = BigMapComp_SwitchMapMode or {}
local M = BigMapComp_SwitchMapMode
M.__index = M
local Time = Time
local UNHOVER_HIDE_TIME = 0.2

function M:OnInit()
	self.tabRect = self.bindData.switchMapModeTabRect
	self.mapModeData = {
		Common = {
			mode = "Common",
			cfgId = LTConfig.GpsBigMapModeConfig.Common,
			signal = EBigMapFSMSignal.SwitchModeCommon
		},
		Faction = {
			mode = "Faction",
			cfgId = LTConfig.GpsBigMapModeConfig.Faction,
			signal = EBigMapFSMSignal.SwitchModeFaction
		},
		Legend = {
			mode = "Legend",
			cfgId = LTConfig.GpsBigMapModeConfig.Legend,
			signal = EBigMapFSMSignal.SwitchModeLegend,
			availableSpirits = LTConfig.LegendaryInvestigatorConfig.UnlockLimitedPlayRole
		}
	}
	self.otherModes = {}

	self:SetMode("Common")
end

function M:OnStart()
	self.eventHandlers = {
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self.bigMap:CreateAction("OnSystemUnlockStateChange", self)
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)

	self.tabRect.OnRenderTab = self.bigMap:CreateAction("OnRenderTab", self)
	self.tabRect.selectedIndex = 0

	function self.hideFunc()
		self:HideList()
	end

	self.bigMap:RegisterConflictComp("SwitchMapMode", self.hideFunc)
end

function M:OnEnd()
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)
end

function M:OnActive()
	self:Refresh()
end

function M:OnInactive()
	self:Refresh()
end

function M:OnUpdate()
	self:TickPcHover()
end

function M:OnEnd()
	self.tabRect.selectedIndex = -1

	self.tabRect:ClearUnusedTabInstances()
end

local UnityInput = UnityEngine.Input
local luaUtils = gCS.LuaUtils

function M:TickPcHover()
	if not self.mainStore then
		return
	end

	if not self:IsPcKeyboard() then
		return
	end

	if self:HasShown() then
		if not luaUtils.RectangleContainsScreenPoint(self.mainStore.hoverRect, UnityInput.mousePosition) and not luaUtils.RectangleContainsScreenPoint(self.mainStore.mainBtnRect, UnityInput.mousePosition) then
			self._hideTimer = self._hideTimer - Time.deltaTime

			if self._hideTimer <= 0 then
				self:HideAndUnregister()
			end
		else
			self._hideTimer = UNHOVER_HIDE_TIME
		end
	elseif luaUtils.RectangleContainsScreenPoint(self.mainStore.mainBtnRect, UnityInput.mousePosition) then
		self:ShowAndRegister()
	end
end

function M:SetMode(mode)
	self.mode = mode

	self:Refresh()
	self.bigMap:RecoverSpiritList()
end

function M:OnSystemUnlockStateChange(eventId, systemId)
	if systemId == LTConfig.SystemUnlockConfig.FactionMap then
		self:Refresh()
	end
end

function M:OnClickMainBtn()
	if self:IsPcKeyboard() then
		return
	end

	if self:CanShow() then
		self:ShowAndRegister()
	else
		self:HideAndUnregister()
	end
end

function M:ShowAndRegister()
	self._hideTimer = UNHOVER_HIDE_TIME

	self:ShowList()
	self.bigMap:HideConflictComps("SwitchMapMode")

	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.mainStore.navArea
end

function M:HideAndUnregister()
	self:HideList()
	SGUI.UNavigationMgr.Inst:UnRegisterArea(self.mainStore.navArea)

	self._hideTimer = nil
end

function M:HideList()
	if self.mainStore then
		self._focusBtnCnt = 0
		self._hideTimer = 0
		self.mainStore.showSub = 0

		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.SwitchMapMode, false)
	end
end

function M:ShowList()
	if self.mainStore then
		self.mainStore.showSub = 1

		self.bigMap:ClearControllerDropdownCtx()
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.SwitchMapMode, true)
	end
end

function M:CanShow()
	return self.mainStore.showSub ~= 1 and #self.otherModes > 0
end

function M:HasShown()
	return self.mainStore and self.mainStore.showSub == 1
end

function M:Refresh()
	if not self.mainStore then
		self.tabRect:SetActive(false)

		return
	end

	if self.actived then
		self.bigMap:RegisterNavArea(EBigMapNavArea.SwitchMapMode, self.mainStore.navArea)
		self.bigMap:RegisterNavArea(EBigMapNavArea.SwitchMapMode, self.mainStore.listNavArea)
		self.bigMap:RegisterControllerKey(EBigMapControllerKey.SwitchMap, self.mainStore.controllerKey)
	else
		self.bigMap:UnRegisterNavArea(EBigMapNavArea.SwitchMapMode, self.mainStore.navArea)
		self.bigMap:UnRegisterNavArea(EBigMapNavArea.SwitchMapMode, self.mainStore.listNavArea)
		self.bigMap:UnRegisterControllerKey(EBigMapControllerKey.SwitchMap)
		self.tabRect:SetActive(false)

		return
	end

	table.clear(self.otherModes)

	for modeName, modeData in pairs(self.mapModeData) do
		if modeName ~= self.mode then
			local cfg = LTConfig.GpsBigMapModeConfig.GetConfig(modeData.cfgId)

			if not cfg then
				-- Nothing
			elseif modeData.availableSpirits and #modeData.availableSpirits > 0 then
				local curTid = gSpiritManager:GetCurFirstSpiritTid()
			elseif not cfg.SystemUnlockId or cfg.SystemUnlockId == 0 or gSystemUnlockMgr:IsUnlock(cfg.SystemUnlockId) then
				table.insert(self.otherModes, modeData)
			end
		end
	end

	if #self.otherModes == 0 then
		self.tabRect:SetActive(false)
	else
		self:SortModes()
		self.mainStore.otherModeList:SetSimpleList(#self.otherModes)

		local cfgId = self.mapModeData[self.mode].cfgId
		local cfg = LTConfig.GpsBigMapModeConfig.GetConfig(cfgId)
		self.mainStore.currentMapName = cfg.Name
		self.mainStore.modeIconId = cfg.IconId

		self.tabRect:SetActive(true)
	end
end

function M:SortModes()
	table.sort(self.otherModes, function (a, b)
		local aCfg = LTConfig.GpsBigMapModeConfig.GetConfig(a.cfgId)
		local bCfg = LTConfig.GpsBigMapModeConfig.GetConfig(b.cfgId)

		return aCfg.Order < bCfg.Order
	end)
end

function M:OnRenderTab(index, tab)
	self.mainStore = gStoreManager:GetStoreGroup("BigMap_SwitchMapModePart"):GetStoreByWidget(tab)
	self.mainBtn = self.mainStore.mainBtn
	self.mainBtn.luaClick = self.bigMap:CreateAction("OnClickMainBtn", self)
	self.mainStore.otherModeList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderOtherMode", self)
	self.mainStore.otherModeList.luaSimpleClick = self.bigMap:CreateAction("OnClickOtherMode", self)

	self:Refresh()
end

function M:OnRenderOtherMode(btn, index)
	index = index + 1
	local item = self.otherModes[index]
	local store = gStoreManager:GetStoreGroup("AnonymousStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.GpsBigMapModeConfig.GetConfig(item.cfgId)
	store.modeIconId = cfg.ListIconId
	store.modeName = cfg.Name
	store.guideId = cfg.GuideId
end

function M:OnClickOtherMode(btn, index)
	index = index + 1
	local item = self.otherModes[index]

	self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.SwitchMapMode, false)
	self.bigMap:SendFSMSignal(EBigMapFSMSignal.Interaction_Reset)
	self.bigMap:SendFSMSignal(item.signal)
	SGUI.UNavigationMgr.Inst:UnRegisterArea(self.mainStore.navArea)

	if self.bigMap.enableController or not luaUtils.IsPCPlatformOrEditorAdaptive() then
		self:HideList()
	end
end

function M:IsPcKeyboard()
	return luaUtils.IsPCPlatformOrEditorAdaptive() and not self.bigMap.enableController
end
