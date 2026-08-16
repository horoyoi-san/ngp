using System;
using System.IO;

namespace AnantaTestGameServer
{
    /// <summary>
    /// Dedicated logger for vehicle-related operations.
    /// Writes to a separate file to avoid cluttering the main console.
    /// </summary>
    public static class VehicleLogger
    {
        private static readonly string LogFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "..\\..\\..\\..\\vehicle_debug.log");
        private static readonly object _lock = new object();

        static VehicleLogger()
        {
            // Resolve the full path
            try
            {
                var fullPath = Path.GetFullPath(LogFilePath);
                LogFilePath = fullPath;
                File.WriteAllText(LogFilePath, $"=== Vehicle Debug Log Started at {DateTime.Now:yyyy-MM-dd HH:mm:ss} ===\n\n");
                Console.WriteLine($"[VehicleLogger] Log file: {LogFilePath}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[VehicleLogger] Failed to initialize log file: {ex.Message}");
            }
        }

        public static void Log(string message)
        {
            string logEntry = $"[{DateTime.Now:HH:mm:ss.fff}] {message}";
            
            // Write to file
            lock (_lock)
            {
                try
                {
                    File.AppendAllText(LogFilePath, logEntry + "\n");
                }
                catch { }
            }

            // Also write to console with a distinct prefix
            Console.WriteLine($"[VEHICLE] {message}");
        }

        public static void LogEnterArea(string operation, ulong vehicleId, int areaId = 0)
        {
            Log($"[AREA] {operation}: vehicleId={vehicleId} areaId={areaId}");
        }

        public static void LogEnterExit(string operation, ulong vehicleId, int seatIndex, bool isEntering)
        {
            Log($"[ENTER/EXIT] {operation}: vehicleId={vehicleId} seat={seatIndex} entering={isEntering}");
        }

        public static void LogRpc(string rpcName, string details)
        {
            Log($"[RPC] {rpcName}: {details}");
        }
    }
}
