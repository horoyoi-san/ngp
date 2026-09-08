-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\HideAndSeek\HideAndSeekManager.lua
-- Decompiled from: 00615_HideAndSeekManager.lua_c0401451e6e8.luajit

C_HideAndSeekManager = DefClass("C_HideAndSeekManager", C_HideAndSeekManager)
local M = C_HideAndSeekManager

M.ctor = function(self)
	self.isCat = false
	self.ratsData = {}
	self.panelIsRegister = false
	self.panelCallBack = {}
	self.buttonBanId = nil
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.ENTER_HIDE_AND_SEEK, self:CreateAction(self.OnEnterHideAndSeek))
end

M.OnBeforeSwitchScene = function(self, eventId, switchSceneEventParams)
	self:ClearData()
	self:ClearBanButton()
end

M.OnEnterHideAndSeek = function(self)
	if not self.buttonBanId then
		self.buttonBanId = gStoreButtonMgr:RegisterOperation({
			["\\xca\\xcf\t\r\\xf5"] = 5,
			["\\xbb\\xa3\\xa4x7\\xea*"] = 0,
			groupId = LTConfig.HudDescGroupConfig.HideandSeek
		})
	end
end

M.ClearBanButton = function(self)
	if self.buttonBanId then
		gStoreButtonMgr:UnRegisterOperation(self.buttonBanId)

		self.buttonBanId = nil
	end
end

M.ClearData = function(self)
	self.isCat = false
	self.ratsData = {}
end

M.SyncHideAndSeekEnd = function(self)
	self:ClearData()
	self:ClearBanButton()
	gTaskUtils:CloseTaskGuideCurTab()
end

M.SyncHideAndSeekGhostMice = function(self, rats)
	if not self.ratsData then
		return
	end

	if rats.Count then
		for i = 1, rats.Count do
			local id = rats[i]

			if id then
				for j, v in ipairs(self.ratsData) do
					if ulong.equals(v.pid, id) then
						self.ratsData[j].alive = false
					end
				end
			end
		end

		self:RefreshRatsList()
	end
end

M.SyncCityHideAndSeekPlayerInfo = function(self, seekers, hiders)
	self:ClearData()
	self:TryFindSelfIsSeeker(seekers)
	self:TryAddHiders(hiders)
end

M.RefreshRatsList = function(self)
	self:SendMessageToPanel(function ()
		local store = gStoreManager:GetStoreGroup("CatRatsPanelStore")

		if store then
			store:SetAllRats()
		end
	end)
end

M.SendMessageToPanel = function(self, callback)
	if not self.panelIsRegister then
		table.insert(self.panelCallBack, callback)
	else
		callback()
	end
end

M.ExecuteCallback = function(self)
	for _, func in pairs(self.panelCallBack) do
		func()
	end

	self.panelCallBack = {}
end

M.TryFindSelfIsSeeker = function(self, seekers)
	if seekers.Count then
		for i = 1, seekers.Count do
			local id = seekers[i]

			if not id then
				-- Nothing
			elseif ulong.equals(gPlayerManager.infoLogin.bindData.pid, id) then
				self.isCat = true

				return
			end
		end

		self.isCat = false
	end
end

M.TryAddHiders = function(self, hiders)
	if hiders.Count then
		for i = 1, hiders.Count do
			local id = hiders[i]

			if id then
				if not self.ratsData then
					self.ratsData = {}
				end

				local ratInfo = {
					["L\\xa2\\xab\\xb9\\xb3"] = true,
					pid = id
				}

				table.insert(self.ratsData, ratInfo)
			end
		end
	end
end

M.SyncStartGhostMode = function(self, pid)
	if not self.ratsData then
		return
	end

	for i, v in ipairs(self.ratsData) do
		if ulong.equals(v.pid, pid) then
			self.ratsData[i].alive = false

			break
		end
	end

	self:RefreshRatsList()
end

gHideAndSeekManager = gHideAndSeekManager or C_HideAndSeekManager.new()
