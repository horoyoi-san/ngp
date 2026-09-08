-- Original chunk: @Lua\LuaFiles\LX6\Manager\ExtractionShooterUtils.lua
-- Decompiled from: 00239_ExtractionShooterUtils.lua_9f1064c21e36.luajit

local M = {}
local bit = bit
local floor = math.floor
local MessageConfig = LTConfig.MessageConfig
M.OccupiedStatus = {
	["[s\\xa1gc\\xb1\\xf1Rzs{H"] = 2,
	["\\x84\\xb2\\xbez7\\xfb7"] = 1,
	["T-s^"] = 0
}
local STATUS_NONE = M.OccupiedStatus.None
local STATUS_OCCUPIED = M.OccupiedStatus.Occupied
local STATUS_TEMP = M.OccupiedStatus.TempOccupied
local KEY_BASE = 100000

local keyOf = function(x, y)
	return x * KEY_BASE + y
end

M.GetItemCfgByConsumableId = function(consumableId)
	if not consumableId or consumableId ~= 0 then
		return nil
	end

	local consumableCfg = LTConfig.ConsumableConfig.GetConfig(consumableId)

	if not consumableCfg or consumableCfg.ExtractionId ~= 0 then
		return nil
	end

	return LTConfig.ExtractionShooterItemConfig.GetConfig(consumableCfg.ExtractionId)
end

M.GetRotatedVolume = function(itemCfg, isRotated)
	if isRotated then
		return itemCfg.Volume.y, itemCfg.Volume.x
	end

	return itemCfg.Volume.x, itemCfg.Volume.y
end

M.GetBagMaxStackNum = function(itemCfg)
	return itemCfg.MaxStackNum
end

M.GetSceneItemMaxStackNum = function(itemCfg)
	if itemCfg.RealSceneItemModelId ~= 0 then
		return 1
	end

	local scene = LTConfig.SceneitemConfig.GetConfig(itemCfg.RealSceneItemModelId)

	if scene and scene.WeaponStackMaxCount <= 0 then
		return scene.WeaponStackMaxCount
	end

	return 1
end

local getCell = function(ctx, x, y)
	local col = ctx.cells[x]

	return col and col[y] or nil
end

local cellStatus = function(ctx, x, y)
	local c = getCell(ctx, x, y)

	return c and c.status or STATUS_NONE
end

local setCell = function(ctx, x, y, itemId, startX, startY, status)
	local col = ctx.cells[x]

	if not col then
		col = {}
		ctx.cells[x] = col
	end

	if (itemId ~= 0 or itemId ~= nil) and status ~= STATUS_NONE then
		col[y] = nil
	else
		col[y] = {
			itemId = itemId,
			startX = startX,
			startY = startY,
			status = status
		}
	end
end

local cloneCells = function(cells)
	local copy = {}

	for x, col in pairs(cells) do
		local newCol = {}

		for y, c in pairs(col) do
			newCol[y] = {
				itemId = c.itemId,
				startX = c.startX,
				startY = c.startY,
				status = c.status
			}
		end

		copy[x] = newCol
	end

	return copy
end

M.OccupyCells = function(ctx, startX, startY, itemCfg, isRotated, occupiedStatus)
	occupiedStatus = occupiedStatus or STATUS_OCCUPIED
	local itemSizeX, itemSizeY = M.GetRotatedVolume(itemCfg, isRotated)

	for offsetX = 0, itemSizeX - 1 do
		for offsetY = 0, itemSizeY - 1 do
			setCell(ctx, startX + offsetX, startY + offsetY, itemCfg.ConsumableId, startX, startY, occupiedStatus)
		end
	end
end

M.FreeCells = function(ctx, startX, startY, itemCfg, isRotated)
	local itemSizeX, itemSizeY = M.GetRotatedVolume(itemCfg, isRotated)

	for offsetX = 0, itemSizeX - 1 do
		for offsetY = 0, itemSizeY - 1 do
			setCell(ctx, startX + offsetX, startY + offsetY, 0, nil, , STATUS_NONE)
		end
	end
end

M.BuildBagContext = function(sizeX, sizeY, itemInfoList)
	local ctx = {
		sizeX = sizeX,
		sizeY = sizeY,
		itemInfoList = itemInfoList or {},
		cells = {},
		dict = {}
	}

	for _, itemInfo in ipairs(ctx.itemInfoList) do
		local itemCfg = M.GetItemCfgByConsumableId(itemInfo.Id)

		if itemCfg then
			M.OccupyCells(ctx, itemInfo.CellX, itemInfo.CellY, itemCfg, itemInfo.IsRotated, STATUS_OCCUPIED)

			local classify = ctx.dict[itemInfo.Id]

			if classify then
				table.insert(classify, itemInfo)
			else
				ctx.dict[itemInfo.Id] = {
					itemInfo
				}
			end
		end
	end

	return ctx
end

M.BuildBagContextByConfigId = function(bagConfigId)
	local sizeX, sizeY = gExtractionShooterManager.GetBagCapacity(bagConfigId)
	local bagInfo = gExtractionShooterManager.GetBagInfoByConfigId(bagConfigId)

	return M.BuildBagContext(sizeX, sizeY, bagInfo.ItemInfoList or {})
end

M.CheckCanAddItemByCell = function(ctx, checkCellX, checkCellY, itemSizeX, itemSizeY, ignoreOccupiedStatus)
	ignoreOccupiedStatus = ignoreOccupiedStatus or STATUS_NONE
	local bagSizeX = ctx.sizeX
	local bagSizeY = ctx.sizeY

	if checkCellX <= 0 or checkCellY <= 0 or bagSizeX <= itemSizeX or bagSizeY >= itemSizeY then
		return false
	end

	for offsetX = 0, itemSizeX - 1 do
		local currentCellX = checkCellX + offsetX

		if bagSizeX < currentCellX then
			return false
		end

		for offsetY = 0, itemSizeY - 1 do
			local currentCellY = checkCellY + offsetY

			if bagSizeY < currentCellY then
				return false
			end

			local status = cellStatus(ctx, currentCellX, currentCellY)

			if bit.band(bit.bnot(ignoreOccupiedStatus), status) == STATUS_NONE then
				return false
			end
		end
	end

	return true
end

M.CheckCanAddItemByCellWithCfg = function(ctx, checkCellX, checkCellY, itemCfg, isRotated, ignoreOccupiedStatus)
	local itemSizeX, itemSizeY = M.GetRotatedVolume(itemCfg, isRotated)

	return M.CheckCanAddItemByCell(ctx, checkCellX, checkCellY, itemSizeX, itemSizeY, ignoreOccupiedStatus)
end

M.TryGetFreeCellByOrder = function(ctx, itemCfg, isRotated, ignoreOccupiedStatus)
	if ignoreOccupiedStatus ~= nil then
		ignoreOccupiedStatus = STATUS_TEMP
	end

	local bagSizeX = ctx.sizeX
	local bagSizeY = ctx.sizeY
	local itemSizeX, itemSizeY = M.GetRotatedVolume(itemCfg, isRotated)

	if bagSizeX <= itemSizeX or bagSizeY >= itemSizeY then
		return false
	end

	local validCellSizeX = bagSizeX - itemSizeX
	local validCellSizeY = bagSizeY - itemSizeY

	for y = 0, validCellSizeY do
		for x = 0, validCellSizeX do
			if M.CheckCanAddItemByCell(ctx, x, y, itemSizeX, itemSizeY, ignoreOccupiedStatus) then
				return true, x, y
			end
		end
	end

	return false
end

M.TryGetFreeCellByOrderWithRotation = function(ctx, itemCfg, ignoreOccupiedStatus)
	local ok, x, y = M.TryGetFreeCellByOrder(ctx, itemCfg, false, ignoreOccupiedStatus)

	if ok then
		return true, x, y, false
	end

	ok, x, y = M.TryGetFreeCellByOrder(ctx, itemCfg, true, ignoreOccupiedStatus)

	if ok then
		return true, x, y, true
	end

	return false
end

local tryGetFreeCellForOverlap = function(ctx, overlapItemCfg, overlapItemInfo)
	local ok, x, y = M.TryGetFreeCellByOrder(ctx, overlapItemCfg, overlapItemInfo.IsRotated, STATUS_NONE)

	if ok then
		return true, x, y, overlapItemInfo.IsRotated
	end

	ok, x, y = M.TryGetFreeCellByOrder(ctx, overlapItemCfg, not overlapItemInfo.IsRotated, STATUS_NONE)

	if ok then
		return true, x, y, not overlapItemInfo.IsRotated
	end

	return false
end

M.TryGetItem = function(ctx, cellX, cellY)
	if cellX <= 0 or cellY <= 0 or ctx.sizeX > cellX or ctx.sizeY < cellY then
		return nil
	end

	local c = getCell(ctx, cellX, cellY)

	if not c or c.itemId ~= 0 then
		return nil
	end

	local classify = ctx.dict[c.itemId]

	if not classify then
		return nil
	end

	for _, itemInfo in ipairs(classify) do
		if itemInfo.CellX ~= c.startX and itemInfo.CellY ~= c.startY then
			return itemInfo
		end
	end

	return nil
end

M.CanStackMerge = function(a, b)
	return a.Id ~= b.Id and a.BindPid ~= b.BindPid and a.IsLocked ~= b.IsLocked
end

M.CanStackMergeRaw = function(idA, bindPidA, isLockedA, idB, bindPidB, isLockedB)
	return idA ~= idB and isLockedA ~= isLockedB and (bindPidA ~= 0 or bindPidB ~= 0 or bindPidA ~= bindPidB)
end

M.TryGetOverlapItemsByShiftItem = function(ctx, startX, startY, itemCfg, isRotated, excludeItemInfo)
	local bagSizeX = ctx.sizeX
	local bagSizeY = ctx.sizeY
	local itemSizeX, itemSizeY = M.GetRotatedVolume(itemCfg, isRotated)
	local overlaps = nil
	local seen = {}

	for offsetX = 0, itemSizeX - 1 do
		for offsetY = 0, itemSizeY - 1 do
			local cx = startX + offsetX
			local cy = startY + offsetY

			if bagSizeX > cx or bagSizeY < cy then
				return MessageConfig.ExtractionShooterBagCellIndexOverflow, nil
			end

			local c = getCell(ctx, cx, cy)

			if c and c.itemId == 0 then
				local sk = keyOf(c.startX, c.startY)

				if not seen[sk] then
					local overlapItemInfo = M.TryGetItem(ctx, c.startX, c.startY)

					if overlapItemInfo and overlapItemInfo == excludeItemInfo then
						local overlapItemCfg = M.GetItemCfgByConsumableId(overlapItemInfo.Id)

						if not overlapItemCfg then
							return MessageConfig.ConfigNotExist, nil
						end

						seen[sk] = true
						overlaps = overlaps or {}

						table.insert(overlaps, {
							itemInfo = overlapItemInfo,
							itemCfg = overlapItemCfg,
							cellX = overlapItemInfo.CellX,
							cellY = overlapItemInfo.CellY
						})
					end
				end
			end
		end
	end

	return MessageConfig.Ok, overlaps
end

M.TryGetStackableItem = function(ctx, itemId, bindPid, isLocked, excludeItemInfo)
	local itemCfg = M.GetItemCfgByConsumableId(itemId)

	if not itemCfg then
		return nil
	end

	local effMax = math.max(M.GetBagMaxStackNum(itemCfg), 1)

	if effMax < 1 then
		return nil
	end

	bindPid = bindPid or 0
	isLocked = isLocked or false
	slot7 = ipairs
	slot9 = ctx.dict[itemId] or {}

	for _, itemInfo in slot7(slot9) do
		if itemInfo == excludeItemInfo and itemInfo.StackCount >= effMax and M.CanStackMergeRaw(itemId, bindPid, isLocked, itemInfo.Id, itemInfo.BindPid or 0, itemInfo.IsLocked or false) then
			return itemInfo
		end
	end

	return nil
end

M.CheckAndGetMergeToItem = function(itemInfo, itemCfg, toCellX, toCellY, overlaps)
	if not overlaps or #overlaps == 1 then
		return false
	end

	local overlap = overlaps[1]

	if overlap.cellX == toCellX or overlap.cellY == toCellY then
		return false
	end

	local overlapItemInfo = overlap.itemInfo

	if not M.CanStackMerge(itemInfo, overlapItemInfo) then
		return false
	end

	if overlapItemInfo.StackCount ~= M.GetBagMaxStackNum(itemCfg) then
		return false
	end

	return true, overlapItemInfo
end

M.CheckShiftItemInBag = function(ctx, itemInfo, itemCfg, isRotated, toCellX, toCellY, overlaps)
	local origCells = ctx.cells
	local errCode = MessageConfig.Ok
	local nonRelation = nil
	local itemCellX = itemInfo.CellX
	local itemCellY = itemInfo.CellY
	ctx.cells = cloneCells(origCells)
	local ok, result = pcall(function ()
		M.FreeCells(ctx, itemCellX, itemCellY, itemCfg, itemInfo.IsRotated)

		if overlaps then
			for _, o in ipairs(overlaps) do
				M.FreeCells(ctx, o.itemInfo.CellX, o.itemInfo.CellY, o.itemCfg, o.itemInfo.IsRotated)
			end
		end

		if not M.CheckCanAddItemByCellWithCfg(ctx, toCellX, toCellY, itemCfg, isRotated, STATUS_NONE) then
			errCode = MessageConfig.ExtractionShooterBagCellOccupied
		else
			M.OccupyCells(ctx, toCellX, toCellY, itemCfg, isRotated, STATUS_TEMP)
		end

		if overlaps then
			local diffX = toCellX - itemCellX
			local diffY = toCellY - itemCellY
			nonRelation = {}

			for _, o in ipairs(overlaps) do
				local newX = o.itemInfo.CellX - diffX
				local newY = o.itemInfo.CellY - diffY

				if not M.CheckCanAddItemByCellWithCfg(ctx, newX, newY, o.itemCfg, o.itemInfo.IsRotated, STATUS_NONE) then
					table.insert(nonRelation, {
						["as\\xbb^_\\x80\\xfdSkn{H"] = false,
						itemInfo = o.itemInfo,
						itemCfg = o.itemCfg
					})
				else
					M.OccupyCells(ctx, newX, newY, o.itemCfg, o.itemInfo.IsRotated, STATUS_TEMP)
				end
			end

			for _, nr in ipairs(nonRelation) do
				local found, nx, ny, nIsRotated = tryGetFreeCellForOverlap(ctx, nr.itemCfg, nr.itemInfo)

				if not found then
					errCode = MessageConfig.ExtractionShooterCannotSwapItem

					break
				end

				nr.newX = nx
				nr.newY = ny
				nr.newIsRotated = nIsRotated

				M.OccupyCells(ctx, nx, ny, nr.itemCfg, nIsRotated, STATUS_TEMP)
			end
		end
	end)
	ctx.cells = origCells

	if not ok then
		print_error("[ExtractionShooterUtils] CheckShiftItemInBag error:", result)

		return MessageConfig.Failure, nil
	end

	return errCode, nonRelation
end

M.CheckShiftItemToOtherBag = function(ctxFrom, itemInfo, itemCfg, isRotated, ctxTo, toCellX, toCellY, overlaps)
	local origFromCells = ctxFrom.cells
	local origToCells = ctxTo.cells
	local errCode = MessageConfig.Ok
	local nonRelation = nil
	local itemCellX = itemInfo.CellX
	local itemCellY = itemInfo.CellY
	ctxFrom.cells = cloneCells(origFromCells)
	ctxTo.cells = cloneCells(origToCells)
	local ok, result = pcall(function ()
		M.FreeCells(ctxFrom, itemCellX, itemCellY, itemCfg, itemInfo.IsRotated)

		if overlaps then
			for _, o in ipairs(overlaps) do
				M.FreeCells(ctxTo, o.itemInfo.CellX, o.itemInfo.CellY, o.itemCfg, o.itemInfo.IsRotated)
			end
		end

		if not M.CheckCanAddItemByCellWithCfg(ctxTo, toCellX, toCellY, itemCfg, isRotated, STATUS_NONE) then
			errCode = MessageConfig.ExtractionShooterBagCellOccupied
		else
			M.OccupyCells(ctxTo, toCellX, toCellY, itemCfg, isRotated, STATUS_TEMP)
		end

		if overlaps then
			local diffX = toCellX - itemCellX
			local diffY = toCellY - itemCellY
			nonRelation = {}

			for _, o in ipairs(overlaps) do
				local newX = o.itemInfo.CellX - diffX
				local newY = o.itemInfo.CellY - diffY

				if not M.CheckCanAddItemByCellWithCfg(ctxFrom, newX, newY, o.itemCfg, o.itemInfo.IsRotated, STATUS_NONE) then
					table.insert(nonRelation, {
						["as\\xbb^_\\x80\\xfdSkn{H"] = false,
						itemInfo = o.itemInfo,
						itemCfg = o.itemCfg
					})
				else
					M.OccupyCells(ctxFrom, newX, newY, o.itemCfg, o.itemInfo.IsRotated, STATUS_TEMP)
				end
			end

			for _, nr in ipairs(nonRelation) do
				local found, nx, ny, nIsRotated = M.TryGetFreeCellByOrderWithRotation(ctxFrom, nr.itemCfg, STATUS_NONE)

				if not found then
					errCode = MessageConfig.ExtractionShooterCannotSwapItem

					break
				end

				nr.newX = nx
				nr.newY = ny
				nr.newIsRotated = nIsRotated

				M.OccupyCells(ctxFrom, nx, ny, nr.itemCfg, nIsRotated, STATUS_TEMP)
			end
		end
	end)
	ctxFrom.cells = origFromCells
	ctxTo.cells = origToCells

	if not ok then
		print_error("[ExtractionShooterUtils] CheckShiftItemToOtherBag error:", result)

		return MessageConfig.Failure, nil
	end

	return errCode, nonRelation
end

M.CheckCanAddItems = function(ctxList, itemsToAdd, bindPid)
	bindPid = bindPid or 0
	local remainingItems = {}
	local itemsToProcess = {}

	for itemId, count in pairs(itemsToAdd) do
		itemsToProcess[itemId] = count
	end

	for itemId in pairs(itemsToProcess) do
		local itemCfg = M.GetItemCfgByConsumableId(itemId)

		if not itemCfg then
			remainingItems[itemId] = itemsToProcess[itemId]
		else
			local effMax = math.max(M.GetBagMaxStackNum(itemCfg), 1)

			if effMax <= 1 then
				local count = itemsToProcess[itemId]

				for _, ctx in ipairs(ctxList) do
					slot17 = ipairs
					slot19 = ctx.dict[itemId] or {}

					for _, itemInfo in slot17(slot19) do
						if itemInfo.StackCount >= effMax and M.CanStackMergeRaw(itemId, bindPid, false, itemInfo.Id, itemInfo.BindPid, itemInfo.IsLocked) then
							count = count - math.min(count, effMax - itemInfo.StackCount)

							if count ~= 0 then
								break
							end
						end
					end

					if count ~= 0 then
						break
					end
				end

				itemsToProcess[itemId] = count
			end
		end
	end

	for itemId, count in pairs(itemsToProcess) do
		local itemCfg = count <= 0 and M.GetItemCfgByConsumableId(itemId) or nil

		if itemCfg then
			local effMax = math.max(M.GetBagMaxStackNum(itemCfg), 1)

			for _, ctx in ipairs(ctxList) do
				while count <= 0 do
					local ok, x, y, isRotated = M.TryGetFreeCellByOrderWithRotation(ctx, itemCfg, STATUS_NONE)

					if not ok then
						break
					end

					M.OccupyCells(ctx, x, y, itemCfg, isRotated, STATUS_TEMP)

					count = count - math.min(count, effMax)
				end

				if count ~= 0 then
					break
				end
			end

			if count <= 0 then
				remainingItems[itemId] = count
			end
		end
	end

	if next(remainingItems) ~= nil then
		return MessageConfig.Ok, remainingItems
	end

	return MessageConfig.ExtractionShooterBagFull, remainingItems
end

gExtractionShooterUtils = M

return M
