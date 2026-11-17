using System;
using System.Collections.Generic;

namespace SSJJ.Server.Snapshot
{
    /// <summary>
    /// 对齐 DATA-CONTRACT.md：30个快照字段与139个被动消费端系统
    /// </summary>
    public class PlayerBasicInfo
    {
        public int Id { get; set; } = 1;
        public int Team { get; set; } = 1; // 1 = T, 2 = CT
        public string PlayerName { get; set; } = "Player";
        public string Career { get; set; } = "police";
        public string CareerSkin { get; set; } = "";
        public string HandName { get; set; } = "man";
        public int Hp { get; set; } = 100;
        public int MaxHp { get; set; } = 100;
        public int Zhuangjia { get; set; } = 100; // 护甲值
        public int Hudun { get; set; } = 0;       // 护盾值
        public bool IsDead { get; set; } = false;
        public bool IsBot { get; set; } = false;
        public int BotQuality { get; set; } = 0;
        public bool HasC4 { get; set; } = false;
        public int LifeBarSeq { get; set; } = 0;

        // Score & State
        public int Kills { get; set; } = 0;
        public int Deaths { get; set; } = 0;
        public int Score { get; set; } = 0;
        public int DuckState { get; set; } = 3; // 3 = stand, 2 = ducking, 0 = crouch
        public int DuckTime { get; set; } = 0;
        public bool OnGround { get; set; } = true;
        public int GroundEntityNum { get; set; } = -1;
        public bool Moving { get; set; } = false;
        public float Velocity2D { get; set; } = 0f;
        public float VelX { get; set; } = 0f;
        public float VelY { get; set; } = 0f;
        public float VelZ { get; set; } = 0f;
        public float Stamina { get; set; } = 100f;
        public int LegsAnim { get; set; } = 7;
        public int TorsoAnim { get; set; } = 13;
        public int ViewAnim { get; set; } = 13;
        public float ViewAnimSpeed { get; set; } = 1.0f;
        public int LeftViewAnim { get; set; } = 13;
        public float LeftViewAnimSpeed { get; set; } = 1.0f;
        public int Fov { get; set; } = 90;
        public float WeaponAccuracy { get; set; } = 0.2f;
        public int ShotsFired { get; set; } = 0;
        public int DecreaseShotsFired { get; set; } = 0;
        public float NextAttackTimer { get; set; } = 0f;
        public float NextSecondaryAttackTimer { get; set; } = 0f;
        public bool DelayFire { get; set; } = false;
        public int CmdSequence { get; set; } = 0;
        public int ClientTime { get; set; } = 0;
        public int InvincibleTime { get; set; } = 0;

        // Transform & Orientation
        public float PosX { get; set; } = 0f;
        public float PosY { get; set; } = 0f;
        public float PosZ { get; set; } = 0f;
        public float ViewYaw { get; set; } = 0f;
        public float ViewPitch { get; set; } = 0f;
        public float MoveYaw { get; set; } = 0f;
        public float MovePitch { get; set; } = 0f;
        public float MoveRoll { get; set; } = 0f;
        public float ViewHeight { get; set; } = 150f;

        // Weapon, Skin, Skill & Animation
        public int CurrentBagId { get; set; } = 1;
        public int CurrentWeapon { get; set; } = 1;      // slot: 1=primary, 2=secondary, 3=melee, 4=throwable, 5=c4
        public string CurrentWeaponName { get; set; } = "m4a1";
        public string CurrentWeaponSkinName { get; set; } = "";
        public int CurrentWeaponIndex { get; set; } = 1;
        public int CurrentClip { get; set; } = 30;
        public int CurrentCarryClip { get; set; } = 120;
        public int MaxClip { get; set; } = 30;
        public int WeaponEffectLevel { get; set; } = 0;
        public int WeaponPower { get; set; } = 0;
        public int WeaponMaxPower { get; set; } = 100;
        public int WeaponPower2 { get; set; } = 0;
        public int WeaponMaxPower2 { get; set; } = 100;
        public bool SpecialMode { get; set; } = false;
        public long NextSkillTimer { get; set; } = 0;
        public long ReloadEndTime { get; set; } = 0;
        public float LegsSpeedAnimTime { get; set; } = 0f;
        public float TorsoAnimStartTime { get; set; } = 0f;
        public float TorsoAnimationTimer { get; set; } = 0f;
        public float FireAnimEndTime { get; set; } = 0f;
        public float ReloadAnimEndTime { get; set; } = 0f;
        public float DeadTimer { get; set; } = 0f;
        public float Alpha { get; set; } = 1.0f;
        public float SelfAlpha { get; set; } = 1.0f;
        // 客户端 HeadScalePlaybackSystem 公式: 1f + HeadEnlarge + OtherHeadEnlarge，默认必须为 0f 才是正常 1.0x 头身比例
        public float HeadEnlarge { get; set; } = 0f;
        public float OtherHeadEnlarge { get; set; } = 0f;
        public int ControlEntityId { get; set; } = 0;
        public List<int> AccessoryList { get; set; } = new List<int>();
    }

    /// <summary>
    /// 喷漆事件（DATA-CONTRACT.md 第三节）
    /// </summary>
    public class SprayEventData
    {
        public int EntityId { get; set; }
        public int ResTypeID { get; set; } // 对应 393 个喷漆 ID
        public float PosX { get; set; }
        public float PosY { get; set; }
        public float PosZ { get; set; }
        public float NormalX { get; set; }
        public float NormalY { get; set; }
        public float NormalZ { get; set; }
        public float Yaw { get; set; }
    }

    /// <summary>
    /// 手雷爆炸事件（DATA-CONTRACT.md 第三节样板）
    /// </summary>
    public class GrenadeExplosionEventData
    {
        public int ThrowerId { get; set; }
        public int WeaponTid { get; set; } = 10; // 手雷
        public float PosX { get; set; }
        public float PosY { get; set; }
        public float PosZ { get; set; }
    }

    /// <summary>
    /// 受击命中事件（打击感核心）
    /// </summary>
    public class HitEventData
    {
        public int AttackerId { get; set; }
        public int VictimId { get; set; }
        public int Damage { get; set; }
        public int HitPart { get; set; } // 1=Head, 2=Chest, 3=Stomach, 4=Arm, 5=Leg
        public bool IsHeadshot => HitPart == 1;
        public string WeaponName { get; set; }
        public float AttackerX { get; set; }
        public float AttackerY { get; set; }
        public float AttackerZ { get; set; }
    }

    /// <summary>
    /// 击杀播报事件 (对标 Quake 3: EV_OBITUARY)
    /// </summary>
    public class KillNoticeEventData
    {
        public int KillerId { get; set; }
        public int VictimId { get; set; }
        public string WeaponName { get; set; } = "m4a1";
        public bool IsHeadshot { get; set; } = false;
        public int MultiKillCount { get; set; } = 1;
    }

    /// <summary>
    /// 开火广播事件 (枪口火花与枪声回放)
    /// </summary>
    public class WeaponFireEventData
    {
        public int ShooterId { get; set; }
        public string WeaponName { get; set; } = "m4a1";
        public float MuzzleX { get; set; }
        public float MuzzleY { get; set; }
        public float MuzzleZ { get; set; }
        public float DirYaw { get; set; }
        public float DirPitch { get; set; }
    }

    /// <summary>
    /// 投掷物实体 (对标 Quake 3: code/game/g_missile.c)
    /// </summary>
    public class MissileEntity
    {
        public int Id { get; set; }
        public int ThrowerId { get; set; }
        public int WeaponTid { get; set; } = 10;
        public float PosX { get; set; }
        public float PosY { get; set; }
        public float PosZ { get; set; }
        public float VelX { get; set; }
        public float VelY { get; set; }
        public float VelZ { get; set; }
        public float FuseTimer { get; set; } = 3.0f; // 3 秒引信
        public bool Exploded { get; set; } = false;
    }

    /// <summary>
    /// 权威武器属性字典
    /// </summary>
    public class WeaponDef
    {
        public string Name { get; set; } = "m4a1";
        public int BaseDamage { get; set; } = 30;
        public float FireInterval { get; set; } = 0.09f; // 约 660 RPM
        public float Spread { get; set; } = 0.015f;
        public int MaxClip { get; set; } = 35;
        public float ReloadTime { get; set; } = 2.2f;
    }
}
