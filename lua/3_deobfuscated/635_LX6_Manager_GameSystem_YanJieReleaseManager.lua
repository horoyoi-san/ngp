YanJieReleaseManager = DefClass("YanJieReleaseManager", YanJieReleaseManager, nil, nil)
local M = YanJieReleaseManager

function M:ExecuteCheckQueue()
	self.checkQueueCo = coroutine.stop(self.checkQueueCo)
	self.checkQueueCo = coroutine.start(function ()
		coroutine.step()
		self:ShowPanel()

		while true do
			coroutine.wait(0.15)
			self:ShowPanel()
		end
	end)
end

function M:ShowPanel()
	if self.queueList and #self.queueList > 0 then
		local phoneId = gClientUtils.GetMainPhonePanelId()
		local args = self.queueList[1]

		if gPanelManager:CheckCanPanelShow(phoneId, args) == 0 then
			table.remove(self.queueList, 1)
			gPanelManager:CheckShow(phoneId, args)
		end
	end
end

function M:Add(args)
	self.queueList = self.queueList or {}

	table.insert(self.queueList, args)
end

function M:Remove(id)
	for index, args in ipairs(self.queueList) do
		if args.id == id then
			table.remove(self.queueList, index)

			break
		end
	end
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.queueList = nil
		self.checkQueueCo = coroutine.stop(self.checkQueueCo)
	else
		self:ExecuteCheckQueue()
	end
end

gYanJieReleaseManager = gYanJieReleaseManager or YanJieReleaseManager.new()
