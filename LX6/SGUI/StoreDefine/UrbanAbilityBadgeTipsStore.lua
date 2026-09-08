-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityBadgeTipsStore.lua
-- Decompiled from: 01196_UrbanAbilityBadgeTipsStore.lua_5a6cae7b3f64.luajit

C_UrbanAbilityBadgeTipsStore = DefClass("C_UrbanAbilityBadgeTipsStore", C_UrbanAbilityBadgeTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityBadgeTipsStore = C_UrbanAbilityBadgeTipsStore
local M = C_UrbanAbilityBadgeTipsStore

M.ctor = function(self)
	self.Type = {
		["\\xb9='7l\\xaeQ\\xd0%\\xa3\\xad"] = 1,
		["?G\\x9c\\x83\\x8cO"] = 0,
		["\\xa4gd"] = 2
	}
	self.JobBadgeType = {
		["vBگ\\x85;\\xb3\r\\xc5\\xe4"] = 2,
		["\\xec\\xcb \\xf4"] = 0,
		["c_ܰ\\x8d\\xab\r\\xc6\\xe6"] = 1
	}
end

M.OnAwake = function(self)
	self.bindData.button.luaClick = self.CreateAction(self, "OnBadgeBtnClick")
	self.bindData.badgeList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderBadgeListItem")
	self.bindData.iconList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderIconListItem")
end

M.OnShow = function(self, panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex
	self.spiritId = args.spiritId

	self:InitView()
	self:SetBadgeData(args.list, args.spiritId)
	self.bindData.button:SetActive(gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Character))
end

M.OnClose = function(self)
end

M.SetBadgeData = function(self, list, spiritId)
	if not list or #list < 0 then
		return
	end

	if #list <= 1 then
		self.bindData.ctrl = 5

		self.SetBadgeList(self, list)

		return
	end

	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(list[1].TemplateId)

	if not cfg then
		return
	end

	self.cfg = cfg
	self.bindData.badgeName.text = cfg.Name
	self.bindData.des = cfg.Description
	self.bindData.badgeIcon = cfg.Image
	self.bindData.badgeIcon2 = cfg.Image
	self.bindData.badgeIcon3 = cfg.Image
	self.bindData.quality = cfg.Quality - 1

	if cfg.Type ~= self.Type.Job then
		self.bindData.ctrl = cfg.JobBadgeType

		self.SetHeadIcon(self, spiritId)
	elseif cfg.Type ~= self.Type.FightSpirit then
		self.bindData.ctrl = 3

		self.SetHeadIcon(self, spiritId)
	else
		self.bindData.ctrl = 4
	end
end

M.SetHeadIcon = function(self, spiritId)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)
	local store = gStoreManager:GetStoreGroup("BubbleCommonAvatar"):GetStoreByWidget(self.bindData.head)

	if cfg and store then
		store.headIcon = cfg.SHeadIconID
	end
end

M.InitView = function(self)
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(5)
		gPanelManager:Close(self.panelId)
	end)
end

M.SetBadgeList = function(self, badgelist)
	local list = {}

	for i, v in pairs(badgelist) do
		local data = {
			id = v.TemplateId,
			cfg = LTConfig.UrbanBadgeConfig.GetConfig(v.TemplateId)
		}

		table.insert(list, data)
	end

	self._badgeListData = list

	self.bindData.badgeList:SetSimpleList(#list)

	self.listCor = coroutine.start(function ()
		coroutine.wait(0.7)
		self.bindData.badgeList:GoToIndex(-1, false)
	end)

	self.bindData.iconList:SetSimpleList(#list)
end

M.OnRenderBadgeListItem = function(self, btn, index)
	local data = self._badgeListData[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadgeTipsTemplate"):GetStoreByWidget(btn)

	if store ~= nil then
		return
	end

	store.quality = data.cfg.Quality - 1
	store.text = data.cfg.Name
end

M.OnRenderIconListItem = function(self, btn, index)
	local data = self._badgeListData[index + 1]
	local store = gStoreManager:GetStoreGroup("BadgeIconTestStore"):GetStoreByWidget(btn)

	if store ~= nil then
		return
	end

	store.icon = data.cfg.Image
end

M.OnBadgeBtnClick = function(self)
	local PAGE = gUrbanAbilityManager.URBANABILITY_PAGE
	local gotoPage = nil

	if self.cfg.Type ~= gUrbanAbilityManager.BADGE_TYPE.JOB then
		gotoPage = PAGE.OCCUPATION
	else
		gotoPage = PAGE.BADGE
	end

	local data = {
		tab = gotoPage,
		cfg = self.cfg
	}

	if gotoPage ~= PAGE.OCCUPATION then
		data.selectedTid = self.spiritId
	end

	gPanelManager:CheckShow(gPanelId.S_URBAN_ABILITY_PANEL, data)
end
