C_UrbanAbilityBadgeTipsStore = DefClass("C_UrbanAbilityBadgeTipsStore", C_UrbanAbilityBadgeTipsStore, C_StoreGroup)
GroupName2Class.UrbanAbilityBadgeTipsStore = C_UrbanAbilityBadgeTipsStore
local M = C_UrbanAbilityBadgeTipsStore

function M:ctor()
	self.Type = {
		FightSpirit = 1,
		Common = 0,
		Job = 2
	}
	self.JobBadgeType = {
		ExtraSkill = 2,
		Upgrade = 0,
		Permission = 1
	}
end

function M:OnAwake()
	self.bindData.button.luaClick = self:CreateAction("OnBadgeBtnClick")
	self.bindData.badgeList.luaRenderItem = self:CreateAction("OnRenderBadgeListItem")
	self.bindData.iconList.luaRenderItem = self:CreateAction("OnRenderIconListItem")
end

function M:OnShow(panelId, args)
	self.panelId = panelId
	self.areaIndex = args.areaIndex

	self:InitView()
	self:SetBadgeData(args.list, args.spiritId)
end

function M:OnClose()
	return
end

function M:SetBadgeData(list, spiritId)
	if not list or #list <= 0 then
		return
	end

	if #list > 1 then
		self.bindData.ctrl = 5

		self:SetBadgeList(list)

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

	if cfg.Type == self.Type.Job then
		self.bindData.ctrl = cfg.JobBadgeType

		self:SetHeadIcon(spiritId)
	elseif cfg.Type == self.Type.FightSpirit then
		self.bindData.ctrl = 3

		self:SetHeadIcon(spiritId)
	else
		self.bindData.ctrl = 4
	end
end

function M:SetHeadIcon(spiritId)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)
	local store = gStoreManager:GetStoreGroup("BubbleCommonAvatar"):GetStoreByWidget(self.bindData.head)

	if cfg and store then
		store.headIcon = cfg.SHeadIconID
	end
end

function M:InitView()
	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(5)
		gPanelManager:Close(self.panelId)
	end)
end

function M:SetBadgeList(badgelist)
	local list = {}

	for i, v in pairs(badgelist) do
		local data = {
			id = v.TemplateId,
			cfg = LTConfig.UrbanBadgeConfig.GetConfig(v.TemplateId)
		}

		table.insert(list, data)
	end

	self.bindData.badgeList:SetList(list)

	self.listCor = coroutine.start(function ()
		coroutine.wait(0.7)
		self.bindData.badgeList:GoToIndex(-1, false)
	end)

	self.bindData.iconList:SetList(list)
end

function M:OnRenderBadgeListItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadgeTipsTemplate"):GetStoreByWidget(btn)

	if store == nil then
		return
	end

	store.quality = data.cfg.Quality - 1
	store.text = data.cfg.Name
end

function M:OnRenderIconListItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("BadgeIconTestStore"):GetStoreByWidget(btn)

	if store == nil then
		return
	end

	store.icon = data.cfg.Image
end

function M:OnBadgeBtnClick()
	local gotoPage = 0

	if self.cfg.Type == gUrbanAbilityManager.BADGE_TYPE.JOB then
		gotoPage = gUrbanAbilityManager.URBANABILITY_PAGE.OCCUPATION
	else
		gotoPage = gUrbanAbilityManager.URBANABILITY_PAGE.BADGE
	end

	gPanelManager:CheckShow(gPanelId.S_URBAN_ABILITY_PANEL, {
		tab = gotoPage,
		cfg = self.cfg
	})
end
