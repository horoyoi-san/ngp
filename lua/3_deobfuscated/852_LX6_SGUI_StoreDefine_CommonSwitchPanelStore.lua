local LingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
local LinkPrepareActionConfig = LTConfig.LinkPrepareActionConfig
local bit = require("bit")
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local StaticProps = {
	Tabs = {
		AVATAR = 0,
		CAR = 1,
		FASHION = 2,
		ONLINE_POSE = 3
	}
}
C_CommonSwitchPanelStore = DefClass("C_CommonSwitchPanelStore", C_CommonSwitchPanelStore, C_StoreGroup, StaticProps)
GroupName2Class.CommonSwitchPanelStore = C_CommonSwitchPanelStore
local M = C_CommonSwitchPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.carList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderContentItem, StaticProps.Tabs.CAR)
	self.bindData.characterList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderContentItem, StaticProps.Tabs.AVATAR)
	self.bindData.onlinePoseList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderContentItem, StaticProps.Tabs.ONLINE_POSE)
	self.bindData.carList.luaSelectedChanged = self:CreateActionWithArgs(self.OnSelectedChange, StaticProps.Tabs.CAR)
	self.bindData.characterList.luaSelectedChanged = self:CreateActionWithArgs(self.OnSelectedChange, StaticProps.Tabs.AVATAR)
	self.bindData.onlinePoseList.luaSelectedChanged = self:CreateActionWithArgs(self.OnSelectedChange, StaticProps.Tabs.ONLINE_POSE)
	self.bindData.fashionBtn.luaClick = self:CreateAction(self.OnClickFashionBtn)
	self.bindData.modBtn.luaClick = self:CreateAction(self.OnClickModBtn)
end

function M:OnTabSelectedChanged(uList)
	self.bindData.type = self.showTab[uList.selectedIndex + 1].id

	if self.bindData.type == StaticProps.Tabs.AVATAR then
		self:RefreshAvatarList()
	elseif self.bindData.type == StaticProps.Tabs.CAR then
		self:RefreshCarList()
	end
end

function M:OnRenderContentItem(tabIndex, btn, index)
	local store = gStoreManager:GetStoreGroup("CommonSwitchPanelStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if tabIndex == StaticProps.Tabs.AVATAR then
		local data = self.showAvatarList[index + 1]
		store.iconId = data.icon
	elseif tabIndex == StaticProps.Tabs.CAR then
		local data = self.showCarList[index + 1]
		local vehicleId = data.id
		local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)
		store.iconId = vehicleCfg.SVehicleIconId
		store.name = vehicleCfg.VehicleName
		store.qualityCtrl = vehicleCfg.VehicleQuality
		store.brandIconId = vehicleCfg.SVehicleBrandIcon
	elseif tabIndex == M.Tabs.ONLINE_POSE then
		local data = self.showPoseList[index + 1]
		local cfg = LinkPrepareActionConfig.GetConfig(data.id)
		store.iconId = cfg.ActionImage
		store.name = cfg.ActionName
	end
end

function M:OnSelectedChange(tabIndex, list)
	if self.callback then
		local id = 0
		local index = list.selectedIndex

		if tabIndex == StaticProps.Tabs.AVATAR then
			local data = self.showAvatarList[index + 1]
			id = data.id
		elseif tabIndex == StaticProps.Tabs.FASHION then
			-- Nothing
		elseif tabIndex == StaticProps.Tabs.CAR then
			local data = self.showCarList[index + 1]
			id = data.id
		elseif tabIndex == StaticProps.Tabs.ONLINE_POSE then
			local data = self.showPoseList[index + 1]
			id = data.id
		end

		self.callback(self.bindData.type, self.subType, id)
	end
end

function M:OnInit(tabList, selectDict, callback)
	self.selectDict = selectDict
	self.callback = callback
	self.subType = 0
	self.showTab = {}
	self.showCarList = {}
	self.showAvatarList = {}
	self.showPoseList = {}
	self.bodyType = 0
	self.getUnlockedVehicleDone = false

	self:RefreshPage(tabList)
end

function M:SetData(enableVehicle, selectDict, callback)
	self.selectDict = selectDict
	self.callback = callback
	self.subType = 0
	self.showTab = {}
	self.showCarList = {}
	self.showAvatarList = {}
	self.showPoseList = {}
	self.bodyType = 0
	self.getUnlockedVehicleDone = false
	self.tabList = {
		{
			title = TextScriptTextConfig.GetConfig(89901276).Text,
			id = StaticProps.Tabs.AVATAR
		}
	}

	if enableVehicle then
		table.insert(self.tabList, {
			title = TextScriptTextConfig.GetConfig(89901275).Text,
			id = StaticProps.Tabs.CAR
		})
	end

	self:RefreshPage(self.tabList)
end

function M:OnBodyTypeRefresh(bodyType)
	if self.bodyType == bodyType then
		return
	end

	self.bodyType = bodyType

	if self.bindData.type == StaticProps.Tabs.ONLINE_POSE then
		self:RefreshOnlinePoseList()
	end
end

function M:RefreshPage(tabList)
	self.showTab = tabList

	self.SubGroup.CommonTabSingleStore:SetData(self.showTab, nil, 0, nil, self:CreateAction(self.OnTabSelectedChanged))
end

function M:RefreshAvatarList()
	if not table.isNilOrEmpty(self.showAvatarList) then
		return
	end

	local selectedIndex = 0
	local lingList = LingGuiUtils:GetAllLingList()
	self.showAvatarList = {}

	for i = 1, #lingList do
		local tId = lingList[i].Tid
		local ele = {
			icon = lingList[i].sIcon,
			name = lingList[i].Name,
			id = tId,
			type = StaticProps.Tabs.AVATAR
		}

		if self.selectDict[StaticProps.Tabs.AVATAR] == tId then
			selectedIndex = i - 1
		end

		table.insert(self.showAvatarList, ele)
	end

	self.bindData.characterList:SetSimpleList(#self.showAvatarList)
	self.bindData.characterList:SelectItem(selectedIndex)
end

function M:RefreshOnlinePoseList()
	local ret = gLinkManager.matchInfo and gLinkManager.matchInfo.AvailablePrepareActions or {}
	local mask = bit.lshift(1, self.bodyType)
	local selectedIndex = 0
	self.showPoseList = {}

	for i = 1, #ret do
		local id = ret[i]
		local cfg = LinkPrepareActionConfig.GetConfig(id)

		if bit.band(mask, cfg.BodyType) ~= 0 then
			local ele = {
				id = id,
				type = StaticProps.Tabs.ONLINE_POSE
			}

			if self.selectDict[StaticProps.Tabs.ONLINE_POSE] == id then
				selectedIndex = i - 1
			end

			table.insert(self.showPoseList, ele)
		end
	end

	self.bindData.onlinePoseList:SetSimpleList(#self.showPoseList)
	self.bindData.onlinePoseList:SelectItem(selectedIndex)
end

function M:RefreshCarList()
	if not self.getUnlockedVehicleDone then
		self:RequestUnlockedVehicle()

		return
	end
end

function M:RequestUnlockedVehicle()
	gDriveVehiclesManager:GetUnlockedVehicleInfo(function (vehicleList)
		self.getUnlockedVehicleDone = true
		local selectedIndex = 0

		if table.isNilOrEmpty(vehicleList) then
			self.showCarList = {}

			return
		end

		for i = 1, #vehicleList do
			local id = vehicleList[i].vehicleConfigID
			local ele = {
				id = vehicleList[i].vehicleConfigID,
				type = StaticProps.Tabs.CAR
			}

			if self.selectDict[StaticProps.Tabs.CAR] == id then
				selectedIndex = i - 1
			end

			table.insert(self.showCarList, ele)
		end

		self.bindData.carList:SetSimpleList(#self.showCarList)
		self.bindData.carList:SelectItem(selectedIndex)
	end)
end

function M:OnClickFashionBtn()
	self.bindData.type = StaticProps.Tabs.FASHION

	gPanelManager:CheckShow(gPanelId.S_COMMON_CHANGE_DRESS_PANEL, {
		callBack = function ()
			self.bindData.type = StaticProps.Tabs.AVATAR
		end
	})
end

function M:OnClickModBtn()
	return
end
