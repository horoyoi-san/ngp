C_DeliveryFakeEndPanelStore = DefClass("C_DeliveryFakeEndPanelStore", C_DeliveryFakeEndPanelStore, C_StoreGroup)
GroupName2Class.DeliveryFakeEndPanelStore = C_DeliveryFakeEndPanelStore
local M = C_DeliveryFakeEndPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.finishAnimation = "S_Vx_DeliveryEndPanel_open"
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
	self.bindData.duration = self:GetFormatTime(data.duration)
	self.bindData.progress = data.progress
	self.bindData.progressText = data.progress
	local duration = self.bindData.root.anim:GetClip(self.finishAnimation).length or LTConfig.DropConfig.SpecialDropShowTime

	self.bindData.root.anim:Play()
	Timer.New(function ()
		gPanelManager:Close(gPanelId.S_DELIVERY_FAKE_END_PANEL)
	end, duration):Start()
end

function M:GetFormatTime(time)
	local rawMin = time <= 0 and 0 or math.floor(time / 60)
	local rawSec = 0
	rawSec = time <= 0 and 0 or math.floor((time - rawMin * 60) % 60)

	return gString.Format("%02d:%02d", rawMin, rawSec), rawMin, rawSec
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
