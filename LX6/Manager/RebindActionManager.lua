-- Original chunk: @Lua\LuaFiles\LX6\Manager\RebindActionManager.lua
-- Decompiled from: 02265_RebindActionManager.lua_858116309876.luajit

local RebindActionConfig = LTConfig.RebindActionConfig
local RebindActionControllerConfig = LTConfig.RebindActionRebindActionControllerConfig
local RebindMode = LX6.Manager.RebindMode
local RebindActionActionMapConfig = LTConfig.RebindActionActionMapConfig
C_RebindActionManager = DefClass("C_RebindActionManager", C_RebindActionManager)
local M = C_RebindActionManager

M.ctor = function(self)
	self.buttonNamePCDic = {}
	self.buttonNameGamepadDic = {}

	for i = 0, LTConfig.InputKeyboardConfig.count - 1 do
		local cfg = LTConfig.InputKeyboardConfig.LoadAt(i)

		if cfg and not string.is_null_or_empty(cfg.ButtonName) then
			self.buttonNamePCDic[cfg.ButtonName] = cfg
		end
	end

	self.buttonNameGamepadDic = {}

	for i = 0, LTConfig.InputGamepadConfig.count - 1 do
		local cfg = LTConfig.InputGamepadConfig.LoadAt(i)

		if cfg and not string.is_null_or_empty(cfg.ButtonName) then
			self.buttonNameGamepadDic[cfg.ButtonName] = cfg
		end
	end
end

M.GetPCClassifyList = function(self)
	if not table.isNilOrEmpty(RebindActionConfig.ClassifyText) then
		return RebindActionConfig.ClassifyText
	end
end

M.GetPCTypeNameList = function(self)
	local typeNameList = {}

	for t = 1, #RebindActionConfig.TypeId do
		typeNameList[RebindActionConfig.TypeId[t]] = RebindActionConfig.TypeText[t]
	end

	return typeNameList
end

M.GetGamepadTypeNameList = function(self)
	local typeNameList = {}

	for t = 1, #RebindActionConfig.ControllerTypeId do
		typeNameList[RebindActionConfig.ControllerTypeId[t]] = RebindActionConfig.ControllerTypeText[t]
	end

	return typeNameList
end

M.InitRebindActionData = function(self, typeNameList)
	local rebindGroupedData = {}
	local tempMapData = {}

	for i = 0, RebindActionControllerConfig.count - 1 do
		local config = RebindActionControllerConfig.LoadAt(i)

		if config then
			local actionMapId = config.ActionMapId

			if not tempMapData[actionMapId] then
				tempMapData[actionMapId] = {}
			end

			table.insert(tempMapData[actionMapId], {
				id = config.Id,
				actionName = config.Name,
				button = gCS.RebindMgr:GetButtonNamesByActionId(config.Id, RebindMode.Gamepad, config.IsComposite):ToTable(),
				isRebind = gCS.RebindMgr:IsActionRebound(config.Id, RebindMode.Gamepad),
				isEmpty = gCS.RebindMgr:IsActionEmpty(config.Id, RebindMode.Gamepad),
				canRebind = config.CanRebind,
				isComposite = config.IsComposite,
				character = config.FightSpiritId
			})
		end
	end

	local typeUsed = {}

	for i = 0, RebindActionActionMapConfig.count - 1 do
		local config = RebindActionActionMapConfig.LoadAt(i)

		if config then
			local mapId = config.Id
			local classify = config.Classify
			local actionType = config.Type
			local mapDetails = tempMapData[mapId]

			if mapDetails then
				if not rebindGroupedData[classify] then
					rebindGroupedData[classify] = {}
				end

				if not table.contains(typeUsed, actionType) and actionType == 0 then
					table.insert(rebindGroupedData[classify], {
						["\t\r"] = -1,
						actionName = typeNameList[actionType]
					})
					table.insert(typeUsed, actionType)
				end

				for _, detail in ipairs(mapDetails) do
					table.insert(rebindGroupedData[classify], detail)
				end
			end
		end
	end

	return rebindGroupedData
end

gRebindActionManager = gRebindActionManager or C_RebindActionManager.new()
