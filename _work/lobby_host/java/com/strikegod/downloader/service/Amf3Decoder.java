package com.strikegod.downloader.service;

import java.io.EOFException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class Amf3Decoder {

    private final byte[] data;
    private int pos;
    private final List<String> stringRefs = new ArrayList<>();
    private final List<Object> objectRefs = new ArrayList<>();
    private final List<Trait> traitRefs = new ArrayList<>();

    public Amf3Decoder(byte[] data) {
        this.data = data;
    }

    public Object decodeOne() throws IOException {
        return readValue();
    }

    public List<Object> decodeAll() throws IOException {
        var values = new ArrayList<>();
        while (pos < data.length) {
            values.add(readValue());
        }
        return values;
    }

    private Object readValue() throws IOException {
        int marker = readU8();
        return switch (marker) {
            case 0x00, 0x01 -> null;
            case 0x02 -> false;
            case 0x03 -> true;
            case 0x04 -> readInteger();
            case 0x05 -> readDouble();
            case 0x06 -> readString();
            case 0x07, 0x0B -> readXml();
            case 0x08 -> readDate();
            case 0x09 -> readArray();
            case 0x0A -> readObject();
            case 0x0C -> readByteArray();
            case 0x0D -> readVectorInt();
            case 0x0E -> readVectorUInt();
            case 0x0F -> readVectorDouble();
            case 0x10 -> readVectorObject();
            case 0x11 -> readDictionary();
            default -> throw new IOException("Unsupported AMF3 marker 0x" + Integer.toHexString(marker) + " at " + (pos - 1));
        };
    }

    private int readInteger() throws IOException {
        int value = readU29();
        if ((value & 0x10000000) != 0) {
            value |= 0xE0000000;
        }
        return value;
    }

    private String readString() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            return stringRefs.get(header >> 1);
        }
        int length = header >> 1;
        if (length == 0) {
            return "";
        }
        String value = readUtf8(length);
        stringRefs.add(value);
        return value;
    }

    private String readXml() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            Object ref = objectRefs.get(header >> 1);
            return ref == null ? null : ref.toString();
        }
        String value = readUtf8(header >> 1);
        objectRefs.add(value);
        return value;
    }

    private Object readDate() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            return objectRefs.get(header >> 1);
        }
        var date = new LinkedHashMap<String, Object>();
        objectRefs.add(date);
        date.put("$date", readDouble());
        return date;
    }

    private Object readArray() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            return objectRefs.get(header >> 1);
        }

        int denseCount = header >> 1;
        var dense = new ArrayList<Object>(denseCount);
        int refIndex = objectRefs.size();
        objectRefs.add(dense);

        var assoc = new LinkedHashMap<String, Object>();
        while (true) {
            String key = readString();
            if (key.isEmpty()) {
                break;
            }
            assoc.put(key, readValue());
        }

        for (int i = 0; i < denseCount; i++) {
            dense.add(readValue());
        }

        if (assoc.isEmpty()) {
            return dense;
        }

        var mixed = new LinkedHashMap<String, Object>(assoc);
        if (!dense.isEmpty()) {
            mixed.put("$dense", dense);
        }
        objectRefs.set(refIndex, mixed);
        return mixed;
    }

    private Object readObject() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            return objectRefs.get(header >> 1);
        }

        Trait trait;
        if ((header & 3) == 1) {
            trait = traitRefs.get(header >> 2);
        } else {
            boolean externalizable = (header & 4) != 0;
            boolean dynamic = (header & 8) != 0;
            int sealedCount = header >> 4;
            String className = readString();
            var sealedNames = new ArrayList<String>(sealedCount);
            for (int i = 0; i < sealedCount; i++) {
                sealedNames.add(readString());
            }
            trait = new Trait(className, dynamic, externalizable, sealedNames);
            traitRefs.add(trait);
        }

        var object = new LinkedHashMap<String, Object>();
        objectRefs.add(object);
        if (!trait.className().isEmpty()) {
            object.put("$class", trait.className());
        }

        if (trait.externalizable()) {
            object.put("$value", readValue());
            return object;
        }

        for (String name : trait.sealedNames()) {
            object.put(name, readValue());
        }

        if (trait.dynamic()) {
            while (true) {
                String key = readString();
                if (key.isEmpty()) {
                    break;
                }
                object.put(key, readValue());
            }
        }

        return object;
    }

    private Object readByteArray() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            return objectRefs.get(header >> 1);
        }
        int length = header >> 1;
        require(length);
        byte[] bytes = new byte[length];
        System.arraycopy(data, pos, bytes, 0, length);
        pos += length;
        var out = new LinkedHashMap<String, Object>();
        out.put("$bytesBase64", Base64.getEncoder().encodeToString(bytes));
        objectRefs.add(out);
        return out;
    }

    private Object readVectorInt() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            return objectRefs.get(header >> 1);
        }
        int length = header >> 1;
        readU8();
        var vector = new ArrayList<Integer>(length);
        objectRefs.add(vector);
        for (int i = 0; i < length; i++) {
            vector.add(readI32());
        }
        return vector;
    }

    private Object readVectorUInt() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            return objectRefs.get(header >> 1);
        }
        int length = header >> 1;
        readU8();
        var vector = new ArrayList<Long>(length);
        objectRefs.add(vector);
        for (int i = 0; i < length; i++) {
            vector.add(readU32());
        }
        return vector;
    }

    private Object readVectorDouble() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            return objectRefs.get(header >> 1);
        }
        int length = header >> 1;
        readU8();
        var vector = new ArrayList<Double>(length);
        objectRefs.add(vector);
        for (int i = 0; i < length; i++) {
            vector.add(readDouble());
        }
        return vector;
    }

    private Object readVectorObject() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            return objectRefs.get(header >> 1);
        }
        int length = header >> 1;
        readU8();
        readString();
        var vector = new ArrayList<Object>(length);
        objectRefs.add(vector);
        for (int i = 0; i < length; i++) {
            vector.add(readValue());
        }
        return vector;
    }

    private Object readDictionary() throws IOException {
        int header = readU29();
        if ((header & 1) == 0) {
            return objectRefs.get(header >> 1);
        }
        int length = header >> 1;
        readU8();
        var entries = new ArrayList<Object>(length);
        objectRefs.add(entries);
        for (int i = 0; i < length; i++) {
            var entry = new LinkedHashMap<String, Object>();
            entry.put("key", readValue());
            entry.put("value", readValue());
            entries.add(entry);
        }
        return entries;
    }

    private int readU29() throws IOException {
        int b = readU8();
        if (b < 128) {
            return b;
        }
        int value = (b & 0x7F) << 7;
        b = readU8();
        if (b < 128) {
            return value | b;
        }
        value = (value | (b & 0x7F)) << 7;
        b = readU8();
        if (b < 128) {
            return value | b;
        }
        value = (value | (b & 0x7F)) << 8;
        b = readU8();
        return value | b;
    }

    private double readDouble() throws IOException {
        long bits = readU64();
        return Double.longBitsToDouble(bits);
    }

    private int readI32() throws IOException {
        return (int) readU32();
    }

    private long readU32() throws IOException {
        require(4);
        long value = ((long) data[pos] & 0xFF) << 24
                | ((long) data[pos + 1] & 0xFF) << 16
                | ((long) data[pos + 2] & 0xFF) << 8
                | ((long) data[pos + 3] & 0xFF);
        pos += 4;
        return value;
    }

    private long readU64() throws IOException {
        require(8);
        long value = 0;
        for (int i = 0; i < 8; i++) {
            value = (value << 8) | (data[pos++] & 0xFFL);
        }
        return value;
    }

    private int readU8() throws IOException {
        require(1);
        return data[pos++] & 0xFF;
    }

    private String readUtf8(int length) throws IOException {
        require(length);
        String value = new String(data, pos, length, StandardCharsets.UTF_8);
        pos += length;
        return value;
    }

    private void require(int count) throws EOFException {
        if (count < 0 || pos + count > data.length) {
            throw new EOFException("Unexpected AMF3 EOF at " + pos);
        }
    }

    private record Trait(String className, boolean dynamic, boolean externalizable, List<String> sealedNames) {}
}
