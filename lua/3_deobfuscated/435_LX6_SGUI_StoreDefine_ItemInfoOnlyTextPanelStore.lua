C_ItemInfoOnlyTextPanelStore = DefClass("C_ItemInfoOnlyTextPanelStore", C_ItemInfoOnlyTextPanelStore, C_StoreGroup)
GroupName2Class.ItemInfoOnlyTextPanelStore = C_ItemInfoOnlyTextPanelStore
local M = C_ItemInfoOnlyTextPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction(self.OnRenderDescItem)
	self.bindData.contentList.onGetTIndex = self:CreateAction(self.OnGetTIndex)
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
end

function M:OnRenderDescItem(btn, index)
	local data = self.contentList[index + 1]

	gCommonItemManager:OnRenderDescItem(btn, index, data)
end

function M:OnGetTIndex(index)
	return self.contentList[index + 1].tIndex
end

function M:OnBackBtnClick()
	gPanelManager:Close(self.m_Id)
end

function M:OnShow(panelId, data)
	if not data then
		self:OnBackBtnClick()
		print_error("ItemInfoOnlyTextPanelStore:OnShow data is nil")
	end

	self.bindData.titleLabel = data.title
	self.contentList = {}

	for i = 1, #data.content do
		if not string.is_null_or_empty(data.content[i].title) then
			table.insert(self.contentList, {
				tIndex = 0,
				text = data.content[i].title
			})
		end

		if not string.is_null_or_empty(data.content[i].desc) then
			table.insert(self.contentList, {
				tIndex = 1,
				text = data.content[i].desc
			})
		end
	end

	self.bindData.contentList:SetSimpleList(#self.contentList)
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
