-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\PhoneWaitManager.lua
-- Decompiled from: 02196_PhoneWaitManager.lua_343d7201c03a.luajit

C_PhoneWaitManager = DefClass("C_PhoneWaitManager", C_PhoneWaitManager, nil, )
local M = C_PhoneWaitManager

M.ctor = function(self)
	self:RegisterMessages()
	self:InitData()
end

M.ExecuteShowLogic = function(self)
	if self:CheckCanShow() then
		local args = self.popUpQueue:Pop()

		gMainPhoneUtils.ShowPhoneAppContent(args)
	end
end

M.CheckCanShow = function(self)
	if not self.popUpQueue or self.popUpQueue.count ~= 0 then
		return false
	end

	if gClientUtils.IsMainPhoneExist() then
		return false
	end

	return true
end

M.InitData = function(self)
	self.popUpQueue = self.popUpQueue or gDataStructureUtils.GetQueue()
end

M.RegisterMessages = function(self)
	self.mEventHandlers = {
		[gEventConstants.PANEL_ON_CLOSE] = function (_)
			self.waitQueueCo = coroutine.start(function ()
				coroutine.step()
				self:ExecuteShowLogic()
			end)
		end
	}

	gMessageManager:RegisterEventHandlers(self.mEventHandlers)
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self.popUpQueue:Clear()

		self.waitQueueCo = coroutine.stop(self.waitQueueCo)
	end
end

gPhoneWaitManager = gPhoneWaitManager or C_PhoneWaitManager.new()
