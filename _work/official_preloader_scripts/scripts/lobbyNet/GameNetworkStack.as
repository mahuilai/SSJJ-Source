package lobbyNet
{
   import flash.events.EventDispatcher;
   import flash.net.Socket;
   import lobbyNet.logic.BaseLogic;
   import lobbyNet.protocol.Protocol;
   
   public class GameNetworkStack extends EventDispatcher
   {
      
      private var _rpcManager:RpcManager = null;
      
      private var _baseLogic:BaseLogic = null;
      
      public function GameNetworkStack(param1:String, param2:uint, param3:BaseLogic)
      {
         super();
         this._baseLogic = param3;
         this._baseLogic.addEventListener("callRemoteEvent",onCallRemote);
         this._rpcManager = new RpcManager(param1,param2);
      }
      
      public function set backFun(param1:Function) : void
      {
         this._rpcManager.backFun = param1;
      }
      
      public function reset(param1:BaseLogic, param2:Protocol) : void
      {
         this.removeCurLogic();
         this._baseLogic = param1;
         this._baseLogic.addEventListener("callRemoteEvent",onCallRemote);
         param2.registerRPC(this._rpcManager,this._baseLogic);
      }
      
      public function removeCurLogic() : void
      {
         if(null != this._baseLogic)
         {
            this._baseLogic.removeEventListener("callRemoteEvent",onCallRemote);
            this._baseLogic = null;
         }
      }
      
      private function onCallRemote(param1:CallRemoteEvent) : void
      {
         this._rpcManager.callRemote(param1.funcName,param1.params);
      }
      
      public function callRemote(param1:String, param2:Array = null) : void
      {
         this._rpcManager.callRemote(param1,param2);
      }
      
      public function start(param1:String = null, param2:uint = 0) : void
      {
         this._rpcManager.start(param1,param2);
      }
      
      public function setSocket(param1:Socket) : void
      {
         this._rpcManager.setSocket(param1);
      }
      
      public function setTCPSocket(param1:TcpSocket) : void
      {
         this._rpcManager.serverSocket = param1;
      }
      
      public function close() : void
      {
         this._rpcManager.disConnect();
      }
      
      private function dispose() : void
      {
         this._baseLogic.removeEventListener("callRemoteEvent",onCallRemote);
      }
      
      public function socketCompress(param1:Boolean) : void
      {
         this._rpcManager.compress = param1;
      }
      
      public function get isSocketCompress() : Boolean
      {
         return _rpcManager.compress;
      }
      
      public function set isDebug(param1:Boolean) : void
      {
         this._rpcManager.isDebug = param1;
      }
      
      public function get socket() : TcpSocket
      {
         return this._rpcManager.serverSocket;
      }
      
      public function set protocol(param1:Protocol) : void
      {
         param1.registerRPC(this._rpcManager,this._baseLogic);
      }
   }
}

