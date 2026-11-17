using System;
using System.Collections.Generic;
using System.IO;
using NetData;
using SSJJ.Data;
using SSJJ.Server.Config;

namespace SSJJ.Server.Snapshot
{
    public sealed class SceneWeaponDrop
    {
        public int Id { get; set; }
        public string WeaponName { get; set; } = "c4";
        public string WeaponSkin { get; set; } = "";
        public int WeaponType { get; set; } = 3;
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }
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
            IReadOnlyList<int>? deletedIds = null)
        {
            using var ms = new MemoryStream();

            var localPlayer = FindPlayer(players, 1);
            int raceType = cfg.EffectiveRaceType;
            bool meleeOnly = ServerConfig.IsMeleeOnly(raceType);

            var bagList = new PlayerBagListData();
            if (localPlayer?.HasC4 == true)
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

            for (int bIdx = 0; bIdx < cfg.Bags.Count; bIdx++)
            {
                int bagId = bIdx + 1;
                var bagCfg = cfg.Bags[bIdx];
                var bagData = new PlayerBagData { BagId = bagId };

                bool isActiveBag = localPlayer != null && localPlayer.CurrentBagId == bagId;
                if (!meleeOnly && !string.IsNullOrWhiteSpace(bagCfg.Primary))
                {
                    bagData.FirstWeapon = MakeBaseWeapon(bagId, 1, bagCfg.Primary, bagCfg.PrimarySkin, tables,
                        isActiveBag && localPlayer!.CurrentWeapon == 1 ? localPlayer : null);
                }
                if (!meleeOnly && !string.IsNullOrWhiteSpace(bagCfg.Secondary))
                {
                    bagData.SecondaryWeapon = MakeBaseWeapon(bagId, 2, bagCfg.Secondary, bagCfg.SecondarySkin, tables,
                        isActiveBag && localPlayer!.CurrentWeapon == 2 ? localPlayer : null);
                }
                if (!string.IsNullOrWhiteSpace(bagCfg.Melee))
                {
                    bagData.MeleeWeapon = MakeBaseWeapon(bagId, 3, bagCfg.Melee, bagCfg.MeleeSkin, tables,
                        isActiveBag && localPlayer!.CurrentWeapon == 3 ? localPlayer : null);
                }
                if (!meleeOnly && !string.IsNullOrWhiteSpace(bagCfg.Throwable))
                {
                    bagData.BombWeapons0 = MakeBaseWeapon(bagId, 4, bagCfg.Throwable, bagCfg.ThrowableSkin, tables,
                        isActiveBag && localPlayer!.CurrentWeapon == 4 ? localPlayer : null);
                }
                bagList.Bags.Add(bagData);
            }

            var header = new SnapshotData
            {
                ServerTime = serverTimeMs,
                Self = 1,
                BagList = bagList,
                Observer = 0,
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
                var pe = BuildPlayerEntityData(p, cfg, serverTimeMs);
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

            // Type 5: GrenadeExplosionEventEntityData
            if (explosions != null)
            {
                foreach (var exp in explosions)
                {
                    var ge = new GrenadeExplosionEventEntityData
                    {
                        BaseEventEntity = new BaseEventEntityData
                        {
                            Id = AllocTempEntityId(),
                            EType = 5,
                            X = exp.PosX,
                            Y = exp.PosY,
                            Z = exp.PosZ,
                            OwnerId = exp.ThrowerId
                        },
                        ResTypeID = exp.WeaponTid,
                        WeaponName = "grenade",
                        HaveBulletHole = true,
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

            return ms.ToArray();
        }

        private static BaseWeaponData MakeBaseWeapon(int bagId, int slot, string weaponName, string? weaponSkin, GameTables tables, PlayerBasicInfo? livePlayer)
        {
            var def = tables.GetWeapon(weaponName);
            int maxClip = def?.MaxClip ?? (slot == 3 ? 0 : 30);
            int maxCarry = def?.MaxCarryClip ?? (slot == 3 ? 0 : 120);
            float accuracy = livePlayer != null ? livePlayer.WeaponAccuracy : (def?.DefaultAccuracy ?? 0.2f);

            var bw = new BaseWeaponData
            {
                Id = bagId * 10 + slot,
                WeaponName = weaponName,
                WeaponSkinName = !string.IsNullOrWhiteSpace(weaponSkin) ? weaponSkin.Trim() : "",
                DyeingColor = "",
                Texture = "",
                Clip = livePlayer != null ? livePlayer.CurrentClip : maxClip,
                MaxClip = maxClip,
                CarryClip = livePlayer != null ? livePlayer.CurrentCarryClip : maxCarry,
                MaxCarryClip = maxCarry,
                Accuracy = accuracy,
                ShotsFired = livePlayer != null ? livePlayer.ShotsFired : 0,
                DecreaseShotsFired = livePlayer != null ? livePlayer.DecreaseShotsFired : 0,
                NextAttackTimer = livePlayer != null ? (uint)Math.Max(0f, livePlayer.NextAttackTimer) : 0u,
                NextSecondaryAttackTimer = livePlayer != null ? (uint)Math.Max(0f, livePlayer.NextSecondaryAttackTimer) : 0u,
                DelayFire = livePlayer != null && livePlayer.DelayFire,
                EffectLevel = livePlayer != null ? livePlayer.WeaponEffectLevel : 0,
                Power = livePlayer != null ? livePlayer.WeaponPower : 100,
                MaxPower = livePlayer != null ? livePlayer.WeaponMaxPower : 100,
                Power2 = livePlayer != null ? livePlayer.WeaponPower2 : 0,
                MaxPower2 = livePlayer != null ? livePlayer.WeaponMaxPower2 : 100,
                SpecialMode = livePlayer != null && livePlayer.SpecialMode,
                NextSkillTimer = livePlayer != null ? livePlayer.NextSkillTimer : 0,
                ReloadEndTime = livePlayer != null ? livePlayer.ReloadEndTime : 0
            };
            return bw;
        }

        private static PlayerEntityData BuildPlayerEntityData(PlayerBasicInfo p, ServerConfig cfg, int serverTimeMs)
        {
            int alpha = Math.Clamp((int)Math.Round(p.Alpha * 100f), 0, 100);
            int selfAlpha = Math.Clamp((int)Math.Round(p.SelfAlpha * 100f), 0, 100);
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
                MoveYaw = p.MoveYaw,
                MovePitch = p.MovePitch,
                MoveRoll = p.MoveRoll,
                LegsAnim = p.LegsAnim > 0 ? p.LegsAnim : 7,
                TorsoAnim = p.TorsoAnim > 0 ? p.TorsoAnim : 13,
                TorsoAnimationTimer = (int)(p.TorsoAnimationTimer * 1000f),
                ViewAnim = p.ViewAnim > 0 ? p.ViewAnim : 13,
                ViewAnimSpeed = p.ViewAnimSpeed > 0f ? p.ViewAnimSpeed : 1f,
                LeftViewAnim = p.LeftViewAnim > 0 ? p.LeftViewAnim : 13,
                LeftViewAnimSpeed = p.LeftViewAnimSpeed > 0f ? p.LeftViewAnimSpeed : 1f,
                Alpha = alpha,
                SelfAlpha = selfAlpha,
                Scale = 0f,
                CharacterId = p.Id == 1 ? cfg.CharId : 100000L + p.Id,
                PlayerName = p.PlayerName,
                Career = string.IsNullOrWhiteSpace(p.Career) ? "police" : p.Career,
                CurrentHandName = string.IsNullOrWhiteSpace(p.HandName) ? "man" : p.HandName,
                RoleColors = "",
                Texture = "",
                InvincibleTime = p.InvincibleTime,
                CurrentBagId = p.CurrentBagId,
                CanChangeBag = true,
                CurrentWeapon = p.CurrentWeapon,
                CurrentWeaponName = string.IsNullOrWhiteSpace(p.CurrentWeaponName) ? "m4a1" : p.CurrentWeaponName,
                CurrentWeaponIndex = p.CurrentWeaponIndex,
                CurrentWeaponSkinName = !string.IsNullOrWhiteSpace(p.CurrentWeaponSkinName) ? p.CurrentWeaponSkinName.Trim() : "",
                CurrentWeaponEffectLevel = p.WeaponEffectLevel,
                Fov = p.Fov,
                LastFov = p.Fov,
                ResumeZoom = false,
                IsDead = p.IsDead,
                DeadTimer = (int)(p.DeadTimer * 1000f),
                Moving = p.Moving,
                OnGround = p.OnGround,
                GroundEntityNum = p.GroundEntityNum,
                Stamina = p.Stamina,
                Velocity2D = (int)p.Velocity2D,
                ViewHeight = p.ViewHeight,
                DuckState = p.DuckState,
                DuckTime = p.DuckTime,
                BeingHitFriction = 16f,
                LimitSpeedInJumpRule = true,
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
                LegsSpeedAnimTime = (int)p.LegsSpeedAnimTime,
                TorsoAnimStartTime = (int)p.TorsoAnimStartTime
            };

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
