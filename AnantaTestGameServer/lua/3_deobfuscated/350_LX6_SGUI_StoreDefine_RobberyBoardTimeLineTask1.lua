C_RobberyBoardTimeLineTask1 = DefClass("C_RobberyBoardTimeLineTask1", C_RobberyBoardTimeLineTask1, C_StoreGroup)
GroupName2Class.RobberyBoardTimeLineTask1 = C_RobberyBoardTimeLineTask1
local M = C_RobberyBoardTimeLineTask1

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
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

function M:OnShow(_, args)
	local uiPivot = args.uiPivot

	if gClientUtils.IsNil(uiPivot) then
		return
	end

	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale
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
	return
end
