C_MajiangTeachPage2Store = DefClass("C_MajiangTeachPage2Store", C_MajiangTeachPage2Store, C_StoreGroup)
GroupName2Class.MajiangTeachPage2Store = C_MajiangTeachPage2Store
local M = C_MajiangTeachPage2Store

function M:GetParent()
	return gStoreManager:GetStoreGroup("MajiangTeachPanelStore")
end

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTechTemplate)
	self.bindData.contentList.onGetTIndex = self:CreateAction(self.OnGetTIndex)
	self.bindData.pageList.luaSelectedChanged = self:CreateAction("OnTabSelectChange")
end

function M:OnTabSelectChange(list)
	self:RefreshPage()
end

function M:OnEnable()
	return
end

function M:OnStart()
	local currentIndex = self:GetParent().bindData.tabIndex
	local pageList = self:GetParent():GetPageList()[currentIndex]
	local subTabList = {}
	local index = 0
	self.pageList = {}

	for k, v in pairs(pageList) do
		table.insert(subTabList, {
			id = index,
			label = k
		})

		local subList = {}

		for i = 1, #v do
			table.insert(subList, self:GetParent():GetTechTemplate(v[i]))
		end

		self.pageList[index] = subList
		index = index + 1
	end

	self.bindData.pageList:SetList(subTabList)
	self.bindData.pageList:SelectItem(0)
	self:RefreshPage()
end

function M:OnClose()
	return
end

function M:RefreshPage()
	local contentList = self.pageList[self.bindData.pageList.selectedIndex]
	self.contentListData = contentList

	self.bindData.contentList:SetSimpleList(#contentList)
	self.bindData.contentList:GoToIndex(0, true)
end

function M:OnRenderTechTemplate(btn, index)
	local data = self.contentListData[index + 1]

	self:GetParent():RenderTechTemplate(btn, index, data)
end

function M:OnGetTIndex(index)
	local data = self.contentListData[index + 1]

	return data.tIndex
end
