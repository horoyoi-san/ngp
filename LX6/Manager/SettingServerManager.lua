-- Original chunk: @Lua\LuaFiles\LX6\Manager\SettingServerManager.lua
-- Decompiled from: 02189_SettingServerManager.lua_b0b3bdc5b247.luajit

C_SettingServerManager = DefClass("C_SettingServerManager", C_SettingServerManager)
local M = C_SettingServerManager
local json = require("cjson/json")

M.ctor = function(self)
	self.cache = {}
	self.dirty = {}
end

M.InitFromServer = function(self, settings)
	if not settings then
		return
	end

	self.cache = {}

	for key, val in pairs(settings) do
		self.cache[key] = {
			NumberValue = val.NumberValue or 0,
			StringValue = val.StringValue or ""
		}
	end

	self.dirty = {}
end

M.SyncFromServer = function(self, settings)
	if not settings then
		return
	end

	for key, val in pairs(settings) do
		if not self.dirty[key] then
			self.cache[key] = {
				NumberValue = val.NumberValue or 0,
				StringValue = val.StringValue or ""
			}
		end
	end
end

M.GetValue = function(self, serverSettingId, valueType)
	local entry = self.cache[serverSettingId]

	if not entry then
		return nil
	end

	if valueType ~= "number" then
		return entry.NumberValue
	elseif valueType ~= "string" then
		return entry.StringValue
	end

	return nil
end

M.SetValue = function(self, serverSettingId, valueType, val)
	self.cache[serverSettingId] = self.cache[serverSettingId] or {
		["\\xb1!-=}\\x8fw\\xd8;\\xbf\\xbc"] = 0,
		["\\xac 26v\\x9aw\\xd8;\\xbf\\xbc"] = ""
	}

	if valueType ~= "number" then
		self.cache[serverSettingId].NumberValue = val
	elseif valueType ~= "string" then
		self.cache[serverSettingId].StringValue = val
	end

	self.dirty[serverSettingId] = true
end

M.ResetValue = function(self, serverSettingId)
	self.cache[serverSettingId] = nil
	self.dirty[serverSettingId] = true
end

M.FlushServerSettings = function(self)
	if table.isNilOrEmpty(self.dirty) then
		return
	end

	local changes = {}

	for key, _ in pairs(self.dirty) do
		if self.cache[key] then
			changes[key] = self.cache[key]
		else
			changes[key] = {
				["\\xb1!-=}\\x8fw\\xd8;\\xbf\\xbc"] = 0,
				["\\xac 26v\\x9aw\\xd8;\\xbf\\xbc"] = ""
			}
		end
	end

	print_notice("[SettingServerManager] FlushServerSettings count=" .. table.count(self.dirty))

	for key, val in pairs(changes) do
		print_notice(string.format("[SettingServerManager]   key=%s NumberValue=%s StringValue=%s", tostring(key), tostring(val.NumberValue), tostring(val.StringValue)))
	end

	gClientToGameDelegate:AskSaveSettings(changes).Callback = function (data)
		if data == 0 then
			print_error("#NoCreateIssue Repairing -- [SettingServerManager] AskSaveSettings failed ")
		end
	end

	self.dirty = {}
end

M.GetTemplate11Value = function(self, parentKey, subKey, valueType)
	local raw = self:GetValue(parentKey, "string")

	if string.is_null_or_empty(raw) then
		return nil
	end

	local ok, parsed = pcall(json.decode, raw)

	if not ok or not parsed then
		return nil
	end

	local val = parsed[tostring(subKey)]

	if val ~= nil then
		return nil
	end

	if valueType ~= "number" then
		return tonumber(val) or val
	end

	return val
end

M.SetTemplate11Value = function(self, parentKey, subKey, valueType, val)
	local raw = self:GetValue(parentKey, "string")
	local merged = {}

	if not string.is_null_or_empty(raw) then
		local ok, parsed = pcall(json.decode, raw)

		if ok and parsed then
			merged = parsed
		end
	end

	if val ~= nil then
		merged[tostring(subKey)] = nil

		if next(merged) ~= nil then
			self:ResetValue(parentKey)

			return
		end
	else
		merged[tostring(subKey)] = val
	end

	self:SetValue(parentKey, "string", json.encode(merged))
end

M.ResetTemplate11Value = function(self, parentKey, subKey)
	local raw = self:GetValue(parentKey, "string")

	if string.is_null_or_empty(raw) then
		return
	end

	local ok, merged = pcall(json.decode, raw)

	if not ok or not merged then
		return
	end

	merged[tostring(subKey)] = nil

	if next(merged) ~= nil then
		self:ResetValue(parentKey)
	else
		self:SetValue(parentKey, "string", json.encode(merged))
	end
end

gSettingServerManager = gSettingServerManager or C_SettingServerManager.new()
