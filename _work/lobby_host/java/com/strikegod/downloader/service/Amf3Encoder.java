package com.strikegod.downloader.service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * Minimal AMF3 (action script Object encoding 3) encoder.
 * Produces output binary-compatible with Flash Player's
 * {@code ByteArray.objectEncoding = 3; writeObject(...)} for the value
 * shapes the lobby protocol actually transmits.
 *
 * Supported value types:
 *   null, Boolean, Integer/Long (in i29 range), Double/Float, String,
 *   List (dense Array), Map (dynamic anonymous Object),
 *   Amf3TypedObject (typed object with class alias + sealed slots, e.g. APC).
 *
 * Reference tables for amf3 markers and the surrounding byte layout
 * are kept in lockstep with {@link Amf3Decoder}.
 */
public final class Amf3Encoder {

    public static final int M_UNDEFINED = 0x00;
    public static final int M_NULL = 0x01;
    public static final int M_FALSE = 0x02;
    public static final int M_TRUE = 0x03;
    public static final int M_INTEGER = 0x04;
    public static final int M_DOUBLE = 0x05;
    public static final int M_STRING = 0x06;
    public static final int M_DATE = 0x08;
    public static final int M_ARRAY = 0x09;
    public static final int M_OBJECT = 0x0A;

    private final ByteArrayOutputStream buf = new ByteArrayOutputStream(512);
    private final Map<String, Integer> stringRefs = new HashMap<>();
    private final Map<Object, Integer> objectRefs = new IdentityHashMap<>();
    private final Map<TraitKey, Integer> traitRefs = new HashMap<>();

    public byte[] encode(Object value) throws IOException {
        writeValue(value);
        return buf.toByteArray();
    }

    public static byte[] encodeOnce(Object value) throws IOException {
        return new Amf3Encoder().encode(value);
    }

    private void writeValue(Object value) throws IOException {
        if (value == null) {
            buf.write(M_NULL);
            return;
        }
        if (value instanceof Boolean b) {
            buf.write(b ? M_TRUE : M_FALSE);
            return;
        }
        if (value instanceof Integer || value instanceof Short || value instanceof Byte) {
            int i = ((Number) value).intValue();
            if (i >= -(1 << 28) && i < (1 << 28)) {
                buf.write(M_INTEGER);
                writeU29(i & 0x1FFFFFFF);
            } else {
                buf.write(M_DOUBLE);
                writeDouble(i);
            }
            return;
        }
        if (value instanceof Long l) {
            if (l >= -(1L << 28) && l < (1L << 28)) {
                buf.write(M_INTEGER);
                writeU29(((int) (long) l) & 0x1FFFFFFF);
            } else {
                buf.write(M_DOUBLE);
                writeDouble(l.doubleValue());
            }
            return;
        }
        if (value instanceof Number n) {
            buf.write(M_DOUBLE);
            writeDouble(n.doubleValue());
            return;
        }
        if (value instanceof CharSequence cs) {
            buf.write(M_STRING);
            writeStringBody(cs.toString());
            return;
        }
        if (value instanceof Amf3TypedObject typed) {
            writeTypedObject(typed);
            return;
        }
        if (value instanceof Map<?, ?> m) {
            writeAnonymousObject(m);
            return;
        }
        if (value instanceof List<?> list) {
            writeDenseArray(list);
            return;
        }
        if (value instanceof Object[] arr) {
            writeDenseArray(Arrays.asList(arr));
            return;
        }
        throw new IOException("Unsupported AMF3 value: " + value.getClass().getName());
    }

    private static final TraitKey ANON_TRAIT = new TraitKey("", List.of(), true, false);

    private void writeAnonymousObject(Map<?, ?> map) throws IOException {
        buf.write(M_OBJECT);
        Integer existing = objectRefs.get(map);
        if (existing != null) {
            writeU29((existing << 1));
            return;
        }
        objectRefs.put(map, objectRefs.size());

        Integer traitIdx = traitRefs.get(ANON_TRAIT);
        if (traitIdx != null) {
            writeU29((traitIdx << 2) | 0x01);
        } else {
            traitRefs.put(ANON_TRAIT, traitRefs.size());
            // Trait header for anonymous dynamic object: 11 (binary) — dynamic + new trait, 0 sealed.
            // bits: ...sealedCount(0) | dynamic(1) | externalizable(0) | newTrait(1) | objectInline(1)
            // = (0 << 4) | (1 << 3) | (0 << 2) | (1 << 1) | 1 = 0x0B
            writeU29(0x0B);
            writeStringBody(""); // anonymous class name
        }
        for (Map.Entry<?, ?> e : map.entrySet()) {
            String k = String.valueOf(e.getKey());
            if (k.isEmpty()) continue;
            writeStringBody(k);
            writeValue(e.getValue());
        }
        writeStringBody(""); // dynamic terminator
    }

    private void writeTypedObject(Amf3TypedObject obj) throws IOException {
        buf.write(M_OBJECT);
        Integer existing = objectRefs.get(obj);
        if (existing != null) {
            writeU29((existing << 1));
            return;
        }
        objectRefs.put(obj, objectRefs.size());

        var key = new TraitKey(obj.className(), List.copyOf(obj.sealedNames()), obj.dynamic(), false);
        Integer traitIdx = traitRefs.get(key);
        if (traitIdx != null) {
            // bits: ...newTrait(0) | objectInline(1) | refType(1) for trait-ref with object inline
            // Header layout: (traitIdx << 2) | 0b01
            writeU29((traitIdx << 2) | 0x01);
        } else {
            traitRefs.put(key, traitRefs.size());
            int header = (obj.sealedNames().size() << 4)
                    | (obj.dynamic() ? 0x08 : 0)
                    | 0x03; // newTrait + objectInline (externalizable=false)
            writeU29(header);
            writeStringBody(obj.className());
            for (String n : obj.sealedNames()) {
                writeStringBody(n);
            }
        }
        for (String n : obj.sealedNames()) {
            writeValue(obj.fields().get(n));
        }
        if (obj.dynamic()) {
            for (Map.Entry<String, Object> e : obj.dynamicFields().entrySet()) {
                String k = e.getKey();
                if (k == null || k.isEmpty()) continue;
                writeStringBody(k);
                writeValue(e.getValue());
            }
            writeStringBody("");
        }
    }

    private void writeDenseArray(List<?> list) throws IOException {
        buf.write(M_ARRAY);
        if (!list.isEmpty()) {
            Integer existing = objectRefs.get(list);
            if (existing != null) {
                writeU29((existing << 1));
                return;
            }
            objectRefs.put(list, objectRefs.size());
        } else {
            objectRefs.put(new Object(), objectRefs.size());
        }

        int header = (list.size() << 1) | 1;
        writeU29(header);
        writeStringBody(""); // empty assoc terminator
        for (Object o : list) {
            writeValue(o);
        }
    }

    private void writeStringBody(String s) throws IOException {
        if (s.isEmpty()) {
            writeU29(1); // empty inline
            return;
        }
        Integer ref = stringRefs.get(s);
        if (ref != null) {
            writeU29(ref << 1);
            return;
        }
        byte[] data = s.getBytes(StandardCharsets.UTF_8);
        stringRefs.put(s, stringRefs.size());
        writeU29((data.length << 1) | 1);
        buf.write(data, 0, data.length);
    }

    private void writeU29(int value) {
        value &= 0x1FFFFFFF;
        if (value < 0x80) {
            buf.write(value);
        } else if (value < 0x4000) {
            buf.write(((value >> 7) & 0x7F) | 0x80);
            buf.write(value & 0x7F);
        } else if (value < 0x200000) {
            buf.write(((value >> 14) & 0x7F) | 0x80);
            buf.write(((value >> 7) & 0x7F) | 0x80);
            buf.write(value & 0x7F);
        } else {
            buf.write(((value >> 22) & 0x7F) | 0x80);
            buf.write(((value >> 15) & 0x7F) | 0x80);
            buf.write(((value >> 8) & 0x7F) | 0x80);
            buf.write(value & 0xFF);
        }
    }

    private void writeDouble(double v) {
        long bits = Double.doubleToLongBits(v);
        for (int i = 7; i >= 0; i--) {
            buf.write((int) ((bits >> (i * 8)) & 0xFF));
        }
    }

    private record TraitKey(String className, List<String> sealedNames, boolean dynamic, boolean externalizable) {}
}
