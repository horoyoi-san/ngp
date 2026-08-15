using System;
using System.Collections.Generic;
using System.Text;

namespace AnantaTestGameServer.Utils
{
    internal static class UrlStringExtractor
    {
        // Extract likely ASCII/UTF-8 strings from a payload and return those that look like URLs.
        // This is heuristic but good for finding "http"/"https" fields inside unknown RPC binary payloads.
        public static List<string> ExtractHttpUrls(byte[] data)
        {
            var results = new List<string>();
            if (data == null || data.Length == 0)
                return results;

            // We decode with replacement to avoid exceptions.
            // Also, we only keep printable-ish chars to avoid garbage explosion.
            string s = DecodeAsciiish(data);

            // Quick checks first.
            if (s.IndexOf("http", StringComparison.OrdinalIgnoreCase) < 0)
                return results;

            // Tokenize by whitespace and common separators.
            // URL may be embedded in JSON-ish/strings, so separators likely exist.
            var tokens = s.Split(new[] { '\u0000', '\n', '\r', '\t', ' ', '"', '\'', ',', ';', '(', ')', '{', '}', '[', ']' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var t in tokens)
            {
                if (t.IndexOf("http", StringComparison.OrdinalIgnoreCase) < 0)
                    continue;

                // Keep only reasonable length strings.
                if (t.Length < 8 || t.Length > 2048)
                    continue;

                // Strip leading/trailing non-url chars.
                string cleaned = CleanToken(t);
                if (cleaned.Length < 8)
                    continue;

                if (!cleaned.StartsWith("http://", StringComparison.OrdinalIgnoreCase) &&
                    !cleaned.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                    continue;

                results.Add(cleaned);
            }

            return results;
        }

        private static string DecodeAsciiish(byte[] data)
        {
            // Create a string by mapping bytes into printable chars.
            // This avoids turning binary into huge Unicode noise.
            var sb = new StringBuilder(data.Length);
            for (int i = 0; i < data.Length; i++)
            {
                byte b = data[i];
                if (b >= 0x20 && b <= 0x7E) // printable ASCII
                {
                    sb.Append((char)b);
                }
                else if (b == 0x0A || b == 0x0D || b == 0x09) // newline/cr/tab
                {
                    sb.Append((char)b);
                }
                else
                {
                    // convert other bytes to separator-ish.
                    sb.Append(' ');
                }
            }
            return sb.ToString();
        }

        private static string CleanToken(string t)
        {
            int start = 0;
            int end = t.Length;
            while (start < end && !IsUrlStartChar(t[start])) start++;
            while (end > start && !IsUrlEndChar(t[end - 1])) end--;
            if (start >= end) return string.Empty;
            return t.Substring(start, end - start);
        }

        private static bool IsUrlStartChar(char c)
        {
            return char.IsLetterOrDigit(c) || c == ':' || c == '/' || c == '.' || c == '-';
        }

        private static bool IsUrlEndChar(char c)
        {
            return char.IsLetterOrDigit(c) || c == ':' || c == '/' || c == '.' || c == '-' || c == '?' || c == '=' || c == '&' || c == '%';
        }
    }
}

