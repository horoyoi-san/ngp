local M = C_ChatChattingPanelStore

function M:AnimUtilsInit()
	self.anim = {
		lastIndex = -1,
		State = {}
	}
end

function M:EnableItemAnim(enable)
	self.anim.enable = enable
end

function M:SetItemAnimLastIndex(index)
	self.anim.lastIndex = index
end

function M:PlayChatItemAnim(btn, index)
	if not self.anim.enable or index <= self.anim.lastIndex then
		return
	end

	local state = self.anim.State[index] or {}
	local name = btn.name
	local isEllipsis = string.starts_with(name, "S_ChatTypingMsgTemplate")
	local isText = not isEllipsis and string.starts_with(name, "S_ChatTextMsgTemplate")
	local transform = btn.transform

	if isEllipsis then
		local ellipsisGo = transform:Find("Button")
		local anim = ellipsisGo and ellipsisGo:GetComponent(typeof(UnityEngine.Animation))
		local ellipsisWidget = ellipsisGo and ellipsisGo:GetComponent(typeof(SGUI.UWidget))

		if ellipsisWidget then
			ellipsisWidget.renderOpacity = 0
		end

		anim:Stop()
		anim:Play()

		state.ellipsisAnimPlayed = true
	elseif isText then
		local contentGo = transform:Find("MsgBubble")

		if state.ellipsisAnimPlayed then
			self:_TryPlayAnimOnNode(contentGo, false)

			if not state.contentAnimPlayed then
				state.contentAnimPlayed = true
			end
		else
			state.contentAnimPlayed = state.contentAnimPlayed or self:_TryPlayAnimOnNode(contentGo, not state.contentAnimPlayed)
		end
	else
		local contentGo = transform:Find("Button") or transform:Find("MsgBubble")
		state.contentAnimPlayed = state.contentAnimPlayed or self:_TryPlayAnimOnNode(contentGo, not state.contentAnimPlayed)
	end

	local avatarGo = transform:Find("ChatHead")
	state.avatarAnimPlayed = state.avatarAnimPlayed or self:_TryPlayAnimOnNode(avatarGo, not state.avatarAnimPlayed)
	self.anim.State[index] = state
end

function M:_TryPlayAnimOnNode(transform, isPlay)
	local anim = transform and transform:GetComponent(typeof(UnityEngine.Animation))

	if anim then
		if isPlay then
			local widget = transform:GetComponent(typeof(SGUI.UWidget))

			if widget then
				widget.renderOpacity = 0
			end

			anim.enabled = true

			anim:Play()

			return true
		else
			anim:Stop()

			anim.enabled = false

			return false
		end
	end

	return false
end
