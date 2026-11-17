package com.strikegod.downloader.service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * AMF3 typed object wrapper used for serializing class-aliased Flash objects
 * (e.g. {@code common.net.APC}). Sealed slots are emitted in declaration order
 * followed by dynamic key/value pairs when {@link #dynamic()} is true.
 */
public final class Amf3TypedObject {
    private final String className;
    private final List<String> sealedNames;
    private final boolean dynamic;
    private final Map<String, Object> fields = new LinkedHashMap<>();
    private final Map<String, Object> dynamicFields = new LinkedHashMap<>();

    public Amf3TypedObject(String className, List<String> sealedNames, boolean dynamic) {
        this.className = className;
        this.sealedNames = List.copyOf(sealedNames);
        this.dynamic = dynamic;
    }

    public String className() { return className; }
    public List<String> sealedNames() { return sealedNames; }
    public boolean dynamic() { return dynamic; }
    public Map<String, Object> fields() { return fields; }
    public Map<String, Object> dynamicFields() { return dynamicFields; }

    public Amf3TypedObject set(String name, Object value) {
        if (sealedNames.contains(name)) {
            fields.put(name, value);
        } else {
            if (!dynamic) {
                throw new IllegalArgumentException("Cannot set dynamic field on non-dynamic object: " + name);
            }
            dynamicFields.put(name, value);
        }
        return this;
    }

    /**
     * Build the {@code common.net.APC} payload used by every {@code callRemote}.
     */
    public static Amf3TypedObject apc(String functionName, List<Object> parameters) {
        var obj = new Amf3TypedObject("common.net.APC", List.of("functionName", "parameters"), true);
        obj.set("functionName", functionName);
        obj.set("parameters", parameters);
        return obj;
    }
}
