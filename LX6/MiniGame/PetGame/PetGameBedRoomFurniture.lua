-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameBedRoomFurniture.lua
-- Decompiled from: 02140_PetGameBedRoomFurniture.lua_ae00428918eb.luajit

C_PetGameBedRoomFurniture = DefClass("C_PetGameBedRoomFurniture", C_PetGameBedRoomFurniture, C_PetGameFurniture)
local PetGameBedRoomFurniture = C_PetGameBedRoomFurniture

PetGameBedRoomFurniture.BindNodes = function(self, furnitureGo)
	PetGameBedRoomFurniture.base.BindNodes(self, furnitureGo)

	self.dayNode = furnitureGo.transform:Find("day")
	self.nightNode = furnitureGo.transform:Find("night")
	self.rainningNode = furnitureGo.transform:Find("rainning")

	self:ApplyDayNightState()
	self:ApplyRainingState()
	self:BindCalendarTexts()
end

PetGameBedRoomFurniture.BindCalendarTexts = function(self)
	self.calendarTexts = {}
	local stateNodes = {
		self.dayNode,
		self.nightNode,
		self.rainningNode
	}

	for _, stateNode in pairs(stateNodes) do
		local calendarTrans = stateNode and stateNode:Find("body/calendar")

		if calendarTrans then
			local calendarText = calendarTrans.gameObject:GetComponentInChildren(typeof(TMPro.TMP_Text), true)

			if calendarText then
				table.insert(self.calendarTexts, calendarText)
			end
		end
	end

	if #self.calendarTexts <= 0 then
		self:RefreshCalendarDate()

		self.calendarEventHandle = {
			[gEventConstants.MINIGAME_PET_GAME_DATE_CHANGED] = function ()
				self:RefreshCalendarDate()
			end
		}

		gMessageManager:RegisterEventHandlers(self.calendarEventHandle)
	end
end

PetGameBedRoomFurniture.RefreshCalendarDate = function(self)
	if not self.calendarTexts or #self.calendarTexts ~= 0 or not gPetGameTime then
		return
	end

	local date = os.date("*t", math.floor(gPetGameTime:Now()))
	local dayKey = string.format("%04d%02d%02d", date.year, date.month, date.day)

	if self.calendarDayKey ~= dayKey then
		return
	end

	self.calendarDayKey = dayKey
	local dayText = tostring(date.day)

	for _, calendarText in ipairs(self.calendarTexts) do
		if calendarText then
			gCS.GuiUtils.BindStringToTMP_Text(calendarText, dayText)
		end
	end
end

PetGameBedRoomFurniture.SetDayNightState = function(self, isDay)
	self.isDay = isDay ~= true

	self:ApplyDayNightState()
end

PetGameBedRoomFurniture.ApplyDayNightState = function(self)
	if self.isDay ~= nil then
		return
	end

	if self.dayNode then
		self.dayNode.gameObject:SetActive(self.isDay)
	end

	if self.nightNode then
		self.nightNode.gameObject:SetActive(not self.isDay)
	end
end

PetGameBedRoomFurniture.SetRainingState = function(self, isRaining)
	self.isRaining = isRaining ~= true

	self:ApplyRainingState()
end

PetGameBedRoomFurniture.ApplyRainingState = function(self)
	if self.isRaining ~= nil then
		return
	end

	if self.rainningNode then
		self.rainningNode.gameObject:SetActive(self.isRaining)
	end
end

PetGameBedRoomFurniture.Clear = function(self)
	if self.calendarEventHandle then
		gMessageManager:UnregisterEventHandlers(self.calendarEventHandle)

		self.calendarEventHandle = nil
	end

	PetGameBedRoomFurniture.base.Clear(self)

	self.dayNode = nil
	self.nightNode = nil
	self.rainningNode = nil
	self.calendarTexts = nil
	self.calendarDayKey = nil
end

return PetGameBedRoomFurniture
