MapSubSystem_SlotEntity = DefClass("MapSubSystem_SlotEntity", MapSubSystem_SlotEntity, MapSubSystemBase)
local M = MapSubSystem_SlotEntity

function M:OnInit()
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

function M:AddItem(entityId)
	local data = gGadgetManager.miniMapList[entityId]

	if data and not gCS.LuaUtils.IsNull(data.tran) and not data.tran:IsDestroyed() then
		local element = nil

		if not self.slotEntityInfo[entityId] then
			element = MapElement.CreateLegacy(EMapElementType.SlotEntity, ulong.tostring(entityId), EMapSubSystemType.SlotEntity, EMapViewMask.MiniMap + EMapViewMask.HudGps, data.raid, 0)

			element:SetVisible(true)

			self.slotEntityInfo[entityId] = element
		else
			element = self.slotEntityInfo[entityId]
		end

		element.mData.sIconId = tonumber(data.icon)

		element:SetPosition(data.tran.position)
	end
end

function M:RemoveItem(entityId)
	if self.slotEntityInfo[entityId] then
		self.slotEntityInfo[entityId]:Dispose()

		self.slotEntityInfo[entityId] = nil
	end
end

return M
