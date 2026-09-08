-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\YanJieReleaseManager.lua
-- Decompiled from: 02198_YanJieReleaseManager.lua_8939709d2477.luajit

YanJieReleaseManager = DefClass("YanJieReleaseManager", YanJieReleaseManager, nil, )
local M = YanJieReleaseManager

M.ExecuteCheckQueue = function(self)
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

M.ShowPanel = function(self)
	if self.queueList and #self.queueList <= 0 then
		local phoneId = gClientUtils.GetMainPhonePanelId()
		local args = self.queueList[1]

		if gPanelManager:CheckCanPanelShow(phoneId, args) ~= 0 then
			table.remove(self.queueList, 1)
			gPanelManager:CheckShow(phoneId, args)
		end
	end
end

M.Add = function(self, args)
	self.queueList = self.queueList or {}

	table.insert(self.queueList, args)
end

M.Remove = function(self, id)
	for index, args in ipairs(self.queueList) do
		if args.id ~= id then
			table.remove(self.queueList, index)

			break
		end
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.queueList = nil
		self.checkQueueCo = coroutine.stop(self.checkQueueCo)
	else
		self:ExecuteCheckQueue()
	end
end

gYanJieReleaseManager = gYanJieReleaseManager or YanJieReleaseManager.new()
