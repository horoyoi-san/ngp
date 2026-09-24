using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.Data.Sqlite;

namespace Ananta.Server.State;

public static class AccountDatabase
{
    private static readonly JsonSerializerOptions Json = new() { PropertyNameCaseInsensitive = true };
    private static readonly object Sync = new();
    private static string _dbPath = string.Empty;
    private static string _connectionString = string.Empty;

    public sealed class Account
    {
        public string Id { get; set; } = string.Empty;
        public string Uid { get; set; } = string.Empty;
        public ulong Pid { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Nickname { get; set; } = string.Empty;
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset LastLogin { get; set; }
        public bool IsActive { get; set; }
    }

    public static string Path => _dbPath;

    private static List<Account>? _cache;

    
    
    
    
    private static void InvalidateCache() { lock (Sync) _cache = null; }

    public static void Initialize(string dataDirectory)
    {
        lock (Sync)
        {
            Directory.CreateDirectory(dataDirectory);
            _dbPath = System.IO.Path.Combine(dataDirectory, "Ananta.db");
            _connectionString = new SqliteConnectionStringBuilder { DataSource = _dbPath, Mode = SqliteOpenMode.ReadWriteCreate }.ToString();

            using var conn = Open();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = """
                CREATE TABLE IF NOT EXISTS accounts (
                    id          TEXT PRIMARY KEY,
                    uid         TEXT NOT NULL UNIQUE,
                    pid         INTEGER NOT NULL UNIQUE,
                    username    TEXT NOT NULL,
                    pass_salt   TEXT NOT NULL,
                    pass_hash   TEXT NOT NULL,
                    nickname    TEXT NOT NULL,
                    created_at  TEXT NOT NULL,
                    last_login  TEXT NOT NULL,
                    is_active   INTEGER NOT NULL DEFAULT 0
                );
                CREATE TABLE IF NOT EXISTS player_state (
                    account_id  TEXT PRIMARY KEY,
                    payload     TEXT NOT NULL,
                    updated_at  TEXT NOT NULL
                );
                """;
            cmd.ExecuteNonQuery();
        }
    }

    private static SqliteConnection Open()
    {
        var conn = new SqliteConnection(_connectionString);
        conn.Open();
        return conn;
    }

    

    private static (string salt, string hash) HashPassword(string password)
    {
        var saltBytes = RandomNumberGenerator.GetBytes(16);
        var salt = Convert.ToHexString(saltBytes);
        return (salt, Hash(salt, password));
    }

    private static string Hash(string salt, string password)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(salt + ":" + password));
        return Convert.ToHexString(bytes);
    }

    public static bool Verify(Account account, string password)
    {
        lock (Sync)
        {
            using var conn = Open();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT pass_salt, pass_hash FROM accounts WHERE id = $id";
            cmd.Parameters.AddWithValue("$id", account.Id);
            using var reader = cmd.ExecuteReader();
            if (!reader.Read())
                return false;
            var salt = reader.GetString(0);
            var expected = reader.GetString(1);
            return CryptographicOperations.FixedTimeEquals(
                Encoding.UTF8.GetBytes(Hash(salt, password)),
                Encoding.UTF8.GetBytes(expected));
        }
    }

    

    public static List<Account> List()
    {
        lock (Sync)
        {
            if (_cache is not null)
                return new List<Account>(_cache);

            var result = new List<Account>();
            using var conn = Open();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT id, uid, pid, username, nickname, created_at, last_login, is_active FROM accounts ORDER BY created_at";
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                result.Add(new Account
                {
                    Id = reader.GetString(0),
                    Uid = reader.GetString(1),
                    Pid = (ulong)reader.GetInt64(2),
                    Username = reader.GetString(3),
                    Nickname = reader.GetString(4),
                    CreatedAt = DateTimeOffset.Parse(reader.GetString(5)),
                    LastLogin = DateTimeOffset.Parse(reader.GetString(6)),
                    IsActive = reader.GetInt32(7) != 0,
                });
            }
            _cache = result;
            return new List<Account>(result);
        }
    }

    public static Account? Find(string id)
        => List().FirstOrDefault(a => a.Id == id || a.Uid == id || a.Username == id);

    public static Account? Active()
        => List().FirstOrDefault(a => a.IsActive) ?? List().FirstOrDefault();

    
    public static Account Create(string id, string username, string password, string nickname, string? uid = null, ulong pid = 0)
    {
        lock (Sync)
        {
            var existing = List();
            id = string.IsNullOrWhiteSpace(id) ? "acc" + Guid.NewGuid().ToString("N")[..6] : id.Trim();
            if (existing.Any(a => a.Id == id))
                throw new InvalidOperationException($"账号 {id} 已存在");

            uid = string.IsNullOrWhiteSpace(uid) ? NextUid(existing) : uid.Trim();
            if (existing.Any(a => a.Uid == uid))
                throw new InvalidOperationException($"账号 ID {uid} 已存在");

            if (pid == 0)
                pid = existing.Count == 0 ? 666UL : existing.Max(a => a.Pid) + 1;
            if (existing.Any(a => a.Pid == pid))
                throw new InvalidOperationException($"角色 ID {pid} 已存在");

            if (string.IsNullOrWhiteSpace(username))
                username = uid + "@netease.win.163.com";
            if (string.IsNullOrWhiteSpace(nickname))
                nickname = id;

            var (salt, hash) = HashPassword(string.IsNullOrEmpty(password) ? "Ananta" : password);
            var now = DateTimeOffset.Now.ToString("O");

            using var conn = Open();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = """
                INSERT INTO accounts (id, uid, pid, username, pass_salt, pass_hash, nickname, created_at, last_login, is_active)
                VALUES ($id, $uid, $pid, $username, $salt, $hash, $nickname, $now, $now, 0)
                """;
            cmd.Parameters.AddWithValue("$id", id);
            cmd.Parameters.AddWithValue("$uid", uid);
            cmd.Parameters.AddWithValue("$pid", (long)pid);
            cmd.Parameters.AddWithValue("$username", username);
            cmd.Parameters.AddWithValue("$salt", salt);
            cmd.Parameters.AddWithValue("$hash", hash);
            cmd.Parameters.AddWithValue("$nickname", nickname);
            cmd.Parameters.AddWithValue("$now", now);
            cmd.ExecuteNonQuery();
            InvalidateCache();

            return Find(id)!;
        }
    }

    private static string NextUid(List<Account> existing)
    {
        
        const string alphabet = "abcdefghijklmnopqrstuvwxyz0123456789";
        string uid;
        do
        {
            var bytes = RandomNumberGenerator.GetBytes(16);
            uid = string.Concat(bytes.Select(b => alphabet[b % alphabet.Length]));
        } while (existing.Any(a => a.Uid == uid));
        return uid;
    }

    public static void SetActive(string id)
    {
        lock (Sync)
        {
            using var conn = Open();
            using var tx = conn.BeginTransaction();
            using (var clear = conn.CreateCommand())
            {
                clear.Transaction = tx;
                clear.CommandText = "UPDATE accounts SET is_active = 0";
                clear.ExecuteNonQuery();
            }
            using (var set = conn.CreateCommand())
            {
                set.Transaction = tx;
                set.CommandText = "UPDATE accounts SET is_active = 1, last_login = $now WHERE id = $id";
                set.Parameters.AddWithValue("$id", id);
                set.Parameters.AddWithValue("$now", DateTimeOffset.Now.ToString("O"));
                set.ExecuteNonQuery();
            }
            tx.Commit();
            InvalidateCache();
        }
    }

    public static bool Delete(string id)
    {
        lock (Sync)
        {
            using var conn = Open();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "DELETE FROM accounts WHERE id = $id";
            cmd.Parameters.AddWithValue("$id", id);
            var affected = cmd.ExecuteNonQuery();

            using var cmd2 = conn.CreateCommand();
            cmd2.CommandText = "DELETE FROM player_state WHERE account_id = $id";
            cmd2.Parameters.AddWithValue("$id", id);
            cmd2.ExecuteNonQuery();
            InvalidateCache();

            return affected > 0;
        }
    }

    

    public static PlayerState LoadState(string accountId)
    {
        lock (Sync)
        {
            using var conn = Open();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT payload FROM player_state WHERE account_id = $id";
            cmd.Parameters.AddWithValue("$id", accountId);
            var payload = cmd.ExecuteScalar() as string;

            if (!string.IsNullOrEmpty(payload))
            {
                try
                {
                    var loaded = JsonSerializer.Deserialize<PlayerState>(payload, Json);
                    if (loaded is not null)
                        return loaded;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[DB] 存档 {accountId} 解析失败: {ex.Message}");
                }
            }

            var fresh = new PlayerState { AccountId = accountId };
            SaveState(fresh);
            return fresh;
        }
    }

    public static void SaveState(PlayerState state)
    {
        lock (Sync)
        {
            if (string.IsNullOrEmpty(_dbPath))
                return;
            state.UpdatedAt = DateTimeOffset.Now;
            using var conn = Open();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = """
                INSERT INTO player_state (account_id, payload, updated_at) VALUES ($id, $payload, $now)
                ON CONFLICT(account_id) DO UPDATE SET payload = $payload, updated_at = $now
                """;
            cmd.Parameters.AddWithValue("$id", state.AccountId);
            cmd.Parameters.AddWithValue("$payload", JsonSerializer.Serialize(state, Json));
            cmd.Parameters.AddWithValue("$now", state.UpdatedAt.ToString("O"));
            cmd.ExecuteNonQuery();
        }
    }
}
