-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\S_RobberyBoardTimeLineGuideTask2.lua
-- Decompiled from: 01396_S_RobberyBoardTimeLineGuideTask2.lua_7773f7da8cbc.luajit

C_S_RobberyBoardTimeLineGuideTask2 = DefClass("C_S_RobberyBoardTimeLineGuideTask2", C_S_RobberyBoardTimeLineGuideTask2, C_StoreGroup)
GroupName2Class.S_RobberyBoardTimeLineGuideTask2 = C_S_RobberyBoardTimeLineGuideTask2
local M = C_S_RobberyBoardTimeLineGuideTask2

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	local uiPivot = args and args.uiPivot

	if gClientUtils.IsNil(uiPivot) then
		return
	end

	self.id = args and args.id or 12150010

	self.rootGo.transform:ChangeLayersRecursively(Layer.Default)

	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale
	self.routeStepMap = {}
	local planningBoardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	local allStepIdList = planningBoardCfg.AllStep

	for _, stepId in ipairs(allStepIdList) do
		local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
		local stepIdList = self.routeStepMap[stepCfg.RouteGroup] or {}

		table.insert(stepIdList, stepId)

		self.routeStepMap[stepCfg.RouteGroup] = stepIdList
	end

	self.RefreshPanelView(self)

	self.bindData.name = planningBoardCfg.Name
end

M.RefreshRouteWidgetView = function(self, index, routeId)
	local widget = self.bindData[("route%d"):format(index)]
	local stepIdList = self.routeStepMap[routeId]
	local stepId = stepIdList[#stepIdList]
	local stepDetailCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local dividendsMultiPlayerId = stepDetailCfg.TaskId
	local multiPlayerCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(dividendsMultiPlayerId)
	local store = self:GetWidgetStore(widget)
	store.desc = multiPlayerCfg.Description
	local routeGroup = stepDetailCfg.RouteGroup
	local routeGroupCfg = LTConfig.PlanningBoardRouteConfig.GetConfig(routeGroup)
	store.title = routeGroupCfg.Desc
end

M.RefreshPanelView = function(self)
	local count = LTConfig.PlanningBoardRouteConfig.count

	for i = 1, count do
		local routeCfg = LTConfig.PlanningBoardRouteConfig.LoadAt(i - 1)

		self.RefreshRouteWidgetView(self, i, routeCfg.Id)
	end
end

M.GetWidgetStore = function(self, widget)
	return gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LANGUAGE_CHANGE] = self.CreateAction(self, self.OnLanguageChange)
	}
end

M.RegisterWidget = function(self)
	self.bindData.route1.luaClick = self.CreateAction(self, self.OnClickRoute1)
	self.bindData.route2.luaClick = self.CreateAction(self, self.OnClickRoute2)
	self.bindData.route3.luaClick = self.CreateAction(self, self.OnClickRoute3)
end

M.OnClickRoute1 = function(self)
end

M.OnClickRoute2 = function(self)
end

M.OnClickRoute3 = function(self)
end

M.OnLanguageChange = function(self)
	self.RefreshPanelView(self)
end
