-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerAppPanelStore.lua
-- Decompiled from: 01692_HackerAppPanelStore.lua_e714d9b3db8c.luajit

local HackerMenuConfig = LTConfig.HackerMenuConfig
local HackAction = require("LX6/GUI/Hacker/HackAction")
local RedDotMgr = SGUI.RedDotMgr
C_HackerAppPanelStore = DefClass("C_HackerAppPanelStore", C_HackerAppPanelStore, C_StoreGroup)
GroupName2Class.HackerAppPanelStore = C_HackerAppPanelStore
local M = C_HackerAppPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshItemList")
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, "OnChangeItem")
	self.bindData.skillList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshSkillList")
	self.bindData.skillList.luaSimpleClick = self.CreateAction(self, "OnChangeSkill")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.carBtn.luaClick = self.CreateAction(self, "CallVehicle")
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnShow = function(self, panelId, data)
	self.InitInfo(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.InitInfo = function(self)
	self.SetPlayerInfo(self)

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
				isNew = cfg.Id ~= 1 and gHackManager.hasHackerJobRedDot or false,
				menuType = cfg.MenuType,
				GuideId = cfg.GuideId
			}

			if cfg.MenuType ~= 0 then
				table.insert(self.itemList, view)
			else
				table.insert(self.skillList, view)
			end
		end
	end

	self.bindData.itemList:SetSimpleList(#self.itemList)
	self.bindData.skillList:SetSimpleList(#self.skillList)
end

M.SetPlayerInfo = function(self)
	local jobId = gSpiritJobManager.GetCurSpiritJobId()
	local info = gSpiritJobManager.GetCurSpiritJob(jobId)

	if table.isNilOrEmpty(info) then
		return
	end

	local urbanJobCfg = LTConfig.UrbanJobConfig.GetConfig(info.Job)

	if urbanJobCfg then
		local hackInfo = gHackManager.HackerJobInfo
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

M.OnRefreshItemList = function(self, btn, index)
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

M.OnChangeItem = function(self, btn, index)
	local data = self.itemList[index + 1]

	if data and data.funcAction then
		HackAction.RunFunc(data.funcAction, data)
	end
end

M.OnRefreshSkillList = function(self, btn, index)
	local data = self.skillList[index + 1]
	local store = gStoreManager:GetStoreGroup("HackerToolTemplate"):GetStoreByWidget(btn)

	if store then
		store.title = data.name
		store.img = data.img
		store.guide.guideID = data.GuideId
	end
end

M.OnChangeSkill = function(self, btn, index)
	local data = self.skillList[index + 1]

	if data and data.funcAction then
		HackAction.RunFunc(data.funcAction, data)
	end
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.HACKER_APP_PANEL)
end

M.CallVehicle = function(self)
	local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj
	slot2 = gVehicleGamePlayManager.cs_manager

	slot2:AskSummonVehicle(LTConfig.VehicleConfig.HackerVehicle, playerObj.position, playerObj.eulerAngles.y, function ()
		gPanelManager:Close(gPanelId.HACKER_APP_PANEL)
	end)
end
