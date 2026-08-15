C_BigMapTooltip_MapEntrance = DefClass("C_BigMapTooltip_MapEntrance", C_BigMapTooltip_MapEntrance, C_BigMapTooltipBase)
local M = C_BigMapTooltip_MapEntrance

function M:SetUpInfo()
	if not self:ValidateTooltipInfo("mapEntranceInfo") then
		return
	end

	self:GetStore("MapEntranceTooltipStore")

	local info = self.tooltipInfo.mapEntranceInfo

	self:SetUpHeader()
	self:SetUpLocation()

	if info.type ~= gMapUtils.RaidMapEntranceType.Metro then
		print_error("BigMapTooltip_MapEntrance:SetUpInfo: Unsupported map entrance type: " .. tostring(info.type))

		return
	end

	local scrollStore = gStoreManager:GetStoreGroup("MapEntranceScrollStore"):GetStoreByWidget(self.store.entranceScroll.content)

	self.store.entranceScroll:GoToPos(Vector2.zero, true)
	self:SetUpScroll(scrollStore, info)
end

function M:SetUpScroll(scrollStore, info)
	local cfg = LTConfig.MapentranceConfig.GetConfig(info.id)
	scrollStore.desc = cfg.Information or ""

	if cfg.RouteID and cfg.RouteID > 0 then
		local routeCfg = LTConfig.MapentranceRouteConfig.GetConfig(cfg.RouteID)
		scrollStore.lineName = routeCfg.RouteName
		scrollStore.lineIcon = routeCfg.RouteIcon
		local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

		if playerPos then
			scrollStore.lineMoney = gMapSubSystem_Entrance:CalcMetroCost(gMapSystem.lastRaidId, self.element.raidId, playerPos, self.element:GetOriginWorldPos())
		end
	end
end

function M:SetUpActions(store, actions, blockReason)
	if not actions or #actions == 0 then
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
