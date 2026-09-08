-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PhotoCircularSliderStore.lua
-- Decompiled from: 00846_PhotoCircularSliderStore.lua_2cae6ad94e24.luajit

local DragEventListener = SGUI.EventSystems.DragEventListener
C_PhotoCircularSliderStore = DefClass("C_PhotoCircularSliderStore", C_PhotoCircularSliderStore, C_StoreGroup)
GroupName2Class.PhotoCircularSliderStore = C_PhotoCircularSliderStore
local M = C_PhotoCircularSliderStore

M.OnAwake = function(self)
	local dragBtn = DragEventListener.Get(self.bindData.dragBtn.gameObject)
	dragBtn.onBeginDrag = self.CreateAction(self, "OnBtnBeginDrag")
	dragBtn.onDrag = self.CreateAction(self, "OnBtnDragging")
	dragBtn.onEndDrag = self.CreateAction(self, "OnBtnEndDrag")

	self.bindData.dragBtn.luaPress = function()
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	self.bindData.dragBtn.luaRelease = function()
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end
end

M.OnGroupEnable = function(self)
	self.bindData.handleText = "1.0x"
end

M.OnBtnBeginDrag = function(self, eventData)
	self.lastPosition = gUtils:GetTouchPosition()
	self.dragging = true
	self.bindData.pressCtrl = 1
	self.draggingPath = 0
end

local clamp_angle = function(angle)
	angle = angle % 360

	if angle < 335 or angle < 50 then
		return angle
	else
		local get_distance = function(x, target)
			local diff = (target - x) % 360

			return diff <= 180 and 360 - diff or diff
		end

		local d50 = get_distance(angle, 50)
		local d335 = get_distance(angle, 335)

		if d50 >= d335 then
			return 50
		else
			return 335
		end
	end
end

local distance_to_335 = function(angle)
	angle = angle % 360
	local clockwise = (335 - angle) % 360
	local counter = (angle - 335) % 360

	return math.min(clockwise, counter)
end

M.OnBtnDragging = function(self, eventData)
	if not self.dragging then
		return
	end

	local current = eventData.position
	local delta = current.y - self.lastPosition.y
	self.draggingPath = self.draggingPath + math.abs(delta)
	self.lastPosition = current

	if self.draggingPath <= 20 then
		self.DoOneStepRolling(self, delta / math.abs(delta))

		self.draggingPath = 0
	end
end

M.OnBtnEndDrag = function(self, eventData)
	self.dragging = false
	self.bindData.pressCtrl = 0
	self.draggingPath = 0
end

M.DoOneStepRolling = function(self, dir)
	local rotZB = self.bindData.scaleImage.transform.localRotation.eulerAngles.z
	local rotZ = rotZB - dir * 5
	rotZ = clamp_angle(rotZ)
	local rotation = Quaternion.Euler(0, 0, rotZ)
	self.bindData.scaleImage.transform.localRotation = rotation
	self.bindData.scalePressImage.transform.localRotation = rotation
	local times = distance_to_335(rotZ) / 5 * 0.1 + 0.5
	self.bindData.handleText = string.format("%.1fx", times)

	if self.cb and times == self.lastCallbackTimes then
		self.lastCallbackTimes = times

		self.cb(self.owner, times)
	end
end

M.SetRollingCallback = function(self, cb, owner)
	self.cb = cb
	self.owner = owner
end

M.SetActive = function(self, active)
	self.rootGo:SetActive(active)
end

M.SetLocalScale = function(self, x, y, z)
	self.rootGo.transform.localScale = Vector3.New(x, y, z)
end

M.SetToStart = function(self, ignoreSound)
	local rotation = Quaternion.Euler(0, 0, 0)
	self.bindData.scaleImage.transform.localRotation = rotation
	self.bindData.scalePressImage.transform.localRotation = rotation
	local times = 1
	self.bindData.handleText = string.format("%.1fx", times)
	self.lastCallbackTimes = times

	if self.cb then
		self.cb(self.owner, times, ignoreSound)
	end
end

M.SetPressCtrl = function(self, press)
	self.bindData.pressCtrl = press and 1 or 0
end
