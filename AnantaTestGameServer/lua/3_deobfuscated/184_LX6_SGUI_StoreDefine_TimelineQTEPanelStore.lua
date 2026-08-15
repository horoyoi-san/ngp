local InputSGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
C_TimelineQTEPanelStore = DefClass("C_TimelineQTEPanelStore", C_TimelineQTEPanelStore, C_StoreGroup)
GroupName2Class.TimelineQTEPanelStore = C_TimelineQTEPanelStore
local M = C_TimelineQTEPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	if not self.EventHandler then
		self.EventHandler = {
			[gEventConstants.CHASING_CAR_TIMELINE_PANEL] = function (eventId, param)
				if param == -1 then
					self:Success()
				elseif param == -2 then
					self:Fail()
				end
			end
		}
	end
end

function M:OnShow(panelId, data)
	self.bindData.panelShow = false

	if not data then
		return
	end

	local qteData = data:ToTable()
	local qteType = qteData.qteType

	if qteType == 2 then
		local qteDuration = qteData.qteDuration
		local pcKey = qteData.pcKey
		local controllerKey = qteData.controllerKey
		local type2_buttonOffset = qteData.type2_buttonOffset

		self:StartQTE(qteType, qteDuration, type2_buttonOffset, pcKey, controllerKey)
	end
end

function M:StartQTE(qteType, qteDuration, qteOffset, qteKey, controllerKey)
	self.bindData.panelShow = true

	if qteType == 2 then
		self.bindData.buttonPosition = Vector3.New(qteOffset.x, qteOffset.y, 0)
		local cfg = InputSGUIPCKeyConfig.GetConfig(qteKey)

		if cfg and #cfg.ButtonIcon > 0 then
			self.bindData.showText = 1
			self.bindData.buttonImage = cfg.ButtonIcon[1]
		else
			self.bindData.showText = 0
			self.bindData.buttonText = cfg.ButtonName
		end

		self.bindData.ControllerImg:ChangeDeviceGamePadAction("GamePad", controllerKey, 2)

		self.bindData.mobileBtn = self:CreateAction("OnKeyPressed")

		gCS.LuaUtils.StopCurrentAnimation(self.bindData.ClickAnim)
		gCS.LuaUtils.SampleTargetAnimation(self.bindData.ClickAnim, "S_Vx_TimelineQTEPanel_Finish", 0)
		gCS.LuaUtils.PlayAnimationByName(self.bindData.ClickAnim, "S_Vx_TimelineQTEPanel_Open")
	end
end

function M:Success()
	gCS.LuaUtils.StopCurrentAnimation(self.bindData.ClickAnim)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.ClickAnim, "S_Vx_TimelineQTEPanel_Finish")
end

function M:Fail()
	gCS.LuaUtils.StopCurrentAnimation(self.bindData.ClickAnim)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.ClickAnim, "S_Vx_TimelineQTEPanel_Fail")
end

function M:OnKeyPressed()
	gMessageManager:SendMessage(gEventConstants.CHASING_CAR_PANEL_TIMELINE, true)
end

function M:BindListener()
	if not self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end

		self.IsBindListener = true
	end
end

function M:UnbindListener()
	if self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:RemoveMessageListener(i, v)
		end

		self.IsBindListener = false
	end
end

function M:OnEnable()
	self:BindListener()
end

function M:OnDisable()
	self:UnbindListener()
end

function M:OnUpdate()
	return
end

function M:OnClose()
	return
end
