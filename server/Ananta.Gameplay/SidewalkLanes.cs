using System;
using System.Collections.Generic;
using System.IO;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using Newtonsoft.Json;

namespace AnantaTestGameServer.Game
{
    // ZoneGraph pedestrian lanes (tag&8) dumped from the client's ZoneGraphStorage.
    // data/sidewalk_lanes.json = { "lanes": [ [x,y,z, x,y,z, ...], ... ] }.
    public static class SidewalkLanes
    {
        const float CELL = 40f;
        const float JoinDist2 = 64f;  // lane endpoints within 8u are connected
        const float VCELL = 18f;      // anti-loop grid: a route may not re-enter a walked cell

        private static List<float[]> s_lanes;                      // lane idx -> flat [x,y,z,...]
        private static float[] s_midX, s_midZ;                     // lane midpoints
        private static Dictionary<(int, int), List<int>> s_grid;   // cell -> lane idxs (by midpoint)

        public static int LaneCount => s_lanes?.Count ?? 0;
        private sealed class LaneFile { public List<float[]> lanes; }

        public static void Load()
        {
            if (s_lanes != null) return;
            s_lanes = new(); s_grid = new();
            try
            {
                string path = Path.Combine(AppContext.BaseDirectory, "data", "sidewalk_lanes.json");
                if (!File.Exists(path))
                {
                    Console.WriteLine("[Lanes] sidewalk_lanes.json not found, skipping lane loading");
                    return;
                }
                
                var f = JsonConvert.DeserializeObject<LaneFile>(File.ReadAllText(path));
                s_lanes = f?.lanes ?? new();
                int rawCount = s_lanes.Count;
                s_lanes = FilterRoadRunning(s_lanes, out int roadDropped);
                s_midX = new float[s_lanes.Count];
                s_midZ = new float[s_lanes.Count];
                for (int i = 0; i < s_lanes.Count; i++)
                {
                    var c = s_lanes[i];
                    if (c.Length < 6) continue;
                    float mx = 0, mz = 0; int n = c.Length / 3;
                    for (int p = 0; p < c.Length; p += 3) { mx += c[p]; mz += c[p + 2]; }
                    mx /= n; mz /= n;
                    s_midX[i] = mx; s_midZ[i] = mz;
                    var k = ((int)MathF.Floor(mx / CELL), (int)MathF.Floor(mz / CELL));
                    if (!s_grid.TryGetValue(k, out var l)) { l = new(); s_grid[k] = l; }
                    l.Add(i);
                }
                Console.WriteLine($"[Lanes] Loaded {s_lanes.Count} sidewalk lanes ({roadDropped} road-running dropped of {rawCount}).");
            }
            catch (Exception e) { Console.WriteLine($"[Lanes] load failed: {e.Message}"); }
        }

        const float RoadOnDist2 = 3.5f * 3.5f;   // midpoint within this of a road segment = on the road
        const float ParallelCos = 0.8f;          // |cos| vs road above this = running along it

        // Drop lanes that are on the road (<3.5u) AND parallel to it (mislabeled road lanes). Offset
        // sidewalks and perpendicular crossings are kept.
        static List<float[]> FilterRoadRunning(List<float[]> lanes, out int dropped)
        {
            dropped = 0;
            var roadPath = Path.Combine(AppContext.BaseDirectory, "data", "road_lanes.json");
            if (!File.Exists(roadPath)) return lanes;
            List<float[]> roads;
            try { roads = JsonConvert.DeserializeObject<LaneFile>(File.ReadAllText(roadPath))?.lanes ?? new(); }
            catch { return lanes; }

            const float RC = 10f;
            var rgrid = new Dictionary<(int, int), List<(float mx, float mz, float ux, float uz)>>();
            foreach (var c in roads)
                for (int p = 0; p + 5 < c.Length; p += 3)
                {
                    float ax = c[p], az = c[p + 2], bx = c[p + 3], bz = c[p + 5];
                    float dx = bx - ax, dz = bz - az; float ll = MathF.Sqrt(dx * dx + dz * dz);
                    if (ll < 1e-3f) continue;
                    float mx = (ax + bx) * 0.5f, mz = (az + bz) * 0.5f;
                    var key = ((int)MathF.Floor(mx / RC), (int)MathF.Floor(mz / RC));
                    if (!rgrid.TryGetValue(key, out var lst)) { lst = new(); rgrid[key] = lst; }
                    lst.Add((mx, mz, dx / ll, dz / ll));
                }

            var keep = new List<float[]>(lanes.Count);
            foreach (var c in lanes)
            {
                if (c.Length < 6) { keep.Add(c); continue; }
                int n = c.Length / 3;
                float cmx = 0, cmz = 0;
                for (int p = 0; p < c.Length; p += 3) { cmx += c[p]; cmz += c[p + 2]; }
                cmx /= n; cmz /= n;
                int kx = (int)MathF.Floor(cmx / RC), kz = (int)MathF.Floor(cmz / RC);
                float bestD2 = float.MaxValue, rux = 0, ruz = 0;
                for (int dx = -1; dx <= 1; dx++)
                    for (int dz = -1; dz <= 1; dz++)
                        if (rgrid.TryGetValue((kx + dx, kz + dz), out var lst))
                            foreach (var seg in lst)
                            {
                                float d2 = (seg.mx - cmx) * (seg.mx - cmx) + (seg.mz - cmz) * (seg.mz - cmz);
                                if (d2 < bestD2) { bestD2 = d2; rux = seg.ux; ruz = seg.uz; }
                            }
                if (bestD2 <= RoadOnDist2)
                {
                    float sx = c[c.Length - 3] - c[0], sz = c[c.Length - 1] - c[2];
                    float sl = MathF.Sqrt(sx * sx + sz * sz);
                    if (sl > 1e-3f && MathF.Abs((sx / sl) * rux + (sz / sl) * ruz) > ParallelCos)
                    {
                        dropped++; continue;
                    }
                }
                keep.Add(c);
            }
            return keep;
        }

        // Lane indices whose midpoint is within `radius` of (x,z).
        public static List<int> LanesNear(float x, float z, float radius)
        {
            var res = new List<int>();
            if (s_grid == null) return res;
            int r = (int)MathF.Ceiling(radius / CELL);
            int cx = (int)MathF.Floor(x / CELL), cz = (int)MathF.Floor(z / CELL);
            float r2 = radius * radius;
            for (int dx = -r; dx <= r; dx++)
                for (int dz = -r; dz <= r; dz++)
                    if (s_grid.TryGetValue((cx + dx, cz + dz), out var l))
                        foreach (var idx in l)
                        {
                            float ddx = s_midX[idx] - x, ddz = s_midZ[idx] - z;
                            if (ddx * ddx + ddz * ddz <= r2) res.Add(idx);
                        }
            return res;
        }

        public static UXVector3 LaneStart(int idx)
        {
            var c = s_lanes[idx];
            return new UXVector3 { X = c[0], Y = c[1], Z = c[2] };
        }

        // Chain connected lanes from `idx` into a forward route up to maxLen (heading-aware, no loop-back).
        public static List<ClientZoneGraphPathPoint> BuildPath(int idx, float maxLen) => Walk(idx, false, maxLen);

        // Forward path from the lane near (x,z) whose direction best matches heading (hx,hz).
        public static List<ClientZoneGraphPathPoint> BuildPathFrom(float x, float z, float hx, float hz, float maxLen)
        {
            int startLane = -1; bool startRev = false; float bestScore = -2f;
            int scx = (int)MathF.Floor(x / CELL), scz = (int)MathF.Floor(z / CELL);
            for (int dx = -1; dx <= 1; dx++)
                for (int dz = -1; dz <= 1; dz++)
                    if (s_grid.TryGetValue((scx + dx, scz + dz), out var l))
                        foreach (var idx in l)
                        {
                            var c = s_lanes[idx];
                            if (c.Length < 6) continue;
                            int L = c.Length;
                            if ((c[0] - x) * (c[0] - x) + (c[2] - z) * (c[2] - z) <= JoinDist2)
                            {
                                float score = Align(hx, hz, c[3] - c[0], c[5] - c[2]);
                                if (score > bestScore) { bestScore = score; startLane = idx; startRev = false; }
                            }
                            if ((c[L - 3] - x) * (c[L - 3] - x) + (c[L - 1] - z) * (c[L - 1] - z) <= JoinDist2)
                            {
                                float score = Align(hx, hz, c[L - 6] - c[L - 3], c[L - 4] - c[L - 1]);
                                if (score > bestScore) { bestScore = score; startLane = idx; startRev = true; }
                            }
                        }
            return startLane < 0 ? new List<ClientZoneGraphPathPoint>() : Walk(startLane, startRev, maxLen);
        }

        // Chain heading-aware lanes from `startLane`, never re-entering a visited VCELL cell (no loop).
        static List<ClientZoneGraphPathPoint> Walk(int startLane, bool startReversed, float maxLen)
        {
            var pts = new List<ClientZoneGraphPathPoint>();
            var used = new HashSet<int>();
            var visited = new HashSet<(int, int)>();
            float len = 0f;
            int cur = startLane;
            bool reversed = startReversed;
            float ex = 0f, ez = 0f;
            float hx = 0f, hz = 0f;
            while (cur >= 0 && cur < s_lanes.Count && used.Add(cur) && len < maxLen)
            {
                var c = s_lanes[cur];
                if (c.Length < 6) break;
                int L = c.Length;
                if (!reversed)
                {
                    for (int p = 0; p + 2 < L; p += 3)
                    {
                        pts.Add(new ClientZoneGraphPathPoint { Position = new UXVector3 { X = c[p], Y = c[p + 1], Z = c[p + 2] }, Facing = 0 });
                        visited.Add(((int)MathF.Floor(c[p] / VCELL), (int)MathF.Floor(c[p + 2] / VCELL)));
                    }
                    ex = c[L - 3]; ez = c[L - 1];
                    hx = c[L - 3] - c[0]; hz = c[L - 1] - c[2];   // chord direction
                }
                else
                {
                    for (int p = L - 3; p >= 0; p -= 3)
                    {
                        pts.Add(new ClientZoneGraphPathPoint { Position = new UXVector3 { X = c[p], Y = c[p + 1], Z = c[p + 2] }, Facing = 0 });
                        visited.Add(((int)MathF.Floor(c[p] / VCELL), (int)MathF.Floor(c[p + 2] / VCELL)));
                    }
                    ex = c[0]; ez = c[2];
                    hx = c[0] - c[L - 3]; hz = c[2] - c[L - 1];   // chord direction (reversed)
                }
                float hl = MathF.Sqrt(hx * hx + hz * hz);
                if (hl > 1e-4f) { hx /= hl; hz /= hl; }
                for (int p = 0; p + 5 < L; p += 3)
                {
                    float dx = c[p + 3] - c[p], dz = c[p + 5] - c[p + 2];
                    len += MathF.Sqrt(dx * dx + dz * dz);
                }
                cur = FindNext(ex, ez, hx, hz, used, visited, out reversed);
            }
            return pts;
        }

        // Straightest unused lane joined at (ex,ez) that doesn't re-enter a visited cell.
        static int FindNext(float ex, float ez, float hx, float hz, HashSet<int> used, HashSet<(int, int)> visited, out bool reversed)
        {
            reversed = false;
            int cx = (int)MathF.Floor(ex / CELL), cz = (int)MathF.Floor(ez / CELL);
            int curVX = (int)MathF.Floor(ex / VCELL), curVZ = (int)MathF.Floor(ez / VCELL);
            int best = -1; float bestScore = -2f; bool bestRev = false;
            for (int dx = -1; dx <= 1; dx++)
                for (int dz = -1; dz <= 1; dz++)
                    if (s_grid.TryGetValue((cx + dx, cz + dz), out var l))
                        foreach (var idx in l)
                        {
                            if (used.Contains(idx)) continue;
                            var c = s_lanes[idx];
                            if (c.Length < 6) continue;
                            int L = c.Length;
                            float sx = c[0] - ex, sz = c[2] - ez;
                            if (sx * sx + sz * sz <= JoinDist2 && !ReentersVisited(c[L - 3], c[L - 1], curVX, curVZ, visited))
                            {
                                float score = Align(hx, hz, c[3] - c[0], c[5] - c[2]);
                                if (score > bestScore) { bestScore = score; best = idx; bestRev = false; }
                            }
                            float exx = c[L - 3] - ex, ezz = c[L - 1] - ez;
                            if (exx * exx + ezz * ezz <= JoinDist2 && !ReentersVisited(c[0], c[2], curVX, curVZ, visited))
                            {
                                float score = Align(hx, hz, c[L - 6] - c[L - 3], c[L - 4] - c[L - 1]);
                                if (score > bestScore) { bestScore = score; best = idx; bestRev = true; }
                            }
                        }
            // visited-cell blocks loop-back; the angle floor rejects an in-cell U-turn (corners pass).
            if (best >= 0 && bestScore > -0.3f) { reversed = bestRev; return best; }
            return -1;
        }

        // True if (fx,fz) is in a walked cell other than the current one.
        static bool ReentersVisited(float fx, float fz, int curVX, int curVZ, HashSet<(int, int)> visited)
        {
            int vx = (int)MathF.Floor(fx / VCELL), vz = (int)MathF.Floor(fz / VCELL);
            if (vx == curVX && vz == curVZ) return false;
            return visited.Contains((vx, vz));
        }

        // cos of the turn from unit heading (hx,hz) to outgoing (ox,oz).
        static float Align(float hx, float hz, float ox, float oz)
        {
            float ol = MathF.Sqrt(ox * ox + oz * oz);
            if (ol < 1e-4f) return -2f;
            return (hx * ox + hz * oz) / ol;
        }

        // Path from (sx,sz) toward (destX,destZ): at each junction take the connected lane whose far
        // endpoint is closest to the goal. Directional, so it can't loop. Stops on arrival/dead-end/maxLen.
        public static List<ClientZoneGraphPathPoint> BuildPathToward(float sx, float sz, float destX, float destZ, float maxLen)
        {
            var pts = new List<ClientZoneGraphPathPoint>();
            int cur = -1; bool reversed = false; float bestStart = float.MaxValue;
            int scx = (int)MathF.Floor(sx / CELL), scz = (int)MathF.Floor(sz / CELL);
            for (int dx = -1; dx <= 1; dx++)
                for (int dz = -1; dz <= 1; dz++)
                    if (s_grid.TryGetValue((scx + dx, scz + dz), out var l))
                        foreach (var idx in l)
                        {
                            var c = s_lanes[idx];
                            if (c.Length < 6) continue;
                            int L = c.Length;
                            float ds = (c[0] - sx) * (c[0] - sx) + (c[2] - sz) * (c[2] - sz);
                            if (ds < bestStart) { bestStart = ds; cur = idx; reversed = false; }
                            float de = (c[L - 3] - sx) * (c[L - 3] - sx) + (c[L - 1] - sz) * (c[L - 1] - sz);
                            if (de < bestStart) { bestStart = de; cur = idx; reversed = true; }
                        }
            if (cur < 0) return pts;
            var used = new HashSet<int>();
            float len = 0f, ex = 0f, ez = 0f;
            while (cur >= 0 && cur < s_lanes.Count && used.Add(cur) && len < maxLen)
            {
                var c = s_lanes[cur];
                if (c.Length < 6) break;
                int L = c.Length;
                if (!reversed)
                {
                    for (int p = 0; p + 2 < L; p += 3)
                        pts.Add(new ClientZoneGraphPathPoint { Position = new UXVector3 { X = c[p], Y = c[p + 1], Z = c[p + 2] }, Facing = 0 });
                    ex = c[L - 3]; ez = c[L - 1];
                }
                else
                {
                    for (int p = L - 3; p >= 0; p -= 3)
                        pts.Add(new ClientZoneGraphPathPoint { Position = new UXVector3 { X = c[p], Y = c[p + 1], Z = c[p + 2] }, Facing = 0 });
                    ex = c[0]; ez = c[2];
                }
                for (int p = 0; p + 5 < L; p += 3)
                {
                    float dx = c[p + 3] - c[p], dz = c[p + 5] - c[p + 2];
                    len += MathF.Sqrt(dx * dx + dz * dz);
                }
                if ((ex - destX) * (ex - destX) + (ez - destZ) * (ez - destZ) < 400f) break;   // arrived (~20u)
                cur = FindToward(ex, ez, destX, destZ, used, out reversed);
            }
            return pts;
        }

        // Connected unused lane whose far endpoint is closest to (dx,dz).
        static int FindToward(float ex, float ez, float dx, float dz, HashSet<int> used, out bool reversed)
        {
            reversed = false;
            int cx = (int)MathF.Floor(ex / CELL), cz = (int)MathF.Floor(ez / CELL);
            int best = -1; float bestDist = float.MaxValue; bool bestRev = false;
            for (int gx = -1; gx <= 1; gx++)
                for (int gz = -1; gz <= 1; gz++)
                    if (s_grid.TryGetValue((cx + gx, cz + gz), out var l))
                        foreach (var idx in l)
                        {
                            if (used.Contains(idx)) continue;
                            var c = s_lanes[idx];
                            if (c.Length < 6) continue;
                            int L = c.Length;
                            float jsx = c[0] - ex, jsz = c[2] - ez;
                            if (jsx * jsx + jsz * jsz <= JoinDist2)
                            {
                                float fd = (c[L - 3] - dx) * (c[L - 3] - dx) + (c[L - 1] - dz) * (c[L - 1] - dz);
                                if (fd < bestDist) { bestDist = fd; best = idx; bestRev = false; }
                            }
                            float jex = c[L - 3] - ex, jez = c[L - 1] - ez;
                            if (jex * jex + jez * jez <= JoinDist2)
                            {
                                float fd = (c[0] - dx) * (c[0] - dx) + (c[2] - dz) * (c[2] - dz);
                                if (fd < bestDist) { bestDist = fd; best = idx; bestRev = true; }
                            }
                        }
            reversed = bestRev;
            return best;
        }
    }
}
