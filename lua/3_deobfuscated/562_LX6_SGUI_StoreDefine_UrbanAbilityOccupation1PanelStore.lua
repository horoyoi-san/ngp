C_UrbanAbilityOccupation1PanelStore = DefClass("C_UrbanAbilityOccupation1PanelStore", C_UrbanAbilityOccupation1PanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityOccupation1PanelStore = C_UrbanAbilityOccupation1PanelStore
local M = C_UrbanAbilityOccupation1PanelStore

function M:ctor()
	self.Empty = {
		NotEmpty = 0,
		Empty = 1
	}
	self.Active = {
		UnActive = 1,
		Active = 0
	}
	self.Select = {
		NotSelect = 0,
		Select = 1
	}
	self.OccupationDetailTitle = {
		LTConfig.TextCommonTextConfig.GetConfig(74003508).Text,
		LTConfig.TextCommonTextConfig.GetConfig(74003509).Text,
		LTConfig.TextCommonTextConfig.GetConfig(74003510).Text
	}
	self.unfoldList = {
		true,
		true,
		false
	}
end

function M:OnAwake()
	self.bindData.slotList.luaRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.jobList.luaRenderItem = self:CreateAction("OnRenderJobPathItem")
	self.bindData.jobList.luaDynamicRenderItem = self:CreateAction("OnRenderJobPathItem")
	self.bindData.detailList.luaRenderItem = self:CreateAction("OnRenderDetailListItem")
	self.bindData.closeTipsBtn.luaClick = self:CreateAction("OnCloseTipsBtnClick")
	self.isInitTipsStore = false
	self.JobPathStore = gStoreManager:GetStoreGroup("UrbanAbilityOccupationPanelStore")
	self.curJobPathIndex = 1
	local msgEvents = {
		[gEventConstants.ON_CHANGE_SPIRITVIEW_DATA] = self:CreateAction("ChangeSpiriViewData")
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnCloseTipsBtnClick()
	self.bindData.occupationTips.gameObject:SetActive(false)
end

function M:OnDestroy()
	self:ClearMessageEvents()

	if self.goToDelay then
		self.goToDelay:Stop()
	end
end

function M:OnEnable()
	if not self.urbanAbilityStore then
		self.urbanAbilityStore = gStoreManager:GetStoreGroup("UrbanAbilityPanelStore")
	end

	Timer.New(function ()
		self:SetJobData(self.urbanAbilityStore:GetCurSpiritTid())
		self:SetSlotData()
		self.bindData.videoPlayer:Init()
		self:PlayVideo()
	end, 0.1):Start()
end

function M:SetDefaultData(data)
	self.defaultData = data
end

function M:PlayVideo()
	local cfg = LTConfig.FightSpiritConfig.GetConfig(self.urbanAbilityStore:GetCurSpiritTid())

	self.bindData.videoPlayer:PlayVideo(cfg.HeadIconVideoId, true, nil)
end

function M:ChangeSpiriViewData(eventId, data)
	self:SetJobData(data.data.id)
	self:SetSlotData()
	self:PlayVideo()
end

function M:SetJobData(tid)
	self.tid = tid
	self.spiritViewData = gSpiritManager:GetSpirit(tid)
	self.fsCfg = LTConfig.FightSpiritConfig.GetConfig(tid)
	local name = nil

	if self.spiritViewData then
		name = self.spiritViewData.Name
	else
		name = self.fsCfg.Name
	end

	if self.fsCfg then
		local cost = gSpiritJobManager:GetSpiritAllCost(tid)
		cost = cost or 0
		local limit = self.fsCfg.JobCostLimit

		self.bindData.progress:ProgressToValue(cost / limit)

		self.bindData.progressText.text = cost .. "/" .. limit
	end

	self.bindData.detail = 1

	self.bindData.occupationTips.gameObject:SetActive(false)
end

function M:SetOccupationList()
	local availableJobs = {}

	if self.spiritViewData then
		availableJobs = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs
	end

	local list = {}

	for i, v in pairs(availableJobs) do
		if v.Job ~= LTConfig.UrbanJobConfig.Jobless then
			local info = {
				id = v.Job,
				selected = false
			}

			table.insert(list, info)
		end
	end

	self.bindData.jobList2:SetList(list)
end

function M:SetSlotData()
	self.list = {}
	self.jobId = 0
	local availableJobs = {}

	if self.spiritViewData then
		availableJobs = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs
		self.jobId = self:GetDefaultSelectJobId(self.spiritViewData.SpiritInfo.SpiritJobInfo)
	end

	for i, v in pairs(availableJobs) do
		if v.Job ~= LTConfig.UrbanJobConfig.Jobless then
			local info = {
				id = v.Job
			}
			local curSelectJob = v.Job == self.jobId
			info.selected = curSelectJob

			if curSelectJob then
				info.tIndex = 0
			else
				info.tIndex = 1
			end

			table.insert(self.list, info)
		end
	end

	local emptyNum = self.fsCfg.JobLimit - #self.list

	if emptyNum == self.fsCfg.JobLimit then
		self.bindData.empty = self.Empty.Empty

		return
	else
		self.bindData.empty = self.Empty.NotEmpty
	end

	self.selectIndex = 1

	self.bindData.slotList:SetList(self.list)
	self:SetJobPath()
	self:SetJobExp()
	self:SetDetailData()
end

function M:SetJobExp()
	if not self.spiritViewData then
		return
	end

	local serverdata = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs[self.jobId]
	local cfg = LTConfig.UrbanJobConfig.GetConfig(self.jobId)

	if cfg and serverdata then
		self.curJobServerData = serverdata
		local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)
		local progress = serverdata.Exp / levelCfg.Exp

		if progress and progress > 0 then
			self.bindData.progress2:ProgressToValue(progress)
		else
			self.bindData.progress2:ProgressToValue(0)
		end
	end
end

function M:SetDetailData()
	if self.goToDelay then
		self.goToDelay:Stop()
	end

	self.goToDelay = Timer.New(function ()
		local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationDetailTemplateStore")

		store:SetData(self.jobId, self.spiritViewData.SpiritInfo, self.curJobPathIndex)
	end, 0.1):Start()
end

function M:SetTabJobPath(level)
	if level then
		self.bindData.jobList:SelectItem(level - 1)
	end
end

function M:GetDefaultSelectJobId(SpiritJobInfo)
	if SpiritJobInfo.CurrentJob ~= LTConfig.UrbanJobConfig.Jobless then
		return SpiritJobInfo.CurrentJob
	end

	for i, v in pairs(SpiritJobInfo.AvailableJobs) do
		if i ~= LTConfig.UrbanJobConfig.Jobless then
			return i
		end
	end

	return LTConfig.UrbanJobConfig.Jobless
end

function M:OnRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilitySlotTemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.id)

	if not cfg then
		store.empty = self.Empty.Empty
		store.active = self.Active.UnActive
		store.button.interactable = false
		store.title.text = ""

		return
	end

	store.empty = self.Empty.NotEmpty
	store.icon = cfg.Icon
	local classCfg = LTConfig.UrbanJobJobClassConfig.GetConfig(cfg.JobClass)

	if classCfg then
		store.title.text = classCfg.ClassName
	end

	if data.id == self.spiritViewData.SpiritInfo.SpiritJobInfo.CurrentJob then
		store.active = self.Active.Active
	else
		store.active = self.Active.UnActive
	end

	store.cost.text = cfg.Cost
	local serverdata = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs[data.id]

	if cfg and serverdata then
		local levelCfg = gSpiritJobManager:GetLevelData(cfg, self.tid)
		local progress = serverdata.Exp / levelCfg.Exp

		if progress and progress > 0 then
			store.progress = progress
		else
			store.progress = 0
		end

		if store.lv then
			store.lv.text = serverdata.Level
		end

		store.progessText = serverdata.Exp .. " / " .. levelCfg.Exp
	end

	local arg = {
		id = data.id,
		serverdata = serverdata
	}
	btn.luaClick = self:CreateActionWithArgs("OnItemClick", arg)
end

function M:OnItemClick(arg)
	self.jobId = arg.id
	self.curJobServerData = arg.serverdata

	self:RefreshJobSlotList()
	self:SetJobPath(self.tid, self.jobId)
	self:SetJobExp()
	self:SetDetailData()
end

function M:RefreshJobSlotList()
	for i, v in pairs(self.list) do
		local curSelectJob = v.id == self.jobId
		v.selected = curSelectJob

		if curSelectJob then
			v.tIndex = 0
		else
			v.tIndex = 1
		end
	end

	self.bindData.slotList:SetList(self.list)
end

function M:OnRenderJob2PathItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationShortTemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.id)

	if not cfg then
		return
	end

	local classCfg = LTConfig.UrbanJobJobClassConfig.GetConfig(cfg.JobClass)

	if classCfg then
		store.text = classCfg.ClassName
	end
end

function M:SetJobPath()
	local jobList = {}

	if self.jobId ~= 0 then
		jobList = gSpiritJobManager:GetJobData(self.jobId)
	end

	self.jobPath = {}
	local num = 1
	local index = 0
	self.curSelectIndex = 0

	for i, v in pairs(jobList) do
		local info = {
			id = v,
			selected = v == self.jobId,
			num = num
		}
		num = num + 1
		info.index = index

		if v == self.jobId then
			self.curSelectIndex = index
		end

		index = index + 1

		table.insert(self.jobPath, info)
	end

	self.bindData.jobList:SetList(self.jobPath)
end

function M:OnRenderJobPathItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationTabTemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.id)

	if not cfg then
		return
	end

	if data.num == #self.jobPath then
		store.isEnd = 1
	else
		store.isEnd = 0
	end

	store.title.text = cfg.Name

	if data.id == self.jobId then
		store.now = 1
	else
		store.now = 0
	end

	store.num.text = gUIUtils:NumToRoman(data.num)
	local arg = {
		index = data.index,
		btn = btn,
		cfg = cfg,
		text = cfg.PromoteDes
	}
	btn.luaClick = self:CreateActionWithArgs("OnPathBtnClick", arg)
end

function M:OnPathBtnClick(arg)
	self.curJobPathIndex = arg.index

	self:GotoIndex()
	self:ShowTips(arg)
end

function M:ShowTips(arg)
	if arg.cfg.Level <= self.curJobServerData.Level then
		return
	end

	if not arg.text or self:ContentIsEmpty(arg.text) then
		return
	end

	self.bindData.occupationLockText = arg.text

	self.bindData.occupationTips.gameObject:SetActive(true)
	self.bindData.occupationTips:SetPosition(arg.btn.transform.position)
end

function M:ContentIsEmpty(str)
	for i = 1, #str do
		if string.sub(str, i, i) ~= "\n" and string.sub(str, i, i) ~= " " then
			return false
		end
	end

	return true
end

function M:GotoIndex()
	local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationDetailTemplateStore")

	store:GoToIndex(self.curJobPathIndex)
end

function M:OnRenderJobPath2Item(btn, _, data)
	local store = gStoreManager:GetStoreGroup("CommonOccupationTemplate2Store"):GetStoreByWidget(btn)
	store.des = data.cfg.description
	store.icon = data.cfg.imageId
end

function M:GetSortBadgeList(id)
	local list = gSpiritJobManager:GetBadgeList(id, self.spiritViewData.SpiritInfo)
	local sortList = {}

	for i, v in pairs(list) do
		if not sortList[v.JobBadgeType] then
			sortList[v.JobBadgeType] = {}
		end

		table.insert(sortList[v.JobBadgeType], v.Id)
	end

	local showList = {}

	for i, v in pairs(sortList) do
		if self.unfoldList[i + 1] then
			table.insert(showList, {
				tIndex = 0,
				id = id,
				jobId = i
			})

			for k1, v1 in pairs(v) do
				table.insert(showList, {
					id = v1,
					tIndex = i + 1,
					jobId = id
				})
			end
		end
	end

	return showList
end

function M:OnRenderDetailList2Item(btn, _, data)
	if data.tIndex == 0 then
		local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationDetailTitleTemplateStore"):GetStoreByWidget(btn)
		store.title = self.OccupationDetailTitle[data.jobId + 1]
		store.button.luaClick = self:CreateActionWithArgs("OnUnfoldBtnClick", data)

		return
	end

	local store = gStoreManager:GetStoreGroup("CommonOccupationDetailTemplate2Store"):GetStoreByWidget(btn)
	local badge = self.spiritViewData.SpiritInfo.InfoBadge.Badges[data.id]

	if badge and badge.Active then
		store.isLock = 0
	else
		store.isLock = 1
	end

	local badgeCfg = LTConfig.UrbanBadgeConfig.GetConfig(data.id)

	if not badgeCfg then
		return
	end

	store.des = badgeCfg.Name
	store.buff = badgeCfg.Description

	if badgeCfg.UnlockDescription then
		local spiritId = badgeCfg.Type == LTConfig.UrbanBadgeConfig.Common and 0 or self.tid
		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.UrbanBadge, data.id, spiritId)
		store.unlockDes = badgeCfg.UnlockDescription .. "(" .. progress .. "/" .. badgeCfg.MaxProgress .. ")"
	else
		store.unlockDes = ""
	end
end

function M:OnL2BtnClick()
	if self.selectIndex > 1 then
		self.selectIndex = self.selectIndex - 1

		self:OnItemClick(self.list[self.selectIndex])
		self.bindData.slotList:SelectItem(self.selectIndex - 1)
	end
end

function M:OnR2BtnClick()
	if self.selectIndex < 3 and self.list[self.selectIndex + 1].id ~= 0 then
		self.selectIndex = self.selectIndex + 1

		self:OnItemClick(self.list[self.selectIndex])
		self.bindData.slotList:SelectItem(self.selectIndex - 1)
	end
end

function M:OnSelectFilterBtnClick(index)
	self:SetFoldList(index)
	self:SetDetailData()
	self:SetSelectFilterList()
end

function M:SetFoldList(selectType)
	self.unfoldList[selectType] = not self.unfoldList[selectType]
end

function M:OnChangeLeftAreaBtnClick()
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.urbanAbilityStore.bindData.navigationArea
end
