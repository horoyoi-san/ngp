local RedDotMgr = SGUI.RedDotMgr
local RedDotConfig = LTConfig.PanelRedDotConfig
C_RedDotMgr = DefClass("C_RedDotMgr", C_RedDotMgr)
local M = C_RedDotMgr

function M:ctor()
	self.data = {}
end

function M:Log(...)
	print_debug("[C_RedDotMgr]", ...)
end

function M:SetNewTip(panelId)
	local data = self:GetData(panelId)
	local dirty = data.newTip ~= true

	if dirty then
		data.newTip = true

		self:Refresh(panelId)
	end
end

function M:ClearNewTip(panelId)
	local data = self:GetData(panelId)
	local dirty = data.newTip ~= false

	if dirty then
		data.newTip = false

		self:Refresh(panelId)
	end
end

function M:IsPanelHasRedPoint(panelId)
	local data = self.data[panelId]

	if not data then
		return false
	end

	if data.newTip then
		return true
	end

	for k, v in pairs(data.subset) do
		if v then
			return true
		end
	end

	return false
end

function M:Clear(panelId)
	self.data[panelId] = nil

	self:Refresh(panelId)
end

function M:GetData(panelId)
	local data = self.data[panelId]

	if not data then
		data = {
			newTip = false,
			subset = {}
		}
		self.data[panelId] = data
	end

	return data
end

function M:Refresh(panelId)
	gMessageManager:SendMessage(gEventConstants.RED_POINT_PANEL_UPDATE, panelId)
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self.data = {}

		self:ClearAllRedDot()
	end
end

function M:RegisterRedDotByKey(id, isShow)
	local key = RedDotConfig.GetConfig(id)

	if not key then
		return
	end

	self:RegisterRedDot(isShow, key.Name)
end

function M:RegisterRedDot(isShown, key, force)
	RedDotMgr.LuaSetRedDot(isShown, key, force)
end

function M:ClearAllRedDot()
	RedDotMgr.ClearAllRedDot()
end

function M:ClearRedDot(key)
	RedDotMgr.ClearRedDotByKey(key)
end

gRedPointMgr = gRedPointMgr or C_RedDotMgr.new()
