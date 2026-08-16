using System;
using System.Collections.Generic;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;

namespace AnantaTestGameServer.Game.Metro
{
    /// <summary>
    /// Waypoint-based metro path system supporting complex topologies.
    /// Features:
    /// - Real waypoints instead of circular approximation
    /// - CatmullRom spline interpolation for smooth curves
    /// - Multiple sub-lines (bidirectional, branching)
    /// - Vertical paths and floating cabin support
    /// </summary>
    public static class MetroPathSystem
    {
        // ======================== PATH DATA STRUCTURES ========================

        /// <summary>
        /// Single waypoint in a metro path
        /// </summary>
        public class Waypoint
        {
            public UXVector3 Position;
            public bool IsStation;
            public int StationIndex;
            public float Progress; // 0-1 along the path

            public Waypoint(UXVector3 pos, bool isStation = false, int stationIdx = -1, float progress = 0f)
            {
                Position = pos;
                IsStation = isStation;
                StationIndex = stationIdx;
                Progress = progress;
            }
        }

        /// <summary>
        /// A complete metro line path with waypoints
        /// </summary>
        public class MetroLinePath
        {
            public uint LineId;
            public string DisplayName;
            public List<Waypoint> Waypoints;
            public bool IsLooped;
            public bool IsVertical; // For floating cabin lines
            public float CycleSeconds;
            public float MaxSpeed;
            public float Acceleration;

            public MetroLinePath(uint lineId, string displayName, bool isLooped = true, bool isVertical = false)
            {
                LineId = lineId;
                DisplayName = displayName;
                Waypoints = new List<Waypoint>();
                IsLooped = isLooped;
                IsVertical = isVertical;
                CycleSeconds = 300f;
                MaxSpeed = 20f;
                Acceleration = 5f;
            }

            /// <summary>
            /// Get position along the path at a given progress (0-1)
            /// </summary>
            public UXVector3 GetPositionAtProgress(float progress)
            {
                if (Waypoints.Count == 0)
                    return new UXVector3 { X = 0, Y = 0, Z = 0 };

                if (Waypoints.Count == 1)
                    return Waypoints[0].Position;

                // Find the segment containing this progress
                float segmentLength = 1f / (Waypoints.Count - 1);
                int segmentIndex = (int)(progress / segmentLength);
                if (segmentIndex >= Waypoints.Count - 1)
                    segmentIndex = Waypoints.Count - 2;

                float segmentProgress = (progress - segmentIndex * segmentLength) / segmentLength;

                // CatmullRom interpolation for smooth curves
                return CatmullRomInterpolate(
                    Waypoints[Math.Max(0, segmentIndex - 1)].Position,
                    Waypoints[segmentIndex].Position,
                    Waypoints[Math.Min(Waypoints.Count - 1, segmentIndex + 1)].Position,
                    Waypoints[Math.Min(Waypoints.Count - 1, segmentIndex + 2)].Position,
                    segmentProgress
                );
            }

            /// <summary>
            /// Get facing direction at a given progress
            /// </summary>
            public float GetFacingAtProgress(float progress)
            {
                float delta = 0.01f;
                float nextProgress = Math.Min(1f, progress + delta);
                UXVector3 currentPos = GetPositionAtProgress(progress);
                UXVector3 nextPos = GetPositionAtProgress(nextProgress);

                float dx = nextPos.X - currentPos.X;
                float dz = nextPos.Z - currentPos.Z;
                float dy = nextPos.Y - currentPos.Y;

                // For vertical lines, use Y for facing
                if (IsVertical)
                {
                    return (float)(Math.Atan2(dy, Math.Sqrt(dx * dx + dz * dz)) * 180f / Math.PI);
                }

                return (float)(Math.Atan2(dx, dz) * 180f / Math.PI);
            }

            /// <summary>
            /// Get speed at a given progress (can vary based on stations)
            /// </summary>
            public float GetSpeedAtProgress(float progress)
            {
                // Slow down near stations
                foreach (var wp in Waypoints)
                {
                    if (wp.IsStation && Math.Abs(progress - wp.Progress) < 0.05f)
                        return MaxSpeed * 0.3f; // 30% speed near stations
                }
                return MaxSpeed;
            }
        }

        /// <summary>
        /// Sub-line definition (for bidirectional or branching lines)
        /// </summary>
        public class SubLine
        {
            public uint SubLineId;
            public string DisplayName;
            public MetroLinePath Path;
            public uint ParentLineId;
            public List<uint> BranchPoints; // Progress values where this branches
            public bool IsReverseDirection;

            public SubLine(uint subLineId, string displayName, MetroLinePath path, uint parentLineId = 0)
            {
                SubLineId = subLineId;
                DisplayName = displayName;
                Path = path;
                ParentLineId = parentLineId;
                BranchPoints = new List<uint>();
                IsReverseDirection = false;
            }
        }

        // ======================== CATMULL-ROM INTERPOLATION ========================

        /// <summary>
        /// CatmullRom spline interpolation for smooth curves
        /// </summary>
        private static UXVector3 CatmullRomInterpolate(UXVector3 p0, UXVector3 p1, UXVector3 p2, UXVector3 p3, float t)
        {
            float t2 = t * t;
            float t3 = t2 * t;

            return new UXVector3
            {
                X = 0.5f * ((2f * p1.X) + (-p0.X + p2.X) * t + (2f * p0.X - 5f * p1.X + 4f * p2.X - p3.X) * t2 + (-p0.X + 3f * p1.X - 3f * p2.X + p3.X) * t3),
                Y = 0.5f * ((2f * p1.Y) + (-p0.Y + p2.Y) * t + (2f * p0.Y - 5f * p1.Y + 4f * p2.Y - p3.Y) * t2 + (-p0.Y + 3f * p1.Y - 3f * p2.Y + p3.Y) * t3),
                Z = 0.5f * ((2f * p1.Z) + (-p0.Z + p2.Z) * t + (2f * p0.Z - 5f * p1.Z + 4f * p2.Z - p3.Z) * t2 + (-p0.Z + 3f * p1.Z - 3f * p2.Z + p3.Z) * t3)
            };
        }

        // ======================== LINE DEFINITIONS ========================

        private static Dictionary<uint, MetroLinePath> _mainLines = new Dictionary<uint, MetroLinePath>();
        private static Dictionary<uint, List<SubLine>> _subLines = new Dictionary<uint, List<SubLine>>();

        static MetroPathSystem()
        {
            InitializeDefaultLines();
        }

        /// <summary>
        /// Initialize default metro lines with placeholder waypoints
        /// These should be replaced with real data extracted from game bundles
        /// </summary>
        private static void InitializeDefaultLines()
        {
            // Line 1: Yellow/Central - Single direction loop
            var line1 = new MetroLinePath(1, "Central Line (Yellow)", isLooped: true, isVertical: false);
            line1.CycleSeconds = 300f;
            // Placeholder waypoints - should be replaced with real data
            for (int i = 0; i < 8; i++)
            {
                float angle = (i / 8f) * 2f * (float)Math.PI;
                line1.Waypoints.Add(new Waypoint(new UXVector3
                {
                    X = 1000f + (float)Math.Cos(angle) * 300f,
                    Y = 0f,
                    Z = 2000f + (float)Math.Sin(angle) * 300f
                }, isStation: true, stationIdx: i, progress: i / 7f));
            }
            _mainLines[1] = line1;

            // Line 2: Green/Bayshore - Bidirectional with branching
            var line2Forward = new MetroLinePath(2, "Bayshore Line (Green) - Forward", isLooped: false, isVertical: false);
            line2Forward.CycleSeconds = 300f;
            // Placeholder waypoints for forward direction
            line2Forward.Waypoints.Add(new Waypoint(new UXVector3 { X = 1200, Y = 0, Z = 2200 }, isStation: true, stationIdx: 0, progress: 0f));
            line2Forward.Waypoints.Add(new Waypoint(new UXVector3 { X = 1400, Y = 0, Z = 2400 }, isStation: true, stationIdx: 1, progress: 0.33f));
            line2Forward.Waypoints.Add(new Waypoint(new UXVector3 { X = 1600, Y = 0, Z = 2600 }, isStation: true, stationIdx: 2, progress: 0.66f));
            line2Forward.Waypoints.Add(new Waypoint(new UXVector3 { X = 1800, Y = 0, Z = 2800 }, isStation: true, stationIdx: 3, progress: 1f));
            _mainLines[2] = line2Forward;

            // Reverse direction as sub-line
            var line2Reverse = new MetroLinePath(20, "Bayshore Line (Green) - Reverse", isLooped: false, isVertical: false);
            line2Reverse.CycleSeconds = 300f;
            line2Reverse.Waypoints.Add(new Waypoint(new UXVector3 { X = 1800, Y = 0, Z = 2800 }, isStation: true, stationIdx: 3, progress: 0f));
            line2Reverse.Waypoints.Add(new Waypoint(new UXVector3 { X = 1600, Y = 0, Z = 2600 }, isStation: true, stationIdx: 2, progress: 0.33f));
            line2Reverse.Waypoints.Add(new Waypoint(new UXVector3 { X = 1400, Y = 0, Z = 2400 }, isStation: true, stationIdx: 1, progress: 0.66f));
            line2Reverse.Waypoints.Add(new Waypoint(new UXVector3 { X = 1200, Y = 0, Z = 2200 }, isStation: true, stationIdx: 0, progress: 1f));

            _subLines[2] = new List<SubLine>
            {
                new SubLine(20, "Bayshore Reverse", line2Reverse, 2) { IsReverseDirection = true }
            };

            // Line 3: Blue Tram - Vertical with floating cabin
            var line3 = new MetroLinePath(3, "Blue Tram Line", isLooped: false, isVertical: true);
            line3.CycleSeconds = 240f;
            line3.MaxSpeed = 15f; // Slower for vertical movement
            // Vertical waypoints (Y varies significantly)
            line3.Waypoints.Add(new Waypoint(new UXVector3 { X = 1400, Y = 0, Z = 2200 }, isStation: true, stationIdx: 0, progress: 0f));
            line3.Waypoints.Add(new Waypoint(new UXVector3 { X = 1400, Y = 50, Z = 2200 }, isStation: true, stationIdx: 1, progress: 0.25f));
            line3.Waypoints.Add(new Waypoint(new UXVector3 { X = 1400, Y = 100, Z = 2200 }, isStation: true, stationIdx: 2, progress: 0.5f));
            line3.Waypoints.Add(new Waypoint(new UXVector3 { X = 1400, Y = 150, Z = 2200 }, isStation: true, stationIdx: 3, progress: 0.75f));
            line3.Waypoints.Add(new Waypoint(new UXVector3 { X = 1400, Y = 200, Z = 2200 }, isStation: true, stationIdx: 4, progress: 1f));
            _mainLines[3] = line3;

            // Line 4: EAT Line 3 - Simple single line
            var line4 = new MetroLinePath(4, "EAT Line 3", isLooped: true, isVertical: false);
            line4.CycleSeconds = 240f;
            for (int i = 0; i < 6; i++)
            {
                float angle = (i / 6f) * 2f * (float)Math.PI;
                line4.Waypoints.Add(new Waypoint(new UXVector3
                {
                    X = 1600f + (float)Math.Cos(angle) * 350f,
                    Y = 0f,
                    Z = 2400f + (float)Math.Sin(angle) * 350f
                }, isStation: true, stationIdx: i, progress: i / 5f));
            }
            _mainLines[4] = line4;
        }

        // ======================== PUBLIC API ========================

        /// <summary>
        /// Get a metro line path by ID
        /// </summary>
        public static MetroLinePath GetLinePath(uint lineId)
        {
            if (_mainLines.TryGetValue(lineId, out var path))
                return path;
            return null;
        }

        /// <summary>
        /// Get all sub-lines for a parent line
        /// </summary>
        public static List<SubLine> GetSubLines(uint parentLineId)
        {
            if (_subLines.TryGetValue(parentLineId, out var subLines))
                return subLines;
            return new List<SubLine>();
        }

        /// <summary>
        /// Get a specific sub-line
        /// </summary>
        public static SubLine GetSubLine(uint subLineId)
        {
            foreach (var kvp in _subLines)
            {
                foreach (var subLine in kvp.Value)
                {
                    if (subLine.SubLineId == subLineId)
                        return subLine;
                }
            }
            return null;
        }

        /// <summary>
        /// Add or update a metro line path
        /// </summary>
        public static void SetLinePath(MetroLinePath path)
        {
            _mainLines[path.LineId] = path;
        }

        /// <summary>
        /// Add a sub-line to a parent line
        /// </summary>
        public static void AddSubLine(uint parentLineId, SubLine subLine)
        {
            if (!_subLines.ContainsKey(parentLineId))
                _subLines[parentLineId] = new List<SubLine>();
            _subLines[parentLineId].Add(subLine);
        }

        /// <summary>
        /// Get all active line IDs
        /// </summary>
        public static HashSet<uint> GetAllLineIds()
        {
            return new HashSet<uint>(_mainLines.Keys);
        }
    }
}
