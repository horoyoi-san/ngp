local M = gDynamicObstacleManager or {}
M.obstacleType = {
	Box = 1
}

function M:CreateDynamicObstacleWithType(taskId, obstacle, obstacleID)
	if obstacle.colliderType == M.obstacleType.Box then
		local pos = Vector3.NewT(obstacle.pos)
		local eulerAngle = Vector3.NewT(obstacle.rotation)
		local scale = Vector3.NewT(obstacle.scale)
		local center = Vector3.NewT(obstacle.colliderCenter)
		local size = Vector3.NewT(obstacle.colliderSize)

		gCS.DynamicObstacles.Instance:AddBoxDynamicObstacle(obstacleID, pos, eulerAngle, scale, center, size, taskId)
	end
end

function M:RemoveDynamicObstacle(obstacleID, taskId)
	gCS.DynamicObstacles.Instance:RemoveDynamicObstacle(obstacleID, taskId)
end

gDynamicObstacleManager = M
