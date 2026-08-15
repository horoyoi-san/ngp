local Tween = require("LX6/Utils/Tween")
local BezierQuadTween = {}
local BezierQuadTween_MT = {
	__index = BezierQuadTween
}

function BezierQuadTween:update(dt)
	if self.t < 1 then
		self.tween:update(dt)

		local p0 = {
			self.P0.x,
			self.P0.y,
			self.P0.z
		}
		local p1 = {
			self.P1.x,
			self.P1.y,
			self.P1.z
		}
		local p2 = {
			self.P2.x,
			self.P2.y,
			self.P2.z
		}
		local param0 = (1 - self.t) * (1 - self.t)
		local param1 = 2 * self.t * (1 - self.t)
		local param2 = self.t * self.t
		self.Bt.x = param0 * self.P0.x + param1 * self.P1.x + param2 * self.P2.x
		self.Bt.y = param0 * self.P0.y + param1 * self.P1.y + param2 * self.P2.y
		self.Bt.z = param0 * self.P0.z + param1 * self.P1.z + param2 * self.P2.z

		return self.Bt
	end

	return nil
end

function BezierQuadTween.new(p0, p1, p2, duration, easing)
	local obj = {
		t = 0,
		P0 = p0,
		P1 = p1,
		P2 = p2,
		Bt = Vector3.New(0, 0, 0)
	}

	setmetatable(obj, BezierQuadTween_MT)

	obj.tween = Tween.new(duration, obj, {
		t = 1
	}, easing)

	return obj
end

function BezierQuadTween:SetP2(p2)
	self.P2 = p2
end

return BezierQuadTween
