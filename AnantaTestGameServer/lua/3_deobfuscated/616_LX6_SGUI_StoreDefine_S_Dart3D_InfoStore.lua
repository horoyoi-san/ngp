C_S_Dart3D_InfoStore = DefClass("C_S_Dart3D_InfoStore", C_S_Dart3D_InfoStore, C_StoreGroup)
GroupName2Class.S_Dart3D_InfoStore = C_S_Dart3D_InfoStore
local M = C_S_Dart3D_InfoStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.BtnBack.luaClick = self:CreateAction("OnBtnBack")
	self.bindData.BtnNextPage.luaClick = self:CreateAction("OnBtnNextPage")
	self.bindData.BtnLastPage.luaClick = self:CreateAction("OnBtnLastPage")
end

function M:OnEnable()
	return
end

function M:OnStart()
	self.bindData.pageIndex = 0
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	return
end

function M:OnClose()
	return
end

function M:OnBtnBack()
	gDartsGameManager.currentDartsGame:BackPre()
end

function M:OnBtnNextPage()
	if self.bindData.pageIndex == 4 then
		return
	end

	self.bindData.pageIndex = self.bindData.pageIndex + 1
end

function M:OnBtnLastPage()
	if self.bindData.pageIndex == 0 then
		return
	end

	self.bindData.pageIndex = self.bindData.pageIndex - 1
end
