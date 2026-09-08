-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimelineQTEProgressPanelStore.lua
-- Decompiled from: 01361_TimelineQTEProgressPanelStore.lua_047132326246.luajit

C_TimelineQTEProgressPanelStore = DefClass("C_TimelineQTEProgressPanelStore", C_TimelineQTEProgressPanelStore, C_StoreGroup)
GroupName2Class.TimelineQTEProgressPanelStore = C_TimelineQTEProgressPanelStore
local M = C_TimelineQTEProgressPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.typeEnum = {
		["\\xa6gr"] = 4,
		["Y-qZ"] = 2,
		["~\\xbe\\xab\\xac\\xaf"] = 1,
		[".@\\x88\\x9a\\x8bL"] = 3,
		T7qW = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.typeEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
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
	self.progressType = 0
	self.speed = 0
	self.bindData.progress.value = 0
	self.bindData.colaProgress.value = 0
	self.bindData.healthBar.hp = 1
	self.bindData.healthBar.maxHp = 1

	if type(data) ~= "string" then
		local parts = {}

		for part in string.gmatch(data, "([^|]+)") do
			parts[#parts + 1] = part
		end

		self.bindData.type = tonumber(parts[1]) or 0
		self.progressBar = self:SelectProgressBar()
		self.speed = tonumber(parts[2]) or 0

		self:SetProgressValue(tonumber(parts[3]) or 0)
	end
end

M.SelectProgressBar = function(self)
	if self.bindData.type ~= 1 then
		return self.bindData.progress
	elseif self.bindData.type ~= 2 then
		return self.bindData.colaProgress
	elseif self.bindData.type ~= 4 then
		return self.bindData.hotProgress
	end

	return nil
end

M.SetProgressValue = function(self, val)
	if self.progressBar then
		self.progressBar.value = val
	end

	self.bindData.healthBar.hp = val
	self.bindData.healthBar.fx = self.bindData.healthBar.hp
end

M.AddProgressValue = function(self, val)
	if self.progressBar then
		self.progressBar.value = self.progressBar.value + val
	end

	self.bindData.healthBar.hp = self.bindData.healthBar.hp + val
	self.bindData.healthBar.fx = self.bindData.healthBar.hp / self.bindData.healthBar.maxHp
end

M.OnUpdate = function(self)
	if self.speed == 0 then
		self.AddProgressValue(self, gLogicTime.deltaTime * self.speed)
	end

	if self.progressBar then
		gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_ON_PROGRESS_CHANGED, self.progressBar.value)
	elseif self.bindData.healthBar then
		gMessageManager:SendMessage(gEventConstants.TIMELINE_QTE_ON_PROGRESS_CHANGED, self.bindData.healthBar.hp)
	end
end

M.GenMessageEvents = function(self)
	if not self.msgEvents then
		self.msgEvents = {
			[gEventConstants.TIMELINE_QTE_CHANGE_PROGRESS] = function (eventId, value)
				if type(value) ~= "number" then
					self:AddProgressValue(value)
				elseif type(value) ~= "string" then
					local sep_pos = string.find(value, "|")

					if sep_pos then
						local changeVal = tonumber(string.sub(value, 1, sep_pos - 1))
						local delay = tonumber(string.sub(value, sep_pos + 1))

						Timer.New(function ()
							self:AddProgressValue(changeVal)
						end, delay):Start()
					end
				end
			end
		}
	end
end

M.RegisterWidget = function(self)
end
