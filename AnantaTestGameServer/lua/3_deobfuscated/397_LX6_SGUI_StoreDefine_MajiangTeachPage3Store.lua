C_MajiangTeachPage3Store = DefClass("C_MajiangTeachPage3Store", C_MajiangTeachPage3Store, C_StoreGroup)
GroupName2Class.MajiangTeachPage3Store = C_MajiangTeachPage3Store
local M = C_MajiangTeachPage3Store

function M:GetParent()
	return gStoreManager:GetStoreGroup("MajiangTeachPanelStore")
end

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.contentList.luaSimpleRenderItem = self:CreateAction(self.OnRenderTechTemplate)
	self.bindData.contentList.onGetTIndex = self:CreateAction(self.OnGetTIndex)
end

function M:OnEnable()
	return
end

function M:OnStart()
	local currentIndex = self:GetParent().bindData.tabIndex
	local pageList = self:GetParent():GetPageList()[currentIndex]
	local subTabList = {}

	for i = 1, #pageList do
		table.insert(subTabList, self:GetParent():GetTechTemplate(pageList[i]))
	end

	self.contentListData = subTabList

	self.bindData.contentList:SetSimpleList(#subTabList)
end

function M:OnRenderTechTemplate(btn, index)
	local data = self.contentListData[index + 1]

	self:GetParent():RenderTechTemplate(btn, index, data)
end

function M:OnGetTIndex(index)
	return self.contentListData[index + 1].tIndex
end
