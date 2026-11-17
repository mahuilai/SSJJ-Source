package lobbyNet.protocol
{
   import lobbyNet.RpcManager;
   import lobbyNet.logic.BaseLogic;
   
   public class Protocol
   {
      
      public function Protocol()
      {
         super();
         registerRemoteClass();
      }
      
      public function registerRPC(param1:RpcManager, param2:BaseLogic) : void
      {
      }
      
      public function unRegisterRPC(param1:RpcManager, param2:BaseLogic) : void
      {
      }
      
      protected function registerRemoteClass() : void
      {
      }
   }
}

