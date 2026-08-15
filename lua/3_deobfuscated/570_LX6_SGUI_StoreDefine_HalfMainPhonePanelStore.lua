C_HalfMainPhonePanelStore = DefClass("C_HalfMainPhonePanelStore", C_HalfMainPhonePanelStore, C_MainPhonePanelStore)
GroupName2Class.HalfMainPhonePanelStore = C_HalfMainPhonePanelStore
local M = C_HalfMainPhonePanelStore

function M:ctor()
	return
end

function M:OnShow(panelId, args)
	self.panelId = panelId

	self:InitModel(args)
	self:InitView(args)
end

function M:OnGroupEnable()
	gClientUtils.PlayPhoneAction()

	gCS.TransitionMgr.showMainCube = true
end

function M:OnExitClick()
	self.bindData.maskActive = true
	local closeAnimationName = "S_Vx_MainPhonePanel_close"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)

	self.playCloseAnimationCo = coroutine.start(function ()
		coroutine.wait(clipTime)
		gPanelManager:Close(self.panelId)
	end)
end

function M:OnAppItemClick(appId)
	gMainPhoneUtils.OnAppItemClick(appId)
end

function M:OnClose()
	self:ReleaseMap()

	self.hasPlayInitExpAnimation = nil
	self.playCloseAnimationCo = coroutine.stop(self.playCloseAnimationCo)
	self.playExpProgressAnimationCo = coroutine.stop(self.playExpProgressAnimationCo)
end
