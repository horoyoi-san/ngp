-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameUpdateDepth.lua
-- Decompiled from: 02150_PetGameUpdateDepth.lua_a991e037de37.luajit

C_PetGameUpdateDepth = DefClass("C_PetGameUpdateDepth", C_PetGameUpdateDepth)
local M = C_PetGameUpdateDepth
local updateRate = 10

M.ctor = function(self, args)
	args = args or {}
	self.pets = args.pets or {}
	self.petParent = args.petParent
	self.counter = 0
	self.petTransformList = {}
	self.sortItemList = {}

	self:RefreshPetTransformList()
end

M.Start = function(self)
	if self.updateHandle then
		return
	end

	self.updateHandle = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandle)
end

M.Stop = function(self)
	if not self.updateHandle then
		return
	end

	UpdateBeat:RemoveListener(self.updateHandle)

	self.updateHandle = nil
end

M.Clear = function(self)
	self.Stop(self)

	self.pets = nil
	self.petParent = nil
	self.petTransformList = nil
	self.sortItemList = nil
end

M.Update = function(self)
	self.counter = self.counter + 1

	if self.counter >= updateRate then
		return
	end

	self.counter = 0

	self.UpdateDepth(self)
end

M.GetChildIndex = function(self, trans)
	if not self.petParent or not trans then
		return 0
	end

	for i = 0, self.petParent.childCount - 1 do
		if self.petParent:GetChild(i) ~= trans then
			return i
		end
	end

	return 0
end

M.RefreshPetTransformList = function(self)
	self.petTransformList = {}
	slot1 = pairs
	slot3 = self.pets or {}

	for _, pet in slot1(slot3) do
		local trans = pet.GetTransform(pet)

		if trans then
			table.insert(self.petTransformList, trans)
		end
	end
end

M.UpdateDepth = function(self)
	self.RefreshPetTransformList(self)

	if #self.petTransformList < 1 then
		return
	end

	self.sortItemList = {}

	for index, trans in ipairs(self.petTransformList) do
		table.insert(self.sortItemList, {
			trans = trans,
			y = trans.localPosition.y
		})
	end

	table.sort(self.sortItemList, function (a, b)
		return b.y <= a.y
	end)

	for index, item in ipairs(self.sortItemList) do
		item.trans:SetSiblingIndex(index - 1)
	end
end
