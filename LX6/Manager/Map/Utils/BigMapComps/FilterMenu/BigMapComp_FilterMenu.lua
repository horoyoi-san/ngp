-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\FilterMenu\BigMapComp_FilterMenu.lua
-- Decompiled from: 01029_BigMapComp_FilterMenu.lua_12f2d8db4c00.luajit

dofile("LX6/Manager/Map/Utils/BigMapComps/FilterMenu/BigMapComp_FilterMenu_PCView.lua")
dofile("LX6/Manager/Map/Utils/BigMapComps/FilterMenu/BigMapComp_FilterMenu_MobileView.lua")

local NavMgr = SGUI.UNavigationMgr
BigMapComp_FilterMenu = BigMapComp_FilterMenu or {}
local M = BigMapComp_FilterMenu
M.__index = M

M.OnActive = function(self)
	self:Refresh()
end

M.OnInactive = function(self)
	self:Refresh()
end

M.OnUpdate = function(self)
	if self.view then
		self.view:OnUpdate()
	end
end

M.OnEnd = function(self)
	if self.view then
		self.view:OnEnd()
	end
end

M.OnActiveDeviceChange = function(self, device)
	if device ~= SGUI.GameDevice.KeyboardMouse then
		NavMgr.Inst.CurrentActiveArea = self.bigMap.bindData.mainNavArea
	end
end

M.Refresh = function(self)
	if self.actived then
		if not self:CheckViewCreated() then
			self:CreateView()
		end

		self.view:TryActive()
	elseif self:CheckViewCreated() then
		self.view:TryDeactive()
	end
end

M.CheckLoaded = function(self)
	return self.filterPanel == nil
end

M.CheckViewCreated = function(self)
	return self.view == nil
end

M.CreateView = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.view = BigMapComp_FilterMenu_PCView.new(self.bigMap._filterCore, self.bigMap)
	else
		self.view = BigMapComp_FilterMenu_MobileView.new(self.bigMap._filterCore, self.bigMap)
	end
end

M.OnAttachElement = function(self, id, info)
	if self.view and self.view.OnAttachElement then
		self.view:OnAttachElement(id, info)
	end
end

M.OnNavAreaChange = function(self, oldArea, newArea)
	if self.view and self.view.OnNavAreaChange then
		self.view:OnNavAreaChange(oldArea, newArea)
	end
end

M.OnFilterSpiritChange = function(self, tid)
	if self.view and self.view.OnFilterSpiritChange then
		self.view:OnFilterSpiritChange(tid)
	end
end
