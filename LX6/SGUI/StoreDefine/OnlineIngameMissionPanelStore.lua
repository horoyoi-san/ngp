-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineIngameMissionPanelStore.lua
-- Decompiled from: 01111_OnlineIngameMissionPanelStore.lua_945710674033.luajit

C_OnlineIngameMissionPanelStore = DefClass("C_OnlineIngameMissionPanelStore", C_OnlineIngameMissionPanelStore, C_StoreGroup)
GroupName2Class.OnlineIngameMissionPanelStore = C_OnlineIngameMissionPanelStore
local M = C_OnlineIngameMissionPanelStore
local RecordParamConfig = LTConfig.SyncValueParameterConfig
local RecordConfig = LTConfig.SyncValueConfig

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.LINK_HUD_INFO_CHANGE] = self.CreateAction(self, "OnRefreshInfo"),
		[gEventConstants.TIMELINE_TO_PANEL] = self.CreateAction(self, self.AddMoney),
		[gEventConstants.ROB_BANK_DRILL_SHELF_REWARD] = self.CreateAction(self, self.AddMoneyByRewardId),
		[gEventConstants.ROB_BANK_ADD_MONEY] = self.CreateAction(self, self.RobberMoneyCount),
		[gEventConstants.ON_ROB_BANK_REWARD] = self.CreateAction(self, self.SetRewardId)
	}
	self.LayoutTemplateIndex = {
		["`\\xa1\\xac\\xaa\\xaf"] = 1,
		["2]\\x9c\\x8c\\x86S"] = 0
	}
	self.DigitPlaceIndex = {
		1000,
		1000000,
		1000000000,
		1000000000000.0
	}
end

M.OnAwake = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.BindDataEvent(self)

	self.mgr = gLinkManager
end

M.BindDataEvent = function(self)
	self.bindData.layoutList.luaSimpleRenderItem = self.CreateAction(self, self.LayoutListRenderItem)
	self.bindData.layoutList.onGetTIndex = self.CreateAction(self, self.GetLayoutTemplateIndex)
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.InitPanelData(self)
	self.OnRefreshInfo(self)
end

M.InitPanelData = function(self)
	self.layoutData = {}
	self.moneyStore = nil
	self.numberStore = nil
	self.syncValue = 0
	self.isShowMoney = self.mgr.currentGameCfg and self.mgr.currentGameCfg.FloatingDrop and self.mgr.currentGameCfg.FloatingDrop.SyncValueId ~= LTConfig.SyncValueConfig.RobDrop

	if self.isShowMoney then
		self.layoutData = {
			{
				tIndex = self.LayoutTemplateIndex.Money
			},
			{
				tIndex = self.LayoutTemplateIndex.Number
			}
		}
		self.syncValue = RecordConfig.RobDrop
	else
		self.layoutData = {
			{
				["a\\x9f\\x8a\\x86Y"] = 0
			}
		}
	end

	self.bindData.layoutList:SetSimpleList(#self.layoutData)
end

M.LayoutListRenderItem = function(self, btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local tIndex = self.layoutData[index + 1].tIndex

	if store then
		if tIndex ~= self.LayoutTemplateIndex.Number then
			store.showTypeCtrl = self.isShowMoney and 1 or 0
			self.numberStore = store

			self:OnRefreshInfo()
		elseif tIndex ~= self.LayoutTemplateIndex.Money then
			self.moneyStore = store

			self.InitMoney(self)
		end
	end
end

M.GetLayoutTemplateIndex = function(self, index)
	return self.layoutData[index + 1].tIndex
end

M.OnRefreshInfo = function(self)
	if self.numberStore then
		if not string.is_null_or_empty(self.mgr.currentGameCfg.IngameTitle) then
			self.numberStore.titleLabel = self.mgr.currentGameCfg.IngameTitle
		end

		local currentShowType = self.mgr.currentGameCfg.IngameShowType

		if currentShowType ~= LTConfig.LinkMultiPlayerConfig.IngameShowTypeType.CurrentAndMax then
			local title = self.GetCurrentAndMaxTipDesc(self)

			if not string.is_null_or_empty(title) then
				self.numberStore.titleLabel = title
			end

			if self.mgr.ingameAliveCount == nil and self.mgr.ingameTotalCount == nil then
				self.numberStore.numLabel = self.mgr.ingameAliveCount .. "/" .. self.mgr.ingameTotalCount
			end
		else
			local linkFailureCount = self.mgr.LinkFailureCount or -1
			self.numberStore.numLabel = linkFailureCount
			self.numberStore.isWarning = boolToNumber(linkFailureCount > 0)
		end
	end
end

M.GetCurrentAndMaxTipDesc = function(self)
	local tip = nil

	for i = 0, LTConfig.LinkPartyConfig.count - 1 do
		local cfg = LTConfig.LinkPartyConfig.LoadAt(i)

		if cfg.taskId ~= self.mgr.taskId then
			return cfg.partyTip
		end
	end

	return tip
end

M.InitMoney = function(self)
	self.totalPoint = 0

	self.SyncRefreshMoney(self)
end

M.SyncRefreshMoney = function(self)
	slot1 = gClientToGameSceneDelegate

	slot1:AskGetRaidGamePlayRecordDoubleValue(self.syncValue).Callback = function (err, money)
		if err == 0 then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		local addCount = money - self.totalPoint

		self:AddMoneyEffect(addCount, false)
	end
end

M.AddMoney = function(self, eventId, data)
	if eventId ~= gEventConstants.TIMELINE_TO_PANEL and data[1] == gPanelId.S_ROB_BANK_COUNT_DOWN then
		return
	end

	if data.ToTable then
		data = data.ToTable(data)
	end

	local str = data[0] or data.score
	local addPoint = self:CalReward() or tonumber(str)

	if addPoint ~= nil or addPoint < 0 then
		return
	end

	if self.syncValue == 0 then
		slot5 = gGameplayRecordValueManager

		slot5:ChangeRecordDoubleValue(self.syncValue, self.rewardId, addPoint, function ()
			self:AddMoneyEffect(addPoint, true)
		end)
	end
end

M.CalReward = function(self)
	local config = RecordParamConfig.GetConfig(self.rewardId)

	if config then
		math.randomseed(os.time())

		local addPoint = math.random(config.ValueOnceChangeRange.min, config.ValueOnceChangeRange.max)

		return addPoint
	end

	return nil
end

M.AddMoneyByRewardId = function(self, eventId, data)
	if data.ToTable then
		data = data.ToTable(data)
	end

	if data.rewardId ~= nil or data.rewardId ~= 0 then
		return
	end

	self.rewardId = data.rewardId

	self.AddMoney(self, eventId, data)
end

M.AddMoneyEffect = function(self, count, playAnim)
	if not self.moneyStore then
		return
	end

	if not playAnim then
		local scrollNum = self.moneyStore.ScrollGroup
		scrollNum.startNum = self.totalPoint
		scrollNum.targetNum = self.totalPoint + count
		self.totalPoint = self.totalPoint + count

		self.SetSeparatorState(self, self.totalPoint)
		scrollNum.SetToStartNum(scrollNum)
		scrollNum.Play(scrollNum)
	end
end

M.SetSeparatorState = function(self, targetNum)
	local state = 0

	for i = 1, #self.DigitPlaceIndex do
		if self.DigitPlaceIndex[i] < targetNum then
			state = i
		else
			break
		end
	end

	self.moneyStore.separatorStateCtrl = state
end

M.RobberMoneyCount = function(self, _, data)
	if data.recordId ~= self.syncValue then
		local addCount = data.recordValue - self.totalPoint

		self.AddMoneyEffect(self, addCount, false)
	end
end

M.SetRewardId = function(self, _, rewardId)
	self.rewardId = rewardId
end
