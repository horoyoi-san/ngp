-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatBrowserPanelStore.lua
-- Decompiled from: 01929_ChatBrowserPanelStore.lua_748299919a59.luajit

C_ChatBrowserPanelStore = DefClass("C_ChatBrowserPanelStore", C_ChatBrowserPanelStore, C_AppFragmentStore)
GroupName2Class.ChatBrowserPanelStore = C_ChatBrowserPanelStore
local M = C_ChatBrowserPanelStore

M.ctor = function(self)
	self.PageType = {
		["\\x83\\xbe\\xaeZ?\\xf96"] = 0,
		["`Sɳ\\x81\\x88\\xce\\xed"] = 1
	}
	self.InfoType = {
		["N'eO"] = 2,
		["d\\xa3\\xa3\\xa8\\xb3"] = 1
	}
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
end

M.OnShow = function(self, _, data)
	self.data = data
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(data.chatID)
	self.cfg = LTConfig.NPCChatWebPageConfig.GetConfig(chatCfg.WebPageID)

	if self.cfg ~= nil then
		print_error("短信" .. data.chatID .. "链接对应的网页配置" .. chatCfg.WebPageID .. "未找到，请策划检查一下配表。 NPCChatConfig=" .. tostring(chatCfg.Id))
		self.activity:CloseCurrentFragment()

		return
	end

	self.InitUI(self)
end

M.InitUI = function(self)
	local cfg = self.cfg
	self.bindData.title = cfg.HeadTitle

	if self.data.pageType ~= self.PageType.HomePage then
		self.RefreshCustomContent(self, cfg.Order, cfg.SImages, cfg.Texts)
	elseif self.data.pageType ~= self.PageType.SignedPage then
		self.RefreshCustomContent(self, cfg.SignedPageOrder, cfg.SignedPageSImages, cfg.SignedPageTexts)
	end

	self.lastCloseType, self.lastCustomCloseFunc = gChatUtils.GetCurrentCloseType()

	gChatUtils.SetCloseType(gChatConst.CloseButtonType.Return, function (_)
		self.activity:CloseCurrentFragment()

		return true
	end)
end

M.OnClose = function(self)
	gChatUtils.SetCloseType(self.lastCloseType, self.lastCustomCloseFunc)
end

M.RefreshCustomContent = function(self, order, images, texts)
	self.items = {}
	local curImageIndex = 1
	local curTextIndex = 1

	for _, type in ipairs(order) do
		local itemData = {
			tIndex = type
		}

		if type ~= self.InfoType.Image then
			if curImageIndex < #images then
				itemData.image = images[curImageIndex]
				curImageIndex = curImageIndex + 1
			end
		elseif type ~= self.InfoType.Text and curTextIndex < #texts then
			itemData.content = texts[curTextIndex]
			curTextIndex = curTextIndex + 1
		end

		table.insert(self.items, itemData)
	end

	self.bindData.list:SetSimpleList(#self.items)
end

M.OnRenderItem = function(self, btn, index)
	local itemData = self.items[index + 1]
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn)

	if itemData.tIndex ~= self.InfoType.Image then
		store.image = itemData.image
	elseif itemData.tIndex ~= self.InfoType.Text then
		store.content = itemData.content
	end
end
