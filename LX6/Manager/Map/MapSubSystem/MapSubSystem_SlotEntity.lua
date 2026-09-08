-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_SlotEntity.lua
-- Decompiled from: 02328_MapSubSystem_SlotEntity.lua_348cd57b2b41.luajit

MapSubSystem_SlotEntity = DefClass("MapSubSystem_SlotEntity", MapSubSystem_SlotEntity, MapSubSystemBase)
local M = MapSubSystem_SlotEntity

M.OnInit = function(self)
	self.slotEntityInfo = {}
	self.eventHandlers = {
		[gEventConstants.MAP_LUA_SLOT_ADD] = function (eventId, entityId)
			self:AddItem(entityId)
		end,
		[gEventConstants.MAP_LUA_SLOT_REMOVE] = function (eventId, entityId)
			self:RemoveItem(entityId)
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.AddItem = function(self, entityId)
	local data = gGadgetManager.miniMapList[entityId]

	if data and not gCS.LuaUtils.IsNull(data.tran) and not data.tran:IsDestroyed() then
		local element = nil

		if not self.slotEntityInfo[entityId] then
			element = MapElement.CreateLegacy(EMapElementType.SlotEntity, ulong.tostring(entityId), EMapSubSystemType.SlotEntity, EMapViewMask.MiniMap + EMapViewMask.HudGps, data.raid, 0)

			element.SetVisible(element, true)

			self.slotEntityInfo[entityId] = element
		else
			element = self.slotEntityInfo[entityId]
		end

		element.mData.sIconId = tonumber(data.icon)

		element.SetPosition(element, data.tran.position)
	end
end

M.RemoveItem = function(self, entityId)
	if self.slotEntityInfo[entityId] then
		self.slotEntityInfo[entityId]:Dispose()

		self.slotEntityInfo[entityId] = nil
	end
end

return M
