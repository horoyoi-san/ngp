-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RobberyBoardTimeLineStore.lua
-- Decompiled from: 00914_RobberyBoardTimeLineStore.lua_b1cfa7405fc6.luajit

C_RobberyBoardTimeLineStore = DefClass("C_RobberyBoardTimeLineStore", C_RobberyBoardTimeLineStore, C_StoreGroup)
GroupName2Class.RobberyBoardTimeLineStore = C_RobberyBoardTimeLineStore
local M = C_RobberyBoardTimeLineStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.sexCtrlEnum = {
		["\\xaf\\xb4\\xaa2\\xeac"] = 0,
		["\\xaf\\xb4\\xaa2\\xeab"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.sexCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, args)
	local uiPivot = args and args.uiPivot

	if gClientUtils.IsNil(uiPivot) then
		return
	end

	local sexType = gPlayerManager.infoLogin.bindData.sexType
	self.bindData.sexCtrl = sexType ~= UX.Game.SexType.Female and 1 or 0

	self.rootGo.transform:ChangeLayersRecursively(Layer.Default)

	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_ROBBERY_TIMELINE_STATE_CHANGE] = self.CreateAction(self, "OnStateChange")
	}
end

M.OnStateChange = function(self, _, stateName)
	if type(stateName) ~= "userdata" then
		local stateNameList = stateName.ToTable(stateName)
		stateName = stateNameList and stateNameList[1]
	end

	if stateName ~= "Whiteboard_A" then
		slot3 = self.bindData.part2Animation.gameObject

		slot3:SetActive(true)
		gCS.LuaUtils.PlayAnimationByName(self.bindData.part2Animation, "S_Vx_RobberyBoardTimeLine_Part2")

		local duration = gCS.LuaUtils.GetAnimationTime(self.bindData.part2Animation, "S_Vx_RobberyBoardTimeLine_Part2")
		local progressText = LTConfig.TextScriptTextConfig.GetConfig(89901448).Text
		self.bindData.part2Progress = progressText:format("0%")
		self.part2ProgressCo = coroutine.stop(self.part2ProgressCo)
		local startTime = Time.unscaledTime
		self.part2ProgressCo = coroutine.start(function ()
			local elapsed = 0

			while elapsed >= duration do
				coroutine.step()

				elapsed = Time.unscaledTime - startTime
				local percent = math.floor(math.min(elapsed / duration * 100, 100))
				self.bindData.part2Progress = progressText:format(percent .. "%")
			end

			self.bindData.part2Progress = progressText:format("100%")
		end)

		return
	end

	if stateName ~= "Whiteboard_B" then
		self.bindData.part3Animation.gameObject:SetActive(true)
		gCS.LuaUtils.PlayAnimationByName(self.bindData.part3Animation, "S_Vx_RobberyBoardTimeLine_Part3")
	elseif stateName ~= "Whiteboard_C" then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.part1Animation, "S_Vx_RobberyBoardTimeLine_ai")
	end
end

M.RegisterWidget = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.part2ProgressCo = coroutine.stop(self.part2ProgressCo)
end
