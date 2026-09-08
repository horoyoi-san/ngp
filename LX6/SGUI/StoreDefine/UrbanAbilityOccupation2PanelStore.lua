-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityOccupation2PanelStore.lua
-- Decompiled from: 01185_UrbanAbilityOccupation2PanelStore.lua_93571c541f9c.luajit

C_UrbanAbilityOccupation2PanelStore = DefClass("C_UrbanAbilityOccupation2PanelStore", C_UrbanAbilityOccupation2PanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityOccupation2PanelStore = C_UrbanAbilityOccupation2PanelStore
local M = C_UrbanAbilityOccupation2PanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityV2PanelStore")
end

M.DefineAllEnumsAutoGen = function(self)
	self.unlockCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isEmptyEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.unlockCtrlEnum = nil
	self.isEmptyEnum = nil
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
	self.bindData.unlockCtrl = self.unlockCtrlEnum._false
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.ShowPanel = function(self, occupationId)
	self.occupationId = occupationId
	local cfg = LTConfig.UrbanJobConfig.GetConfig(occupationId)
	self.bindData.title = cfg.Name

	self.SetListData(self)
end

M.OnClose = function(self)
	self.urbanAbilityStore:CloseCurrentTab()
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderListItem")
	self.bindData.list.luaSimpleClick = self.CreateAction(self, "OnSimpleClickList")
	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
end

M.OnBackBtnClick = function(self)
	self.urbanAbilityStore:CloseCurrentTab()
end

M.SetListData = function(self)
	local tid = self.urbanAbilityStore:GetCurSpiritTid()
	self.spiritViewData = gSpiritManager:GetSpirit(tid)
	local badgeList = gSpiritJobManager:GetJobPathAllBadge(self.occupationId)
	local list = {}

	for i, v in pairs(badgeList) do
		local info = {
			id = v.cfg.Id,
			isLock = true
		}

		table.insert(list, info)

		if self.spiritViewData and self.spiritViewData.SpiritInfo.InfoBadge.Badges[v.cfg.Id] then
			local badge = self.spiritViewData.SpiritInfo.InfoBadge.Badges[v.cfg.Id]

			if badge.Active then
				info.isLock = false
			end
		end
	end

	self._listData = list

	self.bindData.list:SetSimpleList(#list)

	if #list <= 0 then
		local selectIndex = 0

		if self.defaultSelectBadgeId then
			for i, v in ipairs(list) do
				if v.id ~= self.defaultSelectBadgeId then
					selectIndex = i - 1

					break
				end
			end

			self.defaultSelectBadgeId = nil
		end

		self.bindData.list:SelectItem(selectIndex, true)
		self:OnSimpleClickList(nil, selectIndex)

		self.bindData.isEmpty = self.isEmptyEnum._false
	else
		self.bindData.isEmpty = self.isEmptyEnum._true
		self.bindData.unlockCtrl = self.unlockCtrlEnum._false
	end
end

M.OnGetTIndex = function(self, index)
	local data = self._listData[index + 1]
	local badgeCfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)

	if badgeCfg.JobBadgeUseBigIcon then
		return 1
	else
		return 0
	end
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self._listData[index + 1]
	local store = gStoreManager:GetStoreGroup("CommonItemTemplate"):GetStoreByWidget(btn)
	local badgeCfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)

	if not badgeCfg then
		return
	end

	store.iconId = badgeCfg.Image
	store.name = badgeCfg.Name
	store.count = ""
	store.isLock = data.isLock and 1 or 0
	store.quality = badgeCfg.Quality
	btn.enabledTooltip = false
end

M.OnSimpleClickList = function(self, btn, index)
	local data = self._listData[index + 1]
	local badgeCfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)

	if not badgeCfg then
		return
	end

	local desc = badgeCfg.Description or ""
	local unlockDesc = badgeCfg.UnlockDescription or ""
	self.bindData.desc = desc
	self.bindData.unlockDesc = unlockDesc
	self.bindData.unlockCtrl = data.isLock and self.unlockCtrlEnum._true or self.unlockCtrlEnum._false
end
