# RPC 分级报告（M2）

> 本文件由 `_work/lobby_host/tools/classify_rpc.py` 生成，勿手改。
> 输入：`rpc_table.txt` / `LobbyLoginServer.java` / `rpc-callsite-catalog.json`

## 1. 总量

| 分级 | 含义 | 条数 |
|---|---|---|
| **A** | 真实处理（手写分支，返回真数据） | **40** |
| **B** | 零值桩：客户端**在问**，服务端答空 | **868** |
| **C** | 从未发送（AS3 无调用点，死条目） | **41** |
| — | 合计（表内） | 949 |
| — | 手写但不在表内 | 17 |

**关键结论**：真正需要补的只有 **B 类**。C 类是噪音，不必实现；
A 类已通；把精力花在 C 上属于典型的「看起来很忙但用户看不到变化」。

## 2. B 类清单（按客户端调用点降序）

这些 RPC 客户端确实会发，但只会收到 `rpc_table.txt` 里预生成的零值帧
（空列表 / 字段全零的 bean）。UI 表现就是：面板能打开，但内容为空、
显示 `not has id`、或一直转圈。

| # | 请求 | 回调 | 参数 | 空桩返还 | 调用点 | 首个调用位置 |
|---|---|---|---|---|---|---|
| 1 | `startGame` | `callBackStartGame` | 7 | - | 6 | `globalRoom/net/GRoomLogic.as:306` |
| 2 | `changeDesperateFightFlag` | `callbackChangeDesperateFightFlag` | 1 | - | 3 | `lobby/model/rpg/net/RpgServerLogic.as:123` |
| 3 | `addBlack` | `onAddBlack` | 1 | CommonCharInfo | 2 | `lobbyNet/logic/ServersLogic.as:1402` |
| 4 | `changeGameToObserver` | `callBackChangeGameToObserver` | 2 | - | 2 | `globalRoom/net/GRoomLogic.as:220` |
| 5 | `changeTeam` | `callBackChangeTeam` | 3 | - | 2 | `globalRoom/net/GRoomLogic.as:243` |
| 6 | `createChannelTeamWithDifficultyId` | `callbackCreateChannelTeam` | 2 | ChannelTeam | 2 | `acg/lobbyNet/channelLogic/AcgChannelLogic.as:16` |
| 7 | `createRoom` | `callbackCreateRpgRoom` | 2 | - | 2 | `globalRoom/net/GRoomLogic.as:299` |
| 8 | `createScuffleChannelTeam` | `callbackCreateChannelTeam` | 2 | ChannelTeam | 2 | `lobbyNet/channelLogic/ChallengeLogic.as:23` |
| 9 | `getMessagesByWindowId` | `callbackGetMessagesByWindowId` | 1 | - | 2 | `lobby/model/chat/logic/Rpg2ChatBaseChannelLogic.as:55` |
| 10 | `getUserGameData` | `callbackGetUserGameData` | 2 | - | 2 | `acg/lobbyNet/logic/AcgServersLogic.as:236` |
| 11 | `joinRoom` | `callBackJoinRoom` | 3 | RoomInfoEx | 2 | `globalRoom/net/GRoomLogic.as:134` |
| 12 | `leaveRoom` | `callBackLeaveRoom` | 0 | - | 2 | `globalRoom/net/GRoomLogic.as:277` |
| 13 | `notUsePlotWeapon` | `callbackNotUsePlotWeapon` | 1 | - | 2 | `lobby/model/rpg/net/RpgServerLogic.as:273` |
| 14 | `reconnectGame` | `callbackReconnectGameFail` | 0 | - | 2 | `lobby/model/rpg/net/RpgServerLogic.as:73` |
| 15 | `startRpgMatch` | `callBackStartRpgGame` | 5 | - | 2 | `lobby/model/rpg/net/RpgServerLogic.as:375` |
| 16 | `supplyPalSoldier` | `callbackSupplyPalSoldier` | 2 | PalTroop | 2 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:366` |
| 17 | `syncBattleBioEquip` | `callbackSyncBattleBioEquip` | 1 | - | 2 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:70` |
| 18 | `updateRoom` | `callbackUpdateRpgRoom` | 1 | ClientRpgRoomInfo | 2 | `globalRoom/net/GRoomLogic.as:272` |
| 19 | `abandonScratchOff` | `callbackAbandonScratchOff` | 2 | ClientScratchOffUserBean | 1 | `lobbyNet/logic/ServersLogic.as:13934` |
| 20 | `acgBagTakeOff` | `callbackAcgBagTakeOff` | 0 | - | 1 | `acg/lobbyNet/logic/AcgServersLogic.as:186` |
| 21 | `acgBagTakeOn` | `callbackAcgBagTakeOn` | 0 | - | 1 | `acg/lobbyNet/logic/AcgServersLogic.as:176` |
| 22 | `acquireBountyArenaReward` | `callbackAcquireBountyArenaReward` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:12218` |
| 23 | `acquireCatalogReward` | `callbackAcquireCatalogReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:11171` |
| 24 | `acquireDecodePack` | `callbackAcquireDecodePack` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9784` |
| 25 | `acquireExpeditionReward` | `callbackAcquireExpeditionReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13035` |
| 26 | `acquireJumpReward` | `callbackJumpRewardPack` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4142` |
| 27 | `acquirePalResource` | `callbackAcquirePalResource` | 2 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:232` |
| 28 | `acquirePeakLikeReward` | `callbackAcquirePeakLikeReward` | 4 | - | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:116` |
| 29 | `acquireRaceSeasonReward` | `callbackRaceSeasonReward` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:7065` |
| 30 | `acquireRepelPack` | `callbackAcquireRepelPack` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:7862` |
| 31 | `acquireReputationReward` | `callbackAcquireReputationReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:11939` |
| 32 | `acquireRpgTeamDonatePack` | `callbackRpgTeamDonatePack` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:7415` |
| 33 | `acquireScratchOffCellReward` | `callbackAcquireScratchOffCellReward` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:13911` |
| 34 | `acquireSeasonPassReward` | `callbackAcquireSeasonPassReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5311` |
| 35 | `acquireTimeSafeBoxPack` | `callbackAcquireTimeSafeBoxPack` | 4 | ClientTimeSafeBoxOrderBean | 1 | `lobbyNet/logic/ServersLogic.as:12274` |
| 36 | `acquireWarLetterReward` | `callbackAcquireWarLetterReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13230` |
| 37 | `acquireWishTeamPack` | `callbackAcquireWishTeamPack` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:14058` |
| 38 | `activateDecennialWrap` | `callbackActivateDecennialWrap` | 3 | DecennialUserBean | 1 | `lobbyNet/logic/ServersLogic.as:13002` |
| 39 | `activeFavorite` | `callbackActiveFavorite` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11186` |
| 40 | `activeRpgGodWay` | `callbackActiveRpgGodWay` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5599` |
| 41 | `activeRpgLevelTelnet` | `callbackActiveRpgLevelTelnet` | 2 | RpgLevelTelnetNodeBean | 1 | `lobbyNet/logic/ServersLogic.as:13600` |
| 42 | `activeWarLetter` | `callbackActiveWarLetter` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13213` |
| 43 | `addClickPosition` | `callbackAddClientPosition` | 0 | - | 1 | `lobbyNet/logic/ServersLogic.as:7726` |
| 44 | `addEnvoyToLingFu` | `callbackAddEnvoyToLingFu` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13830` |
| 45 | `addRpgWeaponBattleExpByItem` | `callbackAddRpgWeaponBattleExpByItem` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5461` |
| 46 | `allowJoinRpgTeam` | `callbackAllowJoinRpgTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6159` |
| 47 | `allowJoinTeam` | `onAllowJoinTeam` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:2748` |
| 48 | `applyChatWindowId` | `callbackApplyChatWindowId` | 3 | Endpoint | 1 | `lobbyNet/logic/ServersLogic.as:7351` |
| 49 | `applyDyeingFormula` | `callbackApplyDyeingFormula` | 0 | - | 1 | `lobbyNet/logic/ServersLogic.as:14170` |
| 50 | `applyJoinRpgTeam` | `callbackApplyJoinRpgTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6109` |
| 51 | `applyJoinTeam` | `onApplyJoinTeam` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:2685` |
| 52 | `applyMonitor` | `callbackApplyMonitor` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:11456` |
| 53 | `applyPalJobFlag` | `callbackApplyPalJobFlag` | 2 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:251` |
| 54 | `assistantSwitchAbility` | `callbackAssistantSwitchAbility` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9111` |
| 55 | `assistantSwitchAllAbilities` | `callbackAssistantSwitchAllAbilities` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9130` |
| 56 | `automaticEquip` | `callbackAutomaticEquip` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9324` |
| 57 | `automaticEquipSave` | `callbackAutomaticEquipSave` | 2 | ClientHallEquipConfigBean | 1 | `lobbyNet/logic/ServersLogic.as:9299` |
| 58 | `automaticSelectDefault` | `callbackAutomaticSelectDefault` | 2 | ClientHallEquipConfigBean, ClientHallEquipConfigBean | 1 | `lobbyNet/logic/ServersLogic.as:9313` |
| 59 | `avatarChanged` | `callBackAvatarChanged` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:2240` |
| 60 | `avatarTalentAwake` | `callBackAvatarTalentAwake` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9220` |
| 61 | `avatarUnlockSuit` | `callbackAvatarUnlockSuit` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:9464` |
| 62 | `banPeakWeaponGroup` | `callbackBanPeakWeaponGroup` | 3 | - | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:41` |
| 63 | `banPushRecommandFriend` | `onPushRecommandFriend` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4383` |
| 64 | `bargainRealmExchangeItem` | `callbackBargainRealmExchangeItem` | 4 | ClientRealmExchangeBean | 1 | `lobbyNet/logic/ServersLogic.as:13445` |
| 65 | `batchActiveFavorite` | `callbackBatchActiveFavorite` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11212` |
| 66 | `batchCompleteRpgTask` | `callbackBatchCompleteRpgTask` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12800` |
| 67 | `batchDecompositeRing` | `callbackBatchDecompositeRing` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13682` |
| 68 | `batchGetAvatarWornRank` | `callbackBatchGetAvatarWornRank` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8382` |
| 69 | `batchInviteJoinRaceRoom` | `onBatchInviteJoinRaceRoom` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4291` |
| 70 | `batchInviteJoinRoom` | `onBatchInviteJoinRoom` | 3 | - | 1 | `lobbyNet/logic/LobbyLogic.as:488` |
| 71 | `batchLockRing` | `callbackBatchLockRing` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13692` |
| 72 | `batchReceiveTask` | `callBackBatchReceiveTask` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5162` |
| 73 | `bindApplet` | `callbackBindApplet` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:11650` |
| 74 | `bindAvatarEquipment` | `callbackBindAvatarEquipment` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9375` |
| 75 | `bindPhoneNumber` | `callbackBindPhoneNumber` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:3435` |
| 76 | `buy` | `callBackBuy` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:2174` |
| 77 | `buyChip` | `onBuyChip` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5032` |
| 78 | `buyMore` | `callBackBuyMore` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:2213` |
| 79 | `buyMysteryShop` | `callbackBuyMysteryShop` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:10246` |
| 80 | `buyRealmExchangeItem` | `callbackBuyRealmExchangeItem` | 3 | ClientRealmExchangeBean | 1 | `lobbyNet/logic/ServersLogic.as:13455` |
| 81 | `buyRpgShop` | `onBuyRpgShop` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:4928` |
| 82 | `buyTeamLeagueReviveCoin` | `callbackBuyTeamLeagueReviveCoin` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:9764` |
| 83 | `buyWithDiscount` | `onBuyWithEcard` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:2179` |
| 84 | `buyWithEcard` | `onBuyWithEcard` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:2196` |
| 85 | `calibrateSlaveProperty` | `callbackCalibrateSlaveProperty` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9596` |
| 86 | `calibrateWeaponPrecision` | `callbackCalibrateWeaponPrecision` | 3 | ClientWeaponCalibrationBean | 1 | `lobbyNet/logic/ServersLogic.as:13325` |
| 87 | `cancelBountyTask` | `callBackCancelBountyTask` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5208` |
| 88 | `cancelBuyLegionGoods` | `callbackCancelBuyLegionGoods` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:10610` |
| 89 | `cancelResetSecPsw` | `callbackCancelResetSecPsw` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6922` |
| 90 | `capturePalSLG` | `callbackCapturePalSLG` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12912` |
| 91 | `changeAvatarModel` | `callbackChangeAvatarModel` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6364` |
| 92 | `changeChannelCamp` | `callbackChangeChannelCamp` | 2 | - | 1 | `lobbyNet/channelLogic/BaseChannelLogic.as:109` |
| 93 | `changeDangerFactor` | `callbackChangeDangerFactor` | 3 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:430` |
| 94 | `changeExercisesChannelTeamNeedFill` | `callbackChangeExercisesChannelTeamNeedFill` | 1 | - | 1 | `lobbyNet/channelLogic/LimitExerciseLogic.as:49` |
| 95 | `changeFestivalChannelTeam` | `callbackChangeFestivalChannelTeam` | 3 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:48` |
| 96 | `changeFestivalDangerFactor` | `callbackChangeFestivalDangerFactor` | 4 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:33` |
| 97 | `changeMultipleRpgTeam` | `callbackChangeRpgTeam` | 3 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:157` |
| 98 | `changeOneOnOneCard` | `callbackChangeOneOnOneCard` | 2 | - | 1 | `lobbyNet/channelLogic/RpgFightChannelLogic.as:45` |
| 99 | `changeOpenAvatarReplace` | `callbackChangeOpenAvatarReplace` | 2 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:38` |
| 100 | `changeP3Hero` | `callbackChangeP3Hero` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:10912` |
| 101 | `changePhoneCheckSecPsw` | `callbackChangePhoneCheckSecPsw` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3482` |
| 102 | `changePinnacleInfinityLevel` | `callbackChangePinnacleInfinityLevel` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12184` |
| 103 | `changePosition` | `onChangePosition` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3101` |
| 104 | `changePrepareStatus` | `callbackChannelUserChangePrepareStatus` | 2 | - | 1 | `lobbyNet/channelLogic/TeamChannelLogic.as:71` |
| 105 | `changePresetTemplate` | `callbackChangePresetTemplate` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:14085` |
| 106 | `changeReadFlag` | `onChangeReadFlag` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2621` |
| 107 | `changeRpgCamp` | `callbackChangeRpgCamp` | 2 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:219` |
| 108 | `changeRpgPosition` | `onChangeRpgPosition` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3073` |
| 109 | `changeRpgTeam` | `callbackChangeRpgTeam` | 3 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:152` |
| 110 | `changeRpgTeamDeclaration` | `callbackChangeRpgTeamDeclaration` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6139` |
| 111 | `changeRpgTeamNotice` | `callbackChangeRpgTeamNotice` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6149` |
| 112 | `changeRuneBagName` | `callbackChangeRuneBagName` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:11235` |
| 113 | `changeScuffleEquipConfig` | `callbackChangeScuffleEquipConfig` | 1 | ScuffleEquipConfigBean | 1 | `lobbyNet/logic/ServersLogic.as:6069` |
| 114 | `changeSecPsw` | `callbackChangePhoneCheckSecPsw` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6847` |
| 115 | `changeStorageStoreMark` | `callbackChangeStorageStoreMark` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:2017` |
| 116 | `changeTeamDeclaration` | `onChangeTeamDeclaration` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2964` |
| 117 | `changeTeamName` | `onChangeTeamName` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2900` |
| 118 | `changeTeamNotice` | `onChangeTeamNotice` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2985` |
| 119 | `changeTeamPassword` | `callbackChangeTeamPassword` | 1 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:253` |
| 120 | `changeTeamleader` | `onChangeTeamleader` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3027` |
| 121 | `changeTeamleaderResult` | `onChangeTeamleader` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3067` |
| 122 | `changeTrialTowerSelected` | `callbackTrialTowerChangeSelected` | 2 | TrialTowerUserBean | 1 | `lobbyNet/logic/ServersLogic.as:14273` |
| 123 | `changeUserSetting` | `onChangeUserSetting` | 1 | UserSettingBean | 1 | `lobbyNet/logic/ServersLogic.as:4520` |
| 124 | `changeUserStayStep` | `onChangeUserSetting` | 1 | UserSettingBean | 1 | `lobbyNet/logic/ServersLogic.as:2673` |
| 125 | `changeWeaponModel` | `callbackChangeWeaponModel` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6549` |
| 126 | `changeZoomAbility` | `callbackChangeZoomAbility` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:7983` |
| 127 | `changeZoomChannelTeam` | `callbackChangeZoomChannelTeam` | 4 | - | 1 | `lobbyNet/channelLogic/RpgZoomChannelLogic.as:21` |
| 128 | `changeZoomDanger` | `callbackChangeZoomDanger` | 1 | - | 1 | `lobbyNet/channelLogic/RpgZoomChannelLogic.as:48` |
| 129 | `checkActivityDisplayConditions` | `callbackCheckActivityDisplayConditions` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12790` |
| 130 | `checkActivityLogicConditions` | `callbackCheckActivityLogicConditions` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12169` |
| 131 | `checkTeamLeagueMember` | `callbackCheckTeamLeagueMember` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9734` |
| 132 | `checkTeamName` | `onCheckTeamName` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1061` |
| 133 | `choiceOptionalPackItem` | `callbackChoiceOptionalPackItem` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:4809` |
| 134 | `choiceRaceTypeAndLevel` | `callbackChoiceRaceTypeAndLevel` | 2 | ChannelTeam | 1 | `lobbyNet/channelLogic/StormMatchChannelLogic.as:37` |
| 135 | `claimAccomplishmentReward` | `onClaimAccomplishmentReward` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:10003` |
| 136 | `claimCycleTaskActiveReward` | `callbackClaimCycleTaskActiveReward` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:5003` |
| 137 | `claimFestivalSpanReward` | `callbackClaimFestivalSpanReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:10374` |
| 138 | `claimGlobalAchvMedalReward` | `callbackClaimGlobalAchvMedalReward` | 3 | GlobalAchvBean | 1 | `lobbyNet/logic/ServersLogic.as:10348` |
| 139 | `claimIntelligenceItems` | `callbackClaimIntelligenceItems` | 2 | IntelligenceClaimBean | 1 | `lobbyNet/logic/ServersLogic.as:9794` |
| 140 | `claimNewbieTaskReward` | `callbackClaimNewbieTaskReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12086` |
| 141 | `claimZoomReward` | `callbackClaimZoomReward` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:7963` |
| 142 | `clearRpgArenaData` | `callbackClearRpgArenaData` | 1 | ClientRpgArenaResult | 1 | `lobbyNet/logic/ServersLogic.as:9656` |
| 143 | `clearRpgInfinity` | `callbackResetRpgInfinity` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5644` |
| 144 | `clickCreateTeamButton` | `onClickCreateTeamButton` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:3320` |
| 145 | `closeDecoration` | `onCloseDecoration` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1588` |
| 146 | `collectDyeingWork` | `callbackCollectDyeingWork` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:14180` |
| 147 | `completeDelayRaid` | `callbackCompleteDelayRaid` | 10 | - | 1 | `lobbyNet/logic/ServersLogic.as:10867` |
| 148 | `completeSeasonPassTask` | `callbackCompleteRpgTask` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5306` |
| 149 | `completeTask` | `callbackCompleteRpgTask` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5110` |
| 150 | `composeAvatarEquipment` | `callbackComposeAvatarEquipment` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:9495` |
| 151 | `composeEnvoySoul` | `callbackComposeEnvoySoul` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13744` |
| 152 | `confirmRefineResult` | `callbackConfirmRefineResult` | 2 | RingPropertyBean | 1 | `lobbyNet/logic/ServersLogic.as:13672` |
| 153 | `costGold2StartSixthBattle` | `callbackCostGold2StartSixthBattle` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7902` |
| 154 | `createBattleMessage` | `callBackAddBattleMessage` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1229` |
| 155 | `createBiochemicalChannelTeam` | `callbackCreateChannelTeam` | 2 | ChannelTeam | 1 | `lobbyNet/channelLogic/BiochemistryChannelLogic.as:19` |
| 156 | `createChannelTeam` | `callbackCreateChannelTeam` | 2 | ChannelTeam | 1 | `lobbyNet/channelLogic/TeamChannelLogic.as:18` |
| 157 | `createCharacter` | `callBackCreateCharacter` | 2 | UserInfo | 1 | `lobbyNet/logic/ServersLogic.as:1072` |
| 158 | `createExercisesChannelTeam` | `callbackGetExercisesChannelTeamList` | 3 | - | 1 | `lobbyNet/channelLogic/LimitExerciseLogic.as:19` |
| 159 | `createFestivalChannelTeam` | `callbackChangeFestivalChannelTeam` | 3 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:43` |
| 160 | `createMultipleRpgTeam` | `callbackCreateRpgTeam` | 2 | RpgTeamInfo | 1 | `lobby/model/rpg/net/RpgServerLogic.as:88` |
| 161 | `createOrJoinChannelTeam` | `callbackCreateOrJoinChannelTeam` | 2 | TeamLeagueChannelTeam | 1 | `lobbyNet/channelLogic/RpgTeamMatchChannelLogic.as:29` |
| 162 | `createRaceRoom` | `callbackCreateRaceRoom` | 2 | ClientRaceRoom | 1 | `lobbyNet/logic/ServersLogic.as:4226` |
| 163 | `createRestrictionRoom` | `callbackJoinRestrictionRoom` | 1 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:140` |
| 164 | `createRpgRestrictionRoom` | `callbackCreateRpgRoom` | 2 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:394` |
| 165 | `createRpgRoom` | `callbackCreateRpgRoom` | 2 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:385` |
| 166 | `createRpgTeam` | `callbackCreateRpgTeam` | 2 | RpgTeamInfo | 1 | `lobby/model/rpg/net/RpgServerLogic.as:83` |
| 167 | `createTeam` | `onCreateTeam` | 2 | ClientTeamBean | 1 | `lobbyNet/logic/ServersLogic.as:3172` |
| 168 | `createZoomChannelTeam` | `callbackChangeZoomChannelTeam` | 4 | - | 1 | `lobbyNet/channelLogic/RpgZoomChannelLogic.as:16` |
| 169 | `decodeIntelligenceItems` | `callbackDecodeIntelligenceItems` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9774` |
| 170 | `decomposeEnvoySoul` | `callbackDecomposeEnvoySoul` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13772` |
| 171 | `decomposeRunes` | `callbackDecomposeRunes` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:10958` |
| 172 | `defenseLineCostType` | `callbackDefenseLineCostType` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7882` |
| 173 | `deleteAllExpiredStorageItem` | `onDeleteStorage` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1971` |
| 174 | `deleteBlack` | `onDeleteBlack` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1545` |
| 175 | `deleteDivineMark` | `callbackDeleteDivineMark` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:13153` |
| 176 | `deleteExpiredStorageItem` | `onDeleteStorage` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1966` |
| 177 | `deleteFriend` | `onDeleteFriend` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1387` |
| 178 | `deleteMail` | `onDeleteMail` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:2559` |
| 179 | `deleteStorage` | `onDeleteStorage` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10207` |
| 180 | `delistHomelandHallRentItem` | `callbackDelistHomelandHallRentItem` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13543` |
| 181 | `depositTimeSafeBox` | `callbackDepositTimeSafeBox` | 3 | ClientTimeSafeBoxOrderBean | 1 | `lobbyNet/logic/ServersLogic.as:12257` |
| 182 | `disbandPalManpower` | `callbackDisbandPalManpower` | 2 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:237` |
| 183 | `disbandTeam` | `onDisbandTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2874` |
| 184 | `doRebirth` | `callbackDoRebirth` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13610` |
| 185 | `donateIntelligenceItems` | `callbackDonateIntelligenceItems` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9804` |
| 186 | `doubleBattleExpAndGp` | `onDoubleBattleExpAndGp` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:4129` |
| 187 | `douwaBuyVipStatus` | `douwaOnBuyVip` | 3 | ClientCharacterVipBean | 1 | `lobbyNet/logic/ServersLogic.as:4037` |
| 188 | `douwaGetVipStatus` | `douwaOnGetVipStatus` | 1 | ClientCharacterVipBean | 1 | `lobbyNet/logic/ServersLogic.as:4026` |
| 189 | `douwaUseVipPoint` | `douwaOnUsePoint` | 3 | ClientCharacterVipBean | 1 | `lobbyNet/logic/ServersLogic.as:4053` |
| 190 | `dragoonEquip` | `callbackDragoonEquip` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8725` |
| 191 | `dragoonEquipChip` | `callbackDragoonEquipChip` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:8794` |
| 192 | `dragoonGetEquipInfo` | `callbackDragoonGetEquipInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8698` |
| 193 | `dragoonIntoBattle` | `callbackDragoonIntoBattle` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:8759` |
| 194 | `dragoonResolve` | `callbackDragoonResolve` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:8828` |
| 195 | `dragoonSynthesis` | `callbackDragoonSynthesis` | 2 | DragoonBean | 1 | `lobbyNet/logic/ServersLogic.as:8776` |
| 196 | `dragoonTakeoff` | `callbackDragoonTakeoff` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:8742` |
| 197 | `dragoonTakeoffChip` | `callbackDragoonTakeoffChip` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8811` |
| 198 | `dragoonUnlockBag` | `callbackDragoonUnlockBag` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:8708` |
| 199 | `dropStarProjectBox` | `callBackUpdateStarProjectBox` | 1 | StarProjectUserDataBean | 1 | `lobbyNet/logic/ServersLogic.as:10750` |
| 200 | `elevateRuneStorageLimit` | `callbackElevateRuneStorageLimit` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11137` |
| 201 | `enterChannelServer` | `callbackEnterChannelServer` | 4 | ChannelUser | 1 | `lobbyNet/channelLogic/BaseChannelLogic.as:28` |
| 202 | `enterChatServer` | `callbackEnterChatServer` | 1 | - | 1 | `lobby/model/chat/logic/Rpg2ChatBaseChannelLogic.as:20` |
| 203 | `enterHomeland` | `callbackEnterHomeland` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12805` |
| 204 | `enterPalRoom` | `callbackEnterPalRoom` | 7 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:311` |
| 205 | `enterPeakCompetitionGroup` | `callbackEnterPeakCompetitionGroup` | 2 | - | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:21` |
| 206 | `enterQuiz` | `onEnterQuiz` | 6 | - | 1 | `lobbyNet/logic/ServersLogic.as:4769` |
| 207 | `enterRace` | `callbackEnterRace` | 9 | - | 1 | `lobbyNet/logic/ServersLogic.as:1791` |
| 208 | `enterRpgServer` | `callbackEnterRpgServerSuccess` | 1 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:63` |
| 209 | `equipAvatarEquipment` | `callbackEquipAvatarEquipment` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9405` |
| 210 | `equipBattlePet` | `onEquipBattlePet` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1599` |
| 211 | `equipChip` | `onEquipChip` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5052` |
| 212 | `equipDecoration` | `onEquipDecoration` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1555` |
| 213 | `equipDivineMark` | `callbackEquipDivineMark` | 2 | ClientDivineMarkBean | 1 | `lobbyNet/logic/ServersLogic.as:13127` |
| 214 | `equipEmoji` | `callbackEquipEmoji` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:11279` |
| 215 | `equipEnvoySkin` | `callbackEquipEnvoySkin` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:8998` |
| 216 | `equipGroupRootAvatar` | `callBackEquipRootAvatar` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:10922` |
| 217 | `equipHeroAvatar` | `callbackEquipHeroAvatar` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10899` |
| 218 | `equipModuleItem` | `callbackEquipModuleItem` | 1 | RpgModuleSysBean | 1 | `lobbyNet/logic/ServersLogic.as:6519` |
| 219 | `equipParentAvatar` | `callBackEquipParentAvatar` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:10159` |
| 220 | `equipPropertyWing` | `callbackEquipPropertyWing` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8978` |
| 221 | `equipRootAvatarSound` | `callBackEquipRootAvatarSound` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:8942` |
| 222 | `equipRpgXpSkill` | `callbackEquipRpgXpSkill` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5416` |
| 223 | `equipRune` | `callbackEquipRune` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:11007` |
| 224 | `equipUltimateAvatar` | `callbackEquipUltimateAvatar` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10029` |
| 225 | `equipUltimateAvatarConfig` | `callbackEquipUltimateAvatarConfig` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10072` |
| 226 | `equipWeaponSlot` | `callBackEquipWeaponSlot` | 4 | WeaponSlotBean, WeaponSlotReformBean | 1 | `lobbyNet/logic/ServersLogic.as:2393` |
| 227 | `etherApplyEthereumActivity` | `callbackEtherApplyEthereumActivity` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9974` |
| 228 | `etherCancelBuyOrder` | `callbackEtherCancelBuyOrder` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:8062` |
| 229 | `etherCancelSellOrder` | `callbackEtherCancelSellOrder` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:8185` |
| 230 | `etherFetchEthereumActivity` | `callbackEtherFetchEthereumActivity` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9960` |
| 231 | `etherFetchTransactionItem` | `callbackEtherFetchTransactionItem` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:8414` |
| 232 | `etherGetEthereumActivityInfo` | `callbackEtherGetEthereumActivityInfo` | 2 | BillionEthereumActivityBean | 1 | `lobbyNet/logic/ServersLogic.as:9932` |
| 233 | `etherGetMarketOverviewInfo` | `callbackEtherGetMarketOverviewInfo` | 2 | EtherUserMarketOverviewInfo | 1 | `lobbyNet/logic/ServersLogic.as:8660` |
| 234 | `etherGetMarketPriceHistory` | `callbackEtherGetMarketPriceHistory` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:8596` |
| 235 | `etherGetMarketSellOrderByShelf` | `callbackEtherGetMarketSellOrderByShelfV2` | 7 | - | 1 | `lobbyNet/logic/ServersLogic.as:8320` |
| 236 | `etherGetUserBuyOrderInfo` | `callbackEtherGetUserBuyOrderInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:8270` |
| 237 | `etherGetUserSellOrderInfo` | `callbackEtherGetUserSellOrderInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:8290` |
| 238 | `etherGetUserTransactionRecordInfo` | `callbackEtherGetUserTransactionRecordInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:8310` |
| 239 | `etherOpenEthereumActivityHistoryHongBao` | `callbackEtherOpenEthereumActivityHistoryHongBao` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9942` |
| 240 | `etherShowItemDetailInfo` | `callbackEtherShowItemDetailInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:8635` |
| 241 | `etherShowMarketInfo` | `callbackEtherShowMarketInfo` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:7578` |
| 242 | `etherShowShelfPriceAndAmount` | `callbackEtherShowShelfPriceAndAmount` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:8157` |
| 243 | `etherSubmitEtherBuyOrder` | `callbackEtherSubmitBuyOrder` | 2 | EtherBuyOrder | 1 | `lobbyNet/logic/ServersLogic.as:7614` |
| 244 | `etherSubmitPriorityBuyOrder` | `callbackEtherSubmitPriorityBuyOrder` | 2 | EtherBuyOrder | 1 | `lobbyNet/logic/ServersLogic.as:7690` |
| 245 | `etherSubmitSellOrder` | `callbackEtherSubmitSellOrder` | 2 | EtherSellOrder | 1 | `lobbyNet/logic/ServersLogic.as:8008` |
| 246 | `etherUseGoldExchangeEther` | `callbackEtherUseGoldExchangeEther` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:8655` |
| 247 | `exchangePack` | `callbackExchangePack` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:2277` |
| 248 | `exchangeSilver` | `onExchangeSilver` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:4938` |
| 249 | `exchangeStorageItem` | `onExchangeStorageItem` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:6683` |
| 250 | `expediteTask` | `callbackExpediteTask` | 3 | ExpeditionTaskBean | 1 | `lobbyNet/logic/ServersLogic.as:13025` |
| 251 | `extendTeam` | `onExtendTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3133` |
| 252 | `extractWingSlotProperty` | `callbackExtractWingSlotProperty` | 2 | WingPropertyUserBean | 1 | `lobbyNet/logic/ServersLogic.as:11996` |
| 253 | `fastJoinRoom` | `callBackJoinRoom` | 3 | RoomInfoEx | 1 | `lobbyNet/logic/LobbyLogic.as:312` |
| 254 | `fcm` | `callbackFcm` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2255` |
| 255 | `fetchModuleSysOutput` | `callbackFetchModuleSysOutput` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6539` |
| 256 | `fetchRpgAdventureReward` | `callbackFetchRpgAdventureReward` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:5842` |
| 257 | `fetchStarProjectBox` | `callBackFetchStarProjectBox` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10802` |
| 258 | `fetchTemporaryStorage` | `onDeleteTemporaryStorage` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10222` |
| 259 | `fetchTerritorialTeamReward` | `callbackFetchTerritorialTeamReward` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12111` |
| 260 | `firstOpenTitanium` | `callbackFirstOpenTitanium` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7539` |
| 261 | `fix` | `onFix` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:1666` |
| 262 | `fixTerritorialContention` | `callbackFixTerritorialContention` | 1 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:207` |
| 263 | `flipRpgMixture` | `callbackUseRpgMixture` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13287` |
| 264 | `followUser` | `onFollowUser` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:3570` |
| 265 | `forbiddenPeakBag` | `callbackForbiddenPeakBag` | 3 | - | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:66` |
| 266 | `forgeEnvoySoul` | `callbackForgeEnvoySoul` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13729` |
| 267 | `forgingExchangeStorage` | `callbackForgingExchangeStorage` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:11050` |
| 268 | `furnaceUpgrade` | `callbackFurnaceUpgrade` | 5 | RpgFurnaceUserBean | 1 | `lobbyNet/logic/ServersLogic.as:7922` |
| 269 | `gameBind` | `callbackGameBindStatus` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12483` |
| 270 | `gameBindBigReward` | `callbackGameBindReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12493` |
| 271 | `gameBindDailyReward` | `callbackGameBindReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12498` |
| 272 | `gameBindInfo` | `callbackGameBindInfo` | 1 | GameBindBean | 1 | `lobbyNet/logic/ServersLogic.as:12478` |
| 273 | `getAbattoirFirstPassPlayers` | `callbackGetAbattoirFirstPassPlayers` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12729` |
| 274 | `getAbattoirUserInfo` | `callbackGetAbattoirUserInfo` | 1 | ClientAbattoirResult | 1 | `lobbyNet/logic/ServersLogic.as:12739` |
| 275 | `getAbyssTemperature` | `callbackGetAbyssTemperature` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5946` |
| 276 | `getAccomplishment` | `callbackGetAccomplishment` | 2 | AccomplishmentBean | 1 | `lobbyNet/logic/ServersLogic.as:9993` |
| 277 | `getAcgnUserInfo` | `onGetTeamUserInfo` | 1 | ClientTeamUserBean | 1 | `acg/lobbyNet/logic/AcgServersLogic.as:40` |
| 278 | `getActivityDrawTasks` | `callbackGetActivityDrawTasks` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12468` |
| 279 | `getActivityExtraData` | `callbackGetActivityExtraData` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13300` |
| 280 | `getActivityInfoNew` | `onGetActivityInfoNew` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4464` |
| 281 | `getActivityInfoNewWithType` | `callbackGetActivityInfoNewWithType` | 0 | - | 1 | `acg/lobbyNet/logic/AcgServersLogic.as:221` |
| 282 | `getActivityLevelInfo` | `callbackGetActivityLevelInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9278` |
| 283 | `getActivityNewYearInfo` | `callbackGetActivityNewYearInfo` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:7852` |
| 284 | `getAllAbyssReport` | `callbackGetAbyssReport` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5892` |
| 285 | `getAllAdventureLogs` | `callbackGetAllAdventureLogs` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:9171` |
| 286 | `getAllArenaRebirthOverview` | `callbackGetAllArenaRebirthOverview` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13620` |
| 287 | `getAllRpgExpressionValues` | `onGetAllRpgExpressionValues` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4843` |
| 288 | `getAllianceScoreLastRank` | `callbackGetAllianceScoreLastRank` | 3 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:396` |
| 289 | `getAnnounceList` | `callBackGetAnnounceList` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2350` |
| 290 | `getApplyJoinRpgTeamList` | `callbackGetApplyJoinRpgTeamList` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6099` |
| 291 | `getApplyJoinTeamList` | `onGetApplyJoinTeamList` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2738` |
| 292 | `getApplyList` | `onGetApplyList` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3017` |
| 293 | `getArrearsDebufUserBean` | `callbackGetArrearsDebufUserBean` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12982` |
| 294 | `getAssistantUserInfo` | `callbackGetAssistantUserInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9076` |
| 295 | `getAutomaticEquipInfo` | `callbackGetAutomaticEquiponInfo` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:9288` |
| 296 | `getAvailableActivityList` | `onGetAvailableActivityList` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:4421` |
| 297 | `getAvailableActivityListWithType` | `callbackGetAvailableActivityListWithType` | 0 | - | 1 | `acg/lobbyNet/logic/AcgServersLogic.as:206` |
| 298 | `getAvailableRentFriends` | `callbackGetAvailableRentFriends` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13719` |
| 299 | `getAvatarAcgRelationshipUnlockList` | `callbackGetAvatarAcgRelationshipUnlockList` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12429` |
| 300 | `getAvatarDyeing` | `callbackGetAvatarDyeing` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12330` |
| 301 | `getAvatarTalentInfo` | `callBackGetAvatarTalentInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9210` |
| 302 | `getAvatarWornRank` | `callbackGetAvatarWornRank` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:3660` |
| 303 | `getBigData` | `onGetBigData` | 1 | AnaUserDataBean | 1 | `lobbyNet/logic/ServersLogic.as:4744` |
| 304 | `getBindAppletInfo` | `callbackGetAppletInfo` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11670` |
| 305 | `getBioChemDefenseLineInfo` | `callbackGetBioChemDefenseLineInfo` | 1 | BioChemDefenseLineInfo | 1 | `lobbyNet/logic/ServersLogic.as:7872` |
| 306 | `getBlindInfo` | `callbackGetBlindInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:11607` |
| 307 | `getBlueVipPack` | `onGetBlueVipPack` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4070` |
| 308 | `getBountyHallInfo` | `callBackGetBountyHallInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5251` |
| 309 | `getBountyHunterInfo` | `callBackGetBountyHunterInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5272` |
| 310 | `getBountyTask` | `callBackGetBountyTask` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5262` |
| 311 | `getCareerTask` | `callbackGetCareerTask` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10178` |
| 312 | `getChallengeAward` | `callbackGetChallengeAward` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6974` |
| 313 | `getChallengeStatus` | `onGetChallengeStatus` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:6984` |
| 314 | `getChannelRoomList` | `callbackGetChannelRoomList` | 1 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:122` |
| 315 | `getChannelServerInfoByType` | `callbackGetChannelServerInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7221` |
| 316 | `getCharNotinTeam` | `onGetCharNotinTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2772` |
| 317 | `getCharNotinTeamByName` | `onGetCharNotinTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2777` |
| 318 | `getCharacterBoxInfo` | `callbackGetCharacterBoxInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1896` |
| 319 | `getCharacterBoxReward` | `callbackGetCharacterBoxReward` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:1886` |
| 320 | `getCheatSystemInfo` | `callbackGetCheatSystemInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:11509` |
| 321 | `getClientRpgUserInfo` | `callbackGetClientRpgUserInfo` | 1 | ClientRpgUserInfo | 1 | `lobbyNet/logic/ServersLogic.as:5691` |
| 322 | `getClientSignInBean` | `onGetClientSignInBean` | 2 | ClientSignInBean | 1 | `lobbyNet/logic/ServersLogic.as:599` |
| 323 | `getCommonAbilities` | `callbackGetCommonAbilities` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12957` |
| 324 | `getCommonCharInfo` | `callBackGetCommonCharInfo` | 1 | CommonCharInfo | 1 | `lobbyNet/logic/ServersLogic.as:3361` |
| 325 | `getCustomAvailableActivityList` | `onGetCustomAvailableActivityList` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4480` |
| 326 | `getCycleTask` | `callbackGetCycleTask` | 3 | CycleTaskBean | 1 | `lobbyNet/logic/ServersLogic.as:4993` |
| 327 | `getDailyTaskReward` | `callbackDailyTaskReward` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6395` |
| 328 | `getDangerFactor` | `callbackGetDangerFactor` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5956` |
| 329 | `getDecennialUserBean` | `callbackGetDecennialUserBean` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12992` |
| 330 | `getDefenseLineWeaponEquipInfo` | `callbackGetDefenseLineWeaponEquipInfo` | 1 | ClientDefenseLineWeaponBean | 1 | `lobbyNet/logic/ServersLogic.as:9861` |
| 331 | `getDragoonChipBeanInfo` | `callBackDragoonChipBeanInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7775` |
| 332 | `getDragoonChipBreak` | `callBackGetDragoonChipBreak` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:7755` |
| 333 | `getDragoonChipDecompose` | `callBackGetDragoonChipDecompose` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:7785` |
| 334 | `getDragoonChipRestructure` | `callBackDragoonChipRestructure` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:7765` |
| 335 | `getDyeingWorkList` | `callbackGetDyeingWorkList` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:14156` |
| 336 | `getEmojiMap` | `callbackGetEmojiMap` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:11289` |
| 337 | `getEtherHistoryChangeLog` | `callbackGetEtherHistoryChangeLog` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:7568` |
| 338 | `getEtherMarketLockStorageInfo` | `callbackGetEtherMarketLockStorageInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:8625` |
| 339 | `getExercisesBattleRecords` | `callbackGetExercisesBattleRecords` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10084` |
| 340 | `getExercisesChannelRoomList` | `callbackGetExercisesChannelTeamList` | 3 | - | 1 | `lobbyNet/channelLogic/LimitExerciseLogic.as:39` |
| 341 | `getExercisesChannelTeamList` | `callbackGetExercisesChannelTeamList` | 3 | - | 1 | `lobbyNet/channelLogic/LimitExerciseLogic.as:29` |
| 342 | `getExercisesDanReward` | `callbackGetExercisesDanReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:10095` |
| 343 | `getExistForeverWeapon` | `callBackGetExistForeverWeapon` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:3807` |
| 344 | `getExpeditionTaskBeans` | `callbackGetExpeditionTaskBeans` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:13015` |
| 345 | `getFavoriteBean` | `callbackGetFavoriteBean` | 1 | RpgFavoriteBean | 1 | `lobbyNet/logic/ServersLogic.as:11160` |
| 346 | `getFestivalDelayRaidData` | `callbackGetFestivalDelayRaidData` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10845` |
| 347 | `getFestivalInfo` | `callbackGetFestivalInfo` | 2 | RpgFestivalUserBean | 1 | `lobbyNet/logic/ServersLogic.as:10438` |
| 348 | `getFestivalPlayerCount` | `callbackGetFestivalPlayerCount` | 3 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:58` |
| 349 | `getFestivalSpell` | `callbackGetFestivalSpell` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12684` |
| 350 | `getFestivalTask` | `callbackGetFestivalTask` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10464` |
| 351 | `getFestivalVipBean` | `callbackGetFestivalVipBean` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13570` |
| 352 | `getForbiddenItemData` | `onGetForbiddenItemData` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:11692` |
| 353 | `getForeverLandPickBeans` | `callbackGetForeverLandPickBeans` | 2 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:381` |
| 354 | `getForeverLandUserBean` | `callbackGetForeverLandUserBean` | 1 | ClientForeverLandUserBean | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:222` |
| 355 | `getFriendMailList` | `callbackGetFriendMailList` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4531` |
| 356 | `getFriendReceiveCount` | `callbackGetFriendReceiveCount` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12532` |
| 357 | `getFriendShip` | `onGetFriendShip` | 1 | FriendShipUserBean | 1 | `lobbyNet/logic/ServersLogic.as:13580` |
| 358 | `getFuliSort` | `onGetFuliSort` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6600` |
| 359 | `getGameActivationRecord` | `callbackGetGameActivationRecord` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:13481` |
| 360 | `getGameBattleProperty` | `callbackGetGameBattleProperty` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12967` |
| 361 | `getGameChannelServerInfo` | `callbackGetGameChannelServerInfo` | 2 | Endpoint | 1 | `lobbyNet/logic/ServersLogic.as:7133` |
| 362 | `getGameCoolDownInfo` | `callbackGetGameCoolDownInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12865` |
| 363 | `getGameFlowRecoveryInfo` | `callbackGetGameFlowRecoveryInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12414` |
| 364 | `getGlobalAchv` | `callbackGetGlobalAchv` | 5 | GlobalAchvBean | 1 | `lobbyNet/logic/ServersLogic.as:10285` |
| 365 | `getGlobalAchvData` | `callbackGetGlobalAchvData` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10308` |
| 366 | `getHeroAvatarTasks` | `callbackGetHeroAvatarTasks` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10479` |
| 367 | `getHistoryKingScuffleBattleReport` | `callbackGetHistoryKingScuffleBattleReport` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5676` |
| 368 | `getHistoryReport` | `callbackGetHistoryReport` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:1123` |
| 369 | `getHomelandBuildData` | `callbackGetHomelandBuildData` | 1 | ClientHomelandBuildBean | 1 | `lobbyNet/logic/ServersLogic.as:12885` |
| 370 | `getHomelandHallRentData` | `callbackGetHomelandHallRentData` | 6 | - | 1 | `lobbyNet/logic/ServersLogic.as:13498` |
| 371 | `getHomelandHallRentLimit` | `callbackGetHomelandHallRentLimit` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13640` |
| 372 | `getHotRecommend` | `callbackGetHotRecommend` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6964` |
| 373 | `getIntelligenceClaimInfo` | `callbackGetIntelligenceClaimInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9814` |
| 374 | `getKingScuffleCharInfo` | `callbackGetKingScuffleCharInfo` | 3 | UserInfo, ClientRpgUserInfo | 1 | `lobbyNet/logic/ServersLogic.as:5649` |
| 375 | `getKingScuffleSeasonInfo` | `callbackGetKingScuffleSeasonInfo` | 2 | RpgKingScuffleInfo, RpgKingScuffleInfo | 1 | `lobbyNet/logic/ServersLogic.as:6045` |
| 376 | `getKingScuffleSimpleCharInfo` | `callbackGetKingScuffleSimpleCharInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:10832` |
| 377 | `getLastExchangeStorageTimestamp` | `onGetLastExchangeStorageTimestamp` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6837` |
| 378 | `getLeagueEngineReward` | `callbackGetLeagueEngineReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9841` |
| 379 | `getLegendCastingInfo` | `callbackGetLegendCastingInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6234` |
| 380 | `getLiveChatRoomInfo` | `onGetLiveChatRoomInfo` | 2 | Thrift_LiveRoomChInfo | 1 | `lobbyNet/logic/ServersLogic.as:647` |
| 381 | `getLostCityInfo` | `callbackGetLostCityInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9268` |
| 382 | `getLuckyList` | `callBackGetLuckyList` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3931` |
| 383 | `getLuckyWheelData` | `callbackGetLuckyWheelData` | 1 | LuckyWheelUserData | 1 | `lobbyNet/logic/ServersLogic.as:13163` |
| 384 | `getMagicArsenalHistoryLog` | `callbackGetMagicArsenalHistoryLog` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6304` |
| 385 | `getMailGiftById` | `onGetMailGiftById` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:857` |
| 386 | `getMailList` | `callbackGetMailList` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:2542` |
| 387 | `getMailPackById` | `callbackGetMailPackById` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:2598` |
| 388 | `getMapPathNodeOverview` | `callbackGetMapPathNodeOverview` | 2 | FestCelebration2025UserBean | 1 | `lobbyNet/logic/ServersLogic.as:10386` |
| 389 | `getMessageByFriendCid` | `onGetMessageByFriendCid` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4160` |
| 390 | `getModuleSysInfo` | `callbackGetModuleSysInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6499` |
| 391 | `getMonthTotalSignInReward` | `callbackTotalSignInReward` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:764` |
| 392 | `getMyNearbyAbyssRank` | `callbackGetMyNearbyAbyssRank` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:5977` |
| 393 | `getMyRankAndTotalCount` | `callbackGetMyRankAndTotalCount` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:5967` |
| 394 | `getMyRankDataInfo` | `callbackGetMyRankDataInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:3629` |
| 395 | `getMyRpgRiskInfo` | `callbackMyRpgRiskRank` | 1 | ClientRankRpgRiskBean | 1 | `lobbyNet/logic/ServersLogic.as:5579` |
| 396 | `getMysteryShopInfo` | `callbackGetMysteryShopInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10173` |
| 397 | `getNewSignInInfo` | `callbackNewSignInInfo` | 2 | NewClientSignInBean | 1 | `lobbyNet/logic/ServersLogic.as:688` |
| 398 | `getNewWeaponFactoryInfo` | `callBackGetNewWeaponFactoryInfo` | 2 | NewWeaponFactoryInfo | 1 | `lobbyNet/logic/ServersLogic.as:6739` |
| 399 | `getNewWeaponFactoryItem` | `callBackGetNewWeaponFactoryItem` | 3 | NewWeaponFactoryInfo | 1 | `lobbyNet/logic/ServersLogic.as:6759` |
| 400 | `getNewbieTaskBean` | `callbackGetNewbieTaskBean` | 1 | NewbieTaskBean | 1 | `lobbyNet/logic/ServersLogic.as:12061` |
| 401 | `getOnlineFriend` | `onGetOnlineFriend` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1357` |
| 402 | `getOnlineTeamMember` | `onGetOnlineTeamMember` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3233` |
| 403 | `getOtherGlobalAchv` | `callbackGetGlobalAchv` | 5 | GlobalAchvBean | 1 | `lobbyNet/logic/ServersLogic.as:10326` |
| 404 | `getOtherGlobalAchvData` | `callbackGetGlobalAchvData` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10331` |
| 405 | `getOtherReducedRankOverviewInfo` | `callbackGetOtherRankOverviewInfo` | 4 | RankOverviewInfo | 1 | `lobbyNet/logic/ServersLogic.as:3736` |
| 406 | `getPalAllianceTeamInfo` | `callbackGetAllianceTeamInfo` | 2 | ClientPalAllianceTeamData | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:276` |
| 407 | `getPalNodeDetail` | `callbackGetPalNodeDetail` | 2 | ClientPalNodeDetail | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:356` |
| 408 | `getPalUserOverviewInfo` | `callbackGetPalUserOverviewInfo` | 5 | PalRoundUserBean, ClientPalUserBean | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:316` |
| 409 | `getPeakBags` | `callbackGetPeakBags` | 2 | ClientPeakDuelData | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:51` |
| 410 | `getPeakCompetitionGroup` | `callbackGetPeakCompetitionGroup` | 4 | - | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:86` |
| 411 | `getPeakGroups` | `callbackGetPeakGroups` | 1 | - | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:31` |
| 412 | `getPeakLikes` | `callbackGetPeakLikes` | 3 | - | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:96` |
| 413 | `getPerfectWeaponList` | `callbackGetPerfectWeaponList` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9714` |
| 414 | `getPhoneBindInfo` | `callbackGetPhoneBindInfo` | 1 | ClientPhoneBindBean | 1 | `lobbyNet/logic/ServersLogic.as:3372` |
| 415 | `getPinnacleInfinitySeasonInfo` | `callbackGetPinnacleInfinitySeasonInfo` | 2 | RpgPinnacleInfinitySeasonBean | 1 | `lobbyNet/logic/ServersLogic.as:12200` |
| 416 | `getPresetTemplateStatus` | `callbackGetPresetTemplate` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:14075` |
| 417 | `getPveAchievement` | `onGetPveAchievement` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:4393` |
| 418 | `getPveAchievementReward` | `onGetPveAchievementReward` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:4403` |
| 419 | `getPveArtifactLuckyRankInfo` | `onGetPveArtifactLuckyRankInfo` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4507` |
| 420 | `getQQVipPack` | `onGetQQVipPack` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:4002` |
| 421 | `getQuizQuestion` | `onGetQuizQuestion` | 1 | ClientQuizQuestionBean | 1 | `lobbyNet/logic/ServersLogic.as:4779` |
| 422 | `getQuizResult` | `onGetQuizResult` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4789` |
| 423 | `getQuizStatus` | `onGetQuizStatus` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:6609` |
| 424 | `getRaceActiveTasks` | `callbackGetRaceActiveTasks` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11912` |
| 425 | `getRaceEntertainmentBanGroup` | `callbackGetRaceEntertainmentBanGroup` | 1 | - | 1 | `lobbyNet/channelLogic/RaceChannelLogic.as:40` |
| 426 | `getRaceEntertainmentSeasonInfo` | `callbackGetRaceEntertainmentSeasonInfo` | 1 | CharRaceEntertainmentBean | 1 | `lobbyNet/logic/ServersLogic.as:11794` |
| 427 | `getRaceEntertainmentVoteRank` | `callbackGetRaceEntertainmentVoteRank` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:11861` |
| 428 | `getRaceKingRank` | `callbackGetRaceEntertainmentVoteRank` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:10671` |
| 429 | `getRandomPackInfo` | `onGetRandomPackInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:4705` |
| 430 | `getRandomWeightPackInfo` | `callbackGetRandomWeightPackInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6314` |
| 431 | `getRankDisplayInfo` | `callbackGetRankDisplayInfo` | 5 | ClientActivityUserDisplayInfo | 1 | `lobbyNet/logic/ServersLogic.as:3758` |
| 432 | `getRankItemInfo` | `callbackGetRankItemInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:6374` |
| 433 | `getRankList` | `onGetRankList` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2332` |
| 434 | `getRankNew` | `callbackGetRankNew` | 6 | - | 1 | `lobbyNet/logic/ServersLogic.as:3590` |
| 435 | `getRankSliceGroupMap` | `callbackGetRankSliceGroupMap` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12841` |
| 436 | `getRankUserDisplayInfo` | `callbackGetUserDisplayInfo` | 3 | ClientActivityUserDisplayInfo | 1 | `lobbyNet/logic/ServersLogic.as:3753` |
| 437 | `getRealmExchangeBeans` | `callbackGetRealmExchangeBeans` | 2 | RealmExchangeHistoryBean | 1 | `lobbyNet/logic/ServersLogic.as:13425` |
| 438 | `getRealmExchangeRefund` | `callbackGetRealmExchangeRefund` | 4 | ClientRealmExchangeBean | 1 | `lobbyNet/logic/ServersLogic.as:13465` |
| 439 | `getRebirthOverview` | `callbackGetRebirthOverview` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:13630` |
| 440 | `getReceiveRewardInfo` | `callbackGetReceiveRewardInfo` | 1 | ReceiveRewardBean | 1 | `lobbyNet/logic/ServersLogic.as:12542` |
| 441 | `getReducedRankByPage` | `callbackGetReducedRankByPage` | 6 | - | 1 | `lobbyNet/logic/ServersLogic.as:3702` |
| 442 | `getReducedRankOverviewInfo` | `callbackGetOtherRankOverviewInfo` | 4 | RankOverviewInfo | 1 | `lobbyNet/logic/ServersLogic.as:3681` |
| 443 | `getReputationBean` | `callbackGetReputationBean` | 1 | ReputationBean | 1 | `lobbyNet/logic/ServersLogic.as:11928` |
| 444 | `getRpgAdventureEvent` | `callbackGetRpgAdventureEvent` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5819` |
| 445 | `getRpgArenaInfo` | `callBackGetRpgArenaInfo` | 1 | ClientRpgArenaResult | 1 | `lobbyNet/logic/ServersLogic.as:9365` |
| 446 | `getRpgAvatarInfo` | `callbackGetRpgAvatarInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6334` |
| 447 | `getRpgChannel` | `callbackGetRpgChannel` | 1 | RpgChannelInfo | 1 | `lobbyNet/logic/ServersLogic.as:5082` |
| 448 | `getRpgCoreSystemInfo` | `callbackGetRpgCoreSystemInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10492` |
| 449 | `getRpgDailyTaskInfo` | `callbackRpgDailyTaskInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:6415` |
| 450 | `getRpgDivineMarkBeans` | `callbackGetRpgDivineMarkBeans` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13095` |
| 451 | `getRpgEndlessShopInfo` | `callbackGetRpgEndlessShopInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5614` |
| 452 | `getRpgExploreQueueInfo` | `callBackGetRpgExploreQueueInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6430` |
| 453 | `getRpgExpressionValues` | `onGetRpgExpressionValues` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4837` |
| 454 | `getRpgMagicArsenalInfo` | `callbackGetMagicArsenalInfo` | 1 | UserRpgMagicArsenal | 1 | `lobbyNet/logic/ServersLogic.as:6274` |
| 455 | `getRpgMixture` | `callbackGetRpgMixture` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:13264` |
| 456 | `getRpgNewbieTasks` | `callbackGetRpgNewbieTasks` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12071` |
| 457 | `getRpgRandomChallengeBean` | `callbackGetRpgRandomChallengeBean` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:13065` |
| 458 | `getRpgReconstructionMap` | `callbackGetRpgReconstructionMap` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5519` |
| 459 | `getRpgRiskRank` | `callbackGetRpgRiskRank` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:5589` |
| 460 | `getRpgRoomList` | `callbackGetRpgRoomList` | 1 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:283` |
| 461 | `getRpgShopBuyLimit` | `callbackGetRpgShopBuyLimit` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:7716` |
| 462 | `getRpgShopInfo` | `callbackGetRpgShopInfo` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6194` |
| 463 | `getRpgTaskDataList` | `callbackGetRpgTaskDataList` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:12749` |
| 464 | `getRpgTeamHistoryLog` | `callbackGetRpgTeamHistoryLog` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:7399` |
| 465 | `getRpgTeamInfo` | `callbackGetRpgTeamInfo` | 4 | RpgTeamBean | 1 | `lobbyNet/logic/ServersLogic.as:6089` |
| 466 | `getRpgTeamLeagueWeekData` | `callbackGetRpgTeamLeagueWeekData` | 1 | RpgTeamLeagueBean | 1 | `lobbyNet/logic/ServersLogic.as:9851` |
| 467 | `getRpgTeamList` | `callbackGetRpgTeamList` | 1 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:234` |
| 468 | `getRpgWelcomeTasks` | `callbackGetRpgWelcomeTasks` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11675` |
| 469 | `getRpgZoomUserBean` | `callbackGetRpgZoomUserBean` | 1 | RpgZoomUserBean | 1 | `lobbyNet/logic/ServersLogic.as:7936` |
| 470 | `getRuneBagTasks` | `callbackGetRuneBagTasks` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11217` |
| 471 | `getScratchOffUserBean` | `callbackGetScratchOffUserBean` | 2 | ClientScratchOffUserBean | 1 | `lobbyNet/logic/ServersLogic.as:13886` |
| 472 | `getScuffleEquipConfig` | `callbackGetScuffleEquipConfig` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6059` |
| 473 | `getScuffleOneOnOneReport` | `callbackGetScuffleOneOnOneReport` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6079` |
| 474 | `getSeasonPassInfo` | `callbackGetSeasonPasInfo` | 5 | SeasonPassUserBean | 1 | `lobbyNet/logic/ServersLogic.as:5296` |
| 475 | `getShopBuyInfo` | `callbackGetShopBuyInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2146` |
| 476 | `getShopOverviewInfo` | `callbackGetShopOverviewInfo` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:2156` |
| 477 | `getStarProjectInfo` | `callBackGetStarProjectInfo` | 3 | StarProjectUserDataBean | 1 | `lobbyNet/logic/ServersLogic.as:10692` |
| 478 | `getStorageStoreList` | `callbackGetStorageStoreList` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:2027` |
| 479 | `getTeamImpeachInfo` | `callbackGetTeamImpeachInfo` | 2 | ClientTeamImpeachBean | 1 | `lobbyNet/logic/ServersLogic.as:6015` |
| 480 | `getTeamInfo` | `onGetTeamInfo` | 1 | ClientTeamBean | 1 | `lobbyNet/logic/ServersLogic.as:3006` |
| 481 | `getTeamLeagueInfo` | `callbackGetTeamLeagueInfo` | 1 | ClientTeamLeagueBean | 1 | `lobbyNet/logic/ServersLogic.as:9754` |
| 482 | `getTeamLegionStorage` | `callbackGetTeamLegionStorage` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:10578` |
| 483 | `getTeamLegionTechnology` | `callbackGetTeamLegionTechnology` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10542` |
| 484 | `getTeamList` | `onGetTeamList` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:3155` |
| 485 | `getTeamListByName` | `onGetTeamList` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:3160` |
| 486 | `getTeamMember` | `onGetTeamMember` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3203` |
| 487 | `getTeamTreasureBox` | `callbackGetTeamTreasureBox` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12575` |
| 488 | `getTeamUserInfo` | `onGetTeamUserInfo` | 1 | ClientTeamUserBean | 1 | `lobbyNet/logic/ServersLogic.as:3243` |
| 489 | `getTerritorialContentionInfo` | `callbackGetTerritorialContentionInfo` | 1 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:192` |
| 490 | `getTerritorialContentionInfoOne` | `callbackGetTerritorialContentionInfo` | 1 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:202` |
| 491 | `getTerritorialTeamBean` | `callbackGetTerritorialTeamBean` | 2 | ClientTeamTerritorialBean, ClientTeamTerritorialUserBean | 1 | `lobbyNet/logic/ServersLogic.as:12153` |
| 492 | `getTgpVipPack` | `onGetYellowVipPack` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4091` |
| 493 | `getTimeSafeBoxOrderBean` | `callbackGetTimeSafeBoxOrderBean` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12246` |
| 494 | `getTimeSafeBoxesBean` | `callbackGetTimeSafeBoxOrderBean` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:12235` |
| 495 | `getTotalSignInReward` | `callbackTotalSignInReward` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:784` |
| 496 | `getTrialTowerInfo` | `callbackGetTrialTowerInfo` | 3 | TrialTowerUserBean, TrialTowerRandomData | 1 | `lobbyNet/logic/ServersLogic.as:14258` |
| 497 | `getTriggerActivityList` | `callbackGetTriggerActivityList` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:4446` |
| 498 | `getUltimateAvatarInfo` | `callbackGetUltimateAvatarInfo` | 1 | UltimateAvatarBean | 1 | `lobbyNet/logic/ServersLogic.as:10018` |
| 499 | `getUltimateReward` | `callBackGetUltimateReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:6798` |
| 500 | `getUpgradeDragoonChip` | `callBackUpgradeDragoonChip` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:7745` |
| 501 | `getUpgradeDragoonChipByExp` | `callBackGetUpgradeDragoonChipByExp` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7803` |
| 502 | `getUpgradeInfo` | `callbackGetUpgradeInfo` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:9200` |
| 503 | `getUserDyeingWorks` | `callbackGetUserDyeingWorks` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:14225` |
| 504 | `getUserIpRegion` | `callbackGetUserIpRegion` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1336` |
| 505 | `getUserLocationData` | `onGetUserLocationData` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:4170` |
| 506 | `getVariantSkillInfo` | `callBackGetVariantSkillInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10122` |
| 507 | `getVariationItemLimitInfo` | `callBackGetVariationItemLimitInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2117` |
| 508 | `getVerificationCode` | `callbackGetVerificationCode` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3398` |
| 509 | `getVipReturnWeaponInfo` | `callBackGetVipReturnWeaponInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6590` |
| 510 | `getVoteWeaponResult` | `callbackGetVoteWeaponResult` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11900` |
| 511 | `getWarLetterBean` | `callbackGetWarLetterBean` | 1 | ClientWarLetterBean | 1 | `lobbyNet/logic/ServersLogic.as:13203` |
| 512 | `getWeaponBattleData` | `callbackGetWeaponBattleData` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6652` |
| 513 | `getWeaponCalibrationBeans` | `callbackGetWeaponCalibrationBeans` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:13315` |
| 514 | `getWeaponFactoryInfo` | `onGetWeaponFactoryInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:6663` |
| 515 | `getWeaponFactoryItem` | `onGetWeaponFactoryItem` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:6673` |
| 516 | `getWeaponForbiddenDetail` | `callbackGetWeaponForbiddenDetail` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11890` |
| 517 | `getWeaponForbiddenRank` | `callbackGetWeaponForbiddenRank` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11850` |
| 518 | `getWeaponForbiddenUserVotes` | `callbackGetWeaponForbiddenUserVotes` | 2 | WeaponForbiddenUserBean | 1 | `lobbyNet/logic/ServersLogic.as:11783` |
| 519 | `getWeaponGroupSkinData` | `callbackGetWeaponGroupSkinData` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:11763` |
| 520 | `getWeaponSlotInfo` | `callBackGetWeaponSlotInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2377` |
| 521 | `getWeaponStorageInfo` | `callBackGetWeaponStorageInfo` | 1 | ClientWeaponStorageBean | 1 | `lobbyNet/logic/ServersLogic.as:3956` |
| 522 | `getWeaponTreasureLuckyInfo` | `onGetWeaponTreasureLuckyInfo` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4731` |
| 523 | `getWeekTaskReward` | `callbackWeekTaskReward` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6405` |
| 524 | `getWeeklyActiveTask` | `callbackGetWeeklyActiveTask` | 1 | WeeklyActiveTaskBean | 1 | `lobbyNet/logic/ServersLogic.as:4948` |
| 525 | `getWeeklyActiveTaskItemReward` | `callbackWeeklyActiveTaskItemReward` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:4953` |
| 526 | `getWeeklyActiveTaskReward` | `callbackWeeklyActiveTaskReward` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:4958` |
| 527 | `getWeiDuanPack` | `onGeWeiDuanPack` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4112` |
| 528 | `getWishTeamBean` | `callbackGetWishTeamBean` | 4 | ClientWishTeamBean | 1 | `lobbyNet/logic/ServersLogic.as:13945` |
| 529 | `getYellowVipPack` | `onGetYellowVipPack` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:3971` |
| 530 | `giftAwayLegionItem` | `callbackGiftAwayLegionItem` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10647` |
| 531 | `giftLegionCoin` | `callbackGiftLegionCoin` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10659` |
| 532 | `giveGift` | `onGiveGift` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:804` |
| 533 | `giveRpgGift` | `callbackGiveRpgGift` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:835` |
| 534 | `giveUpLuckyWheelTask` | `callbackGiveUpLuckyWheelTask` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:13193` |
| 535 | `giveUpTask` | `callBackGiveUpTask` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5180` |
| 536 | `giveUpTaskBySeasonId` | `callbackGiveUpTaskBySeasonId` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:14117` |
| 537 | `globalRoomChannelAvaliable` | `onGlobalRoomChannelAvaliable` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:878` |
| 538 | `handInTeamBadge` | `callbackHandInTeamBadge` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6827` |
| 539 | `handleWishTeamInvitation` | `callbackHandleWishTeamInvitation` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:14004` |
| 540 | `identifyDivineMarkStone` | `callbackIdentifyDivineStone` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13110` |
| 541 | `impeachTeamLeader` | `callbackImpeachTeamLeader` | 2 | ClientTeamImpeachBean | 1 | `lobbyNet/logic/ServersLogic.as:6025` |
| 542 | `inactiveFavorite` | `callbackInactiveFavorite` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11259` |
| 543 | `inviteJoinChannelTeam` | `callbackInviteJoinChannelTeam` | 1 | - | 1 | `lobbyNet/channelLogic/TeamChannelLogic.as:40` |
| 544 | `inviteJoinInRpgTeam` | `callbackInviteJoinInRpgTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6119` |
| 545 | `inviteJoinRoom` | `onInviteJoinRoom` | 3 | ClientRoom | 1 | `lobbyNet/logic/LobbyLogic.as:536` |
| 546 | `inviteJoinRpgTeam` | `callbackInviteJoinRpgTeam` | 1 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:98` |
| 547 | `inviteJoinTeam` | `onInviteJoinTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2788` |
| 548 | `inviteJoinTeamResult` | `onInviteJoinTeamResult` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2813` |
| 549 | `inviteJoinWishTeam` | `callbackInviteJoinWishTeam` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:13966` |
| 550 | `isAutomaticEquip` | `callbackIsAutomaticEquip` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9338` |
| 551 | `joinChannelTeam` | `callbackJoinChannelTeam` | 2 | ChannelTeam | 1 | `lobbyNet/channelLogic/TeamChannelLogic.as:49` |
| 552 | `joinPalAllianceTeam` | `callbackJoinPalAllianceTeam` | 2 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:286` |
| 553 | `joinRaceRoom` | `callbackJoinRaceRoom` | 2 | ClientRaceRoom | 1 | `lobbyNet/logic/ServersLogic.as:4236` |
| 554 | `joinRestrictionRoom` | `callbackJoinRestrictionRoom` | 1 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:172` |
| 555 | `joinRpgRestrictionRoom` | `callbackJoinRpgRoom` | 2 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:317` |
| 556 | `joinRpgRoom` | `callbackJoinRpgRoom` | 2 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:312` |
| 557 | `joinRpgTeam` | `callbackJoinRpgTeam` | 2 | RpgTeamInfo | 1 | `lobby/model/rpg/net/RpgServerLogic.as:108` |
| 558 | `kickOutRpgTeam` | `callbackKickOutRpgTeam` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6129` |
| 559 | `kickOutTeam` | `onKickOutTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2855` |
| 560 | `kickOutTeamMember` | `callbackKickOutTeamMember` | 1 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:263` |
| 561 | `kickOutWishTeam` | `callbackKickOutWishTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:14048` |
| 562 | `kickRaceUser` | `callbackRaceUserLeave` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4296` |
| 563 | `kingScuffleStartAfk` | `callbackStartKingScuffleAfk` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13390` |
| 564 | `kingScuffleStopAfk` | `callbackStopKingScuffleAfk` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:13408` |
| 565 | `leaveChannelTeam` | `callbackLeaveChannelTeam` | 0 | - | 1 | `lobbyNet/channelLogic/TeamChannelLogic.as:96` |
| 566 | `leaveRaceRoom` | `callbackLeaveRaceRoom` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4251` |
| 567 | `leaveRpgTeam` | `callbackLeaveRpgTeam` | 0 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:204` |
| 568 | `legendCasting` | `callbackLegendCasting` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:6244` |
| 569 | `likeDyeingWork` | `callbackLikeDyeingWork` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:14210` |
| 570 | `likePeakCompetitor` | `callbackLikePeakCompetitor` | 4 | ClientCompetitionGroup | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:106` |
| 571 | `listHomelandHallRentItem` | `callbackListHomelandHallRentItem` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13526` |
| 572 | `loadUltTalentSkill` | `callbackLoadUltTalentSkill` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5529` |
| 573 | `loanRepayment` | `callbackLoanRepayment` | 2 | ClientCreditBillBean | 1 | `lobbyNet/logic/ServersLogic.as:11405` |
| 574 | `lockEnchantmentSlot` | `callbackLockEnchantmentSlot` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5792` |
| 575 | `lockRingAffix` | `callbackLockRingAffix` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:13702` |
| 576 | `lockRunes` | `callbackLockRunes` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10981` |
| 577 | `lockSlavePropertyRecord` | `callbackLockSlavePropertyRecord` | 3 | SecondPropertyBean | 1 | `lobbyNet/logic/ServersLogic.as:9557` |
| 578 | `login` | `onFriendLogin` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:952` |
| 579 | `loginBattle` | `callbackLoginBattle` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7410` |
| 580 | `lookupFriendshipRooms` | `callbackLookupFriendshipRooms` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:13590` |
| 581 | `luckyDrawBulk` | `callBackLuckyDrawBulk` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:3903` |
| 582 | `luckyDrawMulti` | `callBackLuckyDrawMulti` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:3892` |
| 583 | `luckyDrawSingle` | `callBackLuckyDrawSingle` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:3869` |
| 584 | `luckyDrawStartup` | `callBackLuckyDrawStartup` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:3829` |
| 585 | `luckyDrawStartupSuper` | `callBackLuckyDrawStartupSuper` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:3847` |
| 586 | `makeHomelandFormula` | `callbackMakeHomelandFormula` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12895` |
| 587 | `makeLeagueEngine` | `callbackMakeLeagueEngine` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:9824` |
| 588 | `markDragoonChip` | `callBackMarkDragoonChip` | 1 | RpgChipDataBean | 1 | `lobbyNet/logic/ServersLogic.as:7812` |
| 589 | `markPalNodePointFlag` | `callbackMarkPalNodePointFlag` | 3 | HexPoint | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:261` |
| 590 | `marketGetItemDetailInfo` | `callbackGetRankItemInfo` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8645` |
| 591 | `marketGetUserBuyOrderInfo` | `callbackMarketGetUserBuyOrderInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:8280` |
| 592 | `marketGetUserMarketOverviewInfo` | `callbackMarketGetUserMarketOverviewInfo` | 1 | ClientUserMarketOverviewInfo | 1 | `lobbyNet/logic/ServersLogic.as:8670` |
| 593 | `marketGetUserSellOrderInfo` | `callbackMarketGetUserSellOrderInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:8300` |
| 594 | `marketShowComplexSellingOrderListWithPage` | `callbackMarketShowComplexSellingOrderListWithPage` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:8360` |
| 595 | `marketShowHistoryAvgFinalPrice` | `callbackMarketShowHistoryAvgFinalPrice` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8608` |
| 596 | `marketShowOverviewInfo` | `callbackMarketShowOverviewInfo` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:7596` |
| 597 | `marketShowSellingOrderListWithPage` | `callbackMarketShowSellingOrderListWithPage` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:8338` |
| 598 | `marketShowShelfDetailInfo` | `callbackMarketShowShelfDetailInfo` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:8171` |
| 599 | `marketSubmitBuyOrder` | `callbackMarketSubmitBuyOrder` | 2 | BuyOrderDTO | 1 | `lobbyNet/logic/ServersLogic.as:7645` |
| 600 | `marketSubmitSellOrder` | `callbackMarketSubmitSellOrder` | 2 | SellOrderDTO | 1 | `lobbyNet/logic/ServersLogic.as:8036` |
| 601 | `marketSubmitSellOrderV3` | `callbackMarketSubmitSellOrder` | 2 | SellOrderDTO | 1 | `lobbyNet/logic/ServersLogic.as:10953` |
| 602 | `marketSubmitSellOrderWithSystemMode` | `callbackMarketSubmitSellOrder` | 2 | SellOrderDTO | 1 | `lobbyNet/logic/ServersLogic.as:8693` |
| 603 | `marketTryCancelBuyOrder` | `callbackMarketTryCancelBuyOrder` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8092` |
| 604 | `marketTryCancelSellOrder` | `callbackMarketTryCancelSellOrder` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8219` |
| 605 | `marketTryFetchBuyOrder` | `callbackMarketTryFetchBuyOrder` | 2 | BuyOrderDTO | 1 | `lobbyNet/logic/ServersLogic.as:8484` |
| 606 | `marketTryFetchSellOrder` | `callbackMarketTryFetchSellOrder` | 2 | SellOrderDTO | 1 | `lobbyNet/logic/ServersLogic.as:8541` |
| 607 | `marketTryRefundBuyOrder` | `callbackMarketTryRefundBuyOrder` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:8128` |
| 608 | `marketTryRefundSellOrder` | `callbackMarketTryRefundSellOrder` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:8147` |
| 609 | `matchGlobalRoom` | `onMatchGlobalRoom` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4754` |
| 610 | `mergeSkin` | `callbackMergeSkin` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6873` |
| 611 | `militaryExchangeStorage` | `callbackMilitaryExchangeStorage` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:11026` |
| 612 | `modifyRpgAdventureLogRewardList` | `callbackModifyRpgAdventureLogRewardList` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5852` |
| 613 | `mountGrids` | `callbackMountGrids` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12712` |
| 614 | `newSignIn` | `callbackNewSignIn` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:705` |
| 615 | `onCallRankList` | `onGetRankList` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7452` |
| 616 | `onGameCoolDownCompleted` | `onGameCoolDownChanged` | 2 | GameCoolDownBean | 1 | `lobbyNet/logic/ServersLogic.as:12875` |
| 617 | `onGiveTitaniumGift` | `callbackGiveTitaniumGift` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7486` |
| 618 | `onInvitationRankList` | `callbackInvitationRankList` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:7442` |
| 619 | `onTitaniumCode` | `callbackOnTitaniumCode` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7462` |
| 620 | `onTitaniumTaskInfo` | `callbackTitaniumTaskInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7529` |
| 621 | `onUserEtherBeanInfo` | `callbackUserEtherBeanInfo` | 1 | UserEtherBean | 1 | `lobbyNet/logic/ServersLogic.as:7432` |
| 622 | `openBlind` | `callbackOpenBlind` | 3 | RpgBlindPackBean | 1 | `lobbyNet/logic/ServersLogic.as:11627` |
| 623 | `openCard` | `callbackOpenCard` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5988` |
| 624 | `openCreditAccount` | `callbackOpenCreditAccount` | 2 | ClientCreditAccountBean | 1 | `lobbyNet/logic/ServersLogic.as:11312` |
| 625 | `openDecoration` | `onOpenDecoration` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1577` |
| 626 | `openHomeland` | `callbackOpenHomeland` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12823` |
| 627 | `openSkinBox` | `callbackOpenSkinBox` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:2080` |
| 628 | `openVariationBox` | `callBackOpenVariationBox` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:2103` |
| 629 | `operateFestCelebration2025Shop` | `callbackLockFestCelebration2025Shop` | 2 | FestCelebration2025UserBean | 1 | `lobbyNet/logic/ServersLogic.as:10396` |
| 630 | `operateMapPathNode` | `callbackOperateMapPathNode` | 3 | FestCelebration2025UserBean | 1 | `lobbyNet/logic/ServersLogic.as:10406` |
| 631 | `operaterBountyTask` | `callBackOperaterBountyTask` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5225` |
| 632 | `organizeStorage` | `callbackOrganizeStorageComplete` | 0 | - | 1 | `lobbyNet/logic/ServersLogic.as:10212` |
| 633 | `palMarch` | `callbackPalMarch` | 3 | PalTroop | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:296` |
| 634 | `palQuickMarch` | `callbackPalQuickMarch` | 3 | PalTroop | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:306` |
| 635 | `pickForeverLandItem` | `callbackPickForeverLandItem` | 3 | ClientPickBean, ClientPickBean | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:386` |
| 636 | `playActivityNew` | `callbackPlayActivityNew` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:4675` |
| 637 | `playActivityNewWithType` | `callbackPlayActivityNewWithType` | 0 | - | 1 | `acg/lobbyNet/logic/AcgServersLogic.as:251` |
| 638 | `prepareScufflePeak` | `callbackPrepareScufflePeak` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13055` |
| 639 | `queryAcgLuckyDrawProcess` | `callbackQueryAcgLuckyDrawProcess` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12941` |
| 640 | `queryCompletedQuestionnaires` | `callbackQueryCompletedQuestionnaires` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:11524` |
| 641 | `queryCreditAccount` | `callbackQueryCreditAccount` | 3 | ClientCreditAccountBean | 1 | `lobbyNet/logic/ServersLogic.as:11299` |
| 642 | `queryEnvoyLingFuData` | `callbackQueryEnvoyLingFuData` | 6 | - | 1 | `lobbyNet/logic/ServersLogic.as:13804` |
| 643 | `queryExpeditionConditions` | `callbackQueryExpeditionConditions` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:13045` |
| 644 | `queryFriendInfo` | `callbackQueryFriendInfo` | 2 | ClientFriendInfoBean | 1 | `lobbyNet/logic/ServersLogic.as:1418` |
| 645 | `queryHistoryBill` | `callbackQueryHistoryBill` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:11395` |
| 646 | `queryMonitorInfo` | `callbackQueryMonitorInfo` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:11444` |
| 647 | `queryOngoingBill` | `callbackQueryOngoingBill` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:11344` |
| 648 | `queryUserHistoryRecord` | `callbackQueryUserHistoryRecord` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:12852` |
| 649 | `quitRpgTeam` | `callbackQuitRpgTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6169` |
| 650 | `quitTeam` | `onQuitTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2839` |
| 651 | `quitWishTeam` | `callbackQuitWishTeam` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:14037` |
| 652 | `raidRpgBattleField` | `callbackRaidRpgBattleField` | 9 | - | 1 | `lobbyNet/logic/ServersLogic.as:5877` |
| 653 | `randomStarProjectBox` | `callBackUpdateStarProjectBox` | 1 | StarProjectUserDataBean | 1 | `lobbyNet/logic/ServersLogic.as:10716` |
| 654 | `reNewSignIn` | `callbackReNewSignIn` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:726` |
| 655 | `reSignInOncePerDay` | `onSignInByDay` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:659` |
| 656 | `readAndFetchAllMail` | `callbackReadAndFetchAllMail` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:2638` |
| 657 | `realTimeNotice` | `callBackRealTimeNotice` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3946` |
| 658 | `recallRpgWeaponBattleSlv` | `callbackRecallRpgWeaponBattleSlv` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5486` |
| 659 | `receiveLingYunReward` | `callbackReceiveLingYunReward` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13856` |
| 660 | `receiveReward` | `callbackReceiveReward` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:12552` |
| 661 | `receiveTask` | `callBackReceiveTask` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5144` |
| 662 | `receiveTaskBySeasonId` | `callbackReceiveTaskBySeasonId` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:14108` |
| 663 | `refineRing` | `callbackRefineRing` | 2 | RingRefineResult | 1 | `lobbyNet/logic/ServersLogic.as:13662` |
| 664 | `reformUnequippedWeaponSlot` | `callBackReformUnequippedWeaponSlot` | 7 | WeaponSlotReformAffix | 1 | `lobbyNet/logic/ServersLogic.as:2489` |
| 665 | `reformWeaponSlot` | `callBackReformWeaponSlot` | 6 | WeaponSlotReformAffix | 1 | `lobbyNet/logic/ServersLogic.as:2467` |
| 666 | `refreshBlind` | `callbackRefreshBlind` | 2 | RpgBlindPackBean | 1 | `lobbyNet/logic/ServersLogic.as:11617` |
| 667 | `refreshDailyTask` | `callbackRefreshDailyTask` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:5365` |
| 668 | `refreshDefenseLineWeapon` | `callbackRefreshDefenseLineWeapon` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:7912` |
| 669 | `refreshDefenseLineWeaponEquipInfo` | `callbackRefreshDefenseLineWeaponEquipInfo` | 2 | ClientDefenseLineWeaponBean | 1 | `lobbyNet/logic/ServersLogic.as:9881` |
| 670 | `refreshMysteryShop` | `callbackRefreshMysteryShop` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10194` |
| 671 | `refreshRecommandFriendList` | `onRefreshRecommandFriend` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4373` |
| 672 | `refreshRoomStatus` | `onRefreshRoomStatus` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4204` |
| 673 | `refreshRpgShop` | `callbackRefreshRpgShop` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:6199` |
| 674 | `refreshTimeSafeBox` | `callbackRefreshTimeSafeBox` | 3 | ClientTimeSafeBoxesBean | 1 | `lobbyNet/logic/ServersLogic.as:12293` |
| 675 | `refreshWarLetterBuff` | `callbackRefreshWarLetterBuff` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:13247` |
| 676 | `refundPerMonth` | `onRefundPerMonth` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:1720` |
| 677 | `relicEnchantment` | `callbackRelicEnchantment` | 5 | EnchantmentBean | 1 | `lobbyNet/logic/ServersLogic.as:5773` |
| 678 | `relicLvBreakMaxLv` | `callbackRelicLvBreakMaxLv` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5743` |
| 679 | `relicSystemInfo` | `callbackRelicSystemInfo` | 1 | ClientArmorCoreBean | 1 | `lobbyNet/logic/ServersLogic.as:5716` |
| 680 | `remouldRune` | `callbackRemouldRune` | 2 | RunePropertyBean | 1 | `lobbyNet/logic/ServersLogic.as:11110` |
| 681 | `removeAllHaveReadMail` | `callbackRemoveAllHaveReadMail` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2655` |
| 682 | `removeEnvoyFromLingFu` | `callbackRemoveEnvoyFromLingFu` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13843` |
| 683 | `removeMyDyeingWork` | `callbackRemoveMyDyeingWork` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:14237` |
| 684 | `rentHomelandHallItem` | `callbackRentHomelandHallItem` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13560` |
| 685 | `rerandomStarProjectBox` | `callBackUpdateStarProjectBox` | 1 | StarProjectUserDataBean | 1 | `lobbyNet/logic/ServersLogic.as:10728` |
| 686 | `resetCalibrateCount` | `callbackResetCalibrateCount` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:9532` |
| 687 | `resetNewWeaponFactory` | `callBackGetNewWeaponFactoryItem` | 3 | NewWeaponFactoryInfo | 1 | `lobbyNet/logic/ServersLogic.as:6793` |
| 688 | `resetRpgArenaData` | `callbackResetRpgArenaData` | 2 | ClientRpgArenaResult | 1 | `lobbyNet/logic/ServersLogic.as:9637` |
| 689 | `resetRpgInfinity` | `callbackResetRpgInfinity` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5634` |
| 690 | `resetRpgMagicArsenal` | `callbackResetRpgMagicArsenal` | 1 | UserRpgMagicArsenal | 1 | `lobbyNet/logic/ServersLogic.as:6294` |
| 691 | `resetSecPsw` | `callbackResetSecPsw` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6904` |
| 692 | `resetTeamLeague` | `callbackResetTeamLeague` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:9744` |
| 693 | `resetWeaponPrecision` | `callbackResetWeaponPrecision` | 3 | ClientWeaponCalibrationBean | 1 | `lobbyNet/logic/ServersLogic.as:13375` |
| 694 | `resumeRaceGame` | `startRaceGame` | 6 | - | 1 | `lobbyNet/logic/ServersLogic.as:1811` |
| 695 | `retrievalStorageBean` | `callbackRetrievalStorageBean` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:1989` |
| 696 | `rewardBioChemDefenseLine` | `callbackRewardBioChemDefenseLine` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:7892` |
| 697 | `rewardRetrieve` | `callbackRewardRetrieve` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9149` |
| 698 | `rpgExploreQuickComplete` | `callBackRpgExploreQuickComplete` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6480` |
| 699 | `rpgGetExploreReward` | `callBackRpgGetExploreReward` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6461` |
| 700 | `rpgHardTrain` | `callbackRpgHardTrain` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5824` |
| 701 | `rpgMagicArsenalMove` | `callbackRpgMagicArsenalMove` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6264` |
| 702 | `rpgMagicArsenalMove10` | `callbackRpgMagicArsenalMove10` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6254` |
| 703 | `rpgReceiveEndlessReward` | `callbackRpgReceiveEndlessReward` | 6 | - | 1 | `lobbyNet/logic/ServersLogic.as:5867` |
| 704 | `rpgStartExplore` | `callBackRpgStartExplore` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6440` |
| 705 | `saveAvatarDyeing` | `callbackSaveAvatarDyeing` | 3 | AvatarDyeingBean | 1 | `lobbyNet/logic/ServersLogic.as:12388` |
| 706 | `saveQuestionnaire` | `callbackSaveQuestionnaire` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:11534` |
| 707 | `saveUltimateAvatarConfigInfo` | `callbackSaveUltimateAvatarConfigInfo` | 2 | UltimateAvatarConfigBean | 1 | `lobbyNet/logic/ServersLogic.as:10060` |
| 708 | `scrapeScratchOffCell` | `callbackScrapeScratchOffCell` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:13922` |
| 709 | `searchCharacterByName` | `onSearchCharacterByName` | 1 | CommonCharInfo | 1 | `lobbyNet/logic/ServersLogic.as:3351` |
| 710 | `searchHomelandBox` | `callbackAcquireHomelandBox` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12925` |
| 711 | `searchNotInRpgTeam` | `callbackSearchNotInRpgTeam` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6179` |
| 712 | `searchRoomListAllChannel` | `onSearchRoomListAllChannel` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4215` |
| 713 | `selectAbattoirDiffType` | `callbackSelectAbattoirDiffType` | 2 | - | 1 | `lobby/model/rpg/net/RpgServerLogic.as:455` |
| 714 | `selectAvatarJoinVariationWar` | `callBackSelectAvatarJoinVariationWar` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:9008` |
| 715 | `selectBag` | `onSelectBag` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1346` |
| 716 | `selectCalibrateResult` | `callbackSelectCalibrateResult` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:9626` |
| 717 | `selectItem` | `onSelectItem` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2302` |
| 718 | `selectItemJoinVariationWar` | `callBackSelectItemJoinVariationWar` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:9907` |
| 719 | `selectOrdinaryVariant` | `callbackSelectOrdinaryVariant` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9058` |
| 720 | `selectPeakBag` | `callbackSelectPeakBag` | 3 | - | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:76` |
| 721 | `selectRandomChallengeTask` | `callbackSelectRandomChallengeTask` | 4 | ClientRandomChallengeColumnBean | 1 | `lobbyNet/logic/ServersLogic.as:13085` |
| 722 | `selectRealmExchangeWeapon` | `callbackSelectRealmExchangeWeapon` | 3 | ClientRealmExchangeBean | 1 | `lobbyNet/logic/ServersLogic.as:13435` |
| 723 | `selectRuneBag` | `callbackSelectRuneBag` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10996` |
| 724 | `selectScratchOff` | `callbackSelectScratchOff` | 3 | ClientScratchOffUserBean | 1 | `lobbyNet/logic/ServersLogic.as:13897` |
| 725 | `selectUltTalentBag` | `callbackSelectUltTalentBag` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5569` |
| 726 | `selectZoom` | `callbackSelectZoom` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:7946` |
| 727 | `sellChip` | `onSellChip` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5042` |
| 728 | `sellLegionItem` | `callbackSellLegionItem` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10630` |
| 729 | `sendBountyTask` | `callBackSendBountyTask` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5190` |
| 730 | `sendMessage` | `callbackSendMessage` | 3 | - | 1 | `lobby/model/chat/logic/Rpg2ChatBaseChannelLogic.as:39` |
| 731 | `sendMessageByBugleType` | `onSendMessageByBugleType` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:1079` |
| 732 | `sendMessageWithExtra` | `callbackSendMessage` | 3 | - | 1 | `lobby/model/chat/logic/Rpg2ChatBaseChannelLogic.as:35` |
| 733 | `setAutoStored` | `callbackSetAutoStored` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:2007` |
| 734 | `setAvatarSupportCaptain` | `callbackSetAvatarSupportCaptain` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6344` |
| 735 | `setBuyLegionGoods` | `callbackSetBuyLegionGoods` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10591` |
| 736 | `setEnvoySoulFavor` | `callbackSetEnvoySoulFavor` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13759` |
| 737 | `setHomelandHallRentLimit` | `callbackSetHomelandHallRentLimit` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13516` |
| 738 | `setRpgMagicArsenalInfo` | `callbackSetMagicArsenalInfo` | 1 | UserRpgMagicArsenal | 1 | `lobbyNet/logic/ServersLogic.as:6284` |
| 739 | `setSecPsw` | `callbackSetSecPsw` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6868` |
| 740 | `setWarriorTeamAssist` | `callbackSetWarriorTeamAssist` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5375` |
| 741 | `show3366Vip` | `onShow3366Vip` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3982` |
| 742 | `showBlack` | `onShowBlack` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1270` |
| 743 | `showBlueVip` | `onShowBlueVip` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4016` |
| 744 | `showCharacterBattleReport` | `callBackShowCharacterBattleReport` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1098` |
| 745 | `showFriend` | `onShowFriend` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1285` |
| 746 | `showHallAnnounce` | `callBackShowHallAnnounce` | 1 | HallAnnounceInfo | 1 | `lobbyNet/logic/ServersLogic.as:1136` |
| 747 | `showLogRecentBattleBean` | `onShowLogRecentBattleBean` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4339` |
| 748 | `showQQVipPacks` | `onShowQQVipPacks` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3992` |
| 749 | `showRaceUserOverviewInfo` | `callbackShowRaceUserOverviewInfo` | 1 | ClientRaceUserOverviewInfo | 1 | `lobbyNet/logic/ServersLogic.as:4301` |
| 750 | `showRecommandFriendList` | `onShowRecommandFriend` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4363` |
| 751 | `showServerVersion` | `callbackShowVersionAnnounce` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:932` |
| 752 | `showSingleBattleReport` | `callBackShowSingleBattleReport` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1113` |
| 753 | `showTgpVip` | `onShowTgpVip` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4081` |
| 754 | `showVersionAnnounce` | `callbackShowVersionAnnounce` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:2229` |
| 755 | `showWeaponUnlock` | `callBackShowWeaponUnlock` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2355` |
| 756 | `showWeiDuan` | `onShowWeiDuan` | 1 | ClientQQWeiDuanBean | 1 | `lobbyNet/logic/ServersLogic.as:4102` |
| 757 | `showYellowVip` | `onShowYellowVip` | 1 | ClientQQYellowVipBean | 1 | `lobbyNet/logic/ServersLogic.as:3961` |
| 758 | `signInPerDay` | `onSignInByDay` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:618` |
| 759 | `signUpTeamLeague` | `callbackSignUpTeamLeague` | 3 | RpgTeamLeagueUserBean | 1 | `lobbyNet/logic/ServersLogic.as:9724` |
| 760 | `spinLuckyWheel` | `callbackSpinLuckyWheel` | 5 | LuckyWheelUserData | 1 | `lobbyNet/logic/ServersLogic.as:13173` |
| 761 | `startDelayRaid` | `callbackStartDelayRaid` | 1 | RpgFestivalDelayRaidData | 1 | `lobbyNet/logic/ServersLogic.as:10856` |
| 762 | `startPresetTemplate` | `callbackStartPresetTemplate` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:14095` |
| 763 | `stopPalMarch` | `callbackStopPalMarch` | 3 | PalTroop | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:301` |
| 764 | `storageAwake` | `callbackStorageAwake` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6224` |
| 765 | `storeStorageBean` | `callbackStoreStorageBean` | 2 | StorageStoreModel | 1 | `lobbyNet/logic/ServersLogic.as:1976` |
| 766 | `strengthCoreLv` | `callbackStrengthCoreLv` | 2 | ClientCoreSystemBean | 1 | `lobbyNet/logic/ServersLogic.as:10502` |
| 767 | `switchEnvoyLingFu` | `callbackSwitchEnvoyLingFu` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:13817` |
| 768 | `switchLingYunElementType` | `callbackSwitchLingYunElementType` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13872` |
| 769 | `switchWingHalo` | `callbackSwitchWingHalo` | 2 | WingPropertyUserBean | 1 | `lobbyNet/logic/ServersLogic.as:12015` |
| 770 | `syncLegionTechnologyProperty` | `onSyncBattleProperty` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:10573` |
| 771 | `syncServerTime` | `callBackSyncServerTime` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:1146` |
| 772 | `takeSettlementGameCoin` | `callbackTakeSettlementGameCoin` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12607` |
| 773 | `takeTeamTreasureBox` | `callbackTakeTeamTreasureBox` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12586` |
| 774 | `teamLeaveMessage` | `onTeamLeaveMessage` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:3124` |
| 775 | `titaniumPanelOpen` | `callbackTitaniumPanelOpen` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7498` |
| 776 | `unEquipBattlePet` | `onUnEquipBattlePet` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1610` |
| 777 | `unEquipDivineMark` | `callbackUnEquipDivineMark` | 2 | ClientDivineMarkBean | 1 | `lobbyNet/logic/ServersLogic.as:13140` |
| 778 | `unEquipGroupRootAvatar` | `callBackUnEquipRootAvatarInfo` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:10927` |
| 779 | `unEquipModuleItem` | `callbackUnEquipModuleItem` | 1 | RpgModuleSysBean | 1 | `lobbyNet/logic/ServersLogic.as:6529` |
| 780 | `unEquipPropertyWing` | `callbackUnEquipPropertyWing` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8988` |
| 781 | `unEquipRune` | `callbackUnEquipRune` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:11067` |
| 782 | `unEquipTacticalWeapon` | `callbackUnEquipTacticalWeapon` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:7842` |
| 783 | `unLockWarriorMedal` | `callbackUnLockWarriorMedal` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5344` |
| 784 | `unMatchGlobalRoom` | `onMatchGlobalRoom` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4759` |
| 785 | `unSelectAvatarJoinVariationWar` | `callBackUnSelectAvatarJoinVariationWar` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:9013` |
| 786 | `unSelectItem` | `onUnSelectItem` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2312` |
| 787 | `unSelectItemJoinVariationWar` | `callBackUnSelectItemJoinVariationWar` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:9921` |
| 788 | `unbindApplet` | `callbackUnbindApplet` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:11660` |
| 789 | `unequipAvatarEquipment` | `callbackUnequipAvatarEquipment` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9435` |
| 790 | `unequipChip` | `onUnequipChip` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5062` |
| 791 | `unequipChipByWeapon` | `onUnequipChipByWeapon` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5072` |
| 792 | `unequipDecoration` | `onUnequipDecoration` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:1566` |
| 793 | `unequipRootAvatarSound` | `callBackUnequipRootAvatarSound` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:8960` |
| 794 | `unequipRpgXpSkill` | `callbackUnequipRpgXpSkill` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5411` |
| 795 | `unequipUltimateAvatar` | `callbackUnequipUltimateAvatar` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:10049` |
| 796 | `unequipWeaponSlot` | `callBackUnequipWeaponSlot` | 5 | WeaponSlotReformBean | 1 | `lobbyNet/logic/ServersLogic.as:2412` |
| 797 | `unloadUltTalentSkill` | `callbackUnloadUltTalentSkill` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5539` |
| 798 | `unlockAssistantAbility` | `callbackUnlockAssistantAbility` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:9086` |
| 799 | `unlockAvatarAcgRelationship` | `callbackUnlockAvatarAcgRelationship` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12455` |
| 800 | `unlockAvatarDyeing` | `callbackUnlockAvatarDyeing` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12307` |
| 801 | `unlockCreditAccount` | `callbackUnlockCreditAccount` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11362` |
| 802 | `unlockDyeingColor` | `callbackUnlockDyeingColor` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12317` |
| 803 | `unlockEnchantmentSlot` | `callbackUnlockEnchantmentSlot` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5760` |
| 804 | `unlockFestivalTalent` | `callbackUnlockFestivalTalent` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:12345` |
| 805 | `unlockModuleSys` | `callbackUnlockModuleSys` | 1 | RpgModuleSysBean | 1 | `lobbyNet/logic/ServersLogic.as:6509` |
| 806 | `unlockNewbieTask` | `callbackUnlockNewbieTask` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:12096` |
| 807 | `unlockRpgReconstructionTalentSkill` | `callbackUnlockRpgReconstructionTalentSkill` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6214` |
| 808 | `unlockSlavePropertyRecord` | `callbackUnlockSlavePropertyRecord` | 2 | SecondPropertyBean | 1 | `lobbyNet/logic/ServersLogic.as:9583` |
| 809 | `unlockTalent` | `callbackUnlockTalent` | 0 | - | 1 | `acg/lobbyNet/logic/AcgServersLogic.as:196` |
| 810 | `unmountGrids` | `callbackUnmountGrids` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12667` |
| 811 | `updateChipExp` | `callBackUpdateChipExp` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:7822` |
| 812 | `updateDefenseLineWeaponEquipStatus` | `callbackUpdateDefenseLineWeaponEquipStatus` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:9871` |
| 813 | `updateReducedRankDisplayFlag` | `callbackUpdateReducedRankDisplayFlag` | 3 | RankDisplayFlag | 1 | `lobbyNet/logic/ServersLogic.as:3719` |
| 814 | `updateRpgBody` | `onUpdateRpgBody` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:4872` |
| 815 | `updateRpgEquipment` | `onUpdateRpgEquipment` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:4882` |
| 816 | `updateRpgEquipmentBatchStrengthen` | `onUpdateRpgEquipmentBatchStrengthen` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:4905` |
| 817 | `updateRpgKingScuffleRankDisplayFlag` | `callbackUpdateRpgKingScuffleRankDisplayFlag` | 2 | RankDisplayFlag | 1 | `lobbyNet/logic/ServersLogic.as:3785` |
| 818 | `updateRpgWeaponBattleSlv` | `callbackRecallRpgWeaponBattleSlv` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5466` |
| 819 | `updateRpgWeaponMasteryLv` | `callbackUpdateWeaponMasteryLv` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:6561` |
| 820 | `updateRpgXpSkillLv` | `callbackUpdateRpgXpSkillLv` | 1 | RpgXpSkillBean | 1 | `lobbyNet/logic/ServersLogic.as:5421` |
| 821 | `updateRpgXpSkillSlv` | `callbackUpdateRpgXpSkillSlv` | 1 | RpgXpSkillBean | 1 | `lobbyNet/logic/ServersLogic.as:5426` |
| 822 | `updateTaskLobbyInfo` | `callBackUpdateTaskLobbyInfo` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5285` |
| 823 | `upgrade` | `callbackUpgrade` | 3 | UpgradeUserBean | 1 | `lobbyNet/logic/ServersLogic.as:9190` |
| 824 | `upgradeAvatarAcgLevel` | `callbackUpgradeAvatarAcgLevel` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:12442` |
| 825 | `upgradeAvatarLv` | `callbackUpgradeAvatarLv` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6354` |
| 826 | `upgradeAvatarTalent` | `callBackUpgradeAvatarTalent` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:9242` |
| 827 | `upgradeEnvoySoul` | `callbackUpgradeEnvoySoul` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:13788` |
| 828 | `upgradeLegionTechnology` | `callbackUpgradeLegionTechnology` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:10553` |
| 829 | `upgradeLuckyWheelReward` | `callbackUpgradeLuckyWheelReward` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:13183` |
| 830 | `upgradeRingLevel` | `callbackUpgradeRingLevel` | 3 | RingPropertyBean | 1 | `lobbyNet/logic/ServersLogic.as:13652` |
| 831 | `upgradeRpgReconstructionLv` | `callbackUpgradeRpgReconstructionLv` | 5 | - | 1 | `lobbyNet/logic/ServersLogic.as:5549` |
| 832 | `upgradeRpgTeamTechnology` | `callbackUpgradeRpgTeamTechnology` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6324` |
| 833 | `upgradeRpgUltTalentLv` | `callbackUpgradeRpgUltTalentLv` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5559` |
| 834 | `upgradeSkinCoordinationLv` | `callbackUpgradeSkinCoordination` | 3 | SkinPropertyBean | 1 | `lobbyNet/logic/ServersLogic.as:11707` |
| 835 | `upgradeStarProjectBox` | `callBackUpdateStarProjectBox` | 1 | StarProjectUserDataBean | 1 | `lobbyNet/logic/ServersLogic.as:10740` |
| 836 | `upgradeTalent` | `callbackUpgradeTalent` | 0 | - | 1 | `acg/lobbyNet/logic/AcgServersLogic.as:78` |
| 837 | `upgradeTerritorialTechnology` | `callbackUpgradeTerritorialTechnology` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:12136` |
| 838 | `upgradeUnequippedWeaponSlot` | `callbackUpgradeUnequippedWeaponSlot` | 5 | WeaponSlotReformBean | 1 | `lobbyNet/logic/ServersLogic.as:2449` |
| 839 | `upgradeWeaponCalibration` | `callbackUpgradeWeaponCalibration` | 3 | ClientWeaponCalibrationBean | 1 | `lobbyNet/logic/ServersLogic.as:13340` |
| 840 | `upgradeWeaponGroupSkinLv` | `callbackUpgradeWeaponGroupSkinLv` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:11773` |
| 841 | `upgradeWeaponSlot` | `callbackUpgradeWeaponSlot` | 2 | WeaponSlotBean | 1 | `lobbyNet/logic/ServersLogic.as:2430` |
| 842 | `upgradeWingSlot` | `callbackUpgradeWingSlot` | 2 | WingPropertyUserBean | 1 | `lobbyNet/logic/ServersLogic.as:11958` |
| 843 | `upgradeWingSlotProperty` | `callbackUpgradeWingSlotProperty` | 2 | WingPropertyUserBean | 1 | `lobbyNet/logic/ServersLogic.as:11977` |
| 844 | `uploadDyeingWork` | `callbackUploadDyeingWork` | 2 | DyeingWorkUploadResult | 1 | `lobbyNet/logic/ServersLogic.as:14126` |
| 845 | `useAbyssGainItem` | `callbackUseAbyssGainItem` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:5932` |
| 846 | `useAbyssItem` | `callbackUseAbyssItem` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5910` |
| 847 | `useFestivalExtraItem` | `callbackUseFestivalExtraItem` | 3 | - | 1 | `lobbyNet/channelLogic/FestivalBattleChannelLogic.as:53` |
| 848 | `useKingBlessItem` | `callbackUseKingBlessItem` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:5809` |
| 849 | `useOptionalPack` | `callbackUseOptionalPack` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:4799` |
| 850 | `useRpgMixture` | `callbackUseRpgMixture` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:13274` |
| 851 | `useRpgRandomChallengeItem` | `callbackUseRpgRandomChallengeItem` | 3 | ClientRandomChallengeBean | 1 | `lobbyNet/logic/ServersLogic.as:13075` |
| 852 | `useScuffleSuperDesperateFightFlag` | `callbackScuffleSuperDesperateFightFlag` | 2 | UserKingScuffleBean | 1 | `lobbyNet/logic/ServersLogic.as:5664` |
| 853 | `useSkinEffect` | `callbackUseSkinEffect` | 3 | SkinPropertyBean | 1 | `lobbyNet/logic/ServersLogic.as:11735` |
| 854 | `useStorageChipPack` | `callBackUseStorageChipPack` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:7735` |
| 855 | `useStoragePack` | `onUseStoragePack` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:2292` |
| 856 | `useStorageRunePack` | `callbackUseStorageRunePack` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11091` |
| 857 | `usedItemToRelic` | `callbackUsedItemToRelic` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:5726` |
| 858 | `validateSecPsw` | `callbackValidateSecPsw` | 3 | - | 1 | `lobbyNet/logic/ServersLogic.as:3515` |
| 859 | `variantSkillUpgrade` | `callBackVariantSkillUpgrade` | 2 | VariantSkillBean | 1 | `lobbyNet/logic/ServersLogic.as:10132` |
| 860 | `vipReturnWeaponGold` | `callBackReturnWeaponGold` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:6571` |
| 861 | `voteRaceEntertainmentWeapon` | `callbackVoteRaceEntertainmentWeapon` | 2 | - | 1 | `lobbyNet/logic/ServersLogic.as:11830` |
| 862 | `voteTeamImpeach` | `callbackVoteTeamImpeach` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:6035` |
| 863 | `voteVideo` | `callbackVoteVideo` | 2 | VideoDataLite | 1 | `lobbyNet/logic/ServersLogic.as:11484` |
| 864 | `voteWeapon` | `callbackVoteWeapon` | 3 | WeaponForbiddenUserBean | 1 | `lobbyNet/logic/ServersLogic.as:11815` |
| 865 | `watchGame` | `callbackWatchGame` | 1 | - | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:121` |
| 866 | `weaponUnLockClick` | `callBackWeaponUnLock` | 1 | - | 1 | `lobbyNet/logic/ServersLogic.as:2366` |
| 867 | `wingExchangeStorage` | `callbackWingExchangeStorage` | 4 | - | 1 | `lobbyNet/logic/ServersLogic.as:6729` |
| 868 | `withdrawScufflePeak` | `callbackWithdrawScufflePeak` | 1 | - | 1 | `lobbyNet/channelLogic/PeakChannelLogic.as:154` |

## 3. 修复优先级建议

1. **先做调用点多且直接决定仓库/背包可见性的 B 类**（表格前 10–20 条）。
2. 其余 B 类按「玩家是否会主动点开」排，不按字典序——很多是活动系统，永不复用。
3. C 类不动。若日后要清理，删条目而不是补实现。

## 4. 完整分级表（附录）

<details><summary>展开全部 949 条</summary>

| 请求 | 回调 | 分级 | 调用点 |
|---|---|---|---|
| `abandonScratchOff` | `callbackAbandonScratchOff` | B | 1 |
| `abandonSlotMachine` | `callbackAbandonSlotMachine` | C | 0 |
| `acgBagTakeOff` | `callbackAcgBagTakeOff` | B | 1 |
| `acgBagTakeOn` | `callbackAcgBagTakeOn` | B | 1 |
| `acquireBountyArenaReward` | `callbackAcquireBountyArenaReward` | B | 1 |
| `acquireCatalogReward` | `callbackAcquireCatalogReward` | B | 1 |
| `acquireDecodePack` | `callbackAcquireDecodePack` | B | 1 |
| `acquireExpeditionReward` | `callbackAcquireExpeditionReward` | B | 1 |
| `acquireFestivalCycleReward` | `callbackAcquireFestivalCycleReward` | C | 0 |
| `acquireJumpReward` | `callbackJumpRewardPack` | B | 1 |
| `acquirePalResource` | `callbackAcquirePalResource` | B | 1 |
| `acquirePeakLikeReward` | `callbackAcquirePeakLikeReward` | B | 1 |
| `acquireRaceSeasonReward` | `callbackRaceSeasonReward` | B | 1 |
| `acquireRepelPack` | `callbackAcquireRepelPack` | B | 1 |
| `acquireReputationReward` | `callbackAcquireReputationReward` | B | 1 |
| `acquireRpgTeamDonatePack` | `callbackRpgTeamDonatePack` | B | 1 |
| `acquireScratchOffCellReward` | `callbackAcquireScratchOffCellReward` | B | 1 |
| `acquireSeasonPassReward` | `callbackAcquireSeasonPassReward` | B | 1 |
| `acquireTimeSafeBoxPack` | `callbackAcquireTimeSafeBoxPack` | B | 1 |
| `acquireWarLetterReward` | `callbackAcquireWarLetterReward` | B | 1 |
| `acquireWishTeamPack` | `callbackAcquireWishTeamPack` | B | 1 |
| `activateDecennialWrap` | `callbackActivateDecennialWrap` | B | 1 |
| `activeFavorite` | `callbackActiveFavorite` | B | 1 |
| `activeRpgGodWay` | `callbackActiveRpgGodWay` | B | 1 |
| `activeRpgLevelTelnet` | `callbackActiveRpgLevelTelnet` | B | 1 |
| `activeWarLetter` | `callbackActiveWarLetter` | B | 1 |
| `addBlack` | `onAddBlack` | B | 2 |
| `addClickPosition` | `callbackAddClientPosition` | B | 1 |
| `addEnvoyToLingFu` | `callbackAddEnvoyToLingFu` | B | 1 |
| `addEnvoysToLingFu` | `callbackAddEnvoysToLingFu` | C | 0 |
| `addRpgWeaponBattleExpByItem` | `callbackAddRpgWeaponBattleExpByItem` | B | 1 |
| `allowJoinRpgTeam` | `callbackAllowJoinRpgTeam` | B | 1 |
| `allowJoinTeam` | `onAllowJoinTeam` | B | 1 |
| `applyChatWindowId` | `callbackApplyChatWindowId` | B | 1 |
| `applyDyeingFormula` | `callbackApplyDyeingFormula` | B | 1 |
| `applyJoinRpgTeam` | `callbackApplyJoinRpgTeam` | B | 1 |
| `applyJoinTeam` | `onApplyJoinTeam` | B | 1 |
| `applyMonitor` | `callbackApplyMonitor` | B | 1 |
| `applyPalJobFlag` | `callbackApplyPalJobFlag` | B | 1 |
| `assistantSwitchAbility` | `callbackAssistantSwitchAbility` | B | 1 |
| `assistantSwitchAllAbilities` | `callbackAssistantSwitchAllAbilities` | B | 1 |
| `automaticEquip` | `callbackAutomaticEquip` | B | 1 |
| `automaticEquipSave` | `callbackAutomaticEquipSave` | B | 1 |
| `automaticSelectDefault` | `callbackAutomaticSelectDefault` | B | 1 |
| `avatarChanged` | `callBackAvatarChanged` | B | 1 |
| `avatarTalentAwake` | `callBackAvatarTalentAwake` | B | 1 |
| `avatarUnlockSuit` | `callbackAvatarUnlockSuit` | B | 1 |
| `banPeakWeaponGroup` | `callbackBanPeakWeaponGroup` | B | 1 |
| `banPushRecommandFriend` | `onPushRecommandFriend` | B | 1 |
| `bargainRealmExchangeItem` | `callbackBargainRealmExchangeItem` | B | 1 |
| `batchActiveFavorite` | `callbackBatchActiveFavorite` | B | 1 |
| `batchCompleteRpgTask` | `callbackBatchCompleteRpgTask` | B | 1 |
| `batchDecompositeRing` | `callbackBatchDecompositeRing` | B | 1 |
| `batchGetAvatarWornRank` | `callbackBatchGetAvatarWornRank` | B | 1 |
| `batchInviteJoinRaceRoom` | `onBatchInviteJoinRaceRoom` | B | 1 |
| `batchInviteJoinRoom` | `onBatchInviteJoinRoom` | B | 1 |
| `batchLockRing` | `callbackBatchLockRing` | B | 1 |
| `batchReceiveTask` | `callBackBatchReceiveTask` | B | 1 |
| `bindApplet` | `callbackBindApplet` | B | 1 |
| `bindAvatarEquipment` | `callbackBindAvatarEquipment` | B | 1 |
| `bindPhoneNumber` | `callbackBindPhoneNumber` | B | 1 |
| `buy` | `callBackBuy` | B | 1 |
| `buyChip` | `onBuyChip` | B | 1 |
| `buyFestivalMarketRefreshNum` | `callbackBuyFestivalMarketRefreshNum` | C | 0 |
| `buyFestivalMarketSelfSaleNum` | `callbackBuyFestivalMarketSelfSaleNum` | C | 0 |
| `buyMore` | `callBackBuyMore` | B | 1 |
| `buyMysteryShop` | `callbackBuyMysteryShop` | B | 1 |
| `buyRealmExchangeItem` | `callbackBuyRealmExchangeItem` | B | 1 |
| `buyRpgShop` | `onBuyRpgShop` | B | 1 |
| `buyTeamLeagueReviveCoin` | `callbackBuyTeamLeagueReviveCoin` | B | 1 |
| `buyWithDiscount` | `onBuyWithEcard` | B | 1 |
| `buyWithEcard` | `onBuyWithEcard` | B | 1 |
| `calibrateSlaveProperty` | `callbackCalibrateSlaveProperty` | B | 1 |
| `calibrateWeaponPrecision` | `callbackCalibrateWeaponPrecision` | B | 1 |
| `cancelBountyTask` | `callBackCancelBountyTask` | B | 1 |
| `cancelBuyLegionGoods` | `callbackCancelBuyLegionGoods` | B | 1 |
| `cancelResetSecPsw` | `callbackCancelResetSecPsw` | B | 1 |
| `capturePalSLG` | `callbackCapturePalSLG` | B | 1 |
| `changeAvatarModel` | `callbackChangeAvatarModel` | B | 1 |
| `changeChannelCamp` | `callbackChangeChannelCamp` | B | 1 |
| `changeDangerFactor` | `callbackChangeDangerFactor` | B | 1 |
| `changeDesperateFightFlag` | `callbackChangeDesperateFightFlag` | B | 3 |
| `changeExercisesChannelTeamNeedFill` | `callbackChangeExercisesChannelTeamNeedFill` | B | 1 |
| `changeFestivalChannelTeam` | `callbackChangeFestivalChannelTeam` | B | 1 |
| `changeFestivalDangerFactor` | `callbackChangeFestivalDangerFactor` | B | 1 |
| `changeGameToObserver` | `callBackChangeGameToObserver` | B | 2 |
| `changeMedalStatus` | `callbackChangeMedalStatus` | A | 1 |
| `changeMultipleRpgTeam` | `callbackChangeRpgTeam` | B | 1 |
| `changeOneOnOneCard` | `callbackChangeOneOnOneCard` | B | 1 |
| `changeOpenAvatarReplace` | `callbackChangeOpenAvatarReplace` | B | 1 |
| `changeP3Hero` | `callbackChangeP3Hero` | B | 1 |
| `changePalSignupStatus` | `callbackChangePalSignupStatus` | C | 0 |
| `changePhoneCheckSecPsw` | `callbackChangePhoneCheckSecPsw` | B | 1 |
| `changePinnacleInfinityLevel` | `callbackChangePinnacleInfinityLevel` | B | 1 |
| `changePlayerName` | `onChangePlayerName` | A | 1 |
| `changePosition` | `onChangePosition` | B | 1 |
| `changePrepareStatus` | `callbackChannelUserChangePrepareStatus` | B | 1 |
| `changePresetTemplate` | `callbackChangePresetTemplate` | B | 1 |
| `changeReadFlag` | `onChangeReadFlag` | B | 1 |
| `changeRpgCamp` | `callbackChangeRpgCamp` | B | 1 |
| `changeRpgPosition` | `onChangeRpgPosition` | B | 1 |
| `changeRpgTeam` | `callbackChangeRpgTeam` | B | 1 |
| `changeRpgTeamDeclaration` | `callbackChangeRpgTeamDeclaration` | B | 1 |
| `changeRpgTeamDisableUseTeamSignup` | `callbackDisableUseTeamSignup` | C | 0 |
| `changeRpgTeamNotice` | `callbackChangeRpgTeamNotice` | B | 1 |
| `changeRuneBagName` | `callbackChangeRuneBagName` | B | 1 |
| `changeScuffleEquipConfig` | `callbackChangeScuffleEquipConfig` | B | 1 |
| `changeSecPsw` | `callbackChangePhoneCheckSecPsw` | B | 1 |
| `changeStorageStoreMark` | `callbackChangeStorageStoreMark` | B | 1 |
| `changeTeam` | `callBackChangeTeam` | B | 2 |
| `changeTeamDeclaration` | `onChangeTeamDeclaration` | B | 1 |
| `changeTeamName` | `onChangeTeamName` | B | 1 |
| `changeTeamNotice` | `onChangeTeamNotice` | B | 1 |
| `changeTeamPassword` | `callbackChangeTeamPassword` | B | 1 |
| `changeTeamleader` | `onChangeTeamleader` | B | 1 |
| `changeTeamleaderResult` | `onChangeTeamleader` | B | 1 |
| `changeTrialTowerSelected` | `callbackTrialTowerChangeSelected` | B | 1 |
| `changeUserSetting` | `onChangeUserSetting` | B | 1 |
| `changeUserStayStep` | `onChangeUserSetting` | B | 1 |
| `changeWeaponModel` | `callbackChangeWeaponModel` | B | 1 |
| `changeZoomAbility` | `callbackChangeZoomAbility` | B | 1 |
| `changeZoomChannelTeam` | `callbackChangeZoomChannelTeam` | B | 1 |
| `changeZoomDanger` | `callbackChangeZoomDanger` | B | 1 |
| `channelAvaliable` | `onChannelAvaliable` | A | 1 |
| `chargeFestivalCycleBuf` | `callbackChargeFestivalCycleBuf` | C | 0 |
| `checkActivityDisplayConditions` | `callbackCheckActivityDisplayConditions` | B | 1 |
| `checkActivityLogicConditions` | `callbackCheckActivityLogicConditions` | B | 1 |
| `checkAndActiveMedal` | `callbackCheckAndActiveMedal` | A | 1 |
| `checkPlayerName` | `callBackCheckPlayerName` | A | 1 |
| `checkTeamLeagueMember` | `callbackCheckTeamLeagueMember` | B | 1 |
| `checkTeamName` | `onCheckTeamName` | B | 1 |
| `choiceOptionalPackItem` | `callbackChoiceOptionalPackItem` | B | 1 |
| `choiceRaceTypeAndLevel` | `callbackChoiceRaceTypeAndLevel` | B | 1 |
| `claimAccomplishmentReward` | `onClaimAccomplishmentReward` | B | 1 |
| `claimCycleTaskActiveReward` | `callbackClaimCycleTaskActiveReward` | B | 1 |
| `claimFestivalMarketCommission` | `callbackClaimFestivalMarketCommission` | C | 0 |
| `claimFestivalSpanReward` | `callbackClaimFestivalSpanReward` | B | 1 |
| `claimGlobalAchvMedalReward` | `callbackClaimGlobalAchvMedalReward` | B | 1 |
| `claimIntelligenceItems` | `callbackClaimIntelligenceItems` | B | 1 |
| `claimMonthlyCardPack` | `callbackClaimMonthlyCardPack` | C | 0 |
| `claimNewbieTaskReward` | `callbackClaimNewbieTaskReward` | B | 1 |
| `claimPalAllianceRedPacket` | `callbackClaimPalAllianceRedPacket` | C | 0 |
| `claimZoomReward` | `callbackClaimZoomReward` | B | 1 |
| `clearRpgArenaData` | `callbackClearRpgArenaData` | B | 1 |
| `clearRpgInfinity` | `callbackResetRpgInfinity` | B | 1 |
| `clickCreateTeamButton` | `onClickCreateTeamButton` | B | 1 |
| `closeDecoration` | `onCloseDecoration` | B | 1 |
| `collectDyeingWork` | `callbackCollectDyeingWork` | B | 1 |
| `completeDelayRaid` | `callbackCompleteDelayRaid` | B | 1 |
| `completeSeasonPassTask` | `callbackCompleteRpgTask` | B | 1 |
| `completeTask` | `callbackCompleteRpgTask` | B | 1 |
| `composeAvatarEquipment` | `callbackComposeAvatarEquipment` | B | 1 |
| `composeEnvoySoul` | `callbackComposeEnvoySoul` | B | 1 |
| `confirmRefineResult` | `callbackConfirmRefineResult` | B | 1 |
| `costGold2StartSixthBattle` | `callbackCostGold2StartSixthBattle` | B | 1 |
| `createBattleMessage` | `callBackAddBattleMessage` | B | 1 |
| `createBiochemicalChannelTeam` | `callbackCreateChannelTeam` | B | 1 |
| `createChannelTeam` | `callbackCreateChannelTeam` | B | 1 |
| `createChannelTeamWithDifficultyId` | `callbackCreateChannelTeam` | B | 2 |
| `createCharacter` | `callBackCreateCharacter` | B | 1 |
| `createExercisesChannelTeam` | `callbackGetExercisesChannelTeamList` | B | 1 |
| `createFestivalChannelTeam` | `callbackChangeFestivalChannelTeam` | B | 1 |
| `createMultipleRpgTeam` | `callbackCreateRpgTeam` | B | 1 |
| `createOrJoinChannelTeam` | `callbackCreateOrJoinChannelTeam` | B | 1 |
| `createRaceRoom` | `callbackCreateRaceRoom` | B | 1 |
| `createRestrictionRoom` | `callbackJoinRestrictionRoom` | B | 1 |
| `createRoom` | `callbackCreateRpgRoom` | B | 2 |
| `createRpgRestrictionRoom` | `callbackCreateRpgRoom` | B | 1 |
| `createRpgRoom` | `callbackCreateRpgRoom` | B | 1 |
| `createRpgTeam` | `callbackCreateRpgTeam` | B | 1 |
| `createScuffleChannelTeam` | `callbackCreateChannelTeam` | B | 2 |
| `createTeam` | `onCreateTeam` | B | 1 |
| `createZoomChannelTeam` | `callbackChangeZoomChannelTeam` | B | 1 |
| `decodeIntelligenceItems` | `callbackDecodeIntelligenceItems` | B | 1 |
| `decomposeEnvoySoul` | `callbackDecomposeEnvoySoul` | B | 1 |
| `decomposeRunes` | `callbackDecomposeRunes` | B | 1 |
| `defenseLineCostType` | `callbackDefenseLineCostType` | B | 1 |
| `deleteAllExpiredStorageItem` | `onDeleteStorage` | B | 1 |
| `deleteBlack` | `onDeleteBlack` | B | 1 |
| `deleteDivineMark` | `callbackDeleteDivineMark` | B | 1 |
| `deleteExpiredStorageItem` | `onDeleteStorage` | B | 1 |
| `deleteFriend` | `onDeleteFriend` | B | 1 |
| `deleteMail` | `onDeleteMail` | B | 1 |
| `deleteStorage` | `onDeleteStorage` | B | 1 |
| `delistHomelandHallRentItem` | `callbackDelistHomelandHallRentItem` | B | 1 |
| `depositTimeSafeBox` | `callbackDepositTimeSafeBox` | B | 1 |
| `disbandPalManpower` | `callbackDisbandPalManpower` | B | 1 |
| `disbandTeam` | `onDisbandTeam` | B | 1 |
| `doRebirth` | `callbackDoRebirth` | B | 1 |
| `donateIntelligenceItems` | `callbackDonateIntelligenceItems` | B | 1 |
| `doubleBattleExpAndGp` | `onDoubleBattleExpAndGp` | B | 1 |
| `douwaBuyVipStatus` | `douwaOnBuyVip` | B | 1 |
| `douwaGetVipStatus` | `douwaOnGetVipStatus` | B | 1 |
| `douwaUseVipPoint` | `douwaOnUsePoint` | B | 1 |
| `dragoonEquip` | `callbackDragoonEquip` | B | 1 |
| `dragoonEquipChip` | `callbackDragoonEquipChip` | B | 1 |
| `dragoonGetEquipInfo` | `callbackDragoonGetEquipInfo` | B | 1 |
| `dragoonIntoBattle` | `callbackDragoonIntoBattle` | B | 1 |
| `dragoonResolve` | `callbackDragoonResolve` | B | 1 |
| `dragoonSynthesis` | `callbackDragoonSynthesis` | B | 1 |
| `dragoonTakeoff` | `callbackDragoonTakeoff` | B | 1 |
| `dragoonTakeoffChip` | `callbackDragoonTakeoffChip` | B | 1 |
| `dragoonUnlockBag` | `callbackDragoonUnlockBag` | B | 1 |
| `drawStarPray` | `callbackDrawStarPray` | C | 0 |
| `dropStarProjectBox` | `callBackUpdateStarProjectBox` | B | 1 |
| `elevateRuneStorageLimit` | `callbackElevateRuneStorageLimit` | B | 1 |
| `enableSlotMachineBuffers` | `callbackEnableSlotMachineBuffers` | C | 0 |
| `enterChannel` | `callbackEnterChannelServer` | A | 2 |
| `enterChannelServer` | `callbackEnterChannelServer` | B | 1 |
| `enterChatServer` | `callbackEnterChatServer` | B | 1 |
| `enterHomeland` | `callbackEnterHomeland` | B | 1 |
| `enterPalRoom` | `callbackEnterPalRoom` | B | 1 |
| `enterPeakCompetitionGroup` | `callbackEnterPeakCompetitionGroup` | B | 1 |
| `enterQuiz` | `onEnterQuiz` | B | 1 |
| `enterRace` | `callbackEnterRace` | B | 1 |
| `enterRpgServer` | `callbackEnterRpgServerSuccess` | B | 1 |
| `equip` | `onEquip` | A | 1 |
| `equipAvatarEquipment` | `callbackEquipAvatarEquipment` | B | 1 |
| `equipBattlePet` | `onEquipBattlePet` | B | 1 |
| `equipChip` | `onEquipChip` | B | 1 |
| `equipDecoration` | `onEquipDecoration` | B | 1 |
| `equipDivineMark` | `callbackEquipDivineMark` | B | 1 |
| `equipEmoji` | `callbackEquipEmoji` | B | 1 |
| `equipEnvoyAppearance` | `callbackEquipEnvoyAppearance` | C | 0 |
| `equipEnvoySkin` | `callbackEquipEnvoySkin` | B | 1 |
| `equipGroupRootAvatar` | `callBackEquipRootAvatar` | B | 1 |
| `equipHeroAvatar` | `callbackEquipHeroAvatar` | B | 1 |
| `equipModuleItem` | `callbackEquipModuleItem` | B | 1 |
| `equipParentAvatar` | `callBackEquipParentAvatar` | B | 1 |
| `equipPersonalise` | `callbackEquipPersonalise` | A | 1 |
| `equipPropertyWing` | `callbackEquipPropertyWing` | B | 1 |
| `equipRootAvatar` | `callBackEquipRootAvatar` | A | 1 |
| `equipRootAvatarInfo` | `callBackEquipRootAvatarInfo` | A | 1 |
| `equipRootAvatarSound` | `callBackEquipRootAvatarSound` | B | 1 |
| `equipRpgXpSkill` | `callbackEquipRpgXpSkill` | B | 1 |
| `equipRune` | `callbackEquipRune` | B | 1 |
| `equipTacticalWeapon` | `callbackEquipTacticalWeapon` | A | 1 |
| `equipUltimateAvatar` | `callbackEquipUltimateAvatar` | B | 1 |
| `equipUltimateAvatarConfig` | `callbackEquipUltimateAvatarConfig` | B | 1 |
| `equipWeaponSlot` | `callBackEquipWeaponSlot` | B | 1 |
| `etherApplyEthereumActivity` | `callbackEtherApplyEthereumActivity` | B | 1 |
| `etherCancelBuyOrder` | `callbackEtherCancelBuyOrder` | B | 1 |
| `etherCancelSellOrder` | `callbackEtherCancelSellOrder` | B | 1 |
| `etherFetchEthereumActivity` | `callbackEtherFetchEthereumActivity` | B | 1 |
| `etherFetchTransactionItem` | `callbackEtherFetchTransactionItem` | B | 1 |
| `etherGetEthereumActivityInfo` | `callbackEtherGetEthereumActivityInfo` | B | 1 |
| `etherGetMarketOverviewInfo` | `callbackEtherGetMarketOverviewInfo` | B | 1 |
| `etherGetMarketPriceHistory` | `callbackEtherGetMarketPriceHistory` | B | 1 |
| `etherGetMarketSellOrderByShelf` | `callbackEtherGetMarketSellOrderByShelfV2` | B | 1 |
| `etherGetUserBuyOrderInfo` | `callbackEtherGetUserBuyOrderInfo` | B | 1 |
| `etherGetUserSellOrderInfo` | `callbackEtherGetUserSellOrderInfo` | B | 1 |
| `etherGetUserTransactionRecordInfo` | `callbackEtherGetUserTransactionRecordInfo` | B | 1 |
| `etherOpenEthereumActivityHistoryHongBao` | `callbackEtherOpenEthereumActivityHistoryHongBao` | B | 1 |
| `etherShowItemDetailInfo` | `callbackEtherShowItemDetailInfo` | B | 1 |
| `etherShowMarketInfo` | `callbackEtherShowMarketInfo` | B | 1 |
| `etherShowShelfPriceAndAmount` | `callbackEtherShowShelfPriceAndAmount` | B | 1 |
| `etherSubmitEtherBuyOrder` | `callbackEtherSubmitBuyOrder` | B | 1 |
| `etherSubmitPriorityBuyOrder` | `callbackEtherSubmitPriorityBuyOrder` | B | 1 |
| `etherSubmitSellOrder` | `callbackEtherSubmitSellOrder` | B | 1 |
| `etherUseGoldExchangeEther` | `callbackEtherUseGoldExchangeEther` | B | 1 |
| `exchangePack` | `callbackExchangePack` | B | 1 |
| `exchangeSilver` | `onExchangeSilver` | B | 1 |
| `exchangeStorageItem` | `onExchangeStorageItem` | B | 1 |
| `expediteTask` | `callbackExpediteTask` | B | 1 |
| `extendTeam` | `onExtendTeam` | B | 1 |
| `extractWingSlotProperty` | `callbackExtractWingSlotProperty` | B | 1 |
| `fastJoinRoom` | `callBackJoinRoom` | B | 1 |
| `fcm` | `callbackFcm` | B | 1 |
| `fetchModuleSysOutput` | `callbackFetchModuleSysOutput` | B | 1 |
| `fetchRougeAchievementReward` | `callbackFetchRougeAchievementReward` | C | 0 |
| `fetchRpgAdventureReward` | `callbackFetchRpgAdventureReward` | B | 1 |
| `fetchStarProjectBox` | `callBackFetchStarProjectBox` | B | 1 |
| `fetchTemporaryStorage` | `onDeleteTemporaryStorage` | B | 1 |
| `fetchTerritorialTeamReward` | `callbackFetchTerritorialTeamReward` | B | 1 |
| `firstOpenTitanium` | `callbackFirstOpenTitanium` | B | 1 |
| `fix` | `onFix` | B | 1 |
| `fixTerritorialContention` | `callbackFixTerritorialContention` | B | 1 |
| `flipRpgMixture` | `callbackUseRpgMixture` | B | 1 |
| `followUser` | `onFollowUser` | B | 1 |
| `forbiddenPeakBag` | `callbackForbiddenPeakBag` | B | 1 |
| `forgeEnvoySoul` | `callbackForgeEnvoySoul` | B | 1 |
| `forgingExchangeStorage` | `callbackForgingExchangeStorage` | B | 1 |
| `furnaceUpgrade` | `callbackFurnaceUpgrade` | B | 1 |
| `gameBind` | `callbackGameBindStatus` | B | 1 |
| `gameBindBigReward` | `callbackGameBindReward` | B | 1 |
| `gameBindDailyReward` | `callbackGameBindReward` | B | 1 |
| `gameBindInfo` | `callbackGameBindInfo` | B | 1 |
| `getAbattoirFirstPassPlayers` | `callbackGetAbattoirFirstPassPlayers` | B | 1 |
| `getAbattoirUserInfo` | `callbackGetAbattoirUserInfo` | B | 1 |
| `getAbyssTemperature` | `callbackGetAbyssTemperature` | B | 1 |
| `getAccomplishment` | `callbackGetAccomplishment` | B | 1 |
| `getAcgnUserInfo` | `onGetTeamUserInfo` | B | 1 |
| `getActivityDrawTasks` | `callbackGetActivityDrawTasks` | B | 1 |
| `getActivityExtraData` | `callbackGetActivityExtraData` | B | 1 |
| `getActivityInfoNew` | `onGetActivityInfoNew` | B | 1 |
| `getActivityInfoNewWithType` | `callbackGetActivityInfoNewWithType` | B | 1 |
| `getActivityLevelInfo` | `callbackGetActivityLevelInfo` | B | 1 |
| `getActivityNewYearInfo` | `callbackGetActivityNewYearInfo` | B | 1 |
| `getAllAbyssReport` | `callbackGetAbyssReport` | B | 1 |
| `getAllAdventureLogs` | `callbackGetAllAdventureLogs` | B | 1 |
| `getAllArenaRebirthOverview` | `callbackGetAllArenaRebirthOverview` | B | 1 |
| `getAllRpgExpressionValues` | `onGetAllRpgExpressionValues` | B | 1 |
| `getAllianceScoreLastRank` | `callbackGetAllianceScoreLastRank` | B | 1 |
| `getAnnounceList` | `callBackGetAnnounceList` | B | 1 |
| `getApplyJoinRpgTeamList` | `callbackGetApplyJoinRpgTeamList` | B | 1 |
| `getApplyJoinTeamList` | `onGetApplyJoinTeamList` | B | 1 |
| `getApplyList` | `onGetApplyList` | B | 1 |
| `getArrearsDebufUserBean` | `callbackGetArrearsDebufUserBean` | B | 1 |
| `getAssistantUserInfo` | `callbackGetAssistantUserInfo` | B | 1 |
| `getAutomaticEquipInfo` | `callbackGetAutomaticEquiponInfo` | B | 1 |
| `getAvailableActivityList` | `onGetAvailableActivityList` | B | 1 |
| `getAvailableActivityListWithType` | `callbackGetAvailableActivityListWithType` | B | 1 |
| `getAvailableRentFriends` | `callbackGetAvailableRentFriends` | B | 1 |
| `getAvatarAcgRelationshipUnlockList` | `callbackGetAvatarAcgRelationshipUnlockList` | B | 1 |
| `getAvatarDyeing` | `callbackGetAvatarDyeing` | B | 1 |
| `getAvatarLimitInfo` | `callbackGetAvatarLimitInfo` | A | 1 |
| `getAvatarTalentInfo` | `callBackGetAvatarTalentInfo` | B | 1 |
| `getAvatarWornRank` | `callbackGetAvatarWornRank` | B | 1 |
| `getBigData` | `onGetBigData` | B | 1 |
| `getBindAppletInfo` | `callbackGetAppletInfo` | B | 1 |
| `getBioChemDefenseLineInfo` | `callbackGetBioChemDefenseLineInfo` | B | 1 |
| `getBlindInfo` | `callbackGetBlindInfo` | B | 1 |
| `getBlueVipPack` | `onGetBlueVipPack` | B | 1 |
| `getBountyHallInfo` | `callBackGetBountyHallInfo` | B | 1 |
| `getBountyHunterInfo` | `callBackGetBountyHunterInfo` | B | 1 |
| `getBountyTask` | `callBackGetBountyTask` | B | 1 |
| `getCareerTask` | `callbackGetCareerTask` | B | 1 |
| `getChallengeAward` | `callbackGetChallengeAward` | B | 1 |
| `getChallengeStatus` | `onGetChallengeStatus` | B | 1 |
| `getChannelRoomList` | `callbackGetChannelRoomList` | B | 1 |
| `getChannelServerInfoByType` | `callbackGetChannelServerInfo` | B | 1 |
| `getCharMedalList` | `callbackGetCharMedalList` | A | 1 |
| `getCharNotinTeam` | `onGetCharNotinTeam` | B | 1 |
| `getCharNotinTeamByName` | `onGetCharNotinTeam` | B | 1 |
| `getCharacterBoxInfo` | `callbackGetCharacterBoxInfo` | B | 1 |
| `getCharacterBoxReward` | `callbackGetCharacterBoxReward` | B | 1 |
| `getCheatSystemInfo` | `callbackGetCheatSystemInfo` | B | 1 |
| `getClientRogueUserBean` | `callbackGetClientRogueUserBean` | C | 0 |
| `getClientRpgUserInfo` | `callbackGetClientRpgUserInfo` | B | 1 |
| `getClientSignInBean` | `onGetClientSignInBean` | B | 1 |
| `getCommonAbilities` | `callbackGetCommonAbilities` | B | 1 |
| `getCommonCharInfo` | `callBackGetCommonCharInfo` | B | 1 |
| `getCustomAvailableActivityList` | `onGetCustomAvailableActivityList` | B | 1 |
| `getCycleTask` | `callbackGetCycleTask` | B | 1 |
| `getDailyTaskReward` | `callbackDailyTaskReward` | B | 1 |
| `getDangerFactor` | `callbackGetDangerFactor` | B | 1 |
| `getDecennialUserBean` | `callbackGetDecennialUserBean` | B | 1 |
| `getDefenseLineWeaponEquipInfo` | `callbackGetDefenseLineWeaponEquipInfo` | B | 1 |
| `getDragoonChipBeanInfo` | `callBackDragoonChipBeanInfo` | B | 1 |
| `getDragoonChipBreak` | `callBackGetDragoonChipBreak` | B | 1 |
| `getDragoonChipDecompose` | `callBackGetDragoonChipDecompose` | B | 1 |
| `getDragoonChipRestructure` | `callBackDragoonChipRestructure` | B | 1 |
| `getDyeingWorkList` | `callbackGetDyeingWorkList` | B | 1 |
| `getEmojiMap` | `callbackGetEmojiMap` | B | 1 |
| `getEtherHistoryChangeLog` | `callbackGetEtherHistoryChangeLog` | B | 1 |
| `getEtherMarketLockStorageInfo` | `callbackGetEtherMarketLockStorageInfo` | B | 1 |
| `getExercisesBattleRecords` | `callbackGetExercisesBattleRecords` | B | 1 |
| `getExercisesChannelRoomList` | `callbackGetExercisesChannelTeamList` | B | 1 |
| `getExercisesChannelTeamList` | `callbackGetExercisesChannelTeamList` | B | 1 |
| `getExercisesDanReward` | `callbackGetExercisesDanReward` | B | 1 |
| `getExistForeverWeapon` | `callBackGetExistForeverWeapon` | B | 1 |
| `getExpeditionTaskBeans` | `callbackGetExpeditionTaskBeans` | B | 1 |
| `getFavoriteBean` | `callbackGetFavoriteBean` | B | 1 |
| `getFestivalCycleBuffer` | `callbackGetFestivalCycleBuffer` | C | 0 |
| `getFestivalCycleUserBean` | `callbackGetFestivalCycleUserBean` | C | 0 |
| `getFestivalDelayRaidData` | `callbackGetFestivalDelayRaidData` | B | 1 |
| `getFestivalInfo` | `callbackGetFestivalInfo` | B | 1 |
| `getFestivalMarketOtherStore` | `callbackGetFestivalMarketStore` | C | 0 |
| `getFestivalMarketOwnStore` | `callbackGetFestivalMarketStore` | C | 0 |
| `getFestivalMarketRandomGiftStatus` | `callbackGetFestivalMarketRandomGiftStatus` | C | 0 |
| `getFestivalMarketVisitRecords` | `callbackGetFestivalMarketVisitRecords` | C | 0 |
| `getFestivalPlayerCount` | `callbackGetFestivalPlayerCount` | B | 1 |
| `getFestivalSpell` | `callbackGetFestivalSpell` | B | 1 |
| `getFestivalTask` | `callbackGetFestivalTask` | B | 1 |
| `getFestivalVipBean` | `callbackGetFestivalVipBean` | B | 1 |
| `getForbiddenItemData` | `onGetForbiddenItemData` | B | 1 |
| `getForeverLandPickBeans` | `callbackGetForeverLandPickBeans` | B | 1 |
| `getForeverLandUserBean` | `callbackGetForeverLandUserBean` | B | 1 |
| `getFriendMailList` | `callbackGetFriendMailList` | B | 1 |
| `getFriendReceiveCount` | `callbackGetFriendReceiveCount` | B | 1 |
| `getFriendShip` | `onGetFriendShip` | B | 1 |
| `getFuliSort` | `onGetFuliSort` | B | 1 |
| `getGameActivationRecord` | `callbackGetGameActivationRecord` | B | 1 |
| `getGameBattleProperty` | `callbackGetGameBattleProperty` | B | 1 |
| `getGameChannelServerInfo` | `callbackGetGameChannelServerInfo` | B | 1 |
| `getGameCoolDownInfo` | `callbackGetGameCoolDownInfo` | B | 1 |
| `getGameFlowRecoveryInfo` | `callbackGetGameFlowRecoveryInfo` | B | 1 |
| `getGlobalAchv` | `callbackGetGlobalAchv` | B | 1 |
| `getGlobalAchvData` | `callbackGetGlobalAchvData` | B | 1 |
| `getGlobalRoomChannel` | `callbackGetGlobalRoomChannel` | A | 1 |
| `getHallConfig` | `onGetHallConfig` | A | 1 |
| `getHallServerConfig` | `onGetServerHallConfig` | A | 1 |
| `getHeroAvatarTasks` | `callbackGetHeroAvatarTasks` | B | 1 |
| `getHistoryKingScuffleBattleReport` | `callbackGetHistoryKingScuffleBattleReport` | B | 1 |
| `getHistoryReport` | `callbackGetHistoryReport` | B | 1 |
| `getHomelandBuildData` | `callbackGetHomelandBuildData` | B | 1 |
| `getHomelandHallRentData` | `callbackGetHomelandHallRentData` | B | 1 |
| `getHomelandHallRentLimit` | `callbackGetHomelandHallRentLimit` | B | 1 |
| `getHotRecommend` | `callbackGetHotRecommend` | B | 1 |
| `getIntelligenceClaimInfo` | `callbackGetIntelligenceClaimInfo` | B | 1 |
| `getKingScuffleCharInfo` | `callbackGetKingScuffleCharInfo` | B | 1 |
| `getKingScuffleSeasonInfo` | `callbackGetKingScuffleSeasonInfo` | B | 1 |
| `getKingScuffleSimpleCharInfo` | `callbackGetKingScuffleSimpleCharInfo` | B | 1 |
| `getLastExchangeStorageTimestamp` | `onGetLastExchangeStorageTimestamp` | B | 1 |
| `getLeagueEngineReward` | `callbackGetLeagueEngineReward` | B | 1 |
| `getLegendCastingInfo` | `callbackGetLegendCastingInfo` | B | 1 |
| `getLiveChatRoomInfo` | `onGetLiveChatRoomInfo` | B | 1 |
| `getLostCityInfo` | `callbackGetLostCityInfo` | B | 1 |
| `getLuckyList` | `callBackGetLuckyList` | B | 1 |
| `getLuckyWheelData` | `callbackGetLuckyWheelData` | B | 1 |
| `getMagicArsenalHistoryLog` | `callbackGetMagicArsenalHistoryLog` | B | 1 |
| `getMailGiftById` | `onGetMailGiftById` | B | 1 |
| `getMailList` | `callbackGetMailList` | B | 1 |
| `getMailPackById` | `callbackGetMailPackById` | B | 1 |
| `getMapPathNodeOverview` | `callbackGetMapPathNodeOverview` | B | 1 |
| `getMessageByFriendCid` | `onGetMessageByFriendCid` | B | 1 |
| `getMessagesByWindowId` | `callbackGetMessagesByWindowId` | B | 2 |
| `getModuleSysInfo` | `callbackGetModuleSysInfo` | B | 1 |
| `getMonthTotalSignInReward` | `callbackTotalSignInReward` | B | 1 |
| `getMyNearbyAbyssRank` | `callbackGetMyNearbyAbyssRank` | B | 1 |
| `getMyRankAndTotalCount` | `callbackGetMyRankAndTotalCount` | B | 1 |
| `getMyRankDataInfo` | `callbackGetMyRankDataInfo` | B | 1 |
| `getMyRankNew` | `callbackGetMyRankNew` | A | 1 |
| `getMyRpgRiskInfo` | `callbackMyRpgRiskRank` | B | 1 |
| `getMysteryShopInfo` | `callbackGetMysteryShopInfo` | B | 1 |
| `getNewSignInInfo` | `callbackNewSignInInfo` | B | 1 |
| `getNewWeaponFactoryInfo` | `callBackGetNewWeaponFactoryInfo` | B | 1 |
| `getNewWeaponFactoryItem` | `callBackGetNewWeaponFactoryItem` | B | 1 |
| `getNewbieTaskBean` | `callbackGetNewbieTaskBean` | B | 1 |
| `getOnlineFriend` | `onGetOnlineFriend` | B | 1 |
| `getOnlineTeamMember` | `onGetOnlineTeamMember` | B | 1 |
| `getOtherGlobalAchv` | `callbackGetGlobalAchv` | B | 1 |
| `getOtherGlobalAchvData` | `callbackGetGlobalAchvData` | B | 1 |
| `getOtherReducedRankOverviewInfo` | `callbackGetOtherRankOverviewInfo` | B | 1 |
| `getPalAllianceRedPackets` | `callbackGetPalAllianceRedPackets` | C | 0 |
| `getPalAllianceTeamInfo` | `callbackGetAllianceTeamInfo` | B | 1 |
| `getPalNodeDetail` | `callbackGetPalNodeDetail` | B | 1 |
| `getPalSignupStatus` | `callbackGetPalSignupStatus` | C | 0 |
| `getPalUserOverviewInfo` | `callbackGetPalUserOverviewInfo` | B | 1 |
| `getPatchca` | `callbackGetPatchca` | A | 1 |
| `getPeakBags` | `callbackGetPeakBags` | B | 1 |
| `getPeakCompetitionGroup` | `callbackGetPeakCompetitionGroup` | B | 1 |
| `getPeakGroups` | `callbackGetPeakGroups` | B | 1 |
| `getPeakLikes` | `callbackGetPeakLikes` | B | 1 |
| `getPerfectWeaponList` | `callbackGetPerfectWeaponList` | B | 1 |
| `getPersonalise` | `callbackGetPersonalise` | A | 1 |
| `getPhoneBindInfo` | `callbackGetPhoneBindInfo` | B | 1 |
| `getPinnacleInfinitySeasonInfo` | `callbackGetPinnacleInfinitySeasonInfo` | B | 1 |
| `getPresetTemplateStatus` | `callbackGetPresetTemplate` | B | 1 |
| `getPveAchievement` | `onGetPveAchievement` | B | 1 |
| `getPveAchievementReward` | `onGetPveAchievementReward` | B | 1 |
| `getPveArtifactLuckyRankInfo` | `onGetPveArtifactLuckyRankInfo` | B | 1 |
| `getQQVipPack` | `onGetQQVipPack` | B | 1 |
| `getQuizQuestion` | `onGetQuizQuestion` | B | 1 |
| `getQuizResult` | `onGetQuizResult` | B | 1 |
| `getQuizStatus` | `onGetQuizStatus` | B | 1 |
| `getRaceActiveTasks` | `callbackGetRaceActiveTasks` | B | 1 |
| `getRaceEntertainmentBanGroup` | `callbackGetRaceEntertainmentBanGroup` | B | 1 |
| `getRaceEntertainmentSeasonInfo` | `callbackGetRaceEntertainmentSeasonInfo` | B | 1 |
| `getRaceEntertainmentVoteRank` | `callbackGetRaceEntertainmentVoteRank` | B | 1 |
| `getRaceKingRank` | `callbackGetRaceEntertainmentVoteRank` | B | 1 |
| `getRandomPackInfo` | `onGetRandomPackInfo` | B | 1 |
| `getRandomWeightPackInfo` | `callbackGetRandomWeightPackInfo` | B | 1 |
| `getRankDisplayInfo` | `callbackGetRankDisplayInfo` | B | 1 |
| `getRankItemInfo` | `callbackGetRankItemInfo` | B | 1 |
| `getRankList` | `onGetRankList` | B | 1 |
| `getRankNew` | `callbackGetRankNew` | B | 1 |
| `getRankSliceGroupMap` | `callbackGetRankSliceGroupMap` | B | 1 |
| `getRankUserDisplayInfo` | `callbackGetUserDisplayInfo` | B | 1 |
| `getRealmExchangeBeans` | `callbackGetRealmExchangeBeans` | B | 1 |
| `getRealmExchangeRefund` | `callbackGetRealmExchangeRefund` | B | 1 |
| `getRebirthOverview` | `callbackGetRebirthOverview` | B | 1 |
| `getReceiveRewardInfo` | `callbackGetReceiveRewardInfo` | B | 1 |
| `getReducedRankByPage` | `callbackGetReducedRankByPage` | B | 1 |
| `getReducedRankOverviewInfo` | `callbackGetOtherRankOverviewInfo` | B | 1 |
| `getReputationBean` | `callbackGetReputationBean` | B | 1 |
| `getRogueIllustration` | `callbackGetRogueIllustration` | C | 0 |
| `getRoomChannel` | `callbackGetGlobalRoomChannel` | A | 1 |
| `getRougeAchievementInfo` | `callbackGetRougeAchievementInfo` | C | 0 |
| `getRpgAdventureEvent` | `callbackGetRpgAdventureEvent` | B | 1 |
| `getRpgArenaInfo` | `callBackGetRpgArenaInfo` | B | 1 |
| `getRpgAvatarInfo` | `callbackGetRpgAvatarInfo` | B | 1 |
| `getRpgChannel` | `callbackGetRpgChannel` | B | 1 |
| `getRpgCoreSystemInfo` | `callbackGetRpgCoreSystemInfo` | B | 1 |
| `getRpgDailyTaskInfo` | `callbackRpgDailyTaskInfo` | B | 1 |
| `getRpgDivineMarkBeans` | `callbackGetRpgDivineMarkBeans` | B | 1 |
| `getRpgEndlessShopInfo` | `callbackGetRpgEndlessShopInfo` | B | 1 |
| `getRpgExploreQueueInfo` | `callBackGetRpgExploreQueueInfo` | B | 1 |
| `getRpgExpressionValues` | `onGetRpgExpressionValues` | B | 1 |
| `getRpgMagicArsenalInfo` | `callbackGetMagicArsenalInfo` | B | 1 |
| `getRpgMixture` | `callbackGetRpgMixture` | B | 1 |
| `getRpgNewbieTasks` | `callbackGetRpgNewbieTasks` | B | 1 |
| `getRpgRandomChallengeBean` | `callbackGetRpgRandomChallengeBean` | B | 1 |
| `getRpgReconstructionMap` | `callbackGetRpgReconstructionMap` | B | 1 |
| `getRpgRiskRank` | `callbackGetRpgRiskRank` | B | 1 |
| `getRpgRoomList` | `callbackGetRpgRoomList` | B | 1 |
| `getRpgShopBuyLimit` | `callbackGetRpgShopBuyLimit` | B | 1 |
| `getRpgShopInfo` | `callbackGetRpgShopInfo` | B | 1 |
| `getRpgTaskDataList` | `callbackGetRpgTaskDataList` | B | 1 |
| `getRpgTeamHistoryLog` | `callbackGetRpgTeamHistoryLog` | B | 1 |
| `getRpgTeamInfo` | `callbackGetRpgTeamInfo` | B | 1 |
| `getRpgTeamLeagueWeekData` | `callbackGetRpgTeamLeagueWeekData` | B | 1 |
| `getRpgTeamList` | `callbackGetRpgTeamList` | B | 1 |
| `getRpgWelcomeTasks` | `callbackGetRpgWelcomeTasks` | B | 1 |
| `getRpgZoomUserBean` | `callbackGetRpgZoomUserBean` | B | 1 |
| `getRuneBagTasks` | `callbackGetRuneBagTasks` | B | 1 |
| `getScratchOffUserBean` | `callbackGetScratchOffUserBean` | B | 1 |
| `getScuffleEquipConfig` | `callbackGetScuffleEquipConfig` | B | 1 |
| `getScuffleOneOnOneReport` | `callbackGetScuffleOneOnOneReport` | B | 1 |
| `getSeasonPassInfo` | `callbackGetSeasonPasInfo` | B | 1 |
| `getSecretPrizePackLuckyCount` | `callbackGetSecretPrizePackLuckyCount` | C | 0 |
| `getShopBuyInfo` | `callbackGetShopBuyInfo` | B | 1 |
| `getShopOverviewInfo` | `callbackGetShopOverviewInfo` | B | 1 |
| `getSlotMachineUserBean` | `callbackGetSlotMachineUserBean` | C | 0 |
| `getStarPrayData` | `callbackGetStarPrayData` | C | 0 |
| `getStarProjectInfo` | `callBackGetStarProjectInfo` | B | 1 |
| `getStorageStoreList` | `callbackGetStorageStoreList` | B | 1 |
| `getTeamImpeachInfo` | `callbackGetTeamImpeachInfo` | B | 1 |
| `getTeamInfo` | `onGetTeamInfo` | B | 1 |
| `getTeamLeagueInfo` | `callbackGetTeamLeagueInfo` | B | 1 |
| `getTeamLegionStorage` | `callbackGetTeamLegionStorage` | B | 1 |
| `getTeamLegionTechnology` | `callbackGetTeamLegionTechnology` | B | 1 |
| `getTeamList` | `onGetTeamList` | B | 1 |
| `getTeamListByName` | `onGetTeamList` | B | 1 |
| `getTeamMember` | `onGetTeamMember` | B | 1 |
| `getTeamTreasureBox` | `callbackGetTeamTreasureBox` | B | 1 |
| `getTeamUserInfo` | `onGetTeamUserInfo` | B | 1 |
| `getTerritorialContentionInfo` | `callbackGetTerritorialContentionInfo` | B | 1 |
| `getTerritorialContentionInfoOne` | `callbackGetTerritorialContentionInfo` | B | 1 |
| `getTerritorialTeamBean` | `callbackGetTerritorialTeamBean` | B | 1 |
| `getTgpVipPack` | `onGetYellowVipPack` | B | 1 |
| `getTimeSafeBoxOrderBean` | `callbackGetTimeSafeBoxOrderBean` | B | 1 |
| `getTimeSafeBoxesBean` | `callbackGetTimeSafeBoxOrderBean` | B | 1 |
| `getTotalSignInReward` | `callbackTotalSignInReward` | B | 1 |
| `getTrialTowerInfo` | `callbackGetTrialTowerInfo` | B | 1 |
| `getTriggerActivityList` | `callbackGetTriggerActivityList` | B | 1 |
| `getUltimateAvatarInfo` | `callbackGetUltimateAvatarInfo` | B | 1 |
| `getUltimateReward` | `callBackGetUltimateReward` | B | 1 |
| `getUpgradeDragoonChip` | `callBackUpgradeDragoonChip` | B | 1 |
| `getUpgradeDragoonChipByExp` | `callBackGetUpgradeDragoonChipByExp` | B | 1 |
| `getUpgradeInfo` | `callbackGetUpgradeInfo` | B | 1 |
| `getUserDataByLogin` | `callBackGetUserDataByLogin` | A | 1 |
| `getUserDyeingWorks` | `callbackGetUserDyeingWorks` | B | 1 |
| `getUserGameData` | `callbackGetUserGameData` | B | 2 |
| `getUserIpRegion` | `callbackGetUserIpRegion` | B | 1 |
| `getUserLocationData` | `onGetUserLocationData` | B | 1 |
| `getVariantSkillInfo` | `callBackGetVariantSkillInfo` | B | 1 |
| `getVariationItemLimitInfo` | `callBackGetVariationItemLimitInfo` | B | 1 |
| `getVariationWarDetailInfo` | `callBackGetVariationWarDetailInfo` | A | 1 |
| `getVerificationCode` | `callbackGetVerificationCode` | B | 1 |
| `getVipReturnWeaponInfo` | `callBackGetVipReturnWeaponInfo` | B | 1 |
| `getVoteWeaponResult` | `callbackGetVoteWeaponResult` | B | 1 |
| `getWarLetterBean` | `callbackGetWarLetterBean` | B | 1 |
| `getWeaponBattleData` | `callbackGetWeaponBattleData` | B | 1 |
| `getWeaponCalibrationBeans` | `callbackGetWeaponCalibrationBeans` | B | 1 |
| `getWeaponFactoryInfo` | `onGetWeaponFactoryInfo` | B | 1 |
| `getWeaponFactoryItem` | `onGetWeaponFactoryItem` | B | 1 |
| `getWeaponForbiddenDetail` | `callbackGetWeaponForbiddenDetail` | B | 1 |
| `getWeaponForbiddenRank` | `callbackGetWeaponForbiddenRank` | B | 1 |
| `getWeaponForbiddenUserVotes` | `callbackGetWeaponForbiddenUserVotes` | B | 1 |
| `getWeaponGroupSkinData` | `callbackGetWeaponGroupSkinData` | B | 1 |
| `getWeaponSlotInfo` | `callBackGetWeaponSlotInfo` | B | 1 |
| `getWeaponStorageInfo` | `callBackGetWeaponStorageInfo` | B | 1 |
| `getWeaponTreasureLuckyInfo` | `onGetWeaponTreasureLuckyInfo` | B | 1 |
| `getWeekTaskReward` | `callbackWeekTaskReward` | B | 1 |
| `getWeeklyActiveTask` | `callbackGetWeeklyActiveTask` | B | 1 |
| `getWeeklyActiveTaskItemReward` | `callbackWeeklyActiveTaskItemReward` | B | 1 |
| `getWeeklyActiveTaskReward` | `callbackWeeklyActiveTaskReward` | B | 1 |
| `getWeiDuanPack` | `onGeWeiDuanPack` | B | 1 |
| `getWishTeamBean` | `callbackGetWishTeamBean` | B | 1 |
| `getYellowVipPack` | `onGetYellowVipPack` | B | 1 |
| `giftAwayLegionItem` | `callbackGiftAwayLegionItem` | B | 1 |
| `giftLegionCoin` | `callbackGiftLegionCoin` | B | 1 |
| `giveGift` | `onGiveGift` | B | 1 |
| `giveRpgGift` | `callbackGiveRpgGift` | B | 1 |
| `giveUpLuckyWheelTask` | `callbackGiveUpLuckyWheelTask` | B | 1 |
| `giveUpTask` | `callBackGiveUpTask` | B | 1 |
| `giveUpTaskBySeasonId` | `callbackGiveUpTaskBySeasonId` | B | 1 |
| `globalRoomChannelAvaliable` | `onGlobalRoomChannelAvaliable` | B | 1 |
| `handInTeamBadge` | `callbackHandInTeamBadge` | B | 1 |
| `handleWishTeamInvitation` | `callbackHandleWishTeamInvitation` | B | 1 |
| `identifyDivineMarkStone` | `callbackIdentifyDivineStone` | B | 1 |
| `impeachTeamLeader` | `callbackImpeachTeamLeader` | B | 1 |
| `inactiveFavorite` | `callbackInactiveFavorite` | B | 1 |
| `inactivePersonalise` | `callbackInactivePersonalise` | A | 1 |
| `inviteJoinChannelTeam` | `callbackInviteJoinChannelTeam` | B | 1 |
| `inviteJoinInRpgTeam` | `callbackInviteJoinInRpgTeam` | B | 1 |
| `inviteJoinRoom` | `onInviteJoinRoom` | B | 1 |
| `inviteJoinRpgTeam` | `callbackInviteJoinRpgTeam` | B | 1 |
| `inviteJoinTeam` | `onInviteJoinTeam` | B | 1 |
| `inviteJoinTeamResult` | `onInviteJoinTeamResult` | B | 1 |
| `inviteJoinWishTeam` | `callbackInviteJoinWishTeam` | B | 1 |
| `isAutomaticEquip` | `callbackIsAutomaticEquip` | B | 1 |
| `joinChannelTeam` | `callbackJoinChannelTeam` | B | 1 |
| `joinPalAllianceTeam` | `callbackJoinPalAllianceTeam` | B | 1 |
| `joinRaceRoom` | `callbackJoinRaceRoom` | B | 1 |
| `joinRestrictionRoom` | `callbackJoinRestrictionRoom` | B | 1 |
| `joinRoom` | `callBackJoinRoom` | B | 2 |
| `joinRpgRestrictionRoom` | `callbackJoinRpgRoom` | B | 1 |
| `joinRpgRoom` | `callbackJoinRpgRoom` | B | 1 |
| `joinRpgTeam` | `callbackJoinRpgTeam` | B | 1 |
| `kickOutRpgTeam` | `callbackKickOutRpgTeam` | B | 1 |
| `kickOutTeam` | `onKickOutTeam` | B | 1 |
| `kickOutTeamMember` | `callbackKickOutTeamMember` | B | 1 |
| `kickOutWishTeam` | `callbackKickOutWishTeam` | B | 1 |
| `kickRaceUser` | `callbackRaceUserLeave` | B | 1 |
| `kingScuffleStartAfk` | `callbackStartKingScuffleAfk` | B | 1 |
| `kingScuffleStopAfk` | `callbackStopKingScuffleAfk` | B | 1 |
| `leaveChannelTeam` | `callbackLeaveChannelTeam` | B | 1 |
| `leaveRaceRoom` | `callbackLeaveRaceRoom` | B | 1 |
| `leaveRoom` | `callBackLeaveRoom` | B | 2 |
| `leaveRpgTeam` | `callbackLeaveRpgTeam` | B | 1 |
| `legendCasting` | `callbackLegendCasting` | B | 1 |
| `likeDyeingWork` | `callbackLikeDyeingWork` | B | 1 |
| `likePeakCompetitor` | `callbackLikePeakCompetitor` | B | 1 |
| `listHomelandHallRentItem` | `callbackListHomelandHallRentItem` | B | 1 |
| `loadUltTalentSkill` | `callbackLoadUltTalentSkill` | B | 1 |
| `loanRepayment` | `callbackLoanRepayment` | B | 1 |
| `lockEnchantmentSlot` | `callbackLockEnchantmentSlot` | B | 1 |
| `lockRingAffix` | `callbackLockRingAffix` | B | 1 |
| `lockRunes` | `callbackLockRunes` | B | 1 |
| `lockSlavePropertyRecord` | `callbackLockSlavePropertyRecord` | B | 1 |
| `login` | `onFriendLogin` | B | 1 |
| `loginBattle` | `callbackLoginBattle` | B | 1 |
| `loginV3` | `callBackLoginV3` | A | 1 |
| `lookupFriendshipRooms` | `callbackLookupFriendshipRooms` | B | 1 |
| `luckyDrawBulk` | `callBackLuckyDrawBulk` | B | 1 |
| `luckyDrawMulti` | `callBackLuckyDrawMulti` | B | 1 |
| `luckyDrawSingle` | `callBackLuckyDrawSingle` | B | 1 |
| `luckyDrawStartup` | `callBackLuckyDrawStartup` | B | 1 |
| `luckyDrawStartupSuper` | `callBackLuckyDrawStartupSuper` | B | 1 |
| `makeHomelandFormula` | `callbackMakeHomelandFormula` | B | 1 |
| `makeLeagueEngine` | `callbackMakeLeagueEngine` | B | 1 |
| `markDragoonChip` | `callBackMarkDragoonChip` | B | 1 |
| `markPalNodePointFlag` | `callbackMarkPalNodePointFlag` | B | 1 |
| `marketGetItemDetailInfo` | `callbackGetRankItemInfo` | B | 1 |
| `marketGetUserBuyOrderInfo` | `callbackMarketGetUserBuyOrderInfo` | B | 1 |
| `marketGetUserMarketOverviewInfo` | `callbackMarketGetUserMarketOverviewInfo` | B | 1 |
| `marketGetUserSellOrderInfo` | `callbackMarketGetUserSellOrderInfo` | B | 1 |
| `marketShowComplexSellingOrderListWithPage` | `callbackMarketShowComplexSellingOrderListWithPage` | B | 1 |
| `marketShowHistoryAvgFinalPrice` | `callbackMarketShowHistoryAvgFinalPrice` | B | 1 |
| `marketShowOverviewInfo` | `callbackMarketShowOverviewInfo` | B | 1 |
| `marketShowSellingOrderListWithPage` | `callbackMarketShowSellingOrderListWithPage` | B | 1 |
| `marketShowShelfDetailInfo` | `callbackMarketShowShelfDetailInfo` | B | 1 |
| `marketSubmitBuyOrder` | `callbackMarketSubmitBuyOrder` | B | 1 |
| `marketSubmitSellOrder` | `callbackMarketSubmitSellOrder` | B | 1 |
| `marketSubmitSellOrderV3` | `callbackMarketSubmitSellOrder` | B | 1 |
| `marketSubmitSellOrderWithSystemMode` | `callbackMarketSubmitSellOrder` | B | 1 |
| `marketTryCancelBuyOrder` | `callbackMarketTryCancelBuyOrder` | B | 1 |
| `marketTryCancelSellOrder` | `callbackMarketTryCancelSellOrder` | B | 1 |
| `marketTryFetchBuyOrder` | `callbackMarketTryFetchBuyOrder` | B | 1 |
| `marketTryFetchSellOrder` | `callbackMarketTryFetchSellOrder` | B | 1 |
| `marketTryRefundBuyOrder` | `callbackMarketTryRefundBuyOrder` | B | 1 |
| `marketTryRefundSellOrder` | `callbackMarketTryRefundSellOrder` | B | 1 |
| `matchGlobalRoom` | `onMatchGlobalRoom` | B | 1 |
| `mergeSkin` | `callbackMergeSkin` | B | 1 |
| `militaryExchangeStorage` | `callbackMilitaryExchangeStorage` | B | 1 |
| `modifyRpgAdventureLogRewardList` | `callbackModifyRpgAdventureLogRewardList` | B | 1 |
| `mountGrid` | `callbackMountGrid` | A | 1 |
| `mountGrids` | `callbackMountGrids` | B | 1 |
| `mounts` | `callbackMounts` | A | 1 |
| `newSignIn` | `callbackNewSignIn` | B | 1 |
| `notUsePlotWeapon` | `callbackNotUsePlotWeapon` | B | 2 |
| `onCallRankList` | `onGetRankList` | B | 1 |
| `onGameCoolDownCompleted` | `onGameCoolDownChanged` | B | 1 |
| `onGiveTitaniumGift` | `callbackGiveTitaniumGift` | B | 1 |
| `onInvitationRankList` | `callbackInvitationRankList` | B | 1 |
| `onTitaniumCode` | `callbackOnTitaniumCode` | B | 1 |
| `onTitaniumTaskInfo` | `callbackTitaniumTaskInfo` | B | 1 |
| `onUserEtherBeanInfo` | `callbackUserEtherBeanInfo` | B | 1 |
| `openBlind` | `callbackOpenBlind` | B | 1 |
| `openCard` | `callbackOpenCard` | B | 1 |
| `openCreditAccount` | `callbackOpenCreditAccount` | B | 1 |
| `openDecoration` | `onOpenDecoration` | B | 1 |
| `openHomeland` | `callbackOpenHomeland` | B | 1 |
| `openSkinBox` | `callbackOpenSkinBox` | B | 1 |
| `openVariationBox` | `callBackOpenVariationBox` | B | 1 |
| `operateFestCelebration2025Shop` | `callbackLockFestCelebration2025Shop` | B | 1 |
| `operateMapPathNode` | `callbackOperateMapPathNode` | B | 1 |
| `operaterBountyTask` | `callBackOperaterBountyTask` | B | 1 |
| `organizeStorage` | `callbackOrganizeStorageComplete` | B | 1 |
| `palMarch` | `callbackPalMarch` | B | 1 |
| `palQuickMarch` | `callbackPalQuickMarch` | B | 1 |
| `pickForeverLandItem` | `callbackPickForeverLandItem` | B | 1 |
| `playActivityNew` | `callbackPlayActivityNew` | B | 1 |
| `playActivityNewWithType` | `callbackPlayActivityNewWithType` | B | 1 |
| `prepareScufflePeak` | `callbackPrepareScufflePeak` | B | 1 |
| `pullSlotMachine` | `callbackPullSlotMachine` | C | 0 |
| `queryAcgLuckyDrawProcess` | `callbackQueryAcgLuckyDrawProcess` | B | 1 |
| `queryCompletedQuestionnaires` | `callbackQueryCompletedQuestionnaires` | B | 1 |
| `queryCreditAccount` | `callbackQueryCreditAccount` | B | 1 |
| `queryEnvoyLingFuData` | `callbackQueryEnvoyLingFuData` | B | 1 |
| `queryExpeditionConditions` | `callbackQueryExpeditionConditions` | B | 1 |
| `queryFriendInfo` | `callbackQueryFriendInfo` | B | 1 |
| `queryHistoryBill` | `callbackQueryHistoryBill` | B | 1 |
| `queryMonitorInfo` | `callbackQueryMonitorInfo` | B | 1 |
| `queryOngoingBill` | `callbackQueryOngoingBill` | B | 1 |
| `queryUserHistoryRecord` | `callbackQueryUserHistoryRecord` | B | 1 |
| `quitRpgTeam` | `callbackQuitRpgTeam` | B | 1 |
| `quitTeam` | `onQuitTeam` | B | 1 |
| `quitWishTeam` | `callbackQuitWishTeam` | B | 1 |
| `raidRpgBattleField` | `callbackRaidRpgBattleField` | B | 1 |
| `raidSlotMachine` | `callbackRaidSlotMachine` | C | 0 |
| `randomPlayerName` | `onRandomPlayerName` | A | 1 |
| `randomStarProjectBox` | `callBackUpdateStarProjectBox` | B | 1 |
| `reNewSignIn` | `callbackReNewSignIn` | B | 1 |
| `reSignInOncePerDay` | `onSignInByDay` | B | 1 |
| `readAndFetchAllMail` | `callbackReadAndFetchAllMail` | B | 1 |
| `realTimeNotice` | `callBackRealTimeNotice` | B | 1 |
| `recallRpgWeaponBattleSlv` | `callbackRecallRpgWeaponBattleSlv` | B | 1 |
| `receiveLingYunReward` | `callbackReceiveLingYunReward` | B | 1 |
| `receiveReward` | `callbackReceiveReward` | B | 1 |
| `receiveTask` | `callBackReceiveTask` | B | 1 |
| `receiveTaskBySeasonId` | `callbackReceiveTaskBySeasonId` | B | 1 |
| `reconnectGame` | `callbackReconnectGameFail` | B | 2 |
| `refineRing` | `callbackRefineRing` | B | 1 |
| `reformUnequippedWeaponSlot` | `callBackReformUnequippedWeaponSlot` | B | 1 |
| `reformWeaponSlot` | `callBackReformWeaponSlot` | B | 1 |
| `refreshBlind` | `callbackRefreshBlind` | B | 1 |
| `refreshDailyTask` | `callbackRefreshDailyTask` | B | 1 |
| `refreshDefenseLineWeapon` | `callbackRefreshDefenseLineWeapon` | B | 1 |
| `refreshDefenseLineWeaponEquipInfo` | `callbackRefreshDefenseLineWeaponEquipInfo` | B | 1 |
| `refreshFestivalMarketPrice` | `callbackRefreshFestivalMarketPrice` | C | 0 |
| `refreshMysteryShop` | `callbackRefreshMysteryShop` | B | 1 |
| `refreshRecommandFriendList` | `onRefreshRecommandFriend` | B | 1 |
| `refreshRoomStatus` | `onRefreshRoomStatus` | B | 1 |
| `refreshRpgShop` | `callbackRefreshRpgShop` | B | 1 |
| `refreshTimeSafeBox` | `callbackRefreshTimeSafeBox` | B | 1 |
| `refreshWarLetterBuff` | `callbackRefreshWarLetterBuff` | B | 1 |
| `refundPerMonth` | `onRefundPerMonth` | B | 1 |
| `relicEnchantment` | `callbackRelicEnchantment` | B | 1 |
| `relicLvBreakMaxLv` | `callbackRelicLvBreakMaxLv` | B | 1 |
| `relicSystemInfo` | `callbackRelicSystemInfo` | B | 1 |
| `remouldRune` | `callbackRemouldRune` | B | 1 |
| `removeAllHaveReadMail` | `callbackRemoveAllHaveReadMail` | B | 1 |
| `removeEnvoyFromLingFu` | `callbackRemoveEnvoyFromLingFu` | B | 1 |
| `removeMyDyeingWork` | `callbackRemoveMyDyeingWork` | B | 1 |
| `rentHomelandHallItem` | `callbackRentHomelandHallItem` | B | 1 |
| `rerandomStarProjectBox` | `callBackUpdateStarProjectBox` | B | 1 |
| `resetCalibrateCount` | `callbackResetCalibrateCount` | B | 1 |
| `resetNewWeaponFactory` | `callBackGetNewWeaponFactoryItem` | B | 1 |
| `resetRpgArenaData` | `callbackResetRpgArenaData` | B | 1 |
| `resetRpgInfinity` | `callbackResetRpgInfinity` | B | 1 |
| `resetRpgMagicArsenal` | `callbackResetRpgMagicArsenal` | B | 1 |
| `resetSecPsw` | `callbackResetSecPsw` | B | 1 |
| `resetTeamLeague` | `callbackResetTeamLeague` | B | 1 |
| `resetWeaponPrecision` | `callbackResetWeaponPrecision` | B | 1 |
| `resumeRaceGame` | `startRaceGame` | B | 1 |
| `retrievalStorageBean` | `callbackRetrievalStorageBean` | B | 1 |
| `rewardBioChemDefenseLine` | `callbackRewardBioChemDefenseLine` | B | 1 |
| `rewardRetrieve` | `callbackRewardRetrieve` | B | 1 |
| `rollbackUpgrade` | `callbackRollbackUpgrade` | C | 0 |
| `roomList` | `callBackShowRoomList` | A | 2 |
| `rpgExploreQuickComplete` | `callBackRpgExploreQuickComplete` | B | 1 |
| `rpgGetExploreReward` | `callBackRpgGetExploreReward` | B | 1 |
| `rpgHardTrain` | `callbackRpgHardTrain` | B | 1 |
| `rpgMagicArsenalMove` | `callbackRpgMagicArsenalMove` | B | 1 |
| `rpgMagicArsenalMove10` | `callbackRpgMagicArsenalMove10` | B | 1 |
| `rpgReceiveEndlessReward` | `callbackRpgReceiveEndlessReward` | B | 1 |
| `rpgStartExplore` | `callBackRpgStartExplore` | B | 1 |
| `saveAvatarDyeing` | `callbackSaveAvatarDyeing` | B | 1 |
| `saveQuestionnaire` | `callbackSaveQuestionnaire` | B | 1 |
| `saveUltimateAvatarConfigInfo` | `callbackSaveUltimateAvatarConfigInfo` | B | 1 |
| `scrapeScratchOffCell` | `callbackScrapeScratchOffCell` | B | 1 |
| `searchCharacterByName` | `onSearchCharacterByName` | B | 1 |
| `searchHomelandBox` | `callbackAcquireHomelandBox` | B | 1 |
| `searchNotInRpgTeam` | `callbackSearchNotInRpgTeam` | B | 1 |
| `searchRoomListAllChannel` | `onSearchRoomListAllChannel` | B | 1 |
| `selectAbattoirDiffType` | `callbackSelectAbattoirDiffType` | B | 1 |
| `selectAvatarBag` | `callBackSelectAvatarBag` | A | 1 |
| `selectAvatarJoinVariationWar` | `callBackSelectAvatarJoinVariationWar` | B | 1 |
| `selectBag` | `onSelectBag` | B | 1 |
| `selectCalibrateResult` | `callbackSelectCalibrateResult` | B | 1 |
| `selectItem` | `onSelectItem` | B | 1 |
| `selectItemJoinVariationWar` | `callBackSelectItemJoinVariationWar` | B | 1 |
| `selectOrdinaryVariant` | `callbackSelectOrdinaryVariant` | B | 1 |
| `selectPeakBag` | `callbackSelectPeakBag` | B | 1 |
| `selectRandomChallengeTask` | `callbackSelectRandomChallengeTask` | B | 1 |
| `selectRealmExchangeWeapon` | `callbackSelectRealmExchangeWeapon` | B | 1 |
| `selectRogueAvatar` | `callbackSelectRogueAvatar` | C | 0 |
| `selectRogueDiffId` | `callbackSelectRogueDiffId` | C | 0 |
| `selectRogueJob` | `callbackSelectRogueJob` | C | 0 |
| `selectRogueWeapon` | `callbackSelectRogueWeapon` | C | 0 |
| `selectRuneBag` | `callbackSelectRuneBag` | B | 1 |
| `selectScratchOff` | `callbackSelectScratchOff` | B | 1 |
| `selectSlotMachine` | `callbackSelectSlotMachine` | C | 0 |
| `selectUltTalentBag` | `callbackSelectUltTalentBag` | B | 1 |
| `selectZoom` | `callbackSelectZoom` | B | 1 |
| `sellChip` | `onSellChip` | B | 1 |
| `sellFestivalMarketItems` | `callbackSellFestivalMarketItems` | C | 0 |
| `sellLegionItem` | `callbackSellLegionItem` | B | 1 |
| `sendBountyTask` | `callBackSendBountyTask` | B | 1 |
| `sendMessage` | `callbackSendMessage` | B | 1 |
| `sendMessageByBugleType` | `onSendMessageByBugleType` | B | 1 |
| `sendMessageWithExtra` | `callbackSendMessage` | B | 1 |
| `setAutoStored` | `callbackSetAutoStored` | B | 1 |
| `setAvatarSupportCaptain` | `callbackSetAvatarSupportCaptain` | B | 1 |
| `setBuyLegionGoods` | `callbackSetBuyLegionGoods` | B | 1 |
| `setEnvoySoulFavor` | `callbackSetEnvoySoulFavor` | B | 1 |
| `setHomelandHallRentLimit` | `callbackSetHomelandHallRentLimit` | B | 1 |
| `setRogueSwitch` | `callbackSetRogueSwitch` | C | 0 |
| `setRpgMagicArsenalInfo` | `callbackSetMagicArsenalInfo` | B | 1 |
| `setSecPsw` | `callbackSetSecPsw` | B | 1 |
| `setWarriorTeamAssist` | `callbackSetWarriorTeamAssist` | B | 1 |
| `show3366Vip` | `onShow3366Vip` | B | 1 |
| `showBlack` | `onShowBlack` | B | 1 |
| `showBlueVip` | `onShowBlueVip` | B | 1 |
| `showCharacterBattleReport` | `callBackShowCharacterBattleReport` | B | 1 |
| `showFriend` | `onShowFriend` | B | 1 |
| `showHallAnnounce` | `callBackShowHallAnnounce` | B | 1 |
| `showLogRecentBattleBean` | `onShowLogRecentBattleBean` | B | 1 |
| `showQQVipPacks` | `onShowQQVipPacks` | B | 1 |
| `showRaceUserOverviewInfo` | `callbackShowRaceUserOverviewInfo` | B | 1 |
| `showRecommandFriendList` | `onShowRecommandFriend` | B | 1 |
| `showServerVersion` | `callbackShowVersionAnnounce` | B | 1 |
| `showSingleBattleReport` | `callBackShowSingleBattleReport` | B | 1 |
| `showTgpVip` | `onShowTgpVip` | B | 1 |
| `showVersionAnnounce` | `callbackShowVersionAnnounce` | B | 1 |
| `showWeaponUnlock` | `callBackShowWeaponUnlock` | B | 1 |
| `showWeiDuan` | `onShowWeiDuan` | B | 1 |
| `showYellowVip` | `onShowYellowVip` | B | 1 |
| `signInPerDay` | `onSignInByDay` | B | 1 |
| `signUpTeamLeague` | `callbackSignUpTeamLeague` | B | 1 |
| `spinLuckyWheel` | `callbackSpinLuckyWheel` | B | 1 |
| `startDelayRaid` | `callbackStartDelayRaid` | B | 1 |
| `startGame` | `callBackStartGame` | B | 6 |
| `startPresetTemplate` | `callbackStartPresetTemplate` | B | 1 |
| `startRaceMatch` | `startRaceGame` | A | 1 |
| `startRpgMatch` | `callBackStartRpgGame` | B | 2 |
| `stopPalMarch` | `callbackStopPalMarch` | B | 1 |
| `storageAwake` | `callbackStorageAwake` | B | 1 |
| `storeStorageBean` | `callbackStoreStorageBean` | B | 1 |
| `strengthCoreLv` | `callbackStrengthCoreLv` | B | 1 |
| `supplyPalSoldier` | `callbackSupplyPalSoldier` | B | 2 |
| `switchEnvoyLingFu` | `callbackSwitchEnvoyLingFu` | B | 1 |
| `switchLingYunElementType` | `callbackSwitchLingYunElementType` | B | 1 |
| `switchWingHalo` | `callbackSwitchWingHalo` | B | 1 |
| `syncBattleBioEquip` | `callbackSyncBattleBioEquip` | B | 2 |
| `syncLegionTechnologyProperty` | `onSyncBattleProperty` | B | 1 |
| `syncServerTime` | `callBackSyncServerTime` | B | 1 |
| `takeSettlementGameCoin` | `callbackTakeSettlementGameCoin` | B | 1 |
| `takeTeamTreasureBox` | `callbackTakeTeamTreasureBox` | B | 1 |
| `teamLeaveMessage` | `onTeamLeaveMessage` | B | 1 |
| `titaniumPanelOpen` | `callbackTitaniumPanelOpen` | B | 1 |
| `unEquipBattlePet` | `onUnEquipBattlePet` | B | 1 |
| `unEquipDivineMark` | `callbackUnEquipDivineMark` | B | 1 |
| `unEquipGroupRootAvatar` | `callBackUnEquipRootAvatarInfo` | B | 1 |
| `unEquipModuleItem` | `callbackUnEquipModuleItem` | B | 1 |
| `unEquipPersonalise` | `callbackUnEquipPersonalise` | A | 1 |
| `unEquipPropertyWing` | `callbackUnEquipPropertyWing` | B | 1 |
| `unEquipRootAvatarInfo` | `callBackUnEquipRootAvatarInfo` | A | 1 |
| `unEquipRune` | `callbackUnEquipRune` | B | 1 |
| `unEquipTacticalWeapon` | `callbackUnEquipTacticalWeapon` | B | 1 |
| `unLockWarriorMedal` | `callbackUnLockWarriorMedal` | B | 1 |
| `unMatchGlobalRoom` | `onMatchGlobalRoom` | B | 1 |
| `unSelectAvatarJoinVariationWar` | `callBackUnSelectAvatarJoinVariationWar` | B | 1 |
| `unSelectItem` | `onUnSelectItem` | B | 1 |
| `unSelectItemJoinVariationWar` | `callBackUnSelectItemJoinVariationWar` | B | 1 |
| `unbindApplet` | `callbackUnbindApplet` | B | 1 |
| `unequip` | `onUnequip` | A | 1 |
| `unequipAvatarEquipment` | `callbackUnequipAvatarEquipment` | B | 1 |
| `unequipChip` | `onUnequipChip` | B | 1 |
| `unequipChipByWeapon` | `onUnequipChipByWeapon` | B | 1 |
| `unequipDecoration` | `onUnequipDecoration` | B | 1 |
| `unequipRootAvatarSound` | `callBackUnequipRootAvatarSound` | B | 1 |
| `unequipRpgXpSkill` | `callbackUnequipRpgXpSkill` | B | 1 |
| `unequipUltimateAvatar` | `callbackUnequipUltimateAvatar` | B | 1 |
| `unequipWeaponSlot` | `callBackUnequipWeaponSlot` | B | 1 |
| `unloadUltTalentSkill` | `callbackUnloadUltTalentSkill` | B | 1 |
| `unlockAssistantAbility` | `callbackUnlockAssistantAbility` | B | 1 |
| `unlockAvatarAcgRelationship` | `callbackUnlockAvatarAcgRelationship` | B | 1 |
| `unlockAvatarDyeing` | `callbackUnlockAvatarDyeing` | B | 1 |
| `unlockCreditAccount` | `callbackUnlockCreditAccount` | B | 1 |
| `unlockDyeingColor` | `callbackUnlockDyeingColor` | B | 1 |
| `unlockEnchantmentSlot` | `callbackUnlockEnchantmentSlot` | B | 1 |
| `unlockFestivalTalent` | `callbackUnlockFestivalTalent` | B | 1 |
| `unlockModuleSys` | `callbackUnlockModuleSys` | B | 1 |
| `unlockNewbieTask` | `callbackUnlockNewbieTask` | B | 1 |
| `unlockPersonalise` | `callbackUnlockPersonalise` | A | 1 |
| `unlockPersonaliseWithStorageId` | `callbackUnlockPersonalise` | A | 1 |
| `unlockRpgReconstructionTalentSkill` | `callbackUnlockRpgReconstructionTalentSkill` | B | 1 |
| `unlockSlavePropertyRecord` | `callbackUnlockSlavePropertyRecord` | B | 1 |
| `unlockTalent` | `callbackUnlockTalent` | B | 1 |
| `unmountGrid` | `callbackUnmountGrid` | A | 1 |
| `unmountGrids` | `callbackUnmountGrids` | B | 1 |
| `updateChipExp` | `callBackUpdateChipExp` | B | 1 |
| `updateDefenseLineWeaponEquipStatus` | `callbackUpdateDefenseLineWeaponEquipStatus` | B | 1 |
| `updateReducedRankDisplayFlag` | `callbackUpdateReducedRankDisplayFlag` | B | 1 |
| `updateRoom` | `callbackUpdateRpgRoom` | B | 2 |
| `updateRpgBody` | `onUpdateRpgBody` | B | 1 |
| `updateRpgEquipment` | `onUpdateRpgEquipment` | B | 1 |
| `updateRpgEquipmentBatchStrengthen` | `onUpdateRpgEquipmentBatchStrengthen` | B | 1 |
| `updateRpgKingScuffleRankDisplayFlag` | `callbackUpdateRpgKingScuffleRankDisplayFlag` | B | 1 |
| `updateRpgWeaponBattleSlv` | `callbackRecallRpgWeaponBattleSlv` | B | 1 |
| `updateRpgWeaponMasteryLv` | `callbackUpdateWeaponMasteryLv` | B | 1 |
| `updateRpgXpSkillLv` | `callbackUpdateRpgXpSkillLv` | B | 1 |
| `updateRpgXpSkillSlv` | `callbackUpdateRpgXpSkillSlv` | B | 1 |
| `updateTaskLobbyInfo` | `callBackUpdateTaskLobbyInfo` | B | 1 |
| `upgrade` | `callbackUpgrade` | B | 1 |
| `upgradeAvatarAcgLevel` | `callbackUpgradeAvatarAcgLevel` | B | 1 |
| `upgradeAvatarLv` | `callbackUpgradeAvatarLv` | B | 1 |
| `upgradeAvatarTalent` | `callBackUpgradeAvatarTalent` | B | 1 |
| `upgradeEnvoySoul` | `callbackUpgradeEnvoySoul` | B | 1 |
| `upgradeLegionTechnology` | `callbackUpgradeLegionTechnology` | B | 1 |
| `upgradeLuckyWheelReward` | `callbackUpgradeLuckyWheelReward` | B | 1 |
| `upgradeRingLevel` | `callbackUpgradeRingLevel` | B | 1 |
| `upgradeRpgReconstructionLv` | `callbackUpgradeRpgReconstructionLv` | B | 1 |
| `upgradeRpgTeamTechnology` | `callbackUpgradeRpgTeamTechnology` | B | 1 |
| `upgradeRpgUltTalentLv` | `callbackUpgradeRpgUltTalentLv` | B | 1 |
| `upgradeSkinCoordinationLv` | `callbackUpgradeSkinCoordination` | B | 1 |
| `upgradeStarProjectBox` | `callBackUpdateStarProjectBox` | B | 1 |
| `upgradeTalent` | `callbackUpgradeTalent` | B | 1 |
| `upgradeTerritorialTechnology` | `callbackUpgradeTerritorialTechnology` | B | 1 |
| `upgradeUnequippedWeaponSlot` | `callbackUpgradeUnequippedWeaponSlot` | B | 1 |
| `upgradeWeaponCalibration` | `callbackUpgradeWeaponCalibration` | B | 1 |
| `upgradeWeaponGroupSkinLv` | `callbackUpgradeWeaponGroupSkinLv` | B | 1 |
| `upgradeWeaponSlot` | `callbackUpgradeWeaponSlot` | B | 1 |
| `upgradeWingSlot` | `callbackUpgradeWingSlot` | B | 1 |
| `upgradeWingSlotProperty` | `callbackUpgradeWingSlotProperty` | B | 1 |
| `uploadDyeingWork` | `callbackUploadDyeingWork` | B | 1 |
| `useAbyssGainItem` | `callbackUseAbyssGainItem` | B | 1 |
| `useAbyssItem` | `callbackUseAbyssItem` | B | 1 |
| `useCharMedal` | `callbackUseCharMedal` | A | 1 |
| `useChosenBoxMulti` | `callbackUseChosenBox` | C | 0 |
| `useFestivalExtraItem` | `callbackUseFestivalExtraItem` | B | 1 |
| `useKingBlessItem` | `callbackUseKingBlessItem` | B | 1 |
| `useOptionalPack` | `callbackUseOptionalPack` | B | 1 |
| `useRpgMixture` | `callbackUseRpgMixture` | B | 1 |
| `useRpgRandomChallengeItem` | `callbackUseRpgRandomChallengeItem` | B | 1 |
| `useScuffleSuperDesperateFightFlag` | `callbackScuffleSuperDesperateFightFlag` | B | 1 |
| `useSkinEffect` | `callbackUseSkinEffect` | B | 1 |
| `useStorageChipPack` | `callBackUseStorageChipPack` | B | 1 |
| `useStorageItem` | `callBackUseStorageItem` | A | 1 |
| `useStoragePack` | `onUseStoragePack` | B | 1 |
| `useStorageRunePack` | `callbackUseStorageRunePack` | B | 1 |
| `useStorageSkin` | `callbackUseStorageSkin` | A | 1 |
| `usedItemToRelic` | `callbackUsedItemToRelic` | B | 1 |
| `validateSecPsw` | `callbackValidateSecPsw` | B | 1 |
| `variantSkillUpgrade` | `callBackVariantSkillUpgrade` | B | 1 |
| `vipReturnWeaponGold` | `callBackReturnWeaponGold` | B | 1 |
| `voteRaceEntertainmentWeapon` | `callbackVoteRaceEntertainmentWeapon` | B | 1 |
| `voteTeamImpeach` | `callbackVoteTeamImpeach` | B | 1 |
| `voteVideo` | `callbackVoteVideo` | B | 1 |
| `voteWeapon` | `callbackVoteWeapon` | B | 1 |
| `watchGame` | `callbackWatchGame` | B | 1 |
| `weaponEquipSkin` | `callbackEquipTacticalWeapon` | A | 1 |
| `weaponUnLockClick` | `callBackWeaponUnLock` | B | 1 |
| `wingExchangeStorage` | `callbackWingExchangeStorage` | B | 1 |
| `withdrawScufflePeak` | `callbackWithdrawScufflePeak` | B | 1 |

</details>
