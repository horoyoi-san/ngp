local FurnitureConst = {}
local M = FurnitureConst
M.AdsorptionType = {
	Floor = 1,
	Ceiling = 2,
	Wall = 3
}
M.FurnitureMainType = {
	Decoration = 3,
	Furniture = 1,
	InteractiveItem = 5,
	Appliance = 2,
	Hanging = 4
}
M.LayerToAdsorptionType = {
	[0] = M.AdsorptionType.Floor,
	[8] = M.AdsorptionType.Floor,
	[16] = M.AdsorptionType.Wall,
	[27] = M.AdsorptionType.Ceiling
}
M.AdsorptionTypeToTagList = {
	[M.AdsorptionType.Floor] = {
		"HouseBuild"
	},
	[M.AdsorptionType.Ceiling] = {
		"HouseBuild"
	},
	[M.AdsorptionType.Wall] = {
		"HouseExternalWall",
		"HouseInternalWall"
	}
}
M.StorageRes = {
	NoFollowingFurniture = 2,
	NotInEdit = 3,
	Success = 1
}
M.carryTag = "CarryFurniture"
gFurnitureConst = M
