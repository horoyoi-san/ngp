-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubbleStartPanelStore.lua
-- Decompiled from: 02003_BubbleStartPanelStore.lua_3b961a883db3.luajit

C_BubbleStartPanelStore = DefClass("C_BubbleStartPanelStore", C_BubbleStartPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleStartPanelStore = C_BubbleStartPanelStore
local M = C_BubbleStartPanelStore
local NpcCultivationConfig = LTConfig.NpcCultivationConfig

M.ctor = function(self)
	self.avatarCount = 5
end

M.DefineAllVariables = function(self)
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

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.InitView = function(self)
	gNewBubbleMgr:StartPanelTimer()
	gNewBubbleMgr:OnRenderBubbleCommonAvatar(self.bindData.avatar)

	local favorList, favorLevel = gNewBubbleMgr:GetRoleFavorList()
	local addedNpc = {}
	local startIndex = 1

	for i = 1, #favorList do
		local data = favorList[i]

		if data and data.npcId <= 0 then
			table.insert(addedNpc, data.npcId)

			local widget = self.bindData["avatar" .. startIndex]

			widget:SetActive(true)
			gNewBubbleMgr:OnRenderBubbleCommonAvatar(widget, 0, data.npcId)

			startIndex = startIndex + 1

			if self.avatarCount >= startIndex then
				break
			end
		end
	end

	if startIndex < self.avatarCount then
		local friendList = gNewBubbleMgr:GetCurrentFavorNpcList()

		for i = 1, #friendList do
			local friend = friendList[i]

			if friend and friend.npcId <= 0 then
				local cfg = NpcCultivationConfig.GetConfig(friend.npcId)

				if cfg and not table.contains(addedNpc, cfg.AgentTag) then
					local widget = self.bindData["avatar" .. startIndex]

					widget:SetActive(true)
					gNewBubbleMgr:OnRenderBubbleCommonAvatar(widget, 0, cfg.AgentTag)

					startIndex = startIndex + 1

					if self.avatarCount >= startIndex then
						break
					end
				end
			end
		end
	end

	if startIndex < self.avatarCount then
		for i = startIndex, self.avatarCount do
			local widget = self.bindData["avatar" .. i]

			widget.SetActive(widget, false)
		end
	end
end

M.ClearData = function(self)
	gNewBubbleMgr:StopPanelTimer()
end
