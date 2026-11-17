package lobbyNet
{
   public class Constants
   {
      
      private static var _COMMAND_HEART_BEAT:String = "heartBeat";
      
      public function Constants()
      {
         super();
      }
      
      public static function get COMMAND_HEART_BEAT() : String
      {
         return _COMMAND_HEART_BEAT;
      }
      
      public static function setHeartBeatFuncName(param1:String) : void
      {
         _COMMAND_HEART_BEAT = param1;
      }
   }
}

