C_UrbanAbilityBadgePanelStore = DefClass("C_UrbanAbilityBadgePanelStore", C_UrbanAbilityBadgePanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityBadgePanelStore = C_UrbanAbilityBadgePanelStore
local M = C_UrbanAbilityBadgePanelStore

function M:ctor()
	self.BADGE_TYPE = {
		COMMON = 0,
		JOB = 2,
		FIGHT_SPIRIT = 1
	}
end

function M:OnAwake()
	self.badgeMaxLevel = 3
	self.bindData.badgeList.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.badgeList.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.bindData.badgeCountList.luaSimpleRenderItem = self:CreateAction("OnRenderBadgeCountItem")

	function self.bindData.badgeCountList.onGetTIndex(_)
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

	self.pageid = self.BADGE_TYPE.FIGHT_SPIRIT
end

function M:OnDestroy()
	self.lastSelectBtn = nil
	self.lastSelectIndex = nil

	self:ClearMessageEvents()
end

function M:OnEnable()
	self.lastSelectIndex = nil
	self.lastSelectBtn = nil

	self.bindData.videoPlayer:Init()
	self:PlayVideo()
	Timer.New(function ()
		self:SetBadgeData()
	end, 0.1):Start()
end

function M:SetDefaultData(data)
	self.defaultData = data
end

function M:PlayVideo()
	local cfg = LTConfig.FightSpiritConfig.GetConfig(self.urbanAbilityStore:GetCurSpiritTid())

	self.bindData.videoPlayer:PlayVideo(cfg.HeadIconVideoId, true, nil)
end

function M:SyncUrbanBadgeInfo()
	self:SetBadgeData()
end

function M:ChangeSpiriViewData(eventId, data)
	if not data.data.alreadyJoin and not data.data.canJoin then
		return
	end

	self:SetBadgeData()
	self:PlayVideo()
end

function M:SetBadgeData()
	local curSpiritId = self.urbanAbilityStore:GetCurSpiritTid()
	self.fightSpiritBadges = gSpiritManager:GetSpirit(curSpiritId).SpiritInfo.InfoBadge.Badges

	self:SetHeadIcon(curSpiritId)
	self:SetBadgeTabList()
	self:SetRightData()
end

function M:SetHeadIcon(id)
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

function M:OnGetTIndex(index)
	if index > #self.allList - 1 then
		return 1
	end

	return 0
end

function M:SetRightData()
	self.allList = {}

	if self.pageid == self.BADGE_TYPE.COMMON then
		self.bindData.Type = 0

		self:GetCommonBadgeList()
	elseif self.pageid == self.BADGE_TYPE.FIGHT_SPIRIT then
		self.bindData.Type = 1

		self:GetSpiritBadgeList()
	else
		return
	end

	if #self.allList > 0 then
		self.bindData.isEmpty = 0
	else
		self.bindData.isEmpty = 1
	end

	self.lastSelectIndex = -1

	self.bindData.badgeList:SetSimpleList(self:GetTotalCount())
	gSoundMgr:PlaySoundByTid(70650279)

	if self.lastSelectBtn then
		self.lastSelectBtn:SetSelected(false)

		self.lastSelectIndex = nil
		self.lastSelectBtn = nil
	end

	self:SetBadgeTotalList()
end

function M:SetBadgeTabList()
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

	if self.defaultData and self.defaultData.cfg.Type == self.BADGE_TYPE.COMMON then
		self.pageid = self.BADGE_TYPE.COMMON
	end

	self.bindData.qualityList:SetItemSelected(self.pageid, true)
end

function M:SetBadgeTotalList()
	local num, sum, qualityList, quality = nil

	if self.pageid == self.BADGE_TYPE.COMMON then
		num, sum, qualityList, quality = gUrbanAbilityManager:GetAllCommonBadgeNum()
	elseif self.pageid == self.BADGE_TYPE.FIGHT_SPIRIT then
		num, sum, qualityList, quality = gUrbanAbilityManager:GetSpiritAllBadgeNum(self.urbanAbilityStore:GetCurSpiritTid())
	end

	self.qualityList = {}

	for i, v in pairs(quality) do
		if v > 1 then
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

function M:OnRenderItem(btn, index)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadgeTemplateStore"):GetStoreByWidget(btn)
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
	store.button.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", args)

	if not cfg then
		return
	end

	if cfg.UnlockDescription then
		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.UrbanBadge, data.id, 0)
		local unlockDescription = cfg.UnlockDescription .. "(" .. progress .. "/" .. cfg.MaxProgress .. ")"
		store.lock2.text = unlockDescription
	end

	store.iconId = cfg.Image

	store:Commit("iconId", cfg.Image, COMMIT_FORCE)

	store.quality = cfg.Quality - 1

	if cfg.Type == 1 then
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

function M:OnRenderToolTips(arg, btn, PopUp, index)
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

function M:OnRenderBadgeCountItem(btn, index)
	local store = gStoreManager:GetStoreGroup("UrbanBadgeCountTemplateStore"):GetStoreByWidget(btn)
	local data = self.qualityList[index + 1]
	store.quality = data.quality - 1
	store.num = data.num
end

function M:OnRenderBadgeTabItem(btn, index)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadgeTabNormalStore"):GetStoreByWidget(btn)
	local data = self.tabList[index + 1]
	store.title = data.name
	btn.luaClick = self:CreateActionWithArgs("OnBadgeTypeBtnClick", data.id)
end

function M:OnBadgeTypeBtnClick(id)
	self.pageid = id
	self.bindData.title.text = id == self.BADGE_TYPE.COMMON and LTConfig.TextScriptTextConfig.GetConfig(89901250).Text or LTConfig.TextScriptTextConfig.GetConfig(89901251).Text

	self:SetRightData()
	self.bindData.qualityList:SetItemSelected(self.pageid, true)
end

function M:OnRenderQualityItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityBadgeQualityTemplateStore"):GetStoreByWidget(btn)
	store.quality = data.id - 1
	store.num = data.num
end

function M:GetSpiritBadgeList()
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

			if cfg.FightspiritId == curSpiritId and cfg.Type == self.BADGE_TYPE.FIGHT_SPIRIT then
				if self.Badges[cfg.Id] and self.Badges[cfg.Id].Active then
					table.insert(fightSpiritActiveList, data)
				elseif not cfg.HideWhenLocked then
					table.insert(fightSpiritList, data)
				end
			end
		end
	end

	self:AddList(fightSpiritActiveList)
	self:AddList(fightSpiritList)
end

function M:GetCommonBadgeList()
	self.Badges = gPlayerManager.infoMinor.bindData.Badges
	local comActiveList = {}
	local commonList = {}

	for i = 0, LTConfig.UrbanBadgeConfig.count - 1 do
		local cfg = LTConfig.UrbanBadgeConfig.LoadAt(i)
		local data = {}

		if cfg and not cfg.OnlyServer then
			data.id = cfg.Id
			data.sort = cfg.Quality

			if cfg.Type == self.BADGE_TYPE.COMMON then
				if self.Badges[cfg.Id] and self.Badges[cfg.Id].Active then
					table.insert(comActiveList, data)
				elseif not cfg.HideWhenLocked then
					table.insert(commonList, data)
				end
			end
		end
	end

	self:AddList(comActiveList)
	self:AddList(commonList)
end

function M:GetTotalCount()
	local maxNum = self.bindData.badgeList:GetMaxRowAndColCount(0)
	local col = math.max(math.ceil(#self.allList / maxNum.x), maxNum.y)

	return maxNum.x * col
end

function M:AddList(list)
	table.sort(list, function (a, b)
		return b.sort < a.sort
	end)

	for i, v in pairs(list) do
		local info = {
			id = v.id,
			selected = false
		}

		table.insert(self.allList, info)
	end
end

function M:OnItemClick(arg)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if self.lastSelectIndex == arg.data.id then
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

function M:OnChangeLeftAreaBtnClick()
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.urbanAbilityStore.bindData.navigationArea
end
