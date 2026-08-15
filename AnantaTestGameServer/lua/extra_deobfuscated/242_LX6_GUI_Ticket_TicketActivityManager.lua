local M = {
	CurrentActivityId = 0
}

function M:SetCurrentActivityId(activityId)
	self.CurrentActivityId = activityId

	gMessageManager:SendMessage(gEventConstants.RAID_ACTIVITY_CHANGE, nil)
end

gTicketActivityManager = M
