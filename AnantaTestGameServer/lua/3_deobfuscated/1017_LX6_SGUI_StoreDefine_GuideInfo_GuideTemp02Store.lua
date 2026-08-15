C_GuideTemp02Store = DefClass("C_GuideTemp02Store", C_GuideTemp02Store, C_GuideTempTabBaseStore)
GroupName2Class.GuideTemp02Store = C_GuideTemp02Store
local M = C_GuideTemp02Store

function M:PlayTaskStartAnim()
	self.bindData.anim:Play()
end

function M:IsAnimPlaying()
	return self.bindData.anim.isPlaying
end

function M:SkipCurrentAnim()
	self:_SkipAnim(self.bindData.anim)
end
