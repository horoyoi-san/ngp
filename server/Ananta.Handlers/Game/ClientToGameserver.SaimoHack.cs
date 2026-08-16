using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req;

internal partial class ClientToGameserver
{
	private const uint SaimoSpiritId = 15021023u;
	private const uint SaimoTestNpcFormworkId = 40968618u;
	private const uint SaimoTestNpcPersonaId = 45200058u;

	private const int AskHackMethodId = 63359217;
	private const int SyncHackerBatteryCurrentAndTotalCountMethodId = 64128323;
	private const int AskHackingNpcMethodId = 67239192;
	private const int AskHackingNpcPressMethodId = 67527445;

	private static readonly uint[] SaimoHackTextIds =
	{
		74003210u, // Message
		74003211u, // Listen Call
		74003212u, // Phone Ringing
		74003213u, // Phone Music
		74003323u, // Money
		74003324u  // Fans
	};

	private static readonly uint[] SaimoHackAbilityBuffIds =
	{
		52606135u, // Message
		52606136u, // Listen Call
		52606137u, // Phone Ringing
		52606138u, // Phone Music
		52606161u, // Money
		52606162u  // Fans
	};

	private sealed class AskHackArgs : SerializedClass
	{
		public uint hacktype;

		public AskHackArgs()
		{
			onlyFields = true;
		}
	}

	private sealed class AskHackingNpcPressArgs : SerializedClass
	{
		public ulong instanceid;

		public AskHackingNpcPressArgs()
		{
			onlyFields = true;
		}
	}

	private sealed class AskHackingNpcArgs : SerializedClass
	{
		public ulong instanceid;
		public int index;

		public AskHackingNpcArgs()
		{
			onlyFields = true;
		}
	}

	private sealed class HackerBatteryCurrentAndTotalCount : SerializedClass
	{
		public uint BatteryTotalCount;
		public uint BatteryCurrentCount;
	}

	private sealed class StaticNpcInstanceIdArgs : SerializedClass
	{
		public ulong npcInstanceId;

		public StaticNpcInstanceIdArgs()
		{
			onlyFields = true;
		}
	}

	private static void SyncSaimoHackState(Connection conn, bool spawnTestNpc)
	{
		if (conn.currentSpirit != SaimoSpiritId || conn.GetCurrentSpirit() == null)
		{
			return;
		}

		SyncSaimoHackBattery(conn);

		Console.WriteLine(
			$"[SaimoHack] ready spirit={conn.GetCurrentSpirit().Id} " +
			$"targetGates=52606133,52606134 " +
			$"actions={string.Join(",", SaimoHackAbilityBuffIds)}");

		if (!spawnTestNpc)
		{
			return;
		}

		_ = Task.Run(async () =>
		{
			await Task.Delay(700);
			if (conn.currentSpirit != SaimoSpiritId)
			{
				return;
			}

			conn.SyncBuffs();
			SyncSaimoHackBattery(conn);

			lock (conn)
			{
				if (conn.SaimoHackNpcEntityId != 0uL)
				{
					return;
				}

				SpawnSaimoHackTestNpc(conn, forceNew: false);
			}
		});
	}

	private static void SyncSaimoHackBattery(Connection conn)
	{
		if (conn.currentSpirit != SaimoSpiritId)
		{
			return;
		}

		UxRpcMessage sync = new UxRpcMessage
		{
			Mode = UxRpcPacketMode.Notify,
			RpcInvokeId = 0,
			RpcRetcode = 0u,
			RpcMethodId = SyncHackerBatteryCurrentAndTotalCountMethodId
		};
		sync.SetArgs(
			SyncHackerBatteryCurrentAndTotalCountMethodId,
			new HackerBatteryCurrentAndTotalCount
			{
				BatteryTotalCount = 6u,
				BatteryCurrentCount = 6u
			});
		conn.SendPacket(sync);
		Console.WriteLine("[SaimoHack] battery synced 6/6");
	}

	private static void EnsureSaimoAetherInitialized(Connection conn)
	{
		if (conn.SaimoAetherInitialized)
		{
			return;
		}

		UxRpcMessage init = new UxRpcMessage
		{
			Mode = UxRpcPacketMode.Notify,
			RpcInvokeId = 0,
			RpcRetcode = 0u,
			RpcMethodId = (int)MethodId.SyncAetherAIInitDatas
		};
		init.SetArgs(MethodId.SyncAetherAIInitDatas, new AetherAIInitData
		{
			RaidId = 0u,
			HasZoneGraph = true,
			ZoneStorageDataHandle = 0,
			Intersections = new List<ClientTrafficIntersectionInitInfo>(),
			Crowds = new List<ClientCrowdInitData>(),
			StaticNpcs = new List<ClientStaticNpcInitData>(),
			Vehicles = new List<ClientVehicleInitData>(),
			StaticVehicles = new List<ClientStaticVehicleInitData>(),
			VehicleNpcs = new List<ClientVehicleNpcInitData>(),
			MetroNpcs = new List<ClientMetroNpcInitData>()
		});
		conn.SendPacket(init);
		conn.SaimoAetherInitialized = true;
		Console.WriteLine("[SaimoHack] Aether AI initialized");
	}

	private static ulong SpawnSaimoHackTestNpc(Connection conn, bool forceNew)
	{
		if (!forceNew && conn.SaimoHackNpcEntityId != 0uL)
		{
			return conn.SaimoHackNpcEntityId;
		}

		EnsureSaimoAetherInitialized(conn);

		ulong npcEntityId = (ulong)Random.Shared.NextInt64(1000000000L, long.MaxValue);
		UXVector3 origin = conn.LastKnownPlayerPosition;
		ClientStaticNpcInitData npc = new ClientStaticNpcInitData
		{
			Position = new UXVector3
			{
				X = origin.X + 3f,
				Y = origin.Y,
				Z = origin.Z + 1f
			},
			Facing = 180f,
			Id = npcEntityId,
			StaticNpcInfoId = npcEntityId,
			AgentPersonaId = SaimoTestNpcPersonaId,
			NpcPid = 41739060,
			UrbanDiversityId = 88888000u,
			NpcFormworkId = SaimoTestNpcFormworkId,
			PoiActionId = 0u,
			IgnoreAllStim = false,
			TaskRelated = false,
			EnableHack = true,
			LookAtDecisionRulesId = 0u,
			ForceGo = false,
			SourceType = ClientStaticNpcInitData.StaticNpcSourceType.None,
			AgentSyncClientInfo = new AgentSyncClientInfo
			{
				stimIDList = Array.Empty<int>(),
				CanBeExaminedByPolice = true,
				indoorList = new List<uint>(),
				roomIds = Array.Empty<int>(),
				SpoonAgentId = 0,
				treeName = string.Empty,
				petPerformData = string.Empty,
				spawnEffectId = Array.Empty<uint>(),
				randomModelCfgId = 0u,
				LeaveDistance = 10000,
				approachDistance = 10000,
				FashionSuitId = 11190001u
			}
		};

		UxRpcMessage addNpc = new UxRpcMessage
		{
			Mode = UxRpcPacketMode.Notify,
			RpcInvokeId = 0,
			RpcRetcode = 0u,
			RpcMethodId = (int)MethodId.SyncAetherAIStaticNpcAddData
		};
		addNpc.SetArgs(MethodId.SyncAetherAIStaticNpcAddData, npc);
		conn.SendPacket(addNpc);
		conn.SaimoHackNpcEntityId = npcEntityId;

		Console.WriteLine(
			$"[SaimoHack] spawned hackable pedestrian entity={npcEntityId} " +
			$"formwork={SaimoTestNpcFormworkId} enableHack=true " +
			$"pos=({npc.Position.X},{npc.Position.Y},{npc.Position.Z})");

		_ = Task.Run(async () =>
		{
			await Task.Delay(500);
			if (conn.currentSpirit != SaimoSpiritId)
			{
				return;
			}

			UxRpcMessage convert = new UxRpcMessage
			{
				Mode = UxRpcPacketMode.Notify,
				RpcInvokeId = 0,
				RpcRetcode = 0u,
				RpcMethodId = (int)MethodId.SyncAetherAIStaticNpcConvertToPe
			};
			convert.SetArgs(
				MethodId.SyncAetherAIStaticNpcConvertToPe,
				new StaticNpcInstanceIdArgs
				{
					npcInstanceId = npcEntityId
				});
			conn.SendPacket(convert);
			Console.WriteLine(
				$"[SaimoHack] converted static NPC to pedestrian entity={npcEntityId}");
		});

		return npcEntityId;
	}

	private static void SendEmptyOkReturn(Connection conn, UxRpcMessage msg, int methodId)
	{
		UxRpcMessage rsp = new UxRpcMessage
		{
			Mode = UxRpcPacketMode.Return,
			RpcInvokeId = msg.RpcInvokeId,
			RpcRetcode = 0u,
			RpcMethodId = methodId
		};
		conn.SendPacket(rsp);
	}

	[Handler(AskHackMethodId)]
	public static void AskHackHandler(Connection conn, UxRpcMessage msg)
	{
		uint hackType = 0u;
		try
		{
			hackType = msg.GetArgs<AskHackArgs>().hacktype;
		}
		catch (Exception e)
		{
			Console.WriteLine($"[SaimoHack] AskHack parse failed: {e.Message}");
		}

		Console.WriteLine(
			$"[SaimoHack] AskHack type={hackType} spirit={conn.currentSpirit}");
		SendEmptyOkReturn(conn, msg, AskHackMethodId);
		SyncSaimoHackBattery(conn);
	}

	[Handler(AskHackingNpcPressMethodId)]
	public static void AskHackingNpcPressHandler(Connection conn, UxRpcMessage msg)
	{
		ulong target = 0uL;
		try
		{
			target = msg.GetArgs<AskHackingNpcPressArgs>().instanceid;
		}
		catch (Exception e)
		{
			Console.WriteLine(
				$"[SaimoHack] AskHackingNpcPress parse failed: {e.Message}");
		}

		Console.WriteLine(
			$"[SaimoHack] press target={target} spirit={conn.currentSpirit}");
		SendEmptyOkReturn(conn, msg, AskHackingNpcPressMethodId);
	}

	[Handler(AskHackingNpcMethodId)]
	public static void AskHackingNpcHandler(Connection conn, UxRpcMessage msg)
	{
		ulong target = 0uL;
		int index = 0;
		try
		{
			AskHackingNpcArgs args = msg.GetArgs<AskHackingNpcArgs>();
			target = args.instanceid;
			index = args.index;
		}
		catch (Exception e)
		{
			Console.WriteLine(
				$"[SaimoHack] AskHackingNpc parse failed: {e.Message}");
		}

		string option = index >= 0 && index < SaimoHackTextIds.Length
			? $"textId={SaimoHackTextIds[index]} buff={SaimoHackAbilityBuffIds[index]}"
			: "unknown option";
		Console.WriteLine(
			$"[SaimoHack] execute target={target} option={index} {option} " +
			$"spirit={conn.currentSpirit}");
		SendEmptyOkReturn(conn, msg, AskHackingNpcMethodId);
	}

	// AskStealNPCMoney and AskStealNPCFan are handled in ClientToGameserver.cs
}

