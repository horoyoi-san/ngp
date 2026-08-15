local ConsumableConfig = LTConfig.ConsumableConfig
local ImageAvatar = LTConfig.ImageAvatarConfig
local M = {
	ITEM_NUM_CTRL = {
		UP = 3,
		DOWN = 2,
		CONSUME = 1
	},
	GetItemRenderData = function (self, item)
		if item.BindItemKeyValuePair and item.BindItemKeyValuePair.templateId then
			local templateId = item.BindItemKeyValuePair.templateId
			local cfg = ConsumableConfig.GetConfig(templateId)

			if not cfg then
				return nil
			end

			local ret = {
				showDeleteBtn = false,
				itemNum = "",
				IsBtnGray = false,
				isFirstKill = false,
				IsHaved = false,
				isLack = false,
				validTime = "",
				isSelected = false,
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
	end
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:GetRedDotKeyAndIndex(redKey)
	local index = string.find(redKey, ":")

	if index then
		return string.sub(redKey, 1, index - 1), tonumber(string.sub(redKey, index + 1))
	end

	return redKey, nil
end

function M:GetHeadIcon(avatarId)
	local cfg = ImageAvatar.GetConfig(avatarId)

	return cfg and cfg.SguiImageId or 0
end

gStoreStaticMethod = M
