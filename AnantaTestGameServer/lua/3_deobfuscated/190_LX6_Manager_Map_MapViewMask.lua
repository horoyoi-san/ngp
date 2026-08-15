gMapViewMaskHelper = {}
local M = gMapViewMaskHelper
M._cache = {}

function M:SplitViewMask(compositeViewMask)
	if self._cache[compositeViewMask] then
		return self._cache[compositeViewMask]
	end

	local masks = {}
	self._cache[compositeViewMask] = masks
	local viewMask = 1

	while viewMask <= EMapViewMask.Max do
		if bit.band(viewMask, compositeViewMask) > 0 then
			masks[#masks + 1] = viewMask
		end

		viewMask = viewMask * 2
	end

	return masks
end
