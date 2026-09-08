-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_MapEntrance.lua
-- Decompiled from: 01011_BigMapTooltip_MapEntrance.lua_7b6d5bc69fe2.luajit

C_BigMapTooltip_MapEntrance = DefClass("C_BigMapTooltip_MapEntrance", C_BigMapTooltip_MapEntrance, C_BigMapTooltipBase)
local M = C_BigMapTooltip_MapEntrance

M.SetUpInfo = function(self)
	if not self.ValidateTooltipInfo(self, "mapEntranceInfo") then
		return
	end

	self.GetStore(self, "MapEntranceTooltipStore")

	local info = self.tooltipInfo.mapEntranceInfo

	self.SetUpHeader(self)

	if info.type == gMapUtils.RaidMapEntranceType.Metro and info.type == gMapUtils.RaidMapEntranceType.Bus then
		print_error("BigMapTooltip_MapEntrance:SetUpInfo: Unsupported map entrance type: " .. tostring(info.type))

		return
	end

	local scrollStore = gStoreManager:GetStoreGroup("MapEntranceScrollStore"):GetStoreByWidget(self.store.entranceScroll.content)

	self.store.entranceScroll:GoToPos(Vector2.zero, true)
	self:SetUpScroll(scrollStore, info)
end

M.SetUpScroll = function(self, scrollStore, info)
	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(self.element.raidId, self.element:GetWorldPos().x, self.element:GetWorldPos().z)

	if blockId then
		local cfg = LTConfig.CollectionBlockConfig.GetConfig(blockId)
		scrollStore.location = cfg and cfg.BlockName or ""
	end

	local cfg = LTConfig.MapentranceConfig.GetConfig(info.id)
	local playerPos = gMapSystem:GetCurPlayerLocalPosition()
	local lineMoney = 0

	if playerPos then
		lineMoney = gMapSubSystem_Entrance:CalcMetroCost(gMapSystem.lastRaidId, self.element.raidId, playerPos, self.element:GetOriginWorldPos())
	end

	scrollStore.money = "#C(jinyuebi_Text)" .. tostring(lineMoney)
	scrollStore.desc = cfg.Information or ""
	self.routeList = {}

	if not table.isNilOrEmpty(cfg.RouteID) then
		for _, routeId in pairs(cfg.RouteID) do
			local routeCfg = LTConfig.MapentranceRouteConfig.GetConfig(routeId)

			if routeCfg then
				table.insert(self.routeList, {
					name = routeCfg.RouteName,
					iconId = routeCfg.RouteIcon,
					tintColor = routeCfg.Color
				})
			end
		end

		scrollStore.routeList.luaSimpleRenderItem = function(btn, index)
			local store = gStoreManager:GetStoreGroup("MapEntranceRouteStore"):GetStoreByWidget(btn)
			local data = self.routeList[index + 1]

			if store then
				store.lineName = data.name
				store.lineIcon = data.iconId
				store.lineColor = data.tintColor
			end
		end

		scrollStore.routeList:SetSimpleList(#self.routeList)
	end
end

M.SetUpActions = function(self, store, actions, blockReason)
	if not actions or #actions ~= 0 then
		store.showMainBtn = self.HIDE_BTN

		return
	end

	store.showMainBtn = self.SHOW_BTN

	if blockReason then
		store.mainBtnText = blockReason
		store.mainBtnInteractable = false

		return
	end

	store.mainBtnInteractable = true
	store.clickMain = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[1], self)
	store.mainBtnText = gMapUIUtils.GetElementActionName(actions[1])
end
