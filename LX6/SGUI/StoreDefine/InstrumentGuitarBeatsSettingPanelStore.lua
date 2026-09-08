-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InstrumentGuitarBeatsSettingPanelStore.lua
-- Decompiled from: 01827_InstrumentGuitarBeatsSettingPanelStore.lua_3f655b8471af.luajit

C_InstrumentGuitarBeatsSettingPanelStore = DefClass("C_InstrumentGuitarBeatsSettingPanelStore", C_InstrumentGuitarBeatsSettingPanelStore, C_StoreGroup)
GroupName2Class.InstrumentGuitarBeatsSettingPanelStore = C_InstrumentGuitarBeatsSettingPanelStore
local M = C_InstrumentGuitarBeatsSettingPanelStore

require("LX6/Gameplay/Instruments/GuitarManager")

local BeatSlotCount = 2
local DefaultBeatIds = {
	1,
	2
}
local SavedBeatIds = nil

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

local GetBeatName = function(beatId)
	if not beatId or beatId ~= 0 then
		return LTConfig.InstrumentConfig.Guitar_Label_EmptySlot
	end

	return LTConfig.InstrumentConfig["Guitar_RhythmName_" .. beatId]
end

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.panelId = 0
	self.data = nil
	self.beatLibData = {}
	self.currentBeatData = {}
	self.currentBeatIds = {}
	self.originalBeatIds = {}
	self.selectedSlot = nil
	self.gamepadSlot = 1
	self.gamepadBeatId = 0
	self.gamepadActive = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
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
	self.bindData.settingTitle = LTConfig.InstrumentConfig.Guitar_Label_RhythmSettings
	self.bindData.chordLibraryTitle = LTConfig.InstrumentConfig.RhythmPatternLibrary
	self.bindData.chordUsingTitle = LTConfig.InstrumentConfig.CurrentRhythmPattern
	local beatIds = gGuitarManager and gGuitarManager.GetCustomBeatIds and gGuitarManager:GetCustomBeatIds() or SavedBeatIds or DefaultBeatIds
	self.currentBeatIds = CopyArray(beatIds, BeatSlotCount)
	self.originalBeatIds = CopyArray(beatIds, BeatSlotCount)
	self.selectedSlot = nil

	self:RefreshLists()
	self:InitGamepad()
end

M.OnClose = function(self)
	self.gamepadActive = false

	self.StopRhythmPreview(self)
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

	local success, btn = self.bindData.beatLibList:TryGetChildAt(0, nil)

	if success and gClientUtils.NotNil(btn) then
		area.CurrentActiveContent = btn
	end
end

M.RegisterWidget = function(self)
	self.bindData.resetBtn.luaClick = self.CreateAction(self, self.OnClickResetBtn)
	self.bindData.saveBtn.luaClick = self.CreateAction(self, self.OnClickSaveBtn)

	if self.bindData.backBtn then
		self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	end

	self.bindData.beatLibList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderBeatLibListItem)
	self.bindData.currentBeatList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderCurrentBeatListItem)
	self.bindData.beatLibList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickBeatLibList)
	self.bindData.currentBeatList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickCurrentBeatList)
end

M.OnClickResetBtn = function(self)
	self.currentBeatIds = CopyArray(DefaultBeatIds, BeatSlotCount)

	self.RefreshLists(self)
end

M.HasEmptyBeatSlot = function(self)
	for i = 1, BeatSlotCount do
		if not self.currentBeatIds[i] or self.currentBeatIds[i] ~= 0 then
			return true
		end
	end

	return false
end

M.OnClickSaveBtn = function(self)
	if self.HasEmptyBeatSlot(self) then
		ShowTip(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.Guitar_Rhythm_NotEnough).Content)

		return
	end

	if gGuitarManager and gGuitarManager.SetCustomBeatIds then
		gGuitarManager:SetCustomBeatIds(self.currentBeatIds)
		gGuitarManager:SaveCustomGuitarInfo()
	else
		SavedBeatIds = CopyArray(self.currentBeatIds, BeatSlotCount)
	end

	self.RefreshGuitarPanelBeatButtons(self)
	self.ClosePanel(self)
end

M.OnClickBackBtn = function(self)
	if not self.HasUnsavedChanges(self) then
		self.ClosePanel(self)

		return
	end

	ShowDiscardConfirm(function ()
		self:ClosePanel()
	end)
end

M.OnSimpleRenderBeatLibListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.beatLibData[index + 1]

	self:RenderBeatCard(store, data, data and self:IsBeatSelected(data.id))

	store.dragSourceKind = "lib"
	store.dragSourceSlot = 0
	store.dragSourceBeatId = data and data.id or 0
	btn.draggable = data == nil and (data.id or 0) >= 0
	btn.dropable = true
	btn.luaEnterDropWidget = self:CreateActionWithArgs(self.OnEnterDropWidget, btn)
	btn.luaEndDrag = self:CreateAction(self.OnDragEnd)
	btn.luaFocus = self:CreateActionWithArgs(self.OnLibItemFocus, data and data.id or 0)
end

M.OnSimpleClickBeatLibList = function(self, btn, index)
	local data = self.beatLibData[index + 1]

	if not data then
		return
	end

	self.PlayRhythmPreview(self, data.id)
	self.AddBeatToCurrent(self, data.id)
end

M.PlayRhythmPreview = function(self, beatId)
	if not beatId or beatId ~= 0 then
		return
	end

	local rhythmSoundId = LTConfig.InstrumentConfig["GuitarRhythmPattern" .. beatId]

	if not rhythmSoundId or rhythmSoundId < 0 then
		return
	end

	self:StopRhythmPreview()

	self.previewSoundNid = gSoundMgr:PlaySoundByTid(rhythmSoundId) or 0
end

M.StopRhythmPreview = function(self)
	if self.previewSoundNid and self.previewSoundNid <= 0 then
		gSoundMgr:StopSoundByNid(self.previewSoundNid)

		self.previewSoundNid = 0
	end
end

M.OnSimpleRenderCurrentBeatListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.currentBeatData[index + 1]

	self:RenderBeatCard(store, data, data and data.slot ~= self.selectedSlot)

	store.dragSourceKind = "current"
	store.dragSourceSlot = data and data.slot or 0
	store.dragSourceBeatId = data and data.id or 0
	btn.draggable = data == nil and (data.id or 0) >= 0
	btn.dropable = true
	btn.luaEnterDropWidget = self:CreateActionWithArgs(self.OnEnterDropWidget, btn)
	btn.luaEndDrag = self:CreateAction(self.OnDragEnd)
end

M.OnSimpleClickCurrentBeatList = function(self, btn, index)
	local data = self.currentBeatData[index + 1]

	if not data then
		return
	end

	self.selectedSlot = data.slot
	self.gamepadSlot = data.slot

	if (data.id or 0) <= 0 then
		self.currentBeatIds[data.slot] = 0
	end

	self.RefreshLists(self)
end

M.RenderBeatCard = function(self, store, data, isSelected)
	if not data then
		return
	end

	local isEmpty = (data.id or 0) ~= 0
	store.beatName = isEmpty and "" or data.name
	store.isEmptyCtrl = isEmpty and 1 or 0
	store.isEditingCtrl = isSelected and 1 or 0
	store.playingVfxCtrl = 0
end

M.BuildBeatLibData = function(self)
	local list = {}
	local beatCount = 6

	for i = 1, beatCount do
		list[#list + 1] = {
			id = i,
			name = LTConfig.InstrumentConfig["Guitar_RhythmName_" .. i]
		}
	end

	return list
end

M.BuildCurrentBeatData = function(self)
	local list = {}

	for slot = 1, BeatSlotCount do
		local beatId = self.currentBeatIds[slot] or 0
		list[#list + 1] = {
			slot = slot,
			id = beatId,
			name = GetBeatName(beatId)
		}
	end

	return list
end

M.RefreshLists = function(self)
	self.beatLibData = self:BuildBeatLibData()
	self.currentBeatData = self:BuildCurrentBeatData()

	self.bindData.beatLibList:SetSimpleList(#self.beatLibData)
	self.bindData.currentBeatList:SetSimpleList(#self.currentBeatData)
	self:RefreshGamepadSlots()
end

M.InitGamepad = function(self)
	if self.gamepadActive then
		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if not self.bindData.confirmRespond then
		return
	end

	self.gamepadActive = true
	self.bindData.confirmRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnConfirmRespond)

	if self.bindData.changeBtn then
		self.bindData.changeBtn.luaClick = self.CreateAction(self, self.OnClickChangeSlotBtn)
	end

	self.RefreshLists(self)
end

M.RefreshGamepadSlots = function(self)
	if not self.gamepadActive then
		return
	end

	local slots = {
		self.bindData.beatSlotA,
		self.bindData.beatSlotB
	}

	for slot = 1, BeatSlotCount do
		local btn = slots[slot]

		if btn then
			local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

			if store then
				local beatId = self.currentBeatIds[slot] or 0
				store.beatName = GetBeatName(beatId)
				store.playingVfxCtrl = slot ~= self.gamepadSlot and 1 or 0
			end
		end
	end
end

M.OnClickChangeSlotBtn = function(self)
	self.gamepadSlot = self.gamepadSlot ~= 1 and 2 or 1
	self.selectedSlot = self.gamepadSlot

	self:RefreshLists()
end

M.OnLibItemFocus = function(self, beatId)
	beatId = beatId or 0

	if beatId ~= self.gamepadBeatId then
		return
	end

	self.gamepadBeatId = beatId

	self.PlayRhythmPreview(self, beatId)
end

M.OnConfirmRespond = function(self, context)
	if not context or not context.started then
		return
	end

	self.selectedSlot = self.gamepadSlot

	self.SetBeatSlot(self, self.gamepadSlot, self.gamepadBeatId)
end

M.RefreshGuitarPanelBeatButtons = function(self)
	local store = gStoreManager:GetStoreGroup("InstrumentsGuitarPanelMode2Store")

	if store and store.RefreshBeatButtons then
		store.RefreshBeatButtons(store)
	end
end

M.IsBeatSelected = function(self, beatId)
	if not beatId or beatId ~= 0 then
		return false
	end

	for i = 1, BeatSlotCount do
		if self.currentBeatIds[i] ~= beatId then
			return true
		end
	end

	return false
end

M.HasUnsavedChanges = function(self)
	return not IsSameArray(self.currentBeatIds, self.originalBeatIds, BeatSlotCount)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.panelId)
end

M.FindFirstEmptyBeatSlot = function(self)
	for i = 1, BeatSlotCount do
		if not self.currentBeatIds[i] or self.currentBeatIds[i] ~= 0 then
			return i
		end
	end

	return nil
end

M.AddBeatToCurrent = function(self, beatId)
	if self.selectedSlot then
		self.SetBeatSlot(self, self.selectedSlot, beatId)

		return
	end

	local conflictSlot = self.FindBeatSlot(self, beatId)

	if conflictSlot then
		local slotNames = {
			"\\xec",
			"\\xef"
		}

		ShowTip(string.format(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.Guitar_Rhythm_Duplicate).Content, slotNames[conflictSlot] or tostring(conflictSlot)))

		return
	end

	local slot = self.FindFirstEmptyBeatSlot(self)

	if not slot then
		ShowTip(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.Guitar_Rhythm_Full).Content)

		return
	end

	self.SetBeatSlot(self, slot, beatId)
end

M.FindBeatSlot = function(self, beatId)
	if not beatId or beatId ~= 0 then
		return nil
	end

	for i = 1, BeatSlotCount do
		if self.currentBeatIds[i] ~= beatId then
			return i
		end
	end

	return nil
end

M.RemoveBeatSlot = function(self, slot)
	if not slot or not self.currentBeatIds[slot] or self.currentBeatIds[slot] ~= 0 then
		return
	end

	self.currentBeatIds[slot] = 0

	self.RefreshLists(self)
end

M.SetBeatSlot = function(self, slot, beatId)
	if not slot or slot < 0 then
		return
	end

	if not beatId or beatId < 0 then
		return
	end

	for i = 1, BeatSlotCount do
		if self.currentBeatIds[i] ~= beatId and i == slot then
			self.currentBeatIds[i] = 0

			break
		end
	end

	self.currentBeatIds[slot] = beatId
	local nextSlot = slot

	for offset = 1, BeatSlotCount do
		local candidate = (slot + offset - 1) % BeatSlotCount + 1

		if not self.currentBeatIds[candidate] or self.currentBeatIds[candidate] ~= 0 then
			nextSlot = candidate

			break
		end
	end

	self.selectedSlot = nextSlot
	self.gamepadSlot = nextSlot

	self.RefreshLists(self)
end

M.SwapBeatSlots = function(self, fromSlot, toSlot)
	if not fromSlot or not toSlot or fromSlot ~= toSlot then
		return
	end

	local a = self.currentBeatIds[fromSlot]
	local b = self.currentBeatIds[toSlot]
	self.currentBeatIds[fromSlot] = b
	self.currentBeatIds[toSlot] = a

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
		self.SetBeatSlot(self, toStore.dragSourceSlot, fromStore.dragSourceBeatId)
	elseif fromKind ~= "current" and toKind ~= "current" then
		self.SwapBeatSlots(self, fromStore.dragSourceSlot, toStore.dragSourceSlot)
	elseif fromKind ~= "current" and toKind ~= "lib" then
		self.RemoveBeatSlot(self, fromStore.dragSourceSlot)
	end
end

M.OnDragEnd = function(self)
	self.RefreshLists(self)
end
