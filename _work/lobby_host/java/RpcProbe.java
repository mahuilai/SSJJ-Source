import com.strikegod.downloader.service.Amf3Decoder;
import com.strikegod.downloader.service.Amf3Encoder;
import com.strikegod.downloader.service.Amf3TypedObject;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.EOFException;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Round-trips every outgoing lobby RPC against a running server, using the same
 * encoder/decoder as the game server so the wire format cannot drift.
 *
 * Usage: java -cp . RpcProbe &lt;port&gt; &lt;timeoutMs&gt;
 */
public final class RpcProbe {
    public static void main(String[] args) throws Exception {
        int port = args.length > 0 ? Integer.parseInt(args[0]) : 2000;
        int timeoutMs = args.length > 1 ? Integer.parseInt(args[1]) : 600;
        Path root = Paths.get("").toAbsolutePath();
        Path table = root.resolve("rpc_requests.txt");
        if (!Files.isRegularFile(table)) {
            System.out.println("missing " + table);
            return;
        }

        List<String[]> rows = new ArrayList<>();
        for (String line : Files.readAllLines(table, StandardCharsets.UTF_8)) {
            line = line.trim();
            if (line.isEmpty() || line.startsWith("#")) continue;
            String[] p = line.split(" ");
            rows.add(new String[]{p[0], p[1]});
        }

        int ok = 0, silent = 0, wrong = 0, expected = 0;
        List<Long> lat = new ArrayList<>();
        List<String> silentNames = new ArrayList<>();
        List<String> wrongNames = new ArrayList<>();
        for (String[] row : rows) {
            String req = row[0], want = row[1];
            boolean wantReply = !"-".equals(want);
            if (wantReply) expected++;

            byte[] amf = Amf3Encoder.encodeOnce(
                    Amf3TypedObject.apc(req, List.of()));
            long t0 = System.nanoTime();
            String got = null;
            try (Socket s = new Socket()) {
                s.setTcpNoDelay(true);
                s.connect(new java.net.InetSocketAddress("127.0.0.1", port), 2000);
                s.setSoTimeout(timeoutMs);
                DataOutputStream out = new DataOutputStream(new BufferedOutputStream(s.getOutputStream()));
                out.writeInt(amf.length + 1);
                out.writeByte(0);
                out.write(amf);
                out.flush();

                DataInputStream in = new DataInputStream(new BufferedInputStream(s.getInputStream()));
                int len = in.readInt();
                in.readByte();
                byte[] payload = new byte[len - 1];
                in.readFully(payload);
                got = replyName(new Amf3Decoder(payload).decodeOne());
            } catch (EOFException | java.net.SocketTimeoutException e) {
                got = null;
            } catch (Exception e) {
                got = "!ERR " + e.getClass().getSimpleName();
            }
            long dt = (System.nanoTime() - t0) / 1000;
            if (got == null) {
                silent++;
                if (silentNames.size() < 20) silentNames.add(req);
            } else if (wantReply && want.equals(got)) {
                ok++;
                lat.add(dt);
            } else if (!wantReply) {
                ok++;
                lat.add(dt);
            } else {
                wrong++;
                if (wrongNames.size() < 20) wrongNames.add(req + " want=" + want + " got=" + got);
            }
        }

        lat.sort(null);
        System.out.println("requests          : " + rows.size());
        System.out.println("reply expected    : " + expected);
        System.out.println("ok                : " + ok);
        System.out.println("no reply          : " + silent);
        System.out.println("wrong callback    : " + wrong);
        if (!lat.isEmpty()) {
            System.out.printf("connect-mode us  mean %.0f  p50 %d  p95 %d  max %d%n",
                    lat.stream().mapToLong(Long::longValue).average().orElse(0),
                    lat.get(lat.size() / 2), lat.get((int) (lat.size() * 0.95)), lat.get(lat.size() - 1));
        }
        if (!silentNames.isEmpty()) System.out.println("silent: " + silentNames);
        if (!wrongNames.isEmpty()) System.out.println("wrong : " + wrongNames);

        reuseLatency(port, rows);
        pingMicro(port);
    }

    /** Steady-state latency on one warm connection: what the lobby actually sees. */
    private static void reuseLatency(int port, List<String[]> rows) throws Exception {
        List<Long> lat = new ArrayList<>();
        int byteTotal = 0, maxBytes = 0;
        long t0 = System.nanoTime();
        try (Socket s = new Socket()) {
            s.setTcpNoDelay(true);
            s.connect(new java.net.InetSocketAddress("127.0.0.1", port), 2000);
            s.setSoTimeout(800);
            DataOutputStream out = new DataOutputStream(new BufferedOutputStream(s.getOutputStream()));
            DataInputStream in = new DataInputStream(new BufferedInputStream(s.getInputStream()));
            for (String[] row : rows) {
                byte[] amf = Amf3Encoder.encodeOnce(Amf3TypedObject.apc(row[0], List.of()));
                long a = System.nanoTime();
                out.writeInt(amf.length + 1);
                out.writeByte(0);
                out.write(amf);
                out.flush();
                try {
                    int len = in.readInt();
                    in.readByte();
                    byte[] payload = new byte[len - 1];
                    in.readFully(payload);
                    lat.add((System.nanoTime() - a) / 1000);
                    byteTotal += len;
                    maxBytes = Math.max(maxBytes, len);
                } catch (java.net.SocketTimeoutException e) {
                    // branch with no reply; connection is still aligned because the
                    // server never wrote a partial frame
                }
            }
        }
        lat.sort(null);
        double wall = (System.nanoTime() - t0) / 1e9;
        System.out.printf("reuse-mode   n=%d  mean %.0f us  p50 %d  p95 %d  max %d us  wall %.2fs%n",
                lat.size(), lat.stream().mapToLong(Long::longValue).average().orElse(0),
                lat.get(lat.size() / 2), lat.get((int) (lat.size() * 0.95)),
                lat.get(lat.size() - 1), wall);
        System.out.printf("reply bytes  total %d  average %d  max %d%n",
                byteTotal, byteTotal / Math.max(1, lat.size()), maxBytes);
    }

    private static void pingMicro(int port) throws Exception {
        int n = 2000;
        try (Socket s = new Socket()) {
            s.setTcpNoDelay(true);
            s.connect(new java.net.InetSocketAddress("127.0.0.1", port), 2000);
            s.setSoTimeout(2000);
            DataOutputStream out = new DataOutputStream(new BufferedOutputStream(s.getOutputStream()));
            DataInputStream in = new DataInputStream(new BufferedInputStream(s.getInputStream()));
            byte[] amf = Amf3Encoder.encodeOnce(Amf3TypedObject.apc("ping", List.of()));
            for (int i = 0; i < 50; i++) roundTrip(out, in, amf);
            List<Long> lat = new ArrayList<>(n);
            for (int i = 0; i < n; i++) {
                long a = System.nanoTime();
                roundTrip(out, in, amf);
                lat.add((System.nanoTime() - a) / 1000);
            }
            lat.sort(null);
            System.out.printf("ping x%d     mean %.0f us  p50 %d  p95 %d  p99 %d  max %d us%n",
                    n, lat.stream().mapToLong(Long::longValue).average().orElse(0),
                    lat.get(n / 2), lat.get((int) (n * 0.95)), lat.get((int) (n * 0.99)), lat.get(n - 1));
        }
    }

    private static void roundTrip(DataOutputStream out, DataInputStream in, byte[] amf) throws Exception {
        out.writeInt(amf.length + 1);
        out.writeByte(0);
        out.write(amf);
        out.flush();
        int len = in.readInt();
        in.readByte();
        byte[] payload = new byte[len - 1];
        in.readFully(payload);
    }

    private static String replyName(Object obj) {
        Object fn = null;
        if (obj instanceof Amf3TypedObject to) {
            fn = to.fields().get("functionName");
        } else if (obj instanceof Map<?, ?> m) {
            fn = m.get("functionName");
        } else if (obj instanceof LinkedHashMap<?, ?> m) {
            fn = m.get("functionName");
        }
        return fn == null ? "(none)" : fn.toString();
    }

    private RpcProbe() {}
}
