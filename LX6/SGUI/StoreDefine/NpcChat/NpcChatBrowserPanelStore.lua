-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatBrowserPanelStore.lua
-- Decompiled from: 01953_NpcChatBrowserPanelStore.lua_5ec57fd847d4.luajit

C_NpcChatBrowserPanelStore = DefClass("C_NpcChatBrowserPanelStore", C_NpcChatBrowserPanelStore, C_NpcChatFragmentStore)
GroupName2Class.NpcChatBrowserPanelStore = C_NpcChatBrowserPanelStore
local M = C_NpcChatBrowserPanelStore

M.ctor = function(self)
	self.PageType = {
		["\\x83\\xbe\\xaeZ?\\xf96"] = 0,
		["`Sɳ\\x81\\x88\\xce\\xed"] = 1
	}
	self.InfoType = {
		["N'eO"] = 2,
		["d\\xa3\\xa3\\xa8\\xb3"] = 1
	}
	self.listData = {}
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
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

	self.lastCloseType, self.lastCustomCloseFunc = gNpcChatUtils.GetCurrentCloseType()

	gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Return, function (_)
		self.activity:CloseCurrentFragment()

		return true
	end)
end

M.OnClose = function(self)
	gNpcChatUtils.SetCloseType(self.lastCloseType, self.lastCustomCloseFunc)
	gNpcChatUtils.ResumeChatAutoClick()
end

M.RefreshCustomContent = function(self, order, images, texts)
	local items = {}
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

		table.insert(items, itemData)
	end

	self.listData = items

	self.bindData.list:SetSimpleList(#items)
end

M.OnRenderItem = function(self, btn, index)
	local itemData = self.listData[index + 1]

	if not itemData then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn)

	if itemData.tIndex ~= self.InfoType.Image then
		store.image = itemData.image
	elseif itemData.tIndex ~= self.InfoType.Text then
		store.content = itemData.content
	end
end

M.OnGetTIndex = function(self, index)
	local itemData = self.listData[index + 1]

	return itemData and itemData.tIndex or 0
end
