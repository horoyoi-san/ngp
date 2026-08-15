C_PoliceFinePanelStore = DefClass("C_PoliceFinePanelStore", C_PoliceFinePanelStore, C_StoreGroup)
GroupName2Class.PoliceFinePanelStore = C_PoliceFinePanelStore
local M = C_PoliceFinePanelStore

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
	self.panelId = nil
end

function M:OnShow(panelId, data)
	self.panelId = panelId
	self.data = data

	self:ShowFineResult(data.list)
end

function M:OnClose()
	self.fineViewList = nil
end

function M:ShowFineResult(fineList, fineMoney, jobExpInfo)
	local money = 0
	local fineViewList = {}

	for _, v in ipairs(fineList) do
		local fineCfg = LTConfig.PoliceFineConfig.GetConfig(v)
		local dropCfg = LTConfig.DropConfig.GetConfig(fineCfg.Drop)

		if dropCfg == nil then
			print_error_without_stack("PoliceFineConfig=" .. tostring(v) .. " 找不到drop配置！请策划检查 dropId=", fineCfg.Drop)

			return
		end

		local item = {
			tIndex = 0,
			text = fineCfg.Title,
			money = dropCfg.Money
		}

		table.insert(fineViewList, item)

		money = money + dropCfg.Money
	end

	self.bindData.money = fineMoney or money
	self.fineViewList = fineViewList

	self.bindData.list:SetSimpleList(#self.fineViewList)
	Timer.New(function ()
		if self.STATE_EnableOnce then
			self:Close()
		end
	end, 4):Start()

	local jobClassId = LTConfig.UrbanJobJobClassConfig.Police
	local exp = 0

	if jobExpInfo then
		for k, v in pairs(jobExpInfo) do
			if jobClassId == k then
				exp = v
			end
		end
	end

	self.bindData.addexp = "+" .. exp
	local curJobId = gSpiritJobManager:GetCurJobId()

	if curJobId == LTConfig.UrbanJobConfig.Jobless then
		print_warn(" curJobId == LTConfig.UrbanJobConfig.Jobless ")

		return
	end

	local curJobCfg = LTConfig.UrbanJobConfig.GetConfig(curJobId)
	local levelCfg = gSpiritJobManager:GetLevelConfig(curJobCfg)
	local curJobData = gSpiritJobManager:GetCurJobData()

	if not curJobData then
		print_warn(" not curJobData ")

		return
	end

	self.bindData.title = curJobCfg.Name
	local curExp = curJobData.Exp
	local maxExp = levelCfg.Exp

	self.bindData.progress:ProgressToValue(curExp / maxExp)

	self.bindData.progressText = curExp .. "/" .. maxExp

	self.bindData.bar.anim:Play()
end

function M:OnRenderItem(btn, index)
	local data = self.fineViewList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.text = data.text
end

function M:SetCloseCallback(closeCallback)
	self.closeCallback = closeCallback
end

function M:Close()
	if self.panelId then
		gPanelManager:Close(self.panelId)

		return
	end

	if self.closeCallback then
		self.closeCallback()
	end

	self.rootWidget:SetActive(false)
end
