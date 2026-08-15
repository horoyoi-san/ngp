local HackerMenuConfig = LTConfig.HackerMenuConfig
local HackAction = require("LX6/GUI/Hacker/HackAction")
local RedDotMgr = SGUI.RedDotMgr
C_HackerAppPanelStore = DefClass("C_HackerAppPanelStore", C_HackerAppPanelStore, C_StoreGroup)
GroupName2Class.HackerAppPanelStore = C_HackerAppPanelStore
local M = C_HackerAppPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnRefreshItemList")
	self.bindData.itemList.luaSimpleClick = self:CreateAction("OnChangeItem")
	self.bindData.skillList.luaSimpleRenderItem = self:CreateAction("OnRefreshSkillList")
	self.bindData.skillList.luaSimpleClick = self:CreateAction("OnChangeSkill")
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.carBtn.luaClick = self:CreateAction("CallVehicle")
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnShow(panelId, data)
	self:InitInfo()
end

function M:OnClose()
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:InitInfo()
	self:SetPlayerInfo()

	self.itemList = {}
	self.skillList = {}

	for index = 0, HackerMenuConfig.count - 1 do
		local cfg = HackerMenuConfig.LoadAt(index)

		if cfg then
			local view = {
				name = cfg.Title,
				des = cfg.Description,
				img = cfg.Image,
				funcAction = cfg.FuncAction,
				panelId = cfg.PanelId or 0,
				GuideId = cfg.GuideId,
				Id = cfg.Id,
				isNew = cfg.Id == 1 and gHackManager.hasHackerJobRedDot or false,
				menuType = cfg.MenuType,
				GuideId = cfg.GuideId
			}

			if cfg.MenuType == 0 then
				table.insert(self.itemList, view)
			else
				table.insert(self.skillList, view)
			end
		end
	end

	self.bindData.itemList:SetSimpleList(#self.itemList)
	self.bindData.skillList:SetSimpleList(#self.skillList)
end

function M:SetPlayerInfo()
	local jobId = gSpiritJobManager.GetCurSpiritJobId()
	local info = gSpiritJobManager.GetCurSpiritJob(jobId)

	if table.isNilOrEmpty(info) then
		return
	end

	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(info.Job)

	if urbanJobCfg then
		local cardId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
		local hackInfo = gHackManager.HackerSpiritInfo[cardId]
		self.bindData.rankLevel = hackInfo and hackInfo.Rank or 0
	end

	if gCS.MyPlayerManager.PlayerUnit then
		local cardId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
		self.spiritViewData = gSpiritManager:GetSpirit(cardId)

		if table.isNilOrEmpty(self.spiritViewData) then
			print_error("当前找不到角色数据，cardId = " .. cardId)

			return
		end

		self.bindData.name = self.spiritViewData.Name
		local info = LTConfig.FightSpiritConfig.GetConfig(cardId)

		if info then
			self.bindData.playerImg = info.SHeadIconID
		end
	end
end

function M:OnRefreshItemList(btn, index)
	local data = self.itemList[index + 1]
	local store = gStoreManager:GetStoreGroup("HackerAppTemplateStore"):GetStoreByWidget(btn)

	if store then
		local redKey = "HackerAppItemRedDot.HackerAppItemList" .. data.Id
		btn.redKey = redKey

		RedDotMgr.LuaSetRedDot(data.isNew, redKey)

		store.des = data.des
		store.img = data.img
		store.name = data.name
		store.guide.guideID = data.GuideId
	end
end

function M:OnChangeItem(btn, index)
	local data = self.itemList[index + 1]

	if data and data.funcAction then
		HackAction.RunFunc(data.funcAction, data)
	end
end

function M:OnRefreshSkillList(btn, index)
	local data = self.skillList[index + 1]
	local store = gStoreManager:GetStoreGroup("HackerToolTemplate"):GetStoreByWidget(btn)

	if store then
		store.title = data.name
		store.img = data.img
		store.guide.guideID = data.GuideId
	end
end

function M:OnChangeSkill(btn, index)
	local data = self.skillList[index + 1]

	if data and data.funcAction then
		HackAction.RunFunc(data.funcAction, data)
	end
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.HACKER_APP_PANEL)
end

function M:CallVehicle()
	local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj

	gVehicleGamePlayManager.cs_manager:AskSummonVehicle(LTConfig.VehicleConfig.HackerVehicle, playerObj.position, playerObj.eulerAngles.y, function ()
		gPanelManager:Close(gPanelId.HACKER_APP_PANEL)
	end)
end
