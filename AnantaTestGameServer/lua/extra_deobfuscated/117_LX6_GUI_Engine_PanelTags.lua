local bit = require("bit")
gPanelTags = {
	HasFlag = function (tags, flag)
		if tags == nil then
			return false
		end

		return bit.band(tags, flag) == flag
	end
}

return gPanelTags
