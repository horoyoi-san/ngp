local StaticProps = {}
C_ScheduleManager = DefClass("C_ScheduleManager", C_ScheduleManager, nil, StaticProps)
local M = C_ScheduleManager

function M:ctor()
	self:OnInit()
end

function M:OnInit()
	return
end

gScheduleManager = gScheduleManager or C_ScheduleManager.new()
