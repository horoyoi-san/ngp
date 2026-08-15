local C_DCTManager = L18.Script.LX6.Dialog.DCTManager.Instance
local CDCTBindSeatInfo = L18.Script.LX6.Dialog.DCTDefine.BindSeatInfo
C_DialogCameraManager = DefClass("C_DialogCameraManager", C_DialogCameraManager)
local M = C_DialogCameraManager

function M:OnBeforeSwitchScene(data)
	C_DCTManager:OnBeforeSwitchScene(data)
end

function M:PreloadTemplate(dialogID, spoonNodeId, taskIds)
	return C_DCTManager:PreloadTemplate(dialogID, spoonNodeId, taskIds)
end

function M:ReleaseTemplate(dialogID)
	C_DCTManager:ReleaseTemplate(dialogID)
end

function M:GetDCTConfig()
	return C_DCTManager:GetDCTConfig()
end

function M:ParseRealUnitInfo(bindUnitInfos, spoonNode, spoonContext, spoonGraph)
	if not bindUnitInfos or not spoonGraph or not bindUnitInfos or #bindUnitInfos == 0 then
		return
	end

	local bindInfos = {}

	for i = 1, #bindUnitInfos do
		local bindUnitInfo = bindUnitInfos[i]

		if bindUnitInfo.type == 2 then
			local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(bindUnitInfo.type, 0, bindUnitInfo.bindTargetName, bindUnitInfo.unitName)

			table.insert(bindInfos, c_bindInfo)
		elseif bindUnitInfo.type == 3 then
			if bindUnitInfo.unit ~= nil then
				local pType = type(bindUnitInfo.unit)
				local c_bindInfo = nil

				if pType == "table" then
					local pid = 0

					if bindUnitInfo.unit and bindUnitInfo.unit:GetUnit() then
						pid = bindUnitInfo.unit:GetUnit().pid
					end

					c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(bindUnitInfo.type, pid, bindUnitInfo.bindTargetName, nil, bindUnitInfo.unit)
				elseif pType == "number" then
					local spoonUnit = {
						spoonNode = spoonNode,
						spoonContext = spoonContext,
						id = bindUnitInfo.unit
					}
					local pid = gTimelineManager:Timeline_GetBindUnitPid(spoonUnit)
					c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(bindUnitInfo.type, pid, bindUnitInfo.bindTargetName, nil, spoonUnit)
				end

				table.insert(bindInfos, c_bindInfo)
			elseif bindUnitInfo.npc ~= nil then
				local pid = gTimelineManager:Timeline_GetBindUnitPid({
					spoonNode = spoonNode,
					spoonContext = spoonContext,
					id = bindUnitInfo.npc
				})
				local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(bindUnitInfo.type, pid, bindUnitInfo.bindTargetName, nil, {
					spoonNode = spoonNode,
					spoonContext = spoonContext,
					id = bindUnitInfo.npc
				})

				table.insert(bindInfos, c_bindInfo)
			end
		elseif bindUnitInfo.type == 4 then
			local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(bindUnitInfo.type, bindUnitInfo.vehicle, bindUnitInfo.bindTargetName, nil)

			table.insert(bindInfos, c_bindInfo)
		end
	end

	return bindInfos
end

function M:ParseBindCarInfo(data, BindCarInfo, BindSeatInfo)
	local bindInfos = {}

	for index, value in pairs(BindSeatInfo) do
		if value.index == nil then
			value.index = -1
		end

		local bindInfo = CDCTBindSeatInfo.CreateBindSeatInfo(index - 1, Vector3.NewT(value.pos), Vector3.NewT(value.rot), value.index)

		table.insert(bindInfos, #bindInfos + 1, bindInfo)
	end

	data.bindSeatInfos = bindInfos
	data.customPosition = Vector3.NewT(BindCarInfo.pos)
	data.customRotation = Vector3.NewT(BindCarInfo.rot)
	data.carUid = BindCarInfo.uid
end

function M:ParseAdvancedBlackContinue(data, AdvancedBlackContinue)
	local advancedBlackContinueDialogIds = {}
	local advancedBlackContinues = {}

	for _, value in pairs(AdvancedBlackContinue) do
		table.insert(advancedBlackContinueDialogIds, #advancedBlackContinueDialogIds + 1, value.DialogId)
		table.insert(advancedBlackContinues, #advancedBlackContinues + 1, value.Keep)
	end

	data.advancedBlackContinueDialogIds = advancedBlackContinueDialogIds
	data.advancedBlackContinues = advancedBlackContinues
end

function M:IsPlaying()
	return C_DCTManager:IsPlaying()
end

function M:ProcessBlackScreenWhenStart()
	if gBlackScreenManager:IsOccupied() and not gBlackScreenManager:IsOccupiedById(gBlackScreenId.SPOON_TASK) then
		gBlackScreenManager:OpenBlackInstantly(gBlackScreenId.DIALOG_CAMERA_TEMPLATE)
	end
end

function M:InvokeAction(action)
	C_DCTManager:InvokeAction(action)
end

gDialogCameraManager = gDialogCameraManager or C_DialogCameraManager.new()
