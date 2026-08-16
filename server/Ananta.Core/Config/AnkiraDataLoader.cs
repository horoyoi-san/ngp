using System;
using System.IO;

namespace AnantaTestGameServer
{
    /// <summary>
    /// Loads pre-recorded binary data from ANKIRA server captures.
    /// These blobs are serialized in the same UX RPC format and can be sent directly.
    /// Source: ANKIRA-clean-share/assets/data/ (captured from real server)
    /// </summary>
    public static class AnkiraDataLoader
    {
        private static readonly string DataDir = Path.Combine(AppContext.BaseDirectory, "data");

        private static byte[]? _loginGameSyncPlayerInfo;
        private static byte[]? _loginGameSyncPlayerAllTask;
        private static byte[]? _loginGameSyncEnterScene;
        private static byte[]? _loadingFinishedSyncUnitAttrs;
        private static byte[]? _loadingFinishedSyncSpiritWeaponDetail;
        private static byte[]? _loadingFinishedSyncCurrentTask;
        private static byte[]? _requestPatchesFromLogin;

        /// <summary>login_game_sync_player_info.bin (7580 bytes) - Full player info blob</summary>
        public static byte[] LoginGameSyncPlayerInfo => LoadOrEmpty(ref _loginGameSyncPlayerInfo, "login_game_sync_player_info.bin");

        /// <summary>login_game_sync_player_all_task.bin (140 bytes) - All task data</summary>
        public static byte[] LoginGameSyncPlayerAllTask => LoadOrEmpty(ref _loginGameSyncPlayerAllTask, "login_game_sync_player_all_task.bin");

        /// <summary>login_game_sync_enter_scene.bin (460 bytes) - Enter scene data (positions, grid, spirits)</summary>
        public static byte[] LoginGameSyncEnterScene => LoadOrEmpty(ref _loginGameSyncEnterScene, "login_game_sync_enter_scene.bin");

        /// <summary>loading_finished_sync_unit_attrs.bin (789 bytes) - 97 unit attributes all=1.0</summary>
        public static byte[] LoadingFinishedSyncUnitAttrs => LoadOrEmpty(ref _loadingFinishedSyncUnitAttrs, "loading_finished_sync_unit_attrs.bin");

        /// <summary>loading_finished_sync_spirit_weapon_detail.bin (321 bytes) - Spirit weapon inventory</summary>
        public static byte[] LoadingFinishedSyncSpiritWeaponDetail => LoadOrEmpty(ref _loadingFinishedSyncSpiritWeaponDetail, "loading_finished_sync_spirit_weapon_detail.bin");

        /// <summary>loading_finished_sync_current_task.bin (49 bytes) - Current task state</summary>
        public static byte[] LoadingFinishedSyncCurrentTask => LoadOrEmpty(ref _loadingFinishedSyncCurrentTask, "loading_finished_sync_current_task.bin");

        /// <summary>request_patches_from_login.bin (63149 bytes) - Login patch data</summary>
        public static byte[] RequestPatchesFromLogin => LoadOrEmpty(ref _requestPatchesFromLogin, "request_patches_from_login.bin");

        private static byte[] LoadOrEmpty(ref byte[]? cache, string filename)
        {
            if (cache != null) return cache;

            string path = Path.Combine(DataDir, filename);
            if (File.Exists(path))
            {
                cache = File.ReadAllBytes(path);
                Console.WriteLine($"[AnkiraDataLoader] Loaded {filename} ({cache.Length} bytes)");
            }
            else
            {
                Console.WriteLine($"[AnkiraDataLoader] WARNING: {filename} not found at {path}");
                cache = Array.Empty<byte>();
            }
            return cache;
        }

        /// <summary>
        /// Reload all data from disk (useful for hot-reload during development)
        /// </summary>
        public static void Reload()
        {
            _loginGameSyncPlayerInfo = null;
            _loginGameSyncPlayerAllTask = null;
            _loginGameSyncEnterScene = null;
            _loadingFinishedSyncUnitAttrs = null;
            _loadingFinishedSyncSpiritWeaponDetail = null;
            _loadingFinishedSyncCurrentTask = null;
            _requestPatchesFromLogin = null;
            Console.WriteLine("[AnkiraDataLoader] All data cleared, will reload on next access");
        }
    }
}
