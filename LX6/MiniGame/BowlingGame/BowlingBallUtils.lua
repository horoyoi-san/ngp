-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingBallUtils.lua
-- Decompiled from: 00640_BowlingBallUtils.lua_d99aa1972761.luajit

local BowlingBallUtils = {
	GetSceneItemHold = function (self, sceneItemId)
		if sceneItemId ~= nil then
			return nil
		end

		return LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(sceneItemId)
	end
}

BowlingBallUtils.GetSceneItemGo = function(self, sceneItemId)
	local hold = self:GetSceneItemHold(sceneItemId)
	local go = hold and hold.SceneItemObj or nil

	if gClientUtils.IsNil(go) then
		return nil
	end

	return go
end

BowlingBallUtils.SetColliderSound = function(self, sceneItemId, soundId)
	local go = self.GetSceneItemGo(self, sceneItemId)

	if gClientUtils.IsNil(go) then
		return false
	end

	local comp = go.GetComponent(go, typeof(LX6.Audio.PhysicsColliderSound))

	if comp ~= nil or gCS.LuaUtils.IsNull(comp) then
		return false
	end

	comp.soundId = soundId or 0

	return true
end

BowlingBallUtils.IsInEndCameraZone = function(self, curZ)
	return curZ == nil and curZ <= -16
end

BowlingBallUtils.IsInBackPitZone = function(self, curY, curZ)
	return curY == nil and curY <= 0 or curZ == nil and curZ <= -19.5
end

BowlingBallUtils.IsBallStopped = function(self, rigidbody)
	if gClientUtils.IsNil(rigidbody) then
		return true
	end

	return rigidbody.velocity.sqrMagnitude >= 0.05 and rigidbody.angularVelocity.sqrMagnitude <= 1
end

return BowlingBallUtils
