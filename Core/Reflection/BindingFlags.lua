-- Original chunk: @Lua\LuaFiles\Core\Reflection\BindingFlags.lua
-- Decompiled from: 00024_BindingFlags.lua_159329422ade.luajit

if System.Reflection ~= nil then
	System.Reflection = {}
end

local GetMask = function(...)
	local arg = {
		...
	}
	local value = 0

	for i = 1, #arg do
		value = value + arg[i]
	end

	return value
end

local BindingFlags = {
	["\\xfd\\xde(\\xe5"] = 0,
	["\\x98\\xb4\\x8dc;\\xf27"] = 2048,
	["\\x8c\\xb4\\x8dc;\\xf27"] = 1024,
	["\\x82\\xbf\\xbfk0\\xfd6"] = 4,
	["\\xb814j\\x92Q\\xdc%\\xbe\\xa0"] = 4096,
	["5/\\x80\\xfd\\xb9\\xa2\\xfb\\xb5\\x99\\x80\\xdc\\xec5î9\\x8f\\xe7"] = 131072,
	["mHbY[;"] = 32,
	["6/\\x84߮\\xa1̯\\xa9\\x98\\xed\\xf0=֟2\\x8b\\xfb"] = 32768,
	["/\\\\x90\\x9a\\x8aB"] = 8,
	["Fq\\xa2x^\\xb7\\xc0B~olB"] = 16777216,
	["\\xad?\\xf9\\xb5\\&\\xc7W0\\xc9\\xfc\"uU\\xc4%\\xb5\\xc5"] = 262144,
	["A\\x9b\\x84\\xabپ\\xed2\\xac-\\xa0>"] = 64,
	["Jn\\xadtX\\x90\\xfbInspK"] = 65536,
	[",]\\x93\\x82\\x8aB"] = 16,
	["Fx\\xbaxG\\xb7\\xdfB~rqH"] = 256,
	["\\xac14j\\x92Q\\xdc%\\xbe\\xa0"] = 8192,
	["Ks\\xaf{M\\xa0\\xf7CEtrU"] = 2,
	["Ĉ\\xed\\xcf\\xf9\\x9c\\xec\\x8c#-"] = 512,
	["?4\\xc0z\\x8b\\xe7\\xba \\xf6\\xf7\\xf4`\\xe2"] = 16384,
	["z]\\xc0\\xb2\\x96\r\\x9b\\xda\\xed"] = 1
}
System.Reflection.BindingFlags = BindingFlags
System.Reflection.BindingFlags.GetMask = GetMask

return BindingFlags
