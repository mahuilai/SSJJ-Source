package
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFieldType;
   import ui.UIButton;
   import ui.UIContainer;
   import ui.UILabel;
   import utils.UIUtil;

   public class CleanSubViews
   {
      private var _root:CleanLobbyRoot;

      // Subview Containers
      private var _storageContainer:Sprite;
      private var _mallContainer:Sprite;
      private var _roleSelectContainer:Sprite;
      private var _mapSelectContainer:Sprite;

      // Storage State
      private var _storageTab:String = "weapon"; // weapon | role | skin | stuff | pack
      private var _storageWeaponSubSlot:int = 0; // 0=全部, 1=主武器, 2=副武器, 3=近战, 4=投掷
      private var _storagePage:int = 0;
      private var _storagePageSize:int = 12;
      private var _storageSearchText:String = "";
      private var _storageItemsGrid:Sprite;
      private var _storagePageLabel:TextField;

      // Left-Side BagView Panel in Storage
      private var _storageBagView:UIContainer;
      private var _storageBagTabBar:Sprite;

      // Role Select State
      private var _roleTab:int = 1; // 1=普通, 2=变异, 6=英雄
      private var _rolePage:int = 0;
      private var _rolePageSize:int = 8;
      private var _roleSearchText:String = "";
      private var _roleItemsGrid:Sprite;
      private var _rolePageLabel:TextField;
      private var _selectedPreviewRole:Object = null;

      // Mall State
      private var _mallTab:String = "weapon"; // weapon | role | skin | pack | hero | legend
      private var _mallPage:int = 0;
      private var _mallPageSize:int = 12;
      private var _mallSearchText:String = "";
      private var _mallItemsGrid:Sprite;
      private var _mallPageLabel:TextField;

      public function CleanSubViews(root:CleanLobbyRoot)
      {
         _root = root;
      }

      public function closeAllSubViews() : void
      {
         _root.overlayLayer.removeChildren();
         _storageContainer = null;
         _mallContainer = null;
         _roleSelectContainer = null;
         _mapSelectContainer = null;
      }

      public function on3DSceneLoaded() : void
      {
         if(_roleSelectContainer && _roleSelectContainer.visible)
         {
            var cut:DisplayObject = _roleSelectContainer.getChildByName("imgCut");
            if(cut) cut.visible = false;
         }
      }

      // ======================================================================
      // 1. 个人仓库 (Personal Storage)
      // ======================================================================
      public function openStorageView(initialTab:String = "weapon") : void
      {
         closeAllSubViews();
         if(_root.hallModeView) _root.hallModeView.visible = false;

         _storageTab = initialTab;
         _storagePage = 0;
         _storageSearchText = "";
         _storageContainer = new Sprite();
         _root.overlayLayer.addChild(_storageContainer);

         // Background Dimmer
         var mask:Sprite = new Sprite();
         mask.graphics.beginFill(0x040810, 0.7);
         mask.graphics.drawRect(0, 0, 1024, 650);
         mask.graphics.endFill();
         _storageContainer.addChild(mask);

         // Left-Side Full BagView
         buildStorageBagPanel();

         // Right-Side Storage View
         buildStorageRightPanel();

         _storageContainer.addChild(makeCloseButton(986, 12, function():void {
            _root.showHallHome();
         }));
      }

      private function buildStorageBagPanel() : void
      {
         _storageBagView = new UIContainer();
         UIUtil.initUI(_storageBagView, _root.xmlBagView, _root.xmlBagView);
         _storageBagView.x = 10;
         _storageBagView.y = 48;
         _storageContainer.addChild(_storageBagView);

         if("fixAllBtn" in _storageBagView && _storageBagView["fixAllBtn"] is DisplayObject)
         {
            (_storageBagView["fixAllBtn"] as DisplayObject).visible = false;
         }
         if("goldSuitBtn" in _storageBagView && _storageBagView["goldSuitBtn"] is DisplayObject)
         {
            (_storageBagView["goldSuitBtn"] as DisplayObject).visible = false;
         }
         if("topBagWeaponUI" in _storageBagView && _storageBagView["topBagWeaponUI"] is DisplayObject)
         {
            (_storageBagView["topBagWeaponUI"] as DisplayObject).visible = false;
         }
         if("btnTopWeapon" in _storageBagView && _storageBagView["btnTopWeapon"] is DisplayObject)
         {
            (_storageBagView["btnTopWeapon"] as DisplayObject).visible = false;
         }

         _storageBagTabBar = new Sprite();
         _storageBagTabBar.x = 2;
         _storageBagTabBar.y = 36;
         _storageBagView.addChild(_storageBagTabBar);

         refreshStorageBagTabBar();
         refreshStorageBagSlots();
      }

      private function refreshStorageBagTabBar() : void
      {
         if(!_storageBagTabBar) return;
         _storageBagTabBar.removeChildren();
         var selIdx:int = int(_root.userProfile.selectedBagIndex || 0);
         for(var i:int = 0; i < 5; i++)
         {
            var isSel:Boolean = (i == selIdx);
            var tab:Sprite = new Sprite();
            tab.buttonMode = true;
            tab.useHandCursor = true;
            tab.graphics.lineStyle(1, isSel ? 0xf2c96d : 0x2e4966, 0.9);
            tab.graphics.beginFill(isSel ? 0x1a4670 : 0x0c1724, 0.95);
            tab.graphics.drawRoundRect(0, 0, 35, 22, 4, 4);
            tab.graphics.endFill();
            tab.x = i * 38;

            var tf:TextField = CleanLobbyRoot.makeTf("背包" + (i + 1), 11, isSel ? 0xfff0a0 : 0x88b0d8, isSel);
            tf.x = 3;
            tf.y = 2;
            tab.addChild(tf);

            var bagIdx:int = i;
            tab.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
               _root.userProfile.selectedBagIndex = bagIdx;
               refreshStorageBagTabBar();
               refreshStorageBagSlots();
               _root.refreshBagSwitchTabs();
               _root.refreshSmallBagView();
               _root.refreshTopAndLeftInfo();
               _root.update3DRoleWeaponView();
               _root.saveProfile();
               _root.showToast("已选中 背包 " + (bagIdx + 1));
            });
            _storageBagTabBar.addChild(tab);
         }
      }

      private function refreshStorageBagSlots() : void
      {
         if(!_storageBagView) return;
         var bag:Object = _root.getCurrentBag();
         populateStorageCell(_storageBagView["cellMaster"], bag.master, 177, 101, "主武器", 1);
         populateStorageCell(_storageBagView["cellSeondary"], bag.secondary, 177, 101, "副武器", 2);
         populateStorageCell(_storageBagView["cellClosed"], bag.closed, 177, 101, "近战", 3);
         populateStorageCell(_storageBagView["cellBoom1"], bag.bom1, 57, 93, "手雷", 4);
         populateStorageCell(_storageBagView["cellBoom2"], bag.bom2, 57, 93, "闪光", 4);
         populateStorageCell(_storageBagView["cellBoom3"], bag.bom3, 57, 93, "烟雾", 4);
      }

      private function populateStorageCell(cell:Object, slotData:Object, w:int, h:int, title:String, slotType:int) : void
      {
         var sp:Sprite = cell as Sprite;
         if(!sp) return;
         var oldOverlay:DisplayObject = sp.getChildByName("__cellOverlay");
         if(oldOverlay) sp.removeChild(oldOverlay);

         var ov:Sprite = new Sprite();
         ov.name = "__cellOverlay";
         ov.graphics.lineStyle(1, 0x365476, 0.85);
         ov.graphics.beginFill(0x0e1a2a, 0.94);
         ov.graphics.drawRoundRect(0, 0, w, h, 4, 4);
         ov.graphics.endFill();

         var code:String = slotData ? String(slotData.codeName || "") : "";
         var tid:int = slotData ? int(slotData.tid || 0) : 0;
         var wInfo:Object = _root.weaponsByTid[tid] || _root.weaponsByCode[code];
         var nameStr:String = wInfo ? String(wInfo.n) : (code != "" ? code : title);

         if(code != "")
         {
            CleanLobbyRoot.loadPreviewImage("weapon/" + code, ov, 4, 18, w - 8, h - 38);
         }

         var tagTf:TextField = CleanLobbyRoot.makeTf(title, 11, 0x76a8d8, false);
         tagTf.x = 6;
         tagTf.y = 2;
         ov.addChild(tagTf);

         var nameTf:TextField = CleanLobbyRoot.makeTf(nameStr, 12, 0xffffff, true);
         nameTf.x = 6;
         nameTf.y = h - 22;
         nameTf.width = w - 12;
         ov.addChild(nameTf);

         if(slotData != null && code != "")
         {
            var unequipBtn:Sprite = makeSmallButton("卸下", 40, 18, 0x6e2828);
            unequipBtn.x = w - 44;
            unequipBtn.y = 2;
            unequipBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
               unequipFromBag(slotType);
            });
            ov.addChild(unequipBtn);
         }
         sp.addChild(ov);
      }

      private function unequipFromBag(slotType:int) : void
      {
         var bag:Object = _root.getCurrentBag();
         if(slotType == 1) bag.master = null;
         else if(slotType == 2) bag.secondary = null;
         else if(slotType == 3) bag.closed = null;
         else if(slotType == 4) bag.bom1 = null;

         refreshStorageBagSlots();
         _root.refreshSmallBagView();
         _root.update3DRoleWeaponView();
         _root.saveProfile();
         _root.showToast("已卸下装备");
      }

      private function buildStorageRightPanel() : void
      {
         var rightPanel:Sprite = new Sprite();
         rightPanel.x = 210;
         rightPanel.y = 48;
         _storageContainer.addChild(rightPanel);

         // Panel Frame
         var bg:Sprite = new Sprite();
         bg.graphics.lineStyle(1, 0x334e6e, 0.9);
         bg.graphics.beginFill(0x0c1522, 0.96);
         bg.graphics.drawRoundRect(0, 0, 804, 592, 6, 6);
         bg.graphics.endFill();
         rightPanel.addChild(bg);

         // Title & Tab Bar
         var tabs:Array = [
            {"id":"weapon", "label":"武器仓库"},
            {"id":"role",   "label":"角色仓库"},
            {"id":"skin",   "label":"皮肤仓库"},
            {"id":"stuff",  "label":"道具仓库"},
            {"id":"pack",   "label":"礼包仓库"}
         ];

         for(var i:int = 0; i < tabs.length; i++)
         {
            var t:Object = tabs[i];
            var isSel:Boolean = (t.id == _storageTab);
            var tabBtn:Sprite = new Sprite();
            tabBtn.buttonMode = true;
            tabBtn.useHandCursor = true;
            tabBtn.graphics.lineStyle(1, isSel ? 0xf2c96d : 0x2e4a6a, 0.9);
            tabBtn.graphics.beginFill(isSel ? 0x1e4a78 : 0x111e2e, 0.95);
            tabBtn.graphics.drawRoundRect(0, 0, 92, 28, 4, 4);
            tabBtn.graphics.endFill();
            tabBtn.x = 16 + i * 98;
            tabBtn.y = 12;

            var tf:TextField = CleanLobbyRoot.makeTf(t.label, 13, isSel ? 0xfff0a0 : 0xa4c6e6, isSel);
            tf.x = int((92 - tf.textWidth) * 0.5);
            tf.y = 4;
            tabBtn.addChild(tf);

            var tidKey:String = t.id;
            tabBtn.addEventListener(MouseEvent.CLICK, makeStorageTabSwitch(tidKey));
            rightPanel.addChild(tabBtn);
         }

         // Search Input Box
         var searchBox:Sprite = new Sprite();
         searchBox.x = 540;
         searchBox.y = 12;
         searchBox.graphics.lineStyle(1, 0x334e6e, 0.9);
         searchBox.graphics.beginFill(0x070e17, 1);
         searchBox.graphics.drawRoundRect(0, 0, 160, 26, 4, 4);
         searchBox.graphics.endFill();
         rightPanel.addChild(searchBox);

         var searchInput:TextField = new TextField();
         searchInput.type = TextFieldType.INPUT;
         var sFmt:TextFormat = new TextFormat("Microsoft YaHei", 12, 0xffffff);
         searchInput.defaultTextFormat = sFmt;
         searchInput.x = 6;
         searchInput.y = 3;
         searchInput.width = 148;
         searchInput.height = 20;
         searchInput.text = _storageSearchText;
         searchInput.addEventListener(Event.CHANGE, function(e:Event):void {
            _storageSearchText = searchInput.text;
            _storagePage = 0;
            renderStorageGrid();
         });
         searchBox.addChild(searchInput);

         var searchBtn:Sprite = makeSmallButton("搜索", 50, 26, 0x245480);
         searchBtn.x = 706;
         searchBtn.y = 12;
         searchBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            _storagePage = 0;
            renderStorageGrid();
         });
         rightPanel.addChild(searchBtn);

         // Sub-Filter row for Weapons (全部 / 主武器 / 副武器 / 近战 / 投掷)
         if(_storageTab == "weapon")
         {
            var subRow:Sprite = new Sprite();
            subRow.x = 16;
            subRow.y = 46;
            var subFilters:Array = [
               {"slot":0, "name":"全部武器"},
               {"slot":1, "name":"主武器"},
               {"slot":2, "name":"副武器"},
               {"slot":3, "name":"近战武器"},
               {"slot":4, "name":"投掷武器"}
            ];
            for(var sIdx:int = 0; sIdx < subFilters.length; sIdx++)
            {
               var sf:Object = subFilters[sIdx];
               var isSubSel:Boolean = (_storageWeaponSubSlot == sf.slot);
               var sbtn:Sprite = new Sprite();
               sbtn.buttonMode = true;
               sbtn.useHandCursor = true;
               sbtn.graphics.lineStyle(1, isSubSel ? 0xf2c96d : 0x283e54, 0.85);
               sbtn.graphics.beginFill(isSubSel ? 0x224e7a : 0x0f1b28, 0.9);
               sbtn.graphics.drawRoundRect(0, 0, 72, 22, 4, 4);
               sbtn.graphics.endFill();
               sbtn.x = sIdx * 78;

               var stf:TextField = CleanLobbyRoot.makeTf(sf.name, 11, isSubSel ? 0xffea9f : 0x8ab0d2, isSubSel);
               stf.x = int((72 - stf.textWidth) * 0.5);
               stf.y = 2;
               sbtn.addChild(stf);

               var slotVal:int = sf.slot;
               sbtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                  _storageWeaponSubSlot = slotVal;
                  _storagePage = 0;
                  openStorageView("weapon");
               });
               subRow.addChild(sbtn);
            }
            rightPanel.addChild(subRow);
         }

         // Item Cards Grid
         _storageItemsGrid = new Sprite();
         _storageItemsGrid.x = 16;
         _storageItemsGrid.y = (_storageTab == "weapon") ? 74 : 50;
         rightPanel.addChild(_storageItemsGrid);

         // Pagination Controls
         var pager:Sprite = new Sprite();
         pager.x = 260;
         pager.y = 554;
         rightPanel.addChild(pager);

         var prevBtn:Sprite = makeSmallButton("上一页", 70, 26, 0x1c3a58);
         prevBtn.x = 0;
         prevBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            if(_storagePage > 0) {
               _storagePage--;
               renderStorageGrid();
            }
         });
         pager.addChild(prevBtn);

         _storagePageLabel = CleanLobbyRoot.makeTf("1 / 1", 13, 0xffffff, true);
         _storagePageLabel.x = 88;
         _storagePageLabel.y = 3;
         pager.addChild(_storagePageLabel);

         var nextBtn:Sprite = makeSmallButton("下一页", 70, 26, 0x1c3a58);
         nextBtn.x = 160;
         nextBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            _storagePage++;
            renderStorageGrid();
         });
         pager.addChild(nextBtn);

         renderStorageGrid();
      }

      private function makeStorageTabSwitch(tabKey:String) : Function
      {
         return function(e:MouseEvent):void {
            _storageTab = tabKey;
            _storagePage = 0;
            openStorageView(tabKey);
         };
      }

      private function getFilteredStorageItems() : Array
      {
         var list:Array = [];
         var targetType:int = 1;
         if(_storageTab == "weapon") targetType = 1;
         else if(_storageTab == "role") targetType = 2;
         else if(_storageTab == "skin") targetType = 8;
         else if(_storageTab == "stuff") targetType = 3;
         else if(_storageTab == "pack") targetType = 4;

         var search:String = _storageSearchText ? _storageSearchText.toLowerCase() : "";

         for(var i:int = 0; i < _root.catalogItems.length; i++)
         {
            var it:Object = _root.catalogItems[i];
            if(it.t != targetType) continue;
            if(_storageTab == "weapon" && _storageWeaponSubSlot > 0 && it.sl != _storageWeaponSubSlot) continue;
            if(search != "")
            {
               var n:String = it.n ? it.n.toLowerCase() : "";
               var c:String = it.c ? it.c.toLowerCase() : "";
               if(n.indexOf(search) == -1 && c.indexOf(search) == -1) continue;
            }
            list.push(it);
         }
         return list;
      }

      private function renderStorageGrid() : void
      {
         if(!_storageItemsGrid) return;
         _storageItemsGrid.removeChildren();

         var items:Array = getFilteredStorageItems();
         var totalPages:int = Math.max(1, Math.ceil(items.length / _storagePageSize));
         if(_storagePage >= totalPages) _storagePage = totalPages - 1;
         if(_storagePage < 0) _storagePage = 0;

         if(_storagePageLabel)
         {
            _storagePageLabel.text = (_storagePage + 1) + " / " + totalPages + " (共 " + items.length + " 件)";
         }

         var startIdx:int = _storagePage * _storagePageSize;
         var endIdx:int = Math.min(items.length, startIdx + _storagePageSize);

         var cardW:int = 185;
         var cardH:int = 110;

         for(var i:int = startIdx; i < endIdx; i++)
         {
            var it:Object = items[i];
            var col:int = (i - startIdx) % 4;
            var row:int = int((i - startIdx) / 4);

            var card:Sprite = new Sprite();
            card.x = col * (cardW + 10);
            card.y = row * (cardH + 8);
            card.graphics.lineStyle(1, 0x2e4660, 0.9);
            card.graphics.beginFill(0x101b2a, 0.95);
            card.graphics.drawRoundRect(0, 0, cardW, cardH, 4, 4);
            card.graphics.endFill();

            // Preview Thumbnail
            if(it.t == 1 && it.c) CleanLobbyRoot.loadPreviewImage("weapon/" + it.c, card, 6, 6, cardW - 12, 60);
            else if(it.t == 2 && it.c) CleanLobbyRoot.loadPreviewImage("role/" + it.c, card, 6, 6, cardW - 12, 60);
            else if(it.t == 8 && it.id) CleanLobbyRoot.loadPreviewImage("skin/" + it.id, card, 6, 6, cardW - 12, 60);
            else if(it.c) CleanLobbyRoot.loadPreviewImage("weapon/" + it.c, card, 6, 6, cardW - 12, 60);

            // Item Name
            var nameTf:TextField = CleanLobbyRoot.makeTf(String(it.n || it.c), 12, 0xffffff, true);
            nameTf.x = 6;
            nameTf.y = 66;
            nameTf.width = cardW - 12;
            card.addChild(nameTf);

            // Equip Button
            var equipBtn:Sprite = makeSmallButton(it.t == 2 ? "出战" : "装备", 52, 20, 0x205688);
            equipBtn.x = cardW - 58;
            equipBtn.y = cardH - 25;
            var curItem:Object = it;
            equipBtn.addEventListener(MouseEvent.CLICK, makeEquipHandler(curItem));
            card.addChild(equipBtn);

            _storageItemsGrid.addChild(card);
         }
      }

      private function makeEquipHandler(it:Object) : Function
      {
         return function(e:MouseEvent):void {
            equipItemToCurrentBag(it);
         };
      }

      public function equipItemToCurrentBag(it:Object) : void
      {
         var bag:Object = _root.getCurrentBag();
         if(it.t == 1) // Weapon
         {
            var wSlot:int = int(it.sl || 1);
            var itemData:Object = {
               "storageId": 10000000 + int(it.id),
               "tid": int(it.id),
               "codeName": String(it.c)
            };
            if(wSlot == 1) bag.master = itemData;
            else if(wSlot == 2) bag.secondary = itemData;
            else if(wSlot == 3) bag.closed = itemData;
            else if(wSlot == 4) bag.bom1 = itemData;
            else bag.master = itemData;

            _root.showToast("已将 【" + it.n + "】 装备到 当前背包！");
         }
         else if(it.t == 2) // Role
         {
            var team:int = int(_root.userProfile.team || 1);
            if(team == 2) bag.roleCTID = int(it.id);
            else bag.roleTID = int(it.id);
            _root.userProfile.defaultAvatar = int(it.id);
            _root.userProfile.defaultCareer = String(it.c);
            _root.showToast("已选择 【" + it.n + "】 出战！");
         }
         else if(it.t == 8) // Skin
         {
            if(!_root.userProfile.equippedSkins) _root.userProfile.equippedSkins = {};
            _root.userProfile.equippedSkins[String(it.id)] = it.c;
            _root.showToast("已应用皮肤 【" + it.n + "】");
         }
         else
         {
            _root.showToast("已使用 【" + it.n + "】");
         }

         refreshStorageBagSlots();
         _root.refreshSmallBagView();
         _root.refreshTopAndLeftInfo();
         _root.update3DRoleWeaponView();
         _root.saveProfile();
      }

      // ======================================================================
      // 2. 角色选择 (Role Select View)
      // ======================================================================
      public function openRoleSelectView() : void
      {
         closeAllSubViews();
         if(_root.hallModeView) _root.hallModeView.visible = false;

         _roleTab = 1;
         _rolePage = 0;
         _roleSearchText = "";
         _selectedPreviewRole = _root.getCurrentRoleObject();

         _roleSelectContainer = new Sprite();
         _root.overlayLayer.addChild(_roleSelectContainer);

         // Load Official NewRole XML
         var roleUI:UIContainer = new UIContainer();
         UIUtil.initUI(roleUI, _root.xmlNewRoleView.NewRole[0], _root.xmlNewRoleView);
         _roleSelectContainer.addChild(roleUI);

         // Hide unused tabs
         var hideList:Array = ["tabMain_3", "tabMain_4", "tabMain_5", "tabMain_7", "redMain_1", "redMain_2", "redMain_3", "redMain_4"];
         for each(var hn:String in hideList)
         {
            if((hn in roleUI) && roleUI[hn] is DisplayObject) (roleUI[hn] as DisplayObject).visible = false;
         }

         CleanLobbyRoot.wireBtn(roleUI["btnClose"], function():void {
            _root.showHallHome();
         });

         // Tab buttons: 1=普通角色, 6=英雄角色, 2=变异体
         CleanLobbyRoot.wireBtn(roleUI["tabMain_1"], function():void { _roleTab = 1; _rolePage = 0; renderRoleGrid(); });
         CleanLobbyRoot.wireBtn(roleUI["tabMain_6"], function():void { _roleTab = 6; _rolePage = 0; renderRoleGrid(); });
         CleanLobbyRoot.wireBtn(roleUI["tabMain_2"], function():void { _roleTab = 2; _rolePage = 0; renderRoleGrid(); });

         // Search Box & Role Items Grid on the Right
         var rightPanel:Sprite = new Sprite();
         rightPanel.x = 646;
         rightPanel.y = 48;
         _roleSelectContainer.addChild(rightPanel);

         var searchBox:Sprite = new Sprite();
         searchBox.graphics.lineStyle(1, 0x3b587a, 0.9);
         searchBox.graphics.beginFill(0x0a1420, 1);
         searchBox.graphics.drawRoundRect(0, 0, 240, 26, 4, 4);
         searchBox.graphics.endFill();
         rightPanel.addChild(searchBox);

         var searchInput:TextField = new TextField();
         searchInput.type = TextFieldType.INPUT;
         searchInput.defaultTextFormat = new TextFormat("Microsoft YaHei", 12, 0xffffff);
         searchInput.x = 6;
         searchInput.y = 3;
         searchInput.width = 228;
         searchInput.height = 20;
         searchInput.addEventListener(Event.CHANGE, function(e:Event):void {
            _roleSearchText = searchInput.text;
            _rolePage = 0;
            renderRoleGrid();
         });
         searchBox.addChild(searchInput);

         _roleItemsGrid = new Sprite();
         _roleItemsGrid.y = 36;
         rightPanel.addChild(_roleItemsGrid);

         // Pager
         var pager:Sprite = new Sprite();
         pager.x = 40;
         pager.y = 520;
         rightPanel.addChild(pager);

         var prevBtn:Sprite = makeSmallButton("上一页", 65, 24, 0x1d3d5d);
         prevBtn.x = 0;
         prevBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            if(_rolePage > 0) { _rolePage--; renderRoleGrid(); }
         });
         pager.addChild(prevBtn);

         _rolePageLabel = CleanLobbyRoot.makeTf("1 / 1", 12, 0xffffff, true);
         _rolePageLabel.x = 80;
         _rolePageLabel.y = 3;
         pager.addChild(_rolePageLabel);

         var nextBtn:Sprite = makeSmallButton("下一页", 65, 24, 0x1d3d5d);
         nextBtn.x = 180;
         nextBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            _rolePage++;
            renderRoleGrid();
         });
         pager.addChild(nextBtn);

         renderRoleGrid();
         previewRoleInCenter(_selectedPreviewRole);
      }

      private function getFilteredRoles() : Array
      {
         var list:Array = [];
         var search:String = _roleSearchText ? _roleSearchText.toLowerCase() : "";
         for(var i:int = 0; i < _root.rolesList.length; i++)
         {
            var r:Object = _root.rolesList[i];
            if(_roleTab == 1 && r.rt != 1) continue;
            if(_roleTab == 2 && r.rt != 2 && r.rt != 3) continue;
            if(_roleTab == 6 && r.rt != 6 && r.q != 3) continue;
            if(search != "")
            {
               var n:String = r.n ? r.n.toLowerCase() : "";
               var c:String = r.c ? r.c.toLowerCase() : "";
               if(n.indexOf(search) == -1 && c.indexOf(search) == -1) continue;
            }
            list.push(r);
         }
         return list;
      }

      private function renderRoleGrid() : void
      {
         if(!_roleItemsGrid) return;
         _roleItemsGrid.removeChildren();

         var roles:Array = getFilteredRoles();
         var totalPages:int = Math.max(1, Math.ceil(roles.length / _rolePageSize));
         if(_rolePage >= totalPages) _rolePage = totalPages - 1;
         if(_rolePage < 0) _rolePage = 0;

         if(_rolePageLabel)
         {
            _rolePageLabel.text = (_rolePage + 1) + " / " + totalPages + " (共 " + roles.length + " 位)";
         }

         var startIdx:int = _rolePage * _rolePageSize;
         var endIdx:int = Math.min(roles.length, startIdx + _rolePageSize);

         var cardW:int = 160;
         var cardH:int = 110;

         for(var i:int = startIdx; i < endIdx; i++)
         {
            var r:Object = roles[i];
            var col:int = (i - startIdx) % 2;
            var row:int = int((i - startIdx) / 2);

            var card:Sprite = new Sprite();
            card.x = col * (cardW + 12);
            card.y = row * (cardH + 8);
            card.buttonMode = true;
            card.useHandCursor = true;

            var isCurDeploy:Boolean = (_root.userProfile.defaultAvatar == r.id);
            card.graphics.lineStyle(1, isCurDeploy ? 0xf2c96d : 0x2e4660, 0.9);
            card.graphics.beginFill(isCurDeploy ? 0x18344e : 0x0f1c2c, 0.95);
            card.graphics.drawRoundRect(0, 0, cardW, cardH, 4, 4);
            card.graphics.endFill();

            // Role Portrait
            if(r.c) CleanLobbyRoot.loadPreviewImage("role/" + r.c, card, 6, 6, 80, 96);

            // Role Name & Faction
            var nameTf:TextField = CleanLobbyRoot.makeTf(String(r.n), 12, 0xffffff, true);
            nameTf.x = 90;
            nameTf.y = 8;
            nameTf.width = 65;
            card.addChild(nameTf);

            var facStr:String = (r.g == 1) ? "联军" : (r.g == 2 ? "风暴" : "变异");
            var facTf:TextField = CleanLobbyRoot.makeTf(facStr, 11, 0x86b0d8, false);
            facTf.x = 90;
            facTf.y = 28;
            card.addChild(facTf);

            // Deploy Button
            var deployBtn:Sprite = makeSmallButton(isCurDeploy ? "已出战" : "出战", 54, 22, isCurDeploy ? 0x247844 : 0x1f5486);
            deployBtn.x = 90;
            deployBtn.y = cardH - 30;
            var curR:Object = r;
            deployBtn.addEventListener(MouseEvent.CLICK, makeRoleDeployClick(curR));
            card.addChild(deployBtn);

            card.addEventListener(MouseEvent.CLICK, makeRolePreviewClick(curR));
            _roleItemsGrid.addChild(card);
         }
      }

      private function makeRolePreviewClick(r:Object) : Function
      {
         return function(e:MouseEvent):void {
            previewRoleInCenter(r);
         };
      }

      private function makeRoleDeployClick(r:Object) : Function
      {
         return function(e:MouseEvent):void {
            e.stopPropagation();
            var bag:Object = _root.getCurrentBag();
            var team:int = int(_root.userProfile.team || 1);
            if(team == 2) bag.roleCTID = int(r.id);
            else bag.roleTID = int(r.id);
            _root.userProfile.defaultAvatar = int(r.id);
            _root.userProfile.defaultCareer = String(r.c);

            _root.refreshTopAndLeftInfo();
            previewRoleInCenter(r);
            renderRoleGrid();
            _root.saveProfile();
            _root.showToast("已设定 【" + r.n + "】 出战！");
         };
      }

      private function previewRoleInCenter(r:Object) : void
      {
         _selectedPreviewRole = r;
         if(!r) return;
         var bag:Object = _root.getCurrentBag();
         var weaponCode:String = bag && bag.master ? String(bag.master.codeName) : "verdict_legend2";
         _root.preview3DRoleAndWeapon(r.c, weaponCode, "NewRoleView", r.g > 0 ? int(r.g) : 2);
      }

      // ======================================================================
      // 3. 游戏商城 (Game Mall)
      // ======================================================================
      public function openMallView(initialTab:String = "weapon") : void
      {
         closeAllSubViews();
         if(_root.hallModeView) _root.hallModeView.visible = false;

         _mallTab = initialTab;
         _mallPage = 0;
         _mallSearchText = "";
         _mallContainer = new Sprite();
         _root.overlayLayer.addChild(_mallContainer);

         var bg:Sprite = new Sprite();
         bg.graphics.lineStyle(1, 0x355375, 0.9);
         bg.graphics.beginFill(0x0a1422, 0.97);
         bg.graphics.drawRoundRect(0, 0, 1004, 592, 6, 6);
         bg.graphics.endFill();
         bg.x = 10;
         bg.y = 48;
         _mallContainer.addChild(bg);

         // Tab buttons
         var tabs:Array = [
            {"id":"weapon", "label":"武器商城"},
            {"id":"hero",   "label":"英雄武器"},
            {"id":"legend", "label":"传说武器"},
            {"id":"role",   "label":"角色商城"},
            {"id":"skin",   "label":"皮肤专区"},
            {"id":"pack",   "label":"特惠礼包"}
         ];

         for(var i:int = 0; i < tabs.length; i++)
         {
            var t:Object = tabs[i];
            var isSel:Boolean = (t.id == _mallTab);
            var tabBtn:Sprite = new Sprite();
            tabBtn.buttonMode = true;
            tabBtn.useHandCursor = true;
            tabBtn.graphics.lineStyle(1, isSel ? 0xf2c96d : 0x2e4a6a, 0.9);
            tabBtn.graphics.beginFill(isSel ? 0x1e4a78 : 0x111e2e, 0.95);
            tabBtn.graphics.drawRoundRect(0, 0, 96, 28, 4, 4);
            tabBtn.graphics.endFill();
            tabBtn.x = 24 + i * 102;
            tabBtn.y = 60;

            var tf:TextField = CleanLobbyRoot.makeTf(t.label, 13, isSel ? 0xfff0a0 : 0xa4c6e6, isSel);
            tf.x = int((96 - tf.textWidth) * 0.5);
            tf.y = 4;
            tabBtn.addChild(tf);

            var tidKey:String = t.id;
            tabBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
               openMallView(tidKey);
            });
            _mallContainer.addChild(tabBtn);
         }

         // Search input
         var searchBox:Sprite = new Sprite();
         searchBox.x = 720;
         searchBox.y = 60;
         searchBox.graphics.lineStyle(1, 0x334e6e, 0.9);
         searchBox.graphics.beginFill(0x070e17, 1);
         searchBox.graphics.drawRoundRect(0, 0, 180, 26, 4, 4);
         searchBox.graphics.endFill();
         _mallContainer.addChild(searchBox);

         var searchInput:TextField = new TextField();
         searchInput.type = TextFieldType.INPUT;
         searchInput.defaultTextFormat = new TextFormat("Microsoft YaHei", 12, 0xffffff);
         searchInput.x = 6;
         searchInput.y = 3;
         searchInput.width = 168;
         searchInput.height = 20;
         searchInput.addEventListener(Event.CHANGE, function(e:Event):void {
            _mallSearchText = searchInput.text;
            _mallPage = 0;
            renderMallGrid();
         });
         searchBox.addChild(searchInput);

         _mallItemsGrid = new Sprite();
         _mallItemsGrid.x = 24;
         _mallItemsGrid.y = 100;
         _mallContainer.addChild(_mallItemsGrid);

         // Pager
         var pager:Sprite = new Sprite();
         pager.x = 420;
         pager.y = 600;
         _mallContainer.addChild(pager);

         var prevBtn:Sprite = makeSmallButton("上一页", 70, 26, 0x1c3a58);
         prevBtn.x = 0;
         prevBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            if(_mallPage > 0) { _mallPage--; renderMallGrid(); }
         });
         pager.addChild(prevBtn);

         _mallPageLabel = CleanLobbyRoot.makeTf("1 / 1", 13, 0xffffff, true);
         _mallPageLabel.x = 88;
         _mallPageLabel.y = 3;
         pager.addChild(_mallPageLabel);

         var nextBtn:Sprite = makeSmallButton("下一页", 70, 26, 0x1c3a58);
         nextBtn.x = 180;
         nextBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            _mallPage++;
            renderMallGrid();
         });
         pager.addChild(nextBtn);

         _mallContainer.addChild(makeCloseButton(986, 12, function():void {
            _root.showHallHome();
         }));

         renderMallGrid();
      }

      private function getFilteredMallItems() : Array
      {
         var list:Array = [];
         var search:String = _mallSearchText ? _mallSearchText.toLowerCase() : "";

         for(var i:int = 0; i < _root.catalogItems.length; i++)
         {
            var it:Object = _root.catalogItems[i];
            if(_mallTab == "weapon" && it.t == 1) list.push(it);
            else if(_mallTab == "hero" && it.t == 1 && (it.q == 2 || it.q == 3)) list.push(it);
            else if(_mallTab == "legend" && it.t == 1 && it.q == 8) list.push(it);
            else if(_mallTab == "role" && it.t == 2) list.push(it);
            else if(_mallTab == "skin" && it.t == 8) list.push(it);
            else if(_mallTab == "pack" && it.t == 4) list.push(it);

            if(search != "" && list.length > 0 && list[list.length - 1] == it)
            {
               var n:String = it.n ? it.n.toLowerCase() : "";
               var c:String = it.c ? it.c.toLowerCase() : "";
               if(n.indexOf(search) == -1 && c.indexOf(search) == -1) list.pop();
            }
         }
         return list;
      }

      private function renderMallGrid() : void
      {
         if(!_mallItemsGrid) return;
         _mallItemsGrid.removeChildren();

         var items:Array = getFilteredMallItems();
         var totalPages:int = Math.max(1, Math.ceil(items.length / _mallPageSize));
         if(_mallPage >= totalPages) _mallPage = totalPages - 1;
         if(_mallPage < 0) _mallPage = 0;

         if(_mallPageLabel)
         {
            _mallPageLabel.text = (_mallPage + 1) + " / " + totalPages + " (在售 " + items.length + " 件)";
         }

         var startIdx:int = _mallPage * _mallPageSize;
         var endIdx:int = Math.min(items.length, startIdx + _mallPageSize);

         var cardW:int = 230;
         var cardH:int = 114;

         for(var i:int = startIdx; i < endIdx; i++)
         {
            var it:Object = items[i];
            var col:int = (i - startIdx) % 4;
            var row:int = int((i - startIdx) / 4);

            var card:Sprite = new Sprite();
            card.x = col * (cardW + 12);
            card.y = row * (cardH + 10);
            card.graphics.lineStyle(1, 0x304862, 0.9);
            card.graphics.beginFill(0x0e1927, 0.95);
            card.graphics.drawRoundRect(0, 0, cardW, cardH, 4, 4);
            card.graphics.endFill();

            if(it.t == 1 && it.c) CleanLobbyRoot.loadPreviewImage("weapon/" + it.c, card, 8, 6, cardW - 16, 62);
            else if(it.t == 2 && it.c) CleanLobbyRoot.loadPreviewImage("role/" + it.c, card, 8, 6, cardW - 16, 62);
            else if(it.t == 8 && it.id) CleanLobbyRoot.loadPreviewImage("skin/" + it.id, card, 8, 6, cardW - 16, 62);
            else if(it.c) CleanLobbyRoot.loadPreviewImage("weapon/" + it.c, card, 8, 6, cardW - 16, 62);

            var nameTf:TextField = CleanLobbyRoot.makeTf(String(it.n || it.c), 12, 0xffffff, true);
            nameTf.x = 8;
            nameTf.y = 70;
            nameTf.width = cardW - 16;
            card.addChild(nameTf);

            var priceTf:TextField = CleanLobbyRoot.makeTf("免费畅玩", 11, 0x48e878, false);
            priceTf.x = 8;
            priceTf.y = 90;
            card.addChild(priceTf);

            var claimBtn:Sprite = makeSmallButton(it.t == 2 ? "出战" : "一键领取", 64, 20, 0x1f5c32);
            claimBtn.x = cardW - 72;
            claimBtn.y = 86;
            var curItem:Object = it;
            claimBtn.addEventListener(MouseEvent.CLICK, makeEquipHandler(curItem));
            card.addChild(claimBtn);

            _mallItemsGrid.addChild(card);
         }
      }

      // ======================================================================
      // 4. 地图选择与一键进图 (Map Selector & Unity Battle Launch)
      // ======================================================================
      public function openMapSelector(modeKey:String = "team_ai", title:String = "娱乐模式") : void
      {
         closeAllSubViews();

         _mapSelectContainer = new Sprite();
         _root.overlayLayer.addChild(_mapSelectContainer);

         var mask:Sprite = new Sprite();
         mask.graphics.beginFill(0x040810, 0.75);
         mask.graphics.drawRect(0, 0, 1024, 650);
         mask.graphics.endFill();
         _mapSelectContainer.addChild(mask);

         var dlg:Sprite = new Sprite();
         dlg.x = 112;
         dlg.y = 75;
         dlg.graphics.lineStyle(2, 0xf2c96d, 0.95);
         dlg.graphics.beginFill(0x0a1524, 0.98);
         dlg.graphics.drawRoundRect(0, 0, 800, 500, 8, 8);
         dlg.graphics.endFill();
         _mapSelectContainer.addChild(dlg);

         var titleTf:TextField = CleanLobbyRoot.makeTf("进入战斗 · 选择作战地图 (" + title + ")", 18, 0xf6d365, true);
         titleTf.x = 24;
         titleTf.y = 18;
         dlg.addChild(titleTf);

         var descTf:TextField = CleanLobbyRoot.makeTf("将携带当前出战角色与背包配置直接启动本地 3D 战斗客户端 (Unity 引擎)", 12, 0xa4c6e6, false);
         descTf.x = 24;
         descTf.y = 48;
         dlg.addChild(descTf);

         var maps:Array = [
            {"id":"map12", "name":"运输船 (经典对决)", "desc":"经典团队竞技图，极速交火"},
            {"id":"map1",  "name":"双塔惊魂 (经典变异)", "desc":"双塔制高点变异狂潮"},
            {"id":"map43", "name":"冰雪堡垒 (团队竞技)", "desc":"经典雪地掩体对抗"},
            {"id":"map791","name":"暮色庄园 (生化变异)", "desc":"经典生化黄昏对抗"}
         ];

         for(var i:int = 0; i < maps.length; i++)
         {
            var m:Object = maps[i];
            var card:Sprite = new Sprite();
            card.x = 24 + (i % 2) * 380;
            card.y = 85 + int(i / 2) * 190;
            card.graphics.lineStyle(1, 0x355375, 0.9);
            card.graphics.beginFill(0x101f32, 0.95);
            card.graphics.drawRoundRect(0, 0, 360, 175, 6, 6);
            card.graphics.endFill();

            CleanLobbyRoot.loadPreviewImage("map/" + m.id, card, 8, 8, 344, 105);

            var mTitle:TextField = CleanLobbyRoot.makeTf(m.name, 14, 0xffffff, true);
            mTitle.x = 10;
            mTitle.y = 120;
            card.addChild(mTitle);

            var mDesc:TextField = CleanLobbyRoot.makeTf(m.desc, 11, 0x86a8cc, false);
            mDesc.x = 10;
            mDesc.y = 142;
            card.addChild(mDesc);

            var enterBtn:Sprite = makeSmallButton("一键出战", 86, 26, 0x226b3a);
            enterBtn.x = 360 - 96;
            enterBtn.y = 135;
            var curMap:String = m.id;
            enterBtn.addEventListener(MouseEvent.CLICK, makeLaunchBattleClick(curMap, modeKey));
            card.addChild(enterBtn);

            dlg.addChild(card);
         }

         dlg.addChild(makeCloseButton(766, 12, function():void {
            closeAllSubViews();
         }));
      }

      private function makeLaunchBattleClick(mapKey:String, modeKey:String) : Function
      {
         return function(e:MouseEvent):void {
            var bagIdx:int = int(_root.userProfile.selectedBagIndex || 0);
            _root.showToast("正在启动战斗端: 地图=" + mapKey + " 背包=" + (bagIdx + 1) + " ...");
            var url:String = CleanLobbyRoot.BASE_URL + "__launch_battle?map=" + mapKey + "&mode=" + modeKey + "&bag=" + bagIdx;
            CleanLobbyRoot.fetchText("__launch_battle?map=" + mapKey + "&mode=" + modeKey + "&bag=" + bagIdx, function(resp:String):void {
               _root.showToast("3D 战斗客户端启动成功！");
               closeAllSubViews();
            });
         };
      }

      // ======================================================================
      // Utilities
      // ======================================================================
      public static function makeSmallButton(label:String, w:int, h:int, bgColor:uint) : Sprite
      {
         var sp:Sprite = new Sprite();
         sp.buttonMode = true;
         sp.useHandCursor = true;
         sp.graphics.lineStyle(1, 0xf2c96d, 0.7);
         sp.graphics.beginFill(bgColor, 0.95);
         sp.graphics.drawRoundRect(0, 0, w, h, 4, 4);
         sp.graphics.endFill();

         var tf:TextField = CleanLobbyRoot.makeTf(label, 11, 0xffffff, true);
         tf.x = int((w - tf.textWidth) * 0.5);
         tf.y = int((h - tf.textHeight) * 0.5) - 1;
         sp.addChild(tf);
         return sp;
      }

      public static function makeCloseButton(x:int, y:int, onClose:Function) : Sprite
      {
         var sp:Sprite = new Sprite();
         sp.buttonMode = true;
         sp.useHandCursor = true;
         sp.x = x;
         sp.y = y;
         sp.graphics.lineStyle(1, 0xd04848, 0.9);
         sp.graphics.beginFill(0x8b1a1a, 0.95);
         sp.graphics.drawRoundRect(0, 0, 24, 24, 4, 4);
         sp.graphics.endFill();

         var tf:TextField = CleanLobbyRoot.makeTf("X", 13, 0xffffff, true);
         tf.x = 6;
         tf.y = 2;
         sp.addChild(tf);

         sp.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            onClose();
         });
         return sp;
      }
   }
}
