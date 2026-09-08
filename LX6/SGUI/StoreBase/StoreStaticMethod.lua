-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreBase\StoreStaticMethod.lua
-- Decompiled from: 00773_StoreStaticMethod.lua_e5d2867ffd24.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ImageAvatar = LTConfig.ImageNewAvatarConfig
local M = {
	ITEM_NUM_CTRL = {
		["59"] = 3,
		["^\rJu"] = 2,
		["\\xfa\\xf4:.+\t\\xd4"] = 1
	},
	GetItemRenderData = function (self, item)
		if item.BindItemKeyValuePair and item.BindItemKeyValuePair.templateId then
			local templateId = item.BindItemKeyValuePair.templateId
			local cfg = ConsumableConfig.GetConfig(templateId)

			if not cfg then
				return nil
			end

			local ret = {
				["\\xebP;.\\xd5\\xb3U\\xa4t\\xa4\\xb8"] = false,
				["\\xd0\\xcf01\\xfc"] = "",
				["jTN}@9!"] = false,
				["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
				["\\xf0\\xc8<!\\xf5"] = false,
				["[\\xbd\\x8f\\x80J"] = false,
				["UF``J*="] = "",
				["ZI\\xfd\\xb8\\x88\r\\xbb\\xcc\\xec"] = false,
				templateId = templateId,
				iconId = cfg.SItemIconId or 0,
				Quality = cfg.Quality,
				Name = cfg.Name
			}

			for k, v in pairs(item.BindItemKeyValuePair) do
				ret[k] = v
			end

			return ret
		end

		return nil
	end,
	GetRedDotKeyAndIndex = function (self, redKey)
		local index = string.find(redKey, ":")

		if index then
			return string.sub(redKey, 1, index - 1), tonumber(string.sub(redKey, index + 1))
		end

		return redKey, nil
	end
}

M.GetHeadIcon = function(self, avatarId)
	local cfg = ImageAvatar.GetConfig(avatarId)

	return cfg and cfg.SguiImageId or 0
end

gStoreStaticMethod = M
