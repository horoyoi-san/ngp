C_DeliveryFakeTaskStore = DefClass("C_DeliveryFakeTaskStore", C_DeliveryFakeTaskStore, C_StoreGroup)
GroupName2Class.DeliveryFakeTaskStore = C_DeliveryFakeTaskStore
local M = C_DeliveryFakeTaskStore
local UberSimConfig = LTConfig.UberSimConfig

function M:ctor()
	return
end

function M:OnAwake()
	self.msgEvents = {
		[gEventConstants.FAKE_DELIVERY_INTEGRITY] = self:CreateAction(self.ChangeIntegrity),
		[gEventConstants.FAKE_DELIVERY_END] = self:CreateAction(self.CloseFakePanel)
	}

	self:InitConfig()
end

function M:CloseFakePanel()
	gPanelManager:Close(gPanelId.S_DELIVERY_FAKE_TASK_PANEL)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.FakeDeliveryEnd, {
		leftIconId = 28002351,
		content = string.format(UberSimConfig.PopupSubTitle, UberSimConfig.TruckGuideContent),
		mainTitle = UberSimConfig.PopupMainTitle
	})
end

function M:InitConfig()
	self.IntactSectionDescription = UberSimConfig.IntactSectionDescription
end

function M:ChangeIntegrity(_, data)
	self.integrity = Mathf.Clamp(self.integrity + data.integrity, 0, 100)

	self:UpdateIntegrityText()
end

function M:UpdateIntegrityText()
	for index, v in ipairs(self.IntactSectionDescription) do
		if v.min <= self.integrity and self.integrity <= v.max then
			self.bindData.cargoState = index

			return
		end
	end
end

function M:OnUpdate()
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
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.integrity = 98
	self.time = gCS.TimeManager.ServerUnixTime

	self:UpdateIntegrityText()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
