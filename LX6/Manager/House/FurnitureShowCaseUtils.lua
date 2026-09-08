-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\FurnitureShowCaseUtils.lua
-- Decompiled from: 00734_FurnitureShowCaseUtils.lua_f86f44d078c8.luajit

local CSHouseFashionShowcase = LX6.GamePlay.House.HouseFashionShowcase
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local UnitFashionInfoModule = LX6.Units.Module.UnitFashionInfoModule
local UXVector3 = UX.Game.UXVector3
local FurnitureShowCaseUtils = {}

FurnitureShowCaseUtils._GetShowcaseCompByPlacedId = function(self, placedId, needCheckIsShowcase)
	if not placedId then
		return nil, 
	end

	local furnitureGo = gFurnitureUIDManager.uid2FurnitureGoDict[placedId]

	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return nil, 
	end

	if needCheckIsShowcase then
		local furnitureId = gFurnitureManager:TryGetFurnitureIdFromGo(furnitureGo, placedId)

		if not furnitureId or not gHouseManager:IsFashionShowcase(furnitureId) then
			return nil, 
		end
	end

	local comp = nil
	local gadgetId = gHouseGadgetManager:GetGadgetInstanceId(placedId)
	local gadgetGo = gadgetId and gHouseGadgetManager.gadgetGoDict[gadgetId]

	if gadgetGo and not gCS.LuaUtils.IsNull(gadgetGo) then
		comp = gadgetGo.GetComponentInChildren(gadgetGo, typeof(CSHouseFashionShowcase), true)
	end

	if not comp or gCS.LuaUtils.IsNull(comp) then
		comp = furnitureGo.GetComponentInChildren(furnitureGo, typeof(CSHouseFashionShowcase), true)
	end

	if not comp or gCS.LuaUtils.IsNull(comp) then
		return nil, 
	end

	return comp, comp.showcaseInfoList
end

FurnitureShowCaseUtils.ReparentUnits = function(self, placedId, parentGo, active)
	local _, list = self._GetShowcaseCompByPlacedId(self, placedId, false)

	self._ReparentUnitList(self, list, parentGo, active)
end

FurnitureShowCaseUtils._ReparentUnitList = function(self, list, parentGo, active)
	if not list then
		return
	end

	local parentTransform = nil

	if parentGo and not gCS.LuaUtils.IsNull(parentGo) then
		parentTransform = parentGo.transform
	end

	for i = 0, list.Count - 1 do
		local info = list[i]
		local obj = info and info.unit and info.unit.PlayerObj

		if obj and not gCS.LuaUtils.IsNull(obj) then
			if active == nil then
				obj.gameObject:SetActive(active)
			end

			obj.SetParent(obj, parentTransform, true)
		end
	end
end

FurnitureShowCaseUtils.DrivePreviewUnitFollow = function(self, previewGo)
	if not previewGo or gCS.LuaUtils.IsNull(previewGo) then
		return
	end

	local comp = previewGo.GetComponentInChildren(previewGo, typeof(CSHouseFashionShowcase))

	if not comp or gCS.LuaUtils.IsNull(comp) then
		local furnitureId = gFurnitureManager.followingFurnitureId

		if not furnitureId or not gHouseManager:IsFashionShowcase(furnitureId) then
			return
		end

		comp = previewGo.AddComponent(previewGo, typeof(CSHouseFashionShowcase))

		if not comp or gCS.LuaUtils.IsNull(comp) then
			return
		end

		local cfg = HouseFurnitureConfig.GetConfig(furnitureId)
		local defaultModels = cfg and cfg.FashionShowcaseDefaultModels

		if defaultModels and #defaultModels <= 0 then
			for i = 1, #defaultModels do
				comp.AddDefaultShowcaseInfo(comp, defaultModels[i])
			end
		else
			comp.AddDefaultShowcaseInfo(comp, 2)
		end
	end

	comp.Initialize(comp)
	self._ReparentUnitList(self, comp.showcaseInfoList, previewGo, nil)
end

FurnitureShowCaseUtils._ResolveAnchor = function(self, placedId)
	local fm = gFurnitureManager
	local modelGo, hostGo = nil

	if fm.isEditingExisting and fm.followingFurniture and not gCS.LuaUtils.IsNull(fm.followingFurniture) then
		local origGo = gFurnitureUIDManager.uid2FurnitureGoDict[placedId]

		if origGo and origGo ~= fm.followingFurniture then
			hostGo = fm.followingFurniture
			modelGo = fm.followingFurniture
		end
	end

	if not modelGo then
		if gHouseGadgetManager.isEditMode then
			modelGo = gFurnitureUIDManager.uid2FurnitureGoDict[placedId]
			hostGo = gHouseGadgetManager.luaSlotReplaceGoDict[placedId] or modelGo
		else
			local gadgetId = gHouseGadgetManager:GetGadgetInstanceId(placedId)
			modelGo = gadgetId and gHouseGadgetManager.gadgetGoDict[gadgetId]
			hostGo = modelGo
		end
	end

	local anchorList = nil

	if modelGo and not gCS.LuaUtils.IsNull(modelGo) then
		local comp = modelGo.GetComponentInChildren(modelGo, typeof(CSHouseFashionShowcase), true)

		if comp and not gCS.LuaUtils.IsNull(comp) then
			anchorList = comp.showcaseInfoList
		end
	end

	return hostGo, anchorList
end

FurnitureShowCaseUtils._AnchorUnitsTo = function(self, units, hostGo, anchorList)
	if not units then
		return
	end

	local hostTr = hostGo and not gCS.LuaUtils.IsNull(hostGo) and hostGo.transform or nil

	for i = 0, units.Count - 1 do
		local info = units[i]
		local obj = info and info.unit and info.unit.PlayerObj

		if obj and not gCS.LuaUtils.IsNull(obj) then
			obj.gameObject:SetActive(true)

			local pinfo = anchorList and i >= anchorList.Count and anchorList[i]
			local point = pinfo and pinfo.transfrom

			if point and not gCS.LuaUtils.IsNull(point) then
				obj.position = point.position
				obj.rotation = point.rotation
			elseif hostTr then
				obj.position = hostTr.position
			end

			obj.SetParent(obj, hostTr, true)
		end
	end
end

FurnitureShowCaseUtils.ResolveUnitParent = function(self, placedId)
	local _, units = self._GetShowcaseCompByPlacedId(self, placedId, false)
	local host, anchors = self._ResolveAnchor(self, placedId)

	self._AnchorUnitsTo(self, units, host, anchors)
end

FurnitureShowCaseUtils.RescueUnitsToFurniture = function(self, placedId)
	local _, units = self._GetShowcaseCompByPlacedId(self, placedId, false)

	if not units then
		return
	end

	local furnitureGo = gFurnitureUIDManager.uid2FurnitureGoDict[placedId]

	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	local comp = furnitureGo:GetComponentInChildren(typeof(CSHouseFashionShowcase), true)
	local anchors = comp and not gCS.LuaUtils.IsNull(comp) and comp.showcaseInfoList or nil

	self:_AnchorUnitsTo(units, gHouseGadgetManager.luaSlotReplaceGoDict[placedId] or furnitureGo, anchors)
end

FurnitureShowCaseUtils.OnEditPreviewStart = function(self, previewGo, originalUID)
	if previewGo and not gCS.LuaUtils.IsNull(previewGo) then
		local pc = previewGo.GetComponentInChildren(previewGo, typeof(CSHouseFashionShowcase))

		if pc and not gCS.LuaUtils.IsNull(pc) then
			pc.MarkCreated(pc)
		end
	end

	self.ResolveUnitParent(self, originalUID)
end

FurnitureShowCaseUtils._ExtractFashionIds = function(self, fashionData)
	local wearList = fashionData and fashionData.WearFashionInfoList

	if not wearList then
		return nil
	end

	local ids = nil

	for i = 1, #wearList do
		local w = wearList[i]

		if w and w.FashionId then
			ids = ids or {}
			ids[#ids + 1] = w.FashionId
		end
	end

	return ids
end

FurnitureShowCaseUtils._ExtractFashionEditList = function(self, fashionData)
	local editList = fashionData and fashionData.WearFashionEditInfoList

	if not editList then
		return nil
	end

	local result = nil

	for i = 1, #editList do
		local e = editList[i]

		if e then
			result = result or {}
			local rot = e.Rotation
			local off = e.Offset
			result[#result + 1] = {
				FashionId = e.FashionId,
				Scale = e.Scale,
				Rotation = rot and UXVector3.New(rot.X, rot.Y, rot.Z) or nil,
				Offset = off and UXVector3.New(off.X, off.Y, off.Z) or nil
			}
		end
	end

	return result
end

FurnitureShowCaseUtils._FeedShowcaseModelData = function(self, info, modelData)
	if not info then
		return
	end

	local showcaseId = modelData and modelData.ShowcaseId or 0

	if showcaseId ~= 0 then
		info.SetServerModelData(info, 0, nil, , 0, 0)

		return
	end

	local fashionData = modelData.FashionData
	local ids = self:_ExtractFashionIds(fashionData)
	local wearList = ids and UnitFashionInfoModule.GetWearFashionInfoListByLuaTable(ids) or nil
	local editLua = self:_ExtractFashionEditList(fashionData)
	local editList = editLua and UnitFashionInfoModule.GetWearFashionEditInfoListByLuaTable(editLua) or nil
	local hiddenParts = fashionData and fashionData.HiddenParts or 0
	local editedHiddenParts = fashionData and fashionData.EditedHiddenParts or 0

	info:SetServerModelData(showcaseId, wearList, editList, hiddenParts, editedHiddenParts)
end

FurnitureShowCaseUtils._FeedShowcaseData = function(self, placedId, comp)
	local list = comp.showcaseInfoList

	if not list then
		return
	end

	local showcaseData = gHouseManager:GetShowcaseData(placedId)
	local models = showcaseData and showcaseData.Models

	for i = 0, list.Count - 1 do
		local info = list[i]

		if info then
			self:_FeedShowcaseModelData(info, models and models[i])
		end
	end
end

FurnitureShowCaseUtils.TryCreateShowcaseUnits = function(self, placedId)
	local comp = self._GetShowcaseCompByPlacedId(self, placedId, true)

	if not comp then
		return
	end

	self._FeedShowcaseData(self, placedId, comp)

	if not comp.Initialize(comp) then
		local list = comp.showcaseInfoList

		if list then
			for i = 0, list.Count - 1 do
				local info = list[i]

				if info then
					info.CreateUnit(info)
				end
			end
		end
	end
end

FurnitureShowCaseUtils.DestroyFurnitureSideUnits = function(self, placedId)
	local furnitureGo = gFurnitureUIDManager.uid2FurnitureGoDict[placedId]

	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	local comp = furnitureGo.GetComponentInChildren(furnitureGo, typeof(CSHouseFashionShowcase))

	if not comp or gCS.LuaUtils.IsNull(comp) then
		return
	end

	local list = comp.showcaseInfoList

	if not list then
		return
	end

	for i = 0, list.Count - 1 do
		if list[i] then
			list[i]:DestroyUnit()
		end
	end
end

FurnitureShowCaseUtils.OnFurnitureRegistered = function(self, placedId, furnitureGo, furnitureId, isEditMode)
	if not gHouseManager:IsFashionShowcase(furnitureId) then
		return
	end

	local comp = furnitureGo.GetComponentInChildren(furnitureGo, typeof(CSHouseFashionShowcase))

	if not comp or gCS.LuaUtils.IsNull(comp) then
		return
	end

	if isEditMode and not gHouseGadgetManager:GetGadgetInstanceId(placedId) then
		comp.Initialize(comp)
	else
		local list = comp.showcaseInfoList

		if list then
			for i = 0, list.Count - 1 do
				local info = list[i]

				if info and info.unit then
					info.DestroyUnit(info)
				end
			end
		end

		comp.MarkCreated(comp)
		self.TryCreateShowcaseUnits(self, placedId)
	end

	self.ResolveUnitParent(self, placedId)
end

FurnitureShowCaseUtils.RecreateShowcaseUnit = function(self, placedId, modelIndex)
	if modelIndex ~= nil then
		return
	end

	local _, list = self._GetShowcaseCompByPlacedId(self, placedId, false)

	if not list or modelIndex <= 0 or list.Count < modelIndex then
		return
	end

	local info = list[modelIndex]

	if not info then
		return
	end

	self:_FeedShowcaseModelData(info, gHouseManager:GetShowcaseModelData(placedId, modelIndex))
	info:CreateUnit()
	self:ResolveUnitParent(placedId)
end

FurnitureShowCaseUtils.OnGadgetGoReady = function(self, gadgetId)
	if not gadgetId then
		return
	end

	for placedId, gid in pairs(gHouseGadgetManager.placedId2GadgetIdMap) do
		if gid ~= gadgetId then
			self.DestroyFurnitureSideUnits(self, placedId)
			self.TryCreateShowcaseUnits(self, placedId)
			self.ResolveUnitParent(self, placedId)

			return
		end
	end
end

FurnitureShowCaseUtils.GetShowcaseCompByPlacedId = function(self, placedId)
	return self._GetShowcaseCompByPlacedId(self, placedId, true)
end

gFurnitureShowCaseUtils = FurnitureShowCaseUtils
