local Math = {
	Abs = function (d)
		return math.abs(d)
	end,
	Asin = function (d)
		return math.asin(d)
	end,
	Atan = function (d)
		return math.atan(d)
	end,
	Atan2 = function (d)
		return math.atan2(d)
	end,
	Ceiling = function (d)
		return math.ceil(d)
	end,
	Cos = function (d)
		return math.cos(d)
	end,
	Exp = function (d)
		return math.exp(d)
	end,
	Floor = function (d)
		return math.floor(d)
	end,
	Log = function (d, base)
		return math.log(d, base)
	end,
	Log10 = function (d)
		return math.log(d, 10)
	end,
	Max = function (d1, d2)
		return math.max(d1, d2)
	end,
	Min = function (d1, d2)
		return math.min(d1, d2)
	end,
	Pow = function (d1, d2)
		return d1^d2
	end,
	Round = function (d)
		return Mathf.Round(d)
	end,
	Sign = function (d)
		return Mathf.Sign(d)
	end,
	Sin = function (d)
		return math.sin(d)
	end,
	Sqrt = function (d)
		return math.sqrt(d)
	end,
	Tan = function (d)
		return math.tan(d)
	end,
	Truncate = function (d)
		if d < 0 then
			return math.ceil(d)
		end

		return math.floor(d)
	end
}

return Math
