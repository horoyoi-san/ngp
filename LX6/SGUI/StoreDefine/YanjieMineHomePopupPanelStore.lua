-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieMineHomePopupPanelStore.lua
-- Decompiled from: 01252_YanjieMineHomePopupPanelStore.lua_fba440d7e47d.luajit

C_YanjieMineHomePopupPanelStore = DefClass("C_YanjieMineHomePopupPanelStore", C_YanjieMineHomePopupPanelStore, C_StoreGroup)
GroupName2Class.YanjieMineHomePopupPanelStore = C_YanjieMineHomePopupPanelStore
local M = C_YanjieMineHomePopupPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
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

M.OnShow = function(self, panelId, args)
	self.InitModel(self, args)
	self.InitView(self)
end

M.InitModel = function(self, args)
	self.stageId = args.stageId
	self.optionIdList = self.GetEndorsementOptionIdList(self)
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

M.InitView = function(self)
	self.bindData.title = LTConfig.GrowthConfig.NewEndorsementPopupTitleText
	self.bindData.desc = LTConfig.GrowthConfig.NewEndorsementPopupSubtitleText
	local avatarWidget = self.bindData.avatarWidget
	local playerAvatarStore = gStoreManager:GetStoreGroup(avatarWidget.Store):GetStoreByWidget(avatarWidget)
	playerAvatarStore.headIcon = gSocialNetworkUtils.GetPlayerSGuiAvatarId()

	self.bindData.list:SetSimpleList(#self.optionIdList)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmButton.luaClick = self.CreateAction(self, self.OnClickConfirmButton)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
end

M.OnClickConfirmButton = function(self)
	gPanelManager:Close(self.m_Id)
	gPanelManager:CheckShow(gPanelId.YANJIE_MEMBER_CENTER_PANEL, {
		targetStageId = self.stageId
	})
	gSocialNetworkUtils.MarkUnlockedStageHasRead()
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local optionId = self.optionIdList[index + 1]
	local optionCfg = LTConfig.GrowthEndorsementOptionConfig.GetConfig(optionId)
	store.iconId = optionCfg.PreviewRes
	store.sizeCtrl = 0
end

M.OnSimpleClickList = function(self, btn, index)
end
