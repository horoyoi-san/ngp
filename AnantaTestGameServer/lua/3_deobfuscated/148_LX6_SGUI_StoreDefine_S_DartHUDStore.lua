C_S_DartHUDStore = DefClass("C_S_DartHUDStore", C_S_DartHUDStore, C_StoreGroup)
GroupName2Class.S_DartHUDStore = C_S_DartHUDStore
local M = C_S_DartHUDStore

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	if self.animaTimer ~= nil then
		self.animaTimer:Stop()
	end

	self.animaTimer = Timer.New(function ()
		self.animaTimer = nil

		gPanelManager:Close(gPanelId.S_DartHUDStorePanel)
	end, 2.5):Start()
	local hudType = data.hudType
	local num = data.roundNum
	self.bindData.hudType = hudType
	self.bindData.roundText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901074).Text, gUIUtils:NumberToChinese(num))
end

function M:OnClose()
	return
end
