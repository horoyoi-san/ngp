-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CollectionRoomEntrancePanelStore.lua
-- Decompiled from: 01436_CollectionRoomEntrancePanelStore.lua_6ef508efd45b.luajit

local CollectionRoomConfig = LTConfig.CollectionRoomConfig
local MessageConfig = LTConfig.MessageConfig
C_CollectionRoomEntrancePanelStore = DefClass("C_CollectionRoomEntrancePanelStore", C_CollectionRoomEntrancePanelStore, C_StoreGroup)
GroupName2Class.CollectionRoomEntrancePanelStore = C_CollectionRoomEntrancePanelStore
local M = C_CollectionRoomEntrancePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.roomId = 0
	self.bannerList = {}
	self.pendingEnter = false
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

M.OnShow = function(self, panelId, data)
	self.roomId = data and data.roomId or 0

	if self.roomId ~= 0 then
		self.roomId = gCollectionRoomManager:GetDefaultRoomId()
	end

	self.pendingEnter = false

	self.RefreshRoomInfo(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RefreshRoomInfo = function(self)
	local roomCfg = CollectionRoomConfig.GetConfig(self.roomId)

	if not roomCfg then
		print_error("[CollectionRoomEntrancePanel] 收藏室配置不存在, roomId = ", self.roomId)

		self.bindData.des = ""
		self.bannerList = {}

		self.bindData.bannerList:SetSimpleList(0)

		self.bindData.enterBtn.interactable = false

		return
	end

	self.bindData.des = roomCfg.AppDesc or ""
	self.bindData.enterBtn.interactable = true

	self:RefreshBannerList(roomCfg)
end

M.RefreshBannerList = function(self, roomCfg)
	local titles = roomCfg.BannerTitle
	local descs = roomCfg.BannerDesc
	local images = roomCfg.BannerImage
	self.bannerList = {}
	local count = titles and #titles or 0

	if count ~= 0 then
		print_warn("[CollectionRoomEntrancePanel] 收藏室没配 BannerTitle, roomId = ", self.roomId)
		self.bindData.bannerList:SetSimpleList(0)

		return
	end

	if (descs and #descs or 0) == count or (images and #images or 0) == count then
		print_warn("[CollectionRoomEntrancePanel] Banner 三列长度不一致(以 BannerTitle 为准), roomId = ", self.roomId, ", title = ", count, ", desc = ", descs and #descs or 0, ", image = ", images and #images or 0)
	end

	for i = 1, count do
		self.bannerList[i] = {
			title = titles[i] or "",
			desc = descs and descs[i] or "",
			iconId = images and images[i] or 0
		}
	end

	self.bindData.bannerList:SetSimpleList(count)
end

M.RegisterWidget = function(self)
	self.bindData.enterBtn.luaClick = self.CreateAction(self, self.OnClickEnterBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.bannerList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderBannerListItem)
	self.bindData.bannerList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickBannerList)
end

M.OnClickEnterBtn = function(self)
	if self.pendingEnter then
		return
	end

	local roomCfg = CollectionRoomConfig.GetConfig(self.roomId)

	if not roomCfg then
		return
	end

	self.pendingEnter = true
	local param = {
		["\\xf1\\xd4\r\\xf5"] = 0,
		Tag = UX.Game.LinkTag.CollectionRoom,
		ColletionRoomId = self.roomId,
		HouseOwnerPid = ulong.tonum2(gPlayerManager.infoLogin.bindData.pid)
	}
	local rootGo = self.rootGo
	slot4 = gClientToGameDelegate

	slot4:AskCreateCustomLink(param).Callback = function (err)
		self.pendingEnter = false

		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if gClientUtils.IsNil(rootGo) then
			return
		end

		gPanelManager:Close(self.m_Id)
	end
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderBannerListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.bannerList[index + 1]

	if not data then
		return
	end

	store.title = data.title
	store.des = data.desc
	store.iconId = data.iconId
end

M.OnSimpleClickBannerList = function(self, btn, index)
end
