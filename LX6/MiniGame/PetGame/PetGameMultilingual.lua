-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameMultilingual.lua
-- Decompiled from: 02128_PetGameMultilingual.lua_02ba3a3998a0.luajit

local tblanguage_cn = require("LX6/MiniGame/PetGame/data/tblanguage")
C_PetGameMultilingual = DefClass("C_PetGameMultilingual", C_PetGameMultilingual)
local PetGameMultilingual = C_PetGameMultilingual
local languageData = {
	CN = tblanguage_cn
}
local currentLanguage = languageData.CN

PetGameMultilingual.ctor = function(self)
	local currentLanguage = languageData.CN
end

PetGameMultilingual.SetLanguage = function(self, languageCode)
	if languageCode ~= "CN" then
		currentLanguage = languageData.CN
	end
end

PetGameMultilingual.GetText = function(self, key)
	local langTable = currentLanguage[key]

	if langTable then
		return langTable.content
	else
		return "Text Not Found"
	end
end

gPetGameMultilingual = gPetGameMultilingual or C_PetGameMultilingual.new()
