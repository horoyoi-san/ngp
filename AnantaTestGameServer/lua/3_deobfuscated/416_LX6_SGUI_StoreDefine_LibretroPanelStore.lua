C_LibretroPanelStore = DefClass("C_LibretroPanelStore", C_LibretroPanelStore, C_StoreGroup)
GroupName2Class.LibretroPanelStore = C_LibretroPanelStore
local M = C_LibretroPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.aResponse.luaGamePadInputChanged = self:CreateAction("OnAResponse")
	self.bindData.bResponse.luaGamePadInputChanged = self:CreateAction("OnBResponse")
	self.bindData.cResponse.luaGamePadInputChanged = self:CreateAction("OnCResponse")
	self.bindData.dResponse.luaGamePadInputChanged = self:CreateAction("OnDResponse")
	self.bindData.insertResponse.luaGamePadInputChanged = self:CreateAction("OnInsertResponse")
	self.bindData.startResponse.luaGamePadInputChanged = self:CreateAction("OnStartResponse")
	self.bindData.moveWRespond.luaGamePadInputChanged = self:CreateAction("OnMoveWResponse")
	self.bindData.moveARespond.luaGamePadInputChanged = self:CreateAction("OnMoveAResponse")
	self.bindData.moveSRespond.luaGamePadInputChanged = self:CreateAction("OnMoveSResponse")
	self.bindData.moveDRespond.luaGamePadInputChanged = self:CreateAction("OnMoveDResponse")
end

function M:UpdateMoveVector()
	self.moveVector2.x = 0

	if self.activeHorizontalKey == "A" then
		self.moveVector2.x = -1
	elseif self.activeHorizontalKey == "D" then
		self.moveVector2.x = 1
	end

	self.moveVector2.y = 0

	if self.activeVerticalKey == "W" then
		self.moveVector2.y = 1
	elseif self.activeVerticalKey == "S" then
		self.moveVector2.y = -1
	end

	self:OnExecuteMove()
end

function M:OnMoveAResponse(context)
	if context.performed then
		self.activeHorizontalKey = "A"

		self:UpdateMoveVector()
	elseif context.canceled and self.activeHorizontalKey == "A" then
		self.activeHorizontalKey = nil

		self:UpdateMoveVector()
	end
end

function M:OnMoveDResponse(context)
	if context.performed then
		self.activeHorizontalKey = "D"

		self:UpdateMoveVector()
	elseif context.canceled and self.activeHorizontalKey == "D" then
		self.activeHorizontalKey = nil

		self:UpdateMoveVector()
	end
end

function M:OnMoveWResponse(context)
	if context.performed then
		self.activeVerticalKey = "W"

		self:UpdateMoveVector()
	elseif context.canceled and self.activeVerticalKey == "W" then
		self.activeVerticalKey = nil

		self:UpdateMoveVector()
	end
end

function M:OnMoveSResponse(context)
	if context.performed then
		self.activeVerticalKey = "S"

		self:UpdateMoveVector()
	elseif context.canceled and self.activeVerticalKey == "S" then
		self.activeVerticalKey = nil

		self:UpdateMoveVector()
	end
end

function M:OnExecuteMove()
	self.bindData.unityInputProcessorComponent0:OnJoypadDirections(self.moveVector2)
end

function M:OnAResponse(context)
	self.bindData.unityInputProcessorComponent0:OnJoypadBButton(context.performed)
end

function M:OnBResponse(context)
	self.bindData.unityInputProcessorComponent0:OnJoypadAButton(context.performed)
end

function M:OnCResponse(context)
	if self.currentGameType == self.gameType.MetalSlug then
		self.bindData.unityInputProcessorComponent0:OnJoypadLButton(context.performed)
	elseif self.currentGameType == self.gameType.Kof97 then
		self.bindData.unityInputProcessorComponent0:OnJoypadYButton(context.performed)
	end
end

function M:OnDResponse(context)
	if self.currentGameType == self.gameType.MetalSlug then
		self.bindData.unityInputProcessorComponent0:OnJoypadRButton(context.performed)
	elseif self.currentGameType == self.gameType.Kof97 then
		self.bindData.unityInputProcessorComponent0:OnJoypadXButton(context.performed)
	end
end

function M:OnInsertResponse(context)
	self.bindData.unityInputProcessorComponent0:OnJoypadSelectButton(context.performed)
end

function M:OnStartResponse(context)
	self.bindData.unityInputProcessorComponent0:OnJoypadStartButton(context.performed)
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView()
end

function M:InitModel(args)
	self.activeHorizontalKey = nil
	self.activeVerticalKey = nil
	self.gameType = {
		MetalSlug = 0,
		Kof97 = 1
	}
	self.moveVector2 = Vector2.New(0, 0)
	self.currentGameType = args and args.gameType or self.gameType.MetalSlug

	self.bindData.libretroWrapperManager:SetGameType(self.currentGameType)
end

function M:InitView()
	self.bindData.unityInputProcessorManager:AddPlayer(0, self.bindData.player0.gameObject)
end

function M:OnExitClick()
	gPanelManager:Close(self.m_Id)
end

function M:OnDestroy()
	self:ClearMessageEvents()
	self.bindData.unityInputProcessorManager:RemovePlayer(0)
end
