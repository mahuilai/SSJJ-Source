package login
{
   import lobbyNet.logic.BaseLogic;
   
   public class LoginLogic extends BaseLogic
   {
      
      public function LoginLogic()
      {
         super();
      }
      
      public function getUserCharacterState(param1:String, param2:String, param3:int, param4:String, param5:Object) : void
      {
         callRemote("getUserCharacterState",[param1,param2,param3,param4,param5]);
      }
      
      public function callbackGetUserCharacterState(param1:Boolean) : void
      {
         trace("callbackGetUserCharacterState:" + param1);
         LoginManager.instance.handler.onGetUserCharacterState(param1);
      }
   }
}

