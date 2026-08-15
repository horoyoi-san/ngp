C_RobberyBoardTemplate2Store = DefClass("C_RobberyBoardTemplate2Store", C_RobberyBoardTemplate2Store, C_StoreGroup)
GroupName2Class.RobberyBoardTemplate2Store = C_RobberyBoardTemplate2Store
local M = C_RobberyBoardTemplate2Store

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
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

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.optionList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderOptionListItem")
	self.bindData.optionList.luaSimpleClick = self:CreateAction("OnSimpleClickOptionList")
end

function M:OnSimpleRenderOptionListItem(btn, index)
	return
end

function M:OnSimpleClickOptionList(btn, index)
	return
end
