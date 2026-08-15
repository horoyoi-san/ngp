C_ChatBrowserPanelStore = DefClass("C_ChatBrowserPanelStore", C_ChatBrowserPanelStore, C_AppFragmentStore)
GroupName2Class.ChatBrowserPanelStore = C_ChatBrowserPanelStore
local M = C_ChatBrowserPanelStore

function M:ctor()
	self.PageType = {
		HomePage = 0,
		SignedPage = 1
	}
	self.InfoType = {
		Text = 2,
		Image = 1
	}
end

function M:OnAwake()
	self.bindData.list.luaRenderItem = self:CreateAction(self.OnRenderItem)
end

function M:OnShow(_, data)
	self.data = data
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(data.chatID)
	self.cfg = LTConfig.NPCChatWebPageConfig.GetConfig(chatCfg.WebPageID)

	if self.cfg == nil then
		print_error("短信" .. data.chatID .. "链接对应的网页配置" .. chatCfg.WebPageID .. "未找到，请策划检查一下配表。 NPCChatConfig=" .. tostring(chatCfg.Id))
		self.activity:CloseCurrentFragment()

		return
	end

	self:InitUI()
end

function M:InitUI()
	local cfg = self.cfg
	self.bindData.title = cfg.HeadTitle

	if self.data.pageType == self.PageType.HomePage then
		self:RefreshCustomContent(cfg.Order, cfg.SImages, cfg.Texts)
	elseif self.data.pageType == self.PageType.SignedPage then
		self:RefreshCustomContent(cfg.SignedPageOrder, cfg.SignedPageSImages, cfg.SignedPageTexts)
	end

	self.lastCloseType, self.lastCustomCloseFunc = gChatUtils.GetCurrentCloseType()

	gChatUtils.SetCloseType(gChatConst.CloseButtonType.Return, function (_)
		self.activity:CloseCurrentFragment()

		return true
	end)
end

function M:OnClose()
	gChatUtils.SetCloseType(self.lastCloseType, self.lastCustomCloseFunc)
end

function M:RefreshCustomContent(order, images, texts)
	local items = {}
	local curImageIndex = 1
	local curTextIndex = 1

	for _, type in ipairs(order) do
		local itemData = {
			tIndex = type
		}

		if type == self.InfoType.Image then
			if curImageIndex <= #images then
				itemData.image = images[curImageIndex]
				curImageIndex = curImageIndex + 1
			end
		elseif type == self.InfoType.Text and curTextIndex <= #texts then
			itemData.content = texts[curTextIndex]
			curTextIndex = curTextIndex + 1
		end

		table.insert(items, itemData)
	end

	self.bindData.list:SetList(items)
end

function M:OnRenderItem(btn, _, itemData)
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn)

	if itemData.tIndex == self.InfoType.Image then
		store.image = itemData.image
	elseif itemData.tIndex == self.InfoType.Text then
		store.content = itemData.content
	end
end
