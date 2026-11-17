package
{
   import com.junkbyte.console.Cc;
   import errorutil.PostErrorUtil;
   import errorutil.RemoteLogPost;
   import fl.FUIAssets;
   import flash.desktop.NativeApplication;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.InvokeEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.UncaughtErrorEvent;
   import flash.external.ExternalInterface;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.geom.Point;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.system.Security;
   import lobby.LanguageConfig;
   import lobby.common.GlobalVariable;
   import lobby.common.PlateformName;
   import lobby.log.IRemoteLog;
   import lobby.log.LogManager;
   import lobby.log.PostLogUtil;
   import lobby.vo.LoginVO;
   import login.LoginManager;
   import login.interfaces.ILoginHandler;
   import module.ModuleLoader;
   import org.as3commons.logging.api.ILogger;
   import org.as3commons.logging.api.getLogger;
   import tools.StringTool;
   import view.preloadingbar.PreLoaderBar;
   import view.reconnect.AlertPanel;
   
   public class Mini extends Sprite implements ILoginHandler
   {
      
      public static var lobbyFileName:String = "Lobby.swf";
      
      public static var roleCreatorName:String = "HallCreateRole.swf";
      
      public static const GAME_W:Number = 1024;
      
      public static const GAME_H:Number = 650;
      
      public static const GAME_TOP:Number = 50;
      
      public static const GAME_BOTTOM:Number = 36;
      
      public static const GAME_LEFT:Number = 10;
      
      public static const GAME_RIGHT:Number = 10;
      
      private static const _logger:ILogger = getLogger(Mini);
      
      private var I18N:Class = preloder_i18n_txt;
      
      private const HALL_CONFIG_FILE:String = "config/hall_config.xml";
      
      private var loaderBar:PreLoaderBar = null;
      
      private var resurl:String = "";
      
      private var loginParam:Object = {};
      
      private var loginVO:LoginVO;
      
      private var _isRpg2:Boolean = false;
      
      private var _lastScaleX:Number = 1;
      
      private var _lastScaleY:Number = 1;
      
      private var _screenMatchMode:int;
      
      private var _designResolutionX:Number = 0;
      
      private var _designResolutionY:Number = 0;
      
      private var _scale:Number = 1;
      
      private var _params:Object = null;
      
      private var hallConfig:XML = null;
      
      private var lobbyLoader:ModuleLoader = null;
      
      private var roleCreatorLoader:ModuleLoader = null;
      
      private var isNewCharacter:Boolean = false;
      
      private var _fuiAssets:FUIAssets = null;
      
      private var _airJsAdapter:AirJsAdapter = null;
      
      private const FUNC_START_ROLE_CREATOR:String = "startRoleCreator";
      
      private const FUNC_START_LOBBY:String = "startLobby";
      
      private const FUNC_SET_JSCALLABLE:String = "setJsCallable";
      
      private const FUNC_SET_SCALE:String = "setScale";
      
      private var createRoleSprite:Sprite = null;
      
      public function Mini()
      {
         super();
         if(null != stage)
         {
            this.init();
         }
         else
         {
            this.addEventListener("addedToStage",this.onAddToStage);
         }
      }
      
      public static function getDefaultPosition() : Point
      {
         var _loc1_:Point = new Point();
         var _loc3_:Number = (Capabilities.screenResolutionX - 1024) * 0.5;
         var _loc2_:Number = 50;
         _loc1_.x = _loc3_;
         _loc1_.y = _loc2_;
         return _loc1_;
      }
      
      private function setDefaultPosition() : void
      {
         var _loc1_:Point = getDefaultPosition();
         this.setPosition(_loc1_.x,_loc1_.y);
      }
      
      private function onAddToStage(param1:Event) : void
      {
         this.removeEventListener("addedToStage",this.init);
         this.init();
      }
      
      private function setPosition(param1:int, param2:int) : void
      {
         stage.nativeWindow.x = param1;
         stage.nativeWindow.y = param2;
      }
      
      private function setSize(param1:int, param2:int) : void
      {
         stage.nativeWindow.width = param1;
         stage.nativeWindow.height = param2;
         _logger.info("window.width" + param1);
         _logger.info("window.height" + param2);
      }
      
      private function getParams() : Object
      {
         if(null != _params)
         {
            return _params;
         }
         return {};
      }
      
      private function init() : void
      {
         stage.addEventListener("resize",onResize);
         this.stage.color = 0;
         this.stage.scaleMode = "noScale";
         this.stage.align = "TL";
         setDefaultPosition();
         startConsole();
         MultiApplicationUtil.appOpen();
         NativeApplication.nativeApplication.icon.bitmaps = [];
         readParamFromFile();
         var _loc1_:Object = getParams();
         if(_loc1_ && null != _loc1_["isRpg2"])
         {
            this._isRpg2 = int(_loc1_["isRpg2"]) == 1;
         }
         this.setRpg2WindowSize();
         _logger.info("stage.Scale::" + this.stage.scaleX);
         _logger.info("stage.width::" + this.stage.width);
      }
      
      private function onResize(param1:Event) : void
      {
         _logger.info("onResize");
         applyChange();
      }
      
      private function setContentScaleFactor(param1:int, param2:int, param3:int) : void
      {
         this._designResolutionX = param1;
         this._designResolutionY = param2;
         this._screenMatchMode = param3;
         applyChange();
      }
      
      private function applyChange() : void
      {
         var _loc11_:int = 0;
         if(!this._isRpg2)
         {
            return;
         }
         if(this._designResolutionX == 0 || this._designResolutionY == 0)
         {
            return;
         }
         var _loc9_:Number = stage.stageWidth;
         var _loc2_:Number = stage.stageHeight;
         var _loc10_:Number = 1;
         var _loc13_:Number = 0;
         var _loc5_:Number = 0;
         var _loc7_:int = _designResolutionX;
         var _loc8_:int = _designResolutionY;
         var _loc1_:Number = 0;
         var _loc3_:Number = 0;
         if(this._screenMatchMode == 0)
         {
            if(_loc9_ > _loc2_ && _loc7_ < _loc8_ || _loc9_ < _loc2_ && _loc7_ > _loc8_)
            {
               _loc11_ = _loc7_;
               _loc7_ = _loc8_;
               _loc8_ = _loc11_;
            }
            _loc1_ = _loc9_ / _loc7_;
            _loc3_ = _loc2_ / _loc8_;
            _loc13_ = _loc9_;
            _loc5_ = _loc2_;
         }
         else if(this._screenMatchMode == 1)
         {
            _loc10_ = _loc9_ / _loc7_;
            _loc13_ = _loc9_;
            _loc5_ = _loc2_ > _loc13_ * _loc8_ / _loc7_ ? _loc13_ * _loc8_ / _loc7_ : _loc2_;
         }
         else
         {
            _loc10_ = _loc2_ / _loc8_;
            _loc5_ = _loc2_;
            _loc13_ = _loc9_ > _loc5_ * _loc7_ / _loc8_ ? _loc5_ * _loc7_ / _loc8_ : _loc9_;
         }
         this.x = 0;
         this.y = 0;
         var _loc4_:Number = _loc9_ != _loc13_ ? (_loc9_ - _loc13_) / 2 : 0;
         var _loc6_:Number = _loc2_ != _loc5_ ? (_loc2_ - _loc5_) / 2 : 0;
         var _loc12_:Point = new Point(_loc4_,_loc6_);
         if(null != this.parent && this.parent != stage)
         {
            _loc12_ = this.globalToLocal(new Point(_loc4_,_loc6_));
         }
         this.x = _loc12_.x;
         this.y = _loc12_.y;
         if(null != this.loaderBar)
         {
            loaderBar.scaleX /= this._lastScaleX;
            loaderBar.scaleX *= _loc1_;
            loaderBar.scaleY /= this._lastScaleY;
            loaderBar.scaleY *= _loc3_;
         }
         if(null != this.parent)
         {
            _logger.info("parent.x:",[this.parent.x," parent.y:" + this.parent.y]);
            if(null != this.parent.parent)
            {
               _logger.info("parent2.x:",[this.parent.parent.x," parent2.y:" + this.parent.parent.y]);
            }
         }
         _logger.info("stageX:",[stage.x + " stageY:" + stage.y + " initX:" + _loc12_.x + " initY:" + _loc12_.y + " screenWidth:" + _loc9_ + " screenHeight:" + _loc2_ + " contentWidth:" + _loc13_ + " contentHeight:" + _loc5_ + " scaleX:" + _loc1_," scaleY:" + _loc3_]);
         this._lastScaleX = _loc1_;
         this._lastScaleY = _loc3_;
      }
      
      private function readParamFromFile() : void
      {
         var _loc1_:FileStream = new FileStream();
         var _loc2_:File = File.applicationDirectory.resolvePath("paras.dat");
         if(!_loc2_.exists)
         {
            _logger.info("file " + _loc2_.nativePath + " is not exists");
            return;
         }
         _logger.info("read from file " + _loc2_.nativePath);
         _loc1_.open(_loc2_,"read");
         var _loc3_:String = _loc1_.readMultiByte(_loc1_.bytesAvailable,"utf-8");
         _loc1_.close();
         startByParams(_loc3_);
      }
      
      private function startByParams(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = decodeURIComponent(param1);
         _logger.info("参数:" + _loc3_);
         try
         {
            _params = JSON.parse(_loc3_);
            _loc2_ = int(_params.microPort);
            _logger.info("开始连接");
            _airJsAdapter = new AirJsAdapter(_loc2_);
            _airJsAdapter.addCallback("microExitLoader",onMicroExitLoader);
            _airJsAdapter.addCallback("microResize",onMicroResize);
            _airJsAdapter.addCallback("microSetVisible",onMicroSetVisible);
            _airJsAdapter.addCallback("microGettedFocus",onMicroGettedFocus);
            _airJsAdapter.addCallback("microLostFocus",onMicroLostFocus);
            _airJsAdapter.addCallback("microScale",onMicroScale);
            this.stage.nativeWindow.title = "SSJJ_FlashAir_Battle" + _loc2_;
            _airJsAdapter.connectHandle = onConnect;
            _airJsAdapter.connect();
         }
         catch(error:Error)
         {
            _logger.info("参数解析错误" + error.getStackTrace());
         }
      }
      
      private function onInvokeEvent(param1:InvokeEvent) : void
      {
         var _loc2_:Array = param1.arguments;
         if(0 == _loc2_.length)
         {
            _logger.info("无启动参数!!");
            return;
         }
         startByParams(_loc2_[0]);
      }
      
      private function onMicroExitLoader(param1:String) : void
      {
         NativeApplication.nativeApplication.exit();
         MultiApplicationUtil.appClosed();
      }
      
      private function onMicroResize(param1:String) : void
      {
         if(this._isRpg2)
         {
            return;
         }
         var _loc5_:Object = JSON.parse(param1);
         var _loc4_:Number = _loc5_.h - 50 - 36;
         _loc4_ = _loc4_ > 650 ? 650 : _loc4_;
         _loc4_ = _loc4_ < 0 ? 1 : _loc4_;
         var _loc3_:Number = _loc5_.w - 10 - 10;
         _loc3_ = _loc3_ > 1024 ? 1024 : _loc3_;
         _loc3_ = _loc3_ < 0 ? 1 : _loc3_;
         this.setSize(_loc3_,_loc4_);
         var _loc2_:Number = (_loc5_.w - _loc3_) * 0.5;
         _loc2_ = _loc2_ < 0 ? 0 : _loc2_;
         _logger.info("w:" + _loc3_);
         _logger.info("wX:" + _loc2_);
         _logger.info("size.x:" + _loc5_.x);
         _logger.info("size.y:" + _loc5_.y);
         this.setPosition(_loc5_.x + _loc2_,_loc5_.y + 50);
      }
      
      private function onMicroSetVisible(param1:String) : void
      {
         var _loc2_:Boolean = param1 == "true";
         this.stage.nativeWindow.visible = _loc2_;
      }
      
      private function onMicroScale(param1:String) : void
      {
         _scale = Number(param1);
         _logger.info("LobbyScale:::" + _scale);
         this.stage.nativeWindow.width = _scale * 1024;
         this.stage.nativeWindow.height = _scale * 650;
         _logger.info("stage.Scale1::" + this.stage.scaleX);
         _logger.info("stage.width1::" + this.stage.width);
         this.scaleX = this.scaleY = _scale;
      }
      
      private function onMicroGettedFocus(param1:String) : void
      {
         _logger.info("onMicroGettedFocus");
      }
      
      private function onMicroLostFocus(param1:String) : void
      {
         _logger.info("onMicroLostFocus");
      }
      
      private function onConnect() : void
      {
         _logger.info("连接成功");
         realInit();
      }
      
      private function realInit() : void
      {
         _logger.info("初始化");
         var _loc2_:IRemoteLog = new RemoteLogPost();
         PostErrorUtil.postProxy = _loc2_;
         PostLogUtil.postProxy = _loc2_;
         callJs("loader_preloading_step");
         LanguageConfig.instance.loadFromByteArray(new I18N());
         StringTool.initGameUnicodeFromText(LanguageConfig.getText("game_unicodes"));
         this.showLoader(LanguageConfig.getText("WORD_6666"));
         if(this._isRpg2)
         {
            this.setContentScaleFactor(1920,1080,0);
         }
         var _loc1_:Object = getParams();
         _logger.info("初始化参数",[_loc1_]);
         for(var _loc3_:String in _loc1_)
         {
            loginParam[_loc3_] = _loc1_[_loc3_];
         }
         if(_loc1_["resurl"])
         {
            GlobalVariable.resurl = decodeURIComponent(_loc1_["resurl"].toString());
            if(GlobalVariable.resurl.charAt(GlobalVariable.resurl.length - 1) != "/")
            {
               GlobalVariable.resurl += "/";
            }
         }
         if(_loc1_["resurl_bak"])
         {
            GlobalVariable.resurlBak = decodeURIComponent(_loc1_["resurl_bak"].toString());
            if(GlobalVariable.resurlBak.charAt(GlobalVariable.resurlBak.length - 1) != "/")
            {
               GlobalVariable.resurlBak += "/";
            }
         }
         if(_loc1_ && _loc1_["version"])
         {
            GlobalVariable.gameVersion = _loc1_["version"].toString();
         }
         if(_loc1_ && _loc1_["lobbyFileName"])
         {
            lobbyFileName = _loc1_["lobbyFileName"].toString();
         }
         if(_loc1_ && _loc1_["roleCreatorFileName"])
         {
            roleCreatorName = _loc1_["roleCreatorFileName"].toString();
         }
         if(_loc1_ && _loc1_["resurl"])
         {
            resurl = decodeURIComponent(_loc1_["resurl"].toString());
         }
         if(_loc1_ && _loc1_["timestamp"])
         {
            GlobalVariable.timestamp = _loc1_["timestamp"];
         }
         if(_loc1_ && _loc1_["username"])
         {
            GlobalVariable.username = _loc1_["username"];
         }
         if(_loc1_ && _loc1_["server"])
         {
            LoginManager.instance.setServerList([_loc1_["server"]]);
         }
         if(_loc1_ && _loc1_["platform"])
         {
            GlobalVariable.platform = _loc1_["platform"];
         }
         if(_loc1_ && null != _loc1_["serverId"])
         {
            GlobalVariable.serverId = _loc1_["serverId"];
         }
         if(_loc1_ && null != _loc1_["cdnIp"])
         {
            GlobalVariable.cdnIp = _loc1_["cdnIp"];
         }
         if(_loc1_ && null != _loc1_["cdnId"])
         {
            GlobalVariable.cdnId = _loc1_["cdnId"];
         }
         if(_loc1_ && null != _loc1_["isp"])
         {
            GlobalVariable.isp = _loc1_["isp"];
         }
         if(_loc1_ && null != _loc1_["isDebug"])
         {
            GlobalVariable.isDebugAccount = _loc1_["isDebug"];
         }
         if(_loc1_ && null != _loc1_["isadult"])
         {
            GlobalVariable.isadult = parseInt(_loc1_["isadult"]);
         }
         if(_loc1_ && null != _loc1_["sign"])
         {
            GlobalVariable.sign = _loc1_["sign"];
         }
         if(_loc1_ && null != _loc1_["versionList"])
         {
            GlobalVariable.versionList = _loc1_["versionList"];
         }
         if(_loc1_ && null != _loc1_["isMicroClient"])
         {
            GlobalVariable.isMicroClient = int(_loc1_["isMicroClient"]) == 1;
         }
         if(_loc1_ && null != _loc1_["microVersion"])
         {
            GlobalVariable.microVersion = _loc1_["microVersion"];
         }
         if(PlateformName.isTXplateform())
         {
            Security.loadPolicyFile("http://1251158332.cdn.myqcloud.com/1251158332/crossdomain.xml");
         }
         this.loaderInfo.uncaughtErrorEvents.addEventListener("uncaughtError",onUncaughtErrorHandler);
         setLoginData(_loc1_);
         this.loadConfig();
      }
      
      private function setRpg2WindowSize() : void
      {
         _logger.info("_isRpg2:" + this._isRpg2);
         if(this._isRpg2)
         {
            stage.displayState = "fullScreenInteractive";
            _logger.info("Capabilities.screenResolutionX" + Capabilities.screenResolutionX);
            _logger.info("Capabilities.screenResolutionY" + Capabilities.screenResolutionY);
            this.stage.nativeWindow.width = Capabilities.screenResolutionX;
            this.stage.nativeWindow.height = Capabilities.screenResolutionY;
            this.stage.nativeWindow.stage.nativeWindow.x = 0;
            this.stage.nativeWindow.stage.nativeWindow.y = 0;
            _logger.info("window.width" + this.stage.nativeWindow.width);
            _logger.info("window.height" + this.stage.nativeWindow.height);
         }
      }
      
      private function setLoginData(param1:Object) : void
      {
         _logger.info("flashVar:",[loginParam]);
         if(!loginVO)
         {
            loginVO = new LoginVO();
         }
         loginVO.username = param1["username"].toString();
         loginVO.isadult = parseInt(param1["isadult"].toString());
         loginVO.timestamp = param1["timestamp"].toString();
         loginVO.sign = param1["sign"].toString();
         loginVO.clientIp = param1["ip"].toString();
         if(null != loginParam["loginurl"])
         {
            loginVO.loginUrl = param1["loginurl"];
         }
         if(null != loginParam["extParams"])
         {
            try
            {
               loginVO.extParams = JSON.parse(param1["extParams"]);
            }
            catch(e:Error)
            {
               _logger.error("extParams解析错误:" + e.getStackTrace());
            }
         }
         if(loginVO.extParams == null)
         {
            loginVO.extParams = {
               "clientIp":loginVO.clientIp,
               "loginUrl":loginVO.loginUrl
            };
         }
         if(PlateformName.isTXplateform())
         {
            loginVO.qqIsYellowVip = param1["isYellowVip"];
            loginVO.qqIsYellowYearVip = param1["isYellowYearVip"];
            loginVO.qqYellowVipLevel = param1["yellowVipLevel"];
            loginVO.qqIsYellowHighVip = param1["isYellowHighVip"];
            loginVO.qqIsBlueVip = param1["isBlueVip"];
            loginVO.qqIsBlueYearVip = param1["isBlueYearVip"];
            loginVO.qqBlueVipLevel = param1["blueVipLevel"];
            loginVO.qqIsBlueHighVip = param1["isBlueHighVip"];
            loginVO.levelVip3366 = param1["levelVip3366"];
            loginVO.isTgpVip = param1["isTgpVip"];
            loginVO.xinyueType = param1["xinyueType"];
            loginVO.xinyueLevel = param1["xinyueLevel"];
            loginVO.guanjiaType = param1["guanjiaType"];
            if(null != param1["weiduanType"])
            {
               loginVO.qqWeiDuan = param1["weiduanType"];
            }
         }
      }
      
      private function loadConfig() : void
      {
         _logger.info("loadConfig");
         var _loc1_:URLLoader = new URLLoader();
         _loc1_.addEventListener("complete",onLoadConfigComplete);
         _loc1_.addEventListener("ioError",onLoadConfigIOError);
         _loc1_.addEventListener("securityError",onLoadConfigSecurityError);
         var _loc2_:URLRequest = new URLRequest(resurl + "config/hall_config.xml" + "?" + new Date().getTime());
         _logger.info("url:" + _loc2_.url);
         _loc1_.load(_loc2_);
      }
      
      private function onLoadConfigComplete(param1:Event) : void
      {
         _logger.info("onLoadConfigComplete");
         this.hallConfig = new XML(URLLoader(param1.target).data);
         if(hallConfig.hasOwnProperty("reportURL"))
         {
            PostErrorUtil.reportURL = hallConfig["reportURL"];
            PostLogUtil.reportURL = hallConfig["reportURL"];
         }
         if(hallConfig.hasOwnProperty("loginURL"))
         {
            GlobalVariable.loginURL = hallConfig["loginURL"];
         }
         if(hallConfig.hasOwnProperty("eventLogURL"))
         {
            this.setEventLogUrl(hallConfig["eventLogURL"]);
         }
         if(hallConfig.hasOwnProperty("servers"))
         {
            GlobalVariable.servers = hallConfig["servers"];
         }
         if(hallConfig.hasOwnProperty("compress"))
         {
            GlobalVariable.socketCompress = "true" == hallConfig["compress"];
         }
         if(hallConfig.hasOwnProperty("isShowLog") && hallConfig.isShowLog == "true")
         {
         }
         showConfig();
         LoginManager.instance.handler = this;
         LoginManager.instance.errorPoster = new ErrorPoster();
         LoginManager.instance.start();
      }
      
      public function onSelectSeverSuccess() : void
      {
         trace("onSelectSeverSuccess");
         AlertPanel.hide();
         LoginManager.instance.getUserCharacterState(loginVO);
      }
      
      public function onSelectSeverFail() : void
      {
         trace("onSelectSeverFail");
         AlertPanel.hide();
         this.connectErrorHandle();
      }
      
      public function onReconnect(param1:int) : void
      {
         trace("onReconnect:" + param1);
         AlertPanel.showReconnect(this,param1);
      }
      
      public function onMainError(param1:Event) : void
      {
         trace("onMainError:");
         this.connectErrorHandle();
      }
      
      public function onMainClose(param1:Event) : void
      {
         trace("onMainClose:");
         this.connectCloseHandle();
      }
      
      private function connectCloseHandle() : void
      {
         this.callJs("closed_by_loginServer");
         this.showReloginAlert();
      }
      
      private function connectErrorHandle() : void
      {
         this.callJs("connect_to_loginServer_error");
         this.showReloginAlert();
      }
      
      private function showReloginAlert() : void
      {
         AlertPanel.showAlert(this,LanguageConfig.getText("WORD_59"),onAlertClose);
      }
      
      private function onAlertClose() : void
      {
         if(this._isRpg2)
         {
            _airJsAdapter.call("exitAirGame","");
            return;
         }
         navigateToURL(new URLRequest(GlobalVariable.loginURL),"_self");
      }
      
      public function onGetUserCharacterState(param1:Boolean) : void
      {
         _fuiAssets = new FUIAssets();
         this.isNewCharacter = !param1;
         if(param1)
         {
            this._fuiAssets.loadAssets(this.loadLobby);
         }
         else
         {
            this._fuiAssets.loadAssets(this.loadRoleCreator);
         }
      }
      
      private function loadLobby() : void
      {
         this.showLoader(LanguageConfig.getText("WORD_6667"),1);
         this.lobbyLoader = new ModuleLoader(lobbyFileName,this.resurl,onSwfProgress,onLobbyComplete);
         this.lobbyLoader.startLoad();
      }
      
      private function loadRoleCreator() : void
      {
         this.showLoader(LanguageConfig.getText("WORD_6667"),1);
         this.roleCreatorLoader = new ModuleLoader(roleCreatorName,this.resurl,onSwfProgress,onRoleCreatorLoadComplete);
         this.roleCreatorLoader.startLoad();
      }
      
      private function onSwfProgress(param1:ProgressEvent) : void
      {
         if(null == this.loaderBar)
         {
            return;
         }
         this.loaderBar.setProgress(param1);
      }
      
      private function onLobbyComplete(param1:Loader) : void
      {
         _logger.info("onLobbyComplete");
         callJs("loader_hall_step");
         var _loc2_:Sprite = param1.content as Sprite;
         this.lobbyLoader.dispose();
         _loc2_["setJsCallable"](this._airJsAdapter);
         _loc2_["startLobby"](loginParam,hallConfig,loginVO,LoginManager.instance.loginMainStack,this.isNewCharacter);
         if(_loc2_.hasOwnProperty("setScale") && _loc2_["setScale"] is Function)
         {
            _loc2_["setScale"](_scale);
         }
         _logger.info("onLobbyComplete1");
         this.addChildAt(_loc2_,0);
         this.hideLoader();
         LoginManager.instance.mainDisable();
      }
      
      private function onRoleCreateComplete() : void
      {
         this.createRoleSprite = null;
         this.roleCreatorLoader.dispose();
         this.roleCreatorLoader = null;
         this.loadLobby();
      }
      
      private function onRoleCreatorLoadComplete(param1:Loader) : void
      {
         this.createRoleSprite = param1.content as Sprite;
         this.createRoleSprite["setJsCallable"](this._airJsAdapter);
         this.createRoleSprite["startRoleCreator"](loginParam,hallConfig,this.loginVO,LoginManager.instance.loginMainStack,onRoleCreateComplete);
         this.addChildAt(param1.content,0);
         this.hideLoader();
      }
      
      public function onUncaughtErrorHandler(param1:UncaughtErrorEvent) : void
      {
         PostUnexpectedErrorUtil.execute(param1);
         if(param1.error is Error)
         {
            trace("@PreLoader " + Error(param1.error).message + " e.eventPhase is " + param1.eventPhase);
         }
      }
      
      private function onLoadConfigIOError(param1:IOErrorEvent) : void
      {
         trace(param1.text);
         _logger.info("onLoadConfigIOError:" + param1.toString());
      }
      
      private function onLoadConfigSecurityError(param1:SecurityErrorEvent) : void
      {
         trace(param1.text);
         _logger.info("onLoadConfigSecurityError:" + param1.toString());
      }
      
      private function callJs(param1:String, param2:Array = null) : void
      {
         if(ExternalInterface.available)
         {
            try
            {
               ExternalInterface.call("saveStage",param1);
            }
            catch(e:Error)
            {
            }
         }
      }
      
      private function setEventLogUrl(param1:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("setEventUrl",param1);
         }
      }
      
      private function showLoader(param1:String = null, param2:Number = 100) : void
      {
         if(null == this.loaderBar)
         {
            this.loaderBar = new PreLoaderBar(this._isRpg2);
         }
         this.addChild(this.loaderBar);
         if(null != param1)
         {
            this.loaderBar.setDesc(param1);
         }
         this.loaderBar.initRate(param2);
      }
      
      private function hideLoader() : void
      {
         if(null != this.loaderBar && null != this.loaderBar.parent)
         {
            this.loaderBar.parent.removeChild(this.loaderBar);
            this.loaderBar = null;
         }
      }
      
      public function startConsole() : void
      {
         LogManager.start(this.stage,"[wooduanlog]");
         Cc.addSlashCommand("showConfig",showConfig,"show start params,(same as username、version)");
      }
      
      private function showConfig() : void
      {
         var _loc2_:Array = null;
         _logger.info("start params");
         _logger.info("username:",[GlobalVariable.username]);
         _logger.info("isDebugAccount:",[GlobalVariable.isDebugAccount]);
         _logger.info("isadult:",[GlobalVariable.isadult]);
         _logger.info("gameVersion:",[GlobalVariable.gameVersion]);
         _logger.info("platform:",[GlobalVariable.platform]);
         _logger.info("serverId:",[GlobalVariable.serverId]);
         _logger.info("cdnIp:",[GlobalVariable.cdnIp]);
         _logger.info("cdnId:",[GlobalVariable.cdnId]);
         _logger.info("isp:",[GlobalVariable.isp]);
         if(GlobalVariable.versionList)
         {
            _loc2_ = GlobalVariable.versionList.substr(1,GlobalVariable.versionList.length - 2).split(",");
            for each(var _loc1_:String in _loc2_)
            {
               _logger.info(_loc1_);
            }
         }
         _logger.info("");
      }
   }
}

import errorutil.PostErrorUtil;
import lobbyNet.IErrorPoster;

class ErrorPoster implements IErrorPoster
{
   
   public function ErrorPoster()
   {
      super();
   }
   
   public function postMessage(param1:String, param2:* = 0, ... rest) : void
   {
      PostErrorUtil.postMsg(param1,param2,rest);
   }
}
