-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ShowHUDLPGuide.lua
-- Decompiled from: 00435_ShowHUDLPGuide.lua_6c4c1932a1ce.luajit

C_GuideBT_ShowHUDLPGuide = DefClass("C_GuideBT_ShowHUDLPGuide", C_GuideBT_ShowHUDLPGuide, C_GuideBT_ActionBase)
local M = C_GuideBT_ShowHUDLPGuide
local BLACKBOARD_KEY_PREFIX = "HUDLPData_"
local FINISH_ANIM = "S_Vx_HUDlongpress_progressbar_Finish"
local OPEN_ANIM = "S_Vx_HUDlongpressGuide_Open"
local DEFAULT_FINISH_ANIM_DURATION = 0.8666667

local GetBlackboardKey = function(guideId)
	return BLACKBOARD_KEY_PREFIX .. guideId
end

local GetPopupData = function(self)
	local guideId = self.guideId or self.guideKey

	if not guideId or guideId ~= "" then
		return nil, 
	end

	local blackboard = self.GetBlackboard(self)
	local data = blackboard[GetBlackboardKey(guideId)]

	return guideId, data
end

local GetPopupStore = function(component)
	if not component or gCS.LuaUtils.IsNull(component) then
		return nil
	end

	local storeGroup = gStoreManager:GetStoreGroup("HUDlongpressStore")

	if not storeGroup then
		return nil
	end

	return storeGroup.GetStoreByWidget(storeGroup, component)
end

M.OnCreate = function(self)
	self._nextState = nil
	self._finishTimer = nil
	self._isFinishAnimStarted = false
end

M.OnTick = function(self)
	if self._nextState then
		return self._nextState
	end

	local guideId, data = GetPopupData(self)

	if data and data.isFinish and not self._isFinishAnimStarted then
		self._TryStartFinishAnim(self, guideId, data)
	end

	return gGuideNodeState.Running
end

M.OnActiveDeviceChange = function(self)
end

M.OnEnterRunning = function(self)
	M.base.OnEnterRunning(self)

	local guideId = self.guideId or self.guideKey

	if not guideId or guideId ~= "" then
		print_error("[GuideBT] ShowHUDLPGuide 没有配置 guideId")

		return
	end

	local pressTime = self.pressTime or 0
	local blackboardKey = GetBlackboardKey(guideId)
	self._nextState = nil

	self:_StopFinishAnimWait()

	self._isFinishAnimStarted = false
	local blackboard = self:GetBlackboard()
	blackboard[blackboardKey] = {
		["\\xa2\\xa2#\\xa2d7\\xed;"] = false,
		pressTime = pressTime
	}
	local offsetX = self.offset and self.offset.x or 0
	local offsetY = self.offset and self.offset.y or 0

	SGUI.GuideMgr.RegisterPopup(guideId, self.popupUrl, Vector2.New(offsetX, offsetY), function (callbackGuideId, component)
		local data = blackboard[blackboardKey]

		if not data then
			return
		end

		data.popupComp = component

		self:_ResetPopupAnimToOpenEnd(component)

		if not data.isFinish then
			gNewGuideMgr:UpdateHUDLPPopupUI(callbackGuideId, component, 0, pressTime)
		end
	end)
end

M.OnExitRunning = function(self)
	M.base.OnExitRunning(self)
	self:_StopFinishAnimWait()

	self._isFinishAnimStarted = false
	self._nextState = nil
	local guideId = self.guideId or self.guideKey

	if guideId and guideId == "" then
		SGUI.GuideMgr.UnregisterPopup(guideId)

		local blackboard = self.GetBlackboard(self)
		blackboard[GetBlackboardKey(guideId)] = nil
	end
end

M._StopFinishAnimWait = function(self)
	if self._finishTimer then
		self._finishTimer:Stop()

		self._finishTimer = nil
	end
end

M._ResetPopupAnimToOpenEnd = function(self, component)
	local store = GetPopupStore(component)

	if not store or not store.anim or gCS.LuaUtils.IsNull(store.anim) then
		return
	end

	local clip = store.anim:GetClip(OPEN_ANIM)

	if not clip then
		return
	end

	clip:SampleAnimation(store.anim.gameObject, clip.length)
	store.anim:Play(OPEN_ANIM)
end

M._TryStartFinishAnim = function(self, guideId, data)
	local component = data.popupComp
	local store = GetPopupStore(component)

	if not store or not store.anim or gCS.LuaUtils.IsNull(store.anim) then
		return
	end

	self._isFinishAnimStarted = true

	gNewGuideMgr:UpdateHUDLPPopupUI(guideId, component, 1, data.pressTime or 0)
	store.anim:Play(FINISH_ANIM)

	local duration = DEFAULT_FINISH_ANIM_DURATION
	local clip = store.anim:GetClip(FINISH_ANIM)

	if clip then
		duration = clip.length
	end

	if duration < 0 then
		self._nextState = gGuideNodeState.Success

		return
	end

	self._finishTimer = Timer.New(function ()
		self._finishTimer = nil
		self._nextState = gGuideNodeState.Success
	end, duration):Start()
end
