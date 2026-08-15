C_GuideBT_ResourceBase = DefClass("C_GuideBT_ResourceBase", C_GuideBT_ResourceBase, C_GuideBT_NodeBase)
local M = C_GuideBT_ResourceBase

function M:OnCreate()
	return
end

function M:AddOutput(fieldName)
	local outputResProxy = C_GuideBT_ResProxy.NewProxy()
	self[fieldName] = outputResProxy
	outputResProxy.res = self
end

function M:Eval()
	return
end
