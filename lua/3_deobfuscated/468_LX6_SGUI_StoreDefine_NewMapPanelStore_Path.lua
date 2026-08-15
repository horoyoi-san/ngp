local MapNavigationMgr = LX6.Gps.MapNavigationMgr
local M = C_NewMapPanelStore

function M:ClearPathInfo()
	self.navInfo = nil
end

function M:TickPathObjects()
	local path = nil

	if gMapSystem.navigation:CanShowVehicleNavRoute() then
		path = MapNavigationMgr.GetUIRenderPath()
	end

	self:DrawVehiclePath(self.bindData.taskLineRenderer, path)
end

function M:DrawVehiclePath(line, path)
	if path ~= nil then
		line:ClearPoint()

		for i = 0, path.Length - 1 do
			local pos = self:TransformWorldToTex(path[i], self.areaId)

			line:AddPoint(pos.x, pos.y, 20, true, 0, 10)
		end

		line:RefreshSpline()
	else
		line:ClearPoint()
		line:RefreshSpline()
	end
end
