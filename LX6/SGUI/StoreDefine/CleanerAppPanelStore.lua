-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CleanerAppPanelStore.lua
-- Decompiled from: 02044_CleanerAppPanelStore.lua_9d7ab046d087.luajit

C_CleanerAppPanelStore = DefClass("C_CleanerAppPanelStore", C_CleanerAppPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.CleanerAppPanelStore = C_CleanerAppPanelStore
local M = C_CleanerAppPanelStore

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.OnExitClick)
	self.bindData.list.luaRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.bindData.enterOrderButton.luaClick = self.CreateAction(self, self.OnEnterOrderClick)
end

M.InitModel = function(self)
	M.base.InitModel(self)

	self.spiritJobIdList = self.GetCurSpiritJobIdList(self)
end

M.GetCurSpiritJobIdList = function(self)
	local targetJobId = gSpiritJobManager.GetAvailableJobId(LTConfig.UrbanJobJobClassConfig.Washer)

	if targetJobId then
		return {
			targetJobId
		}
	else
		return {}
	end
end

M.InitView = function(self)
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
	gWasherManager:OnAppOpen()
end

M.RefreshPanelView = function(self)
	self.bindData.list:RefreshList()
end

M.OnRenderItem = function(self, btn, _, data)
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

M.GetUrbanJobAvatarConfig = function(self, spiritId)
	local count = LTConfig.UrbanJobAvatarConfig.count

	for i = 0, count - 1 do
		local urbanJobAvatarCfg = LTConfig.UrbanJobAvatarConfig.LoadAt(i)

		if urbanJobAvatarCfg.SpiritId ~= spiritId then
			return urbanJobAvatarCfg
		end
	end
end

M.OnEnterOrderClick = function(self)
	if gClientUtils.NotNil(self.rootGo) then
		gWasherManager:SwitchAppTab(gClientConst.WASHER_APP_SHOW_TYPE.ORDER, true)
	end
end

M.OnHeadIconClick = function(self)
	if gClientUtils.NotNil(self.rootGo) then
		gWasherManager:SwitchAppTab(gClientConst.WASHER_APP_SHOW_TYPE.ORDER, true)
	end
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_WASHER_APP_CONTENT_CLOSE)
end

M.ClearData = function(self)
	gWasherManager:OnAppClose()
end
