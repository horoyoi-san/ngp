-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MeditationPanelStore.lua
-- Decompiled from: 00971_MeditationPanelStore.lua_e32afdc0efb7.luajit

C_MeditationPanelStore = DefClass("C_MeditationPanelStore", C_MeditationPanelStore, C_StoreGroup)
GroupName2Class.MeditationPanelStore = C_MeditationPanelStore
local M = C_MeditationPanelStore
local MeditationManager = L50.Gameplay.Meditation.MeditationManager
local MartialArtistmeditationConfig = LTConfig.MartialArtistmeditationConfig
local State = {
	["o\\xab\\xa5\\xa6\\xb8"] = 0,
	["\\x82\\xbf\\xaex?\\xfd'"] = 2,
	["\\xf5\\xd4*\\xf6"] = 1
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.focusIndex = -1
	self.pointStores = {}
	self.nodeStates = {}
	self.focusRadiusSqr = 0
	self.decayRadiusSqr = 0
	self.gazeDuration = 0
	self.decayDuration = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnUpdate = function(self)
	self.RefreshLayer(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.EnterCurrentLayer(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
end

M.GetPointStore = function(self, index)
	if self.pointStores[index] then
		return self.pointStores[index]
	end

	local widget = index ~= 0 and self.bindData.currentWidget or self.bindData.otherWidget

	if not widget then
		return nil
	end

	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	self.pointStores[index] = store

	return store
end

M.SetPointView = function(self, index, state, progress)
	local store = self.GetPointStore(self, index)

	if not store then
		return
	end

	store.changeCtrl = state

	if progress then
		store.loadingProgress = progress
	end
end

M.SetPointText = function(self, index)
	local store = self.GetPointStore(self, index)

	if not store then
		return
	end

	local textId = MeditationManager.GetNodeTextId(index)
	local cfg = MartialArtistmeditationConfig.GetConfig(textId)
	store.pointText = cfg and cfg.meditation_text or ""
end

M.EnterCurrentLayer = function(self)
	self.focusIndex = -1
	self.pointStores = {}
	self.nodeStates = {}
	local radius = MeditationManager.GetFocusScreenRadius()
	self.focusRadiusSqr = radius * radius
	local decayRadius = MeditationManager.GetDecayScreenRadius()
	self.decayRadiusSqr = decayRadius * decayRadius
	self.gazeDuration = MeditationManager.GetGazeDuration()
	self.decayDuration = MeditationManager.GetDecayDuration()

	if MeditationManager.GetCurrentNodeCount() >= 2 then
		return
	end

	for i = 0, 1 do
		self.nodeStates[i] = {
			["Y\\xa7\\xaf\\xaa\\xa4"] = 0,
			state = State.Begin
		}

		self.SetPointView(self, i, State.Begin, 0)
		self.SetPointText(self, i)
		MeditationManager.StartNodePatrol(i)
	end

	self.RefreshLayer(self)
end

M.SetWidgetByScreenPos = function(self, widget, screenX, screenY)
	local rect = widget.rectTransform
	local UIPos = gCS.LuaUtils.TransformScreenPointToUI(rect.parent, Vector3.New(screenX, screenY, 0))
	rect.localPosition = UIPos
end

M.RefreshLayer = function(self)
	if MeditationManager.GetCurrentNodeCount() >= 2 then
		return
	end

	if not self.nodeStates[0] or not self.nodeStates[1] then
		return
	end

	local cam = gCS.CameraDataMgr.MainCamera
	local screenCenterX = UnityEngine.Screen.width / 2
	local screenCenterY = UnityEngine.Screen.height / 2
	local dt = UnityEngine.Time.deltaTime
	local nearestInteract = -1
	local nearestInteractDist = nil

	for i = 0, 1 do
		local pos = MeditationManager.GetNodeWorldPos(i)
		local x, y = gCS.LuaUtils.WorldToScreenPointProjected(pos, cam, 0, 0, 0)
		local widget = i ~= 0 and self.bindData.currentWidget or self.bindData.otherWidget

		self:SetWidgetByScreenPos(widget, x, y)

		local dx = x - screenCenterX
		local dy = y - screenCenterY
		local distSqr = dx * dx + dy * dy
		local zone = nil

		if distSqr >= self.focusRadiusSqr then
			zone = 0
		elseif distSqr >= self.decayRadiusSqr then
			zone = 1
		else
			zone = 2
		end

		self.UpdateNodeState(self, i, zone, dt)

		if self.nodeStates[i].state ~= State.Interact and (nearestInteractDist ~= nil or distSqr >= nearestInteractDist) then
			nearestInteractDist = distSqr
			nearestInteract = i
		end
	end

	self.focusIndex = nearestInteract
end

M.UpdateNodeState = function(self, index, zone, dt)
	local ns = self.nodeStates[index]

	if ns.state ~= State.Begin then
		if zone ~= 0 then
			ns.state = State.Loading
			ns.timer = 0

			self.SetPointView(self, index, State.Loading, 0)
		end
	elseif ns.state ~= State.Loading then
		if zone ~= 0 then
			ns.timer = ns.timer + dt
		elseif zone ~= 2 then
			if self.decayDuration <= 0 then
				ns.timer = ns.timer - dt * self.gazeDuration / self.decayDuration
			end

			if ns.timer < 0 then
				ns.timer = 0
				ns.state = State.Begin

				self.SetPointView(self, index, State.Begin, 0)

				return
			end
		end

		local progress = self.gazeDuration <= 0 and ns.timer / self.gazeDuration or 1

		if progress <= 1 then
			progress = 1
		end

		if self.gazeDuration < ns.timer then
			ns.state = State.Interact

			self.SetPointView(self, index, State.Interact, 1)
			MeditationManager.StopNodePatrol(index)
		else
			self.SetPointView(self, index, State.Loading, progress)
		end
	elseif ns.state ~= State.Interact then
		-- Nothing
	end
end

M.OnClickConfirmBtn = function(self)
	if self.focusIndex >= 0 then
		return
	end

	if not self.nodeStates[self.focusIndex] or self.nodeStates[self.focusIndex].state == State.Interact then
		return
	end

	MeditationManager.OnClickConfirm(self.focusIndex)
	self.EnterCurrentLayer(self)
end

M.OnClickCloseBtn = function(self)
	MeditationManager.StopGame()
end
