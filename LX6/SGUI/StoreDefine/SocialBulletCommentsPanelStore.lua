-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialBulletCommentsPanelStore.lua
-- Decompiled from: 01333_SocialBulletCommentsPanelStore.lua_65412afe95ca.luajit

C_SocialBulletCommentsPanelStore = DefClass("C_SocialBulletCommentsPanelStore", C_SocialBulletCommentsPanelStore, C_StoreGroup)
GroupName2Class.SocialBulletCommentsPanelStore = C_SocialBulletCommentsPanelStore
local M = C_SocialBulletCommentsPanelStore
local BulletConfig = {
	["\\xb2=.v\\x89D\\xcb!\\xab\\xb5"] = 2,
	["qH{AK,"] = 40,
	["~\\xbe\\xa7\\xaa\\xb2"] = 500,
	["\\xf4\\xda/3\\xe2"] = 4,
	["\\x87\\xb8\\xae^7\\xf36"] = 40
}

M.ctor = function(self)
	self.bulletQueue = {}
	self.activeRows = {}
	self.bulletPool = {}
	self.nextBulletId = 1

	for i = 1, BulletConfig.MaxRows do
		self.activeRows[i] = {
			["\\xe2L89\\xc0\\xa1O\\x95_\\xbd\\xb3"] = 0
		}
	end
end

M.OnAwake = function(self)
	if not self.bulletContainer then
		self.bulletContainer = {}
	end

	self.screenWidth = UnityEngine.Screen.width
	self.screenHeight = UnityEngine.Screen.height

	if self.bindData.bullet then
		self.baseYPos = self.bindData.bullet.transform.anchoredPosition.y
	else
		self.baseYPos = 0
	end

	self.bindData.bullet:SetActive(false)
end

M.OnEnable = function(self)
	self.StartBulletUpdate(self)
end

M.OnDestroy = function(self)
	self.StopBulletUpdate(self)
	self.ClearAllBullets(self)
end

M.AddBullet = function(self, name, text, senderId)
	if not text or text ~= "" then
		return
	end

	local bulletData = {
		id = self.nextBulletId,
		text = text,
		name = name,
		senderId = senderId,
		addTime = gCS.TimeManager.ServerUnixTime
	}
	self.nextBulletId = self.nextBulletId + 1

	table.insert(self.bulletQueue, bulletData)
	self.TrySpawnBullets(self)
end

M.TrySpawnBullets = function(self)
	local currentTime = gCS.TimeManager.ServerUnixTime

	while #self.bulletQueue <= 0 do
		local rowIndex = self.FindAvailableRow(self, currentTime)

		if not rowIndex then
			break
		end

		local bulletData = table.remove(self.bulletQueue, 1)

		self.SpawnBullet(self, bulletData, rowIndex, currentTime)
	end
end

M.FindAvailableRow = function(self, currentTime)
	for i = 1, BulletConfig.MaxRows do
		local row = self.activeRows[i]

		if not row.lastBullet or BulletConfig.MinInterval < currentTime - row.lastSpawnTime then
			return i
		end
	end

	return nil
end

M.SpawnBullet = function(self, bulletData, rowIndex, spawnTime)
	local bulletObj = self.GetBulletFromPool(self)

	if not bulletObj then
		bulletObj = GameObject.Instantiate(self.bindData.bullet)

		bulletObj.transform:SetParent(self.bindData.bullet.transform.parent, false)
	end

	local store = gStoreManager:GetStoreGroup("SocialBulletCommentsTemplateStore"):GetStoreByWidget(bulletObj)

	if store then
		store.name = gSocialFriendManager:GetPlayerDisplayName(bulletData.senderId, bulletData.name) .. ": "
		store.text = bulletData.text
		store.userInfo.pid = bulletData.senderId
	end

	local speed = LTConfig.FriendsConfig.BulletMessageSpeed or BulletConfig.Speed
	local yPos = (self.baseYPos or 0) + (rowIndex - 1) * BulletConfig.RowHeight

	bulletObj:SetActive(true)
	self:StartBulletAnimation(bulletObj, yPos, speed, bulletData.id)

	self.activeRows[rowIndex].lastBullet = bulletObj
	self.activeRows[rowIndex].lastSpawnTime = spawnTime

	table.insert(self.bulletContainer, {
		obj = bulletObj,
		id = bulletData.id,
		rowIndex = rowIndex,
		spawnTime = spawnTime
	})
end

M.StartBulletAnimation = function(self, bulletObj, yPos, speed, bulletId)
	local rectTransform = bulletObj.transform
	local containerWidth = self.screenWidth or UnityEngine.Screen.width
	local bulletWidth = bulletObj.transform.rect.width
	local startX = containerWidth / 2
	local endX = -bulletWidth - 1000
	local distance = startX - endX
	local duration = distance / speed
	rectTransform.anchoredPosition = Vector2.New(startX, yPos)

	if gCS.DOTween then
		slot12 = gCS.DOTween.DOAnchorPosX(rectTransform, endX, duration)

		slot12:OnComplete(function ()
			self:OnBulletComplete(bulletId)
		end)
	else
		local elapsedTime = 0
		local bulletTimer = nil
		bulletTimer = Timer.New(function ()
			elapsedTime = elapsedTime + 0.016
			local t = math.min(elapsedTime / duration, 1)
			local currentX = startX + (endX - startX) * t

			if rectTransform and not gCS.LuaUtils.IsNull(rectTransform) then
				rectTransform.anchoredPosition = Vector2.New(currentX, yPos)
			end

			if t > 1 then
				if bulletTimer then
					bulletTimer:Stop()
				end

				self:OnBulletComplete(bulletId)
			end
		end, 0.016, -1)

		bulletTimer.Start(bulletTimer)

		for _, bullet in ipairs(self.bulletContainer) do
			if bullet.id ~= bulletId then
				bullet.timer = bulletTimer

				break
			end
		end
	end
end

M.OnBulletComplete = function(self, bulletId)
	for i, bullet in ipairs(self.bulletContainer) do
		if bullet.id ~= bulletId then
			self.ReturnBulletToPool(self, bullet.obj)
			table.remove(self.bulletContainer, i)

			if self.activeRows[bullet.rowIndex].lastBullet ~= bullet.obj then
				self.activeRows[bullet.rowIndex].lastBullet = nil
			end

			break
		end
	end
end

M.StartBulletUpdate = function(self)
	if self.updateTimer then
		return
	end

	self.updateTimer = Timer.New(function ()
		self:UpdateBullets()
	end, 0.1, -1)

	self.updateTimer:Start()
end

M.StopBulletUpdate = function(self)
	if self.updateTimer then
		self.updateTimer:Stop()

		self.updateTimer = nil
	end
end

M.UpdateBullets = function(self)
	self.TrySpawnBullets(self)

	local currentTime = gCS.TimeManager.ServerUnixTime

	for i = #self.bulletContainer, 1, -1 do
		local bullet = self.bulletContainer[i]

		if BulletConfig.LifeTime >= currentTime - bullet.spawnTime then
			if bullet.timer then
				bullet.timer:Stop()
			end

			self.OnBulletComplete(self, bullet.id)
		end
	end
end

M.ClearAllBullets = function(self)
	self.bulletQueue = {}

	for i = #self.bulletContainer, 1, -1 do
		local bullet = self.bulletContainer[i]

		if bullet.timer then
			bullet.timer:Stop()
		end

		self.ReturnBulletToPool(self, bullet.obj)
	end

	self.bulletContainer = {}

	for i = 1, BulletConfig.MaxRows do
		self.activeRows[i].lastBullet = nil
		self.activeRows[i].lastSpawnTime = 0
	end
end

M.GetBulletFromPool = function(self)
	if #self.bulletPool <= 0 then
		return table.remove(self.bulletPool)
	end

	return nil
end

M.ReturnBulletToPool = function(self, bulletObj)
	if bulletObj then
		bulletObj.SetActive(bulletObj, false)
		table.insert(self.bulletPool, bulletObj)
	end
end

M.UpdateConfig = function(self, config)
	if config.MaxRows then
		BulletConfig.MaxRows = config.MaxRows

		while #self.activeRows >= BulletConfig.MaxRows do
			table.insert(self.activeRows, {
				["\\xe2L89\\xc0\\xa1O\\x95_\\xbd\\xb3"] = 0
			})
		end
	end

	if config.RowHeight then
		BulletConfig.RowHeight = config.RowHeight
	end

	if config.MinInterval then
		BulletConfig.MinInterval = config.MinInterval
	end

	if config.Speed then
		BulletConfig.Speed = config.Speed
	end

	if config.LifeTime then
		BulletConfig.LifeTime = config.LifeTime
	end
end

M.GetConfig = function(self)
	return {
		MaxRows = BulletConfig.MaxRows,
		RowHeight = BulletConfig.RowHeight,
		MinInterval = BulletConfig.MinInterval,
		Speed = BulletConfig.Speed,
		LifeTime = BulletConfig.LifeTime
	}
end
