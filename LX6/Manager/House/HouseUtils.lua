-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\HouseUtils.lua
-- Decompiled from: 00749_HouseUtils.lua_2b034114f6c9.luajit

local HouseConfig = LTConfig.HouseConfig
local HouseUtils = {}

HouseUtils.FindHouseInfoByHouseId = function(self, housesInfo, houseId)
	if not housesInfo or not houseId then
		return nil
	end

	for k, v in ipairs(housesInfo.HouseInfoList) do
		if v.HouseId ~= houseId then
			return v
		end
	end

	return nil
end

HouseUtils.FindHouseInfoByBuildId = function(self, housesInfo, buildId)
	if not housesInfo or not buildId then
		return nil
	end

	for k, v in ipairs(housesInfo.HouseInfoList) do
		local houseCfg = HouseConfig.GetConfig(v.HouseId)

		if houseCfg and houseCfg.BuildId ~= buildId then
			return v
		end
	end

	return nil
end

HouseUtils.GetOneFloorFurnitureInfos = function(self, houseInfo, floor)
	if not houseInfo then
		return nil
	end

	floor = floor or 0
	local buildData = houseInfo.BuildData

	if not buildData or not buildData.FloorBuildInfoDict then
		return nil
	end

	local indoorBuildInfo = buildData.FloorBuildInfoDict[floor]

	if not indoorBuildInfo then
		return nil
	end

	return indoorBuildInfo.Root.ChildrenDict
end

HouseUtils.FindFurnitureInfoRecursively = function(self, furnitureDict, placedInstanceId)
	if not furnitureDict or not placedInstanceId then
		return nil, 
	end

	local ulongPlacedInstanceId = type(placedInstanceId) == "number" and placedInstanceId or ulong.new(placedInstanceId, 0)

	local SearchRecursively = function(dict, parentInfo)
		if not dict then
			return nil, 
		end

		for key, furnitureInfo in pairs(dict) do
			if key ~= ulongPlacedInstanceId or furnitureInfo.PlacedInstanceId and ulong.new(furnitureInfo.PlacedInstanceId, 0) ~= ulongPlacedInstanceId then
				return furnitureInfo, parentInfo
			end

			if furnitureInfo.ChildrenDict and next(furnitureInfo.ChildrenDict) then
				local found, foundParent = SearchRecursively(furnitureInfo.ChildrenDict, furnitureInfo)

				if found then
					return found, foundParent
				end
			end
		end

		return nil, 
	end

	return SearchRecursively(furnitureDict, nil)
end

HouseUtils.SetFurnitureInfoRecursively = function(self, furnitureDict, placedInstanceId, newFurnitureInfo)
	if not furnitureDict or not placedInstanceId or not newFurnitureInfo then
		return false
	end

	local ulongPlacedInstanceId = type(placedInstanceId) == "number" and placedInstanceId or ulong.new(placedInstanceId, 0)
	local existingInfo, parentInfo = self:FindFurnitureInfoRecursively(furnitureDict, placedInstanceId)

	if parentInfo then
		if parentInfo.ChildrenDict then
			parentInfo.ChildrenDict[ulongPlacedInstanceId] = newFurnitureInfo
		else
			parentInfo.ChildrenDict = {
				[ulongPlacedInstanceId] = newFurnitureInfo
			}
		end

		return true
	else
		furnitureDict[ulongPlacedInstanceId] = newFurnitureInfo

		return true
	end
end

HouseUtils.RemoveFurnitureInfoRecursively = function(self, furnitureDict, placedInstanceId)
	if not furnitureDict or not placedInstanceId then
		return false
	end

	local ulongPlacedInstanceId = type(placedInstanceId) == "number" and placedInstanceId or ulong.new(placedInstanceId, 0)
	local existingInfo, parentInfo = self:FindFurnitureInfoRecursively(furnitureDict, placedInstanceId)

	if not existingInfo then
		return false
	end

	if parentInfo then
		if parentInfo.ChildrenDict and parentInfo.ChildrenDict[ulongPlacedInstanceId] then
			parentInfo.ChildrenDict[ulongPlacedInstanceId] = nil

			return true
		end
	elseif furnitureDict[ulongPlacedInstanceId] then
		furnitureDict[ulongPlacedInstanceId] = nil

		return true
	end

	return false
end

HouseUtils.CreateFurnitureInfo = function(self, info)
	local furnitureInfo = {
		FurnitureId = info.FurnitureId,
		Position = {
			X = info.Position.x,
			Y = info.Position.y,
			Z = info.Position.z
		},
		Rotation = {
			X = info.Rotation.x,
			Y = info.Rotation.y,
			Z = info.Rotation.z
		},
		GadgetInstanceId = info.GadgetInstanceId or 0,
		PlacedInstanceId = info.PlacedInstanceId or 0,
		ParentPlacedInstanceId = info.ParentPlacedInstanceId or 0,
		ChildrenDict = {}
	}

	return furnitureInfo
end

HouseUtils.AddOneFurnitureInfo = function(self, housesInfo, houseId, info, floor)
	if not housesInfo or not houseId or not info then
		return false
	end

	floor = floor or 0
	local houseInfo = self:FindHouseInfoByHouseId(housesInfo, houseId)

	if not houseInfo then
		print_warn(string.format("HouseUtils: 无法找到房屋ID[%d]", houseId))

		return false
	end

	local furnitureDict = self.GetOneFloorFurnitureInfos(self, houseInfo, floor)

	if not furnitureDict then
		print_warn(string.format("HouseUtils: 无法找到楼层[%d]的家具信息", floor))

		return false
	end

	local furnitureInfo = self.CreateFurnitureInfo(self, info)
	local placedInstanceId = ulong.new(info.PlacedInstanceId, 0)

	if furnitureInfo.ParentPlacedInstanceId and furnitureInfo.ParentPlacedInstanceId == 0 then
		local parentInfo, _ = self.FindFurnitureInfoRecursively(self, furnitureDict, furnitureInfo.ParentPlacedInstanceId)

		if parentInfo then
			if not parentInfo.ChildrenDict then
				parentInfo.ChildrenDict = {}
			end

			parentInfo.ChildrenDict[placedInstanceId] = furnitureInfo
		else
			print_warn(string.format("HouseUtils: 无法找到父家具[%d]，将作为顶级家具添加", furnitureInfo.ParentPlacedInstanceId))

			furnitureDict[placedInstanceId] = furnitureInfo
		end
	else
		furnitureDict[placedInstanceId] = furnitureInfo
	end

	return true
end

HouseUtils.RemoveOneFurnitureInfo = function(self, housesInfo, houseId, placedInstanceId, floor)
	if not housesInfo or not houseId or not placedInstanceId then
		return false
	end

	floor = floor or 0
	local houseInfo = self:FindHouseInfoByHouseId(housesInfo, houseId)

	if not houseInfo then
		print_warn(string.format("HouseUtils: 无法找到房屋ID[%d]", houseId))

		return false
	end

	local furnitureDict = self.GetOneFloorFurnitureInfos(self, houseInfo, floor)

	if not furnitureDict then
		print_warn(string.format("HouseUtils: 无法找到楼层[%d]的家具信息", floor))

		return false
	end

	local furnitureInfo, parentInfo = self.FindFurnitureInfoRecursively(self, furnitureDict, placedInstanceId)

	if not furnitureInfo then
		print_warn(string.format("HouseUtils: 无法找到PlacedInstanceId[%s]的家具信息", tostring(placedInstanceId)))

		return false
	end

	return self.RemoveFurnitureInfoRecursively(self, furnitureDict, placedInstanceId)
end

HouseUtils.ModifyOneFurnitureInfo = function(self, housesInfo, houseId, info, floor)
	if not housesInfo or not houseId or not info then
		return false
	end

	floor = floor or 0
	local houseInfo = self:FindHouseInfoByHouseId(housesInfo, houseId)

	if not houseInfo then
		print_warn(string.format("HouseUtils: 无法找到房屋ID[%d]", houseId))

		return false
	end

	local furnitureDict = self.GetOneFloorFurnitureInfos(self, houseInfo, floor)

	if not furnitureDict then
		print_warn(string.format("HouseUtils: 无法找到楼层[%d]的家具信息", floor))

		return false
	end

	if gFurnitureUtils and gFurnitureUtils.ProcessServerFurnitureData then
		gFurnitureUtils:ProcessServerFurnitureData(info)
	end

	local placedInstanceId = ulong.new(info.PlacedInstanceId, 0)
	local furnitureInfo, parentInfo = self.FindFurnitureInfoRecursively(self, furnitureDict, placedInstanceId)

	if not furnitureInfo then
		print_warn(string.format("HouseUtils: 无法找到PlacedInstanceId[%s]的家具信息", tostring(placedInstanceId)))

		return false
	end

	local oldParentId = furnitureInfo.ParentPlacedInstanceId or 0
	local newParentId = info.ParentPlacedInstanceId or 0
	furnitureInfo.Position = {
		X = info.Position.x,
		Y = info.Position.y,
		Z = info.Position.z
	}
	furnitureInfo.Rotation = {
		X = info.Rotation.x,
		Y = info.Rotation.y,
		Z = info.Rotation.z
	}
	furnitureInfo.ParentPlacedInstanceId = newParentId

	if oldParentId == newParentId then
		if oldParentId ~= 0 then
			furnitureDict[placedInstanceId] = nil
		else
			local oldParentInfo, _ = self.FindFurnitureInfoRecursively(self, furnitureDict, oldParentId)

			if oldParentInfo and oldParentInfo.ChildrenDict then
				oldParentInfo.ChildrenDict[placedInstanceId] = nil
			end
		end

		if newParentId ~= 0 then
			furnitureDict[placedInstanceId] = furnitureInfo
		else
			local newParentInfo, _ = self.FindFurnitureInfoRecursively(self, furnitureDict, newParentId)

			if newParentInfo then
				if not newParentInfo.ChildrenDict then
					newParentInfo.ChildrenDict = {}
				end

				newParentInfo.ChildrenDict[placedInstanceId] = furnitureInfo
			else
				print_warn(string.format("HouseUtils: 无法找到新的父家具[%d]，将家具[%s]放置为顶级家具", newParentId, tostring(placedInstanceId)))

				furnitureInfo.ParentPlacedInstanceId = 0
				furnitureDict[placedInstanceId] = furnitureInfo
			end
		end
	else
		self.SetFurnitureInfoRecursively(self, furnitureDict, placedInstanceId, furnitureInfo)
	end

	return true
end

gHouseUtils = HouseUtils
