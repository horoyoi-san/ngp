-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieBrandSelectPanelStore.lua
-- Decompiled from: 01250_YanjieBrandSelectPanelStore.lua_9e1205e8d9a5.luajit

C_YanjieBrandSelectPanelStore = DefClass("C_YanjieBrandSelectPanelStore", C_YanjieBrandSelectPanelStore, C_StoreGroup)
GroupName2Class.YanjieBrandSelectPanelStore = C_YanjieBrandSelectPanelStore
local M = C_YanjieBrandSelectPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.isLockedCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.isLockedCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	self.InitModel(self, args)
	self.InitView(self)
end

M.InitModel = function(self, args)
	self.stageId = args.stageId
end

M.InitView = function(self)
	self.endorsementOptionIdList = self:GetEndorsementOptionIdList()

	self.bindData.list:SetSimpleList(#self.endorsementOptionIdList)

	local targetIndex = math.ceil(#self.endorsementOptionIdList / 2)

	self.bindData.list:GoToIndex(targetIndex - 1, true)
end

M.GetEndorsementOptionIdList = function(self)
	local viewDataList = {}
	local count = LTConfig.GrowthEndorsementOptionConfig.count

	for i = 0, count - 1 do
		local endorsementOptionCfg = LTConfig.GrowthEndorsementOptionConfig.LoadAt(i)

		if endorsementOptionCfg.StageId ~= self.stageId then
			table.insert(viewDataList, endorsementOptionCfg.Id)
		end
	end

	return viewDataList
end

M.CheckEndorsementOptionIdHasUnlocked = function(self, id)
	local endorsementOptionCfg = LTConfig.GrowthEndorsementOptionConfig.GetConfig(id)

	return gEventConditionUtils.CheckHasUnlocked(endorsementOptionCfg, UX.Game.EventConditionImplModule.EndorsementOption)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
end

M.RegisterWidget = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnClickExitButton)
	self.bindData.confirmButton.luaClick = self.CreateAction(self, self.OnClickConfirmButton)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.bindData.list.luaSelectedChanged = self.CreateAction(self, self.OnSelectedChange)
end

M.OnClickExitButton = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnClickConfirmButton = function(self)
	local selectedIndex = self.bindData.list.selectedIndex
	local id = self.endorsementOptionIdList[selectedIndex + 1]
	slot3 = gClientToGameDelegate

	slot3:AskReceiveFansStageLvReward(id).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		local receivedStageLvRewards = gPlayerManager.infoMinor.bindData.receivedStageLvRewards
		receivedStageLvRewards[self.stageId] = id

		gMessageManager:SendMessage(gEventConstants.ON_ENDORSEMENT_STAGE_LEVEL_REWARD_CHANGE)
		gPanelManager:CheckShow(gPanelId.YANJIE_BRAND_GET_PANEL, {
			stageId = self.stageId,
			optionId = id
		})
	end
end

M.OnRenderItem = function(self, btn, index)
	slot3 = gStoreManager
	slot3 = slot3:GetStoreGroup(btn.Store)
	local store = slot3:GetStoreByWidget(btn)
	local id = self.endorsementOptionIdList[index + 1]
	local endorsementOptionCfg = LTConfig.GrowthEndorsementOptionConfig.GetConfig(id)
	store.iconId = endorsementOptionCfg.PreviewRes

	btn.luaClick = function()
		self.bindData.list:GoToIndex(index, false)
	end
end

M.OnSelectedChange = function(self)
	local selectedIndex = self.bindData.list.selectedIndex
	local id = self.endorsementOptionIdList[selectedIndex + 1]
	local hasUnlocked = self:CheckEndorsementOptionIdHasUnlocked(id)
	local endorsementOptionCfg = LTConfig.GrowthEndorsementOptionConfig.GetConfig(id)
	self.bindData.brandName = endorsementOptionCfg.OptionTitle
	self.bindData.confirmButton.interactable = hasUnlocked
	self.bindData.rewardText = endorsementOptionCfg.RewardDesc
	self.bindData.unlockDescription = endorsementOptionCfg.UnlockDescription
	self.bindData.isLockedCtrl = hasUnlocked and 0 or 1
end

M.OnGetStageLevelReward = function(self)
	gPanelManager:Close(self.m_Id)
end
