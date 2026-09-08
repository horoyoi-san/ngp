-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ItemInfoOnlyTextPanelStore.lua
-- Decompiled from: 01765_ItemInfoOnlyTextPanelStore.lua_1c4ab6527dec.luajit

local MessageExplainConfig = LTConfig.MessageExplainConfig
C_ItemInfoOnlyTextPanelStore = DefClass("C_ItemInfoOnlyTextPanelStore", C_ItemInfoOnlyTextPanelStore, C_StoreGroup)
GroupName2Class.ItemInfoOnlyTextPanelStore = C_ItemInfoOnlyTextPanelStore
local M = C_ItemInfoOnlyTextPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
	self.bindData.backGroundBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnShow = function(self, panelId, data)
	if not data then
		self.OnBackBtnClick(self)
		print_error("ItemInfoOnlyTextPanelStore:OnShow data is nil")

		return
	end

	self.bindData.titleLabel = data.title
	self.closeCallback = data.closeCallback

	self.bindData.contentList:InitSimpleList()

	if data.id then
		local cfg = MessageExplainConfig.GetConfig(data.id)

		if not cfg then
			self.OnBackBtnClick(self)
			print_error("ItemInfoOnlyTextPanelStore:OnShow config not found for id: " .. tostring(data.id))

			return
		end

		self.bindData.titleLabel = cfg.Title
		local showList = gUIUtils:parseTitlesAndContents(cfg.Content)

		if table.isNilOrEmpty(showList) then
			self.bindData.contentList:AddSimpleLabel(1, cfg.Content)
		else
			for i = 1, #showList do
				if not string.is_null_or_empty(showList[i].title) then
					self.bindData.contentList:AddSimpleLabel(0, showList[i].title)
				end

				if not string.is_null_or_empty(showList[i].content) then
					self.bindData.contentList:AddSimpleLabel(1, showList[i].content)
				end
			end
		end
	elseif data.content then
		for i = 1, #data.content do
			if not string.is_null_or_empty(data.content[i].title) then
				self.bindData.contentList:AddSimpleLabel(0, data.content[i].title)
			end

			if not string.is_null_or_empty(data.content[i].desc) then
				self.bindData.contentList:AddSimpleLabel(1, data.content[i].desc)
			end
		end
	end

	self.bindData.contentList:RefreshList()
end

M.OnClose = function(self)
	if self.closeCallback then
		self.closeCallback()

		self.closeCallback = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end
