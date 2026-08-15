setfenv(1, require("LX6.Spoon.SpoonEnv"))

local SpoonMgr = {
	GetRaidGraph = function (self)
		return gCS.SpoonRaidMgr.Instance.RaidGraph
	end,
	GetWayPointById = function (self, Id)
		if type(Id) == "string" then
			print_error("#NoCreateIssu need input number not string")

			return
		end

		return gCS.SpoonRaidMgr.Instance:GetWayPointPosition(Id)
	end,
	GetWayPointFacingByNameOrId = function (self, nameOrId)
		if type(nameOrId) == "string" then
			print_error("#NoCreateIssu need input number not string")

			return
		end

		return gCS.SpoonRaidMgr.Instance:GetWayPointFacing(nameOrId)
	end,
	GetWayPointPositionByNameOrId = function (self, nameOrId)
		if type(nameOrId) == "string" then
			print_error("#NoCreateIssu need input number not string")

			return
		end

		return gCS.SpoonRaidMgr.Instance:GetWayPointPosition(nameOrId)
	end,
	GetWayPointByNameOrId = function (self, nameOrId)
		if type(nameOrId) == "string" then
			print_error("#NoCreateIssu need input number not string")

			return
		end

		local wayPointData = gCS.SpoonRaidMgr.Instance:GetWayPointData(nameOrId)

		return {
			transform = {
				position = wayPointData.position,
				eulerAngles = Vector3.New(0, wayPointData.facing, 0)
			}
		}
	end
}

return SpoonMgr
