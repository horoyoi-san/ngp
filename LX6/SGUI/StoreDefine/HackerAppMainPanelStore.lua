-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerAppMainPanelStore.lua
-- Decompiled from: 02022_HackerAppMainPanelStore.lua_a2601518ed35.luajit

local HackerMenuConfig = LTConfig.HackerMenuConfig
local HackAction = require("LX6/GUI/Hacker/HackAction")
local RedDotMgr = SGUI.RedDotMgr
C_HackerAppMainPanelStore = DefClass("C_HackerAppMainPanelStore", C_HackerAppMainPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.HackerAppMainPanelStore = C_HackerAppMainPanelStore
local M = C_HackerAppMainPanelStore

local GEN_IPV6 = function()
	local parts = {}

	for i = 1, 8 do
		local random_block = math.random(0, 65535)
		parts[i] = string.format("%04x", random_block)
	end

	return table.concat(parts, ":")
end

M.DefineAllVariables = function(self)
	self.skillList = {}
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_HACKER_APP_REDPOINT_CHANGE] = self.CreateAction(self, self.RefreshBBSRedDot)
	}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)

	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitClick")
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
end

M.InitView = function(self, args)
	M.base.InitView(self, args)
	math.randomseed(os.time())
	self.InitBindData(self)
	self.RefreshView(self)
end

M.InitBindData = function(self)
	self.bindData.carBtn.luaClick = self.CreateAction(self, "OnClickCarBtn")
	self.bindData.bbsBtn.luaClick = self.CreateAction(self, "OnClickBBSBtn")
	self.bindData.appList.luaSimpleRenderItem = self.CreateAction(self, "OnRefreshAppList")
	self.bindData.appList.luaSimpleClick = self.CreateAction(self, "OnClickAppList")
end

M.RefreshView = function(self)
	self.RefreshSkillList(self)
	self.RefreshPlayerInfo(self)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_HACKER_APP_CONTENT_CLOSE)
end

M.ClearData = function(self)
end

M.OnClickCarBtn = function(self)
	local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj
	slot2 = gVehicleGamePlayManager.cs_manager

	slot2:AskSummonVehicle(LTConfig.VehicleConfig.HackerVehicle, playerObj.position, playerObj.eulerAngles.y, function ()
		gClientUtils.CloseMainPhonePanel()
	end)
end

M.OnClickBBSBtn = function(self)
	gPanelManager:CheckShow(gPanelId.HACKER_MAIN_PANEL)
end

M.RefreshSkillList = function(self)
	self.bindData.decorateText = GEN_IPV6()

	table.clear(self.skillList)

	for index = 0, HackerMenuConfig.count - 1 do
		local cfg = HackerMenuConfig.LoadAt(index)

		if cfg then
			local allowBuff = cfg.BuffID

			if gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, allowBuff) and cfg.MenuType == 0 then
				local view = {
					name = cfg.Title,
					des = GEN_IPV6(),
					img = cfg.Image,
					funcAction = cfg.FuncAction,
					panelId = cfg.PanelId or 0,
					GuideId = cfg.GuideId,
					Id = cfg.Id,
					menuType = cfg.MenuType
				}

				table.insert(self.skillList, view)
			end
		end
	end

	self.bindData.appList:SetSimpleList(#self.skillList)

	if #self.skillList <= 0 then
		self.bindData.skillCtrl = 0
	else
		self.bindData.skillCtrl = 1
	end
end

M.RefreshPlayerInfo = function(self)
	if gCS.MyPlayerManager.PlayerUnit then
		local cardId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
		local spiritViewData = gSpiritManager:GetSpirit(cardId)

		if table.isNilOrEmpty(spiritViewData) then
			print_error("当前找不到角色数据，cardId = " .. cardId)

			return
		end

		self.bindData.nameText = spiritViewData.Name
		local info = gHackManager.HackerJobInfo

		if info then
			self.bindData.rankText = "#" .. info.Rank
		else
			self.bindData.rankText = "#-"
		end
	end

	self.RefreshBBSRedDot(self)
end

M.OnRefreshAppList = function(self, btn, index)
	local data = self.skillList[index + 1]
	local store = gStoreManager:GetStoreGroup("HackerAppBaseBtnStore"):GetStoreByWidget(btn)

	if store then
		store.nameText = data.name
		store.funcIconId = data.img
		store.descText = data.des
		store.guide.guideID = data.GuideId
	end
end

M.OnClickAppList = function(self, btn, index)
	local data = self.skillList[index + 1]

	if data and data.funcAction then
		HackAction.RunFunc(data.funcAction, data)
	end
end

M.RefreshBBSRedDot = function(self)
	RedDotMgr.LuaSetRedDot(gHackManager.hasHackerJobRedDot, "HackBBSRedDot")
end
