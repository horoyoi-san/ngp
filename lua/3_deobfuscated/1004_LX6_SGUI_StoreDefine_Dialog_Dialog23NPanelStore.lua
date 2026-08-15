local DragEventListener = SGUI.EventSystems.DragEventListener
C_Dialog23NPanelStore = DefClass("C_Dialog23NPanelStore", C_Dialog23NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog23NPanelStore = C_Dialog23NPanelStore
local M = C_Dialog23NPanelStore
local base = C_Dialog23NPanelStore.base

function M:InitDialogComponent(data)
	base.InitDialogComponent(self, data)

	if self.bindData.DialogPicture and data.Pictures then
		self:InitPicture(self.bindData.DialogPicture, data.Pictures)
		table.insert(self.activatedComponent, self.DialogComponents.DialogPicture)
	end
end

function M:InitContent(widget, content)
	base.InitContent(self, widget, content)
	base.InitTitleAndShowNext(self, widget, content)

	local store = self:GetDialogComponentStore(widget)
	local dragButton = DragEventListener.Get(store.NextButton.gameObject)
	dragButton.ignoreClickInDraging = true
	dragButton.onBeginDrag = self:CreateAction("OnBaseUpDownBtnPress")
	dragButton.onDrag = self:CreateAction("OnBaseUpDownBtnPressing")
	dragButton.onEndDrag = self:CreateAction("OnBasUpDowneBtnRelease")
	store.NextButton.luaClick = self:CreateAction("OnNextDialogClick")
end

function M:OnBaseUpDownBtnPress(eventData)
	if eventData.button == 0 then
		self.draggingUpDown = true
		self.startTime = Time.time
		self.lastPos = gUtils:GetTouchPosition()
	end
end

function M:OnBaseUpDownBtnPressing(eventData)
	if eventData.button == 0 then
		local offset = gUtils:GetTouchPosition() - self.lastPos
		self.lastPos = gUtils:GetTouchPosition()

		gMessageManager:SendMessage(gEventConstants.MOUSE_MOVE, Vector2.New(offset.x, 0))
	end
end

function M:OnBasUpDowneBtnRelease(eventData)
	if eventData.button == 0 then
		self.draggingUpDown = false
		self.lastPos = nil
	end
end
