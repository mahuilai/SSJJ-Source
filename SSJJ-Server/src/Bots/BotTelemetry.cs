using System;
using System.IO;
using System.Text.Json;

namespace SSJJ.Server.Bots
{
    /// <summary>
    /// Minimal JSONL telemetry sink for the headless harness. P3 expands the
    /// record schema (shots/hits/kills/stuck/path efficiency/tick budget).
    /// </summary>
    public sealed class BotTelemetry : IDisposable
    {
        private readonly StreamWriter? _writer;

        public BotTelemetry(string? path)
        {
            if (string.IsNullOrWhiteSpace(path)) return;
            try
            {
                string? dir = Path.GetDirectoryName(Path.GetFullPath(path));
                if (!string.IsNullOrEmpty(dir)) Directory.CreateDirectory(dir);
                _writer = new StreamWriter(path, append: false) { AutoFlush = true };
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("[SSJJ-Server][TELEMETRY] open failed: " + ex.Message);
            }
        }

        public void Write(object record)
        {
            if (_writer == null) return;
            try
            {
                _writer.WriteLine(JsonSerializer.Serialize(record));
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("[SSJJ-Server][TELEMETRY] write failed: " + ex.Message);
            }
        }

        public void Dispose()
        {
            _writer?.Dispose();
        }
    }
}
