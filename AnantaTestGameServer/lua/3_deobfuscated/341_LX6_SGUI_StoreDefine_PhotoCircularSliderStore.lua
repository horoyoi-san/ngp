local DragEventListener = SGUI.EventSystems.DragEventListener
C_PhotoCircularSliderStore = DefClass("C_PhotoCircularSliderStore", C_PhotoCircularSliderStore, C_StoreGroup)
GroupName2Class.PhotoCircularSliderStore = C_PhotoCircularSliderStore
local M = C_PhotoCircularSliderStore

function M:OnAwake()
	local dragBtn = DragEventListener.Get(self.bindData.dragBtn.gameObject)
	dragBtn.onBeginDrag = self:CreateAction("OnBtnBeginDrag")
	dragBtn.onDrag = self:CreateAction("OnBtnDragging")
	dragBtn.onEndDrag = self:CreateAction("OnBtnEndDrag")

	function self.bindData.dragBtn.luaPress()
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	function self.bindData.dragBtn.luaRelease()
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end
end

function M:OnGroupEnable()
	self.bindData.handleText = "1.0x"
end

function M:OnBtnBeginDrag(eventData)
	self.lastPosition = gUtils:GetTouchPosition()
	self.dragging = true
	self.bindData.pressCtrl = 1
	self.draggingPath = 0
end

local function clamp_angle(angle)
	angle = angle % 360

	if angle >= 335 or angle <= 50 then
		return angle
	else
		local function get_distance(x, target)
			local diff = (target - x) % 360

			return diff > 180 and 360 - diff or diff
		end

		local d50 = get_distance(angle, 50)
		local d335 = get_distance(angle, 335)

		if d50 < d335 then
			return 50
		else
			return 335
		end
	end
end

local function distance_to_335(angle)
	angle = angle % 360
	local clockwise = (335 - angle) % 360
	local counter = (angle - 335) % 360

	return math.min(clockwise, counter)
end

function M:OnBtnDragging(eventData)
	if not self.dragging then
		return
	end

	local current = gUtils:GetTouchPosition()
	local delta = current.y - self.lastPosition.y
	self.draggingPath = self.draggingPath + math.abs(delta)
	self.lastPosition = current

	if self.draggingPath > 20 then
		self:DoOneStepRolling(delta / math.abs(delta))

		self.draggingPath = 0
	end
end

function M:OnBtnEndDrag(eventData)
	self.dragging = false
	self.bindData.pressCtrl = 0
	self.draggingPath = 0
end

function M:DoOneStepRolling(dir)
	local rotZB = self.bindData.scaleImage.transform.localRotation.eulerAngles.z
	local rotZ = rotZB - dir * 5
	rotZ = clamp_angle(rotZ)
	local rotation = Quaternion.Euler(0, 0, rotZ)
	self.bindData.scaleImage.transform.localRotation = rotation
	self.bindData.scalePressImage.transform.localRotation = rotation
	local times = distance_to_335(rotZ) / 5 * 0.1 + 0.5
	self.bindData.handleText = string.format("%.1fx", times)

	if self.cb then
		self.cb(self.owner, times)
	end
end

function M:SetRollingCallback(cb, owner)
	self.cb = cb
	self.owner = owner
end

function M:SetActive(active)
	self.rootGo:SetActive(active)
end

function M:SetLocalScale(x, y, z)
	self.rootGo.transform.localScale = Vector3.New(x, y, z)
end

function M:SetToStart(ignoreSound)
	local rotation = Quaternion.Euler(0, 0, 0)
	self.bindData.scaleImage.transform.localRotation = rotation
	self.bindData.scalePressImage.transform.localRotation = rotation
	local times = 1
	self.bindData.handleText = string.format("%.1fx", times)

	if self.cb then
		self.cb(self.owner, times, ignoreSound)
	end
end

function M:SetPressCtrl(press)
	self.bindData.pressCtrl = press and 1 or 0
end
