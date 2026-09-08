-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineMassageQTEProgressPanelStore.lua
-- Decompiled from: 01356_TimelineMassageQTEProgressPanelStore.lua_dd5a7378e804.luajit

C_TimelineMassageQTEProgressPanelStore = DefClass("C_TimelineMassageQTEProgressPanelStore", C_TimelineMassageQTEProgressPanelStore, C_StoreGroup)
GroupName2Class.TimelineMassageQTEProgressPanelStore = C_TimelineMassageQTEProgressPanelStore
local M = C_TimelineMassageQTEProgressPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.GenMessageEvents(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.speed = 0
	self.bindData.slider.value = 0

	if type(data) ~= "string" then
		local parts = {}

		for part in string.gmatch(data, "([^|]+)") do
			parts[#parts + 1] = part
		end

		self.speed = tonumber(parts[2]) or 0
		self.bindData.slider.value = tonumber(parts[3]) or 0
	end
end

M.OnUpdate = function(self)
	if self.speed == 0 then
		self.bindData.slider.value = self.bindData.slider.value + gLogicTime.deltaTime * self.speed
	end

	gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_ON_PROGRESS_CHANGED, self.bindData.slider.value)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	if not self.msgEvents then
		self.msgEvents = {
			[gEventConstants.TIMELINE_QTE_CHANGE_PROGRESS] = function (eventId, value)
				if type(value) ~= "number" then
					self.bindData.slider.value = self.bindData.slider.value + value
				elseif type(value) ~= "string" then
					local sep_pos = string.find(value, "|")

					if sep_pos then
						local changeVal = tonumber(string.sub(value, 1, sep_pos - 1))
						local delay = tonumber(string.sub(value, sep_pos + 1))

						Timer.New(function ()
							self.bindData.slider.value = self.bindData.slider.value + changeVal
						end, delay):Start()
					end
				end
			end
		}
	end
end
