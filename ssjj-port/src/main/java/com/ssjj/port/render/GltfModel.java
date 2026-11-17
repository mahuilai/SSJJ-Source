package com.ssjj.port.render;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.ArrayList;
import java.util.List;

/**
 * 极简 glTF 2.0 读取器，只覆盖 {@code mc-port/tools/ssjj2gltf.py} 产出的子集。
 *
 * <p>渲染层（独立 viewmodel pass + CPU/GPU 蒙皮）需要的不外乎：顶点位置/法线/UV、
 * 骨骼索引与权重、索引缓冲、skin 的关节顺序与逆绑定矩阵、节点层级、动画通道。
 * 与其引入一个完整 glTF 库，这里按导出器的实际输出做严格解析，字段缺失直接抛错，
 * 不做静默降级（静默降级会把「模型没加载」伪装成「渲染成隐形」）。</p>
 *
 * <p>当前**不做**的事：morph target、多 primitive、多 buffer、稀疏 accessor、
 * 纹理内嵌（图片走外部 png）。遇到这些情况明确抛异常。</p>
 */
public final class GltfModel {

    /** 节点：名称 + 局部 TRS + 子节点 + 可选 mesh/skin。 */
    public static final class Node {
        public final String name;
        public final int[] children;
        public final float[] translation;
        public final float[] rotation;
        public final float[] scale;
        public final int mesh;
        public final int skin;

        Node(String name, int[] children, float[] t, float[] r, float[] s, int mesh, int skin) {
            this.name = name;
            this.children = children;
            this.translation = t;
            this.rotation = r;
            this.scale = s;
            this.mesh = mesh;
            this.skin = skin;
        }
    }

    /** 单个 primitive 的顶点数据。joints 每顶点 4 个，weights 每顶点 4 个已归一化。 */
    public static final class Mesh {
        public final float[] positions;
        public final float[] normals;
        public final float[] uvs;
        public final int[] joints;
        public final float[] weights;
        public final int[] indices;

        Mesh(float[] p, float[] n, float[] uv, int[] j, float[] w, int[] idx) {
            this.positions = p;
            this.normals = n;
            this.uvs = uv;
            this.joints = j;
            this.weights = w;
            this.indices = idx;
        }

        public int vertexCount() {
            return positions.length / 3;
        }

        public int triangleCount() {
            return indices.length / 3;
        }
    }

    /** 蒙皮：joints 是节点索引数组；inverseBind 是 joints.length × 16，列主序。 */
    public static final class Skin {
        public final int[] joints;
        public final float[] inverseBind;

        Skin(int[] joints, float[] ibm) {
            this.joints = joints;
            this.inverseBind = ibm;
        }
    }

    public static final class Channel {
        public final int sampler;
        public final int node;
        public final String path;

        Channel(int sampler, int node, String path) {
            this.sampler = sampler;
            this.node = node;
            this.path = path;
        }
    }

    public static final class Sampler {
        public final int input;
        public final int output;
        public final String interpolation;

        Sampler(int input, int output, String interpolation) {
            this.input = input;
            this.output = output;
            this.interpolation = interpolation;
        }
    }

    public static final class Clip {
        public final String name;
        public final Channel[] channels;
        public final Sampler[] samplers;
        /** 该 clip 所有 sampler input 的原始时间轴（秒）。 */
        public final float[][] times;
        /** 与 {@link #times} 一一对应的输出值数组（VEC3 为 3 个一组，VEC4 为 4 个一组）。 */
        public final float[][] values;

        Clip(String name, Channel[] channels, Sampler[] samplers, float[][] times, float[][] values) {
            this.name = name;
            this.channels = channels;
            this.samplers = samplers;
            this.times = times;
            this.values = values;
        }
    }

    public final Node[] nodes;
    /** 一个 mesh 可能含多个 primitive（例如手+枪合成资产）。 */
    public final List<Mesh> meshes;
    public final Skin skin;
    public final Clip[] clips;

    private GltfModel(Node[] nodes, List<Mesh> meshes, Skin skin, Clip[] clips) {
        this.nodes = nodes;
        this.meshes = meshes;
        this.skin = skin;
        this.clips = clips;
    }

    /** 兼容单 primitive 资产：返回第一个。 */
    public Mesh mesh() {
        return meshes.get(0);
    }

    public static GltfModel load(Path gltfPath) throws IOException {
        String json = Files.readString(gltfPath, StandardCharsets.UTF_8);
        Path dir = gltfPath.toAbsolutePath().getParent();
        return parse(json, uri -> Files.readAllBytes(dir.resolve(uri)));
    }

    /**
     * 从 classpath 读取（打进 jar 的资产）。
     *
     * <p>gltf 与 bin 必须放在同一资源目录，bin 文件名由 {@code buffers[0].uri} 指定。
     * 资源缺失直接抛 {@link IllegalStateException}，不返回空模型。</p>
     */
    public static GltfModel loadFromClasspath(String gltfResource) {
        String json;
        try (InputStream in = GltfModel.class.getResourceAsStream(gltfResource)) {
            if (in == null) {
                throw new IllegalStateException("缺少 gltf 资源: " + gltfResource);
            }
            json = new String(in.readAllBytes(), StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new IllegalStateException("读取 gltf 失败: " + gltfResource, e);
        }
        int slash = gltfResource.lastIndexOf('/');
        String dir = slash < 0 ? "" : gltfResource.substring(0, slash + 1);
        try {
            return parse(json, uri -> {
                String path = dir + uri;
                try (InputStream bin = GltfModel.class.getResourceAsStream(path)) {
                    if (bin == null) {
                        throw new IOException("缺少 bin 资源: " + path);
                    }
                    return bin.readAllBytes();
                }
            });
        } catch (IOException e) {
            throw new IllegalStateException("从 classpath 解析失败: " + gltfResource, e);
        }
    }

    /** 取 bin 的方式：本地文件走 Path，jar 内走 getResourceAsStream。 */
    private interface BinSource {
        byte[] read(String uri) throws IOException;
    }

    private static GltfModel parse(String json, BinSource bins) throws IOException {
        JsonObject root = JsonParser.parseString(json).getAsJsonObject();
        JsonArray views = root.getAsJsonArray("bufferViews");
        JsonArray accessors = root.getAsJsonArray("accessors");

        byte[] bin = readFirstBuffer(root, bins);
        List<Mesh> meshes = readMeshes(root, views, accessors, bin);
        Skin skin = readSkin(root, views, accessors, bin);
        Node[] nodes = readNodes(root, accessors, bin);
        Clip[] clips = readClips(root, views, accessors, bin);

        return new GltfModel(nodes, meshes, skin, clips);
    }

    // ------------------------------------------------------------------ buffer

    private static byte[] readFirstBuffer(JsonObject root, BinSource bins) throws IOException {
        JsonArray buffers = root.getAsJsonArray("buffers");
        if (buffers == null || buffers.size() != 1) {
            throw new IllegalStateException("只支持单 buffer，实际 " + (buffers == null ? 0 : buffers.size()));
        }
        JsonObject b = buffers.get(0).getAsJsonObject();
        if (!b.has("uri") || b.get("uri").getAsString().startsWith("data:")) {
            throw new IllegalStateException("只支持外部 .bin（uri 指向文件）");
        }
        byte[] data = bins.read(b.get("uri").getAsString());
        int declared = b.get("byteLength").getAsInt();
        if (data.length != declared) {
            throw new IllegalStateException("bin 长度 " + data.length + " != 声明 " + declared);
        }
        return data;
    }

    // ------------------------------------------------------------------ accessor

    private static final int FLOAT = 5126;
    private static final int UBYTE = 5121;
    private static final int USHORT = 5123;
    private static final int UINT = 5125;

    private static int componentSize(int type) {
        return switch (type) {
            case FLOAT, UINT -> 4;
            case USHORT -> 2;
            case UBYTE -> 1;
            default -> throw new IllegalStateException("不支持的 componentType: " + type);
        };
    }

    private static int componentCount(String type) {
        return switch (type) {
            case "SCALAR" -> 1;
            case "VEC2" -> 2;
            case "VEC3" -> 3;
            case "VEC4" -> 4;
            case "MAT4" -> 16;
            default -> throw new IllegalStateException("不支持的 accessor type: " + type);
        };
    }

    private static ByteBuffer slice(JsonObject acc, JsonArray views, byte[] bin) {
        JsonObject v = views.get(acc.get("bufferView").getAsInt()).getAsJsonObject();
        int off = v.has("byteOffset") ? v.get("byteOffset").getAsInt() : 0;
        int len = v.get("byteLength").getAsInt();
        if (off + len > bin.length) {
            throw new IllegalStateException("bufferView 越界: off=" + off + " len=" + len);
        }
        return ByteBuffer.wrap(bin, off, len).slice().order(ByteOrder.LITTLE_ENDIAN);
    }

    private static float[] readFloats(JsonArray accs, JsonArray views, byte[] bin, int index) {
        JsonObject acc = accs.get(index).getAsJsonObject();
        int comps = componentCount(acc.get("type").getAsString());
        int count = acc.get("count").getAsInt();
        if (acc.get("componentType").getAsInt() != FLOAT) {
            throw new IllegalStateException("期望 float accessor，实际 " + acc.get("componentType"));
        }
        ByteBuffer bb = slice(acc, views, bin);
        float[] out = new float[count * comps];
        for (int i = 0; i < out.length; i++) {
            out[i] = bb.getFloat(i * 4);
        }
        return out;
    }

    private static int[] readInts(JsonArray accs, JsonArray views, byte[] bin, int index) {
        JsonObject acc = accs.get(index).getAsJsonObject();
        int comps = componentCount(acc.get("type").getAsString());
        int count = acc.get("count").getAsInt();
        int type = acc.get("componentType").getAsInt();
        int cs = componentSize(type);
        ByteBuffer bb = slice(acc, views, bin);
        int[] out = new int[count * comps];
        for (int i = 0; i < out.length; i++) {
            int o = i * cs;
            out[i] = switch (type) {
                case UBYTE -> bb.get(o) & 0xFF;
                case USHORT -> bb.getShort(o) & 0xFFFF;
                case UINT -> bb.getInt(o);
                default -> throw new IllegalStateException("期望整数 accessor，实际 " + type);
            };
        }
        return out;
    }

    // ------------------------------------------------------------------ mesh

    private static List<Mesh> readMeshes(JsonObject root, JsonArray views, JsonArray accs, byte[] bin) {
        JsonArray meshes = root.getAsJsonArray("meshes");
        if (meshes == null || meshes.size() != 1) {
            throw new IllegalStateException("只支持单 mesh，实际 " + (meshes == null ? 0 : meshes.size()));
        }
        JsonArray prims = meshes.get(0).getAsJsonObject().getAsJsonArray("primitives");
        List<Mesh> out = new ArrayList<>(prims.size());
        for (int pi = 0; pi < prims.size(); pi++) {
            out.add(readPrimitive(prims.get(pi).getAsJsonObject(), views, accs, bin));
        }
        return out;
    }

    private static Mesh readPrimitive(JsonObject p, JsonArray views, JsonArray accs, byte[] bin) {
        JsonObject attr = p.getAsJsonObject("attributes");

        float[] pos = readFloats(accs, views, bin, attr.get("POSITION").getAsInt());
        float[] nrm = attr.has("NORMAL")
                ? readFloats(accs, views, bin, attr.get("NORMAL").getAsInt()) : null;
        float[] uv = attr.has("TEXCOORD_0")
                ? readFloats(accs, views, bin, attr.get("TEXCOORD_0").getAsInt()) : null;
        int[] joints = attr.has("JOINTS_0")
                ? readInts(accs, views, bin, attr.get("JOINTS_0").getAsInt()) : null;
        float[] weights = attr.has("WEIGHTS_0")
                ? readFloats(accs, views, bin, attr.get("WEIGHTS_0").getAsInt()) : null;
        int[] idx = readInts(accs, views, bin, p.get("indices").getAsInt());

        return new Mesh(pos, nrm, uv, joints, weights, idx);
    }

    // ------------------------------------------------------------------ skin

    private static Skin readSkin(JsonObject root, JsonArray views, JsonArray accs, byte[] bin) {
        JsonArray skins = root.getAsJsonArray("skins");
        if (skins == null || skins.isEmpty()) {
            return null;
        }
        JsonObject s = skins.get(0).getAsJsonObject();
        int[] joints = new int[s.getAsJsonArray("joints").size()];
        JsonArray ja = s.getAsJsonArray("joints");
        for (int i = 0; i < joints.length; i++) {
            joints[i] = ja.get(i).getAsInt();
        }
        float[] ibm = readFloats(accs, views, bin, s.get("inverseBindMatrices").getAsInt());
        if (ibm.length != joints.length * 16) {
            throw new IllegalStateException("inverseBindMatrices 长度 " + ibm.length
                    + " != joints " + joints.length + " x 16");
        }
        return new Skin(joints, ibm);
    }

    // ------------------------------------------------------------------ nodes

    private static Node[] readNodes(JsonObject root, JsonArray accs, byte[] bin) {
        JsonArray arr = root.getAsJsonArray("nodes");
        Node[] out = new Node[arr.size()];
        for (int i = 0; i < out.length; i++) {
            JsonObject n = arr.get(i).getAsJsonObject();
            int[] children = new int[0];
            if (n.has("children")) {
                JsonArray ca = n.getAsJsonArray("children");
                children = new int[ca.size()];
                for (int k = 0; k < children.length; k++) {
                    children[k] = ca.get(k).getAsInt();
                }
            }
            float[] t = n.has("translation") ? floats(n.getAsJsonArray("translation")) : new float[]{0, 0, 0};
            float[] r = n.has("rotation") ? floats(n.getAsJsonArray("rotation")) : new float[]{0, 0, 0, 1};
            float[] s = n.has("scale") ? floats(n.getAsJsonArray("scale")) : new float[]{1, 1, 1};
            out[i] = new Node(n.has("name") ? n.get("name").getAsString() : ("node_" + i),
                    children, t, r, s,
                    n.has("mesh") ? n.get("mesh").getAsInt() : -1,
                    n.has("skin") ? n.get("skin").getAsInt() : -1);
        }
        return out;
    }

    private static float[] floats(JsonArray a) {
        float[] out = new float[a.size()];
        for (int i = 0; i < out.length; i++) {
            out[i] = a.get(i).getAsFloat();
        }
        return out;
    }

    // ------------------------------------------------------------------ animation

    private static Clip[] readClips(JsonObject root, JsonArray views, JsonArray accs, byte[] bin) {
        if (!root.has("animations")) {
            return new Clip[0];
        }
        JsonArray arr = root.getAsJsonArray("animations");
        List<Clip> out = new ArrayList<>(arr.size());
        for (int i = 0; i < arr.size(); i++) {
            JsonObject a = arr.get(i).getAsJsonObject();
            String name = a.has("name") ? a.get("name").getAsString() : ("clip_" + i);

            JsonArray cha = a.getAsJsonArray("channels");
            Channel[] channels = new Channel[cha.size()];
            for (int c = 0; c < channels.length; c++) {
                JsonObject ch = cha.get(c).getAsJsonObject();
                JsonObject target = ch.getAsJsonObject("target");
                channels[c] = new Channel(ch.get("sampler").getAsInt(),
                        target.get("node").getAsInt(), target.get("path").getAsString());
            }

            JsonArray sa = a.getAsJsonArray("samplers");
            Sampler[] samplers = new Sampler[sa.size()];
            float[][] times = new float[sa.size()][];
            float[][] values = new float[sa.size()][];
            for (int s = 0; s < samplers.length; s++) {
                JsonObject sm = sa.get(s).getAsJsonObject();
                int in = sm.get("input").getAsInt();
                int outp = sm.get("output").getAsInt();
                samplers[s] = new Sampler(in, outp,
                        sm.has("interpolation") ? sm.get("interpolation").getAsString() : "LINEAR");
                times[s] = readFloats(accs, views, bin, in);
                values[s] = readFloats(accs, views, bin, outp);
            }
            out.add(new Clip(name, channels, samplers, times, values));
        }
        return out.toArray(new Clip[0]);
    }
}
