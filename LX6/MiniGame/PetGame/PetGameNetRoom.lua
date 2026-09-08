-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameNetRoom.lua
-- Decompiled from: 02144_PetGameNetRoom.lua_f1d27d33cbc4.luajit

C_PetGameNetRoom = DefClass("C_PetGameNetRoom", C_PetGameNetRoom, C_PetGameRoom)
local PetGameNetRoom = C_PetGameNetRoom

PetGameNetRoom.ctor = function(self, args)
	self.ownerRoom = args.ownerRoom
	self.roomType = args.roomId
	self.cleared = false
	self.active = true
end

PetGameNetRoom.SetVisible = function(self, visible)
	self.active = visible

	self.SetFurnitureVisible(self, visible)
end

PetGameNetRoom.Clear = function(self)
	self.cleared = true

	PetGameNetRoom.base.Clear(self)

	if self.ownerRoom and self.ownerRoom.SetFurnitureVisible then
		self.ownerRoom:SetFurnitureVisible(true)
	end

	self.ownerRoom = nil
end

return PetGameNetRoom
