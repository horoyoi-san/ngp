-- Original chunk: @Lua\LuaFiles\LX6\Manager\DynamicObstacleManager.lua
-- Decompiled from: 00696_DynamicObstacleManager.lua_6ed31004d544.luajit

local M = gDynamicObstacleManager or {}
M.obstacleType = {
	["\\xacg~"] = 1
}

M.CreateDynamicObstacleWithType = function(self, taskId, obstacle, obstacleID)
	if obstacle.colliderType ~= M.obstacleType.Box then
		local pos = Vector3.NewT(obstacle.pos)
		local eulerAngle = Vector3.NewT(obstacle.rotation)
		local scale = Vector3.NewT(obstacle.scale)
		local center = Vector3.NewT(obstacle.colliderCenter)
		local size = Vector3.NewT(obstacle.colliderSize)

		gCS.DynamicObstacles.Instance:AddBoxDynamicObstacle(obstacleID, pos, eulerAngle, scale, center, size, taskId)
	end
end

M.RemoveDynamicObstacle = function(self, obstacleID, taskId)
	gCS.DynamicObstacles.Instance:RemoveDynamicObstacle(obstacleID, taskId)
end

gDynamicObstacleManager = M
