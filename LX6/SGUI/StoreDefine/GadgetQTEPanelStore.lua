-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\GadgetQTEPanelStore.lua
-- Decompiled from: 01880_GadgetQTEPanelStore.lua_58f5ad8d6c1f.luajit

C_GadgetQTEPanelStore = DefClass("C_GadgetQTEPanelStore", C_GadgetQTEPanelStore, C_StoreGroup)
GroupName2Class.GadgetQTEPanelStore = C_GadgetQTEPanelStore
local M = C_GadgetQTEPanelStore
local MAX_QTE_BUTTON_COUNT = 2
local EInteractType = {
	["n\\xa2\\xab\\xac\\xbd"] = 0,
	["\\xeb\\xde7\\xf4"] = 2,
	["}\\xbc\\xa7\\xbc\\xa5"] = 1
}

local ArrayToTable = function(value)
	if value ~= nil then
		return nil
	end

	if type(value) ~= "table" then
		return value
	end

	if not value.ToTable then
		return nil
	end

	return value.ToTable(value)
end

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.ClearPanelData(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.numEnum = {
		["\\x9d"] = 0,
		["\\x9c"] = 1,
		["\\x9f"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.numEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	self.ClearPanelData(self, true)
end

M.OnDestroy = function(self)
	self.ClearPanelData(self, true)
end

M.OnUpdate = function(self)
	local bindData = self.bindData

	if not bindData or not bindData.idList or not bindData.transList then
		return
	end

	local camera = gCS.CameraDataMgr.MainCamera
	local cameraValid = camera == nil and not gCS.LuaUtils.IsNull(camera)
	local staticPosList = self.iconStaticPosList
	local count = math.min(bindData.num or 0, #bindData.idList, #bindData.transList, MAX_QTE_BUTTON_COUNT)

	for i = 1, count do
		local tip = bindData["tip" .. i]

		if tip and tip.parent and not gCS.LuaUtils.IsNull(tip.parent) then
			local staticPos = staticPosList and staticPosList[i]

			if staticPos then
				local x = UnityEngine.Screen.width * staticPos[1]
				local y = UnityEngine.Screen.height * staticPos[2]
				tip.localPosition = gCS.LuaUtils.TransformScreenPointToUI(tip.parent, Vector3.New(x, y, 0))
			elseif cameraValid then
				local trans = bindData.transList[i]

				if trans and not gCS.LuaUtils.IsNull(trans) then
					local pos = trans.position
					local x, y = gCS.LuaUtils.WorldToScreenPointProjected(pos, camera, 0, 0, 0)
					local UIPos = gCS.LuaUtils.TransformScreenPointToUI(tip.parent, Vector3.New(x, y, 0))
					tip.localPosition = UIPos
				end
			end
		end
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.registerOperationId = gStoreButtonMgr:RegisterOperation({
		["\\xca\\xcf\t\r\\xf5"] = 5,
		["O\\xba\\xac\\x86\\xb2"] = 0,
		["\\xbb\\xa3\\xa4x7\\xea*"] = 1,
		groupId = LTConfig.HudDescGroupConfig.COMMON_QTE
	})

	self:ClearPanelData(true)

	local initializationCallback = data and data[3] or nil
	local closedCallback = data and data[4] or nil

	local FailShow = function()
		self:ClearPanelData(false)

		if initializationCallback then
			initializationCallback:DynamicInvoke(false)
		end
	end

	if not data or data[0] ~= nil or data[0] ~= 0 or not initializationCallback or not closedCallback then
		FailShow()

		return
	end

	local idList = ArrayToTable(data[1])
	local transList = ArrayToTable(data[2])

	if not idList or not transList or #idList ~= 0 or MAX_QTE_BUTTON_COUNT <= #idList or #idList == #transList then
		FailShow()

		return
	end

	local inputConfigs = {}
	local keyIds = {}
	local staticPosList = {}

	for i, id in ipairs(idList) do
		local trans = transList[i]
		local tip = self.bindData["tip" .. i]
		local qteConfig = id and LTConfig.PuzzleQTEKeyConfig.GetConfig(id) or nil
		local keyId = qteConfig and qteConfig.PCKey or nil
		local inputConfig = keyId and LTConfig.InputSGUIPCKeyConfig.GetConfig(keyId) or nil
		local btn = self.bindData["btn" .. i]
		local mobileBtn = self.bindData["mobileBtn" .. i]
		local iconStaticPos = qteConfig and qteConfig.IconStaticPos or nil
		local hasStaticPos = iconStaticPos == nil and #iconStaticPos < 2

		if hasStaticPos then
			staticPosList[i] = {
				iconStaticPos[1],
				iconStaticPos[2]
			}
		end

		if not hasStaticPos and (not trans or gCS.LuaUtils.IsNull(trans)) or not tip or not tip.parent or gCS.LuaUtils.IsNull(tip.parent) or not inputConfig or not btn or not mobileBtn then
			FailShow()

			return
		end

		inputConfigs[i] = inputConfig
		keyIds[i] = keyId
	end

	local initialized = pcall(function ()
		self.bindData.entityId = data[0]
		self.bindData.idList = idList
		self.bindData.transList = transList
		self.bindData.num = #idList
		self.iconStaticPosList = staticPosList

		self:BindQTEBtnEvents(self.bindData.btn1, 0)
		self:BindQTEBtnEvents(self.bindData.btn2, 1)
		self:BindQTEBtnEvents(self.bindData.mobileBtn1, 0)
		self:BindQTEBtnEvents(self.bindData.mobileBtn2, 1)

		for i, inputConfig in ipairs(inputConfigs) do
			self.bindData["btn" .. i]:SetPCKeyInfoWithOutTip(keyIds[i])

			local iconList = inputConfig.ButtonIcon or {}
			local isIcon = #iconList == 0
			self.bindData["btn" .. i .. "IsIcon"] = isIcon and 1 or 0

			if isIcon then
				self.bindData["btn" .. i .. "Icon"] = iconList[1]
			else
				self.bindData["btn" .. i .. "Text"] = inputConfig.ButtonName or ""
			end
		end
	end)

	if not initialized then
		FailShow()

		return
	end

	self.panelClosedCallback = closedCallback

	initializationCallback.DynamicInvoke(initializationCallback, true)
end

M.OnClose = function(self)
	if self.registerOperationId then
		gStoreButtonMgr:UnRegisterOperation(self.registerOperationId)

		self.registerOperationId = nil
	end

	self.ClearPanelData(self, true)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.ClearPanelData = function(self, notifyClosed)
	local closedCallback = self.panelClosedCallback
	self.panelClosedCallback = nil
	self.iconStaticPosList = nil

	if not self.bindData then
		if notifyClosed and closedCallback then
			closedCallback.DynamicInvoke(closedCallback)
		end

		return
	end

	for i = 1, MAX_QTE_BUTTON_COUNT do
		local btn = self.bindData["btn" .. i]
		local mobileBtn = self.bindData["mobileBtn" .. i]

		if btn then
			btn.luaClick = nil
			btn.luaPress = nil
			btn.luaRelease = nil
		end

		if mobileBtn then
			mobileBtn.luaClick = nil
			mobileBtn.luaPress = nil
			mobileBtn.luaRelease = nil
		end

		self.bindData["btn" .. i .. "IsIcon"] = 0
		self.bindData["btn" .. i .. "Icon"] = ""
		self.bindData["btn" .. i .. "Text"] = ""
	end

	self.bindData.entityId = nil
	self.bindData.idList = {}
	self.bindData.transList = {}
	self.bindData.num = 0

	if notifyClosed and closedCallback then
		closedCallback.DynamicInvoke(closedCallback)
	end
end

M.BindQTEBtnEvents = function(self, btn, index)
	btn.luaClick = self.CreateActionWithArgs(self, "OnBtnInteract", {
		index = index,
		interactType = EInteractType.Click
	})
	btn.luaPress = self.CreateActionWithArgs(self, "OnBtnInteract", {
		index = index,
		interactType = EInteractType.Press
	})
	btn.luaRelease = self.CreateActionWithArgs(self, "OnBtnInteract", {
		index = index,
		interactType = EInteractType.Release
	})
end

M.OnBtnInteract = function(self, data)
	self.OnClickIndex(self, data.index, data.interactType)
end

M.OnClickIndex = function(self, index, interactType)
	if not self.bindData or not self.bindData.entityId or index <= 0 or index > (self.bindData.num or 0) then
		return
	end

	gSpoonClientMgr:ReleaseContextEvent(self.bindData.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.CommonQteTrigger, {
		index = index,
		interactType = interactType
	})
end
