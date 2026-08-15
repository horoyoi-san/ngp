C_GuideTemp03Store = DefClass("C_GuideTemp03Store", C_GuideTemp03Store, C_GuideTempTabBaseStore)
GroupName2Class.GuideTemp03Store = C_GuideTemp03Store
local M = C_GuideTemp03Store

function M:PlayTaskStartAnim()
	self.bindData.anim:Play()
end

function M:IsAnimPlaying()
	return self.bindData.anim.isPlaying
end

function M:SkipCurrentAnim()
	self:_SkipAnim(self.bindData.anim)
end
