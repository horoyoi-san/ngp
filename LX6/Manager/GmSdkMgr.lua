-- Original chunk: @Lua\LuaFiles\LX6\Manager\GmSdkMgr.lua
-- Decompiled from: 02281_GmSdkMgr.lua_1720f56ca577.luajit

C_GmSdkMgr = DefClass("C_GmSdkMgr", C_GmSdkMgr)
local M = C_GmSdkMgr

M.ctor = function(self)
	self.bIsOpen = false
	self.eventHandlers = {
		[gEventConstants.UNISDK_GM_GENTOKEN] = function ()
			self:OnGenToken()
		end,
		[gEventConstants.UNISDK_GM_WEBCLOSE] = function ()
			self:OnWebClose()
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogin = function(self)
	self.bIsOpen = false
end

M.IsOpen = function(self)
	return self.bIsOpen
end

M.Open = function(self, param)
	local refer = ""

	if param and param.refer and not string.is_null_or_empty(param.refer) then
		refer = param.refer
	end

	UniSDKManager.OpenGMPage(refer)

	self.bIsOpen = true

	print_notice("Open GmPage")
end

M.OnWebClose = function(self)
	self.bIsOpen = false
end

M.OnGenToken = function(self)
	gClientToGameDelegate:GetGMSDKToken().Callback = function (err, token)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if not token or string.is_null_or_empty(token) then
			print_error_without_stack("GMSDK: 服务器返回的Token是空的 RPC:GetGMSDKToken")

			return
		end

		UniSDKManager.SetGMSDKToken(token)
	end
end

gGMSdkMgr = gGMSdkMgr or C_GmSdkMgr.new()
