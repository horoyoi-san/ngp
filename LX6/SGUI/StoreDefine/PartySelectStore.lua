-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartySelectStore.lua
-- Decompiled from: 02031_PartySelectStore.lua_fe4740d45357.luajit

C_PartySelectStore = DefClass("C_PartySelectStore", C_PartySelectStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PartySelectStore = C_PartySelectStore
local M = C_PartySelectStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnSimpleClickList")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)

	self.viewDataList = self:GetViewDataList()

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

M.GetViewDataList = function(self)
	local viewDataList = {}
	local count = LTConfig.PartyConfig.count
	local partyTypeDataMap = {}

	for i = 0, count - 1 do
		local partyCfg = LTConfig.PartyConfig.LoadAt(i)

		if gEventConditionUtils.CheckHasUnlocked(partyCfg, UX.Game.EventConditionImplModule.Party) then
			partyTypeDataMap[partyCfg.Type] = true
		end
	end

	for partyTypeId, _ in pairs(partyTypeDataMap) do
		table.insert(viewDataList, partyTypeId)
	end

	table.sort(viewDataList)

	return viewDataList
end

M.OnSimpleRenderListItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local partyTypeId = self.viewDataList[luaIndex]
	local partyTypeCfg = LTConfig.PartyPartyTypeConfig.GetConfig(partyTypeId)
	store.iconId = partyTypeCfg.IconId
	store.title = partyTypeCfg.Name
	store.guideId = partyTypeCfg.GuideId
end

M.OnSimpleClickList = function(self, _, csIndex)
	if gPartyManager.isInParty then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.RepeatParty)

		return
	end

	local luaIndex = csIndex + 1
	local partyTypeId = self.viewDataList[luaIndex]
	local partyIdList = self:GetPartyIdList(partyTypeId)

	gMessageManager:SendMessage(gEventConstants.ON_PARTY_CONTENT_SHOW, {
		secondShowType = gClientConst.PartyShowType.PartyDestination,
		partyIdList = partyIdList,
		partyTypeId = partyTypeId
	})
end

M.GetPartyIdList = function(self, partyTypeId)
	local count = LTConfig.PartyConfig.count
	local partyIdList = {}

	for i = 0, count - 1 do
		local partyCfg = LTConfig.PartyConfig.LoadAt(i)

		if partyCfg.Type ~= partyTypeId then
			table.insert(partyIdList, partyCfg.Id)
		end
	end

	return partyIdList
end
