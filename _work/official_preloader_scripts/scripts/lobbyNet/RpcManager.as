package lobbyNet
{
   import flash.net.Socket;
   import org.as3commons.logging.api.ILogger;
   import org.as3commons.logging.api.getLogger;
   
   public class RpcManager
   {
      
      private static const _logger:ILogger = getLogger(RpcManager,"remote");
      
      private var funcMap:Object = {};
      
      private var _serverSocket:TcpSocket;
      
      private var _compress:Boolean;
      
      private var _isDebug:Boolean;
      
      private var _stashList:Array;
      
      private var _stashExc:Array;
      
      private var _backFun:Function;
      
      private var _responseHandler:Function = null;
      
      public function RpcManager(param1:String, param2:uint)
      {
         super();
         this._serverSocket = new TcpSocket(param1,param2);
      }
      
      public function start(param1:String = null, param2:uint = 0) : void
      {
         this._serverSocket.connect(param1,param2);
         this._serverSocket.addEventListener("PACKET_ARRIVE",packetHandler);
      }
      
      public function setSocket(param1:Socket) : void
      {
         this._serverSocket.setSocket(param1);
         this._serverSocket.compress = _compress;
         this._serverSocket.addEventListener("PACKET_ARRIVE",packetHandler);
      }
      
      internal function set serverSocket(param1:TcpSocket) : void
      {
         _serverSocket = param1;
         this._serverSocket.compress = _compress;
         this._serverSocket.addEventListener("PACKET_ARRIVE",packetHandler);
      }
      
      public function stash(param1:Array) : void
      {
         _stashExc = param1;
         _stashList = [];
      }
      
      public function stopStash() : void
      {
         var _loc2_:Array = _stashList;
         _stashList = null;
         _stashExc = null;
         for each(var _loc1_:PacketEvent in _loc2_)
         {
            packetHandler(_loc1_);
         }
      }
      
      private function packetHandler(param1:PacketEvent) : void
      {
         if(param1.apc == null)
         {
            throw new Error("illegal packetEvent");
         }
         var _loc3_:String = param1.apc.functionName;
         var _loc2_:Array = funcMap[_loc3_];
         trace("    server " + _loc3_);
         if(_loc2_ == null || _loc2_.length == 0)
         {
            return;
         }
         if(_stashList && _stashExc && _stashExc.indexOf(_loc3_) == -1)
         {
            if(_loc3_ != "callBackChangeRoomData" && _loc3_ != "callBackAddMessage" && _loc3_ != "heartBeat" && _loc3_ != "callbackSyncPalRoomData" && _loc3_ != "callbackEnterPalRoom")
            {
               _logger.info("stash callBack:",[_loc3_,"params:",param1.apc.parameters]);
            }
            _stashList.push(param1);
            return;
         }
         if(_loc3_ == "callBackAddBattleMessage")
         {
            trace(param1.apc.parameters);
         }
         if(_loc3_ != "callBackChangeRoomData" && _loc3_ != "callBackAddMessage" && _loc3_ != "callbackApplyChatWindowId" && _loc3_ != "callbackSyncPalRoomData" && _loc3_ != "callbackEnterPalRoom")
         {
            _logger.info("callBack:",[_loc3_,"params:",param1.apc.parameters]);
         }
         if(Boolean(this._backFun))
         {
            this._backFun("msgtype_ingame_behavior",1,_loc3_);
         }
         if(null != _responseHandler)
         {
            _responseHandler.apply(null,[_loc3_]);
         }
         for each(var _loc4_:Function in _loc2_)
         {
            _loc4_.apply(null,param1.apc.parameters);
         }
      }
      
      public function set responseHandler(param1:Function) : void
      {
         this._responseHandler = param1;
      }
      
      public function registerRPC(param1:String, param2:Function) : void
      {
         if(null == param2)
         {
            throw new Error("null funcPointer");
         }
         if(funcMap[param1] == null)
         {
            funcMap[param1] = [];
         }
         if(funcMap[param1].indexOf(param2) > -1)
         {
            throw new Error("rpc " + param1 + " already exist");
         }
         funcMap[param1].push(param2);
      }
      
      public function unRegisterRPC(param1:String, param2:Function) : void
      {
         if(null == funcMap[param1])
         {
            return;
         }
         if(funcMap[param1].indexOf(param2) > -1)
         {
            (funcMap[param1] as Array).splice(funcMap[param1].indexOf(param2),1);
         }
         if((funcMap[param1] as Array).length == 0)
         {
            funcMap[param1] = null;
         }
      }
      
      public function callRemote(param1:String, param2:Array = null) : void
      {
         _serverSocket.call(param1,param2,_isDebug);
         _logger.info("callRemote:",[param1,"params:",param2]);
      }
      
      public function hasCallback(param1:String) : Boolean
      {
         return null != funcMap[param1];
      }
      
      public function disConnect() : void
      {
         this._serverSocket.close();
      }
      
      internal function get serverSocket() : TcpSocket
      {
         return _serverSocket;
      }
      
      public function set compress(param1:Boolean) : void
      {
         _compress = param1;
         if(_serverSocket)
         {
            _serverSocket.compress = param1;
         }
      }
      
      public function get compress() : Boolean
      {
         return _compress;
      }
      
      public function set isDebug(param1:Boolean) : void
      {
         _isDebug = param1;
      }
      
      public function get isDebug() : Boolean
      {
         return _isDebug;
      }
      
      public function set backFun(param1:Function) : void
      {
         _backFun = param1;
      }
   }
}

