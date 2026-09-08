-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NewMapPanelStore_JiaMuView.lua
-- Decompiled from: 01040_NewMapPanelStore_JiaMuView.lua_c3c0ec8e6021.luajit

local M = C_NewMapPanelStore
local FactionInfluenceAreaConfig = LTConfig.FactionInfluenceAreaConfig
local FactionAreaPointConfig = LTConfig.FactionAreaPointConfig

M.EnableJiaMuView = function(self, enable)
	if enable then
		self.SetViewMask(self, EMapViewMask.Gangster + EMapViewMask.BigMap)
		self.SendFSMSignal(self, EBigMapFSMSignal.OpenJiaMuView)
	else
		self.SetViewMask(self, EMapViewMask.BigMap)
		self.SendFSMSignal(self, EBigMapFSMSignal.CloseJiaMuView)
	end

	self.SetScale(self, self.scale, true, true)
end

M.IsJiaMuViewEnabled = function(self)
	return self.fsms and self.fsms[4].currentState ~= EBigMapFSMState.JiaMuView_Open
end

M.FocusFactionInfluenceAreas = function(self, areaIds)
	if type(areaIds) ~= "number" then
		areaIds = {
			areaIds
		}
	end

	if type(areaIds) == "table" or #areaIds ~= 0 then
		return false
	end

	local minX, maxX, minZ, maxZ = nil

	for _, areaId in ipairs(areaIds) do
		local areaCfg = FactionInfluenceAreaConfig.GetConfig(areaId)

		if areaCfg then
			for _, pointId in ipairs(areaCfg.ContainPoints) do
				local pointCfg = FactionAreaPointConfig.GetConfig(pointId)
				local pos = pointCfg and pointCfg.PosXZ

				if pos then
					minX = not minX and pos.x or math.min(minX, pos.x)
					maxX = not maxX and pos.x or math.max(maxX, pos.x)
					minZ = not minZ and pos.y or math.min(minZ, pos.y)
					maxZ = not maxZ and pos.y or math.max(maxZ, pos.y)
				end
			end
		end
	end

	if not minX then
		return false
	end

	local texX, texY = self.TransformWorldXZToTexXY(self, (minX + maxX) * 0.5, (minZ + maxZ) * 0.5, gMapAreaMgr.XinQiAreaId)

	self.ScheduleOperation(self, self.OperationType.FocusTexPos, {
		["0:%\\xe1w\\xb5\\xe28\\xbc&\\xf6\\xfe\\xefq\\xe9"] = 4,
		texPos = Vector2.New(texX, texY)
	})

	return true
end

local JIAMU_SPIRIT_ID = 15020989

M.NeedAddJiaMuViewEntry = function(self)
	local isJiaMu = self.filterCharacterTid ~= JIAMU_SPIRIT_ID
	local systemUnlock = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.FactionInfluenceMap)

	return isJiaMu and systemUnlock
end
