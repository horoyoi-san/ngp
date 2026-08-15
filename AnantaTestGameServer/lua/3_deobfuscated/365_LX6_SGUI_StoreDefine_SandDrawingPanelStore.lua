C_SandDrawingPanelStore = DefClass("C_SandDrawingPanelStore", C_SandDrawingPanelStore, C_StoreGroup)
GroupName2Class.SandDrawingPanelStore = C_SandDrawingPanelStore
local M = C_SandDrawingPanelStore
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local UCursorInput = SGUI.UCursorInput

function M:Ctor()
	self.msgEvents = {}
end

function M:OnAwake()
	self.bindData.resetButton.luaClick = self:CreateAction("ResetDraw")
	self.bindData.slider.luaValueChanged = self:CreateAction("OnSliderValueChange")
	self.bindData.slider.luaPress = self:CreateAction("OnHover")
	self.bindData.slider.luaRelease = self:CreateAction("OnUnHover")
	self.bindData.pressBtn.luaPress = self:CreateAction("OnBtnPress")
	self.bindData.pressBtn.luaRelease = self:CreateAction("OnBtnRelease")
	self.bindData.UpBtn.luaPress = self:CreateActionWithArgs("OnBrushSizePress", {
		isEndPress = false,
		dir = 1
	})
	self.bindData.DownBtn.luaPress = self:CreateActionWithArgs("OnBrushSizePress", {
		isEndPress = false,
		dir = -1
	})
	self.bindData.UpBtn.luaRelease = self:CreateActionWithArgs("OnBrushSizePress", {
		isEndPress = true
	})
	self.bindData.DownBtn.luaRelease = self:CreateActionWithArgs("OnBrushSizePress", {
		isEndPress = true
	})
	UCursorInput.onCursorPosChange = self:CreateAction("onCursorPosChange")
	self.sliderMin = 0
	self.sliderMax = 100
	local rect = UCursorInput.Inst.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height
	self.currentCursorPos = Vector2.New(width / 2, height / 2, 0)
	self.padChangeTimeSignal = 0
	self.brushChangeType = 0
	self.brushBtnPressing = false
end

function M:OnHover()
	self.brush.canOpen = false
end

function M:OnUnHover()
	self.brush.canOpen = true
end

function M:OnBtnPress()
	self.brush.padPressDown = true
end

function M:OnBtnRelease()
	self.brush.padPressDown = false
end

function M:onCursorPosChange(position)
	self.currentCursorPos = position
end

function M:OnBrushSizePress(args)
	if not args.isEndPress then
		self.brushBtnPressing = true

		if args.dir > 0 then
			self.brushChangeType = 1
		else
			self.brushChangeType = -1
		end
	else
		self.brushBtnPressing = false
		self.brushChangeType = 0
	end
end

function M:OnUpdate()
	self:UpdatePadBrushSize()

	local pos = nil

	if InputActionBind.activeGameDevice == GameDevice.PlayStation or InputActionBind.activeGameDevice == GameDevice.Xbox then
		pos = self.currentCursorPos

		if pos == nil then
			return
		end

		local rect = UCursorInput.Inst.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
		local width = rect.rect.width
		local height = rect.rect.height
		local worldPos = rect:TransformPoint(Vector3.New(pos.x - width / 2, pos.y - height / 2, 0))
		pos = gCS.LuaUtils.WorldToSGUIScreenPoint(worldPos)
		self.brush.padPosition = pos
	end
end

local INTERVAL = 0.1

function M:UpdatePadBrushSize()
	if not self.brushBtnPressing then
		return
	end

	self.padChangeTimeSignal = self.padChangeTimeSignal + Time.deltaTime

	if self.padChangeTimeSignal < INTERVAL then
		return
	end

	self.padChangeTimeSignal = 0
	self.bindData.slider.value = self.bindData.slider.value + self.brushChangeType * self.bindData.slider.stepSize

	self:OnSliderValueChange(self.bindData.slider.value)
end

function M:OnShow(panelId, data)
	gStoreManager:GetStoreGroup("GameplayHudPanelStore"):RegisterBtnBackCallback(self:CreateAction(self.ClickClose))

	self.brush = data.brush
	self.simulator = data.simulator
	self.simulator.simulateEnabled = true
	self.targetMin = data.targetMin
	self.targetMax = data.targetMax
	self.brush.brushSize = self.targetMin + (self.bindData.slider.value - self.bindData.slider.minValue) * (self.targetMax - self.targetMin) / (self.bindData.slider.maxValue - self.bindData.slider.minValue)
end

function M:OnStart()
	return
end

function M:OnSliderValueChange(data)
	local mappedValue = self.targetMin + (data - self.bindData.slider.minValue) * (self.targetMax - self.targetMin) / (self.bindData.slider.maxValue - self.bindData.slider.minValue)
	local formattedValue = string.format("%0.2f", mappedValue)
	local finalValue = tonumber(formattedValue)
	self.brush.brushSize = finalValue

	print_debug(self.brush.brushSize)
end

function M:ClickClose()
	self.brush.canOpen = false
	self.simulator.simulateEnabled = false

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = "SandDrawEnd"
	})
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, true)
	gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.S_GAMEPLAY_HUD_PANEL)
end

function M:ResetDraw()
	if not gCS.LuaUtils.IsNull(self.simulator) then
		self.simulator:Refresh()
	end
end
