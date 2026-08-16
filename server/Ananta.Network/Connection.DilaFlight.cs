using System;
using System.Collections.Generic;
using AnantaTestGameServer.Methods.Return;

namespace AnantaTestGameServer;

public partial class Connection
{
	internal const uint DilaSpiritTemplateId = 15020997u;

	private static readonly uint[] DilaFlightBuffIds =
	{
		52606125u // FloatFlight
	};

	private void AppendDilaFlightBuffs(
		List<BuffViewData> buffs,
		SpiritInfo spirit)
	{
		if (currentSpirit != DilaSpiritTemplateId)
		{
			return;
		}

		for (int i = 0; i < DilaFlightBuffIds.Length; i++)
		{
			buffs.Add(new BuffViewData
			{
				Id = DilaFlightBuffIds[i],
				InstanceId = 1003400u + (uint)i,
				ReleaserId = spirit.Id,
				ExpireTime = 0.0,
				Permanent = true,
				Tier = 1u
			});
		}

		Console.WriteLine(
			$"[DilaFlight] syncing FloatFlight buff=52606125 " +
			$"parkourState=10051 spirit={spirit.Id}");
	}
}
