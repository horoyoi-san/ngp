dofile("LX6/Manager/Map/Utils/BigMapComps/FilterMenu/BigMapComp_FilterMenu_PCView.lua")
dofile("LX6/Manager/Map/Utils/BigMapComps/FilterMenu/BigMapComp_FilterMenu_MobileView.lua")

local NavMgr = SGUI.UNavigationMgr
BigMapComp_FilterMenu = BigMapComp_FilterMenu or {}
local M = BigMapComp_FilterMenu
M.__index = M

function M:OnActive()
	self:Refresh()
end

function M:OnInactive()
	self:Refresh()
end

function M:OnUpdate()
	if self.view then
		self.view:OnUpdate()
	end
end

function M:OnEnd()
	if self.view then
		self.view:OnEnd()
	end
end

function M:OnActiveDeviceChange(device)
	if device == SGUI.GameDevice.KeyboardMouse then
		NavMgr.Inst.CurrentActiveArea = self.bigMap.bindData.mainNavArea
	end
end

function M:Refresh()
	if self.actived then
		if not self:CheckViewCreated() then
			self:CreateView()
		end

		self.view:TryActive()
	elseif self:CheckViewCreated() then
		self.view:TryDeactive()
	end
end

function M:CheckLoaded()
	return self.filterPanel ~= nil
end

function M:CheckViewCreated()
	return self.view ~= nil
end

function M:CreateView()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.view = BigMapComp_FilterMenu_PCView.new(self.bigMap._filterCore, self.bigMap)
	else
		self.view = BigMapComp_FilterMenu_MobileView.new(self.bigMap._filterCore, self.bigMap)
	end
end

function M:OnAttachElement(id, info)
	if self.view and self.view.OnAttachElement then
		self.view:OnAttachElement(id, info)
	end
end

function M:OnNavAreaChange(oldArea, newArea)
	if self.view and self.view.OnNavAreaChange then
		self.view:OnNavAreaChange(oldArea, newArea)
	end
end

function M:OnFilterSpiritChange(tid)
	if self.view and self.view.OnFilterSpiritChange then
		self.view:OnFilterSpiritChange(tid)
	end
end
