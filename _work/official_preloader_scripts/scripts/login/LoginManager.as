package login
{
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import lobby.common.GlobalVariable;
   import lobby.vo.LoginVO;
   import lobbyNet.Constants;
   import lobbyNet.GameNetworkStack;
   import lobbyNet.IErrorPoster;
   import lobbyNet.ServerSelector;
   import lobbyNet.TcpSocket;
   import login.interfaces.ILoginHandler;
   import login.utils.MiniSharedObject;
   import org.as3commons.logging.api.ILogger;
   import org.as3commons.logging.api.getLogger;
   import tools.Singleton;
   import tools.StringUtils;
   
   public class LoginManager
   {
      
      private static const _logger:ILogger = getLogger(LoginManager);
      
      private var _handler:ILoginHandler = null;
      
      private var _errorPoster:IErrorPoster = null;
      
      private var _serverList:Array = null;
      
      private var socketCompress:Boolean = false;
      
      private var _mainStack:GameNetworkStack = null;
      
      private var _mainTimer:Timer = null;
      
      private var _loginLogic:LoginLogic = null;
      
      private var _loginSelector:ServerSelector = null;
      
      public function LoginManager()
      {
         super();
         Singleton.check(this);
      }
      
      public static function get instance() : LoginManager
      {
         return Singleton.getInstanceOrCreate(LoginManager) as LoginManager;
      }
      
      public function set handler(param1:ILoginHandler) : void
      {
         this._handler = param1;
      }
      
      public function get handler() : ILoginHandler
      {
         return this._handler;
      }
      
      public function set errorPoster(param1:IErrorPoster) : void
      {
         this._errorPoster = param1;
         if(null != this._loginSelector)
         {
            this._loginSelector.errorPoster = param1;
         }
      }
      
      public function start() : void
      {
         if(null == this._serverList)
         {
            this._serverList = parseLoginServerPortList(GlobalVariable.servers);
         }
         this.connect();
      }
      
      public function setServerList(param1:Array) : void
      {
         this._serverList = param1;
      }
      
      private function connect() : void
      {
         this.createSocket();
      }
      
      private function get isDebugAccount() : Boolean
      {
         return GlobalVariable.isDebugAccount;
      }
      
      private function createSocket() : void
      {
         if(null == this._mainStack)
         {
            this._loginLogic = new LoginLogic();
            this._mainStack = new GameNetworkStack("",0,this._loginLogic);
            this._mainStack.protocol = new LoginProtocol();
            this._mainStack.socketCompress(this.socketCompress);
            this._mainStack.isDebug = this.isDebugAccount;
            _logger.info("main socket compress:" + this.socketCompress);
         }
         var _loc2_:Array = this._serverList;
         var _loc1_:Object = MiniSharedObject.getData("LOGIN_SERVER");
         if(_loc1_ && _loc2_.indexOf(_loc1_.server) > -1)
         {
            _loc2_.splice(_loc2_.indexOf(_loc1_.server),1);
            _loc2_.unshift(_loc1_.server);
         }
         _loginSelector = new ServerSelector(_loc2_,onSelectSeverSuccess,onSelectSeverFail,onReconnect);
         _loginSelector.errorPoster = this._errorPoster;
         _loginSelector.start("LOGIN");
      }
      
      private function parseLoginServerPortList(param1:String) : Array
      {
         var _loc2_:Array = [];
         for each(var _loc3_:String in param1.split("|"))
         {
            if(StringUtils.isEmpty(_loc3_) == false && _loc3_.indexOf(":") > -1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      private function onSelectSeverSuccess(param1:TcpSocket, param2:String, param3:int) : void
      {
         this._mainStack.setTCPSocket(param1);
         this.mainEnable();
         if(null == this._mainTimer)
         {
            this._mainTimer = new Timer(30000);
         }
         this._mainTimer.addEventListener("timer",onHeartBeat);
         this._mainTimer.start();
         MiniSharedObject.removeData("LOGIN_SERVER");
         MiniSharedObject.setData("LOGIN_SERVER",{"server":param2 + ":" + param3});
         this._handler.onSelectSeverSuccess();
      }
      
      public function getUserCharacterState(param1:LoginVO) : void
      {
         this._loginLogic.getUserCharacterState(GlobalVariable.username,GlobalVariable.timestamp,GlobalVariable.isadult,GlobalVariable.sign,param1.extParams);
      }
      
      private function onSelectSeverFail() : void
      {
         this._handler.onSelectSeverFail();
      }
      
      private function onReconnect(param1:int) : void
      {
         this._handler.onReconnect(param1);
      }
      
      private function onHeartBeat(param1:TimerEvent) : void
      {
         this._mainStack.callRemote(Constants.COMMAND_HEART_BEAT);
         trace("preloader heartBeat");
      }
      
      public function mainEnable() : void
      {
         _mainStack.socket.addEventListener("close",onMainClose);
         _mainStack.socket.addEventListener("ioError",onMainError);
         _mainStack.socket.addEventListener("securityError",onMainError);
      }
      
      public function mainDisable() : void
      {
         _mainStack.socket.removeEventListener("close",onMainClose);
         _mainStack.socket.removeEventListener("ioError",onMainError);
         _mainStack.socket.removeEventListener("securityError",onMainError);
      }
      
      public function get loginMainStack() : GameNetworkStack
      {
         return this._mainStack;
      }
      
      private function onMainError(param1:Event) : void
      {
         trace("main connection error");
         this._handler.onMainError(param1);
      }
      
      private function onMainClose(param1:Event) : void
      {
         trace("onMainClose");
         this._handler.onMainError(param1);
      }
   }
}

