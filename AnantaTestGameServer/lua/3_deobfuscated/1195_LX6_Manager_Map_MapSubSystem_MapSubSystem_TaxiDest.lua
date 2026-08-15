local formula_cs = require("LuaGen/AutoGen/Formula_cs")
local MessageConfig = LTConfig.MessageConfig
local UXVector3 = UX.Game.UXVector3
MapSubSystem_TaxiDest = DefClass("MapSubSystem_TaxiDest", MapSubSystem_TaxiDest, MapSubSystemBase)
local M = MapSubSystem_TaxiDest

function M:OnInit()
	self.taxiTargets = {}
end

function M:OnLoadData()
	for _, info in pairs(self.taxiTargets) do
		info.mapElement:Dispose()
	end

	self.taxiTargets = {}

	for i = 0, LTConfig.TaxiNavigationConfig.count - 1 do
		local cfg = LTConfig.TaxiNavigationConfig.LoadAt(i)
		local worldPos = Vector3.New(cfg.Coordinate[1], cfg.Coordinate[2], cfg.Coordinate[3])
		local element = MapElement.CreateLegacy(EMapElementType.TaxiTarget, cfg.Id, EMapSubSystemType.TaxiDest, EMapViewMask.Taxi, LTConfig.RaidConfig.WorldMap, 0)

		element:SetPosition(worldPos)
		element:SetActions({
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.GoTaxiDest
			}
		})

		element.mData.sIconId = cfg.SIconId
		element.fData.listIconId = cfg.ListIconId and cfg.ListIconId > 0 and cfg.ListIconId or nil
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

function M:OnTaxiMapOpen()
	if gMapSystem.lastRaidId ~= LTConfig.RaidConfig.WorldMap then
		return
	end

	for id, info in pairs(self.taxiTargets) do
		local element = info.mapElement
		local worldPos = element:GetWorldPos()

		self:FindShortestPathLength(worldPos, function (dis)
			local distance = dis + gTaxiManager.CurrentTaxiDistance
			info.distance = distance
			local cost = formula_cs:GetTaxiNormalCost(distance)
			local money = gUIUtils:GetMoneyByType(UX.Game.MoneyType.Money)
			local hasEnoughMoney = cost <= money
			local tooClose = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, worldPos) < (LTConfig.TaxiNavigationConfig.TaxiNearRange or 50)
			local isCurrentTarget = id == gTaxiManager.CurrentDestinationUid
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

function M:SGetTooltipInfo(id)
	local cfg = LTConfig.TaxiNavigationConfig.GetConfig(id)
	local element = self.taxiTargets[id].mapElement
	local worldPos = element:GetWorldPos()
	local distance = self.taxiTargets[id].distance + gTaxiManager.CurrentTaxiDistance
	local cost = formula_cs:GetTaxiNormalCost(distance)
	local money = gUIUtils:GetMoneyByType(UX.Game.MoneyType.Money)
	local hasEnoughMoney = cost <= money
	local tooClose = Vector3.Distance(gCS.MyPlayerManager.PlayerUnit.LocalPosition, worldPos) < (LTConfig.TaxiNavigationConfig.TaxiNearRange or 50)
	local isCurrentTarget = id == gTaxiManager.CurrentDestinationUid
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
		element:SetActions({
			[gMapSystem_Element_State.Normal] = {
				gMapSystemElementAction.GoTaxiDest
			}
		})
	else
		element:SetActions({})
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

function M:ExecuteAction(element, action, ctx)
	if action == gMapSystemElementAction.GoTaxiDest then
		gTaxiManager:ChooseDestination({
			id = element.id
		})
		gMapUtils:CloseBigMap()
	end
end

function M:AskVehicleNavigationPathPoints(targetposition, ignoredirection, ignorealley)
	local uxVec = UXVector3.New(targetposition.x, targetposition.y, targetposition.z)
	local needcenterpoints = false

	gClientToGameSceneDelegate:AskVehicleNavigationPathPoints(0, uxVec, ignoredirection, ignorealley, needcenterpoints).Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			print("AskVehicleNavigationPathPoints err:", err)
		end
	end
end

function M:FindShortestPathLength(targetposition, cb, ignoredirection, ignorealley)
	if ignoredirection == nil then
		ignoredirection = false
	end

	if ignorealley == nil then
		ignorealley = false
	end

	local uxVec = UXVector3.New(targetposition.x, targetposition.y, targetposition.z)

	gClientToGameSceneDelegate:AskVehicleNavigationPathLength(uxVec, ignoredirection, ignorealley).Callback = function (err, data)
		local dis = -1

		if err == MessageConfig.Ok then
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
