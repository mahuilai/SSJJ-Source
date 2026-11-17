package lobbyNet
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import lobbyNet.error.LobbyError;
   import org.as3commons.logging.api.ILogger;
   import org.as3commons.logging.api.getLogger;
   import tools.StringUtils;
   
   public class ServerSelector
   {
      
      public static const SERVERTYPE_LOGIN:String = "LOGIN";
      
      public static const SERVERTYPE_CHANNEL:String = "CHANNEL";
      
      private static const _logger:ILogger = getLogger(ServerSelector);
      
      private var _serverList:Array = null;
      
      private var onSelectSeverSuccess:Function = null;
      
      private var onSelectSeverFail:Function = null;
      
      private var onReconnect:Function = null;
      
      private var serverIndex:int = 0;
      
      private var parallelNum:int = 1;
      
      private var inUseSocketPool:Dictionary = null;
      
      private var connectTimer:Timer = null;
      
      private const SOCK_CONNECTING:int = 0;
      
      private const SOCK_CONNECTED:int = 1;
      
      private const SOCK_FAILED:int = 2;
      
      private var connected:Boolean = false;
      
      public var isWorking:Boolean = false;
      
      private var _serverType:String;
      
      private var _errorPoster:IErrorPoster = null;
      
      public function ServerSelector(param1:Array, param2:Function, param3:Function, param4:Function = null)
      {
         super();
         this.serverList = param1;
         this.onSelectSeverSuccess = param2;
         this.onSelectSeverFail = param3;
         this.onReconnect = param4;
         connectTimer = new Timer(20000,1);
         connectTimer.addEventListener("timer",onTimerOut);
      }
      
      public function set errorPoster(param1:IErrorPoster) : void
      {
         this._errorPoster = param1;
      }
      
      public function start(param1:String) : void
      {
         _serverType = param1;
         serverIndex = 0;
         parallelNum = 1;
         connected = false;
         connectTimer.delay = Math.max(serverList.length,20) * 1000;
         startLogin();
      }
      
      public function stop() : void
      {
         for(var _loc1_ in inUseSocketPool)
         {
            _loc1_.close();
            _loc1_.removeEventListener("connect",connectHandler);
            _loc1_.removeEventListener("PACKET_ARRIVE",dataHandler);
            _loc1_.removeEventListener("ioError",ioErrorHandler);
            _loc1_.removeEventListener("securityError",secErrorHandler);
            _loc1_.removeEventListener("close",closeHandler);
         }
         connected = false;
         connectTimer.stop();
         isWorking = false;
      }
      
      private function startLogin() : void
      {
         var _loc5_:int = 0;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:int = 0;
         var _loc1_:TcpSocket = null;
         isWorking = true;
         if(serverIndex >= this.serverList.length)
         {
            isWorking = false;
            onSelectSeverFail();
            return;
         }
         if(serverIndex != 0)
         {
            if(onReconnect != null)
            {
               onReconnect(connectTimer.delay / 1000);
            }
            parallelNum = serverList.length - parallelNum;
            postServerInfo("onReconnect",LobbyError["ID_" + _serverType + "_CONNECT_ONRECONNECT"]);
         }
         connectTimer.reset();
         inUseSocketPool = new Dictionary();
         _loc5_ = serverIndex;
         while(_loc5_ < serverIndex + parallelNum && _loc5_ < this.serverList.length)
         {
            _loc3_ = this.serverList[_loc5_];
            _loc4_ = _loc3_.split(":")[0];
            _loc2_ = int(_loc3_.split(":")[1]);
            if(!(StringUtils.isEmpty(_loc4_) || _loc2_ == 0))
            {
               _loc1_ = new TcpSocket(_loc4_,_loc2_);
               _loc1_.timeout = 10000;
               _loc1_.addEventListener("connect",connectHandler);
               _loc1_.addEventListener("PACKET_ARRIVE",dataHandler);
               _loc1_.addEventListener("ioError",ioErrorHandler);
               _loc1_.addEventListener("securityError",secErrorHandler);
               _loc1_.addEventListener("close",closeHandler);
               _loc1_.connect();
               inUseSocketPool[_loc1_] = {
                  "state":0,
                  "ip":_loc4_,
                  "port":_loc2_
               };
               trace("connect ip:" + _loc4_ + " port:" + _loc2_);
               _logger.info(_serverType + " connect ip:" + _loc4_ + " port:" + _loc2_);
            }
            _loc5_++;
         }
         serverIndex += parallelNum;
         connectTimer.start();
      }
      
      protected function closeHandler(param1:Event) : void
      {
         var _loc2_:TcpSocket = param1.currentTarget as TcpSocket;
         socketConnectFailed(_loc2_);
      }
      
      private function ioErrorHandler(param1:IOErrorEvent) : void
      {
         var _loc2_:TcpSocket = param1.currentTarget as TcpSocket;
         postServerInfo("connect failed ioError ip:" + inUseSocketPool[_loc2_].ip + " port:" + inUseSocketPool[_loc2_].port,LobbyError["ID_" + _serverType + "_CONNECT_IOERROR"],inUseSocketPool[_loc2_].ip,inUseSocketPool[_loc2_].port);
         socketConnectFailed(_loc2_);
      }
      
      private function secErrorHandler(param1:SecurityErrorEvent) : void
      {
         var _loc2_:TcpSocket = param1.currentTarget as TcpSocket;
         postServerInfo("connect failed secError ip:" + inUseSocketPool[_loc2_].ip + " port:" + inUseSocketPool[_loc2_].port,LobbyError["ID_" + _serverType + "_CONNECT_SECERROR"],inUseSocketPool[_loc2_].ip,inUseSocketPool[_loc2_].port);
         socketConnectFailed(_loc2_);
      }
      
      private function socketConnectFailed(param1:TcpSocket) : void
      {
         trace("scoket connect failed");
         param1.close();
         param1.removeEventListener("connect",connectHandler);
         param1.removeEventListener("PACKET_ARRIVE",dataHandler);
         param1.removeEventListener("ioError",ioErrorHandler);
         param1.removeEventListener("securityError",secErrorHandler);
         param1.removeEventListener("close",closeHandler);
         if(inUseSocketPool[param1] == undefined || inUseSocketPool[param1].state == 2)
         {
            return;
         }
         inUseSocketPool[param1].state = 2;
         for(var _loc2_ in inUseSocketPool)
         {
            if(inUseSocketPool[_loc2_].state != 2)
            {
               return;
            }
         }
         this.connectTimer.stop();
         startLogin();
      }
      
      private function dataHandler(param1:PacketEvent) : void
      {
         trace("send tauch data call back");
         var _loc2_:TcpSocket = param1.currentTarget as TcpSocket;
         severSuccess(_loc2_);
      }
      
      private function connectHandler(param1:Event) : void
      {
         if(connected)
         {
            return;
         }
         var _loc2_:TcpSocket = param1.currentTarget as TcpSocket;
         _loc2_.call("ping",null);
         trace("send tauch data");
      }
      
      private function severSuccess(param1:TcpSocket) : void
      {
         param1.removeEventListener("connect",connectHandler);
         param1.removeEventListener("PACKET_ARRIVE",dataHandler);
         param1.removeEventListener("ioError",ioErrorHandler);
         param1.removeEventListener("securityError",secErrorHandler);
         param1.removeEventListener("close",closeHandler);
         inUseSocketPool[param1].state = 1;
         for(var _loc2_ in inUseSocketPool)
         {
            if(_loc2_ != param1)
            {
               _loc2_.close();
               _loc2_.removeEventListener("connect",connectHandler);
               _loc2_.removeEventListener("PACKET_ARRIVE",dataHandler);
               _loc2_.removeEventListener("ioError",ioErrorHandler);
               _loc2_.removeEventListener("securityError",secErrorHandler);
               _loc2_.removeEventListener("close",closeHandler);
            }
         }
         connected = true;
         connectTimer.stop();
         isWorking = false;
         onSelectSeverSuccess(param1,inUseSocketPool[param1].ip,inUseSocketPool[param1].port);
         if(parallelNum > 1)
         {
            postServerInfo("connect success ip:" + inUseSocketPool[param1].ip + " port:" + inUseSocketPool[param1].port,LobbyError["ID_" + _serverType + "_CONNECT_SUCCESS"],inUseSocketPool[param1].ip,inUseSocketPool[param1].port);
         }
         _logger.info(_serverType + " connect success ip:" + inUseSocketPool[param1].ip + " port:" + inUseSocketPool[param1].port);
      }
      
      private function postServerInfo(param1:String, param2:int = 0, param3:String = null, param4:String = null) : void
      {
         param1 = _serverType + " connect: " + param1;
         _logger.info(param1);
         if(param3 && param4)
         {
            this.postMsg(param1,param2,param3,param4);
         }
         else
         {
            this.postMsg(param1,param2);
         }
      }
      
      private function onTimerOut(param1:TimerEvent) : void
      {
         var _loc2_:TcpSocket = null;
         postServerInfo("connect failed timerOut",LobbyError["ID_" + _serverType + "_CONNECT_TIMEROUT"]);
         for(var _loc3_ in inUseSocketPool)
         {
            if(inUseSocketPool[_loc3_].state == 0)
            {
               _loc2_ = _loc3_;
               _loc2_.close();
               _loc2_.removeEventListener("connect",connectHandler);
               _loc2_.removeEventListener("PACKET_ARRIVE",dataHandler);
               _loc2_.removeEventListener("ioError",ioErrorHandler);
               _loc2_.removeEventListener("securityError",secErrorHandler);
               _loc2_.removeEventListener("close",closeHandler);
            }
         }
         this.connectTimer.stop();
         startLogin();
      }
      
      public function set serverList(param1:Array) : void
      {
         _serverList = param1;
      }
      
      public function get serverList() : Array
      {
         return _serverList;
      }
      
      private function postMsg(param1:String, param2:* = 0, ... rest) : void
      {
         if(null == this._errorPoster)
         {
            return;
         }
         this._errorPoster.postMessage(param1,param2,rest);
      }
   }
}

