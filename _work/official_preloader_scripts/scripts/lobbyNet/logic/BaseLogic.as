package lobbyNet.logic
{
   import flash.events.EventDispatcher;
   import lobbyNet.CallRemoteEvent;
   import lobbyNet.Constants;
   
   public class BaseLogic extends EventDispatcher
   {
      
      public function BaseLogic()
      {
         super();
      }
      
      protected function callRemote(param1:String, param2:Array = null) : void
      {
         var _loc3_:CallRemoteEvent = new CallRemoteEvent("callRemoteEvent");
         _loc3_.funcName = param1;
         _loc3_.params = param2;
         dispatchEvent(_loc3_);
         if(Constants.COMMAND_HEART_BEAT != param1)
         {
            trace("client    " + param1);
         }
      }
      
      public function heartBeat() : void
      {
         callRemote(Constants.COMMAND_HEART_BEAT);
      }
   }
}

