-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\PetGame\PetGameFurniture.lua
-- Decompiled from: 02139_PetGameFurniture.lua_f578c3eec61e.luajit

local PetGameEnum = require("LX6/MiniGame/PetGame/PetGameEnum")
local FurniturePoint = PetGameEnum.FurniturePoint
C_PetGameFurniture = DefClass("C_PetGameFurniture", C_PetGameFurniture)
local PetGameFurniture = C_PetGameFurniture

PetGameFurniture.ctor = function(self, args)
	self.slotId = args.slotId
	self.ownerRoom = args.ownerRoom
	self.parent = args.parent
	self.position = args.position
	self.conf = args.conf
	self.weight = self.conf.interactionWeight or 0

	self:Load()
end

PetGameFurniture.BindNodes = function(self, furnitureGo)
	if not furnitureGo then
		return
	end

	self.petFollow = furnitureGo.transform:Find(FurniturePoint.petFollow)
	self.finish = furnitureGo.transform:Find(FurniturePoint.finish)
	self.selected = furnitureGo.transform:Find(FurniturePoint.selected)

	self:SetSelected(false)
end

PetGameFurniture.Load = function(self)
	local prefabPath = self.conf.prefab
	local parent = self.parent
	slot3 = gCoroutineManager

	slot3:StartCoroutine(function ()
		local loadOp = gResourceManager:LoadAssetAsync(prefabPath, typeof(UnityEngine.GameObject))

		coroutine.yield(loadOp)

		if loadOp.asset then
			local furnitureGo = UnityEngine.GameObject.Instantiate(loadOp.asset, parent)

			if not furnitureGo then
				error("Failed to instantiate pet prefab: " .. prefabPath)

				return
			end

			furnitureGo.transform.position = self.position
			furnitureGo.transform.localRotation = Quaternion.identity
			self.furnitureGo = furnitureGo

			self:BindNodes(furnitureGo)
		else
			error("Failed to load Furniture prefab: " .. prefabPath)
		end
	end)
end

PetGameFurniture.SetVisible = function(self, visible, roomActive)
	if self.furnitureGo then
		self.furnitureGo:SetActive(visible and roomActive)
	end
end

PetGameFurniture.SetSelected = function(self, selected)
	self.isSelected = selected

	if self.selected then
		self.selected.gameObject:SetActive(selected)
	end
end

PetGameFurniture.IsSelected = function(self)
	return self.isSelected ~= true
end

PetGameFurniture.SetStageMode = function(self, stageMode)
	if not self.furnitureGo then
		return
	end

	local active = true

	if stageMode then
		active = self.conf.showInStage
	end

	self.furnitureGo:SetActive(active)

	if active then
		local hideInStageNode = self.furnitureGo.transform:Find(FurniturePoint.hideInStage)

		if hideInStageNode then
			hideInStageNode.gameObject:SetActive(not stageMode)
		end
	end
end

PetGameFurniture.Clear = function(self)
	if self.furnitureGo then
		UnityEngine.GameObject.Destroy(self.furnitureGo)
	end

	self.furnitureGo = nil
	self.petFollow = nil
	self.finish = nil
	self.selected = nil
	self.isSelected = false
end

PetGameFurniture.IsInteractive = function(self)
	if not self.conf or not self.furnitureGo then
		return false
	end

	return (self.conf.interactionWeight or 0) <= 0 and self.conf.interactionId >= 0
end

return PetGameFurniture
