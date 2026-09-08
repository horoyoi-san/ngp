-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\UGuideParams.lua
-- Decompiled from: 00502_UGuideParams.lua_de3286fd68c2.luajit

C_GuideBT_UGuideParams = DefClass("C_GuideBT_UGuideParams", C_GuideBT_UGuideParams, C_GuideBT_ResourceBase)
local M = C_GuideBT_UGuideParams
local MODE_NONE = 0
local MODE_MOBILE_VS_NONMOBILE = 1
local MODE_GAMEPAD_VS_NONGAMEPAD = 2
local MODE_MOBILE_KEYMOUSE_GAMEPAD = 3
local MODE_ALL_DEVICES = 4

M.Eval = function(self)
	local mode = self.mode or MODE_NONE
	local device = gCS.LuaUtils.GetActiveDevice()
	local isMobile = device ~= SGUI.GameDevice.UnKnown
	local isPS = device ~= SGUI.GameDevice.PlayStation
	local isXbox = device ~= SGUI.GameDevice.Xbox
	local isGamepad = isPS or isXbox
	local val = nil

	if mode ~= MODE_NONE then
		val = self.keyMouseParams
	elseif mode ~= MODE_MOBILE_VS_NONMOBILE then
		val = isMobile and self.mobileParams or self.keyMouseParams
	elseif mode ~= MODE_GAMEPAD_VS_NONGAMEPAD then
		val = isGamepad and self.xboxParams or self.keyMouseParams
	elseif mode ~= MODE_MOBILE_KEYMOUSE_GAMEPAD then
		if isMobile then
			val = self.mobileParams
		elseif isGamepad then
			val = self.xboxParams
		else
			val = self.keyMouseParams
		end
	elseif mode ~= MODE_ALL_DEVICES then
		if isMobile then
			val = self.mobileParams
		elseif isPS then
			val = self.psParams
		elseif isXbox then
			val = self.xboxParams
		else
			val = self.keyMouseParams
		end
	else
		print_error("[GuideBT] UGuideParams: 未知 mode =", mode)

		val = self.keyMouseParams
	end

	self.output.val = val
end
