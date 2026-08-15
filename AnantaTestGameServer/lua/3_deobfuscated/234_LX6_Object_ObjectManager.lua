local PickupObject = require("LX6/Object/PickupObject")
local GameConfig = LTConfig.GameConfig
local M = gObjectManager or {}
M.objectList = {}
M.objectCount = 0

function M:OnBeforeSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	self:ClearData()
end

function M:ClearData()
	self:ClearAll()

	self.objectCount = 0
end

local function GenerateRandomXZPosition(minRange, maxRange, height, offsetDir, angle)
	local offsetRad = math.atan2(offsetDir.z, offsetDir.x)
	local radius = (maxRange - minRange) * math.random(1, 128) / 128 + minRange
	local rad = Mathf.PI * 0.5 * math.random(-angle, angle) / 180
	local x = radius * math.cos(rad + offsetRad)
	local y = height
	local z = radius * math.sin(rad + offsetRad)

	return Vector3.New(x, y, z)
end

local function GenerateRandomPositionWithY(range, y)
	local theta = Mathf.PI * 2 * math.random(1, 360) / 360
	local x = range * math.cos(theta)
	local z = range * math.sin(theta)

	return Vector3.New(x, y, z)
end

function M:PlayPickUpEffect(effectId, getEffectId, pos0, delayMove, notUseHeight, AfterPickFunc)
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
			gCS.EffectMgr:PlayEffectsForUnit(gCS.MyPlayerManager.PlayerUnit, getEffectId, gCS.MyPlayerManager.PlayerUnit.LocalPosition, 0.6)
		end

		if AfterPickFunc then
			AfterPickFunc()
		end
	end, delayKill)

	gLuaTimeMgrUtils.Delay(function ()
		obj:TweenTarget(pos1, gCS.MyPlayerManager.PlayerUnit.ModelSlot.upbody or gCS.MyPlayerManager.PlayerUnit.ModelSlot.body, moveTime, "dropItem")
	end, delayMove or 0, nil, nil, true)
	table.insert(self.objectList, obj)
	self:RefreshDynamicUpdate()
end

function M:PlayGadgetPickUp(targetObj, useUpBody, AfterPickFunc)
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
	local obj = PickupObject.new(self.objectCount, targetObj, pos0, gCS.MyPlayerManager.PlayerUnit.PlayerObj.transform.parent, moveTime, nil, function ()
		if type(AfterPickFunc) == "function" then
			AfterPickFunc()
		elseif AfterPickFunc and AfterPickFunc.DynamicInvoke then
			AfterPickFunc:DynamicInvoke()
		end
	end, delayKill)
	local playerTrans = nil

	if useUpBody then
		playerTrans = gCS.MyPlayerManager.PlayerUnit.ModelSlot.upbody or gCS.MyPlayerManager.PlayerUnit.ModelSlot.body
	else
		playerTrans = gCS.MyPlayerManager.PlayerUnit.PlayerObj
	end

	gLuaTimeMgrUtils.Delay(function ()
		obj:TweenTarget(pos1, playerTrans, moveTime, "dropItem")
	end, 0, nil, nil, true)
	table.insert(self.objectList, obj)
	self:RefreshDynamicUpdate()
end

function M:UnRegisterGadgetPickUp(target)
	for i, v in ipairs(self.objectList) do
		if target == v.mObject then
			table.remove(self.objectList, i)

			return
		end
	end
end

function M:ClearAll()
	if self.objectList ~= nil then
		for k, v in ipairs(self.objectList) do
			v:Destroy()
		end
	end

	self.objectList = {}

	self:RefreshDynamicUpdate()
end

function M:RefreshDynamicUpdate()
	if table.isNilOrEmpty(self.objectList) then
		gLuaClient:UnregisterDynamicUpdate("gObjectManager")
	else
		gLuaClient:RegisterDynamicUpdate("gObjectManager", self)
	end
end

function M:OnUpdate()
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
