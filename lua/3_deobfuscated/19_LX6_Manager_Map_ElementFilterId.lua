ElementFilterId = ElementFilterId or {}
local M = ElementFilterId
M.__index = M

function M.CreateFilterIdByCfg(cfg, fieldName, baseId)
	local obj = setmetatable({
		cfg = cfg,
		fieldName = fieldName,
		baseId = baseId
	}, M)

	return obj
end

function M:GetFilterId()
	return self.cfg and self.cfg[self.fieldName] + self.baseId or nil
end
