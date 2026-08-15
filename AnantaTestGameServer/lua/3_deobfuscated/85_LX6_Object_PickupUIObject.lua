local BTween = require("LX6/Utils/BezierQuadTween")
C_PickupUIObject = DefClass("C_PickupUIObject", C_PickupUIObject, C_PickupObject)
local PickupUIObject = C_PickupUIObject

local function GetScreenPos(bornWorldPos)
	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(bornWorldPos)

	if screenPos.z < 0 then
		screenPos.x = -screenPos.x
		screenPos.y = -screenPos.y
	end

	local screenPos = gUtils:ScreenToUIPosition(screenPos)

	return screenPos
end

function PickupUIObject:TweenMove(middlePosFunc, targetPos, duration, easing, delay)
	if self.mDelayTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.mDelayTimer)

		self.mDelayTimer = nil
	end

	if delay and delay > 0 then
		self.mDelayTimer = gLuaTimeMgrUtils.Delay(function ()
			local screenPos = GetScreenPos(self.mBornPosition)
			self.mBTween = BTween.new(screenPos, middlePosFunc(screenPos), targetPos, duration, easing)
			self.mDelayTimer = nil
		end, delay)
	else
		local screenPos = GetScreenPos(self.mBornPosition)
		self.mBTween = BTween.new(self.mBornPosition, middlePosFunc(screenPos), targetPos, duration, easing)
	end
end

function PickupUIObject:Update()
	if self.mIsAlive then
		self.mLiveTime = self.mLiveTime - Time.deltaTime

		if self.mLiveTime < 0 then
			self.mIsAlive = false
		end

		if self.mBTween then
			local tweenPos = self.mBTween:update(Time.deltaTime)

			if tweenPos then
				self.mObject.transform.localPosition = tweenPos
			else
				self.mBTween = nil
			end
		else
			local screenPos = GetScreenPos(self.mBornPosition)
			self.mObject.transform.localPosition = screenPos
		end
	end
end

return PickupUIObject
