local BTween = require("LX6/Utils/BezierQuadTween")
local GameObject = UnityEngine.GameObject
C_PickupObject = DefClass("C_PickupObject", C_PickupObject, C_Object)
local PickupObject = C_PickupObject

function PickupObject:ctor(pid, target, bornPos, parent, liveTime, layer, deathCall, delayKill)
	self.mPid = pid

	if type(target) == "number" then
		self.mTemplateId = target
		self.mObject = GameObject.New("PickupObject" .. pid)
		self.mObject.transform.parent = parent
	else
		self.mObject = target
	end

	self.mBornPosition = bornPos
	self.mMoveRange = {
		max = 5,
		min = 1
	}
	self.mIsAlive = true
	self.mLiveTime = liveTime
	self.mDeathCall = deathCall
	self.mObject.transform.position = Vector3.New(bornPos.x, bornPos.y, bornPos.z)

	if self.mTemplateId then
		self.mEffectUUID = gCS.EffectMgr:PlayEffectsOnTransform(self.mTemplateId, self.mObject.transform, 0, 99999)

		if self.mEffectUUID ~= 0 and layer then
			SGUITools.SetChildLayer(self.mObject.transform, layer)
		end
	end

	self.mDelayKill = delayKill
	self.mIsKilling = false
	self.mCanEarlyDestroy = false
	self.earlyDestroyCheckFunction = nil
	self.earlyDestroyCheckInterval = 1
end

function PickupObject:Destroy()
	if self.mDelayTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.mDelayTimer)

		self.mDelayTimer = nil
	end

	if self.mEffectUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.mEffectUUID)
	end

	if self.mTemplateId then
		if self.mObject and not gCS.LuaUtils.IsNull(self.mObject) and not self.mObject:IsDestroyed() then
			if self.mDeathCall then
				self.mDeathCall(self.mObject.transform.position, self.mTemplateId)
			end

			GameObject.Destroy(self.mObject)
		end
	elseif self.mDeathCall then
		self.mDeathCall()
	end

	self = nil
end

function PickupObject:TweenMove(middlePos, targetPos, duration, easing, delay)
	if self.mDelayTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.mDelayTimer)

		self.mDelayTimer = nil
	end

	self.targetPos = targetPos

	if delay and delay > 0 then
		self.mDelayTimer = gLuaTimeMgrUtils.Delay(function ()
			self.mBTween = BTween.new(self.mBornPosition, middlePos, targetPos, duration, easing)
			self.mDelayTimer = nil
		end, delay)
	else
		self.mBTween = BTween.new(self.mBornPosition, middlePos, targetPos, duration, easing)
	end
end

function PickupObject:TweenTarget(middlePos, target, duration, easing, delay)
	if self.mDelayTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.mDelayTimer)

		self.mDelayTimer = nil
	end

	self.mTarget = target
	self.mEasing = easing
	self.mMiddlePos = middlePos
	self.mDuration = duration

	if delay and delay > 0 then
		self.mDelayTimer = gLuaTimeMgrUtils.Delay(function ()
			local targetPos = target.position
			self.mBTween = BTween.new(self.mBornPosition, middlePos, targetPos, duration, easing)
			self.mDelayTimer = nil
		end, delay)
	else
		local targetPos = target.position
		self.mBTween = BTween.new(self.mBornPosition, middlePos, targetPos, duration, easing)
	end
end

function PickupObject:GetPid()
	return self.mPid
end

function PickupObject:IsAlive()
	return self.mIsAlive
end

function PickupObject:IsKilling()
	return self.mIsKilling
end

function PickupObject:CheckEarlyDestroy()
	if self.earlyDestroyCheckFunction then
		return self.earlyDestroyCheckFunction()
	else
		return false
	end
end

local frameCounter = 0

function PickupObject:Update()
	local myPlayerUnitId = gCS.MyPlayerManager.PlayerUnitId

	if ulong.equals(myPlayerUnitId, ulong.zero) then
		return
	end

	if self.mIsAlive then
		self.mLiveTime = self.mLiveTime - gLogicTime.deltaTime

		if self.mLiveTime < 0 then
			self.mIsAlive = false
			self.mIsKilling = true
		end

		if self.mBTween then
			local tweenPos = self.mBTween:update(gLogicTime.deltaTime)

			if tweenPos then
				self.mObject.transform.position = tweenPos

				if not gCS.LuaUtils.IsNull(self.mTarget) and self.mLiveTime > 0 then
					self.mBTween:SetP2(self.mTarget.position)
				end
			else
				self.mBTween = nil
			end
		end

		if self.mCanEarlyDestroy then
			frameCounter = frameCounter + 1

			if self.earlyDestroyCheckInterval < frameCounter then
				frameCounter = 0

				if self:CheckEarlyDestroy() then
					self.mLiveTime = 0
					self.mIsAlive = false
					self.mIsKilling = true
				end
			end
		end
	else
		self.mLiveTime = self.mLiveTime - gLogicTime.deltaTime
		self.mIsKilling = self.mDelayKill ~= nil and self.mDelayKill + self.mLiveTime > 0

		if self.mIsKilling and not gCS.LuaUtils.IsNull(self.mObject) then
			if not gCS.LuaUtils.IsNull(self.mTarget) then
				self.mObject.transform.position = self.mTarget.position
			elseif self.targetPos then
				self.mObject.transform.position = self.targetPos
			end
		end
	end
end

return PickupObject
