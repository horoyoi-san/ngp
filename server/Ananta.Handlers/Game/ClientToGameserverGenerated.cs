using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
	public static class ClientToGameserverGenerated
	{
		[Handler(MethodId.AskRecommendGetTopWearFashionTag)]
		public static void HandleAskRecommendGetTopWearFashionTagId(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Fashion] AskRecommendGetTopWearFashionTag called");
			// Recommend top wear fashion tags - for private server, just acknowledge
			// In full implementation, would recommend based on player's fashion inventory
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskRecommendGetTopWearFashionTag);
			// Send sync notification with fashion info
			MissingSyncHandlers.SendSyncFashionInfoDict(conn);
		}

		[Handler(MethodId.AskCancelInviteePlayerInteractio)]
		public static void HandleAskCancelInviteePlayerInteractionAction(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Interaction] AskCancelInviteePlayerInteractionAction called");
			// Cancel invitee player interaction - for private server, just acknowledge
			// In full implementation, would cancel pending interaction and sync state
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskCancelInviteePlayerInteractio);
			// Send sync notification to update client state
			MissingSyncHandlers.SendSyncInviteePlayerInteractionActi(conn);
		}

		[Handler(MethodId.AskTakeCompetitionSeasonAllRankR)]
		public static void HandleAskTakeCompetitionSeasonAllRankRewards(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Competition] AskTakeCompetitionSeasonAllRankRewards called");
			// Take competition season all rank rewards - for private server, just acknowledge
			// In full implementation, would give rewards based on player's rank and sync season data
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskTakeCompetitionSeasonAllRankR);
			// Send sync notification with competition season data
			MissingSyncHandlers.SendSyncPlayerCompetitionSeason(conn);
		}

		[Handler(MethodId.AskCancelInteractionActionRedPoi)]
		public static void HandleAskCancelInteractionActionRedPoint(Connection conn, UxRpcMessage msg)
		{
			var args = msg.GetArgs<AskCancelInteractionActionRedPointArgs>();
			Console.WriteLine($"[Interaction] AskCancelInteractionActionRedPoint called, npcitemid={args?.npcitemid}");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskCancelInteractionActionRedPoi);
		}

		[Handler(MethodId.AskTakeCompetitionSeasonOverallR)]
		public static void HandleAskTakeCompetitionSeasonOverallRankReward(Connection conn, UxRpcMessage msg)
		{
			var args = msg.GetArgs<AskTakeCompetitionSeasonOverallRankRewardArgs>();
			Console.WriteLine($"[Competition] AskTakeCompetitionSeasonOverallRankReward called, rewardid={args?.rewardid}");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskTakeCompetitionSeasonOverallR);
		}

		[Handler(MethodId.AskReadPoliceFakeClueAgentInfoLi)]
		public static void HandleAskReadPoliceFakeClueAgentInfoList(Connection conn, UxRpcMessage msg)
		{
			var args = msg.GetArgs<AskReadPoliceFakeClueAgentInfoListArgs>();
			Console.WriteLine($"[Police] AskReadPoliceFakeClueAgentInfoList called, count={args?.clueagentinfoindexlist?.Count ?? 0}");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskReadPoliceFakeClueAgentInfoLi);
		}

		[Handler(MethodId.AskAddTruckOrderSpecialPointRewa)]
		public static void HandleAskAddTruckOrderSpecialPointReward(Connection conn, UxRpcMessage msg)
		{
			var args = msg.GetArgs<AskAddTruckOrderSpecialPointRewardArgs>();
			Console.WriteLine($"[Truck] AskAddTruckOrderSpecialPointReward called, orderid={args?.orderid}, pointid={args?.pointid}");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskAddTruckOrderSpecialPointRewa);
		}

		[Handler(MethodId.AskLinkPlanningBoardDividendsPut)]
		public static void HandleAskLinkPlanningBoardDividendsPutInKeys(Connection conn, UxRpcMessage msg)
		{
			var args = msg.GetArgs<AskLinkPlanningBoardDividendsPutInKeysArgs>();
			Console.WriteLine("[Planning] AskLinkPlanningBoardDividendsPutInKeys called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskLinkPlanningBoardDividendsPut);
		}

		[Handler(MethodId.AskCancelInviterPlayerInteractio)]
		public static void HandleAskCancelInviterPlayerInteractionAction(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Interaction] AskCancelInviterPlayerInteractionAction called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskCancelInviterPlayerInteractio);
		}

		[Handler(MethodId.AskNpcProfileCancelTargetNewStat)]
		public static void HandleAskNpcProfileCancelTargetNewState(Connection conn, UxRpcMessage msg)
		{
			var args = msg.GetArgs<AskNpcProfileCancelTargetNewStateArgs>();
			Console.WriteLine($"[NPC] AskNpcProfileCancelTargetNewState called, profileid={args?.profileid}, target={args?.target}");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskNpcProfileCancelTargetNewStat);
		}

		[Handler(MethodId.AskClearPersonalZoneNewBubbleLik)]
		public static void HandleAskClearPersonalZoneNewBubbleLikes(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Social] AskClearPersonalZoneNewBubbleLikes called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskClearPersonalZoneNewBubbleLik);
		}

		[Handler(MethodId.AskTakeCompetitionSeasonHighestR)]
		public static void HandleAskTakeCompetitionSeasonHighestRankReward(Connection conn, UxRpcMessage msg)
		{
			var args = msg.GetArgs<AskTakeCompetitionSeasonHighestRankRewardArgs>();
			Console.WriteLine($"[Competition] AskTakeCompetitionSeasonHighestRankReward called, rewardid={args?.rewardid}");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskTakeCompetitionSeasonHighestR);
		}

		[Handler(MethodId.AskAddTruckOrderSpecialPointRewa_2)]
		public static void HandleAskAddTruckOrderSpecialPointRewards(Connection conn, UxRpcMessage msg)
		{
			var args = msg.GetArgs<AskAddTruckOrderSpecialPointRewardsArgs>();
			Console.WriteLine($"[Truck] AskAddTruckOrderSpecialPointRewards called, orderids count={args?.orderids?.Count ?? 0}, pointid={args?.pointid}");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskAddTruckOrderSpecialPointRewa_2);
		}

		[Handler(MethodId.AskReplyInvitePlayerInteractionA)]
		public static void HandleAskReplyInvitePlayerInteractionAction(Connection conn, UxRpcMessage msg)
		{
			var args = msg.GetArgs<AskReplyInvitePlayerInteractionActionArgs>();
			Console.WriteLine($"[Interaction] AskReplyInvitePlayerInteractionAction called, isaccept={args?.isaccept}");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskReplyInvitePlayerInteractionA);
		}

		[Handler(MethodId.AskMallSetCommoditySpiritDisplay)]
		public static void HandleAskMallSetCommoditySpiritDisplayPreferences(Connection conn, UxRpcMessage msg)
		{
			var args = msg.GetArgs<AskMallSetCommoditySpiritDisplayPreferencesArgs>();
			Console.WriteLine($"[Mall] AskMallSetCommoditySpiritDisplayPreferences called, spiritids count={args?.spiritidlist?.Count ?? 0}");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskMallSetCommoditySpiritDisplay);
		}

		[Handler(MethodId.AskGravityLand)]
		public static void HandleAskGravityLand(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Movement] AskGravityLand called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskGravityLand);
		}

		[Handler(MethodId.AskGravitySuspend)]
		public static void HandleAskGravitySuspend(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Movement] AskGravitySuspend called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskGravitySuspend);
		}

		[Handler(MethodId.AskUseItems)]
		public static void HandleAskUseItems(Connection conn, UxRpcMessage msg)
		{
			// Use consumible item — no known args signature [NO SIGNATURE]
			// Would: parse itemId, find in PackItems, decrement count, apply healing/buff, sync
			Console.WriteLine("[Item] AskUseItems → consumible use (no impl)");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskUseItems);
		}

		[Handler(MethodId.AskPickupDestructible)]
		public static void HandleAskPickupDestructible(Connection conn, UxRpcMessage msg)
		{
			// Pickup broken destructible as item — no known args signature [NO SIGNATURE]
			// Would: lookup DropConfig for destructible, add items to inventory, sync
			Console.WriteLine("[Item] AskPickupDestructible → loot destructible (no impl)");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskPickupDestructible);
		}

		[Handler(MethodId.AskDiscardWeapon)]
		public static void HandleAskDiscardWeapon(Connection conn, UxRpcMessage msg)
		{
			try
			{
				var args = msg.GetArgs<AskDiscardWeaponArgs>();
				int removed = conn.Weapons.RemoveAll(w => w.InstanceId == args.instanceId);
				if (removed > 0)
				{
					Console.WriteLine($"[Weapon] Discarded weapon instanceId={args.instanceId} ({removed} removed)");
					if (conn.WeaponIndex >= conn.Weapons.Count)
						conn.WeaponIndex = Math.Max(0, conn.Weapons.Count - 1);
					conn.SyncWeapons();
				}
				else
				{
					Console.WriteLine($"[Weapon] Discard failed: weapon instanceId={args.instanceId} not found");
				}
			}
			catch (Exception ex)
			{
				Console.WriteLine($"[Weapon] Discard error: {ex.Message}");
			}
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskDiscardWeapon);
		}

		[Handler(MethodId.AskFeiSuoSuccess)]
		public static void HandleAskFeiSuoSuccess(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Movement] AskFeiSuoSuccess called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskFeiSuoSuccess);
		}

		// AskHack and AskHackingNpc handled in ClientToGameserver.SaimoHack.cs

		[Handler(MethodId.AskFinishHackingKeyFrame)]
		public static void HandleAskFinishHackingKeyFrame(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Hack] AskFinishHackingKeyFrame called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskFinishHackingKeyFrame);
		}

		[Handler(MethodId.AskStartBVBGame)]
		public static void HandleAskStartBVBGame(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[BVB] AskStartBVBGame called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskStartBVBGame);
		}

		[Handler(MethodId.AskExitBVBGame)]
		public static void HandleAskExitBVBGame(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[BVB] AskExitBVBGame called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskExitBVBGame);
		}

		[Handler(MethodId.AskLeaveGame)]
		public static void HandleAskLeaveGame(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Game] AskLeaveGame called — disconnecting player");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskLeaveGame);
			conn.Disconnect();
		}

		[Handler(MethodId.AskChangeMapPin)]
		public static void HandleAskChangeMapPin(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Map] AskChangeMapPin called");
			// Change map pin - for private server, just acknowledge
			// In full implementation, would update player's map pins and sync
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskChangeMapPin);
		}

		[Handler(MethodId.AskPutMapPin)]
		public static void HandleAskPutMapPin(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Map] AskPutMapPin called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskPutMapPin);
		}

		[Handler(MethodId.AskRemoveMapPin)]
		public static void HandleAskRemoveMapPin(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Map] AskRemoveMapPin called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskRemoveMapPin);
		}

		[Handler(MethodId.AskTwitterPageOpen)]
		public static void HandleAskTwitterPageOpen(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Social] AskTwitterPageOpen called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskTwitterPageOpen);
		}

		[Handler(MethodId.AskTwitterPageClose)]
		public static void HandleAskTwitterPageClose(Connection conn, UxRpcMessage msg)
		{
			Console.WriteLine("[Social] AskTwitterPageClose called");
			HandlerUtils.SendEmptySuccessReturn(conn, msg, MethodId.AskTwitterPageClose);
		}

	}

	// Args classes for generated handlers
	public class AskCancelInteractionActionRedPointArgs : SerializedClass
	{
		public uint npcitemid;
		public AskCancelInteractionActionRedPointArgs() { onlyFields = true; }
	}

	public class AskTakeCompetitionSeasonOverallRankRewardArgs : SerializedClass
	{
		public uint rewardid;
		public AskTakeCompetitionSeasonOverallRankRewardArgs() { onlyFields = true; }
	}

	public class AskReadPoliceFakeClueAgentInfoListArgs : SerializedClass
	{
		public List<int> clueagentinfoindexlist;
		public AskReadPoliceFakeClueAgentInfoListArgs() { onlyFields = true; }
	}

	public class AskAddTruckOrderSpecialPointRewardArgs : SerializedClass
	{
		public uint orderid;
		public int pointid;
		public AskAddTruckOrderSpecialPointRewardArgs() { onlyFields = true; }
	}

	public class AskLinkPlanningBoardDividendsPutInKeysArgs : SerializedClass
	{
		public List<KeyCountInfo> keycountinfolist;
		public AskLinkPlanningBoardDividendsPutInKeysArgs() { onlyFields = true; }
	}

	public class AskNpcProfileCancelTargetNewStateArgs : SerializedClass
	{
		public uint profileid;
		public uint target;
		public AskNpcProfileCancelTargetNewStateArgs() { onlyFields = true; }
	}

	public class AskTakeCompetitionSeasonHighestRankRewardArgs : SerializedClass
	{
		public uint rewardid;
		public AskTakeCompetitionSeasonHighestRankRewardArgs() { onlyFields = true; }
	}

	public class AskAddTruckOrderSpecialPointRewardsArgs : SerializedClass
	{
		public List<uint> orderids;
		public int pointid;
		public AskAddTruckOrderSpecialPointRewardsArgs() { onlyFields = true; }
	}

	public class AskReplyInvitePlayerInteractionActionArgs : SerializedClass
	{
		public bool isaccept;
		public AskReplyInvitePlayerInteractionActionArgs() { onlyFields = true; }
	}

	public class AskMallSetCommoditySpiritDisplayPreferencesArgs : SerializedClass
	{
		public List<uint> spiritidlist;
		public AskMallSetCommoditySpiritDisplayPreferencesArgs() { onlyFields = true; }
	}

	public class KeyCountInfo : SerializedClass
	{
		public uint KeyId;
		public uint Count;
	}
}
