-- Original chunk: @Lua\LuaFiles\LX6\Object\ObjectManager.lua
-- Decompiled from: 00236_ObjectManager.lua_b58d4efddd94.luajit

local PickupObject = require("LX6/Object/PickupObject")
local GameConfig = LTConfig.GameConfig
local M = gObjectManager or {}
M.objectList = {}
M.objectCount = 0

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self:ClearData()
end

M.ClearData = function(self)
	self:ClearAll()

	self.objectCount = 0
end

local GenerateRandomXZPosition = function(minRange, maxRange, height, offsetDir, angle)
	local offsetRad = math.atan2(offsetDir.z, offsetDir.x)
	local radius = (maxRange - minRange) * math.random(1, 128) / 128 + minRange
	local rad = Mathf.PI * 0.5 * math.random(-angle, angle) / 180
	local x = radius * math.cos(rad + offsetRad)
	local y = height
	local z = radius * math.sin(rad + offsetRad)

	return Vector3.New(x, y, z)
end

local GenerateRandomPositionWithY = function(range, y)
	local theta = Mathf.PI * 2 * math.random(1, 360) / 360
	local x = range * math.cos(theta)
	local z = range * math.sin(theta)

	return Vector3.New(x, y, z)
end

M.PlayPickUpEffect = function(self, effectId, getEffectId, pos0, delayMove, notUseHeight, AfterPickFunc)
	local minTime = GameConfig.DropItemEffect[1]
	local maxTime = GameConfig.DropItemEffect[2]
	local moveTime = minTime + (maxTime - minTime) * math.random(1, 100) / 100
	local minHeight = GameConfig.DropItemEffect[3]
	local maxHeight = GameConfig.DropItemEffect[4]
	local height = minHeight + (maxHeight - minHeight) * math.random(1, 100) / 100
	local minRange = GameConfig.DropItemEffect[5]
	local maxRange = GameConfig.DropItemEffect[6]
	local angle = GameConfig.DropItemEffect[7]
	local delayKill = GameConfig.DropItemEffect[9] or 0.15
	local offsetDir = -gCS.CameraDataMgr.MainCamera.transform.forward

	if notUseHeight then
		height = 0
	end

	local pos1 = pos0 + GenerateRandomXZPosition(minRange, maxRange, height, offsetDir, angle)
	local obj = PickupObject.new(self.objectCount, effectId, pos0, gCS.MyPlayerManager.PlayerUnit.PlayerObj.transform.parent, moveTime, nil, function ()
		if getEffectId then
			gCS.EffectMgr:PlayEffectsForUnit(gCS.MyPlayerManager.PlayerUnit, getEffectId, LX6.Effect.EffectPlayTag.Gameplay, gCS.MyPlayerManager.PlayerUnit.LocalPosition, 0.6)
		end

		if AfterPickFunc then
			AfterPickFunc()
		end
	end, delayKill)

	gLuaTimeMgrUtils.Delay(function ()
		obj:TweenTarget(pos1, gCS.MyPlayerManager.PlayerUnit.ModelSlot.upbody or gCS.MyPlayerManager.PlayerUnit.ModelSlot.body, moveTime, "dropItem")
	end, delayMove or 0, nil, , true)
	table.insert(self.objectList, obj)
	self:RefreshDynamicUpdate()
end

M.PlayGadgetPickUp = function(self, targetObj, useUpBody, AfterPickFunc, playerpid)
	local minTime = GameConfig.DropItemEffect[1]
	local maxTime = GameConfig.DropItemEffect[2]
	local moveTime = minTime + (maxTime - minTime) * math.random(1, 100) / 100
	local minHeight = GameConfig.DropItemEffect[3]
	local maxHeight = GameConfig.DropItemEffect[4]
	local height = minHeight + (maxHeight - minHeight) * math.random(1, 100) / 100
	local minRange = GameConfig.DropItemEffect[5]
	local maxRange = GameConfig.DropItemEffect[6]
	local angle = GameConfig.DropItemEffect[7]
	local delayKill = GameConfig.DropItemEffect[9] or 0.15
	local offsetDir = -gCS.CameraDataMgr.MainCamera.transform.forward
	local pos0 = targetObj.transform.position
	local pos1 = pos0 + GenerateRandomXZPosition(minRange, maxRange, height, offsetDir, angle)
	local unitId = nil

	if not playerpid or playerpid ~= ulong.zero then
		unitId = gCS.MyPlayerManager.PlayerUnitId
	else
		local flag, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(playerpid, ulong.zero)

		if not flag then
			return
		end
	end

	local playerUnit = gCS.SceneDataMgr.GetUnit(unitId)

	if not playerUnit then
		return
	end

	local obj = PickupObject.new(self.objectCount, targetObj, pos0, playerUnit.PlayerObj.transform.parent, moveTime, nil, function ()
		if type(AfterPickFunc) ~= "function" then
			AfterPickFunc()
		elseif AfterPickFunc and AfterPickFunc.DynamicInvoke then
			AfterPickFunc:DynamicInvoke()
		end
	end, delayKill)
	local playerTrans = nil

	if useUpBody then
		playerTrans = playerUnit.ModelSlot.upbody or playerUnit.ModelSlot.body
	else
		playerTrans = playerUnit.PlayerObj
	end

	gLuaTimeMgrUtils.Delay(function ()
		obj:TweenTarget(pos1, playerTrans, moveTime, "dropItem")
	end, 0, nil, , true)
	table.insert(self.objectList, obj)
	self:RefreshDynamicUpdate()
end

M.UnRegisterGadgetPickUp = function(self, target)
	for i, v in ipairs(self.objectList) do
		if target ~= v.mObject then
			table.remove(self.objectList, i)

			return
		end
	end
end

M.ClearAll = function(self)
	if self.objectList == nil then
		for k, v in ipairs(self.objectList) do
			v:Destroy()
		end
	end

	self.objectList = {}

	self:RefreshDynamicUpdate()
end

M.RefreshDynamicUpdate = function(self)
	if table.isNilOrEmpty(self.objectList) then
		gLuaClient:UnregisterDynamicUpdate("gObjectManager")
	else
		gLuaClient:RegisterDynamicUpdate("gObjectManager", self)
	end
end

M.OnUpdate = function(self)
	local deathObjectIndices = {}

	for k, v in ipairs(self.objectList) do
		if v:IsAlive() or v:IsKilling() then
			v:Update()
		else
			v:Destroy()
			table.insert(deathObjectIndices, k)
		end
	end

	for i = #deathObjectIndices, 1, -1 do
		table.remove(self.objectList, deathObjectIndices[i])
	end

	self:RefreshDynamicUpdate()
end

gObjectManager = M
