C_BowlingGameModePanelStore = DefClass("C_BowlingGameModePanelStore", C_BowlingGameModePanelStore, C_StoreGroup)
GroupName2Class.BowlingGameModePanelStore = C_BowlingGameModePanelStore
local M = C_BowlingGameModePanelStore

function M:OnAwake()
	print_debug("BowlingGameModePanelStore OnAwake")
end

function M:OnStart()
	print_debug("BowlingGameModePanelStore OnStart")

	self.bindData.BtnSingle.luaClick = self:CreateAction("SelectModeSingle")
	self.bindData.BtnBattle.luaClick = self:CreateAction("SelectModeBattle")
	self.bindData.BtnTech.luaClick = self:CreateAction("SelectModeTech")
	self.bindData.BtnF.luaClick = self:CreateAction("SelectExit")
end

function M:OnDestroy()
	return
end

function M:OnShow(panelId, data)
	return
end

function M:OnUpdate()
	return
end

function M:OnRelease()
	return
end

function M:SelectModeSingle()
	gBowlingGameManager.currentGame:ExecuteSelectModeSingle()
end

function M:SelectModeBattle()
	gBowlingGameManager.currentGame:ExecuteSelectModeBattle()
end

function M:SelectModeTech()
	gBowlingGameManager.currentGame:ExecuteSelectModeTech()
end

function M:SelectExit()
	gBowlingGameManager:ExecuteExitGame()
end
