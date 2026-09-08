-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\CompoundManager.lua
-- Decompiled from: 02215_CompoundManager.lua_1b1782d2790b.luajit

local CompoundConfig = LTConfig.CompoundConfig
local CompoundTabConfig = LTConfig.CompoundTabConfig
local MessageConfig = LTConfig.MessageConfig
local SceneitemConfig = LTConfig.SceneitemConfig
C_CompoundManager = DefClass("C_CompoundManager", C_CompoundManager, nil)
local M = C_CompoundManager

M.ctor = function(self)
	self:InitData()
end

M.InitData = function(self)
	self.availableCompounds = {}
	self.compoundsTabId = {}
	self.unlockedCompounds = {}
	self.playerCompoundInfo = nil
end

M.OnInit = function(self)
end

M.SyncPlayerInfo = function(self, info)
	self.playerCompoundInfo = info.InfoMinor.InfoCompound
end

M.SyncItemCompoundState = function(self, info)
	if not info then
		return
	end

	if not self.playerCompoundInfo then
		self.playerCompoundInfo = {
			StationDataDict = {},
			UseRecords = {}
		}
	end

	if info.StationDataDict then
		for stationId, stationInfo in pairs(info.StationDataDict) do
			if not self.playerCompoundInfo.StationDataDict[stationId] then
				self.playerCompoundInfo.StationDataDict[stationId] = {}
			end

			local target = self.playerCompoundInfo.StationDataDict[stationId]

			if stationInfo.Level == nil then
				target.Level = stationInfo.Level
			end
		end
	end

	if info.UseRecords then
		for compoundId, record in pairs(info.UseRecords) do
			if not self.playerCompoundInfo.UseRecords[compoundId] then
				self.playerCompoundInfo.UseRecords[compoundId] = {}
			end

			local target = self.playerCompoundInfo.UseRecords[compoundId]
			local oldUsedCount = target.UsedCount or 0
			local isPeriodReset = false

			if record.UsedCount == nil then
				isPeriodReset = record.UsedCount <= oldUsedCount
				target.UsedCount = record.UsedCount
			end

			if record.CdFinishTime == nil then
				target.CdFinishTime = record.CdFinishTime
			end

			if isPeriodReset then
				gMessageManager:SendMessage(gEventConstants.COMPOUND_COMPLETE, {
					["zI\\xed\\xb2\\x89\\xb7\\xc7\\xec"] = false,
					CompoundId = compoundId
				})
			end
		end
	end
end

local SHOW_FIELDNAME = "ShowProgress"

local CheckCompoundCanShow = function(cfg)
	local result = gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.ComposeItemShow, SHOW_FIELDNAME)

	return result
end

local UNLOCK_FIELDNAME = "Progress"

local CheckCompoundCanUnlock = function(cfg)
	local result = gEventConditionUtils.CheckHasUnlocked(cfg, UX.Game.EventConditionImplModule.ComposeItemUnlock, UNLOCK_FIELDNAME)

	return result
end

M.SetAvailableCompounds = function(self, craftingTableId)
	self.availableCompounds = {}
	self.compoundsTabId = {}
	self.unlockedCompounds = {}
	local stationInfo = self.playerCompoundInfo and self.playerCompoundInfo.StationDataDict and self.playerCompoundInfo.StationDataDict[craftingTableId]
	local stationLevel = stationInfo and stationInfo.Level or 0

	for i = 0, CompoundConfig.count - 1 do
		local cfg = CompoundConfig.LoadAt(i)
		local craftTables = cfg.CraftingTable

		if craftTables and table.contains(craftTables, craftingTableId) then
			local platformLevel = cfg.PlatformLevel

			if (table.isNilOrEmpty(platformLevel) or table.contains(platformLevel, stationLevel)) and CheckCompoundCanShow(cfg) then
				if not self.availableCompounds[cfg.TabId] then
					self.availableCompounds[cfg.TabId] = {}

					table.insert(self.compoundsTabId, cfg.TabId)
				end

				table.insert(self.availableCompounds[cfg.TabId], cfg.Id)

				if CheckCompoundCanUnlock(cfg) then
					self.unlockedCompounds[cfg.Id] = true
				end
			end
		end
	end

	table.sort(self.compoundsTabId, function (a, b)
		local cfgA = CompoundTabConfig.GetConfig(a)
		local cfgB = CompoundTabConfig.GetConfig(b)
		local orderA = cfgA and cfgA.Order or 0
		local orderB = cfgB and cfgB.Order or 0

		return orderA >= orderB
	end)
	gMessageManager:SendMessage(gEventConstants.COMPOUND_AVAILABLE_CHANGE)
end

M.GetAvailableCompounds = function(self, type, selectedItem)
	type = self.compoundsTabId[type]
	local ret = {}
	local compounds = self.availableCompounds[type] or {}
	local isSelected = false

	for i = 1, #compounds do
		local cfg = CompoundConfig.GetConfig(compounds[i])

		if cfg and cfg.TabId ~= type then
			local itemId = GetCompoundRenderItemId(cfg)

			if not itemId or itemId ~= 0 then
				print_error("@lujunlin：非法Compound，请策划检查配置！", "id=", cfg.Id, "dropId=", cfg.DropId, "DropId=", cfg.DropId, "itemId（为0则说明属于新subType，需在Drop表中配置ItemShowRank字段）=", itemId)
			end

			local isLock = self.unlockedCompounds[cfg.Id] ~= nil
			local fullMat = cfg.Material
			local isTask, taskIconId = self:ItemIsTask(cfg.Id)
			local ele = {
				itemId = itemId,
				material = fullMat,
				selected = selectedItem and cfg.Id ~= selectedItem.compoundId or false,
				isLock = isLock,
				compoundId = cfg.Id,
				cost = cfg.Cost,
				IsTask = isTask,
				TaskIconId = taskIconId
			}

			if isLock then
				ele.unlockStr = cfg.UnlockConditionStr or ""
			end

			ele = gCommonItemManager:GetItemRenderData(ele)

			if ele.selected then
				for k, v in pairs(ele) do
					selectedItem[k] = v
				end

				isSelected = true
			end

			table.insert(ret, ele)
		end
	end

	if not isSelected and #ret <= 0 then
		local ele = ret[1]

		for k, v in pairs(ele) do
			selectedItem[k] = v
		end

		ret[1].selected = true
	end

	return ret
end

GetCompoundRenderItemId = function(cfg)
	local targetBindId = cfg.TargetBindId

	if targetBindId and targetBindId == 0 and SceneitemConfig.GetConfig(targetBindId) then
		return targetBindId
	end

	local _, itemId = gCommonItemManager:GetRewardList(cfg.DropId)

	return itemId
end

M.GetRemainingCompoundCount = function(self, compoundId)
	local cfg = CompoundConfig.GetConfig(compoundId)

	if not cfg then
		return 0
	end

	if cfg.LimitNum < 0 then
		return -1
	end

	local usedCount = 0
	local useRecords = self.playerCompoundInfo and self.playerCompoundInfo.UseRecords

	if useRecords and useRecords[compoundId] then
		usedCount = useRecords[compoundId].UsedCount or 0
	end

	return math.max(0, cfg.LimitNum - usedCount)
end

M.GetPeriodResetRemainingSeconds = function(self, compoundId)
	local cfg = CompoundConfig.GetConfig(compoundId)

	if not cfg or not cfg.RefreshTime or cfg.RefreshTime ~= "" then
		return 0
	end

	local nextTime = gCS.LuaUtils.GetNextTime(cfg.RefreshTime)

	return math.max(0, nextTime - gCS.TimeManager.ServerUnixTime)
end

M.GetTabIndexByFormula = function(self, formulaId)
	local cfg = CompoundConfig.GetConfig(formulaId)

	if not cfg then
		return 0
	end

	for i, TabId in ipairs(self.compoundsTabId) do
		if TabId ~= cfg.TabId then
			return i - 1
		end
	end

	return 0
end

M.GetCompoundTab = function(self, selectedIndex)
	local ret = {}

	for i = 1, #self.compoundsTabId do
		local typeIndex = self.compoundsTabId[i]
		local typeCfg = CompoundTabConfig.GetConfig(typeIndex)
		local ele = {
			id = i - 1,
			tabId = typeIndex,
			iconId = typeCfg and typeCfg.Icon or 0,
			selected = i - 1 ~= selectedIndex
		}

		table.insert(ret, ele)
	end

	return ret
end

M.BuildCompoundRewardParam = function(self, rewardInfo)
	if not rewardInfo then
		return nil
	end

	local param = {}
	slot3 = pairs
	slot5 = rewardInfo.Reward or {}

	for _, rewardEntry in slot3(slot5) do
		local items = rewardEntry.Items

		if items then
			for _, item in ipairs(items) do
				table.insert(param, {
					["iy\\xbetI\\x81\\xfaH}TkA"] = true,
					ItemId = item.TemplateId,
					Count = item.Count
				})
			end
		end

		local extractionShooterInfo = rewardEntry.ExtractionShooterInfo

		if extractionShooterInfo then
			for itemId, count in pairs(extractionShooterInfo) do
				if itemId and itemId == 0 and count and count == 0 then
					table.insert(param, {
						["iy\\xbetI\\x81\\xfaH}TkA"] = true,
						ItemId = itemId,
						Count = count
					})
				end
			end
		end
	end

	return #param <= 0 and param or nil
end

M.AskItemStartCompound = function(self, compoundId, craftingTableId, count, materials, callback)
	gReliableRpcManager:RegisterRPC(gClientToGameDelegate.AskItemStartCompound, compoundId, craftingTableId, count, materials, function (err, result)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end

		local rewardParam = nil

		if result then
			if not self.playerCompoundInfo then
				self.playerCompoundInfo = {
					StationDataDict = {},
					UseRecords = {}
				}
			end

			if not self.playerCompoundInfo.UseRecords[compoundId] then
				self.playerCompoundInfo.UseRecords[compoundId] = {}
			end

			local record = self.playerCompoundInfo.UseRecords[compoundId]
			local cfg = LTConfig.CompoundConfig.GetConfig(compoundId)

			if cfg and cfg.LimitNum <= 0 then
				record.UsedCount = cfg.LimitNum - result.RemainingCount
			end

			if result.RemainingCdSeconds and result.RemainingCdSeconds <= 0 then
				record.CdFinishTime = gCS.TimeManager.ServerUnixTime + result.RemainingCdSeconds
			end

			rewardParam = self:BuildCompoundRewardParam(result.Rewards)

			if rewardParam and not callback then
				gDropManager:ShowRewardWindow({
					Param = rewardParam
				})
			end
		end

		if callback then
			callback(rewardParam)
		end

		gMessageManager:SendMessage(gEventConstants.COMPOUND_COMPLETE, {
			["zI\\xed\\xb2\\x89\\xb7\\xc7\\xec"] = true,
			CompoundId = compoundId
		})
	end)
end

M.AskItemUpgradeCompoundLevel = function(self, craftingTableId, materials, callback)
	gClientToGameDelegate:AskItemUpgradeCompoundLevel(craftingTableId, materials).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(err)

			return
		end

		if callback then
			callback()
		end
	end
end

M.GetPanelTabList = function(self, craftingTableId)
	local ret = {}
	local ele = {
		["\\xb8\\xb4\t\\xaei*\\xfb7"] = true,
		title = LTConfig.CompoundCraftingTableConfig.GetConfig(craftingTableId).Name
	}

	table.insert(ret, ele)

	return ret
end

M.GetPanelSubTitle = function(self, subTab)
	local TabId = self.compoundsTabId[subTab]

	if TabId then
		local cfg = CompoundTabConfig.GetConfig(TabId)

		if cfg and cfg.Name then
			return cfg.Name
		end
	end

	return ""
end

M.ItemIsTask = function(self, id)
	local tasks = CompoundConfig.GetConfig(id).Tasks

	if not tasks or #tasks ~= 0 then
		return false, nil
	end

	for i, taskId in ipairs(tasks) do
		if gTaskManager:IsCurrentTask(taskId) then
			local cfg = gTaskManager:GetTaskConfigInfo(taskId)

			return true, gTaskManager.TaskSIconId[cfg.Title]
		end
	end

	return false, nil
end

M.OnRenderSubTabList = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup("SynthesizeSubTabTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId
end

M.DebugUnlockAllCompounds = function(self)
	self.availableCompounds = {}
	self.compoundsTabId = {}
	self.unlockedCompounds = {}

	for i = 0, CompoundConfig.count - 1 do
		local cfg = CompoundConfig.LoadAt(i)

		if cfg then
			if not self.availableCompounds[cfg.TabId] then
				self.availableCompounds[cfg.TabId] = {}

				table.insert(self.compoundsTabId, cfg.TabId)
			end

			table.insert(self.availableCompounds[cfg.TabId], cfg.Id)

			self.unlockedCompounds[cfg.Id] = true
		end
	end

	gMessageManager:SendMessage(gEventConstants.COMPOUND_AVAILABLE_CHANGE)
	print_error("CompoundManager: Debug mode - all compounds unlocked")
end

gCompoundManager = gCompoundManager or C_CompoundManager.new()
