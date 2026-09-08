-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager_Gift.lua
-- Decompiled from: 02208_CommonItemManager_Gift.lua_733faeaecc84.luajit

local GiftTagsConfig = LTConfig.ConsumableTagsConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local M = C_CommonItemManager

M.GetPackGiftList = function(self)
	local ret = {}

	for i = 1, #self.packItems do
		local packItem = self.packItems[i]
		local cfg = ConsumableConfig.GetConfig(packItem.TemplateId)

		if cfg and cfg.SubType ~= LTConfig.ConsumableTypeConfig.NpcGift then
			table.insert(ret, packItem)
		end
	end

	return ret
end

M.GetAllGiftTags = function(self)
	if not table.isNilOrEmpty(self.allTagList) then
		return self.allTagList
	end

	self.allTagList = {}

	for i = 0, GiftTagsConfig.count - 1 do
		local cfg = GiftTagsConfig.LoadAt(i)

		if cfg.IsGiftTag then
			table.insert(self.allTagList, cfg)
		end
	end

	return self.allTagList
end

M.OnRenderToolTipTagList = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup("GiftTagStore"):GetStoreByWidget(btn)

	if store and data then
		if data.isWeaponTag then
			store.tagColor = Color.NewByStr(data.tagColor or "52525280")
			store.tagNameText = data.name or ""

			return
		end

		local cfgId = data.id
		local cfg = GiftTagsConfig.GetConfig(cfgId)
		store.tagColor = Color.NewByStr(cfg.TagColor)
		store.tagNameText = cfg.TagName
		store.alpha = cfg.Alpha or 1
	end
end

M.GetItemTagList = function(self, data)
	if self.CheckIsWeapon(self, data.itemId) then
		return self.GetWeaponTag(self, data.itemId)
	end

	if self.CheckIsDecoartion(self, data.itemId) then
		return self.GetDecoartionTags(self, data.itemId)
	end

	local ret = {}
	local config = ConsumableConfig.GetConfig(data.itemId)

	if not config then
		return ret
	end

	for i = 1, #config.Tags do
		local tag = config.Tags[i]
		local cfg = GiftTagsConfig.GetConfig(tag)

		if cfg.Visible then
			table.insert(ret, {
				id = tag
			})
		end
	end

	return ret
end
