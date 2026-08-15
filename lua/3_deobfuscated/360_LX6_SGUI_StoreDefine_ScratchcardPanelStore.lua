C_ScratchcardPanelStore = DefClass("C_ScratchcardPanelStore", C_ScratchcardPanelStore, C_StoreGroup)
GroupName2Class.ScratchcardPanelStore = C_ScratchcardPanelStore
local M = C_ScratchcardPanelStore

function M:OnAwake()
	self.bindData.controllerMoveRespond.luaGamePadInputChanged = self:CreateAction("OnControllerMove")
	SGUI.UNavigationMgrEx.Inst.luaGamePadTouchChanged = self:CreateAction("luaGamePadTouchChanged")
	self.offset = Vector2.New(0, 0)
end

function M:OnShow(_, args)
	self.gameplayId = args.gamePlayId
	self.store = nil
	self.offset = nil

	gGFManager:ActiveGuide(13000200, 1)
end

function M:OnControllerMove(context)
	self.currentPosition = context:ReadValueVector2()

	print_debug("OnControllerMove", self.currentPosition)
end

function M:luaGamePadTouchChanged(data)
	self.isGamePadTouchTrigger = true

	if not self.isGamePadTouchRunning then
		self.isGamePadTouchRunning = true

		self:PlaySound()
	end

	local screenHeight = UnityEngine.Screen.height
	local screenPos = Vector2.New(data.touch0.x, screenHeight - data.touch0.y)
	self.lastTouchPosition = screenPos

	self:DrawAt(screenPos)
end

function M:OnUpdate()
	if self.isGamePadTouchRunning and not self.isGamePadTouchTrigger then
		self.isGamePadTouchRunning = false

		self:StopSound()
	end

	self.isGamePadTouchTrigger = false

	if self.lastTouchPosition then
		self.offset = Vector2.New(self.lastTouchPosition.x, self.lastTouchPosition.y)
		self.lastTouchPosition = nil
	elseif not self.currentPosition or self.currentPosition.x == 0 and self.currentPosition.y == 0 then
		self.isScratch = false

		self:StopSound()

		return
	else
		if not self.isScratch then
			self:PlaySound()

			self.isScratch = true
		end

		self.offset = self.offset or Vector2.New(0, 0)
		self.offset = self.offset + self.currentPosition * LTConfig.PoiGameConfig.ScratchJoystickSpeed
	end

	self.offset.x = math.max(0, math.min(UnityEngine.Screen.width, self.offset.x))
	self.offset.y = math.max(0, math.min(UnityEngine.Screen.height, self.offset.y))
	local screenPos = Vector2.New(self.offset.x, self.offset.y)

	print_debug(screenPos)

	self.lastPosition = screenPos

	self:DrawAt(screenPos)
end

function M:PlaySound()
	return
end

function M:StopSound()
	return
end

function M:DrawAt(screenPos)
	local pos = Vector2.New(screenPos.x, screenPos.y)

	gMessageManager:SendMessage(gEventConstants.ON_SCRATCH_CARD_GAMEPAD_DRAW_AT, {
		screenPos = pos
	})
end

function M:OnExitClick()
	return
end

function M:OnClose()
	self:StopSound()
end

function M:OnDestroy()
	self:ClearMessageEvents()
end
