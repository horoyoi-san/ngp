local TriggerEnemyState = UX.Game.TriggerEnemyState
local M = {
	State = UX.Game.TriggerEnemyState.None,
	OnBeforeSwitchScene = function (self, switchType)
		self.State = TriggerEnemyState.None
		self.SpoonId = nil
		self.EnemyIds = nil
		self.GpsEnemy = nil
		self.Position = nil
		self.ResetTime = nil
		self.Rewarded = nil
		self.PlayingEffect = false

		gMessageManager:SendMessage(gEventConstants.TRIGGER_ENEMY_INFO_CHANGE)
	end
}
gTriggerEnemyManager = M
