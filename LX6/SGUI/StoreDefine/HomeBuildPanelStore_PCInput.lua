-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HomeBuildPanelStore_PCInput.lua
-- Decompiled from: 01716_HomeBuildPanelStore_PCInput.lua_10f3bf0c00f8.luajit

local M = C_HomeBuildPanelStore

M.OnClickRotateBtn = function(self, btn, data)
	gFurnitureManager:RotateFollowingFurniture45()
end

M.OnPCRotateMouseScroll = function(self, context)
	if not self.inEdit or self.editDomain == "furniture" then
		return
	end

	if context.performed then
		local zoom = context.ReadValueVector2(context).y

		if zoom ~= 0 then
			return
		end

		local rotateDir = zoom <= 0 and 1 or -1

		gFurnitureManager:BeginRotationDrag()
		gFurnitureManager:UpdateFurnitureRotationByDrag(Vector3.New(30 * rotateDir, 0, 0))
		gFurnitureManager:EndRotationDrag()
	end
end

M.OnWASDMove = function(self, params)
	local isX = params[1]
	local size = params[2]
	local isPositive = params[3]

	if size ~= 0 then
		if isX then
			if isPositive and self.cameraJoyStickX <= 0 then
				self.cameraJoyStickX = 0
			elseif not isPositive and self.cameraJoyStickX >= 0 then
				self.cameraJoyStickX = 0
			end
		elseif isPositive and self.cameraJoyStickY <= 0 then
			self.cameraJoyStickY = 0
		elseif not isPositive and self.cameraJoyStickY >= 0 then
			self.cameraJoyStickY = 0
		end
	elseif isX then
		self.cameraJoyStickX = size
	else
		self.cameraJoyStickY = size
	end

	if self.cameraJoyStickX ~= 0 and self.cameraJoyStickY ~= 0 then
		self.cameraJoyStickSize = 0
	else
		self.cameraJoyStickSize = math.sqrt(self.cameraJoyStickX * self.cameraJoyStickX + self.cameraJoyStickY * self.cameraJoyStickY)
	end

	if self.cameraJoyStickSize == 0 then
		if not self.isCameraJoyStickActive then
			self.isCameraJoyStickActive = true

			self.OnCameraJoyStickTick(self)
		end
	else
		self.isCameraJoyStickActive = false
	end
end
