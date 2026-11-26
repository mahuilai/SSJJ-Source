using System;
using System.Collections.Generic;
using System.IO;
using NetData;
using SSJJ.Data;
using SSJJ.Server.Config;
using SSJJ.Server.GameModes;
using SSJJ.Server.Physics;
using SSJJ.Server.QuakeServer;

namespace SSJJ.Server.Snapshot
{
    public sealed class SceneWeaponDrop
    {
        public const float PickupRadius = 95f;
        public const float PickupHeight = 120f;

        public int Id { get; set; }
        public string WeaponName { get; set; } = "c4";
        public string WeaponSkin { get; set; } = "";
        public int WeaponType { get; set; } = 3;
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }
        public float Yaw { get; set; }
        public float Pitch { get; set; }
    }

    public sealed class HitWallSnapshotEvent
    {
        public int EventId { get; set; }
        public int OwnerId { get; set; }
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }
        public float Yaw { get; set; }
        public string WeaponName { get; set; } = "m4a1";
    }

    /// <summary>
    /// 原生 ParseOld 快照序列化器（100% 使用 SSJJ.Contract NetData + ProtobufSerializer，完全对齐 AbstractSnapshotParser.ParseOld）
    /// </summary>
    public static class SV_Snapshot
    {
        private static readonly ProtobufSerializer _proto = new ProtobufSerializer();
        private static int _nextTempEntityId = 50000;

        public static int AllocTempEntityId()
        {
            int id = System.Threading.Interlocked.Increment(ref _nextTempEntityId);
            if (id > 900000) _nextTempEntityId = 50000;
            return id;
        }

        public static byte[] SerializeSnapshot(
            int seqId,
            int serverTimeMs,
            int lastCmdSeq,
            ServerConfig cfg,
            GameTables tables,
            IReadOnlyList<PlayerBasicInfo> players,
            IReadOnlyList<SceneWeaponDrop>? sceneDrops = null,
            IReadOnlyList<GrenadeExplosionEventData>? explosions = null,
            IReadOnlyList<HitEventData>? hits = null,
            IReadOnlyList<int>? deletedIds = null,
            IReadOnlyList<PveTowerEntityData>? pveTowers = null,
            int observerTargetId = 0,
            int selfPlayerId = 1,
            IReadOnlyList<SceneSmokeData>? smokeClouds = null,
            IReadOnlyList<SceneBufEntityData>? sceneBuffs = null)
        {
            using var ms = new MemoryStream();

            var observer = observerTargetId > 0 ? FindPlayer(players, observerTargetId) : null;
            var bagOwner = observer ?? FindPlayer(players, selfPlayerId);
            int raceType = cfg.EffectiveRaceType;
            bool meleeOnly = ServerConfig.IsMeleeOnly(raceType);

            var bagList = new PlayerBagListData();
            if (bagOwner?.HasC4 == true)
            {
                bagList.C4Weapon = new BaseWeaponData
                {
                    Id = 5,
                    WeaponName = "c4",
                    Clip = 1,
                    MaxClip = 1,
                    CarryClip = 0,
                    MaxCarryClip = 0
                };
            }

            var ownerBags = (bagOwner != null && !bagOwner.IsBot) ? cfg.GetHumanBags(bagOwner.CharacterId) : cfg.Bags;
            for (int bIdx = 0; bIdx < ownerBags.Count; bIdx++)
            {
                int bagId = bIdx + 1;
                var bagCfg = ownerBags[bIdx];
                var bagData = new PlayerBagData { BagId = bagId };
                bool isActiveBag = bagOwner != null && bagOwner.CurrentBagId == bagId;
                var loadout = bagOwner?.Loadout;

                BaseWeaponData? BuildSlot(int storageSlot, int protocolSlot, int throwableIdx, int fallbackId)
                {
                    if (ServerConfig.IsBiohazard(raceType) && bagOwner != null && BiohazardRound.IsInfected(bagOwner))
                    {
                        return protocolSlot == 3 && isActiveBag
                            ? MakeBaseWeapon(bagId, fallbackId, bagOwner.CurrentWeaponName, "", tables, bagOwner,
                                new CarriedWeapon(bagOwner.CurrentWeaponName, "", 0, 0) { EntityId = bagOwner.BioWeaponEntityId },
                                bagOwner.BioWeaponEntityId)
                            : null;
                    }
                    if (meleeOnly && storageSlot != 3) return null;
                    var carried = loadout?.Get(bagId, storageSlot);
                    bool isEquipped = isActiveBag && bagOwner!.CurrentWeapon == protocolSlot
                        && (protocolSlot != 4 || bagOwner.CurrentWeaponIndex == throwableIdx);
                    var equipped = isEquipped ? bagOwner : null;
                    string wpnName = (observer != null && equipped != null)
                        ? equipped.CurrentWeaponName
                        : (loadout == null ? bagCfg.GetSlotWeapon(storageSlot) : carried?.Name ?? "");
                    if (string.IsNullOrWhiteSpace(wpnName)) return null;
                    string wpnSkin = (observer != null && equipped != null)
                        ? equipped.CurrentWeaponSkinName
                        : (carried?.Skin ?? bagCfg.GetSlotSkin(storageSlot));
                    int wpnId = carried is { EntityId: > 0 } ? carried.EntityId
                        : carried is { StorageId: > 0 } ? carried.StorageId
                        : bagCfg.GetSlotId(storageSlot);
                    var data = MakeBaseWeapon(bagId, fallbackId, wpnName, wpnSkin, tables, equipped, carried, wpnId);
                    if (observer != null && carried is not { EntityId: > 0 })
                    {
                        data.Id = observer.GetObservedWeaponId(bagId, storageSlot, wpnName);
                    }
                    return data;
                }

                bagData.FirstWeapon = BuildSlot(1, 1, 0, 1);
                bagData.SecondaryWeapon = BuildSlot(2, 2, 0, 2);
                bagData.MeleeWeapon = BuildSlot(3, 3, 0, 3);
                bagData.BombWeapons0 = BuildSlot(4, 4, 0, 4);
                bagData.BombWeapons1 = BuildSlot(6, 4, 1, 14);
                bagData.BombWeapons2 = BuildSlot(7, 4, 2, 24);
                bagList.Bags.Add(bagData);
            }

            var header = new SnapshotData
            {
                ServerTime = serverTimeMs,
                Self = selfPlayerId,
                BagList = bagList,
                Observer = observerTargetId,
                SeqId = seqId,
                Base = -1,
                LastCmd = lastCmdSeq,
                ControlId = 0,
                MainCameraId = 0
            };
            if (deletedIds != null)
            {
                foreach (int del in deletedIds) header.DeleteIdList.Add(del);
            }

            byte[] headerBytes = SerializeProto(header);
            WriteInt32BE(ms, headerBytes.Length);
            ms.Write(headerBytes, 0, headerBytes.Length);

            // Type 1: PlayerEntityData
            foreach (var p in players)
            {
                var pe = BuildPlayerEntityData(p, cfg, serverTimeMs, selfPlayerId);
                WriteEntity(ms, 1, SerializeProto(pe));
            }

            // Type 6: SceneWeaponEntityData (dropped C4 / scene drops)
            if (sceneDrops != null)
            {
                foreach (var drop in sceneDrops)
                {
                    var swe = new SceneWeaponEntityData
                    {
                        Id = drop.Id,
                        EType = 6,
                        X = drop.X,
                        Y = drop.Y,
                        Z = drop.Z,
                        Yaw = drop.Yaw,
                        Pitch = drop.Pitch,
                        WeaponName = drop.WeaponName,
                        WeaponType = drop.WeaponType
                    };
                    if (!string.IsNullOrEmpty(drop.WeaponSkin))
                    {
                        swe.WeaponSkinName = drop.WeaponSkin;
                    }
                    WriteEntity(ms, 6, SerializeProto(swe));
                }
            }

            if (smokeClouds != null)
            {
                foreach (var smoke in smokeClouds)
                {
                    WriteEntity(ms, 9, SerializeProto(new SceneBufEntityData
                    {
                        Id = smoke.Id,
                        EType = 9,
                        X = smoke.Position.X,
                        Y = smoke.Position.Y,
                        Z = smoke.Position.Z,
                        BufName = "smoke_area",
                        Show = true,
                        Scale = new Vector3DData { X = 1f, Y = 1f, Z = 1f }
                    }));
                }
            }

            if (sceneBuffs != null)
            {
                foreach (var buff in sceneBuffs)
                {
                    WriteEntity(ms, 9, SerializeProto(buff));
                }
            }

            // Type 5: GrenadeExplosionEventEntityData
            if (explosions != null)
            {
                foreach (var exp in explosions)
                {
                    var point = exp.CollisionPoint ?? new Vector3f(exp.PosX, exp.PosY, exp.PosZ);
                    var normal = exp.CollisionNormal ?? new Vector3f(0f, 0f, 1f);
                    var ge = new GrenadeExplosionEventEntityData
                    {
                        BaseEventEntity = new BaseEventEntityData
                        {
                            Id = exp.EntityId,
                            EType = 5,
                            EventId = exp.EffectId,
                            X = exp.PosX,
                            Y = exp.PosY,
                            Z = exp.PosZ,
                            OwnerId = exp.ThrowerId,
                            Scale = new Vector3DData { X = 1f, Y = 1f, Z = 1f }
                        },
                        ResTypeID = 0,
                        WeaponName = exp.WeaponName,
                        CollisionPoint = new Vector3DData { X = point.X, Y = point.Y, Z = point.Z },
                        CollisionNormal = new Vector3DData { X = normal.X, Y = normal.Y, Z = normal.Z },
                        HaveBulletHole = exp.CollisionPoint.HasValue,
                        TimeRate = 1f
                    };
                    WriteEntity(ms, 5, SerializeProto(ge));
                }
            }

            // Type 4: BeingHitEventEntityData
            if (hits != null)
            {
                foreach (var h in hits)
                {
                    var bh = new BeingHitEventEntityData
                    {
                        BaseEventEntity = new BaseEventEntityData
                        {
                            Id = AllocTempEntityId(),
                            EType = 4,
                            OwnerId = h.VictimId,
                            X = h.AttackerX,
                            Y = h.AttackerY,
                            Z = h.AttackerZ
                        },
                        ParentId = h.VictimId,
                        ShootId = h.AttackerId,
                        Type = h.IsHeadshot ? 1 : 0,
                        Kind = h.HitPart
                    };
                    WriteEntity(ms, 4, SerializeProto(bh));
                }
            }

            // Type 14: PveTowerEntityData (PVE roadblocks / doors)
            if (pveTowers != null)
            {
                foreach (var tower in pveTowers)
                {
                    WriteEntity(ms, 14, SerializeProto(tower));
                }
            }

            return ms.ToArray();
        }

        private static BaseWeaponData MakeBaseWeapon(int bagId, int slot, string weaponName, string? weaponSkin, GameTables tables, PlayerBasicInfo? livePlayer, QuakeServer.CarriedWeapon? carried = null, int weaponId = 0)
        {
            var def = tables.GetWeapon(weaponName);
            int maxClip = def?.MaxClip ?? (slot == 3 ? 0 : 30);
            int maxCarry = def?.MaxCarryClip ?? (slot == 3 ? 0 : 120);
            float accuracy = livePlayer != null ? livePlayer.WeaponAccuracy : (def?.DefaultAccuracy ?? 0.2f);

            var bw = new BaseWeaponData
            {
                Id = weaponId > 0 ? weaponId : bagId * 10 + slot,
                WeaponName = weaponName,
                WeaponSkinName = !string.IsNullOrWhiteSpace(weaponSkin) ? weaponSkin.Trim() : "",
                DyeingColor = "",
                Texture = "",
                Clip = livePlayer?.CurrentClip ?? carried?.Clip ?? maxClip,
                MaxClip = maxClip,
                CarryClip = livePlayer?.CurrentCarryClip ?? carried?.Reserve ?? maxCarry,
                MaxCarryClip = maxCarry,
                Accuracy = accuracy,
                ShotsFired = livePlayer != null ? livePlayer.ShotsFired : 0,
                DecreaseShotsFired = livePlayer != null ? livePlayer.DecreaseShotsFired : 0,
                NextAttackTimer = livePlayer != null ? (uint)Math.Max(0f, livePlayer.NextAttackTimer) : 0u,
                NextSecondaryAttackTimer = livePlayer != null ? (uint)Math.Max(0f, livePlayer.NextSecondaryAttackTimer) : 0u,
                DelayFire = livePlayer != null && livePlayer.DelayFire,
                Direction = livePlayer?.RecoilDirection ?? carried?.RecoilDirection ?? false,
                EffectLevel = livePlayer != null ? livePlayer.WeaponEffectLevel : 0,
                Power = livePlayer != null ? livePlayer.WeaponPower : 100,
                MaxPower = livePlayer != null ? livePlayer.WeaponMaxPower : 100,
                Power2 = livePlayer != null ? livePlayer.WeaponPower2 : 0,
                MaxPower2 = livePlayer != null ? livePlayer.WeaponMaxPower2 : 100,
                SpecialMode = livePlayer != null && livePlayer.SpecialMode,
                NextSkillTimer = livePlayer != null ? livePlayer.NextSkillTimer : 0,
                IsStartReload = livePlayer != null && (livePlayer.IsStartReload || livePlayer.ReloadEndTime > 0),
                ReloadEndTime = livePlayer != null ? livePlayer.ReloadEndTime : 0
            };
            return bw;
        }

        private static PlayerEntityData BuildPlayerEntityData(PlayerBasicInfo p, ServerConfig cfg, int serverTimeMs, int selfPlayerId)
        {
            int alpha = Math.Clamp((int)Math.Round(p.Alpha * 100f), 0, 100);
            int selfAlpha = Math.Clamp((int)Math.Round(p.SelfAlpha * 100f), 0, 100);
            int torsoAnim = p.TorsoAnim > 0 ? p.TorsoAnim : 13;
            if (p.Id != selfPlayerId && !p.IsDead && p.TorsoAnimRemainMs <= 0 && torsoAnim != 13 && torsoAnim != 39)
            {
                torsoAnim = p.SpecialMode ? 39 : 13;
            }
            var pe = new PlayerEntityData
            {
                Id = p.Id,
                EType = 1,
                X = p.PosX,
                Y = p.PosY,
                Z = p.PosZ,
                Velocity = new Vector3DData { X = p.VelX, Y = p.VelY, Z = p.VelZ },
                ClientTime = p.ClientTime,
                CmdSequence = p.CmdSequence,
                RenderTime = serverTimeMs,
                ViewYaw = p.ViewYaw,
                ViewPitch = p.ViewPitch,
                PunchYaw = p.PunchYaw,
                PunchPitch = p.PunchPitch,
                DecayTime = p.DecayTime,
                MoveYaw = p.MoveYaw,
                MovePitch = p.MovePitch,
                MoveRoll = p.MoveRoll,
                LegsAnim = p.LegsAnim > 0 ? p.LegsAnim : 7,
                LegsAnimationTimer = Math.Max(0, p.LegsAnimRemainMs),
                TorsoAnim = torsoAnim,
                TorsoAnimationTimer = p.IsDead ? Math.Max(0, p.LegsAnimRemainMs) : Math.Max(0, p.TorsoAnimRemainMs),
                ViewAnim = p.ViewAnim > 0 ? p.ViewAnim : 13,
                ViewAnimationTimer = Math.Max(0, p.ViewAnimRemainMs),
                ViewAnimSpeed = p.ViewAnimSpeed > 0f ? p.ViewAnimSpeed : 1f,
                LeftViewAnim = p.LeftViewAnim > 0 ? p.LeftViewAnim : 13,
                LeftViewAnimSpeed = p.LeftViewAnimSpeed > 0f ? p.LeftViewAnimSpeed : 1f,
                LeftViewAnimationTimer = QuakeServer.PlayerPredictionEngine.IsInspectAnimation(p.ViewAnim)
                    ? 0 : Math.Max(0, p.ViewAnimRemainMs),
                Alpha = alpha,
                SelfAlpha = selfAlpha,
                Scale = 0f,
                CharacterId = p.CharacterId > 0 ? p.CharacterId : (p.Id == 1 ? cfg.CharId : 100000L + p.Id),
                PlayerName = p.PlayerName,
                Career = string.IsNullOrWhiteSpace(p.Career) ? "police" : p.Career,
                CurrentHandName = string.IsNullOrWhiteSpace(p.HandName) ? "man" : p.HandName,
                RoleColors = "",
                Texture = "",
                InvincibleTime = p.InvincibleTime,
                CurrentBagId = p.CurrentBagId,
                CanChangeBag = p.CanChangeBag && !p.IsDead,
                CurrentWeapon = p.CurrentWeapon,
                CurrentWeaponName = string.IsNullOrWhiteSpace(p.CurrentWeaponName) ? "m4a1" : p.CurrentWeaponName,
                CurrentWeaponIndex = p.CurrentWeaponIndex,
                CurrentWeaponSkinName = !string.IsNullOrWhiteSpace(p.CurrentWeaponSkinName) ? p.CurrentWeaponSkinName.Trim() : "",
                CurrentWeaponEffectLevel = p.WeaponEffectLevel,
                Fov = p.Fov,
                LastFov = p.LastFov,
                ResumeZoom = p.ResumeZoom,
                IsDead = p.IsDead,
                DeadTimer = p.DeadTimerMs,
                Moving = p.Moving,
                OnGround = p.OnGround,
                GroundEntityNum = p.GroundEntityNum,
                Stamina = p.Stamina,
                Velocity2D = (int)p.Velocity2D,
                ViewHeight = p.ViewHeight,
                DuckState = p.DuckState,
                DuckTime = p.DuckTime,
                PlayerStateFlag = p.StateFlag != 0 ? p.StateFlag : p.PlayerStateFlag,
                BeingHitFriction = p.BeingHitFriction > 0f ? p.BeingHitFriction : 16f,
                LimitSpeedInJumpRule = p.LimitSpeedInJumpRule,
                Team = p.Team,
                TeamId = p.Team,
                Hp = p.Hp,
                MaxHp = p.MaxHp,
                Zhuangjia = p.Zhuangjia,
                MaxZhuangjia = 100,
                ArmorHead = p.Zhuangjia > 0,
                ArmorBody = p.Zhuangjia > 0,
                Hudun = p.Hudun,
                MaxHudun = 100,
                HasC4 = p.HasC4,
                C4Flag = p.HasC4,
                HeadEnlarge = p.HeadEnlarge,
                OtherHeadEnlarge = p.OtherHeadEnlarge,
                IsBot = p.IsBot,
                BotQuality = p.BotQuality,
                ControlEntityId = p.ControlEntityId,
                GravityEffectRate = 1f,
                Airaccelerate = p.Airaccelerate > 0f ? p.Airaccelerate : 10f,
                LegsSpeedAnimTime = (int)p.LegsSpeedAnimTime,
                TorsoAnimStartTime = (int)p.TorsoAnimStartTime
            };

            if (p.BioRespawnRemainingMs is int respawnMs)
                pe.CanReliveTime = respawnMs;

            if (!string.IsNullOrWhiteSpace(p.CareerSkin))
            {
                pe.CareerSkin = p.CareerSkin;
            }
            if (p.AccessoryList != null)
            {
                foreach (int acc in p.AccessoryList) pe.AccessoryList.Add(acc.ToString());
            }

            return pe;
        }

        private static PlayerBasicInfo? FindPlayer(IReadOnlyList<PlayerBasicInfo> players, int id)
        {
            for (int i = 0; i < players.Count; i++)
            {
                if (players[i].Id == id) return players[i];
            }
            return null;
        }

        private static void WriteEntity(MemoryStream ms, byte entityType, byte[] data)
        {
            ms.WriteByte(entityType);
            WriteInt32BE(ms, data.Length);
            ms.Write(data, 0, data.Length);
        }

        private static void WriteInt32BE(MemoryStream ms, int val)
        {
            ms.WriteByte((byte)((val >> 24) & 0xFF));
            ms.WriteByte((byte)((val >> 16) & 0xFF));
            ms.WriteByte((byte)((val >> 8) & 0xFF));
            ms.WriteByte((byte)(val & 0xFF));
        }

        private static byte[] SerializeProto<T>(T obj)
        {
            using var ms = new MemoryStream();
            _proto.Serialize(ms, obj);
            return ms.ToArray();
        }
    }
}
