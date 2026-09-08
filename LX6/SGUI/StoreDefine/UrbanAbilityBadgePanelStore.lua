-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityBadgePanelStore.lua
-- Decompiled from: 01197_UrbanAbilityBadgePanelStore.lua_d29368765f53.luajit

C_UrbanAbilityBadgePanelStore = DefClass("C_UrbanAbilityBadgePanelStore", C_UrbanAbilityBadgePanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityBadgePanelStore = C_UrbanAbilityBadgePanelStore
local M = C_UrbanAbilityBadgePanelStore

M.ctor = function(self)
	self.BADGE_TYPE = {
		["?g\\xbc\\xa3\\xaco"] = 0,
		["\\xa4GD"] = 2,
		["I_\\x8b_x\\x8d\\xc1wCHWx"] = 1
	}
end

M.OnAwake = function(self)
	self.badgeMaxLevel = 3
	self.bindData.badgeList.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.badgeList.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.bindData.badgeCountList.luaSimpleRenderItem = self:CreateAction("OnRenderBadgeCountItem")

	self.bindData.badgeCountList.onGetTIndex = function(_)
		return 0
	end

	self.bindData.qualityList.luaSimpleRenderItem = self:CreateAction("OnRenderBadgeTabItem")
	self.bindData.changeLeftAreaBtn.luaClick = self:CreateAction("OnChangeLeftAreaBtnClick")
	self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityPanelStore")
	local msgEvents = {
		[gEventConstants.ON_SYNC_URBAN_BADGEINFO] = self:CreateAction("SyncUrbanBadgeInfo"),
		[gEventConstants.ON_CHANGE_SPIRITVIEW_DATA] = self:CreateAction("ChangeSpiriViewData")
	}

	self:RegisterMessageEvents(msgEvents)

	self.pageid = self.BADGE_TYPE.COMMON
end

M.OnDestroy = function(self)
	self.lastSelectBtn = nil
	self.lastSelectIndex = nil

	self.ClearMessageEvents(self)
end

M.OnEnable = function(self)
	self.lastSelectIndex = nil
	self.lastSelectBtn = nil

	self.bindData.videoPlayer:Init()
	self:PlayVideo()
	Timer.New(function ()
		self:SetBadgeData()
	end, 0.1):Start()
end

M.SetDefaultData = function(self, data)
	self.defaultData = data
end

M.PlayVideo = function(self)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(self.urbanAbilityStore:GetCurSpiritTid())

	self.bindData.videoPlayer:PlayVideo(cfg.HeadIconVideoId, true, nil)
end

M.SyncUrbanBadgeInfo = function(self)
	self.SetBadgeData(self)
end

M.ChangeSpiriViewData = function(self, eventId, data)
	if not data.data.alreadyJoin and not data.data.canJoin then
		return
	end

	self.SetBadgeData(self)
	self.PlayVideo(self)
end

M.SetBadgeData = function(self)
	local curSpiritId = self.urbanAbilityStore:GetCurSpiritTid()
	self.fightSpiritBadges = gSpiritManager:GetSpirit(curSpiritId).SpiritInfo.InfoBadge.Badges

	self:SetHeadIcon(curSpiritId)
	self:SetBadgeTabList()
	self:SetRightData()
end

M.SetHeadIcon = function(self, id)
	local head1 = gStoreManager:GetStoreGroup("HeadAvatarStore"):GetStoreByWidget(self.bindData.head1)
	local head2 = gStoreManager:GetStoreGroup("HeadAvatarStore"):GetStoreByWidget(self.bindData.head2)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(id)

	if cfg then
		head1.headIcon = cfg.SHeadIconID
		head1.bgColor = Color.NewByStr(cfg.CharListTemplateBgColor)
		head2.headIcon = cfg.SHeadIconID
		head2.bgColor = Color.NewByStr(cfg.CharListTemplateBgColor)
	end
end

M.OnGetTIndex = function(self, index)
	if index <= #self.allList - 1 then
		return 1
	end

	return 0
end

M.SetRightData = function(self)
	self.allList = {}

	if self.pageid ~= self.BADGE_TYPE.COMMON then
		self.bindData.Type = 0

		self.GetCommonBadgeList(self)
	elseif self.pageid ~= self.BADGE_TYPE.FIGHT_SPIRIT then
		self.bindData.Type = 1

		self.GetSpiritBadgeList(self)
	else
		return
	end

	if #self.allList <= 0 then
		self.bindData.isEmpty = 0
	else
		self.bindData.isEmpty = 1
	end

	self.lastSelectIndex = -1

	self.bindData.badgeList:SetSimpleList(self:GetTotalCount())
	gSoundMgr:PlaySoundByTid(70650279)
	self.bindData.badgeList:SetItemSelected(self.pageid, true)

	if self.lastSelectBtn then
		self.lastSelectBtn:SetSelected(false)

		self.lastSelectIndex = nil
		self.lastSelectBtn = nil
	end

	self.SetBadgeTotalList(self)
end

M.SetBadgeTabList = function(self)
	self.tabList = {
		{
			id = self.BADGE_TYPE.COMMON,
			name = LTConfig.TextScriptTextConfig.GetConfig(89901250).Text
		},
		{
			id = self.BADGE_TYPE.FIGHT_SPIRIT,
			name = LTConfig.TextScriptTextConfig.GetConfig(89901251).Text
		}
	}

	self.bindData.qualityList:SetSimpleList(#self.tabList)

	if self.defaultData and self.defaultData.cfg.Type ~= self.BADGE_TYPE.COMMON then
		self.pageid = self.BADGE_TYPE.COMMON
	end

	self.bindData.qualityList:SetItemSelected(self.pageid, true)

	self.defaultData = nil
end

M.SetBadgeTotalList = function(self)
	local num, sum, qualityList, quality = nil

	if self.pageid ~= self.BADGE_TYPE.COMMON then
		num, sum, qualityList, quality = gUrbanAbilityManager:GetAllCommonBadgeNum()
	elseif self.pageid ~= self.BADGE_TYPE.FIGHT_SPIRIT then
		num, sum, qualityList, quality = gUrbanAbilityManager:GetSpiritAllBadgeNum(self.urbanAbilityStore:GetCurSpiritTid())
	end

	self.qualityList = {}

	for i, v in pairs(quality) do
		if v <= 1 then
			local info = {
				id = i,
				selected = false,
				num = #qualityList[v],
				quality = v
			}

			table.insert(self.qualityList, info)
		end
	end

	self.bindData.badgeCountList:SetSimpleList(#self.qualityList)
end

M.OnRenderItem = function(self, btn, index)
	local storeGroup = gStoreManager:GetStoreGroup("UrbanAbilityBadgeTemplateStore")

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)
	local data = self.allList[index + 1]

	if not store or not data then
		return
	end

	local cfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)
	local serverData = self.Badges[data.id]
	store.name.text = cfg.Name

	if serverData and serverData.Active then
		store.isLock = 1
	else
		store.isLock = 0
	end

	local args = {
		cfg = cfg,
		serverData = serverData
	}
	store.button.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderToolTips", args)

	if not cfg then
		return
	end

	if cfg.UnlockDescription then
		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.UrbanBadge, data.id, 0)
		local unlockDescription = cfg.UnlockDescription .. "(" .. progress .. "/" .. cfg.MaxProgress .. ")"
		store.lock2.text = unlockDescription
	end

	store.iconId = cfg.Image

	store.Commit(store, "iconId", cfg.Image, COMMIT_FORCE)

	store.quality = cfg.Quality - 1

	if cfg.Type ~= 1 then
		store.type = cfg.Type + 1
		local headstore = gStoreManager:GetStoreGroup("HeadAvatarStore"):GetStoreByWidget(store.head)
		local cfg = LTConfig.FightSpiritConfig.GetConfig(cfg.FightspiritId)

		if cfg then
			headstore.headIcon = cfg.SHeadIconID
			headstore.bgColor = Color.NewByStr(cfg.CharListTemplateBgColor)
		end
	else
		store.type = 0
	end
end

M.OnRenderToolTips = function(self, arg, btn, PopUp, index)
	local store = gStoreManager:GetStoreGroup("UrbanBadgeTooltipStore"):GetStoreByWidget(PopUp)

	if not store then
		return
	end

	store.level = arg.cfg.Quality - 1
	store.title = arg.cfg.Name
	store.buff = arg.cfg.Description

	if arg.serverData and arg.serverData.Active then
		store.lockCtrl = 1
	else
		store.lockCtrl = 0
	end

	if arg.cfg.UnlockDescription then
		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.UrbanBadge, arg.cfg.Id, 0)
		local unlockDescription = arg.cfg.UnlockDescription .. "(" .. progress .. "/" .. arg.cfg.MaxProgress .. ")"
		store.lock = unlockDescription
	end
end

M.OnRenderBadgeCountItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("UrbanBadgeCountTemplateStore"):GetStoreByWidget(btn)
	local data = self.qualityList[index + 1]
	store.quality = data.quality - 1
	store.num = data.num
end

M.OnRenderBadgeTabItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadgeTabNormalStore"):GetStoreByWidget(btn)
	local data = self.tabList[index + 1]

	store:Commit("title", data.name, COMMIT_IMMEDIATELY_WITH_CHECK)

	btn.luaClick = self:CreateActionWithArgs("OnBadgeTypeBtnClick", data.id)
end

M.OnBadgeTypeBtnClick = function(self, id)
	self.pageid = id
	self.bindData.title.text = id ~= self.BADGE_TYPE.COMMON and LTConfig.TextScriptTextConfig.GetConfig(89901250).Text or LTConfig.TextScriptTextConfig.GetConfig(89901251).Text

	self:SetRightData()
end

M.GetSpiritBadgeList = function(self)
	local curSpiritId = self.urbanAbilityStore:GetCurSpiritTid()
	local spirit = gSpiritManager:GetSpirit(curSpiritId)

	if not spirit then
		return
	end

	self.Badges = spirit.SpiritInfo.InfoBadge.Badges
	local fightSpiritActiveList = {}
	local fightSpiritList = {}

	for i = 0, LTConfig.UrbanBadgeConfig.count - 1 do
		local cfg = LTConfig.UrbanBadgeConfig.LoadAt(i)
		local data = {}

		if cfg and not cfg.OnlyServer then
			data.id = cfg.Id
			data.sort = cfg.Quality

			if cfg.FightspiritId ~= gSpiritManager.DefaultFemale2DefaultMaleSpiritId(curSpiritId) and cfg.Type ~= self.BADGE_TYPE.FIGHT_SPIRIT then
				if self.Badges[cfg.Id] and self.Badges[cfg.Id].Active then
					table.insert(fightSpiritActiveList, data)
				elseif not cfg.HideWhenLocked then
					table.insert(fightSpiritList, data)
				end
			end
		end
	end

	self.AddList(self, fightSpiritActiveList)
	self.AddList(self, fightSpiritList)
end

M.GetCommonBadgeList = function(self)
	self.Badges = gPlayerManager.infoMinor.bindData.Badges
	local comActiveList = {}
	local commonList = {}

	for i = 0, LTConfig.UrbanBadgeConfig.count - 1 do
		local cfg = LTConfig.UrbanBadgeConfig.LoadAt(i)
		local data = {}

		if cfg and not cfg.OnlyServer then
			data.id = cfg.Id
			data.sort = cfg.Quality

			if cfg.Type ~= self.BADGE_TYPE.COMMON then
				if self.Badges[cfg.Id] and self.Badges[cfg.Id].Active then
					table.insert(comActiveList, data)
				elseif not cfg.HideWhenLocked then
					table.insert(commonList, data)
				end
			end
		end
	end

	self.AddList(self, comActiveList)
	self.AddList(self, commonList)
end

M.GetTotalCount = function(self)
	local maxNum = self.bindData.badgeList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.allList / maxNum.x), maxNum.y)

	return maxNum.x * col
end

M.AddList = function(self, list)
	table.sort(list, function (a, b)
		return b.sort <= a.sort
	end)

	for i, v in pairs(list) do
		local info = {
			id = v.id,
			selected = false
		}

		table.insert(self.allList, info)
	end
end

M.OnItemClick = function(self, arg)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if self.lastSelectIndex ~= arg.data.id then
		arg.btn:SetSelected(false)

		self.lastSelectIndex = nil
		self.lastSelectBtn = nil

		return
	end

	if self.lastSelectBtn then
		self.lastSelectBtn:SetSelected(false)
	end

	arg.btn:SetSelected(true)

	self.lastSelectIndex = arg.data.id
	self.lastSelectBtn = arg.btn
end

M.OnChangeLeftAreaBtnClick = function(self)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.urbanAbilityStore.bindData.navigationArea
end
