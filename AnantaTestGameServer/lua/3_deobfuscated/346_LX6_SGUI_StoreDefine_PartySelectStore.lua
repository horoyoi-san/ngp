C_PartySelectStore = DefClass("C_PartySelectStore", C_PartySelectStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.PartySelectStore = C_PartySelectStore
local M = C_PartySelectStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self:CreateAction("OnSimpleClickList")
end

function M:InitModel(args)
	M.base.InitModel(self, args)
end

function M:InitView(args)
	M.base.InitView(self, args)

	self.viewDataList = self:GetViewDataList()

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

function M:GetViewDataList()
	local viewDataList = {}
	local count = LTConfig.PartyConfig.count
	local partyTypeDataMap = {}

	for i = 0, count - 1 do
		local partyCfg = LTConfig.PartyConfig.LoadAt(i)
		partyTypeDataMap[partyCfg.Type] = true
	end

	for partyTypeId, _ in pairs(partyTypeDataMap) do
		table.insert(viewDataList, partyTypeId)
	end

	table.sort(viewDataList)

	return viewDataList
end

function M:OnSimpleRenderListItem(btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local partyTypeId = self.viewDataList[luaIndex]
	local partyTypeCfg = LTConfig.PartyPartyTypeConfig.GetConfig(partyTypeId)
	store.iconId = partyTypeCfg.IconId
	store.title = partyTypeCfg.Name
end

function M:OnSimpleClickList(_, csIndex)
	local luaIndex = csIndex + 1
	local partyTypeId = self.viewDataList[luaIndex]
	local partyIdList = self:GetPartyIdList(partyTypeId)

	gMessageManager:SendMessage(gEventConstants.ON_PARTY_CONTENT_SHOW, {
		secondShowType = gClientConst.PartyShowType.PartyDestination,
		partyIdList = partyIdList,
		partyTypeId = partyTypeId
	})
end

function M:GetPartyIdList(partyTypeId)
	local count = LTConfig.PartyConfig.count
	local partyIdList = {}

	for i = 0, count - 1 do
		local partyCfg = LTConfig.PartyConfig.LoadAt(i)

		if partyCfg.Type == partyTypeId then
			table.insert(partyIdList, partyCfg.Id)
		end
	end

	return partyIdList
end
