C_RobberyBoardTemplate4Store = DefClass("C_RobberyBoardTemplate4Store", C_RobberyBoardTemplate4Store, C_StoreGroup)
GroupName2Class.RobberyBoardTemplate4Store = C_RobberyBoardTemplate4Store
local M = C_RobberyBoardTemplate4Store

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
	self.bindData.leftButton.luaClick = self:CreateAction("OnClickLeftButton")
	self.bindData.rightButton.luaClick = self:CreateAction("OnClickRightButton")
end

function M:OnClickLeftButton()
	return
end

function M:OnClickRightButton()
	return
end
