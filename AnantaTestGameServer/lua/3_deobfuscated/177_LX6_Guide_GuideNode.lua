local GameObject = UnityEngine.GameObject
local M = {
	nodes = {},
	BUBBLE_MODE = {
		ClickScreen = 3,
		Mask = 2,
		Modeless = 4,
		Normal = 1
	},
	activedGuide = {},
	GetNode = function (self, nodeName)
		local node = self.nodes[nodeName]

		if node == nil then
			node = {
				panelId = 0,
				subNodeGenId = 0,
				name = nodeName
			}
			self.nodes[nodeName] = node
		end

		return node
	end,
	Clear = function (self)
		return
	end
}

function M:NodeGoCreate(node, isTemplate, go, container)
	node.isTemplate = isTemplate

	if isTemplate and node.subNodes == nil then
		node.subNodes = {}
	end

	if not gCS.LuaUtils.IsNull(node.gameObject) then
		print_warn("M 节点命名重复 name=", node.name, " path1=", SGUITools.GetHierarchy(node.gameObject), "path2=", SGUITools.GetHierarchy(go))
	end

	node.gameObject = go
	node.container = container

	if go then
		local guideNode = go:GetComponent(typeof(LX6.Guide.GuideNode))
		node.targetGo = guideNode.targetGo or go
		node.controllerTargetGo = guideNode.controllerTargetGo or go
		node.listenerGo = guideNode.listenerGo or go
	end

	if node.clickCbs and #node.clickCbs > 0 or node.pressCbs and #node.pressCbs > 0 then
		self:AddNodeEventListener(node)
	end

	gMessageManager:SendMessage(gEventConstants.GUIDE_NODE_GO_CREATE, node.name)
end

function M:NodeGoDestroy(node)
	node.gameObject = nil
	node.preActive = nil

	self:RemoveEventListener(node, true)

	if node.clearHandlerOnDestroy then
		node.customActiveHandler = nil
	end

	node.customHandlerCell = nil
	node.isTemplate = nil
	node.subNodes = nil
	node.container = nil

	gMessageManager:SendMessage(gEventConstants.GUIDE_NODE_GO_DESTROY, node.name)
end

function M:SubNodeGoCreate(node, index, go)
	node.subNodeGenId = node.subNodeGenId + 1
	local subNodeName = node.name .. "_" .. index
	local subNode = self:GetNode(subNodeName)
	node.subNodes[index] = subNode

	self:NodeGoCreate(subNode, false, go, nil)
end

function M:SubNodeGoDestroy(node, index)
	local subNode = node.subNodes[index]

	self:NodeGoDestroy(subNode)

	node.subNodes[index] = nil
end

function M:SubNodeGoIndexChange(node, index, newIndex)
	if node.subNodes[newIndex] ~= nil then
		print_error("SubNodeGoIndexChange error! subNodes[newIndex]~=nil", node.name, index, newIndex)
	end

	node.subNodes[newIndex] = node.subNodes[index]
	node.subNodes[index] = nil
end

function M:AddClickCallback(node, cb, isPress)
	if node.clickCbs == nil then
		node.clickCbs = {}
		node.pressCbs = {}

		self:AddNodeEventListener(node)
	end

	local list = isPress and node.pressCbs or node.clickCbs
	list[#list + 1] = cb
end

function M:RemoveClickCallback(node, cb, isPress)
	if node.clickCbs == nil then
		return
	end

	local list = isPress and node.pressCbs or node.clickCbs

	for i = 1, #list do
		if list[i] == cb then
			table.remove(list, i)

			break
		end
	end
end

function M:AddNodeEventListener(node)
	if not gCS.LuaUtils.IsNull(node.uieventListener) or gCS.LuaUtils.IsNull(node.gameObject) then
		return
	end

	node.uieventListener = node.gameObject:AddComponent(typeof(UIEventListener))

	function node.uieventListener.onClick(go)
		for i = 1, #node.clickCbs do
			node.clickCbs[i]()
		end
	end

	function node.uieventListener.onPress(go, isPress)
		if isPress then
			for i = 1, #node.pressCbs do
				node.pressCbs[i]()
			end
		end
	end
end

function M:RemoveEventListener(node, isDestroyGo)
	if gCS.LuaUtils.IsNull(node.uieventListener) then
		return
	end

	node.uieventListener.onClick = nil
	node.uieventListener = nil

	if not isDestroyGo then
		GameObject.Destroy(node.uieventListener)
	end
end

function M:RegisterGuideNode(eventName, isTemplate, index, container, csUIAni)
	local node = self:GetNode(eventName)

	if isTemplate then
		if not node.isTemplate then
			self:NodeGoCreate(node, isTemplate, nil, nil)
		end

		self:SubNodeGoCreate(node, index, csUIAni.gameObject)
	else
		self:NodeGoCreate(node, false, csUIAni.gameObject, container)
	end
end

function M:UnRegisterGuideNode(eventName, isTemplate, index)
	local node = self:GetNode(eventName)

	if isTemplate then
		self:SubNodeGoDestroy(node, index)

		if gUtils:IsTableEmpty(node.subNodes) then
			self:NodeGoDestroy(node)
		end
	else
		self:NodeGoDestroy(node)
	end
end

function M:ChangeGuideArrayIndex(eventName, index, newIndex)
	local node = self:GetNode(eventName)

	self:SubNodeGoIndexChange(node, index, newIndex)
end

function M:SetNodePanelId(eventName, panelId, isTemplate, index)
	if isTemplate then
		eventName = eventName .. "_" .. index
	end

	local node = self:GetNode(eventName)

	if node.panelId ~= panelId and panelId > 0 then
		node.panelId = panelId
	end
end

gGuideNode = M
