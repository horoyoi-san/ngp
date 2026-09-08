-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HouseRewardPanelStore.lua
-- Decompiled from: 01808_HouseRewardPanelStore.lua_adc58bc55814.luajit

local HouseConfig = LTConfig.HouseConfig
C_HouseRewardPanelStore = DefClass("C_HouseRewardPanelStore", C_HouseRewardPanelStore, C_StoreGroup)
GroupName2Class.HouseRewardPanelStore = C_HouseRewardPanelStore
local M = C_HouseRewardPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.panelId = nil
	self.houseId = nil
	self.PreLoad = false
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.bindData.CCPlayer:Init()
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.houseId = data and data.houseId or nil
	self.PreLoad = data and data.PreLoad ~= true or false

	if not self.houseId then
		print_error("HouseRewardPanelStore: OnShow 缺少 houseId")

		return
	end

	local cfg = HouseConfig.GetConfig(self.houseId)

	if not cfg then
		print_error(string.format("HouseRewardPanelStore: 找不到 HouseConfig, houseId=%s", tostring(self.houseId)))

		return
	end

	local videoId = cfg.GameVideo

	if self.PreLoad then
		if videoId and videoId <= 0 then
			self.bindData.CCPlayer:PreLoadVideo(videoId)
		end

		gPanelManager:SetActiveById(self.panelId, false)

		return
	end

	self.bindData.nameText = cfg.Name or ""

	gPanelManager:SetActiveById(self.panelId, false)

	if videoId and videoId <= 0 then
		slot5 = self.bindData.CCPlayer

		slot5:PlayVideo(videoId, false, function ()
			local curTask = gTaskManager:GetCurTask()
			local hasTask = curTask and curTask == 0
			local isInBigWorld = gMapAreaMgr:IsBigWorldRaidId(gMapSystem.lastRaidId)

			if not hasTask and isInBigWorld then
				local mapEntranceId = cfg.MapEntrance

				if mapEntranceId and mapEntranceId == 0 then
					gMapSubSystem_Entrance:TryTeleport(mapEntranceId)
				end
			end

			gPanelManager:Close(self.panelId)
		end, function ()
			gPanelManager:SetActiveById(self.panelId, true)
		end)
	end
end

M.OnClose = function(self)
	self.bindData.CCPlayer:Stop()
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
end

M.OnCloseBtnClick = function(self)
end
