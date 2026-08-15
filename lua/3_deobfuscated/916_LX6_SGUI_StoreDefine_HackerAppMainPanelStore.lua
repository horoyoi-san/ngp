local HackerMenuConfig = LTConfig.HackerMenuConfig
local HackAction = require("LX6/GUI/Hacker/HackAction")
local RedDotMgr = SGUI.RedDotMgr
C_HackerAppMainPanelStore = DefClass("C_HackerAppMainPanelStore", C_HackerAppMainPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.HackerAppMainPanelStore = C_HackerAppMainPanelStore
local M = C_HackerAppMainPanelStore

local function GEN_IPV6()
	local parts = {}

	for i = 1, 8 do
		local random_block = math.random(0, 65535)
		parts[i] = string.format("%04x", random_block)
	end

	return table.concat(parts, ":")
end

function M:DefineAllVariables()
	self.skillList = {}
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_HACKER_APP_REDPOINT_CHANGE] = self:CreateAction(self.RefreshBBSRedDot)
	}
end

function M:OnAwake()
	self:DefineAllVariables()

	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitClick")
end

function M:InitModel(args)
	M.base.InitModel(self, args)
end

function M:InitView(args)
	M.base.InitView(self, args)
	math.randomseed(os.time())
	self:InitBindData()
	self:RefreshView()
end

function M:InitBindData()
	self.bindData.carBtn.luaClick = self:CreateAction("OnClickCarBtn")
	self.bindData.bbsBtn.luaClick = self:CreateAction("OnClickBBSBtn")
	self.bindData.appList.luaSimpleRenderItem = self:CreateAction("OnRefreshAppList")
	self.bindData.appList.luaSimpleClick = self:CreateAction("OnClickAppList")
end

function M:RefreshView()
	self:RefreshSkillList()
	self:RefreshPlayerInfo()
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_HACKER_APP_CONTENT_CLOSE)
end

function M:ClearData()
	return
end

function M:OnClickCarBtn()
	local playerObj = gCS.MyPlayerManager.PlayerUnit.PlayerObj

	gVehicleGamePlayManager.cs_manager:AskSummonVehicle(LTConfig.VehicleConfig.HackerVehicle, playerObj.position, playerObj.eulerAngles.y, function ()
		gClientUtils.CloseMainPhonePanel()
	end)
end

function M:OnClickBBSBtn()
	gPanelManager:CheckShow(gPanelId.HACKER_MAIN_PANEL)
end

function M:RefreshSkillList()
	self.bindData.decorateText = GEN_IPV6()

	table.clear(self.skillList)

	for index = 0, HackerMenuConfig.count - 1 do
		local cfg = HackerMenuConfig.LoadAt(index)

		if cfg then
			local allowBuff = cfg.BuffID

			if gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, allowBuff) and cfg.MenuType ~= 0 then
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

	if #self.skillList > 0 then
		self.bindData.skillCtrl = 0
	else
		self.bindData.skillCtrl = 1
	end
end

function M:RefreshPlayerInfo()
	if gCS.MyPlayerManager.PlayerUnit then
		local cardId = gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
		local spiritViewData = gSpiritManager:GetSpirit(cardId)

		if table.isNilOrEmpty(spiritViewData) then
			print_error("当前找不到角色数据，cardId = " .. cardId)

			return
		end

		self.bindData.nameText = spiritViewData.Name
		local info = gHackManager.HackerSpiritInfo[cardId]

		if info then
			self.bindData.rankText = "#" .. info.Rank
		else
			self.bindData.rankText = "#-"
		end
	end

	self:RefreshBBSRedDot()
end

function M:OnRefreshAppList(btn, index)
	local data = self.skillList[index + 1]
	local store = gStoreManager:GetStoreGroup("HackerAppBaseBtnStore"):GetStoreByWidget(btn)

	if store then
		store.nameText = data.name
		store.funcIconId = data.img
		store.descText = data.des
		store.guide.guideID = data.GuideId
	end
end

function M:OnClickAppList(btn, index)
	local data = self.skillList[index + 1]

	if data and data.funcAction then
		HackAction.RunFunc(data.funcAction, data)
	end
end

function M:RefreshBBSRedDot()
	RedDotMgr.LuaSetRedDot(gHackManager.hasHackerJobRedDot, "HackBBSRedDot")
end
