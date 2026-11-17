package
{
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import style.I18NConfig;
   import ui.UIButton;
   import ui.UIContainer;
   import ui.UILabel;
   import utils.UIUtil;

   public class CleanLobbyRoot extends Sprite
   {
      public static function logToServer(msg:String) : void
      {
         try {
            var ul:URLLoader = new URLLoader();
            ul.load(new URLRequest(BASE_URL + "__log?msg=" + encodeURIComponent(msg)));
         } catch(e:Error) {}
         trace("[CleanLobby] " + msg);
      }

      public static const BASE_URL:String = "http://127.0.0.1:8080/";
      public static var instance:CleanLobbyRoot;

      public var userProfile:Object;
      public var catalogItems:Array = [];
      public var weaponsByTid:Object = {};
      public var weaponsByCode:Object = {};
      public var rolesByTid:Object = {};
      public var rolesList:Array = [];

      public var xmlMainView:XML;
      public var xmlBagView:XML;
      public var xmlNewMall:XML;
      public var xmlNewRoleView:XML;

      public var modelSp:Sprite;
      public var modelPlaceholder:Sprite;
      public var sceneLayer:Sprite;
      public var overlayLayer:Sprite;
      public var toastLayer:Sprite;

      public var mainView:UIContainer;
      public var hallModeView:Sprite;
      public var bagTabBar:Sprite;
      public var curRoleLabel:TextField;

      private var _loadingOverlay:Sprite;
      private var _loadingText:TextField;
      private var _loadingBarFill:Sprite;

      private var _swfList:Array = [
         "ResourceAssets.swf",
         "CommonAssets.swf",
         "CommonNewAssets.swf",
         "ComponentAssets.swf",
         "UIComponentAssets.swf",
         "MainAssets.swf",
         "MainTopButtonAssets.swf",
         "RightButtonAssets.swf",
         "HallModelAssets.swf",
         "BagAssets.swf",
         "NewBagAssets.swf",
         "SmallBagAssets.swf",
         "MallAssets.swf",
         "MallNewAssets.swf",
         "NewRoleAssets.swf",
         "RoleAssets.swf",
         "NewRecommendStuffAssets.swf",
         "PanelAssets.swf"
      ];
      private var _swfIndex:int = 0;

      private var _clientViewLoader:Loader;
      private var _clientViewDomain:ApplicationDomain;
      private var _clientViewInst:DisplayObject;
      private var _cur3DViewMode:String = "roledisplay";
      private var _previewCareerOverride:String = null;
      private var _previewWeaponOverride:String = null;
      private var _previewGroupOverride:int = 0;

      private var _subViews:CleanSubViews;

      public function CleanLobbyRoot()
      {
         super();
         instance = this;
         if(stage)
         {
            init();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE, init);
         }
      }

      private function init(e:Event = null) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE, init);
         try {
            UICommon.stage = stage;
            UICommon.init(this);
         } catch(eInit:Error) {}

         modelSp = new Sprite();
         modelSp.mouseEnabled = false;
         modelSp.mouseChildren = false;
         addChild(modelSp);

         modelPlaceholder = new Sprite();
         modelPlaceholder.mouseEnabled = false;
         modelPlaceholder.mouseChildren = false;
         addChild(modelPlaceholder);

         sceneLayer = new Sprite();
         addChild(sceneLayer);

         overlayLayer = new Sprite();
         addChild(overlayLayer);

         toastLayer = new Sprite();
         toastLayer.mouseEnabled = false;
         toastLayer.mouseChildren = false;
         addChild(toastLayer);

         buildLoadingOverlay();
         loadI18n();
      }

      private function buildLoadingOverlay() : void
      {
         _loadingOverlay = new Sprite();
         _loadingOverlay.graphics.beginFill(0x080c14, 1);
         _loadingOverlay.graphics.drawRect(0, 0, 1024, 650);
         _loadingOverlay.graphics.endFill();

         var titleTf:TextField = makeTf("4399 生死狙击 · 原版离线大厅 (方案1A)", 22, 0xf2c96d, true);
         titleTf.x = int((1024 - titleTf.textWidth) * 0.5);
         titleTf.y = 250;
         _loadingOverlay.addChild(titleTf);

         var barBg:Sprite = new Sprite();
         barBg.graphics.lineStyle(1, 0x3b5878, 0.9);
         barBg.graphics.beginFill(0x101a28, 1);
         barBg.graphics.drawRoundRect(0, 0, 480, 16, 8, 8);
         barBg.graphics.endFill();
         barBg.x = 272;
         barBg.y = 310;
         _loadingOverlay.addChild(barBg);

         _loadingBarFill = new Sprite();
         _loadingBarFill.x = 274;
         _loadingBarFill.y = 312;
         _loadingOverlay.addChild(_loadingBarFill);

         _loadingText = makeTf("正在初始化原版资源...", 14, 0xa8c6e8, false);
         _loadingText.width = 600;
         _loadingText.x = 272;
         _loadingText.y = 336;
         _loadingOverlay.addChild(_loadingText);

         addChild(_loadingOverlay);
      }

      private function setLoadingProgress(ratio:Number, msg:String) : void
      {
         if(_loadingText) _loadingText.text = msg;
         if(_loadingBarFill)
         {
            var w:Number = Math.max(4, Math.min(1, ratio) * 476);
            _loadingBarFill.graphics.clear();
            _loadingBarFill.graphics.beginFill(0x2ea8ff, 1);
            _loadingBarFill.graphics.drawRoundRect(0, 0, w, 12, 6, 6);
            _loadingBarFill.graphics.endFill();
         }
      }

      private function loadI18n() : void
      {
         setLoadingProgress(0.05, "正在加载原版多语言字典 (i18n)...");
         fetchText("__i18n", function(txt:String):void {
            if(txt) I18NConfig.loadProperties(txt);
            loadProfile();
         });
      }

      private function loadProfile() : void
      {
         setLoadingProgress(0.12, "正在读取本地玩家存档 (user_profile.json)...");
         fetchText("__profile", function(txt:String):void {
            try {
               userProfile = JSON.parse(txt);
            } catch(err:Error) {
               userProfile = {
                  "selectedBagIndex": 0,
                  "defaultAvatar": 150,
                  "defaultCareer": "pandora_ct",
                  "playerName": "你来时冬至",
                  "team": 1,
                  "bags": [
                     {"roleTID":150,"roleCTID":36,"master":{"storageId":10016142,"tid":16142,"codeName":"verdict_legend2"},"secondary":{"storageId":10016400,"tid":16400,"codeName":"puppet_pistol"},"closed":{"storageId":10015722,"tid":15722,"codeName":"guqin_trans_sword2"},"bom1":{"storageId":10000010,"tid":10,"codeName":"grenade"}}
                  ]
               };
            }
            loadCatalog();
         });
      }

      private function loadCatalog() : void
      {
         setLoadingProgress(0.20, "正在加载全量 21,669 件武器/角色/皮肤/道具目录...");
         fetchText("__catalog", function(txt:String):void {
            try {
               var obj:Object = JSON.parse(txt);
               catalogItems = obj.items as Array;
               for(var i:int = 0; i < catalogItems.length; i++)
               {
                  var it:Object = catalogItems[i];
                  if(it.t == 1)
                  {
                     weaponsByTid[it.id] = it;
                     if(it.c) weaponsByCode[it.c] = it;
                  }
                  else if(it.t == 2)
                  {
                     rolesByTid[it.id] = it;
                     rolesList.push(it);
                  }
               }
            } catch(err:Error) {}
            loadXmlLayouts();
         });
      }

      private function loadXmlLayouts() : void
      {
         setLoadingProgress(0.32, "正在加载原版 XML 布局 (NewMainView / BagView / NewMall / NewRoleView)...");
         fetchText("__xml/NewMainView.xml", function(s1:String):void {
            xmlMainView = new XML(s1);
            fetchText("__xml/BagView.xml", function(s2:String):void {
               xmlBagView = new XML(s2);
               fetchText("__xml/NewMall.xml", function(s3:String):void {
                  xmlNewMall = new XML(s3);
                  fetchText("__xml/NewRoleView.xml", function(s4:String):void {
                     xmlNewRoleView = new XML(s4);
                     _swfIndex = 0;
                     loadNextSwf();
                  });
               });
            });
         });
      }

      private function loadNextSwf() : void
      {
         if(_swfIndex >= _swfList.length)
         {
            onAllAssetsReady();
            return;
         }
         var swfName:String = _swfList[_swfIndex];
         var ratio:Number = 0.35 + (_swfIndex / _swfList.length) * 0.55;
         setLoadingProgress(ratio, "正在加载原版矢量皮肤库 (" + (_swfIndex + 1) + "/" + _swfList.length + "): " + swfName);

         var ul:URLLoader = new URLLoader();
         ul.dataFormat = URLLoaderDataFormat.BINARY;
         ul.addEventListener(Event.COMPLETE, function(e:Event):void {
            var bytes:ByteArray = ul.data as ByteArray;
            var ldr:Loader = new Loader();
            var lc:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
            try { lc["allowCodeImport"] = true; } catch(err:Error) {}
            ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function(ev:Event):void {
               _swfIndex++;
               loadNextSwf();
            });
            ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(ev:IOErrorEvent):void {
               _swfIndex++;
               loadNextSwf();
            });
            ldr.loadBytes(bytes, lc);
         });
         ul.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
            _swfIndex++;
            loadNextSwf();
         });
         ul.load(new URLRequest(BASE_URL + "__swf/" + swfName));
      }

      private function onAllAssetsReady() : void
      {
         logToServer("onAllAssetsReady: entered");
         setLoadingProgress(0.95, "正在构建原版主界面与 Stage3D 3D渲染引擎...");

         try {
            logToServer("onAllAssetsReady: init CleanSubViews");
            _subViews = new CleanSubViews(this);
         } catch(e1:Error) {
            logToServer("CleanSubViews ERROR: " + e1.message);
         }

         try {
            logToServer("onAllAssetsReady: buildMainLobbyUI");
            buildMainLobbyUI();
         } catch(e2:Error) {
            logToServer("buildMainLobbyUI ERROR: " + e2.message + " " + e2.getStackTrace());
         }

         try {
            logToServer("onAllAssetsReady: initClientViewStage3D");
            initClientViewStage3D();
         } catch(e3:Error) {
            logToServer("initClientViewStage3D ERROR: " + e3.message);
         }

         // ALWAYS remove loading overlay so user is NEVER stuck on loading screen
         if(_loadingOverlay && _loadingOverlay.parent)
         {
            _loadingOverlay.parent.removeChild(_loadingOverlay);
            _loadingOverlay = null;
         }
         logToServer("onAllAssetsReady: overlay removed successfully!");
         showToast("原版大厅加载完成 · 已解锁全量 " + catalogItems.length + " 件物品与 335 名角色");
      }

      private function buildMainLobbyUI() : void
      {
         mainView = new UIContainer();
         logToServer("buildMainLobbyUI: xmlMainView is null? " + (xmlMainView == null));
         try {
            UIUtil.initUI(mainView, xmlMainView, xmlMainView);
            logToServer("buildMainLobbyUI: mainView childCount=" + mainView.numChildren);
         } catch(eInitUI:Error) {
            logToServer("buildMainLobbyUI initUI CRASH: " + eInitUI.message + " " + eInitUI.getStackTrace());
         }
         sceneLayer.addChild(mainView);

         // Hide unused clutter elements
         var hideNames:Array = [
            "nationalFlag", "banGameTipLabel", "fashCacheTips", "microClientTips",
            "secondLevelPasswordBtn", "btnBlock", "matchInfo", "setRedImage",
            "setTipsNumLaebel", "labelAntiTips", "bgAntiTips", "btnAnti",
            "modelBottomBgImage", "backBtn", "fastTimeTxt", "redPoint",
            "questionnaireInvBtn", "questionnaireInvBtn1"
         ];
         for each(var hn:String in hideNames)
         {
            if((hn in mainView) && mainView[hn] is DisplayObject)
            {
               (mainView[hn] as DisplayObject).visible = false;
            }
         }
         if("maskSp" in mainView && mainView["maskSp"] is Sprite)
         {
            mainView["maskSp"].mouseEnabled = false;
            mainView["maskSp"].mouseChildren = false;
         }
         if("newPlayerSp" in mainView && mainView["newPlayerSp"] is Sprite)
         {
            mainView["newPlayerSp"].mouseEnabled = false;
            mainView["newPlayerSp"].mouseChildren = false;
         }

         // Update Player Portrait & Currency Bar
         refreshTopAndLeftInfo();

         // Wire TopButtonPanel navigation buttons
         if("topButtonPanel" in mainView && mainView["topButtonPanel"] != null)
         {
            var top:Object = mainView["topButtonPanel"];
            if("tipsImage" in top && top["tipsImage"] is DisplayObject) top["tipsImage"].visible = false;
            if("temporaryBagBtn" in top && top["temporaryBagBtn"] is DisplayObject) top["temporaryBagBtn"].visible = false;

            wireBtn(top["gameHallBtn"], function():void { showHallHome(); });
            wireBtn(top["storageBtn"], function():void { _subViews.openStorageView(); });
            wireBtn(top["mallBtn"], function():void { _subViews.openMallView(); });
            wireBtn(top["activityBtn"], function():void { _subViews.openMallView("pack"); });
            wireBtn(top["festivalListBtn"], function():void { _subViews.openStorageView("skin"); });
            wireBtn(top["timeShopBtn"], function():void { _subViews.openMallView("hero"); });
            wireBtn(top["rankBtn"], function():void { _subViews.openRoleSelectView(); });
            wireBtn(top["teamSystemBtn"], function():void { _subViews.openRoleSelectView(); });
            wireBtn(top["titaniumBtn"], function():void { _subViews.openMapSelector("adventure"); });
            wireBtn(top["ssjjBigActivityBtn"], function():void { _subViews.openMallView("legend"); });
            wireBtn(top["playerListBtn"], function():void { _subViews.openMapSelector("team_ai"); });
         }

         // Wire Left-Side Role & Bag Buttons
         wireBtn(mainView["selectRoleBtn"], function():void { _subViews.openRoleSelectView(); });
         wireBtn(mainView["switchBagBtn"], function():void { _subViews.openStorageView(); });
         wireBtn(mainView["automaticEquipBtn"], function():void { _subViews.openStorageView(); });
         wireBtn(mainView["propBtn"], function():void { _subViews.openStorageView("stuff"); });
         wireBtn(mainView["fulibtn"], function():void { _subViews.openMallView(); });
         wireBtn(mainView["tenBtn"], function():void { _subViews.openStorageView("weapon"); });

         // Build current role name badge above selectRoleBtn
         curRoleLabel = makeTf("", 13, 0x7ce8ff, true);
         curRoleLabel.x = 80;
         curRoleLabel.y = 374;
         curRoleLabel.width = 133;
         mainView.addChild(curRoleLabel);

         // Build 5 Bag Switcher Tabs (1~5) at x=2, y=455
         buildBagSwitchTabs();

         // Build Official FGUI HallModePanel inside mainView._viewContainer
         buildHallModePanel();

         // Populate bottom-left SmallBagView
         refreshSmallBagView();
      }

      private function buildBagSwitchTabs() : void
      {
         bagTabBar = new Sprite();
         bagTabBar.x = 4;
         bagTabBar.y = 456;
         mainView.addChild(bagTabBar);
         refreshBagSwitchTabs();
      }

      public function refreshBagSwitchTabs() : void
      {
         if(!bagTabBar) return;
         bagTabBar.removeChildren();
         var selIdx:int = int(userProfile.selectedBagIndex || 0);
         for(var i:int = 0; i < 5; i++)
         {
            var isSel:Boolean = (i == selIdx);
            var tab:Sprite = new Sprite();
            tab.buttonMode = true;
            tab.useHandCursor = true;
            tab.graphics.lineStyle(1, isSel ? 0xf5d061 : 0x36516e, 0.9);
            tab.graphics.beginFill(isSel ? 0x1e4872 : 0x0d1826, 0.95);
            tab.graphics.drawRoundRect(0, 0, 34, 20, 4, 4);
            tab.graphics.endFill();
            tab.x = i * 37;
            var tf:TextField = makeTf("背包" + (i + 1), 11, isSel ? 0xfff0a0 : 0x8ab0d0, isSel);
            tf.x = 3;
            tf.y = 1;
            tab.addChild(tf);
            var bagIdx:int = i;
            tab.addEventListener(MouseEvent.CLICK, makeBagTabClick(bagIdx));
            bagTabBar.addChild(tab);
         }
      }

      private function makeBagTabClick(idx:int) : Function
      {
         return function(e:MouseEvent):void {
            selectBag(idx);
         };
      }

      public function selectBag(idx:int) : void
      {
         userProfile.selectedBagIndex = idx;
         refreshBagSwitchTabs();
         refreshSmallBagView();
         refreshTopAndLeftInfo();
         _previewCareerOverride = null;
         _previewWeaponOverride = null;
         update3DRoleWeaponView();
         saveProfile();
         showToast("已切换至 背包 " + (idx + 1));
      }

      public function refreshTopAndLeftInfo() : void
      {
         if(!mainView) return;
         if("playerProtrait" in mainView && mainView["playerProtrait"] != null)
         {
            var pp:Object = mainView["playerProtrait"];
            if("playerNameTF" in pp && pp["playerNameTF"] is UILabel)
            {
               (pp["playerNameTF"] as UILabel).text = String(userProfile.playerName || "你来时冬至");
            }
            if("rankTf" in pp && pp["rankTf"] is UILabel)
            {
               (pp["rankTf"] as UILabel).text = "Lv.100 传奇元帅";
            }
            if("icon4399" in pp && pp["icon4399"] is DisplayObject)
            {
               (pp["icon4399"] as DisplayObject).visible = false;
            }
         }
         if("currencyBar" in mainView && mainView["currencyBar"] != null)
         {
            var cb:Object = mainView["currencyBar"];
            if("yqLB" in cb && cb["yqLB"] is UILabel) (cb["yqLB"] as UILabel).text = "点券: 999999";
            if("gpLB" in cb && cb["gpLB"] is UILabel) (cb["gpLB"] as UILabel).text = "9999999";
            if("rpLB" in cb && cb["rpLB"] is UILabel) (cb["rpLB"] as UILabel).text = "999999";
            wireBtn(cb["rechargeBtn"], function():void { _subViews.openMallView(); });
            wireBtn(cb["shoppingCartBtn"], function():void { _subViews.openStorageView(); });
         }
         var roleObj:Object = getCurrentRoleObject();
         if(curRoleLabel && roleObj)
         {
            curRoleLabel.text = "当前出战: " + roleObj.n + " (" + roleObj.c + ")";
         }
      }

      public function refreshSmallBagView() : void
      {
         if(!mainView || !("sbag" in mainView) || mainView["sbag"] == null) return;
         var sbag:UIContainer = mainView["sbag"] as UIContainer;
         if(!sbag) return;
         sbag.y = 478;

         var bag:Object = getCurrentBag();
         populateSmallCell(sbag["cellMaster"], bag.master, 148, 60, "主武器");
         populateSmallCell(sbag["cellSeondary"], bag.secondary, 118, 60, "副武器");
         populateSmallCell(sbag["cellClosed"], bag.closed, 118, 52, "近战");
         populateSmallCell(sbag["cellBoom1"], bag.bom1, 50, 52, "投掷");
      }

      private function populateSmallCell(cell:Object, slotData:Object, w:int, h:int, defaultTitle:String) : void
      {
         var sp:Sprite = cell as Sprite;
         if(!sp) return;
         var oldOverlay:DisplayObject = sp.getChildByName("__cleanOverlay");
         if(oldOverlay) sp.removeChild(oldOverlay);

         var ov:Sprite = new Sprite();
         ov.name = "__cleanOverlay";
         ov.buttonMode = true;
         ov.useHandCursor = true;
         ov.graphics.lineStyle(1, 0x2d4a68, 0.85);
         ov.graphics.beginFill(0x0c1624, 0.92);
         ov.graphics.drawRoundRect(0, 0, w, h, 4, 4);
         ov.graphics.endFill();

         var code:String = slotData ? String(slotData.codeName || "") : "";
         var tid:int = slotData ? int(slotData.tid || 0) : 0;
         var wInfo:Object = weaponsByTid[tid] || weaponsByCode[code];
         var wName:String = wInfo ? String(wInfo.n) : (code != "" ? code : defaultTitle);

         if(code != "")
         {
            loadPreviewImage("weapon/" + code, ov, 4, 4, w - 8, h - 20);
         }

         var lbl:TextField = makeTf(wName, 11, 0xd8ecff, false);
         lbl.x = 4;
         lbl.y = h - 18;
         lbl.width = w - 6;
         ov.addChild(lbl);

         ov.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            _subViews.openStorageView("weapon");
         });
         sp.addChild(ov);
      }

      private function buildHallModePanel() : void
      {
         hallModeView = new Sprite();
         hallModeView.x = 296;
         hallModeView.y = 100;

         var cards:Array = [
            {"img":"q496w.png",  "x":6,   "y":6,   "w":290, "h":220, "mode":"entertainment", "title":"娱乐模式"},
            {"img":"br5e1o.png", "x":306, "y":6,   "w":290, "h":346, "mode":"adventure",     "title":"冒险模式"},
            {"img":"q496y.png",  "x":6,   "y":236, "w":290, "h":116, "mode":"ladder",        "title":"天梯联赛"},
            {"img":"q496z.png",  "x":6,   "y":362, "w":290, "h":116, "mode":"gold_raid",     "title":"摸金战场"},
            {"img":"q49610.png", "x":306, "y":362, "w":290, "h":116, "mode":"classic",       "title":"经典娱乐频道"}
         ];

         for(var i:int = 0; i < cards.length; i++)
         {
            var c:Object = cards[i];
            var cardSp:Sprite = new Sprite();
            cardSp.x = c.x;
            cardSp.y = c.y;
            cardSp.buttonMode = true;
            cardSp.useHandCursor = true;

            cardSp.graphics.lineStyle(1, 0x355375, 0.9);
            cardSp.graphics.beginFill(0x101c2c, 1);
            cardSp.graphics.drawRoundRect(0, 0, c.w, c.h, 6, 6);
            cardSp.graphics.endFill();

            loadExternalImage(BASE_URL + "__fgui/HallModePanel/" + c.img, cardSp, 0, 0, c.w, c.h);

            var hoverBorder:Sprite = new Sprite();
            hoverBorder.graphics.lineStyle(2, 0xf6d365, 1);
            hoverBorder.graphics.drawRoundRect(0, 0, c.w, c.h, 6, 6);
            hoverBorder.visible = false;
            cardSp.addChild(hoverBorder);

            cardSp.addEventListener(MouseEvent.ROLL_OVER, makeHoverHandler(hoverBorder, true));
            cardSp.addEventListener(MouseEvent.ROLL_OUT, makeHoverHandler(hoverBorder, false));
            cardSp.addEventListener(MouseEvent.CLICK, makeModeCardClick(c.mode, c.title));

            hallModeView.addChild(cardSp);
         }

         if("_viewContainer" in mainView && mainView["_viewContainer"] is Sprite)
         {
            (mainView["_viewContainer"] as Sprite).addChild(hallModeView);
         }
         else
         {
            mainView.addChild(hallModeView);
         }
      }

      private function makeHoverHandler(border:Sprite, vis:Boolean) : Function
      {
         return function(e:MouseEvent):void { border.visible = vis; };
      }

      private function makeModeCardClick(modeKey:String, title:String) : Function
      {
         return function(e:MouseEvent):void {
            _subViews.openMapSelector(modeKey, title);
         };
      }

      public function showHallHome() : void
      {
         _subViews.closeAllSubViews();
         if(hallModeView) hallModeView.visible = true;
         _cur3DViewMode = "roledisplay";
         _previewCareerOverride = null;
         _previewWeaponOverride = null;
         update3DRoleWeaponView();
      }

      // ======================================================================
      // Stage3D ClientView.swf 3D Character + Weapon Renderer
      // ======================================================================
      private function initClientViewStage3D() : void
      {
         drawFallbackModelPlaceholder();

         _clientViewDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
         var lc:LoaderContext = new LoaderContext(false, _clientViewDomain);
         try { lc["allowCodeImport"] = true; } catch(err:Error) {}

         _clientViewLoader = new Loader();
         _clientViewLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onClientViewSwfLoaded);
         _clientViewLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
            trace("[ClientView] IO_ERROR: " + e.text);
         });
         _clientViewLoader.load(new URLRequest(BASE_URL + "ClientView_cb90b1c9823af027e0536313e50106e4.swf"), lc);
      }

      private function onClientViewSwfLoaded(e:Event) : void
      {
         var content:DisplayObject = _clientViewLoader.content;
         if(!content) return;
         modelSp.addChild(content);

         if(_clientViewDomain.hasDefinition("ClientView"))
         {
            onClientViewEngineReady();
         }
         else if(ApplicationDomain.currentDomain.hasDefinition("ClientView"))
         {
            _clientViewDomain = ApplicationDomain.currentDomain;
            onClientViewEngineReady();
         }
         else
         {
            content.addEventListener("LoadRenderThreadOK", function(ev:Event):void {
               onClientViewEngineReady();
            });
         }
      }

      private function onClientViewEngineReady() : void
      {
         try
         {
            var cvClass:Class = null;
            if(_clientViewDomain && _clientViewDomain.hasDefinition("ClientView"))
            {
               cvClass = _clientViewDomain.getDefinition("ClientView") as Class;
            }
            else if(ApplicationDomain.currentDomain.hasDefinition("ClientView"))
            {
               cvClass = ApplicationDomain.currentDomain.getDefinition("ClientView") as Class;
            }
            if(cvClass != null)
            {
               _clientViewInst = cvClass["instance"] as DisplayObject;
               if(_clientViewInst && !modelSp.contains(_clientViewInst))
               {
                  modelSp.addChild(_clientViewInst);
               }
               update3DRoleWeaponView();
            }
         }
         catch(err:Error)
         {
            trace("[ClientView] Engine init err: " + err.message);
         }
      }

      public function preview3DRoleAndWeapon(career:String, weaponCode:String, viewMode:String = "roledisplay", group:int = 2) : void
      {
         _previewCareerOverride = career;
         _previewWeaponOverride = weaponCode;
         _previewGroupOverride = group;
         _cur3DViewMode = viewMode;
         update3DRoleWeaponView();
      }

      public function update3DRoleWeaponView() : void
      {
         drawFallbackModelPlaceholder();
         if(!_clientViewInst) return;

         var roleObj:Object = getCurrentRoleObject();
         var bag:Object = getCurrentBag();
         var career:String = _previewCareerOverride != null ? _previewCareerOverride : (roleObj ? String(roleObj.c) : "pandora_ct");
         var weaponCode:String = _previewWeaponOverride != null ? _previewWeaponOverride : (bag && bag.master ? String(bag.master.codeName) : "verdict_legend2");
         var group:int = _previewGroupOverride > 0 ? _previewGroupOverride : (roleObj && roleObj.g > 0 ? int(roleObj.g) : 2);

         var vx:int = (_cur3DViewMode == "NewRoleView") ? 256 : 10;
         var vy:int = (_cur3DViewMode == "NewRoleView") ? 85 : 60;
         var vw:int = (_cur3DViewMode == "NewRoleView") ? 512 : 279;
         var vh:int = (_cur3DViewMode == "NewRoleView") ? 512 : 506;

         var cbDic:Dictionary = new Dictionary();
         cbDic["sceneLoadComplete"] = function():void {
            if(modelPlaceholder) modelPlaceholder.visible = false;
            if(_subViews) _subViews.on3DSceneLoaded();
         };

         var loaderParams:Object = {
            "resurl": BASE_URL,
            "resurl_back": BASE_URL,
            "signConfigFileName": "sign_3b03f6beff7500bb553aeb97522d7f52.xml",
            "version": "release_2026_10_20_20261031095607",
            "platform": "4399",
            "isMicroClient": "1"
         };

         var params:Object = {
            "id": 1,
            "x": vx,
            "y": vy,
            "w": vw,
            "h": vh,
            "playerCareer": career,
            "weaponName": weaponCode,
            "view": _cur3DViewMode,
            "petName": null,
            "hide": false,
            "group": group,
            "weaponEffectLevel": 0,
            "weaponEffectLevelDic": new Dictionary(),
            "loaderInfoParameters": loaderParams,
            "lobbyCallbackFunDic": cbDic
         };

         try
         {
            var fn:Function = _clientViewInst["startPlayerWeaponView"] as Function;
            if(fn != null)
            {
               fn.apply(_clientViewInst, [params]);
            }
         }
         catch(err:Error)
         {
            trace("[ClientView] startPlayerWeaponView error: " + err.message);
         }
      }

      private function drawFallbackModelPlaceholder() : void
      {
         if(!modelPlaceholder) return;
         modelPlaceholder.removeChildren();
         modelPlaceholder.visible = true;

         var roleObj:Object = getCurrentRoleObject();
         var bag:Object = getCurrentBag();
         var career:String = _previewCareerOverride != null ? _previewCareerOverride : (roleObj ? String(roleObj.c) : "pandora_ct");
         var weaponCode:String = _previewWeaponOverride != null ? _previewWeaponOverride : (bag && bag.master ? String(bag.master.codeName) : "verdict_legend2");

         var vx:int = (_cur3DViewMode == "NewRoleView") ? 256 : 10;
         var vy:int = (_cur3DViewMode == "NewRoleView") ? 85 : 60;
         var vw:int = (_cur3DViewMode == "NewRoleView") ? 512 : 279;
         var vh:int = (_cur3DViewMode == "NewRoleView") ? 512 : 506;

         var box:Sprite = new Sprite();
         box.x = vx;
         box.y = vy;

         loadPreviewImage("role/" + career, box, int((vw - 220) * 0.5), 25, 220, 260);
         if(weaponCode != "")
         {
            loadPreviewImage("weapon/" + weaponCode, box, int((vw - 220) * 0.5), 240, 220, 95);
         }
         modelPlaceholder.addChild(box);
      }

      // ======================================================================
      // Data & Profile Helpers
      // ======================================================================
      public function getCurrentBag() : Object
      {
         var bags:Array = userProfile ? (userProfile.bags as Array) : null;
         if(!bags || bags.length == 0)
         {
            return {
               "roleTID": 150,
               "roleCTID": 36,
               "master": {"storageId":10016142,"tid":16142,"codeName":"verdict_legend2"},
               "secondary": {"storageId":10016400,"tid":16400,"codeName":"puppet_pistol"},
               "closed": {"storageId":10015722,"tid":15722,"codeName":"guqin_trans_sword2"},
               "bom1": {"storageId":10000010,"tid":10,"codeName":"grenade"}
            };
         }
         var idx:int = int(userProfile.selectedBagIndex || 0);
         if(idx < 0 || idx >= bags.length) idx = 0;
         return bags[idx];
      }

      public function getCurrentRoleObject() : Object
      {
         var bag:Object = getCurrentBag();
         var rid:int = int(bag.roleTID || userProfile.defaultAvatar || 150);
         if(rolesByTid[rid]) return rolesByTid[rid];
         return {"id":rid, "n":"潘多拉", "c":String(userProfile.defaultCareer || "pandora_ct"), "g":2};
      }

      public function saveProfile(onDone:Function = null) : void
      {
         var req:URLRequest = new URLRequest(BASE_URL + "__save_profile");
         req.method = URLRequestMethod.POST;
         req.data = JSON.stringify(userProfile);
         var ul:URLLoader = new URLLoader();
         ul.addEventListener(Event.COMPLETE, function(e:Event):void {
            if(onDone != null) onDone();
         });
         ul.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
            if(onDone != null) onDone();
         });
         ul.load(req);
      }

      // ======================================================================
      // UI & Network Utilities
      // ======================================================================
      public static function wireBtn(btn:Object, handler:Function) : void
      {
         var d:DisplayObject = btn as DisplayObject;
         if(!d) return;
         if(d is Sprite)
         {
            (d as Sprite).buttonMode = true;
            (d as Sprite).useHandCursor = true;
         }
         d.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
            handler();
         });
      }

      public static function makeTf(txt:String, size:int = 12, color:uint = 0xffffff, bold:Boolean = false) : TextField
      {
         var tf:TextField = new TextField();
         var fmt:TextFormat = new TextFormat("Microsoft YaHei", size, color, bold);
         tf.defaultTextFormat = fmt;
         tf.selectable = false;
         tf.mouseEnabled = false;
         tf.autoSize = "left";
         tf.text = txt;
         return tf;
      }

      public static function fetchText(path:String, cb:Function) : void
      {
         var ul:URLLoader = new URLLoader();
         ul.dataFormat = URLLoaderDataFormat.TEXT;
         ul.addEventListener(Event.COMPLETE, function(e:Event):void {
            cb(String(ul.data));
         });
         ul.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
            cb("");
         });
         ul.load(new URLRequest(BASE_URL + path));
      }

      public static function loadPreviewImage(relPath:String, target:Sprite, x:int, y:int, maxW:int, maxH:int) : void
      {
         loadExternalImage(BASE_URL + "__preview/" + relPath, target, x, y, maxW, maxH);
      }

      public static function loadExternalImage(url:String, target:Sprite, x:int, y:int, maxW:int, maxH:int) : void
      {
         var ldr:Loader = new Loader();
         ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
            var d:DisplayObject = ldr.content;
            if(!d) return;
            if(d is Bitmap) (d as Bitmap).smoothing = true;
            var sx:Number = maxW / Math.max(1, d.width);
            var sy:Number = maxH / Math.max(1, d.height);
            var sc:Number = Math.min(sx, sy);
            d.scaleX = sc;
            d.scaleY = sc;
            d.x = x + int((maxW - d.width) * 0.5);
            d.y = y + int((maxH - d.height) * 0.5);
            target.addChildAt(d, Math.min(1, target.numChildren));
         });
         ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {});
         ldr.load(new URLRequest(url));
      }

      public function showToast(msg:String) : void
      {
         if(!toastLayer) return;
         toastLayer.removeChildren();
         var box:Sprite = new Sprite();
         var tf:TextField = makeTf(msg, 13, 0xfff3b0, true);
         var bw:int = tf.textWidth + 36;
         box.graphics.lineStyle(1, 0xf5d061, 0.9);
         box.graphics.beginFill(0x0c1828, 0.92);
         box.graphics.drawRoundRect(0, 0, bw, 30, 8, 8);
         box.graphics.endFill();
         tf.x = 18;
         tf.y = 5;
         box.addChild(tf);
         box.x = int((1024 - bw) * 0.5);
         box.y = 612;
         toastLayer.addChild(box);
      }
   }
}
