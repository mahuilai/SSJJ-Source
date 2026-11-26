using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using SSJJ.Server.Physics;
using SSJJ.Server.Snapshot;

namespace SSJJ.Server.QuakeServer;

/// <summary>
/// Server-authoritative 17-bone OBB hitbox evaluator backed by extracted native
/// hitbox.xml + model.prefab rest transforms (SSJJ-Server/Data/player_hitboxes.json).
/// </summary>
public static class PlayerHitboxSystem
{
    public readonly record struct BoneHitbox(
        string BoneName,
        int HitPart,
        Vector3f RestCenterSsjj,
        Vector3f SizeSsjj,
        Vector3f AxisXSsjj,
        Vector3f AxisYSsjj,
        Vector3f AxisZSsjj,
        bool IsUpperBody,
        bool IsLegJoint);

    public sealed class CareerHitboxRig
    {
        public string Key { get; }
        public IReadOnlyList<BoneHitbox> Bones { get; }

        internal CareerHitboxRig(string key, IReadOnlyList<BoneHitbox> bones)
        {
            Key = key;
            Bones = bones;
        }
    }

    private sealed class RigJson
    {
        public List<NodeJson>? rig { get; set; }
        public List<HitboxJson>? hitboxes { get; set; }
    }

    private sealed class NodeJson
    {
        public string? name { get; set; }
        public int? parent { get; set; }
        public float[]? position { get; set; }
        public float[]? rotation_xyzw { get; set; }
        public float[]? scale { get; set; }
    }

    private sealed class HitboxJson
    {
        public string? bone { get; set; }
        public int node { get; set; }
        public float[]? center { get; set; }
        public float[]? size { get; set; }
    }

    private readonly record struct Quat(float X, float Y, float Z, float W)
    {
        public static Quat Multiply(Quat a, Quat b) => new(
            a.W * b.X + a.X * b.W + a.Y * b.Z - a.Z * b.Y,
            a.W * b.Y - a.X * b.Z + a.Y * b.W + a.Z * b.X,
            a.W * b.Z + a.X * b.Y - a.Y * b.X + a.Z * b.W,
            a.W * b.W - a.X * b.X - a.Y * b.Y - a.Z * b.Z);

        public Vector3f Rotate(Vector3f v)
        {
            float tx = 2f * (Y * v.Z - Z * v.Y);
            float ty = 2f * (Z * v.X - X * v.Z);
            float tz = 2f * (X * v.Y - Y * v.X);
            return new Vector3f(
                v.X + W * tx + Y * tz - Z * ty,
                v.Y + W * ty + Z * tx - X * tz,
                v.Z + W * tz + X * ty - Y * tx);
        }
    }

    private static readonly Lazy<Dictionary<string, CareerHitboxRig>> _rigs = new(LoadRigs);

    public static CareerHitboxRig? GetRig(string? career)
    {
        var rigs = _rigs.Value;
        if (rigs.Count == 0) return null;

        string key = string.IsNullOrWhiteSpace(career) ? "players/police" : $"players/{career.Trim()}";
        if (rigs.TryGetValue(key, out var exact)) return exact;

        if (!string.IsNullOrWhiteSpace(career))
        {
            string lower = career.ToLowerInvariant();
            if (lower.Contains("doun_master")) return rigs.GetValueOrDefault("players/doun_master") ?? rigs.Values.First();
            if (lower.Contains("doun")) return rigs.GetValueOrDefault("players/doun") ?? rigs.Values.First();
            if (lower.Contains("pandora_t")) return rigs.GetValueOrDefault("players/pandora_t") ?? rigs.Values.First();
            if (lower.Contains("pandora") || lower.Contains("woman") || lower.Contains("queen") || lower.Contains("rose"))
                return rigs.GetValueOrDefault("players/pandora_ct") ?? rigs.GetValueOrDefault("players/feihuwoman") ?? rigs.Values.First();
            if (lower.Contains("ct_knight")) return rigs.GetValueOrDefault("players/ct_knight1") ?? rigs.Values.First();
        }
        return rigs.GetValueOrDefault("players/police") ?? rigs.Values.First();
    }

    public static int LoadedRigCount => _rigs.Value.Count;

    // The names and integer groups are defined by the native HitBoxGroupUtilty.
    public static int GetHitPartForBone(string? boneName) => boneName switch
    {
        "Bip01_Head" => 1,
        "Bip01_Neck" or "Bip01_Spine1" or "Bip01_Spine2" or "Bip01_Spine3" => 2,
        "Bip01_Spine" or "Bip01_Pelvis" => 3,
        "Bip01_L_UpperArm" or "Bip01_L_Forearm" or "Bip01_L_Hand" => 4,
        "Bip01_R_UpperArm" or "Bip01_R_Forearm" or "Bip01_R_Hand" => 5,
        "Bip01_R_Thigh" or "Bip01_R_Calf" or "Bip01_R_Foot" => 6,
        "Bip01_L_Thigh" or "Bip01_L_Calf" or "Bip01_L_Foot" => 7,
        "dunpai" => 9,
        _ => 8
    };

    /// <summary>
    /// Computes the third-person model yaw matching OrientationAnimSystem.CommonUpdateOrientation.
    /// </summary>
    public static float ResolveBodyYaw(float viewYaw, float moveYaw, bool moving, int duckState)
    {
        if (!moving || duckState == 2) return viewYaw;
        float diff = WrapAngle180(viewYaw - moveYaw);
        return MathF.Abs(diff) - 90f > 0.1f ? WrapAngle180(moveYaw + 180f) : moveYaw;
    }

    /// <summary>
    /// Raycasts against all 17 oriented bone hitboxes of the target at the specified stance/orientation.
    /// Returns true on hit with closest entry distance, hit world point, bone name, and native hitPart.
    /// </summary>
    public static bool RaycastTarget(
        Vector3f rayOrigin,
        Vector3f rayDirNormalized,
        float maxDistance,
        PlayerTargetState target,
        out float hitDistance,
        out Vector3f hitPoint,
        out string hitBone,
        out int hitPart)
    {
        hitDistance = maxDistance;
        hitPoint = default;
        hitBone = "";
        hitPart = 2;

        var rig = GetRig(target.Career);
        if (rig == null || rig.Bones.Count == 0)
        {
            return RaycastFallbackCylinder(rayOrigin, rayDirNormalized, maxDistance, target, out hitDistance, out hitPoint, out hitPart);
        }

        // Transform ray into target character-local SSJJ space (yaw-aligned around world Z).
        float bodyYawRad = ResolveBodyYaw(target.ViewYaw, target.MoveYaw, target.Moving, target.DuckState) * (MathF.PI / 180f);
        float cosY = MathF.Cos(bodyYawRad);
        float sinY = MathF.Sin(bodyYawRad);

        Vector3f relOrig = rayOrigin - target.Position;
        Vector3f localOrig = new(relOrig.X * cosY + relOrig.Y * sinY, -relOrig.X * sinY + relOrig.Y * cosY, relOrig.Z);
        Vector3f localDir = new(rayDirNormalized.X * cosY + rayDirNormalized.Y * sinY, -rayDirNormalized.X * sinY + rayDirNormalized.Y * cosY, rayDirNormalized.Z);

        // Stance articulation aligned with BoundBoxConfig & ViewHeight (standing=150, crouch=93, duckJump minZ=60).
        // Native T-pose has Biped head at ~167cm; subtle standing idle spine/knee flex centers eye/head at ~152cm.
        float crouchDropZ = target.DuckState is 0 or 1
            ? (target.ViewHeight < 140f ? Math.Clamp(150f - target.ViewHeight, 40f, 65f) : 57f)
            : 0f;
        float duckJumpRaiseZ = target.DuckState == 2 ? 55f : 0f;

        bool hitAny = false;
        float bestT = maxDistance;

        foreach (var bone in rig.Bones)
        {
            float idleFlexZ = bone.HitPart switch
            {
                1 => -13f,
                2 => bone.BoneName.Contains("Neck", StringComparison.OrdinalIgnoreCase) ? -11f : -4f,
                3 => -4f,
                4 or 5 => -6f,
                _ => 0f
            };
            float zOffset = idleFlexZ;
            float xOffset = 0f;
            if (crouchDropZ > 0f)
            {
                if (bone.IsUpperBody)
                {
                    zOffset -= crouchDropZ;
                }
                else if (bone.BoneName.Contains("Thigh", StringComparison.OrdinalIgnoreCase))
                {
                    zOffset -= crouchDropZ * 0.65f;
                    xOffset = 10f;
                }
                else if (bone.BoneName.Contains("Calf", StringComparison.OrdinalIgnoreCase))
                {
                    zOffset -= 12f;
                }
            }
            else if (duckJumpRaiseZ > 0f && bone.IsLegJoint)
            {
                zOffset += duckJumpRaiseZ;
                xOffset = 6f;
            }

            Vector3f center = new(bone.RestCenterSsjj.X + xOffset, bone.RestCenterSsjj.Y,
                Math.Clamp(bone.RestCenterSsjj.Z + zOffset, target.MinZ + 4f, target.MaxZ - 4f));
            Vector3f half = new(bone.SizeSsjj.X * 0.5f + 0.5f, bone.SizeSsjj.Y * 0.5f + 0.5f, bone.SizeSsjj.Z * 0.5f + 0.5f);

            if (IntersectRayObb(localOrig, localDir, center, bone.AxisXSsjj, bone.AxisYSsjj, bone.AxisZSsjj, half, bestT, out float t))
            {
                float hitWorldZ = rayOrigin.Z + rayDirNormalized.Z * t;
                if (!target.EnclosesHeight(hitWorldZ)) continue;
                hitAny = true;
                bestT = t;
                hitDistance = t;
                hitBone = bone.BoneName;
                hitPart = bone.HitPart;
            }
        }

        if (hitAny)
        {
            hitPoint = rayOrigin + rayDirNormalized * bestT;
        }
        return hitAny;
    }

    private static bool RaycastFallbackCylinder(
        Vector3f rayOrigin,
        Vector3f rayDir,
        float maxDistance,
        PlayerTargetState target,
        out float hitDistance,
        out Vector3f hitPoint,
        out int hitPart)
    {
        hitDistance = maxDistance;
        hitPoint = default;
        hitPart = 2;

        float dx = target.Position.X - rayOrigin.X;
        float dy = target.Position.Y - rayOrigin.Y;
        float dz = (target.Position.Z + 100f) - rayOrigin.Z;
        float proj = dx * rayDir.X + dy * rayDir.Y + dz * rayDir.Z;
        if (proj <= 0f || proj >= maxDistance) return false;

        Vector3f p = rayOrigin + rayDir * proj;
        float rx = p.X - target.Position.X;
        float ry = p.Y - target.Position.Y;
        if (rx * rx + ry * ry > 32f * 32f || !target.EnclosesHeight(p.Z)) return false;

        hitDistance = proj;
        hitPoint = p;
        if (p.Z >= target.Position.Z + 135f) hitPart = 1;
        else if (p.Z >= target.Position.Z + 95f) hitPart = 2;
        else if (p.Z >= target.Position.Z + 65f) hitPart = 3;
        else
        {
            // The cylinder can only estimate which side of the body was hit.
            float yaw = ResolveBodyYaw(target.ViewYaw, target.MoveYaw, target.Moving, target.DuckState) * (MathF.PI / 180f);
            float left = -rx * MathF.Sin(yaw) + ry * MathF.Cos(yaw);
            hitPart = left > 0f ? 7 : 6;
        }
        return true;
    }

    private static bool IntersectRayObb(
        Vector3f orig, Vector3f dir, Vector3f center,
        Vector3f axisX, Vector3f axisY, Vector3f axisZ,
        Vector3f halfExtents, float maxT, out float tEnter)
    {
        tEnter = 0f;
        float tMin = 0f;
        float tMax = maxT;
        Vector3f delta = center - orig;

        if (!TestSlab(Vector3f.Dot(delta, axisX), Vector3f.Dot(dir, axisX), halfExtents.X, ref tMin, ref tMax)) return false;
        if (!TestSlab(Vector3f.Dot(delta, axisY), Vector3f.Dot(dir, axisY), halfExtents.Y, ref tMin, ref tMax)) return false;
        if (!TestSlab(Vector3f.Dot(delta, axisZ), Vector3f.Dot(dir, axisZ), halfExtents.Z, ref tMin, ref tMax)) return false;

        tEnter = tMin;
        return tMin <= tMax && tMin <= maxT && tMax >= 0f;
    }

    private static bool TestSlab(float e, float f, float half, ref float tMin, ref float tMax)
    {
        if (MathF.Abs(f) > 1e-6f)
        {
            float t1 = (e - half) / f;
            float t2 = (e + half) / f;
            if (t1 > t2) (t1, t2) = (t2, t1);
            if (t1 > tMin) tMin = t1;
            if (t2 < tMax) tMax = t2;
            return tMin <= tMax && tMax >= 0f;
        }
        return -e - half <= 0f && -e + half >= 0f;
    }

    private static Vector3f UnityToSsjj(Vector3f u) => new(u.X, u.Z, u.Y);

    private static float WrapAngle180(float angle)
    {
        while (angle > 180f) angle -= 360f;
        while (angle < -180f) angle += 360f;
        return angle;
    }

    private static Dictionary<string, CareerHitboxRig> LoadRigs()
    {
        var result = new Dictionary<string, CareerHitboxRig>(StringComparer.OrdinalIgnoreCase);
        try
        {
            string[] candidates =
            {
                Path.Combine(AppContext.BaseDirectory, "Data", "player_hitboxes.json"),
                Path.Combine(AppContext.BaseDirectory, "player_hitboxes.json"),
                Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "Data", "player_hitboxes.json")),
                Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "SSJJ-Server", "Data", "player_hitboxes.json"))
            };
            string? foundPath = candidates.FirstOrDefault(File.Exists);
            if (foundPath == null) return result;

            var parsed = JsonSerializer.Deserialize<Dictionary<string, RigJson>>(File.ReadAllText(foundPath));
            if (parsed == null) return result;

            foreach (var (key, rigData) in parsed)
            {
                if (rigData.rig == null || rigData.hitboxes == null || rigData.rig.Count == 0) continue;

                var worldPos = new Vector3f[rigData.rig.Count];
                var worldRot = new Quat[rigData.rig.Count];
                for (int i = 0; i < rigData.rig.Count; i++)
                {
                    var node = rigData.rig[i];
                    var pos = ToVec(node.position);
                    var rot = ToQuat(node.rotation_xyzw);
                    if (node.parent is int parentIdx && parentIdx >= 0 && parentIdx < i)
                    {
                        var pScale = ToVec(rigData.rig[parentIdx].scale, defaultVal: 1f);
                        var scaledPos = new Vector3f(pos.X * pScale.X, pos.Y * pScale.Y, pos.Z * pScale.Z);
                        worldPos[i] = worldPos[parentIdx] + worldRot[parentIdx].Rotate(scaledPos);
                        worldRot[i] = Quat.Multiply(worldRot[parentIdx], rot);
                    }
                    else
                    {
                        worldPos[i] = pos;
                        worldRot[i] = rot;
                    }
                }

                var bones = new List<BoneHitbox>(rigData.hitboxes.Count);
                foreach (var hb in rigData.hitboxes)
                {
                    if (string.IsNullOrEmpty(hb.bone) || hb.node < 0 || hb.node >= worldPos.Length) continue;
                    var wp = worldPos[hb.node];
                    var wr = worldRot[hb.node];
                    var rawCenter = ToVec(hb.center);
                    // Unity FBX/AssetBundle bone transforms negate bone-local X relative to 3dsMax Biped/hitbox.xml.
                    var centerUnity = wp + wr.Rotate(new Vector3f(-rawCenter.X, rawCenter.Y, rawCenter.Z));
                    var size = ToVec(hb.size, defaultVal: 16f);

                    var ax = UnityToSsjj(wr.Rotate(new Vector3f(1, 0, 0))).Normalized();
                    var ay = UnityToSsjj(wr.Rotate(new Vector3f(0, 1, 0))).Normalized();
                    var az = UnityToSsjj(wr.Rotate(new Vector3f(0, 0, 1))).Normalized();

                    int part = GetHitPartForBone(hb.bone);
                    bool isUpper = part is >= 1 and <= 5;
                    bool isLeg = part is 6 or 7;

                    bones.Add(new BoneHitbox(
                        hb.bone,
                        part,
                        UnityToSsjj(centerUnity),
                        size,
                        ax,
                        ay,
                        az,
                        isUpper,
                        isLeg));
                }

                result[key] = new CareerHitboxRig(key, bones);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[SSJJ-Server][HITBOX] warn: failed to load player_hitboxes.json: {ex.Message}");
        }
        return result;
    }

    private static Vector3f ToVec(float[]? arr, float defaultVal = 0f) =>
        arr is { Length: >= 3 } ? new Vector3f(arr[0], arr[1], arr[2]) : new Vector3f(defaultVal, defaultVal, defaultVal);

    private static Quat ToQuat(float[]? arr) =>
        arr is { Length: >= 4 } ? new Quat(arr[0], arr[1], arr[2], arr[3]) : new Quat(0, 0, 0, 1);
}
