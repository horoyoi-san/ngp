C_RobberyBoardTimeLineStore = DefClass("C_RobberyBoardTimeLineStore", C_RobberyBoardTimeLineStore, C_StoreGroup)
GroupName2Class.RobberyBoardTimeLineStore = C_RobberyBoardTimeLineStore
local M = C_RobberyBoardTimeLineStore

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
	self:RegisterMessageEvents(self.msgEvents)
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

function M:OnShow(panelId, args)
	local uiPivot = args and args.uiPivot

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
	self.msgEvents = {
		[gEventConstants.ON_ROBBERY_TIMELINE_STATE_CHANGE] = self:CreateAction("OnStateChange")
	}
end

function M:OnStateChange(_, stateName)
	if type(stateName) == "userdata" then
		local stateNameList = stateName:ToTable()
		stateName = stateNameList and stateNameList[1]
	end

	if stateName == "Whiteboard_A" then
		self.bindData.part2Animation.gameObject:SetActive(true)
		gCS.LuaUtils.PlayAnimationByName(self.bindData.part2Animation, "S_Vx_RobberyBoardTimeLine_Part2")
	elseif stateName == "Whiteboard_B" then
		self.bindData.part3Animation.gameObject:SetActive(true)
		gCS.LuaUtils.PlayAnimationByName(self.bindData.part3Animation, "S_Vx_RobberyBoardTimeLine_Part3")
	elseif stateName == "Whiteboard_C" then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.part1Animation, "S_Vx_RobberyBoardTimeLine_ai")
	end
end

function M:RegisterWidget()
	return
end

function M:OnDestroy()
	self:ClearMessageEvents()
end
