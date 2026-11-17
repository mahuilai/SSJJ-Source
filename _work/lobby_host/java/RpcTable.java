import com.strikegod.downloader.service.Amf3Encoder;
import com.strikegod.downloader.service.Amf3TypedObject;

import java.io.DataOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Table-driven replies for lobby RPCs.
 *
 * <p>The table is generated from the client's own ActionScript source, so every
 * entry names the callback the client actually registered. Frames are encoded
 * once at boot: a request then costs a hash lookup plus a single socket write.
 *
 * <p>Replies built here are static defaults (empty lists, zeroed beans). Any RPC
 * that needs real data keeps its hand-written branch in {@link LobbyLoginServer}
 * and never reaches this table.
 */
public final class RpcTable {
    private static final Map<String, byte[]> FRAMES = new HashMap<>();
    private static int beanCount;
    private static int fieldCount;

    private RpcTable() {}

    public static void load(Path file) throws IOException {
        if (!Files.isRegularFile(file)) {
            System.out.println("[rpc] table missing, generic dispatch disabled: " + file);
            return;
        }
        List<String> lines = Files.readAllLines(file, StandardCharsets.UTF_8);
        String req = null;
        String cb = null;
        int nParams = 0;
        List<Object> params = new ArrayList<>();
        int i = 0;
        while (i < lines.size()) {
            String line = lines.get(i).trim();
            if (line.isEmpty() || line.startsWith("#")) { i++; continue; }
            char kind = line.charAt(0);
            if (kind == 'R') {
                if (req != null) put(req, cb, params);
                String[] p = line.split(" ");
                req = p[1];
                cb = p[2];
                nParams = Integer.parseInt(p[3]);
                params = new ArrayList<>(nParams);
                i++;
            } else if (kind == 'P') {
                String[] p = line.split(" ");
                int nFields = Integer.parseInt(p[3]);
                String alias = "-".equals(p[2]) ? null : p[2];
                i++;
                if ("bean".equals(p[1])) {
                    List<String> names = new ArrayList<>(nFields);
                    List<String> kinds = new ArrayList<>(nFields);
                    for (int j = 0; j < nFields; j++) {
                        String fl = lines.get(i++).trim();
                        String[] f = fl.split(" ");
                        names.add(f[1]);
                        kinds.add(f[2]);
                    }
                    params.add(buildBean(alias, names, kinds));
                } else {
                    params.add(defaultScalar(p[1]));
                }
            } else if (kind == 'F') {
                i++;
            } else {
                i++;
            }
        }
        if (req != null) put(req, cb, params);
        System.out.println("[rpc] generic dispatch ready: " + FRAMES.size()
                + " replies pre-encoded, " + beanCount + " beans, " + fieldCount + " fields");
    }

    private static void put(String req, String cb, List<Object> params) {
        try {
            byte[] amf = Amf3Encoder.encodeOnce(Amf3TypedObject.apc(cb, params));
            byte[] frame = new byte[amf.length + 5];
            frame[0] = (byte) ((amf.length + 1) >>> 24);
            frame[1] = (byte) ((amf.length + 1) >>> 16);
            frame[2] = (byte) ((amf.length + 1) >>> 8);
            frame[3] = (byte) (amf.length + 1);
            frame[4] = 0;
            System.arraycopy(amf, 0, frame, 5, amf.length);
            FRAMES.put(req, frame);
        } catch (IOException e) {
            System.out.println("[rpc] cannot pre-encode " + req + ": " + e);
        }
    }

    private static Object buildBean(String alias, List<String> names, List<String> kinds) {
        var bean = new Amf3TypedObject(alias, names, false);
        for (int i = 0; i < names.size(); i++) {
            Object v = defaultScalar(kinds.get(i));
            if (v != null) bean.set(names.get(i), v);
            fieldCount++;
        }
        beanCount++;
        return bean;
    }

    /** Null means "leave the sealed slot unset", which the encoder emits as AMF3 null. */
    private static Object defaultScalar(String kind) {
        switch (kind) {
            case "int":
            case "uint":
            case "number":
                return 0;
            case "string":
                return "";
            case "boolean":
                return Boolean.FALSE;
            case "array":
                return new ArrayList<>();
            case "object":
                return new LinkedHashMap<String, Object>();
            default:
                return null;
        }
    }

    public static boolean has(String fn) {
        return fn != null && FRAMES.containsKey(fn);
    }

    /**
     * Writes the pre-encoded reply. Returns false when the request has no table
     * entry, so the caller can log it as unimplemented.
     */
    public static boolean dispatch(DataOutputStream out, String fn) throws IOException {
        byte[] frame = fn == null ? null : FRAMES.get(fn);
        if (frame == null) return false;
        out.write(frame);
        out.flush();
        // 这里直接写流、不走 LobbyLoginServer.send()，必须显式标记「已回包」，
        // 否则 [NO-REPLY] 观测会把表驱动的正常应答全部误报成静默失败。
        LobbyLoginServer.markSent();
        return true;
    }

    public static int size() {
        return FRAMES.size();
    }
}
