local SeasonRaidConfig = LTConfig.SeasonRaidConfig
local SeasonRaidRaidConfig = LTConfig.SeasonRaidRaidConfig
local MessageConfig = LTConfig.MessageConfig
local ConsumableConfig = LTConfig.ConsumableConfig
C_SeasonGameplayEntrancePanelStore = DefClass("C_SeasonGameplayEntrancePanelStore", C_SeasonGameplayEntrancePanelStore, C_StoreGroup)
GroupName2Class.SeasonGameplayEntrancePanelStore = C_SeasonGameplayEntrancePanelStore
local M = C_SeasonGameplayEntrancePanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.entranceStore = nil
	self.selectedMode = 0
	self.selectedRaid = 0
	self.modeSelectList = {}
	self.raidList = {}
	self.firstRewardList = {}
	self.mayRewardList = {}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterButtons()
	self:RegisterLists()
end

function M:OnShow(panelId, data)
	self:BuildModeSelectList()

	local id = self.bindData.entranceTrans.gameObject:GetInstanceID()
	self.entranceStore = gStoreManager:GetStoreGroup("SeasonEntranceTemplate"):GetStoreById(id)
end

function M:RegisterButtons()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnClick")
	self.bindData.enterBtn.luaClick = self:CreateAction("OnEnterBtnClick")
end

function M:OnExitBtnClick()
	if self.bindData.selectStageCtrl and self.bindData.selectStageCtrl == 1 then
		self.bindData.selectStageCtrl = 0
		self.selectedMode = 0
		self.selectedRaid = 0
	else
		gPanelManager:Close(self.m_Id)
	end
end

function M:OnEnterBtnClick()
	self.bindData.enterBtn.interactable = false
	local roles = gSpiritManager:GetCurrentFightSpirits()
	local currentRole = roles[1]
	local task = gClientToGameDelegate:AskEnterSeasonRaid(self.selectedRaid, {
		currentRole.Tid
	})

	function task.Callback(err)
		self.bindData.enterBtn.interactable = true

		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:RegisterLists()
	self.bindData.modeSelectList.luaRenderItem = self:CreateAction("OnRenderModeSelectList")
	self.bindData.difficultyChooseList.luaRenderItem = self:CreateAction("OnRenderDifficultyChooseList")
	self.bindData.firstRewardList.luaRenderItem = self:CreateAction("OnRenderFirstRewardList")
	self.bindData.normalRewardList.luaRenderItem = self:CreateAction("OnRenderNormalRewardList")
	self.bindData.modeSelectList.luaClick = self:CreateAction("OnClickModeSelectList")
	self.bindData.difficultyChooseList.luaClick = self:CreateAction("OnClickDifficultyChooseList")
	self.bindData.firstRewardList.luaClick = self:CreateAction("OnClickFirstRewardList")
	self.bindData.normalRewardList.luaClick = self:CreateAction("OnClickNormalRewardList")
end

function M:OnRenderModeSelectList(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SeasonEntranceTemplate"):GetStoreById(id)

	if store and data.mode then
		store.mode = data.mode - 1
	end
end

function M:OnClickModeSelectList(btn, data)
	self.selectedMode = data.mode

	self:RefreshRaid()

	self.bindData.selectStageCtrl = 1
	self.entranceStore.mode = data.mode - 1
end

function M:OnRenderDifficultyChooseList(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("SeasonRaidChooseTab"):GetStoreById(id)

	if store and data.name then
		store.difficultyText = data.name
	end
end

function M:OnClickDifficultyChooseList(btn, data)
	self.selectedRaid = data.id

	self:RefreshRewardList()

	self.bindData.difficultyText = data.showName
end

function M:OnRenderFirstRewardList(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreById(id)

	if store then
		store.quality = data.quality
		store.iconId = data.iconId
		store.count = ""
	end
end

function M:OnClickFirstRewardList(btn, data)
	local itemId = data.ItemId

	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemId = itemId
	})
end

function M:OnRenderNormalRewardList(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreById(id)

	if store then
		store.quality = data.quality
		store.iconId = data.iconId
		store.count = ""
	end
end

function M:OnClickNormalRewardList(btn, data)
	local itemId = data.ItemId

	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemId = itemId
	})
end

function M:RefreshRaid()
	table.clear(self.raidList)

	for i = 0, SeasonRaidRaidConfig.count - 1 do
		local raidCfg = SeasonRaidRaidConfig.LoadAt(i)

		if raidCfg.Difficulty == self.selectedMode then
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

function M:BuildModeSelectList()
	local openedDifficultyTab = SeasonRaidConfig.RaidModes

	for _, mode in ipairs(openedDifficultyTab) do
		local data = {
			mode = mode
		}

		table.insert(self.modeSelectList, data)
	end

	self.bindData.modeSelectList:SetList(self.modeSelectList)
end

function M:RefreshRewardList()
	if self.selectedRaid ~= nil then
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
