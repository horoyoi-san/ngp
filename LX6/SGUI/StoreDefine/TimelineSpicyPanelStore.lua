-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineSpicyPanelStore.lua
-- Decompiled from: 01364_TimelineSpicyPanelStore.lua_c2e69eb4de2a.luajit

C_TimelineSpicyPanelStore = DefClass("C_TimelineSpicyPanelStore", C_TimelineSpicyPanelStore, C_StoreGroup)
GroupName2Class.TimelineSpicyPanelStore = C_TimelineSpicyPanelStore
local M = C_TimelineSpicyPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	if not self.EventHandler then
		self.EventHandler = {
			[gEventConstants.TIMELINE_QTE_CHANGE_PROGRESS] = function (eventId, value)
				if type(value) ~= "number" then
					self.bindData.fillAmount = self.bindData.fillAmount + value
				elseif type(value) ~= "string" then
					local sep_pos = string.find(value, "|")

					if sep_pos then
						local changeVal = tonumber(string.sub(value, 1, sep_pos - 1))
						local delay = tonumber(string.sub(value, sep_pos + 1))

						Timer.New(function ()
							self.bindData.fillAmount = self.bindData.fillAmount + changeVal
						end, delay):Start()
					end
				end
			end
		}
	end

	self.BindListener(self)
end

M.BindListener = function(self)
	if not self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end

		self.IsBindListener = true
	end
end

M.UnbindListener = function(self)
	if self.IsBindListener then
		for i, v in pairs(self.EventHandler) do
			gMessageManager:RemoveMessageListener(i, v)
		end

		self.IsBindListener = false
	end
end

M.OnShow = function(self, panelId, data)
	if type(data) ~= "string" then
		data = tonumber(data)
	end

	self.speed = data
	self.bindData.fillAmount = 0
end

M.OnUpdate = function(self)
	self.bindData.fillAmount = self.bindData.fillAmount + gLogicTime.deltaTime * self.speed

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_ON_PROGRESS_CHANGED, self.bindData.fillAmount)
end

M.OnClose = function(self)
	self.UnbindListener(self)
end
