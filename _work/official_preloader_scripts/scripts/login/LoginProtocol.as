package login
{
   import flash.net.registerClassAlias;
   import lobbyNet.APC;
   import lobbyNet.RpcManager;
   import lobbyNet.logic.BaseLogic;
   import lobbyNet.protocol.Protocol;
   
   public class LoginProtocol extends Protocol
   {
      
      public function LoginProtocol()
      {
         super();
      }
      
      override protected function registerRemoteClass() : void
      {
         registerClassAlias("common.net.APC",APC);
      }
      
      override public function registerRPC(param1:RpcManager, param2:BaseLogic) : void
      {
         var _loc3_:LoginLogic = param2 as LoginLogic;
         param1.registerRPC("callbackGetUserCharacterState",_loc3_.callbackGetUserCharacterState);
      }
   }
}

