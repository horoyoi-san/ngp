-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityOccupation1PanelStore.lua
-- Decompiled from: 01186_UrbanAbilityOccupation1PanelStore.lua_28aa2fd6dec1.luajit

C_UrbanAbilityOccupation1PanelStore = DefClass("C_UrbanAbilityOccupation1PanelStore", C_UrbanAbilityOccupation1PanelStore, C_StoreGroup)
GroupName2Class.UrbanAbilityOccupation1PanelStore = C_UrbanAbilityOccupation1PanelStore
local M = C_UrbanAbilityOccupation1PanelStore

M.ctor = function(self)
	self.Empty = {
		["\\x85\\xbe\\x8eg.\\xea*"] = 0,
		["h\\xa3\\xb2\\xbb\\xaf"] = 1
	}
	self.Active = {
		["\\x9e\\xbf$\\xa8~7\\xe86"] = 1,
		["=K\\x85\\x87\\x95D"] = 0
	}
	self.Select = {
		["mHxZK,"] = 0,
		["/M\\x9d\\x8b\\x80U"] = 1
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

M.OnAwake = function(self)
	self.bindData.slotList.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.slotList.luaSelectedChanged = self:CreateAction("OnSelectedChanged")

	self.bindData.slotList.onGetTIndex = function(csIndex)
		return self.list[csIndex + 1].tIndex
	end

	self.bindData.jobList.luaSimpleRenderItem = self:CreateAction("OnRenderJobPathItem")
	self.bindData.jobList.luaSimpleDynamicRenderItem = self:CreateAction("OnRenderJobPathItem")
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

M.OnCloseTipsBtnClick = function(self)
	self.bindData.occupationTips.gameObject:SetActive(false)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	if self.goToDelay then
		self.goToDelay:Stop()
	end

	self.cachedSelectIndex = -1
end

M.OnEnable = function(self)
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

M.SetDefaultData = function(self, data)
	self.defaultData = data
end

M.PlayVideo = function(self)
	local cfg = LTConfig.FightSpiritConfig.GetConfig(self.urbanAbilityStore:GetCurSpiritTid())

	self.bindData.videoPlayer:PlayVideo(cfg.HeadIconVideoId, true, nil)
end

M.ChangeSpiriViewData = function(self, eventId, data)
	self.SetJobData(self, data.data.id)
	self.SetSlotData(self)
	self.PlayVideo(self)
end

M.SetJobData = function(self, tid)
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

M.SetOccupationList = function(self)
	local availableJobs = {}

	if self.spiritViewData then
		availableJobs = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs
	end

	local list = {}

	for i, v in pairs(availableJobs) do
		if v.Job == LTConfig.UrbanJobConfig.Jobless then
			local info = {
				id = v.Job,
				selected = false
			}

			table.insert(list, info)
		end
	end

	self._occupationListData = list

	self.bindData.jobList2:SetSimpleList(#list)
end

M.SetSlotData = function(self)
	self.list = {}
	self.jobId = 0
	local availableJobs = {}

	if self.spiritViewData then
		availableJobs = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs

		if self.defaultData and self.defaultData.jobId then
			self.jobId = self.defaultData.jobId
		else
			self.jobId = self.GetDefaultSelectJobId(self, self.spiritViewData.SpiritInfo.SpiritJobInfo)
		end
	end

	for i, v in pairs(availableJobs) do
		if v.Job == LTConfig.UrbanJobConfig.Jobless then
			local info = {
				id = v.Job
			}
			local curSelectJob = v.Job ~= self.jobId
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

	if emptyNum ~= self.fsCfg.JobLimit then
		self.bindData.empty = self.Empty.Empty

		return
	else
		self.bindData.empty = self.Empty.NotEmpty
	end

	self.selectIndex = 1

	self.bindData.slotList:SetSimpleList(#self.list)
	self:SetJobPath()
	self:SetJobExp()
	self:SetDetailData()
end

M.SetJobExp = function(self)
	if not self.spiritViewData then
		return
	end

	local serverdata = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs[self.jobId]
	local cfg = LTConfig.UrbanJobConfig.GetConfig(self.jobId)

	if cfg and serverdata then
		self.curJobServerData = serverdata
		local levelCfg = gSpiritJobManager:GetLevelConfig(cfg)
		local progress = serverdata.Exp / levelCfg.Exp

		if progress and progress <= 0 then
			self.bindData.progress2:ProgressToValue(progress)
		else
			self.bindData.progress2:ProgressToValue(0)
		end
	end
end

M.SetDetailData = function(self)
	if self.goToDelay then
		self.goToDelay:Stop()
	end

	self.goToDelay = Timer.New(function ()
		local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationDetailTemplateStore")

		store:SetData(self.jobId, self.spiritViewData.SpiritInfo, self.curJobPathIndex)
	end, 0.1):Start()
end

M.SetTabJobPath = function(self, level)
	if level then
		self.bindData.jobList:SelectItem(level - 1)
	end
end

M.GetDefaultSelectJobId = function(self, SpiritJobInfo)
	if SpiritJobInfo.CurrentJob == LTConfig.UrbanJobConfig.Jobless then
		return SpiritJobInfo.CurrentJob
	end

	for i, v in pairs(SpiritJobInfo.AvailableJobs) do
		if i == LTConfig.UrbanJobConfig.Jobless then
			return i
		end
	end

	return LTConfig.UrbanJobConfig.Jobless
end

M.OnRenderItem = function(self, btn, index)
	local data = self.list[index + 1]
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

	if data.id ~= self.spiritViewData.SpiritInfo.SpiritJobInfo.CurrentJob then
		store.active = self.Active.Active
	else
		store.active = self.Active.UnActive
	end

	store.cost.text = cfg.Cost
	local serverdata = self.spiritViewData.SpiritInfo.SpiritJobInfo.AvailableJobs[data.id]

	if cfg and serverdata then
		local levelCfg = gSpiritJobManager:GetLevelData(cfg, self.tid)
		local progress = serverdata.Exp / levelCfg.Exp

		if progress and progress <= 0 then
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
	btn.luaClick = self.CreateActionWithArgs(self, "OnItemClick", arg)
end

M.OnSelectedChanged = function(self)
	self.cachedSelectIndex = self.bindData.slotList.selectedIndex
end

M.OnItemClick = function(self, arg)
	if self.isRefreshingList then
		return
	end

	self.jobId = arg.id
	self.curJobServerData = arg.serverdata

	self.SetJobPath(self, self.tid, self.jobId)
	self.SetJobExp(self)
	self.SetDetailData(self)
	self.RefreshJobSlotList(self)
end

M.RefreshJobSlotList = function(self)
	for i, v in pairs(self.list) do
		local curSelectJob = v.id ~= self.jobId

		if self.cachedSelectIndex == -1 then
			curSelectJob = i - 1 ~= self.cachedSelectIndex
		end

		v.selected = curSelectJob

		if curSelectJob then
			v.tIndex = 0
		else
			v.tIndex = 1
		end
	end

	self.isRefreshingList = true

	self.bindData.slotList:SetSimpleList(#self.list)

	if self.cachedSelectIndex > 0 then
		self.bindData.slotList:SelectItem(self.cachedSelectIndex, false)
	end

	self.isRefreshingList = false
end

M.SetJobPath = function(self)
	local jobList = {}

	if self.jobId == 0 then
		jobList = gSpiritJobManager:GetJobData(self.jobId)
	end

	self.jobPath = {}
	local num = 1
	local index = 0
	self.curSelectIndex = 0

	for i, v in pairs(jobList) do
		local info = {
			id = v,
			selected = v ~= self.jobId,
			num = num
		}
		num = num + 1
		info.index = index

		if v ~= self.jobId then
			self.curSelectIndex = index
		end

		index = index + 1

		table.insert(self.jobPath, info)
	end

	self.bindData.jobList:SetSimpleList(#self.jobPath)

	if self.curSelectIndex then
		self.bindData.jobList:SelectItem(self.curSelectIndex, false)
	end
end

M.OnRenderJobPathItem = function(self, btn, index)
	local data = self.jobPath[index + 1]
	local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationTabTemplateStore"):GetStoreByWidget(btn)
	local cfg = LTConfig.UrbanJobConfig.GetConfig(data.id)

	if not cfg then
		return
	end

	if data.num ~= #self.jobPath then
		store.isEnd = 1
	else
		store.isEnd = 0
	end

	store.title.text = cfg.Name

	if data.id ~= self.jobId then
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

M.OnPathBtnClick = function(self, arg)
	self.curJobPathIndex = arg.index

	self.GotoIndex(self)
	self.ShowTips(self, arg)
end

M.ShowTips = function(self, arg)
	if arg.cfg.Level < self.curJobServerData.Level then
		return
	end

	if not arg.text or self.ContentIsEmpty(self, arg.text) then
		return
	end

	self.bindData.occupationLockText = arg.text

	self.bindData.occupationTips.gameObject:SetActive(true)
	self.bindData.occupationTips:SetPosition(arg.btn.transform.position)
end

M.ContentIsEmpty = function(self, str)
	for i = 1, #str do
		if string.sub(str, i, i) == "\n" and string.sub(str, i, i) == " " then
			return false
		end
	end

	return true
end

M.GotoIndex = function(self)
	local store = gStoreManager:GetStoreGroup("UrbanAbilityOccupationDetailTemplateStore")

	store:GoToIndex(self.curJobPathIndex)
end

M.SetFoldList = function(self, selectType)
	self.unfoldList[selectType] = not self.unfoldList[selectType]
end

M.OnChangeLeftAreaBtnClick = function(self)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.urbanAbilityStore.bindData.navigationArea
end
