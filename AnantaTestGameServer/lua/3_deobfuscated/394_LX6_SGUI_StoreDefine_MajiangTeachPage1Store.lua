C_MajiangTeachPage1Store = DefClass("C_MajiangTeachPage1Store", C_MajiangTeachPage1Store, C_StoreGroup)
GroupName2Class.MajiangTeachPage1Store = C_MajiangTeachPage1Store
local M = C_MajiangTeachPage1Store

function M:GetParent()
	return gStoreManager:GetStoreGroup("MajiangTeachPanelStore")
end

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.nextBtn.luaClick = self:CreateActionWithArgs("OnStep", 1)
	self.bindData.prevBtn.luaClick = self:CreateActionWithArgs("OnStep", -1)
	self.bindData.dotList.luaSimpleClick = self:CreateAction(self.OnDotClick)
	self.currentIndex = 1
end

function M:OnEnable()
	return
end

function M:OnStart()
	local currentIndex = self:GetParent().bindData.tabIndex
	self.pageList = self:GetParent():GetPageList()[currentIndex]
	local dotList = {}

	for i = 1, #self.pageList do
		table.insert(dotList, {
			id = i,
			selected = i == self.currentIndex
		})
	end

	self.dotListData = dotList

	self.bindData.dotList:SetSimpleList(#dotList)
	self.bindData.dotList:SelectItem(self.currentIndex - 1)
	self:RefreshPage()
end

function M:OnDotClick(btn, csIndex)
	local data = self.dotListData[csIndex + 1]
	self.currentIndex = data.id

	self:RefreshPage()
end

function M:OnClose()
	return
end

function M:RefreshPage()
	local data = self:GetParent():GetTechTemplate(self.pageList[self.currentIndex])

	self.bindData.dotList:SelectItem(self.currentIndex - 1)
	self:GetParent():RenderTechTemplate(self.bindData.content, 0, data)

	self.bindData.prevBtn.interactable = self.currentIndex > 1
	self.bindData.nextBtn.interactable = self.currentIndex <= #self.pageList - 1
end

function M:OnStep(step)
	local nextId = self.currentIndex + step

	if nextId <= 0 or nextId > #self.pageList then
		return
	end

	self.currentIndex = nextId

	self:RefreshPage()
end
