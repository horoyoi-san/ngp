-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MACluePanelStore.lua
-- Decompiled from: 01794_MACluePanelStore.lua_d6584893a7f9.luajit

C_MACluePanelStore = DefClass("C_MACluePanelStore", C_MACluePanelStore, C_StoreGroup)
GroupName2Class.MACluePanelStore = C_MACluePanelStore
local M = C_MACluePanelStore
local MartialArtistRumorConfig = LTConfig.MartialArtistRumorConfig
local MartialArtistConfig = LTConfig.MartialArtistConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.TypeMapToSlot = {
		[MartialArtistRumorConfig.SlotTypeType.who] = "mapuzzle1",
		[MartialArtistRumorConfig.SlotTypeType.what] = "mapuzzle2",
		[MartialArtistRumorConfig.SlotTypeType.where] = "mapuzzle3"
	}
	self.TypeMapToTitle = {
		[MartialArtistRumorConfig.SlotTypeType.who] = "ClueTItleWho",
		[MartialArtistRumorConfig.SlotTypeType.what] = "ClueTItleWhat",
		[MartialArtistRumorConfig.SlotTypeType.where] = "ClueTItleWhere"
	}
	self.TAB_TYPE = {
		["\\xafDJ"] = 0,
		["OX"] = 4,
		["\\xb9@I"] = 1,
		["M\n\\o"] = 3,
		["z\\x86\\x87\\x9d\\x93"] = 2
	}
	self.TAB_TYPE_MAP_TO_SLOT_TYPE = {
		[self.TAB_TYPE.WHO] = MartialArtistRumorConfig.SlotTypeType.who,
		[self.TAB_TYPE.WHERE] = MartialArtistRumorConfig.SlotTypeType.where,
		[self.TAB_TYPE.WHAT] = MartialArtistRumorConfig.SlotTypeType.what
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.modeCtrlEnum = {
		["\\xca\\xce7\\xe2"] = 1,
		["T_\\xc0\\xb8\\x96\t\\xac\r\\xc7\\xef"] = 3,
		["|#tW"] = 2,
		["G\\x83\\x83\\x82M"] = 0
	}
	self.btnCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.haveClueCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.modeCtrlEnum = nil
	self.btnCtrlEnum = nil
	self.haveClueCtrlEnum = nil
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
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.InitMAClue(self, data)

	self.isShow = true
end

M.OnClose = function(self)
	self.clueMapBackgroundInfo = nil
	self.isShow = false

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	if self.setTimer then
		self.setTimer:Stop()

		self.setTimer = nil
	end

	self.fuxiBridge.CancelRequests(self.fuxiBridge.GetPendingRequestIds(), nil)
	self.fuxiBridge.ClearPendingRequestIds()

	if self.finished then
		local raidId = gMapManager:GetParentRaidId(gMapSystem.lastRaidId)
		local indoorId = gMapSystem.lastIndoorId

		if indoorId <= 0 then
			local indoorCfg = LTConfig.IndoorConfig.GetConfig(indoorId)

			if indoorCfg then
				raidId = indoorCfg.ParentRaid or LTConfig.RaidConfig.WorldMap
			else
				raidId = LTConfig.RaidConfig.WorldMap
			end
		end

		gMapUtils:CheckRaidCanOpenMap({
			MapRaidId = raidId,
			autoSelectGpsId = gGpsTools.GetGpsId(EMapElementType.FightSkillFromNpc, self.wuxueId)
		})
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.isGamepadMode = SGUI.GameDevice.KeyboardMouse <= device
	local rumorId = self.isGamepadMode and self.rumors[self.selectedIndex] or self.dragRumorId

	self:RefreshHighlight(rumorId)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_MARTIAL_ARTIST_SINGLE_RUMOR_SLOT_INFO_CHANGED] = self.CreateAction(self, "OnSingleSlotInfoChanged"),
		[gEventConstants.ON_MARTIAL_ARTIST_RUMOR_BACKPACK_CHANGED] = self.CreateAction(self, "RefreshContent")
	}
end

M.OnSingleSlotInfoChanged = function(self, eventId, wuxueId)
	if wuxueId ~= self.wuxueId then
		self:RefreshSlotInfo()
		self.bindData.clueList:RefreshList()
	end
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.deleteBtn.luaClick = self.CreateAction(self, self.OnClickDeleteBtn)
	self.bindData.clueList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderClueListItem)
	self.bindData.clueList.luaSelectedChanged = self.CreateAction(self, self.OnClueListSelectChanged)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTabListItem)
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, self.OnTabListSelectChanged)
	self.SlotNameToType = {
		[self.bindData.mapuzzle1.name] = MartialArtistRumorConfig.SlotTypeType.who,
		[self.bindData.mapuzzle2.name] = MartialArtistRumorConfig.SlotTypeType.what,
		[self.bindData.mapuzzle3.name] = MartialArtistRumorConfig.SlotTypeType.where
	}
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(gPanelId.CLUE_PANEL)
end

M.OnClickConfirmBtn = function(self)
	if self.exitCount > 3 and not self.finished then
		self.finished = true
		slot1 = gClientToGameDelegate

		slot1:AskCombineRumors(self.wuxueId).Callback = function (errorId, drawStart, drawEnd)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)
				self:ProcessConfirmRes(false)

				return
			end

			if self.isShow then
				self:ProcessConfirmRes(true)
			end
		end
	end
end

M.OnClickDeleteBtn = function(self)
	if self.exitCount <= 0 and not self.finished then
		if self.slotInfo then
			for slotType, rumorId in pairs(self.slotInfo) do
				slot6 = gClientToGameDelegate

				slot6:AskRemoveRumorFromSlot(self.wuxueId, slotType).Callback = function (errorId, drawStart, drawEnd)
					if errorId == LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(errorId)

						return
					end
				end
			end
		end

		self.fuxiBridge.CancelRequests(self.fuxiBridge.GetPendingRequestIds(), nil)
		self.fuxiBridge.ClearPendingRequestIds()
	end
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local data = self.tabList[index + 1]

	if not data then
		return
	end

	store.title = data.title
end

M.OnTabListSelectChanged = function(self, list)
	local data = self.tabList[list.selectedIndex + 1]

	if not data then
		return
	end

	self.ChangeListContent(self, data)
end

M.OnSimpleRenderClueListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local rumorId = self.rumors[index + 1]

	if not rumorId then
		return
	end

	local rumorCfg = MartialArtistRumorConfig.GetConfig(rumorId)

	if rumorCfg then
		store.title = rumorCfg.Title
		store.desc = rumorCfg.Description
		store.from = rumorCfg.SourceText
		store.tagCtrl = 0
		local typeTile = self.TypeMapToTitle[rumorCfg.SlotType]
		store.tag = MartialArtistConfig[typeTile] or ""
		store.guideID = rumorCfg.GuideId
		local backgroundInfo = self:GetClueBackgroundInfo(rumorId, rumorCfg)
		store.typeCtrl = backgroundInfo.type - 1
		store.background = backgroundInfo.backgroundIcon or 0
	end

	local childIndex = index
	local interactable = not gMartialArtistManager:IsRumorEquipped(rumorId)
	store.disCtrl = interactable and 0 or 1
	btn.draggable = interactable
	btn.luaBeginDrag = self:CreateActionWithArgs("OnRumorBeginDrag", {
		index = childIndex,
		rumorId = rumorId
	})
	btn.luaEndDrag = self:CreateActionWithArgs("OnRumorEndDrag", {
		index = childIndex,
		rumorId = rumorId
	})
	store.ctrlBtn.interactable = interactable
	store.ctrlBtn.luaClick = self:CreateAction("OnRumorClueGamepadClick")
end

M.OnClueListSelectChanged = function(self, list)
	self.selectedIndex = list.selectedIndex + 1

	if not self.isGamepadMode then
		return
	end

	local rumorId = self.rumors[self.selectedIndex]

	self.RefreshHighlight(self, rumorId)
end

M.RefreshHighlight = function(self, rumorId)
	local rumorCfg = MartialArtistRumorConfig.GetConfig(rumorId or 0)

	if rumorCfg then
		local slotType = rumorCfg.SlotType

		for type, bindName in pairs(self.TypeMapToSlot) do
			if bindName then
				local widget = self.bindData[bindName]
				local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

				if store then
					store.showhighlightCtrl = type ~= slotType and 1 or 0
				end
			end
		end
	end
end

M.OnRumorClueGamepadClick = function(self)
	if self.selectedIndex > 0 and self.isGamepadMode then
		local rumorId = self.rumors[self.selectedIndex]
		local success, btn = self.bindData.clueList:TryGetChildAt(self.selectedIndex - 1, nil)

		if rumorId and success and btn and btn.draggable then
			self.CancelDrag(self)

			local rumorCfg = MartialArtistRumorConfig.GetConfig(rumorId)

			if rumorCfg then
				local slotType = rumorCfg.SlotType
				local bindName = self.TypeMapToSlot[slotType]

				if bindName then
					local widget = self.bindData[bindName]
					local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

					if store then
						store.showhighlightCtrl = 0
					end
				end
			end

			if not self.finished then
				local slotType = rumorCfg.SlotType
				local exitRumorId = self.slotInfo[slotType]

				if slotType and exitRumorId == rumorId then
					slot7 = gClientToGameDelegate

					slot7:AskPlaceRumorInSlot(self.wuxueId, slotType, rumorId).Callback = function (errorId, drawStart, drawEnd)
						if errorId == LTConfig.MessageConfig.Ok then
							gDisplayMessageMgr:DisplayServerMessageId(errorId)

							return
						end
					end
				end
			end

			self.bindData.clueList:RefreshList()
		end
	end
end

M.OnRumorBeginDrag = function(self, data)
	self.isDragging = true
	self.dragRumorId = data.rumorId

	self:RefreshHighlight(self.dragRumorId)

	local success, btn = self.bindData.clueList:TryGetChildAt(data.index, nil)

	if success and btn then
		SGUI.Utils.AddTopCanvasToWidget(btn)
	end
end

M.CancelDrag = function(self)
	if self.isDragging then
		self.isDragging = false
	end
end

M.OnRumorEndDrag = function(self, data, dropWidget)
	local success, btn = self.bindData.clueList:TryGetChildAt(data.index, nil)

	if success and btn then
		SGUI.Utils.RemoveTopCanvasToWidget(btn)
	end

	if not self.isDragging then
		SGUI.Utils.RefreshChildMask(self.bindData.clueList)

		return
	end

	self.isDragging = false
	local rumorCfg = MartialArtistRumorConfig.GetConfig(self.dragRumorId or 0)

	if rumorCfg then
		local slotType = rumorCfg.SlotType
		local bindName = self.TypeMapToSlot[slotType]

		if bindName then
			local widget = self.bindData[bindName]
			local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

			if store then
				store.showhighlightCtrl = 0
			end
		end
	end

	if not self.finished and self.dragRumorId ~= data.rumorId and dropWidget then
		local slotType = rumorCfg.SlotType
		local exitRumorId = self.slotInfo[slotType]

		if slotType and exitRumorId == self.dragRumorId then
			slot8 = gClientToGameDelegate

			slot8:AskPlaceRumorInSlot(self.wuxueId, slotType, self.dragRumorId).Callback = function (errorId, drawStart, drawEnd)
				if errorId == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end
			end
		end
	end

	self.dragRumorId = nil

	SGUI.Utils.RefreshChildMask(self.bindData.clueList)
	self.bindData.clueList:RefreshList()
end

M.InitMAClue = function(self, data)
	self.fuxiBridge = L50.MartialArtist.MartialArtistBridge
	self.wuxueId = data.wuxueId
	self.finished = false
	self.selectedIndex = -1
	self.isGamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	self:InitTabList()

	self.successIconId = 0
	self.clueMapBackgroundInfo = {}

	if self.wuxueId and self.wuxueId <= 0 then
		self:RefreshSlotInfo()
		self:RefreshContent()

		local wuxueMapCfg = LTConfig.WuxueMapConfig.GetConfig(self.wuxueId)
		self.successIconId = wuxueMapCfg and wuxueMapCfg.UnlockBanner or 0

		if wuxueMapCfg and wuxueMapCfg.AgentProfile <= 0 then
			local profileCfg = LTConfig.ProfileAgentProfileConfig.GetConfig(wuxueMapCfg.AgentProfile)
			self.bindData.name = profileCfg and profileCfg.Name or ""
		end
	end

	self.bindData.image = LTConfig.MartialArtistConfig.RumorDefaultPic
end

M.RefreshSlotInfo = function(self)
	local info = gMartialArtistManager:GetSlotInfo(self.wuxueId)
	self.slotInfo = info and info.Slots or {}
	local initSlots = {}
	self.exitCount = 0

	if self.slotInfo then
		for slotType, rumorId in pairs(self.slotInfo) do
			self.InitMAPuzzle(self, slotType, rumorId)
			table.insert(initSlots, slotType)
		end
	end

	for k, v in pairs(self.TypeMapToSlot) do
		if not table.contains(initSlots, k) then
			self.InitMAPuzzle(self, k, nil)
		end
	end

	self.bindData.confirmBtn.interactable = self.exitCount > 3 and not self.finished
	self.bindData.deleteCtrl = self.exitCount <= 0 and not self.finished and 0 or 1
	self.bindData.modeCtrl = self.modeCtrlEnum.normal
end

M.InitMAPuzzle = function(self, slotType, rumorId)
	local bindName = self.TypeMapToSlot[slotType]

	if bindName then
		local widget = self.bindData[bindName]
		local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

		if store then
			if rumorId and rumorId <= 0 then
				store.haveClueCtrl = 0
				local rumorCfg = MartialArtistRumorConfig.GetConfig(rumorId)
				store.unlockTitle = rumorCfg and rumorCfg.Title
				self.exitCount = self.exitCount + 1
			else
				store.haveClueCtrl = 1
				local typeTile = self.TypeMapToTitle[slotType]
				store.lockTitle = MartialArtistConfig[typeTile]
			end
		end
	end
end

M.ProcessConfirmRes = function(self, success)
	if success then
		self.bindData.modeCtrl = self.modeCtrlEnum.success
		self.bindData.confirmBtn.interactable = false
		self.bindData.deleteCtrl = 1
		self.bindData.image = self.successIconId
	else
		self.bindData.modeCtrl = self.modeCtrlEnum.generating
		self.bindData.confirmBtn.interactable = false
		self.bindData.deleteCtrl = 1
		local who = self.slotInfo[MartialArtistRumorConfig.SlotTypeType.who]
		local where = self.slotInfo[MartialArtistRumorConfig.SlotTypeType.where]
		local what = self.slotInfo[MartialArtistRumorConfig.SlotTypeType.what]
		local requestObjectName = string.format("MartialArtistRumorFail_who%d_where%d_what%d", who, where, what)

		if self.timer then
			self.timer:Stop()

			self.timer = nil
		end

		slot6 = self.bindData.webImage

		slot6:CleanUp()
		self.fuxiBridge.GenerateImage("shuimo_xiansuo", who, where, what, requestObjectName, true, function (data)
			if data and data.RequestId then
				if self.isShow then
					self.requestId = data.RequestId

					self:StartWaitingTimer()
				else
					self.fuxiBridge.CancelRequests(self.fuxiBridge.GetPendingRequestIds(), nil)
					self.fuxiBridge.ClearPendingRequestIds()
				end
			elseif self.isShow then
				self:ProcessConfirmFailRes()
			end
		end)
	end
end

M.StartWaitingTimer = function(self)
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self.timer = Timer.New(function ()
		if self.isShow then
			self.fuxiBridge.GetAllPendingResults(function (data)
				if not data then
					print_warn("MACluePanelStore：生图失败，获取不到当前生成信息")
					self:ProcessConfirmFailRes()

					return
				end

				local ids = data.RequestIds and data.RequestIds:ToTable()

				if ids and #ids <= 0 then
					local foundIndex = nil

					for i = 1, #ids do
						if ids[i] ~= self.requestId then
							foundIndex = i

							break
						end
					end

					if not foundIndex and #ids ~= 1 then
						foundIndex = 1
					end

					local failed = true
					local imageData = data.Entries:ToTable()

					if foundIndex then
						local requestImageData = imageData[foundIndex]

						if requestImageData.Code ~= 200 then
							failed = false

							if requestImageData.Data and not string.is_null_or_empty(requestImageData.Data.Images) then
								self.fuxiBridge.ClearPendingRequestIds()

								local url = requestImageData.Data.Images

								if self.setTimer then
									self.setTimer:Stop()
								end

								self.setTimer = Timer.New(function ()
									if self.isShow then
										self:ProcessConfirmFailRes(url)
									end
								end, 2):Start()
							else
								self:StartWaitingTimer()
							end
						else
							print_warn("MACluePanelStore：生图失败，code:" .. tostring(requestImageData.Code))
						end
					end

					if failed then
						self.fuxiBridge.CancelRequests(self.fuxiBridge.GetPendingRequestIds(), nil)
						self.fuxiBridge.ClearPendingRequestIds()
						self:ProcessConfirmFailRes()
						print_warn("MACluePanelStore：生图失败，没有获取到当前图片信息")
					end
				else
					self:StartWaitingTimer()
				end
			end)
		end
	end, 1):Start()
end

M.ProcessConfirmFailRes = function(self, url)
	self.finished = false
	self.bindData.modeCtrl = self.modeCtrlEnum.fail
	self.bindData.confirmBtn.interactable = false
	self.bindData.deleteCtrl = 0

	if url then
		self.bindData.webImage.url = url
	end
end

M.InitTabList = function(self)
	self.tabList = {
		{
			id = self.TAB_TYPE.ALL,
			title = LTConfig.MartialArtistConfig.BackpackAllTitle
		},
		{
			id = self.TAB_TYPE.WHO,
			title = LTConfig.MartialArtistConfig.BackpackWhoTitle
		},
		{
			id = self.TAB_TYPE.WHERE,
			title = LTConfig.MartialArtistConfig.BackpackWhereTitle
		},
		{
			id = self.TAB_TYPE.WHAT,
			title = LTConfig.MartialArtistConfig.BackpackWhatTitle
		},
		{
			id = self.TAB_TYPE.USED,
			title = LTConfig.MartialArtistConfig.BackpackUsedTitle
		}
	}
	self.curType = nil

	self.bindData.tabList:SetSimpleList(#self.tabList)
	self.bindData.tabList:SelectItem(0, true)
end

M.ChangeListContent = function(self, data)
	if data and self.curType == data.id then
		self.curType = data.id

		self.RefreshContent(self)
	end
end

M.RefreshContent = function(self)
	self.rumors = {}

	if self.curType ~= self.TAB_TYPE.ALL then
		self.rumors = gMartialArtistManager:GetAllRumorsInBackpack(true)
	elseif self.curType ~= self.TAB_TYPE.USED then
		self.rumors = gMartialArtistManager:GetAllEquipRumors()
	else
		local slotType = self.TAB_TYPE_MAP_TO_SLOT_TYPE[self.curType]

		if slotType then
			self.rumors = gMartialArtistManager:GetAllRumorsInBackpackBySlotType(slotType, true)
		end
	end

	self.bindData.clueList:SetSimpleList(#self.rumors)
end

M.GetClueBackgroundInfo = function(self, id, rumorCfg)
	local info = self.clueMapBackgroundInfo[id]

	if not info then
		info = {}

		math.randomseed(os.clock())

		info.type = math.random(1, 3)

		if rumorCfg.SlotType ~= MartialArtistRumorConfig.SlotTypeType.where then
			info.backgroundIcon = MartialArtistRumorConfig.ClueBackgroundIconWhere[info.type]
		elseif rumorCfg.SlotType ~= MartialArtistRumorConfig.SlotTypeType.what then
			info.backgroundIcon = MartialArtistRumorConfig.ClueBackgroundIconWhat[info.type]
		elseif rumorCfg.SlotType ~= MartialArtistRumorConfig.SlotTypeType.who then
			info.backgroundIcon = MartialArtistRumorConfig.ClueBackgroundIconWho[info.type]
		end

		self.clueMapBackgroundInfo[id] = info
	end

	return info
end
