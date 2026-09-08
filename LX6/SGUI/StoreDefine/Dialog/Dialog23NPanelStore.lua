-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Dialog\Dialog23NPanelStore.lua
-- Decompiled from: 01991_Dialog23NPanelStore.lua_375084d1031d.luajit

local DragEventListener = SGUI.EventSystems.DragEventListener
C_Dialog23NPanelStore = DefClass("C_Dialog23NPanelStore", C_Dialog23NPanelStore, C_DialogBasePanelStore)
GroupName2Class.Dialog23NPanelStore = C_Dialog23NPanelStore
local M = C_Dialog23NPanelStore
local base = C_Dialog23NPanelStore.base

M.InitDialogComponent = function(self, data)
	base.InitDialogComponent(self, data)

	if self.bindData.DialogPicture and data.Pictures then
		self.InitPicture(self, self.bindData.DialogPicture, data.Pictures)
		table.insert(self.activatedComponent, self.DialogComponents.DialogPicture)
	end
end

M.InitContent = function(self, widget, content)
	base.InitContent(self, widget, content)
	base.InitTitleAndShowNext(self, widget, content)

	local store = self.GetDialogComponentStore(self, widget)
	local dragButton = DragEventListener.Get(store.NextButton.gameObject)
	dragButton.ignoreClickInDraging = true
	dragButton.onBeginDrag = self.CreateAction(self, "OnBaseUpDownBtnPress")
	dragButton.onDrag = self.CreateAction(self, "OnBaseUpDownBtnPressing")
	dragButton.onEndDrag = self.CreateAction(self, "OnBasUpDowneBtnRelease")
	store.NextButton.luaClick = self.CreateAction(self, "OnNextDialogClick")
end

M.OnBaseUpDownBtnPress = function(self, eventData)
	if eventData.button ~= 0 then
		self.draggingUpDown = true
		self.startTime = Time.time
		self.lastPos = gUtils:GetTouchPosition()
	end
end

M.OnBaseUpDownBtnPressing = function(self, eventData)
	if eventData.button ~= 0 then
		local offset = gUtils:GetTouchPosition() - self.lastPos
		self.lastPos = gUtils:GetTouchPosition()

		gMessageManager:SendMessage(gEventConstants.MOUSE_MOVE, Vector2.New(offset.x, 0))
	end
end

M.OnBasUpDowneBtnRelease = function(self, eventData)
	if eventData.button ~= 0 then
		self.draggingUpDown = false
		self.lastPos = nil
	end
end
