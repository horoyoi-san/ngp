using AnantaTestGameServer.Configs;

namespace AnantaTestGameServer.Game.State
{
    public static class NpcStateFactory
    {
        public static uint[] BuildNpcFormworkIds()
        {
            if (GameConfig.AllNpcFormworks.Length > 0)
                return GameConfig.AllNpcFormworks;

            return new uint[]
            {
                40923169u, 40923324u, 40924600u, 40924701u,
                40924922u, 40951000u, 40966121u, 40966210u,
                40968615u, 40968618u, 40968628u, 40968659u,
            };
        }

        public static uint[] BuildAutoSpawnNpcIds()
        {
            if (GameConfig.AutoSpawnNpcIds.Length > 0)
                return GameConfig.AutoSpawnNpcIds;

            return new uint[]
            {
                40924922u, 40966121u, 40966210u,
                40968615u, 40968618u, 40968628u, 40968659u,
            };
        }
    }
}
