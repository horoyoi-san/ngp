-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PaintingGameStore.lua
-- Decompiled from: 01066_PaintingGameStore.lua_e57f8bd29303.luajit

C_PaintingGameStore = DefClass("C_PaintingGameStore", C_PaintingGameStore, C_StoreGroup)
GroupName2Class.PaintingGameStore = C_PaintingGameStore
local M = C_PaintingGameStore
local AnimMgr = SGUI.AnimMgr
local Ease = DG.Tweening.Ease
local TRACE_EVENT_PROGRESS = 1
local TRACE_EVENT_COMPLETED = 2
local TRACE_EVENT_FAILED = 3
local FILL_METHOD_HORIZONTAL = 0
local FILL_METHOD_VERTICAL = 1
local REVEAL_FILL = {
	[0] = {
		["Z\\x98\\x89\\x8aO"] = 0,
		method = FILL_METHOD_HORIZONTAL
	},
	{
		["Z\\x98\\x89\\x8aO"] = 0,
		method = FILL_METHOD_VERTICAL
	},
	{
		["Z\\x98\\x89\\x8aO"] = 1,
		method = FILL_METHOD_HORIZONTAL
	},
	{
		["Z\\x98\\x89\\x8aO"] = 1,
		method = FILL_METHOD_VERTICAL
	}
}
local REVEAL_DURATION = 0.5
local REVEAL_EASE = Ease.Linear
local REVEAL_ANIM_ID = "PaintingReveal"

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.currentTraceData = nil
	self.currentStepIndex = 0
	self.currentStep = nil
	self.currentImage = nil
	self.isCurrentImageLoaded = false
	self.isTraceCompleted = false
	self.imageInstances = {}
	self.onPuzzleComplete = nil
	self.isFinished = false
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.StopCurrentStep(self)
end

M.OnDestroy = function(self)
	self.CleanupPuzzle(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.StopCurrentStep(self)
end

M.OnShow = function(self, panelId, data)
	self.BeginPuzzle(self, data.ToTable(data))
end

M.OnClose = function(self)
	local callback = nil

	if self.isFinished then
		callback = self.onPuzzleComplete
	end

	self.CleanupPuzzle(self)

	if callback == nil then
		callback.DynamicInvoke(callback)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.BeginPuzzle = function(self, data)
	self.CleanupPuzzle(self)

	if data ~= nil or data.traceData ~= nil then
		print_error("[PaintingGame] 打开面板缺少 traceData")

		return
	end

	local validationError = data.traceData:GetValidationError()

	if validationError == nil and validationError == "" then
		print_error(string.format("[PaintingGame] 谜题数据无效: %s", validationError))

		return
	end

	self.currentTraceData = data.traceData
	self.onPuzzleComplete = data.onComplete
	self.currentStepIndex = 1
	self.isFinished = false

	self.ApplyImageScale(self)
	self.ShowDamagedImage(self)
	self.StartCurrentStep(self)
end

M.ApplyImageScale = function(self)
	if self.bindData ~= nil or self.bindData.imageRoot ~= nil then
		return
	end

	local scale = self.currentTraceData.imageScale
	self.bindData.imageRoot.localScale = Vector3.New(scale, scale, 1)
end

M.ResetImageScale = function(self)
	if self.bindData ~= nil or self.bindData.imageRoot ~= nil then
		return
	end

	self.bindData.imageRoot.localScale = Vector3.one
end

M.ShowDamagedImage = function(self)
	local traceData = self.currentTraceData

	if not traceData.HasDamagedImage(traceData) then
		return
	end

	local imagePath = traceData.GetDamagedImagePath(traceData)

	if imagePath ~= nil or imagePath ~= "" then
		print_error("[PaintingGame] 破损底图ID无对应配置")

		return
	end

	local image = self.CreateImageInstance(self, traceData.GetDamagedImageCenter(traceData), traceData.GetDamagedImageSize(traceData), FILL_METHOD_HORIZONTAL, 0, 1)

	if image ~= nil then
		return
	end

	gCS.LuaUtils.LoadSpriteAssetWithCallBack(imagePath, function (loadOp)
		if self.currentTraceData == traceData or image ~= nil or image.gameObject ~= nil then
			return
		end

		if loadOp.asset ~= nil then
			print_error(string.format("[PaintingGame] 破损底图加载失败: %s", imagePath))

			return
		end

		image.sprite = loadOp.asset
	end)
end

M.CreateImageInstance = function(self, center, size, fillMethod, fillOrigin, fillAmount)
	local template = self.bindData.imageItemTemplate

	if template ~= nil then
		print_error("[PaintingGame] 缺少图片模板节点")

		return nil
	end

	local imageGo = UnityEngine.GameObject.Instantiate(template.gameObject, self.bindData.imageRoot)

	imageGo.SetActive(imageGo, true)

	local image = imageGo.GetComponent(imageGo, typeof(SGUI.UImage))
	local rect = imageGo.transform
	rect.anchorMin = Vector2.New(0.5, 0.5)
	rect.anchorMax = Vector2.New(0.5, 0.5)
	rect.pivot = Vector2.New(0.5, 0.5)
	rect.anchoredPosition = center
	rect.sizeDelta = size
	image.fillMethod = fillMethod
	image.fillOrigin = fillOrigin
	image.fillAmount = fillAmount

	table.insert(self.imageInstances, imageGo)

	return image
end

M.StartCurrentStep = function(self)
	local step = self.currentTraceData:GetStep(self.currentStepIndex - 1)

	if step ~= nil then
		self.FinishPuzzle(self)

		return
	end

	self.currentStep = step
	self.currentImage = nil
	self.isCurrentImageLoaded = false
	self.isTraceCompleted = false
	local traceBoard = self.bindData.traceBoard

	if not traceBoard.SetTrace(traceBoard, step) then
		print_error(string.format("[PaintingGame] 第%d步路径初始化失败", self.currentStepIndex))
		self.CleanupPuzzle(self)

		return
	end

	local fill = REVEAL_FILL[step.direction]

	if fill ~= nil then
		print_error(string.format("[PaintingGame] 第%d步揭示方向非法: %s", self.currentStepIndex, tostring(step.direction)))
		self.CleanupPuzzle(self)

		return
	end

	self.currentImage = self.CreateImageInstance(self, step.GetImageCenter(step), step.GetImageSize(step), fill.method, fill.origin, 0)

	if self.currentImage ~= nil then
		self.CleanupPuzzle(self)

		return
	end

	self.bindData.trajectoryBoard:BeginTrajectory()

	local imagePath = step:GetImagePath()

	if imagePath ~= nil or imagePath ~= "" then
		print_error(string.format("[PaintingGame] 第%d步图片ID无对应配置", self.currentStepIndex))
		self.CleanupPuzzle(self)

		return
	end

	gCS.LuaUtils.LoadSpriteAssetWithCallBack(imagePath, function (loadOp)
		if self.currentStep == step then
			return
		end

		if loadOp.asset ~= nil then
			print_error(string.format("[PaintingGame] 图片加载失败: %s", imagePath))
			self:CleanupPuzzle()

			return
		end

		self.currentImage.sprite = loadOp.asset
		self.isCurrentImageLoaded = true

		if self.isTraceCompleted then
			self:PlayReveal()
		end
	end)
end

M.OnUpdate = function(self)
	if self.currentStep ~= nil or self.isFinished then
		return
	end

	local eventType = self.bindData.traceBoard:ConsumeEvent()

	if eventType ~= TRACE_EVENT_PROGRESS then
		self.AddTrajectoryPoint(self)
	elseif eventType ~= TRACE_EVENT_COMPLETED then
		self.AddTrajectoryPoint(self)

		self.isTraceCompleted = true

		if self.isCurrentImageLoaded then
			self.PlayReveal(self)
		end
	elseif eventType ~= TRACE_EVENT_FAILED then
		self.ResetCurrentStep(self)
	end
end

M.AddTrajectoryPoint = function(self)
	local point = self.bindData.traceBoard.LastAcceptedNormalized

	self.bindData.trajectoryBoard:AddPoint(point.x, point.y)
end

M.PlayReveal = function(self)
	local step = self.currentStep
	local image = self.currentImage

	if image ~= nil then
		return
	end

	slot3 = self.bindData.traceBoard

	slot3:ClearTrace()

	slot3 = self.bindData.trajectoryBoard

	slot3:EndTrajectory()
	AnimMgr.DoFill(image, REVEAL_ANIM_ID, 1, REVEAL_DURATION, 0, REVEAL_EASE, function ()
		if self.currentStep == step then
			return
		end

		self:CompleteCurrentStep()
	end, false)
end

M.CompleteCurrentStep = function(self)
	self.currentStepIndex = self.currentStepIndex + 1
	self.currentStep = nil
	self.currentImage = nil

	self.StartCurrentStep(self)
end

M.ResetCurrentStep = function(self)
	self.bindData.trajectoryBoard:BeginTrajectory()

	if self.currentImage == nil then
		self.currentImage.fillAmount = 0
	end
end

M.StopCurrentStep = function(self)
	if self.currentImage == nil then
		AnimMgr.Kill(self.currentImage.rectTransform, REVEAL_ANIM_ID)
	end

	if self.bindData == nil and self.bindData.traceBoard == nil then
		self.bindData.traceBoard:ClearTrace()
	end

	if self.bindData == nil and self.bindData.trajectoryBoard == nil then
		self.bindData.trajectoryBoard:Clear()
	end

	self.currentStep = nil
	self.currentImage = nil
end

M.FinishPuzzle = function(self)
	if self.isFinished then
		return
	end

	self.isFinished = true

	self:StopCurrentStep()
	gPanelManager:Close(gPanelId.PAINTING_GAME_PANEL)
end

M.CleanupPuzzle = function(self)
	self.StopCurrentStep(self)
	self.ClearImageInstances(self)
	self.ResetImageScale(self)

	self.currentTraceData = nil
	self.currentStep = nil
	self.currentImage = nil
	self.currentStepIndex = 0
	self.onPuzzleComplete = nil
	self.isFinished = false
end

M.ClearImageInstances = function(self)
	for _, imageGo in ipairs(self.imageInstances) do
		if imageGo == nil then
			UnityEngine.Object.Destroy(imageGo)
		end
	end

	table.clear(self.imageInstances)
end
