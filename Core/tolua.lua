-- Original chunk: @Lua\LuaFiles\Core\tolua.lua
-- Decompiled from: 00001_tolua.lua_b23c55d2e28d.luajit

if jit then
	if jit.opt then
		jit.opt.start(3)
	end

	jit.off()
	jit.flush()
end

if DebugServerIp then
	require("mobdebug").start(DebugServerIp)
end

require("Core.functions")

Mathf = require("UnityEngine.Mathf")
Vector3 = require("UnityEngine.Vector3")
Quaternion = require("UnityEngine.Quaternion")
Vector2 = require("UnityEngine.Vector2")
Vector4 = require("UnityEngine.Vector4")
Color = require("UnityEngine.Color")
Ray = require("UnityEngine.Ray")
Bounds = require("UnityEngine.Bounds")
RaycastHit = require("UnityEngine.RaycastHit")
Touch = require("UnityEngine.Touch")
LayerMask = require("UnityEngine.LayerMask")
Plane = require("UnityEngine.Plane")
EventInstance = require("UnityEngine.EventInstance")
Time = reimport("UnityEngine.Time")
list = require("Core.list")

require("Core.event")
require("Core.typeof")
require("Core.slot")
require("Core.Timer")
require("Core.coroutine")
require("Core.ValueType")
require("Core.Reflection.BindingFlags")
