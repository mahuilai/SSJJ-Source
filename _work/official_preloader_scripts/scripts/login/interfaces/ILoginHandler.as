package login.interfaces
{
   import flash.events.Event;
   
   public interface ILoginHandler
   {
      
      function onSelectSeverSuccess() : void;
      
      function onSelectSeverFail() : void;
      
      function onReconnect(param1:int) : void;
      
      function onMainError(param1:Event) : void;
      
      function onMainClose(param1:Event) : void;
      
      function onGetUserCharacterState(param1:Boolean) : void;
   }
}

