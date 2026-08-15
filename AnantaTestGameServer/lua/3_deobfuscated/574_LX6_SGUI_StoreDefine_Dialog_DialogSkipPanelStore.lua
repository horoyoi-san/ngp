C_DialogSkipPanelStore = DefClass("C_DialogSkipPanelStore", C_DialogSkipPanelStore, C_StoreGroup)
GroupName2Class.DialogSkipPanelStore = C_DialogSkipPanelStore
local M = C_DialogSkipPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.btnConfirm.luaClick = self:CreateAction("OnSkipClick")
	self.bindData.btnCancel.luaClick = self:CreateAction("OnExitClick")
	self.bindData.btnSelect.luaClick = self:CreateAction("OnSelectClick")
	self.closeAnimeName = "vx_S_RaidExitPanel_out"
	self.SkipWithoutConfirm = false
	self.needOpenAutoPlay = gDialogManager.autoPlay

	if self.needOpenAutoPlay then
		gDialogManager:SwitchAutoPlay()
	end
end

function M:OnShow(panelId, data)
	self.CustomText = data.text
	self.JumpFunc = data.jumpFunc
	self.CancelFunc = data.cancelFunc
end

function M:OnClose()
	self:CancelFunc()

	if self.needOpenAutoPlay and not gDialogManager.autoPlay then
		gDialogManager:SwitchAutoPlay()
	end
end

function M:OnSkipClick()
	if self.SkipWithoutConfirm then
		gDialogManager.skipDialogWithoutConfirm = true
	end

	self:JumpFunc()
	self:ClosePanel()
end

function M:OnSelectClick()
	self.SkipWithoutConfirm = not self.SkipWithoutConfirm
end

function M:OnExitClick()
	self:ClosePanel()
end

function M:ClosePanel()
	local duration = gCS.LuaUtils.GetAnimationTime(self.bindData.anim, self.closeAnimeName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.anim, self.closeAnimeName)
	Timer.New(function ()
		gPanelManager:Close(gPanelId.S_SKIP_DIALOG_PANEL)
	end, duration):Start()
end
