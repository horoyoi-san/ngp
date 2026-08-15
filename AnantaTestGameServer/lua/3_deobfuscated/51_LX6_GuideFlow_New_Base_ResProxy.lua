C_GuideBT_ResProxy = {}
local M = C_GuideBT_ResProxy
local mt = {
	__index = M
}

function M.NewProxy()
	local proxy = setmetatable({}, mt)

	return proxy
end

function M:Eval()
	if self.immutable then
		return self.val
	end

	self.res:Eval()

	return self.val
end

function M:SetImmutable(val)
	self.immutable = true
	self.val = val
end

function M:SetValue(val)
	self.val = val
end
