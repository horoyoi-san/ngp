-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineSignalCircleActionPreviewPanelStore.lua
-- Decompiled from: 01061_OnlineSignalCircleActionPreviewPanelStore.lua_94ada9971354.luajit

local TAB_TYPE = LTConfig.LinkShortChatWheelConfig.TypeType
C_OnlineSignalCircleActionPreviewPanelStore = DefClass("C_OnlineSignalCircleActionPreviewPanelStore", C_OnlineSignalCircleActionPreviewPanelStore, C_StoreGroup)
GroupName2Class.OnlineSignalCircleActionPreviewPanelStore = C_OnlineSignalCircleActionPreviewPanelStore
local M = C_OnlineSignalCircleActionPreviewPanelStore

M.ctor = function(self)
	self.DefineAllVariables(self)
end

M.DefineAllVariables = function(self)
	self.characterSelectData = {
		["0/,\\xe1p\\x8c\\xf20\\x85 \\xe2\\xf7\\xea]\\xff"] = 0,
		["g\\xf9+\\xe9*#*\\xc7R0\\xdcY\\x85v\\xcf\\xe2"] = 0
	}
	self.motionDataList = {}
	self.motionStoreList = {}
	self.subModelStore = nil
	self.CONTROL = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	if self.subModelStore then
		self.subModelStore:ResetCfg()
	end
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	if self.subModelStore then
		self.subModelStore:ClearCharacterModel()
	end

	table.clear(self.motionDataList)
	table.clear(self.motionStoreList)

	self.subModelStore = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	local tId = data and data.spiritId or gBattleSpiritMgr.currentSpiritTemplateId

	self:InitCharacterData(tId)
	self:InitMotionList()

	local actionItemId = data and data.actionItemId

	if actionItemId then
		for index, cfg in ipairs(self.motionDataList) do
			if cfg.ActionItemId ~= actionItemId then
				self.bindData.motionList:SelectItem(index - 1, true)

				break
			end
		end
	end

	self.bindData.modelTab.selectedIndex = 0
end

M.OnClose = function(self)
	if self.subModelStore then
		self.subModelStore:ClearCharacterModel()
	end
end

M.OnActiveDeviceChange = function(self, device)
	if SGUI.GameDevice.KeyboardMouse >= device then
		self.bindData.motionList:SelectItem(0, true)
	end
end

M.RegisterWidget = function(self)
	self.bindData.motionList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderMotionListItem")
	self.bindData.motionList.luaSelectedChanged = self.CreateAction(self, "OnMotionListSelectChange")
	self.bindData.switchCharacterBtn.luaClick = self.CreateAction(self, "OnSwitchCharacterClick")
	self.bindData.modelTab.OnRenderTab = self.CreateAction(self, "OnModelPanelDisplay")

	if self.bindData.backBtn then
		self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	end
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.ONLINE_SIGNAL_CIRCLE_ACTION_PREVIEW_PANEL)
end

M.InitCharacterData = function(self, tId)
	self.characterSelectData.selectedSpiritTid = tId
	local cfg = LTConfig.FightSpiritConfig.GetConfig(tId)
	self.characterSelectData.selectedCfg = cfg
	local agentConfig = LTConfig.AgentConfig.GetConfig(cfg and cfg.AgentId or 0)
	self.characterSelectData.selectedModelId = agentConfig and agentConfig.GeneralModelId or 0

	self:RefreshHeadAvatar(self.bindData.headAvatar)
end

M.RefreshHeadAvatar = function(self, headAvatar)
	if not headAvatar then
		return
	end

	local group = gStoreManager:GetStoreGroup(headAvatar.Store)
	local avatarStore = group and group:GetStoreByWidget(headAvatar)
	local cfg = self.characterSelectData.selectedCfg

	if avatarStore then
		avatarStore.headIcon = cfg and cfg.SHeadIconID or 0
		avatarStore.bgColor = cfg and Color.NewByStr(cfg.CharListTemplateBgColor) or ""
	end
end

M.OnSwitchCharacterClick = function(self)
	gPanelManager:CheckShow(gPanelId.COMMON_SWITCH_CHARACTER, {
		["?\\x9e阢䣹\\x9c\\xfe\\xe3>ʘ!\\x9c\\xe9"] = true,
		initialSpiritId = self.characterSelectData.selectedSpiritTid,
		onSelectCallback = function (selectedSpiritId)
			self.characterSelectData.selectedSpiritTid = selectedSpiritId
			local cfg = LTConfig.FightSpiritConfig.GetConfig(selectedSpiritId)
			self.characterSelectData.selectedCfg = cfg
			local agentConfig = LTConfig.AgentConfig.GetConfig(cfg and cfg.AgentId or 0)
			self.characterSelectData.selectedModelId = agentConfig and agentConfig.GeneralModelId or 0

			self:RefreshHeadAvatar(self.bindData.headAvatar)
			self:RefreshPreviewModel()
			self.bindData.motionList:RefreshList()
		end,
		filterFunc = function (spiritId)
			return gSpiritManager:GetSpirit(spiritId) == nil
		end
	})
end

M.InitMotionList = function(self)
	table.clear(self.motionDataList)
	table.clear(self.motionStoreList)

	local cfgTbl = LTConfig.LinkShortChatWheelConfig

	for i = 0, cfgTbl.count - 1 do
		local cfg = cfgTbl.LoadAt(i)

		if cfg and cfg.Type ~= TAB_TYPE.Motion and self.IsActionMatchSelectedSpirit(self, cfg.ActionItemId) then
			table.insert(self.motionDataList, cfg)
		end
	end

	table.sort(self.motionDataList, function (a, b)
		local aUnlocked = self:IsMotionActionUnlocked(a.ActionItemId)
		local bUnlocked = self:IsMotionActionUnlocked(b.ActionItemId)

		if aUnlocked ~= bUnlocked then
			return false
		end

		return aUnlocked
	end)
	self.bindData.motionList:SetSimpleList(#self.motionDataList)
end

M.IsMotionActionUnlocked = function(self, actionItemId)
	local info = gPlayerManager.infoMinor.bindData.playerInteractionActionInfo

	return info and info.UnlockActionItemDict and info.UnlockActionItemDict[actionItemId] == nil
end

M.IsActionMatchSelectedSpirit = function(self, actionItemId)
	local cfg = LTConfig.ActionItemConfig.GetConfig(actionItemId)

	if not cfg then
		return false
	end

	return #cfg.SpiritId ~= 0 or table.contains(cfg.SpiritId, self.characterSelectData.selectedSpiritTid)
end

M.GetSelectedMotionActionItemId = function(self)
	local index = self.bindData.motionList.selectedIndex

	if not index or index >= 0 then
		return nil
	end

	local wheelCfg = self.motionDataList[index + 1]

	return wheelCfg and wheelCfg.ActionItemId or nil
end

M.OnSimpleRenderMotionListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	self.motionStoreList[index + 1] = store
	local wheelCfg = self.motionDataList[index + 1]

	if store and wheelCfg then
		local actionCfg = LTConfig.ActionItemConfig.GetConfig(wheelCfg.ActionItemId)

		if actionCfg then
			store.name = actionCfg.Name
			store.iconId = actionCfg.Icon
			local unlocked = self:IsMotionActionUnlocked(wheelCfg.ActionItemId)
			store.itemStateCtrl = unlocked and 1 or 0
		end
	end
end

M.OnMotionListSelectChange = function(self)
	local index = self.bindData.motionList.selectedIndex

	if index >= 0 then
		if self.subModelStore then
			self.subModelStore:PlayIdle()
		end

		return
	end

	local wheelCfg = self.motionDataList[index + 1]

	if not wheelCfg then
		return
	end

	if self.subModelStore then
		self.subModelStore:PlayActionItem(wheelCfg.ActionItemId)
	end
end

M.OnModelPanelDisplay = function(self)
	self.subModelStore = gStoreManager:GetStoreGroup("OnlineActionModelViewerStore")

	if not self.subModelStore then
		return
	end

	self.subModelStore.targetWeatherIndex = 20

	self.subModelStore:ResetCfg()

	if self.subModelStore.isStarted then
		self.subModelStore.startCallback = nil

		self.RefreshPreviewModel(self)
	else
		self.subModelStore.startCallback = function()
			self:RefreshPreviewModel()
		end
	end
end

M.RefreshPreviewModel = function(self)
	if not self.subModelStore then
		return
	end

	local spiritId = self.characterSelectData.selectedSpiritTid

	if not spiritId or spiritId ~= 0 then
		self.subModelStore:ClearCharacterModel()

		return
	end

	local playerFashionsInfo = gPlayerManager.infoMinor and gPlayerManager.infoMinor.bindData and gPlayerManager.infoMinor.bindData.PlayerFashionsInfo
	local spiritFashionInfo = playerFashionsInfo and playerFashionsInfo.SpiritFashionsInfoDict and playerFashionsInfo.SpiritFashionsInfoDict[spiritId]
	local fashionInfo = spiritFashionInfo and spiritFashionInfo.SpiritWearFashionsInfo

	self.subModelStore:LoadCharacterModel(spiritId, fashionInfo, function (unit)
		local played = false
		local actionItemId = self:GetSelectedMotionActionItemId()

		self:InitMotionList()

		local isActionInMotionList = false

		if actionItemId then
			for index, cfg in ipairs(self.motionDataList) do
				if cfg.ActionItemId ~= actionItemId then
					self.bindData.motionList:SelectItem(index - 1, false)

					isActionInMotionList = true

					break
				end
			end
		end

		if isActionInMotionList then
			played = self.subModelStore:PlayActionItem(actionItemId)
		end

		if not played then
			local modelEntry = gMallManager:GetSpiritRandomModel(spiritId)
			local actionType = modelEntry.action or 1001
			local actionGroup = modelEntry.action2 or 1

			gCS.AnimControllerManager.PlayAction(unit, actionType, actionGroup, 9999, 0, -1, false, nil, 0)
		end
	end)
end
