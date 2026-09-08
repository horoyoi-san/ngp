-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\FurnitureMaterialUtils.lua
-- Decompiled from: 00736_FurnitureMaterialUtils.lua_7111b77cba78.luajit

local FurnitureMaterialUtils = {}
local HouseConfig = LTConfig.HouseConfig

FurnitureMaterialUtils.CreateMaterialInstances = function(self, furnitureGo, baseMeshGo, gadgetMeshGo, materialState)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	materialState.furnitureMaterials = {}
	materialState.baseMeshMaterials = {}
	materialState.gadgetMeshMaterials = {}
	materialState.defaultColors = {}
	local renderers = furnitureGo.GetComponentsInChildren(furnitureGo, typeof(UnityEngine.Renderer))

	if renderers then
		for i = 0, renderers.Length - 1 do
			local renderer = renderers[i]

			if renderer and renderer.material then
				local originalMaterial = renderer.material
				local materialInstance = UnityEngine.Object.Instantiate(originalMaterial)
				renderer.material = materialInstance

				table.insert(materialState.furnitureMaterials, materialInstance)

				if materialInstance.HasProperty(materialInstance, "_Color") then
					local defaultColor = materialInstance.GetColor(materialInstance, "_Color")
					materialState.defaultColors["_Color_" .. i] = defaultColor
				end
			end
		end
	end

	if baseMeshGo and not gCS.LuaUtils.IsNull(baseMeshGo) then
		local baseMeshRenderer = baseMeshGo.GetComponent(baseMeshGo, typeof(UnityEngine.Renderer))

		if baseMeshRenderer and baseMeshRenderer.material then
			local originalBaseMaterial = baseMeshRenderer.material
			local baseMaterialInstance = UnityEngine.Object.Instantiate(originalBaseMaterial)
			baseMeshRenderer.material = baseMaterialInstance

			table.insert(materialState.baseMeshMaterials, baseMaterialInstance)

			if baseMaterialInstance.HasProperty(baseMaterialInstance, "_Color") then
				local baseDefaultColor = baseMaterialInstance.GetColor(baseMaterialInstance, "_Color")
				materialState.defaultColors._BaseMesh_Color = baseDefaultColor
			end
		end
	end

	if gadgetMeshGo and not gCS.LuaUtils.IsNull(gadgetMeshGo) then
		local gadgetMeshRenderer = gadgetMeshGo.GetComponent(gadgetMeshGo, typeof(UnityEngine.Renderer))

		if gadgetMeshRenderer and gadgetMeshRenderer.material then
			local originalGadgetMaterial = gadgetMeshRenderer.material
			local gadgetMaterialInstance = UnityEngine.Object.Instantiate(originalGadgetMaterial)
			gadgetMeshRenderer.material = gadgetMaterialInstance

			if not materialState.gadgetMeshMaterials then
				materialState.gadgetMeshMaterials = {}
			end

			table.insert(materialState.gadgetMeshMaterials, gadgetMaterialInstance)

			if gadgetMaterialInstance.HasProperty(gadgetMaterialInstance, "_Color") then
				local gadgetDefaultColor = gadgetMaterialInstance.GetColor(gadgetMaterialInstance, "_Color")
				materialState.defaultColors._GadgetMesh_Color = gadgetDefaultColor
			end
		end
	end
end

FurnitureMaterialUtils.SetFurnitureColor = function(self, furnitureGo, isColliding, forceRed, baseMeshGo, gadgetMeshGo, lastCanPlaceState)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return nil
	end

	local rightColorArray = HouseConfig.BaseMeshRightColor
	local errorColorArray = HouseConfig.BaseMeshErrorColor
	local rightColor = Color.New(rightColorArray[1], rightColorArray[2], rightColorArray[3], rightColorArray[4])
	local errorColor = Color.New(errorColorArray[1], errorColorArray[2], errorColorArray[3], errorColorArray[4])
	local canPlace, targetColor = nil

	if forceRed then
		canPlace = false
		targetColor = errorColor
	else
		canPlace = not isColliding
		targetColor = canPlace and rightColor or errorColor
	end

	if baseMeshGo and not gCS.LuaUtils.IsNull(baseMeshGo) then
		local baseMeshRenderers = baseMeshGo.GetComponentsInChildren(baseMeshGo, typeof(UnityEngine.Renderer))

		if baseMeshRenderers then
			for i = 0, baseMeshRenderers.Length - 1 do
				local baseMeshRenderer = baseMeshRenderers[i]

				if baseMeshRenderer and baseMeshRenderer.material then
					local baseMaterial = baseMeshRenderer.material

					if baseMaterial.HasProperty(baseMaterial, "_EmissionColor") then
						local emissionColor = targetColor

						baseMaterial.SetColor(baseMaterial, "_EmissionColor", emissionColor)
					end
				end
			end
		end
	end

	if gadgetMeshGo and not gCS.LuaUtils.IsNull(gadgetMeshGo) then
		local gadgetMeshRenderer = gadgetMeshGo.GetComponent(gadgetMeshGo, typeof(UnityEngine.Renderer))

		if gadgetMeshRenderer and gadgetMeshRenderer.material then
			local gadgetMaterial = gadgetMeshRenderer.material

			if gadgetMaterial.HasProperty(gadgetMaterial, "_EmissionColor") then
				local emissionColor = targetColor

				gadgetMaterial.SetColor(gadgetMaterial, "_EmissionColor", emissionColor)
			end
		end
	end

	if lastCanPlaceState ~= nil then
		return canPlace
	end

	local stateChanged = lastCanPlaceState == canPlace

	if stateChanged then
		return canPlace
	end

	return nil
end

FurnitureMaterialUtils.RestoreMaterialColors = function(self, furnitureGo, baseMeshGo, gadgetMeshGo, defaultColors)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	local renderers = furnitureGo.GetComponentsInChildren(furnitureGo, typeof(UnityEngine.Renderer))

	if renderers then
		for i = 0, renderers.Length - 1 do
			local renderer = renderers[i]

			if renderer and renderer.material then
				local material = renderer.material
				local colorKey = "_Color_" .. i

				if defaultColors[colorKey] and material.HasProperty(material, "_Color") then
					material.SetColor(material, "_Color", defaultColors[colorKey])
				end

				if material.HasProperty(material, "_EmissionColor") then
					material.SetColor(material, "_EmissionColor", Color.black)
				end
			end
		end
	end

	if baseMeshGo and not gCS.LuaUtils.IsNull(baseMeshGo) then
		local baseMeshRenderer = baseMeshGo.GetComponent(baseMeshGo, typeof(UnityEngine.Renderer))

		if baseMeshRenderer and baseMeshRenderer.material then
			local baseMaterial = baseMeshRenderer.material

			if defaultColors._BaseMesh_Color and baseMaterial.HasProperty(baseMaterial, "_Color") then
				baseMaterial.SetColor(baseMaterial, "_Color", defaultColors._BaseMesh_Color)
			end

			if baseMaterial.HasProperty(baseMaterial, "_EmissionColor") then
				baseMaterial.SetColor(baseMaterial, "_EmissionColor", Color.black)
			end
		end
	end

	if gadgetMeshGo and not gCS.LuaUtils.IsNull(gadgetMeshGo) then
		local gadgetMeshRenderer = gadgetMeshGo.GetComponent(gadgetMeshGo, typeof(UnityEngine.Renderer))

		if gadgetMeshRenderer and gadgetMeshRenderer.material then
			local gadgetMaterial = gadgetMeshRenderer.material

			if defaultColors._GadgetMesh_Color and gadgetMaterial.HasProperty(gadgetMaterial, "_Color") then
				gadgetMaterial.SetColor(gadgetMaterial, "_Color", defaultColors._GadgetMesh_Color)
			end

			if gadgetMaterial.HasProperty(gadgetMaterial, "_EmissionColor") then
				gadgetMaterial.SetColor(gadgetMaterial, "_EmissionColor", Color.black)
			end
		end
	end
end

gFurnitureMaterialUtils = FurnitureMaterialUtils
