-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SeasonGameplayEntrancePanelStore.lua
-- Decompiled from: 00876_SeasonGameplayEntrancePanelStore.lua_18b26402ce55.luajit

local SeasonRaidConfig = LTConfig.SeasonRaidConfig
local SeasonRaidRaidConfig = LTConfig.SeasonRaidRaidConfig
local MessageConfig = LTConfig.MessageConfig
local ConsumableConfig = LTConfig.ConsumableConfig
C_SeasonGameplayEntrancePanelStore = DefClass("C_SeasonGameplayEntrancePanelStore", C_SeasonGameplayEntrancePanelStore, C_StoreGroup)
GroupName2Class.SeasonGameplayEntrancePanelStore = C_SeasonGameplayEntrancePanelStore
local M = C_SeasonGameplayEntrancePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.entranceStore = nil
	self.selectedMode = 0
	self.selectedRaid = 0
	self.modeSelectList = {}
	self.raidList = {}
	self.firstRewardList = {}
	self.mayRewardList = {}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterButtons(self)
	self.RegisterLists(self)
end

M.OnShow = function(self, panelId, data)
	self:BuildModeSelectList()

	local id = self.bindData.entranceTrans.gameObject:GetInstanceID()
	self.entranceStore = gStoreManager:GetStoreGroup("SeasonEntranceTemplate"):GetStoreById(id)
end

M.RegisterButtons = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnClick")
	self.bindData.enterBtn.luaClick = self.CreateAction(self, "OnEnterBtnClick")
end

M.OnExitBtnClick = function(self)
	if self.bindData.selectStageCtrl and self.bindData.selectStageCtrl ~= 1 then
		self.bindData.selectStageCtrl = 0
		self.selectedMode = 0
		self.selectedRaid = 0
	else
		gPanelManager:Close(self.m_Id)
	end
end

M.OnEnterBtnClick = function(self)
	self.bindData.enterBtn.interactable = false
	slot1 = gSpiritManager
	local roles = slot1:GetCurrentFightSpirits()
	local currentRole = roles[1]
	slot3 = gClientToGameDelegate
	local task = slot3:AskEnterSeasonRaid(self.selectedRaid, {
		currentRole.Tid
	})

	task.Callback = function(err)
		self.bindData.enterBtn.interactable = true

		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.RegisterLists = function(self)
	self.bindData.modeSelectList.luaRenderItem = self.CreateAction(self, "OnRenderModeSelectList")
	self.bindData.difficultyChooseList.luaRenderItem = self.CreateAction(self, "OnRenderDifficultyChooseList")
	self.bindData.firstRewardList.luaRenderItem = self.CreateAction(self, "OnRenderFirstRewardList")
	self.bindData.normalRewardList.luaRenderItem = self.CreateAction(self, "OnRenderNormalRewardList")
	self.bindData.modeSelectList.luaClick = self.CreateAction(self, "OnClickModeSelectList")
	self.bindData.difficultyChooseList.luaClick = self.CreateAction(self, "OnClickDifficultyChooseList")
	self.bindData.firstRewardList.luaClick = self.CreateAction(self, "OnClickFirstRewardList")
	self.bindData.normalRewardList.luaClick = self.CreateAction(self, "OnClickNormalRewardList")
end

M.OnRenderModeSelectList = function(self, btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SeasonEntranceTemplate"):GetStoreById(id)

	if store and data.mode then
		store.mode = data.mode - 1
	end
end

M.OnClickModeSelectList = function(self, btn, data)
	self.selectedMode = data.mode

	self.RefreshRaid(self)

	self.bindData.selectStageCtrl = 1
	self.entranceStore.mode = data.mode - 1
end

M.OnRenderDifficultyChooseList = function(self, btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SeasonRaidChooseTab"):GetStoreById(id)

	if store and data.name then
		store.difficultyText = data.name
	end
end

M.OnClickDifficultyChooseList = function(self, btn, data)
	self.selectedRaid = data.id

	self.RefreshRewardList(self)

	self.bindData.difficultyText = data.showName
end

M.OnRenderFirstRewardList = function(self, btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreById(id)

	if store then
		store.quality = data.quality
		store.iconId = data.iconId
		store.count = ""
	end
end

M.OnClickFirstRewardList = function(self, btn, data)
	local itemId = data.ItemId

	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemId = itemId
	})
end

M.OnRenderNormalRewardList = function(self, btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreById(id)

	if store then
		store.quality = data.quality
		store.iconId = data.iconId
		store.count = ""
	end
end

M.OnClickNormalRewardList = function(self, btn, data)
	local itemId = data.ItemId

	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemId = itemId
	})
end

M.RefreshRaid = function(self)
	table.clear(self.raidList)

	for i = 0, SeasonRaidRaidConfig.count - 1 do
		local raidCfg = SeasonRaidRaidConfig.LoadAt(i)

		if raidCfg.Difficulty ~= self.selectedMode then
			local cell = {
				id = raidCfg.Id,
				selected = false,
				name = gString.Format("%02d", #self.raidList + 1),
				showName = raidCfg.Name or ""
			}

			table.insert(self.raidList, cell)
		end
	end

	if next(self.raidList) then
		self.raidList[1].selected = true
		self.selectedRaid = self.raidList[1].id
		self.bindData.difficultyText = self.raidList[1].showName
	end

	self:RefreshRewardList()
	self.bindData.difficultyChooseList:SetList(self.raidList)
end

M.BuildModeSelectList = function(self)
	local openedDifficultyTab = SeasonRaidConfig.RaidModes

	for _, mode in ipairs(openedDifficultyTab) do
		local data = {
			mode = mode
		}

		table.insert(self.modeSelectList, data)
	end

	self.bindData.modeSelectList:SetList(self.modeSelectList)
end

M.RefreshRewardList = function(self)
	if self.selectedRaid == nil then
		local config = SeasonRaidRaidConfig.GetConfig(self.selectedRaid)

		if config then
			table.clear(self.firstRewardList)

			for i, itemId in ipairs(config.FirstFinishedReward) do
				local id = itemId
				local config = ConsumableConfig.GetConfig(id)
				local data = {
					iconId = config.SItemIconId,
					quality = config.Quality,
					ItemId = id
				}

				table.insert(self.firstRewardList, data)
			end

			table.clear(self.mayRewardList)

			for i, itemId in ipairs(config.AllReward) do
				local id = itemId
				local config = ConsumableConfig.GetConfig(id)
				local data = {
					iconId = config.SItemIconId,
					quality = config.Quality,
					ItemId = id
				}

				table.insert(self.mayRewardList, data)
			end

			self.bindData.firstRewardList:SetList(self.firstRewardList)
			self.bindData.normalRewardList:SetList(self.mayRewardList)
		end
	end
end
