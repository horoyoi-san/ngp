local DataSet = require("LX6/DataBind/DataSet")
local M = {
	units = {},
	users = {},
	CreateUnitData = function (self, pid, isMe, csUnit)
		local clientData = csUnit.ClientData
		local pid = clientData.Pid
		local t = {
			pid = pid,
			name = clientData.Name or "",
			title = clientData.Title or "",
			hp = clientData.Hp,
			maxhp = clientData.MaxHp,
			shield = clientData.Shield,
			partShieldChanged = 0,
			subType = clientData.SubType,
			dam = clientData.Dam,
			def = clientData.PhyDef,
			transformId = 0,
			ownerId = clientData.OwnerId,
			type = clientData.Type,
			level = clientData.Level,
			isMe = isMe,
			realInVisiable = false,
			isBuffHideNameBar = false,
			isDead = false,
			isFightState = false,
			showHpOrUnderAttack = false,
			showPartBarUnderAttack = {},
			gameId = 0,
			toughnessValue = 0,
			toughnessMaxValue = 0,
			isGrabByMind = false,
			isWeak = false,
			beingAssassinated = false
		}
		local data = self.units[pid]

		if data then
			data:RefreshData(t)
		else
			data = DataSet.New(t)
			self.units[pid] = data
		end

		if isMe then
			self.myUnit = data
		end

		return data
	end,
	GetUnitData = function (self, pid)
		return self.units[pid]
	end,
	TryGetOrCreateUnitData = function (self, pid)
		if self.units[pid] == nil then
			local csunit = gCS.SceneDataMgr.GetUnit(pid)

			if csunit then
				self:CreateUnitData(pid, csunit.IsMe, csunit)
			end
		end

		return self.units[pid]
	end,
	GetOrCreateUserData = function (self, uid)
		if self.users[uid] == nil then
			local t = {
				Uid = uid,
				DisplayName = "",
				AllowHeadInfo = true
			}
			self.users[uid] = DataSet.New(t)
		end

		return self.users[uid]
	end,
	ReBindMyUnit = function (self, pid)
		self.myUnit.isMe = false
		local data = self:TryGetOrCreateUnitData(pid)

		if data == nil then
			LX6.Utils.LogUtilsLua.SendToPopo("[ReBindMyUnit] Lua中的dataset没了", "shizhouxu")
		end

		data.isMe = true
		self.myUnit = data
	end,
	RemoveUnitData = function (self, pid)
		self.units[pid] = nil
	end,
	SetUnitData = function (self, pid, key, value)
		if not self.units or not self.units[pid] then
			return
		end

		self.units[pid][key] = value
	end
}
gDataSetManager = M
