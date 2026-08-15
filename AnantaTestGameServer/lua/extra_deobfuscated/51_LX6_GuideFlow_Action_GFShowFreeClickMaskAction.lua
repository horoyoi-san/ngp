local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFShowFreeClickMaskAction = DefClass("C_GFShowFreeClickMaskAction", C_GFShowFreeClickMaskAction, C_GFWaitActionBase)
local C_GFShowFreeClickMaskAction = C_GFShowFreeClickMaskAction

function C_GFShowFreeClickMaskAction:ctor(id, isMonitor, params)
	self.params = {
		nodeId = self.mId,
		nodeName = params.nodeName,
		showType = params.showType,
		textDir = C_GFShowFreeClickMaskAction.TextDirMap(params.textDir),
		size = params.size,
		guideText = params.guideText,
		keyEventId = params.keyEventId,
		iconId = params.iconId,
		controllerButtonCellId = params.controllerButtonCellId
	}
	self.finishCondition = params.finishCondition
	self.attachPanel = params.attachPanel
	self.mActionType = gGFConstant.ActionType.ShowFreeClickMask
	self.mNodeName = "C_GFShowFreeClickMaskAction"
	self.msgEvents = {
		[gEventConstants.GUIDE_FREE_CLICK_FINISH] = function (eventId, data)
			local nodeName = data

			if nodeName == self.params.nodeName and self.mStartAction then
				self.mSelfFinished = true
			end
		end,
		[gEventConstants.GUIDE_FREE_CLICK_DESTROY] = function (eventId, data)
			local nodeName = data

			if nodeName == self.params.nodeName and self.mStartAction then
				gGFManager:RemoveGuideNodeFreeClickMaskById(self.params.nodeName, self.params.nodeId, true)

				self.mStartAction = false
			end
		end
	}

	if params.attachPanel then
		self.msgEvents[gEventConstants.PANEL_ON_SHOW] = function (msg)
			local panel = msg.data

			if panel == self.attachPanel and self.mStartAction then
				self.mSelfFinished = true
			end
		end
	end
end

function C_GFShowFreeClickMaskAction:OnStartAction()
	self.params.node = gGuideNode:GetNode(self.params.nodeName)

	self:InitCheckBlock()

	if not gCS.LuaUtils.IsNull(self.params.node.gameObject) and self.params.node.gameObject.activeInHierarchy then
		local obj = self.params.node.gameObject:FindChild("V3GuideFreeClickMask")

		if obj then
			self.params.freeClickMaskObj = obj

			gGFManager:AddGuideNodeFreeClickMask(self.params.nodeName, self.params.nodeId, self.params)
		end

		self.mStartAction = true
	end
end

function C_GFShowFreeClickMaskAction:OnStopNode()
	local started = self.mStartAction
	self.mStartAction = false

	if started and not self.mSelfFinished then
		gGFManager:RemoveGuideNodeFreeClickMaskById(self.params.nodeName, self.params.nodeId)
	end
end

function C_GFShowFreeClickMaskAction:OnFinishAction()
	gGFManager:RemoveGuideNodeFreeClickMaskById(self.params.nodeName, self.params.nodeId)

	self.mFinishAction = true
end

return C_GFShowFreeClickMaskAction
