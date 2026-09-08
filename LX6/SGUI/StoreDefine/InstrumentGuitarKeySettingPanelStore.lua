-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InstrumentGuitarKeySettingPanelStore.lua
-- Decompiled from: 01833_InstrumentGuitarKeySettingPanelStore.lua_820136543eea.luajit

C_InstrumentGuitarKeySettingPanelStore = DefClass("C_InstrumentGuitarKeySettingPanelStore", C_InstrumentGuitarKeySettingPanelStore, C_StoreGroup)
GroupName2Class.InstrumentGuitarKeySettingPanelStore = C_InstrumentGuitarKeySettingPanelStore
local M = C_InstrumentGuitarKeySettingPanelStore

require("LX6/Gameplay/Instruments/GuitarManager")
require("LX6/Gameplay/Instruments/GuitarGamepadControllerUI")

local ChordSlotCount = 8
local DefaultChordIds = {
	1,
	2,
	3,
	4,
	5,
	6,
	0,
	0
}
local SavedChordIds = nil

local CopyArray = function(source, count)
	local result = {}

	for i = 1, count do
		result[i] = source and source[i] or 0
	end

	return result
end

local PrintWarn = function(msg)
	if print_warn then
		print_warn(msg)
	elseif print then
		print(msg)
	end
end

local ShowTip = function(msg)
	if gDisplayMessageMgr and gDisplayMessageMgr.ShowMessageContent then
		gDisplayMessageMgr:ShowMessageContent(msg)
	else
		PrintWarn(msg)
	end
end

local IsSameArray = function(left, right, count)
	for i = 1, count do
		if (left and left[i] or 0) == (right and right[i] or 0) then
			return false
		end
	end

	return true
end

local ShowDiscardConfirm = function(onConfirm)
	if gDisplayMessageMgr and gDisplayMessageMgr.ShowBomb then
		gDisplayMessageMgr:ShowBomb({
			msgType = gDisplayMessageId and gDisplayMessageId.SELECT_FORCE or nil,
			titleText = LTConfig.InstrumentConfig.Guitar_GiveupEdit,
			tips1Text = LTConfig.MessageConfig.GetConfig(LTConfig.InstrumentConfig.Guitar_Chord_GiveupEdit).Content,
			confirmBtnText = LTConfig.InstrumentConfig.Guitar_Button_Discard,
			cancelBtnText = LTConfig.InstrumentConfig.Guitar_Button_KeepEditing,
			btnConfirmCallback = onConfirm
		})

		return
	end

	if onConfirm then
		onConfirm()
	end
end

local GetChordName = function(chordId)
	if not chordId or chordId ~= 0 then
		return LTConfig.InstrumentConfig.Guitar_Label_EmptySlot
	end

	local cfg = LTConfig.InstrumentGuitarConfig.GetConfig(chordId)

	return cfg and cfg.MusicalNote or tostring(chordId)
end

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.panelId = 0
	self.data = nil
	self.chordLibData = {}
	self.currentChordData = {}
	self.currentChordIds = {}
	self.originalChordIds = {}
	self.selectedSlot = nil
	self.gamepadSlot = nil
	self.gamepadLibChordId = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.data = data
	self.bindData.settingTitle = LTConfig.InstrumentConfig.Guitar_Label_ChordSettings
	self.bindData.libraryTitle = LTConfig.InstrumentConfig.ChordLibrary
	self.bindData.usingTitle = LTConfig.InstrumentConfig.CurrentChord
	local chordIds = gGuitarManager and gGuitarManager.GetCustomChordIds and gGuitarManager:GetCustomChordIds() or SavedChordIds or DefaultChordIds
	self.currentChordIds = CopyArray(chordIds, ChordSlotCount)
	self.originalChordIds = CopyArray(chordIds, ChordSlotCount)
	self.selectedSlot = nil

	self:RefreshLists()
	self:InitGamepadConsole()
end

M.OnClose = function(self)
	self.gamepadConsole = nil
end

M.OnActiveDeviceChange = function(self, device)
	self.TryFocusLibList(self)
end

M.TryFocusLibList = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if gCS.LuaUtils.GetActiveDevice() < SGUI.GameDevice.KeyboardMouse then
		return
	end

	local area = SGUI.UNavigationMgr.Inst.CurrentActiveArea

	if not gClientUtils.NotNil(area) then
		return
	end

	if gClientUtils.NotNil(area.CurrentActiveContent) then
		return
	end

	local success, btn = self.bindData.chordLibList:TryGetChildAt(0, nil)

	if success and gClientUtils.NotNil(btn) then
		area.CurrentActiveContent = btn
	end
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.resetBtn.luaClick = self.CreateAction(self, self.OnClickResetBtn)
	self.bindData.saveBtn.luaClick = self.CreateAction(self, self.OnClickSaveBtn)

	if self.bindData.backBtn then
		self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	end

	self.bindData.chordLibList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderChordLibListItem)
	self.bindData.currentChordList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderCurrentChordListItem)
	self.bindData.chordLibList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickChordLibList)
	self.bindData.currentChordList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickCurrentChordList)
end

M.OnClickResetBtn = function(self)
	local defaults = nil

	if gGuitarManager and gGuitarManager.GetDefaultChordIds then
		defaults = gGuitarManager:GetDefaultChordIds()
	end

	self.currentChordIds = CopyArray(defaults or DefaultChordIds, ChordSlotCount)

	self:RefreshLists()
end

M.OnClickSaveBtn = function(self)
	if self.HasEmptyChordSlot(self) then
		ShowTip(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.Guitar_Chord_NotEnough).Content)

		return
	end

	if gGuitarManager and gGuitarManager.SetCustomChordIds then
		gGuitarManager:SetCustomChordIds(self.currentChordIds)
		gGuitarManager:SaveCustomGuitarInfo()
	else
		SavedChordIds = CopyArray(self.currentChordIds, ChordSlotCount)
	end

	self.RefreshGuitarPanelChordButtons(self)
	self.ClosePanel(self)
end

M.OnClickBackBtn = function(self)
	if self.HasEmptyChordSlot(self) then
		ShowTip(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.Guitar_Chord_NotEnough).Content)

		return
	end

	if not self.HasUnsavedChanges(self) then
		self.ClosePanel(self)

		return
	end

	ShowDiscardConfirm(function ()
		self:ClosePanel()
	end)
end

M.OnSimpleRenderChordLibListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.chordLibData[index + 1]

	self:RenderChordCard(store, data, data and self:IsChordSelected(data.id))

	store.dragSourceKind = "lib"
	store.dragSourceSlot = 0
	store.dragSourceChordId = data and data.id or 0
	btn.draggable = data == nil and (data.id or 0) >= 0
	btn.dropable = true
	btn.luaEnterDropWidget = self:CreateActionWithArgs(self.OnEnterDropWidget, btn)
	btn.luaEndDrag = self:CreateAction(self.OnDragEnd)
	btn.luaFocus = self:CreateActionWithArgs(self.OnLibItemFocus, data and data.id or 0)
end

M.OnSimpleClickChordLibList = function(self, btn, index)
	local data = self.chordLibData[index + 1]

	if not data then
		return
	end

	self.AddChordToCurrent(self, data.id)
end

M.OnSimpleRenderCurrentChordListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.currentChordData[index + 1]

	self:RenderChordCard(store, data, data and data.slot ~= self.selectedSlot)

	store.dragSourceKind = "current"
	store.dragSourceSlot = data and data.slot or 0
	store.dragSourceChordId = data and data.id or 0
	btn.draggable = data == nil and (data.id or 0) >= 0
	btn.dropable = true
	btn.luaEnterDropWidget = self:CreateActionWithArgs(self.OnEnterDropWidget, btn)
	btn.luaEndDrag = self:CreateAction(self.OnDragEnd)
end

M.OnSimpleClickCurrentChordList = function(self, btn, index)
	local data = self.currentChordData[index + 1]

	if not data then
		return
	end

	self.selectedSlot = data.slot
	self.gamepadSlot = data.slot

	if (data.id or 0) <= 0 then
		self.currentChordIds[data.slot] = 0
	end

	self.RefreshLists(self)

	if self.gamepadConsole then
		self.gamepadConsole:SetSelectedIndex(data.slot)
	end
end

M.RenderChordCard = function(self, store, data, isSelected)
	if not data then
		return
	end

	local isEmpty = (data.id or 0) ~= 0
	store.keyName = isEmpty and "" or data.name
	store.isEmptyCtrl = isEmpty and 1 or 0
	store.isEditingCtrl = isSelected and 1 or 0
	store.playingVfxCtrl = 0
end

M.BuildChordLibData = function(self)
	local list = {}
	local cfg = LTConfig.InstrumentGuitarConfig

	for i = 0, cfg.count - 1 do
		local one = cfg.LoadAt(i)

		if one and one.Id == cfg.NoChord then
			list[#list + 1] = {
				id = one.Id,
				name = one.MusicalNote or ""
			}
		end
	end

	return list
end

M.BuildCurrentChordData = function(self)
	local list = {}

	for slot = 1, ChordSlotCount do
		local chordId = self.currentChordIds[slot] or 0
		list[#list + 1] = {
			slot = slot,
			id = chordId,
			name = GetChordName(chordId)
		}
	end

	return list
end

M.RefreshLists = function(self)
	self.chordLibData = self:BuildChordLibData()
	self.currentChordData = self:BuildCurrentChordData()

	self.bindData.chordLibList:SetSimpleList(#self.chordLibData)
	self.bindData.currentChordList:SetSimpleList(#self.currentChordData)

	if self.gamepadConsole then
		self.gamepadConsole:RefreshButtonLabels(self:BuildCurrentChordLabels())
	end
end

M.InitGamepadConsole = function(self)
	if self.gamepadConsole then
		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not self.bindData.console then
		return
	end

	self.gamepadConsole = C_GuitarGamepadControllerUI.new(self.bindData.console, {
		["ds\\xa9g\\xb7\\xfeBin{H"] = true,
		buttonCount = ChordSlotCount,
		buttonLabels = self:BuildCurrentChordLabels(),
		onButtonPress = self:CreateAction(self.OnConsoleSlotSelect)
	})

	self.gamepadConsole.store.controllerAngle:SetActive(false)

	self.gamepadSlot = 1

	self.gamepadConsole:SetSelectedIndex(1)

	if self.bindData.confirmRespond then
		self.bindData.confirmRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnConfirmRespond)
	end
end

M.OnConsoleSlotSelect = function(self, index)
	self.gamepadSlot = index
	self.selectedSlot = index

	self.RefreshLists(self)
end

M.OnLibItemFocus = function(self, chordId)
	self.gamepadLibChordId = chordId or 0
end

M.OnConfirmRespond = function(self, context)
	if not context or not context.started then
		return
	end

	self.SetChordSlot(self, self.gamepadSlot, self.gamepadLibChordId)
end

M.BuildCurrentChordLabels = function(self)
	local labels = {}

	for i = 1, ChordSlotCount do
		labels[i] = GetChordName(self.currentChordIds[i])
	end

	return labels
end

M.RefreshGuitarPanelChordButtons = function(self)
	local storeNames = {
		"\\xe9%'\\xfb\\x8d\\xa8\\xf1\\xb7\\x93\\xf5\\xa7\\x87湊0\\xff\\x87%\\x95\\x85\r\\x8f\\xdd \\xe2",
		"=\\xe5\\xe9[EB`Yii\\xfa\\\\x89\\xe5\\x9ck\\xd9\\xf6^\\xbe3nk\\xcd \\xe4\\xe8J"
	}

	for _, storeName in ipairs(storeNames) do
		local store = gStoreManager:GetStoreGroup(storeName)

		if store and store.RefreshChordButtons then
			store.RefreshChordButtons(store)
		end
	end
end

M.IsChordSelected = function(self, chordId)
	if not chordId or chordId ~= 0 then
		return false
	end

	for i = 1, ChordSlotCount do
		if self.currentChordIds[i] ~= chordId then
			return true
		end
	end

	return false
end

M.HasEmptyChordSlot = function(self)
	for i = 1, ChordSlotCount do
		if not self.currentChordIds[i] or self.currentChordIds[i] ~= 0 then
			return true
		end
	end

	return false
end

M.HasUnsavedChanges = function(self)
	return not IsSameArray(self.currentChordIds, self.originalChordIds, ChordSlotCount)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.panelId)
end

M.FindFirstEmptyChordSlot = function(self)
	for i = 1, ChordSlotCount do
		if not self.currentChordIds[i] or self.currentChordIds[i] ~= 0 then
			return i
		end
	end

	return nil
end

M.AddChordToCurrent = function(self, chordId)
	if self.selectedSlot then
		self.SetChordSlot(self, self.selectedSlot, chordId)

		return
	end

	if self.IsChordSelected(self, chordId) then
		ShowTip(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.Guitar_Chord_Exist).Content)

		return
	end

	local slot = self.FindFirstEmptyChordSlot(self)

	if not slot then
		ShowTip(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.Guitar_Chord_Full).Content)

		return
	end

	self.SetChordSlot(self, slot, chordId)
end

M.RemoveChordSlot = function(self, slot)
	if not slot or not self.currentChordIds[slot] or self.currentChordIds[slot] ~= 0 then
		return
	end

	self.currentChordIds[slot] = 0

	self.RefreshLists(self)
end

M.SetChordSlot = function(self, slot, chordId)
	if not slot or slot < 0 then
		return
	end

	if not chordId or chordId < 0 then
		return
	end

	for i = 1, ChordSlotCount do
		if self.currentChordIds[i] ~= chordId and i == slot then
			self.currentChordIds[i] = 0

			break
		end
	end

	self.currentChordIds[slot] = chordId
	local nextSlot = slot

	for offset = 1, ChordSlotCount do
		local candidate = (slot + offset - 1) % ChordSlotCount + 1

		if not self.currentChordIds[candidate] or self.currentChordIds[candidate] ~= 0 then
			nextSlot = candidate

			break
		end
	end

	self.selectedSlot = nextSlot
	self.gamepadSlot = nextSlot

	self.RefreshLists(self)

	if self.gamepadConsole then
		self.gamepadConsole:SetSelectedIndex(nextSlot)
	end
end

M.SwapChordSlots = function(self, fromSlot, toSlot)
	if not fromSlot or not toSlot or fromSlot ~= toSlot then
		return
	end

	local a = self.currentChordIds[fromSlot]
	local b = self.currentChordIds[toSlot]
	self.currentChordIds[fromSlot] = b
	self.currentChordIds[toSlot] = a

	self.RefreshLists(self)
end

M.OnEnterDropWidget = function(self, fromBtn, toWidget)
	if not toWidget or fromBtn ~= toWidget then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(fromBtn.Store)

	if not storeGroup then
		return
	end

	local fromStore = storeGroup.GetStoreByWidget(storeGroup, fromBtn)
	local toStore = storeGroup.GetStoreByWidget(storeGroup, toWidget)

	if not fromStore or not toStore then
		return
	end

	local fromKind = fromStore.dragSourceKind
	local toKind = toStore.dragSourceKind

	if fromKind ~= "lib" and toKind ~= "current" then
		self.SetChordSlot(self, toStore.dragSourceSlot, fromStore.dragSourceChordId)
	elseif fromKind ~= "current" and toKind ~= "current" then
		self.SwapChordSlots(self, fromStore.dragSourceSlot, toStore.dragSourceSlot)
	elseif fromKind ~= "current" and toKind ~= "lib" then
		self.RemoveChordSlot(self, fromStore.dragSourceSlot)
	end
end

M.OnDragEnd = function(self)
	self.RefreshLists(self)
end
