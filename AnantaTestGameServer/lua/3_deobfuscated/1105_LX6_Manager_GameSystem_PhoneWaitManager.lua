C_PhoneWaitManager = DefClass("C_PhoneWaitManager", C_PhoneWaitManager, nil, nil)
local M = C_PhoneWaitManager

function M:ctor()
	self:RegisterMessages()
	self:InitData()
end

function M:ExecuteShowLogic()
	if self:CheckCanShow() then
		local args = self.popUpQueue:Pop()

		gMainPhoneUtils.ShowPhoneAppContent(args)
	end
end

function M:CheckCanShow()
	if not self.popUpQueue or self.popUpQueue.count == 0 then
		return false
	end

	if gClientUtils.IsMainPhoneExist() then
		return false
	end

	return true
end

function M:InitData()
	self.popUpQueue = self.popUpQueue or gDataStructureUtils.GetQueue()
end

function M:RegisterMessages()
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

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.popUpQueue:Clear()

		self.waitQueueCo = coroutine.stop(self.waitQueueCo)
	end
end

gPhoneWaitManager = gPhoneWaitManager or C_PhoneWaitManager.new()
