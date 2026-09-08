-- Original chunk: @Lua\LuaFiles\LX6\Manager\Akx\AkxManagerBase.lua
-- Decompiled from: 02272_AkxManagerBase.lua_932503c24ef0.luajit

local M = C_AkxManager

M.CreateEmptyAiResponse = function(self)
	return {
		["\\xda\\xd3-\\xf5"] = 0,
		["*9\\xe1}\\x9c\\xc8;\\xae\\xe5\\xfa\\xf3z\\xf0"] = false,
		["t\\x8d#\\xf2i\\xacy$>%/b\\xb1\\xf1+\\xca\\xe2"] = true,
		["\\xb9\\xb4\\xbbe0\\xed6"] = "",
		["H\\xbc\\xb0\\xa0\\xa4"] = false,
		["|~\\xa3`i\\xa4\\xf3K{jI"] = false,
		["PBzG<"] = "",
		["\\xb9\\xb4\\xa2x;\\xfd'"] = false,
		["Z\\x9e\\x83\\xa2H"] = true,
		["NBzO<"] = "",
		["}\\xef\\xff=>#\\xcf^4\\xddB\\x82K\\xc8\\xe1"] = false,
		["G\\x84\\x9c\\x80D"] = ""
	}
end

M.CreateErrorResponse = function(self, err)
	local response = self.CreateEmptyAiResponse(self)
	response.error = true
	response.errorMsg = err

	return response
end

M.CreateRedirectResponse = function(self)
	local response = self.CreateEmptyAiResponse(self)
	response.redirect = true

	return response
end

M.CreateSuggestionContentsFromTextArray = function(self, textArray, sessionid)
	local contents = {}

	for _, text in ipairs(textArray) do
		if text and not string.is_null_or_empty(text) then
			local content = {
				["@Hb}K;<"] = "",
				["ZI\\xf1\\xb6\\x81\\xaf\\xdb\\xec"] = true,
				["\\xd0\\xc8+\n/\\xf8"] = false,
				["[\\xae\\x99\\x86C"] = false,
				text = text,
				data = text,
				sessionid = sessionid
			}

			table.insert(contents, content)
		end
	end

	return contents
end

M.SetDebug = function(self, bEnable)
	self.bDebug = bEnable
end

M.PrintDebug = function(self, ...)
	if self.bDebug then
		print_notice("[AkxManager Debug]", ...)
	end
end

M.PrintCurrentSettings = function(self)
	print_notice("[AkxManager] Current Settings(IF empty or false means not enabled):")
	print_notice("[AkxManager]   GlobalRouterSwitch:", self.bRoutingEnabled)
	print_notice("[AkxManager]   EnableSpiritAigc:", self.bEnableSpiritAigc)
	print_notice("[AkxManager]   EnableEarlySpiritMatch:", self.bEnableEarlySpiritMatch)
	print_notice("[AkxManager]   RoutingMode:", self.routerMode)
	print_notice("[AkxManager]   RoutingTimeout:", self.fuxiTimeout)
	print_notice("[AkxManager]   EnabledDebug:", self.bDebug)
end
