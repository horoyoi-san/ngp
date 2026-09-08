-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_TaxiDest.lua
-- Decompiled from: 02315_MapSubSystem_TaxiDest.lua_727460f1d687.luajit

local formula_cs = require("LuaGen/AutoGen/Formula_cs")
local MessageConfig = LTConfig.MessageConfig
local UXVector3 = UX.Game.UXVector3
local TaxiManager = LX6.Drive.GamePlay.TaxiSystemManager.Instance
MapSubSystem_TaxiDest = DefClass("MapSubSystem_TaxiDest", MapSubSystem_TaxiDest, MapSubSystemBase)
local M = MapSubSystem_TaxiDest

M.OnInit = function(self)
	self.taxiTargets = {}
end

M.OnLoadData = function(self)
	for _, info in pairs(self.taxiTargets) do
		info.mapElement:Dispose()
	end

	self.taxiTargets = {}

	for i = 0, LTConfig.TaxiNavigationConfig.count - 1 do
		local cfg = LTConfig.TaxiNavigationConfig.LoadAt(i)
		local worldPos = Vector3.New(cfg.Coordinate[1], cfg.Coordinate[2], cfg.Coordinate[3])
		local raidId = cfg.RaidId and cfg.RaidId <= 0 and cfg.RaidId or LTConfig.RaidConfig.WorldMap
		local element = MapElement.CreateLegacy(EMapElementType.TaxiTarget, cfg.Id, EMapSubSystemType.TaxiDest, EMapViewMask.Taxi, raidId, 0)

		element:SetPosition(worldPos)
		element:SetActions({
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.GoTaxiDest
			}
		})

		element.mData.sIconId = cfg.SIconId
		element.fData.listIconId = cfg.ListIconId and cfg.ListIconId <= 0 and cfg.ListIconId or nil
		element.mData.lName = GpsLText.CreateCommonText(cfg, "Name")
		element.userdata = {
			taxiId = cfg.Id
		}

		element:SetVisible(true)

		local info = {
			mapElement = element
		}
		self.taxiTargets[cfg.Id] = info
	end
end

M.OnTaxiMapOpen = function(self)
	if not gMapAreaMgr.raidId2AreaId[gMapSystem.lastRaidId] then
		return
	end

	for id, info in pairs(self.taxiTargets) do
		local element = info.mapElement

		if element.raidId == gMapSystem.lastRaidId then
			element.SetVisible(element, false)
		else
			element.SetVisible(element, true)

			local worldPos = element.GetWorldPos(element)

			self.FindShortestPathLength(self, worldPos, function (dis)
				info.remainingDistance = dis
				local estimatedTotalDistance = TaxiManager.CurrentTaxiDistance + info.remainingDistance
				local cost = formula_cs:GetTaxiNormalCost(estimatedTotalDistance)
				local money = gUIUtils:GetMoneyByType(UX.Game.MoneyType.Money)
				local hasEnoughMoney = cost > money
				local tooClose = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, worldPos) <= (LTConfig.TaxiNavigationConfig.TaxiNearRange or 50)
				local isCurrentTarget = id ~= TaxiManager.CurrentDestinationUid
				local canTaxi = not isCurrentTarget and hasEnoughMoney and not tooClose

				if canTaxi then
					element:SetActions({
						[gMapSystem_Element_State.Normal] = {
							gMapSystemElementAction.GoTaxiDest
						}
					})
				else
					element:SetActions({})
				end

				if isCurrentTarget then
					element:SetTraceInfo(EMapGTraceType.ViewOnly)
				else
					element:ClearTraceInfo()
				end
			end)
		end
	end
end

M.SGetTooltipInfo = function(self, id)
	local cfg = LTConfig.TaxiNavigationConfig.GetConfig(id)
	local element = self.taxiTargets[id].mapElement
	local worldPos = element:GetWorldPos()
	local remainingDistance = self.taxiTargets[id].remainingDistance or 0
	local estimatedTotalDistance = TaxiManager.CurrentTaxiDistance + remainingDistance
	local cost = formula_cs:GetTaxiNormalCost(estimatedTotalDistance)
	local money = gUIUtils:GetMoneyByType(UX.Game.MoneyType.Money)
	local hasEnoughMoney = cost > money
	local tooClose = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, worldPos) <= (LTConfig.TaxiNavigationConfig.TaxiNearRange or 50)
	local isCurrentTarget = id ~= TaxiManager.CurrentDestinationUid
	local cantTaxiReasonType, cantTaxiReasonTextCfg = nil

	if isCurrentTarget then
		cantTaxiReasonType = 3
		cantTaxiReasonTextCfg = LTConfig.TextScriptTextConfig.GetConfig(89900977)
	elseif tooClose then
		cantTaxiReasonType = 1
		cantTaxiReasonTextCfg = LTConfig.TextScriptTextConfig.GetConfig(89900979)
	elseif not hasEnoughMoney then
		cantTaxiReasonType = 2
		cantTaxiReasonTextCfg = LTConfig.TextScriptTextConfig.GetConfig(89900978)
	end

	if not cantTaxiReasonType then
		element.SetActions(element, {
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.GoTaxiDest
			}
		})
	else
		element.SetActions(element, {})
	end

	local tooltipInfo = {
		type = EMapTooltipType.Taxi,
		header = {
			name = cfg.Name,
			imageId = cfg.SImageId
		},
		taxiInfo = {
			desc = cfg.Decs,
			cost = cost
		}
	}
	tooltipInfo.taxiInfo.cantTaxiType = cantTaxiReasonType

	return tooltipInfo
end

M.ExecuteAction = function(self, element, action, ctx)
	if action ~= gMapSystemElementAction.GoTaxiDest then
		TaxiManager:ChooseDestination(element.id)
		gMapUtils:CloseBigMap()
	end
end

M.AskVehicleNavigationPathPoints = function(self, targetposition, ignoredirection, ignorealley, usenavmeshconnect, navigationprofile)
	local uxVec = UXVector3.New(targetposition.x, targetposition.y, targetposition.z)
	local needcenterpoints = false

	if ignoredirection ~= nil then
		ignoredirection = false
	end

	if ignorealley ~= nil then
		ignorealley = false
	end

	if usenavmeshconnect ~= nil then
		usenavmeshconnect = false
	end

	if navigationprofile ~= nil then
		navigationprofile = UX.Game.LaneNavigationProfile.Default
	end

	slot8 = gClientToGameSceneDelegate

	slot8:AskVehicleNavigationPathPoints(0, uxVec, ignoredirection, ignorealley, needcenterpoints, usenavmeshconnect, navigationprofile).Callback = function (err, data)
		if err == MessageConfig.Ok then
			print("AskVehicleNavigationPathPoints err:", err)
		end
	end
end

M.FindShortestPathLength = function(self, targetposition, cb, ignoredirection, ignorealley, usenavmeshconnect, navigationprofile)
	if ignoredirection ~= nil then
		ignoredirection = false
	end

	if ignorealley ~= nil then
		ignorealley = false
	end

	if usenavmeshconnect ~= nil then
		usenavmeshconnect = false
	end

	if navigationprofile ~= nil then
		navigationprofile = UX.Game.LaneNavigationProfile.Default
	end

	local uxVec = UXVector3.New(targetposition.x, targetposition.y, targetposition.z)
	slot8 = gClientToGameSceneDelegate

	slot8:AskVehicleNavigationPathLength(uxVec, ignoredirection, ignorealley, usenavmeshconnect, navigationprofile).Callback = function (err, data)
		local dis = -1

		if err ~= MessageConfig.Ok then
			dis = data
		else
			print_error("#NoCreateIssue: AskVehicleNavigationPathLength err:", err, " targetPosition: ", uxVec, " ignoredirection: ", ignoredirection, " ignorealley: ", ignorealley)
		end

		if cb then
			cb(dis)
		end
	end
end

return M
