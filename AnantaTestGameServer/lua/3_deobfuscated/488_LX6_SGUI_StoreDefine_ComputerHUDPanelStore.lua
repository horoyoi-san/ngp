C_ComputerHUDPanelStore = DefClass("C_ComputerHUDPanelStore", C_ComputerHUDPanelStore, C_StoreGroup)
GroupName2Class.ComputerHUDPanelStore = C_ComputerHUDPanelStore
local M = C_ComputerHUDPanelStore

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")

	self:InitMessages()
end

function M:InitMessages()
	local messageEvents = {
		[gEventConstants.ON_COMPUTER_PANEL_EXIT_BUTTON_STATE_CHANGE] = self:CreateAction("OnExitButtonStateChange")
	}

	self:RegisterMessageEvents(messageEvents)
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.exitCallback = args and args.exitCallback

	if args and args.exitInitShow then
		self.bindData.exitButton:SetActive(not args.exitInitShow)
	end
end

function M:InitView(args)
	local navigationArea = args.navigationArea
	navigationArea.gamePadBar = self.bindData.gamePadBar

	navigationArea:RegisterGamePadBar()
	navigationArea:RefreshPCKeys()
	navigationArea:RefreshGamePadBar()
end

function M:OnExitClick()
	if self.exitCallback then
		self.exitCallback()
	end
end

function M:OnExitButtonStateChange(_, isActive)
	self.bindData.exitButton:SetActive(isActive)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end
