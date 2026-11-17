package lobbyNet
{
   import flash.events.Event;
   
   public class CallRemoteEvent extends Event
   {
      
      public static const CALL_REMOTE_EVENT:String = "callRemoteEvent";
      
      public var params:Array = null;
      
      public var funcName:String;
      
      public function CallRemoteEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

