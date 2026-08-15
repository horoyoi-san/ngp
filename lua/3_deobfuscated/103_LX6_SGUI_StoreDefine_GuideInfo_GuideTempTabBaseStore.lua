C_GuideTempTabBaseStore = DefClass("C_GuideTempTabBaseStore", C_GuideTempTabBaseStore, C_StoreGroup)
local M = C_GuideTempTabBaseStore

function M:OnStart()
	local mainPanelStore = gStoreManager:GetStoreGroup("GuideTempPanelStore")

	if mainPanelStore and mainPanelStore.params and mainPanelStore.params.openedByTask then
		self:PlayTaskStartAnim()
	else
		self:PlayNormalStartAnim()
	end
end

function M:PlayTaskStartAnim()
	return
end

function M:PlayNormalStartAnim()
	return
end

function M:IsAnimPlaying()
	return false
end

function M:SkipCurrentAnim()
	return
end

function M:_SkipAnim(anim)
	anim.clip:SampleAnimation(anim.gameObject, 1000)
	anim:Stop()
end
