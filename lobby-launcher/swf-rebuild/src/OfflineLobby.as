package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.utils.ByteArray;
    import flash.net.SharedObject;
    import flash.utils.setTimeout;

    [SWF(width="1024", height="650", frameRate="30", backgroundColor="#0a1119")]
    public final class OfflineLobby extends Sprite {
        [Embed(source="../assets/lobby_bg.png")]
        private static const LobbyBackground:Class;
        [Embed(source="../assets/warehouse_bg.png")]
        private static const WarehouseBackground:Class;
        [Embed(source="../assets/role_bg.png")]
        private static const RoleBackground:Class;
        [Embed(source="../assets/weapon_card.png")]
        private static const WeaponCard:Class;
        [Embed(source="../assets/weapon_card_selected.png")]
        private static const WeaponCardSelected:Class;
        [Embed(source="../assets/role_card.png")]
        private static const RoleCard:Class;
        [Embed(source="../assets/nav_gamehall.png")]
        private static const NavGameHall:Class;
        [Embed(source="../assets/nav_activity.png")]
        private static const NavActivity:Class;
        [Embed(source="../assets/nav_factory.png")]
        private static const NavFactory:Class;
        [Embed(source="../assets/nav_shop.png")]
        private static const NavShop:Class;
        [Embed(source="../assets/nav_rank.png")]
        private static const NavRank:Class;
        [Embed(source="../assets/nav_team.png")]
        private static const NavTeam:Class;
        [Embed(source="../assets/nav_creditshop.png")]
        private static const NavCreditShop:Class;
        [Embed(source="../assets/nav_vitae.png")]
        private static const NavVitae:Class;
        [Embed(source="../assets/nav_warehouse.png")]
        private static const NavWarehouse:Class;
        [Embed(source="../assets/official_lobby_dataset.json", mimeType="application/octet-stream")]
        private static const DatasetBytes:Class;
        [Embed(source="../assets/official_lobby_preview_index.json", mimeType="application/octet-stream")]
        private static const PreviewIndexBytes:Class;

        private static const SW:int = 1024;
        private static const SH:int = 650;
        private static const WHITE:uint = 0xf0e6ca;
        private static const MUTED:uint = 0xa6b2c0;
        private static const GOLD:uint = 0xf0c763;
        private static const BLUE:uint = 0x69c7ec;

        private var rootLayer:Sprite = new Sprite();
        private var pageLayer:Sprite = new Sprite();
        private var messageLayer:Sprite = new Sprite();
        private var data:Object;
        private var previewIndex:Object;
        private var page:String = "home";
        private var selectedBag:int = 1;
        private var selectedSlot:int = 0;
        private var weaponPage:int = 0;
        private var weaponCategory:String = "全部";
        private var weaponSearch:String = "";
        private var rolePage:int = 0;
        private var selectedRole:String = "police";
        private var selectedWeapon:String = "m4a1";
        private var localState:SharedObject;
        private var equipped:Object = {};
        private var profile:Object = {
            gameId: "无端大傻逼", level: 91, rank: "最强王者", vip: 18, gold: 91, gp: 91
        };

        public function OfflineLobby() {
            if (stage) initialize();
            else addEventListener(Event.ADDED_TO_STAGE, onAdded);
        }

        private function onAdded(event:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, onAdded);
            initialize();
        }

        private function initialize():void {
            stage.scaleMode = "noScale";
            stage.align = "TL";
            stage.frameRate = 30;
            data = readEmbeddedJson(DatasetBytes);
            previewIndex = readEmbeddedJson(PreviewIndexBytes);
            loadSavedState();
            addChild(rootLayer);
            addChild(pageLayer);
            addChild(messageLayer);
            render();
        }

        private function readEmbeddedJson(asset:Class):Object {
            var bytes:ByteArray = new asset() as ByteArray;
            bytes.position = 0;
            return JSON.parse(bytes.readUTFBytes(bytes.length));
        }

        private function loadSavedState():void {
            try {
                localState = SharedObject.getLocal("ssjj-lobby/offline", "/");
                var saved:Object = localState.data.state;
                if (!saved) return;
                selectedBag = clamp(int(saved.selectedBag), 1, 5);
                selectedRole = String(saved.selectedRole || selectedRole);
                if (saved.equipped is Object) equipped = saved.equipped;
                if (equipped[selectedBag] && equipped[selectedBag].primary) {
                    selectedWeapon = String(equipped[selectedBag].primary);
                }
            } catch (error:Error) {
                showMessage("本地装配状态读取失败：" + error.message, true);
            }
        }

        private function saveState():void {
            try {
                if (!localState) localState = SharedObject.getLocal("ssjj-lobby/offline", "/");
                localState.data.state = {
                    schemaVersion: 1,
                    selectedBag: selectedBag,
                    selectedRole: selectedRole,
                    equipped: equipped
                };
                localState.flush(0);
            } catch (error:Error) {
                showMessage("保存装配失败：" + error.message, true);
            }
        }

        private function render():void {
            pageLayer.removeChildren();
            messageLayer.removeChildren();
            rootLayer.removeChildren();
            addBitmap(rootLayer, LobbyBackground, 0, 0, SW, SH);
            drawHeader();
            drawProfileBar();
            drawLeftLoadout();
            if (page == "home") drawHome();
            else if (page == "warehouse") drawWarehouse();
            else if (page == "roles") drawRoles();
            else if (page == "mode") drawModePicker();
            else drawOfflinePanel();
        }

        private function drawHeader():void {
            drawRect(rootLayer, 0, 0, SW, 40, 0x09111a, 1);
            drawRect(rootLayer, 0, 38, SW, 2, 0x3c5365, 1);
            var tabs:Array = [
                ["个人设置", NavVitae], ["战队信息", NavTeam], ["排行榜", NavRank],
                ["交易市场", NavCreditShop], ["盛世秋歌", NavActivity], ["游戏大厅", NavGameHall],
                ["精彩活动", NavActivity], ["武器工坊", NavFactory], ["游戏商城", NavShop], ["个人仓库", NavWarehouse]
            ];
            var x:Number = 0;
            for each (var row:Array in tabs) {
                var nav:Sprite = makeNavButton(row[0], row[1] as Class, x, 4, 101, 32);
                var target:String = "offline";
                if (row[0] == "游戏大厅") target = "home";
                if (row[0] == "个人仓库") target = "warehouse";
                if (row[0] == "武器工坊") target = "warehouse";
                nav.name = target;
                nav.addEventListener(MouseEvent.CLICK, onNavigationClick);
                rootLayer.addChild(nav);
                x += 102;
            }
        }

        private function makeNavButton(label:String, imageClass:Class, x:Number, y:Number, w:Number, h:Number):Sprite {
            var button:Sprite = new Sprite();
            button.x = x; button.y = y;
            button.buttonMode = true; button.mouseChildren = false;
            addBitmap(button, imageClass, 0, 0, w, h);
            if (label == "盛世秋歌") {
                button.graphics.beginFill(0x172431, 0.85); button.graphics.drawRect(0, 0, w, h); button.graphics.endFill();
                addText(button, label, 0, 7, w, 21, 13, WHITE, true, "center");
            }
            button.addEventListener(MouseEvent.ROLL_OVER, function(e:MouseEvent):void { button.alpha = 1; });
            button.addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void { button.alpha = 0.88; });
            button.alpha = 0.88;
            return button;
        }

        private function onNavigationClick(event:MouseEvent):void {
            var target:String = Sprite(event.currentTarget).name;
            if (target == "warehouse" || target == "home") page = target;
            else page = "offline";
            render();
        }

        private function drawProfileBar():void {
            var bar:Sprite = new Sprite();
            drawRect(bar, 4, 42, 283, 51, 0x101c27, 0.85);
            drawRect(bar, 4, 89, 283, 4, 0x58b7df, 0.9);
            addText(bar, "Lv." + profile.level + "  " + profile.gameId, 49, 48, 224, 23, 16, WHITE, true);
            addText(bar, profile.rank + "   VIP " + profile.vip, 50, 69, 220, 19, 13, 0xe99b55, true);
            addText(bar, "GP  " + profile.gp, 689, 48, 74, 22, 14, 0x74e866, true, "right");
            addText(bar, "金币  " + profile.gold, 824, 48, 82, 22, 14, GOLD, true, "right");
            addText(bar, "离线资料", 915, 48, 90, 22, 12, 0x74cda5, true, "right");
            rootLayer.addChild(bar);
        }

        private function drawLeftLoadout():void {
            var panel:Sprite = new Sprite();
            addText(panel, "角色展台", 16, 105, 250, 22, 15, GOLD, true);
            var roleName:String = selectedRole;
            var role:Object = findByKey(data.characters, selectedRole);
            if (role && role.name) roleName = String(role.name);
            addText(panel, roleName, 18, 132, 245, 25, 17, WHITE, true);
            addText(panel, "原版大厅角色预览资源", 18, 159, 245, 20, 11, MUTED);
            var rolePath:String = previewPath("characters", selectedRole);
            if (rolePath) loadPreview(panel, rolePath, 48, 188, 194, 216);
            else {
                drawRect(panel, 38, 184, 215, 220, 0x0a121a, 0.62);
                addText(panel, "3D 展台资源待接入", 50, 280, 190, 24, 13, MUTED, false, "center");
            }
            makeButton(panel, "角色选择", 79, 405, 133, 27, BLUE, function():void { page = "roles"; render(); });
            addText(panel, "方案 " + selectedBag + "   ·   主武器", 17, 446, 255, 20, 12, GOLD, true);
            drawBagTabs(panel, 17, 468);
            var slotNames:Array = ["主武器", "副武器", "近战", "投掷"];
            var values:Array = [selectedWeapon, "deagle", "dagger", "grenade"];
            for (var i:int = 0; i < 4; i++) {
                var sy:Number = 496 + i * 34;
                drawRect(panel, 13, sy, 258, 31, 0x111d28, 0.78);
                addText(panel, slotNames[i], 20, sy + 6, 54, 18, 11, MUTED);
                addText(panel, String(values[i]), 76, sy + 5, 132, 20, 12, WHITE, true);
                makeButton(panel, "换装", 214, sy + 4, 48, 22, 0x697c8b, function():void { page = "warehouse"; render(); });
            }
            pageLayer.addChild(panel);
        }

        private function drawBagTabs(parent:Sprite, x:Number, y:Number):void {
            for (var i:int = 1; i <= 5; i++) {
                var bag:int = i;
                makeButton(parent, String(i), x + (i - 1) * 46, y, 40, 24,
                    bag == selectedBag ? 0x5b9fc2 : 0x273340,
                    makeBagAction(bag));
            }
        }

        private function makeBagAction(bag:int):Function {
            return function():void {
                selectedBag = bag;
                if (equipped[selectedBag] && equipped[selectedBag].primary) selectedWeapon = String(equipped[selectedBag].primary);
                else selectedWeapon = "m4a1";
                saveState(); render();
            };
        }

        private function drawHome():void {
            var content:Sprite = new Sprite();
            addText(content, "游戏大厅", 322, 111, 590, 34, 25, WHITE, true);
            addText(content, "选择频道与模式后再进入对局", 324, 148, 590, 24, 14, MUTED);
            makeButton(content, "经典竞技", 327, 198, 272, 55, 0x65717a, function():void { page = "mode"; render(); });
            makeButton(content, "娱乐竞技", 610, 198, 272, 55, 0xc69b44, function():void { page = "mode"; render(); });
            var channels:Array = ["新手频道 1", "自由频道 1", "自由频道 2", "人机频道 1"];
            var positions:Array = [[324,278],[610,278],[324,362],[610,362]];
            for (var i:int = 0; i < channels.length; i++) {
                var position:Array = positions[i];
                var channel:String = channels[i];
                var card:Sprite = new Sprite();
                drawRect(card, position[0], position[1], 270, 70, 0x192733, 0.84);
                drawRect(card, position[0], position[1], 3, 70, 0x4e9fc4, 1);
                addText(card, channel, position[0] + 19, position[1] + 17, 160, 24, 16, WHITE, true);
                addText(card, "空闲   ·   选择模式和地图", position[0] + 19, position[1] + 43, 232, 18, 11, MUTED);
                card.buttonMode = true;
                card.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { page = "mode"; render(); });
                content.addChild(card);
            }
            makeButton(content, "仓库", 324, 465, 158, 35, 0x526d82, function():void { page = "warehouse"; render(); });
            makeButton(content, "角色", 491, 465, 158, 35, 0x526d82, function():void { page = "roles"; render(); });
            addText(content, "点击频道会先进入模式与地图选择", 324, 521, 480, 22, 12, 0xbec7cd);
            pageLayer.addChild(content);
        }

        private function drawModePicker():void {
            drawRect(pageLayer, 0, 40, SW, 610, 0x05090e, 0.64);
            var dialog:Sprite = new Sprite();
            drawRect(dialog, 82, 76, 860, 510, 0x101e2a, 0.98);
            drawRect(dialog, 82, 76, 860, 2, 0x4b9cc0, 1);
            addText(dialog, "选择模式与地图", 110, 94, 760, 32, 23, GOLD, true);
            addText(dialog, "游戏模式", 112, 150, 250, 22, 15, WHITE, true);
            addText(dialog, "选择地图", 395, 150, 300, 22, 15, WHITE, true);
            var modes:Array = ["团队竞技", "爆破战", "刀战", "人机对战"];
            for (var i:int = 0; i < modes.length; i++) {
                var mode:String = modes[i];
                makeButton(dialog, mode, 108, 184 + i * 63, 230, 48, i == 3 ? 0x2f6881 : 0x263747, makeSelectionMessage("已选择模式：" + mode));
            }
            var maps:Array = ["运输船", "沙漠2", "仓库", "炼狱"];
            for (var j:int = 0; j < maps.length; j++) {
                var map:String = maps[j];
                makeButton(dialog, map, 387 + (j % 2) * 244, 184 + int(j / 2) * 106, 222, 84, j == 0 ? 0x8b6d34 : 0x263747, makeSelectionMessage("已选择地图：" + map));
            }
            makeButton(dialog, "返回大厅", 109, 523, 170, 37, 0x304050, function():void { page = "home"; render(); });
            makeButton(dialog, "确认并查看房间", 670, 523, 225, 37, 0xc39840, function():void { showMessage("离线房间列表尚未接入；本地模式与地图选择已保留。", false); });
            pageLayer.addChild(dialog);
        }

        private function drawWarehouse():void {
            drawPanelBackground(WarehouseBackground, 286, 79, 653, 531);
            makeButton(pageLayer, "返回", 301, 88, 83, 29, 0xb4933f, function():void { page = "home"; render(); });
            addText(pageLayer, "个人仓库", 393, 91, 200, 25, 19, GOLD, true);
            var tabs:Array = ["礼包", "武器", "角色", "皮肤", "道具"];
            for (var t:int = 0; t < tabs.length; t++) {
                var label:String = tabs[t];
                makeButton(pageLayer, label, 476 + t * 84, 119, 78, 29,
                    label == "武器" ? 0x99783d : 0x263748,
                    makeWarehouseTabAction(label));
            }
            drawWeaponFilter();
            drawWeaponGrid();
            drawPager();
        }

        private function makeWarehouseTabAction(label:String):Function {
            return function():void {
                if (label == "角色") { page = "roles"; render(); return; }
                if (label != "武器") showMessage(label + "页尚未接入；当前武器仓库使用原版大厅资源。", false);
            };
        }

        private function drawWeaponFilter():void {
            var filters:Array = ["全部", "主武器", "副武器", "近战武器", "投掷武器"];
            for (var i:int = 0; i < filters.length; i++) {
                var filter:String = filters[i];
                makeButton(pageLayer, filter, 476 + i * 91, 154, 84, 25,
                    filter == weaponCategory ? 0x447f9d : 0x1a2935,
                    makeFilterAction(filter));
            }
            var search:TextField = new TextField();
            search.defaultTextFormat = new TextFormat("Microsoft YaHei", 12, WHITE);
            search.type = TextFieldType.INPUT;
            search.background = true; search.backgroundColor = 0x111c25;
            search.border = true; search.borderColor = 0x536b7a;
            search.x = 476; search.y = 181; search.width = 242; search.height = 25;
            search.text = weaponSearch;
            search.addEventListener(Event.CHANGE, function(e:Event):void { weaponSearch = search.text; weaponPage = 0; drawWeaponGrid(); drawPager(); });
            pageLayer.addChild(search);
            addText(pageLayer, "选择背包 " + selectedBag, 729, 181, 145, 23, 12, GOLD, true);
        }

        private function visibleWeapons():Array {
            var rows:Array = data.weapons as Array;
            var result:Array = [];
            var query:String = weaponSearch.toLowerCase();
            for each (var weapon:Object in rows) {
                if (weaponCategory != "全部" && String(weapon.category) != weaponCategory) continue;
                if (query && String(weapon.key).toLowerCase().indexOf(query) < 0 && String(weapon.name).toLowerCase().indexOf(query) < 0) continue;
                result.push(weapon);
            }
            return result;
        }

        private function drawWeaponGrid():void {
            var existing:Array = [];
            for (var i:int = 0; i < pageLayer.numChildren; i++) {
                var child:DisplayObject = pageLayer.getChildAt(i);
                if (child.name == "weapon-grid") existing.push(child);
            }
            for each (var old:DisplayObject in existing) pageLayer.removeChild(old);
            var grid:Sprite = new Sprite(); grid.name = "weapon-grid";
            var list:Array = visibleWeapons();
            var start:int = weaponPage * 6;
            for (var n:int = start; n < Math.min(start + 6, list.length); n++) {
                var weapon:Object = list[n];
                var col:int = (n - start) % 2;
                var row:int = int((n - start) / 2);
                var x:Number = 476 + col * 226;
                var y:Number = 212 + row * 99;
                drawWeaponCard(grid, weapon, x, y, 224, 96);
            }
            pageLayer.addChild(grid);
            drawPager();
        }

        private function drawWeaponCard(parent:Sprite, weapon:Object, x:Number, y:Number, w:Number, h:Number):void {
            var card:Sprite = new Sprite();
            card.x = x; card.y = y; card.buttonMode = true;
            var selected:Boolean = String(weapon.key) == selectedWeapon;
            addBitmap(card, selected ? WeaponCardSelected : WeaponCard, 0, 0, w, h);
            var path:String = previewPath("weapons", String(weapon.key));
            if (path) loadPreview(card, path, 7, 5, w - 14, 58);
            addText(card, String(weapon.name), 9, 60, 126, 20, 12, WHITE, true);
            addText(card, "永久", 169, 59, 45, 20, 14, GOLD, true, "right");
            addText(card, "装备", 173, 79, 42, 15, 10, BLUE, true, "right");
            card.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                selectedWeapon = String(weapon.key);
                if (!equipped[selectedBag]) equipped[selectedBag] = {};
                equipped[selectedBag].primary = selectedWeapon;
                saveState(); render();
                showMessage("已装备到 " + selectedBag + " 号背包：" + weapon.name, false);
            });
            parent.addChild(card);
        }

        private function drawPager():void {
            var existing:Array = [];
            for (var i:int = 0; i < pageLayer.numChildren; i++) {
                var child:DisplayObject = pageLayer.getChildAt(i);
                if (child.name == "pager") existing.push(child);
            }
            for each (var old:DisplayObject in existing) pageLayer.removeChild(old);
            var pager:Sprite = new Sprite(); pager.name = "pager";
            var pages:int = Math.max(1, Math.ceil(visibleWeapons().length / 6));
            makeButton(pager, "◀◀", 580, 516, 42, 26, 0x334c60, function():void { weaponPage = Math.max(0, weaponPage - 10); render(); });
            makeButton(pager, "◀", 626, 516, 32, 26, 0x334c60, function():void { weaponPage = Math.max(0, weaponPage - 1); render(); });
            addText(pager, (weaponPage + 1) + " / " + pages, 663, 518, 90, 22, 12, WHITE, true, "center");
            makeButton(pager, "▶", 753, 516, 32, 26, 0x334c60, function():void { weaponPage = Math.min(pages - 1, weaponPage + 1); render(); });
            makeButton(pager, "▶▶", 789, 516, 42, 26, 0x334c60, function():void { weaponPage = Math.min(pages - 1, weaponPage + 10); render(); });
            pageLayer.addChild(pager);
        }

        private function drawRoles():void {
            pageLayer.removeChildren();
            addBitmap(pageLayer, RoleBackground, 0, 40, SW, 610);
            addText(pageLayer, "角色选择", 23, 53, 250, 25, 18, GOLD, true);
            addText(pageLayer, "角色与皮肤按角色归属展示；此页读取大厅角色立绘索引", 25, 82, 650, 20, 12, MUTED);
            makeButton(pageLayer, "返回大厅", 852, 49, 132, 30, 0x435769, function():void { page = "home"; render(); });
            var rows:Array = data.characters as Array;
            var start:int = rolePage * 6;
            for (var i:int = start; i < Math.min(start + 6, rows.length); i++) {
                var role:Object = rows[i];
                var col:int = (i - start) % 3;
                var row:int = int((i - start) / 3);
                var card:Sprite = new Sprite();
                card.x = 294 + col * 235; card.y = 119 + row * 214;
                card.buttonMode = true;
                addBitmap(card, RoleCard, 0, 0, 218, 198);
                var path:String = previewPath("characters", String(role.key));
                if (path) loadPreview(card, path, 45, 14, 126, 132);
                addText(card, String(role.name || role.key), 10, 151, 198, 21, 13, WHITE, true, "center");
                addText(card, String(role.key), 10, 173, 198, 18, 10, MUTED, false, "center");
                card.addEventListener(MouseEvent.CLICK, makeRoleAction(role));
                pageLayer.addChild(card);
            }
            makeButton(pageLayer, "◀", 817, 548, 45, 27, 0x344d5f, function():void { rolePage = Math.max(0, rolePage - 1); render(); });
            addText(pageLayer, (rolePage + 1) + " / " + Math.ceil(rows.length / 6), 865, 551, 90, 22, 12, WHITE, true, "center");
            makeButton(pageLayer, "▶", 957, 548, 45, 27, 0x344d5f, function():void { rolePage = Math.min(Math.ceil(rows.length / 6) - 1, rolePage + 1); render(); });
        }

        private function makeFilterAction(filter:String):Function {
            return function():void { weaponCategory = filter; weaponPage = 0; render(); };
        }

        private function makeSelectionMessage(message:String):Function {
            return function():void { showMessage(message, false); };
        }

        private function makeRoleAction(role:Object):Function {
            return function(event:MouseEvent):void {
                selectedRole = String(role.key);
                saveState();
                render();
                showMessage("已选择角色：" + String(role.name || role.key), false);
            };
        }

        private function drawOfflinePanel():void {
            drawPanelBackground(WarehouseBackground, 286, 79, 653, 531);
            addText(pageLayer, "该功能的原版界面资源已索引", 350, 205, 530, 30, 19, WHITE, true, "center");
            addText(pageLayer, "尚未接入对应的本地交互数据，不会伪造在线服务成功结果。", 342, 247, 540, 28, 13, MUTED, false, "center");
            makeButton(pageLayer, "返回大厅", 520, 305, 165, 35, 0x536b7c, function():void { page = "home"; render(); });
        }

        private function previewPath(kind:String, key:String):String {
            if (!previewIndex || !previewIndex.by_key || !previewIndex.by_key[kind]) return "";
            return String(previewIndex.by_key[kind][key.toLowerCase()] || "");
        }

        private function loadPreview(parent:DisplayObjectContainer, relative:String, x:Number, y:Number, w:Number, h:Number):void {
            if (!relative || relative.indexOf("..") >= 0 || relative.indexOf("\\") >= 0) return;
            try {
                var loader:Loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void {
                    var display:DisplayObject = loader.content;
                    var bounds:Rectangle = display.getBounds(display);
                    if (bounds.width <= 0 || bounds.height <= 0) return;
                    var scale:Number = Math.min(w / bounds.width, h / bounds.height);
                    display.scaleX = display.scaleY = scale;
                    display.x = x + (w - bounds.width * scale) / 2 - bounds.x * scale;
                    display.y = y + (h - bounds.height * scale) / 2 - bounds.y * scale;
                    if (display is Bitmap) Bitmap(display).smoothing = true;
                    parent.addChild(display);
                });
                loader.load(new URLRequest("data/previews/official_lobby/" + relative));
            } catch (error:Error) {
                // Missing optional art is represented as an empty slot, not as a false preview.
            }
        }

        private function findByKey(rows:Array, key:String):Object {
            if (!rows) return null;
            for each (var row:Object in rows) if (String(row.key).toLowerCase() == key.toLowerCase()) return row;
            return null;
        }

        private function drawPanelBackground(asset:Class, x:Number, y:Number, w:Number, h:Number):void {
            addBitmap(pageLayer, asset, x, y, w, h);
        }

        private function addBitmap(parent:DisplayObjectContainer, asset:Class, x:Number, y:Number, w:Number, h:Number):Bitmap {
            var bitmap:Bitmap = new asset() as Bitmap;
            bitmap.x = x; bitmap.y = y;
            bitmap.width = w; bitmap.height = h;
            bitmap.smoothing = true;
            parent.addChild(bitmap);
            return bitmap;
        }

        private function drawRect(parent:Sprite, x:Number, y:Number, w:Number, h:Number, color:uint, alpha:Number):void {
            parent.graphics.beginFill(color, alpha);
            parent.graphics.drawRect(x, y, w, h);
            parent.graphics.endFill();
        }

        private function addText(parent:Sprite, text:String, x:Number, y:Number, w:Number, h:Number, size:int, color:uint, bold:Boolean=false, align:String="left"):TextField {
            var field:TextField = new TextField();
            field.defaultTextFormat = new TextFormat("Microsoft YaHei", size, color, bold, null, null, null, null, align);
            field.embedFonts = false;
            field.selectable = false;
            field.mouseEnabled = false;
            field.autoSize = TextFieldAutoSize.NONE;
            field.x = x; field.y = y; field.width = w; field.height = h;
            field.text = text;
            parent.addChild(field);
            return field;
        }

        private function makeButton(parent:DisplayObjectContainer, label:String, x:Number, y:Number, w:Number, h:Number, color:uint, action:Function):Sprite {
            var button:Sprite = new Sprite();
            button.x = x; button.y = y; button.buttonMode = true; button.mouseChildren = false;
            button.graphics.beginFill(color, 0.94); button.graphics.lineStyle(1, color == GOLD ? 0xe7c75d : 0x51758b, 1);
            button.graphics.drawRoundRect(0, 0, w, h, 3, 3); button.graphics.endFill();
            addText(button, label, 4, Math.max(2, (h - 20) / 2), w - 8, 21, h <= 27 ? 11 : 14, color == GOLD ? 0x28251a : WHITE, true, "center");
            button.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { action(); });
            button.addEventListener(MouseEvent.ROLL_OVER, function(event:MouseEvent):void { button.alpha = 1; });
            button.addEventListener(MouseEvent.ROLL_OUT, function(event:MouseEvent):void { button.alpha = 0.94; });
            parent.addChild(button);
            return button;
        }

        private function showMessage(text:String, isError:Boolean):void {
            messageLayer.removeChildren();
            var color:uint = isError ? 0x923a35 : 0x173f38;
            drawRect(messageLayer, 265, 606, 500, 32, color, 0.96);
            addText(messageLayer, text, 278, 612, 475, 21, 11, WHITE, true, "center");
            setTimeout(function():void { messageLayer.removeChildren(); }, 3600);
        }

        private function clamp(value:int, min:int, max:int):int {
            return Math.max(min, Math.min(max, value));
        }
    }
}
