local env = {
	env = env,
	class = require("Core.class")
}

setmetatable(env, {
	__index = _G
})
setfenv(1, env)

SpoonGraphs = {}
SpoonTaskGroupGraphs = {}
SpoonEventGraphs = {}
local SpoonTransform_metatable = {
	__index = function (t, k)
		if k == "forward" then
			local f = Quaternion.Euler(0, t.facing, 0) * Vector3.forward
			t[k] = f

			return f
		end
	end
}
SpoonTransform = {
	new = function (x, y, z, facing, xRot, zRot, xScale, yScale, zScale)
		local t = {
			position = Vector3.New(x, y, z),
			facing = facing
		}

		if xRot ~= nil then
			t.rotation = Vector3.New(xRot, facing, zRot)
		else
			t.rotation = Vector3.New(0, facing, 0)
		end

		if xScale ~= nil then
			t.scale = Vector3.New(xScale, yScale, zScale)
		else
			t.scale = Vector3.New(1, 1, 1)
		end

		setmetatable(t, SpoonTransform_metatable)

		return t
	end
}
SpoonUnit = class()

function SpoonUnit:ctor(getter)
	self.getter = getter
end

function SpoonUnit:GetUnit()
	return self.getter()
end

function SpoonUnit:IsMe()
	local unit = self.getter()

	return unit and unit.isMe
end

SpoonWayPoint = class()

function SpoonWayPoint:ctor(x, y, z, facing, name, actionIndex)
	self.transform = SpoonTransform.new(x, y, z, facing)
	self.Name = name
	self.ActionIndex = actionIndex
end

SpoonDoor = class()

function SpoonDoor:ctor(name, px, py, pz, rx, ry, rz, sx, sy, sz, doorId, state)
	self.DoorId = doorId
	local w = gCS.LuaUtils.AddSpoonDoor(name, px, py, pz, rx, ry, rz, sx, sy, sz)

	while not gWaitableUtils.IsWaitDone(w) do
		coroutine.yield(nil)
	end

	self.SceneDoorController = w.GameObject:GetComponent(typeof(LX6.Share.SceneDoorController))

	self.SceneDoorController:SetDoorState(state, false)
end

SpoonTriggerEnemy = class()

function SpoonTriggerEnemy:ctor(id, transform)
	self.Id = id
	self.transform = transform
end

return env
