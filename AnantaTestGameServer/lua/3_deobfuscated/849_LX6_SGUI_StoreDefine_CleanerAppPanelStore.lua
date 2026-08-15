C_CleanerAppPanelStore = DefClass("C_CleanerAppPanelStore", C_CleanerAppPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerAppPanelStore = C_CleanerAppPanelStore
local M = C_CleanerAppPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.list.luaRenderItem = self:CreateAction(self.OnRenderItem)
	self.bindData.enterOrderButton.luaClick = self:CreateAction(self.OnEnterOrderClick)
end

function M:InitModel()
	M.base.InitModel(self)

	self.spiritJobIdList = self:GetCurSpiritJobIdList()
end

function M:GetCurSpiritJobIdList()
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)

	if targetJobId then
		return {
			targetJobId
		}
	else
		return {}
	end
end

function M:InitView()
	M.base.InitView(self)
	gWasherManager.RefreshWasherAvatarView(self.bindData.avatar, true)

	self.bindData.roleName = gPlayerManager.infoLogin.bindData.name
	local viewDataList = {}

	for _, spiritJobId in ipairs(self.spiritJobIdList) do
		table.insert(viewDataList, {
			spiritJobId = spiritJobId
		})
	end

	self.selectedJobId = viewDataList[1] and viewDataList[1].spiritJobId

	self.bindData.list:SetList(viewDataList)

	gWasherManager.appShown = true
end

function M:RefreshPanelView()
	self.bindData.list:RefreshList()
end

function M:OnRenderItem(btn, _, data)
	local storeName = btn.Store
	local store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(btn)
	local spiritJobId = data.spiritJobId
	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(spiritJobId)
	store.name = gWasherManager.GetMainContentSpiritName()
	store.jobName = urbanJobCfg.Name
	local spiritJob = gSpiritJobManager.GetCurSpiritJob(spiritJobId)
	local registerTime = os.date("%Y.%m.%d", spiritJob.RegisterTime)
	store.time = LTConfig.TextScriptTextConfig.GetConfig(89901082).Text:format(registerTime)
	local headAvatarStore = gStoreManager:GetStoreGroup("HeadAvatarSquareBtnStore"):GetStoreByWidget(store.avatar)
	headAvatarStore.avatarId = gWasherManager.GetPlayerAvatarID()
end

function M:GetUrbanJobAvatarConfig(spiritId)
	local count = LTConfig.UrbanJobAvatarConfig.count

	for i = 0, count - 1 do
		local urbanJobAvatarCfg = LTConfig.UrbanJobAvatarConfig.LoadAt(i)

		if urbanJobAvatarCfg.SpiritId == spiritId then
			return urbanJobAvatarCfg
		end
	end
end

function M:OnEnterOrderClick()
	if gClientUtils.NotNil(self.rootGo) then
		gWasherManager:SwitchAppTab(gClientConst.WASHER_APP_SHOW_TYPE.ORDER, true)
	end
end

function M:OnHeadIconClick()
	if gClientUtils.NotNil(self.rootGo) then
		gWasherManager:SwitchAppTab(gClientConst.WASHER_APP_SHOW_TYPE.ORDER, true)
	end
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end

function M:ClearData()
	gWasherManager.appShown = false
end
